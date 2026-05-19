#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_aligned_g3_g4_g6_comparison")
RUN_ID = ARGV[0] || abort("Usage: ruby scripts/prepare_aligned_g3_g4_g6_blind_eval_v0.rb RUN_ID")
RUN_DIR = File.join(FRAMEWORK, "model_runs", RUN_ID)
ROUNDS = File.join(RUN_DIR, "rounds")
PACKET = File.join(RUN_DIR, "blind_evaluation_packet")
PRIVATE = File.join(RUN_DIR, "private")

CASE_ORDER = %w[unit_795 unit_156 unit_906].freeze

def write_csv(path, headers, rows)
  CSV.open(path, "w", write_headers: true, headers: headers) do |csv|
    rows.each { |row| csv << headers.map { |header| row[header] } }
  end
end

abort("Missing rounds dir: #{ROUNDS}") unless Dir.exist?(ROUNDS)

FileUtils.rm_rf(PACKET)
FileUtils.mkdir_p(PACKET)
FileUtils.mkdir_p(PRIVATE)

mapping_rows = []
CASE_ORDER.each_with_index do |unit, index|
  source = File.join(ROUNDS, "#{unit}_trajectory.md")
  abort("Missing trajectory: #{source}") unless File.exist?(source)

  anonymous = "case_#{format("%03d", index + 1)}"
  target = File.join(PACKET, "#{anonymous}_trajectory.md")
  text = File.read(source).gsub(/unit_\d+/, anonymous)
  File.write(target, text)
  mapping_rows << {
    "anonymous_case_id" => anonymous,
    "sealed_unit" => unit,
    "source_file" => source.sub(ROOT + "/", ""),
    "packet_file" => target.sub(ROOT + "/", "")
  }
end

write_csv(
  File.join(PRIVATE, "anonymous_case_mapping_private.csv"),
  %w[anonymous_case_id sealed_unit source_file packet_file],
  mapping_rows
)

File.write(File.join(PACKET, "EVALUATION_RUBRIC.md"), <<~MD)
  # Aligned G3/G4/G6 Evaluation Rubric

  Score each trajectory from 1 to 5 on each metric.

  ## Metrics

  - Idea-count alignment: exactly one Round 0 idea, one Round 1 revision, and one Round 2 final trajectory; no menu of independent alternatives.
  - Goal preservation: the same research trajectory survives across rounds unless explicitly and evidence-groundedly rejected.
  - Branch drift control: updates narrow, ground, or scope-extend the branch rather than jumping to unrelated topics.
  - Link-id validity and endpoint fidelity: cited links appear valid from the trajectory's own tables and are not obviously invented.
  - Path continuity: support is path-like rather than a disconnected list of appealing links.
  - Mechanism grounding: the trajectory learns concrete method/failure-mode mechanisms rather than staying at topic level.
  - Feedback absorption: later observations update the idea selectively without wholesale reset.
  - Conclusion dependence: the final direction is materially constrained by the staged evidence paths.
  - Testability: the final proposal has concrete benchmarks, metrics, and failure modes.

  ## Required Output

  For each anonymized case:

  - `anonymous_case_id`
  - metric scores from 1 to 5
  - short rationale
  - idea-count alignment concerns, if any
  - branch drift concerns, if any
  - whether the final direction depends on the evidence path
  - uncertainty notes

  Then provide a cross-case comparison. Do not guess hidden condition names or mappings.
MD

audit_summary = File.join(RUN_DIR, "audits", "aligned_link_audit_summary.csv")
if File.exist?(audit_summary)
  unit_to_case = mapping_rows.each_with_object({}) { |row, index| index[row["sealed_unit"]] = row["anonymous_case_id"] }
  audit_rows = CSV.read(audit_summary, headers: true).map(&:to_h).map do |row|
    {
      "anonymous_case_id" => unit_to_case[row["unit_id"]],
      "round" => row["round"],
      "parsed_link_steps" => row["parsed_link_steps"],
      "valid_link_steps" => row["valid_link_steps"],
      "invalid_link_steps" => row["invalid_link_steps"],
      "missing_link_ids" => row["missing_link_ids"],
      "endpoint_mismatches" => row["endpoint_mismatches"],
      "path_continuity_breaks" => row["path_continuity_breaks"]
    }
  end
  write_csv(
    File.join(PACKET, "aligned_link_audit_summary_anonymous.csv"),
    %w[anonymous_case_id round parsed_link_steps valid_link_steps invalid_link_steps missing_link_ids endpoint_mismatches path_continuity_breaks],
    audit_rows
  )
end

File.write(File.join(PACKET, "EVALUATOR_BRIEF.md"), <<~MD)
  # Blind Evaluation Brief

  You are the blind evaluator for an aligned three-case comparison.

  ## Required Model

  - Model: `gpt-5.5`
  - Reasoning effort: `xhigh`

  ## Allowed Files

  Read only files inside this blind evaluation packet:

  - `EVALUATOR_BRIEF.md`
  - `EVALUATION_RUBRIC.md`
  - `case_*_trajectory.md`
  - `aligned_link_audit_summary_anonymous.csv`, if present

  ## Prohibited

  - Do not search, browse, list parent/sibling directories, or inspect scripts/logs/metadata.
  - Do not open condition keys, sealed-unit directories, framework internals, or private mapping files.
  - Do not guess hidden condition names or hidden mappings.

  ## Task

  Evaluate the anonymized trajectories using `EVALUATION_RUBRIC.md`.

  Pay special attention to idea-count alignment: each trajectory should have one initial idea, one revision, and one final trajectory. Penalize cases that introduce multiple independent ideas per round or restart instead of revising. Treat the anonymous link audit as a mechanical constraint, not as a replacement for qualitative judgment.
MD

puts "blind_packet=#{PACKET}"
puts "anonymous_cases=#{mapping_rows.size}"
