# Post-Evaluation Unsealed Summary

Run id: `aligned_g3_g4_g6_20260519_144241`

This summary was written after the blind evaluator output was complete.

## Mapping

| anonymous_case_id | sealed_unit | condition |
|---|---|---|
| case_001 | unit_795 | G3 clean_candidate_context |
| case_002 | unit_156 | G4 strict_plus_clean_candidate_context |
| case_003 | unit_906 | G6 adaptive_candidate_to_internal |

## Mechanical Audit

| condition | round0 valid/parsed | round1 valid/parsed | round2 valid/parsed | continuity breaks |
|---|---:|---:|---:|---:|
| G3 clean_candidate_context | 1/1 | 2/2 | 4/4 | 4 total |
| G4 strict_plus_clean_candidate_context | 1/9 | 0/0 | 5/8 | 13 total |
| G6 adaptive_candidate_to_internal | 3/3 | 7/7 | 10/10 | 0 total |

## Blind Evaluation Result After Unsealing

The blind evaluator ranked:

1. case_003 -> G6 adaptive_candidate_to_internal.
2. case_001 -> G3 clean_candidate_context.
3. case_002 -> G4 strict_plus_clean_candidate_context.

G6 received score 5 on every rubric metric:

- idea-count alignment;
- goal preservation;
- branch drift control;
- link-id validity and endpoint fidelity;
- path continuity;
- mechanism grounding;
- feedback absorption;
- conclusion dependence;
- testability.

The evaluator described G6 as the strongest aligned trajectory because it starts with one concrete branch, narrows it with internal evidence, then scope-extends the same branch using throughput/local-energy constraints. The final proposal remained path-dependent and testable.

G3 was mechanically valid but qualitatively less continuous: it preserved a broad principle but shifted domains and mechanisms across rounds.

G4 was mechanistically rich but over-expanded into an umbrella program, and its link audit showed substantial mechanical issues.

## Interpretation Boundary

This aligned run supports the staged G6 design hypothesis under a single seed: candidate-context links work well as branch navigation, and selective strict internal unlock works well for mechanism grounding. This should be replicated across seeds before making stable condition-effect claims.
