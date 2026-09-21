# Beginner guide

[Back to README](../README.md) · [Concepts and notation](CONCEPTS_AND_NOTATION.md) · [Results](RESULTS.md) · [Sources and claims](SOURCES_AND_CLAIMS.md) · [Reproducing](REPRODUCING.md)

This page is the recommended first stop for a reader who knows little game
theory or dynamical systems. It explains the story before introducing the
technical evidence.

## The project in one paragraph

Each agent chooses its own action and has several payoff objectives. The agent
does not begin with one permanently fixed preference between those objectives.
We therefore assign nonnegative preference weights that sum to one, solve the
ordinary scalar-payoff game produced by those weights, and repeat over all
allowed weights. The union of the resulting equilibria is the vector-payoff
Nash set. The repository studies its geometry, the motion of agents around it,
the effect of that motion on all payoffs, a coordinate representation used for
stability analysis, and conditional incentive designs.

## A minimal two-agent picture

Suppose company 1 controls production $x^1$ and company 2 controls production
$x^2$. Each company has a profit objective and an environmental objective.
For agent $i$, choose weights $w_1^i,w_2^i\geq0$ with
$w_1^i+w_2^i=1$, and form

```math
w_1^iJ_1^i(x)+w_2^iJ_2^i(x).
```

For one fixed pair of weight vectors, a Nash equilibrium is a state where each
company's action maximizes its own weighted payoff while the other company's
action is held fixed. Changing the weights can change that equilibrium. The
collection of all such equilibria is $X^*(J)$. It is decentralized: it is not
the same construction as centrally maximizing a social-welfare function.

In the strictly concave quadratic examples, the own-action first-order
conditions are sufficient for the weighted best responses. Stacking those
conditions gives $M(w)x+b(w)=0$. This shortcut is configuration-specific; it
is not a definition of Nash equilibrium for every possible game.

## The arrows are a reading order, not one shared game

The six labels are repository navigation labels, not theorem numbers. Their
arrows show a conceptual research route. They do **not** mean that every module
uses the same payoff functions, number of agents, initial condition, or
parameters.

| Label | Expanded name | Main configuration | Source identity | Shares one game with the next row? |
|---|---|---|---|---|
| T1 | Topology / geometry | Cube: 3 agents, 3 scalar actions; prism: 2 agents, 3 state coordinates; production example: 2 agents, 2 scalar actions | Thesis Chapter 2 parameters/formulas, plus one explicit schematic | No |
| S1 | Stability, compact cases | 2 agents, 2 scalar actions | New theorem-guided constructions; not thesis figure parameters | No |
| S2 | Stability boundaries | 2 agents, 2 scalar actions | New rank-degenerate and noncompact constructions | No |
| P1 | Payoff improvement | 2 agents, 2 scalar actions | Three new analytically solved games plus one source-labelled legacy game | No |
| X1 | Coordinate transformation | 2 agents, 2 scalar actions | Paper example and printed certificate | No |
| I1 | Incentive design | 2 agents, 2 scalar actions | Checked thesis/legacy configurations; the INC-omega supplement is a different game from INC-0 | No |

The words **new analytically solved** in P1 mean that the trajectory and rate
signs are obtained exactly for the constructed formulas. They do not mean an
exact reproduction of thesis Figure 4.3.

## Five definitions to know before viewing the figures

1. **Nash equilibrium:** no agent can improve its own selected scalar payoff by
   changing only its own action while all other actions are fixed.
2. **Scalarization:** replacing several objectives of one agent by their
   weighted sum. The admissible weight vector belongs to the closed simplex
   $\Delta$, so its entries are nonnegative, sum to one, and may lie on the boundary.
   The all-zero vector is not admissible.
3. **Best-response (BR) line:** in the two-agent strictly concave quadratic
   examples, the zero set of one objective's own-gradient. It is an
   objective-specific best-response locus, not the complete multi-objective
   correspondence and not a social optimum.
4. **Selected pseudo-gradient:** the piecewise state-update vector obtained
   after each active agent selects one own-objective direction. It is not a full
   payoff gradient and not a social-welfare gradient.
5. **Set stability:** stability is asked for the whole Nash set, rather than for
   one equilibrium point. The S1/S2 theorem claims are asymptotic stability or
   instability under their stated source assumptions; a plotted trajectory is
   only an illustration.

Here $\Delta^k$ is the $k$-dimensional simplex. Thus $\Delta^1$ is a line segment of
two-objective weights, while $\Delta^2$ is a filled triangle of three-objective
weights.

## How to read a result without overstating it

For every figure, ask three separate questions:

1. **What is sourced?** Paper parameters, a legacy configuration, a new
   construction, or a schematic?
2. **What was checked?** Exact algebra, a theorem's hypotheses, clean MATLAB
   generation, an independent calculation, or a finite grid?
3. **What is the claim size?** Global theorem, configuration-specific analytic
   result, sampled observation, or visual explanation?

The strongest statement is not automatically the most visible one. For
example, a purple unbounded-looking plot does not prove noncompactness; the
paper proposition plus the checked determinant signs supply that conclusion.
Conversely, a theorem does not make newly chosen parameters “paper
parameters.”

## Recommended route

1. Read this page.
2. Use [Concepts and notation](CONCEPTS_AND_NOTATION.md) for the exact symbols
   and technical vocabulary.
3. Follow the 18 figures in [Results](RESULTS.md).
4. Check every theorem-dependent statement in
   [Sources and claims](SOURCES_AND_CLAIMS.md).
5. Use [Provenance](PROVENANCE.md) before reusing a figure or claim.
6. Use [Reproducing](REPRODUCING.md) when you want to run the code.

Running the repository does not require the paper PDFs. Understanding why the
global topology and stability conclusions hold does require the cited paper
results or the theorem synopses and limitations recorded here.
