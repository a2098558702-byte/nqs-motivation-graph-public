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
