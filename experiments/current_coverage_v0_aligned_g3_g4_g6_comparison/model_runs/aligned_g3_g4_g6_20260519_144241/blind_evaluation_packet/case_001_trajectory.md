# Aligned Three-Round Trajectory

## round0

# Round 0

## round0_link_step_table

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C1 | 1 | DTO063.design_principle.monitor_observables | L0012 | DTO110.evaluation.energy_infidelity_scaling | supports | Connects a compression/tomography design principle (track multiple observables, since energy can hide degradation) to an evaluation lens that explicitly contrasts energy vs infidelity scaling across mixedness, motivating multi-metric stopping/selection rules. |

## round0_path_claims

- **C1 (supported path):** In neural-network quantum state tomography / mixed-state reconstruction, model selection and compression decisions should be guided by multiple metrics (not just energy), because energy-like objectives can be insensitive to meaningful degradation and different metrics exhibit different scaling behavior as the target state becomes more mixed. (Path: DTO063.design_principle.monitor_observables --L0012--> DTO110.evaluation.energy_infidelity_scaling)

## idea_title

Multi-Metric Early-Stopping and Compression Criteria for Neural Mixed-State Reconstruction

## assumed_bottleneck

Practitioners often tune/stop training and prune/compress models using a single convenient metric (commonly energy or an energy proxy), which can mask degradation in other physically relevant quantities; this becomes especially fragile as reconstruction targets move away from near-pure states (mixedness changes the relative informativeness/scaling of metrics).

## research_idea

Design and test a **multi-metric early-stopping + pruning/compression protocol** for neural mixed-state reconstruction that jointly tracks:

1. An energy-based metric (or energy proxy where applicable), and
2. An infidelity-like (or state-distance) metric (or a practical surrogate), and
3. A small set of task-relevant observables/correlators.

The protocol would define a small number of **decision rules** (for stopping, choosing hyperparameters, and pruning aggressiveness) that explicitly guard against the failure mode where energy appears stable while other metrics drift.

Concretely, implement a rule such as: stop/prune only when *all* tracked metrics have stabilized within tolerance over a patience window, and reject candidate compressed models if they improve energy but worsen the distance/observable set beyond a threshold. Compare against single-metric baselines (energy-only, distance-only) across a sweep of mixedness regimes.

## why_the_idea_depends_on_the_paths

The idea is specifically motivated by the linked path that ties together:

- A **design principle** warning that energy can be the least sensitive diagnostic during compression and that multiple observables should be monitored (DTO063.design_principle.monitor_observables), and
- An **evaluation framing** that contrasts how energy and infidelity-style quantities scale with mixedness (DTO110.evaluation.energy_infidelity_scaling).

Without that connection, “track more metrics” is generic advice; the path supports the sharper hypothesis that **metric sensitivity changes with mixedness**, so selection rules should be **explicitly multi-objective** rather than tuned to a single scalar.

## minimal_test

Run a small controlled experiment:

1. Pick one mixed-state reconstruction benchmark setup already used in prior work (any setting where both an energy proxy and an infidelity/state-distance estimate are computable or approximable).
2. Train a baseline neural mixed-state reconstruction model under a standard objective.
3. Apply pruning/compression or early-stopping with three policies:
   - energy-only,
   - distance/infidelity-only,
   - the proposed multi-metric rule.
4. Evaluate post-compression quality across:
   - energy proxy,
   - infidelity/state-distance (or surrogate),
   - a fixed panel of observables/correlations.

Success criterion: the multi-metric policy reduces the incidence of “energy looks fine but other metrics degrade” relative to energy-only, especially as mixedness increases.

## risk_or_limitation

Infidelity/state-distance metrics can be expensive or unavailable for realistic many-body mixed states; surrogates may introduce bias, and the protocol may need careful choices of observable panels and thresholds to avoid over-constraining (slowing training or preventing useful compression).

## idea_count_alignment_note

Exactly one research idea is provided, as required for Round 0.

## round1

# Round 1

## round1_link_delta_table

| claim_id | round0_path_status | round0_link_id | round1_link_id | delta_summary |
|---|---|---|---|---|
| C1 | replaced | L0012 | A0003, A0004 | The Round 0 support path was not available in this round’s allowed link set. The revised C1 is now anchored to (i) the review’s “self-attention backflow parametrizations” connection and (ii) the review’s backflow branch framing, shifting the idea from “mixed-state tomography metric sensitivity” to “architecture- and regime-shift-aware training selection criteria” while keeping the same core idea: multi-metric decisions beat single-metric decisions. |

## what_update_changed

1. **Domain focus shift (without changing the core idea):** The Round 0 idea’s motivation was framed around mixed-state reconstruction/tomography and “energy vs infidelity” sensitivity. In Round 1, the same core idea (multi-metric early-stopping + compression/model-selection) is reframed for **fermionic electronic-structure / correlated-electron NQS**, where architecture choices (e.g., attention in backflow parametrizations) and regime shifts (weak-to-strong coupling, basis changes) make single-metric decisions brittle.
2. **What “multi-metric” means operationally:** The revised idea explicitly includes **sampling/coverage metrics** (e.g., unique-sample counts / diversity proxies) alongside energy-like objectives, reflecting the observation that some regimes are limited by the number of uniquely sampled states (captured in the feedback items).
3. **Claim support updated to only use allowed links:** The updated path claims and link-step table use only link ids available in `feedback_links.csv` (A0001–A0004).

## what_update_did_not_change

1. The submission still proposes **one idea**: a practical, testable **multi-metric early-stopping + compression/model-selection protocol** (not multiple alternatives).
2. The core hypothesis remains: **a single scalar metric is insufficient** to robustly decide when to stop training or how aggressively to compress/select models, especially when the regime/architecture changes.
3. The evaluation philosophy remains comparative: test the proposed rule against **single-metric baselines** under a controlled sweep of conditions.

## revised_idea

Build and validate a **multi-metric selection protocol** for *fermionic NQS* (including attention-augmented architectures) that governs:

- **Early stopping** (when to stop optimization),
- **Model selection** (which checkpoint / hyperparameter setting to keep),
- **Compression or capacity control** (e.g., pruning, limiting effective expressivity, or otherwise constraining model size/compute),

using a **panel of metrics** rather than any single one.

Concretely, the protocol jointly monitors:

1. **Energy-like metric(s):** the standard variational objective (or proxy).
2. **Coverage / sampling-efficiency metric(s):** unique-sample count, effective sample size proxies, or other indicators of whether the model is exploring a sufficiently rich subset of Hilbert space (important near critical/strong-coupling regimes where capacity limitations show up as “not enough unique states”).
3. **Task-relevant observables:** a small, fixed set of correlators/structure factors or other physics-facing quantities that can detect qualitative failure even when the energy appears stable.

Decision rule sketch:

- Accept a checkpoint/compressed model only if **(a)** energy does not regress beyond tolerance, **and (b)** coverage does not collapse, **and (c)** observables remain within tolerance (or improve).
- Prefer training curricula / basis choices / ordering choices that keep the above metrics jointly stable across regime shifts (e.g., weak-to-strong coupling), rather than optimizing energy alone.

The new angle is not “track more stuff” in the abstract; it is to make the protocol **architecture-aware** (e.g., attention/backflow variants) and **regime-shift-aware** (e.g., basis or coupling changes), because these changes can alter which metrics are informative and how failures present.

## updated_path_claims

### C1 (supported path)

As NQS architectures for fermionic systems evolve (notably toward **self-attention parametrizations** within established fermionic-NQS branches like **neural backflow**), model-selection and capacity-control decisions should not be based on a single scalar objective alone; they should be **multi-metric** to guard against architecture- and regime-dependent failure modes that may not be visible in the primary objective.

Path basis used (review connects attention to backflow parametrizations; and frames backflow as a determinant-based branch):

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C1 | 1 | CSSA024.paper | A0003 | APW090.paper | supports | Establishes that attention mechanisms have been specifically used to parametrize the backflow transformation, making “attention variants” a realistic architectural knob where selection/diagnostics matter. |
| C1 | 2 | NQSC127.paper.01 | A0004 | NQSC127.method.06 | supports | Places these architectures inside a recognized fermionic-NQS development branch (neural backflow), supporting the claim that there is a family of related models where a shared selection protocol could apply. |

## next_test

Run a controlled comparison across (at least) two fermionic-NQS architecture families within the “backflow / attention-augmented” neighborhood:

1. Train baseline models under a standard objective on a fermionic benchmark with a regime sweep (e.g., weak-to-strong coupling or away/toward a critical regime).
2. Compare three selection policies:
   - Objective-only (energy-only),
   - Coverage-aware (energy + unique-sample/coverage proxy),
   - Full panel (energy + coverage + fixed observable panel).
3. For each policy, measure:
   - Generalization to held-out configurations (where applicable),
   - Stability of observables across the regime sweep,
   - Sensitivity to architecture choice (attention vs non-attention variants).

Success criterion: the multi-metric policies reduce the incidence of “objective looks converged but physics-facing diagnostics degrade” and produce more consistent performance across architectures and regimes.

## branch_drift_check

The Round 1 revision does not introduce a new unrelated idea. It keeps the same core concept from Round 0 (multi-metric early-stopping and compression/model-selection) but re-anchors it to the allowed evidence for this round (fermionic NQS architecture evolution and branch framing), rather than mixed-state tomography-specific motivations that are not supportable with the present link set.

## idea_count_alignment_note

Exactly one revised research idea is provided for Round 1, as required.

## round2

# Round 2

## round2_link_delta_table

| claim_id | round1_path_status | round1_link_id | round2_link_id | delta_summary |
|---|---|---|---|---|
| C1 | replaced | A0003, A0004 | B0001, B0002, B0003, B0004 | The Round 1 support path (attention/backflow branch framing) is not available in this round’s allowed link set. The C1 support is re-anchored to the large-scale NQS training scalability framing and the Fugaku-oriented optimizations: sampling parallelism, local-energy parallelism, and transformer KV-cache management. The core trajectory remains the same: selection/early-stopping/compression decisions should be multi-metric, not single-metric, but the motivating failure mode is now “scaling collapse/hidden resource bottlenecks” rather than “architecture-branch regime drift.” |

## final_research_direction

Develop and validate a **multi-metric training-and-capacity control protocol** for *large-scale NQS training* that explicitly couples:

- physics-facing objectives (energy-like or task objective),
- sampling/coverage and throughput diagnostics, and
- **resource/stability diagnostics** (memory footprint, KV-cache pressure, and local-energy kernel utilization),

so that “good energy” is not allowed to mask impending **OOM, cache blow-ups, or throughput collapse** when scaling to larger systems and node counts.

## trajectory_summary

This trajectory keeps one idea across rounds: **single-metric convergence is brittle** for deciding when to stop, which checkpoint to keep, or how aggressively to constrain capacity (compression / caching / parallelism policy). In Round 2, the same idea is finalized for the *HPC scaling setting* suggested by the Fugaku large-scale NQS framework: when scaling is limited by sampling dynamics, local-energy computation, and transformer cache behavior, the decision rule has to watch those axes directly, not only the variational objective.

## which_bottleneck_survived

The surviving bottleneck is **hidden failure under a seemingly healthy scalar objective**:

- energy (or another single primary loss) can look stable while the training run becomes untenable due to **sampling memory growth**, **local-energy compute bottlenecks**, or **KV-cache memory pressure**.

## which_path_was_strengthened_or_rejected

Strengthened: grounding the “multi-metric selection” idea in **large-scale NQS training bottlenecks** (sampling, local-energy, cache/memory), where operational viability is part of correctness.

Rejected (for this round only, due to lack of allowed links): the Round 1 anchoring via **attention/backflow branch framing**. The idea is not changed; only the evidence path is replaced.

## what_would_be_measured_first

First measurements (collected per-iteration or per-window alongside energy/loss) would be:

1. **Sampling stability/coverage:** unique-sample count (or an ESS proxy) and peak sampler memory.
2. **Local-energy kernel profile:** time share and scaling of local-energy evaluation (per-sample cost, SIMD/thread efficiency proxies, or at minimum walltime fraction).
3. **KV-cache pressure (if transformer-based):** pooled cache size / recomputation rate / cache expansion events as a function of system size and batch/sample count.

These three are selected because they map directly onto the known scaling barriers and corresponding optimization levers in the linked evidence.

## failure_mode_to_watch

The main failure mode is **premature “convergence” under energy-only criteria** that selects a checkpoint/configuration which:

- later fails at larger scale due to OOM (sampling or cache),
- silently degrades throughput so severely that wall-clock feasibility collapses,
- or produces misleadingly stable energy while the run is dominated by a single bottlenecked kernel (local-energy), preventing meaningful exploration/optimization progress.

## branch_drift_check

No branch drift: Round 2 still proposes exactly one research direction, continuous with Round 0/1:

- “Use multi-metric criteria for stopping/selection/capacity control; don’t trust a single scalar.”

What changed across rounds is only the **supporting motivation** (now HPC scaling bottlenecks) and the **operational metric panel** (now includes cache/memory/parallel-efficiency style diagnostics).

## idea_count_alignment_note

Exactly one final trajectory is provided for Round 2, as required.

## Link-Supported Claim Steps (for Round 2)

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C1 | 1 | CSSA145.problem.peaked_hamiltonian | B0001 | CSSA170.problem.scalability_barriers | supports | Establishes that large-scale NQS training is fundamentally limited by sampling-driven compute and memory footprint, creating a setting where “objective-only convergence” can be operationally misleading. |
| C1 | 2 | CSSA145.method.sampling_without_replacement | B0004 | CSSA170.method.sampling_parallelism | supports | Connects the sampling-side instability (dynamic/“unpredictable” memory requirements) to a concrete mitigation (memory-stable sampling parallelism), motivating sampling/memory metrics as first-class selection signals. |
| C1 | 3 | CSSA145.method.local_energy_surrogate | B0003 | CSSA170.method.energy_parallelism | supports | Anchors local-energy evaluation as a core computational bottleneck and ties it to a parallelization strategy, motivating local-energy profiling/utilization metrics in the selection panel. |
| C1 | 4 | CSSA145.method.gpu_compression | B0002 | CSSA170.method.cache_optimization | supports | Grounds transformer KV-cache memory as a concrete scaling constraint and links it to cache pooling/recomputation strategies, motivating cache-pressure diagnostics as selection/early-stop guardrails for transformer-based NQS. |

