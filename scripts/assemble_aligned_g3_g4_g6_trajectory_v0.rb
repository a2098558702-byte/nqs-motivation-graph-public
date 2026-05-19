#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("..", __dir__)
FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_aligned_g3_g4_g6_comparison")
RUN_ID = ARGV[0] || abort("Usage: ruby scripts/assemble_aligned_g3_g4_g6_trajectory_v0.rb RUN_ID")
RUN_DIR = File.join(FRAMEWORK, "model_runs", RUN_ID)
ROUNDS = File.join(RUN_DIR, "rounds")
UNITS = %w[unit_795 unit_156].freeze

abort("Missing rounds dir: #{ROUNDS}") unless Dir.exist?(ROUNDS)

UNITS.each do |unit|
  parts = %w[round0 round1 round2].map do |round|
    path = File.join(ROUNDS, "#{unit}_#{round}.md")
    abort("Missing #{path}") unless File.exist?(path)

    "## #{round}\n\n#{File.read(path).strip}\n"
  end
  target = File.join(ROUNDS, "#{unit}_trajectory.md")
  File.write(target, "# Aligned Three-Round Trajectory\n\n#{parts.join("\n")}\n")
  puts "trajectory=#{target}"
end
