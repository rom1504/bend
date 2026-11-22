#!/usr/bin/env python3
import bisect
import collections
import struct
import subprocess
import sys
from pathlib import Path

def load_syms(exe):
    out = subprocess.check_output(["nm", "-n", str(exe)], text=True)
    addrs = []
    names = []
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] in ("T", "t", "W", "w"):
            try:
                a = int(parts[0], 16)
            except ValueError:
                continue
            addrs.append(a)
            names.append(parts[2])
    return addrs, names

def resolve(addrs, names, pc):
    i = bisect.bisect_right(addrs, pc) - 1
    if i < 0:
        return "<below_text>"
    if pc - addrs[i] > 0x200000:
        return "<external_or_lib>"
    return names[i]

def demangle_fid(sym):
    import re
    m = re.match(r"^(p\d+[a-z]*_|WL_)?FID_([0-9_]+)$", sym)
    if not m:
        return sym
    prefix = m.group(1) or ""
    nums = [int(x) for x in m.group(2).split("_") if x]
    try:
        s = "".join(chr(x) if 32 <= x < 127 else f"\\x{x:02x}" for x in nums)
        return f"{prefix}{s}"
    except Exception:
        return sym

def main():
    exe = Path(sys.argv[1])
    prof = Path(sys.argv[2])
    topn = int(sys.argv[3]) if len(sys.argv) > 3 else 35
    addrs, names = load_syms(exe)
    data = prof.read_bytes()
    n = len(data) // 24
    counts = collections.Counter()
    buckets = collections.defaultdict(collections.Counter)
    ret_counts = collections.defaultdict(collections.Counter)
    max_tick = 0
    for i in range(n):
        rip, ret0, tick, _ = struct.unpack_from("<QQII", data, i * 24)
        sym = resolve(addrs, names, rip)
        counts[sym] += 1
        b = tick // 1250  # ~5s buckets at 250Hz
        buckets[b][sym] += 1
        if tick > max_tick:
            max_tick = tick
        if ret0:
            rsym = resolve(addrs, names, ret0)
            if rsym != "<below_text>" and rsym != "<external_or_lib>":
                ret_counts[sym][rsym] += 1

    print(f"Total samples: {n} (max_tick={max_tick}, ~{max_tick/250.0:.2f}s at 250Hz)")
    print("\n=== TOP SYMBOLS ===")
    cum = 0.0
    for sym, c in counts.most_common(topn):
        pct = 100.0 * c / max(n, 1)
        cum += pct
        d = demangle_fid(sym)
        callers = ", ".join(f"{demangle_fid(k)}({v})" for k, v in ret_counts[sym].most_common(3))
        print(f"  {pct:6.2f}%  (cum {cum:6.2f}%)  {c:6d}  {d:55s}  [ret0: {callers}]")

    # Category breakdown
    cats = collections.Counter()
    for sym, c in counts.items():
        if sym.startswith("p111_rt_") or sym.startswith("p125_") or sym.startswith("p144_") or sym in ("term_drop", "heap_alloc", "heap_alloc_miss", "heap_free", "heap_hand", "rfc_wrap", "rfc_bump", "rfc_seal", "take_term", "step_redex", "eval_loop", "p111_step", "p111_eval", "p111_run"):
            cats["runtime"] += c
        elif sym.startswith("p113d_"):
            cats["p113d_direct"] += c
        elif sym.startswith("p114r_"):
            cats["p114r_reuse"] += c
        elif sym.startswith("p111v_"):
            cats["p111v_vec"] += c
        elif sym.startswith("p111_"):
            cats["p111_trampoline_or_fn"] += c
        elif sym.startswith("<"):
            cats["libc_or_ext"] += c
        else:
            cats["other_c_or_rt"] += c
    print("\n=== CATEGORY BREAKDOWN ===")
    for k, c in cats.most_common():
        print(f"  {100.0*c/max(n,1):6.2f}%  {c:6d}  {k}")

    print("\n=== 5-SECOND TIME BUCKETS (top 5 per bucket) ===")
    for b in sorted(buckets):
        tot = sum(buckets[b].values())
        top5 = ", ".join(f"{s}:{100.0*c/tot:.1f}%" for s, c in buckets[b].most_common(5))
        print(f"  [{b*5:3d}s..{(b+1)*5:3d}s] ({tot:5d}): {top5}")

if __name__ == "__main__":
    main()
