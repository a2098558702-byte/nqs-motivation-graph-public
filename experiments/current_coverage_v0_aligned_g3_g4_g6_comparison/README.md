# Current Coverage V0 Aligned G3/G4/G6 Comparison

This experiment compares the strongest non-adaptive graph variants against the adaptive G6 design under a more controlled three-round setup.

## Question

When idea count and round structure are aligned, does adaptive candidate-to-internal graph control still outperform static edge schemas?

## Compared Conditions

- G3: clean candidate-context edges.
- G4: strict plus clean candidate-context edges.
- G6: adaptive candidate-to-internal staged unlock.

## Included Run

- `model_runs/aligned_g3_g4_g6_20260519_144241/`

## Main Finding

Blind evaluation ranked:

1. G6 adaptive candidate-to-internal.
2. G3 clean candidate-context.
3. G4 strict plus clean candidate-context.

Under the original idea-quality rubric, G6 also ranked first:

- G6: 40/40.
- G3: 30/40.
- G4: 27/40.

## Interpretation

G6 did not win only because of link mechanics. The evaluator judged it strongest because it preserved one bottleneck, grounded the mechanism in branch-local evidence, absorbed feedback selectively, avoided branch drift, and ended with a testable proposal.

## What To Read

1. `model_runs/aligned_g3_g4_g6_20260519_144241/RUN_MANIFEST.md`
2. `model_runs/aligned_g3_g4_g6_20260519_144241/audits/ALIGNED_LINK_AUDIT.md`
3. `model_runs/aligned_g3_g4_g6_20260519_144241/evaluations/blind_evaluation_gpt55_xhigh.md`
4. `model_runs/aligned_g3_g4_g6_20260519_144241/evaluations/blind_evaluation_original_idea_rubric_gpt55_xhigh.md`
5. `model_runs/aligned_g3_g4_g6_20260519_144241/evaluations/post_eval_unsealed_summary.md`
