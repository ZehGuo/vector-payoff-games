# Vector Payoff Games — Research Reconstruction

This repository reconstructs the numerical research examples behind Zehui Guo's
work on vector-payoff games, stability, Pareto improvement, coordinate
transformations, and incentive design.

The repository is organized around six reproducible MATLAB experiment entries:

- `run_t1_topology_applications` — weight domains, Nash images, and application;
- `run_s1_five_cases` — four stable cases and one unstable case;
- `run_s2_degenerate_noncompact` — rank-degenerate and noncompact boundaries;
- `run_p1_payoff_properties` — nonweak/all/weak properties and a separate trap;
- `run_x1_transformation_stability` — domain collapse, independent dynamics, and certificate;
- `run_i1_incentive_budget` — incentive geometry, sigma/omega, before/after, and budget.

Start with [PROJECT_STATE.md](PROJECT_STATE.md) for current status,
[audit/FIGURE_MANIFEST.md](audit/FIGURE_MANIFEST.md) for full research coverage,
and [audit/implementation/R1.md](audit/implementation/R1.md) for the integrated
verification and presentation review. Detailed task reports are under
`audit/implementation/`.

## Evidence boundaries

Static source inspection, independent numerical checks, clean-session MATLAB
execution, and exact source-figure reproduction are different evidence levels.
A successful run or finite grid does not replace a theorem condition. New
parameters and schematic figures are labeled explicitly, and paper/legacy
parameter variants are not silently mixed.

## Local inputs and generated outputs

`source_material/` and `reference/` are local research inputs and are excluded
from Git. Generated MATLAB outputs, including the R1 review pack, are written
under `results/` and are also excluded. This prevents accidental publication of
papers, legacy archives, prototypes, and runtime bundles.

No push, deployment, or public release is performed by the reconstruction tasks.
