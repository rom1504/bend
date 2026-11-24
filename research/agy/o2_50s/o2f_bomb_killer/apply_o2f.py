#!/usr/bin/env python3
"""O2-F: O(N^2) -> O(N) w4b_find_loop quadratic-bomb killer for wave16_unified/compiler.bend.

Root cause:
  w4b_find_loop called w7_collect_jmps (which recorded all `jmp` targets without
  instruction indices), then w7_find_loop_go called O(N) w4b_has_jmp_to(lbl, rest)
  and w4b_has_any_branch_to(lbl, before) on EVERY PLabel whose name appeared as any
  forward `jmp` target. Functions with many forward merge labels (large list literals
  with inline p111_rt_ctor slow-path labels, giant matches, instruction-list builders)
  hit O(L * N) = O(N^2) String.eq scans — accounting for ~80% of -O2 x187_priv time
  (5.57s on standalone 150-element w13c_sink_tpl_bytes in n7_o2, 25.5s in -O0 profiler).

Fix (100% semantically identical, bit-identical -O2 output):
  Collect a single KDef map per function in one O(N) pass storing:
    da(info) = last (maximum) instruction index of `jmp <lbl>` (0 if none)
    dx(info) = first (minimum) instruction index of any `j* <lbl>` (0 if none)
  (with initial `before` indexed at 1 and `items` indexed at 2..N+1).
  Then at PLabel{lbl} at index idx >= 2:
    w4b_has_jmp_to(lbl, rest) && !w4b_has_any_branch_to(lbl, before)
    <==> U32.is_gt(da(info), idx) && U32.is_gt(dx(info), idx).
"""
from __future__ import annotations

import argparse
from pathlib import Path

OLD_W4B_FIND_LOOP = """@unsafe
def w4b_find_loop(+items: List<&2,X187Parsed>, +before: List<&2,X187Parsed>) -> W4BLoopSplit:
  +jmps = w7_collect_jmps(items,missing())
  nt_choose(W4BLoopSplit,agy_str_eq(dk(jmps),"Absent"),
    u => W4BLoopNone{},
    u => w7_find_loop_go(items,before,jmps))"""

NEW_W4B_FIND_LOOP = """@unsafe
def o2f_mark_br(+acc: KDef, +t: String, +isJmp: Bool, +idx: U32) -> KDef:
  +cur = p111v_get(acc,t)
  +prevJmp = da(cur)
  +prevBr = dx(cur)
  +firstBr = nt_choose(U32,U32.is_eq(prevBr,0),u => idx,u => prevBr)
  +lastJmp = nt_choose(U32,isJmp,u => idx,u => prevJmp)
  p111v_put(acc,t,"W7Br",lastJmp,firstBr)

@unsafe
def o2f_collect_before(items: List<&2,X187Parsed>, +acc: KDef) -> KDef:
  match items:
    case Nil{}: acc
    case Con{PInst{X187Instruction{+op,Con{X187Target{+t},Nil{}}}},rest}:
      o2f_collect_before(rest,nt_choose(KDef,String.starts_with(op,"j"),
        u => o2f_mark_br(acc,t,False{},1),u => acc))
    case Con{_,rest}: o2f_collect_before(rest,acc)

@unsafe
def o2f_collect_branches(items: List<&2,X187Parsed>, +idx: U32, +acc: KDef) -> KDef:
  match items:
    case Nil{}: acc
    case Con{PInst{X187Instruction{+op,Con{X187Target{+t},Nil{}}}},rest}:
      o2f_collect_branches(rest,U32.inc(idx),nt_choose(KDef,String.starts_with(op,"j"),
        u => o2f_mark_br(acc,t,agy_str_eq(op,"jmp"),idx),u => acc))
    case Con{_,rest}: o2f_collect_branches(rest,U32.inc(idx),acc)

@unsafe
def o2f_find_loop_go(items: List<&2,X187Parsed>, +before: List<&2,X187Parsed>, +brs: KDef, +idx: U32) -> W4BLoopSplit:
  match items:
    case Nil{}: W4BLoopNone{}
    case Con{PLabel{+lbl},+rest}:
      +info = p111v_get(brs,lbl)
      nt_choose(W4BLoopSplit,
        U32.is_gt(da(info),idx) && U32.is_gt(dx(info),idx),
        u => W4BLoopSplit{nt_reverse(X187Parsed,before,[]),lbl,rest},
        u => o2f_find_loop_go(rest,Con{PLabel{lbl},before},brs,U32.inc(idx)))
    case Con{h,rest}: o2f_find_loop_go(rest,Con{h,before},brs,U32.inc(idx))

@unsafe
def w4b_find_loop(+items: List<&2,X187Parsed>, +before: List<&2,X187Parsed>) -> W4BLoopSplit:
  +brs = o2f_collect_branches(items,2,o2f_collect_before(before,missing()))
  nt_choose(W4BLoopSplit,agy_str_eq(dk(brs),"Absent"),
    u => W4BLoopNone{},
    u => o2f_find_loop_go(items,before,brs,2))"""

PATCHES: list[tuple[str, str, str]] = [
    ("w4b_find_loop_linear", OLD_W4B_FIND_LOOP, NEW_W4B_FIND_LOOP),
]


def apply_text(src: str, require_all: bool = True) -> tuple[str, list[str]]:
    applied: list[str] = []
    out = src
    for name, old, new in PATCHES:
        if new in out:
            applied.append(f"{name}:already")
            continue
        cnt = out.count(old)
        if cnt == 1:
            out = out.replace(old, new, 1)
            applied.append(f"{name}:applied")
        elif require_all:
            raise RuntimeError(f"Patch {name} expected 1 occurrence, found {cnt}")
    return out, applied


def main() -> None:
    ap = argparse.ArgumentParser(description="Apply O2-F O(N) w4b_find_loop fix.")
    ap.add_argument("src", type=Path, help="Input compiler.bend (or m06.bend)")
    ap.add_argument("-o", "--out", type=Path, help="Output path (default: in-place)")
    ap.add_argument("--partial", action="store_true", help="Allow subset of patches")
    args = ap.parse_args()

    src_text = args.src.read_text(encoding="utf-8")
    new_text, status = apply_text(src_text, require_all=not args.partial)
    out_path = args.out or args.src
    out_path.write_text(new_text, encoding="utf-8")
    print(f"O2-F patched {out_path}: {', '.join(status)}")


if __name__ == "__main__":
    main()
