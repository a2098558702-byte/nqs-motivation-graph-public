# Round 1 (Unit 906)

selected_path_label: autoregressive_symmetry_aware_pruning
selected_link_ids: I0021;I0022;I0023;I0026;I0027;I0031;I0012
selected_item_ids: HPM117.problem.anqs_symmetry_sampling;HPM117.problem.postselection_waste;HPM117.method.symmetry_aware_pruning;HPM117.result.chemical_accuracy_speedup;HPM117.limitation.dus_sample_loss;OPW085.method.reverse_sampling_order;APW060.method.physical_priors_constraints
selected_paper_ids: NQSC117;NQSC085;NQSC060

internal_link_step_table:

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C1 | 1 | HPM117.paper | I0021 | HPM117.problem.anqs_symmetry_sampling | forward | Pins down the core bottleneck for this branch: vanilla autoregressive sampling does not naturally respect quantum-number symmetries during generation, so “symmetry compliance during sampling” is a first-class constraint problem (not just a post-hoc projection detail). |
| C2 | 1 | HPM117.paper | I0022 | HPM117.problem.postselection_waste | forward | Establishes the cost of the naive workaround (postselection) as wasted compute, motivating online constraint handling rather than generate-then-reject. |
| C3 | 1 | HPM117.paper | I0023 | HPM117.method.symmetry_aware_pruning | forward | Grounds the concrete mechanism: prune infeasible partial assignments on-the-fly to make sampling symmetry-aware (i.e., enforce constraints during the autoregressive traversal). |
| C4 | 1 | HPM117.paper | I0026 | HPM117.result.chemical_accuracy_speedup | forward | Provides evidence that symmetry-aware sampling/pruning is not merely aesthetic: it can retain chemical-accuracy while producing large speedups, so improving the sampling path can translate into end-to-end gains. |
| C5 | 1 | HPM117.paper | I0027 | HPM117.limitation.dus_sample_loss | forward | Adds an internal failure mode that the Round 0 idea understated: aggressive pruning can lead to “no samples” events and stall optimization, so any extension must explicitly manage sample-loss risk. |
| C6 | 1 | OPW085.paper | I0031 | OPW085.method.reverse_sampling_order | forward | Supports the second lever in the Round 0 proposal: generation order matters in practice, and can be chosen to exploit problem structure (here: an ordering informed by the molecular encoding / Jordan-Wigner structure). This makes “learned ordering / policy” a plausible add-on to pruning. |
| C7 | 1 | APW060.method.physical_priors_constraints | I0012 | APW060.problem.qc_nonlocal_sample_complexity | forward | Re-emphasizes that “baking in” physical constraints is used as a practical response to nonlocality/sample complexity, but it is an architectural commitment. This keeps the motivation for an online feasibility filter (pruning) that can enforce constraints without hard-wiring too much bias into the ansatz itself. |

what_feedback_changed:
Feedback suggests the main pain points around autoregressive NQS are not only symmetry feasibility but also (a) convergence difficulty in strong-interaction regimes and (b) unique-sample/critical-regime limitations. That pushes this branch to be more explicit about optimization stability and “effective sample yield” as primary metrics, and to treat sampling-direction/order as a control variable that can cause outright failures in some settings.

what_feedback_did_not_change:
Feedback does not undermine the core Round 0 framing that symmetry-unaware autoregressive sampling wastes compute and that online constraint enforcement is a meaningful intervention point. It also does not remove the motivation for controlling sampling order/policy; if anything, it reinforces that sampling direction/order can be consequential.

mechanism_learned_from_internal_links:
Within the carried-forward paper (NQSC117), symmetry-aware sampling is framed as a tree traversal problem where unphysical partial assignments can be detected with a polynomial-time “physicality” check and pruned online (I0023). This directly targets the compute waste of postselection (I0022) and is positioned as enabling chemical-accuracy results with large speedups (I0026). However, the same internal record flags a key risk: some pruning strategies can yield “no samples” more often for larger systems, stalling optimization (I0027). Therefore, the mechanism is not “pruning is always good,” but “pruning shifts the sampler’s support dynamically; controlling the traversal/order and/or fallback behavior is necessary to maintain nonzero sample yield.”

revised_idea:
Keep the Round 0 idea (symmetry-aware pruning + policy-controlled sampling), but narrow it to a specific, testable contribution: a *sample-yield–aware* pruning policy for autoregressive NQS. The policy’s job is not just “reduce backtracking,” but “avoid empty-leaf / no-sample episodes” under symmetry-aware pruning.

Concretely:
1) Use the existing symmetry-aware pruning feasibility check as a hard constraint filter over partial assignments (prune infeasible subtrees online).
2) Add a small auxiliary controller that selects the next variable/block ordering (and optionally a conservative fallback ordering) to maximize expected feasible-continuation mass, subject to maintaining exactness (pruning only removes provably infeasible branches).
3) Optimize the controller on a proxy objective that penalizes “no sample produced” events and high prune rates, while keeping the base wavefunction model unchanged.

updated_path_claims:
C1. Autoregressive sampling has difficulty incorporating quantum-number symmetries directly, making symmetry-compliant generation a core bottleneck rather than a minor detail. (I0021)

C2. Postselection is compute-wasteful, so enforcing symmetry constraints online is the right target for efficiency. (I0022)

C3. Symmetry-aware pruning provides an explicit online mechanism to enforce feasibility during sampling by pruning unphysical partial assignments. (I0023)

C4. Symmetry-aware sampling/pruning can preserve chemical accuracy while producing large speedups, so improving the sampling path can yield substantive end-to-end improvements. (I0026)

C5. A central practical risk is sample loss (“no samples”) under pruning, especially at larger scales; therefore, any extension should explicitly measure and mitigate sample-yield collapse. (I0027)

C6. Sampling order is a meaningful control knob in autoregressive NQS (reverse order informed by encoding structure is one example), motivating a learned/optimized ordering policy as a natural companion to pruning. (I0031)

next_test:
On a symmetry-constrained benchmark where pruning is nontrivial (e.g., fixed particle number and spin projection sector), compare samplers with identical base autoregressive model capacity:
1) Plain autoregressive sampling (no pruning).
2) Symmetry-aware pruning with a fixed naive order.
3) Symmetry-aware pruning with a fixed “structure-informed” order (e.g., a hand-designed reverse order where applicable).
4) Symmetry-aware pruning + learned sample-yield–aware ordering controller.

Primary metrics: (a) fraction of attempts that yield at least one valid sample (“nonempty yield rate”), (b) average pruned-branch count per accepted sample, (c) wall-clock per effective sample, (d) VMC optimization stability (variance and energy progress vs steps).

branch_drift_check:
This remains the same branch as Round 0: online enforcement of physical/symmetry constraints during autoregressive sampling via pruning, augmented by sampling-order control. The revision is a narrowing (from generic “reduce backtracking” to explicitly preventing the internally documented “no samples” failure mode) rather than a topic change.

