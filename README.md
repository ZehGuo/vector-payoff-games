# Games where every player has several goals

*Noncooperative dynamical systems with vector-valued payoff functions.*

MATLAB code that reproduces the main results of the PhD thesis *Stability and
Incentive Design for Noncooperative Dynamical Systems With Vector-valued
Payoff Functions* (Zehui Guo, Institute of Science Tokyo, 2025).

## What the research is about

In many real situations each decision maker cares about several goals at once,
such as a firm that wants both profit and a clean environment, and has no fixed
way of weighing them. When such players act selfishly, there is no single
equilibrium point (a state where no player can improve on its own). Instead
there is a whole **region of equilibria**. The thesis answers four questions
about this situation:

1. What does this region look like?
2. Do players who adjust step by step actually converge to it?
3. Does everybody get better off along the way?
4. How can a manager use taxes and subsidies, without spending money, so that
   everybody does?

[GUIDE.md](GUIDE.md) explains the notation, the ideas and the results chapter
by chapter. The thesis itself is not included in this repository.

## How to run

You need MATLAB R2022a or newer; this code was tested with R2025b. No
toolboxes are needed, except that the last script uses the Optimization
Toolbox if it is installed.

1. Open MATLAB and set this folder as the current folder.
2. Type `run_all` and press Enter. It takes about two minutes.

You can also run any single script on its own, for example `ch5_trap`.

## Where the results are

- **Figures:** the folder [`figures/`](figures/) contains every figure, so you
  can look at the results without running anything.
- **Checks:** while running, each script prints `[PASS]` or `[FAIL]` lines.
  Each line compares a computed number or property with the thesis. The run
  ends with a summary (currently 56 checks, all passing).
- **Differences from the thesis text:** a few printed parameters in the thesis
  contain typos. [NOTES.md](NOTES.md) lists each one and what the code uses.

| Script | Thesis | Shows | Figure in `figures/` |
|---|---|---|---|
| `ch2_nash_set_from_weights.m` | Ch. 2, Fig. 2.5 | the equilibrium region of a production–pollution game, built from weighted games | `ch2_production_pollution.png` |
| `ch2_three_agents_cube.m` | Ch. 2, Fig. 2.3 | three players: a cube of weights maps face-to-face onto the equilibrium set | `ch2_three_agents_cube.png` |
| `ch2_two_agents_prism.m` | Ch. 2, Fig. 2.4 | a player with three goals: a prism of weights maps onto the equilibrium set | `ch2_two_agents_prism.png` |
| `ch3_stability.m` | Ch. 3, Figs. 3.5–3.7 | when the equilibrium set attracts nearby trajectories, and when it does not | `ch3_stability_five_cases.png`, `ch3_stability_assumption4.png`, `ch3_unbounded_cases.png` |
| `ch4_pareto_improvement.m` | Ch. 4, Fig. 4.3 | when everybody gains, and when somebody loses, along the trajectory | `ch4_pareto_improvement.png` |
| `ch5_trap.m` | Ch. 5, Fig. 5.1 | the "trap": gaining at every moment, yet ending up worse off | `ch5_trap.png` |
| `ch5_budget_region.m` | Ch. 5, Fig. 5.4 | where the manager's taxes and subsidies stay within budget | `ch5_budget_region.png` |
| `ch5_incentive_design.m` | Ch. 5, Figs. 5.5–5.6 | an incentive that makes everybody better off without costing the manager money | `ch5_incentive_design.png` |
| `ext_lyapunov_transformation.m` | ECC paper, Fig. 4 | a simpler proof of stability with a Lyapunov function | `ext_lyapunov_transformation.png` |

Shared helper functions are in [`functions/`](functions/).
