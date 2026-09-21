#!/usr/bin/env python3
"""Independent arithmetic, integration, witness search, and rendering for P1.

This does not call MATLAB. The first three games have an exact continuous-time
solution and exact rate signs. The source-labelled trap uses deterministic RK4
sampling; its weak-property margin is therefore finite-grid evidence, not a
continuous-time proof.
"""

from __future__ import annotations

import csv
import argparse
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIG = ROOT / "results" / "p1" / "independent"
OUT_JSON = ROOT / "verification" / "p1_checks.json"
OUT_CSV = ROOT / "verification" / "reference-results" / "p1_diagnostics.csv"
ORDER = ["J_1^1", "J_2^1", "J_1^2", "J_2^2"]


def configure_outputs() -> None:
    global FIG, OUT_JSON, OUT_CSV
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
    out = args.output_dir or (ROOT / "results" / "verification" / "p1")
    FIG = out / "figures"
    OUT_JSON = out / "p1_checks.json"
    OUT_CSV = out / "p1_diagnostics.csv"


def common_game(name, ext, prop):
    return dict(
        name=name,
        source="new P1 construction; not a literal Fig. 4.3 transcription",
        A=[[[-1, 0], [0, 0]], [[-1, 0], [0, 0]],
           [[0, 0], [0, -1]], [[0, 0], [0, -1]]],
        b=[[2, ext[0]], [4, ext[1]], [ext[2], -1], [ext[3], 1]],
        c=[0, 0, 0, 0], alpha=[1, 1, 1, 1], x0=[0, 3],
        T=5.0, rule="nearest-BR", prop=prop,
    )


GAMES = [
    common_game("nonweak", [5, 6, -7, -6], "weak"),
    common_game("all-payoff-nondecreasing", [0, 0, 0, 0], "all"),
    common_game("weak-not-all", [3, -4, 5, -3], "weak"),
    dict(
        name="weak-Pareto-trap",
        source=("actual legacy trap.m arrays and scaled-own-gradient helper; "
                "the executable's zero constants are retained"),
        A=[[[-2, 1], [1, -3]], [[-2, -1], [-1, -10]],
           [[-4, 1], [1, -4]], [[-5, -1], [-1, -2]]],
        b=[[5, -5], [20, 124], [90, 0], [72, 0]],
        c=[0, 0, 0, 0], alpha=[1, 1.2, 1, 2],
        x0=[18.5, -8.71], T=4.0, rule="scaled-own-gradient", prop="weak",
    ),
]


def matvec(a, x):
    return [a[0][0] * x[0] + a[0][1] * x[1],
            a[1][0] * x[0] + a[1][1] * x[1]]


def gradients(g, x):
    full = []
    for a, b in zip(g["A"], g["b"]):
        y = matvec(a, x)
        full.append([y[0] + b[0], y[1] + b[1]])
    own = [full[0][0], full[1][0], full[2][1], full[3][1]]
    return full, own


def rhs(g, x):
    _, own = gradients(g, x)
    f = [0.0, 0.0]
    for agent, (p, q) in enumerate(((0, 1), (2, 3))):
        if own[p] * own[q] <= 0:
            continue
        if g["rule"] == "nearest-BR":
            metric = [abs(own[p] / g["A"][p][agent][agent]),
                      abs(own[q] / g["A"][q][agent][agent])]
        else:
            metric = [abs(g["alpha"][p] * own[p]),
                      abs(g["alpha"][q] * own[q])]
        selected = p if metric[0] <= metric[1] else q
        f[agent] = g["alpha"][selected] * own[selected]
    return f


def payoff(g, x):
    out = []
    for a, b, c in zip(g["A"], g["b"], g["c"]):
        ax = matvec(a, x)
        out.append(.5 * (x[0] * ax[0] + x[1] * ax[1]) +
                   b[0] * x[0] + b[1] * x[1] + c)
    return out


def diagnostic(g, x):
    f = rhs(g, x)
    full, own_gradient = gradients(g, x)
    total, own, ext = [], [], []
    for j in range(4):
        owner = 0 if j < 2 else 1
        total.append(full[j][0] * f[0] + full[j][1] * f[1])
        own.append(own_gradient[j] * f[owner])
        ext.append(total[-1] - own[-1])
    if g["prop"] == "all":
        gamma, omega = min(ext), min(total)
    else:
        gamma = min(max(ext[:2]), max(ext[2:]))
        omega = min(max(total[:2]), max(total[2:]))
    return dict(f=f, payoff=payoff(g, x), total=total, own=own, ext=ext,
                gamma=gamma, omega=omega)


def integrate(g, dt=.001):
    n = round(g["T"] / dt)
    ts = [i * dt for i in range(n + 1)]
    if g["name"] != "weak-Pareto-trap":
        xs = [[2 * (1 - math.exp(-t)), 1 + 2 * math.exp(-t)] for t in ts]
    else:
        x = list(g["x0"]); xs = [x[:]]
        for _ in range(n):
            k1 = rhs(g, x)
            k2 = rhs(g, [x[i] + dt * k1[i] / 2 for i in range(2)])
            k3 = rhs(g, [x[i] + dt * k2[i] / 2 for i in range(2)])
            k4 = rhs(g, [x[i] + dt * k3[i] for i in range(2)])
            x = [x[i] + dt * (k1[i] + 2*k2[i] + 2*k3[i] + k4[i]) / 6 for i in range(2)]
            xs.append(x)
    return ts, xs, [diagnostic(g, x) for x in xs]


def find_witness(ts, ds, min_t1=.02, max_t2=3.9):
    values = [d["payoff"][2:4] for d in ds]
    first = next(i for i, t in enumerate(ts) if t >= min_t1)
    last = max(i for i, t in enumerate(ts) if t <= max_t2)
    best = None
    for i in range(first, last):
        for j in range(i + 1, last + 1):
            delta = [values[j][q] - values[i][q] for q in range(2)]
            score = min(-delta[0], -delta[1])
            if score > 0 and (best is None or score > best[0]):
                best = (score, i, j, delta)
    assert best is not None
    _, i, j, delta = best
    return dict(t1=ts[i], t2=ts[j], payoff_t1=values[i], payoff_t2=values[j],
                delta=delta, minimum_drop=best[0], indices=[i, j])


def extrema(ds, key):
    return [min(d[key][j] for d in ds) for j in range(4)]


def analyze():
    runs, summaries = [], []
    for g in GAMES:
        ts, xs, ds = integrate(g)
        weak_margin = [min(max(d["total"][:2]) for d in ds),
                       min(max(d["total"][2:]) for d in ds)]
        item = dict(name=g["name"], source=g["source"], rule=g["rule"],
                    A=g["A"], b=g["b"], c=g["c"], alpha=g["alpha"], x0=g["x0"],
                    t_final=g["T"], min_total_rate=extrema(ds, "total"),
                    min_own_contribution=extrema(ds, "own"),
                    min_externality=extrema(ds, "ext"),
                    min_weak_margin_by_agent=weak_margin,
                    min_gamma_metric=min(d["gamma"] for d in ds),
                    min_omega_metric=min(d["omega"] for d in ds))
        summaries.append(item); runs.append((g, ts, xs, ds))

    # Exact, continuous-time certificates for z=exp(-t), z in (0,1].
    assert all(v < 0 for v in summaries[0]["min_total_rate"])
    assert all(v >= -1e-12 for v in summaries[1]["min_total_rate"])
    assert summaries[2]["min_total_rate"][0] < 0 and summaries[2]["min_total_rate"][3] < 0
    assert all(v >= -1e-12 for v in summaries[2]["min_weak_margin_by_agent"])
    assert all(v >= -1e-12 for v in summaries[3]["min_weak_margin_by_agent"])
    witness = find_witness(runs[3][1], runs[3][3])
    summaries[3]["trap_witness"] = witness
    return runs, summaries


def fonts():
    from PIL import ImageFont
    try:
        return (ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 31),
                ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 19),
                ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 15))
    except OSError:
        f = ImageFont.load_default(); return f, f, f


COLORS = [(190, 35, 45), (232, 130, 30), (30, 105, 180), (65, 155, 110)]


def panel(draw, box, title, xlim, ylim, titlefont, small):
    x0, y0, x1, y1 = box
    draw.rounded_rectangle(box, radius=10, fill=(249, 250, 252), outline=(188, 193, 202), width=2)
    plot = (x0 + 55, y0 + 48, x1 - 18, y1 - 42)
    draw.text((x0 + 14, y0 + 12), title, fill=(28, 34, 44), font=small)
    for k in range(5):
        px = plot[0] + k * (plot[2] - plot[0]) / 4
        py = plot[1] + k * (plot[3] - plot[1]) / 4
        draw.line((px, plot[1], px, plot[3]), fill=(225, 229, 235), width=1)
        draw.line((plot[0], py, plot[2], py), fill=(225, 229, 235), width=1)
    draw.rectangle(plot, outline=(90, 98, 110), width=2)
    def mp(p):
        return (plot[0] + (p[0]-xlim[0])/(xlim[1]-xlim[0])*(plot[2]-plot[0]),
                plot[3] - (p[1]-ylim[0])/(ylim[1]-ylim[0])*(plot[3]-plot[1]))
    if ylim[0] <= 0 <= ylim[1]:
        y = mp((xlim[0], 0))[1]; draw.line((plot[0], y, plot[2], y), fill=(65,65,70), width=1)
    return plot, mp


def polyline(draw, points, color, width=3):
    if len(points) > 1: draw.line([tuple(p) for p in points], fill=color, width=width)


def sampled(points, maxn=900):
    step = max(1, len(points)//maxn); return points[::step]


def render_three(runs):
    from PIL import Image, ImageDraw
    titlefont, font, small = fonts(); W,H=1680,1120
    im=Image.new("RGB",(W,H),"white"); d=ImageDraw.Draw(im,"RGBA")
    d.text((40,24),"P1 - Three distinct payoff properties",fill=(22,28,38),font=titlefont)
    d.text((40,63),"orange: Gamma-certificate failure   red: Omega-property failure   payoff order: J11, J12, J21, J22",fill=(65,72,82),font=small)
    labels=["1  nonweak: both objectives fall","2  all objectives nondecreasing","3  weak, but not all objectives"]
    for row,(g,ts,xs,ds) in enumerate(runs[:3]):
        y=95+row*335
        # phase
        _,mp=panel(d,(35,y,550,y+310),labels[row]+" - phase",(-.5,2.6),(.5,3.5),font,small)
        for ix in range(55):
            for iy in range(55):
                x=-.5+(ix+.5)*3.1/55; yy=.5+(iy+.5)*3/55; dd=diagnostic(g,[x,yy])
                gamma_bad=dd["gamma"] < -1e-10; omega_bad=dd["omega"] < -1e-10
                if gamma_bad or omega_bad:
                    p0=mp((x-3.1/110,yy-3/110));p1=mp((x+3.1/110,yy+3/110))
                    d.rectangle((p0[0],p1[1],p1[0],p0[1]),fill=(190,35,45,80) if omega_bad else (232,135,35,50))
        for q in (2,4):
            p=mp((q,.5)); d.line((p[0],mp((q,3.5))[1],p[0],mp((q,.5))[1]),fill=(45,105,185,100),width=2)
        for q in (-1,1):
            p=mp((-.5,q)); d.line((mp((-.5,q))[0],p[1],mp((2.6,q))[0],p[1]),fill=(115,55,165,100),width=2)
        polyline(d,[mp(x) for x in sampled(xs)],(25,28,35),4); p0=mp(xs[0]); d.ellipse((p0[0]-5,p0[1]-5,p0[0]+5,p0[1]+5),fill=(20,20,20))
        note=("Gamma weak fails; Omega weak fails" if row==0 else
              "Gamma all = Omega all = whole plane" if row==1 else
              "Gamma weak = Omega weak = whole plane")
        d.text((58,y+273),note,fill=(125,55,25) if row==0 else (35,105,70),font=small)
        # payoff change
        vals=[[dd["payoff"][j]-ds[0]["payoff"][j] for dd in ds] for j in range(4)]
        lo=min(min(v) for v in vals); hi=max(max(v) for v in vals); pad=max((hi-lo)*.08,.2)
        _,mp=panel(d,(575,y,1115,y+310),"payoff changes",(0,g["T"]),(lo-pad,hi+pad),font,small)
        for j,v in enumerate(vals): polyline(d,[mp(p) for p in sampled(list(zip(ts,v)))],COLORS[j],3)
        # rates
        rates=[[dd["total"][j] for dd in ds] for j in range(4)]
        lo=min(min(v) for v in rates); hi=max(max(v) for v in rates); pad=max((hi-lo)*.08,.2)
        _,mp=panel(d,(1140,y,1660,y+310),"total derivatives dJ/dt",(0,g["T"]),(lo-pad,hi+pad),font,small)
        for j,v in enumerate(rates): polyline(d,[mp(p) for p in sampled(list(zip(ts,v)))],COLORS[j],3)
    for j,label in enumerate(ORDER): d.text((1160+j*118,76),label,fill=COLORS[j],font=small)
    FIG.mkdir(parents=True,exist_ok=True); im.save(FIG/"P1_three_payoff_properties.png")


def render_decomposition(runs):
    from PIL import Image, ImageDraw
    titlefont,font,small=fonts();W,H=1680,1080
    im=Image.new("RGB",(W,H),"white");d=ImageDraw.Draw(im,"RGBA")
    d.text((40,24),"P1 - Total rate = own contribution + externality",fill=(22,28,38),font=titlefont)
    for row,(g,ts,xs,ds) in enumerate(runs[:3]):
        for agent in range(2):
            ids=range(2*agent,2*agent+2); y=85+row*325; x=35+agent*825
            series=[]
            for key in ("total","own","ext"):
                for j in ids: series.append([dd[key][j] for dd in ds])
            lo=min(min(v) for v in series);hi=max(max(v) for v in series);pad=max((hi-lo)*.08,.3)
            _,mp=panel(d,(x,y,x+790,y+295),f"{g['name']} - agent {agent+1}",(0,g["T"]),(lo-pad,hi+pad),font,small)
            styles=[(COLORS[2*agent],4),(COLORS[2*agent+1],4),(COLORS[2*agent],2),(COLORS[2*agent+1],2),(120,120,120,255),(70,70,70,255)]
            for q,v in enumerate(series):
                color=styles[q] if isinstance(styles[q],tuple) and len(styles[q])==4 else styles[q][0]
                width=2 if q>=2 else 4
                polyline(d,[mp(p) for p in sampled(list(zip(ts,v)))],color,width)
            d.text((x+18,y+259),"thick=total; thin color=own; gray=externality",fill=(70,75,85),font=small)
    FIG.mkdir(parents=True,exist_ok=True);im.save(FIG/"P1_rate_decomposition.png")


def render_trap(run, witness):
    from PIL import Image, ImageDraw
    titlefont,font,small=fonts();g,ts,xs,ds=run;W,H=1680,610
    im=Image.new("RGB",(W,H),"white");d=ImageDraw.Draw(im,"RGBA")
    d.text((40,24),"P1 - Independent weak Pareto trap (actual legacy execution rule)",fill=(22,28,38),font=titlefont)
    # phase with bad-region grid for agent 2
    _,mp=panel(d,(35,85,570,570),"phase: orange = Gamma2 fail; red = Omega2 fail",(12,22),(-12,-2),font,small)
    for ix in range(70):
        for iy in range(70):
            x=12+(ix+.5)*10/70;y=-12+(iy+.5)*10/70;dd=diagnostic(g,[x,y])
            ext_bad=max(dd["ext"][2:])<0;total_bad=max(dd["total"][2:])<0
            if ext_bad or total_bad:
                p0=mp((x-5/70,y-5/70));p1=mp((x+5/70,y+5/70));
                d.rectangle((p0[0],p1[1],p1[0],p0[1]),fill=(190,35,45,85) if total_bad else (232,135,35,55))
    for j,color in enumerate(COLORS):
        agent=0 if j<2 else 1; row=g["A"][j][agent]; own_b=g["b"][j][agent]; pts=[]
        for q in range(201):
            x=12+10*q/200
            if abs(row[1])>1e-12:
                y=-(row[0]*x+own_b)/row[1]
                if -12<=y<=-2: pts.append(mp((x,y)))
        polyline(d,pts,color,2)
    polyline(d,[mp(x) for x in sampled(xs)],(20,25,35),5)
    for idx,color in zip(witness["indices"],((20,20,20),(210,30,40))):
        p=mp(xs[idx]);d.ellipse((p[0]-7,p[1]-7,p[0]+7,p[1]+7),fill=color)
    # payoffs
    base=witness["payoff_t1"]
    vals=[[dd["payoff"][j]-base[q] for dd in ds] for q,j in enumerate((2,3))];lo=min(min(v) for v in vals);hi=max(max(v) for v in vals)
    _,mp2=panel(d,(595,85,1125,570),f"agent 2 payoff changes from t1={witness['t1']:.3f}; t2={witness['t2']:.3f}",(0,4),(lo-2,hi+2),font,small)
    for q,v in enumerate(vals):polyline(d,[mp2(p) for p in sampled(list(zip(ts,v)))],COLORS[q+2],4)
    for idx,color in zip(witness["indices"],((20,20,20),(210,30,40))):
        for q in range(2):
            p=mp2((ts[idx],vals[q][idx]));d.ellipse((p[0]-6,p[1]-6,p[0]+6,p[1]+6),fill=color)
    # rates
    series=[]
    for key in ("total","own","ext"):
        for j in (2,3):series.append([dd[key][j] for dd in ds])
    lo=min(min(v) for v in series);hi=max(max(v) for v in series);pad=.05*(hi-lo)
    _,mp3=panel(d,(1150,85,1655,570),"agent 2: total / own / externality",(0,4),(lo-pad,hi+pad),font,small)
    cs=[COLORS[2],COLORS[3],(60,105,170),(60,150,105),(125,125,125),(70,70,70)]
    for q,v in enumerate(series):polyline(d,[mp3(p) for p in sampled(list(zip(ts,v)))],cs[q],4 if q<2 else 2)
    d.text((620,532),f"Delta J2 = [{witness['delta'][0]:.6f}, {witness['delta'][1]:.6f}]",fill=(155,35,40),font=font)
    FIG.mkdir(parents=True,exist_ok=True);im.save(FIG/"P1_weak_pareto_trap.png")


def write_outputs(runs, summaries):
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    witness=summaries[3]["trap_witness"]
    payload=dict(
        status="pass",
        payoff_order=ORDER,
        gamma="externality >= 0; weak metric is min_i max_j externality, all metric is min_ij externality",
        omega="total payoff rate >= 0 with the analogous weak/all metrics",
        verification_levels={
            "three_property_games":"exact trajectory and exact rate-sign algebra, plus sampled plots",
            "trap":"actual legacy parameters/rule; fixed-step RK4 and finite grid, not continuous-time proof",
        },
        exact_certificates={
            "state":"z=exp(-t); x1=2(1-z), x2=1+2z, f=(2z,-2z)",
            "own":"[4z^2,4z+4z^2,4z+4z^2,4z^2]",
            "nonweak_total":"[4z^2-10z,4z^2-8z,4z^2-10z,4z^2-12z] < 0 for z in (0,1]",
            "all_total":"own >= 0",
            "weak_total":"[4z^2-6z,4z^2+12z,4z^2+14z,4z^2-6z]; one positive objective per agent",
        },
        cases=summaries,
    )
    OUT_JSON.write_text(json.dumps(payload,indent=2,sort_keys=True)+"\n",encoding="utf-8")
    with OUT_CSV.open("w",newline="",encoding="utf-8") as f:
        fields=["case","rule","min_dJ11","min_dJ12","min_dJ21","min_dJ22","min_weak_agent1","min_weak_agent2","min_gamma_metric","min_omega_metric"]
        w=csv.DictWriter(f,fields,lineterminator="\n");w.writeheader()
        for s in summaries:
            row=dict(case=s["name"],rule=s["rule"],min_gamma_metric=s["min_gamma_metric"],min_omega_metric=s["min_omega_metric"])
            for key,val in zip(fields[2:6],s["min_total_rate"]):row[key]=val
            row["min_weak_agent1"],row["min_weak_agent2"]=s["min_weak_margin_by_agent"]
            w.writerow(row)
    render_three(runs);render_decomposition(runs);render_trap(runs[3],witness)


if __name__ == "__main__":
    configure_outputs()
    runs_,summaries_=analyze();write_outputs(runs_,summaries_)
    w=summaries_[3]["trap_witness"]
    print("P1 checks passed: 3 analytically solved property games + actual-rule trap")
    print(f"Interior trap witness t1={w['t1']:.3f} < t2={w['t2']:.3f}; delta={w['delta']}")
