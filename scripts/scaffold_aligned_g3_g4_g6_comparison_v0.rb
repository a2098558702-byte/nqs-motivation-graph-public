#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "time"

ROOT = File.expand_path("..", __dir__)
SOURCE_SEALED = File.join(ROOT, "trajectory_experiments", "sealed_trial_v1")
OUT = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_aligned_g3_g4_g6_comparison")
RUN_ID = ARGV[0] || Time.now.strftime("%Y%m%d_%H%M%S")
G6_RUN_ID = ARGV[1] || "adaptive_g6_20260519_134255"
RUN_DIR = File.join(OUT, "model_runs", RUN_ID)
PACKETS = File.join(RUN_DIR, "packets")
ROUNDS = File.join(RUN_DIR, "rounds")
PRIVATE = File.join(RUN_DIR, "private")

UNITS = {
  "unit_795" => {
    condition: "G3",
    name: "clean_candidate_context",
    source_dir: File.join(SOURCE_SEALED, "unit_795")
  },
  "unit_156" => {
    condition: "G4",
    name: "strict_plus_clean_candidate_context",
    source_dir: File.join(SOURCE_SEALED, "unit_156")
  }
}.freeze

abort("Run already exists: #{RUN_DIR}") if Dir.exist?(RUN_DIR)

UNITS.each_value do |info|
  abort("Missing source sealed dir: #{info[:source_dir]}") unless Dir.exist?(info[:source_dir])
end

g6_trajectory = File.join(
  ROOT,
  "trajectory_experiments",
  "current_coverage_v0_adaptive_g6_assay",
  "model_runs",
  G6_RUN_ID,
  "rounds",
  "unit_906_trajectory.md"
)
abort("Missing G6 trajectory: #{g6_trajectory}") unless File.exist?(g6_trajectory)

FileUtils.mkdir_p(PACKETS)
FileUtils.mkdir_p(ROUNDS)
FileUtils.mkdir_p(PRIVATE)
FileUtils.mkdir_p(File.join(RUN_DIR, "audits"))
FileUtils.mkdir_p(File.join(RUN_DIR, "evaluations"))

UNITS.each do |unit, info|
  %w[round0 round1 round2].each do |round|
    dir = File.join(PACKETS, unit, round)
    FileUtils.mkdir_p(dir)
    case round
    when "round0"
      FileUtils.cp(File.join(info[:source_dir], "items.csv"), File.join(dir, "items.csv"))
      FileUtils.cp(File.join(info[:source_dir], "links.csv"), File.join(dir, "links.csv"))
    when "round1"
      FileUtils.cp(File.join(info[:source_dir], "update_a_items.csv"), File.join(dir, "feedback_items.csv"))
      FileUtils.cp(File.join(info[:source_dir], "update_a_links.csv"), File.join(dir, "feedback_links.csv"))
    when "round2"
      FileUtils.cp(File.join(info[:source_dir], "update_b_items.csv"), File.join(dir, "feedback_items.csv"))
      FileUtils.cp(File.join(info[:source_dir], "update_b_links.csv"), File.join(dir, "feedback_links.csv"))
    end
  end

  File.write(File.join(PACKETS, unit, "round0", "brief.md"), <<~MD)
    # Aligned Comparison Brief: Round 0

    You are running Round 0 of one sealed literature-graph trial.

    ## Allowed Files

    Read only files in this directory:

    - `brief.md`
    - `items.csv`
    - `links.csv`

    ## Prohibited Actions

    - Do not search the filesystem.
    - Do not use `rg`, `grep`, `find`, `ls`, web search, browser tools, or any command/tool to discover other files.
    - Do not open parent directories, sibling directories, framework directories, mapping files, logs, scripts, or metadata.
    - Do not infer hidden labels from filenames, row counts, link counts, or missing files.
    - Do not mention or guess hidden condition names.

    ## Idea-Count Alignment

    Produce exactly one research idea in this round. Do not provide multiple alternative ideas or a menu of unrelated projects.

    ## Task

    Build support paths from the available links and propose one focused research idea.

    Required fields:

    - `round0_link_step_table`
    - `round0_path_claims`
    - `idea_title`
    - `assumed_bottleneck`
    - `research_idea`
    - `why_the_idea_depends_on_the_paths`
    - `minimal_test`
    - `risk_or_limitation`
    - `idea_count_alignment_note`

    Use this exact link-step table header whenever you claim link support:

    | claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |

    If no real support path can be built, say `insufficient_link_support` and do not invent link ids.
  MD

  File.write(File.join(PACKETS, unit, "round1", "brief.md"), <<~MD)
    # Aligned Comparison Brief: Round 1

    You are continuing the same sealed literature-graph trial.

    ## Allowed Files

    Read only files in this directory and the prior Round 0 output explicitly provided by the controller:

    - `brief.md`
    - `feedback_items.csv`
    - `feedback_links.csv`

    ## Prohibited Actions

    - Do not search the filesystem.
    - Do not use `rg`, `grep`, `find`, `ls`, web search, browser tools, or any command/tool to discover other files.
    - Do not open parent directories, sibling directories, framework directories, mapping files, logs, scripts, or metadata.
    - Do not infer hidden labels from filenames, row counts, link counts, or missing files.
    - Do not mention or guess hidden condition names.

    ## Idea-Count Alignment

    Revise the same one idea from Round 0 exactly once. Do not restart with a new unrelated idea. Do not provide multiple alternative ideas.

    ## Task

    Use the feedback observations and feedback links to update the Round 0 idea.

    Required fields:

    - `round1_link_delta_table`
    - `what_update_changed`
    - `what_update_did_not_change`
    - `revised_idea`
    - `updated_path_claims`
    - `next_test`
    - `branch_drift_check`
    - `idea_count_alignment_note`

    Use this exact link-step table header whenever you claim link support:

    | claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |

    Link ids must come from `feedback_links.csv`.
  MD

  File.write(File.join(PACKETS, unit, "round2", "brief.md"), <<~MD)
    # Aligned Comparison Brief: Round 2

    You are continuing the same sealed literature-graph trial.

    ## Allowed Files

    Read only files in this directory and the prior Round 0/Round 1 outputs explicitly provided by the controller:

    - `brief.md`
    - `feedback_items.csv`
    - `feedback_links.csv`

    ## Prohibited Actions

    - Do not search the filesystem.
    - Do not use `rg`, `grep`, `find`, `ls`, web search, browser tools, or any command/tool to discover other files.
    - Do not open parent directories, sibling directories, framework directories, mapping files, logs, scripts, or metadata.
    - Do not infer hidden labels from filenames, row counts, link counts, or missing files.
    - Do not mention or guess hidden condition names.

    ## Idea-Count Alignment

    Finalize the same one trajectory. Do not introduce a new independent idea, and do not provide multiple alternatives.

    ## Task

    Use the feedback observations and feedback links to produce the final trajectory.

    Required fields:

    - `round2_link_delta_table`
    - `final_research_direction`
    - `trajectory_summary`
    - `which_bottleneck_survived`
    - `which_path_was_strengthened_or_rejected`
    - `what_would_be_measured_first`
    - `failure_mode_to_watch`
    - `branch_drift_check`
    - `idea_count_alignment_note`

    Use this exact link-step table header whenever you claim link support:

    | claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |

    Link ids must come from `feedback_links.csv`.
  MD
end

FileUtils.cp(g6_trajectory, File.join(ROUNDS, "unit_906_trajectory.md"))

File.write(File.join(PRIVATE, "condition_key_private.csv"), <<~CSV)
  unit_id,condition_label,condition_name,source
  unit_795,G3,clean_candidate_context,staged rerun from sealed_trial_v1/unit_795
  unit_156,G4,strict_plus_clean_candidate_context,staged rerun from sealed_trial_v1/unit_156
  unit_906,G6,adaptive_candidate_to_internal,#{G6_RUN_ID}
CSV

File.write(File.join(RUN_DIR, "RUN_MANIFEST.md"), <<~MD)
  # Aligned G3/G4/G6 Comparison #{RUN_ID}

  ## Purpose

  Compare G3, G4, and G6 under aligned three-round idea counts.

  ## Idea-Count Rule

  Each condition has exactly:

  - Round 0: one initial idea.
  - Round 1: one revision of the same idea.
  - Round 2: one final trajectory.

  The blind evaluator should penalize trajectories that provide multiple independent ideas inside one round or restart rather than revise.

  ## Generator

  - Model: `gpt-5.2`
  - Reasoning effort: `low`
  - No search, browsing, directory listing, parent/sibling inspection, scripts/logs/metadata/private mappings, or hidden-label guessing.

  ## G6 Source

  G6 trajectory was copied from:

  ```text
  #{g6_trajectory}
  ```
MD

puts "run_dir=#{RUN_DIR}"
puts "g6_source=#{g6_trajectory}"
UNITS.each_key do |unit|
  puts "#{unit}_round0_packet=#{File.join(PACKETS, unit, "round0")}"
end
