# unit_795 trajectory

## Round 0

### round0_link_step_table

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C1 | 1 | APW034.method.rnn_wavefunction_autoregressive | L0006 | CSS045.problem.autoregressive_symmetry_tradeoff | forward | Establishes a concrete bottleneck: exact-sampling autoregressive NQS make symmetry implementation difficult. |
| C1 | 2 | CSS045.problem.autoregressive_symmetry_tradeoff | L0006 | APW034.method.rnn_wavefunction_autoregressive | reverse | Keeps the claim grounded in the core autoregressive method node rather than drifting to a disconnected critique. |
| C1 | 3 | APW034.method.rnn_wavefunction_autoregressive | L0013 | HPM083.method.2d_crnn_symmetry | forward | Shows that symmetry-aware autoregressive constructions exist in practice (U(1) and lattice symmetries in 2D). |
| C2 | 1 | HPM026.future.alternative_sampling_deeper_networks | L0017 | HPM117.method.symmetry_aware_pruning | forward | Connects the stated need for alternative sampling/deeper networks to an explicit constraint-enforcement mechanism (pruning). |
| C2 | 2 | APW060.method.physical_priors_constraints | L0020 | HPM117.method.symmetry_aware_pruning | forward | Supports using hard physical constraints within an autoregressive ansatz via pruning unphysical branches. |
| C2 | 3 | OPW085.method.reverse_sampling_order | L0021 | HPM117.method.symmetry_aware_pruning | forward | Adds that sampling-order design choices are part of the same constraint-aware pruning theme. |
| C3 | 1 | CSSA024.method.ferminet | L0004 | CSSA025.method.paulinetsjb | forward | Anchors a determinant/backflow fermionic NQS lineage from FermiNet toward PauliNet-style constructions. |
| C3 | 2 | CSSA025.method.paulinetsjb | L0003 | CSSA051.problem.efficiency_tuning | forward | Establishes the compute/accuracy tradeoff pressure: smaller/traditional ansatzes are cheaper but notably worse, motivating efficiency tuning. |

### round0_path_claims

- C1: Autoregressive NQS exact sampling introduces a symmetry-implementation bottleneck, but symmetry-aware autoregressive architectures (e.g., 2D complex RNN with U(1)/lattice symmetries) demonstrate feasible templates for constraint-preserving sampling.
- C2: Constraint satisfaction can be made explicit in autoregressive NQS by pruning unphysical/symmetry-violating subtrees (polynomial checks), and this connects naturally to choices like sampling order and hard-coded physical priors.
- C3: In determinant/backflow fermionic NQS (FermiNet/PauliNet line), a key bottleneck is efficiency/size tuning under a compute-vs-accuracy tradeoff, suggesting research should target systematic efficiency improvements that preserve accuracy.

### idea_title
Constraint-Preserving Autoregressive NQS via Pruning + Physics-Informed Sampling

### assumed_bottleneck
Autoregressive NQS are attractive for exact sampling, but enforcing symmetries/physical constraints (and doing so efficiently at scale) is a practical bottleneck; naive training/sampling can drift into symmetry breaking or waste effort exploring irrelevant Hilbert-space regions.

### research_idea
Develop a constraint-preserving autoregressive NQS workflow that combines:

1. Explicit constraint enforcement during sampling using symmetry/physicality pruning (polynomial-time checks) to prevent generating forbidden configurations.
2. Physics-informed sampling order (or other structural choices) to reduce branching into low-value regions.
3. A minimal evaluation protocol that checks not only variational energy but also symmetry indicators / conserved quantum numbers to detect “looks good in energy, wrong in structure” failure.

The immediate objective is not a new universal ansatz, but a reproducible recipe for making autoregressive NQS respect constraints while retaining the practical advantage of exact sampling.

### why_the_idea_depends_on_the_paths

- C1 motivates *why* this is needed: exact-sampling autoregressive models make symmetry implementation problematic, so constraint handling must be designed rather than assumed.
- C2 provides a concrete mechanism: pruning unphysical/symmetry-violating branches gives a direct way to enforce constraints during generation/sampling.
- C3 keeps the idea honest about practicality: even in high-performing fermionic NQS families, compute/efficiency tuning is a central pressure; constraint enforcement must be efficient enough to be worth it.

### minimal_test
On a small benchmark where symmetries are well-defined (e.g., lattice model with U(1) and translation/lattice symmetries):

- Train an autoregressive NQS baseline.
- Train a version with symmetry/physicality pruning active during sampling.

Measure:

- Constraint violation rate (should drop to ~0 with pruning).
- Energy and variance (ensure pruning does not trivially degrade optimization).
- Sample efficiency proxy (unique valid samples obtained per unit compute).

### risk_or_limitation
Pruning/constraint checks may introduce overhead or bias the effective sampling distribution, potentially worsening optimization if the pruning is too strict or mismatched to the ansatz capacity.

## Round 1

(Revision after reading `update_a_items.csv` and `update_a_links.csv`.)

### round1_link_delta_table

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C3 | 3 | CSSA024.paper | A0002 | CSSA025.paper | forward | Adds an auditable link-level statement that PauliNet is backflow-based like FermiNet but incorporates cusp/Jastrow structure, refining the “lineage” context for fermionic efficiency tuning. |
| C4 | 1 | DTO015.method.rbm_density_matrix | A0001 | DTO134.method.nqs_dqme_dissipatons | forward | Extends the constraint/physicality theme from mixed-state RBM physicality to a newer non-Markovian open-system NQS construction, showing constraint preservation generalizes beyond pure states. |

### what_update_changed

- The update adds higher-level review-style connective tissue for fermionic backflow NQS (FermiNet/PauliNet) and clarifies architectural ingredients (cusp conditions, Jastrow factor). This helps sharpen what “efficiency tuning” must preserve (physics priors, not only raw parameter count).
- It also introduces a new, concrete non-Markovian open-system NQS method tied to RBM density-matrix physicality, reinforcing that “physicality constraints” are a recurring, cross-domain requirement (not unique to ground-state wavefunctions).

### what_update_did_not_change

- The core Round 0 bottleneck still stands: autoregressive exact sampling makes symmetry incorporation nontrivial, motivating explicit constraint handling.
- The Round 0 mechanism (symmetry/physicality pruning) remains the most direct, link-supported lever for constraint-preserving sampling in an autoregressive setting.

### revised_idea
Keep the Round 0 idea, but broaden it from “symmetry only” to “constraint stacks”:

- Treat constraints as a stack: (a) hard physicality (positivity/normalization where relevant), (b) conserved quantum numbers / symmetries, and (c) physics priors (e.g., cusp-like structure, reference-state structure).
- Use pruning as the enforcement substrate where possible, and validate constraints with multiple metrics, not energy alone.

### updated_path_claims

- C1: unchanged (autoreg symmetry tradeoff; existence of symmetry-aware autoreg constructions).
- C2: unchanged (polynomial pruning + physical priors + sampling-order design).
- C3: strengthened by adding the paper-level linkage that PauliNet shares backflow foundations with additional physically motivated components.
- C4 (new): physicality constraints in neural density-matrix RBMs connect forward to newer non-Markovian NQS dynamics representations, supporting the generality of “constraint-first” design.

### next_test
Add a “constraint stack” ablation:

- Baseline autoregressive.
- Autoregressive + symmetry pruning.
- Autoregressive + symmetry pruning + an extra physics prior (chosen per benchmark, e.g., basis/reference guidance or simple cusp-inspired inductive bias if applicable).

Track constraint metrics, sample efficiency (unique valid samples), and optimization stability.

## Round 2

(Revision after reading `update_b_items.csv` and `update_b_links.csv`.)

### round2_link_delta_table

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C5 | 1 | CSSA145.method.sampling_without_replacement | B0004 | CSSA170.method.sampling_parallelism | forward | Updates the trajectory with a concrete scalable sampling method: controlling unique samples and managing memory/parallelism at scale. |
| C5 | 2 | CSSA145.method.local_energy_surrogate | B0003 | CSSA170.method.energy_parallelism | forward | Adds that local-energy evaluation is a bottleneck and can be attacked with multi-level parallelism, tying constraint-aware sampling to end-to-end training cost. |
| C5 | 3 | CSSA145.method.gpu_compression | B0002 | CSSA170.method.cache_optimization | forward | Adds the transformer memory/cache barrier and a concrete cache-centric remedy (pooling/recompute/lazy expansion). |

### final_research_direction
Build “constraint-preserving, compute-aware autoregressive NQS” as an end-to-end package:

- Front end: constraint stack (symmetries/physicality/priors) enforced during sampling via pruning and sampling-order structure.
- Back end: scalable training infrastructure focused on the real bottlenecks (unique-sample growth, local-energy evaluation throughput, and transformer KV-cache memory).

The key deliverable is a pipeline where constraint satisfaction is guaranteed by construction, and the compute/memory costs are explicitly managed so the method remains usable at larger scales.

### trajectory_summary

- Round 0 identified and linked the symmetry/constraint bottleneck in autoregressive NQS and pointed to pruning as a concrete enforcement mechanism.
- Round 1 generalized the constraint story across domains (pure-state symmetries and mixed/open-system physicality) and refined fermionic lineage considerations.
- Round 2 grounded the practicality question with explicit scalable sampling/energy/cache strategies, turning the idea from “constraint correctness” into “constraint correctness plus scalability”.

### which_bottleneck_survived
The bottleneck that survived all rounds: it is not enough for an NQS to have expressive power; constraint satisfaction (symmetry/physicality) and compute scalability (sampling, local energy, memory/caching) jointly dominate whether the approach works in practice.

### which_path_was_strengthened_or_rejected

- Strengthened: the constraint-first path (C1/C2) was strengthened by Round 2’s evidence that sampling and memory explode at scale; constraint enforcement must be integrated with scalable sampling rather than bolted on.
- Strengthened: the “efficiency tuning” theme (C3) is reinforced by the explicit identification of sampling/local-energy/cache barriers at large scale.
- Not rejected: no Round 0 path was contradicted by later link evidence, but the emphasis shifted from “symmetry alone” to “constraints plus scaling”.

### what_would_be_measured_first
First measurements would be:

- Constraint violation rate under sampling (symmetry/physicality checks), and how it scales with system size.
- Unique valid sample growth vs wall-clock and memory.
- Local-energy evaluation throughput (time per step) and its scaling under parallelism.

### failure_mode_to_watch
A key failure mode: the pipeline achieves low energy while silently violating constraints or producing unreliable observables, especially when aggressive sampling/parallelism/caching changes the effective training distribution or optimization landscape.
