# Edge Dependency Assay Runbook

Build sealed packets:

```bash
ruby scripts/build_edge_dependency_assay_v0.rb
```

Generator-facing packets are written to:

```text
trajectory_experiments/sealed_trial_v1/unit_*
```

Run each unit with:

- generator model: `gpt-5.2`
- reasoning effort: `low`
- no search, no browsing, no directory listing, no parent/sibling inspection
- strict round gating

Save outputs as:

```text
trajectory_experiments/current_coverage_v0_edge_dependency_assay/model_runs/RUN_ID/rounds/unit_XXX_trajectory.md
```

Then run the mechanical audit:

```bash
ruby scripts/check_edge_dependency_assay_outputs_v0.rb RUN_ID
```

The audit must be run before blind qualitative evaluation. It checks link-id validity, endpoint fidelity, path continuity, and future-round link leakage.

Prepare the blind evaluation packet:

```bash
ruby scripts/prepare_edge_dependency_blind_evaluation_packet_v0.rb RUN_ID
```

Qualitative blind evaluation, if run, must use `gpt-5.5` with reasoning effort `xhigh` and must not expose private mappings.
