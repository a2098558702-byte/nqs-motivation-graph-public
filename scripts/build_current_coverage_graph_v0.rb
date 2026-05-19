#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
OUT = File.join(ROOT, "current_coverage_graph_v0")

WAVES = {
  "frustrated_spin_pilot_wave_v0" => "frustrated_spin",
  "optimization_pilot_wave_v0" => "optimization_scaling",
  "architecture_pilot_wave_v0" => "architecture",
  "high_priority_mixed_coverage_wave_v0" => "high_priority_mixed",
  "chemistry_sampling_symmetry_wave_v0" => "chemistry_sampling_symmetry",
  "dynamics_tomography_wave_v0" => "dynamics_tomography_open_systems"
}.freeze

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

def read_csv(path)
  return [] unless File.exist?(path)

  CSV.read(path, headers: true).map(&:to_h)
end

def write_csv(path, headers, rows)
  CSV.open(path, "w", write_headers: true, headers: headers) do |csv|
    rows.each { |row| csv << headers.map { |h| row[h] } }
  end
end

def count_by(rows, key)
  rows.each_with_object(Hash.new(0)) { |row, counts| counts[row[key].to_s] += 1 }
      .sort_by { |value, count| [-count, value] }
end

def normalize_arxiv_id(value)
  text = value.to_s.downcase
  text = text[%r{arxiv\.org/(?:abs|pdf)/([^?\s/]+)}, 1] || text
  text = text.sub(/\.pdf\z/, "")
  text.sub(/v\d+\z/, "")
end

def normalize_match_text(text)
  text.to_s
      .downcase
      .gsub(/\\[a-zA-Z]+\*?/, " ")
      .gsub(/[{}$^_~`"'“”‘’]/, " ")
      .gsub(/[^a-z0-9]+/, " ")
      .squeeze(" ")
      .strip
end

def read_text(path)
  File.binread(path).encode("UTF-8", invalid: :replace, undef: :replace, replace: " ")
end

def year_from(row)
  row["visible_date"].to_s[/\d{4}/] || row["year"].to_s[/\d{4}/] || row["visible_year"].to_s[/\d{4}/]
end

def reference_files_for_paper(root, paper_row)
  arxiv_id = normalize_arxiv_id(paper_row["url"])
  return [] if arxiv_id == ""

  text_root = File.join(root, "extraction_waves", paper_row["source_wave"], "text")
  return [] unless Dir.exist?(text_root)

  source_dirs = Dir.children(text_root).select do |name|
    path = File.join(text_root, name)
    File.directory?(path) && normalize_arxiv_id(name).start_with?(arxiv_id)
  end

  files = source_dirs.flat_map do |dir|
    Dir.glob(File.join(text_root, dir, "**", "*")).select do |path|
      next false unless File.file?(path)

      basename = File.basename(path).downcase
      ext = File.extname(path).downcase
      ext == ".bib" || ext == ".bbl" || (ext == ".tex" && basename.include?("references"))
    end
  end.sort

  actual_reference_lists = files.select do |path|
    basename = File.basename(path).downcase
    ext = File.extname(path).downcase
    ext == ".bbl" || (ext == ".tex" && basename.include?("references"))
  end
  return actual_reference_lists unless actual_reference_lists.empty?

  files.select { |path| File.extname(path).downcase == ".bib" }
end

def clean_quote(line)
  line.to_s.gsub(/\s+/, " ").strip[0, 260]
end

def reference_blobs(ref_files)
  ref_files.map do |path|
    text = read_text(path)
    lines = text.lines
    {
      "path" => path,
      "lines" => lines,
      "downcased" => text.downcase,
      "normalized" => normalize_match_text(text),
      "normalized_lines" => lines.map { |line| normalize_match_text(line) }
    }
  end
end

def title_quote(blob, title_norm)
  line_index = (0...blob["lines"].size).find do |i|
    normalize_match_text(blob["lines"][i, 3].join(" ")).include?(title_norm)
  end || 0

  {
    "line" => line_index + 1,
    "quote" => clean_quote(blob["lines"][line_index, 3].join(" "))
  }
end

def citation_match(ref_blobs, target)
  ref_blobs.each do |blob|
    if target["arxiv_id"] != "" && blob["downcased"].include?(target["arxiv_id"])
      line_index = blob["lines"].index { |line| line.downcase.include?(target["arxiv_id"]) } || 0
      return {
        "path" => blob["path"],
        "line" => line_index + 1,
        "match_type" => "arxiv_id",
        "quote" => clean_quote(blob["lines"][line_index])
      }
    end

    next unless target["title_norm"].split.size >= 5 && blob["normalized"].include?(target["title_norm"])

    title_context = title_quote(blob, target["title_norm"])
    return {
      "path" => blob["path"],
      "line" => title_context["line"],
      "match_type" => "title_exact",
      "quote" => title_context["quote"]
    }
  end

  nil
end

FileUtils.rm_rf(OUT)
FileUtils.mkdir_p(OUT)
FileUtils.mkdir_p(File.join(OUT, "graph_variants"))

all_nodes = []
all_edges = []
all_candidates = []
node_wave_index = []
edge_wave_index = []
candidate_wave_index = []
paper_index = []

WAVES.each do |wave, branch|
  dir = File.join(ROOT, "extraction_waves", wave)
  nodes = read_csv(File.join(dir, "fulltext_evidence_nodes.csv"))
  edges = read_csv(File.join(dir, "fulltext_evidence_edges.csv"))
  candidates = read_csv(File.join(dir, "development_edge_candidates.csv"))
  manifest = read_csv(File.join(dir, "manifest.csv"))

  manifest.each do |row|
    paper_index << {
      "source_paper_id" => row["universe_id"],
      "title" => row["title"],
      "year" => row["year"],
      "visible_date" => row["visible_date"],
      "url" => row["url"],
      "primary_branch" => row["primary_branch"],
      "source_wave" => wave,
      "branch_label" => branch,
      "extraction_priority" => row["extraction_priority"]
    }
  end

  nodes.each do |row|
    all_nodes << row
    node_wave_index << {
      "node_id" => row["node_id"],
      "source_wave" => wave,
      "branch_label" => branch,
      "source_paper_id" => row["source_paper_id"],
      "node_type" => row["node_type"]
    }
  end

  edges.each do |row|
    all_edges << row
    edge_wave_index << {
      "edge_id" => row["edge_id"],
      "edge_kind" => "strict_paper_local_or_internal",
      "source_wave" => wave,
      "branch_label" => branch,
      "relation_type" => row["relation_type"],
      "evidence_paper_id" => row["evidence_paper_id"]
    }
  end

  candidates.each do |row|
    all_candidates << row
    candidate_wave_index << {
      "edge_id" => row["edge_id"],
      "edge_kind" => "candidate_unreviewed",
      "source_wave" => wave,
      "branch_label" => branch,
      "relation_type" => row["relation_type"],
      "evidence_paper_id" => row["evidence_paper_id"],
      "candidate_status" => row["notes"].to_s[/candidate_status=([^;]+)/, 1].to_s
    }
  end
end

node_ids = all_nodes.map { |row| row["node_id"] }
node_counts = Hash.new(0)
node_ids.each { |id| node_counts[id] += 1 }
duplicate_node_ids = node_counts.select { |_id, count| count > 1 }.keys
node_by_id = all_nodes.to_h { |row| [row["node_id"], row] }

strict_endpoint_errors = all_edges.reject do |row|
  node_by_id[row["source_node_id"]] && node_by_id[row["target_node_id"]]
end
strict_bad_flags = all_edges.select do |row|
  row["graph_layer"] != "evidence" ||
    row["is_inferred"].to_s.downcase == "true" ||
    row["needs_human_check"].to_s.downcase == "true"
end

candidate_endpoint_warnings = all_candidates.reject do |row|
  node_by_id[row["source_node_id"]] && node_by_id[row["target_node_id"]]
end
candidate_bad_flags = all_candidates.select do |row|
  row["graph_layer"] != "candidate" ||
    row["needs_human_check"].to_s.downcase != "true" ||
    !row["notes"].to_s.include?("candidate_status=")
end

candidate_context_edges = all_candidates.select do |row|
  node_by_id[row["source_node_id"]] && node_by_id[row["target_node_id"]]
end.map do |row|
  {
    "edge_id" => "CTX.#{row["edge_id"]}",
    "graph_layer" => "candidate_context",
    "source_node_id" => row["source_node_id"],
    "target_node_id" => row["target_node_id"],
    "relation_type" => "candidate__#{row["relation_type"]}",
    "evidence_paper_id" => row["evidence_paper_id"],
    "evidence_year" => row["evidence_year"],
    "visible_year" => row["visible_year"],
    "evidence_source_type" => row["evidence_source_type"],
    "evidence_location" => row["evidence_location"],
    "evidence_quote" => row["evidence_quote"],
    "confidence" => row["confidence"],
    "is_inferred" => row["is_inferred"],
    "needs_human_check" => "true",
    "notes" => [
      row["notes"],
      "candidate_context_only=true",
      "original_candidate_id=#{row["edge_id"]}",
      "explicitness=#{row["explicitness"]}",
      "review_reason=#{row["review_reason"]}"
    ].join("; ")
  }
end

clean_candidate_context_edges = all_candidates.select do |row|
  node_by_id[row["source_node_id"]] &&
    node_by_id[row["target_node_id"]] &&
    row["graph_layer"] == "candidate" &&
    row["needs_human_check"].to_s.downcase == "true" &&
    row["notes"].to_s.include?("candidate_status=")
end.map do |row|
  {
    "edge_id" => "CTXCLEAN.#{row["edge_id"]}",
    "graph_layer" => "candidate_context",
    "source_node_id" => row["source_node_id"],
    "target_node_id" => row["target_node_id"],
    "relation_type" => "candidate__#{row["relation_type"]}",
    "evidence_paper_id" => row["evidence_paper_id"],
    "evidence_year" => row["evidence_year"],
    "visible_year" => row["visible_year"],
    "evidence_source_type" => row["evidence_source_type"],
    "evidence_location" => row["evidence_location"],
    "evidence_quote" => row["evidence_quote"],
    "confidence" => row["confidence"],
    "is_inferred" => row["is_inferred"],
    "needs_human_check" => "true",
    "notes" => [
      row["notes"],
      "candidate_context_only=true",
      "clean_candidate_context=true",
      "original_candidate_id=#{row["edge_id"]}",
      "explicitness=#{row["explicitness"]}",
      "review_reason=#{row["review_reason"]}"
    ].join("; ")
  }
end

candidate_review_backlog = all_candidates.select do |row|
  !node_by_id[row["source_node_id"]] ||
    !node_by_id[row["target_node_id"]] ||
    row["graph_layer"] != "candidate" ||
    row["needs_human_check"].to_s.downcase != "true" ||
    !row["notes"].to_s.include?("candidate_status=")
end.map do |row|
  {
    "edge_id" => row["edge_id"],
    "source_node_id" => row["source_node_id"],
    "target_node_id" => row["target_node_id"],
    "relation_type" => row["relation_type"],
    "evidence_paper_id" => row["evidence_paper_id"],
    "endpoint_resolved" => (node_by_id[row["source_node_id"]] && node_by_id[row["target_node_id"]]) ? "true" : "false",
    "has_candidate_status" => row["notes"].to_s.include?("candidate_status=").to_s,
    "graph_layer" => row["graph_layer"],
    "needs_human_check" => row["needs_human_check"],
    "notes" => row["notes"],
    "review_reason" => row["review_reason"]
  }
end

paper_node_by_paper_id = all_nodes.select { |row| row["node_type"] == "paper" }
                                  .each_with_object({}) do |row, index|
  index[row["source_paper_id"]] ||= row
end

citation_targets = paper_index.map do |paper_row|
  paper_node = paper_node_by_paper_id[paper_row["source_paper_id"]]
  next unless paper_node

  {
    "paper_id" => paper_row["source_paper_id"],
    "node_id" => paper_node["node_id"],
    "title" => paper_row["title"],
    "title_norm" => normalize_match_text(paper_row["title"]),
    "arxiv_id" => normalize_arxiv_id(paper_row["url"])
  }
end.compact

paper_citation_edges = []
paper_citation_source_coverage = []
paper_index.each do |source_row|
  source_paper_id = source_row["source_paper_id"]
  source_node = paper_node_by_paper_id[source_paper_id]
  next unless source_node

  ref_files = reference_files_for_paper(ROOT, source_row)
  ref_blobs = reference_blobs(ref_files)
  edge_count_before = paper_citation_edges.size
  citation_targets.each do |target|
    next if target["paper_id"] == source_paper_id

    match = citation_match(ref_blobs, target)
    next unless match

    visible_year = year_from(source_row)
    paper_citation_edges << {
      "edge_id" => "CITE.#{source_paper_id}.#{target["paper_id"]}",
      "graph_layer" => "citation",
      "source_node_id" => source_node["node_id"],
      "target_node_id" => target["node_id"],
      "relation_type" => "paper_cites_paper",
      "evidence_paper_id" => source_paper_id,
      "evidence_year" => visible_year,
      "visible_year" => visible_year,
      "evidence_source_type" => "reference_list",
      "evidence_location" => "#{match["path"].sub(ROOT + "/", "")}:#{match["line"]}",
      "evidence_quote" => match["quote"],
      "confidence" => match["match_type"] == "arxiv_id" ? "high" : "medium",
      "is_inferred" => "false",
      "needs_human_check" => "false",
      "notes" => "citation_match=#{match["match_type"]}; cited_paper_id=#{target["paper_id"]}"
    }
  end

  paper_citation_source_coverage << {
    "source_paper_id" => source_paper_id,
    "source_node_id" => source_node["node_id"],
    "source_wave" => source_row["source_wave"],
    "reference_file_count" => ref_files.size,
    "internal_citation_edges" => paper_citation_edges.size - edge_count_before,
    "reference_files" => ref_files.map { |path| path.sub(ROOT + "/", "") }.join(";")
  }
end

write_csv(File.join(OUT, "current_evidence_nodes.csv"), NODE_HEADERS, all_nodes)
write_csv(File.join(OUT, "current_strict_edges.csv"), EDGE_HEADERS, all_edges)
write_csv(File.join(OUT, "current_candidate_edges.csv"), CAND_HEADERS, all_candidates)
write_csv(File.join(OUT, "paper_citation_edges.csv"), EDGE_HEADERS, paper_citation_edges)
write_csv(File.join(OUT, "paper_citation_source_coverage.csv"), %w[source_paper_id source_node_id source_wave reference_file_count internal_citation_edges reference_files], paper_citation_source_coverage)
write_csv(File.join(OUT, "node_wave_index.csv"), %w[node_id source_wave branch_label source_paper_id node_type], node_wave_index)
write_csv(File.join(OUT, "edge_wave_index.csv"), %w[edge_id edge_kind source_wave branch_label relation_type evidence_paper_id], edge_wave_index)
write_csv(File.join(OUT, "candidate_wave_index.csv"), %w[edge_id edge_kind source_wave branch_label relation_type evidence_paper_id candidate_status], candidate_wave_index)
write_csv(File.join(OUT, "paper_index.csv"), %w[source_paper_id title year visible_date url primary_branch source_wave branch_label extraction_priority], paper_index)

write_csv(File.join(OUT, "graph_variants", "nodes_only_nodes.csv"), NODE_HEADERS, all_nodes)
write_csv(File.join(OUT, "graph_variants", "empty_edges_for_nodes_only.csv"), EDGE_HEADERS, [])
write_csv(File.join(OUT, "graph_variants", "paper_internal_edges_only.csv"), EDGE_HEADERS, all_edges)
write_csv(File.join(OUT, "graph_variants", "paper_citation_edges_only.csv"), EDGE_HEADERS, paper_citation_edges)
write_csv(File.join(OUT, "graph_variants", "candidate_context_edges_endpoint_resolved.csv"), EDGE_HEADERS, candidate_context_edges)
write_csv(File.join(OUT, "graph_variants", "candidate_context_edges_clean.csv"), EDGE_HEADERS, clean_candidate_context_edges)
write_csv(File.join(OUT, "graph_variants", "paper_internal_plus_candidate_context_edges.csv"), EDGE_HEADERS, all_edges + candidate_context_edges)
write_csv(File.join(OUT, "graph_variants", "paper_internal_plus_clean_candidate_context_edges.csv"), EDGE_HEADERS, all_edges + clean_candidate_context_edges)
write_csv(File.join(OUT, "candidate_review_backlog.csv"), %w[edge_id source_node_id target_node_id relation_type evidence_paper_id endpoint_resolved has_candidate_status graph_layer needs_human_check notes review_reason], candidate_review_backlog)

node_type_rows = count_by(all_nodes, "node_type").map { |value, count| { "node_type" => value, "count" => count } }
wave_rows = WAVES.map do |wave, branch|
  {
    "source_wave" => wave,
    "branch_label" => branch,
    "papers" => paper_index.count { |r| r["source_wave"] == wave },
    "nodes" => node_wave_index.count { |r| r["source_wave"] == wave },
    "strict_edges" => edge_wave_index.count { |r| r["source_wave"] == wave },
    "candidate_edges" => candidate_wave_index.count { |r| r["source_wave"] == wave }
  }
end
candidate_status_rows = candidate_wave_index.each_with_object(Hash.new(0)) do |row, counts|
  counts[row["candidate_status"]] += 1
end.sort_by { |value, count| [-count, value] }.map { |value, count| { "candidate_status" => value, "count" => count } }

write_csv(File.join(OUT, "node_type_counts.csv"), %w[node_type count], node_type_rows)
write_csv(File.join(OUT, "wave_counts.csv"), %w[source_wave branch_label papers nodes strict_edges candidate_edges], wave_rows)
write_csv(File.join(OUT, "candidate_status_counts.csv"), %w[candidate_status count], candidate_status_rows)

summary = {
  "papers" => paper_index.size,
  "nodes" => all_nodes.size,
  "strict_edges" => all_edges.size,
  "candidate_edges" => all_candidates.size,
  "paper_citation_edges" => paper_citation_edges.size,
  "paper_citation_sources_with_reference_files" => paper_citation_source_coverage.count { |row| row["reference_file_count"].to_i.positive? },
  "candidate_context_edges_endpoint_resolved" => candidate_context_edges.size,
  "candidate_context_edges_clean" => clean_candidate_context_edges.size,
  "candidate_review_backlog" => candidate_review_backlog.size,
  "duplicate_node_ids" => duplicate_node_ids.size,
  "strict_endpoint_errors" => strict_endpoint_errors.size,
  "strict_bad_flags" => strict_bad_flags.size,
  "candidate_endpoint_warnings" => candidate_endpoint_warnings.size,
  "candidate_bad_flags" => candidate_bad_flags.size
}

File.write(File.join(OUT, "SUMMARY.txt"), summary.map { |k, v| "#{k}: #{v}" }.join("\n") + "\n")

File.write(File.join(OUT, "validation_report.md"), <<~MD)
  # Current Coverage Graph V0 Validation Report

  ## Summary

  #{summary.map { |k, v| "- #{k}: #{v}" }.join("\n")}

  ## Wave Counts

  #{wave_rows.map { |r| "- #{r["source_wave"]}: papers=#{r["papers"]}, nodes=#{r["nodes"]}, strict_edges=#{r["strict_edges"]}, candidate_edges=#{r["candidate_edges"]}" }.join("\n")}

  ## Candidate Status Counts

  #{candidate_status_rows.map { |r| "- #{r["candidate_status"]}: #{r["count"]}" }.join("\n")}

  ## Strict Endpoint Errors

  #{strict_endpoint_errors.empty? ? "None." : strict_endpoint_errors.map { |r| "- #{r["edge_id"]}: #{r["source_node_id"]} -> #{r["target_node_id"]}" }.join("\n")}

  ## Candidate Endpoint Warnings

  #{candidate_endpoint_warnings.empty? ? "None." : candidate_endpoint_warnings.map { |r| "- #{r["edge_id"]}: #{r["source_node_id"]} -> #{r["target_node_id"]}" }.join("\n")}

  ## Notes

  Candidate-context graph variants are for experiments only. They do not upgrade candidate edges into strict evidence.
MD

puts summary.map { |k, v| "#{k}=#{v}" }.join(" ")
