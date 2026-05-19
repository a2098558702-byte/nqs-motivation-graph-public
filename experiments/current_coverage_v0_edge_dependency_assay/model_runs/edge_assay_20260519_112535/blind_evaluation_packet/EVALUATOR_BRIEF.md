# Blind Evaluation Brief

You are the blind evaluator for anonymized edge-dependency assay trajectories.

## Required Model

- Model: `gpt-5.5`
- Reasoning effort: `xhigh`

## Allowed Files

Read only files inside this blind evaluation packet:

- `EVALUATOR_BRIEF.md`
- `EVALUATION_RUBRIC.md`
- `case_*_trajectory.md`
- `mechanical_link_audit_summary_anonymous.csv`, if present

## Prohibited

- Do not search, browse, list parent/sibling directories, or inspect scripts/logs/metadata.
- Do not open sealed-unit directories, framework internals, private mapping files, or condition keys.
- Do not guess hidden condition names or hidden mappings.

## Task

Evaluate each anonymized trajectory using `EVALUATION_RUBRIC.md`.

Treat the mechanical audit as a constraint on link mechanics, not as a replacement for qualitative judgment. Include a cross-case comparison, but keep cases anonymous.
