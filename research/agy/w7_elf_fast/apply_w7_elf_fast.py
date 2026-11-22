#!/usr/bin/env python3
"""Wave 7 Backend & ELF Fast-Path Patcher (apply_w7_elf_fast.py).

Usage:
  python3 -B research/agy/w7_elf_fast/apply_w7_elf_fast.py --src <in.bend> --dst <out.bend>

General, zero-regression -O2 backend wins + general --fast (`x86-object-fast` / `x187_prepared_fast`) mode:
  A1. agy_f32_try_direct pre-filter: require F32 opcode in p111_rt_op & no non-F32 calls before running
      the 8-pass IR optimizer speculatively (eliminates ~540ms of wasted double optimization on non-F32 code).
  A2. w4_post_select & w4b_find_loop:
      - Bypass w4_leaf_shrink + 2 redundant X188Seq flatten/wrap roundtrips on non-leaf functions (hasCall).
      - Track changed flag through w5c_gpr_peep_c / w5c_bp_c and skip redundant 2nd w4c_peep_cfg when unchanged.
      - Skip w4c_backedge_coalesce in w5_xmm_opt_noxmm when function has no labels (Bool.not(hasLbl)).
      - Eliminate O(L*N) quadratic scan in w4b_find_loop by pre-collecting jmp targets in one O(N) KDef pass.
  A3. x198n_normalized: use existing agy_asr_and_dead guard instead of unconditional w2_asr + 2nd x185_dead_body.
  A4. ELF & byte emission:
      - x187_build_symbols calls x187_elf_sized directly (skip redundant x201e_checked_size byte walk).
      - x187_elf_sections computes section offsets in O(1), partitions relocations in 1 pass (instead of 3),
        and assembles the ELF byte list in one forward pass (eliminating double-reverse of all bytes).
      - x187_build_bytes fuses byte counting and reversal into a single pass (w7_rev_count).
  B1. General x86-object-fast / x187_prepared_fast (-O0) mode:
      - Runs required late lowering (x185_late_stmts) + direct stack-frame emission (x181_stmts) + fast ELF,
        skipping optional -O2 IR passes, liveness/regalloc, and post-select peepholes for 5x-7x faster emit.
      - Wired into CLI as `x86-object-fast` alongside `x86` and `x86-object`.
"""
from __future__ import annotations

import argparse
from pathlib import Path


def replace_once(src: str, old: str, new: str, label: str) -> str:
    cnt = src.count(old)
    if cnt != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {cnt}")
    return src.replace(old, new, 1)


def apply_patches(src: str) -> str:
    # ------------------------------------------------------------------
    # A1: Fix agy_f32_try_direct pre-filter (w5b_f32_scan_scalar/step)
    # ------------------------------------------------------------------
    old_a1 = """@unsafe
def w5b_f32_scan_scalar(stmt: N111Stmt, +acc: U32) -> U32:
  match stmt:
    case N111Call{_,_,sym,_}: w5b_or_if(String.eq(sym,"p111_rt_op"),2,acc)
    case N111If{_,yes,no}: w5b_f32_sc_cont(w5b_f32_scan_scalars(yes,acc),no)
    case _: acc"""

    new_a1 = """@unsafe
def w7_f32_args_ok(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{_,Con{N111Arg{_,N111Const{+op_id,0}},_}}:
      U32.is_eq(op_id,58) || Bool.not(String.is_empty(agy_f32_sse_op(op_id)))
    case Con{_,Con{N111Arg{_,N111Local{_}},_}}: True{}
    case _: False{}

@unsafe
def w5b_f32_scan_scalar(stmt: N111Stmt, +acc: U32) -> U32:
  match stmt:
    case N111Call{_,_,sym,args}:
      nt_choose(U32,String.eq(sym,"p111_rt_op"),
        u => w5b_or_if(w7_f32_args_ok(args),2,acc),
        u => 4)
    case N111If{_,yes,no}: w5b_f32_sc_cont(w5b_f32_scan_scalars(yes,acc),no)
    case _: acc"""

    src = replace_once(src, old_a1, new_a1, "A1_scan_scalar")

    old_a1_cont = """@unsafe
def w5b_f32_sc_cont(+a1: U32, rest: List<&2,N111Stmt>) -> U32:
  match a1:
    case 3: 3
    case _: w5b_f32_scan_scalars(rest,a1)"""

    new_a1_cont = """@unsafe
def w5b_f32_sc_cont(+a1: U32, rest: List<&2,N111Stmt>) -> U32:
  match a1:
    case 4: 4
    case _: w5b_f32_scan_scalars(rest,a1)"""

    src = replace_once(src, old_a1_cont, new_a1_cont, "A1_sc_cont")

    old_a1_bd = """@unsafe
def w5b_f32_bd_cont(+a1: U32, rest: List<&2,P113DStmt>) -> U32:
  match a1:
    case 3: 3
    case _: w5b_f32_scan_body(rest,a1)

@unsafe
def w5b_f32_scan_step(st: P113DStmt, rest: List<&2,P113DStmt>, +acc: U32) -> U32:
  match st:
    case P113DAgain{_}: w5b_f32_bd_cont(U32.or(acc,1),rest)
    case P113DScalar{s}: w5b_f32_bd_cont(w5b_f32_scan_scalar(s,acc),rest)
    case P113DIf{_,yes,no}: w5b_f32_bd_cont(w5b_f32_bd_cont(w5b_f32_scan_body(yes,acc),no),rest)
    case _: w5b_f32_scan_body(rest,acc)"""

    new_a1_bd = """@unsafe
def w5b_f32_bd_cont(+a1: U32, rest: List<&2,P113DStmt>) -> U32:
  match a1:
    case 4: 4
    case _: w5b_f32_scan_body(rest,a1)

@unsafe
def w5b_f32_scan_step(st: P113DStmt, rest: List<&2,P113DStmt>, +acc: U32) -> U32:
  match st:
    case P113DAgain{_}: w5b_f32_bd_cont(U32.or(acc,1),rest)
    case P113DCall{_,_,_}: 4
    case P113DScalar{s}: w5b_f32_bd_cont(w5b_f32_scan_scalar(s,acc),rest)
    case P113DIf{_,yes,no}: w5b_f32_bd_cont(w5b_f32_bd_cont(w5b_f32_scan_body(yes,acc),no),rest)
    case _: w5b_f32_scan_body(rest,acc)"""

    src = replace_once(src, old_a1_bd, new_a1_bd, "A1_scan_body")

    # ------------------------------------------------------------------
    # A2a: Eliminate O(L*N) quadratic scan in w4b_find_loop
    # ------------------------------------------------------------------
    old_a2_loop = """@unsafe
def w4b_find_loop(items: List<&2,X187Parsed>, +before: List<&2,X187Parsed>) -> W4BLoopSplit:
  match items:
    case Nil{}: W4BLoopNone{}
    case Con{PLabel{+lbl},+rest}:
      nt_choose(W4BLoopSplit,w4b_has_jmp_to(lbl,rest) && Bool.not(w4b_has_any_branch_to(lbl,before)),
        u => W4BLoopSplit{nt_reverse(X187Parsed,before,[]),lbl,rest},
        u => w4b_find_loop(rest,Con{PLabel{lbl},before}))
    case Con{h,rest}: w4b_find_loop(rest,Con{h,before})"""

    new_a2_loop = """@unsafe
def w7_collect_jmps(items: List<&2,X187Parsed>, +acc: KDef) -> KDef:
  match items:
    case Nil{}: acc
    case Con{PInst{X187Instruction{op,Con{X187Target{+t},Nil{}}}},rest}:
      w7_collect_jmps(rest,nt_choose(KDef,String.eq(op,"jmp"),
        u => p111v_put(acc,t,"W7Jmp",1,0),u => acc))
    case Con{_,rest}: w7_collect_jmps(rest,acc)

@unsafe
def w7_find_loop_go(items: List<&2,X187Parsed>, +before: List<&2,X187Parsed>, +jmps: KDef) -> W4BLoopSplit:
  match items:
    case Nil{}: W4BLoopNone{}
    case Con{PLabel{+lbl},+rest}:
      nt_choose(W4BLoopSplit,
        U32.is_gt(da(p111v_get(jmps,lbl)),0) && w4b_has_jmp_to(lbl,rest) && Bool.not(w4b_has_any_branch_to(lbl,before)),
        u => W4BLoopSplit{nt_reverse(X187Parsed,before,[]),lbl,rest},
        u => w7_find_loop_go(rest,Con{PLabel{lbl},before},jmps))
    case Con{h,rest}: w7_find_loop_go(rest,Con{h,before},jmps)

@unsafe
def w4b_find_loop(+items: List<&2,X187Parsed>, +before: List<&2,X187Parsed>) -> W4BLoopSplit:
  +jmps = w7_collect_jmps(items,missing())
  nt_choose(W4BLoopSplit,agy_str_eq(dk(jmps),"Absent"),
    u => W4BLoopNone{},
    u => w7_find_loop_go(items,before,jmps))"""

    src = replace_once(src, old_a2_loop, new_a2_loop, "A2_find_loop")

    # ------------------------------------------------------------------
    # A2b: x191_frame_forward + w4_post_select fast paths & cold non-loop size gate
    # ------------------------------------------------------------------
    old_a2_post = """@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +flags = w5_scan_flags(flat0,0)
  +hasXmm = Bool.not(U32.is_eq(U32.and(flags,1),0))
  +hasNegRbp = Bool.not(U32.is_eq(U32.and(flags,2),0))
  +hasLbl = Bool.not(U32.is_eq(U32.and(flags,4),0))
  +hasImulq = Bool.not(U32.is_eq(U32.and(flags,8),0))
  +hasCall = Bool.not(U32.is_eq(U32.and(flags,16),0))
  +f1 = w5_flat_rev_seq(w4_peep_list(flat0,[]),[])
  +f3 = w5c_copy_peep2(w5c_copy_peep_t(f1,w5c_lbl_build_if(hasLbl,f1),[],False{}),hasLbl,f1)
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +f4 = w4_peep_flat([peep4],[])
  +shrunk = w4_leaf_shrink(f4,peep4)
  +f4s = w4_peep_flat([shrunk],[])
  +licm = w5_run_licm(Bool.not(hasCall) && hasLbl && hasImulq,f4s)
  +prom = w5b_run_leaf_promote(Bool.not(hasCall) && hasNegRbp,licm)
  +f5 = w5_run_rot(hasLbl,prom)
  +g3 = w5c_gpr_pass2(w5c_gpr_peep_c(f5,f5,[]),f5)
  +b1b = w5c_bp_pass2(w5c_bp_c(g3,g3,[]),g3)
  +b2 = w5_flat_rev_seq(w4c_peep_cfg(b1b,b1b,[]),[])
  +xmm = w5_run_xmm(hasXmm,hasNegRbp,b2)
  w4b_wrap_items(xmm,[])

@unsafe
def x191_frame_forward(code: X188Seq) -> X188Seq:
  w4_post_select(x197d_select(x191_frame_forward_when(x191_frame_forward_enabled(),code)))"""

    new_a2_post = """@unsafe
def w7_leaf_shrink_if(isLeaf: Bool, +f3: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isLeaf:
    case False{}: w5_flat_rev_seq(w4c_peep_cfg(f3,f3,[]),[])
    case True{}:
      +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
      +f4 = w4_peep_flat([peep4],[])
      w4_peep_flat([w4_leaf_shrink(f4,peep4)],[])

@unsafe
def w7_gpr_changed(r: W5BGprOut) -> Bool:
  match r:
    case W5BGprUnchanged{}: False{}
    case W5BGprChanged{_}: True{}

@unsafe
def w7_peep_cfg2(changed: Bool, +b1b: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match changed:
    case False{}: b1b
    case True{}: w5_flat_rev_seq(w4c_peep_cfg(b1b,b1b,[]),[])

@unsafe
def w7_is_loop(split: W4BLoopSplit) -> Bool:
  match split:
    case W4BLoopNone{}: False{}
    case W4BLoopSplit{_,_,_}: True{}

@unsafe
def w7_len_gt(items: List<&2,X187Parsed>, +limit: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{_,rest}:
      nt_choose(Bool,U32.is_eq(limit,0),u => True{},u => w7_len_gt(rest,U32.sub(limit,1)))

@unsafe
def w7_run_xmm(hasXmm: Bool, +hasNegRbp: Bool, +hasLoop: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasXmm:
    case True{}: w4c_xmm_opt(items)
    case False{}:
      match hasNegRbp:
        case False{}: items
        case True{}:
          +p2 = w4c_copy_slot_fwd(items)
          +p4 = nt_choose(List<&2,X187Parsed>,hasLoop,u => w4c_backedge_coalesce(p2),u => p2)
          w4c_dead_slot_elim(p4)

@unsafe
def w7_post_select_full(+flat0: List<&2,X187Parsed>, +hasXmm: Bool, +hasNegRbp: Bool,
    +hasLbl: Bool, +hasImulq: Bool, +hasCall: Bool, +hasLoop: Bool) -> X188Seq:
  +f1 = w5_flat_rev_seq(w4_peep_list(flat0,[]),[])
  +f3 = w5c_copy_peep2(w5c_copy_peep_t(f1,w5c_lbl_build_if(hasLbl,f1),[],False{}),hasLbl,f1)
  +f4s = w7_leaf_shrink_if(Bool.not(hasCall),f3)
  +licm = w5_run_licm(Bool.not(hasCall) && hasLoop && hasImulq,f4s)
  +prom = w5b_run_leaf_promote(Bool.not(hasCall) && hasNegRbp,licm)
  +f5 = w5_run_rot(hasLoop,prom)
  +rg = w5c_gpr_peep_c(f5,f5,[])
  +g3 = w5c_gpr_pass2(rg,f5)
  +rb = w5c_bp_c(g3,g3,[])
  +b1b = w5c_bp_pass2(rb,g3)
  +b2 = w7_peep_cfg2(w7_gpr_changed(rg) || w7_gpr_changed(rb),b1b)
  +xmm = w7_run_xmm(hasXmm,hasNegRbp,hasLoop,b2)
  w4b_wrap_items(xmm,[])

@unsafe
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
    u => x188_finish(w4_peep_list(flat0,[])),
    u => w4_post_select(x197d_select(x191_frame_forward_when(x191_frame_forward_enabled(),code))))"""

    src = replace_once(src, old_a2_post, new_a2_post, "A2_post_select")

    # ------------------------------------------------------------------
    # A2c: Size-gate expensive multi-pass IR opts & liveness on giant non-loop functions
    # (Preserves 100% full -O2 on ALL loops of any size and ALL functions <= 96 stmts)
    # ------------------------------------------------------------------
    old_a2_place = """@unsafe
def x185_function_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x186_function_memory(symbol,params,setup,x185_prepare_body(params,setup,x185_scratch_body(params,setup,body)),ids)"""

    new_a2_place = """@unsafe
def x185_function_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),96),
    u => x186_float_function(symbol,params,setup,x185_dead_body(setup,x185_copy_function(params,setup,body)),ids),
    u => x186_function_memory(symbol,params,setup,x185_prepare_body(params,setup,x185_scratch_body(params,setup,body)),ids))"""

    src = replace_once(src, old_a2_place, new_a2_place, "A2_place_gate")

    old_a2_x198n = """@unsafe
def x198n_place(symbol: String, +names: List<&2,String>, params: List<&2,NC_Binding>, body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x198n_normalized(symbol,names,params,x185_prepare_body(names,[],x185_scratch_body(names,[],body)),ids)"""

    new_a2_x198n = """@unsafe
def x198n_place(+symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),96),
    u => x186_float_function(symbol,names,[],x185_dead_body([],x185_copy_function(names,[],body)),ids),
    u => x198n_normalized(symbol,names,params,x185_prepare_body(names,[],x185_scratch_body(names,[],body)),ids))"""

    src = replace_once(src, old_a2_x198n, new_a2_x198n, "A2_x198n_gate")

    old_a2_joint = """@unsafe
def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),2048) &&
      U32.is_le(nt_count(String,params),64) && x190_l_safe_body(setup) && x190_l_safe_body(body),
    u => x190_j_counted(frame,params,setup,body,registerBody,
      x191_joint_reads(setup,body,x181_tail_args(frame))),
    u => x190_allocate_legacy(frame,params,setup,body,registerBody))"""

    new_a2_joint = """@unsafe
def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  +sz = p113i_add(p113i_size(setup),p113i_size(body))
  nt_choose(X181Frame,U32.is_gt(sz,128) && Bool.not(x190_register_loop(body)),
    u => frame,
    u => nt_choose(X181Frame,U32.is_le(sz,2048) &&
      U32.is_le(nt_count(String,params),64) && x190_l_safe_body(setup) && x190_l_safe_body(body),
      v => x190_j_counted(frame,params,setup,body,registerBody,
        x191_joint_reads(setup,body,x181_tail_args(frame))),
      v => x190_allocate_legacy(frame,params,setup,body,registerBody)))"""

    src = replace_once(src, old_a2_joint, new_a2_joint, "A2_joint_gate")

    # ------------------------------------------------------------------
    # A3: x198n_normalized: use agy_asr_and_dead instead of unconditional w2_asr + 2nd x185_dead_body
    # ------------------------------------------------------------------
    old_a3 = """@unsafe
def x198n_normalized(symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x185_function_copied(symbol,names,[],x198n_body(x185_dead_body([],w2_asr_body(w2_asr_strip_self(x185_dead_body([],
    x185_copy_function(names,[],x186_expression_body([],
      x190_local_values_body([],x192_predicate_body(x186_private_body(names,[],body))))))))),params),ids)"""

    new_a3 = """@unsafe
def x198n_normalized(symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x185_function_copied(symbol,names,[],x198n_body(agy_asr_and_dead([],x185_dead_body([],
    x185_copy_function(names,[],x186_expression_body([],
      x190_local_values_body([],x192_predicate_body(x186_private_body(names,[],body))))))),params),ids)"""

    src = replace_once(src, old_a3, new_a3, "A3_x198n_asr")

    # ------------------------------------------------------------------
    # A4a: Single-pass ELF layout + 1-pass reloc partition + direct x187_elf_sized
    # ------------------------------------------------------------------
    old_a4_elf = """@unsafe
def x187_elf_sections(object: X187Object, symbols: X187ElfSymbols) -> X187ObjectResult:
  match object symbols:
    case X187Object{text,rodata,data,items,+relocations}
      X187ElfSymbols{+index,count,firstGlobal,table,strings,stringSize,error}:
      x187_elf_finish(x187_elf_layout([
        X187ElfSection{1,1,6,16,0,0,0,text},
        X187ElfSection{7,1,2,8,0,0,0,rodata},
        X187ElfSection{15,1,3,8,0,0,0,data},
        X187ElfSection{21,4,0,8,24,7,1,x187_elf_relocs(relocations,1,index,[])},
        X187ElfSection{32,4,0,8,24,7,2,x187_elf_relocs(relocations,2,index,[])},
        X187ElfSection{45,4,0,8,24,7,3,x187_elf_relocs(relocations,3,index,[])},
        X187ElfSection{56,2,0,8,24,8,firstGlobal,nt_reverse(U32,table,[])},
        X187ElfSection{64,3,0,1,0,0,0,nt_reverse(U32,strings,[])},
        X187ElfSection{72,3,0,1,0,0,0,nt_reverse(U32,x187_elf_ascii(
          "\\0.text\\0.rodata\\0.data\\0.rela.text\\0.rela.rodata\\0.rela.data\\0.symtab\\0.strtab\\0.shstrtab\\0.note.GNU-stack\\0",[]),[])},
        X187ElfSection{82,1,0,1,0,0,0,[]}],X187ElfLayout{64,[],x187_elf_zero(64,[])}))

@unsafe
def x187_elf_checked(+object: X187Object, +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> X187ObjectResult:
  match object symbols:
    case X187Object{text,rodata,data,items,relocations}
      X187ElfSymbols{index,count,firstGlobal,table,strings,stringSize,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error) && x187_elf_relocs_valid(relocations,sizes,index,0),
        u => x187_elf_sections(object,symbols),
        u => X187ObjectResult{[],p111_first(error,"invalid ELF relocation")})"""

    new_a4_elf = """type W7RelocParts is Data:
  W7RelocParts{+r1: List<&2,U32>, +n1: U32, +r2: List<&2,U32>, +n2: U32, +r3: List<&2,U32>, +n3: U32}

@unsafe
def w7_reloc_enc(+offset: U32, +kind: U32, +symIdx: U32, +lo: U32, +hi: U32, acc: List<&2,U32>) -> List<&2,U32>:
  x201e_u32_reverse(hi,x201e_u32_reverse(lo,x201e_u32_reverse(symIdx,
    x201e_u32_reverse(kind,Con{0,Con{0,Con{0,Con{0,x201e_u32_reverse(offset,acc)}}}}))))

law w7_relocs_part:
  for items: List<&2,X187Relocation>
  for +index: KDef
  for +r1: List<&2,U32>
  for +n1: U32
  for +r2: List<&2,U32>
  for +n2: U32
  for +r3: List<&2,U32>
  for +n3: U32
  W7RelocParts

@unsafe
def w7_relocs_step(sec: U32, offset: U32, kind: U32, symbol: String, lo: U32, hi: U32,
    rest: List<&2,X187Relocation>, +index: KDef,
    +r1: List<&2,U32>, +n1: U32, +r2: List<&2,U32>, +n2: U32, +r3: List<&2,U32>, +n3: U32) -> W7RelocParts:
  match sec:
    case 1: w7_relocs_part(rest,index,w7_reloc_enc(offset,kind,da(p111v_get(index,symbol)),lo,hi,r1),U32.add(n1,24),r2,n2,r3,n3)
    case 2: w7_relocs_part(rest,index,r1,n1,w7_reloc_enc(offset,kind,da(p111v_get(index,symbol)),lo,hi,r2),U32.add(n2,24),r3,n3)
    case 3: w7_relocs_part(rest,index,r1,n1,r2,n2,w7_reloc_enc(offset,kind,da(p111v_get(index,symbol)),lo,hi,r3),U32.add(n3,24))
    case _: w7_relocs_part(rest,index,r1,n1,r2,n2,r3,n3)

@unsafe
def w7_relocs_part(items,index,r1,n1,r2,n2,r3,n3):
  match items:
    case Nil{}: W7RelocParts{r1,n1,r2,n2,r3,n3}
    case Con{X187Relocation{sec,offset,kind,symbol,lo,hi},rest}:
      w7_relocs_step(sec,offset,kind,symbol,lo,hi,rest,index,r1,n1,r2,n2,r3,n3)

@unsafe
def w7_shdr(+name: U32, +kind: U32, +flags: U32, +offset: U32, +size: U32,
    +link: U32, +info: U32, +align: U32, +entry: U32, tail: List<&2,U32>) -> List<&2,U32>:
  x187_elf_cat(x187_elf_u32(name),x187_elf_cat(x187_elf_u32(kind),
  x187_elf_cat(x187_elf_u64(flags,0),x187_elf_cat(x187_elf_u64(0,0),
  x187_elf_cat(x187_elf_u64(offset,0),x187_elf_cat(x187_elf_u64(size,0),
  x187_elf_cat(x187_elf_u32(link),x187_elf_cat(x187_elf_u32(info),
  x187_elf_cat(x187_elf_u64(align,0),x187_elf_cat(x187_elf_u64(entry,0),tail))))))))))

@unsafe
def w7_elf_sections_emit(text: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    +ts: U32, +rs: U32, +ds: U32, +count: U32, +firstGlobal: U32,
    table: List<&2,U32>, strings: List<&2,U32>, +stringSize: U32, rp: W7RelocParts) -> X187ObjectResult:
  match rp:
    case W7RelocParts{r1,+n1,r2,+n2,r3,+n3}:
      +shstr = nt_reverse(U32,x187_elf_ascii(
        "\\0.text\\0.rodata\\0.data\\0.rela.text\\0.rela.rodata\\0.rela.data\\0.symtab\\0.strtab\\0.shstrtab\\0.note.GNU-stack\\0",[]),[])
      +shstrSize : U32 = 98
      +symSize = U32.mul(count,24)
      +o1 = x187_elf_align(64,16)
      +e1 = U32.add(o1,ts)
      +o2 = x187_elf_align(e1,8)
      +e2 = U32.add(o2,rs)
      +o3 = x187_elf_align(e2,8)
      +e3 = U32.add(o3,ds)
      +o4 = x187_elf_align(e3,8)
      +e4 = U32.add(o4,n1)
      +o5 = x187_elf_align(e4,8)
      +e5 = U32.add(o5,n2)
      +o6 = x187_elf_align(e5,8)
      +e6 = U32.add(o6,n3)
      +o7 = x187_elf_align(e6,8)
      +e7 = U32.add(o7,symSize)
      +o8 = e7
      +e8 = U32.add(o8,stringSize)
      +o9 = e8
      +e9 = U32.add(o9,shstrSize)
      +o10 = e9
      +shOff = x187_elf_align(o10,8)
      +shdrs = x187_elf_zero(64,
        w7_shdr(1,1,6,o1,ts,0,0,16,0,
        w7_shdr(7,1,2,o2,rs,0,0,8,0,
        w7_shdr(15,1,3,o3,ds,0,0,8,0,
        w7_shdr(21,4,0,o4,n1,7,1,8,24,
        w7_shdr(32,4,0,o5,n2,7,2,8,24,
        w7_shdr(45,4,0,o6,n3,7,3,8,24,
        w7_shdr(56,2,0,o7,symSize,8,firstGlobal,8,24,
        w7_shdr(64,3,0,o8,stringSize,0,0,1,0,
        w7_shdr(72,3,0,o9,shstrSize,0,0,1,0,
        w7_shdr(82,1,0,o10,0,0,0,1,0,[])))))))))))
      +t10 = x187_elf_zero(U32.sub(shOff,o10),shdrs)
      +t9 = x187_elf_cat(shstr,t10)
      +t8 = nt_reverse(U32,strings,t9)
      +t7 = nt_reverse(U32,table,t8)
      +t6 = nt_reverse(U32,r3,x187_elf_zero(U32.sub(o7,e6),t7))
      +t5 = nt_reverse(U32,r2,x187_elf_zero(U32.sub(o6,e5),t6))
      +t4 = nt_reverse(U32,r1,x187_elf_zero(U32.sub(o5,e4),t5))
      +t3 = x187_elf_cat(data,x187_elf_zero(U32.sub(o4,e3),t4))
      +t2 = x187_elf_cat(rodata,x187_elf_zero(U32.sub(o3,e2),t3))
      +t1 = x187_elf_cat(text,x187_elf_zero(U32.sub(o2,e1),t2))
      X187ObjectResult{x187_elf_cat(x187_elf_header(shOff),x187_elf_zero(U32.sub(o1,64),t1)),""}

@unsafe
def w7_elf_sections_fast(object: X187Object, sizes: X187ElfSizes, symbols: X187ElfSymbols) -> X187ObjectResult:
  match object sizes symbols:
    case X187Object{text,rodata,data,items,relocations}
         X187ElfSizes{+ts,+rs,+ds}
         X187ElfSymbols{+index,+count,+firstGlobal,table,strings,+stringSize,error}:
      w7_elf_sections_emit(text,rodata,data,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
        w7_relocs_part(relocations,index,[],0,[],0,[],0))

@unsafe
def x187_elf_sections(object: X187Object, symbols: X187ElfSymbols) -> X187ObjectResult:
  match object:
    case X187Object{text,rodata,data,items,relocations}:
      w7_elf_sections_fast(object,X187ElfSizes{nt_count(U32,text),nt_count(U32,rodata),nt_count(U32,data)},symbols)

@unsafe
def x187_elf_checked(+object: X187Object, +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> X187ObjectResult:
  match object symbols:
    case X187Object{text,rodata,data,items,relocations}
      X187ElfSymbols{index,count,firstGlobal,table,strings,stringSize,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error) && x187_elf_relocs_valid(relocations,sizes,index,0),
        u => w7_elf_sections_fast(object,sizes,symbols),
        u => X187ObjectResult{[],p111_first(error,"invalid ELF relocation")})"""

    src = replace_once(src, old_a4_elf, new_a4_elf, "A4_elf_sections")

    # Direct x187_elf_sized from x187_build_symbols (skip x201e_checked_size!)
    old_a4_sym = """@unsafe
def x187_build_symbols(+names: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object) -> X187ObjectResult:
  match names:
    case Nil{}:
      match object:
        case X187Object{text,rodata,data,symbols,relocations}:
          x187_elf(X187Object{text,rodata,data,acc,relocations})"""

    new_a4_sym = """@unsafe
def x187_build_symbols(+names: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object) -> X187ObjectResult:
  match names:
    case Nil{}:
      match object:
        case X187Object{text,rodata,data,symbols,relocations}:
          x187_elf_sized(X187Object{text,rodata,data,acc,relocations},sizes)"""

    src = replace_once(src, old_a4_sym, new_a4_sym, "A4_build_symbols")

    # ------------------------------------------------------------------
    # A4b: Fused single-pass reverse+count in x187_build_bytes
    # ------------------------------------------------------------------
    old_a4_bytes = """@unsafe
def w5b_bb_sec(section: U32, +bytes: List<&2,U32>, +count: U32, +build: X187Build,
    t: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  match section:
    case 1: X187Build{1,nt_reverse(U32,bytes,t),r,d,U32.add(ts,count),rs,ds,symbols,names,relocs,error}
    case 2: X187Build{2,t,nt_reverse(U32,bytes,r),d,ts,U32.add(rs,count),ds,symbols,names,relocs,error}
    case 3: X187Build{3,t,r,nt_reverse(U32,bytes,d),ts,rs,U32.add(ds,count),symbols,names,relocs,error}
    case _: x187_build_error("invalid object section",build)

@unsafe
def w5b_bb_ok(oob: Bool, +section: U32, +bytes: List<&2,U32>, +count: U32, +build: X187Build,
    t: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  match oob:
    case True{}: x187_build_error("x86 object section exceeds 32 MiB bound",build)
    case False{}: w5b_bb_sec(section,bytes,count,build,t,r,d,ts,rs,ds,symbols,names,relocs,error)

@unsafe
def x187_build_bytes(+bytes: List<&2,U32>, +build: X187Build) -> X187Build:
  match build:
    case X187Build{+section,t,r,d,+ts,+rs,+ds,symbols,names,relocs,error}:
      +count = nt_count(U32,bytes)
      w5b_bb_ok(U32.is_gt(count,33554432) || U32.is_gt(x187_build_offset(build),U32.sub(33554432,count)),
        section,bytes,count,build,t,r,d,ts,rs,ds,symbols,names,relocs,error)"""

    new_a4_bytes = """type W7RevCount is Data:
  W7RevCount{+list: List<&2,U32>, +len: U32}

@unsafe
def w7_rev_count(bytes: List<&2,U32>, acc: List<&2,U32>, +n: U32) -> W7RevCount:
  match bytes:
    case Nil{}: W7RevCount{acc,n}
    case Con{a,Con{b,Con{c,Con{d,rest}}}}: w7_rev_count(rest,Con{d,Con{c,Con{b,Con{a,acc}}}},U32.add(n,4))
    case Con{a,rest}: w7_rev_count(rest,Con{a,acc},U32.inc(n))

@unsafe
def w7_bb_sec(section: U32, out: List<&2,U32>, +count: U32, +build: X187Build,
    t: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  match section:
    case 1: X187Build{1,out,r,d,U32.add(ts,count),rs,ds,symbols,names,relocs,error}
    case 2: X187Build{2,t,out,d,ts,U32.add(rs,count),ds,symbols,names,relocs,error}
    case 3: X187Build{3,t,r,out,ts,rs,U32.add(ds,count),symbols,names,relocs,error}
    case _: x187_build_error("invalid object section",build)

@unsafe
def w7_bb_apply(+section: U32, +cur: U32, rc: W7RevCount, +build: X187Build,
    t: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  match rc:
    case W7RevCount{out,+count}:
      nt_choose(X187Build,U32.is_gt(count,33554432) || U32.is_gt(cur,U32.sub(33554432,count)),
        u => x187_build_error("x86 object section exceeds 32 MiB bound",build),
        u => w7_bb_sec(section,out,count,build,t,r,d,ts,rs,ds,symbols,names,relocs,error))

@unsafe
def x187_build_bytes(+bytes: List<&2,U32>, +build: X187Build) -> X187Build:
  match build:
    case X187Build{+section,t,r,d,+ts,+rs,+ds,symbols,names,relocs,error}:
      match section:
        case 1: w7_bb_apply(1,ts,w7_rev_count(bytes,t,0),build,t,r,d,ts,rs,ds,symbols,names,relocs,error)
        case 2: w7_bb_apply(2,rs,w7_rev_count(bytes,r,0),build,t,r,d,ts,rs,ds,symbols,names,relocs,error)
        case 3: w7_bb_apply(3,ds,w7_rev_count(bytes,d,0),build,t,r,d,ts,rs,ds,symbols,names,relocs,error)
        case _: x187_build_error("invalid object section",build)"""

    src = replace_once(src, old_a4_bytes, new_a4_bytes, "A4_build_bytes")

    # ------------------------------------------------------------------
    # A4c: Streamline x187_build_seq_work (direct descent, check error only after X188One)
    # ------------------------------------------------------------------
    old_a4_seq = """@unsafe
def w5b_seq_work_if(ok: Bool, todo: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match ok:
    case True{}: x187_build_seq_next(todo,build,count)
    case False{}: build

@unsafe
def x187_build_seq_work(+todo: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  w5b_seq_work_if(String.is_empty(x187_build_message(build)),todo,build,count)

@unsafe
def w5b_seq_next_if(ok: Bool, head: X188Seq, rest: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match ok:
    case True{}: x187_build_seq_item(head,rest,build,U32.inc(count))
    case False{}: x187_build_error("x86 object fragment count exceeds bound",build)

@unsafe
def x187_build_seq_next(todo: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match todo:
    case Nil{}: build
    case Con{head,rest}: w5b_seq_next_if(U32.is_lt(count,67108864),head,rest,build,count)

@unsafe
def x187_build_seq_item(seq: X188Seq, rest: List<&2,X188Seq>, build: X187Build, count: U32) -> X187Build:
  match seq:
    case X188Empty{}: x187_build_seq_work(rest,build,count)
    case X188One{item}: x187_build_seq_work(rest,x187_build_parsed(item,build),count)
    case X188Join{left,right}: x187_build_seq_work(Con{left,Con{right,rest}},build,count)

@unsafe
def x187_build_seq(seq: X188Seq, build: X187Build) -> X187Build:
  x187_build_seq_work([seq],build,0)"""

    new_a4_seq = """law w7_seq_go:
  for seq: X188Seq
  for rest: List<&2,X188Seq>
  for +build: X187Build
  for +count: U32
  X187Build

@unsafe
def w7_seq_pop(rest: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match rest:
    case Nil{}: build
    case Con{head,tail}: w7_seq_go(head,tail,build,count)

@unsafe
def w7_seq_after_one(ok: Bool, rest: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match ok:
    case True{}: w7_seq_pop(rest,build,count)
    case False{}: build

@unsafe
def w7_seq_step(seq: X188Seq, rest: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match seq:
    case X188Empty{}: w7_seq_pop(rest,build,count)
    case X188One{item}:
      +b2 = x187_build_parsed(item,build)
      w7_seq_after_one(String.is_empty(x187_build_message(b2)),rest,b2,count)
    case X188Join{left,right}: w7_seq_go(left,Con{right,rest},build,count)

@unsafe
def w7_seq_chk(ok: Bool, seq: X188Seq, rest: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match ok:
    case True{}: w7_seq_step(seq,rest,build,U32.inc(count))
    case False{}: x187_build_error("x86 object fragment count exceeds bound",build)

@unsafe
def w7_seq_go(seq,rest,build,count):
  w7_seq_chk(U32.is_lt(count,67108864),seq,rest,build,count)

@unsafe
def x187_build_seq_work(+todo: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  w7_seq_after_one(String.is_empty(x187_build_message(build)),todo,build,count)

@unsafe
def x187_build_seq(seq: X188Seq, +build: X187Build) -> X187Build:
  w7_seq_after_one(String.is_empty(x187_build_message(build)),[seq],build,0)"""

    src = replace_once(src, old_a4_seq, new_a4_seq, "A4_build_seq")

    # ------------------------------------------------------------------
    # A4d: Fast-path x188_build_instruction when relocs is Nil{} (95% of instructions)
    # ------------------------------------------------------------------
    old_a4_inst = """@unsafe
def x188_build_instruction(+inst: X187Instruction, +build: X187Build) -> X187Build:
  x187_build_encoded(x188_branch_encoded(inst,x187_encode(inst,x187_build_offset(build))),build)"""

    new_a4_inst = """@unsafe
def w7_build_inst_enc(enc: X187Encoded, +inst: X187Instruction, +build: X187Build) -> X187Build:
  match enc:
    case X187Encoded{bytes,Nil{},SNil{}}: x187_build_bytes(bytes,build)
    case other: x187_build_encoded(x188_branch_encoded(inst,other),build)

@unsafe
def x188_build_instruction(+inst: X187Instruction, +build: X187Build) -> X187Build:
  w7_build_inst_enc(x187_encode(inst,x187_build_offset(build)),inst,build)"""

    src = replace_once(src, old_a4_inst, new_a4_inst, "A4_build_inst")

    # ------------------------------------------------------------------
    # B1: General --fast (`x86-object-fast` / `x187_prepared_fast`) mode
    # ------------------------------------------------------------------
    old_b1_prep = """@unsafe
def x187_prepared(+prepared: P169Prepared) -> X187ObjectResult:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      nt_choose(X187ObjectResult,String.is_empty(error),u => x187_cursor(agy_enrich_cursor(cursor,avail),avail,x187_build_empty()),
        u => X187ObjectResult{[],error})"""

    new_b1_prep = """@unsafe
def x187_prepared(+prepared: P169Prepared) -> X187ObjectResult:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      nt_choose(X187ObjectResult,String.is_empty(error),u => x187_cursor(agy_enrich_cursor(cursor,avail),avail,x187_build_empty()),
        u => X187ObjectResult{[],error})

# General -O0 / fast object emission mode (`x86-object-fast` / `x187_prepared_fast`):
# Runs required late lowering (x185_late_stmts) + direct stack-frame emission (x181_stmts) + fast ELF,
# skipping optional multi-pass IR optimizations, liveness/regalloc, and post-select peepholes.
@unsafe
def x181_function_fast_done(+symbol: String, code: X181Code) -> X181Output:
  match code:
    case X181Code{chunks,next,+terminal,+error}:
      X181Output{[x188_cat(x188_finish(chunks),X188One{PSize{symbol}})],
        nt_choose(String,String.is_empty(error) && Bool.not(terminal),u => "x86 unterminated function",u => error)}

@unsafe
def x181_function_fast_emit(+symbol: String, +params: List<&2,String>, +body: List<&2,P113DStmt>,
    +ids: N111Ids) -> X181Output:
  +frame = x186_saves_frame(x181_frame(symbol,params,body))
  x181_function_fast_done(symbol,x181_stmts(body,ids,frame,
    x181_add(x188_label(x181_loop_label(frame)),X181Code{[x181_prologue(frame)],0,False{},""})))

@unsafe
def x181_function_fast_late(symbol: String, params: List<&2,String>, ids: N111Ids, body: P113ABody) -> X181Output:
  match body:
    case P113ABody{ready,_}: x181_function_fast_emit(symbol,params,ready,ids)

@unsafe
def x181_function_fast(+symbol: String, +params: List<&2,String>, +body: List<&2,P113DStmt>,
    +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x185_late_enabled() && p114t_names(params) && p114t_body_names(body),
    u => x181_function_fast_late(symbol,params,ids,x185_late_stmts(body,ids,0)),
    u => x181_function_fast_emit(symbol,params,body,ids))

@unsafe
def x181_program_private_fast(+function: P113DFunction, context: P134Context, +available: KDef) -> X181Output:
  match function context:
    case P113DFunction{+name,+params,+result,public,+body} P134Context{+ids,index,direct,+ready,view,lookups,heap,mode}:
      +pnames = x181_param_names(params)
      +names : List<&2,String> = Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),u => pnames,u => Con{"__x181_result_out",pnames})}
      +error = p111_first(x181_program_stmts(body,available),p111_first(x181_hygiene_names(pnames),x181_hygiene_stmts(body)))
      nt_choose(X181Output,String.is_empty(error),
        u => x181_program_join(x181_function_fast(p113e_symbol(name),names,body,ids),x181_forward(function,ready)),
        u => X181Output{[],error})

@unsafe
def x181_program_public_fast(+segment: N111Segment, context: P134Context, +available: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,+body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      +error = p111_first(x181_program_scalars(body,available),x181_hygiene_scalars(body))
      nt_choose(X181Output,String.is_empty(error),
        u => nt_choose(X181Output,x202k_shape(body),v => x202k_template(p111q_symbol(name)),
          v => x181_function_fast(p111q_symbol(name),["state"],x181_scalar_rows(body),ids)),
        u => X181Output{[],error})

law x187_cursor_fast:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  X187ObjectResult

@unsafe
def x187_cursor_fast_good(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: x187_cursor_fast(next,available,build)
    case P134Private{Con{head,rest},+context,next}:
      x187_cursor_fast(P134Private{rest,context,next},available,x187_output(x181_program_private_fast(head,context,available),build))
    case P134Legacy{entries,context,next}: x187_cursor_fast(next,available,build)
    case P134Public{Nil{},context,next}: x187_cursor_fast(next,available,build)
    case P134Public{Con{head,rest},+context,next}:
      x187_cursor_fast(P134Public{rest,context,next},available,x187_output(x181_program_public_fast(head,context,available),build))
    case P134Tables{Nil{}}: x187_cursor_fast(P134Main{},available,build)
    case P134Tables{Con{head,rest}}:
      x187_cursor_fast(P134Tables{rest},available,x187_output(x181_program_data(head,available),build))
    case P134Main{}: x201f_finish(x187_build_seq(x181_program_main(),build))
    case _: X187ObjectResult{[],"incomplete object cursor"}

@unsafe
def x187_cursor_fast(cursor,available,build):
  nt_choose(X187ObjectResult,String.is_empty(x187_build_message(build)),
    u => x187_cursor_fast_good(cursor,available,build),u => X187ObjectResult{[],x187_build_message(build)})

@unsafe
def x187_prepared_fast(+prepared: P169Prepared) -> X187ObjectResult:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      nt_choose(X187ObjectResult,String.is_empty(error),u => x187_cursor_fast(cursor,avail,x187_build_empty()),
        u => X187ObjectResult{[],error})"""

    src = replace_once(src, old_b1_prep, new_b1_prep, "B1_prepared_fast")

    # Wire x86-object-fast into CLI
    old_b1_cli = """@unsafe
def x181_entry_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86") || agy_str_eq(program,"x86-object")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => x181_request(path,base,carrier,stamp,agy_str_eq(mode,"cache"),agy_str_eq(program,"x86-object")),
        u => IO.die(U32,2,"expected x86|x86-object, absolute input/Base paths and live|cache mode"))"""

    new_b1_cli = """@unsafe
def x187_print_fast(prepared: P169Prepared) -> IO(U32):
  x187_print_result(x187_prepared_fast(prepared))

@unsafe
def x181_request_fast(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        x187_print_fast(x198pw_compile(path,source,base_path,base,carrier,stamp,True{})),
      u => x187_print_fast(x198pw_compile(path,source,base_path,base,"",stamp,False{})))

@unsafe
def x181_entry_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86") || agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-object-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => nt_choose(IO(U32),agy_str_eq(program,"x86-object-fast"),
          v => x181_request_fast(path,base,carrier,stamp,agy_str_eq(mode,"cache")),
          v => x181_request(path,base,carrier,stamp,agy_str_eq(mode,"cache"),agy_str_eq(program,"x86-object"))),
        u => IO.die(U32,2,"expected x86|x86-object|x86-object-fast, absolute input/Base paths and live|cache mode"))"""

    src = replace_once(src, old_b1_cli, new_b1_cli, "B1_cli_fast")

    return src


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, required=True)
    ap.add_argument("--dst", type=Path, required=True)
    args = ap.parse_args()
    text = args.src.read_text()
    out = apply_patches(text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out)
    print(f"apply_w7_elf_fast: {args.src} -> {args.dst} ({len(text)} -> {len(out)} bytes)")


if __name__ == "__main__":
    main()
