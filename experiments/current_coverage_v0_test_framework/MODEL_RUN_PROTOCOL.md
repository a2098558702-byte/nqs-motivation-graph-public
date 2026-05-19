# Model Run Protocol

## Roles

- Generator: `gpt-5.2`, reasoning effort `low`.
- Blind evaluator: `gpt-5.5`, reasoning effort `xhigh`.

The controller/main agent only prepares packets, launches or records model runs, checks files, and preserves blindness. It must not evaluate the trajectories.

## Generator Procedure

1. Assign each generator exactly one sealed unit directory.
2. Use `gpt-5.2` with reasoning effort `low`.
3. Enforce round-gated access:
   - Round 0: `brief.md`, `items.csv`, `links.csv`.
   - Round 1: unlock `update_a.md` only after Round 0 output is complete.
   - Round 2: unlock `update_b.md` only after Round 1 output is complete.
4. Save each trajectory with the sealed unit id in the run's `rounds/` directory.

## Blind Evaluation Procedure

1. Build an anonymized evaluation packet from completed trajectory files.
2. Remove sealed unit ids, condition labels, condition names, edge-condition names, and key filenames from evaluator-facing materials.
3. Use `gpt-5.5` with reasoning effort `xhigh`.
4. Give the evaluator only:
   - anonymized trajectories;
   - `EVALUATION_RUBRIC.md`;
   - the instruction that hidden mappings must not be guessed.
5. Save evaluator output in the run's `evaluations/` directory.
6. Open private condition keys only after evaluator output is complete and immutable.

## Prohibited

- Do not evaluate trajectories in the controller/main agent.
- Do not expose `condition_key_private.csv` or `blind_condition_key_private.csv` to the evaluator.
- Do not let generator or evaluator search, browse, list parent/sibling directories, or inspect scripts/logs/metadata.
