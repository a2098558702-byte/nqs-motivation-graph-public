# unit_432_trajectory

## Round 0

round0_link_step_table

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
| --- | --- | --- | --- | --- | --- | --- |
| C0P1 | 1 | HPM083.paper | L0105 | HPM083.problem.frustrated_sign_problem | forward | Grounds the motivation: the target regime is dominated by a frustrated/sign-structure difficulty rather than only parameter count. |
| C0P1 | 2 | HPM083.paper | L0106 | HPM083.method.2d_crnn_symmetry | forward | Introduces a concrete architectural lever (complex RNN with symmetry) meant to address that regime. |
| C0P1 | 3 | HPM083.paper | L0107 | HPM083.method.annealing | forward | Adds an optimization/training lever that can be composed with the architecture to stabilize learning. |
| C0P1 | 4 | HPM083.paper | L0109 | HPM083.result.beats_dmrg_triangular | forward | Provides an outcome anchor: this combined approach can reach strong accuracy on a frustrated benchmark. |
| C0P2 | 1 | APW060.paper | L0009 | APW060.limitation.local_energy_barrier | forward | Pins down the compute bottleneck: local-energy evaluation dominates cost in this VMC setting. |
| C0P2 | 2 | APW060.paper | L0007 | APW060.method.physical_priors_constraints | forward | Shows a remedy class (constraints/priors) that can reduce variance/search burden without changing the core objective. |
| C0P2 | 3 | APW060.paper | L0006 | APW060.method.unique_configuration_sampling | forward | Adds a sampling-side lever (unique configurations) that can reduce redundant work and improve effective sample diversity. |
| C0P2 | 4 | APW060.paper | L0008 | APW060.benchmark.molecules_30_spin_orbitals | forward | Ensures the above bottleneck/remedies are evidenced in a nontrivial scale regime (30 spin-orbitals). |
| C0P3 | 1 | DTO063.paper | L0053 | DTO063.benchmark.tfim_pm_qcp | forward | Establishes the compression/pruning setting across distinct TFIM regimes including criticality. |
| C0P3 | 2 | DTO063.paper | L0054 | DTO063.limitation.observable_degradation | forward | States the key failure: pruning may preserve energy while distorting magnetization/correlations. |
| C0P3 | 3 | DTO063.limitation.observable_degradation | L0056 | DTO063.design_principle.monitor_observables | forward | Converts the failure into an actionable design principle (monitor multiple observables). |

round0_path_claims

- C0P1: In frustrated/sign-problem regimes, a symmetry-aware complex RNN combined with an annealing-style training schedule is a plausible path to state-of-the-art accuracy on triangular/square Heisenberg benchmarks, suggesting that the core bottleneck is not only expressivity but trainability under sign structure. Support path: HPM083.paper --(L0105)--> HPM083.problem.frustrated_sign_problem; HPM083.paper --(L0106)--> HPM083.method.2d_crnn_symmetry; HPM083.paper --(L0107)--> HPM083.method.annealing; HPM083.paper --(L0109)--> HPM083.result.beats_dmrg_triangular.
- C0P2: In molecular VMC at moderate scale, local-energy evaluation is a dominant computational expense, and two orthogonal mitigations (physics-motivated constraints/priors and unique-configuration sampling) are already tied to that workflow, motivating research that co-designs sampling and constraints to reduce cost at fixed accuracy. Support path: APW060.paper --(L0009)--> APW060.limitation.local_energy_barrier; APW060.paper --(L0007)--> APW060.method.physical_priors_constraints; APW060.paper --(L0006)--> APW060.method.unique_configuration_sampling; APW060.paper --(L0008)--> APW060.benchmark.molecules_30_spin_orbitals.
- C0P3: Model compression (via pruning) can look successful on energy while silently breaking other physical observables, so any optimization/compression workflow that targets energy alone risks producing misleading “good” states; multi-observable monitoring is a required guardrail. Support path: DTO063.paper --(L0053)--> DTO063.benchmark.tfim_pm_qcp; DTO063.paper --(L0054)--> DTO063.limitation.observable_degradation; DTO063.limitation.observable_degradation --(L0056)--> DTO063.design_principle.monitor_observables.

idea_title

Multi-Objective, Constraint-Aware NQS Training That Tracks Observable Integrity While Reducing Dominant Compute

assumed_bottleneck

Optimization and evaluation loops for neural quantum states can be “misleadingly stable” (energy looks fine) while either (a) training is unstable in sign/frustrated regimes or (b) compute is dominated by local-energy evaluation; the common bottleneck is the absence of an explicit, auditable objective that balances trainability, compute, and observable fidelity.

research_idea

Develop a training-and-evaluation protocol (and small architectural/sampling tweaks) that explicitly:

1. Treats sign/frustration cases as an optimization-stability problem with symmetry constraints (inspired by the HPM083 path), optionally coupled to an annealing schedule to smooth the loss landscape early in training.
2. Treats molecular-scale VMC as a compute-budget problem where local-energy evaluation dominates, so we co-design sampling (unique-configuration sampling) and constraints/priors to reduce redundant evaluations (inspired by APW060).
3. Treats any compression/efficiency knob (pruning, fewer samples, lower precision, fewer MCMC steps) as requiring multi-observable monitoring to prevent energy-only false positives (inspired by DTO063).

Concretely, the unit output would be an “observable integrity dashboard” that is part of the training loop: the loop only accepts an update (or a compression move) if energy improves and a small set of key observables stay within tolerance, with tolerances possibly annealed or adapted by regime.

why_the_idea_depends_on_the_paths

- The HPM083 path motivates that the hard cases are not just about expressivity; they need symmetry-aware modeling and training schedules that stabilize learning under sign/frustrated structure.
- The APW060 path motivates that, in another major application class (molecules), the limiting factor can be dominated by local-energy evaluation, so sampling/constraints are the natural levers for wall-clock.
- The DTO063 path motivates that any “efficiency improvement” that does not track observables risks producing unphysical or qualitatively wrong states even when energy is stable, so multi-objective monitoring is a necessary dependency.

minimal_test

One controlled ablation study in a single domain (pick either a frustrated spin benchmark or a molecular VMC benchmark) where you compare:

- Baseline: optimize energy only, default sampling.
- Variant A: add symmetry/constraint priors (domain-appropriate).
- Variant B: add sampling change aimed at reducing redundant evaluations (e.g., unique-configuration sampling style).
- Variant C: add multi-observable acceptance/early-stopping (energy + 2-3 observables).

Primary metrics: wall-clock to reach a target energy; number of local-energy evaluations; drift in monitored observables; and post-hoc drift in an unmonitored observable (to test whether the dashboard generalizes).

risk_or_limitation

The paths are currently siloed by domain (frustrated spins, molecular VMC, tomography pruning). A unifying protocol may be too generic to help without domain-specific choices of observables/constraints, and “monitor more observables” can increase measurement cost or complicate optimization if observables are noisy.

## Round 1

round1_link_delta_table

| delta_id | change_type | link_id | from_item_id | to_item_id | why_it_matters |
| --- | --- | --- | --- | --- | --- |
| R1D1 | add_strengthen_path | A0018 | CSSA145.paper | CSSA145.method.local_energy_surrogate | Directly targets the Round-0 compute bottleneck (local-energy expense) with a concrete surrogate strategy. |
| R1D2 | add_strengthen_path | A0023 | CSSA145.method.sampling_without_replacement | CSSA145.problem.peaked_hamiltonian | Connects sampling-without-replacement to controlling unique-sample counts, sharpening the “unique configurations” theme from APW060. |
| R1D3 | add_new_angle | A0007 | APW153.paper | APW153.result.physical_basis_sampling_efficiency | Adds a basis/importance-sampling lever: a physics-informed basis can focus sampling on a useful subset of Hilbert space. |
| R1D4 | add_new_angle | A0067 | OPW150.method.hubbard_ramping | OPW150.problem.strong_interaction_convergence | Adds a second, independently evidenced “anneal/ramp parameters during training” knob for convergence in strong-coupling regimes. |

what_update_changed

- The Round-0 “local-energy barrier” path is no longer just a generic bottleneck statement (APW060); update-A provides a specific mitigation toolkit: local-energy surrogates and sampling without replacement aimed at unique-sample control (CSSA145).
- The earlier “training stability under hard physics” idea becomes more concrete: parameter ramping is evidenced as a convergence tool for strong interactions (OPW150), and physics-informed bases provide a principled way to concentrate sampling (APW153).

what_update_did_not_change

- The need for multi-observable monitoring as a guardrail against energy-only false positives remains intact (DTO063), and is arguably even more important once we introduce approximations like surrogates and aggressive sampling control.

revised_idea

Tighten the research direction into a single, auditable protocol for efficiency improvements that must pass an “observable integrity gate,” with three explicit levers:

1. Sampling-control lever: directly control the number of uniquely sampled configurations (unique-configuration sampling; sampling without replacement) to reduce redundant work and improve effective coverage under a fixed budget.
2. Compute-lever: introduce a local-energy surrogate (learned or approximate) that reduces per-sample cost, but only when the integrity gate is satisfied.
3. Optimization-stability lever: use physics-motivated ramps/anneals of Hamiltonian parameters during training to avoid strong-coupling convergence failures, again gated by observables.

updated_path_claims

- C1P1 (strengthened compute path): The “dominant computational expense is local-energy evaluation” bottleneck (APW060) now has direct complementary mitigations: local-energy surrogates (CSSA145) plus explicit unique-sample control via sampling without replacement (CSSA145), suggesting the core engineering target is minimizing redundant/expensive local-energy calls while maintaining observable fidelity.
- C1P2 (basis + sampling efficiency): Physics-informed bases can make autoregressive transformer sampling focus on a small useful subset of Hilbert space (APW153), aligning with the sampling-control lever and giving a principled way to define what “unique and useful” samples mean.
- C1P3 (stability via ramps): Parameter ramping directly addresses strong-interaction convergence issues for autoregressive NQS training (OPW150), reinforcing the Round-0 intuition that “anneal-like” schedules are a first-class optimization primitive in hard regimes.

next_test

On one benchmark (molecular or correlated-electron):

- Compare baseline vs (sampling-control only) vs (sampling-control + local-energy surrogate) vs (sampling-control + surrogate + ramp/anneal).
- Enforce the DTO063-style integrity gate: track energy plus 2-3 observables; declare any run “failed” if observables drift beyond tolerance even when energy improves.
- Report: (i) unique-sample count vs wall-clock, (ii) local-energy evaluations avoided, (iii) observable drift distribution, (iv) convergence robustness across random seeds / interaction strengths.

## Round 2

round2_link_delta_table

| delta_id | change_type | link_id | from_item_id | to_item_id | why_it_matters |
| --- | --- | --- | --- | --- | --- |
| R2D1 | add_scale_validation | B0001 | CSSA170.paper | CSSA170.problem.scalability_barriers | Confirms the same bottlenecks (sampling + local energy + cache/memory) dominate at large molecular scale. |
| R2D2 | add_scale_validation | B0009 | CSSA170.paper | CSSA170.result.memory_sampling | Shows feasible scaling with memory-stable sampling, making “unique-sample budgets + memory” a measurable, first-order engineering object. |
| R2D3 | add_scale_validation | B0010 | CSSA170.paper | CSSA170.result.energy_speedup | Provides concrete evidence that local-energy acceleration (SIMD/OpenMP) yields large speedups, reinforcing local-energy as the lever. |
| R2D4 | add_landscape_risk_control | B0063 | NQSC199.method.geoneb | NQSC199.evaluation.energy_angular_variance | Supports extending the integrity gate beyond observables to include variance-style diagnostics during optimization (energy variance, angular variance). |

final_research_direction

Build an “Integrity-Gated Efficiency Stack” for NQS VMC at scale:

- A sampling layer that explicitly budgets unique configurations and memory (sampling without replacement / memory-stable sampling parallelism).
- A local-energy layer that accelerates or approximates local-energy evaluation (parallelism, vectorization, and optionally surrogates) under explicit acceptance criteria.
- An optimization layer that uses ramps/anneals to stabilize convergence in hard regimes.
- A monitoring layer (integrity gate) that couples energy with a small, curated set of observables plus variance-like diagnostics during training.

trajectory_summary

Round 0 established three isolated but compatible claims: (i) hard frustrated regimes benefit from symmetry + schedule levers (HPM083), (ii) local energy dominates compute (APW060), and (iii) energy-only success can hide observable failures (DTO063).  
Round 1 made the efficiency levers concrete (CSSA145 local-energy surrogate; sampling without replacement; APW153 basis-informed sampling; OPW150 ramping).  
Round 2 validated that these concerns and levers persist at very large scale (CSSA170) and that variance-style diagnostics are a plausible additional guardrail for optimization behavior (NQSC199).

which_bottleneck_survived

Local-energy / evaluation cost and sampling memory pressure remain the dominant scalability bottleneck, and “energy-only” optimization remains an unreliable success criterion once we introduce efficiency approximations.

which_path_was_strengthened_or_rejected

- Strengthened: the compute-efficiency path (APW060) is strengthened by concrete mitigation mechanisms (CSSA145) and by large-scale validation (CSSA170).
- Strengthened: the training-stability-by-schedule idea (HPM083) is strengthened by an independently evidenced ramping approach (OPW150).
- Not rejected, but narrowed: the broad cross-domain unification claim is kept as a protocol-level unifier (integrity-gated efficiency) rather than implying one architecture works everywhere.

what_would_be_measured_first

Unique-sample count and local-energy evaluations per unit wall-clock, alongside (a) 2-3 key observables and (b) an energy-variance-like diagnostic during training; these jointly decide whether a speedup is “real” versus an integrity failure.

failure_mode_to_watch

False convergence: apparent energy improvement with degraded physical observables (DTO063-style) or with rising variance/instability indicators (variance diagnostics) when aggressive sampling control, surrogates, or strong ramps are enabled.
