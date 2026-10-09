# Notes: where this code differs from the thesis text, and why

The mathematics follows the thesis exactly. Parameters are taken from the
thesis text by default. The original simulation code is used instead only
when the printed values cannot reproduce the thesis figure or the claim it
illustrates. Every such case is listed here. All claims are checked
automatically by the scripts (`[PASS]` lines).

| Result | Difference | What this code does |
|---|---|---|
| Fig. 2.3 (Ex. 2.9) | The original script applied the weights only to $b$ and kept $A$ fixed at the payoff-1 rows. As a result the published figure is a straight box with $x^3 \in [-6.7, 0]$. With eq. (2.11) and the printed parameters, $X^*(J)$ is a frustum with $x^3 \in [-10, 0]$. The original script also had two coefficient signs different from the text ($0.6$, $0.5$ instead of $-0.6$, $-0.5$). | Uses eq. (2.11) and the thesis values. The conclusions (6 faces mapped face to face, one-to-one) are unchanged and checked. |
| Fig. 2.4 (Ex. 2.10) | The text prints agent 2's gradient row as $[-1, 0.5, -2]$. With it, $x^2$ becomes negative, unlike the figure. The original code used $[1, 0.5, -2]$. | Uses $[1, 0.5, -2]$; the coordinate ranges of the figure are checked. |
| Fig. 2.5 (Ex. 2.11) | No original code. | Built from the payoffs printed in the text. |
| Figs. 3.5, 3.6 | The original scripts give only the four best-response lines and the speed factors. The panel order (a)–(e) was inferred from the axis ranges of the figures. | Same lines and speed factors. The unused Hessian entries are set to $-1$; they do not affect the dynamics. |
| Fig. 3.7 | No original code or parameters. | Three new examples with mixed determinant signs. |
| Fig. 4.3(a) | Sensitivities $\alpha$ not given. | $\alpha = [1\ 1;\ 1\ 0.5]$ reproduces the published payoff curves: agent 2 loses on both payoffs first ($t \approx 0.2$), then agent 1. |
| Fig. 4.3(b) | With the printed $b$, the start $x_0 = (0,0)$ is already a Nash equilibrium, so nothing moves. The printed values also do not satisfy condition (4.17). The original code built the cross terms from two points that are meant to be where an agent's two best-response lines meet, but are not those points. | Keeps the own-gradient offsets of the original code, so the trajectory is unchanged. Rebuilds the cross terms with the construction (4.17) using the true intersection points. $\Gamma^i_j = \mathbb{R}^2$ and Pareto improvement are then checked. |
| Fig. 5.1 | With the caption's $\alpha = (1.2, 1.2, 1.25, 1)$, the trajectory enters the region where both payoffs of agent 2 fall ($t \approx 0.37$–$0.52$). This contradicts panel (a). The original code switched branches by comparing scaled gradients rather than distances. | Uses rule (3.8) exactly, with the sensitivities effectively used in the original code, $\alpha = [1\ 1.2;\ 1\ 2]$. Weak Pareto improvement holds and agent 2 is trapped, also for the thesis pair $t_1 = 0$, $t_2 = 2.75$. |
| Fig. 5.4 | None. | The switching values $\sigma = 0.4097, 0.5266$ are reproduced. |
| Figs. 5.5–5.6 | The published plots show $J^1_1$, $J^2_1$ and $p$ divided by 10, without saying so. The original code also changed the agents' sensitivities after adding the incentive. | Values are shown unscaled, except panel (c), where the division by 10 is labelled. $\alpha = 1$ before and after the incentive (Theorem 5.4 holds for any $\alpha$). Simulated to $t = 10$ instead of 3 to show convergence to $\hat x^*$. |
| Extension (ECC paper, Fig. 4) | The payoffs, sensitivities and matrices (31) printed in Section IV belong to a different example. With them, $x_0 = (2.3, 7.9)$ lies above agent 1's switching line, outside the region the method analyses, and $\eta(x_0) = (2.25, 5.6)$. Fig. 4 and the stated $\eta(x_0) = (2.2, 7.325)$, $x_0 \in \mathcal D_{(2,2)}$ are reproduced by the parameters of the original simulation code. | Uses the original-code parameters. Checks the paper's statements about $x_0$ and verifies the printed $T$; the LMIs are also solved independently. The transformed system slides along the negative $\tilde x_1$-axis, so it is integrated with small fixed steps. |

Not reproduced: Figs. 2.1, 2.2, 2.6, 3.1–3.4, 3.8, 4.1, 4.2, 5.2 and 5.3 are
schematic drawings without numerical data. Their content is covered by the
figures above.
