#!/usr/bin/env python3
"""Read-only lexical census of saved JS; never imports or executes a module."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re


def sha(data):
    return hashlib.sha256(data).hexdigest()


def identity(path):
    data = path.read_bytes()
    return {"path": str(path.resolve()), "sha256": sha(data), "bytes": len(data)}


# Selected generated bodies contain strings/comments and ordinary division,
# but no regular-expression or template literals. Reject templates explicitly.
LEX = re.compile(r'''\s+|//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[A-Za-z_$][A-Za-z0-9_$]*|\d+(?:\.\d+)?|=>|[^\s]''')


def tokens(text):
    result = []
    for m in LEX.finditer(text):
        value = m.group()
        if value.isspace() or value.startswith(("//", "/*")):
            continue
        assert value != "`", "template literal outside this lexical census scope"
        result.append((value, m.start(), m.end()))
    return result


def decode(name, direct):
    if direct:
        return re.sub(r"_(\d+)_", lambda m: chr(int(m[1])), name[4:])
    return re.sub(r"\$(\d{3})", lambda m: chr(int(m[1])), name[1:-1]).replace("$", ".")


def definitions(text, direct):
    marker = "function $jd$" if direct else "function $"
    begin = text.find(marker)
    assert begin >= 0, marker
    ts = tokens(text[begin:])
    result = {}
    i = 0
    while i + 3 < len(ts):
        if ts[i][0] != "function" or not ts[i + 1][0].startswith("$"):
            i += 1
            continue
        name = ts[i + 1][0]
        assert ts[i + 2][0] == "("
        j = i + 3
        while ts[j][0] != "{":
            j += 1
        depth, end = 1, j + 1
        while depth:
            depth += (ts[end][0] == "{") - (ts[end][0] == "}")
            end += 1
        source_name = decode(name, direct)
        assert source_name not in result, source_name
        start_offset, end_offset = begin + ts[i][1], begin + ts[end - 1][2]
        result[source_name] = {
            "identifier": name,
            "line": text.count("\n", 0, start_offset) + 1,
            "bytes": len(text[start_offset:end_offset].encode()),
            "sha256": sha(text[start_offset:end_offset].encode()),
            "tokens": [t[0] for t in ts[j + 1:end - 1]],
        }
        i = end
    return result


def metrics(item, native_ids):
    ts = item["tokens"]
    calls = collections.Counter(ts[i] for i in range(len(ts) - 1)
                                if ts[i] in native_ids and ts[i + 1] == "(")
    math = collections.Counter(ts[i + 2] for i in range(len(ts) - 3)
                               if ts[i:i + 2] == ["Math", "."] and ts[i + 3] == "(")
    return {
        "line": item["line"], "bytes": item["bytes"], "sha256": item["sha256"],
        "primitiveCalls": dict(sorted(calls.items())),
        "primitiveCallCount": sum(calls.values()),
        "orderedHolds": sum(ts[i] == "const" and bool(re.fullmatch(r"\$ord\d+", ts[i + 1]))
                            for i in range(len(ts) - 1)),
        "constDeclarations": ts.count("const"),
        "arrowExpressions": ts.count("=>"),
        "mathCalls": dict(sorted(math.items())),
    }


def module_data(manifest_path, role, case_id, primitives):
    manifest = json.loads(manifest_path.read_text())
    assert manifest["complete"]
    case = next(x for x in manifest["cases"] if x["id"] == case_id)
    module = case["modules"][role]
    path = manifest_path.parent / module["path"]
    data = path.read_bytes()
    assert sha(data) == module["sha256"] and len(data) == module["bytes"]
    direct = role != "typescript"
    compiler = manifest["roles"][role]["compiler"]
    runtime = compiler.get("directRuntime")
    if direct:
        rt = Path(runtime.get("file", runtime.get("path", runtime.get("canonicalPath"))))
        raw = rt.read_bytes()
        assert sha(raw) == runtime["sha256"] and data.startswith(raw)
    defs = definitions(data.decode(), direct)
    native = {x["identifier"] for key, x in defs.items() if key in primitives}
    rows = {key: metrics(value, native) for key, value in defs.items() if key not in primitives}
    return {
        "manifest": identity(manifest_path), "module": identity(path),
        "sourceSha256": case["sourceSha256"], "point": case["point"],
        "upstreamCommit": manifest["upstreamCommit"],
        "directRuntimeSha256": runtime["sha256"] if runtime else None,
        "primitiveDeclarations": sorted(key for key in defs if key in primitives),
        "primitiveCallCount": sum(x["primitiveCallCount"] for x in rows.values()),
        "orderedHolds": sum(x["orderedHolds"] for x in rows.values()),
        "constDeclarations": sum(x["constDeclarations"] for x in rows.values()),
        "arrowExpressions": sum(x["arrowExpressions"] for x in rows.values()),
        "functions": rows,
    }


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--baseline", required=True, type=Path)
    p.add_argument("--candidate", required=True, type=Path)
    p.add_argument("--typescript", required=True, type=Path)
    p.add_argument("--primitives", required=True, type=Path)
    p.add_argument("--out", required=True, type=Path)
    args = p.parse_args()
    primitive_input = identity(args.primitives)
    primitives = set(re.findall(r'JDPrimitive\{"([^"]+)"', args.primitives.read_text())) - {""}
    assert len(primitives) == 89
    ids = ["mandelbrot", "local-pair", "editdist", "variation-ray-active-64-2440"]
    rows = []
    for case_id in ids:
        roles = {label: module_data(path, role, case_id, primitives)
                 for label, path, role in [("corrected01", args.baseline, "candidate"),
                                           ("ordered02", args.candidate, "candidate"),
                                           ("typescript", args.typescript, "typescript")]}
        assert len({x["sourceSha256"] for x in roles.values()}) == 1
        assert len({json.dumps(x["point"], sort_keys=True) for x in roles.values()}) == 1
        assert len({x["upstreamCommit"] for x in roles.values()}) == 1
        assert roles["corrected01"]["directRuntimeSha256"] == roles["ordered02"]["directRuntimeSha256"]
        rows.append({"case": case_id, "roles": roles})
    assert identity(args.primitives) == primitive_input
    report = {"kind": "phase53-saved-generated-shape", "targetExecution": False,
              "method": "lexical generated-function census; strings/comments excluded; no CFG/JIT inference",
              "producer": identity(Path(__file__)), "primitiveCatalog": primitive_input, "cases": rows}
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("x") as f:
        json.dump(report, f, indent=2)
        f.write("\n")
    print(json.dumps({"output": str(args.out), "cases": len(rows), "targetExecution": False}))


if __name__ == "__main__":
    main()
