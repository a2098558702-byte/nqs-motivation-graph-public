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

