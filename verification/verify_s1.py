#!/usr/bin/env python3
"""Independent algebra and rendering check for the S1 experiment.

This script uses the same documented, newly constructed parameter sets as the
MATLAB entry, but it does not call MATLAB. It checks
slope identities, branch determinants/eigenstructure, general position, local
active cones, and the Case 5 positive-eigenvalue witness.  It also renders the
independent comparison figures with Pillow when available.
"""

from __future__ import annotations

import csv
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_JSON = ROOT / "verification" / "s1_checks.json"
OUT_CSV = ROOT / "verification" / "s1_independent_branch_diagnostics.csv"
FIG_DIR = ROOT / "results" / "s1" / "independent"

CASES = [
    dict(case=1, label="stable-CW", s1=(0.8, 0.3), s2=(-0.6, -0.2), stable=True,
         order="s_1^1 > s_2^1 > 0 > s_2^2 > s_1^2"),
    dict(case=2, label="stable-real", s1=(0.6, 0.4), s2=(0.8, 0.2), stable=True,
         order="s_1^2 > s_1^1 > s_2^1 > s_2^2 > 0"),
    dict(case=3, label="stable-CCW", s1=(-0.3, -0.7), s2=(0.8, 0.5), stable=True,
         order="s_1^2 > s_2^2 > 0 > s_1^1 > s_2^1"),
    dict(case=4, label="stable-mixed", s1=(0.8, 0.5), s2=(-0.4, 0.3), stable=True,
         order="s_1^1 > s_2^1 > s_2^2 > 0 > s_1^2"),
    dict(case=5, label="unstable-saddle", s1=(1.1, 1.3), s2=(2.0, 1.6), stable=False,
         order="s_1^2 > s_2^2 > s_2^1 > s_1^1 > 0"),
]
P1 = (5.0, 6.0)
P2 = (6.0, 5.0)


def setup(case):
    c1 = tuple(P1[0] - s * P1[1] for s in case["s1"])
    c2 = tuple(P2[1] - s * P2[0] for s in case["s2"])
    return {**case, "c1": c1, "c2": c2}


def solve2(a, b):
    det = a[0][0] * a[1][1] - a[0][1] * a[1][0]
    assert abs(det) > 1e-12
    return ((b[0] * a[1][1] - a[0][1] * b[1]) / det,
            (a[0][0] * b[1] - b[0] * a[1][0]) / det)


def gradients(case, x):
    h1 = tuple(-x[0] + s * x[1] + c for s, c in zip(case["s1"], case["c1"]))
    h2 = tuple(s * x[0] - x[1] + c for s, c in zip(case["s2"], case["c2"]))
    return h1, h2


def choose(h):
    if h[0] * h[1] <= 0:
        return 0
    return 1 if abs(h[0]) <= abs(h[1]) else 2


def branch(case, x):
    h1, h2 = gradients(case, x)
    return choose(h1), choose(h2)


def rhs(case, x):
    h1, h2 = gradients(case, x)
    j1, j2 = choose(h1), choose(h2)
    return (0.0 if j1 == 0 else h1[j1 - 1], 0.0 if j2 == 0 else h2[j2 - 1])


def is_nash(case, x):
    h1, h2 = gradients(case, x)
    return h1[0] * h1[1] <= 1e-10 and h2[0] * h2[1] <= 1e-10


def assert_general_position(case):
    lines = [(1.0, -case["s1"][0], -case["c1"][0]),
             (1.0, -case["s1"][1], -case["c1"][1]),
             (-case["s2"][0], 1.0, -case["c2"][0]),
             (-case["s2"][1], 1.0, -case["c2"][1])]
    for i in range(4):
        for j in range(i + 1, 4):
            a, b = lines[i], lines[j]
            point = solve2(((a[0], a[1]), (b[0], b[1])), (-a[2], -b[2]))
            for k, line in enumerate(lines):
                if k not in (i, j):
                    residual = line[0] * point[0] + line[1] * point[1] + line[2]
                    assert abs(residual) > 1e-8, "three BR lines share an intersection"


def eig2(s1, s2):
    product = s1 * s2
    det = 1.0 - product
    if product >= 0:
        root = math.sqrt(product)
        vals = (-1.0 + root, -1.0 - root)
        vecs = []
        for value in vals:
            if abs(s1) > 1e-12:
                v = (s1, 1.0 + value)
            else:
                v = (1.0 + value, s2)
            n = math.hypot(*v)
            vecs.append((v[0] / n, v[1] / n))
        return det, vals, vecs, (0.0, 0.0)
    imag = math.sqrt(-product)
    return det, (-1.0, -1.0), [], (imag, -imag)


def cone(case, xstar, pair, samples=14400):
    mask = []
    for k in range(samples):
        angle = 2 * math.pi * k / samples
        x = (xstar[0] + 1e-6 * math.cos(angle), xstar[1] + 1e-6 * math.sin(angle))
        mask.append(branch(case, x) == pair)
    assert any(mask) and not all(mask)
    outside = mask.index(False)
    rotated = mask[outside + 1:] + mask[:outside + 1]
    runs = []
    start = None
    for k, inside in enumerate(rotated + [False]):
        if inside and start is None:
            start = k
        elif not inside and start is not None:
            runs.append((start, k - 1))
            start = None
    begin, end = max(runs, key=lambda r: r[1] - r[0])
    length = end - begin + 1
    first = (outside + 1 + begin) % samples
    return 2 * math.pi * first / samples, 2 * math.pi * length / samples


def ray_inside(case, xstar, pair, v):
    ans = []
    for sign in (1.0, -1.0):
        x = (xstar[0] + sign * 1e-6 * v[0], xstar[1] + sign * 1e-6 * v[1])
        ans.append(branch(case, x) == pair)
    return ans


def transition(case, s1, s2, det, angle, vals, rays):
    if det < 0:
        for value, inside in zip(vals, rays):
            if value > 0 and any(inside):
                return "unstable non-transitive eigenray"
        return "saddle: stable eigenray / outward generic flow"
    if s1 * s2 < 0:
        return "1-transitive clockwise" if s2 < 0 else "1-transitive counterclockwise"
    return "0-transitive" if angle < math.pi / 2 else "2-transitive"


def analyze():
    rows = []
    summaries = []
    for raw in CASES:
        case = setup(raw)
        assert_general_position(case)
        vertices = []
        counts = {"0": 0, "1": 0, "2": 0, "unstable": 0, "saddle": 0}
        for j1, s1 in enumerate(case["s1"], 1):
            for j2, s2 in enumerate(case["s2"], 1):
                xstar = solve2(((1.0, -s1), (-s2, 1.0)), (case["c1"][j1 - 1], case["c2"][j2 - 1]))
                vertices.append(xstar)
                det, vals, vecs, imags = eig2(s1, s2)
                begin, angle = cone(case, xstar, (j1, j2))
                rays = [ray_inside(case, xstar, (j1, j2), v) for v in vecs]
                label = transition(case, s1, s2, det, angle, vals, rays)
                if label.startswith("0-"): counts["0"] += 1
                elif label.startswith("1-"): counts["1"] += 1
                elif label.startswith("2-"): counts["2"] += 1
                elif label.startswith("unstable"): counts["unstable"] += 1
                else: counts["saddle"] += 1
                rows.append(dict(
                    case=case["case"], j1=j1, j2=j2,
                    matrix=[[-1.0, s1], [s2, -1.0]], determinant=det,
                    eigenvalues=[dict(real=vals[0], imag=imags[0]), dict(real=vals[1], imag=imags[1])],
                    eigenvectors=[list(v) for v in vecs], eigenrays_in_active_cone=rays,
                    cone_start_deg=begin * 180 / math.pi, cone_angle_deg=angle * 180 / math.pi,
                    transition=label, xstar=list(xstar)))
        dets = [r["determinant"] for r in rows if r["case"] == case["case"]]
        assert (all(d > 0 for d in dets) if case["stable"] else all(d < 0 for d in dets))
        assert not is_nash(case, P1) and not is_nash(case, P2)
        summaries.append(dict(case=case["case"], label=case["label"], slope_order=case["order"],
                              s1=list(case["s1"]), s2=list(case["s2"]), c1=list(case["c1"]), c2=list(case["c2"]),
                              determinant_range=[min(dets), max(dets)], transition_counts=counts,
                              vertices=[list(v) for v in vertices], expected_stability="stable" if case["stable"] else "unstable"))
    c5 = [r for r in rows if r["case"] == 5]
    assert any(any(ray) and ev["real"] > 0 for r in c5 for ray, ev in zip(r["eigenrays_in_active_cone"], r["eigenvalues"]))
    return summaries, rows


def rk4(case, x0, total=6.0, dt=0.012):
    points = [tuple(x0)]
    for _ in range(int(total / dt)):
        x = points[-1]
        k1 = rhs(case, x)
        k2 = rhs(case, (x[0] + dt * k1[0] / 2, x[1] + dt * k1[1] / 2))
        k3 = rhs(case, (x[0] + dt * k2[0] / 2, x[1] + dt * k2[1] / 2))
        k4 = rhs(case, (x[0] + dt * k3[0], x[1] + dt * k3[1]))
        nxt = (x[0] + dt * (k1[0] + 2 * k2[0] + 2 * k3[0] + k4[0]) / 6,
               x[1] + dt * (k1[1] + 2 * k2[1] + 2 * k3[1] + k4[1]) / 6)
        points.append(nxt)
        if abs(nxt[0]) + abs(nxt[1]) > 100 or (is_nash(case, nxt) and math.hypot(*rhs(case, nxt)) < 1e-9):
            break
    return points


def convex_order(vertices):
    center = (sum(x for x, _ in vertices) / len(vertices), sum(y for _, y in vertices) / len(vertices))
    return sorted(vertices, key=lambda p: math.atan2(p[1] - center[1], p[0] - center[0]))


def render_overview(summaries, rows):
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        return False
    W, H = 1800, 1080
    im = Image.new("RGB", (W, H), "white")
    draw = ImageDraw.Draw(im, "RGBA")
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 23)
        small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 17)
        titlefont = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 32)
    except OSError:
        font = small = titlefont = ImageFont.load_default()
    draw.text((45, 24), "S1 - Five two-agent stability cases", fill=(25, 30, 40), font=titlefont)
    draw.text((45, 63), "Case identity: BR slope order + four branch matrices + active-cone transitions", fill=(70, 75, 85), font=small)
    panel_w, panel_h = 560, 450
    origins = [(35, 105), (620, 105), (1205, 105), (330, 595), (915, 595)]
    colors = dict(a1=(211, 54, 64, 255), a2=(42, 99, 194, 255), field=(135, 145, 160, 180), traj=(30, 30, 35, 255))
    def clip_segment(p, q, bounds):
        """Liang-Barsky clip in image coordinates."""
        xmin, ymin, xmax, ymax = bounds
        dx, dy = q[0] - p[0], q[1] - p[1]
        entering, leaving = 0.0, 1.0
        for edge, offset in ((-dx, p[0] - xmin), (dx, xmax - p[0]),
                             (-dy, p[1] - ymin), (dy, ymax - p[1])):
            if abs(edge) < 1e-14:
                if offset < 0:
                    return None
                continue
            ratio = offset / edge
            if edge < 0:
                if ratio > leaving:
                    return None
                entering = max(entering, ratio)
            else:
                if ratio < entering:
                    return None
                leaving = min(leaving, ratio)
        return ((p[0] + entering * dx, p[1] + entering * dy),
                (p[0] + leaving * dx, p[1] + leaving * dy))

    def draw_clipped_polyline(points, bounds, fill, width):
        for p, q in zip(points, points[1:]):
            segment = clip_segment(p, q, bounds)
            if segment:
                draw.line((*segment[0], *segment[1]), fill=fill, width=width)

    for summary, origin in zip(summaries, origins):
        case = setup(CASES[summary["case"] - 1])
        ox, oy = origin
        draw.rounded_rectangle((ox, oy, ox + panel_w, oy + panel_h), radius=12, outline=(190, 195, 205), width=2, fill=(250, 251, 253))
        pts = [tuple(v) for v in summary["vertices"]] + [P1, P2]
        lo = (min(p[0] for p in pts) - 1.0, min(p[1] for p in pts) - 1.0)
        hi = (max(p[0] for p in pts) + 1.0, max(p[1] for p in pts) + 1.0)
        left, top, right, bottom = ox + 48, oy + 55, ox + panel_w - 18, oy + panel_h - 42
        plot_bounds = (left, top, right, bottom)
        def mp(p):
            return (left + (p[0] - lo[0]) / (hi[0] - lo[0]) * (right - left),
                    bottom - (p[1] - lo[1]) / (hi[1] - lo[1]) * (bottom - top))
        for g in range(6):
            x = left + g * (right - left) / 5
            y = top + g * (bottom - top) / 5
            draw.line((x, top, x, bottom), fill=(226, 230, 235), width=1)
            draw.line((left, y, right, y), fill=(226, 230, 235), width=1)
        for gx in range(2, 16):
            for gy in range(2, 12):
                x = lo[0] + gx / 17 * (hi[0] - lo[0]); y = lo[1] + gy / 13 * (hi[1] - lo[1])
                f = rhs(case, (x, y)); n = math.hypot(*f)
                if n < 1e-10: continue
                p = mp((x, y)); q = (p[0] + 8 * f[0] / n, p[1] - 8 * f[1] / n)
                draw.line((*p, *q), fill=colors["field"], width=1)
        nash = [mp(v) for v in convex_order([tuple(v) for v in summary["vertices"]])]
        draw.polygon(nash, fill=(160, 89, 177, 100), outline=(102, 45, 120, 240))
        for j in range(2):
            xlo, xhi = lo[0], hi[0]
            ylo = (xlo - case["c1"][j]) / case["s1"][j]; yhi = (xhi - case["c1"][j]) / case["s1"][j]
            segment = clip_segment(mp((xlo, ylo)), mp((xhi, yhi)), plot_bounds)
            if segment:
                draw.line((*segment[0], *segment[1]), fill=colors["a1"], width=3)
            ylo = case["s2"][j] * xlo + case["c2"][j]; yhi = case["s2"][j] * xhi + case["c2"][j]
            segment = clip_segment(mp((xlo, ylo)), mp((xhi, yhi)), plot_bounds)
            if segment:
                draw.line((*segment[0], *segment[1]), fill=colors["a2"], width=3)
        verts = [tuple(v) for v in summary["vertices"]]
        center = (sum(x for x, _ in verts) / 4, sum(y for _, y in verts) / 4)
        radius = max(math.hypot(x - center[0], y - center[1]) for x, y in verts) + 0.65
        for a in [q * math.pi / 4 for q in range(8)]:
            x0 = (center[0] + radius * math.cos(a), center[1] + radius * math.sin(a))
            traj = rk4(case, x0, total=5.0)
            draw_clipped_polyline([mp(p) for p in traj], plot_bounds, colors["traj"], 2)
            px, py = mp(traj[0])
            if left <= px <= right and top <= py <= bottom:
                draw.ellipse((px - 2, py - 2, px + 2, py + 2), fill=colors["traj"])
        if summary["case"] == 5:
            witness = next(r for r in rows if r["case"] == 5 and r["j1"] == 1 and r["j2"] == 2)
            idx = next(i for i, ev in enumerate(witness["eigenvalues"]) if ev["real"] > 0)
            v = witness["eigenvectors"][idx]; xs = witness["xstar"]
            if branch(case, (xs[0] + 1e-5 * v[0], xs[1] + 1e-5 * v[1])) != (1, 2): v = [-v[0], -v[1]]
            traj = rk4(case, (xs[0] + .05 * v[0], xs[1] + .05 * v[1]), total=3.0, dt=.006)
            draw_clipped_polyline([mp(p) for p in traj], plot_bounds, (225, 30, 35), 5)
        draw.rectangle((left, top, right, bottom), outline=(100, 108, 120), width=2)
        draw.text((ox + 18, oy + 14), f"Case {summary['case']}  {summary['label']}", fill=(24, 30, 40), font=font)
        d0, d1 = summary["determinant_range"]
        draw.text((ox + 18, oy + panel_h - 29), f"det range [{d0:.2f}, {d1:.2f}]", fill=(65, 70, 80), font=small)
    FIG_DIR.mkdir(parents=True, exist_ok=True)
    im.save(FIG_DIR / "S1_five_case_overview.png")
    return True


def render_transition(rows):
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        return False
    examples = [(2, 1, 1, "0-transitive", "larger eigenvalue ray lies in acute cone"),
                (2, 1, 2, "2-transitive", "smaller eigenvalue ray separates two exits"),
                (1, 1, 1, "1-transitive", "complex pair; clockwise boundary crossing"),
                (5, 1, 2, "unstable", "positive eigenvalue ray stays in active cone")]
    W, H = 1680, 900
    im = Image.new("RGB", (W, H), "white"); draw = ImageDraw.Draw(im, "RGBA")
    try:
        titlefont = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 32)
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 22)
        small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 17)
    except OSError:
        titlefont = font = small = ImageFont.load_default()
    draw.text((45, 25), "Eigenvectors and local domain transitions", fill=(24, 30, 40), font=titlefont)
    origins = [(40, 95), (850, 95), (40, 490), (850, 490)]
    for example, origin in zip(examples, origins):
        c, j1, j2, name, caption = example
        r = next(x for x in rows if x["case"] == c and x["j1"] == j1 and x["j2"] == j2)
        ox, oy = origin; cx, cy = ox + 190, oy + 190; radius = 145
        draw.rounded_rectangle((ox, oy, ox + 760, oy + 350), radius=12, fill=(249, 250, 252), outline=(190, 195, 205), width=2)
        start = math.radians(r["cone_start_deg"]); span = math.radians(r["cone_angle_deg"])
        poly = [(cx, cy)] + [(cx + radius * math.cos(start + span * k / 80), cy - radius * math.sin(start + span * k / 80)) for k in range(81)]
        draw.polygon(poly, fill=(168, 105, 184, 85))
        for a in (start, start + span):
            draw.line((cx, cy, cx + radius * math.cos(a), cy - radius * math.sin(a)), fill=(30, 30, 35), width=3)
        if r["eigenvectors"]:
            for idx, v in enumerate(r["eigenvectors"]):
                for sign, inside in zip((1, -1), r["eigenrays_in_active_cone"][idx]):
                    color = (220, 35, 42) if inside else (90, 95, 105)
                    end = (cx + sign * radius * .86 * v[0], cy - sign * radius * .86 * v[1])
                    draw.line((cx, cy, *end), fill=color, width=5 if inside else 2)
                    draw.ellipse((end[0] - 4, end[1] - 4, end[0] + 4, end[1] + 4), fill=color)
        else:
            case = setup(CASES[c - 1]); s1 = case["s1"][j1 - 1]; s2 = case["s2"][j2 - 1]
            for q in range(7):
                a = start + span * (q + 1) / 8; y = (.72 * math.cos(a), .72 * math.sin(a)); f = (-y[0] + s1 * y[1], s2 * y[0] - y[1]); n = math.hypot(*f)
                p = (cx + radius * y[0], cy - radius * y[1]); end = (p[0] + 28 * f[0] / n, p[1] - 28 * f[1] / n)
                draw.line((*p, *end), fill=(35, 92, 186), width=3)
        draw.ellipse((cx - 4, cy - 4, cx + 4, cy + 4), fill=(20, 20, 25))
        draw.text((ox + 380, oy + 55), f"Case {c}, branch ({j1},{j2})", fill=(25, 30, 40), font=font)
        draw.text((ox + 380, oy + 95), name, fill=(115, 45, 130) if c < 5 else (205, 30, 35), font=font)
        draw.text((ox + 380, oy + 140), caption, fill=(65, 70, 80), font=small)
        evtext = ", ".join(f"{e['real']:.3f}" + (f"{e['imag']:+.3f}i" if abs(e['imag']) > 1e-9 else "") for e in r["eigenvalues"])
        draw.text((ox + 380, oy + 185), f"eigenvalues: {evtext}", fill=(65, 70, 80), font=small)
        draw.text((ox + 380, oy + 220), f"cone angle: {r['cone_angle_deg']:.1f} deg", fill=(65, 70, 80), font=small)
    FIG_DIR.mkdir(parents=True, exist_ok=True)
    im.save(FIG_DIR / "S1_eigenvectors_transitions.png")
    return True


def write_outputs(summaries, rows):
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    payload = dict(
        status="pass",
        verification_level="independent formula arithmetic and fixed-step illustrative integration; not MATLAB execution",
        source_contract="thesis Lemma 3.6, Remarks 3.7-3.9, Theorem 3.10; M0 notation contract",
        cases=summaries, branches=rows,
        assertions=[
            "Cases 1-4 have det(A_j1j2)>0 for all four double-active branches.",
            "Case 5 has det(A_j1j2)<0 for all four branches.",
            "Case 5 has at least one positive-eigenvalue ray inside its selected active cone.",
            "Every four-line arrangement is in general position (no axes, parallels, or triple intersections).",
            "The two same-agent BR intersections are outside the Nash set (Assumption 3 geometry).",
            "Complex branches are reported as rotations and are not assigned real eigenvectors.",
        ])
    OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    with OUT_CSV.open("w", newline="", encoding="utf-8") as f:
        fields = ["case", "j1", "j2", "matrix", "determinant", "eigenvalues", "eigenvectors",
                  "eigenrays_in_active_cone", "cone_start_deg", "cone_angle_deg", "transition", "xstar"]
        writer = csv.DictWriter(f, fields, lineterminator="\n"); writer.writeheader()
        for row in rows:
            writer.writerow({k: json.dumps(row[k], separators=(",", ":")) if isinstance(row[k], (list, dict)) else row[k] for k in fields})
    rendered = render_overview(summaries, rows)
    rendered = render_transition(rows) and rendered
    return rendered


if __name__ == "__main__":
    summaries_, rows_ = analyze()
    rendered_ = write_outputs(summaries_, rows_)
    print(f"S1 algebra checks passed: {len(summaries_)} cases, {len(rows_)} branches")
    print(f"Evidence figures rendered: {rendered_}")
