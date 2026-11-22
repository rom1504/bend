#!/usr/bin/env python3
"""Raise .p130 carrier bounds in p88_header_counts (and p88_roots_ready).

Raises:
  - p88_header_counts: n <= 65536 -> 1048576 nodes, sn <= 4096 -> 65536 strings
  - p88_roots_ready:   bound <= 1048576 -> 16777216 (for full 3.29 MB compiler.bend)
"""
from __future__ import annotations

import argparse
from pathlib import Path

OLD_HEADER = (
    "p88_header_allocate(P88Cursor{text,mode},n,sn,begin,end,"
    "p130m_valid(mode) && U32.is_ge(n,1) && U32.is_le(n,65536) && "
    "U32.is_le(sn,4096) && U32.is_ge(begin,1) && U32.is_gt(end,begin))"
)
NEW_HEADER = (
    "p88_header_allocate(P88Cursor{text,mode},n,sn,begin,end,"
    "p130m_valid(mode) && U32.is_ge(n,1) && U32.is_le(n,1048576) && "
    "U32.is_le(sn,65536) && U32.is_ge(begin,1) && U32.is_gt(end,begin))"
)

OLD_ROOTS = (
    "p88_roots_gate(products,U32.is_ge(next,1) && U32.is_le(count,65536) && "
    "U32.is_le(bound,1048576) && U32.is_le(stamp,delta))"
)
NEW_ROOTS = (
    "p88_roots_gate(products,U32.is_ge(next,1) && U32.is_le(count,65536) && "
    "U32.is_le(bound,16777216) && U32.is_le(stamp,delta))"
)


def patch_text(src: str) -> str:
    if OLD_HEADER not in src:
        raise RuntimeError("p88_header_counts target not found")
    if src.count(OLD_HEADER) != 1:
        raise RuntimeError(f"Expected 1 p88_header_counts match, found {src.count(OLD_HEADER)}")
    out = src.replace(OLD_HEADER, NEW_HEADER, 1)
    if OLD_ROOTS in out:
        if out.count(OLD_ROOTS) != 1:
            raise RuntimeError(f"Expected 1 p88_roots_ready match, found {out.count(OLD_ROOTS)}")
        out = out.replace(OLD_ROOTS, NEW_ROOTS, 1)
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, required=True)
    ap.add_argument("--dst", type=Path, required=True)
    args = ap.parse_args()
    out = patch_text(args.src.read_text())
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out)
    print(f"[w7c_p130_scale] Patched {args.src} -> {args.dst} (n<=1048576, sn<=65536, bound<=16777216)")


if __name__ == "__main__":
    main()
