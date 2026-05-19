# Post-Evaluation Unsealed Summary: Original Idea Rubric

Run id: `aligned_g3_g4_g6_20260519_144241`

This summary was written after the blind evaluation with the original trajectory-quality rubric was complete.

## Mapping

| anonymous_case_id | condition |
|---|---|
| case_001 | G3 clean_candidate_context |
| case_002 | G4 strict_plus_clean_candidate_context |
| case_003 | G6 adaptive_candidate_to_internal |

## Blind Evaluation Result

The evaluator ranked:

1. case_003 -> G6 adaptive_candidate_to_internal, total 40/40.
2. case_001 -> G3 clean_candidate_context, total 30/40.
3. case_002 -> G4 strict_plus_clean_candidate_context, total 27/40.

## Interpretation

Under the original idea/trajectory-quality rubric, G6 still wins without using the later link-mechanics rubric. The evaluator judged G6 strongest because it preserves one concrete bottleneck, absorbs feedback selectively, grounds the mechanism in internal failure modes, and ends with a falsifiable sampler/throughput test.

G3 was second: it preserves a useful high-level bottleneck, but the concrete evidence branch shifts across rounds.

G4 was third: it contains many plausible mechanisms, but broadens into an umbrella robustness program rather than preserving a compact trajectory.

## Boundary

This evaluation uses existing aligned trajectories and the original current-coverage evaluation rubric. It does not rely on the aligned link audit as a scoring input.
