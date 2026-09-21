# Sources and claim map

[Back to README](../README.md) · [Beginner guide](BEGINNER_GUIDE.md) · [Results](RESULTS.md) · [Related publications](RELATED_PUBLICATIONS.md)

This page identifies the source behind each scientific claim. Printed page
numbers refer to the source's own pagination. PDF page numbers count from the
first PDF page and are supplied only to make a local lawful copy easier to
navigate. Publisher PDFs are not redistributed by this repository.

## Primary synthesis source

The theorem and example numbering used below is from Zehui Guo, *Stability and
Incentive Design for Noncooperative Dynamical Systems With Vector-valued Payoff
Functions*, PhD dissertation, Institute of Science Tokyo, January 2025. The
dissertation synthesizes the published modules listed in
[Related publications](RELATED_PUBLICATIONS.md). Where a public article has its
own numbering, this page names that article separately.

## Claim map

| Module | Claim whose authority comes from a source | Exact source locator | What this repository contributes |
|---|---|---|---|
| T1 | Weighted scalar games generate $X^*(J)$; under invertibility and rank conditions the weight-to-Nash map is a diffeomorphism and the Nash set is simplicial. | Dissertation Ch. 2: equations (2.6)–(2.10), Proposition 2.1 (printed pp. 10–12; PDF pp. 16–18), Theorem 2.4 (printed pp. 14–15; PDF pp. 20–21). | Finite-grid residual, conditioning, and face/edge/vertex diagnostics. These checks do not re-prove the theorem. |
| T1 | Cube, prism, and production–pollution configurations. | Dissertation Examples 2.9–2.11 and Figures 2.3–2.6 (printed pp. 20–23; PDF pp. 26–29). | MATLAB implementation using the dissertation's controlled-coordinate formulas. Figure 2.6 motivates the production–pollution boundary story, but the repository's nonquadratic panel is a schematic rather than an exact sourced parameter set. |
| S1 | Compact-case branch transitions and stability/instability. | Dissertation Lemma 3.6 and Figure 3.3 (printed pp. 36–37; PDF pp. 42–43), Remarks 3.7–3.9 (printed pp. 38–39; PDF pp. 44–45), Theorem 3.10 (printed pp. 39–40; PDF pp. 45–46). | Five new parameter constructions. Their identities are checked through slopes, 20 branch matrices, eigenstructure, active cones, and the theorem hypotheses; they are not exact dissertation Figure 3.5 parameters. |
| S2 | Under general position, four same-sign branch determinants characterize compactness. | Dissertation Assumption 1 and Proposition 3.1 (printed pp. 28–29; PDF pp. 34–35). | Three new mixed-sign constructions. Proposition 3.1, not the finite viewport or sampled arrows, supplies the noncompactness conclusion. |
| S2 | Rank-degenerate compact cases are stable for all-positive determinants and unstable for all-negative determinants under the recorded geometry. | Dissertation Assumption 4 (printed p. 31; PDF p. 37) and Theorem 3.11 (printed pp. 42–43; PDF pp. 48–49). | Five new rank-degenerate constructions; not exact dissertation Figure 3.6 parameters. Theorem 3.11 does not classify the separate mixed-sign noncompact games. |
| P1 | Payoff change contains own-motion and other-agent externality terms; positive-externality regions provide sufficient payoff-improvement regions under the source assumptions. | Dissertation Ch. 4, especially Definition 5 and Theorem 4.3 (printed pp. 47–56; PDF pp. 53–62). | Three new analytically solved comparison games isolate externalities. They are not an exact reconstruction of dissertation Figure 4.3. |
| P1 | Weak improvement can coexist with a cross-time trap. | “Noncooperative Dynamical Systems With Vector-valued Payoff Functions to Achieve Weak Pareto Improvement,” Definitions 2–3 and Figure 1 (PDF pp. 3–4); see its record in Related publications. | The trap uses source-labelled legacy arrays and the actual scaled-own-gradient rule. Its at-every-time weak margin is finite-grid evidence; the two-time payoff decrease is the recorded witness. |
| X1 | A non-bijective coordinate transformation maps the Nash set to the origin and supports a sufficient stability implication. | “Nash Equilibrium and Stability in 2-Agent Systems with Quadratic Vector Payoffs: A Nonlinear Coordinate Transformation Approach,” Sections IV–V: transformation (43), transformed dynamics (50), Theorem 1 and Proposition 3 (PDF pp. 9–11), numerical example and Figure 6 (PDF pp. 11–12). | Separate integration of $x(t)$ and $z(t)$, pointwise evaluation of $\eta(x(t))$, fiber checks, and certificate arithmetic. No exact source-figure recovery is claimed. |
| I1 | Incentives can provide the source theorem's guarantees when its concavity, stationarity, budget, and invariant-set conditions hold. | Dissertation Ch. 5: Lemma 5.1, equations (5.15)–(5.24), Theorem 5.4 and condition (5.35) (printed pp. 61–67; PDF pp. 67–73). Article counterpart: “Noncooperative Dynamical Systems With Vector-valued Payoff Functions to Achieve Weak Pareto Improvement,” Lemma 1, equations (20), (23)–(30), Theorem 2 and conditions (32)–(38) (PDF pp. 3–6). | Exact algebraic identities and sampled paths for checked configurations. The displayed INC-0 path does not establish the missing full invariant-set containment, so the unconditional theorem guarantee is not claimed. |

## Source assumptions used in S1 and S2

- **Assumption 1 (general position):** no two of the four BR lines are
  parallel, no three share one intersection, and no BR line is horizontal or
  vertical.
- **Assumption 2:** the four branch determinants have the same sign.
- **Assumption 3:** the same-agent BR intersections lie outside the Nash set;
  this is the non-rank-degenerate compact geometry used by S1.
- **Assumption 4:** at a Nash state, one agent's pair of own-gradients loses
  rank; this is the pinched/rank-degenerate geometry used by S2.

These short synopses help navigation; the source definitions and complete
hypotheses control the theorem statements.

## Narrow source discrepancies retained in X1

- Direct evaluation of transformation (43) at the recorded initial state gives
  $\eta(x_0)=(-2.5,-13.25)$, while the example text prints
  $(-2.5,-13.5)$. This affects the printed initial coordinate, not the checked
  four-branch certificate.
- In source Figure 6 and the nearby discussion, the A/B image norm changes in
  the opposite direction from the printed inequality. Both implementations
  give a decrease for that segment. This narrow sign discrepancy does not
  replace or invalidate the theorem's certificate conditions.

## A note on unavailable source material

The public repository intentionally does not distribute the dissertation PDF,
publisher-formatted articles, or legacy archives. Source locators describe the
materials used during reconstruction; public DOI and conference records are
listed in [Related publications](RELATED_PUBLICATIONS.md). Claims that rely on
an excluded legacy archive are labelled as source-labelled legacy claims, not
as independently recoverable provenance from a fresh public clone.
