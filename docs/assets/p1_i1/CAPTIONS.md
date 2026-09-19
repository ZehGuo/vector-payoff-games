# P1/I1 public-figure captions and provenance

All PNGs in this directory and the seven linked technical figures were rendered by MATLAB R2025b Update 7 through `experiments/run_p1_payoff_properties.m` or `experiments/run_i1_incentive_budget.m`. The clean numerical bundles were written outside the tracked tree during RR-03; the public PNGs are renderings of those unchanged computations, not redraws with altered parameters.

## Technical figures

| figure | concise caption | MATLAB entry and data | claim boundary |
|---|---|---|---|
| `audit/implementation/figures/P1_three_payoff_properties.png` | Three new exact comparison games isolate nonweak, all-payoff-nondecreasing, and weak-but-not-all behavior under one trajectory and own-gradient structure. | `run_p1_payoff_properties`; `p1_samples.csv`, `p1_summary.csv`, `p1_report.mat` | New comparison family; not an exact reproduction of thesis Fig. 4.3. |
| `audit/implementation/figures/P1_rate_decomposition.png` | For each agent and objective, total payoff rate equals the own-direction contribution plus the externality; the externality can reverse the sign. | `run_p1_payoff_properties`; the `own`, `externality`, and `totalRate` fields in `p1_report.mat` | The three terms are diagnostics of one dynamics, not three different dynamics. |
| `audit/implementation/figures/P1_weak_pareto_trap.png` | Under the actual legacy `A/b/x0/alpha` and scaled-own-gradient rule, the two interior times `t1=0.020<t2=1.820` give changes `Delta J_1^2=-0.313864` and `Delta J_2^2=-0.319846`. | `run_p1_payoff_properties`; trap rows in `p1_samples.csv` and `trapWitness` in `p1_report.mat` | The weak-at-every-time margin is finite-output-grid evidence; the trap does not replace the separate nonweak game. |
| `audit/implementation/figures/I1_design_geometry.png` | Reading order: centralized social Pareto samples versus decentralized Nash geometry, anchored domains, same-game omega comparison, then behavior before and after the incentive. Only `J_1^i` is modified. | `run_i1_incentive_budget`; `i1_report.mat` | Social Pareto and Nash are distinct; the finite endpoint is near, not equal to, the target. |
| `audit/implementation/figures/I1_sigma_budget.png` | Sigma changes the budget-boundary topology. Orange consistently denotes `D_bud^c`, where aggregate transfer is positive; the common exclusion panel is a stronger-certificate explanation. | `run_i1_incentive_budget`; `report.sigma` in `i1_report.mat` | Failure of the stronger containment certificate is not general impossibility. |
| `audit/implementation/figures/I1_before_after.png` | INC-0 compares original and incentivized trajectories, original and modified payoff changes, and complete aggregate transfer with feasible sign convention `p^1+p^2<=0`; terminal distance is `0.0151764`. | `run_i1_incentive_budget`; `i1_condition_checks.csv`, `i1_trajectory_summary.csv`, `i1_report.mat` | Algebra checked; trajectory observed; full invariant-set containment remains unproved. |
| `audit/implementation/figures/I1_INC_omega.png` | The INC-omega supplement shows weighted modified payoffs and why the complete budget identity must retain both omega-weighted terms. | `run_i1_incentive_budget`; INC-omega fields in both CSVs and `i1_report.mat` | Different game; not a one-factor omega control. |

## Mobile/homepage derivatives

| asset | homepage caption | source |
|---|---|---|
| `P1_rate_decomposition_card.png` | Moving in an own-improving direction need not raise total payoff: externality is the missing term. | Direct MATLAB rendering from the nonweak game's unchanged `own`, `externality`, and `totalRate` arrays. |
| `P1_trap_two_times_card.png` | A locally weak trajectory can still contain two times at which both objectives of one agent are worse. | Direct MATLAB rendering of the legacy trap witness in `p1_report.mat`; finite-grid qualification remains required nearby. |
| `I1_trajectory_card.png` | The incentive changes the observed trajectory toward the target; the finite endpoint remains `0.0151764` away. | Direct MATLAB rendering of the INC-0 original/incentivized trajectories and unchanged BR lines. |
| `I1_aggregate_transfer_card.png` | Along the observed INC-0 trajectory, the complete aggregate transfer remains nonpositive under the stated sign convention. | Direct MATLAB rendering of `aggregateTransfer`; sampled observation, not an invariant-domain theorem certificate. |

## Required nearby boundary statement for I1

Use these three labels together whenever the I1 numerical example is shown publicly:

`algebra checked | trajectory observed | invariant containment unproved`

The stronger failure of `D(U,x0) subset D_bud` rejects that sufficient certificate only; it does not establish general impossibility.
