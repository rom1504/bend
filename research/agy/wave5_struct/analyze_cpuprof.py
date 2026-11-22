#!/usr/bin/env python3
import json
import sys
from collections import defaultdict
from pathlib import Path

prof_path = Path(sys.argv[1])
data = json.loads(prof_path.read_text())
nodes = {n["id"]: n for n in data["nodes"]}
samples = data.get("samples", [])
deltas = data.get("timeDeltas", [])

self_us = defaultdict(int)
total_us = 0
for nid, dt in zip(samples, deltas):
    fn = nodes[nid]["callFrame"]["functionName"] or "(anon)"
    self_us[fn] += dt
    total_us += dt

def classify(fn):
    f = fn.lstrip("$")
    if f.startswith(("w4", "w2", "agy_")):
        if "str_eq" in f:
            return "StringEq/Hash"
        if f.startswith("w4") or f.startswith("w2"):
            return "Wave2/4_Opt"
        return "Agy_Opt"
    if any(k in f for k in ("string_eq", "String$eq", "String$order", "index_hash", "index_find", "index_bucket", "p131i_", "p98_tag_eq", "String$starts_with")):
        return "StringEq/Hash"
    if f.startswith(("x187", "x188", "x201", "x202", "x198")):
        return "ELF_Encode(x187/188)"
    if f.startswith(("x181", "x185", "x186", "x190", "x184", "x182", "x183")):
        return "x86_Codegen(x181-190)"
    if f.startswith(("p169", "p111", "p112", "p113", "p114", "p118", "p124", "p125", "p128", "p134", "p137", "p186", "nc_", "nu_", "no_effect")):
        return "Lowering(p111-p169)"
    if f.startswith(("check_", "norm_", "p177", "dr_", "kr_", "p142", "ka_")):
        return "Typecheck/Norm"
    if f.startswith(("f_", "p88_", "p86_", "lex_", "parse_")):
        return "Frontend/Parse"
    if f in ("(garbage collector)", "(program)", "(idle)", "(root)"):
        return "V8_GC/Runtime"
    return "Other"

cats = defaultdict(int)
for fn, us in self_us.items():
    cats[classify(fn)] += us

print(f"Total sampled time: {total_us/1e6:.2f} s ({len(samples)} samples)\n")
print("=== Category Breakdown ===")
for cat, us in sorted(cats.items(), key=lambda x: -x[1]):
    print(f"  {cat:<24s} {us/1e6:7.2f} s  ({100*us/total_us:5.1f}%)")

print("\n=== Top 40 Self-Time Functions ===")
for i, (fn, us) in enumerate(sorted(self_us.items(), key=lambda x: -x[1])[:40], 1):
    print(f"  {i:2d}. {fn:<48s} {us/1e6:6.2f} s  ({100*us/total_us:5.1f}%)  [{classify(fn)}]")
