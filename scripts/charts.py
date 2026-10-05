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
          "runtime-average-research.json", "compilation-average-research.json")
NAMES = ("simplicity", "compilation", "conformance", "runtime-gains", "runtime-gaps",
         "runtime-average-history", "runtime-programs", "compilation-average-history",
         "compilation-programs")
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
        "Date": "2026-10-04",
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
    upper = math.ceil(max(p["physicalLines"] for p in points) / 5000) * 5000 + 1000
    ax.set_ylim(0, upper)
    ax.set_xlim(-.2, len(points) - .5)
    ax.set_yticks(range(0, upper, 5000))
    ax.yaxis.set_major_formatter(FuncFormatter(lambda n, _: f"{n:,.0f}"))
    tick_indices = sorted(set([0, 1, 3, 6, 8, 10, len(points) - 1]))
    ax.set_xticks(tick_indices, [points[i]["chartLabel"].replace(" / ", "\n") for i in tick_indices])
    ax.set_xlabel("Recorded development milestones", labelpad=10)
    note(fig, "Compiler source · lines of code")
    ax.annotate(f"{points[0]['physicalLines']:,}", (0, points[0]["physicalLines"]),
                xytext=(0, 18000), fontsize=13, color=GREEN,
                arrowprops={"arrowstyle": "-", "color": GREEN, "linewidth": 1})
    ax.annotate(f"{points[-1]['physicalLines']:,}", (xs[-1], points[-1]["physicalLines"]),
                xytext=(-3, 13), textcoords="offset points", ha="right",
                fontsize=15, fontweight="bold", color=GREEN)
    latest_nonblank = next((i for i in reversed(xs) if points[i].get("nonblankLines")), None)
    if latest_nonblank is not None:
        ax.annotate(f"{points[latest_nonblank]['nonblankLines']:,}",
                    (latest_nonblank, points[latest_nonblank]["nonblankLines"]),
                    xytext=(-3, -24), textcoords="offset points", ha="right",
                    fontsize=14, fontweight="bold", color=TEAL)
    ax.annotate("Cleanup\n−1,842 physical lines", (3, 14667), xytext=(1.1, 7600),
                arrowprops={"arrowstyle": "-", "color": GREEN, "linewidth": 1},
                color=GREEN, fontsize=13, linespacing=1.5)
    ax.text(7.1, 5100, "Later work adds\ncoverage and optimizations", fontsize=13,
            color=MUTED, linespacing=1.5)
    handles, labels = ax.get_legend_handles_labels()
    fig.legend(handles, labels, loc="lower left", bbox_to_anchor=(.11, .001), ncol=2,
               frameon=False, fontsize=12, handlelength=2)
    save(plt, fig, "simplicity",
         f"Physical and nonblank compiler source lines across {len(points)} selected snapshots, on a zero-based "
         "axis. Dedicated consolidation removes 1842 physical lines from Phase5 to Phase7. Later "
         f"coverage and performance work increases source size to {points[-1]['physicalLines']} physical "
         "lines. Missing nonblank counts are left unplotted. Source size is a proxy, not a complete measure of simplicity.")


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
    fig, ax = line_axes(plt)
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
    note(fig, "Exact frontend agreement · vertical axis starts at 70%")
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
    fig.text(.11, .037, "Pinned targets", fontsize=11, color=MUTED)
    for x, segment, color in zip((.32, .53, .75), data["segments"], colors):
        fig.text(x, .037, f"● {segment['id']}  ({segment['total']:,})", fontsize=11, color=color)
    save(plt, fig, "conformance",
         "Exact parse/check agreement across selected recorded milestones. Three disconnected "
         "series use distinct pinned upstream targets and denominators. Vertical axis starts "
         "at 70 percent. Current recorded agreement is 3026 of 3026 observations.")


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
    fig.subplots_adjust(left=.10, right=.95, top=.80, bottom=.27)
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
            count = points[indices[0]]["pointCount"]
            protocol = points[indices[0]].get("protocolGroup", "")
            segment_label = ("Mixed warmup" if protocol.startswith("mixed-") else
                             "1,000 ms warmup" if protocol else f"{count} cases")
            ax.text(sum(indices) / len(indices), 1.015, segment_label,
                    transform=ax.get_xaxis_transform(), ha="center", va="bottom",
                    color=color, fontsize=12, fontweight="bold")
        if j:
            ax.axvline(indices[0] - .5, color=GRID, linewidth=1.5, linestyle=(0, (3, 4)))
    for i, ratio in enumerate(ratios):
        last = i == len(points) - 1
        ax.annotate(f"{ratio:.2f}×", (i, ratio), xytext=(0, 13),
                    textcoords="offset points", ha="center", va="bottom",
                    fontsize=17 if last else 14, fontweight="bold" if last else "normal",
                    color=GREEN if last else MUTED)
    upper = max(ratios) * 1.30
    ax.set_ylim(0, max(upper, 4))
    ax.set_xlim(-.35, len(points) - .65 if len(points) > 1 else .65)
    from matplotlib.ticker import FuncFormatter, MaxNLocator
    ax.yaxis.set_major_locator(MaxNLocator(nbins=5, min_n_ticks=3))
    ax.yaxis.set_major_formatter(FuncFormatter(lambda value, _: f"{value:g}×"))
    labels = [checkpoint_label(point) for point in points]
    if len(points) > 5:
        labels = [label.replace(" · ", "\n") for label in labels]
    ax.set_xticks(xs, labels, fontsize=12)
    ax.set_ylabel("Time ÷ TypeScript time", labelpad=10)
    ax.set_xlabel("Release checkpoints · commit date and ID", labelpad=13, fontsize=12)
    fig.text(.10, .966, "Average slowdown vs. TypeScript", fontsize=17, fontweight="bold", va="top")
    subtitle = ("Geometric mean of benchmark cases · lower is better" if runtime else
                "Geometric mean of 4 programs · checks + JS emission · lower is better")
    fig.text(.10, .91, subtitle, fontsize=12.5, color=MUTED, va="top")
    footnote = ("Same 45 cases. Warmup changed at P41; lines are separated at that boundary." if runtime and data.get("historyProtocolBoundary") else
               "Disconnected lines mark different suites; compare changes within each suite." if len(segments) > 1 else
                "Same programs and inputs at every checkpoint; ratios use each report’s TypeScript reference.")
    fig.text(.10, .028, footnote, fontsize=11, color=MUTED)
    save(plt, fig, f"{kind}-average-history",
         f"Average {'compiled program execution' if runtime else 'compiler request'} time divided by "
         "TypeScript reference time at recorded release commits. Geometric means give each benchmark "
         f"case equal weight. Lower is better and the 1x TypeScript reference is visible. {footnote} "
         f"Latest recorded average is {ratios[-1]:.4f}x at Phase{points[-1]['phase']}.")


def compilation_history(plt, current, history):
    """Keep historical checking snapshots separate from the fixed-program compile suite."""
    from matplotlib.ticker import FuncFormatter

    earlier = history["compilerChecking"]["series"]
    recent = current["history"]
    fig = plt.figure(figsize=(9, 9.5))
    early_ax = fig.add_axes((.11, .585, .84, .24))
    recent_ax = fig.add_axes((.11, .16, .84, .205))

    fig.text(.11, .98, "Compilation cost across development", fontsize=18,
             fontweight="bold", va="top")
    fig.text(.11, .94, "Two measurement scopes · time ÷ TypeScript time · lower is better",
             fontsize=12, color=MUTED, va="top")
    fig.text(.11, .889, "EARLIER · Compiler-source checking", fontsize=14,
             fontweight="bold", va="top")
    fig.text(.11, .858, "Process time · no code emission · log scale",
             fontsize=12, color=MUTED, va="top")

    selected_phases = {8, 9, 11, 16, 24}
    phases = [point["phase"] for point in earlier]
    ratios = [point["bend_to_typescript_process_ratio"] for point in earlier]
    # Source snapshots, measurement windows, and eventually the TypeScript pin change.
    # Deliberately use isolated markers, without a connecting trendline.
    colors = [GREEN if phase in selected_phases else TEAL for phase in phases]
    early_ax.scatter(phases, ratios, s=53, c=colors, edgecolors=PAPER,
                     linewidths=1.2, zorder=4)
    early_ax.set_yscale("log")
    early_ax.set_ylim(1, 100)
    early_ax.set_xlim(min(phases) - .8, max(phases) + .8)
    early_ax.set_yticks([1, 3, 10, 30, 100], ["1×", "3×", "10×", "30×", "100×"])
    early_ax.minorticks_off()
    early_ticks = [phase for phase in (8, 9, 11, 14, 16, 19, 21, 23, 24) if phase in phases]
    early_ax.set_xticks(early_ticks, [f"P{phase}" for phase in early_ticks], fontsize=11)
    early_ax.grid(axis="y")
    early_ax.axhline(1, color=INK, linewidth=1.3, zorder=2)
    early_ax.text(.01, 1, "1× = TypeScript", transform=early_ax.get_yaxis_transform(),
                  va="bottom", fontsize=11, color=INK,
                  bbox={"facecolor": PAPER, "edgecolor": "none", "pad": 3})
    for phase, ratio in zip(phases, ratios):
        if phase in selected_phases:
            # Early large reductions and the final snapshot get direct value labels.
            offset = (7, 8) if phase == 8 else ((-1, 12) if phase == 24 else (0, 12))
            early_ax.annotate(f"{ratio:.2f}×", (phase, ratio), xytext=offset,
                              textcoords="offset points", ha="center", va="bottom",
                              color=GREEN, fontsize=13, fontweight="bold")
    pin_changes = [point["phase"] - .5 for previous, point in zip(earlier, earlier[1:])
                   if previous["pin"] != point["pin"]]
    for boundary in pin_changes:
        early_ax.axvline(boundary, color=GRID, linewidth=1.5, linestyle=(0, (3, 4)))
        early_ax.text(boundary - .25, 63, f"New TS pin\nat P{int(boundary + .5)}",
                      ha="right", va="top", color=MUTED, fontsize=11, linespacing=1.5)
    fig.text(.11, .527, "Source and timing windows evolve; each dot is a separate release snapshot.",
             fontsize=11, color=MUTED)
    first, last = earlier[0], earlier[-1]
    fig.text(.11, .500,
             f"Bend process time: {first['bend_process_seconds']:.3f} s (P{first['phase']}) → "
             f"{last['bend_process_seconds']:.3f} s (P{last['phase']})",
             fontsize=11.5, color=GREEN)

    # A full-width divider and separate axis prevent a false historical-to-current trend.
    from matplotlib.lines import Line2D
    fig.add_artist(Line2D([.11, .95], [.468, .468], transform=fig.transFigure,
                         color=GRID, linewidth=1.2))
    fig.text(.11, .438, "RECENT · Checking + JavaScript emission", fontsize=14,
             fontweight="bold", va="top")
    fig.text(.11, .407, "Geometric mean of the same 4 programs · request time",
             fontsize=12, color=MUTED, va="top")

    xs = list(range(len(recent)))
    recent_ratios = [point["ratio"] for point in recent]
    recent_ax.plot(xs, recent_ratios, color=GREEN, linewidth=2.8, marker="o", markersize=8,
                   markeredgecolor=PAPER, markeredgewidth=1.5, zorder=4)
    recent_ax.set_xlim(-.35, len(recent) - .65)
    recent_ax.set_ylim(0, max(10.8, max(recent_ratios) * 1.28))
    recent_ax.set_yticks([0, 2.5, 5, 7.5, 10])
    recent_ax.yaxis.set_major_formatter(FuncFormatter(lambda value, _: f"{value:g}×"))
    recent_ax.set_xticks(xs, [checkpoint_label(point) for point in recent], fontsize=11)
    recent_ax.grid(axis="y")
    recent_ax.axhline(1, color=INK, linewidth=1.3)
    recent_ax.text(.01, 1, "1× = TypeScript", transform=recent_ax.get_yaxis_transform(),
                   va="bottom", fontsize=11, color=INK,
                   bbox={"facecolor": PAPER, "edgecolor": "none", "pad": 3})
    for i, ratio in enumerate(recent_ratios):
        recent_ax.annotate(f"{ratio:.2f}×", (i, ratio), xytext=(0, 11),
                           textcoords="offset points", ha="center", va="bottom",
                           fontsize=15 if i == len(recent) - 1 else 13,
                           color=GREEN, fontweight="bold" if i == len(recent) - 1 else "normal")
    fig.text(.11, .067, "Release checkpoints · commit date and ID", fontsize=11, color=MUTED)
    fig.text(.11, .027, "Each ratio uses its report’s TypeScript reference; lower is better.",
             fontsize=11, color=MUTED)
    save(plt, fig, "compilation-average-history",
         "Two separate compilation measurement scopes. The upper panel shows 15 historical "
         "compiler-source checking process-time snapshots from Phase8 to Phase24, without code "
         "emission, on a logarithmic 1x to 100x axis. The source and timing windows evolve, so "
         "the snapshots are unconnected. The TypeScript reference pin changes at Phase23. "
         f"The recorded ratio declines from {ratios[0]:.2f}x to {ratios[-1]:.2f}x across these snapshots. "
         "The lower panel separately shows the geometric mean of checked JavaScript emission "
         "request-time ratios on the same four programs at Phase42 through Phase45, on a linear "
         f"axis, ending at {recent_ratios[-1]:.2f}x. Both panels show the 1x TypeScript reference. "
         "Historical and current measurements are not joined or treated as a matched workload.")


def speed_programs(plt, data, kind):
    """Current per-program ratios, grouped explicitly when a source has multiple cases."""
    runtime = kind == "runtime"
    points = data["latest"]["sourceGroups"] if runtime else data["programs"]
    ratio_key = "ratioToTypeScript" if runtime else "ratio"
    points = sorted(points, key=lambda point: point[ratio_key])
    count = len(points)
    fig, ax = plt.subplots(figsize=(9, 2.6 + count * .365))
    fig.subplots_adjust(left=.39 if runtime else .31, right=.91,
                        top=.89 if runtime else .76, bottom=.15 if runtime else .27)
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
    fig.text(.055, .975, "Current slowdown by program", fontsize=17, fontweight="bold", va="top")
    fig.text(.055, .935 if runtime else .875,
             "Lower is better · 1× = TypeScript", fontsize=13, color=MUTED, va="top")
    if runtime:
        footnote = ("P45 · geometric mean within each source program. Parentheses show case counts.\n"
                    "The headline weights all 45 cases equally, rather than these 23 groups.")
    else:
        footnote = "P45 · complete compiler requests, including checks and JavaScript emission."
    fig.text(.055, .025, footnote, fontsize=11, color=MUTED, linespacing=1.6)
    save(plt, fig, f"{kind}-programs",
         f"Phase45 {'execution' if runtime else 'compiler request'} times divided by same-window "
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
        speed_programs(plt, data[f"{kind}-average-research.json"], kind)
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
