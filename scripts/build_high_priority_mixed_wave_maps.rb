#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"

ROOT = File.expand_path("..", __dir__)
WAVE = File.join(ROOT, "extraction_waves", "high_priority_mixed_coverage_wave_v0")

SOURCE_HEADERS = %w[
  universe_id title url source_found source_type local_source_path source_notes extraction_status
].freeze

SECTION_HEADERS = %w[
  universe_id section_name source_location section_role notes
].freeze

MAIN_FILES = {
  "NQSC026" => "text/1909.12852/main.tex",
  "NQSC002" => "text/1701.06246/neuron_prl.tex",
  "NQSC003" => "text/1704.05148/machine3.tex",
  "NQSC030" => "text/1912.08828/main.tex",
  "NQSC083" => "text/2207.14314/main.tex",
  "NQSC007" => "text/1802.09558/dbm_arxiv.tex",
  "NQSC010" => "text/1807.07445/main-2019-v1.tex",
  "NQSC011" => "text/1807.10770/main.tex",
  "NQSC037" => "text/2007.14282/main.tex",
  "NQSC059" => "text/2108.08631/main.tex",
  "NQSC117" => "text/2310.04166/main.tex",
  "NQSC129" => "text/2403.05249/main.tex"
}.freeze

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
  return "method" if n.match?(/method|wave function|ansatz|architecture|hamiltonian|symmetr|sampling|optimization|algorithm|backflow|formalism|statistics|correlator/)
  return "benchmark" if n.match?(/system|model|hamiltonian|benchmark|description/)
  return "results" if n.match?(/result|numerics|experiment|potential energy|transverse|ising|heisenberg|hubbard|nuclei|tomography/)
  return "discussion" if n.match?(/discussion|conclusion|outlook|remarks/)
  "section"
end

manifest = CSV.read(File.join(WAVE, "manifest.csv"), headers: true).map(&:to_h)

CSV.open(File.join(WAVE, "source_status.csv"), "w", write_headers: true, headers: SOURCE_HEADERS) do |csv|
  manifest.each do |row|
    local = MAIN_FILES.fetch(row["universe_id"])
    exists = File.exist?(File.join(WAVE, local))
    csv << [
      row["universe_id"],
      row["title"],
      row["url"],
      exists.to_s,
      exists ? "arxiv_source" : "missing",
      local,
      exists ? "arXiv e-print source downloaded and main TeX identified" : "source downloaded but main TeX not found",
      exists ? "source_mapped" : "needs_source_review"
    ]
  end
end

CSV.open(File.join(WAVE, "section_map.csv"), "w", write_headers: true, headers: SECTION_HEADERS) do |csv|
  manifest.each do |row|
    local = MAIN_FILES.fetch(row["universe_id"])
    path = File.join(WAVE, local)
    next unless File.exist?(path)

    text = File.binread(path).force_encoding("UTF-8").scrub
    text.lines.each_with_index do |line, index|
      next unless line.match?(/\\title|\\begin\{abstract\}|\\section|\\subsection|\\subsubsection|\\paragraph/)

      name = clean_heading(line)
      csv << [
        row["universe_id"],
        name,
        "#{local}:#{index + 1}",
        role_for(name),
        "auto section-map row; inspect nearby lines before extracting evidence"
      ]
    end
  end
end

puts "Wrote source_status.csv and section_map.csv for #{manifest.size} papers"
