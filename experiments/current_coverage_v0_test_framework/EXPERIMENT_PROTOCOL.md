# Current Coverage V0 Experiment Protocol

## Build Command

```bash
ruby scripts/backfill_missing_reference_lists_from_arxiv.rb
ruby scripts/build_current_coverage_test_framework_v0.rb
```

The backfill command is needed whenever newly added papers lack local reference-list coverage. The framework command rebuilds `current_coverage_graph_v0`, writes the test framework directory, and runs deterministic retrieval probes.

## Directory Contract

- `TEST_FRAMEWORK_LOGIC.md`: stable logic and invariants.
- `condition_matrix.csv`: public condition sizes and roles.
- `condition_key_private.csv`: private condition names for blind evaluation.
- `blind_condition_key_private.csv`: maps sealed case directories to private condition names.
- `inputs/`: visible node/edge CSVs, generator prompts, and feedback packets.
- `analysis/`: deterministic probe outputs and reports.
- `rounds/`: intended location for model-generated trajectories.
- `evaluations/`: intended location for hidden-key evaluation outputs.
- `../sealed_trial_v0/`: neutral generation packet; use this for valid model-generation trials.

## Round Protocol

1. Assign each generator exactly one neutral sealed directory under `trajectory_experiments/sealed_trial_v0/unit_*`.
2. Give the generator only that unit's `brief.md`; the brief itself lists the allowed files.
3. Enforce no-search / whitelist-only access. The generator must not list parent directories or inspect scripts/logs/keys.
4. Enforce round-gated access: Round 0 uses only `items.csv` and `links.csv`; Round 1 unlocks `update_a.md`; Round 2 unlocks `update_b.md`.
5. Save outputs as `rounds/unit_104_trajectory.md`, etc.
6. Run a hidden-key evaluator using `EVALUATION_RUBRIC.md`.
7. Only after evaluation, inspect `blind_condition_key_private.csv`.

## Model Role Contract

- Generator model: `gpt-5.2` with reasoning effort `low`.
- Blind evaluator model: `gpt-5.5` with reasoning effort `xhigh`.
- The controller/main agent must not score, classify, or rank generated trajectories.
- The evaluator receives only anonymized trajectory files and the rubric, never `condition_key_private.csv`, `blind_condition_key_private.csv`, condition names, or sealed unit mappings.
- Save model outputs and evaluator outputs in a timestamped run directory so model identity and reasoning effort remain auditable.

## Candidate Context Rule

Candidate-context edges are allowed only as labelled experimental context. They must not be quoted as strict graph facts.

In sealed packets, candidate/strict labels are removed from generator-facing link names. The controller may recover the condition only after the blind evaluation.

## Paper Citation Rule

Paper citation edges are generated separately from reference-list files. They connect paper nodes only and mean "the source paper references the target paper"; they do not by themselves claim method inheritance, problem response, or conceptual development.

After any paper expansion wave, rerun `scripts/backfill_missing_reference_lists_from_arxiv.rb` and then `scripts/build_current_coverage_test_framework_v0.rb` so the citation-only condition and sealed packet stay in sync with evidence coverage.
