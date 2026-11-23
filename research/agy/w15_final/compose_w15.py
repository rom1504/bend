#!/usr/bin/env python3
"""W15-INT: Deterministic composer for selfhost/build/agy/wave15_unified/compiler.bend.

Starts from read-only selfhost/build/agy/wave13_unified/compiler.bend (which
already contains W11-A, W12-A..W12-G, W13-A..W13-D, and W13-INT FID dedup/ABI fixes)
and cleanly stacks all 5 verified Wave 13-E + Wave 14 optimization tracks:
  1. W13-E: SSE4.1 4-wide vectorizer + non-escaping stack Array<U32> + mul-add inliner + notl
  2. W14-A: Straight-line & multi-branch loop optimizer + 4-way cmov/or4 + negq + rt_op nonloop
  3. W14-F: Extended SL loop opt (fuel=560, rounds=40, %r12, xorshift/and-idx/self-movl, imull hoist)
            + class-3 (5..8 field) inline p111_rt_ctor / p111_rt_take (preserving W13-B ctor2 & take1..4!)
  4. W14-B: x86-iface v3 (strictly-linear zero-fallback decoder + CPS-pruned ABI + fast encoder)
  5. W14-E: Lean inline term-drop skip + certified native index_find & String.append + KIndexNode-first index_find
"""
from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
SRC = ROOT / "selfhost/build/agy/wave13_unified/compiler.bend"
DST = ROOT / "selfhost/build/agy/wave15_unified/compiler.bend"

W14B_PATCH = ROOT / "research/agy/w14_campaign/w14b_iface_v3/w14b_iface_v3.patch"

sys.path.insert(0, str(ROOT / "research/agy/w13_campaign/w13e_bst_hist_1x"))
sys.path.insert(0, str(ROOT / "research/agy/w14_campaign/w14a_edit_expr_1x"))
sys.path.insert(0, str(ROOT / "research/agy/w14_campaign/w14f_holdouts"))
sys.path.insert(0, str(ROOT / "research/agy/w14_campaign/w14e_drop_and_hot_leaves"))

import build_w13e
import build_w14a
import apply_w14f
import apply_w14e


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    cnt = text.count(old)
    if cnt != 1:
        raise RuntimeError(f"[compose_w15:{label}] expected 1 occurrence, found {cnt}")
    return text.replace(old, new, 1)


def apply_unified_patch(src: str, patch_path: Path, label: str) -> str:
    with tempfile.TemporaryDirectory(prefix=f"w15int_{label}_") as td:
        target = Path(td) / "compiler.bend"
        target.write_text(src, encoding="utf-8")
        r = subprocess.run(
            ["patch", "--batch", "--forward", "--no-backup-if-mismatch", "-F", "3", str(target), str(patch_path)],
            capture_output=True, text=True,
        )
        if r.returncode != 0:
            raise RuntimeError(
                f"[compose_w15:{label}] patch failed (rc={r.returncode}):\nSTDOUT:\n{r.stdout}\nSTDERR:\n{r.stderr}"
            )
        lines = [ln for ln in r.stdout.strip().splitlines() if ln.strip()]
        print(f"  [OK] {label}: {lines[-1] if lines else 'clean'}", flush=True)
        return target.read_text(encoding="utf-8")


def apply_w13e_delta(text: str) -> str:
    """Apply W13-E directly onto wave13_unified (which already contains W12-G)."""
    # Temporarily stub build_w12g.apply_patches so build_w13e.apply_w13e_patches
    # applies ONLY the W13-E delta without re-applying W12-G.
    orig_fn = build_w13e.build_w12g.apply_patches
    build_w13e.build_w12g.apply_patches = lambda s: s
    try:
        out = build_w13e.apply_w13e_patches(text)
    finally:
        build_w13e.build_w12g.apply_patches = orig_fn
    print("  [OK] W13-E (SSE4.1 vectorizer + stack Array<U32> + mul-add + notl)", flush=True)
    return out


def apply_w14a_delta(text: str) -> str:
    """Apply W14-A directly on top of W13-E."""
    orig_fn = build_w14a.build_w13e.apply_w13e_patches
    build_w14a.build_w13e.apply_w13e_patches = lambda s: s
    try:
        out = build_w14a.apply_w14a_patches(text)
    finally:
        build_w14a.build_w13e.apply_w13e_patches = orig_fn
    print("  [OK] W14-A (SL/MB loop opt + 4-way cmov/or4 + negq + rt_op nonloop)", flush=True)
    return out


def apply_w14f_delta(text: str) -> str:
    """Apply W14-F on top of wave13_unified + W13-E + W14-A while preserving
    W13-B's inline ctor2 (with rfc_seal) and p111_rt_take(1..4)."""
    # 1. Insert W14F_RT_INLINE_CODE (w14f_rt_ctor_big_text + w14f_rt_take_big_text) right before agy_rt_inline_try
    text = replace_exact(
        text,
        """@unsafe
def agy_rt_inline_try(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,""",
        apply_w14f.W14F_RT_INLINE_CODE + """
@unsafe
def agy_rt_inline_try(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,""",
        "w14f_insert_rt_inline",
    )

    # 2. Wire class-3 (count = 5..8) p111_rt_ctor and p111_rt_take in agy_rt_inline_try
    #    while keeping W13-B's p111_rt_ctor(..., 2) and p111_rt_take(..., 1..4) intact!
    old_p111_ctor2_take = """    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && agy_str_eq(symbol,"p111_rt_ctor") &&
          agy_str_eq(state,"state") && w13b_ctor2_known(ctor,ids) && U32.is_le(next,4294967288),
        u => X181Code{Con{w13b_rt_ctor2_text(name,symbol,args,agy_ctor_cid(ctor,ids),True{},ids,frame,next),chunks},U32.add(next,7),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111Const{+cnt,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_take_inline_enabled() && agy_frame_ctor_ok(frame) && agy_str_eq(symbol,"p111_rt_take") &&
          agy_str_eq(state,"state") && U32.is_ge(cnt,1) && U32.is_le(cnt,4) && U32.is_le(next,4294967279),
        u => X181Code{Con{w13b_rt_take_p111_text(name,args,cnt,ids,frame,next),chunks},U32.add(next,16),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))"""

    new_p111_ctor2_take = """    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111Const{+cnt,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && agy_str_eq(symbol,"p111_rt_ctor") &&
          agy_str_eq(state,"state") && U32.is_eq(cnt,2) && w13b_ctor2_known(ctor,ids) && U32.is_le(next,4294967288),
        u => X181Code{Con{w13b_rt_ctor2_text(name,symbol,args,agy_ctor_cid(ctor,ids),True{},ids,frame,next),chunks},U32.add(next,7),terminal,error},
        u => nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && agy_str_eq(symbol,"p111_rt_ctor") &&
          agy_str_eq(state,"state") && U32.is_ge(cnt,5) && U32.is_le(cnt,8) && p185cb_known(ctor,ids) && p185cc_known(ctor,cnt,ids) &&
          U32.is_le(next,4294967293),
        v => X181Code{Con{w14f_rt_ctor_big_text(name,args,agy_ctor_cid(ctor,ids),cnt,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        v => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111Const{+cnt,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_take_inline_enabled() && agy_frame_ctor_ok(frame) && agy_str_eq(symbol,"p111_rt_take") &&
          agy_str_eq(state,"state") && U32.is_ge(cnt,1) && U32.is_le(cnt,4) && U32.is_le(next,4294967279),
        u => X181Code{Con{w13b_rt_take_p111_text(name,args,cnt,ids,frame,next),chunks},U32.add(next,16),terminal,error},
        u => nt_choose(X181Code,agy_take_inline_enabled() && agy_frame_ctor_ok(frame) && agy_str_eq(symbol,"p111_rt_take") &&
          agy_str_eq(state,"state") && U32.is_ge(cnt,5) && U32.is_le(cnt,8) && U32.is_le(next,4294967293),
        v => X181Code{Con{w14f_rt_take_big_text(name,args,cnt,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        v => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)))"""

    text = replace_exact(text, old_p111_ctor2_take, new_p111_ctor2_take, "w14f_wire_class3_ctor_take")

    # 3. Extend W14-A straight-line loop optimizer (Pass 1 from apply_w14f.py)
    text = replace_exact(
        text,
        """    case Con{PLabel{+lTop},+rest}:
      w14a_sl_find_step(w14a_sl_take_body(220,lTop,rest,[],nt_reverse(X187Parsed,preAcc,[]),fnItems),lTop,rest,preAcc,fnItems)""",
        """    case Con{PLabel{+lTop},+rest}:
      w14a_sl_find_step(w14a_sl_take_body(560,lTop,rest,[],nt_reverse(X187Parsed,preAcc,[]),fnItems),lTop,rest,preAcc,fnItems)""",
        "w14f_sl_fuel_560",
    )
    text = replace_exact(
        text,
        """w14a_pick_free_reg([ld,0,11,10,14,3,6,9,2,1,7,8,13,15],fw,lr,ld,body,afterBody,pre,fnItems)""",
        """w14a_pick_free_reg([ld,0,11,10,14,3,6,9,2,1,7,8,12,13,15],fw,lr,ld,body,afterBody,pre,fnItems)""",
        "w14f_pick_free_r12",
    )
    text = replace_exact(
        text,
        """@unsafe
def w14a_sl_loop_opt_go(sp: W14ASLSplit, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match sp:
    case W14ASLNo{}: items
    case W14ASLHit{+pre,+lTop,+body,+backJcc,+post}:
      +bodyDedup = w14a_dedup_stores(body,body,pre,post,[])
      +canR12 = Bool.not(w5b_reg_used(12,bodyDedup)) && w14a_reg_saved_in(12,pre) &&
                w14a_post_r12_safe(post) && Bool.not(w4b_has_any_branch_to(lTop,pre)) &&
                Bool.not(w4b_has_any_branch_to(lTop,post))
      +dCarry = nt_choose(U32,canR12,u => w14a_find_carried_slot(bodyDedup,bodyDedup,pre,post),u => 0)
      +hasCarry = Bool.not(U32.is_eq(dCarry,0))
      +body0 = nt_choose(List<&2,X187Parsed>,hasCarry,u => w5b_rew_items(dCarry,12,False{},bodyDedup,[]),u => bodyDedup)
      +pre2 = nt_choose(List<&2,X187Parsed>,hasCarry,
                u => nt_append(X187Parsed,pre,[PInst{X187Instruction{"movq",[X187Mem{5,dCarry},x188_reg(12,64)]}}]),
                u => pre)
      +post2 = nt_choose(List<&2,X187Parsed>,hasCarry,
                 u => Con{PInst{X187Instruction{"movq",[x188_reg(12,64),X187Mem{5,dCarry}]}},post},
                 u => post)
      +afterBody2 : List<&2,X187Parsed> = Con{backJcc,post2}
      +fn2 = nt_append(X187Parsed,pre2,Con{PLabel{lTop},nt_append(X187Parsed,body0,afterBody2)})
      +bodyOpt = w14a_sl_rounds(8,lTop,body0,afterBody2,pre2,post2,fn2)
      nt_append(X187Parsed,pre2,Con{PLabel{lTop},nt_append(X187Parsed,bodyOpt,afterBody2)})""",
        apply_w14f.W14F_SL_HOIST_CODE + """
@unsafe
def w14f_sl_hoist_apply(cand: W14FImulCand, +pre: List<&2,X187Parsed>, +lTop: String,
    +body: List<&2,X187Parsed>, +afterBody: List<&2,X187Parsed>, +post: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match cand:
    case W14FImulNo{}:
      +fn0 = nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,body,afterBody)})
      +b1 = w14a_sl_rounds(40,lTop,body,afterBody,pre,post,fn0)
      +fn1 = nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,b1,afterBody)})
      +b2 = w14f_sl_extra(b1,afterBody,fn1,[])
      +fn2 = nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,b2,afterBody)})
      +b3 = w14a_sl_copy_go(b2,afterBody,fn2,[])
      nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,b3,afterBody)})
    case W14FImulYes{+rInv,+imm}:
      +preH = nt_append(X187Parsed,pre,[PInst{X187Instruction{"imull",[X187Imm{imm,0},x188_reg(rInv,32)]}}])
      +bodyH = w14f_imul_rew(rInv,imm,body,[])
      +fnH = nt_append(X187Parsed,preH,Con{PLabel{lTop},nt_append(X187Parsed,bodyH,afterBody)})
      +b1 = w14a_sl_rounds(40,lTop,bodyH,afterBody,preH,post,fnH)
      +fn1 = nt_append(X187Parsed,preH,Con{PLabel{lTop},nt_append(X187Parsed,b1,afterBody)})
      +b2 = w14f_sl_extra(b1,afterBody,fn1,[])
      +fn2 = nt_append(X187Parsed,preH,Con{PLabel{lTop},nt_append(X187Parsed,b2,afterBody)})
      +b3 = w14a_sl_copy_go(b2,afterBody,fn2,[])
      nt_append(X187Parsed,preH,Con{PLabel{lTop},nt_append(X187Parsed,b3,afterBody)})

@unsafe
def w14a_sl_loop_opt_go(sp: W14ASLSplit, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match sp:
    case W14ASLNo{}: items
    case W14ASLHit{+pre,+lTop,+body,+backJcc,+post}:
      +bodyClean = w14f_drop_self_movl(body,[])
      +bodyDedup = w14a_dedup_stores(bodyClean,bodyClean,pre,post,[])
      +canR12 = Bool.not(w5b_reg_used(12,bodyDedup)) && w14a_reg_saved_in(12,pre) &&
                w14a_post_r12_safe(post) && Bool.not(w4b_has_any_branch_to(lTop,pre)) &&
                Bool.not(w4b_has_any_branch_to(lTop,post))
      +dCarry = nt_choose(U32,canR12,u => w14a_find_carried_slot(bodyDedup,bodyDedup,pre,post),u => 0)
      +hasCarry = Bool.not(U32.is_eq(dCarry,0))
      +body0 = nt_choose(List<&2,X187Parsed>,hasCarry,u => w5b_rew_items(dCarry,12,False{},bodyDedup,[]),u => bodyDedup)
      +pre2 = nt_choose(List<&2,X187Parsed>,hasCarry,
                u => nt_append(X187Parsed,pre,[PInst{X187Instruction{"movq",[X187Mem{5,dCarry},x188_reg(12,64)]}}]),
                u => pre)
      +post2 = nt_choose(List<&2,X187Parsed>,hasCarry,
                 u => Con{PInst{X187Instruction{"movq",[x188_reg(12,64),X187Mem{5,dCarry}]}},post},
                 u => post)
      +afterBody2 : List<&2,X187Parsed> = Con{backJcc,post2}
      +canHoist = Bool.not(w4b_has_any_branch_to(lTop,pre2)) && Bool.not(w4b_has_any_branch_to(lTop,post2))
      +cand = nt_choose(W14FImulCand,canHoist,u => w14f_find_imul_cand(body0,body0,pre2,post2),u => W14FImulNo{})
      w14f_sl_hoist_apply(cand,pre2,lTop,body0,afterBody2,post2)""",
        "w14f_sl_loop_opt_ext",
    )
    print("  [OK] W14-F (extended SL loop opt + class-3 ctor/take, preserving W13-B ctor2/take1..4)", flush=True)
    return text


def apply_w15_p126scc_local(text: str) -> str:
    """W15-INT modular ELF visibility fix: mark private $p126scc.* mutual-recursion
    workers as STB_LOCAL so independent modules never collide on $p126scc.<slot>."""
    old = """@unsafe
def w10_is_mod_local_sym(+name: String) -> Bool:
  String.starts_with(name,"p111_FID_36_112_49_49_49_46_107_46_") ||
    String.starts_with(name,"p113d_FID_36_112_49_49_49_46_107_46_") ||
    String.starts_with(name,"p114r_FID_36_112_49_49_49_46_107_46_") ||"""
    new = """@unsafe
def w10_is_mod_local_sym(+name: String) -> Bool:
  String.starts_with(name,"p111_FID_36_112_49_49_49_46_107_46_") ||
    String.starts_with(name,"p113d_FID_36_112_49_49_49_46_107_46_") ||
    String.starts_with(name,"p114r_FID_36_112_49_49_49_46_107_46_") ||
    String.starts_with(name,"p113d_FID_36_112_49_50_54_115_99_99_46_") ||
    String.starts_with(name,"p111_FID_36_112_49_50_54_115_99_99_46_") ||"""
    out = replace_exact(text, old, new, "w15_p126scc_local")
    print("  [OK] W15-INT ($p126scc.* STB_LOCAL modular visibility fix)", flush=True)
    return out


def apply_w15_hotfixes(text: str) -> str:
    """W15-FIX surgical hotfixes:
    1. Restore cmoveq if-conversion for 1..2-stmt non-terminal `if` with empty `no`
       in w12_x190_bin_if so W14-A's w14a_cmov_table_go + w14a_sl_loop_opt fire on editdist.
    2. Bundle P113DCall context in w13e_sa_chk_body and w13e_sa_rew_body so the
       cross-module w13e_vals_single_idx call has <= 3 live captures (avoiding n5_o2's
       9+-capture p112f_inline frame-forward bug that broke bst -O2 stack-array cloning).
    """
    # Fix 1: w12_x190_bin_if cmov restoration
    text = replace_exact(
        text,
        """               (List.is_empty(&2,P113DStmt,no) || x190_branch_terminal(yes) || x190_branch_terminal(no) || U32.is_gt(p113i_size(yes),2)) &&""",
        """               (x190_branch_terminal(yes) || x190_branch_terminal(no) || U32.is_gt(p113i_size(yes),2)) &&""",
        "w15_fix_cmov_bin_if",
    )

    # Fix 2a: w13e_sa_chk_body P113DCall low-capture helper
    chk_helper = """type W13ESAChkCallCtx is Data:
  W13ESAChkCallCtx{+rest: List<&2,P113DStmt>, +aset: List<&2,String>, +isRoot: Bool,
                   +selfName: String, +paramIdx: U32, +fs: List<&2,P113DFunction>,
                   +fuel: U32, +retIdx: U32}

@unsafe
def w13e_sa_chk_dcall_go(+aidx: U32, +dsts: List<&2,String>, +target: String, ctx: W13ESAChkCallCtx) -> W13ESAChk:
  match ctx:
    case W13ESAChkCallCtx{rest,aset,isRoot,selfName,paramIdx,fs,fuel,retIdx}:
      nt_choose(W13ESAChk,U32.is_eq(aidx,99),
        u => nt_choose(W13ESAChk,isRoot && agy_str_eq(target,selfName),v => W13ESABad{},
          v => w13e_sa_chk_body(rest,w13e_str_del_many(aset,dsts),isRoot,selfName,paramIdx,fs,fuel,retIdx)),
        u => nt_choose(W13ESAChk,U32.is_eq(aidx,98) || agy_str_eq(target,selfName),
          v => W13ESABad{},
          v => w13e_sa_chk_after_call(w13e_sa_chk_callee(w13e_find_fn(fs,target),aidx,fs,fuel),
            dsts,rest,aset,isRoot,selfName,paramIdx,fs,fuel,retIdx)))

@unsafe
def w13e_sa_chk_dcall(+args: List<&2,N111Value>, +aset: List<&2,String>,
    +dsts: List<&2,String>, +target: String, ctx: W13ESAChkCallCtx) -> W13ESAChk:
  w13e_sa_chk_dcall_go(w13e_vals_single_idx(args,aset,0,99),dsts,target,ctx)

@unsafe
def w13e_sa_chk_body(body,aset,isRoot,selfName,paramIdx,fs,fuel,retIdx):"""

    text = replace_exact(
        text,
        """@unsafe
def w13e_sa_chk_body(body,aset,isRoot,selfName,paramIdx,fs,fuel,retIdx):""",
        chk_helper,
        "w15_fix_sa_chk_helper",
    )

    text = replace_exact(
        text,
        """    case Con{P113DCall{+dsts,+target,+args},+rest}:
      +aidx = w13e_vals_single_idx(args,aset,0,99)
      nt_choose(W13ESAChk,U32.is_eq(aidx,99),
        u => nt_choose(W13ESAChk,isRoot && agy_str_eq(target,selfName),v => W13ESABad{},
          v => w13e_sa_chk_body(rest,w13e_str_del_many(aset,dsts),isRoot,selfName,paramIdx,fs,fuel,retIdx)),
        u => nt_choose(W13ESAChk,U32.is_eq(aidx,98) || agy_str_eq(target,selfName),
          v => W13ESABad{},
          v => w13e_sa_chk_after_call(w13e_sa_chk_callee(w13e_find_fn(fs,target),aidx,fs,fuel),
            dsts,rest,aset,isRoot,selfName,paramIdx,fs,fuel,retIdx)))""",
        """    case Con{P113DCall{+dsts,+target,+args},+rest}:
      w13e_sa_chk_dcall(args,aset,dsts,target,W13ESAChkCallCtx{rest,aset,isRoot,selfName,paramIdx,fs,fuel,retIdx})""",
        "w15_fix_sa_chk_call",
    )

    # Fix 2b: w13e_sa_rew_body P113DCall low-capture helper
    rew_helper = """type W13ESARewCallCtx is Data:
  W13ESARewCallCtx{+args: List<&2,N111Value>, +rest: List<&2,P113DStmt>, +aset: List<&2,String>,
                   +cls: U32, +seq: U32, +fs: List<&2,P113DFunction>, +specs: List<&2,W13ESACloneSpec>}

@unsafe
def w13e_sa_rew_dcall_go(+aidx: U32, +dsts: List<&2,String>, +target: String, ctx: W13ESARewCallCtx) -> W13ESARew:
  match ctx:
    case W13ESARewCallCtx{args,rest,aset,cls,seq,fs,specs}:
      nt_choose(W13ESARew,U32.is_lt(aidx,98),
        u =>
          +cName = w13e_sa_clone_name(target,cls,aidx)
          +sp1 = nt_choose(List<&2,W13ESACloneSpec>,w13e_sa_spec_has(specs,target,cls,aidx),
            v => specs,v => Con{W13ESACloneSpec{target,cls,aidx},specs})
          +rIdx = w13e_sa_chk_ret(w13e_sa_chk_callee(w13e_find_fn(fs,target),aidx,fs,3))
          +as1 = w13e_str_del_many(aset,dsts)
          +as2 = nt_choose(List<&2,String>,U32.is_lt(rIdx,nt_count(String,dsts)),
            v => w13e_str_add(as1,w13e_nth_str(dsts,rIdx)),v => as1)
          w13e_sa_rew_cons(P113DCall{dsts,cName,args},w13e_sa_rew_body(rest,as2,cls,seq,fs,sp1)),
        u => w13e_sa_rew_cons(P113DCall{dsts,target,args},w13e_sa_rew_body(rest,w13e_str_del_many(aset,dsts),cls,seq,fs,specs)))

@unsafe
def w13e_sa_rew_dcall(+args: List<&2,N111Value>, +aset: List<&2,String>,
    +dsts: List<&2,String>, +target: String, ctx: W13ESARewCallCtx) -> W13ESARew:
  w13e_sa_rew_dcall_go(w13e_vals_single_idx(args,aset,0,99),dsts,target,ctx)

@unsafe
def w13e_sa_rew_body(body,aset,cls,seq,fs,specs):"""

    text = replace_exact(
        text,
        """@unsafe
def w13e_sa_rew_body(body,aset,cls,seq,fs,specs):""",
        rew_helper,
        "w15_fix_sa_rew_helper",
    )

    text = replace_exact(
        text,
        """    case Con{P113DCall{+dsts,+target,+args},+rest}:
      +aidx = w13e_vals_single_idx(args,aset,0,99)
      nt_choose(W13ESARew,U32.is_lt(aidx,98),
        u =>
          +cName = w13e_sa_clone_name(target,cls,aidx)
          +sp1 = nt_choose(List<&2,W13ESACloneSpec>,w13e_sa_spec_has(specs,target,cls,aidx),
            v => specs,v => Con{W13ESACloneSpec{target,cls,aidx},specs})
          +rIdx = w13e_sa_chk_ret(w13e_sa_chk_callee(w13e_find_fn(fs,target),aidx,fs,3))
          +as1 = w13e_str_del_many(aset,dsts)
          +as2 = nt_choose(List<&2,String>,U32.is_lt(rIdx,nt_count(String,dsts)),
            v => w13e_str_add(as1,w13e_nth_str(dsts,rIdx)),v => as1)
          w13e_sa_rew_cons(P113DCall{dsts,cName,args},w13e_sa_rew_body(rest,as2,cls,seq,fs,sp1)),
        u => w13e_sa_rew_cons(P113DCall{dsts,target,args},w13e_sa_rew_body(rest,w13e_str_del_many(aset,dsts),cls,seq,fs,specs)))""",
        """    case Con{P113DCall{+dsts,+target,+args},+rest}:
      w13e_sa_rew_dcall(args,aset,dsts,target,W13ESARewCallCtx{args,rest,aset,cls,seq,fs,specs})""",
        "w15_fix_sa_rew_call",
    )

    print("  [OK] W15-FIX (w12_x190_bin_if cmov restoration + w13e_sa low-capture P113DCall helpers)", flush=True)
    return text


def main() -> None:
    print(f"=== W15-INT Compose: {SRC} -> {DST} ===", flush=True)
    src = SRC.read_text(encoding="utf-8")
    base_len = len(src)
    base_lines = src.count("\n")
    print(f"  Base wave13_unified: {base_len:,} B ({base_lines:,} lines)", flush=True)

    src = apply_w13e_delta(src)
    src = apply_w14a_delta(src)
    src = apply_w14f_delta(src)
    src = apply_unified_patch(src, W14B_PATCH, "W14-B (x86-iface v3)")
    src = apply_w14e.apply_w14e(src)
    print("  [OK] W14-E (inline term-drop skip + certified index_find & String.append)", flush=True)
    src = apply_w15_p126scc_local(src)
    src = apply_w15_hotfixes(src)

    DST.parent.mkdir(parents=True, exist_ok=True)
    DST.write_text(src, encoding="utf-8")
    print(
        f"=== Wrote {DST} ({len(src):,} B, +{len(src)-base_len:,} B, {src.count(chr(10)):,} lines) ===",
        flush=True,
    )


if __name__ == "__main__":
    main()
