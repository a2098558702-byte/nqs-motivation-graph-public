# NQS Full-Text 100plus Run V0 Progress Log

This file records durable progress for the NQS motivation graph full expansion. Any agent working on this run should update this file after each coherent work unit.

## Logging Format

```text
## YYYY-MM-DD HH:MM CST - Short action title

- Action:
- Files changed / inspected:
- Counts:
- Quality concerns:
- Next action:
```

## 2026-05-18 21:52 CST - Expansion plan recording started

- Action: Created the durable implementation plan for expanding the NQS motivation graph using the first 10-paper J1-J2 strict pilot as the gold standard.
- Files changed / inspected:
  - `Outputs/NQS Motivation Graph Full Expansion Implementation Plan V0.md`
  - `Data/Motivation Graph Agent V0/NQS_J1J2_Strict_Pilot/`
  - `Data/Motivation Graph Agent V0/NQS_FullText_Evidence_Batches/j1j2_repair_batch_v0/`
  - `Data/Motivation Graph Agent V0/NQS_FullText_Evidence_Batches/fulltext_100plus_run_v0/`
- Counts:
  - Remaining manifest currently contains 206 paper candidates plus header.
  - Current fulltext run batch status remains pending for all 24 manifest batches.
- Quality concerns:
  - First-pass expansion should not ask workers to create broad strict cross-paper development edges from arbitrary batches.
  - Cross-paper development relations must be calibrated against the 10-paper pilot and strict evidence rules.
- Next action: Link this plan from `AGENTS.md` and update `RUN_PROTOCOL.md` so future workers follow the paper-local-first workflow.

## 2026-05-18 22:09 CST - Gold-standard calibration pack created

- Action: Created a worker-facing calibration pack from the 10-paper strict pilot and J1-J2 full-text repair batch.
- Files changed / inspected:
  - `Outputs/NQS Motivation Graph Gold Standard Calibration Pack V0.md`
  - `Data/Motivation Graph Agent V0/NQS_J1J2_Strict_Pilot/edges.csv`
  - `Data/Motivation Graph Agent V0/NQS_J1J2_Strict_Pilot/human_review_edges.md`
  - `Data/Motivation Graph Agent V0/NQS_FullText_Evidence_Batches/j1j2_repair_batch_v0/fulltext_evidence_nodes_v0.csv`
  - `Data/Motivation Graph Agent V0/NQS_FullText_Evidence_Batches/j1j2_repair_batch_v0/fulltext_evidence_edges_v0.csv`
  - `Data/Motivation Graph Agent V0/NQS_FullText_Evidence_Batches/j1j2_repair_batch_v0/development_edge_candidates_v0.csv`
  - `AGENTS.md`
  - `RUN_PROTOCOL.md`
- Counts:
  - Calibration pack includes accepted node examples, paper-internal edge examples, strict cross-paper development edge examples, candidate/human-review examples, and rejected edge patterns.
- Quality concerns:
  - The calibration pack is intentionally conservative: broad motivation relations are useful but should start as candidates unless full-text evidence upgrades them.
- Next action: Generate branch-level assignment tables for the 206 remaining paper candidates so the first extraction wave can be paper-local but still branch-aware.

## 2026-05-18 22:13 CST - Branch assignment manifest generated

- Action: Added a reproducible script and generated a branch-aware view of the 206-paper manifest.
- Files changed / inspected:
  - `scripts/build_branch_assignments.rb`
  - `manifests/branch_assignment_v0.csv`
  - `manifests/branch_assignment_summary_v0.md`
  - `RUN_PROTOCOL.md`
- Counts:
  - 206 papers assigned.
  - Primary branch counts: frustrated_spin_j1j2 57; optimization_sr_minsr_linear_scalable 33; fermionic_chemistry_hubbard 32; architecture_cnn_gcnn_rnn_transformer_foundation 25; dynamics_time_evolution 14; general_nqs_expressivity 14; sign_structure_symmetry 13; tomography_experimental_reconstruction 12; review_benchmark_meta_comparison 6.
  - Extraction priorities: high 59; medium 102; standard 45.
- Quality concerns:
  - Primary branch is only an organizing label and must not be treated as evidence.
  - Some multi-tag papers may need cross-branch linking later; secondary branches were preserved.
- Next action: Generate branch workpacks and a worker prompt / extraction instruction that enforces paper-local-first extraction.

## 2026-05-18 22:15 CST - Branch workpacks and prompts created

- Action: Generated branch-level workpacks and wrote reusable worker/controller prompts for the full-text expansion.
- Files changed / inspected:
  - `workpacks/README.md`
  - `workpacks/*.csv`
  - `prompts/paper_local_extraction_worker_prompt_v0.md`
  - `prompts/controller_branch_linking_prompt_v0.md`
  - `scripts/build_branch_assignments.rb`
  - `RUN_PROTOCOL.md`
- Counts:
  - 9 branch workpacks created.
  - Workpack paper counts: frustrated_spin_j1j2 57; optimization_sr_minsr_linear_scalable 33; fermionic_chemistry_hubbard 32; architecture_cnn_gcnn_rnn_transformer_foundation 25; dynamics_time_evolution 14; general_nqs_expressivity 14; sign_structure_symmetry 13; tomography_experimental_reconstruction 12; review_benchmark_meta_comparison 6.
- Quality concerns:
  - Worker prompt deliberately forbids broad strict cross-paper edge generation in first pass.
  - Controller prompt should be used later for branch-local linking after paper-local outputs exist.
- Next action: Start a small verified extraction wave, preferably on a high-priority subset of the `frustrated_spin_j1j2` workpack, before scaling to all 206 papers.

## 2026-05-18 22:24 CST - Frustrated-spin pilot wave V0 extracted

- Action: Created and ran the first small verified paper-local extraction wave for `frustrated_spin_j1j2`.
- Files changed / inspected:
  - `scripts/build_pilot_wave.rb`
  - `extraction_waves/frustrated_spin_pilot_wave_v0/manifest.csv`
  - `extraction_waves/frustrated_spin_pilot_wave_v0/source_status.csv`
  - `extraction_waves/frustrated_spin_pilot_wave_v0/section_map.csv`
  - `extraction_waves/frustrated_spin_pilot_wave_v0/fulltext_evidence_nodes.csv`
  - `extraction_waves/frustrated_spin_pilot_wave_v0/fulltext_evidence_edges.csv`
  - `extraction_waves/frustrated_spin_pilot_wave_v0/development_edge_candidates.csv`
  - `extraction_waves/frustrated_spin_pilot_wave_v0/protocol_notes.md`
  - `extraction_waves/frustrated_spin_pilot_wave_v0/extraction_log.md`
- Counts:
  - Selected papers: 6.
  - Source found: 6 arXiv e-print TeX sources.
  - Section-map rows: 25.
  - Evidence nodes: 40.
  - Strict evidence edges: 47.
  - Cross-paper candidate edges: 3.
  - Strict edge endpoint errors: 0.
  - Strict `needs_human_check=true`: 0.
  - Strict `is_inferred=true`: 0.
- Quality concerns:
  - This wave intentionally keeps cross-paper development relations as candidates, not strict edges.
  - The candidate edges suggest a useful local trajectory from sign/frustration pressure toward hybrid ansatz, lattice inductive bias, and transformer feature extraction, but this should only be upgraded during branch-level linking.
- Next action: Review this pilot wave for protocol pressure points, then either expand the frustrated-spin wave to more high-priority papers or run a parallel small wave in optimization/architecture for comparison.

## 2026-05-18 22:40 CST - Optimization pilot wave V0 extracted

- Action: Completed the second small verified paper-local extraction wave for `optimization_sr_minsr_linear_scalable`.
- Files changed / inspected:
  - `extraction_waves/optimization_pilot_wave_v0/manifest.csv`
  - `extraction_waves/optimization_pilot_wave_v0/source_status.csv`
  - `extraction_waves/optimization_pilot_wave_v0/section_map.csv`
  - `extraction_waves/optimization_pilot_wave_v0/fulltext_evidence_nodes.csv`
  - `extraction_waves/optimization_pilot_wave_v0/fulltext_evidence_edges.csv`
  - `extraction_waves/optimization_pilot_wave_v0/development_edge_candidates.csv`
  - `extraction_waves/optimization_pilot_wave_v0/protocol_notes.md`
  - `extraction_waves/optimization_pilot_wave_v0/extraction_log.md`
  - `Outputs/Optimization Pilot Wave V0 Result.md`
- Counts:
  - Selected papers: 6.
  - Source found: 6 arXiv e-print TeX sources.
  - Section-map rows: 38.
  - Evidence nodes: 51.
  - Strict evidence edges: 64.
  - Cross-paper candidate edges: 6.
  - Strict edge endpoint errors: 0.
  - Candidate edge endpoint errors: 0.
  - Strict `needs_human_check=true`: 0.
  - Strict `is_inferred=true`: 0.
  - Candidate `needs_human_check=true`: 6.
- Quality concerns:
  - Candidate edges involving NQSC109 and NQSC085 have strong citation-context support, but they remain candidates until branch-local linking upgrades them.
  - The optimization branch should not be compressed into optimizer names; its useful nodes include sampling bottlenecks, local-energy bottlenecks, QFM geometry, scalability design, and regime-specific failure modes.
- Next action: Run a small verified architecture / transformer wave to compare whether architecture papers form method lineage, inductive-bias responses, or scaling responses.

## 2026-05-18 23:22 CST - Architecture pilot wave V0 extracted

- Action: Completed the third small verified paper-local extraction wave for `architecture_cnn_gcnn_rnn_transformer_foundation`.
- Files changed / inspected:
  - `extraction_waves/architecture_pilot_wave_v0/manifest.csv`
  - `extraction_waves/architecture_pilot_wave_v0/source_status.csv`
  - `extraction_waves/architecture_pilot_wave_v0/section_map.csv`
  - `extraction_waves/architecture_pilot_wave_v0/fulltext_evidence_nodes.csv`
  - `extraction_waves/architecture_pilot_wave_v0/fulltext_evidence_edges.csv`
  - `extraction_waves/architecture_pilot_wave_v0/development_edge_candidates.csv`
  - `extraction_waves/architecture_pilot_wave_v0/protocol_notes.md`
  - `extraction_waves/architecture_pilot_wave_v0/extraction_log.md`
  - `Outputs/Architecture Pilot Wave V0 Result.md`
- Counts:
  - Selected papers: 6.
  - Source found: 6 arXiv e-print TeX sources.
  - Section-map rows: 35.
  - Evidence nodes: 60.
  - Strict evidence edges: 75.
  - Cross-paper candidate edges: 8.
  - Strict edge endpoint errors: 0.
  - Candidate edge endpoint errors: 0.
  - Strict `needs_human_check=true`: 0.
  - Strict `is_inferred=true`: 0.
  - Candidate `needs_human_check=true`: 8.
- Quality concerns:
  - Architecture relations are mixed: expressivity, exact sampling, physical inductive bias, task transfer, self-attention, and basis interpretability should not be collapsed into one generic `method-extension` edge.
  - TQS-to-physics-informed-basis and Barrett-style unique-string sampling relations have strong citation-context support but remain candidates until controller review.
- Next action: Use the three verified waves together for branch-level linking: frustrated spin for physical benchmark pressure, optimization for scaling bottleneck pressure, and architecture for representation / inductive-bias pressure.

## 2026-05-18 23:40 CST - Three-wave branch-linking preview created

- Action: Reviewed candidate development edges from the frustrated-spin, optimization, and architecture pilot waves before formal branch-level linking.
- Files changed / inspected:
  - `controller_linking_preview_v0/candidate_upgrade_review.csv`
  - `controller_linking_preview_v0/branch_pressure_units.csv`
  - `controller_linking_preview_v0/branch_linking_preview_report.md`
  - `extraction_waves/frustrated_spin_pilot_wave_v0/development_edge_candidates.csv`
  - `extraction_waves/optimization_pilot_wave_v0/development_edge_candidates.csv`
  - `extraction_waves/architecture_pilot_wave_v0/development_edge_candidates.csv`
- Counts:
  - Candidate relations reviewed: 17.
  - Upgrade-ready candidates: 4.
  - Needs-retarget candidates: 2.
  - Candidate-only relations: 9.
  - Internal-future-only relations: 2.
- Quality concerns:
  - Several relations are scientifically useful but still too broad for strict evidence edges.
  - Two promising relations need source-node retargeting before upgrade.
- Next action: Build a small cross-wave branch-level graph from the 18 verified papers before scaling to all 206 papers.

## 2026-05-18 23:58 CST - Cross-wave branch graph V0 built

- Action: Built the first small branch-level graph from the three verified pilot waves and wrote a result memo.
- Files changed / inspected:
  - `scripts/build_cross_wave_branch_graph_v0.rb`
  - `cross_wave_branch_graph_v0/cross_wave_evidence_nodes.csv`
  - `cross_wave_branch_graph_v0/cross_wave_evidence_edges.csv`
  - `cross_wave_branch_graph_v0/cross_wave_strict_development_edges.csv`
  - `cross_wave_branch_graph_v0/cross_wave_candidate_edges_reviewed.csv`
  - `cross_wave_branch_graph_v0/branch_pressure_units.csv`
  - `cross_wave_branch_graph_v0/node_wave_index.csv`
  - `cross_wave_branch_graph_v0/edge_wave_index.csv`
  - `cross_wave_branch_graph_v0/graph_variants/`
  - `cross_wave_branch_graph_v0/README.md`
  - `Outputs/Cross-Wave Branch Graph V0 Result.md`
- Counts:
  - Papers: 18.
  - Evidence nodes: 151.
  - Evidence edges total: 190.
  - Paper-local/internal strict edges: 186.
  - Strict cross-wave development edges: 4.
  - Reviewed candidate development edges: 17.
  - Endpoint errors: 0.
  - Strict `is_inferred=true`: 0.
  - Strict `needs_human_check=true`: 0.
- Quality concerns:
  - Only 4 cross-paper relations were upgraded; this is intentionally conservative.
  - Several scientifically useful relations remain candidate-only because they lack hard enough evidence.
- Next action: Run a controlled trajectory experiment on the small graph variants with the same seed, cutoff, and feedback packet.

## 2026-05-19 07:43 CST - Cross-wave graph variants clarified and rebuilt

- Action: Rebuilt `cross_wave_branch_graph_v0` after making the build script regenerate the README and all experimental graph variants.
- Files changed / inspected:
  - `scripts/build_cross_wave_branch_graph_v0.rb`
  - `cross_wave_branch_graph_v0/README.md`
  - `cross_wave_branch_graph_v0/graph_variants/nodes_only_nodes.csv`
  - `cross_wave_branch_graph_v0/graph_variants/empty_edges_for_nodes_only.csv`
  - `cross_wave_branch_graph_v0/graph_variants/paper_internal_edges_only.csv`
  - `cross_wave_branch_graph_v0/graph_variants/strict_development_edges_only.csv`
  - `cross_wave_branch_graph_v0/graph_variants/citation_context_plus_strict_development_edges.csv`
  - `cross_wave_branch_graph_v0/graph_variants/all_strict_evidence_edges.csv`
- Validation:
  - Evidence nodes: 151.
  - Evidence edges total: 190.
  - Paper-local/internal strict edges: 186.
  - Strict cross-wave development edges: 4.
  - Endpoint errors: 0.
  - Strict `is_inferred=true`: 0.
  - Strict `needs_human_check=true`: 0.
- Next action: Start a controlled trajectory experiment using the same seed, cutoff, and feedback packet while varying only the edge condition.

## 2026-05-19 08:05 CST - Cross-wave edge-schema trajectory test V0 created

- Action: Created and ran a preliminary controlled trajectory experiment on the 18-paper full-text cross-wave graph.
- Raw folder:
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/`
- Files created:
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/EXPERIMENT_PROTOCOL.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/EVALUATION_RUBRIC.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/input_summary.csv`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/inputs/G1_generator_prompt.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/inputs/G2_generator_prompt.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/inputs/G3_generator_prompt.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/inputs/G4_generator_prompt.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/inputs/feedback_round1_paper_nodes.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/inputs/feedback_round2_paper_nodes.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/rounds/G1_trajectory.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/rounds/G2_trajectory.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/rounds/G3_trajectory.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/rounds/G4_trajectory.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/analysis/controller_preliminary_analysis.md`
  - `Outputs/Cross-Wave V0 Edge-Schema Trajectory Test Result.md`
  - `scripts/build_cross_wave_trajectory_experiment_v0.rb`
- Setup:
  - Cutoff: 2022.
  - Visible nodes per condition: 114.
  - G1 visible edges: 0.
  - G2 visible edges: 138.
  - G3 visible edges: 2.
  - G4 visible edges: 140.
- Preliminary result:
  - Nodes-only produced node-local synthesis.
  - Paper-internal-only produced paper-level argument / evidence-chain logic.
  - Strict-development-only produced cross-paper method-lineage logic.
  - All-strict-evidence produced an integrated but broader research-program trajectory.
- Limitation:
  - This is not a strict blind evaluation because the controller opened `condition_key_private.csv` during validation.
- Next action:
  - Run a hidden-key evaluator over the four generated trajectories using only `EVALUATION_RUBRIC.md`; then compare the evaluator's role labels with the actual condition key.

## 2026-05-19 08:14 CST - Hidden-key evaluation recovered edge-schema roles

- Action: Ran a separate hidden-key evaluator over the four anonymized trajectories.
- Files created / updated:
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/analysis/hidden_key_eval_v0/EVALUATOR_PROMPT.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/analysis/hidden_key_eval_v0/README.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/analysis/hidden_key_eval_v0/blind_input_bundle/`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/analysis/hidden_key_eval_v0/HIDDEN_KEY_EVALUATION_RESULT.md`
  - `trajectory_experiments/cross_wave_v0_edge_schema_test_v0/analysis/hidden_key_eval_v0/HIDDEN_KEY_COMPARISON.md`
  - `Outputs/Cross-Wave V0 Edge-Schema Trajectory Test Result.md`
  - `Outputs/AI Physicists Experiment Result Index.md`
- Hidden-key result:
  - G1 was classified as node-local / semantic synthesis.
  - G2 was classified as paper-internal argument logic / evidence-chain validation.
  - G3 was classified as method-lineage / cross-paper field trajectory.
  - G4 was classified as integrated research program.
- Match with actual key:
  - G1 = nodes-only: matched.
  - G2 = paper-internal-only: matched.
  - G3 = strict-development-only: matched.
  - G4 = all-strict-evidence: matched.
- Updated interpretation:
  - Edge schema appears to leave recognizable signatures in multi-round research trajectories.
  - Paper-internal edges behave like scientific-argument priors.
  - Cross-paper development edges behave like field-trajectory priors.
  - Hybrid strict evidence behaves like a broader research-program prior.
- Remaining limitation:
  - The trajectories were controller-written. The next replication should use independent generator agents for G1-G4, then repeat hidden-key evaluation.

## 2026-05-19 08:26 CST - High-priority mixed coverage wave completed

- Action: Paused trajectory experiments and returned to evidence-first NQS graph expansion toward 100+ papers.
- Wave completed:
  - `extraction_waves/high_priority_mixed_coverage_wave_v0/`
- Papers extracted:
  - NQSC026, NQSC002, NQSC003, NQSC030, NQSC083, NQSC007, NQSC010, NQSC011, NQSC037, NQSC059, NQSC117, NQSC129.
- Files updated:
  - `extraction_waves/high_priority_mixed_coverage_wave_v0/fulltext_evidence_nodes.csv`
  - `extraction_waves/high_priority_mixed_coverage_wave_v0/fulltext_evidence_edges.csv`
  - `extraction_waves/high_priority_mixed_coverage_wave_v0/development_edge_candidates.csv`
  - `extraction_waves/high_priority_mixed_coverage_wave_v0/section_map.csv`
  - `extraction_waves/high_priority_mixed_coverage_wave_v0/protocol_notes.md`
  - `extraction_waves/high_priority_mixed_coverage_wave_v0/extraction_log.md`
  - `scripts/populate_high_priority_mixed_wave_v0.rb`
- Counts:
  - 12 papers.
  - 94 evidence nodes.
  - 82 strict evidence edges.
  - 15 cross-paper candidate edges.
- Validation:
  - Strict edge endpoint errors: 0.
  - Strict `is_inferred=true`: 0.
  - Strict `needs_human_check=true`: 0.
  - Candidate endpoint errors against current extracted waves: 0.
  - Candidate `needs_human_check=false`: 0.
- Strict-standard note:
  - Cross-paper relations were not relaxed into the strict graph.
  - Strong-looking but unreviewed cross-paper links were preserved only in `development_edge_candidates.csv`.
- Current totals across completed extraction waves:
  - 30 papers.
  - 245 evidence nodes.
  - 268 strict evidence edges.
  - 32 candidate edges.
- Next action:
  - Continue coverage expansion rather than trajectory experiments.
  - Prefer branch-aware waves that fill NQS gaps: fermionic/chemistry, tomography/open systems/dynamics, foundational expressivity, and recent transformer/foundation-NQS lines.

## 2026-05-19 08:44 CST - Chemistry/sampling/symmetry wave setup completed

- Action:
  - Created a new branch-aware expansion wave for fermionic chemistry, sign/symmetry, sampling, and late electronic-structure NQS pressure.
  - Added a reusable setup script that builds a wave, downloads arXiv e-print sources, extracts TeX, identifies main TeX files, and writes a section map.
  - Added a reusable merge/validation script for worker outputs so central CSV files are not hand-merged.
- Files created / updated:
  - `scripts/build_branch_wave_with_sources.rb`
  - `scripts/merge_worker_outputs_and_validate_wave.rb`
  - `extraction_waves/chemistry_sampling_symmetry_wave_v0/manifest.csv`
  - `extraction_waves/chemistry_sampling_symmetry_wave_v0/source_status.csv`
  - `extraction_waves/chemistry_sampling_symmetry_wave_v0/section_map.csv`
  - `extraction_waves/chemistry_sampling_symmetry_wave_v0/protocol_notes.md`
  - `extraction_waves/chemistry_sampling_symmetry_wave_v0/extraction_log.md`
- Counts:
  - Selected papers: 14.
  - Source mapped: 14 arXiv TeX sources.
  - Section-map rows: 380.
- Quality concerns:
  - This wave is rich in cross-paper method lineage, but strict graph rules remain unchanged.
  - Worker outputs must keep strict paper-local/internal edges separate from unreviewed development candidates.
- Next action:
  - Merge worker outputs after extraction, validate endpoints and strict/candidate separation, then update the run totals.

## 2026-05-19 08:53 CST - Chemistry/sampling/symmetry wave extracted and merged

- Action:
  - Merged four independent worker shards for `chemistry_sampling_symmetry_wave_v0`.
  - Filtered a duplicate non-manifest NQSC117 shard so this wave only counts its 14 selected papers.
  - Quarantined one worker-marked review edge from strict into candidate layer.
  - Preserved unresolved cross-paper/bibkey endpoints as candidate warnings for later controller retargeting rather than relaxing strict evidence.
- Files created / updated:
  - `extraction_waves/chemistry_sampling_symmetry_wave_v0/fulltext_evidence_nodes.csv`
  - `extraction_waves/chemistry_sampling_symmetry_wave_v0/fulltext_evidence_edges.csv`
  - `extraction_waves/chemistry_sampling_symmetry_wave_v0/development_edge_candidates.csv`
  - `extraction_waves/chemistry_sampling_symmetry_wave_v0/validation_report.md`
  - `extraction_waves/chemistry_sampling_symmetry_wave_v0/extraction_log.md`
  - `scripts/merge_worker_outputs_and_validate_wave.rb`
- Wave counts:
  - Papers: 14.
  - Evidence nodes: 147.
  - Strict evidence edges: 140.
  - Candidate edges: 33.
- Validation:
  - Strict endpoint errors: 0.
  - Strict `is_inferred=true`: 0.
  - Strict `needs_human_check=true`: 0.
  - Candidate endpoint warnings: 16, retained as non-fatal candidate-layer retargeting tasks.
- Current totals across completed extraction waves:
  - Papers: 44.
  - Evidence nodes: 392.
  - Strict evidence edges: 408.
  - Candidate edges: 65.
- Next action:
  - Continue coverage expansion toward 100+ papers.
  - Best next wave: dynamics/time evolution + tomography/experimental reconstruction, because current graph is now relatively strong on frustrated spin, architecture, optimization, and fermionic chemistry.

## 2026-05-19 09:33 CST - Dynamics/tomography/open-system wave extracted and merged

- Action:
  - Completed `dynamics_tomography_wave_v0` from the imported latest Codex/OpenAI thread context.
  - Added a repeatable population script and wrote four worker-output shards for early tomography/generative methods, open-system and real-time dynamics, later tomography scaling, and late dynamics stability.
  - Merged worker outputs with the existing wave merge/validation script.
  - Corrected the wave protocol notes branch-pressure section, which had been copied from the chemistry wave.
- Files created / updated:
  - `scripts/populate_dynamics_tomography_wave_v0.rb`
  - `extraction_waves/dynamics_tomography_wave_v0/worker_outputs/`
  - `extraction_waves/dynamics_tomography_wave_v0/fulltext_evidence_nodes.csv`
  - `extraction_waves/dynamics_tomography_wave_v0/fulltext_evidence_edges.csv`
  - `extraction_waves/dynamics_tomography_wave_v0/development_edge_candidates.csv`
  - `extraction_waves/dynamics_tomography_wave_v0/validation_report.md`
  - `extraction_waves/dynamics_tomography_wave_v0/protocol_notes.md`
  - `extraction_waves/dynamics_tomography_wave_v0/extraction_log.md`
- Wave counts:
  - Papers: 16.
  - Evidence nodes: 150.
  - Strict evidence edges: 186.
  - Candidate edges: 12.
- Validation:
  - Strict endpoint errors: 0.
  - Strict `is_inferred=true`: 0.
  - Strict `needs_human_check=true`: 0.
  - Candidate endpoint warnings: 0.
  - Candidate `needs_human_check=false`: 0.
  - Candidate `graph_layer` errors: 0.
- Current totals across completed extraction waves:
  - Papers: 60.
  - Evidence nodes: 542.
  - Strict evidence edges: 594.
  - Candidate edges: 77.
- Quality concerns:
  - Cross-paper relations involving QuCumber, Liouvillian gap, non-Markovian DQME, and TDVP instability have strong-looking evidence but remain candidate-only until controller review.
  - The wave uses concise evidence quotes and paper-local strict edges; downstream controller work should retarget or upgrade only after branch-local inspection.
- Next action:
  - Continue evidence coverage toward 100+ papers, or run a controller review over dynamics/tomography candidate edges if the next phase needs branch-level trajectories.

## 2026-05-19 09:48 CST - Current-coverage graph test framework solidified

- Action:
  - Paused paper expansion and formalized a reusable test framework over the current 60-paper evidence graph.
  - Added a current-coverage graph builder that merges all completed extraction waves into one graph package with strict edges, raw candidates, clean candidate-context variants, indexes, counts, and validation reports.
  - Added a test-framework builder that rebuilds the graph, writes condition-specific inputs, prompts, feedback packets, evaluation rubric, runbook, and deterministic retrieval probes.
  - Ran the framework builder successfully and generated deterministic sanity-check outputs.
- Files created / updated:
  - `scripts/build_current_coverage_graph_v0.rb`
  - `scripts/build_current_coverage_test_framework_v0.rb`
  - `current_coverage_graph_v0/`
  - `trajectory_experiments/current_coverage_v0_test_framework/`
- Current graph counts:
  - Papers: 60.
  - Evidence nodes: 542.
  - Strict edges: 594.
  - Raw candidate edges: 77.
  - Endpoint-resolved candidate-context edges: 61.
  - Clean candidate-context edges: 44.
  - Candidate review backlog rows: 33.
  - Strict endpoint errors: 0.
  - Strict bad flags: 0.
- Test condition sizes at cutoff 2023:
  - `G1 nodes_only`: 418 visible nodes, 0 visible edges.
  - `G2 strict_paper_internal`: 418 visible nodes, 459 visible edges.
  - `G3 clean_candidate_context`: 418 visible nodes, 26 visible edges.
  - `G4 strict_plus_clean_candidate_context`: 418 visible nodes, 485 visible edges.
- Deterministic probe outputs:
  - Probe result rows: 240.
  - Probe edge-hit rows: 394.
  - Probe report: `trajectory_experiments/current_coverage_v0_test_framework/analysis/deterministic_probe_report.md`.
- Quality concerns:
  - Candidate-context variants are experimental only and do not upgrade candidate edges.
  - Candidate-only deterministic probes can look weak when candidate endpoints are not lexical matches; model-trajectory testing is still needed for the main edge-schema claim.
  - `candidate_review_backlog.csv` records unresolved or legacy-format candidate rows that should be retargeted/normalized before controller upgrades.
- Next action:
  - Use `trajectory_experiments/current_coverage_v0_test_framework/inputs/G*_generator_prompt.md` to run blind generator trajectories, then evaluate with `EVALUATION_RUBRIC.md` before opening `condition_key_private.csv`.

## 2026-05-19 10:09 CST - Sealed no-search trial protocol added after contamination concern

- Action:
  - Identified a contamination risk in the initial `G1`-`G4` generation attempt: generator-facing prompts and filenames exposed suggestive role labels such as `candidate_context`, `strict_paper_internal`, and condition names.
  - Moved the initial generated trajectories to `trajectory_experiments/contaminated_current_coverage_v0_20260519_initial_run/` and marked them invalid for experiment conclusions.
  - Updated the framework generator so valid model-generation trials use a separate neutral sealed packet:
    - `trajectory_experiments/sealed_trial_v0/unit_104/`
    - `trajectory_experiments/sealed_trial_v0/unit_287/`
    - `trajectory_experiments/sealed_trial_v0/unit_563/`
    - `trajectory_experiments/sealed_trial_v0/unit_829/`
  - Sealed unit prompts now explicitly forbid search, browsing, directory listing, parent/sibling inspection, and opening files outside the assigned unit directory.
  - Generator-facing files avoid control-layer terms such as `candidate`, `strict`, `paper_internal`, `nodes_only`, `edge_schema`, `condition`, `G1`, `G2`, `G3`, `G4`, and `current_coverage`.
  - Added an automatic sealed-packet audit generated by the script.
- Files created / updated:
  - `scripts/build_current_coverage_test_framework_v0.rb`
  - `trajectory_experiments/sealed_trial_v0/`
  - `trajectory_experiments/current_coverage_v0_test_framework/SEALED_PACKET_AUDIT.md`
  - `trajectory_experiments/current_coverage_v0_test_framework/blind_condition_key_private.csv`
  - `trajectory_experiments/current_coverage_v0_test_framework/sealed_packet_manifest.csv`
  - `trajectory_experiments/contaminated_current_coverage_v0_20260519_initial_run/CONTAMINATION_NOTE.md`
- Sealed packet audit:
  - Control-layer sensitive terms found: 0.
  - Scientific data files may naturally contain words like boundary conditions or conditional GAN; those are evidence content and are not treated as control-layer leakage.
- Current sealed unit sizes:
  - `unit_104`: 418 visible items, 0 visible links.
  - `unit_287`: 418 visible items, 459 visible links.
  - `unit_563`: 418 visible items, 26 visible links.
  - `unit_829`: 418 visible items, 485 visible links.
- Quality concerns:
  - Future valid generator runs must use only one assigned `sealed_trial_v0/unit_*` directory and must not inspect framework/key/log/script files.
  - The contaminated initial `G1`-`G4` trajectories are retained only as audit evidence and should not be evaluated as valid results.
- Next action:
  - Rerun model trajectories using only sealed unit prompts, then evaluate before opening `blind_condition_key_private.csv`.

## 2026-05-19 10:30 CST - Paper-citation condition and round-gated sealed protocol added

- Action:
  - Added a separate paper-to-paper citation layer to the current-coverage graph builder.
  - The citation layer is generated locally from each source paper's own reference-list files and matches corpus papers by arXiv ID or exact normalized title.
  - Reference extraction now prefers actual reference lists (`.bbl` and references `.tex`); `.bib` files are used only when no actual reference list exists for that source paper.
  - Added a fifth internal test condition, `G5 paper_citation_only`, while keeping generator-facing sealed files neutral.
  - Tightened sealed briefs with round-gated access: Round 0 uses only `items.csv` and `links.csv`; Round 1 unlocks `update_a.md`; Round 2 unlocks `update_b.md`.
- Files created / updated:
  - `scripts/build_current_coverage_graph_v0.rb`
  - `scripts/build_current_coverage_test_framework_v0.rb`
  - `current_coverage_graph_v0/paper_citation_edges.csv`
  - `current_coverage_graph_v0/paper_citation_source_coverage.csv`
  - `current_coverage_graph_v0/graph_variants/paper_citation_edges_only.csv`
  - `trajectory_experiments/sealed_trial_v0/unit_641/`
  - `trajectory_experiments/current_coverage_v0_test_framework/TEST_FRAMEWORK_LOGIC.md`
  - `trajectory_experiments/current_coverage_v0_test_framework/EXPERIMENT_PROTOCOL.md`
- Current citation counts:
  - Paper citation edges across all years: 224.
  - Sources with usable reference-list files: 46 / 60.
  - `G5 paper_citation_only`: 418 visible nodes, 137 visible links at cutoff 2023.
- Current condition sizes at cutoff 2023:
  - `G1 nodes_only`: 418 visible nodes, 0 visible links.
  - `G2 strict_paper_internal`: 418 visible nodes, 459 visible links.
  - `G3 clean_candidate_context`: 418 visible nodes, 26 visible links.
  - `G4 strict_plus_clean_candidate_context`: 418 visible nodes, 485 visible links.
  - `G5 paper_citation_only`: 418 visible nodes, 137 visible links.
- Sealed packet audit:
  - Control-layer sensitive terms found: 0.
  - Audit now also checks for `G5`, `citation`, `cites`, and `paper_cites_paper` in generator-facing control files.
- Quality concerns:
  - Citation edges are descriptive reference-list links only. They do not assert method inheritance, problem response, or conceptual development by themselves.
  - Fourteen source papers currently have no usable local reference-list file and therefore contribute no outgoing citation edges until references are recovered.

## 2026-05-19 10:48 CST - Missing citation reference lists backfilled and future citation maintenance codified

- Action:
  - Added `scripts/backfill_missing_reference_lists_from_arxiv.rb`.
  - Backfilled the 14 papers that lacked local reference-list coverage by downloading their arXiv source packages and extracting `thebibliography` blocks into supplemental `citation_backfill_thebibliography.bbl` files.
  - Rebuilt the graph and current-coverage test framework after backfill.
  - Updated `RUN_PROTOCOL.md` and generated framework docs so future paper expansion must update the separate paper-to-paper citation layer before sealed experiments are considered complete.
- Files created / updated:
  - `scripts/backfill_missing_reference_lists_from_arxiv.rb`
  - `citation_reference_backfill_v0/reference_backfill_status.csv`
  - `RUN_PROTOCOL.md`
  - `scripts/build_current_coverage_test_framework_v0.rb`
  - `trajectory_experiments/current_coverage_v0_test_framework/TEST_FRAMEWORK_LOGIC.md`
  - `trajectory_experiments/current_coverage_v0_test_framework/EXPERIMENT_PROTOCOL.md`
  - `trajectory_experiments/current_coverage_v0_test_framework/RUNBOOK.md`
- Backfill result:
  - Missing source papers before backfill: 14.
  - `thebibliography_extracted`: 14.
  - Citation source coverage after backfill: 60 / 60.
  - Paper citation edges across all years: 261.
  - `G5 paper_citation_only`: 418 visible nodes, 172 visible links at cutoff 2023.
- Durable rule:
  - After any new paper expansion wave, run `ruby scripts/backfill_missing_reference_lists_from_arxiv.rb` and then `ruby scripts/build_current_coverage_test_framework_v0.rb`.
  - Citation edges remain a separate descriptive paper-reference layer and must not be treated as evidence of semantic development relations.

## 2026-05-19 10:58 CST - Generator/evaluator model roles fixed for sealed trajectory tests

- Action:
  - Fixed the generator model role to `gpt-5.2` with reasoning effort `low`.
  - Fixed the blind evaluator model role to `gpt-5.5` with reasoning effort `xhigh`.
  - Added durable model-role documentation and a blind-evaluation packet preparation script.
  - Explicitly prohibited the controller/main agent from scoring, classifying, ranking, or otherwise substituting its own judgment for blind evaluation.
- Files created / updated:
  - `scripts/build_current_coverage_test_framework_v0.rb`
  - `scripts/prepare_blind_evaluation_packet_v0.rb`
  - `trajectory_experiments/current_coverage_v0_test_framework/model_role_manifest.csv`
  - `trajectory_experiments/current_coverage_v0_test_framework/MODEL_RUN_PROTOCOL.md`
  - `trajectory_experiments/current_coverage_v0_test_framework/EVALUATION_RUBRIC.md`
  - `trajectory_experiments/current_coverage_v0_test_framework/RUNBOOK.md`
- Model-run rule:
  - Generators receive exactly one sealed unit and must follow round-gated file access.
  - Evaluator receives only anonymized trajectories and `EVALUATION_RUBRIC.md`.
  - Evaluator must not receive condition keys, sealed unit mappings, framework internals, or private mapping files.
  - Private keys may be opened only after evaluator output is complete and immutable.

## 2026-05-19 10:57 CST - Sealed model run completed with GPT-5.2 generators and GPT-5.5 blind evaluator

- Action:
  - Ran one full sealed trajectory test with five independent generator workers.
  - Generator model: `gpt-5.2`, reasoning effort `low`.
  - Blind evaluator model: `gpt-5.5`, reasoning effort `xhigh`.
  - Generated an anonymized blind evaluation packet after all five trajectories completed.
  - Opened private mapping only after the blind evaluator output was complete.
- Run directory:
  - `trajectory_experiments/current_coverage_v0_test_framework/model_runs/20260519_104953/`
- Generated trajectories:
  - `rounds/unit_104_trajectory.md`
  - `rounds/unit_287_trajectory.md`
  - `rounds/unit_563_trajectory.md`
  - `rounds/unit_829_trajectory.md`
  - `rounds/unit_641_trajectory.md`
- Evaluation outputs:
  - `evaluations/blind_evaluation_gpt55_xhigh.md`
  - `evaluations/post_eval_unsealed_summary.md`
  - `private/unsealed_case_condition_index.csv`
- Post-evaluation unsealed mapping:
  - `case_001` -> `G1 nodes_only`
  - `case_002` -> `G2 strict_paper_internal`
  - `case_003` -> `G3 clean_candidate_context`
  - `case_004` -> `G4 strict_plus_clean_candidate_context`
  - `case_005` -> `G5 paper_citation_only`
- Blind evaluator's cross-case result after unsealing:
  - `G3 clean_candidate_context` and `G5 paper_citation_only` strongest by rubric fit.
  - `G1 nodes_only` very close behind.
  - `G2 strict_paper_internal` good but more diffuse.
  - `G4 strict_plus_clean_candidate_context` adequate but least controlled.
- Caveat:
  - This is a single stochastic sealed run. It should be treated as one trajectory sample, not a stable effect estimate.

## 2026-05-19 11:20 CST - Edge-dependency assay added as reusable script framework

- Motivation:
  - The first open-ended three-round trajectory test allowed `nodes_only` to produce a strong node-local research plan, making edge effects hard to isolate.
  - Added a separate assay where the primary observable is auditable relation-path construction, not general idea quality.
- New reusable scripts:
  - `scripts/build_edge_dependency_assay_v0.rb`
  - `scripts/scaffold_edge_dependency_assay_run_v0.rb`
  - `scripts/check_edge_dependency_assay_outputs_v0.rb`
  - `scripts/prepare_edge_dependency_blind_evaluation_packet_v0.rb`
  - `scripts/scaffold_current_coverage_model_run_v0.rb`
  - `scripts/rebuild_all_test_frameworks_v0.rb`
- New framework directory:
  - `trajectory_experiments/current_coverage_v0_edge_dependency_assay/`
- New sealed packet directory:
  - `trajectory_experiments/sealed_trial_v1/`
- Assay design:
  - Every unit receives the same selected item set.
  - Only the link layer varies.
  - Generator must provide link-step tables with `link_id`, endpoints, traversal direction, and path claims.
  - Mechanical audit checks cited link IDs, endpoint fidelity, and path continuity.
  - Qualitative scoring remains reserved for blind `gpt-5.5` / `xhigh` evaluation.
- Generated assay packet sizes:
  - Shared visible items: 183.
  - `unit_118` / `G1 nodes_only`: round0 links 0, update A links 0, update B links 0.
  - `unit_432` / `G2 strict_paper_internal`: round0 links 134, update A links 69, update B links 66.
  - `unit_795` / `G3 clean_candidate_context`: round0 links 26, update A links 4, update B links 4.
  - `unit_156` / `G4 strict_plus_clean_candidate_context`: round0 links 160, update A links 73, update B links 70.
  - `unit_608` / `G5 paper_citation_only`: round0 links 172, update A links 64, update B links 25.
- Durable rule:
  - Use the edge-dependency assay when the experimental question is specifically whether edges matter.
  - The no-link condition should abstain from support-path claims and therefore cannot score high on primary relation-dependency metrics merely by producing a good node-local synthesis.

## 2026-05-19 11:37 CST - Edge-dependency assay first sealed run completed

- Run id:
  - `edge_assay_20260519_112535`
- Run directory:
  - `trajectory_experiments/current_coverage_v0_edge_dependency_assay/model_runs/edge_assay_20260519_112535/`
- Generator settings:
  - Five independent generator workers.
  - Generator model: `gpt-5.2`, reasoning effort `low`.
  - Each worker received exactly one sealed unit under `trajectory_experiments/sealed_trial_v1/`.
  - No search, browsing, directory listing, parent/sibling inspection, framework/script/log/private mapping access, hidden-label guessing, or pre-reading future rounds.
- Blind evaluator:
  - Evaluator model: `gpt-5.5`, reasoning effort `xhigh`.
  - Evaluator received anonymized trajectories plus anonymous mechanical audit summary.
  - Private mappings were opened only after `evaluations/blind_evaluation_gpt55_xhigh.md` was complete.
- Mechanical audit:
  - G1 nodes_only: 0 parsed link steps, 0 valid, 0 invalid, 7 insufficient-link mentions.
  - G4 strict_plus_clean_candidate_context: 14 parsed link steps, 13 valid, 1 invalid, 3 continuity breaks.
  - G2 strict_paper_internal: 11 parsed link steps, 11 valid, 0 invalid, 7 continuity breaks.
  - G5 paper_citation_only: 6 parsed link steps, 6 valid, 0 invalid, 0 continuity breaks, 2 insufficient-link mentions.
  - G3 clean_candidate_context: 13 parsed link steps, 13 valid, 0 invalid, 5 continuity breaks.
  - No future-round link violations were detected.
- Unsealed mapping:
  - case_001 -> G1 nodes_only.
  - case_002 -> G4 strict_plus_clean_candidate_context.
  - case_003 -> G2 strict_paper_internal.
  - case_004 -> G5 paper_citation_only.
  - case_005 -> G3 clean_candidate_context.
- Blind evaluation result after unsealing:
  - Strongest edge-dependent trajectories: G4 strict_plus_clean_candidate_context and G3 clean_candidate_context.
  - G2 strict_paper_internal was technically rich and testable but penalized for path-continuity breaks.
  - G5 paper_citation_only was mechanically clean but citation-style links did not strongly carry the substantive claims.
  - G1 nodes_only behaved as intended: honest node-local fallback, low primary relation-dependency scores.
- Caveat:
  - This is one stochastic sealed run. It demonstrates that the assay can expose edge dependence and make nodes-only low on relation-path metrics, but it should not be treated as a stable condition-effect estimate without replication.

## 2026-05-19 13:49 CST - Adaptive G6 candidate-to-internal assay scripted and first run completed

- Motivation:
  - Test the staged design hypothesis: use candidate-context links first for branch navigation, then mechanically unlock strict paper-internal evidence for the selected branch to learn mechanisms, while receiving the same feedback rounds as other conditions.
- New reusable scripts:
  - `scripts/build_adaptive_candidate_internal_assay_v0.rb`
  - `scripts/scaffold_adaptive_candidate_internal_run_v0.rb`
  - `scripts/prepare_adaptive_candidate_internal_round_v0.rb`
  - `scripts/assemble_adaptive_candidate_internal_trajectory_v0.rb`
  - `scripts/check_adaptive_candidate_internal_outputs_v0.rb`
- Framework:
  - `trajectory_experiments/current_coverage_v0_adaptive_g6_assay/`
- Sealed round-0 packet:
  - `trajectory_experiments/sealed_trial_v2/unit_906/round0/`
- Run id:
  - `adaptive_g6_20260519_134255`
- Round 0:
  - Generator saw shared visible items plus 26 clean candidate-context links only.
  - Selected branch: `autoregressive_symmetry_aware_pruning`.
  - Selected candidate links: `C0020;C0021;C0017`.
  - Selected papers: `NQSC060;NQSC085;NQSC026;NQSC117`.
- Round 1 mechanical unlock:
  - Resolved selected papers: `NQSC026;NQSC060;NQSC085;NQSC117`.
  - Unlocked items: 34.
  - Unlocked strict internal links: 37.
  - Generator narrowed the idea from generic pruning/backtracking reduction to sample-yield-aware symmetry pruning, using internal evidence about symmetry-aware pruning, postselection waste, chemical-accuracy speedups, and no-sample/sample-loss risk.
- Round 2 mechanical unlock:
  - Resolved selected papers: `NQSC060;NQSC085;NQSC117`.
  - Unlocked items: 27.
  - Unlocked strict internal links: 31.
  - Generator preserved the same branch and scope-extended it to yield- and batch-efficiency-aware symmetry-pruned autoregressive sampling, integrating internal scaling evidence about local-energy and large-batch throughput.
- Mechanical audit:
  - Round 0: 3 parsed link steps, 3 valid, 0 invalid, 0 continuity breaks.
  - Round 1: 7 parsed link steps, 7 valid, 0 invalid, 0 continuity breaks.
  - Round 2: 10 parsed link steps, 10 valid, 0 invalid, 0 continuity breaks.
- Interpretation:
  - This first G6 run supports the staged-design hypothesis qualitatively and mechanically: candidate links localized a branch, then strict internal links grounded the mechanism and narrowed the proposal without branch drift.
  - This is a single run and must be compared against G3/G4/G2 across multiple seeds before claiming stable superiority.

## 2026-05-19 14:53 CST - Aligned G3/G4/G6 blind comparison completed

- Motivation:
  - Align idea counts and round structure across G3, G4, and G6.
  - Each condition was evaluated as one Round 0 idea, one Round 1 revision, and one Round 2 final trajectory.
- Run id:
  - `aligned_g3_g4_g6_20260519_144241`
- Run directory:
  - `trajectory_experiments/current_coverage_v0_aligned_g3_g4_g6_comparison/model_runs/aligned_g3_g4_g6_20260519_144241/`
- Generator / evaluator:
  - G3 and G4 were rerun with staged physical rounds using `gpt-5.2` / `low`.
  - G6 used the existing staged adaptive run `adaptive_g6_20260519_134255`.
  - Blind evaluator used `gpt-5.5` / `xhigh`.
  - Evaluator received anonymized trajectories plus anonymous aligned link audit summary, not condition mappings.
- Unsealed mapping:
  - case_001 -> G3 clean_candidate_context.
  - case_002 -> G4 strict_plus_clean_candidate_context.
  - case_003 -> G6 adaptive_candidate_to_internal.
- Mechanical audit:
  - G3: Round0 1/1 valid, Round1 2/2 valid with 1 continuity break, Round2 4/4 valid with 3 continuity breaks.
  - G4: Round0 1/9 valid with 6 continuity breaks, Round1 0 parsed links, Round2 5/8 valid with 7 continuity breaks.
  - G6: Round0 3/3 valid, Round1 7/7 valid, Round2 10/10 valid, 0 continuity breaks.
- Blind evaluation:
  - Overall ranking: G6 first, G3 second, G4 third.
  - G6 received 5/5 on all metrics: idea-count alignment, goal preservation, branch drift control, link validity, path continuity, mechanism grounding, feedback absorption, conclusion dependence, and testability.
  - G3 preserved one broad principle but shifted domains/mechanisms across rounds, weakening branch continuity.
  - G4 contained concrete mechanisms but over-expanded into an umbrella program and had substantial link-mechanics issues.
- Caveat:
  - This is one aligned seed. It strongly supports the G6 staged design hypothesis but needs multi-seed replication.

## 2026-05-19 15:05 CST - Aligned G3/G4/G6 re-evaluated with original idea-quality rubric

- User request:
  - Re-evaluate the existing aligned G3/G4/G6 trajectories with the original trajectory-quality rubric, not the later link-dependency rubric.
- Inputs:
  - Existing anonymized trajectories from `aligned_g3_g4_g6_20260519_144241`.
  - Original rubric from `trajectory_experiments/current_coverage_v0_test_framework/EVALUATION_RUBRIC.md`.
  - No link audit was provided to the evaluator.
- Blind evaluator:
  - `gpt-5.5`, reasoning effort `xhigh`.
  - Evaluator saw only anonymized case trajectories and the original rubric.
- Unsealed result:
  - case_001 -> G3 clean_candidate_context: 30/40.
  - case_002 -> G4 strict_plus_clean_candidate_context: 27/40.
  - case_003 -> G6 adaptive_candidate_to_internal: 40/40.
- Interpretation:
  - The original idea-quality rubric also ranks G6 first, G3 second, G4 third.
  - G6 wins not only on link mechanics but on goal preservation, selective feedback absorption, branch-local update, mechanism specificity, drift control, and testability.
  - G3 preserves a useful high-level bottleneck but shifts domains/mechanisms across rounds.
  - G4 contains plausible mechanisms but broadens into an umbrella robustness program.
