# Adaptive G6 Candidate-To-Internal Assay

## Purpose

This assay tests a staged external-knowledge structure:

1. Round 0 uses clean candidate-context links as a navigation layer.
2. The generator self-selects a path using explicit selected link/item/paper ids.
3. Round 1 mechanically unlocks strict paper-internal evidence only for selected path papers, plus the same 2024 feedback items used in the other current-coverage assays.
4. Round 2 repeats the process with 2025-2026 feedback and the current selected branch.

The point is to test whether candidate edges are useful for branch selection while strict internal edges are useful for mechanism grounding after a branch has been selected.

## No Manual Branch Choice

The controller does not choose the branch. `scripts/prepare_adaptive_candidate_internal_round_v0.rb` parses the generator's selected ids and unlocks internal nodes/links mechanically.

## Model Roles

- Generator: `gpt-5.2`, reasoning effort `low`.
- Blind evaluator, if run: `gpt-5.5`, reasoning effort `xhigh`.
- Controller/main agent must not substitute qualitative judgment for the evaluator.
