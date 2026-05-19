#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
GRAPH = File.join(ROOT, "current_coverage_graph_v0")
FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_edge_dependency_assay")
SEALED = File.join(ROOT, "trajectory_experiments", "sealed_trial_v1")
INPUTS = File.join(FRAMEWORK, "inputs")
PRIVATE = File.join(FRAMEWORK, "private")
CUTOFF = 2023

GENERATOR_MODEL = "gpt-5.2"
GENERATOR_REASONING_EFFORT = "low"
EVALUATOR_MODEL = "gpt-5.5"
EVALUATOR_REASONING_EFFORT = "xhigh"

UNIT_CASES = {
  "unit_118" => "G1",
  "unit_432" => "G2",
  "unit_795" => "G3",
  "unit_156" => "G4",
  "unit_608" => "G5"
}.freeze

CONDITIONS = {
  "G1" => {
    name: "nodes_only",
    edge_file: File.join(GRAPH, "graph_variants", "empty_edges_for_nodes_only.csv")
  },
  "G2" => {
    name: "strict_paper_internal",
    edge_file: File.join(GRAPH, "graph_variants", "paper_internal_edges_only.csv")
  },
  "G3" => {
    name: "clean_candidate_context",
    edge_file: File.join(GRAPH, "graph_variants", "candidate_context_edges_clean.csv")
  },
  "G4" => {
    name: "strict_plus_clean_candidate_context",
    edge_file: File.join(GRAPH, "graph_variants", "paper_internal_plus_clean_candidate_context_edges.csv")
  },
  "G5" => {
    name: "paper_citation_only",
    edge_file: File.join(GRAPH, "graph_variants", "paper_citation_edges_only.csv")
  }
}.freeze

ITEM_HEADERS = %w[
  item_id item_kind label paper_id year section evidence paraphrase
].freeze

LINK_HEADERS = %w[
  link_id from_item_id to_item_id paper_id year evidence_location evidence
].freeze

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

def filter_edges(edges, allowed_node_ids, max_year)
  edges.select do |edge|
    edge["visible_year"].to_i <= max_year &&
      allowed_node_ids[edge["source_node_id"]] &&
      allowed_node_ids[edge["target_node_id"]]
  end
end

def incremental_edges(all_edges, seen_edge_ids)
  all_edges.reject { |edge| seen_edge_ids[edge["edge_id"]] }.tap do |rows|
    rows.each { |edge| seen_edge_ids[edge["edge_id"]] = true }
  end
end

def neutral_links(edges, prefix)
  edges.sort_by { |edge| edge["edge_id"] }.each_with_index.map do |edge, index|
    {
      "link_id" => "#{prefix}#{format("%04d", index + 1)}",
      "from_item_id" => edge["source_node_id"],
      "to_item_id" => edge["target_node_id"],
      "paper_id" => edge["evidence_paper_id"],
      "year" => edge["visible_year"],
      "evidence_location" => edge["evidence_location"],
      "evidence" => edge["evidence_quote"]
    }
  end
end

def link_key_rows(unit, condition_label, condition_name, round_name, links, edges)
  edge_by_pair = {}
  edges.each { |edge| edge_by_pair[[edge["source_node_id"], edge["target_node_id"], edge["evidence_quote"]]] = edge }
  links.map do |link|
    edge = edge_by_pair[[link["from_item_id"], link["to_item_id"], link["evidence"]]]
    {
      "unit_id" => unit,
      "condition_label" => condition_label,
      "condition_name" => condition_name,
      "round" => round_name,
      "link_id" => link["link_id"],
      "edge_id" => edge&.fetch("edge_id", nil),
      "relation_type" => edge&.fetch("relation_type", nil),
      "from_item_id" => link["from_item_id"],
      "to_item_id" => link["to_item_id"],
      "paper_id" => link["paper_id"],
      "year" => link["year"]
    }
  end
end

def compact_counts(rows, key)
  rows.group_by { |row| row[key] }.transform_values(&:size)
      .sort_by { |value, count| [-count, value.to_s] }
      .map { |value, count| "#{value}:#{count}" }
      .join("; ")
end

graph_builder = File.join(ROOT, "scripts", "build_current_coverage_graph_v0.rb")
abort("Failed to rebuild current coverage graph") unless system("ruby", graph_builder)

abort("Missing graph directory: #{GRAPH}") unless Dir.exist?(GRAPH)
abort("Refusing unexpected framework path: #{FRAMEWORK}") unless FRAMEWORK.start_with?(File.join(ROOT, "trajectory_experiments"))
abort("Refusing unexpected sealed path: #{SEALED}") unless SEALED.start_with?(File.join(ROOT, "trajectory_experiments"))

FileUtils.rm_rf(FRAMEWORK)
FileUtils.rm_rf(SEALED)
FileUtils.mkdir_p(INPUTS)
FileUtils.mkdir_p(PRIVATE)
FileUtils.mkdir_p(SEALED)

nodes = read_csv(File.join(GRAPH, "current_evidence_nodes.csv"))
node_by_id = nodes.each_with_object({}) { |row, index| index[row["node_id"]] = row }
condition_edges = CONDITIONS.transform_values { |info| read_csv(info[:edge_file]) }

visible_nodes_all = nodes.select { |row| row["visible_year"].to_i <= CUTOFF }
round1_nodes = nodes.select { |row| row["visible_year"].to_i == 2024 }
round2_nodes = nodes.select { |row| row["visible_year"].to_i >= 2025 }
visible_all_ids = visible_nodes_all.each_with_object({}) { |row, ids| ids[row["node_id"]] = true }

union_visible_edges = CONDITIONS.keys.reject { |label| label == "G1" }.flat_map do |label|
  filter_edges(condition_edges.fetch(label), visible_all_ids, CUTOFF)
end
degree = Hash.new(0)
union_visible_edges.each do |edge|
  degree[edge["source_node_id"]] += 1
  degree[edge["target_node_id"]] += 1
end

# The item subset is selected once from the union of non-empty relation layers, then reused
# unchanged for every sealed unit. This keeps the packet compact while preserving comparability.
selected_ids = {}

g3_visible = filter_edges(condition_edges.fetch("G3"), visible_all_ids, CUTOFF)
g3_visible.each do |edge|
  selected_ids[edge["source_node_id"]] = true
  selected_ids[edge["target_node_id"]] = true
end

g5_visible = filter_edges(condition_edges.fetch("G5"), visible_all_ids, CUTOFF)
g5_visible.each do |edge|
  selected_ids[edge["source_node_id"]] = true
  selected_ids[edge["target_node_id"]] = true
end

paper_nodes = visible_nodes_all.select { |row| row["node_type"] == "paper" }
paper_nodes.each { |row| selected_ids[row["node_id"]] = true }

strict_visible = filter_edges(condition_edges.fetch("G2"), visible_all_ids, CUTOFF)
strict_by_paper = strict_visible.group_by { |edge| edge["source_node_id"] }
paper_nodes.each do |paper|
  edges = strict_by_paper.fetch(paper["node_id"], [])
  edges.sort_by { |edge| [edge["relation_type"], edge["target_node_id"]] }.first(2).each do |edge|
    selected_ids[edge["target_node_id"]] = true
  end
end

max_items = 150
visible_nodes_all.sort_by { |row| [-degree[row["node_id"]], row["node_id"]] }.each do |row|
  break if selected_ids.size >= max_items

  selected_ids[row["node_id"]] = true
end

visible_nodes = visible_nodes_all.select { |row| selected_ids[row["node_id"]] }
visible_ids = visible_nodes.each_with_object({}) { |row, ids| ids[row["node_id"]] = true }

round1_all_ids = visible_ids.merge(round1_nodes.each_with_object({}) { |row, ids| ids[row["node_id"]] = true })
round2_all_ids = round1_all_ids.merge(round2_nodes.each_with_object({}) { |row, ids| ids[row["node_id"]] = true })

write_csv(File.join(INPUTS, "assay_visible_items_cutoff_#{CUTOFF}.csv"), ITEM_HEADERS, visible_nodes.map { |row| item_from_node(row) })
write_csv(File.join(INPUTS, "assay_update_a_items_2024.csv"), ITEM_HEADERS, round1_nodes.map { |row| item_from_node(row) })
write_csv(File.join(INPUTS, "assay_update_b_items_2025_2026.csv"), ITEM_HEADERS, round2_nodes.map { |row| item_from_node(row) })
write_csv(File.join(INPUTS, "assay_visible_nodes_raw.csv"), NODE_HEADERS, visible_nodes)
write_csv(File.join(INPUTS, "assay_update_a_nodes_raw.csv"), NODE_HEADERS, round1_nodes)
write_csv(File.join(INPUTS, "assay_update_b_nodes_raw.csv"), NODE_HEADERS, round2_nodes)

condition_rows = []
private_link_rows = []

UNIT_CASES.each do |unit, label|
  info = CONDITIONS.fetch(label)
  case_dir = File.join(SEALED, unit)
  FileUtils.mkdir_p(case_dir)

  edges = condition_edges.fetch(label)
  round0_edges = filter_edges(edges, visible_ids, CUTOFF)
  seen = {}
  round0_increment = incremental_edges(round0_edges, seen)
  round1_edges = filter_edges(edges, round1_all_ids, 2024)
  round1_increment = incremental_edges(round1_edges, seen)
  round2_edges = filter_edges(edges, round2_all_ids, 3000)
  round2_increment = incremental_edges(round2_edges, seen)

  round0_links = neutral_links(round0_increment, "L")
  round1_links = neutral_links(round1_increment, "A")
  round2_links = neutral_links(round2_increment, "B")

  write_csv(File.join(case_dir, "items.csv"), ITEM_HEADERS, visible_nodes.map { |row| item_from_node(row) })
  write_csv(File.join(case_dir, "links.csv"), LINK_HEADERS, round0_links)
  write_csv(File.join(case_dir, "update_a_items.csv"), ITEM_HEADERS, round1_nodes.map { |row| item_from_node(row) })
  write_csv(File.join(case_dir, "update_a_links.csv"), LINK_HEADERS, round1_links)
  write_csv(File.join(case_dir, "update_b_items.csv"), ITEM_HEADERS, round2_nodes.map { |row| item_from_node(row) })
  write_csv(File.join(case_dir, "update_b_links.csv"), LINK_HEADERS, round2_links)

  private_link_rows.concat(link_key_rows(unit, label, info[:name], "round0", round0_links, round0_increment))
  private_link_rows.concat(link_key_rows(unit, label, info[:name], "round1", round1_links, round1_increment))
  private_link_rows.concat(link_key_rows(unit, label, info[:name], "round2", round2_links, round2_increment))

  condition_rows << {
    "unit_id" => unit,
    "condition_label" => label,
    "condition_name" => info[:name],
    "visible_items" => visible_nodes.size,
    "round0_links" => round0_links.size,
    "update_a_items" => round1_nodes.size,
    "update_a_links" => round1_links.size,
    "update_b_items" => round2_nodes.size,
    "update_b_links" => round2_links.size
  }

  File.write(File.join(case_dir, "brief.md"), <<~MD)
    # Trial Brief

    You are running one sealed literature-graph trial.

    ## Allowed Files

    You may read only the files in this directory, and only when the round allows them:

    - `brief.md`
    - `items.csv`
    - `links.csv`
    - `update_a_items.csv`
    - `update_a_links.csv`
    - `update_b_items.csv`
    - `update_b_links.csv`

    ## Prohibited Actions

    - Do not search the filesystem.
    - Do not use `rg`, `grep`, `find`, `ls`, web search, browser tools, or any command/tool to discover other files.
    - Do not open parent directories, sibling directories, framework directories, mapping files, logs, scripts, or metadata.
    - Do not infer why this packet has this shape from filenames, directory names, row counts, link counts, or missing links.
    - Do not mention or guess hidden labels.
    - Do not pre-read update files before their round begins.

    ## Data Semantics

    - `items.csv` contains observations available before the trial starts.
    - `links.csv` may contain zero or more neutral links between observations.
    - Each link has `from_item_id`, `to_item_id`, and supporting evidence.
    - You may traverse a link forward or reverse, but every stated step must cite a real `link_id` and the matching endpoint pair.
    - Later files are observations only, not advice.

    ## Required Link-Step Table

    Whenever you claim support from links, use this exact table header:

    | claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |

    `traversal` must be `forward` if the step follows `from_item_id -> to_item_id` as written in the link file, or `reverse` if it uses the same link in the opposite direction.

    If there are not enough links to build a support path, say `insufficient_link_support` and do not invent link ids.

    ## Round-Gated Access

    - Round 0: read only `brief.md`, `items.csv`, and `links.csv`.
    - Round 1: after completing Round 0 output, read `update_a_items.csv` and `update_a_links.csv`.
    - Round 2: after completing Round 1 output, read `update_b_items.csv` and `update_b_links.csv`.

    ## Task

    Run three rounds. Your main object is not a general literature summary; it is a research direction whose support is auditable through link-connected observations.

    ### Round 0

    Build up to three support paths. Prefer two to four link steps per path when available. A one-step path is acceptable only when no connected multi-step alternative is available.

    Required fields:

    - `round0_link_step_table`
    - `round0_path_claims`
    - `idea_title`
    - `assumed_bottleneck`
    - `research_idea`
    - `why_the_idea_depends_on_the_paths`
    - `minimal_test`
    - `risk_or_limitation`

    If no real support path can be built, separate any prose under `node_local_fallback_only`.

    ### Round 1

    After reading `update_a_items.csv` and `update_a_links.csv`, revise rather than restart. Add, repair, or reject paths using the new observations. Use at least one newly available link if a valid one helps; otherwise state why none can be used.

    Required fields:

    - `round1_link_delta_table`
    - `what_update_changed`
    - `what_update_did_not_change`
    - `revised_idea`
    - `updated_path_claims`
    - `next_test`

    ### Round 2

    After reading `update_b_items.csv` and `update_b_links.csv`, revise again and state the final trajectory. Use at least one newly available link if a valid one helps; otherwise state why none can be used.

    Required fields:

    - `round2_link_delta_table`
    - `final_research_direction`
    - `trajectory_summary`
    - `which_bottleneck_survived`
    - `which_path_was_strengthened_or_rejected`
    - `what_would_be_measured_first`
    - `failure_mode_to_watch`

    Keep the output concise but complete.
  MD
end

write_csv(
  File.join(FRAMEWORK, "condition_matrix_private.csv"),
  %w[unit_id condition_label condition_name visible_items round0_links update_a_items update_a_links update_b_items update_b_links],
  condition_rows
)
write_csv(
  File.join(PRIVATE, "unit_condition_key_private.csv"),
  %w[unit_id condition_label condition_name visible_items round0_links update_a_items update_a_links update_b_items update_b_links],
  condition_rows
)
write_csv(
  File.join(PRIVATE, "unit_link_key_private.csv"),
  %w[unit_id condition_label condition_name round link_id edge_id relation_type from_item_id to_item_id paper_id year],
  private_link_rows
)

File.write(File.join(SEALED, "README.md"), <<~MD)
  # Sealed Trial V1

  This directory is the only packet intended for generation workers.

  Use one unit directory at a time. Workers must read only files inside their assigned unit directory and must not search, browse, list sibling directories, inspect parent directories, or open mapping files.

  No mapping file is stored here.
MD

File.write(File.join(FRAMEWORK, "MODEL_RUN_PROTOCOL.md"), <<~MD)
  # Edge Dependency Assay Model Run Protocol

  ## Roles

  - Generator: `#{GENERATOR_MODEL}`, reasoning effort `#{GENERATOR_REASONING_EFFORT}`.
  - Blind evaluator: `#{EVALUATOR_MODEL}`, reasoning effort `#{EVALUATOR_REASONING_EFFORT}`.

  The controller/main agent prepares packets, launches or records model runs, checks mechanical link validity, and preserves blindness. It must not substitute qualitative judgment for the blind evaluator.

  ## Generator Procedure

  1. Assign each generator exactly one sealed unit directory under `trajectory_experiments/sealed_trial_v1/unit_*`.
  2. Use `#{GENERATOR_MODEL}` with reasoning effort `#{GENERATOR_REASONING_EFFORT}`.
  3. Enforce round-gated access:
     - Round 0: `brief.md`, `items.csv`, `links.csv`.
     - Round 1: unlock `update_a_items.csv` and `update_a_links.csv` only after Round 0 output is complete.
     - Round 2: unlock `update_b_items.csv` and `update_b_links.csv` only after Round 1 output is complete.
  4. Save each trajectory with the sealed unit id under a run-specific `rounds/` directory.

  ## Mechanical Audit

  After generation, run:

  ```bash
  ruby scripts/check_edge_dependency_assay_outputs_v0.rb RUN_ID
  ```

  This audit only checks link mechanics: whether cited link ids exist, whether stated endpoints match, and whether path tables are continuous. It is not a qualitative evaluation of scientific merit.

  ## Blind Evaluation Procedure

  Use `#{EVALUATOR_MODEL}` with reasoning effort `#{EVALUATOR_REASONING_EFFORT}` for qualitative evaluation. The evaluator receives anonymized trajectories, the assay rubric, and the mechanical audit summary, but not private mappings.

  ## Prohibited

  - Do not let generator or evaluator search, browse, list parent/sibling directories, or inspect scripts/logs/metadata.
  - Do not expose files under `private/` to the generator or evaluator.
  - Do not use the controller/main agent as the qualitative scorer.
MD

File.write(File.join(FRAMEWORK, "EVALUATION_RUBRIC.md"), <<~MD)
  # Edge Dependency Assay Evaluation Rubric

  Score each trajectory from 1 to 5 on each metric. This assay is deliberately different from an open-ended research-idea contest: the primary observable is whether the trajectory depends on auditable link-connected observations.

  ## Primary Metrics

  - Link-id validity: cited link ids exist in the allowed files for the relevant round.
  - Endpoint fidelity: stated `from_item_id`, `to_item_id`, and traversal direction match the cited link.
  - Path continuity: multi-step claims form continuous paths rather than disconnected link lists.
  - Link-evidence faithfulness: prose interpretation follows the linked observations and support evidence.
  - Update locality: Round 1 and Round 2 revise, extend, or reject earlier paths using newly available observations.
  - Unsupported-bridge control: the trajectory does not smuggle in unlinked semantic jumps as if they were link-supported.
  - Conclusion dependence: the final research direction would materially change if the support paths were removed.
  - Testability: the final direction includes a realistic benchmark, diagnostic, or falsification path.

  ## Nodes-Only Handling

  A packet with no usable links can be honest and well written, but it cannot receive high scores on link-id validity, endpoint fidelity, path continuity, update locality through links, or conclusion dependence on paths. Do not inflate the primary score for node-local synthesis. Record node-local fallback quality separately if useful.

  ## Required Evaluator

  Blind qualitative evaluation must be performed by `#{EVALUATOR_MODEL}` with reasoning effort `#{EVALUATOR_REASONING_EFFORT}`.

  The controller/main agent must not substitute its own judgment for this blind evaluation.

  ## Required Output Schema

  For each anonymized trajectory:

  - `anonymous_case_id`
  - metric scores from 1 to 5
  - mechanical audit notes, if provided
  - short evidence-grounded rationale
  - whether the final direction truly depends on support paths
  - unsupported-bridge or hallucinated-link concerns
  - uncertainty notes

  Also provide a cross-case comparison without revealing or guessing hidden mappings.
MD

File.write(File.join(FRAMEWORK, "TEST_FRAMEWORK_LOGIC.md"), <<~MD)
  # Current Coverage V0 Edge Dependency Assay

  ## Purpose

  The existing three-round trajectory test can reward strong node-local synthesis, so a no-link packet can still produce a persuasive research plan. This assay isolates a different question: does an allowed relation layer help a generator build, preserve, and revise auditable support paths?

  ## Core Design

  - Every sealed unit receives the same selected observation items.
  - Only the link layer changes across units.
  - The task requires explicit path tables with `link_id`, endpoints, and traversal direction.
  - A no-link unit is expected to abstain from path claims and therefore score low on the primary relation-dependency metrics.
  - Later rounds unlock new items and new links together, so update quality can be measured as path repair/extension rather than generic feedback absorption.

  ## Conditions

  - `G1 nodes_only`: same selected items, no links.
  - `G2 strict_paper_internal`: selected items plus paper-local strict links.
  - `G3 clean_candidate_context`: selected items plus endpoint-clean candidate-context links.
  - `G4 strict_plus_clean_candidate_context`: selected items plus strict and clean candidate-context links.
  - `G5 paper_citation_only`: selected items plus paper-to-paper reference-list links.

  ## Item Selection

  Round 0 uses a compact shared item set selected before sealing:

  - all visible paper nodes;
  - endpoints of visible clean candidate-context links;
  - endpoints of visible paper-citation links;
  - up to two strict paper-local targets per visible paper;
  - highest union-degree visible nodes until the packet reaches the configured cap.

  The selection is reused unchanged for every unit. Updates use all currently available 2024 items in Round 1 and all 2025-2026 items in Round 2.

  ## Scoring Separation

  - Mechanical audit: deterministic script checks cited link ids, endpoint matches, and path continuity.
  - Qualitative evaluation: blind `#{EVALUATOR_MODEL}`/`#{EVALUATOR_REASONING_EFFORT}` evaluator applies `EVALUATION_RUBRIC.md`.
  - Controller/main agent may report audit outputs but must not qualitatively score trajectories.

  ## Contamination Rules

  Generator-facing control files must not contain hidden condition names, private mappings, role labels, or metadata hints. Generators may not search, browse, list directories, inspect parent/sibling directories, or pre-read future-round files.
MD

File.write(File.join(FRAMEWORK, "RUNBOOK.md"), <<~MD)
  # Edge Dependency Assay Runbook

  Build sealed packets:

  ```bash
  ruby scripts/build_edge_dependency_assay_v0.rb
  ```

  Generator-facing packets are written to:

  ```text
  trajectory_experiments/sealed_trial_v1/unit_*
  ```

  Run each unit with:

  - generator model: `#{GENERATOR_MODEL}`
  - reasoning effort: `#{GENERATOR_REASONING_EFFORT}`
  - no search, no browsing, no directory listing, no parent/sibling inspection
  - strict round gating

  Save outputs as:

  ```text
  trajectory_experiments/current_coverage_v0_edge_dependency_assay/model_runs/RUN_ID/rounds/unit_XXX_trajectory.md
  ```

  Then run the mechanical audit:

  ```bash
  ruby scripts/check_edge_dependency_assay_outputs_v0.rb RUN_ID
  ```

  Qualitative blind evaluation, if run, must use `#{EVALUATOR_MODEL}` with reasoning effort `#{EVALUATOR_REASONING_EFFORT}` and must not expose private mappings.
MD

control_terms = %w[
  candidate
  strict
  paper_internal
  nodes_only
  edge_schema
  condition
  current_coverage
  G1
  G2
  G3
  G4
  G5
  condition_key
  citation
  cites
  paper_cites_paper
]
control_files = [File.join(SEALED, "README.md")] + UNIT_CASES.keys.map { |unit| File.join(SEALED, unit, "brief.md") }
control_hits = []
control_files.each do |path|
  text = File.read(path)
  control_terms.each do |term|
    control_hits << { "file" => path.sub(ROOT + "/", ""), "term" => term } if text.downcase.include?(term.downcase)
  end
end

File.write(File.join(FRAMEWORK, "SEALED_PACKET_AUDIT.md"), <<~MD)
  # Sealed Packet Audit

  Generated by `scripts/build_edge_dependency_assay_v0.rb`.

  ## Control-Layer Scan

  Scanned generator-facing control files only:

  - `trajectory_experiments/sealed_trial_v1/README.md`
  - `trajectory_experiments/sealed_trial_v1/unit_*/brief.md`

  ## Sensitive Terms Checked

  #{control_terms.map { |term| "- `#{term}`" }.join("\n")}

  ## Result

  #{control_hits.empty? ? "No sensitive control-layer terms found." : control_hits.map { |hit| "- #{hit["file"]}: `#{hit["term"]}`" }.join("\n")}

  ## Note

  Data CSV files are not scanned for ordinary scientific words because they contain source evidence.
MD

File.write(File.join(FRAMEWORK, "README.md"), <<~MD)
  # Current Coverage V0 Edge Dependency Assay

  This framework is a relation-dependent companion to the open-ended trajectory test.

  The no-link unit should not be able to earn a high primary relation-dependency score, because the required output is an auditable support path with real link ids and matching endpoints.
MD

File.write(File.join(FRAMEWORK, "SUMMARY.txt"), <<~TEXT)
  visible_items=#{visible_nodes.size}
  update_a_items=#{round1_nodes.size}
  update_b_items=#{round2_nodes.size}
  selected_item_kind_counts=#{compact_counts(visible_nodes, "node_type")}
  units=#{UNIT_CASES.size}
  sealed_root=#{SEALED.sub(ROOT + "/", "")}
TEXT

puts "framework=#{FRAMEWORK}"
puts "sealed_root=#{SEALED}"
puts "visible_items=#{visible_nodes.size}"
condition_rows.each do |row|
  puts [
    row["unit_id"],
    row["condition_label"],
    "round0_links=#{row["round0_links"]}",
    "update_a_links=#{row["update_a_links"]}",
    "update_b_links=#{row["update_b_links"]}"
  ].join(" ")
end
puts(control_hits.empty? ? "sealed_control_scan=pass" : "sealed_control_scan=fail")
