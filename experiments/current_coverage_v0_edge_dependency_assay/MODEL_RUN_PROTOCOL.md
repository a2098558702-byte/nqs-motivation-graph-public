# Edge Dependency Assay Model Run Protocol

## Roles

- Generator: `gpt-5.2`, reasoning effort `low`.
- Blind evaluator: `gpt-5.5`, reasoning effort `xhigh`.

The controller/main agent prepares packets, launches or records model runs, checks mechanical link validity, and preserves blindness. It must not substitute qualitative judgment for the blind evaluator.

## Generator Procedure

1. Assign each generator exactly one sealed unit directory under `trajectory_experiments/sealed_trial_v1/unit_*`.
2. Use `gpt-5.2` with reasoning effort `low`.
3. Enforce round-gated access:
   - Round 0: `brief.md`, `items.csv`, `links.csv`.
   - Round 1: unlock `update_a_items.csv` and `update_a_links.csv` only after Round 0 output is complete.
   - Round 2: unlock `update_b_items.csv` and `update_b_links.csv` only after Round 1 output is complete.
4. Save each trajectory with the sealed unit id under a run-specific `rounds/` directory.

## Mechanical Audit

After generation, run:

```bash
ruby scripts/check_edge_dependency_assay_outputs_v0.rb RUN_ID
```

This audit only checks link mechanics: whether cited link ids exist, whether stated endpoints match, and whether path tables are continuous. It is not a qualitative evaluation of scientific merit.

## Blind Evaluation Procedure

Use `gpt-5.5` with reasoning effort `xhigh` for qualitative evaluation. The evaluator receives anonymized trajectories, the assay rubric, and the mechanical audit summary, but not private mappings.

## Prohibited

- Do not let generator or evaluator search, browse, list parent/sibling directories, or inspect scripts/logs/metadata.
- Do not expose files under `private/` to the generator or evaluator.
- Do not use the controller/main agent as the qualitative scorer.
