# Adaptive G6 Runbook

Build the staged packet:

```bash
ruby scripts/build_adaptive_candidate_internal_assay_v0.rb
```

Scaffold a run:

```bash
ruby scripts/scaffold_adaptive_candidate_internal_run_v0.rb RUN_ID
```

Run Round 0 with `gpt-5.2` / `low` using only:

```text
trajectory_experiments/sealed_trial_v2/unit_906/round0/
```

Save Round 0 output to:

```text
trajectory_experiments/current_coverage_v0_adaptive_g6_assay/model_runs/RUN_ID/rounds/unit_906_round0.md
```

Prepare Round 1 packet:

```bash
ruby scripts/prepare_adaptive_candidate_internal_round_v0.rb RUN_ID round1
```

Run Round 1 using only the generated run packet. Then prepare and run Round 2:

```bash
ruby scripts/prepare_adaptive_candidate_internal_round_v0.rb RUN_ID round2
ruby scripts/assemble_adaptive_candidate_internal_trajectory_v0.rb RUN_ID
ruby scripts/check_adaptive_candidate_internal_outputs_v0.rb RUN_ID
```
