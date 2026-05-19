# Unit 156 — Round 2

## round2_link_delta_table

| claim_id | delta_type | round1_basis | round2_basis | rationale |
|---|---|---|---|---|
| C1 | replace_path_support | Round 1 grounded “budget-aware guardrails under resource constraints” on nodes/links that are not present in this Round 2 packet. | Re-anchor the same single idea on (i) demonstrated large-scale NQS scalability bottlenecks and system-level optimizations (sampling / local energy / transformer cache) and (ii) dynamics-specific instability evidence showing that a seemingly plausible objective/integration choice can silently fail without stability guardrails. | The Round 2 packet contains direct evidence about (a) compute+memory bottlenecks and HPC optimizations for large-scale molecular NQS and (b) stiff-regime failures of explicit TDVP time integration; together they support the same “do not trust a single proxy; enforce robustness guardrails under budgets” trajectory without introducing a new independent idea. |

## final_research_direction

Develop a **budget-aware NQS training-and-validation protocol** where **throughput optimizations (sampling parallelism, local-energy parallelism, cache management, and/or surrogate approximations)** are treated as necessary enablers, but **model-quality decisions are made using explicit robustness guardrails** that catch “looks fine under the main metric, fails elsewhere” behavior.

Concretely, the protocol makes two commitments:

1. **Static (ground-state / VMC-style) runs:** treat large-system scalability as a first-class constraint, using evidenced parallelism and memory-stability techniques to reach regimes where failures actually appear; then evaluate with guardrails that are sensitive to instability (repeatability across sampling budgets; variance-like diagnostics; and checks that optimizations did not merely improve wall-clock while leaving accuracy fragile).
2. **Dynamic runs (time evolution):** treat **integrator stability** as a guardrail, not an implementation detail; do not accept explicit integration just because it is cheaper or seems to track observables in easy regimes. Use implicit/adaptive schemes when stiffness is expected, and measure breakdown risk directly.

This is one idea: **resource-aware NQS needs multi-metric robustness guardrails so that “efficient” does not become “silently wrong.”**

## trajectory_summary

The trajectory tightens around a single bottleneck: **as NQS scales up (larger systems, longer times, harder regimes), primary objectives and cheap choices can become misleading**.

- For large-scale molecular NQS, the evidence emphasizes that training is bottlenecked by sampling, local-energy evaluation, and transformer KV-cache memory, motivating system-level optimizations to make scaling feasible. These optimizations are enablers, but they also increase the risk that progress is judged by a narrow proxy (e.g., speed or an energy-like metric) while stability/robustness degrades.
- For NQS dynamics, explicit TDVP time integration can **break down in strongly quenched regimes**, with the breakdown attributed to **stiffness**; implicit/adaptive integrators can recover the dynamics. This is the dynamic analog of the same pattern: a cheaper/default choice can fail catastrophically unless stability guardrails are enforced.

So the final direction is: **scale with the right HPC/algorithmic optimizations, but decide success using robustness diagnostics that specifically target known silent-failure modes (memory/sampling-driven fragility; integrator stiffness breakdown).**

## which_bottleneck_survived

The surviving bottleneck is **“single-metric / single-choice success criteria fail under scale.”**

In static training, the bottleneck shows up as **sampling + local-energy + cache constraints** that push practitioners toward aggressive optimizations; without guardrails, this can make it too easy to declare success based on speedups or an energy proxy. In dynamics, the bottleneck shows up as **stiffness-driven instability** where explicit integration fails even when some observables may look superficially plausible.

## which_path_was_strengthened_or_rejected

Strengthened path: **“HPC scalability enablers + robustness guardrails”** rather than “pick one best optimization.”

Rejected path: **“optimize the main objective faster and assume correctness follows.”** The explicit TDVP instability result makes this rejection concrete: a method can be computationally convenient yet unreliable in the regimes we most care about.

## what_would_be_measured_first

Measure **robustness under the budget axis you are actually constraining**, before chasing additional speed:

1. **Repeatability / stability** of the target quantities across controlled changes in sampling budget (for static training) and across timestep/integrator settings (for dynamics).
2. A **variance-like diagnostic** (e.g., local-energy variance or another stability proxy already computed in the run) to detect fragility that energy alone can miss.
3. For dynamics specifically: a **breakdown indicator** tied to stiffness (e.g., divergence of variational parameters, loss spikes, or failure to converge within an adaptive scheme), rather than relying only on a small set of observables.

## failure_mode_to_watch

Two tightly related failure modes (same underlying issue, different surface form):

1. **Throughput-driven false confidence:** scaling optimizations (parallelism, caching, surrogate evaluation) improve wall-clock and even appear to stabilize the primary loss, but the solution is fragile, non-reproducible across sampling budgets, or collapses on harder systems.
2. **Integrator-driven silent error in dynamics:** explicit integration produces plausible-looking short-time observables but fails in stiff/strong-quench regimes; the failure can be misattributed to noise or expressivity when the core issue is stiffness.

## branch_drift_check

No branch drift: Round 2 keeps exactly one trajectory and preserves the same core hypothesis carried from Round 0/1 at a higher level:

“Under resource constraints, do not trust a single proxy or convenience choice; enforce multi-metric robustness guardrails, and validate stability in the regimes where known failure modes occur.”

The only change is the **evidence base**: Round 2 re-grounds the idea in (a) large-scale molecular NQS HPC bottlenecks/optimizations and (b) explicit time-integration instability evidence in NQS dynamics.

## idea_count_alignment_note

Exactly one final trajectory is provided for Round 2, and it is a continuation/refinement of the same single idea from prior rounds (not a new independent idea).

## Link-Step Table (C1)

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C1 | 1 | CSSA170.paper | B0005 | CSSA170.problem.scalability_barriers | supports | Establishes that large-scale molecular NQS is blocked by prohibitive compute/memory costs, motivating budget-aware protocols rather than “train as usual.” |
| C1 | 2 | CSSA170.paper | B0006 | CSSA170.method.sampling_parallelism | supports | Grounds a concrete scalability enabler (sampling parallelism) that expands feasible regime but also changes what “robustness under sampling budgets” should mean. |
| C1 | 3 | CSSA170.paper | B0007 | CSSA170.method.energy_parallelism | supports | Grounds that local-energy evaluation is a key cost center addressed by multi-level parallelism; guardrails must account for estimator/compute choices. |
| C1 | 4 | CSSA170.paper | B0008 | CSSA170.method.cache_optimization | supports | Shows transformer KV-cache memory is a first-class scaling constraint; “efficient” training depends on memory management choices that can shift failure modes. |
| C1 | 5 | DTO178.paper | B0029 | DTO178.problem.strong_quench_instability | supports | Brings in a directly evidenced “silent failure unless guarded” dynamic: strong-quench NQS dynamics can break down under explicit integration. |
| C1 | 6 | DTO178.paper | B0033 | DTO178.result.breakdown_delta | supports | Makes the instability concrete (explicit integration failure in a strong-quench regime), justifying stability checks rather than trusting the default integrator. |
| C1 | 7 | DTO178.paper | B0034 | DTO178.result.implicit_adaptive_recovers | supports | Supports the guardrail prescription: implicit/adaptive integration can recover dynamics, so “robustness across integrators/timesteps” is a meaningful first measurement. |
| C1 | 8 | DTO178.paper | B0035 | DTO178.interpretation.stiffness_not_noise | supports | Identifies stiffness as the likely cause, sharpening the failure-mode model and what a budget-aware protocol must diagnose early. |

