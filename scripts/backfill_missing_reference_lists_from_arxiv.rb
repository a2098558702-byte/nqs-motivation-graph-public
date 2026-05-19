#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"
require "net/http"
require "rbconfig"
require "uri"
require "zlib"

ROOT = File.expand_path("..", __dir__)
GRAPH = File.join(ROOT, "current_coverage_graph_v0")
OUT = File.join(ROOT, "citation_reference_backfill_v0")
CACHE = File.join(OUT, "cache")
TMP = File.join(OUT, "tmp")
STATUS = File.join(OUT, "reference_backfill_status.csv")

STATUS_HEADERS = %w[
  source_paper_id title url source_wave arxiv_id status download_url
  destination_dir files_written notes
].freeze

def read_csv(path)
  CSV.read(path, headers: true).map(&:to_h)
end

def write_csv(path, headers, rows)
  CSV.open(path, "w", write_headers: true, headers: headers) do |csv|
    rows.each { |row| csv << headers.map { |h| row[h] } }
  end
end

def normalize_arxiv_id(value)
  text = value.to_s.downcase
  text = text[%r{arxiv\.org/(?:abs|pdf|e-print)/([^?\s/]+)}, 1] || text
  text = text.sub(/\.pdf\z/, "")
  text.sub(/v\d+\z/, "")
end

def source_text_dir(row)
  arxiv_id = normalize_arxiv_id(row["url"])
  text_root = File.join(ROOT, "extraction_waves", row["source_wave"], "text")
  existing = Dir.exist?(text_root) ? Dir.children(text_root).find do |name|
    File.directory?(File.join(text_root, name)) && normalize_arxiv_id(name).start_with?(arxiv_id)
  end : nil
  dir = File.join(text_root, existing || arxiv_id)
  FileUtils.mkdir_p(dir)
  dir
end

def fetch_with_redirects(url, limit = 5)
  raise "too many redirects for #{url}" if limit <= 0

  uri = URI(url)
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 120) do |http|
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "Codex reference-list backfill script"
    http.request(request)
  end

  case response
  when Net::HTTPSuccess
    response.body
  when Net::HTTPRedirection
    fetch_with_redirects(URI.join(url, response["location"]).to_s, limit - 1)
  else
    raise "HTTP #{response.code} for #{url}"
  end
end

def download_eprint(arxiv_id)
  FileUtils.mkdir_p(CACHE)
  path = File.join(CACHE, "#{arxiv_id}.eprint")
  return path if File.exist?(path) && File.size(path).positive?

  url = "https://arxiv.org/e-print/#{arxiv_id}"
  File.binwrite(path, fetch_with_redirects(url))
  path
end

def extract_source_package(package_path, arxiv_id)
  package_tmp = File.join(TMP, arxiv_id)
  FileUtils.rm_rf(package_tmp)
  FileUtils.mkdir_p(package_tmp)

  tar_ok = system("tar", "-xzf", package_path, "-C", package_tmp, out: File::NULL, err: File::NULL)
  return package_tmp if tar_ok

  begin
    Zlib::GzipReader.open(package_path) do |gz|
      File.binwrite(File.join(package_tmp, "#{arxiv_id}.tex"), gz.read)
    end
  rescue Zlib::GzipFile::Error
    File.binwrite(File.join(package_tmp, "#{arxiv_id}.tex"), File.binread(package_path))
  end

  package_tmp
end

def files_under(dir)
  Dir.glob(File.join(dir, "**", "*")).select { |path| File.file?(path) }
end

def actual_reference_list?(path)
  basename = File.basename(path).downcase
  ext = File.extname(path).downcase
  ext == ".bbl" || (ext == ".tex" && basename.include?("references"))
end

def safe_backfill_name(path)
  basename = File.basename(path)
  basename = basename.gsub(/[^A-Za-z0-9._-]+/, "_")
  "citation_backfill_#{basename}"
end

def copy_reference_files(paths, dest_dir)
  paths.map do |path|
    dest = File.join(dest_dir, safe_backfill_name(path))
    FileUtils.cp(path, dest)
    dest
  end
end

def extract_thebibliography(files, dest_dir)
  tex_files = files.select { |path| File.extname(path).downcase == ".tex" }
  blocks = []
  tex_files.each do |path|
    text = File.binread(path).encode("UTF-8", invalid: :replace, undef: :replace, replace: " ")
    text.scan(/\\begin\{thebibliography\}.*?\\end\{thebibliography\}/m) do |match|
      blocks << "% source: #{path}\n#{match}\n"
    end
  end
  return [] if blocks.empty?

  dest = File.join(dest_dir, "citation_backfill_thebibliography.bbl")
  File.write(dest, blocks.join("\n"))
  [dest]
end

def missing_reference_rows
  graph_builder = File.join(ROOT, "scripts", "build_current_coverage_graph_v0.rb")
  system(RbConfig.ruby, graph_builder) || abort("Graph rebuild failed before backfill.")

  coverage = read_csv(File.join(GRAPH, "paper_citation_source_coverage.csv"))
  paper_index = read_csv(File.join(GRAPH, "paper_index.csv")).each_with_object({}) do |row, index|
    index[row["source_paper_id"]] = row
  end

  coverage.select { |row| row["reference_file_count"].to_i.zero? }.map do |row|
    paper_index.fetch(row["source_paper_id"]).merge(row)
  end
end

FileUtils.mkdir_p(OUT)
FileUtils.mkdir_p(CACHE)
FileUtils.mkdir_p(TMP)

status_rows = []
missing_reference_rows.each do |row|
  arxiv_id = normalize_arxiv_id(row["url"])
  download_url = "https://arxiv.org/e-print/#{arxiv_id}"
  dest_dir = source_text_dir(row)
  files_written = []
  status = nil
  notes = nil

  begin
    package_path = download_eprint(arxiv_id)
    extracted_dir = extract_source_package(package_path, arxiv_id)
    files = files_under(extracted_dir)
    actual_lists = files.select { |path| actual_reference_list?(path) }
    bib_files = files.select { |path| File.extname(path).downcase == ".bib" }

    if actual_lists.any?
      files_written = copy_reference_files(actual_lists, dest_dir)
      status = "actual_reference_list_copied"
      notes = "Copied .bbl or references .tex from arXiv source package."
    else
      files_written = extract_thebibliography(files, dest_dir)
      if files_written.any?
        status = "thebibliography_extracted"
        notes = "Extracted thebibliography block from arXiv source .tex."
      elsif bib_files.any?
        files_written = copy_reference_files(bib_files, dest_dir)
        status = "bib_only_fallback"
        notes = "Copied .bib because no .bbl, references .tex, or thebibliography block was found."
      else
        status = "no_reference_list_found"
        notes = "Downloaded arXiv source but found no usable reference-list or .bib file."
      end
    end
  rescue StandardError => e
    status = "download_or_extract_failed"
    notes = e.message
  end

  status_rows << {
    "source_paper_id" => row["source_paper_id"],
    "title" => row["title"],
    "url" => row["url"],
    "source_wave" => row["source_wave"],
    "arxiv_id" => arxiv_id,
    "status" => status,
    "download_url" => download_url,
    "destination_dir" => dest_dir.sub(ROOT + "/", ""),
    "files_written" => files_written.map { |path| path.sub(ROOT + "/", "") }.join(";"),
    "notes" => notes
  }
end

write_csv(STATUS, STATUS_HEADERS, status_rows)

system(RbConfig.ruby, File.join(ROOT, "scripts", "build_current_coverage_graph_v0.rb")) || abort("Graph rebuild failed after backfill.")

puts "missing_before=#{status_rows.size}"
puts "status_file=#{STATUS}"
puts status_rows.each_with_object(Hash.new(0)) { |row, counts| counts[row["status"]] += 1 }
                .sort_by { |status, _count| status.to_s }
                .map { |status, count| "#{status}=#{count}" }
                .join(" ")
