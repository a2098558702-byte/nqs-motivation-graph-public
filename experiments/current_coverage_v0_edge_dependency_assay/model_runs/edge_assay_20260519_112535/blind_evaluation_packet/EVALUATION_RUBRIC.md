# Edge Dependency Assay Evaluation Rubric

Score each trajectory from 1 to 5 on each metric. This assay is deliberately different from an open-ended research-idea contest: the primary observable is whether the trajectory depends on auditable link-connected observations.

## Primary Metrics

- Link-id validity: cited link ids exist in the allowed files for the relevant round.
- Endpoint fidelity: stated `from_item_id`, `to_item_id`, and traversal direction match the cited link.
- Path continuity: multi-step claims form continuous paths rather than disconnected link lists.
- Link-evidence faithfulness: prose interpretation follows the linked observations and support evidence.
- Update locality: Round 1 and Round 2 revise, extend, or reject earlier paths using newly available observations.
- Unsupported-bridge control: the trajectory does not smuggle in unlinked semantic jumps as if they were link-supported.
- Conclusion dependence: the final research direction would materially change if the support paths were removed.
- Testability: the final direction includes a realistic benchmark, diagnostic, or falsification path.

## Nodes-Only Handling

A packet with no usable links can be honest and well written, but it cannot receive high scores on link-id validity, endpoint fidelity, path continuity, update locality through links, or conclusion dependence on paths. Do not inflate the primary score for node-local synthesis. Record node-local fallback quality separately if useful.

## Required Evaluator

Blind qualitative evaluation must be performed by `gpt-5.5` with reasoning effort `xhigh`.

The controller/main agent must not substitute its own judgment for this blind evaluation.

## Required Output Schema

For each anonymized trajectory:

- `anonymous_case_id`
- metric scores from 1 to 5
- mechanical audit notes, if provided
- short evidence-grounded rationale
- whether the final direction truly depends on support paths
- unsupported-bridge or hallucinated-link concerns
- uncertainty notes

Also provide a cross-case comparison without revealing or guessing hidden mappings.
