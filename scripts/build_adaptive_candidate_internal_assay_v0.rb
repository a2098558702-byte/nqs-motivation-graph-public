#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
GRAPH = File.join(ROOT, "current_coverage_graph_v0")
SOURCE_ASSAY = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_edge_dependency_assay")
FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_adaptive_g6_assay")
SEALED = File.join(ROOT, "trajectory_experiments", "sealed_trial_v2")
UNIT_ID = "unit_906"
CUTOFF = 2023

ITEM_HEADERS = %w[item_id item_kind label paper_id year section evidence paraphrase].freeze
LINK_HEADERS = %w[link_id from_item_id to_item_id paper_id year evidence_location evidence].freeze
KEY_HEADERS = %w[round link_id source_edge_id relation_type from_item_id to_item_id paper_id year].freeze

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

graph_builder = File.join(ROOT, "scripts", "build_current_coverage_graph_v0.rb")
abort("Failed to rebuild current coverage graph") unless system("ruby", graph_builder)

source_nodes_path = File.join(SOURCE_ASSAY, "inputs", "assay_visible_nodes_raw.csv")
source_update_a_path = File.join(SOURCE_ASSAY, "inputs", "assay_update_a_nodes_raw.csv")
source_update_b_path = File.join(SOURCE_ASSAY, "inputs", "assay_update_b_nodes_raw.csv")

unless File.exist?(source_nodes_path) && File.exist?(source_update_a_path) && File.exist?(source_update_b_path)
  abort("Missing edge-dependency assay inputs. Run: ruby scripts/build_edge_dependency_assay_v0.rb")
end

abort("Refusing unexpected framework path") unless FRAMEWORK.start_with?(File.join(ROOT, "trajectory_experiments"))
abort("Refusing unexpected sealed path") unless SEALED.start_with?(File.join(ROOT, "trajectory_experiments"))

FileUtils.rm_rf(FRAMEWORK)
FileUtils.rm_rf(SEALED)
FileUtils.mkdir_p(File.join(FRAMEWORK, "inputs"))
FileUtils.mkdir_p(File.join(FRAMEWORK, "private"))
FileUtils.mkdir_p(File.join(SEALED, UNIT_ID, "round0"))

nodes = read_csv(File.join(GRAPH, "current_evidence_nodes.csv"))
node_by_id = nodes.each_with_object({}) { |row, index| index[row["node_id"]] = row }
visible_nodes = read_csv(source_nodes_path)
update_a_nodes = read_csv(source_update_a_path)
update_b_nodes = read_csv(source_update_b_path)
visible_ids = visible_nodes.each_with_object({}) { |row, ids| ids[row["node_id"]] = true }

candidate_edges = read_csv(File.join(GRAPH, "graph_variants", "candidate_context_edges_clean.csv"))
round0_edges = candidate_edges.select do |edge|
  edge["visible_year"].to_i <= CUTOFF &&
    visible_ids[edge["source_node_id"]] &&
    visible_ids[edge["target_node_id"]]
end.sort_by { |edge| edge["edge_id"] }

round0_links = round0_edges.each_with_index.map do |edge, index|
  {
    "link_id" => "C#{format("%04d", index + 1)}",
    "from_item_id" => edge["source_node_id"],
    "to_item_id" => edge["target_node_id"],
    "paper_id" => edge["evidence_paper_id"],
    "year" => edge["visible_year"],
    "evidence_location" => edge["evidence_location"],
    "evidence" => edge["evidence_quote"]
  }
end

round0_key = round0_links.zip(round0_edges).map do |link, edge|
  {
    "round" => "round0",
    "link_id" => link["link_id"],
    "source_edge_id" => edge["edge_id"],
    "relation_type" => edge["relation_type"],
    "from_item_id" => link["from_item_id"],
    "to_item_id" => link["to_item_id"],
    "paper_id" => link["paper_id"],
    "year" => link["year"]
  }
end

write_csv(File.join(FRAMEWORK, "inputs", "round0_items.csv"), ITEM_HEADERS, visible_nodes.map { |row| item_from_node(row) })
write_csv(File.join(FRAMEWORK, "inputs", "round0_candidate_links.csv"), LINK_HEADERS, round0_links)
write_csv(File.join(FRAMEWORK, "inputs", "update_a_items.csv"), ITEM_HEADERS, update_a_nodes.map { |row| item_from_node(row) })
write_csv(File.join(FRAMEWORK, "inputs", "update_b_items.csv"), ITEM_HEADERS, update_b_nodes.map { |row| item_from_node(row) })
write_csv(File.join(FRAMEWORK, "private", "round0_candidate_link_key_private.csv"), KEY_HEADERS, round0_key)

write_csv(File.join(SEALED, UNIT_ID, "round0", "items.csv"), ITEM_HEADERS, visible_nodes.map { |row| item_from_node(row) })
write_csv(File.join(SEALED, UNIT_ID, "round0", "links.csv"), LINK_HEADERS, round0_links)

File.write(File.join(SEALED, UNIT_ID, "round0", "brief.md"), <<~MD)
  # Adaptive Trial Brief: Round 0

  You are running the first round of one sealed literature-graph trial.

  ## Allowed Files

  Read only files in this directory:

  - `brief.md`
  - `items.csv`
  - `links.csv`

  ## Prohibited Actions

  - Do not search the filesystem.
  - Do not use `rg`, `grep`, `find`, `ls`, web search, browser tools, or any command/tool to discover other files.
  - Do not open parent directories, sibling directories, framework directories, mapping files, logs, scripts, or metadata.
  - Do not infer hidden labels from filenames, row counts, link counts, or missing files.
  - Do not mention or guess hidden condition names.

  ## Round 0 Task

  Use `links.csv` as a navigation layer. First propose one research idea, then self-evaluate which candidate path or local branch it belongs to.

  The output must contain these fields exactly:

  - `selected_path_label`
  - `selected_link_ids`
  - `selected_item_ids`
  - `selected_paper_ids`
  - `path_selection_rationale`
  - `round0_link_step_table`
  - `idea_title`
  - `assumed_bottleneck`
  - `research_idea`
  - `why_this_path`
  - `minimal_test`
  - `risk_or_limitation`

  Use this exact link-step table header whenever you claim link support:

  | claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |

  `selected_link_ids`, `selected_item_ids`, and `selected_paper_ids` should be semicolon-separated. `selected_paper_ids` must use the `paper_id` values visible in `items.csv`, not paper titles.

  If a connected multi-step path is unavailable, choose the strongest local link cluster and say so explicitly. Do not invent link ids.
MD

File.write(File.join(SEALED, "README.md"), <<~MD)
  # Sealed Trial V2

  This directory contains staged adaptive trial packets. Use only the current round packet given by the controller. Do not inspect parent or sibling directories.
MD

File.write(File.join(FRAMEWORK, "TEST_FRAMEWORK_LOGIC.md"), <<~MD)
  # Adaptive G6 Candidate-To-Internal Assay

  ## Purpose

  This assay tests a staged external-knowledge structure:

  1. Round 0 uses clean candidate-context links as a navigation layer.
  2. The generator self-selects a path using explicit selected link/item/paper ids.
  3. Round 1 mechanically unlocks strict paper-internal evidence only for selected path papers, plus the same 2024 feedback items used in the other current-coverage assays.
  4. Round 2 repeats the process with 2025-2026 feedback and the current selected branch.

  The point is to test whether candidate edges are useful for branch selection while strict internal edges are useful for mechanism grounding after a branch has been selected.

  ## No Manual Branch Choice

  The controller does not choose the branch. `scripts/prepare_adaptive_candidate_internal_round_v0.rb` parses the generator's selected ids and unlocks internal nodes/links mechanically.

  ## Model Roles

  - Generator: `gpt-5.2`, reasoning effort `low`.
  - Blind evaluator, if run: `gpt-5.5`, reasoning effort `xhigh`.
  - Controller/main agent must not substitute qualitative judgment for the evaluator.
MD

File.write(File.join(FRAMEWORK, "RUNBOOK.md"), <<~MD)
  # Adaptive G6 Runbook

  Build the staged packet:

  ```bash
  ruby scripts/build_adaptive_candidate_internal_assay_v0.rb
  ```

  Scaffold a run:

  ```bash
  ruby scripts/scaffold_adaptive_candidate_internal_run_v0.rb RUN_ID
  ```

  Run Round 0 with `gpt-5.2` / `low` using only:

  ```text
  trajectory_experiments/sealed_trial_v2/#{UNIT_ID}/round0/
  ```

  Save Round 0 output to:

  ```text
  trajectory_experiments/current_coverage_v0_adaptive_g6_assay/model_runs/RUN_ID/rounds/#{UNIT_ID}_round0.md
  ```

  Prepare Round 1 packet:

  ```bash
  ruby scripts/prepare_adaptive_candidate_internal_round_v0.rb RUN_ID round1
  ```

  Run Round 1 using only the generated run packet. Then prepare and run Round 2:

  ```bash
  ruby scripts/prepare_adaptive_candidate_internal_round_v0.rb RUN_ID round2
  ruby scripts/assemble_adaptive_candidate_internal_trajectory_v0.rb RUN_ID
  ruby scripts/check_adaptive_candidate_internal_outputs_v0.rb RUN_ID
  ```
MD

File.write(File.join(FRAMEWORK, "README.md"), <<~MD)
  # Adaptive G6 Candidate-To-Internal Assay

  Initial round-0 packet: `trajectory_experiments/sealed_trial_v2/#{UNIT_ID}/round0/`.
MD

puts "framework=#{FRAMEWORK}"
puts "sealed_round0=#{File.join(SEALED, UNIT_ID, "round0")}"
puts "round0_items=#{visible_nodes.size}"
puts "round0_candidate_links=#{round0_links.size}"
