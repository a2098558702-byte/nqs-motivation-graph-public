# Unit 156 — Round 1

## round1_link_delta_table

| claim_id | delta_type | round0_basis | round1_basis | rationale |
|---|---|---|---|---|
| C1 | replace_path_support | Round 0 relied on a link/path not present in this Round 1 packet. | Re-anchor the same core idea (multi-metric guardrails under resource constraints) using links about (i) controlling unique samples, (ii) cheaper local-energy estimation, and (iii) known NQS optimization bottlenecks. | The Round 1 evidence batch does not include the Round 0 nodes/links, so the revision keeps the idea but re-bases it on available, directly supported mechanisms and failure modes. |
| C2 | add_path_support | Not present. | Add a curriculum/ramping component as an *optimization stabilizer* for hard regimes, grounded in a physics-motivated ramping method. | Keeps the “guardrails + scaling diagnostics” framing, but now explicitly addresses the optimization bottleneck highlighted in the review and Hubbard ramping result. |
| C3 | add_path_support | Not present. | Add a physicality/constraint check for reduced density objects when using surrogate objectives, grounded in Hermiticity/positivity-preserving parameterizations. | Preserves the “don’t trust a single cheap proxy” spirit by ensuring proxies don’t violate physical constraints. |

## what_update_changed

- Rebased the **supporting graph paths** from a tomography/mixed-state evaluation link (Round 0) to a **resource-constrained ANQS / electronic-structure** setting where the key practical failure mode is: “cheap objective looks good, but overall physics/accuracy doesn’t.”
- Made the “multi-metric guardrails” concrete in terms of **unique-sample control** (sampling without replacement) and **separate cost drivers** (local-energy evaluation), because those are explicitly evidenced in this packet.
- Added an explicit **curriculum/ramping** knob for optimization stability in hard regimes (strong coupling / difficult convergence), rather than treating optimization as a black box.

## what_update_did_not_change

- Still exactly one idea: a **compression/resource-aware protocol** that uses **guardrails beyond a single scalar metric**, and then validates with **scaling-style diagnostics** rather than one-off point estimates.
- Still targets the same core failure mode: “a primary loss/proxy can look fine while other physically relevant quality measures regress,” especially under constrained budgets.

## revised_idea

Build a **budget-aware ANQS training and evaluation protocol** for fermionic / molecular NQS in which *sampling and estimator choices are treated as first-class levers*, and success is judged by multi-metric guardrails rather than energy alone.

Concretely:

1. Treat the number of **unique sampled configurations** as an explicit budget axis and control it with **autoregressive sampling without replacement**. Use this to design *apples-to-apples* comparisons across model sizes and training schedules.
2. When local-energy evaluation dominates cost, incorporate **local-energy surrogates** and/or data structures (e.g., **prefix-tree / trie** organization of sampled determinants) to reduce per-iteration cost, but do not let these proxies become the only target.
3. Run training with a simple **curriculum/ramping schedule** (analogous to physics-motivated parameter ramping) to mitigate known NQS optimization difficulty in hard regimes.
4. Select checkpoints and compression/sampling settings using a **Pareto-style criterion** over:
   - (a) energy or variational-energy proxy,
   - (b) at least one secondary physics-relevant diagnostic (e.g., stability across repeated sampling budgets / unique-state counts), and
   - (c) a robustness indicator tied to optimization stability (e.g., sensitivity to ramp schedule, or stability under SR/minSR vs vanilla gradients if available).

**Hypothesis:** by explicitly controlling unique-sample budgets and separating “cheaper estimation” from “model quality,” we can avoid the common failure where improved *throughput* (or improved energy-like proxies) masks degraded overall accuracy, particularly on hard molecular cases.

## updated_path_claims

### Link-Step Table (C1)

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C1 | 1 | CSSA145.paper | A0021 | CSSA145.method.sampling_without_replacement | supports | Grounds the idea’s “explicit unique-sample budget” control mechanism (sampling without replacement) as a core technical lever. |
| C1 | 2 | CSSA145.paper | A0022 | CSSA145.method.local_energy_surrogate | supports | Shows an explicit, evidenced strategy to reduce the computational cost of local-energy evaluation via a cheaper surrogate objective. |
| C1 | 3 | CSSA145.paper | A0023 | CSSA145.method.prefix_tree | supports | Adds a second, complementary way to reduce local-energy cost by exploiting structure in sampled configurations (trie/prefix-tree). |
| C1 | 4 | CSSA145.paper | A0028 | CSSA145.limitation.c2 | supports | Motivates the guardrail framing: even with increased unique samples (and associated efficiency techniques), some hard cases remain unsolved, so energy/proxy improvements alone are not sufficient. |

**C1 (path claim):** In resource-constrained ANQS for molecular systems, you should (i) control the unique-sample budget explicitly and (ii) separate computational shortcuts (local-energy surrogate; trie-based evaluation) from model-quality decisions, because hard cases can remain inaccurate even when sampling/throughput is improved. (Path: `CSSA145.paper` --`A0021/A0022/A0023/A0028`--> methods+limitation.)

### Link-Step Table (C2)

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C2 | 1 | NQSC127.paper.01 | A0053 | NQSC127.problem.02 | supports | Establishes that optimization is a primary bottleneck for NQS, so stabilizing training is a central design requirement. |
| C2 | 2 | OPW150.paper | A0065 | OPW150.method.hubbard_ramping | supports | Provides an evidenced, physics-motivated curriculum/ramping mechanism during training. |
| C2 | 3 | OPW150.paper | A0067 | OPW150.result.ramping_improves_fhm | supports | Supports the claim that such ramping can materially improve convergence in difficult regimes. |

**C2 (path claim):** Because NQS optimization is a core bottleneck, introducing a curriculum-like **parameter ramping** schedule is a justified ingredient of a budget-aware protocol; ramping has demonstrated convergence improvements in challenging autoregressive NQS training settings. (Path: `NQSC127.paper.01` --`A0053`--> `NQSC127.problem.02`; `OPW150.paper` --`A0065/A0067`--> ramping method+result.)

### Link-Step Table (C3)

| claim_id | step_index | from_item_id | link_id | to_item_id | traversal | why_step_matters |
|---|---:|---|---|---|---|---|
| C3 | 1 | DTO134.paper | A0032 | DTO134.method.rbm_rdt_physicality | supports | Grounds the idea’s “guardrails beyond a cheap proxy” principle in an explicit example where parameterization is designed to preserve Hermiticity/positivity. |

**C3 (path claim):** When using cheaper objectives/proxies (e.g., local-energy surrogates) as part of a scaling/efficiency protocol, incorporate **physicality guardrails** (Hermiticity/positivity preservation or analogous constraints) so that efficiency improvements do not drift into unphysical solutions. (Path: `DTO134.paper` --`A0032`--> `DTO134.method.rbm_rdt_physicality`.)

## next_test

A minimal, controlled test that matches the revised evidence:

1. Pick a molecular/electronic-structure benchmark suite that includes at least one “easy” and one “hard” case (the hard case is meant to mirror the packet’s “still hard despite more unique samples” signal).
2. For each case, run ANQS training under a fixed compute budget with a grid over:
   - unique-sample budgets (enabled by sampling without replacement),
   - local-energy evaluation strategy (exact vs surrogate; with/without prefix-tree acceleration),
   - optimization schedule (baseline vs ramping).
3. Compare *at matched wall-clock or matched unique-sample count*:
   - energy/proxy energy,
   - stability across resampling (variance / reproducibility vs unique-sample budget),
   - success/failure rates of optimization (convergence robustness across seeds/schedules).

Pass condition: the guardrailed protocol identifies regimes where energy/proxy looks good but robustness/stability is poor, and selects settings that improve stability on the hard case without sacrificing energy on the easy case.

## branch_drift_check

- Drift risk: Round 0 was framed around mixed-state tomography evaluation; this Round 1 packet does not contain those Round 0 nodes/links, so I cannot preserve the exact same graph path.
- Mitigation: I preserved the **same underlying research idea** (resource-constrained NQS requires multi-metric guardrails and scaling-style diagnostics; don’t trust a single objective/proxy), but re-expressed it in a **molecular ANQS** setting with directly evidenced mechanisms (unique-sample control, cheaper local energy evaluation, optimization stabilization).

## idea_count_alignment_note

Exactly one revised research idea is provided for Round 1, and it is a single revision of the Round 0 idea (not a new, unrelated idea).
