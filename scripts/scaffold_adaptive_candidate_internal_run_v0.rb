#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "time"

ROOT = File.expand_path("..", __dir__)
FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_adaptive_g6_assay")
RUN_ID = ARGV[0] || Time.now.strftime("%Y%m%d_%H%M%S")
RUN_DIR = File.join(FRAMEWORK, "model_runs", RUN_ID)
UNIT_ID = "unit_906"

abort("Missing framework. Run: ruby scripts/build_adaptive_candidate_internal_assay_v0.rb") unless Dir.exist?(FRAMEWORK)
abort("Run already exists: #{RUN_DIR}") if Dir.exist?(RUN_DIR)

FileUtils.mkdir_p(File.join(RUN_DIR, "rounds"))
FileUtils.mkdir_p(File.join(RUN_DIR, "packets"))
FileUtils.mkdir_p(File.join(RUN_DIR, "audits"))
FileUtils.mkdir_p(File.join(RUN_DIR, "evaluations"))
FileUtils.mkdir_p(File.join(RUN_DIR, "private"))

File.write(File.join(RUN_DIR, "RUN_MANIFEST.md"), <<~MD)
  # Adaptive G6 Run #{RUN_ID}

  ## Generator Settings

  - Model: `gpt-5.2`
  - Reasoning effort: `low`
  - Search, browsing, directory listing, parent/sibling inspection, metadata inspection, and hidden-label guessing are prohibited.

  ## Round 0

  Read only:

  ```text
  #{File.join(ROOT, "trajectory_experiments", "sealed_trial_v2", UNIT_ID, "round0")}
  ```

  Save:

  ```text
  #{File.join(RUN_DIR, "rounds", "#{UNIT_ID}_round0.md")}
  ```

  ## Round 1 / Round 2

  Prepare each subsequent packet mechanically:

  ```bash
  ruby scripts/prepare_adaptive_candidate_internal_round_v0.rb #{RUN_ID} round1
  ruby scripts/prepare_adaptive_candidate_internal_round_v0.rb #{RUN_ID} round2
  ```
MD

puts "run_dir=#{RUN_DIR}"
puts "round0_output=#{File.join(RUN_DIR, "rounds", "#{UNIT_ID}_round0.md")}"
