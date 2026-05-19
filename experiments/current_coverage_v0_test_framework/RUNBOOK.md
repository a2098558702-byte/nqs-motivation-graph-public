# Runbook

## Rebuild Everything

```bash
ruby scripts/rebuild_all_test_frameworks_v0.rb
```

This runs citation backfill, rebuilds the current coverage graph, rebuilds this open-ended trajectory framework, and rebuilds the edge-dependency assay.

For this framework only:

```bash
ruby scripts/build_current_coverage_test_framework_v0.rb
```

## Inspect Deterministic Probe Results

```bash
sed -n '1,220p' trajectory_experiments/current_coverage_v0_test_framework/analysis/deterministic_probe_report.md
```

## Run Model Trajectories Later

Create a reusable run directory:

```bash
ruby scripts/scaffold_current_coverage_model_run_v0.rb RUN_ID
```

Use sealed units, not the debug `inputs/G*` prompts:

- `../sealed_trial_v0/unit_104/brief.md`
- `../sealed_trial_v0/unit_287/brief.md`
- `../sealed_trial_v0/unit_563/brief.md`
- `../sealed_trial_v0/unit_829/brief.md`
- `../sealed_trial_v0/unit_641/brief.md`

Worker rule:

- generator model is `gpt-5.2` with reasoning effort `low`;
- read only the assigned unit directory;
- do not search;
- do not list sibling or parent directories;
- do not inspect key, framework, script, or log files.
- do not pre-read update files before their round begins.

Save outputs under:

- `trajectory_experiments/current_coverage_v0_test_framework/model_runs/RUN_ID/rounds/unit_104_trajectory.md`
- `trajectory_experiments/current_coverage_v0_test_framework/model_runs/RUN_ID/rounds/unit_287_trajectory.md`
- `trajectory_experiments/current_coverage_v0_test_framework/model_runs/RUN_ID/rounds/unit_563_trajectory.md`
- `trajectory_experiments/current_coverage_v0_test_framework/model_runs/RUN_ID/rounds/unit_829_trajectory.md`
- `trajectory_experiments/current_coverage_v0_test_framework/model_runs/RUN_ID/rounds/unit_641_trajectory.md`

## Run Blind Evaluation Later

Use `gpt-5.5` with reasoning effort `xhigh`.

Prepare the anonymized packet:

```bash
ruby scripts/prepare_blind_evaluation_packet_v0.rb RUN_ID
```

The evaluator receives only anonymized trajectories plus `EVALUATION_RUBRIC.md`. The controller/main agent must not score the trajectories.

## Relation-Dependency Variant

If the goal is specifically to test whether edges matter, use the companion framework:

```bash
ruby scripts/build_edge_dependency_assay_v0.rb
ruby scripts/scaffold_edge_dependency_assay_run_v0.rb RUN_ID
```

After generator outputs are saved, run:

```bash
ruby scripts/check_edge_dependency_assay_outputs_v0.rb RUN_ID
ruby scripts/prepare_edge_dependency_blind_evaluation_packet_v0.rb RUN_ID
```

This variant is designed so the no-link packet cannot score high on relation-path metrics merely by writing a strong node-local research proposal.
