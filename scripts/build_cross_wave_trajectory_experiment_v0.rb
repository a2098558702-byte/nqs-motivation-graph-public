#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
GRAPH = File.join(ROOT, "cross_wave_branch_graph_v0")
OUT = File.join(ROOT, "trajectory_experiments", "cross_wave_v0_edge_schema_test_v0")
INPUTS = File.join(OUT, "inputs")

CUTOFF = 2022

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

CONDITIONS = {
  "G1" => {
    name: "nodes_only",
    edge_file: File.join(GRAPH, "graph_variants", "empty_edges_for_nodes_only.csv")
  },
  "G2" => {
    name: "paper_internal_only",
    edge_file: File.join(GRAPH, "graph_variants", "paper_internal_edges_only.csv")
  },
  "G3" => {
    name: "strict_development_only",
    edge_file: File.join(GRAPH, "graph_variants", "strict_development_edges_only.csv")
  },
  "G4" => {
    name: "all_strict_evidence",
    edge_file: File.join(GRAPH, "graph_variants", "all_strict_evidence_edges.csv")
  }
}.freeze

def read_csv(path)
  CSV.read(path, headers: true)
end

def write_csv(path, headers, rows)
  CSV.open(path, "w", write_headers: true, headers: headers) do |csv|
    rows.each { |row| csv << headers.map { |h| row[h] } }
  end
end

def short(text, max = 190)
  raw = text.to_s.gsub(/\s+/, " ").strip
  return raw if raw.length <= max

  raw[0, max - 3] + "..."
end

FileUtils.rm_rf(OUT)
FileUtils.mkdir_p(INPUTS)
FileUtils.mkdir_p(File.join(OUT, "rounds"))
FileUtils.mkdir_p(File.join(OUT, "analysis"))

nodes_all = read_csv(File.join(GRAPH, "cross_wave_evidence_nodes.csv")).map(&:to_h)
edges_all = read_csv(File.join(GRAPH, "cross_wave_evidence_edges.csv")).map(&:to_h)

visible_nodes = nodes_all.select { |row| row["visible_year"].to_i <= CUTOFF }
hidden_nodes = nodes_all.select { |row| row["visible_year"].to_i > CUTOFF }
visible_node_ids = visible_nodes.to_h { |row| [row["node_id"], true] }

write_csv(File.join(INPUTS, "visible_nodes_cutoff_#{CUTOFF}.csv"), NODE_HEADERS, visible_nodes)
write_csv(File.join(INPUTS, "hidden_future_nodes_after_#{CUTOFF}.csv"), NODE_HEADERS, hidden_nodes)

node_by_id = nodes_all.to_h { |row| [row["node_id"], row] }

paper_cards = visible_nodes.group_by { |row| row["source_paper_id"] }.map do |paper_id, rows|
  rows = rows.sort_by { |row| [row["node_type"], row["node_id"]] }
  year = rows.first["source_year"]
  title = rows.find { |row| row["node_type"] == "paper" }&.fetch("canonical_label", nil) || rows.first["canonical_label"]
  body = rows.map do |row|
    "- `#{row["node_id"]}` (#{row["node_type"]}): #{row["canonical_label"]}. Evidence: \"#{short(row["evidence_quote"], 140)}\""
  end.join("\n")
  "### #{paper_id} (#{year}) #{title}\n\n#{body}"
end.join("\n\n")

future_cards_by_round = {
  1 => %w[NQSC109 NQSC122],
  2 => %w[NQSC150 NQSC153]
}

future_cards_by_round.each do |round, paper_ids|
  cards = paper_ids.map do |paper_id|
    rows = hidden_nodes.select { |row| row["source_paper_id"] == paper_id }
    year = rows.first&.fetch("source_year", nil)
    title = rows.find { |row| row["node_type"] == "paper" }&.fetch("canonical_label", nil) || rows.first&.fetch("canonical_label", nil)
    nodes = rows.sort_by { |row| [row["node_type"], row["node_id"]] }.map do |row|
      "- `#{row["node_id"]}` (#{row["node_type"]}): #{row["canonical_label"]}. Observed evidence: \"#{short(row["evidence_quote"], 150)}\""
    end.join("\n")
    "### #{paper_id} (#{year}) #{title}\n\n#{nodes}"
  end.join("\n\n")

  File.write(File.join(INPUTS, "feedback_round#{round}_paper_nodes.md"), <<~MD)
    # Feedback Round #{round}: Neutral Historical Paper-Node Packet

    Feedback level: F1 historical paper-node feedback.

    This packet reports post-cutoff historical observations from the local evidence graph. It is not advice and it does not tell the generator what to do next.

    Historical status: adjacent / partial counterpart papers exist in the bounded local NQS graph.

    Scope of check: only the current 18-paper cross-wave V0 graph, cutoff #{CUTOFF}, post-cutoff nodes visible after feedback.

    Neutrality check: this packet gives paper-node observations only. It does not rank the previous idea and does not prescribe the next idea.

    Forbidden leakage checked: no command such as "you should use X next" is included.

    #{cards}
  MD
end

protocol = <<~MD
  # Cross-Wave V0 Edge-Schema Trajectory Experiment

  Created: 2026-05-19

  ## Purpose

  Test the refined claim:

  > Same evidence nodes mainly control one-shot scientific content, while edge schemas shape multi-round research trajectory updates.

  This experiment uses the cleaned 18-paper cross-wave V0 graph. It keeps the visible nodes, cutoff, task, and feedback packets fixed. The only controlled variable is the edge condition.

  ## Cutoff

  - Cutoff year: #{CUTOFF}.
  - Visible before generation: papers and nodes with `visible_year <= #{CUTOFF}`.
  - Hidden feedback pool: post-cutoff paper nodes from 2023-2024 inside the same cross-wave graph.

  ## Conditions

  The public condition labels are anonymized:

  - `G1`
  - `G2`
  - `G3`
  - `G4`

  The private condition key is in `condition_key_private.csv`.

  ## Round Structure

  - Round 0: generate a focused next-step NQS research idea from visible graph information.
  - Feedback 1: add neutral post-cutoff paper-node observations from 2023.
  - Round 1: revise the idea and explain the update logic.
  - Feedback 2: add neutral post-cutoff paper-node observations from 2024.
  - Round 2: revise again and state the final research trajectory.

  ## Fixed Generator Task

  The generator must:

  - identify the current bottleneck implied by the visible graph;
  - propose one focused next-step research idea;
  - explain the evidence support using visible nodes and, if available, edges;
  - after feedback, update rather than restart;
  - keep the idea testable and scientifically meaningful.

  ## What Not To Claim

  This is not yet a proof that one graph is globally better. The target observable is trajectory shape:

  - Does the condition preserve the same bottleneck?
  - Does it update locally or jump branches?
  - Does it become method-lineage, paper-logic, physical-diagnostic, benchmark, or integrated?
  - Does it use feedback as evidence rather than instruction?
MD

File.write(File.join(OUT, "EXPERIMENT_PROTOCOL.md"), protocol)

evaluation = <<~MD
  # Evaluation Rubric

  Scores use 1-5. Evaluate trajectory behavior, not only final idea prettiness.

  ## Metrics

  1. Goal preservation: whether the trajectory keeps a stable scientific target across rounds.
  2. Feedback absorption selectivity: whether feedback is incorporated as bounded evidence rather than swallowed wholesale.
  3. Evidence-path faithfulness: whether the claimed support comes from visible nodes/edges rather than decorative citations.
  4. Branch-local update: whether revisions move through nearby graph structure rather than jumping randomly.
  5. Mechanism specificity: whether the idea names a concrete physical / optimization / architectural mechanism.
  6. Testability: whether the final idea gives a realistic experiment, benchmark, diagnostic, or falsification route.
  7. Drift control: whether the trajectory avoids keyword-following and maintains coherence.
  8. Research-role clarity: whether the condition induces a recognizable role, such as method-lineage, paper-internal reasoning, physical diagnostic, benchmark discipline, or integrated program.

  ## Qualitative Labels

  Use one or more:

  - node-local synthesis
  - paper-internal argument logic
  - cross-paper field trajectory
  - method-lineage / scaling
  - physical diagnostic / tension
  - benchmark adjudication
  - integrated research program
  - keyword drift / loose brainstorm

  ## Blindness Rule

  Evaluate `G1`-`G4` before opening `condition_key_private.csv`.
MD

File.write(File.join(OUT, "EVALUATION_RUBRIC.md"), evaluation)

condition_key_rows = CONDITIONS.map do |label, info|
  {
    "condition_label" => label,
    "condition_name" => info[:name],
    "edge_file" => info[:edge_file].sub(ROOT + "/", "")
  }
end
write_csv(File.join(OUT, "condition_key_private.csv"), %w[condition_label condition_name edge_file], condition_key_rows)

CONDITIONS.each do |label, info|
  edge_rows = read_csv(info[:edge_file]).map(&:to_h)
  visible_edges = edge_rows.select do |row|
    row["visible_year"].to_i <= CUTOFF &&
      visible_node_ids[row["source_node_id"]] &&
      visible_node_ids[row["target_node_id"]]
  end

  write_csv(File.join(INPUTS, "#{label}_visible_nodes.csv"), NODE_HEADERS, visible_nodes)
  write_csv(File.join(INPUTS, "#{label}_visible_edges.csv"), EDGE_HEADERS, visible_edges)

  edge_cards = if visible_edges.empty?
                 "No edges are visible in this condition."
               else
                 visible_edges.map do |row|
                   source = node_by_id[row["source_node_id"]]
                   target = node_by_id[row["target_node_id"]]
                   "- `#{row["edge_id"]}`: `#{row["source_node_id"]}` (#{source&.fetch("node_type", "?")}) --#{row["relation_type"]}--> `#{row["target_node_id"]}` (#{target&.fetch("node_type", "?")}). Evidence: \"#{short(row["evidence_quote"], 130)}\""
                 end.join("\n")
               end

  prompt = <<~MD
    # Generator Prompt: #{label}

    You are given an anonymized NQS literature graph condition with cutoff year #{CUTOFF}.

    Do not use papers after #{CUTOFF} unless they are explicitly provided later as feedback. Do not guess the hidden condition name.

    ## Visible Evidence Nodes

    #{paper_cards}

    ## Visible Edges For This Condition

    #{edge_cards}

    ## Task

    Run three rounds:

    ### Round 0
    Propose one focused next-step NQS research idea that a researcher might naturally ask after the visible literature.

    Required fields:

    - `idea_title`
    - `assumed_bottleneck`
    - `research_idea`
    - `why_this_follows_from_visible_graph`
    - `evidence_path_or_support`
    - `minimal_test`
    - `risk_or_limitation`

    ### Round 1
    After receiving `feedback_round1_paper_nodes.md`, revise the idea. Update rather than restart.

    Required fields:

    - `what_feedback_changed`
    - `what_feedback_did_not_change`
    - `revised_idea`
    - `updated_evidence_path_or_support`
    - `next_test`

    ### Round 2
    After receiving `feedback_round2_paper_nodes.md`, revise again and state the final trajectory.

    Required fields:

    - `final_research_direction`
    - `trajectory_summary`
    - `which_bottleneck_survived`
    - `which_branch_was_strengthened`
    - `what_would_be_measured_first`
    - `failure_mode_to_watch`

    ## Constraints

    - Do not optimize for sounding novel. Optimize for a coherent, testable trajectory.
    - If edges exist, use them as relation constraints, not decorative citations.
    - If no edges exist, say the support is node-local.
    - Keep the output concise but complete.
  MD

  File.write(File.join(INPUTS, "#{label}_generator_prompt.md"), prompt)
end

summary_rows = CONDITIONS.map do |label, info|
  edge_count = CSV.read(File.join(INPUTS, "#{label}_visible_edges.csv"), headers: true).size
  {
    "condition_label" => label,
    "visible_nodes" => visible_nodes.size,
    "visible_edges" => edge_count,
    "cutoff" => CUTOFF
  }
end
write_csv(File.join(OUT, "input_summary.csv"), %w[condition_label visible_nodes visible_edges cutoff], summary_rows)

File.write(File.join(OUT, "README.md"), <<~MD)
  # Cross-Wave V0 Edge-Schema Test

  This directory contains the first controlled trajectory experiment built from `cross_wave_branch_graph_v0`.

  Use `EXPERIMENT_PROTOCOL.md` for the fixed setup, `EVALUATION_RUBRIC.md` for scoring, and `inputs/` for anonymized generator prompts and feedback packets.

  Current condition sizes:

  #{summary_rows.map { |row| "- `#{row["condition_label"]}`: #{row["visible_nodes"]} visible nodes, #{row["visible_edges"]} visible edges, cutoff #{row["cutoff"]}" }.join("\n")}
MD

puts summary_rows.map { |row| "#{row["condition_label"]}: nodes=#{row["visible_nodes"]} edges=#{row["visible_edges"]}" }.join(" | ")
