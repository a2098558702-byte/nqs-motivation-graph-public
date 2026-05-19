# unit_608 — three-round trajectory (sealed edge-dependency assay)

## Round 0

### round0_link_step_table

insufficient_link_support

Node-local fallback only (no auditable multi-step support path is possible from the Round 0 link set, which is dominated by cross-paper citation edges and does not link the within-paper bottlenecks/benchmarks/claims in `items.csv`).

### round0_path_claims

- claim_id: R0C1
  claim: A recurring bottleneck across NQS/VMC-style approaches for strongly correlated and frustrated systems is *optimization difficulty* (e.g., becoming worse as representational capacity grows), and a practical research direction is to design training curricula/regularizers that stabilize optimization while preserving or improving representational power.
  support: node_local_fallback_only
  primary_items:
    - FWP004.limitation.optimization_large_alpha
    - FWP021.limitation.su2_bias

- claim_id: R0C2
  claim: For frustrated spin models, architectural/ansatz choices that better match correlation structure (e.g., correlation-enhanced RBM variants; PEPS+CNN; lattice-convolutional networks) can improve energy/accuracy, suggesting that *structure-aware inductive bias* is a lever to reduce symmetry-breaking and improve performance.
  support: node_local_fallback_only
  primary_items:
    - FWP047.result.lower_energies_with_correlators
    - FWP043.result.competitive_sota
    - FWP078.result.lcn_outperforms_gnn_frustrated
    - FWP021.limitation.su2_bias

- claim_id: R0C3
  claim: When compressing or pruning neural reconstructions, energy can be an insensitive metric; multiple observables should be monitored because degradation can hide in correlations/magnetization even if energy appears stable.
  support: node_local_fallback_only
  primary_items:
    - DTO063.limitation.observable_degradation
    - DTO063.design_principle.monitor_observables

### idea_title

Curriculum- and bias-controlled NQS training for frustrated systems: stabilize optimization while preserving symmetries and correlation structure.

### assumed_bottleneck

Optimization becomes unstable/hard as model expressivity increases (e.g., larger RBM hidden density) and/or when inductive bias fights the target symmetries (e.g., SU(2) breaking in frustrated regimes), causing training to get stuck or converge to symmetry-broken solutions.

### research_idea

Develop and test a training protocol for variational NQS on frustrated spin models that combines:

1. A capacity schedule (grow correlator strength or effective hidden density over training), paired with constraints/penalties that explicitly track symmetry restoration (e.g., SU(2) diagnostics) rather than only energy.
2. An ansatz choice that is correlation-structure-aware (e.g., correlation-enhanced correlators or lattice-convolutional style inductive biases) to reduce the burden on optimization.

The focus is not on inventing a new architecture from scratch; it is on *training + diagnostics* that prevent the known failure modes (optimization difficulty and symmetry breaking) while leveraging architectures that already show energy gains on frustrated settings.

### why_the_idea_depends_on_the_paths

insufficient_link_support

Because Round 0 links do not connect the concrete limitation/result items to each other via auditable `link_id` paths, the dependency is asserted only via node-local evidence: optimization difficulty at larger capacity (FWP004), symmetry bias (FWP021), and correlation/architecture improvements (FWP047/FWP043/FWP078) jointly motivate focusing on stabilization + inductive bias.

### minimal_test

On a single frustrated benchmark (e.g., square-lattice J1-J2 at J2/J1 = 0.5):

- Train a baseline RBM-correlator or comparable NQS without curriculum/constraints.
- Train the same ansatz with a capacity schedule and an explicit symmetry-monitoring loss/selection rule.
- Evaluate energy plus at least two non-energy observables sensitive to symmetry/correlations (e.g., spin structure factor, correlation functions), consistent with the “monitor multiple observables” warning from tomography/pruning work.

### risk_or_limitation

- If the ansatz class intrinsically favors symmetry-broken representations in the frustrated regime, training protocol tweaks may not fully fix it (could require symmetry-enforcing parameterization rather than a penalty).
- Improvements may be benchmark- and metric-dependent (energy improves but correlations/symmetry metrics do not), echoing the risk that energy is not a sufficient quality proxy.

## Round 1

### round1_link_delta_table

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| R1C1 | 1 | OPW150.paper | A0052 | NQSC127.paper.01 | forward | Connects a concrete recent autoregressive Hubbard NQS study to a 2024 review node, enabling an auditable “optimization-bottleneck + mitigation” trajectory anchored by a review context. |
| R1C2 | 1 | APW153.paper | A0064 | OPW150.paper | forward | Links physics-informed transformer work to autoregressive Hubbard work, supporting a path from “basis/interpretability + sampling efficiency” to “convergence issues + ramping curriculum”. |
| R1C3 | 1 | NQSC127.paper.01 | A0003 | FWP004.paper | forward | Anchors the older RBM strongly-correlated paper within the review’s citation neighborhood, letting us relate classic RBM optimization bottlenecks to updated 2024 context (still via citation edges). |

Notes:
- These links are citation-style edges (paper-to-paper), but unlike Round 0 they allow at least a minimal auditable chain across *the specific new items* (OPW150, APW153, NQSC127, and the older RBM baseline).

### what_update_changed

- Added concrete 2024 observations about autoregressive NQS in Hubbard settings, including a named optimization challenge at strong interaction and a physics-motivated “ramping” training method that improves convergence (OPW150.*).
- Added a 2024 paper arguing that basis choice and reference-state structure can improve sampling efficiency and interpretability for transformer-based autoregressive states (APW153.*).
- Added a 2024 review node (NQSC127.*) that frames broad bottlenecks (e.g., scaling issues, QGT inverse bottleneck in dynamics) and provides citation edges that let us build at least short auditable paths.

### what_update_did_not_change

- The Round 0 core bottleneck hypothesis still holds: optimization/convergence is a central limiting factor as expressivity increases or regimes become harder (strong coupling, frustration).
- The need to evaluate beyond energy alone remains relevant; the update did not remove the risk that a single metric can hide degradation.

### revised_idea

Shift from “capacity schedule for frustrated spins” (Round 0) to a broader, more auditable training-direction:

Combine (a) physics-motivated curriculum schedules (e.g., Hamiltonian parameter ramping) with (b) physics-informed reference-basis/autoregressive correction factorization, targeting regimes where autoregressive/transformer NQS have convergence trouble (strong coupling / critical regimes).

In practice: use a reference-state basis (HF- or strong-coupling motivated) and train an autoregressive transformer to learn *corrections*, while also applying a Hamiltonian-parameter ramp (e.g., ramp tunneling) to keep optimization in a well-conditioned region early in training.

### updated_path_claims

- claim_id: R1C1
  claim: Strong-interaction regimes can make autoregressive NQS convergence difficult, and a physics-motivated ramping of Hamiltonian parameters during training can materially improve convergence (notably in 2D Fermi-Hubbard benchmarks).
  path_support:
    - OPW150.paper ->(A0052)-> NQSC127.paper.01  (contextual anchoring)
  node_support_items:
    - OPW150.problem.strong_interaction_convergence
    - OPW150.method.hubbard_ramping
    - OPW150.result.ramping_improves_fhm

- claim_id: R1C2
  claim: Physics-informed transformer wave functions that sample corrections around an energetically motivated reference basis can improve sampling efficiency and interpretability; this complements curriculum/ramping approaches aimed at convergence.
  path_support:
    - APW153.paper ->(A0064)-> OPW150.paper
  node_support_items:
    - APW153.problem.basis_dependence_interpretability
    - APW153.method.physics_informed_reference_basis
    - APW153.method.transformer_corrections
    - APW153.result.physical_basis_sampling_efficiency

- claim_id: R1C3
  claim: Classic RBM/VMC-style approaches already noted that optimization becomes harder as capacity increases; the 2024 review cites this older work, reinforcing that optimization is a persistent bottleneck rather than a one-off issue.
  path_support:
    - NQSC127.paper.01 ->(A0003)-> FWP004.paper
  node_support_items:
    - FWP004.limitation.optimization_large_alpha

### next_test

Minimal integrated experiment (single Hamiltonian family; two training knobs):

1. Choose a correlated-electron benchmark with a tunable interaction (e.g., Hubbard).
2. Compare four conditions:
   - baseline autoregressive NQS training
   - + Hamiltonian ramping curriculum (tunneling ramp)
   - + physics-informed reference basis (reference-state corrections)
   - + both ramping + reference basis
3. Measure:
   - convergence success rate across seeds (did it converge?)
   - energy and at least one non-energy diagnostic tied to the chosen basis/physics (e.g., occupancy/structure factor) to detect “energy-only” blind spots.

## Round 2

### round2_link_delta_table

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| R2C1 | 1 | CSSA170.paper | B0007 | OPW109.paper | forward | Adds an explicit scalability/HPC-oriented NQS chemistry framework node into the auditable citation graph (even if via citation), supporting the “training is compute/memory limited” angle at scale. |
| R2C2 | 1 | NQSC164.paper | B0001 | HPM011.paper | forward | Connects a 2025 expressivity/theory paper to a known backflow-NQS branch via citation, reinforcing that ansatz expressivity/structure (determinantal vs alternatives) is a parallel axis to optimization curricula. |
| R2C3 | 1 | DTO178.paper | B0020 | DTO031.paper | forward | Brings in a concrete dynamics failure mode (explicit TDVP instability) and links it to prior real-time NQS literature, supporting a refined “bottleneck = stiffness/integrator instability” subcase for dynamics trajectories. |

### final_research_direction

A two-pronged “make it converge and make it scale” program for NQS, grounded in auditable cross-paper link edges:

1. Optimization/convergence: Combine physics-motivated curricula (Hamiltonian parameter ramping) with physics-informed reference-basis factorization for autoregressive transformers in strongly correlated regimes.
2. Systems/dynamics robustness: When moving from ground states to dynamics, treat integrator stiffness/instability as a first-class failure mode (avoid relying on explicit TDVP in strongly quenched regimes without stiffness-aware integrators).
3. Scalability: For ab initio quantum chemistry scale-up, treat sampling + local-energy evaluation + transformer cache as practical bottlenecks and adopt cache- and parallelism-aware implementations to unlock larger systems.

### trajectory_summary

- Round 0 started from within-paper bottlenecks (optimization difficulty at larger capacity; symmetry breaking; energy-vs-observable mismatch) but lacked link-connected auditability.
- Round 1 introduced 2024 autoregressive Hubbard work (convergence issues + ramping remedy) and physics-informed transformer bases, enabling short but auditable link paths through paper-level edges.
- Round 2 added 2025 scale-out chemistry infrastructure and 2025 dynamics instability findings, broadening the direction from “training protocol for one benchmark” to “convergence + stiffness-aware dynamics + HPC scalability”.

### which_bottleneck_survived

Optimization/convergence remains the persistent bottleneck, now sharpened into:

- strong-coupling convergence challenges for autoregressive NQS (OPW150),
- critical-regime unique-state capacity / alpha learning limits for physics-informed transformers (APW153),
- and, for dynamics, stiffness-driven integration breakdowns (DTO178).

### which_path_was_strengthened_or_rejected

- Strengthened: “curriculum/ramping + physics-informed basis” as a convergent training strategy (supported by the APW153 -> OPW150 citation link plus the OPW150 method/result nodes).
- Strengthened: “scalability barriers are concrete engineering constraints” via the addition of the Fugaku-scale framework (CSSA170.*) and its explicit focus on sampling/energy/cache bottlenecks.
- Rejected (as primary in this unit): the Round 0 frustrated-spin symmetry-restoration idea is not rejected as false, but it is deprioritized because the later rounds provide more direct, auditable observations about convergence interventions (ramping; basis choice; cache/parallelism; stiffness-aware integrators).

### what_would_be_measured_first

First measurements should be about *reliability* rather than best-case energy:

- convergence success rate vs interaction strength (how often training succeeds),
- number of unique sampled states (where relevant to physics-informed bases),
- and wall-clock / memory scaling (sampling throughput; local-energy evaluation throughput; KV-cache memory) for chemistry-scale targets.

### failure_mode_to_watch

- “Looks converged in energy but is physically wrong” (hidden observable degradation).
- Autoregressive directionality / sampling-order failures in non-Hermitian or otherwise difficult settings (noted as a limitation in OPW150).
- Dynamics: explicit integration producing unreliable observables under strong quenches due to stiffness (DTO178 framing), even when stochastic noise or regularization is not the core issue.

