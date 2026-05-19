# NQS Motivation Graph Public Artifact

This repository is a public research artifact for testing whether external literature-graph structure changes LLM-generated research trajectories in neural quantum states (NQS).

The core research question is: when the same literature observations are given to a generator, do edge structures such as paper-internal evidence links, candidate development links, citation links, or staged branch unlocks measurably change the resulting research idea trajectory?

## Current Public Snapshot

- Papers: 60
- Evidence nodes: 542
- Strict paper-internal edges: 594
- Candidate development/context edges: 77
- Paper citation edges: 261
- Citation reference-list coverage: 60 / 60 source papers
- Public package size: about 2 MB

Raw PDFs, arXiv source packages, `.tex`, `.bbl`, `.eprint`, private blind-evaluation keys, and local full-text caches are intentionally not redistributed.

## Repository Layout

- `data/current_coverage_graph_v0/`: redacted graph tables and validation summaries.
- `experiments/current_coverage_v0_edge_dependency_assay/`: nodes-only versus edge-conditioned assay, including run outputs and blind evaluation.
- `experiments/current_coverage_v0_adaptive_g6_assay/`: adaptive candidate-to-internal three-round assay.
- `experiments/current_coverage_v0_aligned_g3_g4_g6_comparison/`: aligned G3/G4/G6 comparison with equalized idea counts and blind evaluation.
- `protocols/RUN_PROTOCOL.md`: durable protocol rules for graph expansion, citation expansion, no-search generator/evaluator packets, and blind evaluation.
- `scripts/`: graph/test-framework builders from the private workspace plus public redaction, hygiene, and audit scripts.
- `docs/PROGRESS_LOG.md`: chronological project log.

## Main Results In This Snapshot

1. The edge-dependency assay made `nodes_only` a low-scoring but honest baseline on relation-path metrics. The strongest edge-dependent trajectories were G4 (`strict_plus_clean_candidate_context`) and G3 (`clean_candidate_context`), while G5 (`paper_citation_only`) was mechanically clean but semantically weaker.

2. The adaptive G6 run selected one candidate branch in round 0, unlocked strict internal evidence for that branch in later rounds, and produced 0 continuity breaks in the mechanical audit.

3. The aligned G3/G4/G6 comparison ranked G6 first under both the link/path rubric and the earlier idea-quality rubric. In the original idea rubric, the blind evaluator scored G6 40/40, G3 30/40, and G4 27/40.

These results are single-run evidence, not final condition-effect estimates. The next scientific step is replication across seeds, papers, and model snapshots.

## Quick Reproducibility Checks

The public repo uses only Ruby standard libraries for the included checks.

```bash
ruby scripts/redact_public_artifact_v0.rb
ruby scripts/check_public_release_hygiene_v0.rb
ruby scripts/check_edge_dependency_assay_outputs_v0.rb edge_assay_20260519_112535
ruby scripts/check_adaptive_candidate_internal_outputs_v0.rb adaptive_g6_20260519_134255
ruby scripts/check_aligned_g3_g4_g6_outputs_v0.rb aligned_g3_g4_g6_20260519_144241 adaptive_g6_20260519_134255
```

The graph-building scripts that reconstruct extraction waves require the private local full-text workspace and are preserved for provenance. They are not expected to rebuild the full graph from this public artifact alone.

## Contamination Controls

Generator and evaluator packets follow the durable protocol in `protocols/RUN_PROTOCOL.md`:

- no web search or browsing;
- no directory listing or parent/sibling inspection;
- no hidden condition-label guessing;
- no access to scripts, logs, private mapping keys, or future-round files;
- evaluator receives anonymous case packets before unsealing;
- controller-written qualitative scoring is not used as a substitute for blind evaluation.

## Data Boundary

The public graph tables preserve node ids, labels, relation types, paper ids, years, evidence locations, and paraphrases. Columns that previously carried source-paper excerpts are redacted as `[redacted_for_public_release]`.

See `DATA_STATEMENT.md` for data provenance and redistribution boundaries.
