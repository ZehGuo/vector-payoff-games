# Independent verification

This directory contains numerical checks written independently of the MATLAB
experiment entries. They test algebraic identities, branch data, sampled
trajectories, and certificate margins at the tolerances recorded by each
script.

Run the checks from the repository root:

```bash
python3 verification/verify_s1.py
python3 verification/verify_s2.py
python3 verification/verify_p1.py
python3 verification/verify_x1.py
python3 verification/verify_i1.py
```

The JSON and CSV files beside the scripts are recorded check outputs.
`reference-results/` contains compact MATLAB/reference summaries used for
cross-checking. Independent figures, if generated, are written below the
Git-ignored `results/` directory and do not overwrite the tracked MATLAB
figures in `figures/`.

A passing numerical check establishes agreement for the stated calculation,
grid, and tolerance. It does not independently prove a theorem or establish an
exact reproduction of a published figure.
