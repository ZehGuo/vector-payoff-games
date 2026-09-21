#!/usr/bin/env python3
"""Independent formula and finite-grid checks for I1.

It preserves the two source-labelled games, includes the omega terms in the
supplementary budget, and keeps theorem hypotheses separate from sampled
trajectory observations.
"""

from __future__ import annotations

import csv
import argparse
import json
import math
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT_JSON = ROOT / "verification/i1_checks.json"
OUT_CSV = ROOT / "verification/reference-results/i1_condition_checks.csv"


def configure_outputs() -> None:
    global OUT_JSON, OUT_CSV
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--update-reference", action="store_true",
                        help="write tracked verification baselines instead of ignored run output")
    parser.add_argument("--output-dir", type=Path,
                        help="custom output directory (cannot be combined with --update-reference)")
    args = parser.parse_args()
    if args.update_reference and args.output_dir:
        parser.error("--update-reference and --output-dir cannot be combined")
    if args.update_reference:
        return
    out = args.output_dir or (ROOT / "results" / "verification" / "i1")
    OUT_JSON = out / "i1_checks.json"
    OUT_CSV = out / "i1_condition_checks.csv"


def q(A, b, x):
    return float(0.5 * x @ A @ x + b @ x)


def make_game(name, b, eta, x0, sigma, zeta, omega, horizon):
    A = np.array([
        [[-4, 1], [1, -10]], [[-4, -1], [-1, -3]],
        [[-16, 8], [8, -16]], [[-5, -1], [-1, -2]],
    ], dtype=float)
    b = np.asarray(b, dtype=float)
    eta = np.asarray(eta, dtype=float)
    x0 = np.asarray(x0, dtype=float)
    zeta = np.asarray(zeta, dtype=float)
    omega = np.asarray(omega, dtype=float)
    AU = np.einsum("i,ijk->jk", eta, A)
    bU = eta @ b
    target = np.linalg.solve(-AU, bU)
    At = np.array([
        zeta[0] * sigma * AU - omega[0] * A[1], A[1],
        zeta[1] * sigma * AU - omega[1] * A[3], A[3],
    ])
    bt = np.array([
        zeta[0] * sigma * bU - omega[0] * b[1], b[1],
        zeta[1] * sigma * bU - omega[1] * b[3], b[3],
    ])
    ct = np.array([
        q(A[0], b[0], x0) - zeta[0]*sigma*q(AU,bU,x0) + omega[0]*q(A[1],b[1],x0), 0,
        q(A[2], b[2], x0) - zeta[1]*sigma*q(AU,bU,x0) + omega[1]*q(A[3],b[3],x0), 0,
    ])
    return dict(name=name, A=A, b=b, eta=eta, x0=x0, sigma=sigma,
                zeta=zeta, omega=omega, horizon=horizon, AU=AU, bU=bU,
                target=target, At=At, bt=bt, ct=ct)


INC0 = make_game(
    "INC-0", [[5, -440], [30, -20], [360, 0], [58.5, 0]],
    [.7, 4, 1, 2], [16, -15], .05, [.3, .7], [0, 0], 8.0)
INCW = make_game(
    "INC-omega", [[5, 730], [30, -295], [360, 0], [180, 0]],
    [.5, 2.5, .5, 2], [21, -35], 3.0, [.5, .5], [1, 4], 5.0)


def gradients(A, b, x):
    full = np.einsum("ijk,k->ij", A, x) + b
    return full, np.array([full[0, 0], full[1, 0], full[2, 1], full[3, 1]])


def rhs(A, b, x):
    _, own = gradients(A, b, x)
    f = np.zeros(2)
    for agent, pair in enumerate(((0, 1), (2, 3))):
        h = own[list(pair)]
        if h[0] * h[1] <= 0:
            continue
        rho = [abs(h[k] / A[pair[k], agent, agent]) for k in range(2)]
        selected = pair[0] if rho[0] <= rho[1] else pair[1]
        f[agent] = own[selected]
    return f


def integrate(A, b, x0, horizon, dt=.001):
    n = round(horizon / dt)
    X = np.empty((n + 1, 2)); X[0] = x0
    for k in range(n):
        x = X[k]
        k1 = rhs(A, b, x)
        k2 = rhs(A, b, x + dt * k1 / 2)
        k3 = rhs(A, b, x + dt * k2 / 2)
        k4 = rhs(A, b, x + dt * k3)
        X[k + 1] = x + dt * (k1 + 2*k2 + 2*k3 + k4) / 6
    return np.linspace(0, horizon, n + 1), X


def line_checks(A, b):
    rows = np.array([A[0, 0], A[1, 0], A[2, 1], A[3, 1]])
    offs = np.array([b[0, 0], b[1, 0], b[2, 1], b[3, 1]])
    pair_dets, triple_residuals = [], []
    for i in range(4):
        for j in range(i + 1, 4):
            M = np.vstack([rows[i], rows[j]])
            d = float(np.linalg.det(M)); pair_dets.append(abs(d))
            if abs(d) > 1e-12:
                x = np.linalg.solve(-M, np.array([offs[i], offs[j]]))
                for k in range(4):
                    if k not in (i, j):
                        triple_residuals.append(abs(float(rows[k] @ x + offs[k])) /
                                                max(np.linalg.norm(rows[k]), 1e-15))
    return min(pair_dets), min(triple_residuals)


def branch_dets(A):
    return [float(np.linalg.det(np.vstack([A[j1, 0], A[j2, 1]])))
            for j1 in (0, 1) for j2 in (2, 3)]


def payoff_changes(A, b, X, x0):
    base = np.array([q(A[j], b[j], x0) for j in range(4)])
    return np.array([[q(A[j], b[j], x) for j in range(4)] for x in X]) - base


def analyze(g):
    t0, X0 = integrate(g["A"], g["b"], g["x0"], g["horizon"])
    t, X = integrate(g["At"], g["bt"], g["x0"], g["horizon"])
    original_on_original = payoff_changes(g["A"], g["b"], X0, g["x0"])
    original_on_incentivized = payoff_changes(g["A"], g["b"], X, g["x0"])
    modified = payoff_changes(g["At"], g["bt"], X, g["x0"])
    dU = np.array([q(g["AU"], g["bU"], x) - q(g["AU"], g["bU"], g["x0"]) for x in X])
    original_weighted = (original_on_incentivized[:, 0] + g["omega"][0] * original_on_incentivized[:, 1] +
                         original_on_incentivized[:, 2] + g["omega"][1] * original_on_incentivized[:, 3])
    aggregate = g["sigma"] * dU - original_weighted
    direct = (modified[:, 0] - original_on_incentivized[:, 0] +
              modified[:, 2] - original_on_incentivized[:, 2])
    omitted = g["sigma"] * dU - original_on_incentivized[:, 0] - original_on_incentivized[:, 2]
    anchor = []
    for i, j in enumerate((0, 2)):
        anchor.append(q(g["At"][j], g["bt"][j], g["x0"]) + g["ct"][j] - q(g["A"][j], g["b"][j], g["x0"]))
    pair_det, triple_resid = line_checks(g["At"], g["bt"])
    target_stationarity = [
        float(np.linalg.norm((g["At"][0] + g["omega"][0]*g["A"][1]) @ g["target"] +
                             g["bt"][0] + g["omega"][0]*g["b"][1])),
        float(np.linalg.norm((g["At"][2] + g["omega"][1]*g["A"][3]) @ g["target"] +
                             g["bt"][2] + g["omega"][1]*g["b"][3])),
    ]
    # Finite polar grid over D(U,x0), used only to test the stronger
    # sufficient inclusion D(U,x0) subset D_bud.  A positive witness rejects
    # that stronger certificate, not incentive feasibility in general.
    radius2=q(g["AU"],g["bU"],g["target"])-q(g["AU"],g["bU"],g["x0"])
    L=np.linalg.cholesky(-g["AU"])
    theta=np.linspace(0,2*math.pi,2001); radial=np.linspace(0,1,201)
    R,T=np.meshgrid(radial,theta,indexing="ij")
    Y=np.column_stack([np.cos(T.ravel()),np.sin(T.ravel())])*(np.sqrt(2*radius2)*R.ravel()[:,None])
    domain_points=g["target"]+np.linalg.solve(L.T,Y.T).T
    def qv(A,b,X): return .5*np.einsum("ni,ij,nj->n",X,A,X)+X@b
    du=qv(g["AU"],g["bU"],domain_points)-q(g["AU"],g["bU"],g["x0"])
    dj=sum(([1,g["omega"][0],1,g["omega"][1]][j])*(qv(g["A"][j],g["b"][j],domain_points)-q(g["A"][j],g["b"][j],g["x0"])) for j in range(4))
    domain_budget=g["sigma"]*du-dj; iw=int(np.argmax(domain_budget))
    return dict(
        name=g["name"], target=g["target"].tolist(), x0=g["x0"].tolist(),
        omega=g["omega"].tolist(), sigma=g["sigma"], zeta=g["zeta"].tolist(),
        U_eigenvalues=np.linalg.eigvalsh(g["AU"]).tolist(),
        own_curvatures=[g["At"][0,0,0],g["At"][1,0,0],g["At"][2,1,1],g["At"][3,1,1]],
        branch_determinants=branch_dets(g["At"]), min_line_pair_determinant=pair_det,
        min_nonincident_line_residual=triple_resid, p_at_x0=anchor,
        target_stationarity_residual=target_stationarity,
        budget_identity_max_error=float(np.max(abs(aggregate-direct))),
        aggregate_transfer_max=float(np.max(aggregate)), aggregate_transfer_min=float(np.min(aggregate)),
        aggregate_transfer_final=float(aggregate[-1]), omitted_formula_final=float(omitted[-1]),
        original_terminal=X0[-1].tolist(), incentivized_terminal=X[-1].tolist(),
        target_distance_final=float(np.linalg.norm(X[-1]-g["target"])),
        original_payoff_change_on_original_final=original_on_original[-1].tolist(),
        original_payoff_change_on_incentivized_final=original_on_incentivized[-1].tolist(),
        modified_payoff_change_final=modified[-1].tolist(),
        strong_domain_inclusion_grid_max=float(domain_budget[iw]),
        strong_domain_inclusion_counterexample=domain_points[iw].tolist(),
        validation_level=("omega=0 boundary: exact identities and sampled trajectory; positive-lambda theorem not invoked"
                          if np.all(g["omega"] == 0) else
                          "algebraic theorem hypotheses checked; invariant-set inclusion not proved, sampled trajectory only"),
    )


def sigma_checks():
    A = np.array([[[-2,1],[1,-3]],[[-2,-1],[-1,-10]],
                  [[-4,1],[1,-4]],[[-5,-1],[-1,-2]]], float)
    b = np.array([[5,-5],[20,124],[90,0],[72,0]], float)
    eta = np.array([1,3,1,3], float); omega = np.array([1,1], float)
    AU = np.einsum("i,ijk->jk",eta,A)
    AJ = A[0]+A[1]+A[2]+A[3]
    # det(sigma AU - AJ) is a quadratic; fit and solve.
    s=np.array([0.,1.,2.]); y=np.array([np.linalg.det(v*AU-AJ) for v in s])
    coef=np.polyfit(s,y,2); roots=np.sort(np.roots(coef).real)
    signs=[]
    for v in (.35,.47,.56):
        H=v*AU-AJ; ev=np.linalg.eigvalsh(H)
        signs.append(dict(sigma=v,eigenvalues=ev.tolist(),classification=(
            "interior ellipse" if np.all(ev>0) else "exterior ellipse" if np.all(ev<0) else "hyperbola/parabola regime")))
    return dict(critical_sigma=roots.tolist(), regimes=signs,
                acc_complement_sigmas=[3,.551],
                interpretation=("ACC-style complement comparison uses the checked identity; "
                                "it is not labeled as an exact ACC-parameter reproduction"))


def main():
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    results=[analyze(INC0),analyze(INCW)]
    checks=dict(payoff_order=["J_1^1","J_2^1","J_1^2","J_2^2"],
                rule="nearest-BR", experiments=results, sigma=sigma_checks(),
                theorem_boundary=("Theorem conditions imply their stated guarantees. Failure to prove the "
                                  "sufficient invariant-set inclusion is not an impossibility result."))
    for r in results:
        assert max(abs(v) for v in r["p_at_x0"]) < 1e-10
        assert r["budget_identity_max_error"] < 1e-8
        assert max(r["own_curvatures"]) < 0
        assert min(r["branch_determinants"]) > 0
        assert r["min_line_pair_determinant"] > 1e-8
        assert r["min_nonincident_line_residual"] > 1e-8
        assert max(r["target_stationarity_residual"]) < 1e-9
        assert r["aggregate_transfer_max"] < 1e-7
    OUT_JSON.write_text(json.dumps(checks,indent=2)+"\n")
    with OUT_CSV.open("w",newline="") as f:
        w=csv.writer(f,lineterminator="\n"); w.writerow(["experiment","p_x0_max_abs","budget_identity_max_error","min_own_curvature_margin","min_branch_det","min_pair_det","min_triple_residual","budget_max","budget_min","budget_final","omitted_budget_final","target_distance_final","strong_domain_grid_max","validation_level"])
        for r in results:
            w.writerow([r["name"],max(abs(v) for v in r["p_at_x0"]),r["budget_identity_max_error"],-max(r["own_curvatures"]),min(r["branch_determinants"]),r["min_line_pair_determinant"],r["min_nonincident_line_residual"],r["aggregate_transfer_max"],r["aggregate_transfer_min"],r["aggregate_transfer_final"],r["omitted_formula_final"],r["target_distance_final"],r["strong_domain_inclusion_grid_max"],r["validation_level"]])
    print(json.dumps(checks,indent=2))


if __name__ == "__main__":
    configure_outputs()
    main()
