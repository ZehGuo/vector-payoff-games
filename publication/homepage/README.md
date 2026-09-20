# Homepage portable content pack

Status: **prepared, but not author-approved or published** (RR-06, 2026-09-19).

This framework-neutral pack turns the repository's full 18-figure evidence layer
into a short homepage route for visitors who do not already know vector-payoff
games. Because the author has not made the final image selection, the order here
is a **provisional editorial selection** based on
[`PUBLICATION_BLUEPRINT.md`](../../audit/reader_review/PUBLICATION_BLUEPRINT.md),
not final approval.

The one-sentence message is:

> Multiple unordered objectives turn a Nash point into a Nash set; the research
> studies its geometry, dynamics, welfare, and budget-constrained conditional
> design while making the limits of transformations and theorem claims explicit.

Nothing in this directory changes the real personal website. Nothing has been
pushed, deployed, or published, and no local paper PDF is linked or bundled.

## Contents

- [`story.md`](story.md): finished English copy in the intended reading order.
- [`captions.md`](captions.md): captions, alt text, and link targets for every
  proposed image.
- [`asset_manifest.csv`](asset_manifest.csv): source-to-derivative provenance,
  dimensions, claim boundaries, and approval state.
- `assets/`: static PNGs copied or proportionally resized only from tracked,
  approved RR-02/03/04 public derivatives.
- `assets/homepage_preview_1100.png` and `assets/homepage_preview_390.png`:
  implementation-neutral static layout checks, not website code.

## Provisional editorial sequence

1. T1 production/pollution as the motivation and geometry lead.
2. P1 two-time trap, followed by the own/externality/total-rate card.
3. X1 fiber collapse, promoted as the central representation limit.
4. I1 trajectory and aggregate-transfer cards as conditional design.
5. Deep links to the repository story, reproduction guide, and author-approved
   public paper locations.

Cube/prism geometry is optional. S1 stable/unstable and S2 noncompact cards are
extension material only; they do not interrupt the short route.

## Handoff contract for any website implementer

- Preserve the order and nearby claim boundaries in `story.md` and
  `captions.md`; visual polish must not strengthen the scientific claims.
- Use the paired `900` and `390` files as desktop/mobile sources. At 390 px,
  show one comparison per card—never shrink a six- or nine-panel technical
  figure into the evidence slot.
- Keep captions visible without a click. Use line style, marker, labels, and
  layout as well as color; do not make color the only encoding.
- Keep “weighted Nash image” distinct from “social Pareto,” and keep the P1
  trap distinct from the separate nonweak construction.
- Describe X1 as information-losing analysis, not stabilization. Keep I1's
  `algebra checked | trajectory observed | invariant containment unproved`
  boundary next to the design cards.
- Use only the author-confirmed DOI and conference-record URLs in
  [`docs/RELATED_PUBLICATIONS.md`](../../docs/RELATED_PUBLICATIONS.md). Never
  substitute a path to a local PDF.

## Static layout checks

The two preview PNGs use the actual selected card files. The desktop check is
1100 px wide with at most a two-card comparison; the mobile check is 390 px wide
and stacks every card. Both were rendered to PNG during QA and inspected at
their target widths. The mobile layout has no six- or nine-panel evidence image
and each card carries one comparison.

## Author decisions still required

- [ ] Approve or replace T1 production/pollution as the lead image.
- [ ] Choose no cube/prism card, cube only, prism only, or both for the optional
  geometry expansion.
- [ ] Approve the paired P1 trap and rate-decomposition cards.
- [ ] Approve the proposed promotion of X1 fiber collapse.
- [ ] Approve the paired I1 trajectory and aggregate-transfer cards.
- [ ] Decide whether the S1 stable/unstable and S2 noncompact extensions appear
  on the homepage or remain repository-only links.
- [x] Repository code license: BSD-3-Clause.
- [x] Documentation and original generated-figure license: CC BY 4.0.
- [x] Software citation metadata: `CITATION.cff`, release `v1.0.0`.
- [x] Public paper targets: DOI records plus the ECC 2026 program pending its
  final DOI/page range.

These are editorial and release decisions. The pack does not reopen resolved
scientific questions and must not be described as a completed website.
