#!/usr/bin/env python3
"""Independent standard-library checks for the S2 experiment.

This does not call MATLAB, inspect cdc2023 filenames as case labels, or infer
compactness from a plotting window.  It checks the new documented parameters,
Assumption 1, Assumption 4 for the five degenerate games, every branch matrix,
and the mixed-determinant noncompact certificate from thesis Proposition 3.1.
"""

from __future__ import annotations

import csv
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_JSON = ROOT / "verification" / "s2_checks.json"
OUT_CSV = ROOT / "verification" / "s2_independent_branch_diagnostics.csv"

DEGENERATE = [
    ("D1", "stable-CW", (.8, .3), (-.6, -.2), (0., 0.), (1., -1.), True),
    ("D2", "stable-real", (.6, .4), (.8, .2), (0., 0.), (1., -1.), True),
    ("D3", "stable-CCW", (-.3, -.7), (.8, .5), (0., 0.), (1., -1.), True),
    ("D4", "stable-mixed", (.8, .5), (-.4, .3), (0., 0.), (1., -1.), True),
    ("D5", "unstable-saddle", (1.1, 1.3), (2., 1.6), (0., 0.), (1., -1.), False),
]
NONCOMPACT = [
    ("N1", "one-saddle-branch funnel", (.4, 1.6), (.5, 1.), (-1., 1.), (-1., 1.)),
    ("N2", "three-saddle-branch funnel", (.6, 1.4), (.8, 2.), (-2., 1.), (1., -2.)),
    ("N3", "opposite-wing geometry", (-.8, .8), (-.7, 1.8), (-1., 1.), (1., -1.)),
]


def solve2(rows, rhs):
    a, b = rows
    det = a[0] * b[1] - a[1] * b[0]
    assert abs(det) > 1e-12
    return ((rhs[0] * b[1] - a[1] * rhs[1]) / det,
            (a[0] * rhs[1] - rhs[0] * b[0]) / det)


def gradients(game, x):
    _, _, p, q, c, d, *_ = game
    return ((-x[0] + p[0] * x[1] + c[0], -x[0] + p[1] * x[1] + c[1]),
            (q[0] * x[0] - x[1] + d[0], q[1] * x[0] - x[1] + d[1]))


def is_nash(game, x):
    h1, h2 = gradients(game, x)
    return h1[0] * h1[1] <= 1e-10 and h2[0] * h2[1] <= 1e-10


def choose(h):
    if h[0] * h[1] <= 0:
        return 0
    return 1 if abs(h[0]) <= abs(h[1]) else 2


def rhs(game, x):
    h1, h2 = gradients(game, x)
    j1, j2 = choose(h1), choose(h2)
    return (0. if j1 == 0 else h1[j1 - 1], 0. if j2 == 0 else h2[j2 - 1])


def general_position(game):
    _, _, p, q, c, d, *_ = game
    lines = [(1., -p[0], -c[0]), (1., -p[1], -c[1]),
             (-q[0], 1., -d[0]), (-q[1], 1., -d[1])]
    intersections = []
    for i in range(4):
        for j in range(i + 1, 4):
            point = solve2((lines[i][:2], lines[j][:2]), (-lines[i][2], -lines[j][2]))
            for k, line in enumerate(lines):
                if k not in (i, j):
                    assert abs(line[0] * point[0] + line[1] * point[1] + line[2]) > 1e-9
            intersections.append(point)
    assert all(abs(v) > 1e-12 for v in (*p, *q))
    return intersections


def branch_rows(game, group):
    ident, label, p, q, c, d, *_ = game
    rows = []
    for j1, a12 in enumerate(p, 1):
        for j2, a21 in enumerate(q, 1):
            det = 1. - a12 * a21
            product = a12 * a21
            if product >= 0:
                root = math.sqrt(product)
                eigenvalues = [(-1. + root, 0.), (-1. - root, 0.)]
            else:
                root = math.sqrt(-product)
                eigenvalues = [(-1., root), (-1., -root)]
            corner = solve2(((1., -a12), (-a21, 1.)), (c[j1 - 1], d[j2 - 1]))
            rows.append(dict(group=group, case=ident, label=label, j1=j1, j2=j2,
                             matrix=[[-1., a12], [a21, -1.]], determinant=det,
                             eigenvalues=eigenvalues, corner=list(corner)))
    return rows


def recession_sample(game, samples=72000):
    _, _, p, q, *_ = game
    inside = 0
    for k in range(samples):
        angle = 2 * math.pi * k / samples
        v = (math.cos(angle), math.sin(angle))
        a = (-v[0] + p[0] * v[1], -v[0] + p[1] * v[1])
        b = (q[0] * v[0] - v[1], q[1] * v[0] - v[1])
        inside += a[0] * a[1] <= 1e-12 and b[0] * b[1] <= 1e-12
    return 360. * inside / samples


def rk4(game, x0, total=7., dt=.015):
    x = tuple(x0)
    max_norm = math.hypot(*x)
    for _ in range(math.ceil(total / dt)):
        k1 = rhs(game, x)
        k2 = rhs(game, (x[0] + dt * k1[0] / 2, x[1] + dt * k1[1] / 2))
        k3 = rhs(game, (x[0] + dt * k2[0] / 2, x[1] + dt * k2[1] / 2))
        k4 = rhs(game, (x[0] + dt * k3[0], x[1] + dt * k3[1]))
        x = (x[0] + dt * (k1[0] + 2 * k2[0] + 2 * k3[0] + k4[0]) / 6,
             x[1] + dt * (k1[1] + 2 * k2[1] + 2 * k3[1] + k4[1]) / 6)
        max_norm = max(max_norm, math.hypot(*x))
        if max_norm > 100:
            break
    return x, max_norm


def analyze():
    summaries, rows = [], []
    for game in DEGENERATE:
        general_position(game)
        current = branch_rows(game, "degenerate")
        rows.extend(current)
        dets = [r["determinant"] for r in current]
        stable = game[6]
        assert all(d > 0 for d in dets) if stable else all(d < 0 for d in dets)
        h1, h2 = gradients(game, (0., 0.))
        assert h1 == (0., 0.) and h2[0] * h2[1] < 0 and is_nash(game, (0., 0.))
        _, _, _, q, _, d, _ = game
        p2 = solve2(((-q[0], 1.), (-q[1], 1.)), d)
        assert not is_nash(game, p2)
        summaries.append(dict(group="degenerate", case=game[0], label=game[1],
                              parameters=dict(p=game[2], q=game[3], c=game[4], d=game[5]),
                              determinant_range=[min(dets), max(dets)], assumption1=True,
                              assumption2=True, assumption4=True, rank_zero_point=[0., 0.],
                              other_same_agent_intersection=list(p2), theorem311_applies=True,
                              theorem311_result="asymptotically stable" if stable else "unstable"))
    for game in NONCOMPACT:
        general_position(game)
        current = branch_rows(game, "noncompact")
        rows.extend(current)
        dets = [r["determinant"] for r in current]
        assert any(d > 0 for d in dets) and any(d < 0 for d in dets)
        angle = recession_sample(game)
        assert angle > 0
        summaries.append(dict(group="noncompact", case=game[0], label=game[1],
                              parameters=dict(p=game[2], q=game[3], c=game[4], d=game[5]),
                              determinants=dets, assumption1=True, assumption2=False,
                              theorem311_applies=False,
                              noncompact_certificate="Proposition 3.1: mixed determinant signs under Assumption 1",
                              sampled_recession_angle_degrees=angle))
    # Representative instability observation, separate from the theorem identity.
    end, max_norm = rk4(DEGENERATE[4], (-2., -1.))
    assert max_norm > 20
    return summaries, rows, dict(case="D5", x0=[-2., -1.], final=list(end), max_norm=max_norm,
                                 role="finite-time representative trajectory, not the case proof")


def write_outputs(summaries, rows, witness):
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUT_JSON.write_text(json.dumps(dict(status="pass", summaries=summaries,
                                        branch_count=len(rows), unstable_observation=witness),
                                   indent=2, ensure_ascii=False) + "\n")
    with OUT_CSV.open("w", newline="") as stream:
        writer = csv.writer(stream, lineterminator="\n")
        writer.writerow(["group", "case", "j1", "j2", "a11", "a12", "a21", "a22",
                         "det", "eig1_real", "eig1_imag", "eig2_real", "eig2_imag",
                         "corner_x1", "corner_x2"])
        for r in rows:
            e1, e2 = r["eigenvalues"]
            writer.writerow([r["group"], r["case"], r["j1"], r["j2"], -1,
                             r["matrix"][0][1], r["matrix"][1][0], -1, r["determinant"],
                             e1[0], e1[1], e2[0], e2[1], *r["corner"]])


if __name__ == "__main__":
    summaries, rows, witness = analyze()
    write_outputs(summaries, rows, witness)
    print(f"S2 independent verification passed: {len(summaries)} games, {len(rows)} branches")
