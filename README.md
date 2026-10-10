**English** | [中文](README.zh-CN.md) | [日本語](README.ja.md)

# Vector Payoff Games

Simulations that show what happens in a game when **every player has several
goals at once** and no fixed way of weighing them.

![Equilibrium region of a production–pollution game](figures/equilibrium_region.png)

## The idea in one paragraph

Think of two firms that each want high profit *and* a clean environment. A
firm is satisfied when it cannot improve **both** goals by changing its own
production. Because "satisfied" no longer means "best in one number", there is
not one equilibrium point but a whole **region** of them (purple above). This
repository explores four questions about such games:

1. What does the equilibrium region look like?
2. If players keep adjusting step by step, do they settle down in it?
3. Does everybody get better off along the way?
4. Can a manager use taxes and subsidies, without spending money, so that
   everybody does?

[GUIDE.md](GUIDE.md) explains each question with pictures, in plain words.

## How to run

You need MATLAB (R2022a or newer; tested with R2025b). No toolboxes are
needed. Only `stability_lyapunov.m` uses the Optimization Toolbox, and it
still runs without it.

1. Open MATLAB and make this folder the current folder.
2. Type `run_all` and press Enter (about two minutes).

You can also run a single script, for example `improvement_trap`.

## Where the results are

- **Figures:** the folder [`figures/`](figures/). You can look at them without
  running anything.
- **Checks:** each script prints `[PASS]` / `[FAIL]` lines that compare its
  numbers with the published results, and `run_all` ends with a summary.
  All checks should pass.

| Question | Script | Figure |
|---|---|---|
| What does the equilibrium region look like? | `equilibrium_region.m` | `equilibrium_region.png` |
| | `equilibrium_three_players.m` | `equilibrium_three_players.png` |
| | `equilibrium_vector_states.m` | `equilibrium_vector_states.png` |
| Do the players settle down? | `stability_cases.m` | `stability_one_piece.png`, `stability_two_pieces.png`, `stability_unbounded.png` |
| | `stability_lyapunov.m` | `stability_lyapunov.png` |
| Does everybody get better off? | `improvement_pareto.m` | `improvement_pareto.png` |
| | `improvement_trap.m` | `improvement_trap.png` |
| Can a manager help? | `incentive_budget.m` | `incentive_budget.png` |
| | `incentive_design.m` | `incentive_design.png` |

Small helper functions shared by the scripts are in [`functions/`](functions/).

## Papers

The ideas behind each script are published in these papers; the matching
paper is also named at the top of each script.

- Z. Guo, T. Hayakawa, "Topology of Nash equilibrium set with quadratic vector payoff functions," *American Control Conference (ACC)*, 2024. [doi:10.23919/ACC60939.2024.10644643](https://doi.org/10.23919/ACC60939.2024.10644643)
- Z. Guo, T. Hayakawa, Y. Yan, "Nash equilibrium of 2-agent game with quadratic vector payoff functions and its stability," *IFAC World Congress*, 2023. [doi:10.1016/j.ifacol.2023.10.1395](https://doi.org/10.1016/j.ifacol.2023.10.1395)
- Z. Guo, T. Hayakawa, Y. Yan, "Stability and stabilization of Nash equilibrium for noncooperative systems with vector-valued payoff functions," *IEEE Conference on Decision and Control (CDC)*, 2023. [doi:10.1109/CDC49753.2023.10384265](https://doi.org/10.1109/CDC49753.2023.10384265)
- Z. Guo, T. Hayakawa, "Pareto improvement for noncooperative systems with vector-valued payoff functions," *IEEE Conference on Decision and Control (CDC)*, 2024. [doi:10.1109/CDC56724.2024.10886420](https://doi.org/10.1109/CDC56724.2024.10886420)
- Z. Guo, T. Hayakawa, "Two-agent noncooperative dynamical systems with quadratic vector-valued payoff functions and weak Pareto improvement," *IEEE Control Systems Letters*, vol. 8, 2024. [doi:10.1109/LCSYS.2024.3522596](https://doi.org/10.1109/LCSYS.2024.3522596)
- Z. Guo, T. Hayakawa, "A coordinate transformation method for stability analysis of Nash equilibria with vector payoff functions," *European Control Conference (ECC)*.
