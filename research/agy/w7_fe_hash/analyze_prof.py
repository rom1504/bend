#!/usr/bin/env python3
import json, sys
from collections import defaultdict

p = json.load(open(sys.argv[1]))
nodes = {n["id"]: n for n in p["nodes"]}
parent = {}
for n in p["nodes"]:
    for c in n.get("children", []):
        parent[c] = n["id"]

self_us = defaultdict(int)
tot_us = defaultdict(int)
samples = p.get("samples", [])
deltas = p.get("timeDeltas", [])
total_time = sum(deltas)

for sid, dt in zip(samples, deltas):
    fn = nodes[sid]["callFrame"]["functionName"] or "(anon)"
    self_us[fn] += dt
    seen = set()
    cur = sid
    while cur is not None:
        cfn = nodes[cur]["callFrame"]["functionName"] or "(anon)"
        if cfn not in seen:
            seen.add(cfn)
            tot_us[cfn] += dt
        cur = parent.get(cur)

print(f"Total profiled time: {total_time/1000:.1f} ms")
print("\n=== TOP 35 BY SELF TIME ===")
for fn, us in sorted(self_us.items(), key=lambda x: -x[1])[:35]:
    print(f"  {us/1000:8.1f} ms ({100*us/total_time:5.1f}%)  {fn}")

print("\n=== TOP 35 BY TOTAL (INCLUSIVE) TIME ===")
for fn, us in sorted(tot_us.items(), key=lambda x: -x[1])[:35]:
    print(f"  {us/1000:8.1f} ms ({100*us/total_time:5.1f}%)  {fn}")
