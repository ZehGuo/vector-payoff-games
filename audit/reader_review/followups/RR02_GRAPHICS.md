# RR-02 / CR-P1-03 / CR-P2-01 / CR-P2-02 — T1/S1/S2 graphics

Date: 2026-09-19

## Outcome

The eight tracked T1/S1/S2 technical figures were regenerated from MATLAB with
presentation-only changes. Responsive derivatives and a caption manifest were
added under `docs/assets/t1_s1_s2/`. This task does not choose the final homepage
selection.

The intended public sentence is now visible across the figures and captions:
weight-domain/Nash-set structure, stable versus unstable cases, and the
noncompact boundary are certified respectively by theorem conditions,
branch/eigenstructure/cone transitions, and mixed determinant signs. Trajectories
and finite windows illustrate those certificates; they do not replace them.

## Presentation changes

- T1 cube/prism: added the map direction `weight -> solve M(w)x+b(w)=0 -> x*(w)`,
  direct face labels, persistent vertex IDs, and compact responsive
  correspondence keys.
- T1 production/pollution: expanded BR as best response, stated dimensionless
  model units, retained the explicit Nash-not-social-Pareto distinction, and used
  line style as well as color.
- T1 nonquadratic: shortened the title, moved the limitation to the neighboring
  caption, and retained the prominent schematic-only label.
- S1 overview: separated orange agent-1 BRs from the magenta unstable eigenray
  witness, added trajectory direction arrows, and put a minimal analytic
  criterion in every case panel.
- S1 eigenstructure: defined 0/1/2-transitive and added a gray/black/red/blue role
  key.
- S2 rank-degenerate: placed new-construction and Assumption-4 identity first,
  marked the rank-zero pinch, and put the determinant/Theorem-3.11 criterion in
  each panel.
- S2 noncompact: placed the mixed-sign Proposition-3.1 certificate above the
  trajectories, added recession-direction arrows, and labeled the finite window
  as illustrative only.

## Scientific invariants preserved

- T1 cube/prism still use the paper parameters, and both `M` and `b` use the same
  weights. The global diffeomorphism claim remains theorem-based, not
  finite-sample-based.
- The production purple region remains a weighted Nash image, not a centralized
  social Pareto set. The nonquadratic figure remains schematic only.
- S1 retains four stable cases followed by one unstable case. Case identity still
  uses slope order, every branch matrix, eigenstructure, active cones, and theorem
  assumptions—not trajectory classification.
- S2 remains a labeled new construction. Rank-degenerate and noncompact groups
  remain separate; mixed-sign noncompact cases remain outside Theorem 3.11, and
  a finite viewport remains non-evidence for compactness.
- No numerical parameter, ODE rule, case order, or diagnostic tolerance changed.

## Outputs

- Technical figures: `audit/implementation/figures/T1_*.png`,
  `audit/implementation/figures/S1_*.png`, and
  `audit/implementation/figures/S2_*.png`.
- Responsive assets: `docs/assets/t1_s1_s2/*_900.png` and `*_390.png`.
- Caption and alt-text manifest: `docs/assets/t1_s1_s2/CAPTIONS.md`.

## Verification protocol

1. Generated a pre-change baseline and a post-change run in separate, newly
   created temporary output roots with MATLAB R2025b Update 7.
2. Compared every T1/S1/S2 CSV byte-for-byte and compared MAT variables
   semantically; parameters, branch diagnostics, classifications, trajectories,
   and reports were unchanged.
3. Opened all eight technical figures at original resolution and at 1100, 900,
   and 390 pixels. The 390-pixel technical copies are inspection evidence only;
   mobile delivery uses the single-comparison derivative cards.
4. Opened every responsive derivative at both 900 and 390 pixels. Each 390-pixel
   card contains one mapping, case, or noncompact configuration.
5. Kept all eight technical figures; no boundary case was removed for public
   presentation.
