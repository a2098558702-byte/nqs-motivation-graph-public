# Blind Evaluation Using Original Idea/Trajectory-Quality Rubric

Evaluator: gpt-5.5, reasoning effort xhigh  
Evaluation basis: only the anonymized rubric and anonymized case trajectory files in the blind evaluation packet.

No hidden condition mappings are inferred or used. Cases are evaluated as anonymous research trajectories.

## Score Summary

| anonymous_case_id | goal preservation | feedback absorption selectivity | evidence-path faithfulness | edge-condition sensitivity | branch-local update | mechanism specificity | testability | drift control | total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| case_001 | 4 | 4 | 3 | 4 | 3 | 4 | 4 | 4 | 30 |
| case_002 | 3 | 3 | 4 | 4 | 2 | 4 | 4 | 3 | 27 |
| case_003 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 40 |

## case_001

anonymous_case_id: case_001

Metric scores:

| metric | score |
|---|---:|
| Goal preservation | 4 |
| Feedback absorption selectivity | 4 |
| Evidence-path faithfulness | 3 |
| Edge-condition sensitivity | 4 |
| Branch-local update | 3 |
| Mechanism specificity | 4 |
| Testability | 4 |
| Drift control | 4 |

Qualitative labels:

- method-lineage / scaling
- benchmark adjudication
- integrated research program

Short evidence-grounded rationale:

This trajectory preserves a recognizable bottleneck across all three rounds: a single scalar objective can look healthy while another important axis of model quality, physical reliability, or operational feasibility degrades. Round 0 expresses this in mixed-state reconstruction, where energy-like criteria may miss infidelity or observable degradation. Round 1 translates the same concern into fermionic NQS model selection across architecture and regime shifts. Round 2 lands in large-scale NQS training, where energy can mask sampling instability, local-energy bottlenecks, or KV-cache and memory pressure.

The strongest feature is the stable abstract problem statement plus increasingly concrete final diagnostics. The Round 2 formulation is materially specific: sampling/coverage measures, local-energy kernel profiling, KV-cache pressure, OOM risk, throughput collapse, and comparisons against single-metric policies. The test path is plausible and aligned with the final claim.

The main weakness is that the branch moves across substantially different domains: mixed-state tomography, attention/backflow-style fermionic NQS, and HPC-scale NQS training. The trajectory controls this drift by repeatedly naming what survives, but the update is not fully branch-local. Round 1 is also more inferential than the other rounds: attention/backflow links support an architectural neighborhood, but only indirectly support the need for multi-metric stopping or compression rules. The final round is better grounded because the resource diagnostics map directly onto the scaling bottlenecks it names.

Suspected trajectory role, without guessing hidden condition names:

This appears to be a portable-bottleneck trajectory: it carries the idea "single-objective success is brittle" across changing evidence neighborhoods and turns it into a scaling-aware training and capacity-control protocol.

Uncertainty notes:

The score would be higher if the middle round had more direct support for the multi-metric failure mode rather than mainly supporting the architectural setting. The final direction is coherent and testable, but some continuity depends on accepting the bottleneck at a high level rather than preserving the original mixed-state tomography formulation.

## case_002

anonymous_case_id: case_002

Metric scores:

| metric | score |
|---|---:|
| Goal preservation | 3 |
| Feedback absorption selectivity | 3 |
| Evidence-path faithfulness | 4 |
| Edge-condition sensitivity | 4 |
| Branch-local update | 2 |
| Mechanism specificity | 4 |
| Testability | 4 |
| Drift control | 3 |

Qualitative labels:

- integrated research program
- method-lineage / scaling
- physical diagnostic / tension
- benchmark adjudication

Short evidence-grounded rationale:

This trajectory begins with a focused Round 0 idea: compression-aware mixed-state tomography should use multi-observable guardrails and energy/infidelity scaling diagnostics. Round 1 rebases the same broad principle into budget-aware ANQS, adding unique-sample control, local-energy surrogates, prefix-tree evaluation, curriculum/ramping, and physicality checks. Round 2 further broadens the frame to a budget-aware NQS training-and-validation protocol spanning static large-scale training and dynamic time evolution, including integrator stability under stiffness.

The evidence use is generally faithful at the level of individual claims. Sampling without replacement, local-energy surrogates, prefix-tree methods, ramping, physicality-preserving parameterization, HPC scalability barriers, cache optimization, and explicit/implicit integrator behavior are each used in ways that match the visible node content. The final direction also shows good edge-condition sensitivity: static runs are treated differently from dynamic runs, and stiffness is not collapsed into a generic "more metrics" recommendation.

The weakness is selectivity and branch locality. Compared with case_001, this trajectory absorbs more feedback as program expansion. By Round 2, the final idea is a broad robustness-guardrail program covering throughput, sampling budgets, surrogate approximations, cache management, and time-integration stability. That program is meaningful, but it is less clearly a branch-local revision of the original mixed-state compression/tomography idea. It risks becoming "resource-aware NQS should validate many failure modes" rather than a sharply preserved research line.

Mechanism specificity remains fairly strong because the trajectory names real mechanisms and diagnostics rather than staying at slogan level. Testability is also solid: it proposes repeatability under sampling budgets, variance-like diagnostics, timestep/integrator checks, breakdown indicators, and static/dynamic comparisons. Still, the final test plan is more of a program scaffold than a compact falsification experiment.

Suspected trajectory role, without guessing hidden condition names:

This appears to be a broad integrative robustness trajectory: it synthesizes multiple resource and stability failure modes into one validation philosophy for NQS under scale.

Uncertainty notes:

If the intended role is cross-branch synthesis, the breadth is a strength. Under the original idea/trajectory-quality rubric, however, the same breadth lowers branch-local update and drift-control scores because the final direction has moved far from the specific Round 0 compression-aware mixed-state tomography bottleneck.

## case_003

anonymous_case_id: case_003

Metric scores:

| metric | score |
|---|---:|
| Goal preservation | 5 |
| Feedback absorption selectivity | 5 |
| Evidence-path faithfulness | 5 |
| Edge-condition sensitivity | 5 |
| Branch-local update | 5 |
| Mechanism specificity | 5 |
| Testability | 5 |
| Drift control | 5 |

Qualitative labels:

- node-local synthesis
- paper-internal argument logic
- candidate-lineage trajectory
- method-lineage / scaling
- benchmark adjudication

Short evidence-grounded rationale:

This is the strongest trajectory. Round 0 identifies a concrete local branch: symmetry-aware pruning for autoregressive NQS, motivated by physical priors/constraints, reverse sampling order, and alternative sampling directions. The proposed mechanism is already specific: a feasibility filter over partial assignments plus a learned ordering or pruning policy that reduces backtracking while preserving exact sampling semantics.

Round 1 absorbs feedback with high selectivity. It does not reset the idea or chase a new theme. Instead, it narrows the mechanism around an internally surfaced failure mode: pruning can produce "no sample" events and stall optimization. The revision turns the policy from a generic backtracking reducer into a sample-yield-aware controller. It also uses sampling order as a well-supported control knob rather than adding unrelated components.

Round 2 keeps the same branch and adds systems pressure in a controlled way. The final direction remains a symmetry-pruned autoregressive sampler, but now the controller is yield- and batch-efficiency-aware. This is a branch-local update because the added constraints are directly tied to the same sampler's downstream role in large-batch local-energy evaluation and end-to-end VMC throughput. The trajectory distinguishes logical pruning gains from actual optimization wall-clock gains, which is an important mechanism-level refinement.

The mechanism is concrete throughout: hard feasibility filter, provably infeasible partial-assignment pruning, ordering/controller over a constrained menu of candidate orderings, nonempty yield rate, late-failure penalty, batch divergence proxy, and local-energy throughput. The final test is unusually well aligned with the idea: a sampler-only symmetry stress phase followed by an end-to-end VMC throughput phase. Metrics are realistic and diagnostic, including yield collapse, prune counts, late failure, batch divergence, effective samples per second, variance, and energy progress.

Suspected trajectory role, without guessing hidden condition names:

This appears to be a focused candidate-lineage refinement: a local candidate idea is repeatedly sharpened using internal failure modes until it becomes a systems-aware but still mechanism-specific sampler proposal.

Uncertainty notes:

The main technical risk is that a learned or adaptive ordering controller may be difficult to optimize while preserving exactness and avoiding batch divergence. The trajectory explicitly recognizes that risk, so it does not materially reduce the evaluation score.

## Cross-Case Comparison

case_003 is the clear top trajectory under the original idea/trajectory-quality rubric. It preserves the same bottleneck, updates locally, absorbs feedback selectively, and ends with a concrete, falsifiable mechanism. Its strongest quality is that every new round tightens the same research object rather than merely broadening the theme.

case_001 is second. It maintains a coherent high-level bottleneck and reaches a useful final scaling-aware protocol, but it relies on a portable abstraction across changing domains. The final idea is strong, yet the trajectory is less branch-local and the middle round's evidence is only indirectly tied to the claimed multi-metric decision rule.

case_002 is third. It is evidence-aware and scientifically plausible, but it becomes a broad integrated robustness program. That breadth makes it interesting as a research agenda, but weaker as a preserved three-round trajectory: the final static-plus-dynamic guardrail framework is farther from the initial compression-aware mixed-state tomography idea.

Overall ranking for anonymized trajectory quality:

1. case_003
2. case_001
3. case_002

