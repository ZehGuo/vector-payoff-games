# Homepage story

Editorial status: **provisional selection; author approval pending**.

## 1. When equilibrium becomes a set

### Headline

**What changes when every player has several objectives, but no fixed ranking among them?**

### Body (77 words)

In an ordinary game, each player optimizes one ordered payoff. In a
vector-payoff game, admissible weights express different ways to balance several
objectives. Those weights can generate a geometric set of Nash states rather
than one Nash point. I study how that set is shaped, how decentralized motion
behaves around it, how externalities alter welfare, and when a conditional
incentive can redirect behavior while reporting its budget cost and the limits
of what has actually been proved.

### Editorial fields

- Asset: `assets/t1_production_900.png` / `assets/t1_production_390.png`
- Caption: Styled profit and environmental best-response lines bound a
  decentralized weighted Nash image—not a centralized social Pareto set.
- Alt text: Styled best-response lines enclose a purple weighted Nash region in
  a two-dimensional production and pollution example.
- Repository target: [`README.md` — Why a set?](../../README.md#why-a-set)
- Paper target: [ACC 2024](https://doi.org/10.23919/ACC60939.2024.10644643).

## 2. Geometry gives the set a structure

### Headline

**Weights do more than sweep out points: under regularity conditions, they organize faces and boundaries.**

### Body (78 words)

The production example makes the central object visible: changing each agent's
objective weights changes the decentralized equilibrium and fills a weighted
Nash image. In the paper's cube and prism cases, weight-domain faces can be
matched to faces of that image when the theorem's conditions hold. The diagrams
are a route into the geometry, not a numerical proof of global one-to-one
structure. They also do not turn the Nash image into a social-welfare frontier;
those are different mathematical objects.

### Editorial fields

- Optional assets: `assets/t1_cube_900.png` and `assets/t1_prism_900.png`, with
  their paired `390` versions; select neither, one, or both.
- Caption: Matching labels route the paper's cube or prism weight-domain faces
  to faces of the weighted Nash image under the stated regularity conditions.
- Alt text: Compact correspondence keys pair labeled cube or prism faces and
  vertices between a weight domain and its weighted Nash image.
- Repository target: [`docs/RESULTS.md` — T1 geometry](../../docs/RESULTS.md#t1--weight-domains-and-weighted-nash-images)
- Paper target: [ACC 2024](https://doi.org/10.23919/ACC60939.2024.10644643).

## 3. Local improvement can hide a welfare loss

### Headline

**Moving uphill on a selected objective does not determine the total change in every payoff.**

### Body (90 words)

An agent's own motion contributes one term to its payoff rate; the other
agent's motion contributes an externality. Their sum is the total rate, and the
externality can reverse its sign. In a separate legacy-rule trap experiment, a
sampled local weak condition coexists with two later comparison times at which
both payoff components of one agent are lower. The trap and the constructed
nonweak example answer different questions. The plotted trajectory supplies
finite-grid evidence for this case—it does not prove a continuous-time theorem
or replace the analytic rate decomposition.

### Editorial fields

- Assets: `assets/p1_trap_900.png`, then `assets/p1_rate_900.png`; use their
  paired `390` versions as separate mobile cards.
- Caption: The two-time trap is finite-grid evidence under the actual legacy
  rule; the second card shows total payoff rate as own contribution plus
  externality.
- Alt text: One card compares two sampled times where both objectives are lower;
  a second separates own, externality, and total payoff-rate curves.
- Repository target: [`docs/RESULTS.md` — P1 welfare](../../docs/RESULTS.md#p1--own-improvement-externality-and-total-payoff)
- Paper targets: [IEEE Control Systems Letters 2024](https://doi.org/10.1109/LCSYS.2024.3522596) and [CDC 2024](https://doi.org/10.1109/CDC56724.2024.10886420).

## 4. A useful transformation can still discard information

### Headline

**Many original states can share one transformed point.**

### Body (85 words)

The non-bijective map used in the stability analysis compresses a one-active
domain to an axis. An entire level fiber of original states can therefore share
one transformed point, so the inverse is set-valued and cannot select a unique
original state. This loss of information matters dynamically: the pointwise
image of an original trajectory and a separately integrated transformed-system
trajectory are different mathematical objects. The transformation supports an
analysis and its certificate; it is not a controller, and applying it does not
itself stabilize the system.

### Editorial fields

- Asset: `assets/x1_fiber_900.png` / `assets/x1_fiber_390.png`
- Caption: Many states on one original-space fiber map to one axis point, whose
  inverse is the full fiber rather than a chosen state.
- Alt text: A vertical card shows several original states on one line fiber
  collapsing to a single filled point on a transformed axis.
- Repository target: [`docs/RESULTS.md` — X1 representation](../../docs/RESULTS.md#x1--non-bijective-representation)
- Paper target: [ECC 2026 program](https://controls.papercept.net/conferences/conferences/ECC26/program/ECC26_ContentListWeb_3.html); DOI/page range pending.

## 5. Design is conditional—and the budget stays visible

### Headline

**A credible intervention reports behavior, welfare, and transfer together.**

### Body (88 words)

The incentive construction changes only one payoff component per agent and
redirects the observed trajectory toward a target region. A companion card
shows the complete aggregate transfer along that same INC-0 trajectory under
the stated sign convention. These are checked algebra and observed numerical
behavior, not an unconditional guarantee: full invariant-set containment has
not been proved for the displayed case. The separate INC-omega supplement uses
a different game, so it is not evidence that changing omega alone caused a
difference and is intentionally excluded from the homepage baseline.

### Editorial fields

- Assets: `assets/i1_trajectory_900.png`, then `assets/i1_transfer_900.png`; use
  their paired `390` versions as separate mobile cards.
- Caption: The incentive redirects the observed trajectory while the complete
  sampled aggregate transfer stays nonpositive; invariant containment remains
  unproved.
- Alt text: One card compares original and incentivized paths near a target; a
  second plots aggregate transfer at or below zero over sampled time.
- Repository target: [`docs/RESULTS.md` — I1 design](../../docs/RESULTS.md#i1--conditional-incentive-design)
- Paper targets: [IEEE Control Systems Letters 2024](https://doi.org/10.1109/LCSYS.2024.3522596) and [CDC 2024](https://doi.org/10.1109/CDC56724.2024.10886420).

## 6. Continue into the evidence

### Headline

**Choose the depth you need: story, reproducibility, or papers.**

### Body (71 words)

The homepage is the short route, not the evidence archive. The repository story
explains all six experiment groups and all 18 technical figures; the
reproduction guide runs the tracked MATLAB workflow without requiring local
paper files; and the provenance guide separates paper cases, legacy cases, new
constructions, schematics, and numerical evidence. Public paper buttons use the
author-confirmed DOI and conference-record links in
`docs/RELATED_PUBLICATIONS.md`. No local PDF should be published automatically.

### Link fields

- Caption: No image is required; present these as three text buttons.
- Alt text: Not applicable to the text-only navigation block.
- Repository targets: [research story](../../docs/RESULTS.md),
  [reproduce the experiments](../../docs/REPRODUCING.md), and
  [provenance](../../docs/PROVENANCE.md).
- Paper target: [related publications](../../docs/RELATED_PUBLICATIONS.md).

## Optional extension, below the main story

Use S1 stable/unstable as one paired comparison and S2 noncompact as individual
cards only after the five-section route. Stability comes from branch,
eigenstructure, cone, and theorem checks—not trajectory appearance. S2
noncompactness comes from the analytic mixed-sign determinant certificate—not
the finite viewport. The extension assets and exact boundaries are listed in
[`captions.md`](captions.md).
