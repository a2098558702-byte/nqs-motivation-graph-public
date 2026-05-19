#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
GRAPH = File.join(ROOT, "current_coverage_graph_v0")
OUT = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_test_framework")
INPUTS = File.join(OUT, "inputs")
ANALYSIS = File.join(OUT, "analysis")
BLIND = File.join(ROOT, "trajectory_experiments", "sealed_trial_v0")
BLIND_CASES = {
  "unit_104" => "G1",
  "unit_287" => "G2",
  "unit_563" => "G3",
  "unit_829" => "G4",
  "unit_641" => "G5"
}.freeze
CUTOFF = 2023
GENERATOR_MODEL = "gpt-5.2"
GENERATOR_REASONING_EFFORT = "low"
EVALUATOR_MODEL = "gpt-5.5"
EVALUATOR_REASONING_EFFORT = "xhigh"

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

BLIND_ITEM_HEADERS = %w[
  item_id item_kind label paper_id year section evidence paraphrase
].freeze

BLIND_LINK_HEADERS = %w[
  link_id from_item_id to_item_id link_text paper_id year evidence_location evidence
].freeze

CONDITIONS = {
  "G1" => {
    name: "nodes_only",
    role: "Node-local semantic synthesis baseline.",
    edge_file: File.join(GRAPH, "graph_variants", "empty_edges_for_nodes_only.csv")
  },
  "G2" => {
    name: "strict_paper_internal",
    role: "Paper-local argument structure and within-paper evidence constraints.",
    edge_file: File.join(GRAPH, "graph_variants", "paper_internal_edges_only.csv")
  },
  "G3" => {
    name: "clean_candidate_context",
    role: "Unreviewed but endpoint-clean cross-paper development context only.",
    edge_file: File.join(GRAPH, "graph_variants", "candidate_context_edges_clean.csv")
  },
  "G4" => {
    name: "strict_plus_clean_candidate_context",
    role: "Paper-local strict evidence plus endpoint-clean candidate development context.",
    edge_file: File.join(GRAPH, "graph_variants", "paper_internal_plus_clean_candidate_context_edges.csv")
  },
  "G5" => {
    name: "paper_citation_only",
    role: "Paper-to-paper reference-list citation graph only.",
    edge_file: File.join(GRAPH, "graph_variants", "paper_citation_edges_only.csv")
  }
}.freeze

PROBES = [
  {
    id: "P1",
    name: "frustrated_sign_architecture",
    question: "What near-term NQS direction follows from frustrated spin sign-structure pressure and architecture choices?",
    terms: ["frustrated", "sign", "phase", "j1", "j2", "heisenberg", "symmetry", "cnn", "rnn", "transformer", "lattice"]
  },
  {
    id: "P2",
    name: "optimization_scaling_sr_sampling",
    question: "What bottleneck is central for scalable NQS optimization and sampling?",
    terms: ["optimization", "sampling", "stochastic reconfiguration", "sr", "qfm", "local energy", "scaling", "parallel", "minsr", "linear"]
  },
  {
    id: "P3",
    name: "fermionic_chemistry_antisymmetry",
    question: "What development path is visible for fermionic chemistry NQS under antisymmetry, determinant, and sampling pressure?",
    terms: ["fermionic", "chemistry", "antisymmetry", "determinant", "jastrow", "backflow", "molecule", "local energy", "sampling", "fugaku"]
  },
  {
    id: "P4",
    name: "dynamics_open_system_stability",
    question: "What do current nodes imply about NQS real-time and open-system dynamics stability?",
    terms: ["dynamics", "tdvp", "time", "open", "liouvillian", "non-markovian", "lindblad", "stiffness", "integrator", "dissipative"]
  },
  {
    id: "P5",
    name: "tomography_physicality_scaling",
    question: "What is the current tomography frontier around physicality, measurement data, and phase-diagram scaling?",
    terms: ["tomography", "qst", "reconstruction", "povm", "spam", "shadow", "mixed", "density", "physical", "hyperrbm", "phase"]
  }
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

def short(text, max = 170)
  raw = text.to_s.gsub(/\s+/, " ").strip
  return raw if raw.length <= max

  raw[0, max - 3] + "..."
end

def safe_name(value)
  value.to_s.gsub(/[^A-Za-z0-9_.-]+/, "_")
end

def score_node(row, terms)
  label = row["canonical_label"].to_s.downcase
  para = row["paraphrase"].to_s.downcase
  quote = row["evidence_quote"].to_s.downcase
  section = row["source_section"].to_s.downcase
  type = row["node_type"].to_s.downcase

  score = 0.0
  terms.each do |term|
    t = term.downcase
    score += 3.0 if label.include?(t)
    score += 2.0 if para.include?(t)
    score += 1.0 if quote.include?(t)
    score += 0.5 if section.include?(t)
    score += 0.5 if type.include?(t)
  end
  score
end

def relation_bonus(edge)
  rel = edge["relation_type"].to_s
  return 1.0 if rel.include?("method_targets_problem")
  return 0.9 if rel.include?("result_supports") || rel.include?("method_supports")
  return 0.8 if rel.start_with?("candidate__")
  return 0.7 if rel.include?("limitation") || rel.include?("future")
  return 0.5 if rel.start_with?("paper_")

  0.6
end

def compact_paper_cards(rows)
  rows.group_by { |row| row["source_paper_id"] }.sort_by { |paper_id, _rows| paper_id }.map do |paper_id, paper_rows|
    title = paper_rows.find { |r| r["node_type"] == "paper" }
    title_text = title ? title["canonical_label"] : paper_rows.first["canonical_label"]
    year = paper_rows.first["visible_year"]
    body = paper_rows.sort_by { |r| [r["node_type"], r["node_id"]] }.map do |r|
      "- `#{r["node_id"]}` (#{r["node_type"]}): #{r["canonical_label"]}. Evidence: \"#{short(r["evidence_quote"], 130)}\""
    end.join("\n")
    "### #{paper_id} (#{year}) #{title_text}\n\n#{body}"
  end.join("\n\n")
end

def top_join(values, max_items = 6)
  counts = Hash.new(0)
  values.compact.each { |v| counts[v] += 1 unless v.to_s.empty? }
  counts.sort_by { |value, count| [-count, value] }.first(max_items).map { |value, count| "#{value}:#{count}" }.join("; ")
end

def blind_item(row)
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

def neutral_link_text(index)
  "relation_#{format("%04d", index)}"
end

graph_builder = File.join(ROOT, "scripts", "build_current_coverage_graph_v0.rb")
unless system("ruby", graph_builder)
  abort("Failed to rebuild current coverage graph with #{graph_builder}")
end

abort("Missing graph directory: #{GRAPH}") unless Dir.exist?(GRAPH)
abort("Refusing to clear unexpected output path: #{OUT}") unless OUT.start_with?(File.join(ROOT, "trajectory_experiments"))
abort("Refusing to clear unexpected blind path: #{BLIND}") unless BLIND.start_with?(File.join(ROOT, "trajectory_experiments"))

FileUtils.rm_rf(OUT)
FileUtils.rm_rf(BLIND)
FileUtils.mkdir_p(INPUTS)
FileUtils.mkdir_p(ANALYSIS)
FileUtils.mkdir_p(BLIND)

nodes = read_csv(File.join(GRAPH, "current_evidence_nodes.csv"))
node_by_id = {}
nodes.each { |row| node_by_id[row["node_id"]] = row }
node_wave = read_csv(File.join(GRAPH, "node_wave_index.csv")).each_with_object({}) { |row, h| h[row["node_id"]] = row }
paper_index = read_csv(File.join(GRAPH, "paper_index.csv")).each_with_object({}) { |row, h| h[row["source_paper_id"]] = row }
summary_lines = File.exist?(File.join(GRAPH, "SUMMARY.txt")) ? File.read(File.join(GRAPH, "SUMMARY.txt")).strip : ""

visible_nodes = nodes.select { |row| row["visible_year"].to_i <= CUTOFF }
hidden_round1 = nodes.select { |row| row["visible_year"].to_i == 2024 }
hidden_round2 = nodes.select { |row| row["visible_year"].to_i >= 2025 }
visible_node_ids = {}
visible_nodes.each { |row| visible_node_ids[row["node_id"]] = true }

write_csv(File.join(INPUTS, "visible_nodes_cutoff_#{CUTOFF}.csv"), NODE_HEADERS, visible_nodes)
write_csv(File.join(INPUTS, "feedback_round1_2024_nodes.csv"), NODE_HEADERS, hidden_round1)
write_csv(File.join(INPUTS, "feedback_round2_2025_2026_nodes.csv"), NODE_HEADERS, hidden_round2)
File.write(File.join(INPUTS, "feedback_round1_2024_nodes.md"), "# Feedback Round 1: 2024 Paper Nodes\n\n#{compact_paper_cards(hidden_round1)}\n")
File.write(File.join(INPUTS, "feedback_round2_2025_2026_nodes.md"), "# Feedback Round 2: 2025-2026 Paper Nodes\n\n#{compact_paper_cards(hidden_round2)}\n")

condition_rows = []
CONDITIONS.each do |label, info|
  all_edges = read_csv(info[:edge_file])
  visible_edges = all_edges.select do |row|
    row["visible_year"].to_i <= CUTOFF &&
      visible_node_ids[row["source_node_id"]] &&
      visible_node_ids[row["target_node_id"]]
  end

  write_csv(File.join(INPUTS, "#{label}_visible_nodes.csv"), NODE_HEADERS, visible_nodes)
  write_csv(File.join(INPUTS, "#{label}_visible_edges.csv"), EDGE_HEADERS, visible_edges)

  condition_rows << {
    "condition_label" => label,
    "condition_name" => info[:name],
    "role" => info[:role],
    "edge_file" => info[:edge_file].sub(ROOT + "/", ""),
    "visible_nodes" => visible_nodes.size,
    "visible_edges" => visible_edges.size,
    "cutoff" => CUTOFF
  }

  File.write(File.join(INPUTS, "#{label}_generator_prompt.md"), <<~MD)
    # Generator Prompt: #{label}

    This is a controlled NQS motivation-graph test over current coverage V0.

    Do not inspect `condition_key_private.csv` while generating. Use only:

    - `inputs/#{label}_visible_nodes.csv`
    - `inputs/#{label}_visible_edges.csv`
    - then `inputs/feedback_round1_2024_nodes.md`
    - then `inputs/feedback_round2_2025_2026_nodes.md`

    Cutoff before feedback: #{CUTOFF}.

    ## Round 0

    Propose one focused next-step NQS research idea.

    Required fields:

    - `idea_title`
    - `assumed_bottleneck`
    - `research_idea`
    - `why_this_follows_from_visible_graph`
    - `evidence_path_or_support`
    - `minimal_test`
    - `risk_or_limitation`

    ## Round 1

    After reading `feedback_round1_2024_nodes.md`, revise the idea. Update rather than restart.

    Required fields:

    - `what_feedback_changed`
    - `what_feedback_did_not_change`
    - `revised_idea`
    - `updated_evidence_path_or_support`
    - `next_test`

    ## Round 2

    After reading `feedback_round2_2025_2026_nodes.md`, revise again and state the final trajectory.

    Required fields:

    - `final_research_direction`
    - `trajectory_summary`
    - `which_bottleneck_survived`
    - `which_branch_was_strengthened`
    - `what_would_be_measured_first`
    - `failure_mode_to_watch`

    ## Constraints

    - Treat edges as constraints when present.
    - Treat candidate-context edges as unreviewed context, never strict proof.
    - If edges are absent, say that the support is node-local.
    - Do not use post-cutoff facts until the corresponding feedback round.
  MD
end

write_csv(File.join(OUT, "condition_matrix.csv"), %w[condition_label condition_name role edge_file visible_nodes visible_edges cutoff], condition_rows)
write_csv(File.join(OUT, "condition_key_private.csv"), %w[condition_label condition_name edge_file], condition_rows.map { |r| r.select { |k, _v| %w[condition_label condition_name edge_file].include?(k) } })
write_csv(
  File.join(OUT, "blind_condition_key_private.csv"),
  %w[blind_case condition_label condition_name],
  BLIND_CASES.map do |blind_case, label|
    row = condition_rows.find { |r| r["condition_label"] == label }
    { "blind_case" => blind_case, "condition_label" => label, "condition_name" => row["condition_name"] }
  end
)
write_csv(
  File.join(OUT, "model_role_manifest.csv"),
  %w[role model reasoning_effort allowed_inputs output_location notes],
  [
    {
      "role" => "generator",
      "model" => GENERATOR_MODEL,
      "reasoning_effort" => GENERATOR_REASONING_EFFORT,
      "allowed_inputs" => "one sealed unit directory, round-gated",
      "output_location" => "durable model-run rounds directory",
      "notes" => "Generator must not search, browse, list directories, inspect keys, or infer hidden labels."
    },
    {
      "role" => "blind_evaluator",
      "model" => EVALUATOR_MODEL,
      "reasoning_effort" => EVALUATOR_REASONING_EFFORT,
      "allowed_inputs" => "anonymous blind evaluation packet and rubric only",
      "output_location" => "durable model-run evaluations directory",
      "notes" => "Evaluator must not open condition keys. The controller/main agent must not score trajectories."
    }
  ]
)

blind_items = visible_nodes.map { |row| blind_item(row) }
blind_round1_items = hidden_round1.map { |row| blind_item(row) }
blind_round2_items = hidden_round2.map { |row| blind_item(row) }

BLIND_CASES.each do |blind_case, label|
  case_dir = File.join(BLIND, blind_case)
  FileUtils.mkdir_p(case_dir)

  visible_edges = read_csv(File.join(INPUTS, "#{label}_visible_edges.csv"))
  blind_links = visible_edges.each_with_index.map do |row, index|
    {
      "link_id" => "L#{format("%04d", index + 1)}",
      "from_item_id" => row["source_node_id"],
      "to_item_id" => row["target_node_id"],
      "link_text" => neutral_link_text(index + 1),
      "paper_id" => row["evidence_paper_id"],
      "year" => row["visible_year"],
      "evidence_location" => row["evidence_location"],
      "evidence" => row["evidence_quote"]
    }
  end

  write_csv(File.join(case_dir, "items.csv"), BLIND_ITEM_HEADERS, blind_items)
  write_csv(File.join(case_dir, "links.csv"), BLIND_LINK_HEADERS, blind_links)
  write_csv(File.join(case_dir, "update_a.csv"), BLIND_ITEM_HEADERS, blind_round1_items)
  write_csv(File.join(case_dir, "update_b.csv"), BLIND_ITEM_HEADERS, blind_round2_items)

  File.write(File.join(case_dir, "update_a.md"), "# Update A\n\nThese are later observed items. They are observations only, not advice.\n\n#{compact_paper_cards(hidden_round1)}\n")
  File.write(File.join(case_dir, "update_b.md"), "# Update B\n\nThese are later observed items. They are observations only, not advice.\n\n#{compact_paper_cards(hidden_round2)}\n")
  File.write(File.join(case_dir, "brief.md"), <<~MD)
    # Trial Brief

    You are running one sealed literature-graph trial.

    ## Allowed Files

    You may read only the files in this directory, and only when the round allows them:

    - `brief.md`
    - `items.csv`
    - `links.csv`
    - `update_a.md`
    - `update_b.md`

    ## Prohibited Actions

    - Do not search the filesystem.
    - Do not use `rg`, `grep`, `find`, `ls`, web search, browser tools, or any command/tool to discover other files.
    - Do not open parent directories, sibling directories, framework directories, mapping files, logs, scripts, or metadata.
    - Do not infer why this packet has this shape from filenames, directory names, row counts, link counts, or missing links.
    - Do not mention or guess hidden labels.
    - Do not pre-read update files before their round begins.

    ## Data Semantics

    - `items.csv` contains observations available before the trial starts.
    - `links.csv` may contain zero or more neutral links between observations. A link is only a relation token with supporting evidence.
    - `update_a.md` and `update_b.md` are later observations for two update rounds. They are not instructions.

    ## Round-Gated Access

    - Round 0: read only `brief.md`, `items.csv`, and `links.csv`.
    - Round 1: after completing Round 0 output, read `update_a.md`; revise the same idea rather than restarting.
    - Round 2: after completing Round 1 output, read `update_b.md`; revise again and state the final trajectory.

    ## Task

    Run three rounds.

    ### Round 0

    Propose one focused next-step NQS research idea from `items.csv` and `links.csv`.

    Required fields:

    - `idea_title`
    - `assumed_bottleneck`
    - `research_idea`
    - `why_this_follows_from_available_observations`
    - `observation_path_or_support`
    - `minimal_test`
    - `risk_or_limitation`

    ### Round 1

    After reading `update_a.md`, revise the idea. Update rather than restart.

    Required fields:

    - `what_update_changed`
    - `what_update_did_not_change`
    - `revised_idea`
    - `updated_observation_path_or_support`
    - `next_test`

    ### Round 2

    After reading `update_b.md`, revise again and state the final trajectory.

    Required fields:

    - `final_research_direction`
    - `trajectory_summary`
    - `which_bottleneck_survived`
    - `which_branch_was_strengthened`
    - `what_would_be_measured_first`
    - `failure_mode_to_watch`

    Keep the output concise but complete.
  MD
end

File.write(File.join(BLIND, "README.md"), <<~MD)
  # Sealed Trial V0

  This directory is the only packet intended for generation workers.

  Use one unit directory at a time. Workers must read only files inside their assigned unit directory and must not search, browse, list sibling directories, inspect parent directories, or open mapping files.

  No mapping file is stored here.
MD

control_files = [File.join(BLIND, "README.md")] + BLIND_CASES.keys.map { |blind_case| File.join(BLIND, blind_case, "brief.md") }
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
control_hits = []
control_files.each do |path|
  text = File.read(path)
  control_terms.each do |term|
    next unless text.downcase.include?(term.downcase)

    control_hits << {
      "file" => path.sub(ROOT + "/", ""),
      "term" => term
    }
  end
end

File.write(File.join(OUT, "SEALED_PACKET_AUDIT.md"), <<~MD)
  # Sealed Packet Audit

  Generated by `scripts/build_current_coverage_test_framework_v0.rb`.

  ## Control-Layer Scan

  The scan checks generator-facing control files only:

  - `trajectory_experiments/sealed_trial_v0/README.md`
  - `trajectory_experiments/sealed_trial_v0/unit_*/brief.md`

  It intentionally does not scan `items.csv`, `links.csv`, or update data for ordinary scientific words such as "boundary conditions" or "conditional GAN", because those are evidence content rather than framework metadata.

  ## Sensitive Terms Checked

  #{control_terms.map { |term| "- `#{term}`" }.join("\n")}

  ## Result

  #{control_hits.empty? ? "No sensitive control-layer terms found." : control_hits.map { |hit| "- #{hit["file"]}: `#{hit["term"]}`" }.join("\n")}

  ## Sealed Generation Rule

  A valid generation worker receives exactly one `unit_*` directory and may read only:

  - `brief.md`
  - `items.csv`
  - `links.csv`
  - `update_a.md`
  - `update_b.md`

  Search, browsing, directory listing, parent/sibling inspection, and key/framework/script/log access are prohibited.
MD

probe_result_rows = []
probe_summary_rows = []
probe_edge_rows = []

CONDITIONS.each do |label, info|
  edges = read_csv(info[:edge_file])
  adjacency = Hash.new { |h, k| h[k] = [] }
  edges.each do |edge|
    next unless node_by_id[edge["source_node_id"]] && node_by_id[edge["target_node_id"]]

    adjacency[edge["source_node_id"]] << [edge, edge["target_node_id"], 1.0]
    adjacency[edge["target_node_id"]] << [edge, edge["source_node_id"], 0.55]
  end

  PROBES.each do |probe|
    base_scores = {}
    nodes.each do |node|
      score = score_node(node, probe[:terms])
      base_scores[node["node_id"]] = score
    end

    seed_ids = base_scores.select { |_id, score| score.positive? }
                          .sort_by { |id, score| [-score, id] }
                          .first(14)
                          .map { |id, _score| id }

    expanded_scores = base_scores.dup
    support_edges = Hash.new { |h, k| h[k] = [] }
    seed_ids.each do |seed_id|
      seed_score = base_scores[seed_id].to_f
      adjacency[seed_id].each do |edge, other_id, direction_weight|
        bonus = seed_score * 0.22 * direction_weight + relation_bonus(edge)
        expanded_scores[other_id] = expanded_scores[other_id].to_f + bonus
        support_edges[other_id] << edge
        probe_edge_rows << {
          "condition_label" => label,
          "condition_name" => info[:name],
          "probe_id" => probe[:id],
          "probe_name" => probe[:name],
          "seed_node_id" => seed_id,
          "expanded_node_id" => other_id,
          "edge_id" => edge["edge_id"],
          "relation_type" => edge["relation_type"],
          "evidence_paper_id" => edge["evidence_paper_id"],
          "edge_bonus" => format("%.3f", bonus)
        }
      end
    end

    ranked = nodes.map do |node|
      {
        "node" => node,
        "base_score" => base_scores[node["node_id"]].to_f,
        "expanded_score" => expanded_scores[node["node_id"]].to_f,
        "support_edges" => support_edges[node["node_id"]]
      }
    end.select { |item| item["expanded_score"].positive? }
      .sort_by { |item| [-item["expanded_score"], item["node"]["node_id"]] }
      .first(12)

    ranked.each_with_index do |item, index|
      node = item["node"]
      wave_row = node_wave[node["node_id"]] || {}
      paper_row = paper_index[node["source_paper_id"]] || {}
      support = item["support_edges"]
      probe_result_rows << {
        "condition_label" => label,
        "condition_name" => info[:name],
        "probe_id" => probe[:id],
        "probe_name" => probe[:name],
        "rank" => index + 1,
        "node_id" => node["node_id"],
        "source_paper_id" => node["source_paper_id"],
        "paper_title" => paper_row["title"],
        "branch_label" => wave_row["branch_label"],
        "node_type" => node["node_type"],
        "canonical_label" => node["canonical_label"],
        "base_score" => format("%.3f", item["base_score"]),
        "expanded_score" => format("%.3f", item["expanded_score"]),
        "support_edge_ids" => support.map { |edge| edge["edge_id"] }.uniq.join(";"),
        "support_relation_types" => support.map { |edge| edge["relation_type"] }.uniq.join(";")
      }
    end

    probe_summary_rows << {
      "condition_label" => label,
      "condition_name" => info[:name],
      "probe_id" => probe[:id],
      "probe_name" => probe[:name],
      "question" => probe[:question],
      "top_papers" => top_join(ranked.map { |item| item["node"]["source_paper_id"] }),
      "top_branches" => top_join(ranked.map { |item| (node_wave[item["node"]["node_id"]] || {})["branch_label"] }),
      "top_node_types" => top_join(ranked.map { |item| item["node"]["node_type"] }),
      "edge_supported_top_nodes" => ranked.count { |item| !item["support_edges"].empty? },
      "top_node_ids" => ranked.map { |item| item["node"]["node_id"] }.join(";")
    }
  end
end

write_csv(
  File.join(ANALYSIS, "retrieval_probe_results.csv"),
  %w[condition_label condition_name probe_id probe_name rank node_id source_paper_id paper_title branch_label node_type canonical_label base_score expanded_score support_edge_ids support_relation_types],
  probe_result_rows
)
write_csv(
  File.join(ANALYSIS, "retrieval_probe_condition_summary.csv"),
  %w[condition_label condition_name probe_id probe_name question top_papers top_branches top_node_types edge_supported_top_nodes top_node_ids],
  probe_summary_rows
)
write_csv(
  File.join(ANALYSIS, "probe_edge_hits.csv"),
  %w[condition_label condition_name probe_id probe_name seed_node_id expanded_node_id edge_id relation_type evidence_paper_id edge_bonus],
  probe_edge_rows
)

probe_sections = PROBES.map do |probe|
  rows = probe_summary_rows.select { |r| r["probe_id"] == probe[:id] }
  body = rows.map do |row|
    "- `#{row["condition_label"]}` #{row["condition_name"]}: branches [#{row["top_branches"]}], node_types [#{row["top_node_types"]}], edge_supported_top_nodes=#{row["edge_supported_top_nodes"]}, top_nodes=#{row["top_node_ids"]}"
  end.join("\n")
  "## #{probe[:id]} #{probe[:name]}\n\nQuestion: #{probe[:question]}\n\n#{body}"
end.join("\n\n")

File.write(File.join(ANALYSIS, "deterministic_probe_report.md"), <<~MD)
  # Deterministic Retrieval Probe Report

  This report is generated by `scripts/build_current_coverage_test_framework_v0.rb`.

  The probe is not a replacement for model-based generation. It is a deterministic sanity check that edge conditions change retrievable context in the expected direction before any expensive trajectory test is run.

  #{probe_sections}

  ## Reading Rule

  - `G1` should expose node-local semantic matches only.
  - `G2` should enrich context through paper-local argument edges.
  - `G3` should expose only unreviewed but clean cross-paper candidate context.
  - `G4` should combine paper-local argument structure with clean candidate context.
  - `G5` should expose paper-to-paper reference-list connectivity only.
MD

File.write(File.join(OUT, "TEST_FRAMEWORK_LOGIC.md"), <<~MD)
  # Current Coverage V0 Test Framework Logic

  ## Purpose

  This framework freezes the current graph-test logic for the 60-paper NQS evidence graph. It is designed to test how graph structure changes research-trajectory behavior while keeping the evidence-node set fixed.

  ## Input Graph

  The framework always rebuilds `current_coverage_graph_v0` before generating test files.

  Current graph summary:

  ```text
  #{summary_lines}
  ```

  The strict graph remains evidence-only. Candidate-context variants are experimental inputs only and do not upgrade candidates into strict edges.

  ## Fixed Units

  - Node: author-stated evidence node from full text.
  - Strict edge: paper-local/internal evidence edge with no inference and no human-check flag.
  - Paper citation edge: paper-node to paper-node edge generated from local reference files when a corpus paper references another corpus paper by arXiv ID or exact title.
  - Candidate edge: unreviewed development relation that must keep `needs_human_check=true`.
  - Clean candidate-context edge: candidate edge with resolved endpoints and `candidate_status=...`; used only as an experimental context layer.

  ## Conditions

  - `G1 nodes_only`: same visible nodes, no edges.
  - `G2 strict_paper_internal`: same visible nodes, paper-local strict edges only.
  - `G3 clean_candidate_context`: same visible nodes, clean candidate-context edges only.
  - `G4 strict_plus_clean_candidate_context`: same visible nodes, strict paper-local edges plus clean candidate-context edges.
  - `G5 paper_citation_only`: same visible nodes, paper-to-paper reference-list citation edges only.

  ## Cutoff And Feedback

  - Round 0 cutoff: #{CUTOFF}.
  - Feedback round 1 reveals 2024 paper nodes only.
  - Feedback round 2 reveals 2025-2026 paper nodes only.
  - Feedback packets contain nodes, not prescriptions.
  - Round access is gated: generators may not read update files before completing the prior round output.

  ## Test Modes

  1. Deterministic retrieval probes:
     - Cheap sanity checks.
     - Compare top-k retrieved context across conditions for fixed research questions.
     - Output lives in `analysis/retrieval_probe_*.csv` and `analysis/deterministic_probe_report.md`.
     - These probes are intentionally conservative: they only test whether edge conditions perturb retrievable context, not whether a language model will use those edges creatively.
     - A clean candidate-only condition can look weak in deterministic probes if its endpoints are not lexical matches for the probe terms; that is a probe limitation, not evidence that candidate context is useless.

  2. Model trajectory generation:
     - Use only `trajectory_experiments/sealed_trial_v0/unit_*/brief.md`.
     - Give each generator exactly one assigned `unit_*` directory.
     - Generators must not search, browse, list sibling directories, inspect parent directories, or open key/framework files.
     - Generators must not pre-read `update_a.md` or `update_b.md`; each update is unlocked only after the previous round output is complete.
     - The older `inputs/G*_generator_prompt.md` files are retained only for internal framework debugging and must not be used for valid sealed trials.
     - The output should be saved under `rounds/` if run later.

  3. Hidden-key evaluation:
     - Evaluate completed trajectories with `EVALUATION_RUBRIC.md` before opening the private key.
     - The target observable is trajectory role, not only final idea quality.

  ## Invariants

  - Same visible node set per condition.
  - Same cutoff per condition.
  - Same feedback packets per condition.
  - Same generator task per condition.
  - Only edge condition changes.
  - Current citation coverage must be complete for all source papers before sealed model-generation trials are run. If `paper_citation_sources_with_reference_files < papers`, run `scripts/backfill_missing_reference_lists_from_arxiv.rb` and rebuild.
  - Candidate context is always labelled as unreviewed context.
  - Paper citation edges are descriptive reference-list links only; they do not assert semantic development by themselves.
  - Sealed generation prompts must not contain condition-role words such as `strict`, `candidate`, `paper_internal`, `nodes_only`, `citation`, or `edge_schema`.
  - Sealed generation prompts must include an explicit no-search / whitelist-only rule.

  ## What This Framework Can Test

  - Whether strict paper-local edges produce paper-argument reasoning.
  - Whether candidate-context edges produce branch-trajectory reasoning.
  - Whether paper-to-paper citation edges alone create useful literature-lineage trajectories.
  - Whether combined edges produce a more integrated research-program trajectory.
  - Whether feedback is absorbed selectively or causes branch drift.

  ## What This Framework Cannot Claim Alone

  - It does not prove any candidate edge is strict.
  - It does not rank the whole NQS literature.
  - It does not measure scientific novelty without independent generator/evaluator runs.
  - It does not replace human review of candidate development edges.
MD

File.write(File.join(OUT, "EXPERIMENT_PROTOCOL.md"), <<~MD)
  # Current Coverage V0 Experiment Protocol

  ## Build Command

  ```bash
  ruby scripts/backfill_missing_reference_lists_from_arxiv.rb
  ruby scripts/build_current_coverage_test_framework_v0.rb
  ```

  The backfill command is needed whenever newly added papers lack local reference-list coverage. The framework command rebuilds `current_coverage_graph_v0`, writes the test framework directory, and runs deterministic retrieval probes.

  ## Directory Contract

  - `TEST_FRAMEWORK_LOGIC.md`: stable logic and invariants.
  - `condition_matrix.csv`: public condition sizes and roles.
  - `condition_key_private.csv`: private condition names for blind evaluation.
  - `blind_condition_key_private.csv`: maps sealed case directories to private condition names.
  - `inputs/`: visible node/edge CSVs, generator prompts, and feedback packets.
  - `analysis/`: deterministic probe outputs and reports.
  - `rounds/`: intended location for model-generated trajectories.
  - `evaluations/`: intended location for hidden-key evaluation outputs.
  - `../sealed_trial_v0/`: neutral generation packet; use this for valid model-generation trials.

  ## Round Protocol

  1. Assign each generator exactly one neutral sealed directory under `trajectory_experiments/sealed_trial_v0/unit_*`.
  2. Give the generator only that unit's `brief.md`; the brief itself lists the allowed files.
  3. Enforce no-search / whitelist-only access. The generator must not list parent directories or inspect scripts/logs/keys.
  4. Enforce round-gated access: Round 0 uses only `items.csv` and `links.csv`; Round 1 unlocks `update_a.md`; Round 2 unlocks `update_b.md`.
  5. Save outputs as `rounds/unit_104_trajectory.md`, etc.
  6. Run a hidden-key evaluator using `EVALUATION_RUBRIC.md`.
  7. Only after evaluation, inspect `blind_condition_key_private.csv`.

  ## Model Role Contract

  - Generator model: `#{GENERATOR_MODEL}` with reasoning effort `#{GENERATOR_REASONING_EFFORT}`.
  - Blind evaluator model: `#{EVALUATOR_MODEL}` with reasoning effort `#{EVALUATOR_REASONING_EFFORT}`.
  - The controller/main agent must not score, classify, or rank generated trajectories.
  - The evaluator receives only anonymized trajectory files and the rubric, never `condition_key_private.csv`, `blind_condition_key_private.csv`, condition names, or sealed unit mappings.
  - Save model outputs and evaluator outputs in a timestamped run directory so model identity and reasoning effort remain auditable.

  ## Candidate Context Rule

  Candidate-context edges are allowed only as labelled experimental context. They must not be quoted as strict graph facts.

  In sealed packets, candidate/strict labels are removed from generator-facing link names. The controller may recover the condition only after the blind evaluation.

  ## Paper Citation Rule

  Paper citation edges are generated separately from reference-list files. They connect paper nodes only and mean "the source paper references the target paper"; they do not by themselves claim method inheritance, problem response, or conceptual development.

  After any paper expansion wave, rerun `scripts/backfill_missing_reference_lists_from_arxiv.rb` and then `scripts/build_current_coverage_test_framework_v0.rb` so the citation-only condition and sealed packet stay in sync with evidence coverage.
MD

File.write(File.join(OUT, "EVALUATION_RUBRIC.md"), <<~MD)
  # Current Coverage V0 Evaluation Rubric

  Score each trajectory from 1 to 5 on each metric.

  ## Metrics

  - Goal preservation: stable bottleneck across rounds.
  - Feedback absorption selectivity: feedback changes the idea without wholesale reset.
  - Evidence-path faithfulness: support follows visible nodes and allowed edges.
  - Edge-condition sensitivity: trajectory role reflects the edge condition.
  - Branch-local update: revisions move through nearby graph structure.
  - Mechanism specificity: idea names a concrete physical, optimization, architectural, or measurement mechanism.
  - Testability: final direction includes a realistic benchmark, diagnostic, or falsification path.
  - Drift control: avoids keyword-following and keeps a coherent research line.

  ## Qualitative Labels

  Use one or more:

  - node-local synthesis
  - paper-internal argument logic
  - candidate-lineage trajectory
  - method-lineage / scaling
  - physical diagnostic / tension
  - benchmark adjudication
  - integrated research program
  - keyword drift / loose brainstorm

  ## Blindness Rule

  Evaluate all sealed-unit trajectories before opening `condition_key_private.csv`.

  ## Required Evaluator

  This blind evaluation must be performed by `#{EVALUATOR_MODEL}` with reasoning effort `#{EVALUATOR_REASONING_EFFORT}`.

  The controller/main agent must not substitute its own judgment for this blind evaluation.

  ## Required Output Schema

  For each anonymized trajectory:

  - `anonymous_case_id`
  - metric scores from 1 to 5
  - qualitative labels
  - short evidence-grounded rationale
  - suspected trajectory role, without guessing hidden condition names
  - uncertainty notes

  Also provide a cross-case comparison that does not reveal or guess hidden condition mappings.
MD

File.write(File.join(OUT, "MODEL_RUN_PROTOCOL.md"), <<~MD)
  # Model Run Protocol

  ## Roles

  - Generator: `#{GENERATOR_MODEL}`, reasoning effort `#{GENERATOR_REASONING_EFFORT}`.
  - Blind evaluator: `#{EVALUATOR_MODEL}`, reasoning effort `#{EVALUATOR_REASONING_EFFORT}`.

  The controller/main agent only prepares packets, launches or records model runs, checks files, and preserves blindness. It must not evaluate the trajectories.

  ## Generator Procedure

  1. Assign each generator exactly one sealed unit directory.
  2. Use `#{GENERATOR_MODEL}` with reasoning effort `#{GENERATOR_REASONING_EFFORT}`.
  3. Enforce round-gated access:
     - Round 0: `brief.md`, `items.csv`, `links.csv`.
     - Round 1: unlock `update_a.md` only after Round 0 output is complete.
     - Round 2: unlock `update_b.md` only after Round 1 output is complete.
  4. Save each trajectory with the sealed unit id in the run's `rounds/` directory.

  ## Blind Evaluation Procedure

  1. Build an anonymized evaluation packet from completed trajectory files.
  2. Remove sealed unit ids, condition labels, condition names, edge-condition names, and key filenames from evaluator-facing materials.
  3. Use `#{EVALUATOR_MODEL}` with reasoning effort `#{EVALUATOR_REASONING_EFFORT}`.
  4. Give the evaluator only:
     - anonymized trajectories;
     - `EVALUATION_RUBRIC.md`;
     - the instruction that hidden mappings must not be guessed.
  5. Save evaluator output in the run's `evaluations/` directory.
  6. Open private condition keys only after evaluator output is complete and immutable.

  ## Prohibited

  - Do not evaluate trajectories in the controller/main agent.
  - Do not expose `condition_key_private.csv` or `blind_condition_key_private.csv` to the evaluator.
  - Do not let generator or evaluator search, browse, list parent/sibling directories, or inspect scripts/logs/metadata.
MD

File.write(File.join(OUT, "RUNBOOK.md"), <<~MD)
  # Runbook

  ## Rebuild Everything

  ```bash
  ruby scripts/backfill_missing_reference_lists_from_arxiv.rb
  ruby scripts/build_current_coverage_graph_v0.rb
  ruby scripts/build_current_coverage_test_framework_v0.rb
  ```

  The test-framework command already calls the graph builder, but both are listed for clarity. Run the citation backfill first after any paper expansion or when citation source coverage is incomplete.

  ## Inspect Deterministic Probe Results

  ```bash
  sed -n '1,220p' trajectory_experiments/current_coverage_v0_test_framework/analysis/deterministic_probe_report.md
  ```

  ## Run Model Trajectories Later

  Use sealed units, not the debug `inputs/G*` prompts:

  - `../sealed_trial_v0/unit_104/brief.md`
  - `../sealed_trial_v0/unit_287/brief.md`
  - `../sealed_trial_v0/unit_563/brief.md`
  - `../sealed_trial_v0/unit_829/brief.md`
  - `../sealed_trial_v0/unit_641/brief.md`

  Worker rule:

  - generator model is `#{GENERATOR_MODEL}` with reasoning effort `#{GENERATOR_REASONING_EFFORT}`;
  - read only the assigned unit directory;
  - do not search;
  - do not list sibling or parent directories;
  - do not inspect key, framework, script, or log files.
  - do not pre-read update files before their round begins.

  Save outputs under:

  - `rounds/unit_104_trajectory.md`
  - `rounds/unit_287_trajectory.md`
  - `rounds/unit_563_trajectory.md`
  - `rounds/unit_829_trajectory.md`
  - `rounds/unit_641_trajectory.md`

  ## Run Blind Evaluation Later

  Use `#{EVALUATOR_MODEL}` with reasoning effort `#{EVALUATOR_REASONING_EFFORT}`.

  The evaluator receives only anonymized trajectories plus `EVALUATION_RUBRIC.md`. The controller/main agent must not score the trajectories.
MD

FileUtils.mkdir_p(File.join(OUT, "rounds"))
FileUtils.mkdir_p(File.join(OUT, "evaluations"))

File.write(File.join(OUT, "README.md"), <<~MD)
  # Current Coverage V0 Test Framework

  This directory freezes the graph-testing logic for the current 60-paper NQS evidence graph.

  Current public condition sizes:

  #{condition_rows.map { |r| "- `#{r["condition_label"]}`: #{r["visible_nodes"]} visible nodes, #{r["visible_edges"]} visible edges, cutoff #{r["cutoff"]}" }.join("\n")}

  Start with:

  - `TEST_FRAMEWORK_LOGIC.md`
  - `EXPERIMENT_PROTOCOL.md`
  - `analysis/deterministic_probe_report.md`

  For valid model generation, use the neutral sealed packet at `../sealed_trial_v0/`, not the debug `inputs/G*` prompts.
MD

manifest_rows = Dir.glob(File.join(OUT, "**", "*")).select { |path| File.file?(path) }.sort.map do |path|
  rel = path.sub(OUT + "/", "")
  {
    "path" => rel,
    "bytes" => File.size(path),
    "role" => if rel.start_with?("inputs/")
                "test_input"
              elsif rel.start_with?("analysis/")
                "deterministic_analysis"
              elsif rel.include?("RUBRIC") || rel.include?("PROTOCOL") || rel.include?("LOGIC")
                "framework_doc"
              else
                "framework_support"
              end
  }
end
write_csv(File.join(OUT, "framework_manifest.csv"), %w[path bytes role], manifest_rows)

blind_manifest_rows = Dir.glob(File.join(BLIND, "**", "*")).select { |path| File.file?(path) }.sort.map do |path|
  {
    "path" => path.sub(BLIND + "/", ""),
    "bytes" => File.size(path),
    "role" => File.basename(path) == "brief.md" ? "sealed_brief" : "sealed_input"
  }
end
write_csv(File.join(OUT, "sealed_packet_manifest.csv"), %w[path bytes role], blind_manifest_rows)

puts "framework=#{OUT}"
puts "sealed_packet=#{BLIND}"
puts "visible_nodes=#{visible_nodes.size}"
CONDITIONS.each do |label, info|
  row = condition_rows.find { |r| r["condition_label"] == label }
  puts "#{label}=#{info[:name]} visible_edges=#{row["visible_edges"]}"
end
puts "probe_results=#{probe_result_rows.size}"
puts "probe_edge_hits=#{probe_edge_rows.size}"
