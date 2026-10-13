#!/usr/bin/env python3
"""Offline, CPU-affinity-neutral attribution of Phase85 Node trace evidence.

Run under taskset -c 0. This script launches no target workloads. Trace clocks
are matched by explicit P85_CLOCK job+pid, never filename order or mtime.
"""
import argparse
import collections
import hashlib
import json
from pathlib import Path


def read(path):
    return json.loads(path.read_text())


def pin(path):
    data = path.read_bytes()
    return {"file": str(path.resolve()), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def union(intervals):
    result = []
    for start, end in sorted(intervals):
        if end <= start:
            continue
        if result and start <= result[-1][1]:
            result[-1][1] = max(result[-1][1], end)
        else:
            result.append([start, end])
    return result


def length(intervals):
    return sum(end - start for start, end in union(intervals))


def overlap_length(left, right):
    left, right = union(left), union(right)
    i = j = total = 0
    while i < len(left) and j < len(right):
        total += max(0, min(left[i][1], right[j][1]) - max(left[i][0], right[j][0]))
        if left[i][1] < right[j][1]:
            i += 1
        else:
            j += 1
    return total


def slices(events):
    """Retain X slices and reconstruct matched B/E slices per OS thread."""
    result, stacks = [], collections.defaultdict(list)
    for event in events:
        phase = event.get("ph")
        if phase == "X":
            result.append(event)
        elif phase == "B":
            stacks[event["tid"]].append(event)
        elif phase == "E":
            stack = stacks[event["tid"]]
            if not stack:
                raise ValueError("Unmatched trace end")
            start = stack.pop()
            if event.get("name") and event["name"] != start["name"]:
                raise ValueError("Mismatched trace begin/end")
            result.append({**start, "ph": "X", "dur": event["ts"] - start["ts"],
                           "tdur": event["tts"] - start["tts"]})
    if any(stacks.values()):
        raise ValueError("Unclosed trace begin")
    for event in result:
        if event["dur"] < 0 or event["tdur"] < 0:
            raise ValueError("Negative trace duration")
    return result


def cpu_intervals(events):
    out = collections.defaultdict(list)
    for event in events:
        out[event["tid"]].append((event["tts"], event["tts"] + event["tdur"]))
    return out


def group(events, start, end):
    relevant = [e for e in events if e["ts"] < end and e["ts"] + e["dur"] > start]
    inside = [e for e in relevant if e["ts"] >= start and e["ts"] + e["dur"] <= end]
    crossing = [e for e in relevant if e["ts"] < start or e["ts"] + e["dur"] > end]
    lower, upper = cpu_intervals(inside), cpu_intervals(relevant)
    by_thread = {str(tid): {"containedCpuMs": length(lower[tid]) / 1000,
                            "overlappingWholeSlicesCpuMs": length(upper[tid]) / 1000}
                 for tid in sorted(set(lower) | set(upper))}
    by_name = collections.defaultdict(lambda: {"count": 0, "inclusiveCpuMs": 0})
    for event in inside:
        by_name[event["name"]]["count"] += 1
        by_name[event["name"]]["inclusiveCpuMs"] += event["tdur"] / 1000
    return {"containedCpuMs": sum(length(v) for v in lower.values()) / 1000,
            "overlappingWholeSlicesCpuMs": sum(length(v) for v in upper.values()) / 1000,
            "containedEventCount": len(inside), "byThread": by_thread,
            "byNameInclusiveNotAdditive": dict(sorted(by_name.items())),
            "boundaryCrossing": [{k: e[k] for k in ("name", "tid", "ts", "dur", "tts", "tdur", "bind_id") if k in e}
                                 for e in crossing]}, lower, upper


def summarize_phase(events, main_tid, start, end):
    compile_events = [e for e in events if "disabled-by-default-v8.compile" in e["cat"].split(",")]
    main = [e for e in compile_events if e["tid"] == main_tid]
    tf = [e for e in compile_events if e["tid"] != main_tid and e["name"] == "V8.OptimizeBackground"]
    maglev = [e for e in compile_events if e["tid"] != main_tid and e["name"] == "V8.MaglevBackground"]
    gc = [e for e in events if e["tid"] == main_tid and
          (e["name"].startswith("V8.GC") or e["name"] in ("MinorGC", "MajorGC"))]
    output = {"startHrtimeUs": start, "endHrtimeUs": end, "markerWallMs": (end - start) / 1000}
    sets = {}
    for name, selected in (("mainCompile", main), ("backgroundTurboFan", tf),
                           ("backgroundMaglev", maglev), ("mainGc", gc)):
        output[name], low, high = group(selected, start, end)
        sets[name] = (low[main_tid], high[main_tid])
    # Compile slices can include nested GC. Remove observed GC conservatively
    # when reporting compile-only bounds; never add both inclusive totals.
    compile_low, compile_high = sets["mainCompile"]
    gc_low, gc_high = sets["mainGc"]
    output["mainCompileExcludingObservedGcCpuMs"] = {
        "lower": (length(compile_low) - overlap_length(compile_low, gc_high)) / 1000,
        "upper": (length(compile_high) - overlap_length(compile_high, gc_low)) / 1000,
    }
    main_bounds = output["mainCompileExcludingObservedGcCpuMs"]
    output["attributedCompileCpuMs"] = {
        "lower": main_bounds["lower"] + output["backgroundTurboFan"]["containedCpuMs"] + output["backgroundMaglev"]["containedCpuMs"],
        "upper": main_bounds["upper"] + output["backgroundTurboFan"]["overlappingWholeSlicesCpuMs"] + output["backgroundMaglev"]["overlappingWholeSlicesCpuMs"],
    }
    output["largestBackgroundJobsOverlappingPhase"] = [
        {k: e[k] for k in ("name", "tid", "ts", "dur", "tts", "tdur", "bind_id") if k in e}
        for e in sorted(tf + maglev, key=lambda e: e["tdur"], reverse=True)
        if e["ts"] < end and e["ts"] + e["dur"] > start][:10]
    return output


def records(path, prefix):
    return [json.loads(line[len(prefix):]) for line in path.read_text().splitlines() if line.startswith(prefix)]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run_dir", type=Path)
    parser.add_argument("output_json", type=Path)
    parser.add_argument("output_md", type=Path)
    args = parser.parse_args()
    trace_by_pid = {}
    for path in sorted(args.run_dir.glob("timeline-*.json")):
        events = read(path)["traceEvents"]
        pids = {e["pid"] for e in events}
        if len(pids) != 1:
            raise ValueError(f"Ambiguous trace process: {path}")
        pid = pids.pop()
        if pid in trace_by_pid:
            raise ValueError(f"Duplicate trace process: {pid}")
        trace_by_pid[pid] = (path, events)
    result = {"kind": "phase85-offline-thread-cpu-attribution", "method": pin(Path(__file__)),
              "runDirectory": str(args.run_dir.resolve()), "jobs": [], "limitations": [
        "Diagnostic traced runs, not clean benchmark clocks or additive removable costs.",
        "CPU unions are computed separately per OS tid using tts/tdur; nested events are not double counted.",
        "Boundary-straddling slices yield lower/upper attribution bounds; no wall-time prorating.",
        "Main compilation category includes tier decisions and code finalization; observed nested GC is subtracted for compile-only bounds.",
        "Background accounting includes job-execution scopes only, excludes task-wrapper overhead and uninstrumented Sparkplug compilation.",
        "Import process-CPU denominator was not recorded; request CPU comes from the near-boundary P85_CPU observer.",
        "Unattributed CPU is not proven JavaScript execution and observed JIT CPU is not guaranteed removable without execution regressions.",
    ]}
    for report_path in sorted((args.run_dir / "runs").glob("*/report.json")):
        report = read(report_path)
        job = report["job"]["name"]
        guard = report_path.parent.parent / (job + "-guard")
        stdout = guard / "stdout.log"
        clocks = records(stdout, "P85_CLOCK ")
        if not clocks or {c["job"] for c in clocks} != {job} or len({c["pid"] for c in clocks}) != 1:
            raise ValueError(f"Missing/ambiguous explicit clock identity: {job}")
        pid = clocks[0]["pid"]
        trace_path, raw_events = trace_by_pid[pid]
        mains = {e["tid"] for e in raw_events if e["ph"] == "M" and
                 e["name"] == "thread_name" and e["args"].get("name") == "JavaScriptMainThread"}
        if len(mains) != 1:
            raise ValueError(f"Missing main-thread metadata: {job}")
        main_tid = mains.pop()
        events = slices(raw_events)
        marks = {(c["phase"], c["call"]): c for c in clocks}
        if len(marks) != len(clocks):
            raise ValueError(f"Duplicate clock marks: {job}")
        if not all(min(e["ts"] for e in events) <= c["hrtimeUs"] <= max(e["ts"] + e["dur"] for e in events) for c in clocks):
            raise ValueError(f"Clock outside trace time domain: {job}")
        job_result = {"job": report["job"], "pid": pid, "mainTid": main_tid,
                      "report": pin(report_path), "trace": pin(trace_path), "clockLog": pin(stdout),
                      "pass": report["pass"], "exactC": all(c["exactC"] for c in report["calls"]), "phases": {}}
        process_cpu = {c["call"]: (c["cpu"]["user"] + c["cpu"]["system"]) / 1000 for c in records(stdout, "P85_CPU ")}
        for phase, call, stopwatch in [("import", 0, report["importsMs"])] + [
                ("request", c["call"], c["requestMs"]) for c in report["calls"]]:
            start, end = marks[(phase + "-start", call)]["hrtimeUs"], marks[(phase + "-end", call)]["hrtimeUs"]
            row = summarize_phase(events, main_tid, start, end)
            row["workerStopwatchMs"] = stopwatch
            row["markerMinusStopwatchMs"] = row["markerWallMs"] - stopwatch
            row["processCpuMs"] = process_cpu.get(call) if phase == "request" else None
            if row["processCpuMs"]:
                row["attributedCompileShareOfProcessCpuBounds"] = {
                    k: v / row["processCpuMs"] for k, v in row["attributedCompileCpuMs"].items()}
            job_result["phases"][phase if phase == "import" else f"request{call}"] = row
        result["jobs"].append(job_result)
    if not result["jobs"]:
        raise ValueError("No complete job reports")
    result["comparisons"] = []
    by_case = collections.defaultdict(dict)
    for job in result["jobs"]:
        by_case[job["job"]["case"]][job["job"]["role"]] = job["phases"]["request1"]
    for case, roles in sorted(by_case.items()):
        if "b2" not in roles or "typescript" not in roles:
            continue
        b2, ts = roles["b2"], roles["typescript"]
        cpu_gap = b2["processCpuMs"] - ts["processCpuMs"]
        compile_gap_low = b2["attributedCompileCpuMs"]["lower"] - ts["attributedCompileCpuMs"]["upper"]
        compile_gap_high = b2["attributedCompileCpuMs"]["upper"] - ts["attributedCompileCpuMs"]["lower"]
        result["comparisons"].append({"case": case, "processCpuGapMs": cpu_gap,
            "attributedCompileCpuGapMs": {"lower": compile_gap_low, "upper": compile_gap_high},
            "compileGapShareOfProcessCpuGap": None if cpu_gap <= 0 else {
                "lower": compile_gap_low / cpu_gap, "upper": compile_gap_high / cpu_gap},
            "notAttributedToTracedCompilationCpuMs": {
                role: {"lower": row["processCpuMs"] - row["attributedCompileCpuMs"]["upper"],
                       "upper": row["processCpuMs"] - row["attributedCompileCpuMs"]["lower"]}
                for role, row in roles.items()}})
    args.output_json.parent.mkdir(parents=True, exist_ok=True)
    args.output_json.write_text(json.dumps(result, indent=2) + "\n")
    lines = ["# Phase85: direct V8 thread CPU attribution", "",
             "Offline analysis of one traced request per role/case. All times below are milliseconds; these are diagnostic observations, not clean speedups.", "",
             "| Case / role | Phase | Worker wall | Process CPU | Main compile CPU¹ | Background TF CPU² | Background Maglev CPU² | Total traced compile CPU² |",
             "|---|---|---:|---:|---:|---:|---:|---:|"]
    def bounds(low, high):
        return f"{low:.1f}" if abs(low - high) < 0.05 else f"{low:.1f}–{high:.1f}"
    for job in result["jobs"]:
        for phase, row in job["phases"].items():
            main = row["mainCompileExcludingObservedGcCpuMs"]
            tf, mag = row["backgroundTurboFan"], row["backgroundMaglev"]
            total = row["attributedCompileCpuMs"]
            cpu = "not recorded" if row["processCpuMs"] is None else f"{row['processCpuMs']:.1f}"
            lines.append(f"| {job['job']['case']} / {job['job']['role']} | {phase} | {row['workerStopwatchMs']:.1f} | {cpu} | {bounds(main['lower'], main['upper'])} | {bounds(tf['containedCpuMs'], tf['overlappingWholeSlicesCpuMs'])} | {bounds(mag['containedCpuMs'], mag['overlappingWholeSlicesCpuMs'])} | {bounds(total['lower'], total['upper'])} |")
    lines += ["", "¹ Main compilation-category CPU union excludes observed nested GC; includes tier decisions and finalization.",
              "² Lower/upper ranges arise from slices crossing a phase boundary. No CPU is prorated by wall overlap. Task envelopes and nested job phases are not added twice.", "",
              "Each trace is bound to its report by explicit P85_CLOCK job and process ID. Clock marks use process.hrtime microseconds, the documented Node trace time source. Main OS thread IDs come from trace metadata. Detailed hashes, per-thread counters, boundary-crossing slices and largest background jobs are in timeline.json.", "",
              "Limits: import process CPU was not recorded; background Sparkplug has no equivalent scope; tracing and clock logging perturb execution; JIT CPU is not automatically a removable latency gain. The residual includes execution, untraced compilation, GC and other runtime work. Named optimization jobs require additional same-run identity instrumentation; flow IDs alone do not name functions.", ""]
    for comparison in result["comparisons"]:
        gap = comparison["attributedCompileCpuGapMs"]
        share = comparison["compileGapShareOfProcessCpuGap"]
        share_text = "" if share is None else f" ({bounds(100 * share['lower'], 100 * share['upper'])}% of the observed process-CPU gap)"
        lines.append(f"For {comparison['case']}, the B2-minus-TypeScript process-CPU gap is {comparison['processCpuGapMs']:.1f} ms. The directly attributed compilation difference is {bounds(gap['lower'], gap['upper'])} ms{share_text}. This is attribution within one instrumented pair, not a forecast of achievable speedup.")
        lines.append("")
    lines += ["The two mechanisms to separate next are extra first-use parse/bytecode work and extra TurboFan compilation. Maglev CPU is similar between roles in these pairs. A change must still demonstrate clean request gains: avoiding compilation can make subsequent JavaScript execution slower.", "",
              "The earlier timeline01 traces lack request clock markers and cannot support phase attribution. Node 24.18.0's performance.mark implementation does not emit the requested usertiming trace events. The v2 preload supplies explicit job/PID/hrtime markers; no trace-file ordering is used.", ""]
    args.output_md.parent.mkdir(parents=True, exist_ok=True)
    args.output_md.write_text("\n".join(lines))
    print(json.dumps({"jobs": len(result["jobs"]), "output": str(args.output_json), "notes": str(args.output_md)}))


if __name__ == "__main__":
    main()
