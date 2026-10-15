#!/usr/bin/env python3
"""Export completed Phase98 receipts; reads data only and launches no targets."""
import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / "selfhost/build/phase98"
RECEIPTS = {}


def require(ok, message):
    if not ok:
        raise ValueError(message)


def pin(path):
    path = (ROOT / path).resolve()
    data = path.read_bytes()
    return {"file": str(path.relative_to(ROOT)), "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)}


def verify(value):
    actual = pin(value["file"])
    require(all(actual[k] == value[k] for k in ("sha256", "bytes")), f"changed input: {value['file']}")
    return actual


def read(key, path, sources=(), checked=True):
    path = (ROOT / path).resolve()
    data = json.loads(path.read_text())
    if checked:
        require(data.get("complete") is True, f"incomplete: {path}")
        require(data.get("passed", data.get("qualified", True)) is True, f"failed: {path}")
        require(data.get("inputsUnchanged", True) is True, f"changed inputs: {path}")
    RECEIPTS[key] = {**pin(path), "compilerSources": [verify(s) for s in sources]}
    return data


def same_source(actual, expected):
    require(verify(actual)["sha256"] == verify(expected)["sha256"], "compiler/source identity mismatch")


def screen(key, stage, source, baseline):
    data = read(key, BUILD / f"origin-{stage}-screen01/report.json", [source, baseline])
    producer = data["candidate"] if stage == "b1" else data["producers"]["candidate"]
    same_source(producer["source"], source)
    old = data["baseline"] if stage == "b1" else data["producers"]["baseline"]
    same_source(old["source"], baseline)
    require(len(data["rows"]) == 48 and data["rounds"] == 4, "screen coverage")
    require(all(r["passed"] and r["exactC"] and r["diagnosticExact"] for r in data["rows"]), "screen observations")
    return {"receipt": key, "cases": 6, "pairsPerCase": 4,
            "candidateOverBaseline": data["summary"]["equalCaseGeometricRatios"],
            "aggregation": "Equal-case geometric mean of per-case ratios of medians.", "scope": data["scope"]}


def self_row(key, directory, source, compiler):
    data = read(key, BUILD / directory / "report.json", [compiler])
    same_source(data["source"], source)
    same_source(data["producer"]["source"], compiler)
    require(data["row"]["passed"] and data["row"].get("diagnosticExact", data["row"].get("referenceDiagnosticCaptured")), "self observation")
    RECEIPTS[key]["inputSource"] = verify(source)
    RECEIPTS[key]["diagnostic"] = verify(data["row"]["diagnosticFile"])
    return {k: data["row"][k] for k in ("requestMs", "processWallMs")}


def historical_runtime(baseline):
    cases = {}
    for name in ("measure-pilot01", "measure-broad01"):
        data = read(name, ROOT / "selfhost/build/phase93" / name / "report.json", [baseline])
        for acquisition in data["acquired"]:
            verify(acquisition)
            acquired = read(name + "-acquisition", acquisition["file"], [baseline])
            same_source(acquired["authentication"]["source"], baseline)
            require(all(c["passed"] for c in acquired["cases"]), "historical acquisition")
        for r in data["records"]:
            require(r["correct"] and r["qualified"] and r["job"]["process"]["complete"] and
                    r["job"]["process"]["returncode"] == 0, "historical runtime observation")
            verify(r["child"])
            cases.setdefault(r["case"], {}).setdefault(r["role"], []).append(r["elapsedMs"] / r["repetitions"])
    require(len(cases) == 44 and all(set(v) == {"own", "upstream"} and
            all(len(x) == 3 for x in v.values()) for v in cases.values()), "historical runtime coverage")
    ratios = {k: statistics.median(v["own"]) / statistics.median(v["upstream"]) for k, v in sorted(cases.items())}
    return {"timingPhase": 93, "qualifiedCases": 44, "pairsPerCase": 3,
            "nativeOverUpstreamCGeometricRatio": math.exp(statistics.mean(map(math.log, ratios.values()))),
            "perCaseNativeOverUpstreamRatio": ratios,
            "scope": "Historical own-native vs TypeScript-emitted C, normalized elapsed batch ms/repetitions; 44 qualified cases, zero-work control excluded. No Phase98 runtime timing or JS-target retest."}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, default=ROOT / "implementation/phase98/results.json")
    parser.add_argument("--svg", type=Path, default=ROOT / "implementation/phase98/request-times.svg")
    args = parser.parse_args()
    admission = read("admission", BUILD / "origin-admission01/report.json")
    source = verify(admission["source"])
    baseline = pin(ROOT / "selfhost/build/phase92/upstream-checked01/compiler.bend")
    RECEIPTS["admission"]["compilerSources"] = [source]
    for stage in admission["stages"].values():
        same_source(stage["source"], source)
        verify(stage["binary"])
    performance = {s: screen(s + "Screen", s, source, baseline) for s in ("b1", "b2")}
    old = self_row("b1SelfBaseline", "origin-baseline-b1-reference01", source, baseline)
    new = self_row("b1SelfCandidate", "origin-b1-self01", source, source)
    require(RECEIPTS["b1SelfBaseline"]["diagnostic"]["sha256"] == RECEIPTS["b1SelfCandidate"]["diagnostic"]["sha256"], "B1 same-input diagnostic")
    performance["b1FullSelf"] = {"baseline": old, "candidate": new, "samplesPerCompiler": 1,
                               "candidateOverBaseline": {k: new[k] / old[k] for k in old}, "inputSource": source}
    pairs = read("b2SelfPairs", BUILD / "origin-b2-self-pairs01/report.json", [source, baseline])
    same_source(pairs["source"], source)
    require(pairs["rounds"] == 2 and len(pairs["rows"]) == 4, "self pair coverage")
    for row in pairs["rows"]:
        same_source(row["source"], source)
        require(row["passed"] and row["exactC"] and row["diagnosticExact"], "self pair")
    performance["b2FullSelf"] = {"samplesPerCompiler": 2, "inputSource": source,
                                "metrics": pairs["summary"]["cases"]["candidate-self"]}
    performance["clockScope"] = "Cached native request excludes preparation; process wall includes startup/preparation/write/teardown. Full-self comparisons compile the same candidate source with the same full diagnostic. B2 pairs check each producer's own full C oracle; B1 n=1 is a single comparison, with candidate C qualified separately."
    ts = read("tsContext", BUILD / "origin-ts-self-plan01/report.json", [source])
    same_source(ts["source"], source)
    require(len(ts["rows"]) == 2 and all(r["exactC"] for r in ts["rows"]), "TS observations")
    for context in ts["nativeContext"]:
        verify(context["receipt"])
        native = read("tsNative-" + context["stage"], context["receipt"]["file"], [source])
        same_source(native["source"], source)
        same_source(native["producer"]["source"], source)
    broad = read("broad45", BUILD / "origin-broad45-native01/report.json", [source])
    conform = read("native69", BUILD / "origin-conformance02/collected.json", [source])
    verify(admission["receipts"]["broad45"][0]); verify(admission["receipts"]["conformance"])
    require(len(broad["programs"]) == 45 and all(p["passed"] for p in broad["programs"]), "broad programs")
    require(conform["counts"]["eligiblePerRole"] == 69 and conform["counts"]["excludedPerRole"] == 31, "conformance coverage")
    continuity = read("continuity", BUILD / "origin-batch-continuity01/report.json", [source])
    same_source(continuity["producer"]["source"], source)
    require(continuity["allHistoricalCExact"] and continuity["counts"] == {"emissions": 45, "exactC": 45, "changedC": 0}
            and continuity["runtimeMeasurementPerformed"] is False, "continuity scope")
    sizes = read("sourceSize", BUILD / "source-size01.json", [source, baseline], checked=False)
    require(sizes["canonicalUnchangedFromBaseline"] is True, "canonical source changed")
    for item in sizes["canonicalInputs"]:
        verify(item)
    require(len(sizes["canonicalInputs"]) == sizes["canonicalModules"] and
            sum(p["lines"] for p in sizes["canonicalInputs"]) == sizes["canonicalPhysicalLines"], "source count")
    for key, value in (("baseline", baseline), ("candidate", source)):
        require(sizes[key] == {"bytes": value["bytes"], "physicalLines": len((ROOT / value["file"]).read_text().splitlines())}, "source size")
    result = {"kind": "phase98-results-scoreboard", "complete": True, "dataOnly": True, "targetsLaunched": 0,
              "source": source, "baselineSource": baseline, "method": pin(Path(__file__)),
              "compilerPerformance": performance,
              "typescriptContext": {"freshProcesses": 2, "callsPerProcess": 1, "mediansMs": ts["mediansMs"],
                                    "nativeContext": ts["nativeContext"], "clockScope": ts["scope"]},
              "correctness": {"broad45": broad["counts"], "native69": conform["counts"], "scope": conform["scope"]},
              "sourceSize": {k: v for k, v in sizes.items() if k != "canonicalInputs"},
              "programRuntime": {"artifactContinuity": continuity["counts"], "newRuntimeTiming": False,
                                 "continuityScope": continuity["scope"], "historicalTiming": historical_runtime(baseline)},
              "receipts": RECEIPTS}
    bars = [("B1 baseline (n=1)", old["requestMs"]), ("B1 candidate (n=1)", new["requestMs"]),
            ("B2 baseline (n=2 median)", pairs["summary"]["cases"]["candidate-self"]["requestMs"]["medians"]["baseline"]),
            ("B2 candidate (n=2 median)", pairs["summary"]["cases"]["candidate-self"]["requestMs"]["medians"]["candidate"]),
            ("TS/Bun (n=2 median; contextual)", ts["mediansMs"]["requestMs"])]
    svg = ['<svg xmlns="http://www.w3.org/2000/svg" width="900" height="340" viewBox="0 0 900 340" role="img">',
           '<title>Same-source full compiler request seconds</title><rect width="900" height="340" fill="white"/>',
           '<g font-family="sans-serif" font-size="14" fill="#172033"><text x="20" y="28" font-size="20">Full-source request time (seconds; lower is faster)</text>']
    for i, (label, ms) in enumerate(bars):
        y = 63 + i * 44
        svg += [f'<text x="20" y="{y + 18}">{label}</text><rect x="280" y="{y}" width="{ms / 320:.2f}" height="26" fill="{("#5278a5" if i % 2 == 0 else "#218475")}"/><text x="{290 + ms / 320:.2f}" y="{y + 18}">{ms / 1000:.3f}</text>']
    svg += ['<text x="20" y="303">TS request includes ordinary Base work; native requests use prepared Base outside the clock.</text>',
            '<text x="20" y="325">Separate observed scopes; no confidence interval or matched TS speedup claim.</text></g></svg>']
    args.svg.parent.mkdir(parents=True, exist_ok=True)
    args.svg.write_text("\n".join(svg) + "\n")
    result["visualization"] = pin(args.svg)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"complete": True, "output": pin(args.out), "visualization": result["visualization"]}))


if __name__ == "__main__":
    main()
