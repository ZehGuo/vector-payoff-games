# Independent verification

[Back to README](../README.md) · [Beginner guide](../docs/BEGINNER_GUIDE.md) · [Reproducing](../docs/REPRODUCING.md) · [Sources and claims](../docs/SOURCES_AND_CLAIMS.md)

This directory contains numerical checks written independently of the MATLAB
experiment entries. They test algebraic identities, branch data, sampled
trajectories, and certificate margins at the tolerances recorded by each
script.

Run the checks from the repository root:

## Requirements

- Python 3.9 or newer is recommended.
- S1, S2, and P1 arithmetic use the standard library; S1/P1 comparison-figure
  rendering uses Pillow when available.
- X1 and I1 require NumPy.

Install the declared packages into your chosen environment with:

```bash
python3 -m pip install -r verification/requirements.txt
```

## Safe default run

Run the checks from the repository root:

```bash
python3 verification/verify_s1.py
python3 verification/verify_s2.py
python3 verification/verify_p1.py
python3 verification/verify_x1.py
python3 verification/verify_i1.py
```

By default, these commands write JSON, CSV, and optional comparison figures
below the Git-ignored `results/verification/<task>/` directory. They do not
overwrite the tracked baselines or the tracked MATLAB figures in `figures/`.
Use `--output-dir PATH` for another destination. `git status --short` should be
unchanged after a default run.

The JSON and CSV files tracked beside the scripts are recorded reference check
outputs. `reference-results/` contains compact MATLAB/reference summaries used
for cross-checking. Repository maintainers can deliberately refresh a tracked
verification baseline with `--update-reference`; ordinary readers should not
use that option.

## Expected success messages

- S1: `S1 algebra checks passed: 5 cases, 20 branches`
- S2: `S2 independent verification passed: 8 games, 32 branches`
- P1: `P1 checks passed: 3 analytically solved property games + actual-rule trap`
- X1: `X1 independent checks passed: ...`
- I1 prints its JSON report and exits successfully after all assertions pass.

T1 has no separate Python checker. Its MATLAB entry reports residual,
conditioning, and finite-grid Jacobian diagnostics, while the global
diffeomorphism/simplicial claim belongs to dissertation Proposition 2.1 and
Theorem 2.4. Adding another finite-grid script would not independently prove
that theorem.

A passing numerical check establishes agreement for the stated calculation,
grid, and tolerance. It does not independently prove a theorem or establish an
exact reproduction of a published figure.
