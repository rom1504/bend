#!/usr/bin/env python3
"""Approximate sampled-thread CPU timeline from authenticated ordered captures.

No target execution and no new symbolization path. Ordinal * timer period is an
approximation relative to sampling start, never a wall-clock timestamp. Missing
identity, delivery or coverage guarantees preserve ordinal windows only.
"""
import argparse
import collections
import json
import math
from pathlib import Path

import analyze
import attribute


def cpu_clock(header, attribution):
    reasons = []
    quality = attribution["quality"]
    if not attribution.get("pairing", {}).get("verified"):
        reasons.append("Runner receipt does not authenticate the paired capture")
    if header.get("dropped") != 0 or header.get("overruns") != 0 or not quality.get("zero_loss"):
        reasons.append("Lost samples or timer overruns make ordinal CPU spacing unreliable")
    for name in ("handler_intact", "main_thread_shutdown", "thread_lifecycle_complete",
                 "near_complete_process_cpu_coverage", "delivery_plausible"):
        if not quality.get(name):
            reasons.append("Capture quality condition failed: " + name)
    if quality.get("scope") != "main_thread":
        reasons.append("Only a single sampled-thread sequence is supported")
    return {"available": not reasons, "reasons": reasons,
            "coordinate": "sample ordinal multiplied by period; relative to sampling start",
            "isWallTime": False, "isMeasuredTimestamp": False,
            "limitations": ["Delivery jitter and sampling aliasing remain possible without reported loss.",
                            "Sampling-start zero is not process-start zero or a compiler phase boundary.",
                            "Suspension, I/O waits and other-thread execution are not wall-clock gaps here."]}


def windows(events, header, attribution, *, window_cpu_seconds=25.0, window_samples=None, top=8):
    period = header.get("period_us")
    if type(period) is not int or period <= 0:
        raise ValueError("Positive integer sampling period required")
    if type(top) is not int or top < 1:
        raise ValueError("top must be positive")
    if type(header.get("samples")) is not int or header["samples"] != len(events):
        raise ValueError("Ordered-event count differs from capture")
    if any(event.get("sample") != index for index, event in enumerate(events)):
        raise ValueError("Ordered-event sequence is missing, duplicated or reordered")
    if window_samples is None:
        if not math.isfinite(window_cpu_seconds) or window_cpu_seconds <= 0:
            raise ValueError("Window CPU seconds must be finite and positive")
        width = max(1, round(window_cpu_seconds * 1e6 / period))
    else:
        if type(window_samples) is not int or window_samples < 1:
            raise ValueError("Window sample count must be positive")
        width = window_samples
    clock = cpu_clock(header, attribution)
    contexts = bool((attribution.get("contextHeader") or {}).get("context_available"))
    owner_available = contexts and attribution.get("ownerBinding") is not None
    result = []
    for start in range(0, len(events), width):
        chunk = events[start:start + width]
        leaves, owners, fids = collections.Counter(), collections.Counter(), collections.Counter()
        unknown_leaf, unknown_owner, known_context = 0, 0, 0
        for event in chunk:
            leaf, context = event["leaf"], event.get("dispatchContext") or {}
            symbol = leaf.get("symbol")
            leaves[(leaf.get("object"), symbol, leaf.get("decoded") or symbol)] += 1
            unknown_leaf += symbol is None
            owner = context.get("loweredOwner")
            owners[owner] += 1
            unknown_owner += owner is None
            fids[context.get("fid")] += 1
            known_context += context.get("fid") is not None
        count = len(chunk)
        window = {"index": len(result), "sampleStart": start, "sampleEndExclusive": start + count,
                  "samples": count, "lowSampleCount": count < 20,
                  "unknownPhysicalLeafSamples": unknown_leaf,
                  "unknownActiveOwnerSamples": unknown_owner, "knownDispatchSamples": known_context,
                  "topPhysicalLeaves": [{"object": key[0], "symbol": key[1], "decoded": key[2],
                                         "samples": value, "fractionOfWindow": value / count}
                                        for key, value in leaves.most_common(top)],
                  "topActiveOwners": [{"owner": key, "samples": value, "fractionOfWindow": value / count}
                                      for key, value in owners.most_common(top)] if owner_available else [],
                  "topDispatchFids": [{"fid": key, "samples": value, "fractionOfWindow": value / count}
                                      for key, value in fids.most_common(top)] if contexts else []}
        if clock["available"]:
            window.update(approximateCpuStartSeconds=start * period / 1e6,
                          approximateCpuEndSeconds=(start + count) * period / 1e6)
        result.append(window)
    return {"schema": "bend-sampled-cpu-timeline-v1", "clock": clock,
            "periodUs": period, "samples": len(events), "windowSamples": width,
            "requestedWindowCpuSeconds": window_cpu_seconds if window_samples is None else None,
            "approximateWindowCpuSeconds": width * period / 1e6 if clock["available"] else None,
            "activeDispatchAvailable": contexts, "activeOwnerAvailable": owner_available,
            "windows": result,
            "limitations": ["Windows preserve capture order, including unknown physical leaves and dispatch contexts.",
                            "Displayed top lists are truncated; every fraction uses all samples in its window.",
                            "Active dispatch ownership is not an inclusive logical stack or allocation-origin record.",
                            "Changing dominant names suggests changing computations; compiler phases are not inferred.",
                            "Short windows are descriptive; no confidence intervals or speedup claims are implied."]}


def markdown(report):
    def escape(value):
        return str(value).replace("|", "\\|").replace("\n", " ").replace("`", "'")
    def ranked(rows, key):
        return "; ".join("%s %.1f%%" % (escape(row[key] or "[unknown]"), row["fractionOfWindow"] * 100)
                         for row in rows[:3]) or "unavailable"
    available = report["clock"]["available"]
    lines = ["# " + ("Approximate sampled-thread CPU timeline" if available else "Ordered sample windows; CPU timeline unavailable"), "",
             "Coordinates are approximate sampled-thread CPU seconds from sampling start, never wall timestamps." if available else
             "CPU coordinates were suppressed: " + "; ".join(report["clock"]["reasons"]), "",
             "Physical leaves and active Bend owners are separate observations. Unknown samples remain in each denominator.", "",
             "| Window | Samples | Top physical leaves | Top active owners | Unknown leaf / owner |",
             "| --- | ---: | --- | --- | ---: |"]
    for row in report["windows"]:
        label = ("%.3f–%.3f s" % (row["approximateCpuStartSeconds"], row["approximateCpuEndSeconds"])) if available else (
            "samples %d–%d" % (row["sampleStart"], row["sampleEndExclusive"] - 1))
        lines.append("| %s | %d | %s | %s | %d / %d |" % (label, row["samples"],
            ranked(row["topPhysicalLeaves"], "decoded"), ranked(row["topActiveOwners"], "owner"),
            row["unknownPhysicalLeafSamples"], row["unknownActiveOwnerSamples"]))
    lines += ["", "Active owners are execution contexts, not inclusive stacks. Window boundaries do not establish compiler phases.", ""]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--analysis", type=Path, required=True)
    for name in ("contexts", "owners", "callers", "table"):
        parser.add_argument("--" + name, type=Path)
    width = parser.add_mutually_exclusive_group()
    width.add_argument("--window-cpu-seconds", type=float, default=None)
    width.add_argument("--window-samples", type=int)
    parser.add_argument("--top", type=int, default=8)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    try:
        if args.out.exists():
            raise ValueError("Output directory must be fresh")
        attribution, events = attribute.attribute(args.analysis, args.callers, args.table, args.contexts, args.owners)
        capture = attribution["identities"]["capture"]
        header, _, _ = analyze.parse_capture(attribute.checked_pin(capture)["file"])
        result = windows(events, header, attribution,
                         window_cpu_seconds=args.window_cpu_seconds if args.window_cpu_seconds is not None else 25.0,
                         window_samples=args.window_samples, top=args.top)
        result.update(identities={**attribution["identities"], "timeline": analyze.pin(__file__)},
                      pairing=attribution["pairing"], quality=attribution["quality"],
                      ownerBinding=attribution.get("ownerBinding"))
        args.out.mkdir(parents=True)
        (args.out / "timeline.json").write_text(json.dumps(result, indent=2) + "\n")
        (args.out / "timeline.md").write_text(markdown(result))
        print(json.dumps({"output": str(args.out), "samples": result["samples"],
                          "windows": len(result["windows"]), "cpuCoordinatesAvailable": result["clock"]["available"]}))
    except (ValueError, OSError, KeyError) as error:
        parser.exit(2, "timeline: %s\n" % error)


if __name__ == "__main__":
    main()
