# RR-04 / CR-P1-03 / CR-P2-01 / CR-P2-02 - X1 graphics follow-up

Date: 2026-09-19
Owner: X1
Status: complete; clean MATLAB generation, numerical comparison, and visual
review passed.

## Outcome

The X1 public figures now explain the non-bijective transformation without
assuming the reader already knows the domain notation. The domain figure defines
`D^(i,j)` and uses outlines, marker shapes, line styles, and direct labels in
addition to color. The fiber figure is promoted from repository support to a
public candidate and states the many-to-one mechanism directly. This editorial
promotion does not choose the final homepage figure; that remains an author
decision.

The intended public sentence is now visible in the figures and captions: the map
compresses two-dimensional domains to local quadrant subsets, strips to axes,
and the Nash set to the origin; an axis point therefore has a set-valued inverse
fiber, so pointwise `eta(x(t))` and independently integrated `z(t)` are different
objects.

## Presentation changes

- Domain map: added a `D^(i,j)` key; replaced the dense transformed-side texture
  with sparse markers and explicit subset outlines; styled the four half-axes;
  retained the local-subset, not whole-quadrant-surjectivity, boundary.
- Fiber collapse: directly labels a fiber as many original states and its image
  as one point; defines `kappa` in the public caption; states that the inverse is
  the full set-valued fiber and never selects a representative original state.
- Trajectories: numbered original `x(t)`, pointwise `eta(x(t))`, independent
  `z(t)`, and certificate values as four objects. Solid/circle and
  dashed/triangle encodings remain distinguishable without color. An A/B inset
  makes the post-fiber split intentional rather than numerical noise.
- Mobile/homepage derivatives: added one vertical fiber card and four
  single-object trajectory/certificate cards at 900 and 390 pixels. A 390-pixel
  card no longer asks the reader to decode the full four-panel figure.

## Scientific invariants preserved

- `x(t)`, pointwise `eta(x(t))`, and independently integrated `z(t)` remain
  separate arrays with separate provenance.
- The axis inverse remains undefined/set-valued; no representative inverse is
  introduced.
- The displayed transformed regions remain local image subsets, not claims of
  whole-quadrant surjectivity.
- The coordinate map is described as an analysis device, not a controller or
  stabilizer. System instability, certificate applicability, and information
  loss remain distinct statements.
- The paper's printed `eta_0^2=-13.5`, the computed `-13.25`, and the printed
  A/B norm-inequality direction issue remain recorded. No exact-reproduction
  claim was added.
- Certificate matrices, branch and boundary rules, integration parameters,
  initial state, horizon, and tolerances were not changed.

## Clean numerical comparison

Baseline and modified runs used MATLAB R2025b Update 7 in separate new temporary
directories.

| comparison | result |
|---|---|
| `x1_trajectories.csv` | byte-for-byte identical; SHA-256 `5d5194d82b337b3be4464840832bce14bed6330efef0d7da69c1664a061a0101` |
| baseline/new MAT variables | all loaded fields `isequaln` |
| first separation | unchanged at `t=0.047` |
| maximum separation | unchanged at `5.5267024482` |
| A/B one-active interval | unchanged at `[0.047,0.174]` |
| strict decay margin | unchanged at `12.6690660020` |
| strict positivity margin | unchanged at `2.2440811913` |
| branch/boundary checks | unchanged; both pass |

## Visual review

The three technical figures were opened at original resolution and at 1100,
900, and 390 pixels. At 900 pixels the solid/circle pointwise image and
dashed/triangle independent trajectory remain distinct. The 390-pixel technical
copies confirm that the four-panel figure should not serve as a mobile card.

All ten responsive derivatives (five subjects at 900 and 390 pixels) were
opened. Each 390-pixel trajectory card presents only one numbered object, while
the vertical fiber card still shows “many x map to one point.” Captions,
alt-text guidance, and provenance are in `docs/assets/x1/CAPTIONS.md`.

No README, other module, source material, prior prototype, push, publication, or
deployment was included in this task.
