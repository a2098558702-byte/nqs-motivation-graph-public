#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"
require "pathname"

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

def read_csv_if_exists(path)
  return [] unless File.exist?(path)

  CSV.read(path, headers: true).map(&:to_h)
end

def write_csv(path, headers, rows)
  CSV.open(path, "w", write_headers: true, headers: headers) do |csv|
    rows.each { |row| csv << headers.map { |h| row[h] } }
  end
end

def assert_headers!(path, expected)
  return unless File.exist?(path)

  headers = CSV.open(path, &:readline)
  return if headers == expected

  abort("Header mismatch in #{path}\nexpected: #{expected.join(",")}\nactual:   #{headers.join(",")}")
end

def dedupe(rows, key)
  seen = {}
  rows.each_with_object([]) do |row, out|
    value = row[key]
    next if value.nil? || value.empty?
    next if seen[value]

    seen[value] = true
    out << row
  end
end

def normalize_graph_layer!(rows)
  rows.each do |row|
    row["graph_layer"] = "evidence" if row["graph_layer"] == "fulltext_evidence"
  end
  rows
end

def retarget_paper_placeholders!(rows, existing_node_ids, paper_node_map)
  rows.each do |row|
    %w[source_node_id target_node_id].each do |key|
      node_id = row[key].to_s
      next if existing_node_ids[node_id]

      match = node_id.match(/\A(NQSC\d+)\.paper\z/)
      next unless match
      next unless paper_node_map[match[1]]

      row[key] = paper_node_map[match[1]]
      row["notes"] = [row["notes"], "auto_retargeted_#{key}_from=#{node_id}"].compact.join("; ")
    end
  end
  rows
end

wave_name = ARGV[0] || abort("Usage: ruby scripts/merge_worker_outputs_and_validate_wave.rb WAVE_NAME")
wave_dir = File.join(ROOT, "extraction_waves", wave_name)
worker_root = File.join(wave_dir, "worker_outputs")

abort("Missing wave dir: #{wave_dir}") unless Dir.exist?(wave_dir)
abort("Missing worker output dir: #{worker_root}") unless Dir.exist?(worker_root)

manifest_ids = CSV.read(File.join(wave_dir, "manifest.csv"), headers: true)
                  .map { |row| row["universe_id"] }
                  .compact
                  .to_h { |id| [id, true] }

node_files = Dir.glob(File.join(worker_root, "*", "nodes.csv")).sort
edge_files = Dir.glob(File.join(worker_root, "*", "strict_edges.csv")).sort
cand_files = Dir.glob(File.join(worker_root, "*", "candidate_edges.csv")).sort

(node_files + edge_files + cand_files).each do |path|
  case File.basename(path)
  when "nodes.csv" then assert_headers!(path, NODE_HEADERS)
  when "strict_edges.csv" then assert_headers!(path, EDGE_HEADERS)
  when "candidate_edges.csv" then assert_headers!(path, CAND_HEADERS)
  end
end

raw_nodes = normalize_graph_layer!(dedupe(node_files.flat_map { |path| read_csv_if_exists(path) }, "node_id"))
raw_edges = normalize_graph_layer!(dedupe(edge_files.flat_map { |path| read_csv_if_exists(path) }, "edge_id"))
raw_cands = dedupe(cand_files.flat_map { |path| read_csv_if_exists(path) }, "edge_id")

nodes = raw_nodes.select { |row| manifest_ids[row["source_paper_id"]] }
current_node_ids = nodes.map { |row| row["node_id"] }.to_h { |id| [id, true] }

existing_nodes_for_mapping = Dir.glob(File.join(ROOT, "extraction_waves", "*", "fulltext_evidence_nodes.csv")).flat_map do |path|
  read_csv_if_exists(path)
end + nodes
existing_node_ids_for_mapping = existing_nodes_for_mapping.map { |row| row["node_id"] }.compact.to_h { |id| [id, true] }
paper_node_map = {}
existing_nodes_for_mapping.each do |row|
  next unless row["node_type"] == "paper"
  next if row["source_paper_id"].to_s.empty?

  paper_node_map[row["source_paper_id"]] ||= row["node_id"]
end

raw_edges_in_manifest_with_endpoints = raw_edges.select do |row|
  manifest_ids[row["evidence_paper_id"]] &&
    current_node_ids[row["source_node_id"]] &&
    current_node_ids[row["target_node_id"]]
end

quarantined_strict_edges = raw_edges_in_manifest_with_endpoints.select do |row|
  row["is_inferred"].to_s.downcase == "true" ||
    row["needs_human_check"].to_s.downcase == "true" ||
    row["graph_layer"] != "evidence"
end

edges = raw_edges_in_manifest_with_endpoints - quarantined_strict_edges

quarantined_candidates = quarantined_strict_edges.map.with_index(1) do |row, index|
  {
    "edge_id" => "CAND.QUARANTINED.#{row["edge_id"] || index}",
    "graph_layer" => "candidate",
    "source_node_id" => row["source_node_id"],
    "target_node_id" => row["target_node_id"],
    "relation_type" => row["relation_type"],
    "evidence_paper_id" => row["evidence_paper_id"],
    "evidence_year" => row["evidence_year"],
    "visible_year" => row["visible_year"],
    "evidence_source_type" => row["evidence_source_type"],
    "evidence_location" => row["evidence_location"],
    "evidence_quote" => row["evidence_quote"],
    "confidence" => row["confidence"].to_s.empty? ? "medium" : row["confidence"],
    "is_inferred" => row["is_inferred"],
    "needs_human_check" => "true",
    "notes" => "candidate_status=strict_quarantined_unreviewed; original_edge_id=#{row["edge_id"]}; #{row["notes"]}",
    "explicitness" => "worker_marked_needs_review_or_non_strict",
    "review_reason" => "This row was submitted as a strict edge but had needs_human_check=true, is_inferred=true, or non-evidence graph_layer; merge script quarantined it into candidate layer."
  }
end

cands = dedupe(
  raw_cands.select { |row| manifest_ids[row["evidence_paper_id"]] } + quarantined_candidates,
  "edge_id"
)
retarget_paper_placeholders!(cands, existing_node_ids_for_mapping.merge(current_node_ids), paper_node_map)

write_csv(File.join(wave_dir, "fulltext_evidence_nodes.csv"), NODE_HEADERS, nodes)
write_csv(File.join(wave_dir, "fulltext_evidence_edges.csv"), EDGE_HEADERS, edges)
write_csv(File.join(wave_dir, "development_edge_candidates.csv"), CAND_HEADERS, cands)

all_extracted_node_ids = Dir.glob(File.join(ROOT, "extraction_waves", "*", "fulltext_evidence_nodes.csv")).flat_map do |path|
  read_csv_if_exists(path).map { |row| row["node_id"] }
end.to_h { |id| [id, true] }
all_extracted_node_ids.merge!(current_node_ids)

strict_endpoint_errors = edges.select do |row|
  !current_node_ids[row["source_node_id"]] || !current_node_ids[row["target_node_id"]]
end
strict_inferred = edges.select { |row| row["is_inferred"].to_s.downcase == "true" }
strict_needs_review = edges.select { |row| row["needs_human_check"].to_s.downcase == "true" }
candidate_endpoint_warnings = cands.select do |row|
  !all_extracted_node_ids[row["source_node_id"]] || !all_extracted_node_ids[row["target_node_id"]]
end
candidate_review_errors = cands.reject { |row| row["needs_human_check"].to_s.downcase == "true" }
candidate_layer_errors = cands.reject { |row| row["graph_layer"] == "candidate" }

report = {
  "wave" => wave_name,
  "worker_node_files" => node_files.size,
  "worker_edge_files" => edge_files.size,
  "worker_candidate_files" => cand_files.size,
  "raw_nodes" => raw_nodes.size,
  "raw_strict_edges" => raw_edges.size,
  "raw_candidate_edges" => raw_cands.size,
  "nodes" => nodes.size,
  "strict_edges" => edges.size,
  "candidate_edges" => cands.size,
  "excluded_non_manifest_nodes" => raw_nodes.size - nodes.size,
  "excluded_non_manifest_or_bad_endpoint_strict_edges" => raw_edges.size - raw_edges_in_manifest_with_endpoints.size,
  "quarantined_strict_edges_to_candidates" => quarantined_strict_edges.size,
  "excluded_non_manifest_candidate_edges" => raw_cands.size - raw_cands.select { |row| manifest_ids[row["evidence_paper_id"]] }.size,
  "strict_endpoint_errors" => strict_endpoint_errors.size,
  "strict_is_inferred_true" => strict_inferred.size,
  "strict_needs_human_check_true" => strict_needs_review.size,
  "candidate_endpoint_warnings" => candidate_endpoint_warnings.size,
  "candidate_needs_human_check_false" => candidate_review_errors.size,
  "candidate_graph_layer_errors" => candidate_layer_errors.size
}

File.write(File.join(wave_dir, "validation_report.md"), <<~MD)
  # #{wave_name} Validation Report

  #{report.map { |k, v| "- #{k}: #{v}" }.join("\n")}

  ## Strict endpoint errors

  #{strict_endpoint_errors.empty? ? "None." : strict_endpoint_errors.map { |r| "- #{r["edge_id"]}: #{r["source_node_id"]} -> #{r["target_node_id"]}" }.join("\n")}

  ## Candidate endpoint warnings

  #{candidate_endpoint_warnings.empty? ? "None." : candidate_endpoint_warnings.map { |r| "- #{r["edge_id"]}: #{r["source_node_id"]} -> #{r["target_node_id"]}" }.join("\n")}
MD

puts report.map { |k, v| "#{k}=#{v}" }.join(" ")
