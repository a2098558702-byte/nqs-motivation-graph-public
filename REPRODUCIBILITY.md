# Reproducibility Notes

## Environment

- Ruby 2.6 or newer.
- No non-standard Ruby gems are required for the public checks.

## Public Checks

Run from the repository root:

```bash
ruby scripts/redact_public_artifact_v0.rb
ruby scripts/check_public_release_hygiene_v0.rb
ruby scripts/check_edge_dependency_assay_outputs_v0.rb edge_assay_20260519_112535
ruby scripts/check_adaptive_candidate_internal_outputs_v0.rb adaptive_g6_20260519_134255
ruby scripts/check_aligned_g3_g4_g6_outputs_v0.rb aligned_g3_g4_g6_20260519_144241 adaptive_g6_20260519_134255
```

Expected high-level audit results:

- Edge dependency assay: `nodes_only` has 0 parsed/valid link steps and records fallback mentions; G3/G4/G2/G5 contain link-step tables with condition-specific continuity behavior.
- Adaptive G6 assay: round0 3/3 valid, round1 7/7 valid, round2 10/10 valid, 0 continuity breaks.
- Aligned comparison: G6 has 0 continuity breaks; G3 and G4 retain their recorded mechanical weaknesses.

## Private-Workspace Scripts

Some scripts are retained for provenance but require the original full-text workspace:

- extraction-wave builders;
- citation-reference backfill from arXiv source packages;
- full graph rebuild from raw extraction waves;
- sealed packet scaffolding from private condition matrices.

Do not expect those scripts to fully rebuild the project from this public repository alone.
