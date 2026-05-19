# case_002_trajectory

## Round 0

### round0_link_step_table

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| path0_claim1 | 1 | DTO063.paper | L0080 | DTO063.limitation.observable_degradation | forward | Establishes that compressing/pruning an RBM in tomography can preserve some objectives (e.g., energy) while degrading physically meaningful observables (magnetization/correlations). |
| path0_claim1 | 2 | DTO063.limitation.observable_degradation | L0082 | DTO063.design_principle.monitor_observables | forward | Turns the degradation observation into an actionable design principle: evaluate multiple observables, not just a single metric. |
| path0_claim1 | 3 | DTO063.design_principle.monitor_observables | L0012 | DTO110.evaluation.energy_infidelity_scaling | forward | Connects that design principle to a mixed-state reconstruction setting where multiple metrics (energy vs infidelity-related behavior) are explicitly compared/scaled. |
| path0_claim2 | 1 | DTO110.paper | L0091 | DTO110.limitation.nonconvex_optimization | forward | Grounds an assumed bottleneck: mixed-state neural reconstruction is nonconvex and can be hard to optimize reliably. |
| path0_claim2 | 2 | DTO110.paper | L0090 | DTO110.evaluation.energy_infidelity_scaling | forward | Establishes a concrete evaluation surface (energy and infidelity scaling behavior) that could be used to detect optimization pathologies. |
| path0_claim3 | 1 | DTO015.paper | L0064 | DTO015.method.rbm_density_matrix | forward | Introduces an explicit parameterization for mixed/open-system objects (density matrices) with built-in Hermiticity/PSD. |
| path0_claim3 | 2 | DTO015.method.rbm_density_matrix | L0011 | DTO041.method.spin_bibase_rbm | forward | Connects density-matrix RBM approaches to a related mapping approach for representing density/eigenmatrix problems with RBMs. |
| path0_claim3 | 3 | DTO041.paper | L0076 | DTO041.method.spin_bibase_rbm | forward | Anchors the method in its originating work (Liouvillian-gap estimation) to avoid treating it as a free-floating technique. |
| path0_claim3 | 4 | DTO041.paper | L0078 | DTO041.limitation.xyz_slow | forward | Adds a concrete failure mode (slow convergence for XYZ due to non-orthogonal decay modes), motivating robustness diagnostics and/or method tweaks. |

### round0_path_claims

1. **path0_claim1 (compression diagnostics transfer):** In neural quantum state tomography, pruning/compression can silently damage observables even when energy looks stable; therefore, mixed-state reconstruction should be evaluated with multiple observables/metrics, and scaling-style diagnostics (energy vs infidelity-like metrics) are a plausible operationalization. (Links: L0080, L0082, L0012)
2. **path0_claim2 (optimization bottleneck + measurable signals):** Mixed-state neural reconstruction inherits a nonconvex optimization bottleneck, but the same work also frames measurable scaling/evaluation endpoints (energy and infidelity-related behavior) that can be used to detect when optimization is failing or misleading. (Links: L0091, L0090)
3. **path0_claim3 (open-system representation + known slowdown):** RBM density-matrix parameterizations and spin bi-base mappings provide concrete NQS-style representations for open-system/mixed-state objects, and there are known convergence slowdowns in certain models (XYZ), so any new training/compression strategy should be stress-tested against those hard regimes. (Links: L0064, L0011, L0076, L0078)

### idea_title
Multi-metric early-warning diagnostics for mixed/open-system neural reconstructions under nonconvex training and compression

### assumed_bottleneck
Mixed-state/open-system NQS reconstructions are **nonconvex** and can appear successful under a single objective (e.g., energy) while **silently degrading** other physically relevant observables or stability properties, especially after compression/pruning.

### research_idea
Build a training and compression protocol for mixed/open-system neural reconstructions (RBM density-matrix style or spin bi-base mapping style) that bakes in an **early-warning diagnostic suite**:

- Track a small, fixed panel of observables/metrics throughout training and pruning, not just the primary loss.
- Use a simple “scaling check” protocol (vary sample budget / measurement budget / training steps) to detect regimes where energy improves but other metrics stall or regress.
- In stress-test benchmarks (e.g., dissipative XYZ-like hard cases), use these diagnostics to choose between: (a) stopping/pruning earlier, (b) reweighting objectives, or (c) modifying the optimizer schedule to avoid misleading minima.

### why_the_idea_depends_on_the_paths
The proposed direction is only motivated if two link-connected claims hold simultaneously:

- Compression/pruning can hide degradation in observables (not just worsen the loss), so multi-metric monitoring is necessary (path0_claim1).
- Mixed-state reconstruction has nonconvex optimization risk, so diagnostics are not a nice-to-have; they are required to know whether “success” is real (path0_claim2).
- Open-system/mixed-state NQS representations exist and have identified slow regimes, providing a concrete place to test whether diagnostics actually prevent false confidence (path0_claim3).

### minimal_test
On a small mixed-state benchmark already present in the items (finite-temperature TFIM / depolarized LiH setting from DTO110 context), run:

1. Baseline training with the standard objective.
2. Apply a lightweight pruning/compression pass.
3. Compare two evaluation policies:
   - “single-metric”: monitor only energy-like objective.
   - “multi-metric”: monitor energy + at least one additional observable proxy and the infidelity-related scaling endpoint described in DTO110’s evaluation node.

Success criterion: multi-metric policy flags degradation (or prevents it by changing stopping/pruning decisions) in cases where single-metric policy would declare success.

### risk_or_limitation
Even if multi-metric monitoring detects problems, it may not prescribe an unambiguous fix (nonconvexity may still dominate). There is also a risk that added diagnostics increase evaluation cost, and the chosen metric panel might not generalize across model classes unless carefully selected.

## Round 1

### round1_link_delta_table

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| path1_claim3 | 1 | DTO015.method.rbm_density_matrix | A0001 | DTO134.method.nqs_dqme_dissipatons | forward | Extends the Round 0 “RBM density matrix” representation direction from (primarily) Markovian/open-system settings to a concrete non-Markovian dissipaton-augmented DQME formulation encoded with NQS. |
| path1_claim4 | 1 | OPW150.method.hubbard_ramping | A0071 | OPW150.problem.strong_interaction_convergence | forward | Adds a physics-motivated training-schedule intervention (parameter ramping) as an explicit response to a convergence bottleneck, suggesting a general pattern: change the training path, not just the ansatz. |

### what_update_changed
The update adds two relevant “interventions” that make the Round 0 idea more actionable:

1. A direct link (A0001) connecting an RBM density-matrix method node (DTO015) to a non-Markovian open-dynamics method node (DTO134), meaning the mixed/open-system setting is not just conceptual; there is an NQS-encoded non-Markovian target where the diagnostics/compression story could matter.
2. A direct link (A0071) tying a convergence bottleneck in correlated-electron autoregressive NQS (OPW150.problem.strong_interaction_convergence) to a proposed cure (OPW150.method.hubbard_ramping), strengthening the case that “training path design” is a first-class knob alongside multi-metric evaluation.

### what_update_did_not_change
The central bottleneck hypothesis remains: nonconvex training and compression can produce misleading “success” under narrow metrics, so an early-warning multi-metric diagnostic suite is still the core research direction.

### revised_idea
Refine the Round 0 direction into a two-part protocol:

1. **Diagnostics:** multi-metric monitoring throughout training and pruning (energy-like objective plus at least one observable proxy plus an infidelity-style/global metric when available).
2. **Interventions when diagnostics trigger:** explicitly vary the *training trajectory* (e.g., physics-motivated parameter ramping schedules) before changing model class, to test whether failures are due to stiff/ill-conditioned optimization paths rather than pure expressivity limits.

This revision targets two domains suggested by the update:
- non-Markovian open dynamics encoded with NQS (DTO134 via A0001)
- strong-coupling correlated-electron autoregressive training (OPW150 via A0071)

### updated_path_claims

1. **path0_claim1 (still valid):** pruning can damage observables while energy seems stable; therefore, multi-metric monitoring is required, and scaling-style endpoints provide an operationalization. (Links: L0080, L0082, L0012)
2. **path0_claim2 (still valid):** nonconvex optimization is an inherent bottleneck; evaluation endpoints exist to detect misleading optimization outcomes. (Links: L0091, L0090)
3. **path1_claim3 (strengthened and broadened):** RBM density-matrix representations connect into a concrete non-Markovian NQS dynamics method family (DTO134), providing a higher-stakes testbed where physicality and memory effects make “false confidence” more likely. (New link: A0001; plus Round 0 links L0064, L0011)
4. **path1_claim4 (new):** convergence issues can be attacked by changing the training path (Hubbard ramping) rather than only the architecture, suggesting a principled response when diagnostics detect failures. (New link: A0071)

### next_test
Pilot “diagnostics + intervention” in the simplest setting supported by links/items:

1. Start from the DTO110-style mixed-state reconstruction evaluation setup (energy + infidelity-related scaling endpoint).
2. Add a small, explicit “training-trajectory” intervention inspired by OPW150 (parameter ramping of an effective control parameter) and test whether it reduces cases where energy improves but other metrics regress, especially after pruning/compression.

If that works, port the same monitoring+intervention protocol to an open-dynamics NQS setting suggested by DTO134 (non-Markovian memory as an additional stressor).

## Round 2

### round2_link_delta_table

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| path2_claim5 | 1 | DTO063.design_principle.monitor_observables | B0045 | DTO201.evaluation.fidelity_susceptibility | forward | Upgrades “monitor multiple observables” into a concrete *global* diagnostic construct (fidelity susceptibility, plus local/global metrics) designed to detect critical behavior and sensitivity, aligning directly with the multi-metric early-warning thesis. |
| path2_claim6 | 1 | CSSA145.method.local_energy_surrogate | B0003 | CSSA170.method.energy_parallelism | forward | Connects local-energy compute bottlenecks to a concrete HPC intervention (multi-level energy parallelism), tightening the story that diagnostics/interventions must be feasible at scale. |
| path2_claim7 | 1 | NQSC199.method.geoneb | B0067 | NQSC199.evaluation.energy_angular_variance | forward | Provides an example where “energy alone” is not the only lens: landscape/path analysis uses additional variances, reinforcing that multi-metric monitoring can reveal structure missed by energy minimization. |

### final_research_direction
Develop a **multi-metric, scale-feasible reliability protocol** for neural quantum state reconstructions and dynamics (mixed/open systems and correlated electrons) that:

1. Uses **global sensitivity diagnostics** (e.g., fidelity-susceptibility-style measures and local/global metric panels) in addition to energy-like objectives, motivated by linked evidence that single-metric success can mask failures.
2. Couples those diagnostics to **explicit interventions** on the training trajectory (ramping/schedules) and on compute feasibility (energy/sampling parallelism concepts) so the protocol remains usable as system sizes grow.

### trajectory_summary
Round 0 established the core claim: compression and nonconvex training can create misleading success unless multiple observables/metrics are tracked (DTO063 -> DTO110), and open-system RBM representations provide concrete testbeds (DTO015/DTO041).

Round 1 strengthened the direction by adding (a) a non-Markovian NQS open-dynamics target reachable from RBM density-matrix representations (DTO015 -> DTO134), and (b) a demonstrated “training path” intervention for convergence issues (OPW150 ramping).

Round 2 made the diagnostic suite sharper and more principled by linking “monitor observables” to a global sensitivity diagnostic (fidelity susceptibility) and by adding evidence that scalability bottlenecks require pragmatic, compute-aware interventions.

### which_bottleneck_survived
The bottleneck that survives all rounds is: **single-objective optimization (especially energy-only) is not a reliable success signal under nonconvex training and/or compression**, and this unreliability becomes more severe in hard regimes (memory effects, strong coupling, stiff dynamics, and scale).

### which_path_was_strengthened_or_rejected
Strengthened:
- The “multi-metric monitoring” path is strengthened by B0045, which connects multi-observable monitoring to fidelity-susceptibility-style global diagnostics (path2_claim5).
- The “open-system testbed” path is strengthened by A0001, which provides a direct bridge to non-Markovian NQS dynamics (path1_claim3).

Rejected/limited:
- No link evidence in these rounds directly connects the pruning/monitoring story to a specific *best* intervention beyond “change the training path”; therefore, the proposal stays at the level of a protocol and evaluation plan rather than claiming a specific universally effective fix.

### what_would_be_measured_first
First measurement is a **multi-metric panel over training and pruning time**:

- energy-like objective
- at least one physically meaningful observable proxy (magnetization/correlations where applicable)
- a global diagnostic when available (fidelity susceptibility / related global fidelity or Renyi-style quantities as suggested by DTO201 evaluation node)

### failure_mode_to_watch
“False confidence”: energy improves (or stays stable) while observables or global sensitivity diagnostics degrade, especially after pruning/compression or when entering hard regimes (strong coupling, non-Markovian memory growth, or stiff dynamics). This is the specific failure mode the protocol is meant to detect early.
