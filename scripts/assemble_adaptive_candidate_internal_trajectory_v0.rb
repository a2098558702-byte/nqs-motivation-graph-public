#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

ROOT = File.expand_path("..", __dir__)
FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_adaptive_g6_assay")
RUN_ID = ARGV[0] || abort("Usage: ruby scripts/assemble_adaptive_candidate_internal_trajectory_v0.rb RUN_ID")
UNIT_ID = "unit_906"
RUN_DIR = File.join(FRAMEWORK, "model_runs", RUN_ID)
ROUNDS = File.join(RUN_DIR, "rounds")

abort("Missing run rounds directory: #{ROUNDS}") unless Dir.exist?(ROUNDS)

parts = %w[round0 round1 round2].map do |round|
  path = File.join(ROUNDS, "#{UNIT_ID}_#{round}.md")
  abort("Missing round output: #{path}") unless File.exist?(path)

  "## #{round}\n\n#{File.read(path).strip}\n"
end

target = File.join(ROUNDS, "#{UNIT_ID}_trajectory.md")
File.write(target, "# Adaptive G6 Candidate-To-Internal Trajectory\n\n#{parts.join("\n")}\n")

puts "trajectory=#{target}"
