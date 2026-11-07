#!/usr/bin/env python3
"""Compare retained emission products; no compiler/program execution."""
import argparse
import hashlib
import json
import pathlib
import re


def pin(path):
    data = path.read_bytes()
    return {"file": str(path.resolve()), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def digest(text):
    return {"bytes": len(text.encode()), "sha256": hashlib.sha256(text.encode()).hexdigest()}


def decode(name):
    if "_FID_" not in name:
        return name
    left, right = name.split("_FID_", 1)
    try:
        return left + "_" + "".join(chr(int(x)) for x in right.split("_") if x)
    except ValueError:
        return name


def blocks(text):
    matches = list(re.finditer(r"(?m)^(?:export )?(function|data) [^\n]*?\$([^ (\n=]+)", text))
    result = {}
    for i, match in enumerate(matches):
        key = match.group(1), match.group(2)
        if key in result:
            raise ValueError("duplicate block " + str(key))
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        result[key] = text[match.start():end]
    return text[:matches[0].start()], result


def assembly_body(text, symbol):
    match = re.search(r"(?m)^" + re.escape(symbol) + r":$", text)
    if match is None:
        raise ValueError("missing native function " + symbol)
    end = text.index("\n.size", match.end())
    return text[match.start():text.index("\n", end + 1) + 1]


def census(qbe, assembly):
    instructions = [line.strip() for line in assembly.splitlines()
                    if line.startswith("\t") and not line.lstrip().startswith(".")]
    return {"qbe": digest(qbe), "assembly": digest(assembly),
            "constantTagSites": len(re.findall(r"(?m)^%p113_again_0 =l copy \d+$", qbe)),
            "armJumpSitesIncludingDispatchDefault": len(re.findall(r"(?m)^jmp @p173dj_arm_", qbe)),
            "loopJumpsIncludingEntry": qbe.count("jmp @p113_loop\n"),
            "armLabels": len(re.findall(r"(?m)^@p173dj_arm_", qbe)),
            "instructions": len(instructions),
            "calls": sum(bool(re.match(r"callq?\s", x)) for x in instructions),
            "exchangeInstructions": sum(x.startswith("xchg") for x in instructions),
            "instructionsReferencingStack": sum("(%rbp)" in x or "(%rsp)" in x for x in instructions),
            "firstFrameSubtraction": re.findall(r"subq\s+\$([0-9]+), %rsp", assembly)[:1]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for key in ("before-qbe", "after-qbe", "before-assembly", "after-assembly", "pair", "out", "bodies"):
        parser.add_argument("--" + key, type=pathlib.Path, required=True)
    args = parser.parse_args()
    before_prefix, before = blocks(args.before_qbe.read_text())
    after_prefix, after = blocks(args.after_qbe.read_text())
    old_assembly, new_assembly = args.before_assembly.read_text(), args.after_assembly.read_text()
    common = before.keys() & after.keys()
    changed = [{"kind": key[0], "symbol": key[1], "decoded": decode(key[1]),
                "before": digest(before[key]), "after": digest(after[key])}
               for key in sorted(common) if before[key] != after[key]]
    workers, bodies = {}, []
    for name, number in (("import", 0), ("export", 8), ("refs", 7), ("compact", 5), ("word", 2)):
        symbol = "p113d_FID_" + "_".join(str(ord(c)) for c in "$p173scc." + str(number)) + "_"
        key = "function", symbol
        old_body, new_body = assembly_body(old_assembly, symbol), assembly_body(new_assembly, symbol)
        workers[name] = {"symbol": symbol, "before": census(before[key], old_body),
                         "after": census(after[key], new_body)}
        bodies.append(new_body)
    args.bodies.write_text("\n".join(bodies))
    pair = json.loads(args.pair.read_text())
    result = {"kind": "phase173-dispatch-product-comparison", "version": 1,
              "complete": True, "targetsRun": False,
              "inputs": [pin(x) for x in (pathlib.Path(__file__), args.before_qbe, args.after_qbe,
                                           args.before_assembly, args.after_assembly, args.pair)],
              "beforeBlocks": len(before), "afterBlocks": len(after),
              "prefixExact": before_prefix == after_prefix, "blockOrderExact": list(before) == list(after),
              "added": [list(x) for x in sorted(after.keys() - before.keys())],
              "removed": [list(x) for x in sorted(before.keys() - after.keys())],
              "changed": changed,
              "dataExact": all(before[key] == after[key] for key in common if key[0] == "data"),
              "workers": workers, "exactCandidateAssemblyBodies": pin(args.bodies),
              "pairSummary": {key: pair.get(key) for key in ("complete", "resolved", "rounds", "medians", "ratio", "scope")},
              "limits": "Static instruction/stack-reference counts, not dynamic cost. "
                        "SCC numbers identify only this frozen store product. Timing is copied from the retained controlled campaign."}
    args.out.write_text(json.dumps(result, indent=2) + "\n")


if __name__ == "__main__":
    main()
