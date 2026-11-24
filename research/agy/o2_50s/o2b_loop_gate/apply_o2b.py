#!/usr/bin/env python3
"""O2-B: Loop-Gated -O2 Fast-Path Patcher.

Replaces the redundant O(N^2) w4b_find_loop + w5_scan_flags + heavy w7_post_select_full
pipeline on non-loop, non-XMM, non-rt_op functions with a single O(N) linear classifier
(`o2b_classify_fn`) and O(N) essential cleanup fast path, while preserving 100% of
existing -O2 passes untouched whenever `hasBackEdge || hasXmm || hasRtOp`.

Idempotent on both `selfhost/build/agy/wave16_unified/compiler.bend` and
`selfhost/build/agy/k10_wave16/m08.bend` (or any copy thereof).
"""
from __future__ import annotations

import argparse
from pathlib import Path

MARKER = "def o2b_classify_fn("

TARGET_BLOCK = """@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +flags = w5_scan_flags(flat0,0)
  +hasXmm = Bool.not(U32.is_eq(U32.and(flags,1),0))
  +hasNegRbp = Bool.not(U32.is_eq(U32.and(flags,2),0))
  +hasLbl = Bool.not(U32.is_eq(U32.and(flags,4),0))
  +hasImulq = Bool.not(U32.is_eq(U32.and(flags,8),0))
  +hasCall = Bool.not(U32.is_eq(U32.and(flags,16),0))
  +hasLoop = hasLbl && w7_is_loop(w4b_find_loop(flat0,[]))
  nt_choose(X188Seq,hasCall && Bool.not(hasXmm) && Bool.not(hasLoop) && w7_len_gt(flat0,96),
    u => x188_finish(w4_peep_list(flat0,[])),
    u => w7_post_select_full(flat0,hasXmm,hasNegRbp,hasLbl,hasImulq,hasCall,hasLoop))

@unsafe
def x191_frame_forward(+code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +flags = w5_scan_flags(flat0,0)
  +hasXmm = Bool.not(U32.is_eq(U32.and(flags,1),0))
  +hasLbl = Bool.not(U32.is_eq(U32.and(flags,4),0))
  +hasCall = Bool.not(U32.is_eq(U32.and(flags,16),0))
  nt_choose(X188Seq,hasCall && Bool.not(hasXmm) && w7_len_gt(flat0,96) && Bool.not(hasLbl && w7_is_loop(w4b_find_loop(flat0,[]))),
    u => nt_choose(X188Seq,w14a_has_rt_op(flat0),
           v => x188_finish(w4_peep_list(w4_peep_flat([x191_frame_forward_when(True{},code)],[]),[])),
           v => x188_finish(w4_peep_list(flat0,[]))),
    u => w4_post_select(x197d_select(x191_frame_forward_when(True{},code))))"""

REPLACEMENT_BLOCK = """@unsafe
def o2b_op_flags(op: X187Operand) -> U32:
  match op:
    case X187Reg{_,_,True{}}: 1
    case X187Mem{b,d}:
      nt_choose(U32,U32.is_eq(b,5) && U32.is_ge(d,2147483648),u => 2,u => 0)
    case _: 0

@unsafe
def o2b_args_flags(args: List<&2,X187Operand>, +acc: U32) -> U32:
  match args:
    case Nil{}: acc
    case Con{a,rest}: o2b_args_flags(rest,U32.or(acc,o2b_op_flags(a)))

@unsafe
def o2b_inst_flags(+op: String, +args: List<&2,X187Operand>, +seen: KDef, +acc: U32) -> U32:
  match op args:
    case SCon{+ch,+tail} Con{X187Target{+t},Nil{}}:
      +c = Char.to_u32(ch)
      nt_choose(U32,U32.is_eq(c,106),
        u => nt_choose(U32,Bool.not(U32.is_eq(U32.and(acc,4),0)) && U32.is_gt(da(p111v_get(seen,t)),0),
          v => U32.or(acc,64),
          v => acc),
        u => nt_choose(U32,U32.is_eq(c,99) && agy_str_eq(tail,"all"),
          v => nt_choose(U32,agy_str_eq(t,"p111_rt_op"),
            w => U32.or(acc,48),
            w => U32.or(acc,16)),
          v => acc))
    case _ _:
      +f1 = nt_choose(U32,agy_str_eq(op,"imulq"),u => U32.or(acc,8),u => acc)
      +f2 = nt_choose(U32,agy_str_eq(op,"call"),u => U32.or(f1,16),u => f1)
      o2b_args_flags(args,f2)

@unsafe
def o2b_classify_go(items: List<&2,X187Parsed>, +seen: KDef, +n: U32, +acc: U32) -> U32:
  match items:
    case Nil{}: acc
    case Con{PLabel{+lbl},rest}:
      +n2 = nt_choose(U32,U32.is_lt(n,97),u => U32.inc(n),u => n)
      +acc0 = nt_choose(U32,U32.is_eq(n,96),u => U32.or(acc,128),u => acc)
      o2b_classify_go(rest,p111v_put(seen,lbl,"O2BL",1,0),n2,U32.or(acc0,4))
    case Con{PInst{X187Instruction{op,args}},rest}:
      +n2 = nt_choose(U32,U32.is_lt(n,97),u => U32.inc(n),u => n)
      +acc0 = nt_choose(U32,U32.is_eq(n,96),u => U32.or(acc,128),u => acc)
      o2b_classify_go(rest,seen,n2,o2b_inst_flags(op,args,seen,acc0))
    case Con{_,rest}:
      +n2 = nt_choose(U32,U32.is_lt(n,97),u => U32.inc(n),u => n)
      +acc0 = nt_choose(U32,U32.is_eq(n,96),u => U32.or(acc,128),u => acc)
      o2b_classify_go(rest,seen,n2,acc0)

@unsafe
def o2b_classify_fn(+items: List<&2,X187Parsed>) -> U32:
  o2b_classify_go(items,missing(),0,0)

@unsafe
def w4_post_select_classified(+flat0: List<&2,X187Parsed>, +flags: U32) -> X188Seq:
  +hasXmm = Bool.not(U32.is_eq(U32.and(flags,1),0))
  +hasNegRbp = Bool.not(U32.is_eq(U32.and(flags,2),0))
  +hasLbl = Bool.not(U32.is_eq(U32.and(flags,4),0))
  +hasImulq = Bool.not(U32.is_eq(U32.and(flags,8),0))
  +hasCall = Bool.not(U32.is_eq(U32.and(flags,16),0))
  +hasRtOp = Bool.not(U32.is_eq(U32.and(flags,32),0))
  +hasBackEdge = Bool.not(U32.is_eq(U32.and(flags,64),0))
  nt_choose(X188Seq,hasBackEdge || hasXmm || hasRtOp,
    u => w7_post_select_full(flat0,hasXmm,hasNegRbp,hasLbl,hasImulq,hasCall,
           hasBackEdge && hasLbl && w7_is_loop(w4b_find_loop(flat0,[]))),
    u => x188_finish(w4_peep_list(flat0,[])))

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  w4_post_select_classified(flat0,o2b_classify_fn(flat0))

@unsafe
def x191_frame_forward(+code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +flags = o2b_classify_fn(flat0)
  +hasXmm = Bool.not(U32.is_eq(U32.and(flags,1),0))
  +hasRtOp = Bool.not(U32.is_eq(U32.and(flags,32),0))
  +hasBackEdge = Bool.not(U32.is_eq(U32.and(flags,64),0))
  +gt96 = Bool.not(U32.is_eq(U32.and(flags,128),0))
  nt_choose(X188Seq,hasBackEdge || hasXmm || hasRtOp,
    u => w4_post_select(x197d_select(x191_frame_forward_when(True{},code))),
    u => nt_choose(X188Seq,gt96,
           v => x188_finish(w4_peep_list(flat0,[])),
           v => x188_finish(w4_peep_list(w4_peep_flat([x191_frame_forward_when(True{},code)],[]),[]))))"""


def apply_text(src: str) -> tuple[str, str]:
    if MARKER in src:
        return src, "ALREADY_APPLIED"
    count = src.count(TARGET_BLOCK)
    if count != 1:
        raise RuntimeError(f"Expected 1 occurrence of TARGET_BLOCK, found {count}")
    return src.replace(TARGET_BLOCK, REPLACEMENT_BLOCK, 1), "APPLIED"


def main() -> None:
    ap = argparse.ArgumentParser(description="Apply O2-B loop-gated -O2 fast-path patch.")
    ap.add_argument("src", type=Path, help="Input .bend file (compiler.bend or m08.bend)")
    ap.add_argument("-o", "--out", type=Path, default=None, help="Output .bend file (default: edit in place)")
    args = ap.parse_args()
    text = args.src.read_text(encoding="utf-8")
    patched, status = apply_text(text)
    out_path = args.out if args.out is not None else args.src
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(patched, encoding="utf-8")
    print(f"O2-B {status}: {out_path} ({len(patched):,} bytes)")


if __name__ == "__main__":
    main()
