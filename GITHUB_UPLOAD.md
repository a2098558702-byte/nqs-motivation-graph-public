# GitHub Upload Guide

This repository root is the GitHub-ready public artifact.

## What To Upload

Upload the contents of this directory as one repository.

Included:

- `README.md`
- `DATA_STATEMENT.md`
- `REPRODUCIBILITY.md`
- `RELEASE_MANIFEST.md`
- `CITATION.cff`
- `LICENSE`
- `.gitignore`
- `data/`
- `experiments/`
- `protocols/`
- `scripts/`
- `docs/`

Do not upload the original private full-text workspace, raw paper PDFs, arXiv source packages, `.tex`, `.bbl`, `.eprint`, private mapping keys, or local caches.

## Before Upload

Run:

```bash
ruby scripts/redact_public_artifact_v0.rb
ruby scripts/check_public_release_hygiene_v0.rb
ruby scripts/check_edge_dependency_assay_outputs_v0.rb edge_assay_20260519_112535
ruby scripts/check_adaptive_candidate_internal_outputs_v0.rb adaptive_g6_20260519_134255
ruby scripts/check_aligned_g3_g4_g6_outputs_v0.rb aligned_g3_g4_g6_20260519_144241 adaptive_g6_20260519_134255
```

Only upload if all checks pass.

## Create A GitHub Repo

1. Go to GitHub and create a new empty repository.
2. Do not initialize it with a README, license, or `.gitignore`, because this artifact already contains them.
3. Copy the repository SSH or HTTPS URL.

## Push From Terminal

Replace `<repo-url>` with your GitHub repo URL:

```bash
git init
git add .
git commit -m "Release public NQS motivation graph artifact"
git branch -M main
git remote add origin <repo-url>
git push -u origin main
```

## After Upload

Update `CITATION.cff`:

- replace `https://github.com/<your-github-username>/<your-repo-name>` with the actual repository URL;
- consider adding ORCID, DOI, or institutional author metadata if available.

Then make a GitHub release tag, for example:

```bash
git tag v0.1.0
git push origin v0.1.0
```
