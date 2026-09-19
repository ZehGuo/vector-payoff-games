# Reproducing the six experiments safely

**From the repository root, run one public entry; by default every generated file goes only to `results/public`, each of the six experiments writes figures, CSV data, and a MAT report, and the tracked worktree remains unchanged before and after the run.**

This page is for a first-time reader who has cloned the repository and installed MATLAB. Reading the papers is not required to run the six experiments.

## Requirements

- Tested: **MATLAB R2025b Update 7** on macOS.
- Other MATLAB releases have not been verified.
- Start in the repository root (the directory containing `experiments/`, `docs/`, and `PROJECT_STATE.md`).
- The default output directory, `results/public`, must be absent or empty. The runner refuses to mix a new run with old output.

The local directories `source_material/`, `reference/`, and `results/` are intentionally excluded from Git. A new clone therefore does not contain the source PDFs, the legacy archive, previous results, or the local R1 review pack. None of those local-only materials is needed by the six experiment runners.

## One-command run

If MATLAB is already on `PATH`, run this from the repository root:

```bash
matlab -batch "addpath('experiments'); run_public_reproduction"
```

On macOS, MATLAB can also be invoked by its installed application path. For the tested release:

```bash
/Applications/MATLAB_R2025b.app/bin/matlab -batch "addpath('experiments'); run_public_reproduction"
```

The path is an example for a standard MATLAB installation, not an author-specific directory. If a different release is installed, replace `MATLAB_R2025b.app` with the application name present under `/Applications/`; that release is not claimed as verified here.

To use a new empty output directory, pass an absolute path or a path relative to the repository root:

```bash
matlab -batch "addpath('experiments'); run_public_reproduction('results/public-second-run')"
```

A custom path inside the repository is accepted only below the Git-ignored `results/` directory. A path outside the repository is also allowed. The wrapper checks that it is called from the repository root, manages the experiment path for the run, and reports the exact task (`T1`, `S1`, `S2`, `P1`, `X1`, or `I1`) if a task fails.

## Output index and schema

After a successful default run, open `results/public/PUBLIC_OUTPUT_INDEX.md`. It lists every generated experiment artifact, byte size, and minimal per-task report metadata. `results/public/public_output_index.csv` contains the same 39-row experiment-artifact index for programs, and `results/public/public_reproduction_report.mat` stores the wrapper report plus the six returned reports.

The six experiments produce 18 figure classes and 21 nonfigure experiment-artifact classes:

| Task | Figures | CSV and MAT data |
|---|---|---|
| T1 | `t1/figures/T1_cube_face_correspondence.png`; `T1_prism_face_correspondence.png`; `T1_production_pollution.png`; `T1_nonquadratic_schematic.png` | `t1_face_correspondence.csv`; `t1_edge_correspondence.csv`; `t1_vertex_correspondence.csv`; `t1_diagnostics.csv`; `t1_report.mat` |
| S1 | `s1/s1_five_case_overview.png`; `s1_eigenvectors_and_transitions.png` | `s1_case_summary.csv`; `s1_branch_diagnostics.csv`; `s1_report.mat` |
| S2 | `s2/S2_rank_degenerate_five_cases.png`; `S2_noncompact_three_configurations.png` | `s2_case_summary.csv`; `s2_branch_diagnostics.csv`; `s2_noncompact_summary.csv`; `s2_trajectory_summary.csv`; `s2_report.mat` |
| P1 | `p1/p1_three_payoff_properties.png`; `p1_rate_decomposition.png`; `p1_weak_pareto_trap.png` | `p1_samples.csv`; `p1_summary.csv`; `p1_report.mat` |
| X1 | `x1/x1_domain_map.png`; `x1_fiber_collapse.png`; `x1_trajectories_lyapunov.png` | `x1_trajectories.csv`; `x1_report.mat` |
| I1 | `i1/figures/I1_design_geometry.png`; `I1_sigma_budget.png`; `I1_before_after.png`; `I1_INC_omega.png` | `i1_condition_checks.csv`; `i1_trajectory_summary.csv`; `i1_report.mat` |

Paths after the first entry in a table cell use the same task directory. T1 and I1 receive their `figures/` directories explicitly, so the public runner never uses their unsafe maintenance default of `audit/implementation/figures/`.

The public entry is [`experiments/run_public_reproduction.m`](../experiments/run_public_reproduction.m). The six scientific entries it calls, in order, are [T1](../experiments/run_t1_topology_applications.m), [S1](../experiments/run_s1_five_cases.m), [S2](../experiments/run_s2_degenerate_noncompact.m), [P1](../experiments/run_p1_payoff_properties.m), [X1](../experiments/run_x1_transformation_stability.m), and [I1](../experiments/run_i1_incentive_budget.m). [`run_r1_integration_review.m`](../experiments/run_r1_integration_review.m) is a separate local packaging/checking entry; it does not start the six experiments and is not required here.

## Scientific interpretation boundaries

- T1 uses the same weight in both `M(weight)` and `b(weight)`. Its finite weight grid checks implementation diagnostics; the global diffeomorphism identity comes from the paper theorem, not from the grid.
- S1 and S2 retain the documented new constructions, case order, branch matrices, and stability criteria. S2 noncompactness uses the analytic determinant criterion; a finite plotting window is only a visualization.
- P1 keeps the first three games as the new exact comparison family. Its trap is separate and uses the actual legacy scaled-own-gradient rule. A finite output-grid weak-property check is not a continuous-time proof.
- X1 keeps `x(t)`, the pointwise image `eta(x(t))`, and the independently integrated `z(t)` as three different objects.
- I1 modifies only `J_1^i`. The INC-0 same-game omega comparison and the different-game INC-omega supplement remain separate.
- A successful run, a trajectory, or a finite-grid check is execution evidence; none is, by itself, a theorem proof.

## Confirming worktree safety

The public outputs are below the Git-ignored `results/` directory. To confirm that no tracked file changed, compare `git status --short` before and after the MATLAB command. Existing untracked or user-edited files should appear unchanged in both snapshots; the new `results/public` output should not appear.
