# Blind Edge-Dependency Evaluation

Evaluator: `gpt-5.5`  
Reasoning effort: `xhigh`  
Scope: anonymized trajectories only; no hidden condition mappings inferred.

Scores are 1-5, where 5 is strongest. The mechanical audit is treated as a constraint on link mechanics, while the qualitative judgment below evaluates whether the prose and final research direction actually depend on auditable support paths.

## Score Summary

| anonymous_case_id | link-id validity | endpoint fidelity | path continuity | link-evidence faithfulness | update locality | unsupported-bridge control | conclusion dependence | testability |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| case_001 | 1 | 1 | 1 | 2 | 2 | 5 | 1 | 4 |
| case_002 | 4 | 4 | 3 | 4 | 4 | 4 | 4 | 4 |
| case_003 | 5 | 5 | 2 | 4 | 4 | 3 | 3 | 5 |
| case_004 | 5 | 5 | 4 | 3 | 3 | 3 | 2 | 4 |
| case_005 | 5 | 5 | 3 | 4 | 4 | 3 | 4 | 4 |

## Per-Case Evaluations

### anonymous_case_id: case_001

- Link-id validity: 1
- Endpoint fidelity: 1
- Path continuity: 1
- Link-evidence faithfulness: 2
- Update locality: 2
- Unsupported-bridge control: 5
- Conclusion dependence: 1
- Testability: 4

Mechanical audit notes, if provided: 0 parsed link steps, 0 valid link steps, 0 invalid link steps, 0 endpoint mismatches, 0 path continuity breaks, 7 insufficient-link-support mentions, and 4 node-local fallback mentions.

Short evidence-grounded rationale: This trajectory is unusually explicit that no links are available in any round. Round 0, Round 1, and Round 2 repeatedly mark `insufficient_link_support` and frame all support as node-local fallback. The substantive synthesis is coherent: optimization instability, symmetry/inductive-bias mismatch, curriculum/ramping, basis choice, HPC scaling, and dynamics stiffness are all plausible NQS bottleneck themes. However, the rubric is an edge-dependency assay, and the trajectory supplies no auditable link ids, endpoints, or continuous paths.

Whether the final direction truly depends on support paths: No. The final research direction depends on a convergence of node-local observations, not graph-traversable support paths. Removing paths would not materially change the direction because there are no paths to remove.

Unsupported-bridge or hallucinated-link concerns: No hallucinated-link concern; the trajectory is honest about the absence of links. The main limitation is that cross-item synthesis is necessarily semantic and node-local.

Uncertainty notes: Low uncertainty on edge-dependency scoring because the packet and audit agree there are no usable links. Node-local fallback quality is good, but the rubric forbids inflating the edge-dependent metrics on that basis.

### anonymous_case_id: case_002

- Link-id validity: 4
- Endpoint fidelity: 4
- Path continuity: 3
- Link-evidence faithfulness: 4
- Update locality: 4
- Unsupported-bridge control: 4
- Conclusion dependence: 4
- Testability: 4

Mechanical audit notes, if provided: 14 parsed link steps, 13 valid link steps, 1 invalid link step, 1 endpoint mismatch, 3 path continuity breaks, and no missing link ids or future-round violations.

Short evidence-grounded rationale: The core diagnostic thesis is well supported by the cited links: observable degradation under compression, the design principle of monitoring observables, mixed-state reconstruction metrics, nonconvex optimization, density-matrix/open-system representations, and hard convergence regimes. The trajectory also uses Round 1 and Round 2 updates locally: A0001 broadens the mixed/open-system testbed, A0071 introduces training-path intervention, B0045 sharpens multi-metric monitoring with a global diagnostic, and B0003/B0067 add scale and landscape-diagnostic angles. The mechanical audit prevents a top score because one link step is invalid or endpoint-mismatched and several multi-step claims are not fully continuous.

Whether the final direction truly depends on support paths: Mostly yes. The final "multi-metric, scale-feasible reliability protocol" would be materially weakened if the support paths connecting observable monitoring, nonconvex reconstruction, open-system representations, and fidelity/variance-style diagnostics were removed. Some intervention pieces, especially ramping and compute parallelism, are more adjacent than central.

Unsupported-bridge or hallucinated-link concerns: Moderate-low. The prose generally acknowledges when a link only motivates a protocol rather than proving a specific fix. The broader move from tomography/compression diagnostics to mixed/open-system dynamics and correlated-electron training is plausible but not fully path-continuous.

Uncertainty notes: The exact identity of the invalid endpoint step is not recoverable from the audit alone, but the qualitative conclusion is stable: this is one of the stronger edge-dependent trajectories, with mechanical imperfections.

### anonymous_case_id: case_003

- Link-id validity: 5
- Endpoint fidelity: 5
- Path continuity: 2
- Link-evidence faithfulness: 4
- Update locality: 4
- Unsupported-bridge control: 3
- Conclusion dependence: 3
- Testability: 5

Mechanical audit notes, if provided: 11 parsed link steps, all 11 valid, 0 endpoint mismatches, 0 bad traversal values, but 7 path continuity breaks.

Short evidence-grounded rationale: The trajectory cites valid links and its interpretations usually follow the linked observations: frustrated/sign-structure difficulty with symmetry-aware CRNN and annealing, local-energy barriers and unique-configuration sampling, observable degradation under pruning, local-energy surrogates, sampling without replacement, basis-informed sampling, ramping, large-scale CSSA170 constraints, and variance-style diagnostics. The main weakness is that many "paths" are star-shaped lists from a paper node to several method/problem/result nodes rather than continuous multi-step paths. The final "Integrity-Gated Efficiency Stack" is a coherent, testable research program, but it is assembled by bridging across frustrated spins, molecular VMC, pruning/tomography, transformer sampling, and HPC scaling more than by following continuous support paths.

Whether the final direction truly depends on support paths: Partially. The direction clearly draws from cited link-supported observations, especially compute bottlenecks and energy-only failure modes. But if continuous path structure were removed, much of the final stack could still be reconstructed from node-local evidence and domain-level analogy.

Unsupported-bridge or hallucinated-link concerns: Moderate. There is no hallucinated-link concern mechanically, but the unification across domains is broader than the edge structure strictly warrants. The trajectory does acknowledge this risk in Round 0, which improves unsupported-bridge control.

Uncertainty notes: Low uncertainty on link validity; higher uncertainty on how much to reward star-shaped paper-to-claim evidence. Under this rubric, the seven continuity breaks are a significant constraint.

### anonymous_case_id: case_004

- Link-id validity: 5
- Endpoint fidelity: 5
- Path continuity: 4
- Link-evidence faithfulness: 3
- Update locality: 3
- Unsupported-bridge control: 3
- Conclusion dependence: 2
- Testability: 4

Mechanical audit notes, if provided: 6 parsed link steps, all 6 valid, no endpoint mismatches, no traversal errors, no path continuity breaks, 2 insufficient-link-support mentions, and 3 node-local fallback mentions.

Short evidence-grounded rationale: Mechanically, the cited links are clean. Qualitatively, the support is weaker because Round 0 is explicitly node-local fallback, and later rounds rely heavily on citation-style paper-to-paper edges. The trajectory is candid about this in places, noting that the Round 1 links are citation-style edges and that Round 0 did not connect concrete limitation/result items. However, many substantive claims about ramping, reference bases, convergence limits, scalability, and dynamics stiffness are carried by node-support items rather than by the cited link endpoints themselves.

Whether the final direction truly depends on support paths: Weakly. The final "make it converge and make it scale" program would change little if the paper-level citation edges were removed, because the direction mostly depends on node-local content and broad conceptual synthesis.

Unsupported-bridge or hallucinated-link concerns: Moderate. There is no mechanical hallucination in the audited links, but the trajectory sometimes treats citation-neighborhood edges as enough to support stronger bottleneck/intervention claims. It also shifts from the Round 0 frustrated-spin symmetry-restoration idea to a broader convergence, dynamics, and HPC program primarily because later node-local observations are more useful.

Uncertainty notes: Mechanical confidence is high, but qualitative confidence in edge-dependence is lower because citation edges may be valid without carrying the asserted causal or methodological relationship.

### anonymous_case_id: case_005

- Link-id validity: 5
- Endpoint fidelity: 5
- Path continuity: 3
- Link-evidence faithfulness: 4
- Update locality: 4
- Unsupported-bridge control: 3
- Conclusion dependence: 4
- Testability: 4

Mechanical audit notes, if provided: 13 parsed link steps, all 13 valid, 0 endpoint mismatches, 0 traversal errors, but 5 path continuity breaks.

Short evidence-grounded rationale: The trajectory has a strong central throughline: autoregressive exact sampling creates symmetry/constraint difficulties; pruning, physical priors, and sampling-order choices offer concrete constraint-handling mechanisms; later updates broaden this into constraint stacks and then compute-aware scaling through sampling, local-energy, and cache links. The cited links are mechanically valid, and the final direction is recognizably shaped by the support. The main weakness is continuity: several claims are built from multiple independent edges converging on a theme rather than from continuous traversals, especially the pruning/constraint group and the Round 2 scaling group.

Whether the final direction truly depends on support paths: Mostly yes. Removing the support paths would materially weaken the case for "constraint-preserving, compute-aware autoregressive NQS," because the direction depends on linked evidence for symmetry tradeoffs, pruning/constraint mechanisms, fermionic efficiency pressure, open-system physicality, and scaling bottlenecks.

Unsupported-bridge or hallucinated-link concerns: Moderate. No hallucinated-link issue appears mechanically. The concern is semantic breadth: the path from autoregressive symmetry pruning to mixed/open-system physicality and then to large-scale cache/parallelism is plausible but not always path-continuous. The trajectory does not overclaim a universal architecture, which helps.

Uncertainty notes: Low uncertainty on mechanical validity; moderate uncertainty on whether the open-system and fermionic-lineage branches are central enough to the final autoregressive constraint-stack proposal.

## Cross-Case Comparison

case_002 and case_005 are the strongest edge-dependent trajectories overall. case_002 has a particularly coherent diagnostic thesis around multi-metric reliability, though it is constrained by one invalid or endpoint-mismatched step and several continuity breaks. case_005 has clean link validity and endpoint fidelity with a persuasive constraint-preserving throughline, but it also relies on several disconnected thematic link clusters.

case_003 is rich, technically concrete, and the most testable, but it suffers the largest path-continuity penalty among the linked cases. Its final integrity-gated efficiency stack is compelling as a research program, yet much of the support is star-shaped or cross-domain synthesis rather than continuous edge traversal.

case_004 is mechanically clean but qualitatively weaker as an edge-dependency demonstration. Its links are valid and continuous, but they are mostly citation-style paper links; the substantive claims depend more on node-local observations than on link endpoints. It is therefore stronger mechanically than evidentially.

case_001 is best read as an honest node-local fallback baseline. It is well written and appropriately cautious, but because no usable links exist in any round, it cannot score highly on the primary edge-dependency metrics. Its high unsupported-bridge-control score reflects honesty, not link-supported success.

Across cases, the key discriminator is not whether the final research idea is plausible; all five are plausible. The differentiator is whether the trajectory demonstrates that the final direction is materially constrained by auditable, continuous link-connected observations. On that standard, case_002 and case_005 lead, case_003 is promising but discontinuous, case_004 is mechanically valid but citation-thin, and case_001 is a non-edge-dependent fallback.
