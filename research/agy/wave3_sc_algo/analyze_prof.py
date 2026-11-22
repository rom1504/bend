#!/usr/bin/env python3
import bisect, re, struct, subprocess, sys
from collections import Counter

bin_path = sys.argv[1]
prof_path = sys.argv[2]

out = subprocess.check_output(["nm", "-n", bin_path], text=True)
addrs = []
names = []
for line in out.splitlines():
    parts = line.split()
    if len(parts) >= 3 and parts[1] in ("T", "t", "W", "w"):
        addrs.append(int(parts[0], 16))
        names.append(parts[2])

def decode_sym(s):
    m = re.match(r"^(p\d+[a-z]*_)FID_([0-9_]+?)_?$", s)
    if m:
        prefix = m.group(1)
        nums = [int(x) for x in m.group(2).split("_") if x]
        try:
            decoded = "".join(chr(x) for x in nums)
            return f"{prefix}{decoded}"
        except Exception:
            return s
    return s

decoded_names = [decode_sym(n) for n in names]

def resolve(pc):
    idx = bisect.bisect_right(addrs, pc) - 1
    if idx < 0:
        return "<unknown>"
    return decoded_names[idx]

def stage_of(sym):
    s = sym
    if "p118borrow.read." in s:
        s = s.split("p118borrow.read.", 1)[1]
    elif "$direct." in s:
        s = s.split("$direct.", 1)[1]
    elif "$p111." in s:
        return "p111_closure"
    if s.startswith(("p111_rt_", "p125_rt_", "p118_rt_", "p198_rfc_", "span_", "term_", "work_loop", "blk_", "ctr_", "mem", "malloc", "free", "data_start", "p111_set_regs")):
        return "RUNTIME"
    for p in ["ctfe_", "w2d_", "bf_", "agy_", "x198pw_", "p205", "p114h_", "x187_", "x188_", "x186_", "x185_", "x181_", "x201", "x202", "p169", "p134", "p130", "p113", "p111", "p88_", "p98_", "f_", "c_", "nr_", "nt_"]:
        if s.startswith(p):
            return p.rstrip("_")
    return "other"

WRAP = (1 << 64) // 1000000
data = open(prof_path, "rb").read()
n = len(data) // 16
counts = Counter()
stage_counts = Counter()
buckets = {}
stage_buckets = {}
max_ms = 0
for i in range(n):
    ms, pc = struct.unpack_from("<QQ", data, i * 16)
    if ms > 10**12:
        ms = ms - WRAP + 1000  # approximate fix for unsigned nsec borrow
    if ms > max_ms:
        max_ms = ms
    sym = resolve(pc)
    st = stage_of(sym)
    counts[sym] += 1
    stage_counts[st] += 1
    b = ms // 15000  # 15s bucket
    buckets.setdefault(b, Counter())[sym] += 1
    stage_buckets.setdefault(b, Counter())[st] += 1

print(f"Total samples: {n} (duration ~{max_ms/1000:.2f}s)")
print("\n=== BY STAGE/PREFIX ===")
for st, cnt in stage_counts.most_common(25):
    print(f"  {cnt:6d} ({100*cnt/max(n,1):5.1f}%)  {st}")

print("\n=== TOP 35 SYMBOLS ===")
for sym, cnt in counts.most_common(35):
    print(f"  {cnt:6d} ({100*cnt/max(n,1):5.1f}%)  {sym}")

print("\n=== 15s TIMELINE (top 4 stages + top 2 syms) ===")
for b in sorted(buckets):
    tot = sum(buckets[b].values())
    top_st = ", ".join(f"{s}:{100*c/tot:.0f}%" for s, c in stage_buckets[b].most_common(4))
    top_fn = ", ".join(f"{s}:{100*c/tot:.0f}%" for s, c in buckets[b].most_common(2))
    print(f"  {b*15:4d}-{(b+1)*15:4d}s ({tot:4d}): [{top_st}] | {top_fn}")
