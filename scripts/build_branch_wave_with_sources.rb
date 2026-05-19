#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"
require "open3"
require "pathname"
require "shellwords"
require "zlib"

ROOT = File.expand_path("..", __dir__)

NODE_HEADERS = %w[
  node_id graph_layer node_type canonical_label source_paper_id source_year visible_year
  source_section evidence_location evidence_quote paraphrase confidence is_inferred
  needs_human_check notes
].freeze

EDGE_HEADERS = %w[
  edge_id graph_layer source_node_id target_node_id relation_type evidence_paper_id
  evidence_year visible_year evidence_source_type evidence_location evidence_quote
  confidence is_inferred needs_human_check notes
].freeze

CAND_HEADERS = %w[
  edge_id graph_layer source_node_id target_node_id relation_type evidence_paper_id
  evidence_year visible_year evidence_source_type evidence_location evidence_quote
  confidence is_inferred needs_human_check notes explicitness review_reason
].freeze

SOURCE_HEADERS = %w[
  universe_id title url source_found source_type local_source_path source_notes extraction_status
].freeze

SECTION_HEADERS = %w[
  universe_id section_name source_location section_role notes
].freeze

CONFIGS = {
  "chemistry_sampling_symmetry_wave_v0" => {
    manifest: "manifests/branch_assignment_v0.csv",
    selected_ids: %w[
      NQSC024
      NQSC025
      NQSC045
      NQSC051
      NQSC069
      NQSC071
      NQSC080
      NQSC106
      NQSC120
      NQSC127
      NQSC145
      NQSC164
      NQSC170
      NQSC199
    ],
    title: "Chemistry Sampling Symmetry Wave V0",
    scope: "branch-aware expansion wave for fermionic chemistry, sign/symmetry, sampling, and later electronic-structure NQS pressure"
  },
  "dynamics_tomography_wave_v0" => {
    manifest: "manifests/branch_assignment_v0.csv",
    selected_ids: %w[
      NQSC013
      NQSC014
      NQSC015
      NQSC019
      NQSC031
      NQSC040
      NQSC041
      NQSC063
      NQSC077
      NQSC099
      NQSC103
      NQSC110
      NQSC134
      NQSC175
      NQSC178
      NQSC201
    ],
    title: "Dynamics Tomography Wave V0",
    scope: "branch-aware expansion wave for NQS dynamics, dissipative/open systems, quantum-state tomography, and experimental reconstruction"
  }
}.freeze

def csv_write(path, headers, rows)
  CSV.open(path, "w", write_headers: true, headers: headers) do |csv|
    rows.each { |row| csv << headers.map { |h| row[h] } }
  end
end

def arxiv_id(url)
  match = url.to_s.match(%r{arxiv\.org/(?:abs|pdf)/([^/?#]+)})
  return nil unless match

  match[1].sub(/\.pdf\z/, "")
end

def shell_success?(*cmd)
  system(*cmd, out: File::NULL, err: File::NULL)
end

def extract_source(source_path, dest_dir)
  FileUtils.mkdir_p(dest_dir)
  return "already_extracted" unless Dir.glob(File.join(dest_dir, "**", "*")).empty?

  if shell_success?("tar", "-xf", source_path, "-C", dest_dir)
    return "tar_archive"
  end

  begin
    Zlib::GzipReader.open(source_path) do |gz|
      File.binwrite(File.join(dest_dir, "source.tex"), gz.read)
    end
    return "single_gzip_tex"
  rescue Zlib::GzipFile::Error
    # fall through
  end

  raw = File.binread(source_path)
  File.binwrite(File.join(dest_dir, "source.tex"), raw)
  "raw_tex_or_unknown"
end

def score_tex(path)
  text = File.binread(path).force_encoding("UTF-8").scrub
  score = 0
  score += 100 if text.include?("\\documentclass")
  score += 80 if text.include?("\\begin{document}")
  score += 30 if text.include?("\\title")
  score += 20 if text.include?("\\begin{abstract}")
  score += text.scan(/\\section\*?\s*\{/).size * 4
  score += text.scan(/\\input\{|\\include\{/).size * 2
  score
end

def main_tex(dest_dir)
  tex_files = Dir.glob(File.join(dest_dir, "**", "*.tex"))
  return nil if tex_files.empty?

  tex_files.max_by { |path| score_tex(path) }
end

def clean_heading(line)
  raw = line.gsub(/%.*$/, "").strip
  return "abstract" if raw.include?("\\begin{abstract}")
  return "title" if raw.include?("\\title")

  raw = raw.gsub(/\\(section|subsection|subsubsection|paragraph)\*?\s*\{/, "")
           .gsub(/\\texorpdfstring\{([^}]*)\}\{[^}]*\}/, "\\1")
           .gsub(/[{}]/, "")
           .gsub(/\\[a-zA-Z]+/, "")
           .gsub(/\s+/, " ")
           .strip
  raw.empty? ? "unnamed section" : raw
end

def role_for(name)
  n = name.downcase
  return "title" if n == "title"
  return "abstract" if n == "abstract"
  return "introduction" if n.include?("introduction")
  return "related_work" if n.match?(/related|background|previous|prior/)
  return "method" if n.match?(/method|wave function|ansatz|architecture|hamiltonian|symmetr|sampling|optimization|algorithm|backflow|formalism|network|model/)
  return "benchmark" if n.match?(/system|benchmark|molecule|atom|electron|nuclei|description/)
  return "results" if n.match?(/result|numerics|experiment|accuracy|energy|potential|simulation|analysis/)
  return "discussion" if n.match?(/discussion|conclusion|outlook|remarks|summary/)

  "section"
end

def section_rows_for(universe_id, dest_dir, wave_dir)
  tex_files = Dir.glob(File.join(dest_dir, "**", "*.tex")).sort
  rows = []
  tex_files.each do |path|
    rel = Pathname.new(path).relative_path_from(Pathname.new(wave_dir)).to_s
    text = File.binread(path).force_encoding("UTF-8").scrub
    text.lines.each_with_index do |line, index|
      next unless line.match?(/\\title|\\begin\{abstract\}|\\section|\\subsection|\\subsubsection|\\paragraph/)

      name = clean_heading(line)
      rows << {
        "universe_id" => universe_id,
        "section_name" => name,
        "source_location" => "#{rel}:#{index + 1}",
        "section_role" => role_for(name),
        "notes" => "auto section-map row; inspect nearby lines before extracting evidence"
      }
    end
  end
  rows
end

wave_name = ARGV[0] || "chemistry_sampling_symmetry_wave_v0"
config = CONFIGS[wave_name] || abort("Unknown wave name: #{wave_name}")
manifest_rows = CSV.read(File.join(ROOT, config[:manifest]), headers: true)
selected = config[:selected_ids].map do |id|
  manifest_rows.find { |row| row["universe_id"] == id } || abort("Missing #{id}")
end

wave_dir = File.join(ROOT, "extraction_waves", wave_name)
sources_dir = File.join(wave_dir, "sources")
text_dir = File.join(wave_dir, "text")
FileUtils.mkdir_p(sources_dir)
FileUtils.mkdir_p(text_dir)

CSV.open(File.join(wave_dir, "manifest.csv"), "w") do |csv|
  csv << manifest_rows.headers
  selected.each { |row| csv << row }
end

csv_write(File.join(wave_dir, "fulltext_evidence_nodes.csv"), NODE_HEADERS, [])
csv_write(File.join(wave_dir, "fulltext_evidence_edges.csv"), EDGE_HEADERS, [])
csv_write(File.join(wave_dir, "development_edge_candidates.csv"), CAND_HEADERS, [])

source_rows = []
section_rows = []

selected.each do |row|
  id = row["universe_id"]
  aid = arxiv_id(row["url"])
  if aid.nil?
    source_rows << {
      "universe_id" => id,
      "title" => row["title"],
      "url" => row["url"],
      "source_found" => "false",
      "source_type" => "non_arxiv_or_unparsed",
      "local_source_path" => "",
      "source_notes" => "URL could not be converted to arXiv e-print source",
      "extraction_status" => "needs_source_review"
    }
    next
  end

  source_path = File.join(sources_dir, "#{aid}.eprint")
  unless File.exist?(source_path) && File.size(source_path).positive?
    eprint_url = "https://arxiv.org/e-print/#{aid}"
    stdout, stderr, status = Open3.capture3("curl", "-L", "--fail", "--silent", "--show-error", "-o", source_path, eprint_url)
    unless status.success?
      FileUtils.rm_f(source_path)
      source_rows << {
        "universe_id" => id,
        "title" => row["title"],
        "url" => row["url"],
        "source_found" => "false",
        "source_type" => "arxiv_source_download_failed",
        "local_source_path" => "",
        "source_notes" => (stderr.empty? ? stdout : stderr).strip,
        "extraction_status" => "needs_source_review"
      }
      next
    end
  end

  dest_dir = File.join(text_dir, aid)
  source_type = extract_source(source_path, dest_dir)
  main = main_tex(dest_dir)
  local_main = main ? Pathname.new(main).relative_path_from(Pathname.new(wave_dir)).to_s : ""

  source_rows << {
    "universe_id" => id,
    "title" => row["title"],
    "url" => row["url"],
    "source_found" => main ? "true" : "false",
    "source_type" => "arxiv_source/#{source_type}",
    "local_source_path" => local_main,
    "source_notes" => main ? "arXiv e-print source downloaded and TeX source mapped" : "source downloaded but no TeX file was found",
    "extraction_status" => main ? "source_mapped" : "needs_source_review"
  }

  section_rows.concat(section_rows_for(id, dest_dir, wave_dir))
end

csv_write(File.join(wave_dir, "source_status.csv"), SOURCE_HEADERS, source_rows)
csv_write(File.join(wave_dir, "section_map.csv"), SECTION_HEADERS, section_rows)

File.write(File.join(wave_dir, "protocol_notes.md"), <<~MD)
  # #{config[:title]} Protocol Notes

  This wave expands NQS coverage through #{config[:scope]}.

  ## Scope

  Selected from `#{config[:manifest]}`:

  #{config[:selected_ids].map { |id| "- #{id}" }.join("\n")}

  ## Extraction Rule

  Paper-local first:

  - extract only author-stated evidence nodes;
  - extract strict paper-internal evidence edges;
  - record cross-paper relations as candidates unless direct full-text evidence is unambiguous;
  - keep candidate relations in `development_edge_candidates.csv` with `needs_human_check=true`;
  - do not upgrade candidate edges during this coverage-expansion phase unless a controller review is explicitly started later.

  ## Branch Pressure To Watch

  - fermionic sign / antisymmetry;
  - neural-orbital vs determinant/Jastrow/backflow structure;
  - sampling and optimization bottlenecks;
  - symmetry-preserving architectures;
  - scalable electronic-structure benchmarks.
MD

File.write(File.join(wave_dir, "extraction_log.md"), <<~MD)
  # #{config[:title]} Extraction Log

  ## Setup

  Created from `scripts/build_branch_wave_with_sources.rb`.

  - Selected papers: #{selected.size}
  - Source mapped: #{source_rows.count { |r| r["source_found"] == "true" }}
  - Section rows: #{section_rows.size}

  ## Log Entries

MD

File.write(File.join(wave_dir, "README.md"), <<~MD)
  # #{config[:title]}

  This is a branch-aware coverage expansion wave for NQS motivation graph construction.

  ## Input

  - `manifest.csv`

  ## Outputs

  - `source_status.csv`
  - `section_map.csv`
  - `fulltext_evidence_nodes.csv`
  - `fulltext_evidence_edges.csv`
  - `development_edge_candidates.csv`

  ## Protocols

  Read:

  - `Outputs/NQS Motivation Graph Gold Standard Calibration Pack V0.md`
  - `prompts/paper_local_extraction_worker_prompt_v0.md`
MD

puts "Wave: #{wave_name}"
puts "Selected papers: #{selected.size}"
puts "Source mapped: #{source_rows.count { |r| r["source_found"] == "true" }}"
puts "Section rows: #{section_rows.size}"
