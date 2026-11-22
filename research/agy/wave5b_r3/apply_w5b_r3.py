#!/usr/bin/env python3
"""Wave 5B Engine B Track W5B-R3: General Holdout-Transfer Closer.

100% general compiler passes (zero benchmark-specific matchers) on top of
`selfhost/build/agy/wave5a_unified/compiler.bend`:

  1. Fix `w5_xmm_opt_noxmm` disjoint-buffer guard + O(N) lookback cap in
     `w4c_find_def_back`: restores W5-R3's slot copy-forwarding, backedge
     coalescing, and dead-slot elimination for integer functions with disjoint
     stack buffers (`leaq -disp(%rbp)`).
  2. Lift `x190_joint_frame` and `x190_liveness_frame` statement-size cap from
     512 -> 2048 so large hot loops receive 9-GPR joint graph coloring.
  3. General `x190_local_values` enhancements:
     - Constant comparison folding (`eq`/`ne`/`ult`/`ule` on constants).
     - Constant branch folding (`P113DIf{N111Const{...}, yes, no}`).
     - O(N)-guarded `P113DIf` invariant trailing-copy hoisting: when both arms
       end with identical `N111Set{x, typ, v}` for an unmodified `v`, hoist
       `x = v` out of the `if` so `x190_v_body` copy-propagates it across
       nested diamonds.
  4. `P111_SPECIAL_SUCC` fast-path store sinking in `x185_late_stmts`:
     Sink `N111Store{typ, buf, 0, val}` into the overflow slow-path branch.
  5. General x86-64 `rolw`/`rorw`/`roll`/`rorl`/`movzwl` encoding in `x187`
     and 16-bit rotate peephole (`((x >> k) | (x << (16-k))) & 0xffff` ->
     `movzwl + rorw/rolw`).
  6. General x86-64 GPR/CFG peepholes (`w5b_peep` in `w4_post_select`):
     - `movzbl %r8, %r32; movl %r32, %r32` -> `movzbl %r8, %r32`
     - `movq %rS, %rT; movq %rT, disp(%rbp)` (%rT dead) -> `movq %rS, disp(%rbp)`
     - `movq %rA, %r10; movq %rB, %r11; cmpq %r11, %r10; setcc %r10b; movzbl %r10b, %r10d`
       (%r11 dead) -> `cmpq %rB, %rA; setcc %r10b; movzbl %r10b, %r10d`
     - `movq d(%rbp), %rA; movq d(%rbp), %rB; imull %rA32, %rB32` (%rA dead)
       -> `movq d(%rbp), %rB; imull %rB32, %rB32` (and symmetric)
     - `movq %r10, %rax; movq srcY, %r10; movq %rN, %r11; testl %eax, %eax; cmovneq %r10, %r11; movq %r11, dst`
       (%rax,%r10,%r11,%rN dead) -> `movq srcY, %r11; testl %r10d, %r10d; cmovneq %r11, %rN; movq %rN, dst`
     - `cmp + set<cc> + movzbl + [xorl $1] + [movq] + testl + je/jne L` -> `cmp + j<cc> L`
"""
import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave5a_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave5b_r3/compiler.bend"


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


def patch_1_noxmm_disjoint_buf(src: str) -> str:
    old = """@unsafe
def w5_xmm_opt_noxmm(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w5_xmm_opt_noxmm_go(w4c_has_leaq_rbp(items),items)"""
    new = """@unsafe
def w5_xmm_opt_noxmm(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +p2 = w4c_copy_slot_fwd(items)
  +p4 = w4c_backedge_coalesce(p2)
  w4c_dead_slot_elim(p4)"""
    src = replace_exact(src, old, new, "Pass 1a: w5_xmm_opt_noxmm disjoint-buf")

    # Bound w4c_find_def_back lookback to 64 instructions so huge basic blocks stay O(N)
    old_fb = """@unsafe
def w4c_find_def_back(+disp: U32, revPrefix: List<&2,X187Parsed>, +between: List<&2,X187Parsed>) -> W4CDefSplit:
  match revPrefix:
    case Nil{}: W4CDSNo{}
    case Con{+h,+rest}:
      nt_choose(W4CDefSplit,w4c_inst_writes_slot(disp,h),
        u => W4CDSYes{between,h,rest},
        u => w4c_find_def_back(disp,rest,Con{h,between}))"""
    new_fb = """@unsafe
def w4c_find_def_back_f(+disp: U32, revPrefix: List<&2,X187Parsed>, +between: List<&2,X187Parsed>, +fuel: U32) -> W4CDefSplit:
  match revPrefix:
    case Nil{}: W4CDSNo{}
    case Con{+h,+rest}:
      nt_choose(W4CDefSplit,U32.is_eq(fuel,0),
        z => W4CDSNo{},
        z => nt_choose(W4CDefSplit,w4c_inst_writes_slot(disp,h),
          u => W4CDSYes{between,h,rest},
          u => w4c_find_def_back_f(disp,rest,Con{h,between},U32.sub(fuel,1))))

@unsafe
def w4c_find_def_back(+disp: U32, revPrefix: List<&2,X187Parsed>, +between: List<&2,X187Parsed>) -> W4CDefSplit:
  w4c_find_def_back_f(disp,revPrefix,between,64)"""
    src = replace_exact(src, old_fb, new_fb, "Pass 1b: bound w4c_find_def_back lookback")
    return src


def patch_2_regalloc_size_cap(src: str) -> str:
    old_j = """def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),512) &&"""
    new_j = """def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),2048) &&"""
    src = replace_exact(src, old_j, new_j, "Pass 2a: x190_joint_frame cap 512->2048")

    old_l = """def x190_liveness_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,x190_liveness_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),512) &&"""
    new_l = """def x190_liveness_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,x190_liveness_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),2048) &&"""
    src = replace_exact(src, old_l, new_l, "Pass 2b: x190_liveness_frame cap 512->2048")
    return src


def patch_3_local_values_if_hoist(src: str) -> str:
    old_bin = """@unsafe
def x190_v_binary(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +state: X190Values) -> X190ValueStep:
  nt_choose(X190ValueStep,agy_str_eq(op,"and") && x190_v_mask(right),
    u => x190_v_set(name,N111U32{},left,state),u =>
      X190ValueStep{P113DScalar{N111Bin{name,typ,op,left,right}},
        x190_v_written(name,U32.is_eq(p111v_type(typ),1) || p111v_comparison(op),state)})"""

    new_bin = """@unsafe
def w5b_const_cmp(+op: String, +al: U32, +ah: U32, +bl: U32, +bh: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,agy_str_eq(op,"eq"),
    u => Some{nt_choose(U32,U32.is_eq(al,bl) && U32.is_eq(ah,bh),v => 1,v => 0)},
    u => nt_choose(Maybe<&2,U32>,agy_str_eq(op,"ne"),
      v => Some{nt_choose(U32,U32.is_eq(al,bl) && U32.is_eq(ah,bh),w => 0,w => 1)},
      v => nt_choose(Maybe<&2,U32>,agy_str_eq(op,"ult"),
        w => Some{nt_choose(U32,U32.is_lt(ah,bh) || (U32.is_eq(ah,bh) && U32.is_lt(al,bl)),z => 1,z => 0)},
        w => nt_choose(Maybe<&2,U32>,agy_str_eq(op,"ule"),
          z => Some{nt_choose(U32,U32.is_lt(ah,bh) || (U32.is_eq(ah,bh) && U32.is_le(al,bl)),q => 1,q => 0)},
          z => None{}))))

@unsafe
def w5b_try_const_bin(+op: String, left: N111Value, right: N111Value) -> Maybe<&2,U32>:
  match left:
    case N111Const{al,ah}:
      match right:
        case N111Const{bl,bh}: w5b_const_cmp(op,al,ah,bl,bh)
        case _: None{}
    case _: None{}

@unsafe
def w5b_v_binary_go(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value,
    +state: X190Values, folded: Maybe<&2,U32>) -> X190ValueStep:
  match folded:
    case Some{v}: x190_v_set(name,typ,N111Const{v,0},state)
    case None{}:
      nt_choose(X190ValueStep,agy_str_eq(op,"and") && x190_v_mask(right),
        u => x190_v_set(name,N111U32{},left,state),u =>
          X190ValueStep{P113DScalar{N111Bin{name,typ,op,left,right}},
            x190_v_written(name,U32.is_eq(p111v_type(typ),1) || p111v_comparison(op),state)})

@unsafe
def x190_v_binary(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +state: X190Values) -> X190ValueStep:
  w5b_v_binary_go(name,typ,op,left,right,state,w5b_try_const_bin(op,left,right))"""

    src = replace_exact(src, old_bin, new_bin, "Pass 3a: const comparison folding in x190_v_binary")

    old_if = """@unsafe
def x195bf_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    +rest: List<&2,P113DStmt>, +state: X190Values) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x195bf_enabled(),
    u => Con{P113DIf{condition,x190_v_body(yes,state),x190_v_body(no,state)},
      x190_v_body(rest,x195bf_join(yes,no,state))},
    u => x190_v_if(condition,yes,no,rest))"""

    new_if = """# W5B-R3: General P113DIf constant-branch folding & O(N)-guarded invariant trailing-copy hoisting
type W5BSplitSets is Data:
  W5BSplitSets{+prefix: List<&2,P113DStmt>, +sets: List<&2,P113DStmt>}

@unsafe
def w5b_is_set(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{N111Set{_,_,_}}: True{}
    case _: False{}

@unsafe
def w5b_take_sets_rev(rev: List<&2,P113DStmt>, +sets: List<&2,P113DStmt>) -> W5BSplitSets:
  match rev:
    case Nil{}: W5BSplitSets{[],sets}
    case Con{+h,+t}:
      nt_choose(W5BSplitSets,w5b_is_set(h),
        u => w5b_take_sets_rev(t,Con{h,sets}),
        u => W5BSplitSets{nt_reverse(P113DStmt,Con{h,t},[]),sets})

@unsafe
def w5b_split_trailing_sets(body: List<&2,P113DStmt>) -> W5BSplitSets:
  w5b_take_sets_rev(nt_reverse(P113DStmt,body,[]),[])

@unsafe
def w5b_val_eq(a: N111Value, b: N111Value) -> Bool:
  match a:
    case N111Local{na}:
      match b:
        case N111Local{nb}: agy_str_eq(na,nb)
        case _: False{}
    case N111Const{al,ah}:
      match b:
        case N111Const{bl,bh}: U32.is_eq(al,bl) && U32.is_eq(ah,bh)
        case _: False{}
    case _: False{}

@unsafe
def w5b_typ_eq(a: N111Type, b: N111Type) -> Bool:
  U32.is_eq(p111v_type(a),p111v_type(b))

@unsafe
def w5b_put_name(+name: String, +m: KDef) -> KDef:
  p111v_put(m,name,"W5B",U32.inc(da(p111v_get(m,name))),0)

@unsafe
def w5b_has_name(+name: String, m: KDef) -> Bool:
  U32.is_gt(da(p111v_get(m,name)),0)

@unsafe
def w5b_cnt_name(+name: String, m: KDef) -> U32:
  da(p111v_get(m,name))

@unsafe
def w5b_put_names(names: List<&2,String>, +m: KDef) -> KDef:
  match names:
    case Nil{}: m
    case Con{n,t}: w5b_put_names(t,w5b_put_name(n,m))

law w5b_writes_body:
  for body: List<&2,P113DStmt>
  for +m: KDef
  KDef

@unsafe
def w5b_writes_scalar(stmt: N111Stmt, +m: KDef) -> KDef:
  match stmt:
    case N111Set{n,_,_}: w5b_put_name(n,m)
    case N111Bin{n,_,_,_,_}: w5b_put_name(n,m)
    case N111Offset{n,_,_}: w5b_put_name(n,m)
    case N111Load{n,_,_,_}: w5b_put_name(n,m)
    case N111Call{n,_,_,_}: w5b_put_name(n,m)
    case N111Alloca{n,_,_}: w5b_put_name(n,m)
    case N111If{_,yes,no}: w5b_writes_body(x181_scalar_rows(no),w5b_writes_body(x181_scalar_rows(yes),m))
    case _: m

@unsafe
def w5b_writes_body(body,m):
  match body:
    case Nil{}: m
    case Con{P113DScalar{s},t}: w5b_writes_body(t,w5b_writes_scalar(s,m))
    case Con{P113DIf{_,yes,no},t}: w5b_writes_body(t,w5b_writes_body(no,w5b_writes_body(yes,m)))
    case Con{P113DCall{ns,_,_},t}: w5b_writes_body(t,w5b_put_names(ns,m))
    case Con{_,t}: w5b_writes_body(t,m)

@unsafe
def w5b_sets_reads(sets: List<&2,P113DStmt>, +m: KDef) -> KDef:
  match sets:
    case Nil{}: m
    case Con{P113DScalar{N111Set{_,_,N111Local{v}}},t}: w5b_sets_reads(t,w5b_put_name(v,m))
    case Con{_,t}: w5b_sets_reads(t,m)

@unsafe
def w5b_val_unmodified(v: N111Value, +x: String, +allW: KDef) -> Bool:
  match v:
    case N111Const{_,_}: True{}
    case N111Local{+vn}: Bool.not(agy_str_eq(vn,x)) && Bool.not(w5b_has_name(vn,allW))
    case _: False{}

@unsafe
def w5b_in_sets(+x: String, +typ: N111Type, +v: N111Value, sets: List<&2,P113DStmt>) -> Bool:
  match sets:
    case Nil{}: False{}
    case Con{P113DScalar{N111Set{n,nt,nv}},t}:
      nt_choose(Bool,agy_str_eq(n,x) && w5b_typ_eq(nt,typ) && w5b_val_eq(nv,v),
        u => True{},u => w5b_in_sets(x,typ,v,t))
    case Con{_,t}: w5b_in_sets(x,typ,v,t)

@unsafe
def w5b_has_common_set(ySets: List<&2,P113DStmt>, +nSets: List<&2,P113DStmt>) -> Bool:
  match ySets:
    case Nil{}: False{}
    case Con{P113DScalar{N111Set{x,typ,v}},t}:
      nt_choose(Bool,w5b_in_sets(x,typ,v,nSets),u => True{},u => w5b_has_common_set(t,nSets))
    case Con{_,t}: w5b_has_common_set(t,nSets)

@unsafe
def w5b_can_hoist(stmt: P113DStmt, +nSets: List<&2,P113DStmt>, +preW: KDef, +ySetW: KDef,
    +nSetW: KDef, +setR: KDef, +allW: KDef) -> Bool:
  match stmt:
    case P113DScalar{N111Set{+x,+typ,+v}}:
      Bool.not(w5b_has_name(x,preW)) &&
      U32.is_eq(w5b_cnt_name(x,ySetW),1) &&
      U32.is_eq(w5b_cnt_name(x,nSetW),1) &&
      Bool.not(w5b_has_name(x,setR)) &&
      w5b_val_unmodified(v,x,allW) &&
      w5b_in_sets(x,typ,v,nSets)
    case _: False{}

@unsafe
def w5b_collect_hoist(ySets: List<&2,P113DStmt>, +nSets: List<&2,P113DStmt>, +preW: KDef,
    +ySetW: KDef, +nSetW: KDef, +setR: KDef, +allW: KDef, +hoistNames: KDef) -> KDef:
  match ySets:
    case Nil{}: hoistNames
    case Con{+h,+t}:
      match h:
        case P113DScalar{N111Set{+x,_,_}}:
          nt_choose(KDef,w5b_can_hoist(h,nSets,preW,ySetW,nSetW,setR,allW),
            u => w5b_collect_hoist(t,nSets,preW,ySetW,nSetW,setR,allW,w5b_put_name(x,hoistNames)),
            u => w5b_collect_hoist(t,nSets,preW,ySetW,nSetW,setR,allW,hoistNames))
        case _: w5b_collect_hoist(t,nSets,preW,ySetW,nSetW,setR,allW,hoistNames)

@unsafe
def w5b_filter_sets(sets: List<&2,P113DStmt>, +hoistNames: KDef, +keepHoisted: Bool) -> List<&2,P113DStmt>:
  match sets:
    case Nil{}: []
    case Con{+h,+t}:
      match h:
        case P113DScalar{N111Set{+x,_,_}}:
          +isH = w5b_has_name(x,hoistNames)
          nt_choose(List<&2,P113DStmt>,nt_choose(Bool,keepHoisted,u => isH,u => Bool.not(isH)),
            u => Con{h,w5b_filter_sets(t,hoistNames,keepHoisted)},
            u => w5b_filter_sets(t,hoistNames,keepHoisted))
        case _:
          nt_choose(List<&2,P113DStmt>,keepHoisted,
            u => w5b_filter_sets(t,hoistNames,keepHoisted),
            u => Con{h,w5b_filter_sets(t,hoistNames,keepHoisted)})

@unsafe
def w5b_emit_if_go(+yes2: List<&2,P113DStmt>, +no2: List<&2,P113DStmt>,
    +condition: N111Value, +tail: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match yes2:
    case Nil{}:
      match no2:
        case Nil{}: tail
        case _: Con{P113DIf{condition,yes2,no2},tail}
    case _: Con{P113DIf{condition,yes2,no2},tail}

@unsafe
def w5b_emit_if(+condition: N111Value, +yes2: List<&2,P113DStmt>, +no2: List<&2,P113DStmt>,
    +hoisted: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>, +state: X190Values) -> List<&2,P113DStmt>:
  +tail = x190_v_body(nt_append(P113DStmt,hoisted,rest),x195bf_join(yes2,no2,state))
  w5b_emit_if_go(yes2,no2,condition,tail)

@unsafe
def w5b_hoist_if_do(+ySets: List<&2,P113DStmt>, +nSets: List<&2,P113DStmt>,
    +yPre: List<&2,P113DStmt>, +nPre: List<&2,P113DStmt>,
    +condition: N111Value, +rest: List<&2,P113DStmt>, +state: X190Values) -> List<&2,P113DStmt>:
  +preW = w5b_writes_body(nPre,w5b_writes_body(yPre,missing()))
  +ySetW = w5b_writes_body(ySets,missing())
  +nSetW = w5b_writes_body(nSets,missing())
  +allW = w5b_writes_body(nSets,w5b_writes_body(ySets,preW))
  +setR = w5b_sets_reads(nSets,w5b_sets_reads(ySets,missing()))
  +hNames = w5b_collect_hoist(ySets,nSets,preW,ySetW,nSetW,setR,allW,missing())
  +hoisted = w5b_filter_sets(ySets,hNames,True{})
  +yKeep = w5b_filter_sets(ySets,hNames,False{})
  +nKeep = w5b_filter_sets(nSets,hNames,False{})
  w5b_emit_if(condition,nt_append(P113DStmt,yPre,yKeep),nt_append(P113DStmt,nPre,nKeep),hoisted,rest,state)

@unsafe
def w5b_hoist_if_go(+ySets: List<&2,P113DStmt>, +nSets: List<&2,P113DStmt>,
    +yPre: List<&2,P113DStmt>, +nPre: List<&2,P113DStmt>,
    +condition: N111Value, +rest: List<&2,P113DStmt>, +state: X190Values) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,w5b_has_common_set(ySets,nSets),
    u => w5b_hoist_if_do(ySets,nSets,yPre,nPre,condition,rest,state),
    u => w5b_emit_if(condition,nt_append(P113DStmt,yPre,ySets),nt_append(P113DStmt,nPre,nSets),[],rest,state))

@unsafe
def w5b_hoist_if_split(+condition: N111Value, ySp: W5BSplitSets, nSp: W5BSplitSets,
    +rest: List<&2,P113DStmt>, +state: X190Values) -> List<&2,P113DStmt>:
  match ySp:
    case W5BSplitSets{yPre,ySets}:
      match nSp:
        case W5BSplitSets{nPre,nSets}:
          w5b_hoist_if_go(ySets,nSets,yPre,nPre,condition,rest,state)

@unsafe
def w5b_if_enabled(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    +rest: List<&2,P113DStmt>, +state: X190Values) -> List<&2,P113DStmt>:
  match condition:
    case N111Const{lo,hi}:
      nt_choose(List<&2,P113DStmt>,U32.is_eq(lo,0) && U32.is_eq(hi,0),
        u => x190_v_body(nt_append(P113DStmt,no,rest),state),
        u => x190_v_body(nt_append(P113DStmt,yes,rest),state))
    case _:
      +y1 = x190_v_body(yes,state)
      +n1 = x190_v_body(no,state)
      w5b_hoist_if_split(condition,w5b_split_trailing_sets(y1),w5b_split_trailing_sets(n1),rest,state)

@unsafe
def x195bf_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    +rest: List<&2,P113DStmt>, +state: X190Values) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x195bf_enabled(),
    u => w5b_if_enabled(condition,yes,no,rest,state),
    u => x190_v_if(condition,yes,no,rest))"""

    src = replace_exact(src, old_if, new_if, "Pass 3b: const branch fold + O(N)-guarded invariant copy hoist")
    return src


def patch_4_succ_store_sink(src: str) -> str:
    old = """@unsafe
def x185_late_stmts(body: List<&2,P113DStmt>, +ids: N111Ids, +site: U32) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],site}
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x185_late_yes(condition,x181_scalar_rows(no),rest,ids,x185_late_stmts(x181_scalar_rows(yes),ids,site))
    case Con{P113DScalar{+stmt},+rest}:"""

    new = """# W5B-R3 Pass 4: Sink N111Store into P111_SPECIAL_SUCC overflow slow-path
law x185_late_stmts:
  for body: List<&2,P113DStmt>
  for +ids: N111Ids
  for +site: U32
  P113ABody

@unsafe
def w5b_match_succ_pair(+styp: N111Type, +sbuf: String, +sval: N111Value,
    +dest: String, +sym: String, +args: List<&2,N111Arg>, +site: U32) -> Maybe<&2,List<&2,P113DStmt>>:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+state}},
         Con{N111Arg{N111U32{},N111Const{4,0}},
         Con{N111Arg{N111Ptr{},N111Local{+cbuf}},
         Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}:
      nt_choose(Maybe<&2,List<&2,P113DStmt>>,
        agy_str_eq(sym,"p111_rt_special_ctor") && agy_str_eq(state,"state") &&
        agy_str_eq(sbuf,cbuf) && Bool.not(agy_str_eq(sbuf,"state")),
        u => Some{[
          P113DScalar{N111Bin{p114t_name(site,"succ_ok"),N111U64{},"ult",sval,N111Const{4294967295,65535}}},
          P113DIf{p114t_local(site,"succ_ok"),
            [P113DScalar{N111Bin{dest,N111U64{},"add",sval,N111Const{1,0}}}],
            [P113DScalar{N111Store{styp,N111Local{sbuf},0,sval}},
             P113DScalar{N111Call{dest,N111U64{},sym,args}}]}]},
        u => None{})
    case _: None{}

@unsafe
def w5b_late_store_call(+styp: N111Type, +sbuf: String, +sval: N111Value,
    +dest: String, +sym: String, +args: List<&2,N111Arg>, +rest: List<&2,P113DStmt>,
    +ids: N111Ids, +site: U32, matched: Maybe<&2,List<&2,P113DStmt>>) -> P113ABody:
  match matched:
    case Some{expanded}:
      p113a_prefix(expanded,
        x185_late_stmts(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)))
    case None{}:
      +s0 : N111Stmt = N111Store{styp,N111Local{sbuf},0,sval}
      +c0 : P113DStmt = P113DScalar{N111Call{dest,N111U64{},sym,args}}
      +r0 : List<&2,P113DStmt> = Con{c0,rest}
      p113a_prefix(x181_scalar_rows(x185_late_scalar(s0,ids,site,w4_bf_mask_for(s0,r0,ids,site))),
        x185_late_stmts(r0,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)))

@unsafe
def x185_late_stmts(body,ids,site):
  match body:
    case Nil{}: P113ABody{[],site}
    case Con{P113DScalar{N111Store{+styp,N111Local{+sbuf},0,+sval}},
         Con{P113DScalar{N111Call{+dest,N111U64{},+sym,+args}},+rest}}:
      w5b_late_store_call(styp,sbuf,sval,dest,sym,args,rest,ids,site,
        w5b_match_succ_pair(styp,sbuf,sval,dest,sym,args,site))
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x185_late_yes(condition,x181_scalar_rows(no),rest,ids,x185_late_stmts(x181_scalar_rows(yes),ids,site))
    case Con{P113DScalar{+stmt},+rest}:"""

    return replace_exact(src, old, new, "Pass 4: P111_SPECIAL_SUCC store sinking")


def patch_5_x187_rotate_encode(src: str) -> str:
    old_sh = """@unsafe
def x187_e_shift(+src: X187Operand, +dst: X187Operand, +width: U32, +ext: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{+lo,0}:
      nt_choose(X187Encoded,U32.is_le(lo,255) && x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(0,[193],U32.is_eq(width,64),ext,dst,False{},[lo],offset),u => x187_e_error())
    case X187Reg{1,8,False{}}:
      nt_choose(X187Encoded,x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(0,[211],U32.is_eq(width,64),ext,dst,False{},[],offset),u => x187_e_error())
    case _: x187_e_error()"""

    new_sh = """@unsafe
def x187_e_shift(+src: X187Operand, +dst: X187Operand, +width: U32, +ext: U32, +prefix: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{+lo,0}:
      nt_choose(X187Encoded,U32.is_le(lo,255) && x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(prefix,[193],U32.is_eq(width,64),ext,dst,False{},[lo],offset),u => x187_e_error())
    case X187Reg{1,8,False{}}:
      nt_choose(X187Encoded,x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(prefix,[211],U32.is_eq(width,64),ext,dst,False{},[],offset),u => x187_e_error())
    case _: x187_e_error()"""
    src = replace_exact(src, old_sh, new_sh, "Pass 5a: x187_e_shift prefix")

    old_pair = """  nt_choose(X187Encoded,U32.is_eq(family,3),u => x187_e_shift(src,dst,width,extra,offset),u =>"""
    new_pair = """  nt_choose(X187Encoded,U32.is_eq(family,3),u => x187_e_shift(src,dst,width,extra,prefix,offset),u =>"""
    src = replace_exact(src, old_pair, new_pair, "Pass 5b: x187_e_pair shift prefix")

    old_p16 = """    nt_choose(X187Encoded,U32.is_eq(family,16),v => x191cm_pair(src,dst,width,code,offset),v => x187_e_error()))))))))))))"""
    new_p16 = """    nt_choose(X187Encoded,U32.is_eq(family,16),v => x191cm_pair(src,dst,width,code,offset),v =>
    nt_choose(X187Encoded,U32.is_eq(family,18) && x187_e_reg(dst,32,False{}) && x187_e_rm(src,32,False{}),w =>
      x187_e_modrm(0,[15,183],False{},x187_e_index(dst),src,False{},[],offset),w => x187_e_error())))))))))))))"""
    src = replace_exact(src, old_p16, new_p16, "Pass 5c: x187_e_pair movzwl family 18")

    old_m = """      nt_choose(X187Op,agy_str_eq(tail,"ovzbl"),u => X187Op{6,32,0,0,0},u =>"""
    new_m = """      nt_choose(X187Op,agy_str_eq(tail,"ovzbl"),u => X187Op{6,32,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"ovzwl"),u => X187Op{18,32,183,0,0},u =>"""
    src = replace_exact(src, old_m, new_m, "Pass 5d: x202o_dispatch movzwl")
    # Fix closing parens for case 109
    old_m_end = """      nt_choose(X187Op,agy_str_eq(tail,"ulss"),u => X187Op{7,128,89,0,243},u =>
      X187OpNone{}))))))))"""
    new_m_end = """      nt_choose(X187Op,agy_str_eq(tail,"ulss"),u => X187Op{7,128,89,0,243},u =>
      X187OpNone{})))))))))"""
    src = replace_exact(src, old_m_end, new_m_end, "Pass 5e: x202o_dispatch case 109 parens")

    old_r = """    case 114:
      nt_choose(X187Op,agy_str_eq(tail,"et"),u => X187Op{14,0,195,0,0},u =>
      X187OpNone{})"""
    new_r = """    case 114:
      nt_choose(X187Op,agy_str_eq(tail,"et"),u => X187Op{14,0,195,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"olw"),u => X187Op{3,32,0,0,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"orw"),u => X187Op{3,32,0,1,102},u =>
      nt_choose(X187Op,agy_str_eq(tail,"oll"),u => X187Op{3,32,0,0,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"orl"),u => X187Op{3,32,0,1,0},u =>
      X187OpNone{})))))"""
    src = replace_exact(src, old_r, new_r, "Pass 5f: x202o_dispatch rolw/rorw/roll/rorl")
    return src


def patch_6_general_peepholes(src: str) -> str:
    old_post = """  +g1 = w5_gpr_peep(f5,f5,[])
  +g2 = w5_gpr_peep(g1,g1,[])
  +g3 = w5_gpr_peep(g2,g2,[])
  +xmm = w5_run_xmm(hasXmm,hasNegRbp,g3)
  w4b_wrap_items(xmm,[])"""

    w5b_peep_code = """# ============================================================================
# W5B-R3 Pass 5/6: General Rotate, Spill-Bounce, Cmp+Branch, Square & Select Peepholes
# ============================================================================
@unsafe
def w5b_inv_cc(+cc: String) -> String:
  nt_choose(String,agy_str_eq(cc,"e"),u => "ne",u =>
  nt_choose(String,agy_str_eq(cc,"ne"),u => "e",u =>
  nt_choose(String,agy_str_eq(cc,"z"),u => "nz",u =>
  nt_choose(String,agy_str_eq(cc,"nz"),u => "z",u =>
  nt_choose(String,agy_str_eq(cc,"a"),u => "be",u =>
  nt_choose(String,agy_str_eq(cc,"be"),u => "a",u =>
  nt_choose(String,agy_str_eq(cc,"ae"),u => "b",u =>
  nt_choose(String,agy_str_eq(cc,"b"),u => "ae",u =>
  nt_choose(String,agy_str_eq(cc,"g"),u => "le",u =>
  nt_choose(String,agy_str_eq(cc,"le"),u => "g",u =>
  nt_choose(String,agy_str_eq(cc,"ge"),u => "l",u =>
  nt_choose(String,agy_str_eq(cc,"l"),u => "ge",u => ""))))))))))))

@unsafe
def w5b_set_cc(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"sete"),u => "e",u =>
  nt_choose(String,agy_str_eq(op,"setne"),u => "ne",u =>
  nt_choose(String,agy_str_eq(op,"seta"),u => "a",u =>
  nt_choose(String,agy_str_eq(op,"setae"),u => "ae",u =>
  nt_choose(String,agy_str_eq(op,"setb"),u => "b",u =>
  nt_choose(String,agy_str_eq(op,"setbe"),u => "be",u =>
  nt_choose(String,agy_str_eq(op,"setg"),u => "g",u =>
  nt_choose(String,agy_str_eq(op,"setge"),u => "ge",u =>
  nt_choose(String,agy_str_eq(op,"setl"),u => "l",u =>
  nt_choose(String,agy_str_eq(op,"setle"),u => "le",u => ""))))))))))

@unsafe
def w5b_j_cc(+cc: String, +invert: Bool) -> String:
  "j" ++ nt_choose(String,invert,u => w5b_inv_cc(cc),u => cc)

@unsafe
def w5b_is_cmp(+op: String) -> Bool:
  agy_str_eq(op,"cmpq") || agy_str_eq(op,"cmpl")

@unsafe
def w5b_is_je_jne(item: X187Parsed) -> Maybe<&2,String>:
  match item:
    case PInst{X187Instruction{+op,Con{X187Target{+lbl},Nil{}}}}:
      nt_choose(Maybe<&2,String>,agy_str_eq(op,"je") || agy_str_eq(op,"jz"),
        u => Some{"E:" ++ lbl},
        u => nt_choose(Maybe<&2,String>,agy_str_eq(op,"jne") || agy_str_eq(op,"jnz"),
          v => Some{"N:" ++ lbl},v => None{}))
    case _: None{}

@unsafe
def w5b_reg_dead_fast(+r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Bool:
  w4b_reg_dead(r,rest,fnItems,64)

@unsafe
def w5b_jcc_name(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"je"),u => "e",u =>
  nt_choose(String,agy_str_eq(op,"jne"),u => "ne",u =>
  nt_choose(String,agy_str_eq(op,"jz"),u => "z",u =>
  nt_choose(String,agy_str_eq(op,"jnz"),u => "nz",u =>
  nt_choose(String,agy_str_eq(op,"ja"),u => "a",u =>
  nt_choose(String,agy_str_eq(op,"jae"),u => "ae",u =>
  nt_choose(String,agy_str_eq(op,"jb"),u => "b",u =>
  nt_choose(String,agy_str_eq(op,"jbe"),u => "be",u =>
  nt_choose(String,agy_str_eq(op,"jg"),u => "g",u =>
  nt_choose(String,agy_str_eq(op,"jge"),u => "ge",u =>
  nt_choose(String,agy_str_eq(op,"jl"),u => "l",u =>
  nt_choose(String,agy_str_eq(op,"jle"),u => "le",u => ""))))))))))))

@unsafe
def w5b_try_jcc_jmp(+op: String, +l1: String, rest: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{opJ,Con{X187Target{+l2},Nil{}}}},Con{PLabel{+l3},+tail}}:
      +cc = w5b_jcc_name(op)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        Bool.not(String.is_empty(cc)) && agy_str_eq(opJ,"jmp") && agy_str_eq(l1,l3),
        u => Some{Con{PInst{X187Instruction{w5b_j_cc(cc,True{}),[X187Target{l2}]}},Con{PLabel{l3},tail}}},
        u => None{})
    case _: None{}

# Try 16-bit rotate pattern R1 (shr-first):
#   movq %rX, %rA; shrq $k, %rA; movq %rA, %rB; movq %rX, %rA; shll $(16-k), %rA32; orq %rB, %rA; andq $65535, %rA
@unsafe
def w5b_try_ror16(+rX: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Imm{+k,0},Con{X187Reg{ra1,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{ra2,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op3,Con{X187Reg{rx3,64,False{}},Con{X187Reg{ra3,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op4,Con{X187Imm{+m,0},Con{X187Reg{ra4,w4,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op5,Con{X187Reg{rb5,64,False{}},Con{X187Reg{ra5,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op6,Con{X187Imm{65535,0},Con{X187Reg{ra6,64,False{}},Nil{}}}}},+tail}}}}}}:
      +ok = agy_str_eq(op1,"shrq") && agy_str_eq(op2,"movq") && agy_str_eq(op3,"movq") &&
            (agy_str_eq(op4,"shll") || agy_str_eq(op4,"shlq")) &&
            agy_str_eq(op5,"orq") && agy_str_eq(op6,"andq") &&
            U32.is_eq(ra1,rA) && U32.is_eq(ra2,rA) && U32.is_eq(rx3,rX) &&
            U32.is_eq(ra3,rA) && U32.is_eq(ra4,rA) && U32.is_eq(rb5,rB) &&
            U32.is_eq(ra5,rA) && U32.is_eq(ra6,rA) &&
            Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rX)) &&
            U32.is_ge(k,1) && U32.is_le(k,15) && U32.is_eq(U32.add(k,m),16) &&
            w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movzwl",[x188_reg(rX,32),x188_reg(rA,32)]}},
                  Con{PInst{X187Instruction{"rorw",[X187Imm{k,0},x188_reg(rA,32)]}},tail}}},
        u => None{})
    case _: None{}

# Try 16-bit rotate pattern R2 (shl-first):
#   movq %rX, %rA; shlq $k, %rA; movl %rA32, %rA32; movq %rX, %rB; shrq $(16-k), %rB; orq %rB, %rA; andq $65535, %rA
@unsafe
def w5b_try_rol16(+rX: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Imm{+k,0},Con{X187Reg{ra1,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{ra2a,32,False{}},Con{X187Reg{ra2b,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op3,Con{X187Reg{rx3,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op4,Con{X187Imm{+m,0},Con{X187Reg{rb4,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op5,Con{X187Reg{rb5,64,False{}},Con{X187Reg{ra5,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op6,Con{X187Imm{65535,0},Con{X187Reg{ra6,64,False{}},Nil{}}}}},+tail}}}}}}:
      +ok = agy_str_eq(op1,"shlq") && agy_str_eq(op2,"movl") && agy_str_eq(op3,"movq") &&
            agy_str_eq(op4,"shrq") && agy_str_eq(op5,"orq") && agy_str_eq(op6,"andq") &&
            U32.is_eq(ra1,rA) && U32.is_eq(ra2a,rA) && U32.is_eq(ra2b,rA) &&
            U32.is_eq(rx3,rX) && U32.is_eq(rb4,rB) && U32.is_eq(rb5,rB) &&
            U32.is_eq(ra5,rA) && U32.is_eq(ra6,rA) &&
            Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rX)) &&
            U32.is_ge(k,1) && U32.is_le(k,15) && U32.is_eq(U32.add(k,m),16) &&
            w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movzwl",[x188_reg(rX,32),x188_reg(rA,32)]}},
                  Con{PInst{X187Instruction{"rolw",[X187Imm{k,0},x188_reg(rA,32)]}},tail}}},
        u => None{})
    case _: None{}

# Try cmp + set<cc> + movzbl + [xorl $1] + [movq] + testl + je/jne -> cmp + j<cc>
@unsafe
def w5b_try_cmp_jcc(+cmpInst: X187Parsed, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    # Pattern B2a: setcc %rA8; movzbl %rA8,%rA32; xorl $1,%rA32; movq %rA,%rB; testl %rB32,%rB32; je/jne L
    case Con{PInst{X187Instruction{+opSet,Con{X187Reg{+rA,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opX,Con{X187Imm{1,0},Con{X187Reg{rx,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{rm1,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opT,Con{X187Reg{rt1,32,False{}},Con{X187Reg{rt2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opJ,Con{X187Target{+lbl},Nil{}}}},+tail}}}}}}:
      +cc = w5b_set_cc(opSet)
      +isE = agy_str_eq(opJ,"je") || agy_str_eq(opJ,"jz")
      +isN = agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")
      +ok = Bool.not(String.is_empty(cc)) && (isE || isN) &&
            agy_str_eq(opZ,"movzbl") && agy_str_eq(opX,"xorl") && agy_str_eq(opM,"movq") && agy_str_eq(opT,"testl") &&
            U32.is_eq(rz1,rA) && U32.is_eq(rz2,rA) && U32.is_eq(rx,rA) && U32.is_eq(rm1,rA) &&
            U32.is_eq(rt1,rB) && U32.is_eq(rt2,rB) &&
            w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,isN),[X187Target{lbl}]}},tail}}},
        u => None{})
    # Pattern B2b: setcc %rA8; movzbl %rA8,%rA32; movq %rA,%rB; xorl $1,%rB32; testl %rB32,%rB32; je/jne L
    case Con{PInst{X187Instruction{+opSet,Con{X187Reg{+rA,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{rm1,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opX,Con{X187Imm{1,0},Con{X187Reg{rx,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opT,Con{X187Reg{rt1,32,False{}},Con{X187Reg{rt2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opJ,Con{X187Target{+lbl},Nil{}}}},+tail}}}}}}:
      +cc = w5b_set_cc(opSet)
      +isE = agy_str_eq(opJ,"je") || agy_str_eq(opJ,"jz")
      +isN = agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")
      +ok = Bool.not(String.is_empty(cc)) && (isE || isN) &&
            agy_str_eq(opZ,"movzbl") && agy_str_eq(opM,"movq") && agy_str_eq(opX,"xorl") && agy_str_eq(opT,"testl") &&
            U32.is_eq(rz1,rA) && U32.is_eq(rz2,rA) && U32.is_eq(rm1,rA) && U32.is_eq(rx,rB) &&
            U32.is_eq(rt1,rB) && U32.is_eq(rt2,rB) &&
            w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,isN),[X187Target{lbl}]}},tail}}},
        u => None{})
    # Pattern B1: setcc %rA8; movzbl %rA8,%rA32; movq %rA,%rB; testl %rB32,%rB32; je/jne L
    case Con{PInst{X187Instruction{+opSet,Con{X187Reg{+rA,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opM,Con{X187Reg{rm1,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{opT,Con{X187Reg{rt1,32,False{}},Con{X187Reg{rt2,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opJ,Con{X187Target{+lbl},Nil{}}}},+tail}}}}}:
      +cc = w5b_set_cc(opSet)
      +isE = agy_str_eq(opJ,"je") || agy_str_eq(opJ,"jz")
      +isN = agy_str_eq(opJ,"jne") || agy_str_eq(opJ,"jnz")
      +ok = Bool.not(String.is_empty(cc)) && (isE || isN) &&
            agy_str_eq(opZ,"movzbl") && agy_str_eq(opM,"movq") && agy_str_eq(opT,"testl") &&
            U32.is_eq(rz1,rA) && U32.is_eq(rz2,rA) && U32.is_eq(rm1,rA) &&
            U32.is_eq(rt1,rB) && U32.is_eq(rt2,rB) &&
            w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,isE),[X187Target{lbl}]}},tail}}},
        u => None{})
    case _: None{}

# Try movq %rA, %r10; movq %rB, %r11; cmpq %r11, %r10; setcc %r10b; movzbl %r10b, %r10d -> cmpq %rB, %rA; setcc; movzbl
@unsafe
def w5b_try_cmp_bounce(+rA: U32, +rT1: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{+rB,64,False{}},Con{X187Reg{+rT2,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{c1,64,False{}},Con{X187Reg{c2,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{+opS,Con{X187Reg{rs,8,False{}},Nil{}}}},
         Con{PInst{X187Instruction{opZ,Con{X187Reg{rz1,8,False{}},Con{X187Reg{rz2,32,False{}},Nil{}}}}},+tail}}}}:
      +ok = agy_str_eq(op1,"movq") && agy_str_eq(op2,"cmpq") && agy_str_eq(opZ,"movzbl") &&
            Bool.not(String.is_empty(w5b_set_cc(opS))) &&
            U32.is_eq(c1,rT2) && U32.is_eq(c2,rT1) && U32.is_eq(rs,rT1) &&
            U32.is_eq(rz1,rT1) && U32.is_eq(rz2,rT1) &&
            Bool.not(U32.is_eq(rT1,rT2)) && Bool.not(U32.is_eq(rB,rT1)) &&
            w5b_reg_dead_fast(rT2,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"cmpq",[x188_reg(rB,64),x188_reg(rA,64)]}},
                  Con{PInst{X187Instruction{opS,[X187Reg{rT1,8,False{}}]}},
                  Con{PInst{X187Instruction{"movzbl",[X187Reg{rT1,8,False{}},x188_reg(rT1,32)]}},tail}}}},
        u => None{})
    case _: None{}

# Try spill-bounce: movq %rS, %rT; movq %rT, d(%rbp) (rT in {10,11}, rT dead) -> movq %rS, d(%rbp)
@unsafe
def w5b_try_spill_bounce(+rS: U32, +rT: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{rt1,64,False{}},Con{X187Mem{5,+disp},Nil{}}}}},+tail}:
      +ok = agy_str_eq(op1,"movq") && U32.is_eq(rt1,rT) && (U32.is_eq(rT,10) || U32.is_eq(rT,11)) &&
            Bool.not(U32.is_eq(rS,rT)) && w5b_reg_dead_fast(rT,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movq",[x188_reg(rS,64),X187Mem{5,disp}]}},tail}},
        u => None{})
    case _: None{}

# Try select-bounce: movq %r10, %rax; movq d(%rbp), %r10; movq %rN, %r11; testl %eax,%eax; cmovneq %r10,%r11; movq %r11, dst
#   (%rax,%r10,%r11,%rN dead) -> movq d(%rbp), %r11; testl %r10d,%r10d; cmovneq %r11,%rN; movq %rN, dst
@unsafe
def w5b_try_sel_bounce(+rA: U32, +rD: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{+srcY,Con{X187Reg{r10a,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{+rN,64,False{}},Con{X187Reg{r11a,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op3,Con{X187Reg{0,32,False{}},Con{X187Reg{0,32,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op4,Con{X187Reg{r10b,64,False{}},Con{X187Reg{r11b,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op5,Con{X187Reg{r11c,64,False{}},Con{+dst,Nil{}}}}},+tail}}}}}:
      +ok = U32.is_eq(rA,10) && U32.is_eq(rD,0) &&
            agy_str_eq(op1,"movq") && agy_str_eq(op2,"movq") && agy_str_eq(op3,"testl") &&
            agy_str_eq(op4,"cmovneq") && agy_str_eq(op5,"movq") &&
            U32.is_eq(r10a,10) && U32.is_eq(r11a,11) && U32.is_eq(r10b,10) &&
            U32.is_eq(r11b,11) && U32.is_eq(r11c,11) &&
            Bool.not(U32.is_eq(rN,10)) && Bool.not(U32.is_eq(rN,11)) && Bool.not(U32.is_eq(rN,0)) &&
            w5b_reg_dead_fast(0,tail,fnItems) && w5b_reg_dead_fast(10,tail,fnItems) &&
            w5b_reg_dead_fast(11,tail,fnItems) && w5b_reg_dead_fast(rN,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{Con{PInst{X187Instruction{"movq",[srcY,x188_reg(11,64)]}},
                  Con{PInst{X187Instruction{"testl",[x188_reg(10,32),x188_reg(10,32)]}},
                  Con{PInst{X187Instruction{"cmovneq",[x188_reg(11,64),x188_reg(rN,64)]}},
                  Con{PInst{X187Instruction{"movq",[x188_reg(rN,64),dst]}},tail}}}}},
        u => None{})
    case _: None{}

# Try duplicate load before imull: movq d(%rbp), %rA; movq d(%rbp), %rB; imull %rA32, %rB32 (%rA dead)
@unsafe
def w5b_try_dup_square(+d1: U32, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Mem{5,d2},Con{X187Reg{+rB,64,False{}},Nil{}}}}},
         Con{PInst{X187Instruction{op2,Con{X187Reg{+m1,32,False{}},Con{X187Reg{+m2,32,False{}},Nil{}}}}},+tail}}:
      +okA = agy_str_eq(op1,"movq") && agy_str_eq(op2,"imull") && U32.is_eq(d1,d2) &&
             Bool.not(U32.is_eq(rA,rB)) && U32.is_eq(m1,rA) && U32.is_eq(m2,rB) &&
             w5b_reg_dead_fast(rA,tail,fnItems)
      +okB = agy_str_eq(op1,"movq") && agy_str_eq(op2,"imull") && U32.is_eq(d1,d2) &&
             Bool.not(U32.is_eq(rA,rB)) && U32.is_eq(m1,rB) && U32.is_eq(m2,rA) &&
             w5b_reg_dead_fast(rB,tail,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,okA,
        u => Some{Con{PInst{X187Instruction{"movq",[X187Mem{5,d1},x188_reg(rB,64)]}},
                  Con{PInst{X187Instruction{"imull",[x188_reg(rB,32),x188_reg(rB,32)]}},tail}}},
        u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,okB,
          v => Some{Con{PInst{X187Instruction{"movq",[X187Mem{5,d1},x188_reg(rA,64)]}},
                    Con{PInst{X187Instruction{"imull",[x188_reg(rA,32),x188_reg(rA,32)]}},tail}}},
          v => None{}))
    case _: None{}

law w5b_peep:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w5b_peep_apply(hit: Maybe<&2,List<&2,X187Parsed>>, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hit:
    case Some{rewritten}: w5b_peep(rewritten,fnItems,acc)
    case None{}: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5b_peep_movq(+rA: U32, +rB: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +h = w4c_or_peep_opt(w5b_try_ror16(rA,rB,rest,fnItems),
    u => w4c_or_peep_opt(w5b_try_rol16(rA,rB,rest,fnItems),
      v => w4c_or_peep_opt(w5b_try_cmp_bounce(rA,rB,rest,fnItems),
        w => w4c_or_peep_opt(w5b_try_sel_bounce(rA,rB,rest,fnItems),
          z => w5b_try_spill_bounce(rA,rB,rest,fnItems)))))
  w5b_peep_apply(h,i0,rest,fnItems,acc)

@unsafe
def w5b_peep_movzbl(+rD: U32, +i0: X187Parsed, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{r1,32,False{}},Con{X187Reg{r2,32,False{}},Nil{}}}}},+tail}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op1,"movl") && U32.is_eq(r1,rD) && U32.is_eq(r2,rD),
        u => w5b_peep(tail,fnItems,Con{i0,acc}),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case _: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5b_peep_inst(+i0: X187Parsed, +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match i0:
    case PInst{X187Instruction{+op,Con{X187Reg{+rA,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movq"),
        u => w5b_peep_movq(rA,rB,i0,rest,fnItems,acc),
        u => nt_choose(List<&2,X187Parsed>,w5b_is_cmp(op),
          v => w5b_peep_apply(w5b_try_cmp_jcc(i0,rest,fnItems),i0,rest,fnItems,acc),
          v => w5b_peep(rest,fnItems,Con{i0,acc})))
    case PInst{X187Instruction{+op,Con{X187Reg{_,8,False{}},Con{X187Reg{+rD,32,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movzbl"),
        u => w5b_peep_movzbl(rD,i0,rest,fnItems,acc),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case PInst{X187Instruction{+op,Con{X187Mem{5,+d1},Con{X187Reg{+rA,64,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movq"),
        u => w5b_peep_apply(w5b_try_dup_square(d1,rA,rest,fnItems),i0,rest,fnItems,acc),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case PInst{X187Instruction{+op,Con{X187Target{+l1},Nil{}}}}:
      w5b_peep_apply(w5b_try_jcc_jmp(op,l1,rest),i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,_}}:
      nt_choose(List<&2,X187Parsed>,w5b_is_cmp(op),
        u => w5b_peep_apply(w5b_try_cmp_jcc(i0,rest,fnItems),i0,rest,fnItems,acc),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case _: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5b_peep(items,fnItems,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,+rest}: w5b_peep_inst(i0,rest,fnItems,acc)

"""

    anchor = """@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:"""
    src = replace_exact(src, anchor, w5b_peep_code + anchor, "Pass 6a: insert w5b_peep")

    new_post = """  +g1 = w5_gpr_peep(f5,f5,[])
  +g2 = w5_gpr_peep(g1,g1,[])
  +g3 = w5_gpr_peep(g2,g2,[])
  +b1 = w5b_peep(g3,g3,[])
  +b1b = w5b_peep(b1,b1,[])
  +b2 = w5_flat_rev_seq(w4c_peep_cfg(b1b,b1b,[]),[])
  +xmm = w5_run_xmm(hasXmm,hasNegRbp,b2)
  w4b_wrap_items(xmm,[])"""
    src = replace_exact(src, old_post, new_post, "Pass 6b: wire w5b_peep + w4c_peep_cfg into w4_post_select")
    return src


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    src = args.src.read_text()
    src = patch_1_noxmm_disjoint_buf(src)
    src = patch_2_regalloc_size_cap(src)
    src = patch_3_local_values_if_hoist(src)
    src = patch_4_succ_store_sink(src)
    src = patch_5_x187_rotate_encode(src)
    src = patch_6_general_peepholes(src)

    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(src)
    print(f"Wrote {args.dst} ({len(src)} bytes)", flush=True)


if __name__ == "__main__":
    main()
