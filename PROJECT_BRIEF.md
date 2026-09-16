# Project brief

## Role

Act as the main research-software agent for this project. Understand the mathematical logic of the papers and its implementation, maintain project state, and integrate later work. Proof reconstruction is not required, but mathematical objects, algorithms, parameters, experiments, and plotted conclusions must be understood accurately.

## Final objective

Build a new, reproducible, well-documented MATLAB repository suitable for public GitHub presentation and selected figures on a personal website. Figures do not need to match the papers pixel-for-pixel and may use different parameters, but the repository must retain the comparisons needed to understand the research claims.

## Source material

- `source_material/papers/ifac_extension_37.pdf`
- `source_material/papers/thesis.pdf`
- `source_material/legacy_matlab/simulation_summary/`
- `source_material/legacy_github/ZehuiGuo_Pareto_Improvement_Simulation-main/`
- `reference/previous_prototype/` — prior refactoring attempt; use only as evidence and do not assume its scope or structure is correct.

## Phase 0: audit only

Do not refactor MATLAB code, delete legacy material, introduce a common API, or claim completion. Do not use subagents during the initial audit.

Create:

1. `audit/AUDIT.md`
2. `audit/FIGURE_MANIFEST.md`
3. Updates to `PROJECT_STATE.md`

`AUDIT.md` must explain:

- the main mathematical logic, without reproducing proofs;
- how each mathematical object is computed in code;
- mappings among equations, algorithms, MATLAB files, and parameters;
- the purpose, inputs, outputs, and dependencies of important scripts;
- duplicated code, hard-coded parameters, and likely defects;
- disagreements between paper descriptions and actual code;
- what the old GitHub repository and prior prototype cover or omit.

`FIGURE_MANIFEST.md` must list each relevant figure, table, and numerical experiment, with:

- paper/thesis location and figure number when available;
- the research question it answers;
- axes, curves, regions, comparison groups, and parameters;
- whether it is essential for understanding the paper;
- whether it is suitable for a personal website;
- corresponding MATLAB scripts and data;
- current run status;
- coverage in the prior prototype;
- recommendation to reproduce, redesign, combine, or omit, with reasons.

## Phase 0 completion criteria

- Every relevant paper experiment has a recorded disposition.
- Every important legacy MATLAB script has a classification.
- Every proposed public figure states the comparison it communicates.
- Missing experiments and figures in the previous prototype are explicit.
- Passing unit tests is not treated as evidence that the research content is complete.
- Stop after the audit and request review before implementing Phase 1.

## Working policy

- Use GPT-6 Astra at medium reasoning for the main task.
- Prefer one main session to several agents rereading the same material.
- Use a subagent later only for a narrow unresolved question, with specific source files and a required output file.
- Store durable conclusions in this repository rather than relying on chat history.
- Update `PROJECT_STATE.md` after each accepted phase or material discovery.

