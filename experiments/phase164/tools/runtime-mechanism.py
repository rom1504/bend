#!/usr/bin/env python3
"""Offline retained-product audit; does not execute compiler or workload images."""
import collections
import hashlib
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[3]
CASES = {
    "mandelbrot": ["p113d_FID_$direct.mit", "p113d_FID_$direct.hchunk",
                   "p113d_FID_$direct.rpix", "p111_FID_$direct.hfold",
                   "p111_FID_$direct.rcol", "p112w_FID_$direct.hchunk",
                   "p112w_FID_$direct.rpix"],
    "coverage-unicode-text-16": ["p113d_FID_$p118.trmc.$direct.String.append",
                                "p114r_FID_$direct.ssplit",
                                "p114r_FID_$direct.p37.text.repeat",
                                "p111_FID_$p111.k.53073", "p111_FID_$p111.k.53076",
                                "p111_FID_$p111.k.52710", "p111_FID_$p111.k.52713",
                                "p112w_FID_$direct.String.append"],
    "editdist": ["p113d_FID_$direct.row", "p113d_FID_$product.row",
                 "p113d_FID_$direct.pair", "p113d_FID_$direct.dp",
                 "p114r_FID_$direct.batch", "p112w_FID_$direct.pair"],
}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    data = path.read_bytes()
    return {"file": str(path.relative_to(ROOT)), "bytes": len(data), "sha256": sha(data)}


def decode(text):
    return re.sub(r"(?<=FID_)(?:\d+_)+", lambda m: "".join(
        chr(int(x)) for x in m[0].strip("_").split("_")), text)


def labels_only(text):
    labels = {}
    return re.sub(r"\.Lbb\d+", lambda m: ".LOCAL" + str(
        labels.setdefault(m[0], len(labels))), text)


def main():
    report_path = ROOT / "selfhost/build/phase164/transfer-machine01/report.json"
    report = json.loads(report_path.read_text())
    result = {"method": "Offline exact SSA worker equality; assembly equality normalizes only .Lbb numeric labels. Counts are static, not execution counts.",
              "inputs": [pin(report_path), pin(ROOT / "selfhost/build/phase164/transfer01/report.json"),
                         pin(ROOT / "selfhost/build/phase164/hybrid-api-source01/compiler.bend")],
              "cases": []}
    for name, selected in CASES.items():
        timing = next(r for r in report["rows"] if r["name"] == name)
        row = {"name": name, "medianMilliseconds": timing["medianMilliseconds"],
               "runtimeRatio": timing["runtimeRatio"], "products": {}}
        for role in ("baseline", "candidate"):
            sp = ROOT / f"selfhost/build/phase164/transfer01/{name}-{role}.ssa"
            machine = ROOT / f"selfhost/build/phase164/transfer-machine01/{name}-{role}"
            text = sp.read_text()
            fs = {decode(m[1]): m[0] for m in re.finditer(
                r"(?:export )?function \w \$([^ (]+)\([^\n]*\) \{\n.*?^\}", text, re.M | re.S)}
            asm = {decode(m[1]): m[0] for m in re.finditer(
                r"^([^\s.:][^\n :]*):\n.*?^\.size [^\n]+", (machine / "program.s").read_text(), re.M | re.S)}
            segments = [decode(x) for x in re.findall(r"l \$([^ ,}]+)", re.search(
                r"^data \$p111_segments.*$", text, re.M)[0])]
            chosen = {}
            for key in selected:
                if key not in fs:
                    continue
                body = fs[key]
                assembly = asm[key]
                chosen[key] = {"ssaSha256": sha(body.encode()),
                               "asmLabelsOnlySha256": sha(labels_only(assembly).encode()),
                               "assemblyInstructionLines": len(re.findall(r"^\t[a-z]", assembly, re.M)),
                               "assemblyCalls": [decode(x) for x in re.findall(r"\bcallq ([^\s]+)", assembly)],
                               "ssaJumpTargets": [{"fid": int(x), "symbol": segments[int(x)]} for x in re.findall(
                                   r"call \$p111_rt_jump\(l %state, w (\d+)", body)]}
                if key in segments:
                    chosen[key]["fid"] = segments.index(key)
            row["products"][role] = {"ssa": pin(sp), "assembly": pin(machine / "program.s"),
                                     "object": pin(machine / "program.o"), "binary": pin(machine / "program"),
                                     "functionCounts": dict(collections.Counter(k.split("FID_")[0] for k in fs)),
                                     "selectedFunctions": chosen}
        a, b = (row["products"][r]["selectedFunctions"] for r in ("baseline", "candidate"))
        row["workerComparisons"] = {k: {"exactSSA": a[k]["ssaSha256"] == b[k]["ssaSha256"],
                                          "assemblyLabelsOnly": a[k]["asmLabelsOnlySha256"] == b[k]["asmLabelsOnlySha256"]}
                                    for k in a.keys() & b.keys()}
        result["cases"].append(row)
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
