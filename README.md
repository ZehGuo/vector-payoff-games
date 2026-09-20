# Vector-Payoff Games: From Nash-Set Geometry to Incentive Design

**Research question:** What changes when each agent pursues several payoff
objectives, but no preference between those objectives is fixed in advance?

## Why does Nash equilibrium become a set?

In a standard scalar-payoff game, each agent optimizes one payoff, and the
analysis often focuses on a Nash equilibrium of that game.

Here, each agent has several payoff components. To obtain a scalar game, the
components are combined using objective weights. Different admissible weights
represent different preferences and can produce different Nash equilibria.

The central object is therefore the **Nash equilibrium set**: the collection of
decentralized equilibrium states generated as the admissible preference weights
vary. The repository asks what this set looks like, whether decentralized
behavior approaches or leaves it, how that behavior affects payoffs, what a
change of representation preserves, and how incentives can alter the behavior.

```text
Multiple objectives
        ↓
Preference weights
        ↓
Nash equilibrium set
        ↓
Geometry             T1
        ↓
Stability            S1 / S2
        ↓
Payoff effects       P1
        ↓
Representation       X1
        ↓
Incentive design     I1
```

**Start here:** [follow the six-part results guide](docs/RESULTS.md) ·
[learn the notation](docs/CONCEPTS_AND_NOTATION.md) ·
[reproduce all six experiments](docs/REPRODUCING.md)

## Three objects that should not be confused

| Object | What it means here | Question it answers |
|---|---|---|
| **Nash set** | The decentralized equilibrium states obtained from different admissible preference weights. | Where can individually optimal responses balance? |
| **Dynamics** | The state trajectory generated when agents move according to a selected pseudo-gradient and branch rule. | Does behavior approach, enter, or leave the Nash set? |
| **Social Pareto / welfare target** | A centralized comparison based on the agents' payoffs or a chosen welfare function. | Which states are desirable from a collective viewpoint? |

**A Nash set is not a social Pareto set.** Nash states describe decentralized
mutual best responses under selected preferences. A social Pareto set or welfare
target compares outcomes centrally. The two constructions answer different
questions and need not select the same states.

![Four styled best-response lines bound a purple weighted Nash region in two-dimensional production space; the region is explicitly distinguished from a social Pareto set.](docs/assets/t1_s1_s2/T1_production_pollution_card_900.png)

*In the production--pollution example, varying the objective weights produces
the purple decentralized weighted Nash image. The region is not a centralized
welfare optimum.*

## From preference weights to a Nash set

For agent $i$, $J_j^i$ denotes objective $j$, and $w_j^i \geq 0$ is an
admissible weight on that objective. A weighted scalar game asks each agent to
maximize

$$
\sum_j w_j^i J_j^i(x).
$$

$X^*(J)$ is the union of the Nash states obtained over the allowed weights. In
the quadratic T1 examples, a weight produces a state by solving

$$
M(w)x+b(w)=0,
$$

with the **same weights applied to both $M$ and $b$**. Under the paper's stated
regularity conditions, this gives the weight-domain/Nash-image correspondence.
The finite grids in this repository check the implementation; they do not prove
the global one-to-one/onto statement. See
[Concepts and notation](docs/CONCEPTS_AND_NOTATION.md) for the complete symbol
map.

![A compact key pairs the six cube faces and eight vertices by matching identifiers from the weight cube to the weighted Nash image.](docs/assets/t1_s1_s2/T1_cube_correspondence_card_900.png)

*Matching identifiers connect faces and vertices of the weight cube to the
weighted Nash image. This card is a map key, not a numerical proof of global
bijectivity.*

## The six-part research chain

### T1 — Geometry of the Nash Set

**Question:** How do admissible preference weights generate and organize a Nash
set?

Weights define scalarized games, and their Nash equilibria assemble into a
geometric image. The cube and prism cases retain the paper parameters, the
production--pollution case provides an application, and the nonlinear boundary
figure is explicitly schematic.

### S1 — Stability of Piecewise Game Dynamics

**Question:** When do decentralized piecewise dynamics approach a compact Nash
set, and when can they move away from it?

A selected pseudo-gradient chooses one own-objective direction for each active
agent. Branch matrices, determinant signs, eigenstructure, active cones, and
theorem assumptions distinguish four stable new cases from one unstable new
case. Trajectories illustrate these classifications; they do not establish them
by themselves.

![A stable phase portrait shows a black trajectory entering a purple Nash quadrilateral among styled best-response lines.](docs/assets/t1_s1_s2/S1_stable_case_card_900.png)

*Stable S1 representative: analytic branch and theorem checks classify the
case; the trajectory illustrates that classification.*

![An unstable phase portrait highlights a magenta dashed outward eigenray witness within a purple Nash quadrilateral.](docs/assets/t1_s1_s2/S1_unstable_case_card_900.png)

*Unstable S1 representative: the active positive-eigenvalue ray is the local
witness. Visual slope or one trajectory endpoint is not the proof.*

### S2 — Degenerate and Noncompact Cases

**Question:** What changes when the Nash geometry becomes rank-degenerate or
unbounded?

S2 separates two settings. New rank-degenerate constructions are classified
under the recorded Theorem 3.11 hypotheses. Separate new noncompact
constructions use mixed branch-determinant signs under the recorded
general-position condition and Proposition 3.1. A bounded plotting window or a
sampled recession direction is not the noncompactness proof.

### P1 — Payoff Improvement and Externalities

**Question:** If an agent moves in a direction that improves its selected
objective, must its total payoff improve?

For dynamics $\dot{x}=f(x)$, the rate of every payoff decomposes as

$$
\frac{dJ_j^i}{dt}
=
\underbrace{\frac{\partial J_j^i}{\partial x^i}\dot{x}^i}_{\text{own-direction contribution}}
+
\underbrace{\frac{\partial J_j^i}{\partial x^{-i}}\dot{x}^{-i}}_{\text{externality}}.
$$

In words: **total payoff rate = own-direction contribution + externality**.

The answer is no in general. An agent's own motion can contribute positively
while the other agent's motion creates a sufficiently negative externality.
This decomposition is the bridge between the decentralized dynamics and their
welfare effects.

The first three P1 games keep the trajectory and own-gradient structure fixed
while changing only linear externalities. They are a new exact comparison
family: nonweak, all-payoff-nondecreasing, and weak-but-not-all. A fourth,
separate experiment uses the actual legacy scaled-own-gradient rule to exhibit
a sampled two-time weak-Pareto trap.

![Four payoff diagnostics compare own-direction, externality, and total payoff rates; externality changes the sign of some total rates.](docs/assets/p1_i1/P1_rate_decomposition_card.png)

*Moving in an own-improving direction need not raise total payoff. The
externality from the other agent's motion is the missing term.*

### X1 — Non-bijective Representation

**Question:** Can a set-stability problem be represented as an origin-stability
problem, and what information can that representation lose?

The original problem asks whether $x(t)$ approaches the Nash set. The
transformation $z=\eta(x)$ maps the Nash set to the origin, allowing the
set-stability question to be studied in transformed coordinates.

The key limitation is that $\eta$ is non-bijective. Different original states
may have the same image, so an inverse image can be a set-valued fiber. The
original trajectory $x(t)$, its pointwise image $\eta(x(t))$, and an
independently integrated transformed-system trajectory $z(t)$ are therefore
different mathematical objects. The transformation is an analysis device, not
a controller or stabilizer.

![Six original states lie on one colored fiber and map to one filled point on a transformed coordinate axis.](docs/assets/x1/X1_fiber_collapse_vertical_900.png)

*Many original states can share one image point. The inverse is the full fiber,
not a selected representative state.*

### I1 — Conditional Incentive Design

**Question:** Under explicit conditions, how can incentives change
decentralized behavior toward a chosen welfare target?

I1 moves the research chain from **analysis of a given game** to **designing
incentives that change decentralized behavior**. The construction modifies
only $J_1^i$ and keeps the target, $\omega$, $\sigma$, anchoring, and budget roles
explicit. It evaluates original payoffs, modified payoffs, and aggregate
transfer. $\omega$ is compared within the same INC-0 game; the INC-omega
supplement is a different game.

The evidence boundary remains:

`algebra checked | trajectory observed | invariant containment unproved`

![Original and incentivized trajectories share an initial state; the incentivized path ends near, but not exactly at, the marked target.](docs/assets/p1_i1/I1_trajectory_card.png)

*The observed incentivized trajectory approaches the target region. This is not
an unconditional theorem guarantee because full invariant-set containment has
not been proved for the displayed parameters.*

## Results at a glance

| Group | Research question | Main public conclusion | Entry |
|---|---|---|---|
| T1 | How do payoff weights generate a Nash set? | Under the paper conditions, weight-domain structure corresponds to a weighted Nash image; Nash is not social Pareto. | [`run_t1_topology_applications`](experiments/run_t1_topology_applications.m) |
| S1 | When is the piecewise Nash set stable or unstable? | Four new cases satisfy the stable branch pattern; one retains active positive-eigenvalue witnesses. | [`run_s1_five_cases`](experiments/run_s1_five_cases.m) |
| S2 | What changes at rank degeneracy or noncompactness? | Rank-degenerate cases use Theorem 3.11; mixed determinant signs certify separate noncompact constructions via Proposition 3.1. | [`run_s2_degenerate_noncompact`](experiments/run_s2_degenerate_noncompact.m) |
| P1 | Does own improvement imply payoff improvement? | No: total change also contains externality; the legacy trap is separate finite-grid evidence. | [`run_p1_payoff_properties`](experiments/run_p1_payoff_properties.m) |
| X1 | What does a non-bijective representation preserve or collapse? | Fibers collapse, and $\eta(x(t))$ is not the independently integrated $z(t)$. | [`run_x1_transformation_stability`](experiments/run_x1_transformation_stability.m) |
| I1 | What can a budget-aware incentive design show? | The algebra and observed paths pass their checks, while full invariant-set containment remains unproved. | [`run_i1_incentive_budget`](experiments/run_i1_incentive_budget.m) |

Every one of the 18 technical figures has a research question, comparison,
caption, alt text, evidence statement, and “do not infer” boundary in
[Results](docs/RESULTS.md).

## Reading routes

- **30 seconds:** read “Why does Nash equilibrium become a set?”, the research
  map, and “Three objects that should not be confused.”
- **3 minutes:** add the six research questions, the P1 rate decomposition, the
  X1 fiber limitation, and the I1 evidence boundary.
- **15 minutes:** follow all six experiment groups in
  [Results](docs/RESULTS.md), then use the linked entries, figures, and
  verification records for the groups that matter to you.

## Reproduce the public outputs

Tested with **MATLAB R2025b Update 7 on macOS**. Other releases have not been
verified. From a new clone at the repository root:

```bash
/Applications/MATLAB_R2025b.app/bin/matlab -batch "addpath('experiments'); run_public_reproduction"
```

The wrapper writes only below the ignored `results/public/` directory, refuses
to mix a run with old output, and produces an index for 18 figure classes and 21
nonfigure experiment-artifact classes. It does not require local PDFs, legacy
archives, or earlier result bundles. See [Reproducing](docs/REPRODUCING.md) for
requirements, alternate MATLAB paths, a custom output location, the output
schema, and interpretation boundaries.

## Repository structure

- `experiments/`: six MATLAB experiment entries and the safe all-in-one runner.
- `figures/`: 18 tracked MATLAB reference figures used by the results guide.
- `docs/`: concepts, results, reproduction instructions, provenance, and papers.
- `verification/`: independent numerical checks and compact reference outputs.
- `results/`: generated output location; ignored by Git.

## Provenance and limitations

The repository keeps theorem/paper identity, exact algebra, clean MATLAB
execution, independent numerical checks, finite sampling, and schematic
illustration distinct. Paper configurations, legacy configurations, new
constructions, and independent renderers are labeled rather than blended. Read
[Provenance](docs/PROVENANCE.md) before reusing a figure or making a stronger
claim.

`source_material/`, `reference/`, and `results/` are intentionally ignored local
directories. A new clone does not contain local PDFs, the legacy archive,
previous prototypes, or generated run bundles, and no public link in these docs
depends on them.

## Papers, citation, and license

Use [`CITATION.cff`](CITATION.cff) to cite release `v1.0.0`. If you use a
specific experiment group, also cite the corresponding paper listed in
[Related publications](docs/RELATED_PUBLICATIONS.md). Public links point to DOI
or conference records; publisher PDFs are not redistributed here.

Code in `experiments/` and `verification/` is released under the
[BSD 3-Clause License](LICENSE). Original documentation and
repository-generated figures are released under
[CC BY 4.0](LICENSE-DOCUMENTATION) unless a file or provenance record states
otherwise. These licenses do not cover publisher-formatted papers, third-party
source material, legacy archives, trademarks, or material not distributed in
this repository.
