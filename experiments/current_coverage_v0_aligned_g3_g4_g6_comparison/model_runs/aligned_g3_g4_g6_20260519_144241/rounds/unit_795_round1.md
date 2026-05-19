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

