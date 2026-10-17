# Extensions

This folder collects **new results that go beyond the published papers** of
this repository. The main part of the repository (the scripts in the top
folder, `functions/`, `figures/`, `GUIDE.md`) reproduces published work and is
not changed by anything here.

| Extension | What it adds | Status |
|---|---|---|
| [`n_agent_stability/`](n_agent_stability/README.md) | Stability of the equilibrium set for **N players**: a new coordinate change (vertex coordinates), a reduction to $`2^N`$ small systems, and tests that do not depend on the players' speeds. Simulations for 2 and 3 players. | New, not yet peer reviewed |

## Layout of an extension

Every extension is a self-contained folder:

```
extensions/<name>/
  README.md        what is new, how it builds on the published papers, results
  run_<name>.m     reproduces every figure and check of the extension
  *.m              one script per figure, with [PASS]/[FAIL] checks
  functions/       helpers used only by this extension
  figures/         figures produced by the scripts
```

An extension may use the helpers in the main `functions/` folder (they are
added to the path), but it never modifies them, and its own helpers have
different names. Each extension states at the top of its README which
published results it builds on and which statements are new.

## How to run

Open MATLAB in the repository folder and run, for example,

```matlab
cd extensions/n_agent_stability
run_n_agent_stability
```

The main `run_all` does not run the extensions.
