#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"

root = File.expand_path("..", __dir__)

wave_name = ARGV[0] || "frustrated_spin_pilot_wave_v0"

configs = {
  "frustrated_spin_pilot_wave_v0" => {
    workpack: "frustrated_spin_j1j2.csv",
    selected_ids: %w[
      NQSC004
      NQSC021
      NQSC043
      NQSC047
      NQSC078
      NQSC122
    ],
    title: "Frustrated Spin Pilot Wave V0",
    scope: "first small verified extraction wave for the frustrated_spin_j1j2 workpack"
  },
  "optimization_pilot_wave_v0" => {
    workpack: "optimization_sr_minsr_linear_scalable.csv",
    selected_ids: %w[
      NQSC016
      NQSC028
      NQSC053
      NQSC085
      NQSC109
      NQSC150
    ],
    title: "Optimization Pilot Wave V0",
    scope: "small verified extraction wave for optimization / scalable-training pressure"
  },
  "architecture_pilot_wave_v0" => {
    workpack: "architecture_cnn_gcnn_rnn_transformer_foundation.csv",
    selected_ids: %w[
      NQSC001
      NQSC034
      NQSC060
      NQSC084
      NQSC090
      NQSC153
    ],
    title: "Architecture Pilot Wave V0",
    scope: "small verified extraction wave for architecture lineage, inductive bias, and transformer/self-attention pressure"
  },
  "high_priority_mixed_coverage_wave_v0" => {
    manifest: "manifests/branch_assignment_v0.csv",
    selected_ids: %w[
      NQSC026
      NQSC002
      NQSC003
      NQSC030
      NQSC083
      NQSC007
      NQSC010
      NQSC011
      NQSC037
      NQSC059
      NQSC117
      NQSC129
    ],
    title: "High Priority Mixed Coverage Wave V0",
    scope: "first broad 100plus expansion wave after the pilot waves, covering early architecture, fermionic chemistry, dynamics, tomography, optimization, frustrated spin, and symmetry"
  }
}.freeze

config = configs[wave_name] || abort("Unknown wave name: #{wave_name}")

workpack_path = File.join(root, config[:manifest] || File.join("workpacks", config[:workpack]))
wave_dir = File.join(root, "extraction_waves", wave_name)
manifest_path = File.join(wave_dir, "manifest.csv")
selected_ids = config[:selected_ids]

FileUtils.mkdir_p(wave_dir)

rows = CSV.read(workpack_path, headers: true)
selected = selected_ids.map do |id|
  rows.find { |row| row["universe_id"] == id } || abort("Missing #{id}")
end

CSV.open(manifest_path, "w") do |csv|
  csv << rows.headers
  selected.each { |row| csv << row }
end

templates = {
  "source_status.csv" => [
    %w[universe_id title url source_found source_type local_source_path source_notes extraction_status]
  ],
  "section_map.csv" => [
    %w[universe_id section_name source_location section_role notes]
  ],
  "fulltext_evidence_nodes.csv" => [
    %w[node_id graph_layer node_type canonical_label source_paper_id source_year visible_year source_section evidence_location evidence_quote paraphrase confidence is_inferred needs_human_check notes]
  ],
  "fulltext_evidence_edges.csv" => [
    %w[edge_id graph_layer source_node_id target_node_id relation_type evidence_paper_id evidence_year visible_year evidence_source_type evidence_location evidence_quote confidence is_inferred needs_human_check notes]
  ],
  "development_edge_candidates.csv" => [
    %w[edge_id graph_layer source_node_id target_node_id relation_type evidence_paper_id evidence_year visible_year evidence_source_type evidence_location evidence_quote confidence is_inferred needs_human_check notes explicitness review_reason]
  ]
}

templates.each do |filename, rows_to_write|
  CSV.open(File.join(wave_dir, filename), "w") do |csv|
    rows_to_write.each { |row| csv << row }
  end
end

File.write(File.join(wave_dir, "protocol_notes.md"), <<~MD)
  # #{config[:title]} Protocol Notes

  This is the #{config[:scope]}.

  ## Scope

  Selected from `#{config[:manifest] || "workpacks/#{config[:workpack]}"}`:

  #{selected_ids.map { |id| "- #{id}" }.join("\n")}

  ## Extraction Rule

  Paper-local first:

  - extract author-stated evidence nodes;
  - extract paper-internal evidence edges;
  - record cross-paper hints only as candidates unless direct full-text evidence exists;
  - do not infer development edges from same benchmark, same ansatz, or same branch.
  - current phase is coverage expansion, so strong-looking but unreviewed cross-paper relations should normally stay in `development_edge_candidates.csv` with `candidate_status=strict_possible_unreviewed`, not be upgraded by the worker.

  ## Notes To Fill During Extraction

  - Hard-to-classify node types:
  - Recurring branch pressure:
  - Candidate relation types needing protocol update:
  - Papers needing human review:
MD

File.write(File.join(wave_dir, "extraction_log.md"), <<~MD)
  # #{config[:title]} Extraction Log

  ## Setup

  Created from `scripts/build_pilot_wave.rb`.

  ## Log Entries

MD

File.write(File.join(wave_dir, "README.md"), <<~MD)
  # #{config[:title]}

  This wave tests the full expansion protocol on #{config[:scope]}.

  ## Input

  - `manifest.csv`

  ## Outputs

  - `source_status.csv`
  - `section_map.csv`
  - `fulltext_evidence_nodes.csv`
  - `fulltext_evidence_edges.csv`
  - `development_edge_candidates.csv`
  - `protocol_notes.md`
  - `extraction_log.md`

  ## Protocols

  Read:

  - `Outputs/NQS Motivation Graph Gold Standard Calibration Pack V0.md`
  - `prompts/paper_local_extraction_worker_prompt_v0.md`
MD

puts "Wrote #{wave_dir}"
