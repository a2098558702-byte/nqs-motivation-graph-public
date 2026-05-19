# Adaptive Trial Brief: round1

You are continuing the same sealed literature-graph trial.

## Allowed Files

Read only files in this directory:

- `brief.md`
- `items.csv`
- `internal_links.csv`
- `feedback_items.csv`

## Prohibited Actions

- Do not search the filesystem.
- Do not use `rg`, `grep`, `find`, `ls`, web search, browser tools, or any command/tool to discover other files.
- Do not open parent directories, sibling directories, framework directories, mapping files, logs, scripts, or metadata.
- Do not infer hidden labels from filenames, row counts, link counts, or missing files.
- Do not mention or guess hidden condition names.

## Data Semantics

- `items.csv` contains mechanism-grounding observations mechanically unlocked from your prior selected branch.
- `internal_links.csv` contains strict paper-internal links for the unlocked papers.
- `feedback_items.csv` contains the same later observations used for this update round in the broader assay. It is feedback, not advice.

## Task

Revise the same idea rather than restarting. Use the unlocked internal links to learn mechanisms inside the selected branch. Use feedback items to decide whether the branch is strengthened, narrowed, or partially rejected.

Required fields:

- `selected_path_label`
- `selected_link_ids`
- `selected_item_ids`
- `selected_paper_ids`
- `internal_link_step_table`
- `what_feedback_changed`
- `what_feedback_did_not_change`
- `mechanism_learned_from_internal_links`
- `revised_idea`
- `updated_path_claims`
- `next_test`
- `branch_drift_check`

Use this exact link-step table header whenever you claim link support:

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |

`selected_link_ids`, `selected_item_ids`, and `selected_paper_ids` should be semicolon-separated and should reflect the branch you carry forward after this round. Link ids must come from `internal_links.csv`; do not invent link ids.
