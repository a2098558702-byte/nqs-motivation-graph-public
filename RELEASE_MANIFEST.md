# Release Manifest

Snapshot date: 2026-05-19

## Artifact

Name: `nqs-motivation-graph-public`

Purpose: public research artifact for studying external literature-graph structure as a control signal for LLM research-trajectory generation.

## Data Summary

- 60 source papers represented by derived metadata.
- 542 evidence nodes.
- 594 strict paper-internal edges.
- 77 candidate development/context edges.
- 261 paper-citation edges.
- 60 / 60 source papers have available reference-list coverage in the private reconstruction log.

## Included Runs

- `edge_assay_20260519_112535`
- `adaptive_g6_20260519_134255`
- `aligned_g3_g4_g6_20260519_144241`

## Public-Release Safeguards

- No raw full-text paper files are included.
- No private condition keys are included.
- No local absolute paths should remain after `ruby scripts/redact_public_artifact_v0.rb`.
- `evidence` and `evidence_quote` CSV columns are redacted.
- Mechanical audit reproduction uses redacted packet tables and does not require source-paper excerpts.

## Before GitHub Push

Run:

```bash
ruby scripts/redact_public_artifact_v0.rb
ruby scripts/check_public_release_hygiene_v0.rb
git status --short
```
