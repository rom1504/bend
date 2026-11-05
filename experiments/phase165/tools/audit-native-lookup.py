#!/usr/bin/env python3
"""Static generated-C call inventory; never executes compiled code."""
import argparse
import bisect
import collections
import hashlib
import json
import re
from pathlib import Path

MASK = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*[\s\S]*?\*/')
START = re.compile(r'^(?:(?:static|inline|BEND_[A-Z0-9_]+)\s+)*V ([A-Za-z0-9_]+)\([^\n]*\)\s*\{', re.M)
REF = re.compile(r'\b(?:F|U|W)_[A-Za-z0-9_]+\b')
SELECTED = {"F_Map_dbit", "F_Map_dget", "F_Map_dhas", "F_String_dcmp", "F_String_deq"}


def census(path, private_prefix="p165portable"):
    raw = path.read_bytes()
    text = raw.decode()
    text = MASK.sub(lambda m: "".join("\n" if c == "\n" else " " for c in m.group()), text)
    newlines = [i for i, char in enumerate(text) if char == "\n"]
    functions = {}
    for match in START.finditer(text):
        pos, depth = match.end(), 1
        end = pos
        while depth:
            if text[end] == "{":
                depth += 1
            elif text[end] == "}":
                depth -= 1
            end += 1
        functions[match.group(1)] = {
            "line": bisect.bisect_left(newlines, match.start()) + 1,
            "references": REF.findall(text[pos:end - 1]),
        }
    checker = {n: r for n, r in functions.items() if n.startswith(("F_Chk_d", "U_Chk_d", "W_Chk_d"))}
    private = {n: r for n, r in functions.items() if "d" + private_prefix + "_d" in n}
    reachable, pending, terminals = set(), list(private), set()
    while pending:
        name = pending.pop()
        if name in reachable:
            continue
        if name not in functions:
            terminals.add(name)
            continue
        reachable.add(name)
        pending.extend(functions[name]["references"])
    refs = collections.Counter(ref for row in checker.values() for ref in row["references"])
    return {
        "input": {"file": str(path.resolve()), "bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()},
        "functions": len(functions), "checkerFunctions": len(checker), "privateFunctions": len(private),
        "checkerSelectedNativeReferences": {n: refs[n] for n in sorted(SELECTED)},
        "checkerNativeMemoReferences": {n: refs[n] for n in sorted(refs) if n.startswith("F_Chk_dmemo_d")},
        "privateReachableFunctions": len(reachable),
        "privateSelectedNativeTerminals": sorted(terminals & SELECTED),
        "privateSelectedNativeDefinedFunctions": sorted(reachable & SELECTED),
        "privateOtherTerminals": sorted(terminals - SELECTED),
        "examples": {n: functions[n] for n in ("F_Chk_dStr_dhas", "F_Chk_dMap_dfind_dgo")},
        "privateOrdinaryBodies": {n: r for n, r in private.items() if n.startswith("F_")},
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--private-prefix", default="p165portable")
    args = parser.parse_args()
    if args.out.exists():
        raise ValueError("output already exists")
    old, new = census(args.baseline, args.private_prefix), census(args.candidate, args.private_prefix)
    result = {"kind": "phase165-generated-c-portable-lookup-audit", "version": 3,
              "privatePrefix": args.private_prefix,
              "targetsRun": False, "method": str(Path(__file__).resolve()),
              "methodSha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              "baseline": old, "candidate": new,
              "nativeMemoStaticReferencesEqual": old["checkerNativeMemoReferences"] == new["checkerNativeMemoReferences"],
              "limitations": "Static F/U/W function references only, including wrapper references. Counts are not dynamic calls. Runtime intrinsic bodies are external; this does not establish semantic equivalence or speed."}
    args.out.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"report": str(args.out), "nativeMemoStaticReferencesEqual": result["nativeMemoStaticReferencesEqual"],
                      "candidateSelectedNativeReferences": new["checkerSelectedNativeReferences"],
                      "candidatePrivateNativeTerminals": new["privateSelectedNativeTerminals"]}))


if __name__ == "__main__":
    main()
