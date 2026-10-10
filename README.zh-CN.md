[English](README.md) | **中文** | [日本語](README.ja.md)

# Vector Payoff Games（向量收益博弈）

这是一组仿真程序，展示当**每个玩家同时拥有多个目标**、而且没有固定的方式去权衡这些目标时，博弈中会发生什么。

![生产与污染博弈的均衡区域](figures/equilibrium_region.png)

## 一段话说明思路

设想两家企业，每家都既想要高利润，*又*想要干净的环境。当一家企业无法只靠改变自己的产量让**两个**目标同时变好时，它就满足了。由于"满足"不再意味着"某一个数最大"，均衡就不再是一个点，而是一整片**区域**（上图中的紫色部分）。本仓库围绕这类博弈探讨四个问题：

1. 均衡区域长什么样？
2. 如果玩家一步一步地调整，最后会停在这个区域里吗？
3. 在调整过程中，每个人都会变得更好吗？
4. 管理者能否在不花钱的前提下，用税收和补贴让每个人都变得更好？

[GUIDE.zh-CN.md](GUIDE.zh-CN.md) 用图和通俗的语言逐一解释这些问题。

## 如何运行

需要 MATLAB（R2022a 或更新版本；已在 R2025b 上测试）。不需要任何工具箱。只有 `stability_lyapunov.m` 会用到 Optimization Toolbox，但没有它也能运行。

1. 打开 MATLAB，把本文件夹设为当前文件夹。
2. 输入 `run_all` 并回车（约两分钟）。

也可以单独运行某个脚本，例如 `improvement_trap`。

## 结果在哪里

- **图：** 在 [`figures/`](figures/) 文件夹中，不运行程序也可以直接查看。图中的文字是英文，每张图的含义在 GUIDE 中有中文说明。
- **核对：** 每个脚本都会打印 `[PASS]` / `[FAIL]`，把计算结果与已发表的结果进行比较；`run_all` 最后会给出汇总。所有核对都应当通过。

| 问题 | 脚本 | 图 |
|---|---|---|
| 均衡区域长什么样？ | `equilibrium_region.m` | `equilibrium_region.png` |
| | `equilibrium_three_players.m` | `equilibrium_three_players.png` |
| | `equilibrium_vector_states.m` | `equilibrium_vector_states.png` |
| 玩家会停下来吗？ | `stability_cases.m` | `stability_one_piece.png`, `stability_two_pieces.png`, `stability_unbounded.png` |
| | `stability_lyapunov.m` | `stability_lyapunov.png` |
| 每个人都会变好吗？ | `improvement_pareto.m` | `improvement_pareto.png` |
| | `improvement_trap.m` | `improvement_trap.png` |
| 管理者能帮忙吗？ | `incentive_budget.m` | `incentive_budget.png` |
| | `incentive_design.m` | `incentive_design.png` |

各脚本共用的小函数在 [`functions/`](functions/) 中。代码注释为英文。

## 论文

各脚本背后的思路发表于以下论文；每个脚本开头也写明了对应的论文。

- Z. Guo, T. Hayakawa, "Topology of Nash equilibrium set with quadratic vector payoff functions," *American Control Conference (ACC)*, 2024. [doi:10.23919/ACC60939.2024.10644643](https://doi.org/10.23919/ACC60939.2024.10644643)
- Z. Guo, T. Hayakawa, Y. Yan, "Nash equilibrium of 2-agent game with quadratic vector payoff functions and its stability," *IFAC World Congress*, 2023. [doi:10.1016/j.ifacol.2023.10.1395](https://doi.org/10.1016/j.ifacol.2023.10.1395)
- Z. Guo, T. Hayakawa, Y. Yan, "Stability and stabilization of Nash equilibrium for noncooperative systems with vector-valued payoff functions," *IEEE Conference on Decision and Control (CDC)*, 2023. [doi:10.1109/CDC49753.2023.10384265](https://doi.org/10.1109/CDC49753.2023.10384265)
- Z. Guo, T. Hayakawa, "Pareto improvement for noncooperative systems with vector-valued payoff functions," *IEEE Conference on Decision and Control (CDC)*, 2024. [doi:10.1109/CDC56724.2024.10886420](https://doi.org/10.1109/CDC56724.2024.10886420)
- Z. Guo, T. Hayakawa, "Two-agent noncooperative dynamical systems with quadratic vector-valued payoff functions and weak Pareto improvement," *IEEE Control Systems Letters*, vol. 8, 2024. [doi:10.1109/LCSYS.2024.3522596](https://doi.org/10.1109/LCSYS.2024.3522596)
- Z. Guo, T. Hayakawa, "A coordinate transformation method for stability analysis of Nash equilibria with vector payoff functions," *European Control Conference (ECC)*.
