# Aligned Three-Round Trajectory

## round0

# Unit 156 — Round 0

## round0_link_step_table

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C1 | 1 | DTO063.design_principle.monitor_observables | L0012 | DTO110.evaluation.energy_infidelity_scaling | supports | Connects a pruning/compression design principle (track multiple observables; energy can be least sensitive) to a later evaluation framing that explicitly compares energy- vs infidelity-related scaling behavior across mixedness. |

## round0_path_claims

- **C1:** For compressed / resource-constrained neural quantum state tomography and mixed-state reconstruction, evaluation and training targets should be multi-metric (not energy-only), because energy can hide degradations in other physical observables; this aligns with later work that evaluates reconstruction via energy/infidelity scaling exponents across mixedness. (Path: `DTO063.design_principle.monitor_observables` --`L0012`--> `DTO110.evaluation.energy_infidelity_scaling`.)

## idea_title

Compression-Aware Mixed-State Tomography With Multi-Observable Guardrails and Scaling Diagnostics

## assumed_bottleneck

When NQS tomography models are pruned/compressed or otherwise capacity-limited, optimization may still drive down an energy-like loss while silently degrading other physically meaningful quantities (magnetization/correlations) and/or worsening fidelity-related behavior, especially as the target state becomes more mixed.

## research_idea

Develop and test a **compression-aware training+evaluation protocol** for neural-network mixed-state reconstruction that:

1. Uses **multi-observable guardrails** during pruning (or other compression/regularization), explicitly tracking a small set of observables (e.g., magnetization and selected two-point correlators) alongside the primary loss.
2. Chooses pruning/early-stopping schedules by optimizing a **Pareto criterion** over (a) energy-like error, (b) observable deviations, and (c) an infidelity proxy (or any available fidelity-related estimate), rather than a single scalar metric.
3. Reports performance in the **scaling-exponent language** (energy and infidelity scaling trends vs sample count / mixedness) to reveal whether compression changes the apparent sample complexity regime.

The core hypothesis is that introducing guardrails plus scaling diagnostics will prevent “energy looks fine” failure modes and produce reconstructions that remain physically reliable across increasing mixedness, even at similar parameter budgets.

## why_the_idea_depends_on_the_paths

The link-supported path grounds two ingredients that need to be combined:

- A **design principle** from pruning/compression in tomography: energy can be the least sensitive quantity, so tracking only energy can miss meaningful degradations (source node: `DTO063.design_principle.monitor_observables`).
- An **evaluation framing** for mixed-state reconstruction that explicitly contrasts **energy vs infidelity scaling exponents** and how they change with mixedness (target node: `DTO110.evaluation.energy_infidelity_scaling`).

The idea is specifically to fuse these: compression decisions should be made with multi-observable guardrails, then validated using scaling diagnostics that can expose hidden regressions that energy-only monitoring would miss.

## minimal_test

Run a small controlled study with two reconstruction settings (one nearer-pure, one more mixed) and compare:

- Baseline: standard training + pruning/regularization using energy-only (or single-metric) selection.
- Proposed: identical model class and budget, but pruning/selection uses multi-observable guardrails; evaluation includes energy- and infidelity-related scaling trends.

Success criteria (minimal): at matched parameter count, the proposed protocol reduces observable deviations (e.g., magnetization/correlations) without worsening energy error, and shows equal-or-better fidelity-related scaling behavior in the more-mixed setting.

## risk_or_limitation

Observable guardrails can be expensive or noisy to estimate, and there may be tension between optimizing observable accuracy and improving fidelity/energy simultaneously; the Pareto selection might become sensitive to which observables are chosen, reducing generality.

## idea_count_alignment_note

Exactly one research idea is provided for Round 0, as required.

## round1

# Unit 156 — Round 1

## round1_link_delta_table

| claim_id | delta_type | round0_basis | round1_basis | rationale |
|---|---|---|---|---|
| C1 | replace_path_support | Round 0 relied on a link/path not present in this Round 1 packet. | Re-anchor the same core idea (multi-metric guardrails under resource constraints) using links about (i) controlling unique samples, (ii) cheaper local-energy estimation, and (iii) known NQS optimization bottlenecks. | The Round 1 evidence batch does not include the Round 0 nodes/links, so the revision keeps the idea but re-bases it on available, directly supported mechanisms and failure modes. |
| C2 | add_path_support | Not present. | Add a curriculum/ramping component as an *optimization stabilizer* for hard regimes, grounded in a physics-motivated ramping method. | Keeps the “guardrails + scaling diagnostics” framing, but now explicitly addresses the optimization bottleneck highlighted in the review and Hubbard ramping result. |
| C3 | add_path_support | Not present. | Add a physicality/constraint check for reduced density objects when using surrogate objectives, grounded in Hermiticity/positivity-preserving parameterizations. | Preserves the “don’t trust a single cheap proxy” spirit by ensuring proxies don’t violate physical constraints. |

## what_update_changed

- Rebased the **supporting graph paths** from a tomography/mixed-state evaluation link (Round 0) to a **resource-constrained ANQS / electronic-structure** setting where the key practical failure mode is: “cheap objective looks good, but overall physics/accuracy doesn’t.”
- Made the “multi-metric guardrails” concrete in terms of **unique-sample control** (sampling without replacement) and **separate cost drivers** (local-energy evaluation), because those are explicitly evidenced in this packet.
- Added an explicit **curriculum/ramping** knob for optimization stability in hard regimes (strong coupling / difficult convergence), rather than treating optimization as a black box.

## what_update_did_not_change

- Still exactly one idea: a **compression/resource-aware protocol** that uses **guardrails beyond a single scalar metric**, and then validates with **scaling-style diagnostics** rather than one-off point estimates.
- Still targets the same core failure mode: “a primary loss/proxy can look fine while other physically relevant quality measures regress,” especially under constrained budgets.

## revised_idea

Build a **budget-aware ANQS training and evaluation protocol** for fermionic / molecular NQS in which *sampling and estimator choices are treated as first-class levers*, and success is judged by multi-metric guardrails rather than energy alone.

Concretely:

1. Treat the number of **unique sampled configurations** as an explicit budget axis and control it with **autoregressive sampling without replacement**. Use this to design *apples-to-apples* comparisons across model sizes and training schedules.
2. When local-energy evaluation dominates cost, incorporate **local-energy surrogates** and/or data structures (e.g., **prefix-tree / trie** organization of sampled determinants) to reduce per-iteration cost, but do not let these proxies become the only target.
3. Run training with a simple **curriculum/ramping schedule** (analogous to physics-motivated parameter ramping) to mitigate known NQS optimization difficulty in hard regimes.
4. Select checkpoints and compression/sampling settings using a **Pareto-style criterion** over:
   - (a) energy or variational-energy proxy,
   - (b) at least one secondary physics-relevant diagnostic (e.g., stability across repeated sampling budgets / unique-state counts), and
   - (c) a robustness indicator tied to optimization stability (e.g., sensitivity to ramp schedule, or stability under SR/minSR vs vanilla gradients if available).

**Hypothesis:** by explicitly controlling unique-sample budgets and separating “cheaper estimation” from “model quality,” we can avoid the common failure where improved *throughput* (or improved energy-like proxies) masks degraded overall accuracy, particularly on hard molecular cases.

## updated_path_claims

### Link-Step Table (C1)

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C1 | 1 | CSSA145.paper | A0021 | CSSA145.method.sampling_without_replacement | supports | Grounds the idea’s “explicit unique-sample budget” control mechanism (sampling without replacement) as a core technical lever. |
| C1 | 2 | CSSA145.paper | A0022 | CSSA145.method.local_energy_surrogate | supports | Shows an explicit, evidenced strategy to reduce the computational cost of local-energy evaluation via a cheaper surrogate objective. |
| C1 | 3 | CSSA145.paper | A0023 | CSSA145.method.prefix_tree | supports | Adds a second, complementary way to reduce local-energy cost by exploiting structure in sampled configurations (trie/prefix-tree). |
| C1 | 4 | CSSA145.paper | A0028 | CSSA145.limitation.c2 | supports | Motivates the guardrail framing: even with increased unique samples (and associated efficiency techniques), some hard cases remain unsolved, so energy/proxy improvements alone are not sufficient. |

**C1 (path claim):** In resource-constrained ANQS for molecular systems, you should (i) control the unique-sample budget explicitly and (ii) separate computational shortcuts (local-energy surrogate; trie-based evaluation) from model-quality decisions, because hard cases can remain inaccurate even when sampling/throughput is improved. (Path: `CSSA145.paper` --`A0021/A0022/A0023/A0028`--> methods+limitation.)

### Link-Step Table (C2)

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C2 | 1 | NQSC127.paper.01 | A0053 | NQSC127.problem.02 | supports | Establishes that optimization is a primary bottleneck for NQS, so stabilizing training is a central design requirement. |
| C2 | 2 | OPW150.paper | A0065 | OPW150.method.hubbard_ramping | supports | Provides an evidenced, physics-motivated curriculum/ramping mechanism during training. |
| C2 | 3 | OPW150.paper | A0067 | OPW150.result.ramping_improves_fhm | supports | Supports the claim that such ramping can materially improve convergence in difficult regimes. |

**C2 (path claim):** Because NQS optimization is a core bottleneck, introducing a curriculum-like **parameter ramping** schedule is a justified ingredient of a budget-aware protocol; ramping has demonstrated convergence improvements in challenging autoregressive NQS training settings. (Path: `NQSC127.paper.01` --`A0053`--> `NQSC127.problem.02`; `OPW150.paper` --`A0065/A0067`--> ramping method+result.)

### Link-Step Table (C3)

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C3 | 1 | DTO134.paper | A0032 | DTO134.method.rbm_rdt_physicality | supports | Grounds the idea’s “guardrails beyond a cheap proxy” principle in an explicit example where parameterization is designed to preserve Hermiticity/positivity. |

**C3 (path claim):** When using cheaper objectives/proxies (e.g., local-energy surrogates) as part of a scaling/efficiency protocol, incorporate **physicality guardrails** (Hermiticity/positivity preservation or analogous constraints) so that efficiency improvements do not drift into unphysical solutions. (Path: `DTO134.paper` --`A0032`--> `DTO134.method.rbm_rdt_physicality`.)

## next_test

A minimal, controlled test that matches the revised evidence:

1. Pick a molecular/electronic-structure benchmark suite that includes at least one “easy” and one “hard” case (the hard case is meant to mirror the packet’s “still hard despite more unique samples” signal).
2. For each case, run ANQS training under a fixed compute budget with a grid over:
   - unique-sample budgets (enabled by sampling without replacement),
   - local-energy evaluation strategy (exact vs surrogate; with/without prefix-tree acceleration),
   - optimization schedule (baseline vs ramping).
3. Compare *at matched wall-clock or matched unique-sample count*:
   - energy/proxy energy,
   - stability across resampling (variance / reproducibility vs unique-sample budget),
   - success/failure rates of optimization (convergence robustness across seeds/schedules).

Pass condition: the guardrailed protocol identifies regimes where energy/proxy looks good but robustness/stability is poor, and selects settings that improve stability on the hard case without sacrificing energy on the easy case.

## branch_drift_check

- Drift risk: Round 0 was framed around mixed-state tomography evaluation; this Round 1 packet does not contain those Round 0 nodes/links, so I cannot preserve the exact same graph path.
- Mitigation: I preserved the **same underlying research idea** (resource-constrained NQS requires multi-metric guardrails and scaling-style diagnostics; don’t trust a single objective/proxy), but re-expressed it in a **molecular ANQS** setting with directly evidenced mechanisms (unique-sample control, cheaper local energy evaluation, optimization stabilization).

## idea_count_alignment_note

Exactly one revised research idea is provided for Round 1, and it is a single revision of the Round 0 idea (not a new, unrelated idea).

## round2

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

