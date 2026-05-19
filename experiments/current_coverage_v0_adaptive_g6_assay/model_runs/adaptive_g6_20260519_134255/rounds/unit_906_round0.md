# Round 0 (Unit 906)

selected_path_label: autoregressive_symmetry_aware_pruning
selected_link_ids: C0020;C0021;C0017
selected_item_ids: APW060.method.physical_priors_constraints;OPW085.method.reverse_sampling_order;HPM026.future.alternative_sampling_deeper_networks;HPM117.method.symmetry_aware_pruning
selected_paper_ids: NQSC060;NQSC085;NQSC026;NQSC117
path_selection_rationale: The strongest connected cluster in this packet centers on incorporating constraints/structure into autoregressive sampling via symmetry-aware pruning. Multiple independent prior items (hard-coded physical priors in an autoregressive ansatz, reverse sampling order, and calls for alternative sampling in electronic-structure RBM work) all link into the same concrete mechanism node (symmetry-aware pruning), making it a well-supported local branch to extend.

idea_title: Symmetry-Constrained Autoregressive NQS via Learnable Pruning Policies
assumed_bottleneck: Autoregressive NQS can sample exactly, but enforcing quantum-number and lattice symmetries during sampling is awkward; ad hoc hard-coded priors help but can restrict expressivity, and symmetry-unaware sampling wastes probability mass on configurations that will later be rejected or projected away.

research_idea: Build an autoregressive NQS sampler that enforces symmetry constraints online by combining (1) a symmetry-aware pruning routine (as an explicit feasibility filter over partial assignments) with (2) a learned “pruning policy” that reorders or biases the generation order to reduce backtracking. Concretely: maintain a partial configuration; at each step propose the next variable (or next block) using a small auxiliary network trained to minimize expected pruning/backtracking subject to the same exact-sampling semantics. The pruning routine guarantees physical/symmetry feasibility; the policy improves efficiency by steering generation toward high-feasibility continuations early.

why_this_path: The packet contains a tight, multi-source path into a specific intervention point: symmetry-aware pruning for autoregressive sampling. It also explicitly highlights tension between hard-coded physical priors/constraints and flexibility in autoregressive ansatze, suggesting a useful extension that preserves exactness while improving efficiency.

minimal_test: On a small symmetry-sensitive benchmark (e.g., fixed-particle-number or fixed-magnetization sector on a 2D lattice toy instance), compare four samplers under identical base autoregressive model capacity: (A) plain autoregressive sampling, (B) hard-coded priors/constraints only, (C) pruning-only (symmetry-aware pruning with naive order), (D) pruning + learned pruning policy. Measure: average number of pruned branches per completed sample, wall-clock per effective sample, and VMC optimization stability (variance/energy vs steps) at matched compute.

risk_or_limitation: Pruning can introduce discontinuous sampling-time control flow that is hard to optimize jointly with the wavefunction parameters; the learned pruning policy might overfit to a training distribution of partial assignments and fail to generalize across coupling regimes, and aggressive pruning may inadvertently bias sampling if the exactness guarantees are not carefully preserved (the feasibility filter must not silently discard valid configurations without renormalization).

round0_link_step_table:

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C1 | 1 | APW060.method.physical_priors_constraints | C0020 | HPM117.method.symmetry_aware_pruning | forward | Establishes that prior work treats physical priors/constraints in autoregressive ansatze as ad hoc, motivating a more systematic constraint-enforcement mechanism (symmetry-aware pruning) as a remedy target. |
| C2 | 1 | OPW085.method.reverse_sampling_order | C0021 | HPM117.method.symmetry_aware_pruning | forward | Links an alternative autoregressive sampling strategy (reverse sampling order leveraging structure) to symmetry-aware pruning, supporting the idea that sampling-order control is a relevant lever alongside pruning. |
| C3 | 1 | HPM026.future.alternative_sampling_deeper_networks | C0017 | HPM117.method.symmetry_aware_pruning | forward | Connects an explicit future-work call for alternative sampling (and deeper architectures) to the concrete pruning method, justifying a Round 0 proposal focused on sampling efficiency/constraints rather than only increasing model size. |

