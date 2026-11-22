#!/usr/bin/env python3
"""Wave 4 Phase 3 Track W4-9: General Branchless cmov Diamonds + Loop Rotation/Copy-Peep Fixes.

100% general, semantics-preserving compiler passes on top of wave4b_unified/compiler.bend:
  1. Post-p111v pure scalar diamond hoisting (`w4c_diamond_body`) right before CSE (`x186_e_body`):
     hoists short (<=16 stmt) effect-free, trap-free scalar P113DIf arms into straight-line code
     feeding a canonical 1-stmt P113DIf select lowered to branchless `cmov` by `x191_conditional_select`.
  2. CSE (`x186_e_if`) and transient GPR regalloc (`x185_t_if`) preservation across 1-stmt
     branchless `cmov` selects (no state clear / no region cut), plus cap bump (64->128 facts,
     4096->8192 stmt cap in x186_expression_body and x185_dead_body).
  3. Restore & strengthen W4-7 x86 backend passes when composed with W4-6's `cmpq $0 -> testq`
     peephole:
     - `w4b_rotate_body`: accept both `cmpq/cmpl $0, %r` and `testq/testl %r, %r`.
     - `w4b_copy_check_cmp`: accept both `cmpq $0, %c` and `testq %c, %c`.
     - `w4b_taildup_check`: tail-duplicate both 1-inst and 2-inst merge-backedge blocks.
     - `w4b_reg_dead_go`: treat `popq %reg` as write-only (overwrites `%reg`, does not read it),
       bump deadness hops 3->4 and budget 24->36, and run a post-rotation `w4b_copy_peep` pass.
"""
import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave4b_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave4c_cmov/compiler.bend"


def replace_once(text: str, old: str, new: str, label: str) -> str:
    n = text.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return text.replace(old, new, 1)


# ---------------------------------------------------------------------------
# Patch 1: x185_t_if preservation across 1-stmt branchless cmov select diamonds
# ---------------------------------------------------------------------------
OLD_T_IF = """@unsafe
def x185_t_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, scan: X185TScan) -> X185TScan:
  x185_t_cut(x185_t_body(no,x185_t_cut(x185_t_body(yes,x185_t_cut(x185_t_read(condition,scan))))))"""

NEW_T_IF = """type W4CSelArm is Data:
  W4CSelArmNone{}
  W4CSelArm{+name: String, +typ: N111Type, +val: N111Value}

@unsafe
def w4c_sel_val(v: N111Value) -> Bool:
  match v:
    case N111Local{_}: True{}
    case N111Const{_,_}: True{}
    case _: False{}

def w4c_sel_width(t: N111Type) -> Bool:
  match t:
    case N111U32{}: True{}
    case N111U64{}: True{}
    case _: False{}

@unsafe
def w4c_sel_arm_scalar(stmt: N111Stmt) -> W4CSelArm:
  match stmt:
    case N111Set{n,t,v}: W4CSelArm{n,t,v}
    case _: W4CSelArmNone{}

@unsafe
def w4c_sel_arm(body: List<&2,P113DStmt>) -> W4CSelArm:
  match body:
    case Con{P113DScalar{sc},Nil{}}: w4c_sel_arm_scalar(sc)
    case _: W4CSelArmNone{}

@unsafe
def w4c_t_if_sel_no(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    +a: String, +ta: N111Type, +va: N111Value, na: W4CSelArm, +scan: X185TScan) -> X185TScan:
  match na:
    case W4CSelArm{+b,+tb,+vb}:
      nt_choose(X185TScan,
        w4c_sel_val(condition) && agy_str_eq(a,b) && Bool.not(x181_register_reserved(a)) &&
          w4c_sel_width(ta) && U32.is_eq(p111v_type(ta),p111v_type(tb)) &&
          w4c_sel_val(va) && w4c_sel_val(vb),
        u => x185_t_next(x185_t_event(a,True{},x185_t_read(vb,x185_t_read(va,x185_t_read(condition,scan))))),
        u => x185_t_cut(x185_t_body(no,x185_t_cut(x185_t_body(yes,x185_t_cut(x185_t_read(condition,scan)))))))
    case W4CSelArmNone{}:
      x185_t_cut(x185_t_body(no,x185_t_cut(x185_t_body(yes,x185_t_cut(x185_t_read(condition,scan))))))

@unsafe
def w4c_t_if_sel(condition: N111Value, yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    ya: W4CSelArm, scan: X185TScan) -> X185TScan:
  match ya:
    case W4CSelArm{a,ta,va}: w4c_t_if_sel_no(condition,yes,no,a,ta,va,w4c_sel_arm(no),scan)
    case W4CSelArmNone{}:
      x185_t_cut(x185_t_body(no,x185_t_cut(x185_t_body(yes,x185_t_cut(x185_t_read(condition,scan))))))

@unsafe
def x185_t_if(condition: N111Value, +yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, scan: X185TScan) -> X185TScan:
  w4c_t_if_sel(condition,yes,no,w4c_sel_arm(yes),scan)"""


# ---------------------------------------------------------------------------
# Patch 1b: Prevent long-lived intervals (>48 stmts) from hogging transient GPRs
# in large functions (>256 stmts) in x185_t_place / x185_t_scanned.
# ---------------------------------------------------------------------------
OLD_T_PLACE = """@unsafe
def x185_t_place(names,ranges,frame,ends):
  match names frame:
    case Nil{} _: frame
    case Con{+name,+rest} X181Frame{+slots,bytes,calls,params,symbol}:
      +range = p111v_get(ranges,name)
      nt_choose(X181Frame,agy_str_eq(dk(range),"X185TRange") &&
          agy_str_eq(dk(p111v_get(slots,name)),"X181Stack"),
        u => x185_t_chosen(name,rest,ranges,frame,ends,x185_t_pick(ends,da(range),0),dx(range)),
        u => x185_t_place(rest,ranges,frame,ends))

@unsafe
def x185_t_scanned(frame: X181Frame, scan: X185TScan) -> X181Frame:
  match scan:
    case X185TScan{ranges,names,position,region}:
      x185_t_place(nt_reverse(String,names,[]),ranges,frame,[0,0,0,0,0])"""

NEW_T_PLACE = """law w4c_t_place_cap:
  for names: List<&2,String>
  for +ranges: KDef
  for +frame: X181Frame
  for +ends: List<&2,U32>
  for +maxSpan: U32
  X181Frame

@unsafe
def w4c_t_chosen_cap(name: String, +rest: List<&2,String>, +ranges: KDef, +frame: X181Frame,
    +ends: List<&2,U32>, +maxSpan: U32, +index: U32, +last: U32) -> X181Frame:
  nt_choose(X181Frame,U32.is_lt(index,5),
    u => w4c_t_place_cap(rest,ranges,x185_t_install(name,index,frame),x185_t_end(ends,index,last),maxSpan),
    u => w4c_t_place_cap(rest,ranges,frame,ends,maxSpan))

@unsafe
def w4c_t_place_cap(names,ranges,frame,ends,maxSpan):
  match names frame:
    case Nil{} _: frame
    case Con{+name,+rest} X181Frame{+slots,bytes,calls,params,symbol}:
      +range = p111v_get(ranges,name)
      +spanOk = U32.is_eq(maxSpan,0) || U32.is_le(U32.sub(dx(range),da(range)),maxSpan)
      nt_choose(X181Frame,agy_str_eq(dk(range),"X185TRange") &&
          agy_str_eq(dk(p111v_get(slots,name)),"X181Stack") && spanOk,
        u => w4c_t_chosen_cap(name,rest,ranges,frame,ends,maxSpan,x185_t_pick(ends,da(range),0),dx(range)),
        u => w4c_t_place_cap(rest,ranges,frame,ends,maxSpan))

@unsafe
def x185_t_place(names,ranges,frame,ends):
  w4c_t_place_cap(names,ranges,frame,ends,0)

@unsafe
def x185_t_scanned(frame: X181Frame, scan: X185TScan) -> X181Frame:
  match scan:
    case X185TScan{ranges,names,+position,region}:
      +cap = nt_choose(U32,U32.is_gt(position,256),u => 48,u => 0)
      w4c_t_place_cap(nt_reverse(String,names,[]),ranges,frame,[0,0,0,0,0],cap)"""


# ---------------------------------------------------------------------------
# Patch 2: Bump x185_dead_body cap 4096 -> 8192
# ---------------------------------------------------------------------------
OLD_DEAD_CAP = """@unsafe
def x185_dead_body(setup,body):
  nt_choose(List<&2,P113DStmt>,x185_dead_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),"""

NEW_DEAD_CAP = """@unsafe
def x185_dead_body(setup,body):
  nt_choose(List<&2,P113DStmt>,x185_dead_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),8192),"""


# ---------------------------------------------------------------------------
# Patch 3: Bump x186_e_remember_alias & x186_e_insert caps 64 -> 1024
# ---------------------------------------------------------------------------
OLD_E_ALIAS_CAP = """          Bool.not(x185_sf_source(value,name)) && U32.is_lt(nt_count(X186Alias,aliases),64),"""
NEW_E_ALIAS_CAP = """          Bool.not(x185_sf_source(value,name)) && U32.is_lt(nt_count(X186Alias,aliases),1024),"""

OLD_E_FACT_CAP = """          U32.is_lt(nt_count(X186Expr,facts),64),"""
NEW_E_FACT_CAP = """          U32.is_lt(nt_count(X186Expr,facts),1024),"""


# ---------------------------------------------------------------------------
# Patch 4: CSE preservation across 1-stmt cmov select + w4c_diamond_body
# ---------------------------------------------------------------------------
OLD_E_IF_AND_EXPR = """@unsafe
def x186_e_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, +state: X186ExprState) -> List<&2,P113DStmt>:
  Con{P113DIf{condition,x186_e_body(yes,state),x186_e_body(no,state)},x186_e_body(rest,x186_e_empty())}

@unsafe
def x186_e_body(body,state):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x186_e_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,state)
    case Con{P113DIf{condition,yes,no},rest}: x186_e_if(condition,yes,no,rest,state)
    case Con{P113DScalar{stmt},rest}: x186_e_after(rest,x186_e_scalar(stmt,state))
    case Con{head,rest}: Con{head,x186_e_body(rest,x186_e_empty())}

@unsafe
def x186_expression_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x186_expression_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x186_e_body(body,x186_e_empty()),u => body)"""

NEW_E_IF_AND_EXPR = """@unsafe
def w4c_e_kill_val(v: N111Value, state: X186ExprState) -> X186ExprState:
  match v:
    case N111Local{n}: x186_e_written(state,n)
    case _: state

@unsafe
def w4c_e_kill_cond(+v: N111Value, +state: X186ExprState) -> X186ExprState:
  match state:
    case X186ExprState{_,aliases}:
      w4c_e_kill_val(x186_e_value(v,aliases),w4c_e_kill_val(v,state))

@unsafe
def w4c_e_if_sel_no(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    +a: String, +ta: N111Type, +va: N111Value, na: W4CSelArm,
    +rest: List<&2,P113DStmt>, +state: X186ExprState) -> List<&2,P113DStmt>:
  match na:
    case W4CSelArm{+b,+tb,+vb}:
      nt_choose(List<&2,P113DStmt>,
        w4c_sel_val(condition) && agy_str_eq(a,b) && Bool.not(x181_register_reserved(a)) &&
          w4c_sel_width(ta) && U32.is_eq(p111v_type(ta),p111v_type(tb)) &&
          w4c_sel_val(va) && w4c_sel_val(vb),
        u => Con{P113DIf{condition,yes,no},
          x186_e_body(rest,w4c_e_kill_cond(condition,x186_e_written(state,a)))},
        u => Con{P113DIf{condition,x186_e_body(yes,state),x186_e_body(no,state)},x186_e_body(rest,x186_e_empty())})
    case W4CSelArmNone{}:
      Con{P113DIf{condition,x186_e_body(yes,state),x186_e_body(no,state)},x186_e_body(rest,x186_e_empty())}

@unsafe
def w4c_e_if_sel(condition: N111Value, yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    ya: W4CSelArm, rest: List<&2,P113DStmt>, +state: X186ExprState) -> List<&2,P113DStmt>:
  match ya:
    case W4CSelArm{a,ta,va}: w4c_e_if_sel_no(condition,yes,no,a,ta,va,w4c_sel_arm(no),rest,state)
    case W4CSelArmNone{}:
      Con{P113DIf{condition,x186_e_body(yes,state),x186_e_body(no,state)},x186_e_body(rest,x186_e_empty())}

@unsafe
def x186_e_if(condition: N111Value, +yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, +state: X186ExprState) -> List<&2,P113DStmt>:
  w4c_e_if_sel(condition,yes,no,w4c_sel_arm(yes),rest,state)

@unsafe
def x186_e_body(body,state):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x186_e_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,state)
    case Con{P113DIf{condition,yes,no},rest}: x186_e_if(condition,yes,no,rest,state)
    case Con{P113DScalar{stmt},rest}: x186_e_after(rest,x186_e_scalar(stmt,state))
    case Con{head,rest}: Con{head,x186_e_body(rest,x186_e_empty())}

# General post-p111v pure scalar diamond hoisting to branchless cmov selects.
type W4CLastDst is Data:
  W4CLastNone{}
  W4CLast{+name: String, +typ: N111Type}

type W4CDiaRes is Data:
  W4CDiaRes{+body: List<&2,P113DStmt>, +live: KDef, +seq: U32}

@unsafe
def w4c_dia_has(+m: KDef, +n: String) -> Bool:
  U32.is_gt(da(p111v_get(m,n)),0)

@unsafe
def w4c_dia_is_sel(arm: W4CSelArm) -> Bool:
  match arm:
    case W4CSelArm{_,_,_}: True{}
    case W4CSelArmNone{}: False{}

@unsafe
def w4c_dia_pure_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{+n,+t,_}: Bool.not(x181_register_reserved(n)) && w4c_sel_width(t)
    case N111Bin{+n,+t,+op,_,_}: Bool.not(x181_register_reserved(n)) && w4k_pure_bin(op) && w4c_sel_width(t)
    case _: False{}

@unsafe
def w4c_dia_arm_pure(body: List<&2,P113DStmt>, +limit: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{sc},rest}:
      U32.is_gt(limit,0) && w4c_dia_pure_scalar(sc) && w4c_dia_arm_pure(rest,U32.sub(limit,1))
    case _: False{}

@unsafe
def w4c_dia_last_scalar(stmt: N111Stmt) -> W4CLastDst:
  match stmt:
    case N111Set{n,t,_}: W4CLast{n,t}
    case N111Bin{n,t,+op,_,_}:
      W4CLast{n,nt_choose(N111Type,p111v_comparison(op),u => N111U32{},u => t)}
    case _: W4CLastNone{}

@unsafe
def w4c_dia_last_dst(body: List<&2,P113DStmt>) -> W4CLastDst:
  match body:
    case Nil{}: W4CLastNone{}
    case Con{P113DScalar{sc},Nil{}}: w4c_dia_last_scalar(sc)
    case Con{_,rest}: w4c_dia_last_dst(rest)

@unsafe
def w4c_dia_write_scalar(stmt: N111Stmt, acc: KDef) -> KDef:
  match stmt:
    case N111Set{n,_,_}: x185_d_mark(acc,n)
    case N111Bin{n,_,_,_,_}: x185_d_mark(acc,n)
    case _: acc

@unsafe
def w4c_dia_writes(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{sc},rest}: w4c_dia_writes(rest,w4c_dia_write_scalar(sc,acc))
    case Con{_,rest}: w4c_dia_writes(rest,acc)

@unsafe
def w4c_dia_read_scalar(stmt: N111Stmt, acc: KDef) -> KDef:
  match stmt:
    case N111Set{_,_,v}: x185_d_value(v,acc)
    case N111Bin{_,_,_,l,r}: x185_d_value(r,x185_d_value(l,acc))
    case _: acc

@unsafe
def w4c_dia_reads(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{sc},rest}: w4c_dia_reads(rest,w4c_dia_read_scalar(sc,acc))
    case Con{_,rest}: w4c_dia_reads(rest,acc)

@unsafe
def w4c_dia_nonlast_name(stmt: N111Stmt) -> String:
  match stmt:
    case N111Set{n,_,_}: n
    case N111Bin{n,_,_,_,_}: n
    case _: ""

@unsafe
def w4c_dia_nonlast_ok(body: List<&2,P113DStmt>, +dst: String, +forb: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{_,Nil{}}: True{}
    case Con{P113DScalar{sc},rest}:
      +n = w4c_dia_nonlast_name(sc)
      Bool.not(String.is_empty(n)) && Bool.not(agy_str_eq(n,dst)) &&
        Bool.not(w4c_dia_has(forb,n)) && w4c_dia_nonlast_ok(rest,dst,forb)
    case _: False{}

@unsafe
def w4c_dia_cond_ok(cond: N111Value, +writes: KDef) -> Bool:
  match cond:
    case N111Local{n}: Bool.not(w4c_dia_has(writes,n))
    case N111Const{_,_}: True{}
    case _: False{}

@unsafe
def w4c_dia_rename_scalar(stmt: N111Stmt, +newDst: String) -> N111Stmt:
  match stmt:
    case N111Set{_,t,v}: N111Set{newDst,t,v}
    case N111Bin{_,t,op,l,r}: N111Bin{newDst,t,op,l,r}
    case _: stmt

@unsafe
def w4c_dia_rename_last(body: List<&2,P113DStmt>, +newDst: String) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{sc},Nil{}}: [P113DScalar{w4c_dia_rename_scalar(sc,newDst)}]
    case Con{h,rest}: Con{h,w4c_dia_rename_last(rest,newDst)}

@unsafe
def w4c_dia_try_no(+cond: N111Value, +yb: List<&2,P113DStmt>, +nb: List<&2,P113DStmt>,
    +rest: List<&2,P113DStmt>, +afterLive: KDef, +yl: KDef, +nl: KDef, +seq: U32,
    +ydst: String, +yt: N111Type, nd: W4CLastDst) -> W4CDiaRes:
  match nd:
    case W4CLast{+ndst,+nt}:
      +basic = Bool.not(String.is_empty(ydst)) && agy_str_eq(ydst,ndst) &&
        Bool.not(x181_register_reserved(ydst)) &&
        w4c_sel_width(yt) && w4c_sel_width(nt) &&
        w4c_sel_val(cond) &&
        Bool.not(w4c_dia_is_sel(w4c_sel_arm(yb)) && w4c_dia_is_sel(w4c_sel_arm(nb))) &&
        w4c_dia_arm_pure(yb,16) && w4c_dia_arm_pure(nb,16)
      nt_choose(W4CDiaRes,basic,
        u =>
          +yw = w4c_dia_writes(yb,missing())
          +nw = w4c_dia_writes(nb,missing())
          +yr = w4c_dia_reads(yb,missing())
          +nr = w4c_dia_reads(nb,missing())
          +forbY = x185_d_union(afterLive,x185_d_union(nr,nw))
          +forbN = x185_d_union(afterLive,x185_d_union(yr,yw))
          +ok = w4c_dia_cond_ok(cond,yw) && w4c_dia_cond_ok(cond,nw) &&
            w4c_dia_nonlast_ok(yb,ydst,forbY) && w4c_dia_nonlast_ok(nb,ydst,forbN)
          nt_choose(W4CDiaRes,ok,
            v =>
              +resTyp = nt_choose(N111Type,U32.is_eq(p111v_type(yt),2) || U32.is_eq(p111v_type(nt),2),
                z => N111U64{},z => N111U32{})
              +ynm = ydst ++ "_w4cy" ++ U32.show(seq)
              +nnm = ydst ++ "_w4cn" ++ U32.show(seq)
              +sel : P113DStmt = P113DIf{cond,
                [P113DScalar{N111Set{ydst,resTyp,N111Local{ynm}}}],
                [P113DScalar{N111Set{ydst,resTyp,N111Local{nnm}}}]}
              +merged = nt_append(P113DStmt,w4c_dia_rename_last(yb,ynm),
                nt_append(P113DStmt,w4c_dia_rename_last(nb,nnm),Con{sel,rest}))
              W4CDiaRes{merged,x185_d_value(cond,x185_d_union(yl,nl)),U32.inc(seq)},
            v => W4CDiaRes{Con{P113DIf{cond,yb,nb},rest},x185_d_value(cond,x185_d_union(yl,nl)),seq}),
        u => W4CDiaRes{Con{P113DIf{cond,yb,nb},rest},x185_d_value(cond,x185_d_union(yl,nl)),seq})
    case W4CLastNone{}:
      W4CDiaRes{Con{P113DIf{cond,yb,nb},rest},x185_d_value(cond,x185_d_union(yl,nl)),seq}

@unsafe
def w4c_dia_try(+cond: N111Value, +yb: List<&2,P113DStmt>, +nb: List<&2,P113DStmt>,
    +rest: List<&2,P113DStmt>, +afterLive: KDef, +yl: KDef, +nl: KDef, +seq: U32,
    yd: W4CLastDst) -> W4CDiaRes:
  match yd:
    case W4CLast{ydst,yt}: w4c_dia_try_no(cond,yb,nb,rest,afterLive,yl,nl,seq,ydst,yt,w4c_dia_last_dst(nb))
    case W4CLastNone{}:
      W4CDiaRes{Con{P113DIf{cond,yb,nb},rest},x185_d_value(cond,x185_d_union(yl,nl)),seq}

law w4c_dia_body:
  for body: List<&2,P113DStmt>
  for live: KDef
  for +again: KDef
  for +terminal: KDef
  for +seq: U32
  W4CDiaRes

@unsafe
def w4c_dia_if_done(+cond: N111Value, rest: List<&2,P113DStmt>, +afterLive: KDef,
    yes: W4CDiaRes, no: W4CDiaRes) -> W4CDiaRes:
  match yes:
    case W4CDiaRes{+yb,+yl,_}:
      match no:
        case W4CDiaRes{+nb,+nl,+seq2}:
          w4c_dia_try(cond,yb,nb,rest,afterLive,yl,nl,seq2,w4c_dia_last_dst(yb))

@unsafe
def w4c_dia_if_yes(+cond: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +afterLive: KDef, +again: KDef, +terminal: KDef, yes: W4CDiaRes) -> W4CDiaRes:
  match yes:
    case W4CDiaRes{yb,yl,+seq1}:
      w4c_dia_if_done(cond,rest,afterLive,W4CDiaRes{yb,yl,seq1},w4c_dia_body(no,afterLive,again,terminal,seq1))

@unsafe
def w4c_dia_if(cond: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    after: W4CDiaRes, +again: KDef, +terminal: KDef) -> W4CDiaRes:
  match after:
    case W4CDiaRes{rest,+live,+seq0}:
      w4c_dia_if_yes(cond,no,rest,live,again,terminal,w4c_dia_body(yes,live,again,terminal,seq0))

@unsafe
def w4c_dia_scalar_go(+stmt: N111Stmt, rest: List<&2,P113DStmt>, live: KDef, +seq: U32, +again: KDef, +terminal: KDef) -> W4CDiaRes:
  match stmt:
    case N111Set{name,_,value}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_value(value,x185_d_kill(live,name)),seq}
    case N111Bin{name,_,_,l,r}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_value(r,x185_d_value(l,x185_d_kill(live,name))),seq}
    case N111Offset{name,b,by}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_value(by,x185_d_value(b,x185_d_kill(live,name))),seq}
    case N111Call{name,_,_,args}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_args(args,x185_d_kill(live,name)),seq}
    case N111Load{name,_,b,_}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_value(b,x185_d_kill(live,name)),seq}
    case N111Store{_,b,_,v}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_value(v,x185_d_value(b,live)),seq}
    case N111Alloca{name,_,_}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_kill(live,name),seq}
    case N111If{cond,yes,no}: w4c_dia_if(cond,x181_scalar_rows(yes),x181_scalar_rows(no),W4CDiaRes{rest,live,seq},again,terminal)
    case N111Return{v}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_value(v,terminal),seq}

@unsafe
def w4c_dia_scalar(stmt: N111Stmt, after: W4CDiaRes, +again: KDef, +terminal: KDef) -> W4CDiaRes:
  match after:
    case W4CDiaRes{rest,live,seq}: w4c_dia_scalar_go(stmt,rest,live,seq,again,terminal)

@unsafe
def w4c_dia_stmt(+stmt: P113DStmt, after: W4CDiaRes, +again: KDef, +terminal: KDef) -> W4CDiaRes:
  match stmt:
    case P113DScalar{sc}: w4c_dia_scalar(sc,after,again,terminal)
    case P113DIf{cond,yes,no}: w4c_dia_if(cond,yes,no,after,again,terminal)
    case P113DCall{names,_,args}:
      match after:
        case W4CDiaRes{rest,live,seq}: W4CDiaRes{Con{stmt,rest},x185_d_values(args,x185_d_kills(names,live)),seq}
    case P113DResult{vals}:
      match after:
        case W4CDiaRes{rest,_,seq}: W4CDiaRes{Con{stmt,rest},x185_d_values(vals,terminal),seq}
    case P113DAgain{vals}:
      match after:
        case W4CDiaRes{rest,_,seq}: W4CDiaRes{Con{stmt,rest},x185_d_values(vals,again),seq}

@unsafe
def w4c_dia_body(body,live,again,terminal,seq):
  match body:
    case Nil{}: W4CDiaRes{[],live,seq}
    case Con{h,rest}: w4c_dia_stmt(h,w4c_dia_body(rest,live,again,terminal,seq),again,terminal)

@unsafe
def w4c_dia_out(res: W4CDiaRes) -> List<&2,P113DStmt>:
  match res:
    case W4CDiaRes{out,_,_}: out

@unsafe
def w4c_diamond_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  +base = x185_d_base()
  +again = x185_d_union(x185_copy_writes(setup,missing()),base)
  w4c_dia_out(w4c_dia_body(body,base,again,base,0))

# General adjacent self-update splitter before CSE:
# When `x = pure_bin(l1, r1)` is immediately followed by `x = bin(l2, r2)` (same `x`),
# rename the first def to a fresh local `xs` and substitute `x -> xs` in `l2, r2`.
# This exposes both expressions to `x186_e_body` CSE without changing semantics.
@unsafe
def w4c_su_subst(v: N111Value, +old: String, +fresh: String) -> N111Value:
  match v:
    case N111Local{+n}: nt_choose(N111Value,agy_str_eq(n,old),u => N111Local{fresh},u => N111Local{n})
    case _: v

law w4c_su_body:
  for body: List<&2,P113DStmt>
  for +seq: U32
  List<&2,P113DStmt>

@unsafe
def w4c_su_is_const1(v: N111Value) -> Bool:
  match v:
    case N111Const{1,0}: True{}
    case _: False{}

@unsafe
def w4c_su_is_local(v: N111Value, +target: String) -> Bool:
  match v:
    case N111Local{n}: agy_str_eq(n,target)
    case _: False{}

@unsafe
def w4c_su_check_second(+x1: String, +t1: N111Type, +op1: String, +l1: N111Value, +r1: N111Value,
    +s2: P113DStmt, +rest: List<&2,P113DStmt>, +seq: U32) -> List<&2,P113DStmt>:
  match s2:
    case P113DScalar{N111Bin{+x2,+t2,+op2,+l2,+r2}}:
      +dblXor = agy_str_eq(op1,"xor") && agy_str_eq(op2,"xor") &&
        w4c_su_is_const1(r1) && w4c_su_is_const1(r2) && w4c_su_is_local(l2,x1) &&
        Bool.not(w4c_su_is_local(l1,x1)) &&
        Bool.not(x181_register_reserved(x2)) && w4c_sel_width(t1) && w4c_sel_width(t2)
      nt_choose(List<&2,P113DStmt>,dblXor,
        u =>
          +outTyp = nt_choose(N111Type,U32.is_eq(p111v_type(t1),1) || U32.is_eq(p111v_type(t2),1),
            z => N111U32{},z => N111U64{})
          Con{P113DScalar{N111Bin{x1,t1,op1,l1,r1}},
            w4c_su_body(Con{P113DScalar{N111Set{x2,outTyp,l1}},rest},seq)},
        u => nt_choose(List<&2,P113DStmt>,agy_str_eq(x1,x2) && Bool.not(x181_register_reserved(x1)) && w4k_pure_bin(op1),
          v =>
            +fresh = x1 ++ "_w4s" ++ U32.show(seq)
            +st1 : P113DStmt = P113DScalar{N111Bin{fresh,t1,op1,l1,r1}}
            +st2 : P113DStmt = P113DScalar{N111Bin{x2,t2,op2,w4c_su_subst(l2,x1,fresh),w4c_su_subst(r2,x1,fresh)}}
            Con{st1,w4c_su_body(Con{st2,rest},U32.inc(seq))},
          v => Con{P113DScalar{N111Bin{x1,t1,op1,l1,r1}},w4c_su_body(Con{s2,rest},seq)}))
    case _: Con{P113DScalar{N111Bin{x1,t1,op1,l1,r1}},w4c_su_body(Con{s2,rest},seq)}

@unsafe
def w4c_su_pair(s1: P113DStmt, s2: P113DStmt, rest: List<&2,P113DStmt>, +seq: U32) -> List<&2,P113DStmt>:
  match s1:
    case P113DScalar{N111Bin{x1,t1,op1,l1,r1}}: w4c_su_check_second(x1,t1,op1,l1,r1,s2,rest,seq)
    case P113DIf{cond,yes,no}:
      Con{P113DIf{cond,w4c_su_body(yes,seq),w4c_su_body(no,U32.add(seq,1000))},w4c_su_body(Con{s2,rest},U32.add(seq,2000))}
    case _: Con{s1,w4c_su_body(Con{s2,rest},seq)}

@unsafe
def w4c_su_body(body,seq):
  match body:
    case Nil{}: []
    case Con{s1,Con{s2,rest}}: w4c_su_pair(s1,s2,rest,seq)
    case Con{P113DIf{cond,yes,no},Nil{}}: [P113DIf{cond,w4c_su_body(yes,seq),w4c_su_body(no,U32.add(seq,1000))}]
    case Con{h,Nil{}}: [h]

@unsafe
def x186_expression_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x186_expression_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),8192),
    u => x186_e_body(w4c_su_body(w4c_diamond_body(setup,body),0),x186_e_empty()),u => body)"""


# ---------------------------------------------------------------------------
# Patch 4b: In x190_j_counted, dispatch huge loop functions (>64 candidate vars)
# to x181_register_frame + x185_transient_frame (which is 100% loop-safe),
# instead of spilling >80% of temporaries due to x190_j_selected's 32-var cap.
# ---------------------------------------------------------------------------
OLD_J_COUNTED = """      nt_choose(X181Frame,U32.is_gt(nt_count(String,names),32) && Bool.not(x190_register_loop(body)),
        u => x185_transient_frame(x181_register_frame(frame,registerBody),params,setup,body),"""

NEW_J_COUNTED = """      +nCands = nt_count(String,names)
      nt_choose(X181Frame,(U32.is_gt(nCands,32) && Bool.not(x190_register_loop(body))) || U32.is_gt(nCands,64),
        u => x185_transient_frame(x181_register_frame(frame,registerBody),params,setup,body),"""


# ---------------------------------------------------------------------------
# Patch 5: W4-7 / W4-6 composition fixes + expression speedups
#   - popq handling in w4b_reg_dead_go, hops 3->4, budget 24->36
#   - testq %c, %c support in w4b_copy_check_cmp
#   - testq/testl %r, %r support in w4b_rotate_body
#   - 1-inst and 2-inst merge blocks in w4b_taildup_check
#   - post-rotation w4b_copy_peep in w4_post_select
# ---------------------------------------------------------------------------
OLD_REG_DEAD = """@unsafe
def w4b_reg_dead_go(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{_},rest}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)
    case Con{PInst{X187Instruction{+op,+args}},+rest}:
      nt_choose(Bool,agy_str_eq(op,"ret"),u => Bool.not(U32.is_eq(r,0)),u =>
        nt_choose(Bool,w4b_is_write_only_op(op),v => w4b_reg_dead_write(r,args,rest,fnItems,budget,hops),
          v => nt_choose(Bool,w4b_is_simple_alu(op),w =>
            nt_choose(Bool,w4b_args_read_reg(r,args),x => False{},
              x => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)),
            w => nt_choose(Bool,String.starts_with(op,"j"),
              x => w4b_reg_dead_branch(r,op,args,rest,fnItems,budget,hops),
              x => False{}))))
    case _: False{}

@unsafe
def w4b_reg_dead_step(r,items,fnItems,budget,hops):
  nt_choose(Bool,U32.is_eq(budget,0),u => False{},u => w4b_reg_dead_go(r,items,fnItems,budget,hops))

@unsafe
def w4b_reg_dead(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  w4b_reg_dead_step(r,items,fnItems,budget,3)"""

NEW_REG_DEAD = """@unsafe
def w4b_reg_dead_pop(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{X187Reg{+dr,+dw,False{}},Nil{}}:
      nt_choose(Bool,U32.is_eq(dr,r) && U32.is_ge(dw,32),u => True{},
        u => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops))
    case _: False{}

@unsafe
def w4b_reg_dead_go(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{_},rest}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)
    case Con{PInst{X187Instruction{+op,+args}},+rest}:
      nt_choose(Bool,agy_str_eq(op,"ret"),u => Bool.not(U32.is_eq(r,0)),u =>
        nt_choose(Bool,agy_str_eq(op,"popq"),p => w4b_reg_dead_pop(r,args,rest,fnItems,budget,hops),p =>
        nt_choose(Bool,w4b_is_write_only_op(op),v => w4b_reg_dead_write(r,args,rest,fnItems,budget,hops),
          v => nt_choose(Bool,w4b_is_simple_alu(op),w =>
            nt_choose(Bool,w4b_args_read_reg(r,args),x => False{},
              x => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)),
            w => nt_choose(Bool,String.starts_with(op,"j"),
              x => w4b_reg_dead_branch(r,op,args,rest,fnItems,budget,hops),
              x => False{})))))
    case _: False{}

@unsafe
def w4b_reg_dead_step(r,items,fnItems,budget,hops):
  nt_choose(Bool,U32.is_eq(budget,0),u => False{},u => w4b_reg_dead_go(r,items,fnItems,budget,hops))

@unsafe
def w4b_reg_dead(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  w4b_reg_dead_step(r,items,fnItems,budget,4)"""


OLD_COPY_CHECK = """@unsafe
def w4b_copy_check_cmp(cm: W4BImmReg, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match cm:
    case W4BImmReg{cop,lo,hi,cr,cw}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(cop,"cmpq") && U32.is_eq(lo,0) && U32.is_eq(hi,0) &&
          U32.is_eq(cr,c) && U32.is_eq(cw,64),
        u => w4b_copy_check_jcc(w4b_as_branch(i3),i0,i1,i2,i3,tail,fnItems,out),
        u => w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out}))
    case W4BImmRegNone{}: w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out})"""

NEW_COPY_CHECK = """@unsafe
def w4c_sub_fold4(r4: W4BRR, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match r4:
    case W4BRR{op4,s4,ws4,d4,wd4}:
      nt_choose(List<&2,X188Seq>,
        agy_str_eq(op4,"movq") && U32.is_eq(s4,a) && U32.is_eq(ws4,64) && U32.is_eq(d4,b) && U32.is_eq(wd4,64) &&
        Bool.not(U32.is_eq(a,b) || U32.is_eq(t,a) || U32.is_eq(t,b) || U32.is_eq(t,11) || U32.is_eq(a,11) || U32.is_eq(b,11)) &&
        w4b_reg_dead(t,tail,fnItems,36) && w4b_reg_dead(a,tail,fnItems,36) && w4b_reg_dead(11,tail,fnItems,36),
        u => w4b_copy_peep(Con{PInst{X187Instruction{"subl",[X187Reg{a,32,False{}},X187Reg{b,32,False{}}]}},tail},fnItems,out),
        u => w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out}))
    case W4BRRNone{}: w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})

@unsafe
def w4c_sub_fold3(r3: W4BRR, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match r3:
    case W4BRR{op3,s3,ws3,d3,wd3}:
      nt_choose(List<&2,X188Seq>,
        agy_str_eq(op3,"subl") && U32.is_eq(s3,11) && U32.is_eq(ws3,32) && U32.is_eq(d3,a) && U32.is_eq(wd3,32),
        u => w4c_sub_fold4(w4b_as_rr(i4),b,t,a,i0,i1,rest,tail,fnItems,out),
        u => w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out}))
    case W4BRRNone{}: w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})

@unsafe
def w4c_sub_fold2(r2: W4BRR, +i3: X187Parsed, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match r2:
    case W4BRR{op2,s2,ws2,d2,wd2}:
      nt_choose(List<&2,X188Seq>,
        agy_str_eq(op2,"movq") && U32.is_eq(s2,t) && U32.is_eq(ws2,64) && U32.is_eq(d2,a) && U32.is_eq(wd2,64),
        u => w4c_sub_fold3(w4b_as_rr(i3),i4,b,t,a,i0,i1,rest,tail,fnItems,out),
        u => w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out}))
    case W4BRRNone{}: w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})

@unsafe
def w4c_sub_fold(+b: U32, +t: U32, +a: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rest:
    case Con{i2,Con{i3,Con{i4,tail}}}:
      w4c_sub_fold2(w4b_as_rr(i2),i3,i4,b,t,a,i0,i1,rest,tail,fnItems,out)
    case _: w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})

@unsafe
def w4b_copy_check_test(tr: W4BRR, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match tr:
    case W4BRR{top,s,ws,d,wd}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(top,"testq") && U32.is_eq(s,c) && U32.is_eq(d,c) &&
          U32.is_eq(ws,64) && U32.is_eq(wd,64),
        u => w4b_copy_check_jcc(w4b_as_branch(i3),i0,i1,i2,i3,tail,fnItems,out),
        u => w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out}))
    case W4BRRNone{}: w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out})

@unsafe
def w4b_copy_check_cmp(cm: W4BImmReg, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match cm:
    case W4BImmReg{cop,lo,hi,cr,cw}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(cop,"cmpq") && U32.is_eq(lo,0) && U32.is_eq(hi,0) &&
          U32.is_eq(cr,c) && U32.is_eq(cw,64),
        u => w4b_copy_check_jcc(w4b_as_branch(i3),i0,i1,i2,i3,tail,fnItems,out),
        u => w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out}))
    case W4BImmRegNone{}: w4b_copy_check_test(w4b_as_rr(i2),c,i0,i1,i2,i3,tail,fnItems,out)"""

OLD_COPY_BUDGET = """      nt_choose(List<&2,X188Seq>,isMov32 && agy_str_eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) &&
          U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w4b_reg_dead(t,rest,fnItems,24),
        u => w4b_copy_peep(Con{PInst{X187Instruction{"movl",[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},fnItems,out),
        # movl %s32, %t32 ; alu32 %t32, %d32 -> alu32 %s32, %d32
        u => nt_choose(List<&2,X188Seq>,isMov32 && w4b_is_alu32_rr(op1) && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
            U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w4b_reg_dead(t,rest,fnItems,24),
          v => w4b_copy_peep(Con{PInst{X187Instruction{op1,[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},fnItems,out),
          # subl %s32, %t32 ; movl %t32, %d32 ; cmpq $0, %d64 ; jz/jnz -> drop cmpq
          v => nt_choose(List<&2,X188Seq>,agy_str_eq(op0,"subl") && agy_str_eq(op1,"movl") &&
              U32.is_eq(wt,32) && U32.is_eq(wt2,32) && U32.is_eq(wd,32) && U32.is_eq(t,t2),
            w => w4b_copy_after_sub(d,rest,i0,i1,fnItems,out),
            # movl/alu32 _, %t32 ; movl %t32, %t32 -> drop redundant zero-extend
            w => nt_choose(List<&2,X188Seq>,(isMov32 || (w4b_is_alu32_rr(op0) && U32.is_eq(wt,32))) &&
                agy_str_eq(op1,"movl") && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
                U32.is_eq(t,t2) && U32.is_eq(t,d),
              x => w4b_copy_peep(rest,fnItems,Con{X188One{i0},out}),
              x => w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})))))"""

NEW_COPY_BUDGET = """      nt_choose(List<&2,X188Seq>,isMov32 && agy_str_eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) &&
          U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w4b_reg_dead(t,rest,fnItems,36),
        u => w4b_copy_peep(Con{PInst{X187Instruction{"movl",[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},fnItems,out),
        # movl %s32, %t32 ; alu32 %t32, %d32 -> alu32 %s32, %d32
        u => nt_choose(List<&2,X188Seq>,isMov32 && w4b_is_alu32_rr(op1) && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
            U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w4b_reg_dead(t,rest,fnItems,36),
          v => w4b_copy_peep(Con{PInst{X187Instruction{op1,[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},fnItems,out),
          # comm_alu32 %d32, %t32 ; movq %t64, %d64 -> comm_alu32 %t32, %d32 (when %t is dead)
          v => nt_choose(List<&2,X188Seq>,
              (agy_str_eq(op0,"addl") || agy_str_eq(op0,"imull") || agy_str_eq(op0,"andl") || agy_str_eq(op0,"orl") || agy_str_eq(op0,"xorl")) &&
              U32.is_eq(ws,32) && U32.is_eq(wt,32) && agy_str_eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) &&
              U32.is_eq(t,t2) && U32.is_eq(s,d) && Bool.not(U32.is_eq(t,d)) && w4b_reg_dead(t,rest,fnItems,36),
            z => w4b_copy_peep(Con{PInst{X187Instruction{op0,[X187Reg{t,32,False{}},X187Reg{d,32,False{}}]}},rest},fnItems,out),
            # subl %s32, %t32 ; movl %t32, %d32 ; cmpq $0, %d64 ; jz/jnz -> drop cmpq
            z => nt_choose(List<&2,X188Seq>,agy_str_eq(op0,"subl") && agy_str_eq(op1,"movl") &&
                U32.is_eq(wt,32) && U32.is_eq(wt2,32) && U32.is_eq(wd,32) && U32.is_eq(t,t2),
              w => w4b_copy_after_sub(d,rest,i0,i1,fnItems,out),
              # movl/alu32 _, %t32 ; movl %t32, %t32 -> drop redundant zero-extend
              w => nt_choose(List<&2,X188Seq>,(isMov32 || (w4b_is_alu32_rr(op0) && U32.is_eq(wt,32))) &&
                  agy_str_eq(op1,"movl") && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
                  U32.is_eq(t,t2) && U32.is_eq(t,d),
                x => w4b_copy_peep(rest,fnItems,Con{X188One{i0},out}),
                x => nt_choose(List<&2,X188Seq>,isMov32 && agy_str_eq(op1,"movq") &&
                    U32.is_eq(wt2,64) && U32.is_eq(wd,64) && U32.is_eq(d,11),
                  y => w4c_sub_fold(s,t,t2,i0,i1,rest,fnItems,out),
                  y => w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})))))))"""


OLD_TAILDUP_ROTATE = """@unsafe
def w4b_taildup_check(revBody: List<&2,X187Parsed>, +body: List<&2,X187Parsed>, +exitLbl: String) -> List<&2,X187Parsed>:
  match revBody:
    case Con{+jne,Con{+tst,Con{+mv,Con{PLabel{+mergeLbl},_}}}}:
      nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(mergeLbl,body),
        u => w4b_taildup_replace(body,mergeLbl,mv,tst,jne,exitLbl),
        u => body)
    case _: body

@unsafe
def w4b_rotate_finish(exitSplit: W4BExitSplit, before: List<&2,X187Parsed>, +loopLbl: String,
    +bodyLbl: String, +r: U32, +w: U32, orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match exitSplit:
    case W4BExitNone{}: orig
    case W4BExitSplit{exitBlk,loopBody}:
      +exitLbl = loopLbl ++ "_exit"
      +rew = w4b_rewrite_backedges(loopBody,loopLbl,bodyLbl,exitLbl,r,w)
      +rew2 = w4b_taildup_check(nt_reverse(X187Parsed,rew,[]),rew,exitLbl)
      nt_append(X187Parsed,before,
        Con{w4b_test_inst(r,w),
          Con{PInst{X187Instruction{"je",[X187Target{exitLbl}]}},
            Con{PLabel{bodyLbl},
              nt_append(X187Parsed,rew2,
                Con{PLabel{exitLbl},exitBlk})}}})

@unsafe
def w4b_rotate_check_hdr(cm: W4BImmReg, br: W4BBranch, +before: List<&2,X187Parsed>, +loopLbl: String,
    +afterHdr: List<&2,X187Parsed>, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match cm br:
    case W4BImmReg{cmpop,lo,hi,+r,+w} W4BBranch{jop,+bodyLbl}:
      nt_choose(List<&2,X187Parsed>,
        U32.is_eq(lo,0) && U32.is_eq(hi,0) &&
        ((agy_str_eq(cmpop,"cmpq") && U32.is_eq(w,64)) || (agy_str_eq(cmpop,"cmpl") && U32.is_eq(w,32))) &&
        (agy_str_eq(jop,"jne") || agy_str_eq(jop,"jnz")),
        v => w4b_rotate_finish(w4b_take_exit_clean(afterHdr,bodyLbl,[]),before,loopLbl,bodyLbl,r,w,orig),
        v => orig)
    case _ _: orig

@unsafe
def w4b_rotate_body(+before: List<&2,X187Parsed>, +loopLbl: String, body: List<&2,X187Parsed>,
    +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match body:
    case Con{i0,Con{i1,afterHdr}}:
      w4b_rotate_check_hdr(w4b_as_imm_reg(i0),w4b_as_branch(i1),before,loopLbl,afterHdr,orig)
    case _: orig"""

NEW_TAILDUP_ROTATE = """@unsafe
def w4c_taildup_replace2(items: List<&2,X187Parsed>, +mergeLbl: String, +mv1: X187Parsed, +mv2: X187Parsed,
    +tst: X187Parsed, +jne: X187Parsed, +exitLbl: String) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: []
    case Con{+h,+rest}:
      nt_choose(List<&2,X187Parsed>,w4b_branch_is_jmp(mergeLbl,w4b_as_branch(h)),
        u => Con{mv1,Con{mv2,Con{tst,Con{jne,Con{PInst{X187Instruction{"jmp",[X187Target{exitLbl}]}},
               w4c_taildup_replace2(rest,mergeLbl,mv1,mv2,tst,jne,exitLbl)}}}}},
        u => Con{h,w4c_taildup_replace2(rest,mergeLbl,mv1,mv2,tst,jne,exitLbl)})

@unsafe
def w4b_taildup_check(revBody: List<&2,X187Parsed>, +body: List<&2,X187Parsed>, +exitLbl: String) -> List<&2,X187Parsed>:
  match revBody:
    case Con{+jne,Con{+tst,Con{+mv,Con{PLabel{+m1},Con{PLabel{+m2},_}}}}}:
      +b1 = nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m1,body),u => w4b_taildup_replace(body,m1,mv,tst,jne,exitLbl),u => body)
      nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m2,b1),u => w4b_taildup_replace(b1,m2,mv,tst,jne,exitLbl),u => b1)
    case Con{+jne,Con{+tst,Con{+mv,Con{PLabel{+mergeLbl},_}}}}:
      nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(mergeLbl,body),
        u => w4b_taildup_replace(body,mergeLbl,mv,tst,jne,exitLbl),
        u => body)
    case Con{+jne,Con{+tst,Con{+mv2,Con{+mv1,Con{PLabel{+m1},Con{PLabel{+m2},_}}}}}}:
      +b1 = nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m1,body),u => w4c_taildup_replace2(body,m1,mv1,mv2,tst,jne,exitLbl),u => body)
      nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m2,b1),u => w4c_taildup_replace2(b1,m2,mv1,mv2,tst,jne,exitLbl),u => b1)
    case Con{+jne,Con{+tst,Con{+mv2,Con{+mv1,Con{PLabel{+mergeLbl},_}}}}}:
      nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(mergeLbl,body),
        u => w4c_taildup_replace2(body,mergeLbl,mv1,mv2,tst,jne,exitLbl),
        u => body)
    case _: body

@unsafe
def w4b_rotate_finish(exitSplit: W4BExitSplit, before: List<&2,X187Parsed>, +loopLbl: String,
    +bodyLbl: String, +r: U32, +w: U32, orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match exitSplit:
    case W4BExitNone{}: orig
    case W4BExitSplit{exitBlk,loopBody}:
      +exitLbl = loopLbl ++ "_exit"
      +rew = w4b_rewrite_backedges(loopBody,loopLbl,bodyLbl,exitLbl,r,w)
      +rew2 = w4b_taildup_check(nt_reverse(X187Parsed,rew,[]),rew,exitLbl)
      nt_append(X187Parsed,before,
        Con{w4b_test_inst(r,w),
          Con{PInst{X187Instruction{"je",[X187Target{exitLbl}]}},
            Con{PLabel{bodyLbl},
              nt_append(X187Parsed,rew2,
                Con{PLabel{exitLbl},exitBlk})}}})

@unsafe
def w4c_rotate_check_test(tr: W4BRR, br: W4BBranch, +before: List<&2,X187Parsed>, +loopLbl: String,
    +afterHdr: List<&2,X187Parsed>, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match tr br:
    case W4BRR{top,+s,+ws,+d,+wd} W4BBranch{jop,+bodyLbl}:
      nt_choose(List<&2,X187Parsed>,
        U32.is_eq(s,d) && U32.is_eq(ws,wd) &&
        ((agy_str_eq(top,"testq") && U32.is_eq(ws,64)) || (agy_str_eq(top,"testl") && U32.is_eq(ws,32))) &&
        (agy_str_eq(jop,"jne") || agy_str_eq(jop,"jnz")),
        v => w4b_rotate_finish(w4b_take_exit_clean(afterHdr,bodyLbl,[]),before,loopLbl,bodyLbl,s,ws,orig),
        v => orig)
    case _ _: orig

@unsafe
def w4c_rotate_check_cmp(+cmpop: String, +lo: U32, +hi: U32, +r: U32, +w: U32,
    br: W4BBranch, +before: List<&2,X187Parsed>, +loopLbl: String,
    +afterHdr: List<&2,X187Parsed>, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match br:
    case W4BBranch{jop,+bodyLbl}:
      nt_choose(List<&2,X187Parsed>,
        U32.is_eq(lo,0) && U32.is_eq(hi,0) &&
        ((agy_str_eq(cmpop,"cmpq") && U32.is_eq(w,64)) || (agy_str_eq(cmpop,"cmpl") && U32.is_eq(w,32))) &&
        (agy_str_eq(jop,"jne") || agy_str_eq(jop,"jnz")),
        v => w4b_rotate_finish(w4b_take_exit_clean(afterHdr,bodyLbl,[]),before,loopLbl,bodyLbl,r,w,orig),
        v => orig)
    case W4BBranchNone{}: orig

@unsafe
def w4b_rotate_check_hdr(cm: W4BImmReg, br: W4BBranch, +i0: X187Parsed, +before: List<&2,X187Parsed>, +loopLbl: String,
    +afterHdr: List<&2,X187Parsed>, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match cm:
    case W4BImmReg{cmpop,lo,hi,r,w}: w4c_rotate_check_cmp(cmpop,lo,hi,r,w,br,before,loopLbl,afterHdr,orig)
    case W4BImmRegNone{}: w4c_rotate_check_test(w4b_as_rr(i0),br,before,loopLbl,afterHdr,orig)

@unsafe
def w4b_rotate_body(+before: List<&2,X187Parsed>, +loopLbl: String, body: List<&2,X187Parsed>,
    +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match body:
    case Con{+i0,Con{i1,afterHdr}}:
      w4b_rotate_check_hdr(w4b_as_imm_reg(i0),w4b_as_branch(i1),i0,before,loopLbl,afterHdr,orig)
    case _: orig"""


OLD_POST_SELECT = """  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  w4b_wrap_items(rot,[])"""

NEW_POST_SELECT = """  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  x188_finish(w4b_copy_peep(rot,rot,[]))"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    text = args.src.read_text()
    text = replace_once(text, OLD_T_IF, NEW_T_IF, "x185_t_if")
    text = replace_once(text, OLD_T_PLACE, NEW_T_PLACE, "x185_t_place")
    text = replace_once(text, OLD_DEAD_CAP, NEW_DEAD_CAP, "x185_dead_body_cap")
    text = replace_once(text, OLD_E_ALIAS_CAP, NEW_E_ALIAS_CAP, "x186_e_alias_cap")
    text = replace_once(text, OLD_E_FACT_CAP, NEW_E_FACT_CAP, "x186_e_fact_cap")
    text = replace_once(text, OLD_E_IF_AND_EXPR, NEW_E_IF_AND_EXPR, "x186_e_if_and_diamond")
    text = replace_once(text, OLD_J_COUNTED, NEW_J_COUNTED, "x190_j_counted_huge_loop")
    text = replace_once(text, OLD_REG_DEAD, NEW_REG_DEAD, "w4b_reg_dead")
    text = replace_once(text, OLD_COPY_CHECK, NEW_COPY_CHECK, "w4b_copy_check_cmp")
    text = replace_once(text, OLD_COPY_BUDGET, NEW_COPY_BUDGET, "w4b_copy_budget")
    text = replace_once(text, OLD_TAILDUP_ROTATE, NEW_TAILDUP_ROTATE, "w4b_taildup_rotate")
    text = replace_once(text, OLD_POST_SELECT, NEW_POST_SELECT, "w4_post_select")

    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(text)
    print(f"Wrote {args.dst} ({len(text)} bytes)")


if __name__ == "__main__":
    main()
