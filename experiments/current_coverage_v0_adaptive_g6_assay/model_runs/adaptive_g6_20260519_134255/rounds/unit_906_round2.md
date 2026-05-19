# Round 2 (Unit 906)

selected_path_label: autoregressive_symmetry_aware_pruning
selected_link_ids: J0015;J0016;J0017;J0020;J0021;J0025;J0030;J0028;J0009;J0012
selected_item_ids: HPM117.problem.anqs_symmetry_sampling;HPM117.problem.postselection_waste;HPM117.method.symmetry_aware_pruning;HPM117.result.chemical_accuracy_speedup;HPM117.limitation.dus_sample_loss;OPW085.method.reverse_sampling_order;OPW085.method.tensor_local_energy_parallel;OPW085.result.weak_scaling_batch;APW060.limitation.local_energy_barrier;APW060.method.physical_priors_constraints
selected_paper_ids: NQSC117;NQSC085;NQSC060

internal_link_step_table:

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C1 | 1 | HPM117.paper | J0015 | HPM117.problem.anqs_symmetry_sampling | forward | Re-anchors the branch bottleneck: in autoregressive NQS, incorporating quantum-number symmetries *during sampling* is intrinsically challenging, so the intervention point is the sampling procedure itself (not only the wavefunction parameterization). |
| C2 | 1 | HPM117.paper | J0016 | HPM117.problem.postselection_waste | forward | Justifies online constraint handling: the naive workaround (postselecting into the right symmetry sector) wastes compute, so any efficiency gain must come from avoiding invalid branches earlier. |
| C3 | 1 | HPM117.paper | J0017 | HPM117.method.symmetry_aware_pruning | forward | Grounds the concrete mechanism: symmetry-aware pruning is an on-the-fly tree-pruning procedure over partial assignments, making feasibility a first-class control-flow element in sampling. |
| C4 | 1 | HPM117.paper | J0020 | HPM117.result.chemical_accuracy_speedup | forward | Shows the mechanism matters end-to-end: pruning-based symmetry-aware sampling can retain chemical accuracy while providing order-of-magnitude speedups, so sampler engineering is not just “overhead reduction.” |
| C5 | 1 | HPM117.paper | J0021 | HPM117.limitation.dus_sample_loss | forward | Forces a narrowing of the idea: some pruning strategies can increase “no sample produced” events (sample-yield collapse), which can stall optimization; preventing empty-yield episodes becomes a primary design goal. |
| C6 | 1 | OPW085.paper | J0025 | OPW085.method.reverse_sampling_order | forward | Supports the “ordering/policy” lever: for molecular encodings, changing the autoregressive variable order (e.g., reversing it) is explicitly used to improve sampling effectiveness, making an ordering controller a plausible companion to pruning. |
| C7 | 1 | OPW085.method.tensor_local_energy_parallel | J0030 | OPW085.problem.local_energy_sampling_scalability | forward | Adds the scaling constraint that interacts with sampling: local-energy evaluation is a bottleneck and is addressed via GPU tensorization/distributed batches; pruning/order changes must be compatible with high-throughput batched execution, not only reduce logical backtracking. |
| C8 | 1 | OPW085.paper | J0028 | OPW085.result.weak_scaling_batch | forward | Reinforces the “batching as a first-class knob” premise: large batches and parallelization can achieve near-optimal weak scaling, suggesting the pruning+ordering extension should be evaluated under large-batch regimes (where yield collapse can be especially expensive). |
| C9 | 1 | APW060.paper | J0009 | APW060.limitation.local_energy_barrier | forward | Connects to an older internal scaling diagnosis: after improving sampling, local-energy evaluation becomes the remaining dominant expense, so sampler-side improvements should be judged by their downstream impact on local-energy throughput and total optimization wall-clock. |
| C10 | 1 | APW060.method.physical_priors_constraints | J0012 | APW060.problem.qc_nonlocal_sample_complexity | forward | Preserves the original motivation: hard-coding physical priors/constraints is used to cope with nonlocality/sample complexity, but it is an architectural commitment; pruning provides a way to enforce feasibility online without permanently baking in all structure into the ansatz. |

what_feedback_changed:
Feedback adds stronger pressure that “sampling improvements” must be *systems-aware* at large scale: large molecular NQS training is described as hitting not only sampling and local-energy scalability barriers but also transformer-cache/memory barriers, and the claimed wins include memory-stable sampling at extremely large sample counts and high parallel efficiency on many nodes. This shifts the branch from “controller reduces pruning/backtracking” toward “controller must preserve high-throughput, memory-stable, batched execution,” because a pruning policy that increases control-flow divergence or reduces batch utilization could erase the speedups that large-batch sampling/energy pipelines rely on.

what_feedback_did_not_change:
Feedback does not contradict the core Round 0/1 rationale that online symmetry feasibility enforcement is a meaningful target and that postselection waste motivates pruning-style approaches. It also does not weaken the specific internal limitation already identified in Round 1 (sample-yield collapse / no-sample episodes); if anything, scaling-focused feedback makes that failure mode more costly, reinforcing the need to make yield a primary metric.

mechanism_learned_from_internal_links:
Across the carried branch papers, “sampling” is not a monolithic operation:
1) In NQSC117, symmetry handling is posed as an autoregressive *tree traversal* where infeasible partial assignments can be detected and pruned online (J0017), directly targeting the compute waste of postselection (J0016). But the same internal record warns that certain pruning strategies can lead to empty-yield sampling attempts (“produce no samples”) and stall larger-system optimization (J0021), implying that feasibility filtering must be coupled to a yield-preserving traversal strategy.
2) In NQSC085 and NQSC060, scaling is jointly limited by sampling and local-energy evaluation: NQSC085 explicitly frames local-energy + sampling as scalability issues and introduces GPU/distributed local-energy parallelization (J0030), while NQSC060 states that local-energy evaluation becomes the remaining dominant expense once sampling is improved (J0009). This implies the pruning/ordering mechanism should be optimized for *end-to-end throughput* (samples delivered into local-energy batches), not just “fewer pruned branches.”

revised_idea:
Keep the Round 1 narrowing (sample-yield–aware pruning + ordering control), and scope-extend it in a constrained way to respect the internal scaling constraints:

Build a **yield- and batch-efficiency–aware symmetry-pruned autoregressive sampler** for molecular/electronic-structure NQS.

Core components:
1) **Hard feasibility filter (unchanged):** use symmetry-aware pruning as a correctness mechanism (prune only provably infeasible partial assignments; do not rely on postselection).
2) **Ordering/controller (refined):** learn or heuristically optimize a generation order (possibly blockwise) that maximizes *expected feasible-continuation mass* while explicitly penalizing:
   - empty-yield probability (no-sample episodes),
   - control-flow divergence across a batch (to preserve GPU/parallel efficiency),
   - and “late failure” (pruning only after many steps), which wastes compute similarly to postselection.
3) **Batched execution contract:** constrain the controller to a small discrete set of candidate orderings (e.g., a few structure-informed permutations such as the reverse order in NQSC085) and select among them per-iteration or per-region of parameter space, rather than per-sample arbitrary branching. The goal is to reduce per-sample divergence while still steering away from yield collapse.

updated_path_claims:
C1. In autoregressive NQS, directly incorporating quantum-number symmetries during sampling is a core challenge, motivating sampling-procedure interventions. (J0015)

C2. Postselection wastes compute, so online feasibility enforcement is the right efficiency target. (J0016)

C3. Symmetry-aware pruning is a concrete mechanism for online feasibility enforcement via on-the-fly pruning of infeasible partial assignments. (J0017)

C4. Symmetry-aware pruning can preserve chemical accuracy while delivering large speedups, so the sampling mechanism can drive end-to-end gains. (J0020)

C5. A key failure mode is “no-sample” (sample-yield collapse) under pruning, especially at larger scales; extensions must explicitly measure and mitigate empty-yield events. (J0021)

C6. Sampling order is a meaningful control knob in molecular autoregressive NQS (e.g., reverse sampling order informed by encoding structure), supporting an ordering/controller add-on to pruning. (J0025)

C7. Local-energy evaluation remains a dominant scaling barrier and is addressed via high-throughput parallelization; therefore, pruning/ordering improvements should be evaluated by their impact on batched sample-to-local-energy throughput, not only logical pruning counts. (J0030; J0009)

C8. Large-batch regimes can achieve near-optimal weak scaling, so pruning/ordering changes should be stress-tested under large batches where batch efficiency and yield collapse matter most. (J0028)

next_test:
Two-phase test that separates correctness/yield from end-to-end throughput.

Phase A (sampler-only, symmetry stress):
Compare under identical base autoregressive model capacity:
1) Plain autoregressive sampling (no pruning).
2) Symmetry-aware pruning with fixed naive order.
3) Symmetry-aware pruning with fixed structure-informed order (e.g., reverse order where applicable).
4) Symmetry-aware pruning + yield-and-batch-efficiency–aware controller (restricted to a small menu of candidate orderings).

Metrics:
- nonempty yield rate (fraction of attempts producing at least one valid sample),
- average pruned-branch count per accepted sample,
- “late failure” rate (fraction of prunes occurring after a large prefix length),
- batch divergence proxy (e.g., variance in per-sample prune counts / steps within a batch).

Phase B (end-to-end VMC throughput):
Plug samplers (2)-(4) into a VMC loop with batched local-energy evaluation. Measure:
- wall-clock per effective optimization step at matched target statistical error,
- local-energy throughput (effective samples/sec into the energy kernel),
- optimization stability (variance and energy vs steps), watching for stalls correlated with empty-yield events.

branch_drift_check:
This remains the same trajectory as Round 0/1: enforce symmetry/physical constraints online during autoregressive sampling via pruning, augmented by sampling-order control. The Round 2 change is a scoped extension driven by internal evidence: explicitly coupling the pruning/ordering objective to (a) preventing sample-yield collapse (already internal to NQSC117) and (b) preserving batched throughput under local-energy scaling constraints (internal to NQSC085/NQSC060), rather than drifting to a new topic.

