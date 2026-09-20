# Concepts and notation

This page fixes the notation used throughout the public documentation. The
superscript/subscript order is scientifically significant.

## Players, objectives, and gradients

| Symbol or term | Meaning | Common misreading to avoid |
|---|---|---|
| $x=[x^1,x^2]^\mathsf{T}$ | State; agent $i$ controls coordinate $x^i$. | The superscript is an agent label, not a power. |
| $J_j^i(x)$ | Objective $j$ of agent $i$: **superscript = agent, subscript = objective**. | $J_2^1$ is agent 1's second objective, not agent 2's first objective. MATLAB names are agent-first: `J12` means $J_2^1$. |
| $\nabla J_j^i$ | Full gradient with respect to every state coordinate. | It is not the scalar own-gradient. |
| $h_j^i=\partial J_j^i/\partial x^i$ | Own-gradient: the derivative with respect to the coordinate controlled by agent $i$. | It omits the derivative with respect to the other agent's coordinate. |
| $\mathrm{BR}_j^i$ | The own-gradient-zero set $h_j^i=0$, called the best-response line in the two-agent quadratic examples. | A BR is not a global trajectory and is not a social optimum. |

For a quadratic payoff,

```math
J_j^i(x)
=\frac{1}{2}x^\mathsf{T}A^{ij}x+(b^{ij})^\mathsf{T}x+c^{ij}.
```

## Weighted games and the Nash set

Each admissible vector $w^i$ gives nonnegative weights over agent $i$'s own
objectives. The corresponding scalarized game uses

```math
\sum_j w_j^i J_j^i(x).
```

$X^*(J)$ is the union of Nash states over the allowed weights. It is a
**decentralized vector-payoff Nash object**, not the centralized social Pareto
set. In the T1 quadratic examples, a state is found from

```math
M(w)x+b(w)=0,
```

and the same weights must be applied to both $M$ and $b$. Finite weight grids
check residuals and nondegeneracy in the implementation; global mapping claims
still depend on the paper's regularity conditions.

## Selected pseudo-gradient and branch rules

The selected pseudo-gradient is the state update assembled after each active
agent selects one own objective. It is neither a full payoff gradient nor the
gradient of a common social-welfare function.

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

## Own contribution, externality, and total payoff rate

For dynamics $\dot{x}=f(x)$,

```math
\frac{dJ_j^i}{dt}
=\frac{\partial J_j^i}{\partial x^i}f^i
+\frac{\partial J_j^i}{\partial x^{-i}}f^{-i}
=\operatorname{own}_j^i+\operatorname{externality}_j^i.
```

- **Own-direction contribution** $\operatorname{own}_j^i$ measures change caused by agent
  $i$'s own motion. It is nonnegative for the selected own objective in these
  dynamics.
- **Externality** measures change caused by the other agent's motion. It can
  reverse the sign of the total rate.
- **Total payoff rate** is the sum of both terms. Own improvement alone does not
  determine it.

The P1 regions are

```math
\Gamma_j^i
=\{x:\operatorname{externality}_j^i\geq 0\},
\qquad
\Omega_j^i
=\left\{x:\frac{dJ_j^i}{dt}\geq 0\right\}.
```

$\Gamma_j^i$ is a sufficient positive-externality certificate and is contained
in $\Omega_j^i$, but the two sets are not equal. Weak improvement for one agent
uses a union over that agent's objectives; all-payoff nondecrease uses the
appropriate intersection.

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
- $U$ is the chosen social-welfare function; its maximizer is the target, not a
  claim that every finite endpoint equals the target.

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
