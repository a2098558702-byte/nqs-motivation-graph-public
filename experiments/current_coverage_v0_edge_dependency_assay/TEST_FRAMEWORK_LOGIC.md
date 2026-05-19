# Current Coverage V0 Edge Dependency Assay

## Purpose

The existing three-round trajectory test can reward strong node-local synthesis, so a no-link packet can still produce a persuasive research plan. This assay isolates a different question: does an allowed relation layer help a generator build, preserve, and revise auditable support paths?

## Core Design

- Every sealed unit receives the same selected observation items.
- Only the link layer changes across units.
- The task requires explicit path tables with `link_id`, endpoints, and traversal direction.
- A no-link unit is expected to abstain from path claims and therefore score low on the primary relation-dependency metrics.
- The no-link unit may still receive notes for honest node-local fallback quality, but that fallback cannot substitute for relation-path evidence.
- Later rounds unlock new items and new links together, so update quality can be measured as path repair/extension rather than generic feedback absorption.

## Conditions

- `G1 nodes_only`: same selected items, no links.
- `G2 strict_paper_internal`: selected items plus paper-local strict links.
- `G3 clean_candidate_context`: selected items plus endpoint-clean candidate-context links.
- `G4 strict_plus_clean_candidate_context`: selected items plus strict and clean candidate-context links.
- `G5 paper_citation_only`: selected items plus paper-to-paper reference-list links.

## Item Selection

Round 0 uses a compact shared item set selected before sealing:

- all visible paper nodes;
- endpoints of visible clean candidate-context links;
- endpoints of visible paper-citation links;
- up to two strict paper-local targets per visible paper;
- highest union-degree visible nodes until the packet reaches the configured cap.

The selection is reused unchanged for every unit. Updates use all currently available 2024 items in Round 1 and all 2025-2026 items in Round 2.

## Scoring Separation

- Mechanical audit: deterministic script checks cited link ids, endpoint matches, path continuity, and future-round link leakage.
- Qualitative evaluation: blind `gpt-5.5`/`xhigh` evaluator applies `EVALUATION_RUBRIC.md`.
- Controller/main agent may report audit outputs but must not qualitatively score trajectories.

## Contamination Rules

Generator-facing control files must not contain hidden condition names, private mappings, role labels, or metadata hints. Generators may not search, browse, list directories, inspect parent/sibling directories, or pre-read future-round files.
