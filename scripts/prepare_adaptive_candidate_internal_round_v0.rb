#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"
require "set"

ROOT = File.expand_path("..", __dir__)
GRAPH = File.join(ROOT, "current_coverage_graph_v0")
FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_adaptive_g6_assay")
RUN_ID = ARGV[0] || abort("Usage: ruby scripts/prepare_adaptive_candidate_internal_round_v0.rb RUN_ID round1|round2")
ROUND = ARGV[1] || abort("Usage: ruby scripts/prepare_adaptive_candidate_internal_round_v0.rb RUN_ID round1|round2")
abort("ROUND must be round1 or round2") unless %w[round1 round2].include?(ROUND)

UNIT_ID = "unit_906"
RUN_DIR = File.join(FRAMEWORK, "model_runs", RUN_ID)
ROUNDS = File.join(RUN_DIR, "rounds")
PACKETS = File.join(RUN_DIR, "packets", ROUND)
PRIVATE = File.join(RUN_DIR, "private")

ITEM_HEADERS = %w[item_id item_kind label paper_id year section evidence paraphrase].freeze
LINK_HEADERS = %w[link_id from_item_id to_item_id paper_id year evidence_location evidence].freeze

def read_csv(path)
  return [] unless File.exist?(path)

  CSV.read(path, headers: true).map(&:to_h)
end

def write_csv(path, headers, rows)
  CSV.open(path, "w", write_headers: true, headers: headers) do |csv|
    rows.each { |row| csv << headers.map { |header| row[header] } }
  end
end

def item_from_node(row)
  {
    "item_id" => row["node_id"],
    "item_kind" => row["node_type"],
    "label" => row["canonical_label"],
    "paper_id" => row["source_paper_id"],
    "year" => row["visible_year"],
    "section" => row["source_section"],
    "evidence" => row["evidence_quote"],
    "paraphrase" => row["paraphrase"]
  }
end

def extract_field(text, field)
  match = text.match(/^#{Regexp.escape(field)}\s*:\s*(.+)$/i)
  return [] unless match

  match[1].split(/[;,]/).map { |value| value.gsub(/[`"'，]/, "").strip }.reject(&:empty?)
end

def selected_ids_from_outputs(rounds_dir, round)
  source_round =
    if round == "round1"
      "round0"
    else
      "round1"
    end
  path = File.join(rounds_dir, "#{UNIT_ID}_#{source_round}.md")
  abort("Missing prior output: #{path}") unless File.exist?(path)

  text = File.read(path)
  {
    "selected_link_ids" => extract_field(text, "selected_link_ids"),
    "selected_item_ids" => extract_field(text, "selected_item_ids"),
    "selected_paper_ids" => extract_field(text, "selected_paper_ids")
  }
end

abort("Missing run directory: #{RUN_DIR}") unless Dir.exist?(RUN_DIR)

FileUtils.rm_rf(PACKETS)
FileUtils.mkdir_p(PACKETS)
FileUtils.mkdir_p(PRIVATE)

nodes = read_csv(File.join(GRAPH, "current_evidence_nodes.csv"))
node_by_id = nodes.each_with_object({}) { |row, index| index[row["node_id"]] = row }
strict_edges = read_csv(File.join(GRAPH, "graph_variants", "paper_internal_edges_only.csv"))
visible_items = read_csv(File.join(FRAMEWORK, "inputs", "round0_items.csv"))
update_items = read_csv(File.join(FRAMEWORK, "inputs", ROUND == "round1" ? "update_a_items.csv" : "update_b_items.csv"))
candidate_key = read_csv(File.join(FRAMEWORK, "private", "round0_candidate_link_key_private.csv"))

selected = selected_ids_from_outputs(ROUNDS, ROUND)
selected_papers = Set.new(selected["selected_paper_ids"])
selected_items = Set.new(selected["selected_item_ids"])

candidate_key.each do |row|
  next unless selected["selected_link_ids"].include?(row["link_id"])

  [row["from_item_id"], row["to_item_id"]].each do |node_id|
    node = node_by_id[node_id]
    next unless node

    selected_items << node_id
    selected_papers << node["source_paper_id"]
  end
end

selected_items.each do |node_id|
  node = node_by_id[node_id]
  selected_papers << node["source_paper_id"] if node
end

abort("No selected_paper_ids could be resolved from prior output") if selected_papers.empty?

allowed_papers = selected_papers
round_max_year = ROUND == "round1" ? 2024 : 3000
allowed_nodes = nodes.select do |row|
  allowed_papers.include?(row["source_paper_id"]) && row["visible_year"].to_i <= round_max_year
end
allowed_node_ids = allowed_nodes.each_with_object({}) { |row, ids| ids[row["node_id"]] = true }

internal_edges = strict_edges.select do |edge|
  allowed_node_ids[edge["source_node_id"]] &&
    allowed_node_ids[edge["target_node_id"]] &&
    edge["visible_year"].to_i <= round_max_year
end.sort_by { |edge| edge["edge_id"] }

internal_links = internal_edges.each_with_index.map do |edge, index|
  {
    "link_id" => "#{ROUND == "round1" ? "I" : "J"}#{format("%04d", index + 1)}",
    "from_item_id" => edge["source_node_id"],
    "to_item_id" => edge["target_node_id"],
    "paper_id" => edge["evidence_paper_id"],
    "year" => edge["visible_year"],
    "evidence_location" => edge["evidence_location"],
    "evidence" => edge["evidence_quote"]
  }
end

write_csv(File.join(PACKETS, "items.csv"), ITEM_HEADERS, allowed_nodes.map { |row| item_from_node(row) })
write_csv(File.join(PACKETS, "internal_links.csv"), LINK_HEADERS, internal_links)
write_csv(File.join(PACKETS, "feedback_items.csv"), ITEM_HEADERS, update_items)
write_csv(
  File.join(PRIVATE, "#{ROUND}_unlock_manifest.csv"),
  %w[round selected_link_ids selected_item_ids selected_paper_ids resolved_paper_ids unlocked_items unlocked_internal_links],
  [
    {
      "round" => ROUND,
      "selected_link_ids" => selected["selected_link_ids"].join(";"),
      "selected_item_ids" => selected["selected_item_ids"].join(";"),
      "selected_paper_ids" => selected["selected_paper_ids"].join(";"),
      "resolved_paper_ids" => allowed_papers.to_a.sort.join(";"),
      "unlocked_items" => allowed_nodes.size,
      "unlocked_internal_links" => internal_links.size
    }
  ]
)

File.write(File.join(PACKETS, "brief.md"), <<~MD)
  # Adaptive Trial Brief: #{ROUND}

  You are continuing the same sealed literature-graph trial.

  ## Allowed Files

  Read only files in this directory:

  - `brief.md`
  - `items.csv`
  - `internal_links.csv`
  - `feedback_items.csv`

  ## Prohibited Actions

  - Do not search the filesystem.
  - Do not use `rg`, `grep`, `find`, `ls`, web search, browser tools, or any command/tool to discover other files.
  - Do not open parent directories, sibling directories, framework directories, mapping files, logs, scripts, or metadata.
  - Do not infer hidden labels from filenames, row counts, link counts, or missing files.
  - Do not mention or guess hidden condition names.

  ## Data Semantics

  - `items.csv` contains mechanism-grounding observations mechanically unlocked from your prior selected branch.
  - `internal_links.csv` contains strict paper-internal links for the unlocked papers.
  - `feedback_items.csv` contains the same later observations used for this update round in the broader assay. It is feedback, not advice.

  ## Task

  Revise the same idea rather than restarting. Use the unlocked internal links to learn mechanisms inside the selected branch. Use feedback items to decide whether the branch is strengthened, narrowed, or partially rejected.

  Required fields:

  - `selected_path_label`
  - `selected_link_ids`
  - `selected_item_ids`
  - `selected_paper_ids`
  - `internal_link_step_table`
  - `what_feedback_changed`
  - `what_feedback_did_not_change`
  - `mechanism_learned_from_internal_links`
  - `revised_idea`
  - `updated_path_claims`
  - `next_test`
  - `branch_drift_check`

  Use this exact link-step table header whenever you claim link support:

  | claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |

  `selected_link_ids`, `selected_item_ids`, and `selected_paper_ids` should be semicolon-separated and should reflect the branch you carry forward after this round. Link ids must come from `internal_links.csv`; do not invent link ids.
MD

puts "packet=#{PACKETS}"
puts "round=#{ROUND}"
puts "resolved_paper_ids=#{allowed_papers.to_a.sort.join(";")}"
puts "unlocked_items=#{allowed_nodes.size}"
puts "unlocked_internal_links=#{internal_links.size}"
