# Unit 156 — Round 0

## round0_link_step_table

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C1 | 1 | DTO063.design_principle.monitor_observables | L0012 | DTO110.evaluation.energy_infidelity_scaling | supports | Connects a pruning/compression design principle (track multiple observables; energy can be least sensitive) to a later evaluation framing that explicitly compares energy- vs infidelity-related scaling behavior across mixedness. |

## round0_path_claims

- **C1:** For compressed / resource-constrained neural quantum state tomography and mixed-state reconstruction, evaluation and training targets should be multi-metric (not energy-only), because energy can hide degradations in other physical observables; this aligns with later work that evaluates reconstruction via energy/infidelity scaling exponents across mixedness. (Path: `DTO063.design_principle.monitor_observables` --`L0012`--> `DTO110.evaluation.energy_infidelity_scaling`.)

## idea_title

Compression-Aware Mixed-State Tomography With Multi-Observable Guardrails and Scaling Diagnostics

## assumed_bottleneck

When NQS tomography models are pruned/compressed or otherwise capacity-limited, optimization may still drive down an energy-like loss while silently degrading other physically meaningful quantities (magnetization/correlations) and/or worsening fidelity-related behavior, especially as the target state becomes more mixed.

## research_idea

Develop and test a **compression-aware training+evaluation protocol** for neural-network mixed-state reconstruction that:

1. Uses **multi-observable guardrails** during pruning (or other compression/regularization), explicitly tracking a small set of observables (e.g., magnetization and selected two-point correlators) alongside the primary loss.
2. Chooses pruning/early-stopping schedules by optimizing a **Pareto criterion** over (a) energy-like error, (b) observable deviations, and (c) an infidelity proxy (or any available fidelity-related estimate), rather than a single scalar metric.
3. Reports performance in the **scaling-exponent language** (energy and infidelity scaling trends vs sample count / mixedness) to reveal whether compression changes the apparent sample complexity regime.

The core hypothesis is that introducing guardrails plus scaling diagnostics will prevent “energy looks fine” failure modes and produce reconstructions that remain physically reliable across increasing mixedness, even at similar parameter budgets.

## why_the_idea_depends_on_the_paths

The link-supported path grounds two ingredients that need to be combined:

- A **design principle** from pruning/compression in tomography: energy can be the least sensitive quantity, so tracking only energy can miss meaningful degradations (source node: `DTO063.design_principle.monitor_observables`).
- An **evaluation framing** for mixed-state reconstruction that explicitly contrasts **energy vs infidelity scaling exponents** and how they change with mixedness (target node: `DTO110.evaluation.energy_infidelity_scaling`).

The idea is specifically to fuse these: compression decisions should be made with multi-observable guardrails, then validated using scaling diagnostics that can expose hidden regressions that energy-only monitoring would miss.

## minimal_test

Run a small controlled study with two reconstruction settings (one nearer-pure, one more mixed) and compare:

- Baseline: standard training + pruning/regularization using energy-only (or single-metric) selection.
- Proposed: identical model class and budget, but pruning/selection uses multi-observable guardrails; evaluation includes energy- and infidelity-related scaling trends.

Success criteria (minimal): at matched parameter count, the proposed protocol reduces observable deviations (e.g., magnetization/correlations) without worsening energy error, and shows equal-or-better fidelity-related scaling behavior in the more-mixed setting.

## risk_or_limitation

Observable guardrails can be expensive or noisy to estimate, and there may be tension between optimizing observable accuracy and improving fidelity/energy simultaneously; the Pareto selection might become sensitive to which observables are chosen, reducing generality.

## idea_count_alignment_note

Exactly one research idea is provided for Round 0, as required.

