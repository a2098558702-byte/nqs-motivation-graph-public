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

