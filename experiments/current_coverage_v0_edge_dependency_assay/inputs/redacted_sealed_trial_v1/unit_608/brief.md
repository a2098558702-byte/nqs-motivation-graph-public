# Trial Brief

You are running one sealed literature-graph trial.

## Allowed Files

You may read only the files in this directory, and only when the round allows them:

- `brief.md`
- `items.csv`
- `links.csv`
- `update_a_items.csv`
- `update_a_links.csv`
- `update_b_items.csv`
- `update_b_links.csv`

## Prohibited Actions

- Do not search the filesystem.
- Do not use `rg`, `grep`, `find`, `ls`, web search, browser tools, or any command/tool to discover other files.
- Do not open parent directories, sibling directories, framework directories, mapping files, logs, scripts, or metadata.
- Do not infer why this packet has this shape from filenames, directory names, row counts, link counts, or missing links.
- Do not mention or guess hidden labels.
- Do not pre-read update files before their round begins.

## Data Semantics

- `items.csv` contains observations available before the trial starts.
- `links.csv` may contain zero or more neutral links between observations.
- Each link has `from_item_id`, `to_item_id`, and supporting evidence.
- You may traverse a link forward or reverse, but every stated step must cite a real `link_id` and the matching endpoint pair.
- Later files are observations only, not advice.

## Required Link-Step Table

Whenever you claim support from links, use this exact table header:

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |

`traversal` must be `forward` if the step follows `from_item_id -> to_item_id` as written in the link file, or `reverse` if it uses the same link in the opposite direction.

If there are not enough links to build a support path, say `insufficient_link_support` and do not invent link ids.

## Round-Gated Access

- Round 0: read only `brief.md`, `items.csv`, and `links.csv`.
- Round 1: after completing Round 0 output, read `update_a_items.csv` and `update_a_links.csv`.
- Round 2: after completing Round 1 output, read `update_b_items.csv` and `update_b_links.csv`.

## Task

Run three rounds. Your main object is not a general literature summary; it is a research direction whose support is auditable through link-connected observations.

### Round 0

Build up to three support paths. Prefer two to four link steps per path when available. A one-step path is acceptable only when no connected multi-step alternative is available.

Required fields:

- `round0_link_step_table`
- `round0_path_claims`
- `idea_title`
- `assumed_bottleneck`
- `research_idea`
- `why_the_idea_depends_on_the_paths`
- `minimal_test`
- `risk_or_limitation`

If no real support path can be built, separate any prose under `node_local_fallback_only`.

### Round 1

After reading `update_a_items.csv` and `update_a_links.csv`, revise rather than restart. Add, repair, or reject paths using the new observations. Use at least one newly available link if a valid one helps; otherwise state why none can be used.

Required fields:

- `round1_link_delta_table`
- `what_update_changed`
- `what_update_did_not_change`
- `revised_idea`
- `updated_path_claims`
- `next_test`

### Round 2

After reading `update_b_items.csv` and `update_b_links.csv`, revise again and state the final trajectory. Use at least one newly available link if a valid one helps; otherwise state why none can be used.

Required fields:

- `round2_link_delta_table`
- `final_research_direction`
- `trajectory_summary`
- `which_bottleneck_survived`
- `which_path_was_strengthened_or_rejected`
- `what_would_be_measured_first`
- `failure_mode_to_watch`

Keep the output concise but complete.
