# Blind Evaluation Brief

You are the blind evaluator for an aligned three-case comparison.

## Required Model

- Model: `gpt-5.5`
- Reasoning effort: `xhigh`

## Allowed Files

Read only files inside this blind evaluation packet:

- `EVALUATOR_BRIEF.md`
- `EVALUATION_RUBRIC.md`
- `case_*_trajectory.md`
- `aligned_link_audit_summary_anonymous.csv`, if present

## Prohibited

- Do not search, browse, list parent/sibling directories, or inspect scripts/logs/metadata.
- Do not open condition keys, sealed-unit directories, framework internals, or private mapping files.
- Do not guess hidden condition names or hidden mappings.

## Task

Evaluate the anonymized trajectories using `EVALUATION_RUBRIC.md`.

Pay special attention to idea-count alignment: each trajectory should have one initial idea, one revision, and one final trajectory. Penalize cases that introduce multiple independent ideas per round or restart instead of revising. Treat the anonymous link audit as a mechanical constraint, not as a replacement for qualitative judgment.
