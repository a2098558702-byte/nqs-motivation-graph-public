# Data Statement

This repository contains derived research artifacts from a neural quantum states literature-graph project.

## Included

- Derived graph tables: paper ids, node ids, node labels, relation types, years, source sections, evidence locations, confidence flags, candidate-review flags, and paraphrases.
- Mechanical link audits and blind-evaluation outputs.
- Protocols, rubrics, run manifests, and public scripts needed to inspect the included runs.
- Redacted sealed packets sufficient for mechanical link-id and endpoint-audit reproduction.

## Not Included

- Raw PDFs.
- arXiv source packages.
- `.tex`, `.bbl`, `.bib`, `.eprint`, zip, tar, or cache files from source papers.
- Private blind-evaluation condition keys or anonymous-case mappings.
- Local absolute paths to the original research workspace.
- Bulk verbatim source-paper excerpts.

## Redaction Policy

Columns named `evidence` or `evidence_quote` are redacted in the public artifact. Evidence locations are retained so that a licensed local copy of the source paper can be checked by a researcher. Human paraphrases are retained as derived annotations.

## Rebuilding From Raw Sources

Full graph reconstruction requires the private full-text workspace used during extraction. Public reproducibility focuses on:

- validating the released graph summary and schema;
- re-running mechanical link audits for included model trajectories;
- inspecting blind-evaluation packets and post-evaluation unsealed summaries;
- checking that no private mapping keys or raw full-text artifacts are included.

## Citation And Copyright

The source papers remain under their own copyrights and licenses. This repository does not grant redistribution rights for third-party paper text.
