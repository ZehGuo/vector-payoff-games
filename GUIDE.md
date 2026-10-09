# Guide: the questions, the ideas, and the answers

This guide explains the reasoning of the thesis chapter by chapter, at the
level needed to understand the code and the figures. It states results
informally and leaves out proofs. Equation and theorem numbers refer to the
thesis (Zehui Guo, *Stability and Incentive Design for Noncooperative
Dynamical Systems With Vector-valued Payoff Functions*, Institute of Science
Tokyo, 2025).

Contents:
[Notation](#0-setting-and-notation) ·
[Ch. 2 Shape of the Nash set](#1-chapter-2--what-does-the-nash-equilibrium-set-look-like) ·
[Ch. 3 Stability](#2-chapter-3--do-the-agents-converge-to-the-nash-set) ·
[Ch. 4 Pareto improvement](#3-chapter-4--does-everybody-get-better-off-on-the-way) ·
[Ch. 5 Incentive design](#4-chapter-5--how-can-a-manager-make-everybody-better-off) ·
[Extension: Lyapunov](#5-extension--a-lyapunov-proof-of-stability) ·
[Papers](#6-related-papers)

---

## 0. Setting and notation

**The situation.** Several decision makers (*agents*) each control one
quantity, for example how much a firm produces. Each agent cares about
**several goals at once**, for example profit *and* environmental impact, and
does **not** know how to weigh one goal against another. Agents act
selfishly: each only tries to improve its own goals.

| Symbol | Meaning |
|---|---|
| $i = 1,\dots,n$ | agents (mostly $n = 2$) |
| $x^i$ | state (decision) of agent $i$; $x = (x^i, x^{-i})$, where $x^{-i}$ is everybody else |
| $J^i_j(x)$ | payoff $j$ of agent $i$, $j = 1,\dots,s_i$ |
| $J^i = [J^i_1,\dots,J^i_{s_i}]^\top$ | the *vector* payoff of agent $i$ |
| $J^i_j(x) = \tfrac12 x^\top A^{ij}x + b^{ij\top}x + c^{ij}$ | all payoffs are quadratic, strictly concave in the agent's own state |
| $\partial J^i_j/\partial x^i$ | *own gradient*: how payoff $j$ changes when agent $i$ moves itself (code: `own_gradient`) |
| $\mathcal{BR}^i_j$ | *best-response line*: the states where $\partial J^i_j/\partial x^i = 0$, i.e. where agent $i$ cannot improve payoff $j$ alone |
| $\lambda^i \in \Delta^{s_i-1}$ | weights of agent $i$ on its payoffs ($\lambda^i_j \ge 0$, $\sum_j \lambda^i_j = 1$) |
| $X^*(J)$ | the Nash equilibrium set (below) |
| $\alpha^i_j > 0$ | sensitivity: how fast agent $i$ moves when it follows payoff $j$ |

**Nash equilibrium with vector payoffs (Definition 1).** A state $x^*$ is a
Nash equilibrium if no agent can move alone so that **all** its payoffs are at
least as good and at least one is strictly better. With a single payoff this
is the usual Nash equilibrium, a point. With several payoffs, *which* trade-off
an agent accepts is not fixed. As a result the equilibria form a **set**
$X^*(J)$, usually a whole region.

**Colours used in all figures:** agent 1 red, agent 2 blue; payoff 1 solid
line, payoff 2 dashed line; the Nash set $X^*(J)$ purple; simulated
trajectories black (green in the last figure).

**In code** (2 agents, scalar states, 2 payoffs each), a game is a struct `G`
with `G.A{i,j}` $=A^{ij}$, `G.b{i,j}` $=b^{ij}$, `G.c(i,j)` $=c^{ij}$ and
`G.alpha(i,j)` $=\alpha^i_j$.

---

## 1. Chapter 2 — What does the Nash equilibrium set look like?

**Question.** $X^*(J)$ is a set, so what is its shape? Is it bounded? Is it
in one piece? Can we describe it completely?

**Key idea: weights.** Fix weights $\lambda^i$ and let each agent maximize the
single number $\lambda^{i\top}J^i(x)$. This is an ordinary game with one
payoff per agent, and its Nash point $x^*(\lambda)$ solves a linear system:

$$x^*(\lambda) = -(\Lambda(\lambda)A)^{-1}\Lambda(\lambda)b \qquad (2.11)$$

Here $\Lambda(\lambda)(Ax + b) = 0$ is just every agent's weighted
first-order condition $\sum_j \lambda^i_j\,\partial J^i_j/\partial x^i = 0$,
stacked into one linear system (code: `weighted_nash_point`). The Nash set is the collection of these points
over **all** weights (eq. (2.7)). The set of all weights is a product of
simplices $\Delta$: a square for 2 agents with 2 payoffs each, a cube for 3
agents, a prism when one agent has 3 payoffs. So the question becomes: **how
does the map $\lambda \mapsto x^*(\lambda)$ deform this simple shape?**

**Results.**
- **Bounded and connected (Proposition 2.1, Lemmas 2.2–2.3).** Pick, for each
  agent, the gradient row of one of its payoffs and stack the rows into a
  square matrix $A_{j_1\dots j_n}$. If all these matrices have determinants of
  the **same sign**, the map is well defined and continuous. Then $X^*(J)$ is
  compact and connected (*weakly simplicial*).
- **A faithful copy of the weight space (Theorem 2.4).** If, in addition, each
  agent's own-gradient matrix has rank $s_i - 1$ on $X^*(J)$, the map is a
  **diffeomorphism**: a smooth one-to-one map whose inverse is also smooth.
  For an agent with 2 payoffs, the rank condition just says that its two
  own gradients never vanish at the same point of $X^*(J)$. $X^*(J)$ then has exactly the shape of the weight space,
  and every face of the weight space is mapped onto a face of $X^*(J)$
  (*simplicial*). The face where agent $i$ ignores payoff $j$ becomes the Nash
  set of the smaller game without $J^i_j$.
- **Explicit formula, 2 payoffs, scalar states (eq. (2.28)).** $x \in X^*(J)$
  exactly when, for every agent, its two own gradients do **not** have the
  same strict sign. In words: no agent can raise both payoffs by moving alone
  (code: `in_nash_set`).

**Scripts.**

| Script | Thesis | What to look for |
|---|---|---|
| `ch2_nash_set_from_weights.m` | Ex. 2.11, Fig. 2.5 | production–pollution game: the weight square (left) and the Nash region (right). Same colour = same weights. The weighted-game points and the sign test (2.28) give the same region. |
| `ch2_three_agents_cube.m` | Ex. 2.9, Fig. 2.3 | 3 agents: the six faces of the weight cube map onto the six faces of $X^*(J)$ |
| `ch2_two_agents_prism.m` | Ex. 2.10, Fig. 2.4 | agent 1 has a 2-D state and 3 payoffs: a prism of weights maps onto a 5-faced $X^*(J)$ with a curved face |

---

## 2. Chapter 3 — Do the agents converge to the Nash set?

**Setting.** 2 agents, scalar states $x^1, x^2$, 2 payoffs each. The four
best-response lines $\mathcal{BR}^i_j$ cut the plane into regions.

**How agents move: pseudo-gradient dynamics (eq. (3.8)).** Agents are myopic:
they react to the current state only.
- If agent $i$'s two own gradients have **opposite signs**, no move can
  improve both payoffs, so the agent **stays**.
- Otherwise both payoffs improve in the same direction. The agent moves along
  the gradient of the payoff whose best-response line is **closer**:
  $\dot x^i = \alpha^i_j\,\partial J^i_j/\partial x^i$.

The switch between payoff 1 and payoff 2 happens on a horizontal line (agent 1)
or a vertical line (agent 2), drawn green in the figures. Inside each region
the motion is linear, $\dot x = \mathrm{diag}(\alpha)A_{j_1j_2}(x - x^*_{j_1j_2})$,
where $x^*_{j_1j_2}$ is the crossing point of $\mathcal{BR}^1_{j_1}$ and
$\mathcal{BR}^2_{j_2}$ (eq. (3.13); code: `pseudo_gradient`, `simulate_game`).

**What "stable" means for a set (Definition 4).** Measure the distance
$d_H(x, X^*(J))$ from the state to the *set*. The set is stable if starting
close keeps you close. It is asymptotically stable if, in addition, this
distance goes to 0.

**Idea of the analysis.** In each linear region, look at the eigenvectors of
the region's matrix (Lemma 3.6). They decide whether trajectories stay in the
region (*0-transitive*), leave it to one neighbour (*1-transitive*), or split
between two neighbours (*2-transitive*), as in Remarks 3.7–3.8. Following the
trajectories around $X^*(J)$ region by region, the slopes of the four lines
can be ordered in 5 essentially different ways (Remark 3.9).

**Results.** Let $A_{j_1j_2} = [\mathrm{row}_1(A^{1j_1});\ \mathrm{row}_2(A^{2j_2})]$.
- Mixed determinant signs: $X^*(J)$ is **unbounded** (Proposition 3.1).
- All four $\det A_{j_1j_2} > 0$: $X^*(J)$ is **asymptotically stable**.
- All four $< 0$: $X^*(J)$ is **unstable**.

These hold both when the interior of $X^*(J)$ is connected (Theorem 3.10) and
when it consists of two pieces meeting at a point (Theorem 3.11).

**Script.** `ch3_stability.m` predicts stability from the determinant signs.
It then simulates trajectories that start close to $X^*(J)$ and checks the
prediction.

| Figure | Content |
|---|---|
| `ch3_stability_five_cases.png` | Fig. 3.5: the 5 cases; (a)–(d) stable, (e) unstable |
| `ch3_stability_assumption4.png` | Fig. 3.6: the same cases when $X^*(J)$ is two pieces touching at a point |
| `ch3_unbounded_cases.png` | Fig. 3.7: unbounded Nash sets (new examples) |

---

## 3. Chapter 4 — Does everybody get better off on the way?

**Definitions (Definition 5).** Along a trajectory $x(t)$:
- **Pareto improving**: every payoff of every agent never decreases.
- **Weakly Pareto improving**: at every moment, each agent has **at least
  one** payoff that does not decrease. This is a weaker, more realistic goal.

**Key observation (eqs. (4.4)–(4.6)).** The change of $J^i_j$ splits into
two parts: the effect of agent $i$'s own move plus the effect of the other
agent's move. The first part is never negative, because agents only move to
improve. So only the **other** agent can hurt you. Define
$\Gamma^i_j$, the region where the other agent's move does not decrease
$J^i_j$ (*positive externality*). It does **not** depend on the unknown
sensitivities $\alpha$, so a manager can compute it.

**Results.**
- $\Gamma^i_j = \mathbb{R}^2$ if and only if the line
  $\{\partial J^i_j/\partial x^{-i} = 0\}$ lies entirely in the region where
  the other agent does not move (Lemma 4.2). If this holds for all $i, j$, **every** trajectory is
  Pareto improving, for any start and any $\alpha$ (Corollary 4.5).
- $\Gamma^i_1 \cup \Gamma^i_2 = \mathbb{R}^2$ if and only if some *weighted*
  line $\{\lambda^i_1 \partial J^i_1/\partial x^{-i} + \lambda^i_2\partial J^i_2/\partial x^{-i} = 0\}$
  with $\lambda^i \ge 0$ has this property (Theorem 4.3). If this holds for
  both agents, every trajectory is **weakly** Pareto improving.
- These conditions are linked to where the Pareto-efficient states lie
  relative to $X^*(J)$ (Corollaries 4.4, 4.7).

**Script.** `ch4_pareto_improvement.m` (Fig. 4.3), three examples:
(a) the trajectory crosses the grey regions where an agent can lose on both
payoffs, so it is not weakly Pareto improving; (b) all $\Gamma^i_j$ cover the
plane, so all four payoffs rise; (c) the unions cover the plane, so the
trajectory is weakly Pareto improving but some payoff falls.

---

## 4. Chapter 5 — How can a manager make everybody better off?

**A new problem: the trap (Definition 6).** Weak Pareto improvement is
checked moment by moment, which is not enough. An agent's two payoffs may take
turns decreasing. Then at a later time $t_2$ *both* payoffs can be lower than
at an earlier time $t_1$, and the agent is simply worse off. The thesis calls
this the **trap of weak Pareto improvement** (`ch5_trap.m`, Fig. 5.1).

**The manager's tools and limits.**
- A tax/subsidy $p^i(x)$ can only be added to the *money* payoff:
  $\tilde J^i_1 = J^i_1 + p^i$ (eq. (5.1)). The other payoffs (e.g.
  environment) cannot be paid for.
- Budget rules: nobody gains or loses at the start, $p^i(x_0) = 0$ (5.5).
  The manager never pays out net money, $p^1 + p^2 \le 0$ (5.6).
- The manager's goal: a social welfare $U = \sum_{i,j} \eta^i_j J^i_j$ with
  priorities $\eta^i_j$. The target state is $\hat x^* = \arg\max U$ (5.7)–(5.8).

**Key lemma (Lemma 5.1).** Suppose that for each agent some positive
combination $\tilde J^i_1 + \lambda^i J^i_2$ never decreases along the
trajectory. Then the trajectory is weakly Pareto improving **and** nobody is
trapped.

**Design (eqs. (5.18)–(5.19), (5.27)).** Choose the incentives so that the
sum of the agents' combined payoffs equals a scaled copy of the social welfare,
$\sigma(U - U(x_0)) + \text{const}$. Then hand each agent a share $\zeta_i$ of
it. In the simplest version ($\omega^i = 0$, $Q_i = 0$) agent $i$'s money
payoff becomes

$$\tilde J^i_1(x) = \zeta_i\,\sigma\,(U(x) - U(x_0)) + J^i_1(x_0). \qquad (5.28)$$

(The thesis has two further design parameters, $\omega^i$ and $Q_i$, which
change the shape of the regions involved; the example uses the simplest choice.)

Each agent is then paid by how much the social welfare improves. The target
$\hat x^*$ becomes a Nash equilibrium of the new game.

**The budget region.** The total incentive is
$p^1 + p^2 = \sigma(U - U(x_0)) - (J_{\rm sum} - J_{\rm sum}(x_0))$ (5.23), so
the trajectory must stay in $\mathcal{D}_{\rm bud}(\sigma) = \{p^1 + p^2 \le 0\}$.
This region is bounded by a conic whose type depends on $\sigma$: inside of an
ellipse, then a hyperbola, then the outside of an ellipse
(`ch5_budget_region.m`, Fig. 5.4).

**Main result (Theorem 5.4).** Suppose the incentivized best-response lines
satisfy the determinant condition of Chapter 3 (5.29a). Suppose also that the
smallest invariant region containing $x_0$ (the region the trajectory can
possibly visit) lies inside the positive-externality regions and inside
$\mathcal{D}_{\rm bud}(\sigma)$ (5.29b). Then, for any
sensitivities:
- the new Nash set is asymptotically stable;
- the trajectory is weakly Pareto improving;
- nobody falls into the trap;
- the budget constraint holds.

**Script.** `ch5_incentive_design.m` (Figs. 5.5–5.6) compares the trajectory
without the incentive (agent 1 loses on both payoffs) and with it. With the
incentive, all payoffs rise, the trajectory reaches $\hat x^*$, and
$p^1 + p^2 \le 0$ throughout.

---

## 5. Extension — a Lyapunov proof of stability

*Source: Z. Guo, T. Hayakawa, "A Coordinate Transformation Method for
Stability Analysis of Nash Equilibria with Vector Payoff Functions," European
Control Conference paper. This goes beyond the thesis; equation numbers below
refer to that paper.*

The region-by-region analysis of Chapter 3 is long and hard to extend. The
follow-up idea:
1. Use a coordinate change $\tilde x = \eta(x)$: each coordinate is the signed
   distance from the agent's state to the best-response line it follows, and
   0 if the agent does not move (eq. (20)). The whole set $X^*(J)$ collapses
   to the **origin**. Each quadrant of $\tilde x$ corresponds to one pair of
   followed payoffs, with **linear** dynamics
   $\dot{\tilde x} = \tilde{\mathcal A}_{(j_1,j_2)}\tilde x$ (eqs. (25)–(27)).
2. If the origin of this piecewise-linear system is stable, so is $X^*(J)$
   (Theorem 1).
3. Find a piecewise quadratic Lyapunov function
   $V = \tilde x^\top P_{(j_1,j_2)}\tilde x$ by solving linear matrix
   inequalities (eqs. (28)–(30), Proposition 2).

**Script.** `ext_lyapunov_transformation.m` reproduces the example of the
paper (Fig. 4). It checks the paper's statements about the starting point.
It solves the inequalities with MATLAB's `coneprog` and also verifies the
matrix $T$ printed in the paper. It then shows that $V$ decreases along both
the original and the transformed trajectories.

---

## 6. Related papers

| Content | Publication |
|---|---|
| Ch. 2 | Z. Guo, T. Hayakawa, "Topology of Nash equilibrium set with quadratic vector payoff functions," *Proc. American Control Conference*, 2024, pp. 845–850. |
| Ch. 3 | Z. Guo, T. Hayakawa, Y. Yan, "Nash equilibrium of 2-agent game with quadratic vector payoff function and its stability," *Proc. IFAC World Congress*, 2023, pp. 2824–2829. |
| Ch. 3 | Z. Guo, T. Hayakawa, Y. Yan, "Stability and stabilization of Nash equilibrium for noncooperative systems with vector-valued payoff functions," *Proc. IEEE CDC*, 2023, pp. 203–208. |
| Ch. 4 | Z. Guo, T. Hayakawa, "Pareto improvement for noncooperative systems with vector-valued payoff functions," *Proc. IEEE CDC*, 2024, pp. 960–965. |
| Ch. 5 | Z. Guo, T. Hayakawa, "Two-agent noncooperative dynamical systems with quadratic vector-valued payoff functions and weak Pareto improvement," *IEEE Control Systems Letters*, vol. 8, pp. 3327–3332, 2024. |
| Extension | Z. Guo, T. Hayakawa, "A coordinate transformation method for stability analysis of Nash equilibria with vector payoff functions," *Proc. European Control Conference*. |
