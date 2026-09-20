#!/usr/bin/env python3
"""Independent numerical checks for X1 without calling MATLAB."""

from __future__ import annotations

import csv
import json
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT_JSON = ROOT / "verification" / "x1_checks.json"
OUT_CSV = ROOT / "verification" / "x1_certificate_margins.csv"

A = np.array([
    [[-2, -1], [-1, -3]],
    [[-4, -4], [-4, -12]],
    [[-7, 1], [1, -2]],
    [[-3, 1], [1, -1]],
], dtype=float)
B = np.array([[8, 0], [30, 0], [4, 0], [12, 0]], dtype=float)
ALPHA = np.array([[0.5, 0.25], [5.0, 1.0]])
T = np.array([
    [6.2058, -1.0547, -2.5757, 0.1138],
    [-1.0547, 4.3862, 3.9895, 0.6236],
    [-2.5757, 3.9895, 6.2058, -2.8365],
    [0.1138, 0.6236, -2.8365, 4.3862],
])
U = np.array([[0.0, 1.0], [1.0, 0.0]])
W = U.copy()


def distances(x: np.ndarray) -> np.ndarray:
    return np.array([
        (A[0, 0] @ x + B[0, 0]) / A[0, 0, 0],
        (A[1, 0] @ x + B[1, 0]) / A[1, 0, 0],
        (A[2, 1] @ x + B[2, 1]) / A[2, 1, 1],
        (A[3, 1] @ x + B[3, 1]) / A[3, 1, 1],
    ])


def mapped(x: np.ndarray):
    d = distances(x)
    eta = np.zeros(2)
    selected = np.zeros(2, dtype=int)
    for i, pair in enumerate((d[:2], d[2:])):
        if pair[0] * pair[1] <= 0:
            continue
        selected[i] = 1 if abs(pair[0]) <= abs(pair[1]) else 2
        eta[i] = pair[selected[i] - 1]
    return eta, selected


def original_rhs(x: np.ndarray) -> np.ndarray:
    _, selected = mapped(x)
    f = np.zeros(2)
    for i, j in enumerate(selected):
        if j:
            q = 2 * i + j - 1
            f[i] = ALPHA[i, j - 1] * (A[q, i] @ x + B[q, i])
    return f


def coordinate_matrix(j1: int, j2: int) -> np.ndarray:
    return np.vstack((A[j1 - 1, 0] / A[j1 - 1, 0, 0],
                      A[j2 + 1, 1] / A[j2 + 1, 1, 1]))


def transformed_matrix(j1: int, j2: int) -> np.ndarray:
    d = np.diag((ALPHA[0, j1 - 1] * A[j1 - 1, 0, 0],
                 ALPHA[1, j2 - 1] * A[j2 + 1, 1, 1]))
    return coordinate_matrix(j1, j2) @ d


def transformed_rhs(z: np.ndarray) -> np.ndarray:
    j1 = 1 if z[0] <= 0 else 2
    j2 = 1 if z[1] <= 0 else 2
    return transformed_matrix(j1, j2) @ z


def rk4(rhs, y0, dt, steps):
    y = np.zeros((steps + 1, len(y0)))
    y[0] = y0
    for k in range(steps):
        q = y[k]
        k1 = rhs(q)
        k2 = rhs(q + dt * k1 / 2)
        k3 = rhs(q + dt * k2 / 2)
        k4 = rhs(q + dt * k3)
        y[k + 1] = q + dt * (k1 + 2 * k2 + 2 * k3 + k4) / 6
    return y


def certificate_rows():
    rows = []
    for j1 in (1, 2):
        for j2 in (1, 2):
            e = np.diag((2 * j1 - 3, 2 * j2 - 3)).astype(float)
            f = np.vstack((e, np.eye(2)))
            p = f.T @ T @ f
            at = transformed_matrix(j1, j2)
            decay = at.T @ p + p @ at + e.T @ U @ e
            positivity = p - e.T @ W @ e
            decay_eig = np.linalg.eigvalsh((decay + decay.T) / 2)
            positive_eig = np.linalg.eigvalsh((positivity + positivity.T) / 2)
            rows.append(dict(
                j1=j1, j2=j2, Atilde=at.tolist(), P=p.tolist(),
                decay_eigenvalues=decay_eig.tolist(),
                positivity_eigenvalues=positive_eig.tolist(),
                max_decay_eigenvalue=float(decay_eig.max()),
                min_positivity_eigenvalue=float(positive_eig.min()),
            ))
    return rows


def main():
    rows = certificate_rows()
    worst_decay = max(r["max_decay_eigenvalue"] for r in rows)
    min_positive = min(r["min_positivity_eigenvalue"] for r in rows)
    assert np.all(U >= 0) and np.all(W >= 0)
    assert worst_decay < 0 and min_positive > 0

    x0 = np.array([6.5, -10.0])
    eta0, _ = mapped(x0)
    assert np.allclose(eta0, [-2.5, -13.25])
    assert not np.allclose(eta0, [-2.5, -13.5])

    dt = 2e-4
    steps = round(5 / dt)
    x = rk4(original_rhs, x0, dt, steps)
    image = np.array([mapped(q)[0] for q in x])
    branches = np.array([mapped(q)[1] for q in x])
    independent = rk4(transformed_rhs, eta0, dt, steps)
    separation = np.linalg.norm(image - independent, axis=1)
    first = int(np.flatnonzero(separation > 1e-3)[0])

    residual = 0.0
    checked = 0
    for q in x[::50]:
        eta, selected = mapped(q)
        if np.all(selected > 0) and np.all(np.abs(eta) > 1e-8):
            lhs = coordinate_matrix(*selected) @ original_rhs(q)
            residual = max(residual, float(np.linalg.norm(lhs - transformed_rhs(eta))))
            checked += 1
    assert checked and residual < 1e-10

    tie_eta, tie_selected = mapped(np.array([7.0, 7.0]))
    tie_d = distances(np.array([7.0, 7.0]))
    assert abs(tie_d[0] - tie_d[1]) < 1e-12 and tie_selected[0] == 1
    assert separation.max() > 1.0

    axis_mask = np.any(branches == 0, axis=1) & ~np.all(branches == 0, axis=1)
    indices = np.flatnonzero(axis_mask)
    first_axis, last_axis = int(indices[0]), int(indices[np.flatnonzero(np.diff(indices) > 1)[0]])
    report = dict(
        provenance="independent NumPy/RK4 transcription of paper formulas; no MATLAB",
        U_entrywise_nonnegative=True,
        W_entrywise_nonnegative=True,
        certificate=dict(
            printed_T=T.tolist(), branches=rows,
            worst_decay_eigenvalue=worst_decay,
            strict_decay_margin=-worst_decay,
            smallest_positivity_eigenvalue=min_positive,
            strict_positivity_margin=min_positive,
            new_certificate_needed=False,
        ),
        eta0=dict(computed=eta0.tolist(), printed=[-2.5, -13.5], residual=0.25),
        integration=dict(
            dt=dt, t_final=5.0, original_integrated=True,
            transformed_integrated_independently=True,
            image_is_pointwise_map=True, interpolation_used=False,
            first_separation_time=first * dt,
            max_separation=float(separation.max()),
            first_one_active_segment=[first_axis * dt, last_axis * dt],
            mapped_segment_endpoints=[image[first_axis].tolist(), image[last_axis].tolist()],
            mapped_segment_norms=[float(np.linalg.norm(image[first_axis])), float(np.linalg.norm(image[last_axis]))],
        ),
        branch_consistency=dict(points_checked=checked, max_chain_rule_residual=residual),
        boundaries=dict(
            active_distance_tie_selects_objective_1=True,
            transformed_axis_rule="nonpositive selects objective 1",
            inverse_on_axes="not returned because preimage is non-unique",
        ),
    )
    OUT_JSON.write_text(json.dumps(report, indent=2) + "\n")
    with OUT_CSV.open("w", newline="") as stream:
        writer = csv.DictWriter(stream, lineterminator="\n", fieldnames=["j1", "j2", "max_decay_eigenvalue", "min_positivity_eigenvalue"])
        writer.writeheader()
        for row in rows:
            writer.writerow({key: row[key] for key in writer.fieldnames})
    print(f"X1 independent checks passed: {checked} full-active points, max separation {separation.max():.6g}")


if __name__ == "__main__":
    main()
