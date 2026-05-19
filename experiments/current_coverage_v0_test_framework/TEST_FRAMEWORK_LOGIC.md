# Current Coverage V0 Test Framework Logic

## Purpose

This framework freezes the current graph-test logic for the 60-paper NQS evidence graph. It is designed to test how graph structure changes research-trajectory behavior while keeping the evidence-node set fixed.

## Input Graph

The framework always rebuilds `current_coverage_graph_v0` before generating test files.

Current graph summary:

```text
papers: 60
nodes: 542
strict_edges: 594
candidate_edges: 77
paper_citation_edges: 261
paper_citation_sources_with_reference_files: 60
candidate_context_edges_endpoint_resolved: 61
candidate_context_edges_clean: 44
candidate_review_backlog: 33
duplicate_node_ids: 0
strict_endpoint_errors: 0
strict_bad_flags: 0
candidate_endpoint_warnings: 16
candidate_bad_flags: 17
```

The strict graph remains evidence-only. Candidate-context variants are experimental inputs only and do not upgrade candidates into strict edges.

## Fixed Units

- Node: author-stated evidence node from full text.
- Strict edge: paper-local/internal evidence edge with no inference and no human-check flag.
- Paper citation edge: paper-node to paper-node edge generated from local reference files when a corpus paper references another corpus paper by arXiv ID or exact title.
- Candidate edge: unreviewed development relation that must keep `needs_human_check=true`.
- Clean candidate-context edge: candidate edge with resolved endpoints and `candidate_status=...`; used only as an experimental context layer.

## Conditions

- `G1 nodes_only`: same visible nodes, no edges.
- `G2 strict_paper_internal`: same visible nodes, paper-local strict edges only.
- `G3 clean_candidate_context`: same visible nodes, clean candidate-context edges only.
- `G4 strict_plus_clean_candidate_context`: same visible nodes, strict paper-local edges plus clean candidate-context edges.
- `G5 paper_citation_only`: same visible nodes, paper-to-paper reference-list citation edges only.

## Cutoff And Feedback

- Round 0 cutoff: 2023.
- Feedback round 1 reveals 2024 paper nodes only.
- Feedback round 2 reveals 2025-2026 paper nodes only.
- Feedback packets contain nodes, not prescriptions.
- Round access is gated: generators may not read update files before completing the prior round output.

## Test Modes

1. Deterministic retrieval probes:
   - Cheap sanity checks.
   - Compare top-k retrieved context across conditions for fixed research questions.
   - Output lives in `analysis/retrieval_probe_*.csv` and `analysis/deterministic_probe_report.md`.
   - These probes are intentionally conservative: they only test whether edge conditions perturb retrievable context, not whether a language model will use those edges creatively.
   - A clean candidate-only condition can look weak in deterministic probes if its endpoints are not lexical matches for the probe terms; that is a probe limitation, not evidence that candidate context is useless.

2. Model trajectory generation:
   - Use only `trajectory_experiments/sealed_trial_v0/unit_*/brief.md`.
   - Give each generator exactly one assigned `unit_*` directory.
   - Generators must not search, browse, list sibling directories, inspect parent directories, or open key/framework files.
   - Generators must not pre-read `update_a.md` or `update_b.md`; each update is unlocked only after the previous round output is complete.
   - The older `inputs/G*_generator_prompt.md` files are retained only for internal framework debugging and must not be used for valid sealed trials.
   - The output should be saved under `rounds/` if run later.

3. Hidden-key evaluation:
   - Evaluate completed trajectories with `EVALUATION_RUBRIC.md` before opening the private key.
   - The target observable is trajectory role, not only final idea quality.

## Invariants

- Same visible node set per condition.
- Same cutoff per condition.
- Same feedback packets per condition.
- Same generator task per condition.
- Only edge condition changes.
- Current citation coverage must be complete for all source papers before sealed model-generation trials are run. If `paper_citation_sources_with_reference_files < papers`, run `scripts/backfill_missing_reference_lists_from_arxiv.rb` and rebuild.
- Candidate context is always labelled as unreviewed context.
- Paper citation edges are descriptive reference-list links only; they do not assert semantic development by themselves.
- Sealed generation prompts must not contain condition-role words such as `strict`, `candidate`, `paper_internal`, `nodes_only`, `citation`, or `edge_schema`.
- Sealed generation prompts must include an explicit no-search / whitelist-only rule.

## What This Framework Can Test

- Whether strict paper-local edges produce paper-argument reasoning.
- Whether candidate-context edges produce branch-trajectory reasoning.
- Whether paper-to-paper citation edges alone create useful literature-lineage trajectories.
- Whether combined edges produce a more integrated research-program trajectory.
- Whether feedback is absorbed selectively or causes branch drift.

## What This Framework Cannot Claim Alone

- It does not prove any candidate edge is strict.
- It does not rank the whole NQS literature.
- It does not measure scientific novelty without independent generator/evaluator runs.
- It does not replace human review of candidate development edges.
