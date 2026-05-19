#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_edge_dependency_assay")
RUN_ID = ARGV[0] || abort("Usage: ruby scripts/prepare_edge_dependency_blind_evaluation_packet_v0.rb RUN_ID")
RUN_DIR = File.join(FRAMEWORK, "model_runs", RUN_ID)
ROUNDS = File.join(RUN_DIR, "rounds")
AUDITS = File.join(RUN_DIR, "audits")
PACKET = File.join(RUN_DIR, "blind_evaluation_packet")
PRIVATE = File.join(RUN_DIR, "private")

GENERATOR_MODEL = "gpt-5.2"
GENERATOR_REASONING_EFFORT = "low"
EVALUATOR_MODEL = "gpt-5.5"
EVALUATOR_REASONING_EFFORT = "xhigh"

def write_csv(path, headers, rows)
  CSV.open(path, "w", write_headers: true, headers: headers) do |csv|
    rows.each { |row| csv << headers.map { |header| row[header] } }
  end
end

def read_csv(path)
  return [] unless File.exist?(path)

  CSV.read(path, headers: true).map(&:to_h)
end

abort("Missing run rounds directory: #{ROUNDS}") unless Dir.exist?(ROUNDS)

FileUtils.rm_rf(PACKET)
FileUtils.mkdir_p(PACKET)
FileUtils.mkdir_p(PRIVATE)

trajectory_files = Dir.children(ROUNDS).grep(/\Aunit_\d+_trajectory\.md\z/).sort
abort("No trajectory files found under #{ROUNDS}") if trajectory_files.empty?

mapping_rows = []
trajectory_files.each_with_index do |file, index|
  anonymous_id = "case_#{format("%03d", index + 1)}"
  source = File.join(ROUNDS, file)
  target = File.join(PACKET, "#{anonymous_id}_trajectory.md")
  text = File.read(source).gsub(/unit_\d+/, anonymous_id)
  File.write(target, text)
  mapping_rows << {
    "anonymous_case_id" => anonymous_id,
    "sealed_unit" => file.sub(/_trajectory\.md\z/, ""),
    "source_file" => source.sub(ROOT + "/", ""),
    "packet_file" => target.sub(ROOT + "/", "")
  }
end

rubric = File.join(FRAMEWORK, "EVALUATION_RUBRIC.md")
FileUtils.cp(rubric, File.join(PACKET, "EVALUATION_RUBRIC.md")) if File.exist?(rubric)

audit_summary = File.join(AUDITS, "mechanical_link_audit_summary.csv")
if File.exist?(audit_summary)
  audit_rows = read_csv(audit_summary)
  unit_to_case = mapping_rows.each_with_object({}) { |row, index| index[row["sealed_unit"]] = row["anonymous_case_id"] }
  anonymized = audit_rows.map do |row|
    {
      "anonymous_case_id" => unit_to_case[row["unit_id"]],
      "parsed_link_steps" => row["parsed_link_steps"],
      "valid_link_steps" => row["valid_link_steps"],
      "invalid_link_steps" => row["invalid_link_steps"],
      "missing_link_ids" => row["missing_link_ids"],
      "endpoint_mismatches" => row["endpoint_mismatches"],
      "bad_traversal_values" => row["bad_traversal_values"],
      "path_continuity_breaks" => row["path_continuity_breaks"],
      "future_round_link_violations" => row["future_round_link_violations"],
      "insufficient_link_support_mentions" => row["insufficient_link_support_mentions"],
      "node_local_fallback_mentions" => row["node_local_fallback_mentions"]
    }
  end
  write_csv(
    File.join(PACKET, "mechanical_link_audit_summary_anonymous.csv"),
    %w[
      anonymous_case_id parsed_link_steps valid_link_steps invalid_link_steps
      missing_link_ids endpoint_mismatches bad_traversal_values path_continuity_breaks
      future_round_link_violations insufficient_link_support_mentions node_local_fallback_mentions
    ],
    anonymized
  )
end

write_csv(
  File.join(PRIVATE, "anonymous_case_mapping_private.csv"),
  %w[anonymous_case_id sealed_unit source_file packet_file],
  mapping_rows
)

File.write(File.join(PRIVATE, "model_role_private_note.md"), <<~MD)
  # Private Model Role Note

  Generator model: `#{GENERATOR_MODEL}`, reasoning effort `#{GENERATOR_REASONING_EFFORT}`.

  Blind evaluator model: `#{EVALUATOR_MODEL}`, reasoning effort `#{EVALUATOR_REASONING_EFFORT}`.

  Do not expose this private directory to the evaluator.
MD

File.write(File.join(PACKET, "EVALUATOR_BRIEF.md"), <<~MD)
  # Blind Evaluation Brief

  You are the blind evaluator for anonymized edge-dependency assay trajectories.

  ## Required Model

  - Model: `#{EVALUATOR_MODEL}`
  - Reasoning effort: `#{EVALUATOR_REASONING_EFFORT}`

  ## Allowed Files

  Read only files inside this blind evaluation packet:

  - `EVALUATOR_BRIEF.md`
  - `EVALUATION_RUBRIC.md`
  - `case_*_trajectory.md`
  - `mechanical_link_audit_summary_anonymous.csv`, if present

  ## Prohibited

  - Do not search, browse, list parent/sibling directories, or inspect scripts/logs/metadata.
  - Do not open sealed-unit directories, framework internals, private mapping files, or condition keys.
  - Do not guess hidden condition names or hidden mappings.

  ## Task

  Evaluate each anonymized trajectory using `EVALUATION_RUBRIC.md`.

  Treat the mechanical audit as a constraint on link mechanics, not as a replacement for qualitative judgment. Include a cross-case comparison, but keep cases anonymous.
MD

puts "blind_packet=#{PACKET}"
puts "anonymous_cases=#{mapping_rows.size}"
puts "evaluator_model=#{EVALUATOR_MODEL}"
puts "evaluator_reasoning_effort=#{EVALUATOR_REASONING_EFFORT}"
