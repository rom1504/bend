"""Native compiler report charts, with explicit cohort and timing boundaries."""

from __future__ import annotations

import math
import re
import textwrap


INK = "#202d29"
MUTED = "#586660"
PAPER = "#f6f7f2"
GREEN = "#245f43"
TEAL = "#2b7f85"
ORANGE = "#a3692d"
BLUE = "#426ba0"
GRID = "#dce3da"


def ratio_format(ax, axis="y"):
    from matplotlib.ticker import FuncFormatter
    getattr(ax, f"{axis}axis").set_major_formatter(FuncFormatter(lambda n, _: f"{n:g}×"))


def figure(plt, height=5.9, left=.12, bottom=.23):
    fig, ax = plt.subplots(figsize=(9, height))
    fig.subplots_adjust(left=left, right=.94, top=.79, bottom=bottom)
    return fig, ax


def heading(fig, title, subtitle, x=.09):
    fig.text(x, .966, title, fontsize=17, fontweight="bold", va="top")
    fig.text(x, .910, subtitle, fontsize=11.5, color=MUTED, va="top", linespacing=1.5)


def footnote(fig, text, y=.035):
    fig.text(.09, y, text, fontsize=10.5, color=MUTED, linespacing=1.6, va="bottom")


def phase_label(point):
    compiler_phase = point.get("compilerPhase", point["phase"])
    label = f"P{compiler_phase}"
    report_phase = point.get("reportPhase", point.get("measurementPhase", point["phase"]))
    if report_phase != compiler_phase:
        label += f" baseline\nmeasured P{report_phase}"
    date = (point.get("date") or point.get("commitDate") or point.get("commit_date") or "")[:10]
    if date:
        label += f" · {date[5:].replace('-', '/')}"
    commit = point.get("commit")
    if commit:
        label += "\n" + commit[:7]
    return label


def carried(point):
    status = str(point.get("measurementStatus", "")).lower()
    return any(s in status for s in ("carry", "carried", "identity", "identical", "reused"))


def execution_history(plt, data, save):
    points = data["history"]
    fig, ax = figure(plt, bottom=.28 if len(points) > 4 else .25)
    ratios = [p.get("ratio", p.get("averageRatio")) for p in points]
    xs = list(range(len(points)))
    # Each suite gets its own line; identical output is an explicit hollow marker.
    segments = []
    for i, point in enumerate(points):
        key = (point.get("cohortKey"), point.get("referenceCommit"), point.get("protocolGroup"))
        if not segments or segments[-1][0] != key or point.get("connectToPrevious") is False:
            segments.append((key, []))
        segments[-1][1].append(i)
    for index, (_, indices) in enumerate(segments):
        color = GREEN if index == len(segments) - 1 else TEAL
        # Carried evidence must not appear to be an independently timed plateau.
        for a, b in zip(indices, indices[1:]):
            ax.plot([a, b], [ratios[a], ratios[b]], color=color, linewidth=2.4,
                    linestyle=(0, (3, 3)) if carried(points[a]) or carried(points[b]) else "-")
        for i in indices:
            ax.scatter([i], [ratios[i]], s=100, color=PAPER if carried(points[i]) else color,
                       edgecolor=color, linewidth=2, zorder=4)
        if index:
            ax.axvline(indices[0] - .5, color=GRID, linestyle=(0, (3, 4)))
    for i, (point, value) in enumerate(zip(points, ratios)):
        suffix = "\noutput identity" if carried(point) else ""
        ax.annotate(f"{value:.3f}×{suffix}", (i, value), xytext=(0, 15),
                    textcoords="offset points", fontsize=13 if suffix else 15,
                    fontweight="bold" if i == len(points) - 1 else "normal",
                    ha="center", color=GREEN if i == len(points) - 1 else MUTED,
                    linespacing=1.4)
    ax.axhline(1, color=INK, linewidth=1.1)
    ax.text(.015, 1, "1× = upstream C", transform=ax.get_yaxis_transform(), va="bottom",
            color=INK, fontsize=10.5, bbox={"facecolor": PAPER, "edgecolor": "none", "pad": 3})
    lower = min(.9, math.floor((min(ratios) - .04) * 10) / 10)
    upper = max(1.22, max(ratios) * 1.16)
    ax.set_ylim(lower, upper)
    ax.set_xlim(-.4, max(.4, len(points) - .6))
    ax.set_xticks(xs, [phase_label(p) for p in points], fontsize=9.5 if len(points) > 4 else 11)
    ax.set_ylabel("Execution time ÷ upstream C time", fontsize=11.5, labelpad=10)
    ax.set_xlabel("Compiler checkpoints · changed suites are disconnected", fontsize=11, labelpad=12)
    ax.grid(axis="y")
    ratio_format(ax)
    heading(fig, "Native program speed · progress toward parity",
            "Warmed generated C programs · geometric mean · lower is better")
    footnote(fig, "44 positive-work cases in the broad suite; the earlier C12 screens are separate.\n"
             "Hollow marker = carried by identical emitted C, not a fresh timing run. Axis starts at 0.9×.")
    save(plt, fig, "native-runtime-history",
         "Native generated-program runtime divided by upstream C runtime. Changed benchmark suites "
         "are disconnected. Hollow points and dashed segments identify earlier results carried by "
         "byte-identical output, not fresh runtime measurements. The final broad mean gives equal "
         f"weight to 44 positive-work points and is {ratios[-1]:.6f}x. Lower is better; the axis starts at 0.9x.")


def clean_program_label(group):
    names = {"editdist": "Edit distance", "symreg": "Symbolic regression", "bst": "Binary search tree",
             "raytrace": "Ray tracing", "raytrace-active": "Ray tracing · active",
             "test-rle-roundtrip": "Run-length encoding", "test-map-set-ops": "Map / set operations",
             "test-morning-program": "Morning program", "test-evening-program": "Evening program"}
    label = names.get(group.get("id"), group.get("label", group.get("name", group.get("id", ""))))
    label = re.sub(r"\s*[·(]\s*\d+\s*(?:inputs|cases|points)\)?$", "", label)
    label = label.replace("_", " ").replace("-", " ")
    label = label[:1].upper() + label[1:]
    return f"{label} ({group['pointCount']})" if "pointCount" in group else label


def execution_programs(plt, data, save):
    latest = data["latest"]
    groups = sorted(latest["groups"], key=lambda p: p["ratio"])
    height = max(5.8, 2.7 + len(groups) * .36)
    fig, ax = plt.subplots(figsize=(9, height))
    fig.subplots_adjust(left=.39, right=.91, top=1 - 1.35 / height, bottom=1.25 / height)
    values = [p["ratio"] for p in groups]
    colors = [GREEN if value <= 1 else ORANGE for value in values]
    ax.barh(range(len(groups)), [v - 1 for v in values], left=1, height=.50, color=colors)
    for i, value in enumerate(values):
        ax.text(max(value, 1) * 1.055, i, f"{value:.2f}×", va="center",
                color=colors[i], fontsize=12.5, fontweight="bold")
    ax.set_yticks(range(len(groups)), [clean_program_label(g) for g in groups], fontsize=11.5)
    ax.set_ylim(len(groups) - .35, -.7)
    ax.set_xscale("log")
    lower, upper = min(.78, min(values) * .85), max(values) * 1.35
    ax.set_xlim(lower, max(1.5, upper))
    ticks = [v for v in (.05, .1, .2, .3, .5, .75, 1, 1.5, 2, 3, 5, 10, 20)
             if lower <= v <= max(1.5, upper)]
    ax.set_xticks(ticks, [f"{v:g}×" for v in ticks], fontsize=10.5)
    ax.minorticks_off()
    ax.axvline(1, color=INK, linewidth=1.2)
    ax.grid(axis="x")
    ax.set_xlabel("Time ÷ upstream C time · log scale", fontsize=11.5, labelpad=13)
    fig.text(.065, 1 - .2 / height, f"P{latest['phase']} · native speed by program", fontsize=17,
             fontweight="bold", va="top")
    fig.text(.065, 1 - .65 / height, "Lower is better · 1× = upstream C · green is faster, amber is slower",
             fontsize=11.5, color=MUTED, va="top")
    footnote(fig, "Each row is the geometric mean within one source; parentheses show case counts.\n"
             f"Headline: {latest['pointCount']} cases weighted equally. Equal-source mean: {latest['equalSourceRatio']:.3f}×.",
             y=.20 / height)
    save(plt, fig, "native-runtime-programs",
         f"All {len(groups)} original source groups in the Phase{latest['phase']} native C runtime suite, "
         "sorted by geometric mean execution-time ratio to upstream C. Bars start at the 1x parity line "
         "on a logarithmic axis. Each source group weights its own cases equally; the headline instead "
         f"weights all {latest['pointCount']} positive-work cases equally. Lower is better.")


def compiler_history(plt, data, stage, save):
    points = data["history"]
    fig, ax = figure(plt, bottom=.30)
    for i, point in enumerate(points):
        request = point.get("requestRatio", point.get("ratio"))
        process = point.get("processRatio")
        # Each milestone is a separate matched comparison: no chained trend line.
        ax.plot([i, i], [1, request], color=GREEN if request <= 1 else ORANGE, linewidth=4, alpha=.70)
        ax.scatter([i], [request], color=GREEN if request <= 1 else ORANGE, s=110, zorder=4)
        if process is not None:
            ax.scatter([i + .1], [process], color=BLUE, s=45, marker="D", zorder=5)
        ax.annotate(f"{request:.3f}×", (i, request), xytext=(0, -24 if request <= 1 else 15),
                    textcoords="offset points", color=GREEN if request <= 1 else ORANGE,
                    fontsize=16, fontweight="bold", ha="center")
    labels = []
    for point in points:
        baseline = point.get("baselineLabel", point.get("baseline", "paired baseline"))
        if isinstance(baseline, dict):
            baseline = baseline.get("label", baseline.get("name", "paired baseline"))
        baseline = str(baseline).replace("Phase", "P")
        baseline = textwrap.fill(baseline, width=32)
        labels.append(f"{phase_label(point)}\nvs. {baseline}")
    ax.set_xticks(range(len(points)), labels, fontsize=10.5)
    ax.set_xlim(-.5, max(.5, len(points) - .5))
    values = [p.get("requestRatio", p.get("ratio")) for p in points]
    values += [p["processRatio"] for p in points if p.get("processRatio") is not None]
    ax.set_ylim(min(.5, min(values) - .15), max(1.18, max(values) + .15))
    ax.axhline(1, color=INK, linewidth=1.2)
    ax.text(.015, 1, "1× = each paired baseline", transform=ax.get_yaxis_transform(), va="bottom",
            color=INK, fontsize=10.5, bbox={"facecolor": PAPER, "edgecolor": "none", "pad": 3})
    ax.grid(axis="y")
    ratio_format(ax)
    ax.set_ylabel("Candidate time ÷ paired baseline time", fontsize=11, labelpad=10)
    heading(fig, f"Native {stage} compilation · measured change",
            "Independent matched screens · ● compiler request   ◆ complete process")
    footnote(fig, "Each milestone uses its own source and measurement window; gains are not chained.\n"
             "Lower is better. The latest comparison is against P98, not upstream TypeScript.")
    stem = "native-second-stage" if stage == "B2" else "native-compilation"
    save(plt, fig, f"{stem}-history",
         f"Native {stage} compilation history shown as separate matched before-and-after comparisons. "
         "Circles show compiler-request ratios; diamonds show complete-process ratios. Baselines "
         "and cohorts differ between screens, so no trend line joins them and gains are not multiplied. "
         "Latest baseline is Phase98, not upstream TypeScript. Lower is better; vertical axis starts at 0.5x.")


def compiler_programs(plt, data, stage, save):
    latest = data["latest"]
    programs = sorted(latest["programs"], key=lambda p: p["requestRatio"])
    height = max(6.5, 2.6 + .58 * len(programs))
    fig, ax = plt.subplots(figsize=(9, height))
    fig.subplots_adjust(left=.31, right=.89, top=.77, bottom=.20)
    for i, point in enumerate(programs):
        request, process = point["requestRatio"], point["processRatio"]
        color = GREEN if request <= 1 else ORANGE
        ax.plot([min(request, process), max(request, process)], [i, i], color=GRID, linewidth=3)
        ax.scatter([request], [i], color=color, s=85, zorder=4)
        ax.scatter([process], [i], color=BLUE, s=38, marker="D", zorder=5)
        ax.text(max(request, process) + .025, i, f"{request:.3f}×", color=color,
                fontsize=12.5, fontweight="bold", va="center")
    ax.set_yticks(range(len(programs)), [p.get("label", p["id"]) for p in programs], fontsize=12)
    ax.set_ylim(len(programs) - .4, -.6)
    values = [p[k] for p in programs for k in ("requestRatio", "processRatio")]
    lower = min(.45, math.floor((min(values) - .05) * 10) / 10)
    upper = max(1.3, max(values) + .22)
    ax.set_xlim(lower, upper)
    ax.axvline(1, color=INK, linewidth=1.2)
    ax.grid(axis="x")
    ratio_format(ax, "x")
    ax.set_xlabel("Candidate04 time ÷ Phase98 time · lower is better", fontsize=11.5, labelpad=14)
    heading(fig, f"P{latest['phase']} · native {stage} by source",
            "Six sources · four alternating rounds · one worker\n"
            "● compiler request (labelled)   ◆ complete process")
    footnote(fig, "Request excludes Base decoding. Process includes startup, Base preparation and output IO.\n"
             "Both clocks exclude Clang. Generated program speed is measured separately.")
    stem = "native-second-stage" if stage == "B2" else "native-compilation"
    save(plt, fig, f"{stem}-programs",
         f"All six Phase102 native {stage} compilation sources compared with the matching Phase98 stage. "
         "Each labelled circle shows compiler-request time ratio, and each blue diamond shows the "
         "complete-process ratio including startup, Base preparation, output writing and teardown. "
         "Both clocks exclude Clang. Four alternating rounds per comparator. "
         "The 1x line means equal time to Phase98. Lower is better.")


def simplicity(plt, data, save):
    from matplotlib.ticker import FuncFormatter
    source = data["simplicity"]
    points = source["series"]
    native = source["nativeAssembly"]["points"]
    fig = plt.figure(figsize=(9, 8.8))
    ax = fig.add_axes((.12, .47, .82, .34))
    native_ax = fig.add_axes((.12, .14, .82, .15))
    xs = list(range(len(points)))
    for key, color, label in (("physicalLines", GREEN, "Physical lines"),
                               ("nonblankLines", TEAL, "Nonblank lines"),
                               ("codeLines", BLUE, "Code lines")):
        ax.plot(xs, [p.get(key) or float("nan") for p in points], color=color,
                linewidth=2.5, marker="o", markersize=4, label=label)
    latest = points[-1]
    ax.annotate(f"{latest['physicalLines']:,}", (xs[-1], latest["physicalLines"]),
                xytext=(-2, 12), textcoords="offset points", ha="right", fontsize=16,
                color=GREEN, fontweight="bold")
    ticks = sorted(set([0, 3, 10, 17, len(points) - 6, len(points) - 3, len(points) - 1]))
    ticks = [i for i in ticks if 0 <= i < len(points)]
    ax.set_xticks(ticks, [points[i].get("chartLabel", f"P{points[i].get('phase', '')}").replace(" / ", "\n")
                         for i in ticks], fontsize=10.5)
    ax.set_xlim(-.4, len(points) - .5)
    ax.set_ylim(0, max(40000, latest["physicalLines"] * 1.15))
    ax.set_yticks([0, 10000, 20000, 30000, 40000])
    ax.yaxis.set_major_formatter(FuncFormatter(lambda n, _: f"{n / 1000:g}k"))
    ax.grid(axis="y")
    ax.set_ylabel("Source lines · zero-based axis", fontsize=11)
    ax.legend(loc="upper left", ncol=3, frameon=False, fontsize=10, handlelength=1.6)
    fig.text(.09, .966, "Simplicity · keep the counting boundaries visible", fontsize=17,
             fontweight="bold", va="top")
    fig.text(.09, .908, "CANONICAL MODULES", fontsize=13, fontweight="bold", va="top")
    fig.text(.09, .875, "Compiler features and native support grew the maintained source.",
             fontsize=11.5, color=MUTED, va="top")
    fig.text(.09, .392, "ASSEMBLED NATIVE PROFILES · separate counting boundary", fontsize=12.5,
             fontweight="bold", va="top")
    fig.text(.09, .355, "Includes generated / bundled material and the selected entry point.",
             fontsize=11.5, color=MUTED, va="top")
    native_ax.bar(range(len(native)), [p["physicalLines"] for p in native], width=.38, color=TEAL)
    for i, point in enumerate(native):
        native_ax.text(i, point["physicalLines"] + 1800, f"{point['physicalLines']:,}",
                       ha="center", fontsize=12, color=TEAL, fontweight="bold")
    native_ax.set_xticks(range(len(native)), [f"P{p['phase']}" for p in native], fontsize=10.5)
    native_ax.set_ylim(0, 48000)
    native_ax.set_yticks([0, 20000, 40000], ["0", "20k", "40k"])
    native_ax.grid(axis="y")
    native_ax.set_xlim(-.6, len(native) - .4)
    footnote(fig, "The public CLI is 152 Bend lines; its OS provider and startup add 246 + 19 C lines.\n"
             "Removing runtime interpreter dependencies is a simplicity gain; total source size did not shrink.")
    save(plt, fig, "simplicity",
         "Canonical compiler module source and assembled native profiles are shown in separate panels "
         "on zero-based axes; they are different counting boundaries and are never connected. Canonical "
         f"physical lines reach {latest['physicalLines']}; assembled native profiles reach {native[-1]['physicalLines']}. "
         "Historical physical, nonblank and noncomment code lines remain separate series with missing "
         "observations left unplotted. The public CLI uses 152 Bend lines, 246 OS-provider C lines and "
         "19 startup C lines. Source size is a proxy, not a complete measure of simplicity.")


def conformance(plt, data, save):
    from matplotlib.ticker import FuncFormatter
    from matplotlib.lines import Line2D
    native = data["currentNative"]
    cli = data["nativeCLI"]
    census = data["javascriptCensus"]
    current = data["current"]
    fig = plt.figure(figsize=(9, 11.2))
    ax = fig.add_axes((.12, .714, .82, .148))
    for segment, color in zip(data["segments"], [BLUE, TEAL, GREEN, ORANGE, "#836192", TEAL, GREEN]):
        points = segment["points"]
        ax.plot([p["phase"] for p in points], [p["exact"] / p["total"] * 100 for p in points],
                color=color, linewidth=2.4, marker="o", markersize=5.5)
    latest = data["segments"][-1]["points"][-1]
    ax.set_ylim(70, 105)
    ax.set_xlim(2, latest["phase"] + 2)
    ax.set_xticks([3, 16, 36, 66, latest["phase"]], ["P3", "P16", "P36", "P66", f"P{latest['phase']}"])
    ax.set_yticks([70, 80, 90, 100])
    ax.yaxis.set_major_formatter(FuncFormatter(lambda n, _: f"{n:g}%"))
    ax.axhline(100, color=GREEN, alpha=.3)
    ax.grid(axis="y")
    ax.annotate(f"{latest['exact']:,} / {latest['total']:,}",
                (latest["phase"], latest["exact"] / latest["total"] * 100),
                xytext=(0, -27), textcoords="offset points", ha="right", fontsize=13,
                fontweight="bold", color=ORANGE)
    fig.text(.09, .972, "Conformance · four independent scopes", fontsize=18, fontweight="bold", va="top")
    fig.text(.09, .925, "01   FRONTEND · exact parse / check agreement", fontsize=13.5, fontweight="bold", va="top")
    fig.text(.09, .891, f"P{latest['phase']} · {latest['exact']:,} of {latest['total']:,} exact · axis starts at 70%",
             fontsize=11.5, color=MUTED, va="top")
    fig.text(.12, .681, "Disconnected targets have different denominators. Latest remaining difference:\n"
             "B2 rejects the invalid proof, but its deep diagnostic is shortened after a stack overflow.",
             fontsize=10.5, color=MUTED, linespacing=1.6, va="top")
    for y in (.624, .395, .210):
        fig.add_artist(Line2D([.09, .94], [y, y], transform=fig.transFigure, color=GRID))
    fig.text(.09, .605, f"02   NATIVE · P{native['phase']} candidate04, B1 and B2", fontsize=13.5,
             fontweight="bold", va="top")
    fig.text(.12, .556, f"{native['fixturesPass']} / {native['fixturesTotal']}", fontsize=27,
             fontweight="bold", color=GREEN, va="top")
    fig.text(.52, .556, f"{native['rejectionPass']} / {native['rejectionTotal']}", fontsize=27,
             fontweight="bold", color=GREEN, va="top")
    fig.text(.12, .514, "eligible fixtures · each stage", fontsize=11.5, color=MUTED, va="top")
    fig.text(.52, .514, "expected rejections · each stage", fontsize=11.5, color=MUTED, va="top")
    fig.text(.12, .471, f"{native['broadPrograms']} catalog points (23 sources)  ·  {native['backendObligations']} backend obligations\n"
             f"{native['excluded']} fixture exclusions remain outside the supported native scope.",
             fontsize=11.5, color=MUTED, linespacing=1.7, va="top")
    fig.text(.09, .375, f"03   PUBLIC CLI · P{cli['phase']} standalone release", fontsize=13.5,
             fontweight="bold", va="top")
    fig.text(.12, .330, f"{cli['controlsPass']} / {cli['controlsTotal']}", fontsize=27,
             fontweight="bold", color=GREEN, va="top")
    fig.text(.52, .330, f"{cli['equivalencePass']} / {cli['equivalenceTotal']}", fontsize=27,
             fontweight="bold", color=GREEN, va="top")
    fig.text(.12, .287, "integration controls", fontsize=11.5, color=MUTED, va="top")
    fig.text(.52, .287, "complete C / verdict pairs", fontsize=11.5, color=MUTED, va="top")
    fig.text(.12, .248, "Release and interface checks; the broad compiler suites were not rerun here.",
             fontsize=10.5, color=MUTED, va="top")
    fig.text(.09, .190, f"04   JAVASCRIPT · retained P{census['phase']} fixture census", fontsize=13.5,
             fontweight="bold", va="top")
    fig.text(.12, .144, f"{census['goldenPasses']:,}", fontsize=27, fontweight="bold", color=TEAL, va="top")
    fig.text(.35, .140, "golden passes across the Node / Bun census\n"
             f"{census['exempt']} exemptions · {census['sharedFailure']} shared failure · {census['deferred']} deferral",
             fontsize=11.5, color=MUTED, linespacing=1.7, va="top")
    footnote(fig, "Different suites answer different questions. Their counts are never added into one pass rate.\n"
             "Checked laws and finite production contracts are reported separately; they do not prove the compiler.", y=.026)
    save(plt, fig, "conformance",
         f"Four independent conformance scopes: Phase{latest['phase']} exact frontend agreement "
         f"{latest['exact']} of {latest['total']}; Phase{native['phase']} native B1 and B2 each pass "
         f"{native['fixturesPass']} eligible fixtures and {native['rejectionPass']} expected rejections, with "
         f"{native['excluded']} excluded fixtures; Phase{cli['phase']} CLI passes {cli['controlsPass']} "
         f"integration controls and {cli['equivalencePass']} complete C/verdict pairs; retained JavaScript "
         f"census has {census['goldenPasses']} golden passes. These are separately denominated evidence, "
         "not a combined all-language pass rate. B2's deep frontend diagnostic remains shortened.")


def render(plt, data, save):
    execution_history(plt, data["execution"], save)
    execution_programs(plt, data["execution"], save)
    for key, stage in (("secondStage", "B2"), ("compilation", "B1")):
        compiler_history(plt, data[key], stage, save)
        compiler_programs(plt, data[key], stage, save)
