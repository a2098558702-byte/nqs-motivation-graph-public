# Full-Text 100plus Run V0 Protocol

Use these global protocols:

- `Outputs/Full-Text Evidence Extraction Logic V0.md`
- `Outputs/NQS Development-Edge Extraction Protocol V0.md`
- `Outputs/Evidence-Only Motivation Graph Protocol.md`
- `Outputs/NQS Motivation Graph Full Expansion Implementation Plan V0.md`
- `Outputs/NQS Motivation Graph Gold Standard Calibration Pack V0.md`

## Progress Rule

After each coherent work unit, update:

- `Data/Motivation Graph Agent V0/NQS_FullText_Evidence_Batches/fulltext_100plus_run_v0/PROGRESS_LOG.md`

Do not leave durable decisions, extraction status, or experiment results only in chat.

## Key Rule

This run is not building the main motivation graph as a pure citation graph.

Maintain a separate paper-to-paper citation layer alongside the evidence graph. For every paper added to an extraction wave, citation coverage must be updated from that paper's own reference list before current-coverage experiments are treated as complete.

Citation-layer rules:

- Citation edges connect paper nodes only.
- Citation edges mean only `source paper references target paper`; they do not assert method inheritance, limitation response, benchmark reuse, or conceptual development.
- Prefer actual reference lists (`.bbl` or references `.tex`) over `.bib` files.
- If a paper has no local reference list, run `ruby scripts/backfill_missing_reference_lists_from_arxiv.rb` to fetch the arXiv source package and extract/copy reference-list material.
- After adding papers or backfilling references, rebuild with `ruby scripts/build_current_coverage_test_framework_v0.rb`; this rebuilds citation edges, graph variants, sealed packets, and deterministic probes.
- To rebuild every reusable test asset in the current run, use `ruby scripts/rebuild_all_test_frameworks_v0.rb`.
- Do not use web search snippets or inferred bibliography matches as citation evidence. Use source/reference-list files and record provenance.

## Reusable Test Frameworks

The current run maintains two reusable model-test frameworks:

1. Open-ended three-round trajectory test:
   - Build: `ruby scripts/build_current_coverage_test_framework_v0.rb`
   - Scaffold run: `ruby scripts/scaffold_current_coverage_model_run_v0.rb RUN_ID`
   - Prepare blind evaluation packet: `ruby scripts/prepare_blind_evaluation_packet_v0.rb RUN_ID`
   - Purpose: observe how graph variants affect research-trajectory behavior under the same node set and feedback rounds.

2. Edge-dependency assay:
   - Build: `ruby scripts/build_edge_dependency_assay_v0.rb`
   - Scaffold run: `ruby scripts/scaffold_edge_dependency_assay_run_v0.rb RUN_ID`
   - Mechanical audit: `ruby scripts/check_edge_dependency_assay_outputs_v0.rb RUN_ID`
   - Prepare blind evaluation packet: `ruby scripts/prepare_edge_dependency_blind_evaluation_packet_v0.rb RUN_ID`
   - Purpose: test whether relation layers enable auditable support paths. Use this when the question is whether edges matter; the no-link condition is expected to abstain from path claims and score low on primary relation-dependency metrics.

Both frameworks preserve the same model role rule:

- Generator: `gpt-5.2`, reasoning effort `low`.
- Blind evaluator: `gpt-5.5`, reasoning effort `xhigh`.
- Controller/main agent must not substitute qualitative judgment for the blind evaluator.
- Generator/evaluator packets must prohibit search, browsing, directory listing, parent/sibling inspection, framework/script/log/key access, hidden-label guessing, and pre-reading future rounds.

## Current Phase Rule

Current phase: scale evidence-node coverage toward 100+ papers.

Do not spend this phase on controller review or upgrading broad cross-paper relations. Keep strict and possible relations separated:

- `fulltext_evidence_edges.csv`: strict paper-local edges, plus only hard cross-paper edges with direct full-text evidence.
- `development_edge_candidates.csv`: all useful but unreviewed cross-paper relations, including relations that look likely to become strict after review.
- `inference layer`: do not create yet unless explicitly requested.

The goal is to preserve potential cross-paper structure without relaxing the strict graph.

The first expansion wave is paper-local first:

1. locate source / full text;
2. create section map;
3. extract author-stated evidence nodes;
4. extract paper-internal evidence edges;
5. record possible cross-paper development candidates;
6. do not create broad strict cross-paper development edges from arbitrary batch co-occurrence.

Strict cross-paper development edges should be upgraded later during branch-local linking, unless a worker finds direct hard evidence while reading a paper, such as explicit citation context, method inheritance, limitation-response wording, comparison target, or review/frontier summary.

For each batch, extract:

1. paper-internal evidence nodes;
2. paper-internal evidence edges;
3. hard cross-paper development edges when supported by direct full-text evidence;
4. medium development-edge candidates when supported by shared motivation units or field-role continuation, with `needs_human_check = true`;
5. protocol notes for edge types or evidence sources not covered by the current protocol.

Medium sources such as shared motivation unit, shared benchmark role, parallel branch response, or field-frontier alignment must go to `development_edge_candidates.csv`, not `fulltext_evidence_edges.csv`, unless there is additional hard full-text evidence.

## Cross-Paper Candidate Recording Rule

When reading introduction, related work, method comparison, discussion, conclusion, or outlook, record possible cross-paper relations if the later paper:

- uses an earlier paper as a benchmark or comparison target;
- adopts, modifies, or extends an earlier method;
- responds to an earlier limitation or failure mode;
- turns an earlier result into a new question;
- turns an earlier method component, benchmark, diagnostic, or bottleneck into a research axis.

Because this phase is not doing controller review, put these relations into `development_edge_candidates.csv` with one of these notes:

- `candidate_status=strict_possible_unreviewed`: direct full-text evidence appears strong, but no controller upgrade has been performed.
- `candidate_status=possible_unreviewed`: relation is scientifically useful but too broad or indirect for strict graph.
- `candidate_status=weak_possible_unreviewed`: relation is worth preserving for later human/model inspection but probably should not become strict.

All candidate rows must keep `graph_layer=candidate` and `needs_human_check=true`.

Do not downgrade the strict standard to increase cross-paper edge count.

## Output Files Per Batch

- `source_status.csv`
- `section_map.csv`
- `fulltext_evidence_nodes.csv`
- `fulltext_evidence_edges.csv`
- `development_edge_candidates.csv`
- `protocol_notes.md`
- `extraction_log.md`

## Branch-Aware Manifest

Use this file to choose branch-aware work units:

- `manifests/branch_assignment_v0.csv`

Summary:

- `manifests/branch_assignment_summary_v0.md`

The primary branch is an organizing label only. It is not evidence and must not be used as proof of a scientific relation.

Branch workpacks:

- `workpacks/`

Worker prompts:

- `prompts/paper_local_extraction_worker_prompt_v0.md`
- `prompts/controller_branch_linking_prompt_v0.md`

## Cross-Paper Edge Calibration

Calibrate against the first 10-paper J1-J2 strict pilot. Important relation types include:

- `benchmark_escalation`
- `turns_pain_point_into_benchmark`
- `mitigates_failure_mode`
- `branch_response`
- `physics_transition`
- `moves_beyond_raw_method`
- `requires_controlled_comparison`
- `turns_component_into_axis`
- `identifies_interaction`
- `scaling_transition`
- `exposes_new_pain_point`
- `convergence_node`
- `forms_recipe_space`

Citation context can support these relations, but is not the relation itself.
