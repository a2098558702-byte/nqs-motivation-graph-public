# Current Coverage V0 Edge Dependency Assay

This framework is a relation-dependent companion to the open-ended trajectory test.

The no-link unit should not be able to earn a high primary relation-dependency score, because the required output is an auditable support path with real link ids and matching endpoints.

## Question

Do graph edges materially change the generator's research trajectory, or can a nodes-only packet produce the same quality by using node-local content alone?

## Conditions

- G1: nodes only.
- G2: strict paper-internal edges.
- G3: clean candidate-context edges.
- G4: strict plus clean candidate-context edges.
- G5: paper-citation-only edges.

## Included Run

- `model_runs/edge_assay_20260519_112535/`

## Main Finding

The nodes-only condition is an honest fallback and scores low on relation-path metrics. G3 and G4 are strongest overall. G5 is mechanically clean but semantically weaker because citation-only edges do not reliably encode method/problem/result development.

## What To Read

1. `TEST_FRAMEWORK_LOGIC.md`
2. `model_runs/edge_assay_20260519_112535/audits/MECHANICAL_LINK_AUDIT.md`
3. `model_runs/edge_assay_20260519_112535/evaluations/blind_evaluation_gpt55_xhigh.md`
4. `model_runs/edge_assay_20260519_112535/evaluations/post_eval_unsealed_summary.md`
