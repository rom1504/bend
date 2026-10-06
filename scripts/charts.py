#!/usr/bin/env python3
"""Render the recorded Bend measurements; --check needs only the standard library."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "site" / "charts"
INPUTS = ("history-research.json", "conformance-research.json", "runtime-research.json",
          "runtime-average-research.json", "compilation-average-research.json",
          "second-stage-research.json")
NAMES = ("simplicity", "compilation", "conformance", "runtime-gains", "runtime-gaps",
         "runtime-average-history", "runtime-programs", "compilation-average-history",
         "compilation-programs", "second-stage-average-history", "second-stage-programs",
         "second-stage-self-emission")
INK = "#202d29"
MUTED = "#586660"
PAPER = "#f6f7f2"
GREEN = "#245f43"
TEAL = "#2b7f85"
ORANGE = "#a3692d"
BLUE = "#426ba0"
GRID = "#dce3da"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check() -> int:
    manifest_path = DEST / "manifest.json"
    if not manifest_path.exists():
        print("Chart manifest missing; run python3 scripts/charts.py", file=sys.stderr)
        return 1
    manifest = json.loads(manifest_path.read_text())
    errors = []
    for group, base in (("inputs", ROOT), ("outputs", DEST)):
        for name, expected in manifest[group].items():
            path = base / name
            if not path.is_file() or digest(path) != expected:
                errors.append(str(path.relative_to(ROOT)))
    if errors:
        print("Chart inputs or outputs changed; regenerate charts: " + ", ".join(errors), file=sys.stderr)
        return 1
    print(f"All {len(NAMES)} charts match their recorded inputs and generated files.")
    return 0


def configure():
    # Never create a cache in the active compiler checkout or in the user's home.
    os.environ.setdefault("MPLCONFIGDIR", "/tmp/bend-progress-matplotlib")
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    matplotlib.rcParams.update({
        "font.family": "DejaVu Sans",
        "font.size": 13,
        "text.color": INK,
        "axes.labelcolor": MUTED,
        "axes.edgecolor": GRID,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "axes.spines.left": False,
        "axes.spines.bottom": False,
        "xtick.color": MUTED,
        "ytick.color": MUTED,
        "xtick.major.size": 0,
        "ytick.major.size": 0,
        "xtick.major.pad": 9,
        "ytick.major.pad": 9,
        "axes.axisbelow": True,
        "grid.color": GRID,
        "grid.linewidth": 0.8,
        "figure.facecolor": "none",
        "axes.facecolor": "none",
        "savefig.facecolor": "none",
        "svg.fonttype": "none",
        "svg.hashsalt": "bend-progress-charts-v1",
    })
    return plt


def save(plt, fig, name: str, description: str):
    metadata = {
        "Title": name.replace("-", " ").title(),
        "Description": description,
        "Creator": "Bend Progress chart renderer",
        "Date": "2026-10-06",
    }
    fig.savefig(DEST / f"{name}.svg", metadata=metadata, transparent=True)
    fig.savefig(DEST / f"{name}.png", dpi=160, transparent=False, facecolor=PAPER,
                metadata={"Title": metadata["Title"], "Description": description,
                          "Software": "Bend Progress chart renderer"})
    plt.close(fig)


def line_axes(plt, height=5.6):
    fig, ax = plt.subplots(figsize=(9, height))
    fig.subplots_adjust(left=.11, right=.96, top=.87, bottom=.18)
    ax.grid(axis="y")
    return fig, ax


def note(fig, text: str, y=.96, color=MUTED, size=13):
    fig.text(.11, y, text, color=color, fontsize=size, va="top")


def simplicity(plt, data):
    from matplotlib.ticker import FuncFormatter
    points = data["simplicity"]["series"]
    fig, ax = line_axes(plt)
    fig.subplots_adjust(bottom=.25)
    xs = list(range(len(points)))
    ax.axvspan(1, 3, color="#eaf0e7", linewidth=0)
    ax.plot(xs, [p["physicalLines"] for p in points], color=GREEN,
            linewidth=2.8, marker="o", markersize=5.5, label="Physical lines")
    # A missing count is a gap, never an invented value or a connecting segment.
    ax.plot(xs, [p.get("nonblankLines") or float("nan") for p in points], color=TEAL,
            linewidth=2.5, marker="o", markersize=4.5, label="Nonblank lines")
    ax.plot(xs, [p.get("codeLines") or float("nan") for p in points], color=BLUE,
            linewidth=2.5, marker="o", markersize=4.5, label="Code lines · excludes comments")
    upper = math.ceil(max(p["physicalLines"] for p in points) / 5000) * 5000 + 1000
    ax.set_ylim(0, upper)
    ax.set_xlim(-.2, len(points) - .5)
    ax.set_yticks(range(0, upper, 5000))
    ax.yaxis.set_major_formatter(FuncFormatter(lambda n, _: f"{n:,.0f}"))
    tick_indices = sorted(set([0, 3, 6, 10, *range(13, len(points), 3), len(points) - 1]))
    tick_indices = [i for i in tick_indices if i < len(points)]
    ax.set_xticks(tick_indices, [points[i]["chartLabel"].replace(" / ", "\n") for i in tick_indices])
    ax.set_xlabel("Recorded development milestones", labelpad=10)
    note(fig, "Compiler source size · three distinct line counts")
    ax.annotate(f"{points[0]['physicalLines']:,}", (0, points[0]["physicalLines"]),
                xytext=(0, 18000), fontsize=13, color=GREEN,
                arrowprops={"arrowstyle": "-", "color": GREEN, "linewidth": 1})
    ax.annotate(f"{points[-1]['physicalLines']:,}", (xs[-1], points[-1]["physicalLines"]),
                xytext=(-3, 13), textcoords="offset points", ha="right",
                fontsize=15, fontweight="bold", color=GREEN)
    if points[-1].get("codeLines"):
        ax.annotate(f"{points[-1]['codeLines']:,}", (xs[-1], points[-1]["codeLines"]),
                    xytext=(-3, -22), textcoords="offset points", ha="right",
                    fontsize=14, fontweight="bold", color=BLUE)
    latest_nonblank = next((i for i in reversed(xs) if points[i].get("nonblankLines")), None)
    if latest_nonblank is not None:
        count_label = f"{points[latest_nonblank]['nonblankLines']:,}"
        if latest_nonblank != xs[-1]:
            count_label += f"\n(last counted {points[latest_nonblank]['chartLabel']})"
        ax.annotate(count_label,
                    (latest_nonblank, points[latest_nonblank]["nonblankLines"]),
                    xytext=(20, -32), textcoords="offset points", ha="left", va="top",
                    arrowprops={"arrowstyle": "-", "color": TEAL, "linewidth": 1},
                    fontsize=12, fontweight="bold", color=TEAL)
    ax.annotate("Cleanup\n−1,842 physical lines", (3, 14667), xytext=(1.1, 7600),
                arrowprops={"arrowstyle": "-", "color": GREEN, "linewidth": 1},
                color=GREEN, fontsize=13, linespacing=1.5)
    ax.text(7.1, 5100, "Later work adds\ncoverage and optimizations", fontsize=13,
            color=MUTED, linespacing=1.5)
    handles, labels = ax.get_legend_handles_labels()
    fig.legend(handles, labels, loc="lower left", bbox_to_anchor=(.07, .001), ncol=3,
               frameon=False, fontsize=10.5, handlelength=1.7, columnspacing=1.6)
    save(plt, fig, "simplicity",
         f"Physical, historical nonblank and later nonblank/noncomment source lines across {len(points)} snapshots, on a zero-based "
         "axis. Dedicated consolidation removes 1842 physical lines from Phase5 to Phase7. Later "
         f"coverage and performance work increases source size to {points[-1]['physicalLines']} physical "
         "lines. Nonblank and code-line series are distinct and missing counts are left unplotted. Source size is a proxy, not a complete measure of simplicity.")


def compilation(plt, data):
    points = data["compilerChecking"]["selectedPairs"]
    fig, ax = plt.subplots(figsize=(9, 5.6))
    fig.subplots_adjust(left=.13, right=.96, top=.86, bottom=.19)
    reductions = [100 * (1 - p["bend_process_seconds"] / p["same_window_predecessor_seconds"])
                  for p in points]
    ax.barh(range(len(points)), reductions, height=.27, color=GREEN)
    for i, (p, value) in enumerate(zip(points, reductions)):
        ax.text(value + 1.2, i, f"−{value:.1f}%", va="center", color=GREEN,
                fontsize=14, fontweight="bold")
        ax.text(0, i + .30,
                f"{p['same_window_predecessor_seconds']:.3f} → {p['bend_process_seconds']:.3f} s",
                va="center", fontsize=13, color=MUTED)
    ax.set_yticks(range(len(points)), [p["label"] for p in points])
    ax.set_ylim(len(points) - .40, -.6)
    ax.set_xlim(0, 84)
    ax.set_xticks([0, 20, 40, 60, 80], ["0%", "20%", "40%", "60%", "80%"])
    ax.set_xlabel("Process time saved vs. paired baseline", labelpad=12)
    ax.grid(axis="x")
    note(fig, "Compiler-source checking · before → after seconds")
    fig.text(.13, .04, "Same-window pairs; checking only, without code emission.",
             fontsize=12, color=MUTED)
    save(plt, fig, "compilation",
         "Five separate, same-window compiler-source checking improvements. Horizontal bars show "
         "the percent of process time saved, with before and after seconds printed beside each pair. "
         "Each phase has its own source and measurement window. These gains are not a cumulative series.")


def conformance(plt, data):
    from matplotlib.ticker import FuncFormatter
    from matplotlib.lines import Line2D
    semantic = data["independentSemanticSeries"]
    fig = plt.figure(figsize=(9, 11))
    ax = fig.add_axes((.11, .62, .84, .23))
    semantic_ax = fig.add_axes((.25, .15, .70, .29))
    ax.grid(axis="y")
    colors = (BLUE, TEAL, GREEN)
    for segment, color in zip(data["segments"], colors):
        points = segment["points"]
        xs = [p["phase"] for p in points]
        ys = [100 * p["exact"] / p["total"] for p in points]
        ax.plot(xs, ys, color=color, linewidth=2.8, marker="o", markersize=6,
                markeredgecolor=PAPER, markeredgewidth=1.2, zorder=3)
    for x in (7.5, 22.5):
        ax.axvline(x, color=GRID, linewidth=1.5, linestyle=(0, (3, 4)))
    ax.axhline(100, color=GREEN, alpha=.32, linewidth=1)
    ax.set_ylim(70, 104)
    last_point = data["segments"][-1]["points"][-1]
    last_phase = last_point["phase"]
    ax.set_xlim(2, last_phase + 1)
    ax.set_yticks([70, 80, 90, 100])
    ax.yaxis.set_major_formatter(FuncFormatter(lambda n, _: f"{n:g}%"))
    phases = sorted(set([3, 8, 16, 22, 28, 36, last_phase]))
    ax.set_xticks(phases, [f"P{phase}" for phase in phases])
    ax.set_xlabel("Development phase", labelpad=12)
    fig.text(.11, .977, "Conformance · two distinct test suites", fontsize=18,
             fontweight="bold", va="top")
    fig.text(.11, .935, "HISTORICAL · Exact frontend agreement", fontsize=14,
             fontweight="bold", va="top")
    fig.text(.11, .903, f"Last full rerun: P{last_phase} · {last_point['total']:,} main observations · axis starts at 70%",
             fontsize=12, color=MUTED, va="top")
    ax.annotate("79.7%", (3, 2196 / 2756 * 100), xytext=(0, -24),
                textcoords="offset points", fontsize=13, color=BLUE, ha="left")
    ax.annotate("New target", (8, 2262 / 2996 * 100), xytext=(5, -27),
                textcoords="offset points", fontsize=12, color=TEAL)
    ax.annotate("2 differences", (16, 2994 / 2996 * 100), xytext=(-14, -29),
                textcoords="offset points", fontsize=12, color=TEAL, ha="center")
    ax.annotate(f"{last_point['exact']:,} / {last_point['total']:,}",
                (last_phase, last_point['exact'] / last_point['total'] * 100), xytext=(0, -29),
                textcoords="offset points", fontsize=14, fontweight="bold", color=GREEN, ha="right")
    # Each target is a distinct series. No line crosses a changed denominator.
    for x, segment, color in zip((.11, .40, .69), data["segments"], colors):
        fig.text(x, .542, f"● {segment['id']}  ({segment['total']:,})", fontsize=11, color=color)
    fig.add_artist(Line2D([.11, .95], [.52, .52], transform=fig.transFigure,
                         color=GRID, linewidth=1.2))
    fig.text(.11, .497, "INDEPENDENT · Runtime semantics", fontsize=14,
             fontweight="bold", va="top")
    latest = semantic[-1]
    fig.text(.11, .467, f"Same {latest['total']} source-oracle scenarios · {latest['fixtures']} fixtures · each image tested separately",
             fontsize=11.5, color=MUTED, va="top")
    totals = [p["total"] for p in semantic]
    passed = [p["pass"] for p in semantic]
    semantic_ax.barh(range(len(semantic)), totals, height=.48, color=ORANGE)
    semantic_ax.barh(range(len(semantic)), passed, height=.48,
                     color=[GREEN if p['pass'] == p['total'] else TEAL for p in semantic])
    for i, p in enumerate(semantic):
        semantic_ax.text(p["pass"] - 3, i, f"{p['pass']} / {p['total']}",
                         ha="right", va="center", color=PAPER, fontsize=15, fontweight="bold")
    image_labels = ["B1 + B2" if p.get("alsoQualifiedCompilerImages") else
                    "B2" if p.get("compilerImage") == "directB2" else "B1" for p in semantic]
    semantic_ax.set_yticks(range(len(semantic)),
                          [f"P{p['phase']} · {role}" for p, role in zip(semantic, image_labels)],
                          fontsize=12)
    semantic_ax.set_ylim(len(semantic) - .45, -.55)
    semantic_ax.set_xlim(0, max(totals) * 1.02)
    semantic_ax.set_xticks([0, 24, 48, 72, 96])
    semantic_ax.grid(axis="x")
    semantic_ax.set_xlabel("Passing independently specified scenarios", fontsize=12, labelpad=11)
    fig.text(.11, .063, "P53 repaired one NaN case. Both P58 images pass 96/96 each; TypeScript stays 95/96.",
             fontsize=10.5, color=GREEN)
    fig.text(.11, .033, "B1 = installed checked compiler · B2 = separately self-emitted compiler",
             fontsize=10.5, color=MUTED)
    save(plt, fig, "conformance",
         "Exact parse/check agreement across selected recorded milestones. Three disconnected "
         "series use distinct pinned upstream targets and denominators. Vertical axis starts "
         f"at 70 percent. Fresh frontend evidence ends at Phase{last_phase}, with 3026 of 3026 observations. "
         "A separate lower panel shows independent source semantics on the unchanged 96 scenarios: "
         "Phase52 B1 passes 95; Phases53, 54 and 55 B1, Phase56 B2, and both Phase58 B1 and B2 "
         "pass 96 each. TypeScript remains at 95. B2 is separately qualified, not installed. These distinct suites "
         "measure different scopes and must not be combined into one percentage.")


def milliseconds(value):
    if value >= 1000:
        return f"{value:,.1f}"
    if value >= 10:
        return f"{value:.2f}"
    return f"{value:.3f}"


def runtime_gains(plt, data):
    # Original-program examples only; focused diagnostic wins remain in the data.
    points = [p for p in data["pairedGains"] if p["phase"] >= 30]
    labels = {"mandelbrot": "Mandelbrot", "editdist": "Edit distance",
              "symreg": "Symbolic regression", "raytrace": "Ray tracing"}
    fig, ax = plt.subplots(figsize=(9, 6.0))
    fig.subplots_adjust(left=.35, right=.97, top=.85, bottom=.16)
    xs = [p["beforeMs"] / p["afterMs"] for p in points]
    colors = [GREEN if p["phase"] == 36 else TEAL for p in points]
    ax.barh(range(len(points)), [x - 1 for x in xs], left=1, height=.28, color=colors)
    ax.set_xscale("log")
    for i, (p, x, color) in enumerate(zip(points, xs, colors)):
        ax.text(x * 1.12, i, f"{x:.2f}×", va="center", color=color,
                fontsize=14, fontweight="bold")
        ax.text(1, i + .31,
                f"{milliseconds(p['beforeMs'])} → {milliseconds(p['afterMs'])} ms",
                va="center", fontsize=12.5, color=MUTED)
    transitions = [f"P{re.search(r'Phase([0-9]+)', p['baseline']).group(1)}→{p['phase']}"
                   for p in points]
    ax.set_yticks(range(len(points)),
                 [f"{transition} · {labels[p['id']]}"
                  for transition, p in zip(transitions, points)], fontsize=12.5)
    ax.set_ylim(len(points) - .40, -.6)
    ax.set_xlim(1, 230)
    ax.set_xticks([1, 2, 5, 10, 20, 50, 100], ["1×", "2×", "5×", "10×", "20×", "50×", "100×"])
    ax.minorticks_off()
    ax.grid(axis="x")
    ax.set_xlabel("Speedup vs. paired baseline (log scale)", labelpad=12)
    fig.text(.04, .965, "Generated JavaScript · fixed inputs", fontsize=13, color=MUTED, va="top")
    fig.text(.04, .915, "Complete exported calls · before → after milliseconds", fontsize=12.5, color=MUTED, va="top")
    fig.text(.04, .025, "Each row is a separate timing window. Gains are not multiplied.", fontsize=12, color=MUTED)
    save(plt, fig, "runtime-gains",
         "Seven selected original-program runtime gains against same-window predecessor compiler "
         "baselines. Every row names its baseline-to-candidate phase transition, including "
         "Phase32 to Phase35. Generated JavaScript executes fixed inputs. Bars begin at 1x on "
         "a logarithmic speedup axis. Before and after milliseconds "
         "per complete exported call are printed for every row. These examples are not a suite average.")


def runtime_gaps(plt, data):
    points = sorted(data["latest"]["points"], key=lambda p: p["ratioToTypeScript"])
    colors = {"original": ORANGE, "diagnostic": BLUE, "canary": TEAL}
    fig, ax = plt.subplots(figsize=(11, 8.0))
    fig.subplots_adjust(left=.31, right=.94, top=.9, bottom=.14)
    xs = [p["ratioToTypeScript"] for p in points]
    ax.barh(range(len(points)), [x - 1 for x in xs], left=1, height=.46,
            color=[colors[p["category"]] for p in points])
    for i, (p, x) in enumerate(zip(points, xs)):
        ax.text(x * 1.09, i, f"{x:.2f}×", va="center", fontsize=13,
                color=colors[p["category"]], fontweight="bold")
    ax.set_yticks(range(len(points)), [p["label"] for p in points], fontsize=13)
    ax.set_ylim(len(points) - .45, -.75)
    ax.set_xscale("log")
    ax.set_xlim(.92, 160)
    ax.set_xticks([1, 2, 5, 10, 20, 50, 100], ["1×", "2×", "5×", "10×", "20×", "50×", "100×"])
    ax.minorticks_off()
    ax.grid(axis="x")
    ax.axvline(1, color=INK, linewidth=1.2)
    ax.set_xlabel("P36 runtime ÷ TypeScript-emitted runtime (log scale)", labelpad=14)
    fig.text(.055, .973, "Remaining runtime gaps · all 15 maintained points", fontsize=16,
             fontweight="bold", color=INK, va="top")
    fig.text(.055, .932, "Lower is better. 1× means equal execution time in the same measurement window.",
             fontsize=12.5, color=MUTED, va="top")
    for x, category, label in ((.06, "original", "Original programs"),
                               (.34, "diagnostic", "Focused diagnostics"),
                               (.66, "canary", "Small / boundary controls")):
        fig.text(x, .035, f"● {label}", color=colors[category], fontsize=12)
    save(plt, fig, "runtime-gaps",
         "All 15 maintained Phase36 execution points, sorted by candidate median execution time "
         "divided by the same-window TypeScript-emitted program median. A logarithmic axis has a "
         "visible 1x equal-time reference. Lower ratios are better; all recorded points remain "
         "slower than the reference. Original programs, focused diagnostics and boundary controls "
         "have distinct colors.")


def checkpoint_label(point):
    """A phase and commit identify the measurement; dates make chronology visible."""
    date = point.get("date", point.get("commit_date", ""))[:10]
    month_day = date[5:].replace("-", "/")
    return f"P{point['phase']} · {month_day}\n{point['commit'][:7]}"


def speed_history(plt, data, kind):
    """Show ratios on a common scale, connecting only unchanged benchmark cohorts."""
    points = data["history"]
    runtime = kind == "runtime"
    ratio_key = "averageRatio" if runtime else "ratio"
    xs = list(range(len(points)))
    ratios = [point[ratio_key] for point in points]
    fig, ax = line_axes(plt, height=5.9)
    fig.subplots_adjust(left=.10, right=.95, top=.79, bottom=.28)
    ax.axhline(1, color=INK, linewidth=1.25)
    ax.text(0.01, 1, "1× = TypeScript", color=INK, fontsize=12,
            transform=ax.get_yaxis_transform(), va="bottom", ha="left",
            bbox={"facecolor": PAPER, "edgecolor": "none", "pad": 3})
    # Suites expand over time. A gap in the line is deliberately visible.
    segments = []
    for i, point in enumerate(points):
        key = (point.get("suiteId", point.get("cohortKey", point.get("pointCount", 4))),
               point.get("protocolGroup"))
        if not segments or segments[-1][0] != key:
            segments.append((key, []))
        segments[-1][1].append(i)
    for j, (key, indices) in enumerate(segments):
        color = GREEN if j == len(segments) - 1 else (TEAL if j % 2 else BLUE)
        ax.plot(indices, [ratios[i] for i in indices], color=color,
                linewidth=3, marker="o", markersize=8, markeredgecolor=PAPER,
                markeredgewidth=1.5, zorder=4)
        if len(segments) > 1:
            count = points[indices[0]].get("pointCount", points[indices[0]].get("cohortSize"))
            protocol = points[indices[0]].get("protocolGroup", "")
            segment_label = ("Mixed warmup" if protocol.startswith("mixed-") else
                             "Direct JS" if "direct" in protocol else
                             "Legacy JS" if protocol else f"{count} programs")
            ax.text(sum(indices) / len(indices), 1.015, segment_label,
                    transform=ax.get_xaxis_transform(), ha="center", va="bottom",
                    color=color, fontsize=12, fontweight="bold")
        if j:
            ax.axvline(indices[0] - .5, color=GRID, linewidth=1.5, linestyle=(0, (3, 4)))
    label_indices = {0, 2, 4, 7, 9, len(points) - 1} if runtime else set(xs)
    for i, ratio in enumerate(ratios):
        if i not in label_indices:
            continue
        last = i == len(points) - 1
        below = runtime and i in {0, 7}
        ax.annotate(f"{ratio:.2f}×", (i, ratio), xytext=(0, -14 if below else 13),
                    textcoords="offset points", ha="center", va="top" if below else "bottom",
                    fontsize=17 if last else 14, fontweight="bold" if last else "normal",
                    color=GREEN if last else MUTED)
    if runtime:
        ax.set_yscale("log")
        ax.set_ylim(.8, 25)
        ax.set_yticks([1, 2, 5, 10, 20], ["1×", "2×", "5×", "10×", "20×"])
        ax.minorticks_off()
    else:
        upper = max(ratios) * 1.30
        ax.set_ylim(0, max(upper, 4))
    ax.set_xlim(-.35, len(points) - .65 if len(points) > 1 else .65)
    from matplotlib.ticker import FuncFormatter, MaxNLocator
    if not runtime:
        ax.yaxis.set_major_locator(MaxNLocator(nbins=5, min_n_ticks=3))
        ax.yaxis.set_major_formatter(FuncFormatter(lambda value, _: f"{value:g}×"))
    labels = [checkpoint_label(point) for point in points]
    if len(points) > 5:
        labels = [label.replace(" · ", "\n") for label in labels]
    tick_count = min(7, len(points))
    ticks = (sorted({round(i * (len(points) - 1) / max(1, tick_count - 1))
                     for i in range(tick_count)}) if runtime else xs)
    ticks = [i for i in ticks if 0 <= i < len(points)]
    ax.set_xticks(ticks, [labels[i] for i in ticks], fontsize=10.5 if runtime else 12)
    ax.set_ylabel("Time ÷ TypeScript time" + (" · log scale" if runtime else ""), labelpad=10)
    ax.set_xlabel("Release checkpoints · commit date and ID", labelpad=13, fontsize=12)
    fig.text(.10, .966, "Average slowdown vs. TypeScript", fontsize=17, fontweight="bold", va="top")
    subtitle = (f"Same {points[-1]['pointCount']} benchmark cases · geometric mean · lower is better" if runtime else
                "Geometric mean of 4 programs · checks + JS emission · lower is better")
    fig.text(.10, .91, subtitle, fontsize=12.5, color=MUTED, va="top")
    footnote = ("Breaks mark P41’s warmup change and P52’s direct JavaScript contract.\n"
                "Each point uses its campaign’s TypeScript reference; P56 was remeasured in P58." if runtime else
               "Disconnected lines mark different suites; compare changes within each suite." if len(segments) > 1 else
                "Same programs and inputs at every checkpoint; ratios use each report’s TypeScript reference.")
    fig.text(.10, .026, footnote, fontsize=10.5, color=MUTED, linespacing=1.5)
    save(plt, fig, f"{kind}-average-history",
         f"Average {'compiled program execution' if runtime else 'compiler request'} time divided by "
         "TypeScript reference time at recorded release commits. Geometric means give each benchmark "
         f"case equal weight. Lower is better and the 1x TypeScript reference is visible. "
         f"{'Logarithmic axis from 0.8x to 25x. ' if runtime else ''}{footnote} "
         f"Latest recorded average is {ratios[-1]:.4f}x at Phase{points[-1]['phase']}.")


def first_request_axis(ax, points, stage, value_size=14):
    """Keep repeat observations isolated; connect only the fresh old/new pair."""
    from matplotlib.ticker import FuncFormatter, MaxNLocator
    ratios = [p["ratio"] for p in points]
    xs = list(range(len(points)))
    ax.axvspan(len(points) - 2.4, len(points) - .65, color="#eaf0e7", linewidth=0)
    ax.scatter(xs, ratios, c=[TEAL] * (len(points) - 1) + [GREEN], s=72,
               edgecolors=PAPER, linewidths=1.5, zorder=4)
    # The earlier points are new measurements of the same P56 image, not releases.
    ax.plot(xs[-2:], ratios[-2:], color=GREEN, linewidth=2.8, zorder=3)
    ax.text(len(points) - 1.5, .96, "Same-campaign comparison", ha="center", va="top",
            transform=ax.get_xaxis_transform(), color=GREEN, fontsize=10.5)
    for i, ratio in enumerate(ratios):
        ax.annotate(f"{ratio:.2f}×", (i, ratio), xytext=(0, 12),
                    textcoords="offset points", ha="center", va="bottom",
                    fontsize=value_size, fontweight="bold" if i == len(points) - 1 else "normal",
                    color=GREEN if i == len(points) - 1 else MUTED)
    labels = []
    for i, point in enumerate(points):
        phase = point["phase"]
        compiler = point.get("compiler_phase", phase)
        event = "release" if i == 0 else "baseline" if phase != compiler and phase == points[-1]["phase"] else "repeat" if phase != compiler else "selected"
        date = point.get("commit_date", "")[:10][5:].replace("-", "/")
        labels.append(f"P{phase} {event}\nP{compiler} compiler\n{date} · {point['commit'][:7]}")
    ax.set_xticks(xs, labels, fontsize=9.5)
    ax.set_xlim(-.35, len(points) - .65)
    ax.set_ylim(0, max(ratios) * 1.35)
    ax.yaxis.set_major_locator(MaxNLocator(nbins=5, min_n_ticks=4))
    ax.yaxis.set_major_formatter(FuncFormatter(lambda value, _: f"{value:g}×"))
    ax.grid(axis="y")
    ax.axhline(1, color=INK, linewidth=1.25)
    ax.text(.01, 1, "1× = TypeScript", transform=ax.get_yaxis_transform(),
            va="bottom", color=INK, fontsize=10.5,
            bbox={"facecolor": PAPER, "edgecolor": "none", "pad": 2})


def compilation_history(plt, current, history):
    """Keep checking, legacy requests and import-inclusive direct requests separate."""
    from matplotlib.ticker import FuncFormatter
    from matplotlib.lines import Line2D
    earlier = history["compilerChecking"]["series"]
    legacy = [p for p in current["history"] if p.get("backend") != "direct-js"]
    modern = [p for p in current["history"] if p.get("backend") == "direct-js"]
    fig = plt.figure(figsize=(9, 13.2))
    early_ax = fig.add_axes((.11, .708, .84, .155))
    legacy_ax = fig.add_axes((.11, .397, .84, .155))
    modern_ax = fig.add_axes((.11, .105, .84, .155))
    fig.text(.11, .98, "First-stage compilation · B1", fontsize=19, fontweight="bold", va="top")
    fig.text(.11, .946, "Three separate measurement scopes · time ÷ TypeScript time · lower is better",
             fontsize=11.5, color=MUTED, va="top")
    fig.text(.11, .914, "EARLIER · Compiler-source checking", fontsize=14, fontweight="bold", va="top")
    fig.text(.11, .889, "Process time · no emission · changing source snapshots · log scale",
             fontsize=11.5, color=MUTED, va="top")
    phases = [p["phase"] for p in earlier]
    ratios = [p["bend_to_typescript_process_ratio"] for p in earlier]
    selected = {8, 9, 11, 16, 24}
    early_ax.scatter(phases, ratios, s=50, c=[GREEN if p in selected else TEAL for p in phases],
                     edgecolors=PAPER, linewidths=1.2, zorder=4)
    early_ax.set_yscale("log")
    early_ax.set_ylim(1, 100)
    early_ax.set_xlim(min(phases) - .8, max(phases) + .8)
    early_ax.set_yticks([1, 3, 10, 30, 100], ["1×", "3×", "10×", "30×", "100×"])
    early_ax.minorticks_off()
    ticks = [p for p in (8, 9, 11, 14, 16, 19, 21, 23, 24) if p in phases]
    early_ax.set_xticks(ticks, [f"P{p}" for p in ticks], fontsize=10.5)
    early_ax.grid(axis="y")
    early_ax.axhline(1, color=INK, linewidth=1.2)
    for phase, ratio in zip(phases, ratios):
        if phase in selected:
            early_ax.annotate(f"{ratio:.2f}×", (phase, ratio), xytext=(5 if phase == 8 else 0, 9),
                              textcoords="offset points", ha="center", va="bottom",
                              color=GREEN, fontsize=12, fontweight="bold")
    for previous, point in zip(earlier, earlier[1:]):
        if previous["pin"] != point["pin"]:
            boundary = point["phase"] - .5
            early_ax.axvline(boundary, color=GRID, linewidth=1.5, linestyle=(0, (3, 4)))
            early_ax.text(boundary - .25, 65, f"New TS pin\nat P{point['phase']}",
                          ha="right", va="top", color=MUTED, fontsize=10.5)
    fig.text(.11, .665, "Separate release snapshots; dots do not form a matched-source speedup curve.",
             fontsize=10.5, color=MUTED)
    fig.text(.11, .641, f"Bend checking: {earlier[0]['bend_process_seconds']:.3f} s → {earlier[-1]['bend_process_seconds']:.3f} s",
             fontsize=11.5, color=GREEN)
    fig.add_artist(Line2D([.11, .95], [.621, .621], transform=fig.transFigure, color=GRID))
    fig.text(.11, .601, "HISTORICAL · Legacy JavaScript requests", fontsize=14, fontweight="bold", va="top")
    fig.text(.11, .576, "Checks + emission · host import excluded · changing program cohorts",
             fontsize=11.5, color=MUTED, va="top")
    xs = list(range(len(legacy)))
    legacy_ratios = [p["ratio"] for p in legacy]
    groups = []
    for i, point in enumerate(legacy):
        key = (point["cohortKey"], tuple(point["cohortIds"]))
        if not groups or groups[-1][0] != key or point.get("connectToPrevious") is False:
            groups.append((key, []))
        groups[-1][1].append(i)
    for j, (_, indices) in enumerate(groups):
        color = (BLUE, TEAL, GREEN)[min(j, 2)]
        legacy_ax.plot(indices, [legacy_ratios[i] for i in indices], color=color,
                       linewidth=2.7, marker="o", markersize=7, markeredgecolor=PAPER, zorder=4)
        for i in indices:
            legacy_ax.annotate(f"{legacy_ratios[i]:.2f}×", (i, legacy_ratios[i]), xytext=(0, 10),
                               textcoords="offset points", ha="center", color=color, fontsize=12)
        if j:
            legacy_ax.axvline(indices[0] - .5, color=GRID, linestyle=(0, (3, 4)))
    legacy_ax.set_xlim(-.35, len(legacy) - .65)
    legacy_ax.set_ylim(0, max(legacy_ratios) * 1.25)
    legacy_ax.set_yticks([0, 2.5, 5, 7.5, 10])
    legacy_ax.yaxis.set_major_formatter(FuncFormatter(lambda v, _: f"{v:g}×"))
    legacy_ax.set_xticks(xs, [f"P{p['phase']}\n{p['cohortSize']} programs\n{p['commit'][:7]}" for p in legacy], fontsize=9.5)
    legacy_ax.axhline(1, color=INK, linewidth=1.2)
    legacy_ax.grid(axis="y")
    fig.text(.11, .335, "Cohort changes break the line. This request-only scope ends at P48.", fontsize=10.5, color=MUTED)
    fig.add_artist(Line2D([.11, .95], [.316, .316], transform=fig.transFigure, color=GRID))
    fig.text(.11, .299, "CURRENT · Direct JavaScript first request", fontsize=14, fontweight="bold", va="top")
    fig.text(.11, .276, "Import + API load + first checked request · Evening and Lexer",
             fontsize=11.5, color=MUTED, va="top")
    first_request_axis(modern_ax, modern, "B1", value_size=12.5)
    fig.text(.11, .024, "The first three dots measure the P56 compiler. Only the last pair compares images.\n"
             "Fresh-process medians; Base caches primed. P58 B1 is effectively flat (+0.40% time).",
             fontsize=10.5, color=MUTED, linespacing=1.45)
    save(plt, fig, "compilation-average-history",
         "Three unjoined compilation scopes: historical compiler-source checking from P8 to P24 "
         "with no emission, legacy checked-library requests from P42 to P48 excluding host import "
         "and using separate cohorts, and modern B1 first checked direct-library requests including "
         "host import and API load on Evening and Lexer. Modern observations at P56, P57 and the "
         "fresh P58 baseline all measure the P56 compiler. Only the final pair compares P56 to "
         f"selected P58, from {modern[-2]['ratio']:.4f}x to {modern[-1]['ratio']:.4f}x TypeScript. "
         "Averaging uses equal-program geometric means; Base caches are primed and process startup is excluded.")


def second_stage_history(plt, data):
    fig, ax = line_axes(plt, height=5.8)
    fig.subplots_adjust(left=.11, right=.95, top=.73, bottom=.29)
    first_request_axis(ax, data["history"], "B2", value_size=15)
    fig.text(.11, .97, "Second-stage compilation · B2", fontsize=19, fontweight="bold", va="top")
    fig.text(.11, .91, "Import + API load + first checked request", fontsize=13, color=MUTED, va="top")
    fig.text(.11, .857, "Evening + Lexer · equal-program geometric mean · lower is better", fontsize=11.5, color=MUTED, va="top")
    fig.text(.11, .043, "The first three observations use the same P56 B2. Only the last pair compares images.\n"
             "Three fresh processes per program; Base caches primed. Qualified B2 remains uninstalled.",
             fontsize=10.5, color=MUTED, linespacing=1.55)
    ax.set_ylabel("Time ÷ TypeScript time", fontsize=12)
    save(plt, fig, "second-stage-average-history",
         "Four separate B2 first-request observations with import and API load included. P56 original, "
         "P57 repeat and P58 fresh baseline all use the P56 B2 compiler. The final same-campaign pair "
         f"improves from {data['history'][-2]['ratio']:.4f}x to {data['history'][-1]['ratio']:.4f}x TypeScript. "
         "Earlier observations are unconnected. Each equal-program geometric mean covers Evening and Lexer "
         "with three fresh processes per role. Base caches are primed; process startup is excluded. B2 is not installed.")


def compiler_programs(plt, data, stage):
    points = sorted(data["programs"], key=lambda p: p["ratio"])
    fig, ax = plt.subplots(figsize=(9, 4.8))
    fig.subplots_adjust(left=.23, right=.94, top=.70, bottom=.33)
    values = [p["ratio"] for p in points]
    ax.barh(range(len(points)), values, height=.37, color=ORANGE)
    for i, p in enumerate(points):
        ax.text(p["ratio"] + .07, i, f"{p['ratio']:.2f}×", va="center", color=ORANGE,
                fontsize=16, fontweight="bold")
        ax.text(0, i + .30, f"Bend {p['bend_ms']/1000:.3f} s  ·  TypeScript {p['typescript_ms']/1000:.3f} s",
                va="center", fontsize=11, color=MUTED,
                bbox={"facecolor": PAPER, "edgecolor": "none", "pad": .4})
    ax.set_yticks(range(len(points)), [p.get("name", p["id"]) for p in points], fontsize=15)
    ax.set_ylim(len(points) - .42, -.52)
    ax.set_xlim(0, max(values) * 1.26)
    ax.set_xticks(range(0, math.ceil(max(values) * 1.26)),
                  [f"{i}×" for i in range(0, math.ceil(max(values) * 1.26))])
    ax.grid(axis="x")
    ax.axvline(1, color=INK, linewidth=1.25)
    ax.set_xlabel("Time ÷ TypeScript time · 1× = equal time", labelpad=12, fontsize=12)
    fig.text(.07, .967, f"P{data['latest_phase']} · {'first' if stage == 'B1' else 'second'}-stage compilation ({stage})",
             fontsize=18, fontweight="bold", va="top")
    fig.text(.07, .881, "By program · import + API load + first checked request", fontsize=12.5, color=MUTED, va="top")
    footer = "Installed checked B1" if stage == "B1" else "Separately qualified B2 · not installed"
    fig.text(.07, .070, f"{footer} · three fresh processes per program and role.\n"
             "Base caches primed; process startup excluded. Lower is better.", fontsize=11, color=MUTED, linespacing=1.6)
    name = "compilation-programs" if stage == "B1" else "second-stage-programs"
    save(plt, fig, name, f"Latest P{data['latest_phase']} {stage} first-request latency including import and API loading "
         "for Evening and Lexer, shown against each campaign's TypeScript reference. "
         + "; ".join(f"{p.get('name', p['id'])}: {p['ratio']:.4f}x, Bend {p['bend_ms']:.3f} ms, TypeScript {p['typescript_ms']:.3f} ms" for p in points)
         + ". Three fresh processes per role and program; Base caches primed, process startup excluded. " + footer + ".")


def second_stage_self_emission(plt, data):
    points = data["selfEmissionHistory"]
    fig, ax = plt.subplots(figsize=(9, 4.9))
    fig.subplots_adjust(left=.28, right=.93, top=.70, bottom=.32)
    values = [p["seconds"] for p in points]
    ax.barh(range(len(points)), values, height=.43, color=[TEAL, GREEN])
    for i, value in enumerate(values):
        ax.text(value + 5, i, f"{value:.3f} s", va="center", fontsize=16, fontweight="bold",
                color=TEAL if i == 0 else GREEN)
    ax.set_yticks(range(len(points)), [f"P{p['phase']} B2" for p in points], fontsize=15)
    ax.set_ylim(len(points) - .5, -.55)
    ax.set_xlim(0, max(values) * 1.29)
    ax.set_xticks([0, 50, 100, 150, 200, 250])
    ax.set_xlabel("Complete compiler-image emission · seconds", fontsize=12, labelpad=12)
    ax.grid(axis="x")
    fig.text(.07, .968, f"Self-emission · {data['selfEmission']['speedup']:.2f}× faster", fontsize=19, fontweight="bold", va="top")
    fig.text(.07, .88, "B2 emits its complete B3 · each compiles its own compiler source", fontsize=12, color=MUTED, va="top")
    fig.text(.07, .066, "Same clean method; one observation per image. Baseline retained from earlier in P58.\n"
             "Each output is byte-checked. Fresh source checking is a separate qualification.",
             fontsize=10.5, color=MUTED, linespacing=1.6)
    save(plt, fig, "second-stage-self-emission",
         f"Clean complete compiler-image emission falls from {values[0]:.9f} seconds on P56 B2 "
         f"to {values[1]:.9f} seconds on P58 last01 B2, a {data['selfEmission']['speedup']:.4f}x speedup. "
         "Two observations under the same clean method; the baseline is retained from earlier in the P58 "
         "campaign and was not rerun consecutively with the selected image. Each image compiles its own "
         "source and verifies its own complete output bytes. Fresh type checking and 39.199-second "
         "qualification reproduction are separate clocks.")


def speed_programs(plt, data, kind):
    """Current per-program ratios, grouped explicitly when a source has multiple cases."""
    runtime = kind == "runtime"
    points = data["latest"]["sourceGroups"] if runtime else data["programs"]
    ratio_key = "ratioToTypeScript" if runtime else "ratio"
    points = sorted(points, key=lambda point: point[ratio_key])
    count = len(points)
    phase = data["latest"]["phase"] if runtime else data["latest_phase"]
    height = 2.6 + count * .365
    if not runtime:
        height = max(4.4, height)
    fig, ax = plt.subplots(figsize=(9, height))
    fig.subplots_adjust(left=.39 if runtime else .31, right=.91,
                        top=.89 if runtime else .76, bottom=.15 if runtime else .35)
    values = [point[ratio_key] for point in points]
    colors = [GREEN if ratio <= 1 else ORANGE for ratio in values]
    ax.barh(range(count), [value - 1 for value in values], left=1, height=.49, color=colors)
    for i, value in enumerate(values):
        ax.text(value * 1.08 if value >= 1 else 1.03, i, f"{value:.2f}×",
                color=colors[i], fontsize=14, fontweight="bold", va="center", ha="left")
    if runtime:
        labels = []
        for point in points:
            label = re.sub(r" · \d+ inputs$", "", point["label"])
            if point.get("sourcePath", "").endswith("raytrace-active.bend"):
                label = "Ray tracing · active"
            elif point.get("sourcePath", "").endswith("mandelbrot-grid.bend"):
                label = "Mandelbrot · grid"
            label = label[:1].upper() + label[1:]
            labels.append(f"{label} ({point['pointCount']})")
    else:
        labels = [point.get("label", point.get("name", point["id"])) for point in points]
    ax.set_yticks(range(count), labels, fontsize=14)
    ax.set_ylim(count - .35, -.75)
    ax.set_xscale("log")
    lower = min(.82, min(values) * .80)
    upper = max(values) * 1.5
    ax.set_xlim(lower, upper)
    ticks = [value for value in (.1, .2, .5, 1, 2, 5, 10, 20, 50, 100, 200, 500)
             if lower <= value <= upper]
    ax.set_xticks(ticks, [f"{value:g}×" for value in ticks], fontsize=12)
    ax.minorticks_off()
    ax.grid(axis="x")
    ax.axvline(1, color=INK, linewidth=1.25)
    ax.set_xlabel("Time ÷ TypeScript time · log scale", labelpad=14, fontsize=12)
    title = f"P{phase} execution time by program" if runtime else f"P{phase} legacy compilation · latest measured"
    fig.text(.055, .975, title, fontsize=17, fontweight="bold", va="top")
    fig.text(.055, .935 if runtime else .875,
             "Lower is better · 1× = TypeScript", fontsize=13, color=MUTED, va="top")
    if runtime:
        footnote = (f"P{phase} · geometric mean within each source program. Parentheses show case counts.\n"
                    f"The headline weights all {data['latest']['pointCount']} cases equally, rather than these {count} groups.")
    else:
        footnote = (f"P{phase} · {count} programs · checking + legacy JavaScript emission.\n"
                    f"The P{data['installed_phase']} default backend has no comparable compilation measurement.")
    fig.text(.055, .025, footnote, fontsize=11, color=MUTED, linespacing=1.6)
    save(plt, fig, f"{kind}-programs",
         f"Phase{phase} {'execution' if runtime else 'compiler request'} times divided by same-window "
         f"TypeScript reference times for {count} program groups. Lower is better. The logarithmic "
         "axis has a visible 1x equal-time reference. " + footnote.replace("\n", " "))


def render():
    data = {name: json.loads((ROOT / name).read_text()) for name in INPUTS}
    plt = configure()
    DEST.mkdir(parents=True, exist_ok=True)
    simplicity(plt, data["history-research.json"])
    compilation(plt, data["history-research.json"])
    conformance(plt, data["conformance-research.json"])
    runtime_gains(plt, data["runtime-research.json"])
    runtime_gaps(plt, data["runtime-research.json"])
    for kind in ("runtime", "compilation"):
        if kind == "compilation":
            compilation_history(plt, data["compilation-average-research.json"],
                                data["history-research.json"])
        else:
            speed_history(plt, data[f"{kind}-average-research.json"], kind)
        if kind == "runtime":
            speed_programs(plt, data[f"{kind}-average-research.json"], kind)
        else:
            compiler_programs(plt, data["compilation-average-research.json"], "B1")
    second_stage_history(plt, data["second-stage-research.json"])
    compiler_programs(plt, data["second-stage-research.json"], "B2")
    second_stage_self_emission(plt, data["second-stage-research.json"])
    manifest = {
        "version": 1,
        "inputs": {name: digest(ROOT / name)
                   for name in (*INPUTS, "scripts/charts.py", "requirements-charts.txt")},
        "outputs": {f"{name}.{ext}": digest(DEST / f"{name}.{ext}")
                    for name in NAMES for ext in ("svg", "png")},
    }
    (DEST / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"Rendered {len(NAMES)} SVG/PNG chart pairs and their checksum manifest.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Check input/output hashes; no plotting dependencies needed")
    args = parser.parse_args()
    if args.check:
        return check()
    render()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
