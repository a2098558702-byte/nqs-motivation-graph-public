#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"
require "time"

ROOT = File.expand_path("..", __dir__)
FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_edge_dependency_assay")
SEALED = File.join(ROOT, "trajectory_experiments", "sealed_trial_v1")
RUN_ID = ARGV[0] || Time.now.strftime("%Y%m%d_%H%M%S")
RUN_DIR = File.join(FRAMEWORK, "model_runs", RUN_ID)
ROUNDS = File.join(RUN_DIR, "rounds")
PRIVATE = File.join(RUN_DIR, "private")
UNIT_KEY = File.join(FRAMEWORK, "private", "unit_condition_key_private.csv")

abort("Missing framework. Run: ruby scripts/build_edge_dependency_assay_v0.rb") unless Dir.exist?(FRAMEWORK)
abort("Missing sealed packets. Run: ruby scripts/build_edge_dependency_assay_v0.rb") unless Dir.exist?(SEALED)
abort("Run already exists: #{RUN_DIR}") if Dir.exist?(RUN_DIR)

FileUtils.mkdir_p(ROUNDS)
FileUtils.mkdir_p(PRIVATE)
FileUtils.mkdir_p(File.join(RUN_DIR, "audits"))
FileUtils.mkdir_p(File.join(RUN_DIR, "evaluations"))

if File.exist?(UNIT_KEY)
  FileUtils.cp(UNIT_KEY, File.join(PRIVATE, "unit_condition_key_private.csv"))
end

unit_dirs = Dir.children(SEALED).grep(/\Aunit_\d+\z/).sort

File.write(File.join(RUN_DIR, "RUN_MANIFEST.md"), <<~MD)
  # Edge Dependency Assay Run #{RUN_ID}

  ## Generator Settings

  - Model: `gpt-5.2`
  - Reasoning effort: `low`
  - One generator per sealed unit.
  - Search, browsing, directory listing, parent/sibling inspection, metadata inspection, and hidden-label guessing are prohibited.
  - Follow the round gate inside each unit's `brief.md`.

  ## Sealed Units

  #{unit_dirs.map { |unit| "- `#{unit}` -> save output as `rounds/#{unit}_trajectory.md`" }.join("\n")}

  ## After Generation

  Run:

  ```bash
  ruby scripts/check_edge_dependency_assay_outputs_v0.rb #{RUN_ID}
  ruby scripts/prepare_edge_dependency_blind_evaluation_packet_v0.rb #{RUN_ID}
  ```

  The first command is a mechanical audit only. The second command prepares an anonymized packet for the required blind evaluator.
MD

unit_dirs.each do |unit|
  File.write(File.join(RUN_DIR, "#{unit}_generator_instructions.md"), <<~MD)
    # Generator Instructions For #{unit}

    Use model `gpt-5.2` with reasoning effort `low`.

    Read only this sealed directory:

    ```text
    #{File.join(SEALED, unit)}
    ```

    Follow the round-gated access rules in `brief.md`.

    Save the final three-round output here:

    ```text
    #{File.join(ROUNDS, "#{unit}_trajectory.md")}
    ```

    Do not search, browse, list directories, inspect parent or sibling directories, inspect framework files, inspect logs, or infer hidden labels from packet shape.
MD
end

puts "run_dir=#{RUN_DIR}"
puts "rounds_dir=#{ROUNDS}"
puts "unit_count=#{unit_dirs.size}"
