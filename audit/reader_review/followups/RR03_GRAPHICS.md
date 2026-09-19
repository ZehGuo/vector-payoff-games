# RR-03 / CR-P1-04 / CR-P1-05 / CR-P2-01 graphics follow-up

Date: 2026-09-19
Owner: P1/I1
Status: complete; local MATLAB generation and visual review passed.

## Outcome

The tracked P1 public figures now use the MATLAB entry and clean numerical result as their rendering authority. The former tracked independent renderings are no longer the current public PNGs; their historical provenance remains documented in the pre-RR-03 implementation/review record. The replacement is not described as an exact thesis Fig. 4.3 reproduction.

The public message is now explicit: total payoff rate is the sum of the own-direction contribution and externality. The I1 numerical examples show behavior, original/modified payoff changes, and complete aggregate transfer, while full invariant-domain theorem containment remains unproved.

## Rendering changes

- P1 three-property overview: retained the three-row comparison, added real axes/time/ticks and one logical judgment per row, and labeled the family as new rather than exact Fig. 4.3 parameters.
- P1 rate decomposition: objective is encoded by color, term by line style, with one global legend and labeled zero lines.
- P1 trap: kept the actual legacy `A/b/x0/alpha` and scaled-own-gradient rule; identified the interior `t1/t2` selection and the separate `J_1^2`/`J_2^2` changes; retained the finite-grid qualification.
- I1 design geometry: numbered social Pareto/Nash -> domains -> same-game omega -> behavior, with an explicit social-Pareto-versus-Nash legend.
- I1 sigma/budget: orange now has one meaning in every panel, `D_bud^c = {aggregate transfer > 0}`; the raw formula annotation was replaced by readable prose.
- I1 before/after: states the terminal target distance, aggregate-transfer sign convention, and `algebra checked | trajectory observed | invariant-set containment unproved` boundary.
- I1 INC-omega: remains a supplement and is titled `DIFFERENT GAME`, not a one-factor omega comparison.
- Four direct MATLAB mobile/homepage cards were added under `docs/assets/p1_i1/`; they do not depend on a multi-panel technical figure at 390 px.

## Clean numerical comparison

Baseline and modified runs used MATLAB R2025b Update 7 in separate new temporary directories. No research parameter, ODE branch rule, initial state, horizon, sample step, or budget identity changed.

| comparison | result |
|---|---|
| P1 `p1_samples.csv` | byte-for-byte identical |
| P1 `p1_summary.csv` | byte-for-byte identical |
| I1 `i1_condition_checks.csv` | byte-for-byte identical |
| I1 `i1_trajectory_summary.csv` | byte-for-byte identical |
| P1 baseline/new MAT contents | all loaded fields `isequaln` |
| I1 baseline/new MAT contents | all loaded fields `isequaln` |

Representative unchanged values include the P1 MATLAB-grid witness `0.020<1.820` with changes `[-0.313864,-0.319846]`, INC-0 terminal distance `0.0151764070`, and sampled aggregate-transfer maxima `0` for both INC-0 and INC-omega.

## Visual review

All seven tracked technical figures were opened at 1100 px and 900 px. At 900 px the P1 rate signs and trap judgment remain readable, and I1 still exposes the evidence boundary and the different-game label. All seven were also opened at 390 px to confirm that the multi-panel technical figures should not be used as mobile cards.

The four derived assets were opened at 390 px. Each remains independently readable: P1 two-time trap, P1 rate decomposition, I1 trajectory, and I1 aggregate transfer. The captions and provenance mapping are in `docs/assets/p1_i1/CAPTIONS.md`.

## Evidence boundary

- P1's first three games remain a new exact comparison family, not exact Fig. 4.3 parameters.
- The trap remains the actual legacy configuration and scaled-own-gradient rule; its weak-at-every-time statement is finite-grid evidence.
- I1 modifies only `J_1^i`; target, omega, sigma, anchoring, and the complete aggregate budget identity are unchanged.
- INC-0 same-game omega comparison and INC-omega different-game supplement remain separate.
- No complete construction of `N_x0` containment was added. The stronger `D(U,x0) subset D_bud` certificate remains unavailable for these parameters, and this is not generalized to impossibility.

No push, publication, or deployment was performed.
