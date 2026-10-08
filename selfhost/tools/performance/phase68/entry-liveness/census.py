#!/usr/bin/env python3
"""Read generated selfhost C and report literal-FID reachability opportunities.

This is a source-only discriminator, not a compiler transform or a soundness
claim for arbitrary embedded C. It never invokes a compiler or writes C.
"""

import argparse
import collections
import hashlib
import json
from pathlib import Path
import re


FID = r"FID_(?:[0-9]+_)+"
TOKEN = re.compile(r"(?<![A-Za-z0-9_])(" + FID + r")(?![A-Za-z0-9_])")
SEGMENT = re.compile(
    r"^  WL_CASE\((" + FID + r")\)\n  \{\n.*?^  \}\}\n", re.M | re.S
)


def name(fid):
    return "".join(chr(int(x)) for x in fid[4:].split("_") if x)


def category(fid):
    decoded = name(fid)
    return ("direct" if decoded.startswith("$direct.") else
            "local" if decoded.startswith("native_k_") else "ordinary")


def census(path):
    raw = path.read_bytes()
    src = raw.decode()
    ids = dict((fid, int(n)) for fid, n in re.findall(
        r"^#define (" + FID + r") ([0-9]+)$", src, re.M))
    segments = {m.group(1): m.group(0) for m in SEGMENT.finditer(src)}
    if not ids or set(ids) != set(segments):
        raise ValueError("generated segment preflight mismatch")
    if sorted(ids.values()) != list(range(len(ids))):
        raise ValueError("expected contiguous generated FIDs")
    main = re.search(r"^#define MAIN_FID (" + FID + r")$", src, re.M)
    if main is None or main.group(1) not in ids:
        raise ValueError("missing generated main entry")
    flags = re.search(r"CONSTV u8 FID_FLAG_T\[\] = \{ ([0-9, ]+) \};", src)
    if flags is None:
        raise ValueError("missing FID flags")
    flags = [int(x.strip()) for x in flags.group(1).split(",")]
    if len(flags) != len(ids) + 2:
        raise ValueError("flag table length mismatch")

    # The table explicitly names every entry and must not seed reachability.
    # Main is restored as an explicit root below. Other outside generated IDs
    # are literal external roots (e.g. imported foreign C callbacks).
    outside = SEGMENT.sub("", src)
    table_start = outside.index("// Tables\n// ======")
    table_end = outside.index("// Spins\n// =====", table_start)
    outside = outside[:table_start] + outside[table_end:]
    roots = {main.group(1)} | (set(TOKEN.findall(outside)) & set(ids))
    bang_roots = {fid for fid, i in ids.items() if flags[i] & 1}
    # Keep all bang-marked segments so the BANGS zero/nonzero condition cannot
    # change in an initial pruning experiment.
    roots |= bang_roots
    edges = {fid: (set(TOKEN.findall(body)) - {fid}) & set(ids)
             for fid, body in segments.items()}
    pending, live = list(roots), set()
    while pending:
        fid = pending.pop()
        if fid in live:
            continue
        live.add(fid)
        pending.extend(edges[fid] - live)
    dead = set(ids) - live
    classes = {}
    for label, fids in [("all", set(ids)), ("live", live), ("dead", dead)]:
        classes[label] = dict(sorted(collections.Counter(map(category, fids)).items()))
    return {
        "source": str(path), "sha256": hashlib.sha256(raw).hexdigest(),
        "source_bytes": len(raw), "segments": len(ids),
        "roots": sorted(map(name, roots)), "bang_roots": len(bang_roots),
        "live_segments": len(live), "dead_segments": len(dead),
        "dead_segment_body_bytes": sum(len(segments[fid].encode()) for fid in dead),
        "segment_body_bytes": sum(len(body.encode()) for body in segments.values()),
        "classes": classes,
        "dead_named_entries": sorted(name(fid) for fid in dead if category(fid) != "local"),
        "scope": "literal-FID source census only; no C rewrite, build, or execution",
        "limitations": [
            "External C can form or inspect function IDs dynamically; lexical roots alone do not prove arbitrary foreign code safe.",
            "Existing source-level fork dependency flags must be frozen before pruning.",
            "No dynamic frequency, runtime speed, Clang time, or lowering-time claim."
        ],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("sources", type=Path, nargs="+")
    args = parser.parse_args()
    print(json.dumps({"version": 1, "results": [census(p) for p in args.sources]}, indent=2))


if __name__ == "__main__":
    main()
