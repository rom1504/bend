#!/usr/bin/env python3
"""Freeze independent integer expectations and a native transport harness."""
import argparse
import hashlib
import json
import pathlib

parser = argparse.ArgumentParser()
parser.add_argument("--out", required=True, type=pathlib.Path)
args = parser.parse_args()
args.out.mkdir(parents=True, exist_ok=False)
HERE = pathlib.Path(__file__).resolve().parent
U64 = (1 << 64) - 1
U32 = (1 << 32) - 1
PAIRS = [
    (0, 0), (U32, 1), (1 << 31, U32), (1 << 32, 3),
    ((1 << 40) + 7, (1 << 63) + 9), (U64, U64),
    (1 << 63, (1 << 32) + 1), (0x1122334455667788, 0xFEDCBA9876543210),
]


def expected(which, a, b):
    if which < 6:
        result = (a + b, a - b, a * b, a & b, a | b, a ^ b)[which]
        return result & U32
    if which == 6:
        return a & U32
    if which == 7:
        return (a + b) & U32
    if which == 8:
        return (a * a) & U32
    if which in (9, 12):
        return (a + b) & U64
    if which == 10:
        return (a >> 32) & U32
    if which == 11:
        return ((a << 40) & U64) & U32
    if which == 13:
        return (a + b) & 0xFFFFFFFE
    if which == 14:
        return (a + b) & 0x1FFFFFFFF
    if which == 15:
        return ((a * b) & U32) >> 40
    raise ValueError(which)


cases = [{"case": case, "a": str(a), "b": str(b),
          "expected": str(expected(case, a, b))}
         for case in range(16) for a, b in PAIRS]
(args.out / "cases.json").write_text(json.dumps(cases, indent=2) + "\n")
(args.out / "expected.stdout").write_text("".join(
    f"{row['case']} {row['a']} {row['b']} {row['expected']}\n" for row in cases))

# Symbol spelling is transport only: nt_fid uses Unicode decimal codepoints.
def symbol(case):
    name = f"p113_width_case_{case}"
    return "p113d_FID_" + "".join(f"{ord(c)}_" for c in name)


lines = ["#include <stdint.h>", "#include <stdio.h>", "#include <inttypes.h>"]
for case in range(16):
    lines.append(f"extern uint64_t {symbol(case)}(void*,uint64_t,uint64_t);")
lines.append("int main(void) {")
for row in cases:
    case, a, b = row["case"], row["a"], row["b"]
    lines.append(f'  printf("{case} {a} {b} %" PRIu64 "\\n", '
                 f'{symbol(case)}(0,UINT64_C({a}),UINT64_C({b})));')
lines.extend(["  return 0;", "}", ""])
(args.out / "harness.c").write_text("\n".join(lines))


def pin(path):
    raw = path.read_bytes()
    return {"file": str(path.resolve()), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


report = {
    "kind": "phase113-width-independent-controls", "complete": True,
    "targetsRun": False, "caseFunctions": 16, "observations": len(cases),
    "scope": "Raw reflected machine words, not a source representation theorem.",
    "inputs": [pin(pathlib.Path(__file__).resolve())] + [pin(HERE / name) for name in
              ("emit.bend", "overrides.bend", "controls.bend", "cases.bend")],
    "outputs": [pin(args.out / name) for name in
                ("cases.json", "expected.stdout", "harness.c")],
}
(args.out / "manifest.json").write_text(json.dumps(report, indent=2) + "\n")
