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
