# Concepts and notation

This page fixes the notation used throughout the public documentation. The
superscript/subscript order is scientifically significant.

## Players, objectives, and gradients

| Symbol or term | Meaning | Common misreading to avoid |
|---|---|---|
| `x=[x^1,x^2]^T` | State; agent `i` controls coordinate `x^i`. | The superscript is an agent label, not a power. |
| `J_j^i(x)` | Objective `j` of agent `i`: **superscript = agent, subscript = objective**. | `J_2^1` is agent 1's second objective, not agent 2's first objective. MATLAB names are agent-first: `J12` means `J_2^1`. |
| `grad J_j^i` | Full gradient with respect to every state coordinate. | It is not the scalar own-gradient. |
| `h_j^i = partial J_j^i / partial x^i` | Own-gradient: the derivative with respect to the coordinate controlled by agent `i`. | It omits the derivative with respect to the other agent's coordinate. |
| `BR_j^i` | The own-gradient-zero set `h_j^i=0`, called the best-response line in the two-agent quadratic examples. | A BR is not a global trajectory and is not a social optimum. |

For a quadratic payoff,

```text
J_j^i(x) = (1/2) x^T A^{ij} x + (b^{ij})^T x + c^{ij}.
```

## Weighted games and the Nash set

Each admissible vector `w^i` gives nonnegative weights over agent `i`'s own
objectives. The corresponding scalarized game uses

```text
sum_j w_j^i J_j^i(x).
```

`X*(J)` is the union of Nash states over the allowed weights. It is a
**decentralized vector-payoff Nash object**, not the centralized social Pareto
set. In the T1 quadratic examples, a state is found from

```text
M(w)x + b(w) = 0,
```

and the same weights must be applied to both `M` and `b`. Finite weight grids
check residuals and nondegeneracy in the implementation; global mapping claims
still depend on the paper's regularity conditions.

## Selected pseudo-gradient and branch rules

The selected pseudo-gradient is the state update assembled after each active
agent selects one own objective. It is neither a full payoff gradient nor the
gradient of a common social-welfare function.

Two selection rules occur and are named explicitly:

- **nearest-BR rule:** compare `|h_j^i/a_j^i|`, where `a_j^i` is the own
  curvature;
- **scaled-own-gradient rule:** compare `alpha_j^i |h_j^i|`.

They are globally equivalent for agent `i` only when

```text
alpha_1^i |a_1^i| = alpha_2^i |a_2^i|.
```

Otherwise they may choose the same branch at a particular state but are not the
same rule. The P1 legacy trap retains the scaled-own-gradient label.

## Own contribution, externality, and total payoff rate

For dynamics `xdot=f(x)`,

```text
dJ_j^i/dt
  = (partial J_j^i / partial x^i) f^i
  + (partial J_j^i / partial x^{-i}) f^{-i}
  = own_j^i + externality_j^i.
```

- **Own-direction contribution** `own_j^i` measures change caused by agent
  `i`'s own motion. It is nonnegative for the selected own objective in these
  dynamics.
- **Externality** measures change caused by the other agent's motion. It can
  reverse the sign of the total rate.
- **Total payoff rate** is the sum of both terms. Own improvement alone does not
  determine it.

The P1 regions are

```text
Gamma_j^i = {x : externality_j^i >= 0},
Omega_j^i = {x : dJ_j^i/dt >= 0}.
```

`Gamma_j^i` is a sufficient positive-externality certificate and is contained
in `Omega_j^i`, but the two sets are not equal. Weak improvement for one agent
uses a union over that agent's objectives; all-payoff nondecrease uses the
appropriate intersection.

## Non-bijective representation

| Symbol | Meaning | Boundary |
|---|---|---|
| `eta(x)` | The paper's state-dependent coordinate map. | It can be many-to-one. |
| `eta(x(t))` | Pointwise evaluation of `eta` after integrating the original `x(t)`. | It is not a second ODE solution. |
| `z(t)` | An independently integrated transformed-system trajectory with `z(0)=eta(x0)`. | It is not constructed by interpolation or by choosing an inverse-fiber representative. |

Two-dimensional active domains map to local quadrant subsets, one-active strips
map to axes, and `X*(J)` maps to the origin. On an axis, the inverse image is a
set-valued fiber; the implementation does not select an arbitrary original
state. The map is an analysis device, not a controller or stabilizer.

## Incentive-design parameters

Only `J_1^i` is modified in I1. For the displayed `Q_i=0` construction,

```text
tilde J_1^i(x)
  = zeta_i sigma [U(x)-U(x0)]
  - omega_i [J_2^i(x)-J_2^i(x0)]
  + J_1^i(x0).
```

- `sigma` scales the welfare term and changes the topology of the budget
  boundary in the illustrated legacy game.
- `omega_i` weights the unincentivized objective in the modified stationarity
  relation and in the aggregate budget identity.
- `zeta_i` allocates the welfare term across agents.
- `U` is the chosen social-welfare function; its maximizer is the target, not a
  claim that every finite endpoint equals the target.

The complete identity is

```text
p^1(x)+p^2(x)
  = sigma [U(x)-U(x0)]
  - [J_sum^omega(x)-J_sum^omega(x0)],

J_sum^omega
  = J_1^1 + omega_1 J_2^1 + J_1^2 + omega_2 J_2^2.
```

Both omega-weighted terms must remain. The same-game `omega` comparison and the
separate INC-omega game answer different questions and are not merged.

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
