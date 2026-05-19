#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "time"

ROOT = File.expand_path("..", __dir__)
FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_test_framework")
SEALED = File.join(ROOT, "trajectory_experiments", "sealed_trial_v0")
RUN_ID = ARGV[0] || Time.now.strftime("%Y%m%d_%H%M%S")
RUN_DIR = File.join(FRAMEWORK, "model_runs", RUN_ID)
ROUNDS = File.join(RUN_DIR, "rounds")
PRIVATE = File.join(RUN_DIR, "private")

abort("Missing framework. Run: ruby scripts/build_current_coverage_test_framework_v0.rb") unless Dir.exist?(FRAMEWORK)
abort("Missing sealed packets. Run: ruby scripts/build_current_coverage_test_framework_v0.rb") unless Dir.exist?(SEALED)
abort("Run already exists: #{RUN_DIR}") if Dir.exist?(RUN_DIR)

FileUtils.mkdir_p(ROUNDS)
FileUtils.mkdir_p(PRIVATE)
FileUtils.mkdir_p(File.join(RUN_DIR, "evaluations"))

key = File.join(FRAMEWORK, "blind_condition_key_private.csv")
FileUtils.cp(key, File.join(PRIVATE, "blind_condition_key_private.csv")) if File.exist?(key)

unit_dirs = Dir.children(SEALED).grep(/\Aunit_\d+\z/).sort

File.write(File.join(RUN_DIR, "RUN_MANIFEST.md"), <<~MD)
  # Current Coverage Trajectory Run #{RUN_ID}

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
  ruby scripts/prepare_blind_evaluation_packet_v0.rb #{RUN_ID}
  ```

  Then send the generated `blind_evaluation_packet/` to the required blind evaluator: `gpt-5.5` with reasoning effort `xhigh`.
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
