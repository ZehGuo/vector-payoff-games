# Concepts and notation

This page fixes the notation used throughout the public documentation. The
superscript/subscript order is scientifically significant.

[Back to README](../README.md) · [Beginner guide](BEGINNER_GUIDE.md) · [Results](RESULTS.md) · [Sources and claims](SOURCES_AND_CLAIMS.md)

## Scope of the state notation

In general, write $x=[(x^1)^\mathsf{T},\ldots,(x^n)^\mathsf{T}]^\mathsf{T}$,
where the block $x^i\in\mathbb{R}^{r_i}$ is controlled by agent $i$. Most
S1–I1 examples have two agents with scalar actions, so there
$x=[x^1,x^2]^\mathsf{T}\in\mathbb{R}^2$. T1 is broader: its cube has three
agents with one scalar action each, while its prism has a two-dimensional
action for agent 1 and a scalar action for agent 2.

## Players, objectives, and gradients

| Symbol or term | Meaning | Common misreading to avoid |
|---|---|---|
| $x=[(x^1)^\mathsf{T},\ldots,(x^n)^\mathsf{T}]^\mathsf{T}$ | State; agent $i$ controls block $x^i$. In the common two-scalar-agent case this reduces to $[x^1,x^2]^\mathsf{T}$. | The superscript is an agent label, not a power. |
| $J_j^i(x)$ | Objective $j$ of agent $i$: **superscript = agent, subscript = objective**. | $J_2^1$ is agent 1's second objective, not agent 2's first objective. MATLAB names are agent-first: `J12` means $J_2^1$. |
| $\nabla J_j^i$ | Full gradient with respect to every state coordinate. | It is not the scalar own-gradient. |
| $h_j^i=\partial J_j^i/\partial x^i$ | Own-gradient: the derivative with respect to the action block controlled by agent $i$; it is a scalar only when $r_i=1$. | It omits derivatives with respect to other agents' action blocks. |
| $\mathrm{BR}_j^i$ | The own-gradient-zero set $h_j^i=0$, called the best-response line in the two-agent quadratic examples. | A BR is not a global trajectory and is not a social optimum. |

For a quadratic payoff,

```math
J_j^i(x)
=\frac{1}{2}x^\mathsf{T}A^{ij}x+(b^{ij})^\mathsf{T}x+c^{ij}.
```

## Weighted games and the Nash set

For one fixed scalarized game, $x^*$ is a Nash equilibrium when, for every
agent $i$, $x^{i*}$ maximizes that agent's weighted payoff while
$x^{-i*}$ is held fixed. The source framework maximizes payoffs rather than
minimizing costs.

Each admissible vector $w^i$ belongs to the closed simplex

```math
\Delta^{s_i-1}=\{w^i\in\mathbb{R}^{s_i}:w_j^i\geq0,\ \sum_jw_j^i=1\}.
```

Thus boundary weights are allowed and the all-zero vector is not. The
corresponding scalarized game uses

```math
\sum_j w_j^i J_j^i(x).
```

$J$ denotes the collection of all agents' vector payoff functions. In the
strictly concave differentiable source setting, the paper characterizes
$X^*(J)$ as the union of Nash states over the allowed weights. If a weighted
game has more than one Nash state, all of its Nash states belong to that union.
It is a
**decentralized vector-payoff Nash object**, not the centralized social Pareto
set. In the T1 quadratic examples, a state is found from

```math
M(w)x+b(w)=0,
```

and the same weights must be applied to both $M$ and $b$. Strict concavity makes
the own-action stationarity conditions sufficient for the relevant best
responses; invertibility supplies the unique linear-system solution in the T1
examples. Finite weight grids check residuals and nondegeneracy in the
implementation; global mapping claims still depend on dissertation Proposition
2.1 and Theorem 2.4.

The simplex notation $\Delta^1$ means a line segment of two-objective weights;
$\Delta^2$ means a filled triangle of three-objective weights. A **surjection** reaches
every point of the Nash image, a **bijection** also gives every image point one
weight preimage, and a **diffeomorphism** is a smooth bijection with a smooth
inverse.

## Selected pseudo-gradient and branch rules

The selected pseudo-gradient is the state update assembled after each active
agent selects one own objective. It is neither a full payoff gradient nor the
gradient of a common social-welfare function.

In the two-objective scalar-action dynamics used here, agent $i$ is active
when its two own-gradients have the same strict sign. If they have opposite
signs, or either is zero, its update is set to zero. On an active branch the
selected objective $j$ supplies

```math
\dot{x}^i=\alpha_j^i h_j^i(x),
```

where $\alpha$ is a positive sensitivity/time-scale parameter. In the quadratic
case $h_j^i=a_j^i(x^i-\mathrm{BR}_j^i(x^{-i}))$, so
$\lvert h_j^i/a_j^i\rvert$ is the distance to that objective's BR line. The
implemented tie rule selects objective 1. Boundary labels may overlap, but the
selected zero own-gradient still gives a zero vector-field value.

This repository treats that rule as a deterministic, pointwise piecewise ODE
and integrates the selected right-hand side. It does not claim a separate
Filippov or differential-inclusion analysis on switching boundaries. A reader
who needs such a solution concept should not infer it from the plotted paths.

Two selection rules occur and are named explicitly:

- **nearest-BR rule:** compare $\lvert h_j^i/a_j^i\rvert$, where $a_j^i$ is the own
  curvature;
- **scaled-own-gradient rule:** compare $\alpha_j^i\lvert h_j^i\rvert$.

They are globally equivalent for agent $i$ only when

```math
\alpha_1^i\lvert a_1^i\rvert
=\alpha_2^i\lvert a_2^i\rvert.
```

Otherwise they may choose the same branch at a particular state but are not the
same rule. The P1 legacy trap retains the scaled-own-gradient label.

## Stability and branch vocabulary

- **Branch matrix:** the local linear state matrix after one objective has been
  selected for each active agent.
- **Hurwitz matrix:** every eigenvalue has strictly negative real part. This is
  a local branch property, not by itself a theorem about the whole piecewise
  system.
- **Active cone:** the region in which a particular pair of objectives is
  selected. An eigenray matters only when it lies in the cone whose matrix
  generated it.
- **0/1/2-transitive:** locally, zero, one, or two cone boundaries can be exited
  toward adjacent domains under the recorded eigenstructure.
- **Set stability:** trajectories starting sufficiently near the Nash set
  remain near it. **Asymptotic set stability** additionally requires their
  distance to the set to tend to zero. These are the S1/S2 theorem notions;
  they are not inferred from one plotted path.
- **General position:** the source Assumption 1 requires no parallel BR pair,
  no triple intersection, and no horizontal or vertical BR line.
- **Rank-degenerate / rank-zero pinch:** at a Nash point, one agent's pair of
  own-gradients loses rank, producing the Assumption-4 geometry used in S2.
- **Compact / noncompact:** compact means closed and bounded in these
  finite-dimensional examples. A sampled **recession direction** illustrates
  an unbounded direction, but S2's mixed determinant signs plus Proposition 3.1
  provide the analytic noncompactness result.

Determinant signs are not universal stability rules. Their conclusions in S1
and S2 require the cited general-position, rank, cone/transition, and theorem
hypotheses. Mixed signs in S2 classify the Nash set as noncompact; they do not
classify the global stability of that mixed-sign system.

## Own contribution, externality, and total payoff rate

For dynamics $\dot{x}=f(x)$,

```math
\frac{dJ_j^i}{dt}
=\frac{\partial J_j^i}{\partial x^i}f^i
+\frac{\partial J_j^i}{\partial x^{-i}}f^{-i}
=\mathrm{own}_j^i+\mathrm{externality}_j^i.
```

- **Own-direction contribution** $\mathrm{own}_j^i$ measures change caused by agent
  $i$'s own motion. It is nonnegative for the selected own objective in these
  dynamics.
- **Externality** measures change caused by the other agent's motion. It can
  reverse the sign of the total rate.
- **Total payoff rate** is the sum of both terms. Own improvement alone does not
  determine it.

The P1 regions are

```math
\Gamma_j^i
=\{x:\mathrm{externality}_j^i\geq 0\},
\qquad
\Omega_j^i
=\left\{x:\frac{dJ_j^i}{dt}\geq 0\right\}.
```

$\Gamma_j^i$ is a sufficient positive-externality certificate and is contained
in $\Omega_j^i$, but the two sets are not equal. At a given time:

- **weak instantaneous improvement** means that, for every agent, at least one
  of its objective rates is nonnegative;
- **all-payoff nondecrease** means every objective rate of every agent is
  nonnegative;
- **nonweak** in the P1 comparison is a case where the weak instantaneous
  condition fails.

The displayed P1 property labels concern the full recorded time interval. A
zero rate counts as nondecrease. A cross-time trap is different: for one agent,
all payoff levels at a later time are lower than at an earlier time even though
the sampled trajectory meets the instantaneous weak condition. The identity of
the currently nondecreasing objective can change over time, so the
instantaneous condition does not forbid that cross-time outcome.

## Non-bijective representation

| Symbol | Meaning | Boundary |
|---|---|---|
| $\eta(x)$ | The paper's state-dependent coordinate map. | It can be many-to-one. |
| $\eta(x(t))$ | Pointwise evaluation of $\eta$ after integrating the original $x(t)$. | It is not a second ODE solution. |
| $z(t)$ | An independently integrated transformed-system trajectory with $z(0)=\eta(x_0)$. | It is not constructed by interpolation or by choosing an inverse-fiber representative. |

Two-dimensional active domains map to local quadrant subsets, one-active strips
map to axes, and $X^*(J)$ maps to the origin. On an axis, the inverse image is a
set-valued fiber; the implementation does not select an arbitrary original
state. The map is an analysis device, not a controller or stabilizer.

For the two-scalar-agent paper example, define the signed normalized distance
to objective $j$'s BR line by

```math
d_j^i(x)=\frac{h_j^i(x)}{a_j^i}.
```

If $d_1^id_2^i\leq0$, then $\eta^i(x)=0$. Otherwise $\eta^i(x)$ is whichever of
$d_1^i,d_2^i$ has smaller absolute value, with objective 1 used at a tie. The
pair $\eta(x)$ therefore records selected signed BR distances and deliberately
collapses inactive directions. Inside a fixed double-active domain, the chain
rule gives the paper's transformed linear branch; on an axis the original
state has a full fiber of preimages, so the transformed ODE uses its own forward
branch rule rather than selecting an inverse representative.

The printed piecewise-quadratic $V$ is a Lyapunov certificate: positivity
margins check $V(z)>0$ away from the origin, and decay margins check
$\dot V(z)<0$ on each branch. Temporary growth of the Euclidean norm is not a
contradiction to decrease of this branch-dependent certificate.

## Incentive-design parameters

Only $J_1^i$ is modified in I1. For the displayed $Q_i=0$ construction,

```math
\widetilde{J}_1^i(x)
=\zeta_i\sigma\bigl[U(x)-U(x_0)\bigr]
-\omega_i\bigl[J_2^i(x)-J_2^i(x_0)\bigr]
+J_1^i(x_0).
```

- $\sigma$ scales the welfare term and changes the topology of the budget
  boundary in the illustrated legacy game.
- $\omega_i$ weights the unincentivized objective in the modified stationarity
  relation and in the aggregate budget identity.
- $\zeta_i$ allocates the welfare term across agents.
- $U=\sum_{i,j}\eta_j^iJ_j^i$ is the chosen weighted social-welfare function;
  the I1 welfare-weight vector is stored as `eta` in code and is unrelated to
  X1's coordinate map $\eta(x)$. Its maximizer is the target, not a
  claim that every finite endpoint equals the target.

With $Q_i=0$, no optional quadratic shaping term is added. “Target
stationarity” means that the modified weighted own-gradient vanishes at the
chosen welfare target under the theorem's stated weights and assumptions; it
does not mean that every original payoff component is stationary there.

The incentive transfer is $p^i=\widetilde J_1^i-J_1^i$: only the first payoff
component is directly modified. The sign convention is from the system
manager's sustainable-budget constraint. Here $p^1+p^2\leq0$ means the
aggregate modification does not require a positive net payment by the manager;
the complement $D_{\mathrm{bud}}^c$ is excluded because aggregate transfer is
positive there. Anchoring means $p^i(x_0)=0$.

The complete identity is

```math
\begin{aligned}
p^1(x)+p^2(x)
&=\sigma\bigl[U(x)-U(x_0)\bigr]
-\bigl[J_{\mathrm{sum}}^\omega(x)-J_{\mathrm{sum}}^\omega(x_0)\bigr],\\
J_{\mathrm{sum}}^\omega
&=J_1^1+\omega_1J_2^1+J_1^2+\omega_2J_2^2.
\end{aligned}
```

Both $\omega$-weighted terms must remain. The same-game $\omega$ comparison
and the separate INC-omega game answer different questions and are not merged.

`INC-0` names the checked configuration with $\omega=0$. `INC-omega` is a different
source-labelled game, not a one-factor variant of INC-0. $D(U,x_0)$ is the
region where welfare is no lower than at $x_0$; $D(J_{\mathrm{sum}},x_0)$
is the analogous comparison for the recorded payoff sum; and
$D_{\mathrm{bud}}$ is the region satisfying the aggregate budget inequality.
The source theorem also needs the relevant smallest trajectory-containing set
to remain inside the required externality and budget regions. That forward
invariant-set containment has not been proved for the displayed parameters, so
the algebra and sampled paths are not promoted to the theorem's full guarantee.

## Evidence words used in this repository

- **theorem/paper identity:** a claim whose global scope comes from the cited
  paper conditions;
- **exact algebra/branch calculation:** a symbolic or direct matrix result;
- **clean MATLAB execution:** a fresh MATLAB process produced the declared
  artifacts;
- **independent numerical check:** a separately implemented calculation agrees
  at its stated numerical level;
- **finite sampling:** evidence only on the recorded grid or trajectory;
- **schematic:** a conceptual drawing with no asserted source parameters.

These labels describe different strengths of evidence. A plot, a successful
run, or a finite sample is never promoted to a theorem proof.
