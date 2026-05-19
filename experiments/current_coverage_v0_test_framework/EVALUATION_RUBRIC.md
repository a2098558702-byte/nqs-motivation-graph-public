# Current Coverage V0 Evaluation Rubric

Score each trajectory from 1 to 5 on each metric.

## Metrics

- Goal preservation: stable bottleneck across rounds.
- Feedback absorption selectivity: feedback changes the idea without wholesale reset.
- Evidence-path faithfulness: support follows visible nodes and allowed edges.
- Edge-condition sensitivity: trajectory role reflects the edge condition.
- Branch-local update: revisions move through nearby graph structure.
- Mechanism specificity: idea names a concrete physical, optimization, architectural, or measurement mechanism.
- Testability: final direction includes a realistic benchmark, diagnostic, or falsification path.
- Drift control: avoids keyword-following and keeps a coherent research line.

## Qualitative Labels

Use one or more:

- node-local synthesis
- paper-internal argument logic
- candidate-lineage trajectory
- method-lineage / scaling
- physical diagnostic / tension
- benchmark adjudication
- integrated research program
- keyword drift / loose brainstorm

## Blindness Rule

Evaluate all sealed-unit trajectories before opening `condition_key_private.csv`.

## Required Evaluator

This blind evaluation must be performed by `gpt-5.5` with reasoning effort `xhigh`.

The controller/main agent must not substitute its own judgment for this blind evaluation.

## Required Output Schema

For each anonymized trajectory:

- `anonymous_case_id`
- metric scores from 1 to 5
- qualitative labels
- short evidence-grounded rationale
- suspected trajectory role, without guessing hidden condition names
- uncertainty notes

Also provide a cross-case comparison that does not reveal or guess hidden condition mappings.
