#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_test_framework")
RUN_ID = ARGV[0] || abort("Usage: ruby scripts/prepare_blind_evaluation_packet_v0.rb RUN_ID")
RUN_DIR = File.join(FRAMEWORK, "model_runs", RUN_ID)
ROUNDS = File.join(RUN_DIR, "rounds")
EVAL = File.join(RUN_DIR, "blind_evaluation_packet")
PRIVATE = File.join(RUN_DIR, "private")

GENERATOR_MODEL = "gpt-5.2"
GENERATOR_REASONING_EFFORT = "low"
EVALUATOR_MODEL = "gpt-5.5"
EVALUATOR_REASONING_EFFORT = "xhigh"

CASE_ORDER = %w[unit_104 unit_287 unit_563 unit_829 unit_641].freeze

def write_csv(path, headers, rows)
  CSV.open(path, "w", write_headers: true, headers: headers) do |csv|
    rows.each { |row| csv << headers.map { |h| row[h] } }
  end
end

abort("Missing run rounds directory: #{ROUNDS}") unless Dir.exist?(ROUNDS)

FileUtils.rm_rf(EVAL)
FileUtils.mkdir_p(EVAL)
FileUtils.mkdir_p(PRIVATE)

mapping_rows = []
CASE_ORDER.each_with_index do |unit, index|
  source = File.join(ROUNDS, "#{unit}_trajectory.md")
  next unless File.exist?(source)

  anonymous_id = "case_#{format("%03d", index + 1)}"
  target = File.join(EVAL, "#{anonymous_id}_trajectory.md")
  text = File.read(source)
  text = text.gsub(/unit_\d+/, anonymous_id)
  File.write(target, text)
  mapping_rows << {
    "anonymous_case_id" => anonymous_id,
    "sealed_unit" => unit,
    "source_file" => source.sub(ROOT + "/", ""),
    "packet_file" => target.sub(ROOT + "/", "")
  }
end

abort("No trajectory files found under #{ROUNDS}") if mapping_rows.empty?

FileUtils.cp(File.join(FRAMEWORK, "EVALUATION_RUBRIC.md"), File.join(EVAL, "EVALUATION_RUBRIC.md"))

File.write(File.join(EVAL, "EVALUATOR_BRIEF.md"), <<~MD)
  # Blind Evaluation Brief

  You are the blind evaluator for anonymized three-round research trajectories.

  ## Required Model

  - Model: `#{EVALUATOR_MODEL}`
  - Reasoning effort: `#{EVALUATOR_REASONING_EFFORT}`

  ## Allowed Files

  Read only files inside this blind evaluation packet:

  - `EVALUATOR_BRIEF.md`
  - `EVALUATION_RUBRIC.md`
  - `case_*_trajectory.md`

  ## Prohibited

  - Do not search, browse, list parent/sibling directories, or inspect scripts/logs/metadata.
  - Do not open condition keys, sealed-unit directories, framework internals, or private mapping files.
  - Do not guess hidden condition names or hidden mappings.

  ## Task

  Evaluate each anonymized trajectory using `EVALUATION_RUBRIC.md`.

  Use the rubric's required output schema. Include a cross-case comparison, but keep cases anonymous.
MD

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

puts "run_dir=#{RUN_DIR}"
puts "blind_packet=#{EVAL}"
puts "anonymous_cases=#{mapping_rows.size}"
puts "evaluator_model=#{EVALUATOR_MODEL}"
puts "evaluator_reasoning_effort=#{EVALUATOR_REASONING_EFFORT}"
