# Adaptive G6 Run adaptive_g6_20260519_134255

## Generator Settings

- Model: `gpt-5.2`
- Reasoning effort: `low`
- Search, browsing, directory listing, parent/sibling inspection, metadata inspection, and hidden-label guessing are prohibited.

## Round 0

Read only:

```text
<LOCAL_RESEARCH_WORKSPACE>/trajectory_experiments/sealed_trial_v2/unit_906/round0
```

Save:

```text
<LOCAL_RESEARCH_WORKSPACE>/trajectory_experiments/current_coverage_v0_adaptive_g6_assay/model_runs/adaptive_g6_20260519_134255/rounds/unit_906_round0.md
```

## Round 1 / Round 2

Prepare each subsequent packet mechanically:

```bash
ruby scripts/prepare_adaptive_candidate_internal_round_v0.rb adaptive_g6_20260519_134255 round1
ruby scripts/prepare_adaptive_candidate_internal_round_v0.rb adaptive_g6_20260519_134255 round2
```
