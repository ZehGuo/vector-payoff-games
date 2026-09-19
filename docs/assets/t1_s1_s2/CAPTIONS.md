# T1/S1/S2 public-figure captions

These captions accompany RR-02. The technical figures remain the complete audit
record; the `900` and `390` derivatives are reading aids for repository and
homepage layouts. No homepage selection is decided here.

## Technical figures

### `T1_cube_face_correspondence.png`

**Caption.** Under the paper parameters and regularity conditions, the cube of
payoff weights maps through `M(w)x+b(w)=0` to the weighted Nash image. Matching
`F1`–`F6` and `C1`–`C8` labels identify corresponding faces and vertices.

- Evidence: theorem/paper identity plus clean MATLAB implementation diagnostics.
- Do not infer: the finite grid or the 3D view does not prove the global
  diffeomorphism.
- Alt text: A labeled weight cube points to a labeled three-dimensional weighted
  Nash image; each face and vertex keeps the same identifier.

### `T1_prism_face_correspondence.png`

**Caption.** The triangular-prism weight domain and its weighted Nash image use
matching `P1`–`P5` face labels and `P1`–`P6` vertex labels. Both `M` and `b` use
the same payoff weights.

- Evidence: theorem/paper identity plus clean MATLAB implementation diagnostics.
- Do not infer: a hidden face in one camera view has not disappeared, and finite
  samples do not establish global bijectivity.
- Alt text: A labeled triangular-prism weight domain maps to a deformed labeled
  weighted Nash image with the same face and vertex identifiers.

### `T1_production_pollution.png`

**Caption.** Best-response (BR) lines for profit and environmental objectives
bound the purple decentralized weighted Nash image. The axes use dimensionless
model units; the purple set is not a centralized social Pareto set.

- Evidence: exact model algebra and clean MATLAB rendering.
- Do not infer: weighted decentralized Nash equilibria are not centralized
  welfare optima.
- Alt text: Four differently styled best-response lines bound a purple weighted
  Nash region in two-dimensional production space.

### `T1_nonquadratic_schematic.png`

**Caption.** Schematic only: curved own-gradient zero sets can bound a curved
weighted Nash image.

- Evidence: schematic.
- Do not infer: no source payoff functions, parameters, or numerical
  reproduction are asserted.
- Alt text: Four styled curved boundaries enclose a purple conceptual Nash
  region.

### `S1_five_case_overview.png`

**Caption.** Cases 1–4 are stable and Case 5 is unstable. The case identities
come from slope order, all 20 branch matrices, eigenstructure, active cones, and
Theorem 3.10 assumptions; arrowed trajectories illustrate those identities.

- Evidence: exact branch calculations, theorem conditions, and clean MATLAB
  execution.
- Do not infer: trajectory endpoints do not classify a case or prove stability.
- Alt text: Five phase portraits show four stable Nash sets and one unstable
  case; a magenta dashed eigenray witness is distinct from orange agent-1 BRs.

### `S1_eigenvectors_transitions.png`

**Caption.** A 0-transitive cone has no boundary exit, a 1-transitive cone has
one adjacent exit, and a 2-transitive cone has two possible exits. Black marks
cone boundaries, gray other eigenrays, red active eigenrays, and blue local
rotational flow.

- Evidence: branch eigenstructure and active-cone calculations.
- Do not infer: a coordinate change does not remove the Case-5 positive
  eigenvalue.
- Alt text: Four local cone diagrams compare zero-, one-, and two-exit branch
  transitions with an unstable positive-eigenvalue ray.

### `S2_rank_degenerate_five_cases.png`

**Caption.** These are new constructions under Assumption 4, with a gold
rank-zero Nash pinch. D1–D4 have all-positive branch determinants and are stable;
D5 has all-negative determinants and is unstable by Theorem 3.11.

- Evidence: exact branch calculations, theorem conditions, and clean MATLAB
  execution.
- Do not infer: these are not the exact thesis parameters, and the trajectories
  do not certify the classifications.
- Alt text: Five rank-degenerate phase portraits share a gold Nash pinch; four
  are stable and one has a magenta outward witness.

### `S2_noncompact_three_configurations.png`

**Caption.** In each new construction, mixed branch-determinant signs certify a
noncompact Nash set by Proposition 3.1. Purple arrows show sampled recession
directions; dashed trajectories and the finite plot window are illustrations.

- Evidence: analytic mixed-sign determinant certificate plus clean MATLAB
  rendering.
- Do not infer: the bounded viewport is not a compactness test, and Theorem 3.11
  does not classify these mixed-sign systems.
- Alt text: Three unbounded purple Nash geometries carry prominent mixed-sign
  certificates and purple recession-direction arrows.

## Responsive derivative cards

Each basename below is delivered in `_900.png` and `_390.png` variants. Every
390-pixel card carries one comparison or one case.

### `T1_cube_correspondence_card`

**Caption.** Cube faces `F1`–`F6` and vertices `C1`–`C8` keep their identifiers
from the weight domain to the weighted Nash image.

- Evidence: theorem/paper identity; the card is a routing key.
- Do not infer: the key is not a numerical proof of the global map.
- Alt text: A compact key pairs the six cube faces and eight vertices by matching
  identifiers.

### `T1_prism_correspondence_card`

**Caption.** Prism faces `P1`–`P5` and vertices `P1`–`P6` keep their identifiers
from the weight domain to the weighted Nash image.

- Evidence: theorem/paper identity; the card is a routing key.
- Do not infer: visibility in a 3D view is not the correspondence proof.
- Alt text: A compact key pairs five prism faces and six vertices by matching
  identifiers.

### `T1_production_pollution_card`

**Caption.** Styled BR lines bound a decentralized weighted Nash image, not a
centralized social Pareto set.

- Evidence: exact model algebra and clean MATLAB rendering.
- Do not infer: Nash and social Pareto sets are interchangeable.
- Alt text: Styled red and blue best-response lines bound a purple weighted Nash
  region.

### `T1_nonquadratic_schematic_card`

**Caption.** Schematic only: nonlinear own-gradient zero sets can create a curved
weighted Nash image.

- Evidence: schematic.
- Do not infer: a source model or numerical result.
- Alt text: Styled curved boundaries surround a purple schematic region.

### `S1_stable_case_card`

**Caption.** S1 Case 2 is stable because every branch has positive determinant
and is Hurwitz; the arrowed trajectory is illustrative.

- Evidence: branch calculation and theorem conditions.
- Do not infer: one convergent trajectory proves set stability.
- Alt text: A stable phase portrait shows a black trajectory entering a purple
  Nash quadrilateral among styled BR lines.

### `S1_unstable_case_card`

**Caption.** S1 Case 5 has negative branch determinants and an active
positive-eigenvalue ray, shown as a magenta dashed witness distinct from the BRs.

- Evidence: branch eigenstructure and active-cone calculation.
- Do not infer: the visual slope of the plotted path alone proves instability.
- Alt text: An unstable phase portrait highlights a magenta dashed outward
  eigenray witness within a purple Nash quadrilateral.

### `S2_rank_degenerate_stable_card`

**Caption.** New D2 construction: the gold point certifies the Assumption-4
rank-zero Nash pinch, while all-positive determinants and Theorem 3.11 certify
stability.

- Evidence: exact algebra and theorem conditions.
- Do not infer: exact thesis parameters or proof from the plotted trajectory.
- Alt text: A stable rank-degenerate portrait marks the Nash pinch with a gold
  star.

### `S2_rank_degenerate_unstable_card`

**Caption.** New D5 construction: the rank-zero Nash pinch satisfies Assumption
4, while all-negative determinants and Theorem 3.11 certify instability.

- Evidence: exact algebra and theorem conditions.
- Do not infer: exact thesis parameters or proof from the finite window.
- Alt text: An unstable rank-degenerate portrait shows a gold pinch and a
  magenta outward witness.

### `S2_noncompact_N1_card`, `S2_noncompact_N2_card`, and `S2_noncompact_N3_card`

**Caption.** Each card shows one new noncompact configuration. Mixed determinant
signs are the Proposition-3.1 certificate; the recession arrow is geometric
guidance.

- Evidence: analytic mixed-sign determinant certificate.
- Do not infer: the displayed window proves noncompactness or Theorem 3.11
  classifies the mixed-sign dynamics.
- Alt text: One noncompact purple Nash geometry is shown with its mixed-sign
  certificate and a recession-direction arrow.
