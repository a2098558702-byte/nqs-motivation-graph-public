# Adaptive G6 Candidate-To-Internal Assay

This experiment tests a staged graph-control design:

- use candidate-context edges to select a promising branch;
- unlock strict paper-internal edges only for that selected branch;
- revise the same idea over three rounds using branch-local mechanism evidence.

## Question

Can candidate edges act as a branch-navigation policy while strict internal edges act as mechanism-grounding evidence?

## Three-Round Flow

- Round 0: candidate-context paths propose one idea and select a branch.
- Round 1: strict internal links for the selected branch are unlocked.
- Round 2: the same branch is updated again with internal mechanism evidence and feedback.

## Included Run

- `model_runs/adaptive_g6_20260519_134255/`

## Main Finding

The mechanical link audit found:

- round0: 3/3 valid link steps;
- round1: 7/7 valid link steps;
- round2: 10/10 valid link steps;
- continuity breaks: 0.

This supports the staged G6 design under this single run.

## What To Read

1. `TEST_FRAMEWORK_LOGIC.md`
2. `model_runs/adaptive_g6_20260519_134255/rounds/unit_906_trajectory.md`
3. `model_runs/adaptive_g6_20260519_134255/audits/ADAPTIVE_LINK_AUDIT.md`
