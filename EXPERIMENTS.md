# Experiment Map

This repository contains one frozen test framework and three concrete experiment runs. They should be read in this order.

## 1. Test Framework

Path: `experiments/current_coverage_v0_test_framework/`

Role: protocol and design layer.

This directory defines the experiment logic for the current 60-paper graph. It records the graph conditions, generator/evaluator roles, sealed-packet constraints, no-search rules, blind-evaluation rules, and the basic scoring rubric.

It is not mainly a result directory. It is the "rules of the game" that later experiments instantiate.

Key files:

- `TEST_FRAMEWORK_LOGIC.md`
- `EXPERIMENT_PROTOCOL.md`
- `MODEL_RUN_PROTOCOL.md`
- `EVALUATION_RUBRIC.md`
- `condition_matrix.csv`
- `model_role_manifest.csv`

## 2. Edge Dependency Assay

Path: `experiments/current_coverage_v0_edge_dependency_assay/`

Role: first relation-dependence test.

This experiment asks whether edges matter at all. The task is designed so that a nodes-only condition cannot score highly on relation-path metrics, because the generator must build auditable support paths with real link ids and matching endpoints.

Compared conditions:

- G1: nodes only
- G2: strict paper-internal edges
- G3: clean candidate-context edges
- G4: strict plus clean candidate-context edges
- G5: paper-citation-only edges

Main result:

- G1 behaves as an honest node-local fallback and scores low on relation-path metrics.
- G3 and G4 are strongest overall.
- G5 is mechanically clean but semantically weaker because citation edges alone often do not carry method/problem/result development.

Key run:

- `model_runs/edge_assay_20260519_112535/`

## 3. Adaptive G6 Candidate-To-Internal Assay

Path: `experiments/current_coverage_v0_adaptive_g6_assay/`

Role: staged graph-attention mechanism test.

This experiment tests the hypothesis that candidate-context edges are useful for branch navigation, while strict internal edges are useful for mechanism learning.

Three-round flow:

- Round 0: the generator sees candidate-context paths and proposes one idea.
- Round 1: the selected branch unlocks strict paper-internal links for that branch, plus the same feedback style as other conditions.
- Round 2: the branch is updated again using unlocked internal mechanism evidence and feedback.

Main result:

- Round 0: 3/3 valid link steps.
- Round 1: 7/7 valid link steps.
- Round 2: 10/10 valid link steps.
- Continuity breaks: 0.

Interpretation:

G6 supports the staged design: use cross-paper candidate links as a reading policy, then use branch-local internal links to ground the mechanism.

Key run:

- `model_runs/adaptive_g6_20260519_134255/`

## 4. Aligned G3/G4/G6 Comparison

Path: `experiments/current_coverage_v0_aligned_g3_g4_g6_comparison/`

Role: fair comparison of the strongest non-adaptive and adaptive designs.

This experiment compares G3, G4, and G6 after aligning the number of idea proposals and the three-round structure. This prevents a condition from winning merely because it produced more candidate ideas or received a different round schedule.

Compared conditions:

- G3: clean candidate-context edges
- G4: strict plus clean candidate-context edges
- G6: adaptive candidate-to-internal staged unlock

Main blind-evaluation result:

1. G6: first
2. G3: second
3. G4: third

Under the earlier original idea-quality rubric, G6 also ranked first:

- G6: 40/40
- G3: 30/40
- G4: 27/40

Interpretation:

G6 wins not only because of link mechanics, but because it preserves one bottleneck, grounds the mechanism locally, absorbs feedback selectively, controls branch drift, and ends with a testable research direction.

Key run:

- `model_runs/aligned_g3_g4_g6_20260519_144241/`

## How To Read The Evidence

For each concrete run, read in this order:

1. `RUN_MANIFEST.md`
2. `rounds/`
3. `audits/*LINK_AUDIT.md`
4. `blind_evaluation_packet/` or `idea_blind_evaluation_packet/`
5. `evaluations/blind_evaluation*.md`
6. `evaluations/post_eval_unsealed_summary*.md`

The blind-evaluation packet is what the evaluator saw before condition labels were unsealed. The post-evaluation summary maps anonymous cases back to graph conditions.
