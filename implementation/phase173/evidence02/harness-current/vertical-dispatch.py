#!/usr/bin/env python3
"""Read retained QBE/assembly; never compile or execute a target."""
import argparse
import collections
import hashlib
import json
import pathlib
import re


def receipt(path):
    data = path.read_bytes()
    return {"file": str(path.resolve()), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--qbe", type=pathlib.Path, required=True)
    parser.add_argument("--assembly", type=pathlib.Path, required=True)
    parser.add_argument("--out", type=pathlib.Path, required=True)
    parser.add_argument("--bodies", type=pathlib.Path, required=True)
    args = parser.parse_args()
    qbe, assembly = args.qbe.read_text(), args.assembly.read_text()
    rows, bodies = {}, []
    for purpose, number in (("import", 0), ("export", 8), ("refs", 7), ("compact", 5)):
        source_name = "$p173scc." + str(number)
        symbol = "p113d_FID_" + "_".join(str(ord(x)) for x in source_name) + "_"
        qm = re.search(r"(?m)^function l \$" + re.escape(symbol) + r"\(", qbe)
        am = re.search(r"(?m)^" + re.escape(symbol) + r":$", assembly)
        if qm is None or am is None:
            raise SystemExit("missing expected qualified worker: " + source_name)
        qb = qbe[qm.start():qbe.index("\n}", qm.end()) + 2]
        ae = assembly.index("\n.size", am.end())
        ae = assembly.index("\n", ae + 1)
        ab = assembly[am.start():ae + 1]
        instructions = [line.strip() for line in ab.splitlines()
                        if line.startswith("\t") and not line.lstrip().startswith(".")]
        tags = collections.Counter(re.findall(r"(?m)^%p113_again_0 =l copy (\d+)$", qb))
        rows[purpose] = {
            "symbol": symbol,
            "qbeLine": qbe.count("\n", 0, qm.start()) + 1,
            "assemblyLine": assembly.count("\n", 0, am.start()) + 1,
            "literalBackedgeSites": sum(tags.values()),
            "literalTagSiteHistogram": dict(sorted(tags.items(), key=lambda x: int(x[0]))),
            "loopJumpsIncludingEntry": qb.count("jmp @p113_loop\n"),
            "dispatchTests": len(re.findall(r"(?m)^%v_p173sc_test_\d+ =w ceql ", qb)),
            "assemblyInstructions": len(instructions),
            "assemblyCalls": sum(bool(re.match(r"callq?\s", x)) for x in instructions),
            "assemblyExchangeInstructions": sum(x.startswith("xchg") for x in instructions),
            "assemblyStackReferences": sum("(%rbp)" in x or "(%rsp)" in x for x in instructions),
            "exactAssemblyBytes": len(ab.encode()),
            "exactAssemblySha256": hashlib.sha256(ab.encode()).hexdigest(),
        }
        bodies.append(ab)
    args.bodies.write_text("\n".join(bodies))
    result = {"kind": "phase173-static-dispatch-census", "version": 1,
              "complete": True, "targetsRun": False,
              "inputs": [receipt(pathlib.Path(__file__)), receipt(args.qbe), receipt(args.assembly)],
              "exactAssemblyBodies": receipt(args.bodies), "workers": rows,
              "limits": "Static site counts, not dynamic cost or measured optimization gains. "
                        "Worker numbers refer only to the pinned ABI03 product."}
    args.out.write_text(json.dumps(result, indent=2) + "\n")


if __name__ == "__main__":
    main()
