# Edge Dependency Assay Run edge_assay_20260519_112535

## Generator Settings

- Model: `gpt-5.2`
- Reasoning effort: `low`
- One generator per sealed unit.
- Search, browsing, directory listing, parent/sibling inspection, metadata inspection, and hidden-label guessing are prohibited.
- Follow the round gate inside each unit's `brief.md`.

## Sealed Units

- `unit_118` -> save output as `rounds/unit_118_trajectory.md`
- `unit_156` -> save output as `rounds/unit_156_trajectory.md`
- `unit_432` -> save output as `rounds/unit_432_trajectory.md`
- `unit_608` -> save output as `rounds/unit_608_trajectory.md`
- `unit_795` -> save output as `rounds/unit_795_trajectory.md`

## After Generation

Run:

```bash
ruby scripts/check_edge_dependency_assay_outputs_v0.rb edge_assay_20260519_112535
ruby scripts/prepare_edge_dependency_blind_evaluation_packet_v0.rb edge_assay_20260519_112535
```

The first command is a mechanical audit only. The second command prepares an anonymized packet for the required blind evaluator.
