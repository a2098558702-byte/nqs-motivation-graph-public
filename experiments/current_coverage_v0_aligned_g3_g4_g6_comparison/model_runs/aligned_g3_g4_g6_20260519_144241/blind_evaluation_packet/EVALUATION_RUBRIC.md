# Aligned G3/G4/G6 Evaluation Rubric

Score each trajectory from 1 to 5 on each metric.

## Metrics

- Idea-count alignment: exactly one Round 0 idea, one Round 1 revision, and one Round 2 final trajectory; no menu of independent alternatives.
- Goal preservation: the same research trajectory survives across rounds unless explicitly and evidence-groundedly rejected.
- Branch drift control: updates narrow, ground, or scope-extend the branch rather than jumping to unrelated topics.
- Link-id validity and endpoint fidelity: cited links appear valid from the trajectory's own tables and are not obviously invented.
- Path continuity: support is path-like rather than a disconnected list of appealing links.
- Mechanism grounding: the trajectory learns concrete method/failure-mode mechanisms rather than staying at topic level.
- Feedback absorption: later observations update the idea selectively without wholesale reset.
- Conclusion dependence: the final direction is materially constrained by the staged evidence paths.
- Testability: the final proposal has concrete benchmarks, metrics, and failure modes.

## Required Output

For each anonymized case:

- `anonymous_case_id`
- metric scores from 1 to 5
- short rationale
- idea-count alignment concerns, if any
- branch drift concerns, if any
- whether the final direction depends on the evidence path
- uncertainty notes

Then provide a cross-case comparison. Do not guess hidden condition names or mappings.
