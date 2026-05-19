# Edge Construction

This document explains the edge layers used in the public artifact and how they become the G1-G6 experimental conditions.

## Why There Are Multiple Edge Layers

The project deliberately separates three different things that are often conflated in literature graphs:

1. a paper's own argument structure;
2. possible cross-paper development relations;
3. paper-to-paper citation links.

Only the first layer is treated as strict evidence in the current graph. Candidate and citation layers are useful experimental context, but they do not become strict development facts by default.

## Nodes

Nodes are author-stated evidence units extracted from paper text. Common node types include:

- `paper`
- `problem`
- `method`
- `benchmark`
- `result_claim`
- `limitation`
- `future_work`
- `interpretation`
- `evaluation`
- `regime`

Public node rows keep the node id, paper id, year, label, section, location, and paraphrase. Source-paper excerpts in `evidence_quote` are redacted.

Main file:

- `data/current_coverage_graph_v0/graph_variants/nodes_only_nodes.csv`

## Layer 1: Strict Paper-Internal Evidence Edges

Main file:

- `data/current_coverage_graph_v0/graph_variants/paper_internal_edges_only.csv`

Construction source in the private workspace:

- `fulltext_evidence_edges.csv` from each extraction wave.

Meaning:

These edges encode author-supported relations inside a paper, usually from a paper node to its problem, method, benchmark, result, limitation, interpretation, or future-work nodes, or between those within-paper nodes.

Examples of relation types:

- `paper_states_problem`
- `paper_uses_method`
- `paper_evaluates_on_benchmark`
- `paper_reports_result`
- `method_targets_problem`
- `method_supports_result`
- `result_supports_interpretation`
- `limitation_motivates_future_work`

Strict-edge requirements:

- `graph_layer=evidence`
- endpoints must resolve to known node ids;
- `is_inferred=false`
- `needs_human_check=false`
- evidence comes from the paper text, not from broad topical similarity.

Interpretation:

A strict paper-internal edge says: within this paper, the source and target nodes have an author-supported relation of this type. It does not automatically say that two papers develop from one another.

## Layer 2: Candidate Development / Context Edges

Main files:

- `data/current_coverage_graph_v0/graph_variants/candidate_context_edges_endpoint_resolved.csv`
- `data/current_coverage_graph_v0/graph_variants/candidate_context_edges_clean.csv`

Construction source in the private workspace:

- `development_edge_candidates.csv` from each extraction wave.

Meaning:

Candidate edges preserve possible cross-paper development structure without weakening the strict evidence standard. They are useful for branch navigation, but they remain unreviewed.

Typical candidate relation sources:

- a later paper adopts or modifies an earlier method;
- a later paper responds to an earlier limitation or failure mode;
- a later paper uses an earlier benchmark or comparison target;
- a later paper turns an earlier method, result, diagnostic, or bottleneck into a research axis;
- two papers share a motivation unit or frontier pressure.

Candidate-edge requirements:

- original rows have `graph_layer=candidate`;
- public experimental variants use `graph_layer=candidate_context`;
- `needs_human_check=true`;
- relation types are prefixed with `candidate__` in public graph variants;
- these rows are experimental context, not strict facts.

Candidate status values:

- `strict_possible_unreviewed`: direct full-text context looks strong, but no controller upgrade has been performed.
- `possible_unreviewed`: scientifically useful but too broad or indirect for the strict graph.
- `weak_possible_unreviewed`: worth preserving for later inspection, but unlikely to become strict without more support.

Endpoint-resolved versus clean:

- `candidate_context_edges_endpoint_resolved.csv` keeps candidate edges whose source and target node ids both exist in the current graph.
- `candidate_context_edges_clean.csv` is stricter: endpoints resolve, `graph_layer=candidate`, `needs_human_check=true`, and a `candidate_status=...` note is present.

Interpretation:

A candidate edge says: this is a plausible cross-paper context relation worth testing or reviewing. It does not prove method inheritance, limitation response, or conceptual development.

## Layer 3: Paper Citation Edges

Main file:

- `data/current_coverage_graph_v0/graph_variants/paper_citation_edges_only.csv`

Construction source in the private workspace:

- each source paper's local reference list, preferring `.bbl` or references `.tex` over `.bib`;
- citation matching by arXiv id or normalized exact title match.

Meaning:

Citation edges connect paper nodes only:

```text
source paper node -> target paper node
```

The relation type is:

- `paper_cites_paper`

Interpretation:

A citation edge means only "the source paper references the target paper." It does not assert method inheritance, benchmark reuse, limitation response, or conceptual development.

## Public Graph Variants

The public release includes several graph variants so the same node set can be tested under different edge structures.

| File | Meaning | Used as |
|---|---|---|
| `empty_edges_for_nodes_only.csv` | no visible edges | G1 baseline |
| `paper_internal_edges_only.csv` | strict paper-internal evidence edges only | G2 |
| `candidate_context_edges_clean.csv` | endpoint-clean unreviewed candidate context only | G3 |
| `paper_internal_plus_clean_candidate_context_edges.csv` | strict internal edges plus clean candidate context | G4 |
| `paper_citation_edges_only.csv` | paper-node reference-list citations only | G5 |
| `candidate_context_edges_endpoint_resolved.csv` | broader endpoint-resolved candidate context | inspection / analysis |
| `paper_internal_plus_candidate_context_edges.csv` | strict internal plus broader endpoint-resolved candidate context | inspection / analysis |

The full public snapshot has:

- 60 papers;
- 542 evidence nodes;
- 594 strict paper-internal edges;
- 77 candidate development/context edges;
- 261 paper-citation edges.

Some experiments use a 2023 visibility cutoff. Under that cutoff, the condition matrix uses 418 visible nodes and condition-specific edge counts.

## Experimental Conditions

The reusable test framework defines:

- G1 `nodes_only`: same visible nodes, no edges.
- G2 `strict_paper_internal`: same visible nodes, strict paper-internal edges only.
- G3 `clean_candidate_context`: same visible nodes, clean candidate-context edges only.
- G4 `strict_plus_clean_candidate_context`: same visible nodes, strict paper-internal edges plus clean candidate-context edges.
- G5 `paper_citation_only`: same visible nodes, paper-to-paper citation edges only.

G6 is adaptive rather than a static graph file:

- Round 0 uses candidate-context paths to choose a branch.
- Later rounds unlock strict paper-internal edges for the selected branch.
- The purpose is to test whether candidate edges can act as a reading policy while internal edges provide mechanism grounding.

## What These Edges Do Not Claim

- Candidate-context edges do not become strict facts.
- Citation edges do not imply semantic development.
- Branch labels are organizing metadata, not evidence.
- Redacted evidence columns in the public repo are not sufficient for independent source verification; a researcher needs legitimate access to the source paper to check the cited location.

## Where The Rules Are Implemented

Core scripts:

- `scripts/build_current_coverage_graph_v0.rb`
- `scripts/build_current_coverage_test_framework_v0.rb`
- `scripts/build_edge_dependency_assay_v0.rb`

Core protocol files:

- `protocols/RUN_PROTOCOL.md`
- `experiments/current_coverage_v0_test_framework/TEST_FRAMEWORK_LOGIC.md`
- `experiments/current_coverage_v0_test_framework/EXPERIMENT_PROTOCOL.md`
