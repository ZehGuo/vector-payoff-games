# A beginner's tour

This guide explains the ideas behind the scripts with pictures and as little
mathematics as possible. Every figure is produced by a script, and every
mark in a figure is explained in the text next to it. Each section ends with
the scripts to run and the paper where the idea comes from.

1. [The setting](#1-the-setting)
2. [What does the equilibrium region look like?](#2-what-does-the-equilibrium-region-look-like)
3. [Do the players settle down?](#3-do-the-players-settle-down)
4. [Does everybody get better off along the way?](#4-does-everybody-get-better-off-along-the-way)
5. [Can a manager help, without spending money?](#5-can-a-manager-help-without-spending-money)

---

## 1. The setting

- There are a few **players** (mostly two). Player *i* chooses a number xⁱ,
  for example how much a firm produces.
- Each player has **two goals**, for example profit and environmental score.
  Goal *j* of player *i* is written Jⁱⱼ (in papers also called a *payoff*),
  so J¹₁, J¹₂ are player 1's goals and J²₁, J²₂ are player 2's.
- Every goal depends on what **both** players choose, and each is a simple
  quadratic ("hill-shaped") function:

  ```math
  J^i_j(x) = \frac{1}{2}\, x^\top A^{ij} x + (b^{ij})^\top x + c^{ij}
  ```

  In the code, a game is a struct `G` with `G.A{i,j}`, `G.b{i,j}` and
  `G.c(i,j)` holding these numbers.
- **Best response.** If the other player's choice is fixed, each goal has one
  best choice for player *i*. Drawing these best choices for every possible
  choice of the other player gives a straight line, the **best-response
  line** of that goal. With 2 players and 2 goals each, there are 4 lines.
- **Equilibrium.** A state is an equilibrium if **no player can improve both
  of its goals at once** by changing only its own choice. Because players do
  not rank their goals, many states qualify: the equilibria form a whole
  **region**, the *equilibrium set*.

### How to read the figures

All figures use the same marks, so they only need to be learned once:

| Mark | Meaning |
|---|---|
| red / blue | player 1 / player 2 |
| solid / dashed | goal 1 / goal 2 |
| a red or blue line on a map | the best-response line of that goal |
| a red or blue curve over time | how much that goal has changed since the start (above 0: better than at the start) |
| purple area | the equilibrium set |
| black line with arrows, starting at a black dot | a simulated path of the players |
| faint grey-blue lines | the direction in which the players would move from each place |
| light red / light blue | player 1 / player 2 **loses both goals at once** there (on a map) or then (over time) |

On a map, the horizontal axis x¹ is player 1's choice and the vertical axis
x² is player 2's choice.

---

## 2. What does the equilibrium region look like?

**The trick: weights.** Suppose each player decided how much it cares about
each goal, say 70% profit and 30% environment. Then it would have just one
number to maximize, and the game would have one ordinary equilibrium. Every
choice of weights gives one such point. **Collecting these points for all
possible weights gives exactly the equilibrium region.**

The figure below shows a production–pollution example with two firms
(goal 1 = profit, goal 2 = environment):

- **Left:** every square is one choice of weights; across, firm 1's weight on
  profit, up, firm 2's.
- **Right:** every dot is the equilibrium for the weights of the same colour
  on the left. The dots fill the purple region. The four lines are the
  best-response lines of the four goals; they form the region's border.
- **Black dots:** the four corners of the square (each firm cares about one
  goal only) become the four corners of the region.

![Equilibrium region](figures/equilibrium_region.png)

The script also checks the region a second, independent way: a state is an
equilibrium when, for each firm, moving can only raise one goal while
lowering the other.

**What we learn.**
- **The determinant test.** Each best-response line can be written as
  a·x¹ + b·x² = c. Pick one goal per player and put the numbers (a, b) of
  their two lines into the rows of a 2×2 matrix. With 2 goals per player
  there are four such matrices. If all four determinants have the same sign,
  the region is **bounded and in one piece**.
- If, in addition, a player's two goals never peak at the same state inside
  the region, the region is a **faithful copy of the set of weights**:
  different weights give different equilibria, and edges and faces match.

The next figure shows this with **three players**. Write wᵢ for player *i*'s
weight on its goal 1 (so wᵢ = 0 means "player *i* cares only about goal 2").
All weights together form a cube (left); the equilibrium set is a deformed
cube (right). Each face carries its name, for example w₁ = 0, and the same
colour on both sides. The top row shows three faces, the bottom row the
other three (seen from the other side); the right shape is turned so that it
shows the same faces as the cube next to it:

![Three players](figures/equilibrium_three_players.png)

The same holds when player 1 chooses **two numbers** (x¹₁, x¹₂) and has
**three goals**. Its weights λ₁, λ₂, λ₃ on the three goals add up to 1 and
form a triangle; together with μ, player 2's weight on its goal 2, all
weights form a prism with 5 faces. The face λ₁ = 0, for example, means
"player 1 ignores goal 1". Each face becomes one face of the equilibrium set:

![Vector states](figures/equilibrium_vector_states.png)

**Run:** `equilibrium_region`, `equilibrium_three_players`,
`equilibrium_vector_states`.
**Paper:** [ACC 2024](https://doi.org/10.23919/ACC60939.2024.10644643)

---

## 3. Do the players settle down?

**How the players move.** Players do not plan ahead; they react to the
current state:
- if moving can raise **both** of its goals, a player moves in that
  direction, following the goal whose best-response line is **closer**;
- otherwise (any move would hurt one goal) it **stays put**.

**What we learn.** The answer depends only on the four determinants of the
test in section 2:
- All four determinants **positive**: the region is bounded and **stable**.
  Players who start near it are drawn into it.
- All four **negative**: the region is bounded but **unstable**. Players who
  start near it drift away.
- **Mixed** signs: the region is **unbounded**.

The four lines can be arranged in five essentially different ways; four are
stable and one is unstable. In each panel below, the title is the prediction
from the determinants, the faint lines show where the players would move
from every place, and one simulated path shows what happens: in (a)–(d) it
runs into the purple region, in (e) it starts right next to the region and
moves away. (The script checks this for twelve start points around each
region.)

![Stability, one piece](figures/stability_one_piece.png)

The same rule holds when the region consists of two pieces touching at a
point (`stability_two_pieces.png`). With mixed signs the purple region runs
out of the picture in two directions (`stability_unbounded.png`).

**A shortcut with an "energy" function.** Checking the regions one by one is
long. The figure below shows a shorter way in three steps:

- **(a) New coordinates.** For a state x (black dot), measure how far each
  player is from the best-response line it is following: z¹ is the
  horizontal distance (red arrow) from player 1's line, z² the vertical
  distance (blue arrow) from player 2's line. Here both players follow the
  dashed line of their goal 2, because it is the closer one. A player that
  does not move gets 0, so every state inside the purple region, such as the
  white dot, gets z = (0, 0).
- **(b) The original picture.** The path from the black dot ends in the
  purple region. The dotted closed curves are levels of an "energy"
  (a Lyapunov function); the path only crosses them inwards, so the energy
  never increases.
- **(c) The same path in the new coordinates z¹, z².** The whole purple
  region has become the single point (0, 0), and the path runs into it.
  Stability of a region has become stability of a point, which is much
  easier to prove. The computer finds the energy by solving a small convex
  problem.

![Lyapunov](figures/stability_lyapunov.png)

**Run:** `stability_cases`, `stability_lyapunov`.
**Papers:** [IFAC 2023](https://doi.org/10.1016/j.ifacol.2023.10.1395),
[CDC 2023](https://doi.org/10.1109/CDC49753.2023.10384265), and ECC
(coordinate change).

---

## 4. Does everybody get better off along the way?

Two ways to say "better off" while the players move:
- **Pareto improving:** no goal of any player ever goes down.
- **Weakly Pareto improving:** at every moment, each player has **at least
  one** goal that is not going down. In other words, no player ever loses
  both goals at once.

**Who can hurt you?** A player only moves to improve its own goals, so its
own move never hurts itself. Only the **other** player's move can lower its
goals. The paper shows how to tell, from the goals alone, whether every path
will be (weakly) Pareto improving; the script checks these conditions for
the three examples below.

Each column of the figure is one example. The top row is the map with the
path; the bottom row shows how much each of the four goals has changed since
the start. Wherever a player loses both goals at once, the path on the map
and the same moments in the time plot are shaded in that player's light
colour:

- **(a)** Player 2 loses both goals for a short moment (light blue), and
  player 1 loses both goals from about t = 1.4 on (light red): not even
  weakly Pareto improving.
- **(b)** All four curves only go up: Pareto improving.
- **(c)** Player 2's goal 1 goes down, but its goal 2 goes up at the same
  time, and no shading appears: weakly Pareto improving.

![Pareto improvement](figures/improvement_pareto.png)

**The trap.** "No player ever loses both goals at once" is not enough. A
player's two goals can take turns falling. Comparing a later moment with an
earlier one, **both** goals can then be lower, and the player is simply
worse off. In the figure below:

- **(a)** The light-blue area is where player 2 *would* lose both goals at
  once. The path never enters it, so the path is weakly Pareto improving.
  The white square marks where the players are at time t₂.
- **(b)** Player 2's two goals over time: goal 1 (solid) falls first, then
  goal 2 (dashed) falls. At time t₂ (white squares) both are below their
  start values (below 0), and they stay there: player 2 is worse off than at
  the start, although it never lost both goals at the same moment.

![Trap](figures/improvement_trap.png)

**Run:** `improvement_pareto`, `improvement_trap`.
**Papers:** [CDC 2024](https://doi.org/10.1109/CDC56724.2024.10886420),
[IEEE Control Systems Letters 2024](https://doi.org/10.1109/LCSYS.2024.3522596)

---

## 5. Can a manager help, without spending money?

A manager wants the players to reach a **target** state (yellow star) that is
good for society. Society's welfare U is a weighted sum of all goals, with
the manager's priorities as weights, and the target is where U is largest.
Goal 1 of each player is **money**, and the manager can add a tax or subsidy
pⁱ to it, but only under two budget rules:

- nobody gains or loses at the start: p¹ = p² = 0 at the starting state;
- the manager never pays out net money: p¹ + p² ≤ 0 at all times.

**The design.** In the simplest version, each player's money goal is replaced
by a fixed share ζᵢ of the gain in social welfare (ζ₁ + ζ₂ = 1), scaled by a
strength σ:

```math
\tilde J^i_1(x) = \zeta_i\,\sigma\,\bigl(U(x) - U(x_0)\bigr) + J^i_1(x_0)
```

Each player is now paid according to how much **society** improves, so
selfish moves push towards the target. Because a player's new money goal can
never go down, nobody falls into the trap.

**The budget region.** The manager pays nothing net (p¹ + p² ≤ 0) only in
part of the map, the **budget region** (orange), and the players must stay
inside it. The figure shows it for three strengths σ, in the game of the trap
example. The start (black dot) always lies on its edge, because nothing is
paid there. For a weak incentive (a) the region is the inside of an ellipse
and contains the target. For stronger incentives (b, c) its border becomes a
hyperbola or an ellipse with the region outside, and the target is no
longer inside: the manager could not afford to bring the players there.

![Budget region](figures/incentive_budget.png)

**Result.** The last figure compares the same game without and with a weak
incentive (σ = 0.05):

- **(a) Without incentive**, the path (black) stops at a corner of the
  purple equilibrium set, away from the target (star). Along the way
  player 1 loses both goals (light red on the path).
- **(b) With incentive**, the lines and the purple set are those of the new
  game. The target is now an equilibrium, and the path goes from the start
  straight to it, inside the budget region (orange).
- **(c) Without incentive over time:** player 1 loses both goals for most of
  the time (light red). Money changes much more than the other goals, so
  money (goal 1) is shown divided by 10.
- **(d) With incentive over time:** goal 1 is now money plus incentive. All
  four goals go up, so nobody ever loses both goals, and the manager's net
  payment p¹ + p² (grey dotted) stays below zero.

![Incentive design](figures/incentive_design.png)

**Run:** `incentive_budget`, `incentive_design`.
**Paper:** [IEEE Control Systems Letters 2024](https://doi.org/10.1109/LCSYS.2024.3522596)
