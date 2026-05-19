# case_001 edge-dependency assay trajectory

## Round 0

### round0_link_step_table
insufficient_link_support

(No link steps are available: `links.csv` contains only the header row and no `link_id` entries. Therefore, no auditable multi-step (or even one-step) support paths can be constructed.)

### round0_path_claims
insufficient_link_support

node_local_fallback_only:
- Path construction is not possible in Round 0 due to absence of links. The only available support is item-local observations drawn directly from `items.csv` nodes.

### idea_title
Mitigating optimization and inductive-bias bottlenecks in neural quantum states for frustrated / strongly correlated lattice models by combining correlation-structured ansatzes with training curricula.

### assumed_bottleneck
Nonconvex optimization instability and inductive-bias mismatch (e.g., symmetry breaking) become the practical limiting factor as expressivity/parameter density increases, especially in frustrated regimes.

### research_idea
Design and test a two-part strategy for neural quantum states (NQS) targeting frustrated/strongly correlated lattice Hamiltonians:

1. **Correlation-structured ansatz selection:** Prefer architectures/augmentations that encode physically motivated correlations (e.g., correlator-enhanced RBM variants or hybrid tensor-network + neural components) when benchmarking on frustrated lattices.
2. **Training curriculum & constraints:** Use curriculum-like schedules and explicit symmetry/constraint handling to reduce the tendency of expressive correlators to drift into symmetry-broken or poorly optimized solutions.

Round-0 grounded motivations (item-local):
- Larger RBM hidden density ("alpha") can become increasingly hard to optimize in practice. (FWP004.limitation.optimization_large_alpha)
- In frustrated settings, RBM correlators can break SU(2) symmetry and struggle to recover it. (FWP021.limitation.su2_bias)
- Correlator-enhanced RBM variants can achieve substantially lower energies at fixed parameter count in frustrated benchmarks (triangular Heisenberg). (FWP047.result.lower_energies_with_correlators)
- Hybrid PEPS+CNN can reach competitive ground-state energies on highly frustrated J1-J2. (FWP043.result.competitive_sota)
- Lattice Convolutional Networks can match/improve GNN performance without explicit structure encoding across multiple lattices including frustrated ones. (FWP078.result.lcn_outperforms_gnn_frustrated)

### why_the_idea_depends_on_the_paths
insufficient_link_support

node_local_fallback_only:
- Because there are no links, the dependency cannot be demonstrated as a graph-traversable chain. Instead, the idea is justified by a convergence of item-local observations: optimization difficulty at high capacity (FWP004), symmetry/inductive-bias issues in frustration (FWP021), and evidence that correlation-structured augmentations or hybrids improve energies (FWP047, FWP043) while other architectures handle geometry without hand-crafted encodings (FWP078).

### minimal_test
A minimal empirical test using only the item-local scope suggested by Round 0:

- **System:** One frustrated benchmark already represented in the items, e.g. triangular Heisenberg (FWP047.benchmark.triangular_heisenberg) or square J1-J2 at J2/J1=0.5 (FWP021.benchmark.square_j1j2 / FWP043.benchmark.square_j1j2).
- **Models compared:**
  - Baseline RBM correlator setup.
  - Correlator-enhanced RBM (cRBM-style) at matched parameter counts.
  - Optionally, a hybrid baseline (PEPS+CNN style) if available.
- **Interventions:** Add a simple curriculum schedule (e.g., gradually increase correlator strength/hidden density) and add an SU(2)-symmetry monitoring/regularization strategy.
- **Measurements:** Energy, variance, and at least one symmetry/observable diagnostic (e.g., SU(2) recovery proxy or spin-rotation invariants) to detect the failure mode highlighted in FWP021.

### risk_or_limitation
- Without links, the proposal is not supported by auditable cross-item evidence paths; it is only a synthesis of unlinked observations.
- Correlation-structured ansatzes may reduce energy while still yielding biased observables or hidden symmetry breaking; energy alone can be misleading.
- Training curricula may be fragile and benchmark-dependent; improvements might not transfer across lattices/interaction regimes.

## Round 1

### round1_link_delta_table
insufficient_link_support

(No newly available links: `update_a_links.csv` contains only the header row and no `link_id` entries. Therefore, no link-based deltas can be reported.)

### what_update_changed
Round 1 adds several newer (2024) item-local observations that sharpen and extend the Round-0 bottleneck framing:

- Autoregressive NQS for Hubbard models report that convergence becomes challenging at stronger interactions, and propose a physics-motivated **ramping** of Hamiltonian parameters during training to improve convergence, especially in 2D. (OPW150.problem.strong_interaction_convergence; OPW150.method.hubbard_ramping; OPW150.result.ramping_improves_fhm)
- Physics-informed transformer approaches emphasize **basis dependence** and propose using an energetically motivated reference basis with a transformer learning corrections; they highlight limitations in critical regimes tied to unique sampled states and alpha optimization. (APW153.problem.basis_dependence_interpretability; APW153.method.physics_informed_reference_basis; APW153.limitation.critical_unique_states)
- A 2024 review item (NQSC127) foregrounds scaling bottlenecks in fermionic electronic-structure settings (Hamiltonian term scaling; QGT-inverse bottleneck for real-time t-VMC), which broadens the context from lattice frustration to computational scaling constraints. (NQSC127.problem.03; NQSC127.future_work.01)
- Non-Markovian open-system dynamics with NQS introduces sparsity filtering and hybrid sampling to cut costs, plus notes low-temperature/memory limitations. (DTO134.method.sparse_filter_hybrid_sampling; DTO134.result.sparsity_reduces_cost; DTO134.limitation.low_temp_memory)

### what_update_did_not_change
- The Round-0 core hypothesis remains: optimization and inductive bias are key practical bottlenecks as expressivity grows, especially in hard regimes (frustrated lattices, strong coupling, criticality).
- The lack of links remains unchanged, so the support is still not auditable through graph-connected paths.

### revised_idea
Refine the Round-0 proposal into a more concrete, testable direction:

Adopt **physics-motivated curricula and representations** to stabilize training in hard regimes:

1. **Curriculum via Hamiltonian/parameter ramping:** Use ramping (as in OPW150) to improve convergence in strongly correlated 2D Hubbard-like settings.
2. **Representation via reference-basis + corrective autoregression:** Use physics-informed bases (APW153) so the model focuses on sampling a smaller, relevant subset of Hilbert space; treat critical regimes as a special case requiring increased unique-state capacity and careful alpha learning.
3. **Diagnostics beyond energy:** Incorporate symmetry/observable checks (motivated by SU(2) breaking in FWP021 and general "energy can mislead" concerns in NQS practice) to ensure improvements are not purely variational-energy artifacts.

### updated_path_claims
insufficient_link_support

node_local_fallback_only:
- With no new links, the update is incorporated as additional independent observations supporting the same bottleneck theme: ramping improves convergence (OPW150), physics-informed bases improve sampling efficiency and interpretability but have critical-regime limits (APW153), and broader reviews emphasize scaling/QGT bottlenecks (NQSC127).

### next_test
A focused Round-1 next test consistent with the newly added items:

- **Benchmark:** 2D Fermi-Hubbard model regime where OPW150 reports ramping benefits.
- **Compare:** plain autoregressive NQS training vs. ramped Hamiltonian training.
- **Add-on:** evaluate a basis-informed variant (where feasible) or at least a basis-ordering ablation to probe basis dependence (APW153 framing).
- **Measure:** convergence rate (energy/variance vs steps), stability across seeds, and a proxy for sampling diversity (unique sampled states) to detect the critical/unique-state limitation class in APW153.

## Round 2

### round2_link_delta_table
insufficient_link_support

(No newly available links: `update_b_links.csv` contains only the header row and no `link_id` entries. Therefore, no link-based deltas can be reported.)

### final_research_direction
Build an NQS training and representation pipeline that explicitly targets the dominant practical bottleneck across regimes: **stability and scalability of optimization/sampling under hard physics (strong coupling, frustration, criticality, stiff dynamics) and large system sizes**.

Concretely:

1. **For ground states in strongly correlated electronic structure / Hubbard-like models:** use physics-motivated curricula (e.g., tunneling/interaction ramping) and reference-basis corrective modeling to reduce the effective search space.
2. **For large-scale ab initio quantum chemistry NQS deployments:** integrate HPC-aware sampling and local-energy parallelism plus cache-aware transformer memory strategies as part of the algorithmic design constraints (CSSA170.method.sampling_parallelism; CSSA170.method.energy_parallelism; CSSA170.method.cache_optimization).
3. **For real-time dynamics:** treat integrator stiffness as a first-class risk factor; prefer implicit/adaptive formulations when explicit TDVP breaks down under strong quenches (DTO178.result.breakdown_delta; DTO178.result.implicit_adaptive_recovers), and consider interval/global-loss formulations (DTO175.method.global_interval_loss) to reduce local-step instability.

### trajectory_summary
- Round 0: identified optimization difficulty at high capacity (FWP004) and inductive-bias/symmetry issues in frustrated settings (FWP021) while noting correlator-structured/hybrid models can lower energies (FWP047, FWP043) and some architectures generalize across lattices without explicit structure encoding (FWP078).
- Round 1: strengthened the proposal with explicit curriculum/ramping evidence (OPW150) and basis-informed transformer framing (APW153), broadening to scaling bottlenecks (NQSC127) and cost-control mechanisms in open dynamics (DTO134).
- Round 2: extended the bottleneck to system-scale and dynamics-scale constraints, adding HPC systems-level solutions for sampling/energy/KV-cache scaling (CSSA170) and emphasizing stiffness-aware integration for dynamics (DTO178) plus continuous-time/interval-loss formulations as alternative stabilization approaches (DTO175).

Throughout: link support remained unavailable, so the trajectory is necessarily a node-local synthesis, not an auditable edge-dependent path.

### which_bottleneck_survived
Optimization stability and sampling/compute scaling under hard regimes survived as the primary bottleneck theme.

- On ground states: nonconvex optimization, basis dependence, critical unique-state capacity, symmetry bias.
- On dynamics: stiffness and integrator instability.
- On scale: sampling and local-energy compute/memory, transformer cache pressure.

### which_path_was_strengthened_or_rejected
insufficient_link_support

node_local_fallback_only:
- No link-defined paths could be strengthened or rejected (no `link_id`s exist in any round). The conceptual throughline was strengthened by additional independent items in Rounds 1 and 2, but not by auditable edge traversal.

### what_would_be_measured_first
Across the proposed pipeline components, the first measurements should emphasize *stability and generalization* rather than only final energy:

- Convergence curves (energy and variance vs optimization steps) and their sensitivity to seeds/hyperparameters.
- Sampling diversity proxy (unique sampled states) in critical/near-critical regimes (APW153.limitation.critical_unique_states).
- Symmetry/observable diagnostics in frustrated systems (motivated by FWP021.limitation.su2_bias).
- For large-scale runs: throughput (samples/sec), memory footprint (KV-cache + sampling buffers), and local-energy time breakdown (CSSA170 framing).
- For dynamics: instability indicators under strong quenches, comparing explicit vs implicit/adaptive integrators (DTO178).

### failure_mode_to_watch
- Apparent energy improvement masking degraded observables or symmetry breaking.
- Curriculum/ramping improving convergence only in narrow regimes (poor transfer across models/lattices).
- Reference-basis methods failing in critical regimes due to insufficient unique-state coverage or unstable alpha optimization.
- Dynamics failures where explicit integrators produce plausible observables while variational parameters diverge (DTO178.limitation.explicit_unreliable).
- Large-scale runs bottlenecking on KV-cache memory or sampling imbalance despite theoretical scalability (CSSA170.problem.scalability_barriers).
