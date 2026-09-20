# Homepage captions, alt text, and targets

Status: provisional editorial selection; author approval pending. Keep every
boundary statement adjacent to its image. Paper targets are public DOI or
conference records from `docs/RELATED_PUBLICATIONS.md`, never local PDFs.

## Main route

### T1 production/pollution — proposed lead

- Caption: **A Nash set is not a social Pareto set.** Styled profit and
  environmental best-response lines bound the purple decentralized weighted
  Nash image.
- Alt text: Styled red and blue best-response lines enclose a purple weighted
  Nash region in a two-dimensional production and pollution example.
- Repository target: [`README.md` — Why a set?](../../README.md#why-a-set)
- Paper target: [ACC 2024](https://doi.org/10.23919/ACC60939.2024.10644643).
- Boundary: Weighted decentralized Nash equilibria are not centralized welfare
  optima.

### P1 two-time trap — proposed welfare card 1

- Caption: Under the actual legacy scaled-own-gradient rule, both objectives of
  agent 2 are lower at the later sampled time. This is finite-grid evidence for
  one trajectory, not a continuous-time theorem.
- Alt text: A card compares two sampled times on one trajectory and reports both
  payoff components of agent 2 lower at the later time.
- Repository target: [`docs/RESULTS.md` — Weak-Pareto trap](../../docs/RESULTS.md#11-weak-pareto-trap)
- Paper targets: [IEEE Control Systems Letters 2024](https://doi.org/10.1109/LCSYS.2024.3522596) and [CDC 2024](https://doi.org/10.1109/CDC56724.2024.10886420).
- Boundary: This trap is separate from the new nonweak comparison game.

### P1 rate decomposition — proposed welfare card 2

- Caption: Total payoff rate is the own-direction contribution plus the
  externality; the externality can reverse the sign.
- Alt text: Curves for own contribution, externality, and total payoff rate are
  distinguished by line style and labeled relative to zero.
- Repository target: [`docs/RESULTS.md` — Rate decomposition](../../docs/RESULTS.md#10-rate-decomposition)
- Paper targets: [IEEE Control Systems Letters 2024](https://doi.org/10.1109/LCSYS.2024.3522596) and [CDC 2024](https://doi.org/10.1109/CDC56724.2024.10886420).
- Boundary: The three terms diagnose one dynamics; they are not three different
  trajectories or a theorem proof.

### X1 fiber collapse — proposed promotion

- Caption: Many original states on one level fiber share the same axis image;
  the inverse is the full set-valued fiber, not one selected state.
- Alt text: Six open-circle states on one original-space line fiber collapse to
  one filled point on a transformed coordinate axis.
- Repository target: [`docs/RESULTS.md` — Fiber collapse](../../docs/RESULTS.md#13-fiber-collapse)
- Paper target: [ECC 2026 program](https://controls.papercept.net/conferences/conferences/ECC26/program/ECC26_ContentListWeb_3.html); DOI/page range pending.
- Boundary: The transformation is an information-losing analysis device, not a
  controller or stabilizer.

### I1 trajectory — proposed design card 1

- Caption: The INC-0 incentive redirects the observed trajectory toward the
  target; the finite endpoint remains 0.0151764 away.
- Alt text: Original and incentivized paths are drawn with distinct styles near
  best-response lines and a marked target.
- Repository target: [`docs/RESULTS.md` — INC-0 before and after](../../docs/RESULTS.md#17-inc-0-before-and-after)
- Paper targets: [IEEE Control Systems Letters 2024](https://doi.org/10.1109/LCSYS.2024.3522596) and [CDC 2024](https://doi.org/10.1109/CDC56724.2024.10886420).
- Boundary: Algebra checked; trajectory observed; invariant containment
  unproved.

### I1 aggregate transfer — proposed design card 2

- Caption: Along the observed INC-0 trajectory, the complete sampled aggregate
  transfer remains nonpositive under the stated sign convention.
- Alt text: Aggregate transfer is plotted over time at or below a labeled zero
  line.
- Repository target: [`docs/RESULTS.md` — INC-0 before and after](../../docs/RESULTS.md#17-inc-0-before-and-after)
- Paper targets: [IEEE Control Systems Letters 2024](https://doi.org/10.1109/LCSYS.2024.3522596) and [CDC 2024](https://doi.org/10.1109/CDC56724.2024.10886420).
- Boundary: This sampled observation is not a certificate of full invariant-set
  containment. INC-omega is a different game, not a one-factor causal control.

## Optional geometry expansion

### T1 cube correspondence

- Caption: Cube faces and vertices keep matching identifiers from the paper's
  weight domain to its weighted Nash image under the stated conditions.
- Alt text: A compact key pairs six cube faces and eight vertices by matching
  labels across the weight domain and Nash image.
- Repository target: [`docs/RESULTS.md` — Cube](../../docs/RESULTS.md#1-cube-face-correspondence)
- Paper target: [ACC 2024](https://doi.org/10.23919/ACC60939.2024.10644643).
- Boundary: The routing key and finite sampling do not prove the global
  diffeomorphism.

### T1 prism correspondence

- Caption: Prism faces and vertices keep matching identifiers from the paper's
  weight domain to its weighted Nash image; both `M` and `b` use the same
  weights.
- Alt text: A compact key pairs five prism faces and six vertices by matching
  labels across the weight domain and Nash image.
- Repository target: [`docs/RESULTS.md` — Prism](../../docs/RESULTS.md#2-triangular-prism-face-correspondence)
- Paper target: [ACC 2024](https://doi.org/10.23919/ACC60939.2024.10644643).
- Boundary: Visibility in a 3D view and finite samples do not establish global
  bijectivity.

## Optional method and boundary extension

### S1 stable versus unstable

- Caption: Case 2 is stable under its branch and theorem checks; Case 5 has an
  active positive-eigenvalue witness. The trajectories illustrate, but do not
  establish, those classifications.
- Alt text: Two separate phase-portrait cards contrast an inward stable path
  with an unstable magenta outward eigenray witness.
- Repository target: [`docs/RESULTS.md` — S1](../../docs/RESULTS.md#s1--stable-and-unstable-piecewise-dynamics)
- Paper targets: [IFAC 2023](https://doi.org/10.1016/j.ifacol.2023.10.1395) and [CDC 2023](https://doi.org/10.1109/CDC49753.2023.10384265).
- Boundary: Stability identity comes from slope order, branch matrices,
  eigenstructure, active cones, and theorem assumptions—not a plotted path.

### S2 noncompact N1, N2, and N3

- Caption: Each new construction has mixed branch-determinant signs, the
  analytic Proposition-3.1 certificate for noncompactness; recession arrows are
  geometric guidance.
- Alt text: Each separate card shows one unbounded purple Nash geometry with a
  mixed-sign certificate and a recession-direction arrow.
- Repository target: [`docs/RESULTS.md` — S2 noncompact](../../docs/RESULTS.md#8-three-noncompact-configurations)
- Paper targets: [IFAC 2023](https://doi.org/10.1016/j.ifacol.2023.10.1395) and [CDC 2023](https://doi.org/10.1109/CDC49753.2023.10384265).
- Boundary: A bounded viewport does not test compactness, and Theorem 3.11 does
  not classify these mixed-sign systems.
