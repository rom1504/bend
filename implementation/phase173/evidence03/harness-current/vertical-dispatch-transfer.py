#!/usr/bin/env python3
"""Inventory existing tagged SCCs in retained products; never run targets."""
import argparse
import collections
import hashlib
import json
import pathlib
import re


def pin(path):
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return {"file": str(path.resolve()), "bytes": path.stat().st_size, "sha256": digest.hexdigest()}


def decode(name):
    if "_FID_" not in name:
        return name
    left, right = name.split("_FID_", 1)
    try:
        return left + "_" + "".join(chr(int(x)) for x in right.split("_") if x)
    except ValueError:
        return name


def is_worker(name):
    return name.startswith(("p113d_$p126scc.", "p113d_$p173scc."))


def inspect(path):
    workers, aliases = {}, collections.defaultdict(list)
    name, body, functions = "", None, 0
    with path.open() as source:
        for line in source:
            if line.startswith(("function ", "export function ")):
                name = decode(re.search(r"\$([^ (]+)", line)[1])
                functions += 1
                body = [] if is_worker(name) else None
            if body is not None:
                body.append(line)
                if line.strip() == "}":
                    text = "".join(body)
                    workers[name] = {
                        "bytes": len(text.encode()), "sha256": hashlib.sha256(text.encode()).hexdigest(),
                        "constantBackedges": len(re.findall(r"(?m)^%(?:p113_again|p126_next)_0 =l copy \d+$", text)),
                        "typedBackedges": text.count("%p126_next_0 =l copy"),
                        "loopJumpsIncludingEntry": text.count("jmp @p113_loop\n"),
                        "tagComparisons": len(re.findall(r"=w ceql %v_p126scc_tag,", text))}
                    body = None
            if "call $p113d_FID_36_112_49_" in line:
                target = decode(re.search(r"call \$([^ (]+)", line)[1])
                if is_worker(target):
                    aliases[target].append(name)
    for name, row in workers.items():
        row["directCallers"] = aliases[name]
    return {"input": pin(path), "functionCount": functions, "workers": workers,
            "workerCount": len(workers), "constantBackedges": sum(x["constantBackedges"] for x in workers.values())}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--qbe", type=pathlib.Path, action="append", required=True)
    parser.add_argument("--assembly", type=pathlib.Path, required=True)
    parser.add_argument("--out", type=pathlib.Path, required=True)
    parser.add_argument("--body", type=pathlib.Path, required=True)
    args = parser.parse_args()
    # This exact worker identity belongs to the frozen qualified Phase170 image.
    symbol = "p113d_FID_" + "_".join(str(ord(c)) for c in "$p126scc.1514") + "_"
    lines, active = [], False
    with args.assembly.open() as source:
        for line in source:
            if line.rstrip() == symbol + ":":
                active = True
            if active:
                lines.append(line)
                if line.startswith(".size"):
                    break
    if not active:
        raise SystemExit("missing frozen f_find SCC assembly")
    args.body.write_text("".join(lines))
    report = {"kind": "phase173-existing-scc-transfer-census", "version": 1,
              "complete": True, "targetsRun": False, "method": pin(pathlib.Path(__file__)),
              "products": [inspect(path) for path in args.qbe],
              "assembly": pin(args.assembly), "exactLookupWorker": pin(args.body),
              "limits": "Existing generated code only. Static tagged edges identify transfer candidates, "
                        "not final admission or measured whole-compiler speedups. No new dump was acquired."}
    args.out.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
