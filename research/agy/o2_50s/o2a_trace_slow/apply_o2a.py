#!/usr/bin/env python3
"""O2-A: Surgical O(N^2)/O(2^k) -O2 compile-time bomb fixes for wave16_unified/compiler.bend.

Idempotent patcher targeting 4 root causes identified by per-function --trace-slow profiling:
  1. w4b_reg_dead: cap lookahead budget <= 32 and branch hops 8 -> 2 (kills 2^8 * O(N) explosion).
  2. x191_frame_forward: bypass w7_post_select_full when hasCall && !hasXmm && len > 384
     (even when hasLoop is True — kills quadratic peephole/loop passes on huge tail-recursive
     compiler functions with calls, while leaving all leaf/XMM hot loops 100% untouched).
  3. x185_function_place & x198n_place_h: on the existing non-loop large-with-call fast path
     (!hasLoop && size > 96 && hasCall), skip O(N^2) x185_dead_body/x185_copy_function
     HAMT unions over 50-150 sequential/nested P113DIfs.
  4. x191_ordinary: on !hasLoop && size > 128 && hasCall, skip x190_branch_facts/x191_placement
     and emit directly via x191_function_saved.
  5. w14f_sl_hoist_apply: cap w14a_sl_rounds fuel 40 -> 20.
"""
from __future__ import annotations

import argparse
from pathlib import Path

PATCHES: list[tuple[str, str, str]] = [
    (
        "w4b_reg_dead_cap",
        """@unsafe
def w4b_reg_dead(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  w4b_reg_dead_step(r,items,fnItems,budget,8,[])""",
        """@unsafe
def w4b_reg_dead(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  +b = nt_choose(U32,U32.is_gt(budget,32),u => 32,u => budget)
  w4b_reg_dead_step(r,items,fnItems,b,2,[])""",
    ),
    (
        "w14a_sl_rounds_cap",
        """      +b1 = w14a_sl_rounds(40,lTop,body,afterBody,pre,post,fn0)""",
        """      +b1 = w14a_sl_rounds(20,lTop,body,afterBody,pre,post,fn0)""",
    ),
    (
        "w14a_sl_rounds_cap_h",
        """      +b1 = w14a_sl_rounds(40,lTop,bodyH,afterBody,preH,post,fnH)""",
        """      +b1 = w14a_sl_rounds(20,lTop,bodyH,afterBody,preH,post,fnH)""",
    ),
    (
        "x191_frame_forward_large_call_cap",
        """  nt_choose(X188Seq,hasCall && Bool.not(hasXmm) && w7_len_gt(flat0,96) && Bool.not(hasLbl && w7_is_loop(w4b_find_loop(flat0,[]))),""",
        """  +isLoop = hasLbl && w7_is_loop(w4b_find_loop(flat0,[]))
  nt_choose(X188Seq,Bool.not(hasXmm) && ((w7_len_gt(flat0,384) && (hasCall || Bool.not(isLoop))) || (hasCall && w7_len_gt(flat0,96) && Bool.not(isLoop))),""",
    ),
    (
        "x185_function_place_skip_dead_copy",
        """@unsafe
def x185_function_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),96) && w7b_stmts_has_call(body),
    u => x186_float_function(symbol,params,setup,x185_dead_body(setup,x185_copy_function(params,setup,body)),ids),
    u => x186_function_memory(symbol,params,setup,x185_prepare_body(params,setup,x185_scratch_body(params,setup,body)),ids))""",
        """@unsafe
def x185_function_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),96) && w7b_stmts_has_call(body),
    u => x186_float_function(symbol,params,setup,body,ids),
    u => x186_function_memory(symbol,params,setup,x185_prepare_body(params,setup,x185_scratch_body(params,setup,body)),ids))""",
    ),
    (
        "x198n_place_h_skip_dead_copy",
        """@unsafe
def x198n_place_h(+symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),96) && w7b_stmts_has_call(body),
    u => x186_float_function(symbol,names,setup,x185_dead_body(setup,x185_copy_function(names,setup,body)),ids),
    u => x198n_normalized_h(symbol,names,params,setup,x185_prepare_body(names,setup,x185_scratch_body(names,setup,body)),ids))""",
        """@unsafe
def x198n_place_h(+symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),96) && w7b_stmts_has_call(body),
    u => x186_float_function(symbol,names,setup,body,ids),
    u => x198n_normalized_h(symbol,names,params,setup,x185_prepare_body(names,setup,x185_scratch_body(names,setup,body)),ids))""",
    ),
    (
        "x191_ordinary_skip_facts_large_nonloop",
        """@unsafe
def x191_ordinary(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x191_ordinary_facts(symbol,params,setup,body,ids,x190_branch_facts(params,setup,body))""",
        """@unsafe
def o2a_ordinary_choose(fast: Bool, +symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  match fast:
    case True{}:
      x191_function_saved(symbol,setup,body,X190BranchFacts{missing(),missing(),missing(),missing()},ids,
        x186_saves_frame(x181_frame(symbol,params,nt_append(P113DStmt,setup,body))))
    case False{}:
      x191_ordinary_facts(symbol,params,setup,body,ids,x190_branch_facts(params,setup,body))

@unsafe
def x191_ordinary(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  o2a_ordinary_choose(Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),128) && w7b_stmts_has_call(body),
    symbol,params,setup,body,ids)""",
    ),
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
    ap = argparse.ArgumentParser(description="Apply O2-A -O2 compile-time fixes.")
    ap.add_argument("src", type=Path, help="Input compiler.bend (or module .bend)")
    ap.add_argument("-o", "--out", type=Path, help="Output path (default: in-place)")
    ap.add_argument("--partial", action="store_true", help="Allow subset of patches (for split modules)")
    args = ap.parse_args()

    src_text = args.src.read_text(encoding="utf-8")
    new_text, status = apply_text(src_text, require_all=not args.partial)
    out_path = args.out or args.src
    out_path.write_text(new_text, encoding="utf-8")
    print(f"O2-A patched {out_path}: {', '.join(status)}")


if __name__ == "__main__":
    main()
