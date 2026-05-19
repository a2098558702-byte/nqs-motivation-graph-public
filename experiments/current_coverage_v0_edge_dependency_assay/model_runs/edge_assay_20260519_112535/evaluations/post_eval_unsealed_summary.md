# Post-Evaluation Unsealed Summary

Run id: `edge_assay_20260519_112535`

This summary was written after the blind evaluator output was complete.

## Mapping

| anonymous_case_id | sealed_unit | condition |
|---|---|---|
| case_001 | unit_118 | G1 nodes_only |
| case_002 | unit_156 | G4 strict_plus_clean_candidate_context |
| case_003 | unit_432 | G2 strict_paper_internal |
| case_004 | unit_608 | G5 paper_citation_only |
| case_005 | unit_795 | G3 clean_candidate_context |

## Mechanical Audit

| condition | parsed link steps | valid link steps | invalid link steps | continuity breaks | future-round violations | insufficient-link mentions |
|---|---:|---:|---:|---:|---:|---:|
| G1 nodes_only | 0 | 0 | 0 | 0 | 0 | 7 |
| G4 strict_plus_clean_candidate_context | 14 | 13 | 1 | 3 | 0 | 0 |
| G2 strict_paper_internal | 11 | 11 | 0 | 7 | 0 | 0 |
| G5 paper_citation_only | 6 | 6 | 0 | 0 | 0 | 2 |
| G3 clean_candidate_context | 13 | 13 | 0 | 5 | 0 | 0 |

## Blind Evaluation Result After Unsealing

The blind evaluator identified case_002 and case_005 as the strongest edge-dependent trajectories overall.

After unsealing, these correspond to:

- case_002 -> G4 strict_plus_clean_candidate_context
- case_005 -> G3 clean_candidate_context

The evaluator treated case_003 as rich and technically concrete but penalized its path-continuity breaks.

After unsealing:

- case_003 -> G2 strict_paper_internal

The evaluator treated case_004 as mechanically clean but qualitatively weaker as an edge-dependency demonstration because citation-style links did not strongly carry the substantive claims.

After unsealing:

- case_004 -> G5 paper_citation_only

The evaluator treated case_001 as an honest node-local fallback baseline with no usable link paths and therefore low primary edge-dependency scores.

After unsealing:

- case_001 -> G1 nodes_only

## Interpretation Boundary

This assay shows that the edge-dependent task successfully makes `nodes_only` score low on the primary relation-path metrics. It does not by itself prove that any one edge schema is globally better. The run is one stochastic sample and should be replicated across seeds before estimating stable condition effects.
