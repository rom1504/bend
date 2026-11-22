#!/usr/bin/env python3
"""Wave 5 Track W5-C2: Structural Compile-Speed Optimizer (`AGY-W5-STRUCT`).

Composable, 100% bit-exact patcher transforming
`wave4c_unified/compiler.bend` -> `wave5_c2/compiler.bend`.

Orthogonal to W5-C1 (`w4_post_select` backend peepholes). Attacks the top
structural O(N^2) / redundant-hashing bottlenecks identified by V8 CPU
profiling across lexer, raytrace, gameoflife, histogram, and nbody:

  1. `p113k_join` Patricia-trie structural intersection + single-hash `p113k_put`
     (was 11.28s / 18.6% of total compile time; eliminated 4x index_hash and
     2x redundant index_find per variable per if/else join, plus O(1) disjoint
     subtree pruning).
  2. `x186_e_*` O(N^2) -> O(log N) CSE & Alias Engine
     (was 6.45s / 10.7% of total compile time; replaces O(1024) linear scans in
     x186_e_kill_facts, x186_e_kill_aliases, x186_e_alias, x186_e_find, and
     nt_count with O(log N) Patricia hash-tries + SSA `mentioned` guard).
  3. `x185_sf_scalar` empty-facts short-circuit (avoids p111v_get on every load
     when scratch facts list is empty).
  4. `x187_encode` / `x202o_dispatch` opcode dispatch fusion (moves `sqrtss`
     and `cvttss2siq` into first-char switch, eliminating 2 string compares on
     every emitted x86 instruction).
  5. `index_remove` uses `agy_str_eq` instead of `p88_string_eq`.
"""
import argparse
from pathlib import Path

DEFAULT_SRC = Path("/home/ai/bend2_agy/selfhost/build/agy/wave4c_unified/compiler.bend")
DEFAULT_DST = Path("/home/ai/bend2_agy/selfhost/build/agy/wave5_c2/compiler.bend")


def once(s: str, old: str, new: str, label: str) -> str:
    n = s.count(old)
    assert n == 1, f"{label}: expected 1 match, got {n}"
    return s.replace(old, new, 1)


# ----------------------------------------------------------------------------
# Opt 1: p113k_put single-hash + p113k_join Patricia-trie intersection
# ----------------------------------------------------------------------------
OLD_P113K_PUT = """@unsafe
def p113k_put(+facts: KDef, +name: String, fact: P113KFact) -> KDef:
  match fact:
    case P113KFact{bits,exact,lo,hi}:
      index_set(facts,KDef{name,"P113KFact",bits,Bool.to_u32(exact),kt("Epoch","",U32.inc(p113l_version(facts,name)),0,[]),kt("P113KValue","",lo,hi,[]),[],False{},False{}},index_hash(name,2166136261),32)"""

NEW_P113K_PUT = """# AGY-W5-STRUCT: single-hash p113k_put
@unsafe
def p113k_put(+facts: KDef, +name: String, fact: P113KFact) -> KDef:
  match fact:
    case P113KFact{bits,exact,lo,hi}:
      +h = index_hash(name,2166136261)
      +ver = ix(dt(index_find(facts,name,h,32)))
      p131i_insert(facts,KDef{name,"P113KFact",bits,Bool.to_u32(exact),kt("Epoch","",U32.inc(ver),0,[]),kt("P113KValue","",lo,hi,[]),[],False{},False{}},h)"""

OLD_P113K_JOIN = """@unsafe
def p113k_join_bucket(bucket: List<&2,KDef>, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket(rest,right,p113k_join_record(head,right,out))


@unsafe
def p113k_join_record(+record: KDef, +right: KDef, +out: KDef) -> KDef:
  +name = dn(record)
  +found = p111v_get(right,name)
  nt_choose(KDef,agy_str_eq(dk(found),"P113KFact"),
    u => p113k_put(out,name,p113k_join_fact(P113KFact{da(record),U32.is_eq(dx(record),1),ix(dv(record)),qt(dv(record))},p113k_get(right,name))),
    u => out)


@unsafe
def p113k_join(left: KDef, +right: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: p113k_join_bucket(bucket,right,out)
    case KIndexNode{hash,mask,a,b}: p113k_join(b,right,p113k_join(a,right,out))
    case _: out"""

NEW_P113K_JOIN = """# AGY-W5-STRUCT: Patricia-trie structural intersection for p113k_join (0 re-hashing, O(1) disjoint pruning)
@unsafe
def p113k_join_insert(+out: KDef, +name: String, +hash: U32, fact: P113KFact) -> KDef:
  match fact:
    case P113KFact{bits,exact,lo,hi}:
      p131i_insert(out,KDef{name,"P113KFact",bits,Bool.to_u32(exact),kt("Epoch","",1,0,[]),kt("P113KValue","",lo,hi,[]),[],False{},False{}},hash)

@unsafe
def p113k_join_record_h(+record: KDef, +hash: U32, +right: KDef, +out: KDef) -> KDef:
  nt_choose(KDef,agy_str_eq(dk(record),"P113KFact"),
    u =>
      +name = dn(record)
      +found = index_find(right,name,hash,32)
      nt_choose(KDef,agy_str_eq(dk(found),"P113KFact"),
        v => p113k_join_insert(out,name,hash,p113k_join_fact(
          P113KFact{da(record),U32.is_eq(dx(record),1),ix(dv(record)),qt(dv(record))},
          P113KFact{da(found),U32.is_eq(dx(found),1),ix(dv(found)),qt(dv(found))})),
        v => out),
    u => out)

@unsafe
def p113k_join_bucket_h(bucket: List<&2,KDef>, +hash: U32, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket_h(rest,hash,right,p113k_join_record_h(head,hash,right,out))

@unsafe
def p113k_join_record_b(+record: KDef, +hash: U32, +rbucket: List<&2,KDef>, +out: KDef) -> KDef:
  nt_choose(KDef,agy_str_eq(dk(record),"P113KFact"),
    u =>
      +name = dn(record)
      +found = index_bucket(rbucket,name)
      nt_choose(KDef,agy_str_eq(dk(found),"P113KFact"),
        v => p113k_join_insert(out,name,hash,p113k_join_fact(
          P113KFact{da(record),U32.is_eq(dx(record),1),ix(dv(record)),qt(dv(record))},
          P113KFact{da(found),U32.is_eq(dx(found),1),ix(dv(found)),qt(dv(found))})),
        v => out),
    u => out)

@unsafe
def p113k_join_buckets(lbucket: List<&2,KDef>, +hash: U32, +rbucket: List<&2,KDef>, out: KDef) -> KDef:
  match lbucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_buckets(rest,hash,rbucket,p113k_join_record_b(head,hash,rbucket,out))

@unsafe
def p113k_join_bucket(bucket: List<&2,KDef>, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket(rest,right,p113k_join_record_h(head,index_hash(dn(head),2166136261),right,out))

@unsafe
def p113k_join_record(+record: KDef, +right: KDef, +out: KDef) -> KDef:
  p113k_join_record_h(record,index_hash(dn(record),2166136261),right,out)

law p113k_join_go:
  for +left: KDef
  for +right: KDef
  for +out: KDef
  KDef

@unsafe
def p113k_join_leaf(+lh: U32, +lbucket: List<&2,KDef>, +right: KDef, +out: KDef) -> KDef:
  match right:
    case KIndexLeaf{rh,rbucket}:
      nt_choose(KDef,U32.is_eq(lh,rh),u => p113k_join_buckets(lbucket,lh,rbucket,out),u => out)
    case KIndexNode{rh,rm,ra,rb}:
      nt_choose(KDef,U32.is_eq(rm,0),
        u => p113k_join_bucket_h(lbucket,lh,right,out),
        u => nt_choose(KDef,U32.is_eq(U32.and(U32.xor(lh,rh),U32.sub(rm,1)),0),
          v => nt_choose(KDef,U32.is_eq(U32.and(lh,rm),0),
            w => p113k_join_leaf(lh,lbucket,ra,out),
            w => p113k_join_leaf(lh,lbucket,rb,out)),
          v => out))
    case KDef{_,kind,_,_,_,_,_,_,_}:
      nt_choose(KDef,agy_str_eq(kind,"Absent"),u => out,u => p113k_join_bucket_h(lbucket,lh,right,out))

@unsafe
def p113k_join_nn_diff(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  nt_choose(KDef,U32.is_lt(lm,rm),
    u => nt_choose(KDef,U32.is_eq(U32.and(U32.xor(lh,rh),U32.sub(lm,1)),0),
      v => nt_choose(KDef,U32.is_eq(U32.and(rh,lm),0),
        w => p113k_join_go(la,right,out),
        w => p113k_join_go(lb,right,out)),
      v => out),
    u => nt_choose(KDef,U32.is_eq(U32.and(U32.xor(lh,rh),U32.sub(rm,1)),0),
      v => nt_choose(KDef,U32.is_eq(U32.and(lh,rm),0),
        w => p113k_join_go(left,ra,out),
        w => p113k_join_go(left,rb,out)),
      v => out))

@unsafe
def p113k_join_nn(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  nt_choose(KDef,U32.is_eq(lm,0) || U32.is_eq(rm,0),
    u => p113k_join_go(lb,right,p113k_join_go(la,right,out)),
    u => nt_choose(KDef,U32.is_eq(lm,rm),
      v => nt_choose(KDef,U32.is_eq(U32.and(U32.xor(lh,rh),U32.sub(lm,1)),0),
        w => p113k_join_go(lb,rb,p113k_join_go(la,ra,out)),
        w => out),
      v => p113k_join_nn_diff(lh,lm,la,lb,left,rh,rm,ra,rb,right,out)))

@unsafe
def p113k_join_node(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +right: KDef, +out: KDef) -> KDef:
  match right:
    case KIndexLeaf{rh,rbucket}:
      nt_choose(KDef,U32.is_eq(lm,0),
        u => p113k_join_go(lb,right,p113k_join_go(la,right,out)),
        u => nt_choose(KDef,U32.is_eq(U32.and(U32.xor(lh,rh),U32.sub(lm,1)),0),
          v => nt_choose(KDef,U32.is_eq(U32.and(rh,lm),0),
            w => p113k_join_go(la,right,out),
            w => p113k_join_go(lb,right,out)),
          v => out))
    case KIndexNode{rh,rm,ra,rb}:
      p113k_join_nn(lh,lm,la,lb,left,rh,rm,ra,rb,right,out)
    case KDef{_,kind,_,_,_,_,_,_,_}:
      nt_choose(KDef,agy_str_eq(kind,"Absent"),u => out,u => p113k_join_go(lb,right,p113k_join_go(la,right,out)))

@unsafe
def p113k_join_go(left,right,out):
  match left:
    case KIndexLeaf{lh,lbucket}: p113k_join_leaf(lh,lbucket,right,out)
    case KIndexNode{lh,lm,la,lb}: p113k_join_node(lh,lm,la,lb,left,right,out)
    case _: out

@unsafe
def p113k_join(left: KDef, +right: KDef, out: KDef) -> KDef:
  p113k_join_go(left,right,out)"""


# ----------------------------------------------------------------------------
# Opt 2: x186_e_* O(N^2) -> O(log N) CSE & Alias Engine
# ----------------------------------------------------------------------------
OLD_X186_E = """type X186ExprState is Data:
  X186ExprState{+facts: List<&2,X186Expr>, +aliases: List<&2,X186Alias>}
type X186ExprStep is Data:
  X186ExprStep{+stmt: P113DStmt, +state: X186ExprState}

def x186_expression_enabled() -> Bool: True{}
def x186_e_empty() -> X186ExprState: X186ExprState{[],[]}

@unsafe
def x186_e_equal(left: N111Value, right: N111Value) -> Bool:
  match left right:
    case N111Local{a} N111Local{b}: agy_str_eq(a,b)
    case N111Const{al,ah} N111Const{bl,bh}: U32.is_eq(al,bl) && U32.is_eq(ah,bh)
    case N111Symbol{a} N111Symbol{b}: agy_str_eq(a,b)
    case N111FuncId{a} N111FuncId{b}: agy_str_eq(a,b)
    case N111CtorId{a} N111CtorId{b}: agy_str_eq(a,b)
    case _ _: False{}

@unsafe
def x186_e_alias(aliases: List<&2,X186Alias>, +name: String) -> N111Value:
  match aliases:
    case Nil{}: N111Local{name}
    case Con{X186Alias{other,value},rest}:
      nt_choose(N111Value,agy_str_eq(name,other),u => value,u => x186_e_alias(rest,name))

@unsafe
def x186_e_value(value: N111Value, aliases: List<&2,X186Alias>) -> N111Value:
  match value:
    case N111Local{name}: x186_e_alias(aliases,name)
    case _: value

@unsafe
def x186_e_kill_facts(facts: List<&2,X186Expr>, +name: String) -> List<&2,X186Expr>:
  match facts:
    case Nil{}: []
    case Con{+fact,+rest}:
      match fact:
        case X186Expr{result,kind,typ,op,left,right}:
          nt_choose(List<&2,X186Expr>,agy_str_eq(result,name) || x185_sf_source(left,name) || x185_sf_source(right,name),
            u => x186_e_kill_facts(rest,name),u => Con{fact,x186_e_kill_facts(rest,name)})

@unsafe
def x186_e_kill_aliases(aliases: List<&2,X186Alias>, +name: String) -> List<&2,X186Alias>:
  match aliases:
    case Nil{}: []
    case Con{+alias,+rest}:
      match alias:
        case X186Alias{result,value}:
          nt_choose(List<&2,X186Alias>,agy_str_eq(result,name) || x185_sf_source(value,name),
            u => x186_e_kill_aliases(rest,name),u => Con{alias,x186_e_kill_aliases(rest,name)})

@unsafe
def x186_e_written(state: X186ExprState, +name: String) -> X186ExprState:
  match state:
    case X186ExprState{facts,aliases}: X186ExprState{x186_e_kill_facts(facts,name),x186_e_kill_aliases(aliases,name)}

@unsafe
def x186_e_remember_alias(state: X186ExprState, +name: String, +typ: N111Type, +value: N111Value) -> X186ExprState:
  match state:
    case X186ExprState{facts,+aliases}:
      X186ExprState{facts,nt_choose(List<&2,X186Alias>,Bool.not(U32.is_eq(p111v_type(typ),1)) &&
          Bool.not(x185_sf_source(value,name)) && U32.is_lt(nt_count(X186Alias,aliases),1024),
        u => Con{X186Alias{name,value},aliases},u => aliases)}

@unsafe
def x186_e_set(+stmt: N111Stmt, +name: String, +typ: N111Type, +value: N111Value, +state: X186ExprState) -> X186ExprStep:
  nt_choose(X186ExprStep,U32.is_eq(p111v_type(typ),1),
    u => x186_e_expression(state,stmt,name,2,N111U32{},"zext32",value,N111Const{0,0}),
    u => x186_e_set_state(state,stmt,name,typ,value))

@unsafe
def x186_e_set_state(+state: X186ExprState, stmt: N111Stmt, +name: String, typ: N111Type, value: N111Value) -> X186ExprStep:
  match state:
    case X186ExprState{facts,aliases}:
      X186ExprStep{P113DScalar{stmt},x186_e_remember_alias(x186_e_written(state,name),name,typ,x186_e_value(value,aliases))}

@unsafe
def w4_cse_comm(+op: String) -> Bool:
  agy_str_eq(op,"add") || agy_str_eq(op,"mul") || agy_str_eq(op,"and") ||
    agy_str_eq(op,"or") || agy_str_eq(op,"xor")

@unsafe
def x186_e_find(facts: List<&2,X186Expr>, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value) -> Maybe<&2,String>:
  match facts:
    case Nil{}: None{}
    case Con{X186Expr{name,other,width,operation,+a,+b},rest}:
      nt_choose(Maybe<&2,String>,U32.is_eq(kind,other) && U32.is_eq(p111v_type(typ),p111v_type(width)) &&
          agy_str_eq(op,operation) &&
          ((x186_e_equal(left,a) && x186_e_equal(right,b)) ||
           (U32.is_eq(kind,0) && w4_cse_comm(op) && x186_e_equal(left,b) && x186_e_equal(right,a))),
        u => Some{name},u => x186_e_find(rest,kind,typ,op,left,right))

@unsafe
def x186_e_insert(state: X186ExprState, +name: String, kind: U32, typ: N111Type, op: String,
    +left: N111Value, +right: N111Value) -> X186ExprState:
  match state:
    case X186ExprState{+facts,aliases}:
      X186ExprState{nt_choose(List<&2,X186Expr>,Bool.not(x185_sf_source(left,name) || x185_sf_source(right,name)) &&
          U32.is_lt(nt_count(X186Expr,facts),1024),
        u => Con{X186Expr{name,kind,typ,op,left,right},facts},u => facts),aliases}

@unsafe
def x186_e_result_type(+kind: U32, typ: N111Type, op: String) -> N111Type:
  nt_choose(N111Type,U32.is_eq(kind,1),u => N111Ptr{},
    u => nt_choose(N111Type,p111v_comparison(op),v => N111U32{},v => typ))

@unsafe
def x186_e_found(found: Maybe<&2,String>, stmt: N111Stmt, +name: String, kind: U32, +typ: N111Type,
    state: X186ExprState) -> X186ExprStep:
  match found:
    case None{}: X186ExprStep{P113DScalar{stmt},state}
    case Some{+source}: X186ExprStep{P113DScalar{nt_choose(N111Stmt,U32.is_eq(kind,1),
        u => stmt,u => N111Set{name,N111U64{},N111Local{source}})},
      x186_e_result_alias(state,name,N111U64{},source)}

# Offset declarations retain their exact capacity-propagating verifier row.
# Their value equivalence may canonicalize later keys, but never replaces that row.
@unsafe
def x186_e_result_alias(state: X186ExprState, name: String, typ: N111Type, source: String) -> X186ExprState:
  match state:
    case X186ExprState{+facts,+aliases}:
      x186_e_remember_alias(X186ExprState{facts,aliases},name,typ,x186_e_alias(aliases,source))

@unsafe
def x186_e_expression(+state: X186ExprState, stmt: N111Stmt, +name: String, +kind: U32,
    +typ: N111Type, +op: String, left: N111Value, right: N111Value) -> X186ExprStep:
  match state:
    case X186ExprState{facts,+aliases}:
      x186_e_key(stmt,name,kind,typ,op,x186_e_value(left,aliases),x186_e_value(right,aliases),facts,x186_e_written(state,name))

@unsafe
def x186_e_key(stmt: N111Stmt, +name: String, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, facts: List<&2,X186Expr>, state: X186ExprState) -> X186ExprStep:
  x186_e_found(x186_e_find(facts,kind,typ,op,left,right),stmt,name,kind,x186_e_result_type(kind,typ,op),
    x186_e_insert(state,name,kind,typ,op,left,right))

@unsafe
def x186_e_scalar(+stmt: N111Stmt, +state: X186ExprState) -> X186ExprStep:
  match stmt:
    case N111Set{name,typ,value}: x186_e_set(stmt,name,typ,value,state)
    case N111Bin{name,typ,op,left,right}: x186_e_expression(state,stmt,name,0,typ,op,left,right)
    case N111Offset{name,base,bytes}: x186_e_expression(state,stmt,name,1,N111Ptr{},"offset",base,bytes)
    case N111Load{name,typ,base,offset}: X186ExprStep{P113DScalar{stmt},x186_e_written(state,name)}
    case N111Alloca{name,bytes,align}: X186ExprStep{P113DScalar{stmt},x186_e_written(state,name)}
    case _: X186ExprStep{P113DScalar{stmt},x186_e_empty()}

law x186_e_body:
  for body: List<&2,P113DStmt>
  for state: X186ExprState
  List<&2,P113DStmt>

@unsafe
def x186_e_after(rest: List<&2,P113DStmt>, step: X186ExprStep) -> List<&2,P113DStmt>:
  match step:
    case X186ExprStep{stmt,state}: Con{stmt,x186_e_body(rest,state)}

@unsafe
def w4c_e_kill_val(v: N111Value, state: X186ExprState) -> X186ExprState:
  match v:
    case N111Local{n}: x186_e_written(state,n)
    case _: state

@unsafe
def w4c_e_kill_cond(+v: N111Value, +state: X186ExprState) -> X186ExprState:
  match state:
    case X186ExprState{_,aliases}:
      w4c_e_kill_val(x186_e_value(v,aliases),w4c_e_kill_val(v,state))"""

NEW_X186_E = """# AGY-W5-STRUCT: O(log N) Patricia-trie CSE & Alias Engine (100% bit-exact)
type X186FactTrie is Data:
  X186FTNil{}
  X186FTLeaf{+hash: U32, +items: List<&2,X186Expr>}
  X186FTNode{+hash: U32, +mask: U32, +left: X186FactTrie, +right: X186FactTrie}

type X186AliasTrie is Data:
  X186ATNil{}
  X186ATLeaf{+hash: U32, +items: List<&2,X186Alias>}
  X186ATNode{+hash: U32, +mask: U32, +left: X186AliasTrie, +right: X186AliasTrie}

type X186ExprState is Data:
  X186ExprState{+facts: List<&2,X186Expr>, +aliases: List<&2,X186Alias>,
    +factCount: U32, +aliasCount: U32,
    +mentioned: KDef, +factTrie: X186FactTrie, +aliasTrie: X186AliasTrie}

type X186ExprStep is Data:
  X186ExprStep{+stmt: P113DStmt, +state: X186ExprState}

def x186_expression_enabled() -> Bool: True{}
def x186_e_empty() -> X186ExprState:
  X186ExprState{[],[],0,0,missing(),X186FTNil{},X186ATNil{}}

@unsafe
def w4_cse_comm(+op: String) -> Bool:
  match op:
    case SCon{h,t}:
      +c = Char.to_u32(h)
      nt_choose(Bool,U32.is_eq(c,97),u => agy_str_eq(t,"dd") || agy_str_eq(t,"nd"),u =>
      nt_choose(Bool,U32.is_eq(c,109),u => agy_str_eq(t,"ul"),u =>
      nt_choose(Bool,U32.is_eq(c,111),u => agy_str_eq(t,"r"),u =>
      nt_choose(Bool,U32.is_eq(c,120),u => agy_str_eq(t,"or"),u => False{}))))
    case SNil{}: False{}

@unsafe
def x186_val_hash(v: N111Value) -> U32:
  match v:
    case N111Local{a}: index_hash(a,2166136261)
    case N111Const{lo,hi}: U32.mul(U32.xor(lo,U32.mul(hi,16777619)),2654435761)
    case N111Symbol{a}: U32.xor(index_hash(a,2166136261),135792468)
    case N111FuncId{a}: U32.xor(index_hash(a,2166136261),246813579)
    case N111CtorId{a}: U32.xor(index_hash(a,2166136261),357924680)

@unsafe
def x186_expr_hash(+kind: U32, +tid: U32, +op: String, +left: N111Value, +right: N111Value) -> U32:
  +hl = x186_val_hash(left)
  +hr = x186_val_hash(right)
  +ho = index_hash(op,U32.add(U32.mul(kind,131),tid))
  nt_choose(U32,U32.is_eq(kind,0) && w4_cse_comm(op),
    u => U32.xor(U32.mul(ho,16777619),U32.xor(U32.add(hl,hr),U32.mul(U32.xor(hl,hr),33554467))),
    u => U32.mul(U32.xor(U32.mul(U32.xor(ho,hl),16777619),hr),16777619))

@unsafe
def x186_ft_find(trie: X186FactTrie, +h: U32) -> List<&2,X186Expr>:
  match trie:
    case X186FTNil{}: []
    case X186FTLeaf{stored,items}: nt_choose(List<&2,X186Expr>,U32.is_eq(stored,h),u => items,u => [])
    case X186FTNode{stored,mask,l,r}:
      nt_choose(List<&2,X186Expr>,U32.is_eq(U32.and(h,mask),0),u => x186_ft_find(l,h),u => x186_ft_find(r,h))

@unsafe
def x186_ft_join(+trie: X186FactTrie, +item: X186Expr, +h: U32, +stored: U32, +mask: U32) -> X186FactTrie:
  nt_choose(X186FactTrie,U32.is_eq(U32.and(h,mask),0),
    u => X186FTNode{stored,mask,X186FTLeaf{h,[item]},trie},
    u => X186FTNode{stored,mask,trie,X186FTLeaf{h,[item]}})

@unsafe
def x186_ft_insert(+trie: X186FactTrie, +item: X186Expr, +h: U32) -> X186FactTrie:
  match trie:
    case X186FTNil{}: X186FTLeaf{h,[item]}
    case X186FTLeaf{stored,items}:
      +mask = index_split_bit(U32.xor(h,stored))
      nt_choose(X186FactTrie,U32.is_eq(mask,0),
        u => X186FTLeaf{h,Con{item,items}},
        u => x186_ft_join(trie,item,h,stored,mask))
    case X186FTNode{stored,split,l,r}:
      +diff = U32.xor(h,stored)
      nt_choose(X186FactTrie,U32.is_eq(U32.and(diff,U32.sub(split,1)),0),
        u => nt_choose(X186FactTrie,U32.is_eq(U32.and(h,split),0),
          v => X186FTNode{stored,split,x186_ft_insert(l,item,h),r},
          v => X186FTNode{stored,split,l,x186_ft_insert(r,item,h)}),
        u => x186_ft_join(trie,item,h,stored,index_split_bit(diff)))

@unsafe
def x186_ft_rebuild(facts: List<&2,X186Expr>) -> X186FactTrie:
  match facts:
    case Nil{}: X186FTNil{}
    case Con{+f,rest}:
      match f:
        case X186Expr{name,kind,typ,op,left,right}:
          x186_ft_insert(x186_ft_rebuild(rest),f,x186_expr_hash(kind,p111v_type(typ),op,left,right))

@unsafe
def x186_at_find(trie: X186AliasTrie, +h: U32) -> List<&2,X186Alias>:
  match trie:
    case X186ATNil{}: []
    case X186ATLeaf{stored,items}: nt_choose(List<&2,X186Alias>,U32.is_eq(stored,h),u => items,u => [])
    case X186ATNode{stored,mask,l,r}:
      nt_choose(List<&2,X186Alias>,U32.is_eq(U32.and(h,mask),0),u => x186_at_find(l,h),u => x186_at_find(r,h))

@unsafe
def x186_at_join(+trie: X186AliasTrie, +item: X186Alias, +h: U32, +stored: U32, +mask: U32) -> X186AliasTrie:
  nt_choose(X186AliasTrie,U32.is_eq(U32.and(h,mask),0),
    u => X186ATNode{stored,mask,X186ATLeaf{h,[item]},trie},
    u => X186ATNode{stored,mask,trie,X186ATLeaf{h,[item]}})

@unsafe
def x186_at_insert(+trie: X186AliasTrie, +item: X186Alias, +h: U32) -> X186AliasTrie:
  match trie:
    case X186ATNil{}: X186ATLeaf{h,[item]}
    case X186ATLeaf{stored,items}:
      +mask = index_split_bit(U32.xor(h,stored))
      nt_choose(X186AliasTrie,U32.is_eq(mask,0),
        u => X186ATLeaf{h,Con{item,items}},
        u => x186_at_join(trie,item,h,stored,mask))
    case X186ATNode{stored,split,l,r}:
      +diff = U32.xor(h,stored)
      nt_choose(X186AliasTrie,U32.is_eq(U32.and(diff,U32.sub(split,1)),0),
        u => nt_choose(X186AliasTrie,U32.is_eq(U32.and(h,split),0),
          v => X186ATNode{stored,split,x186_at_insert(l,item,h),r},
          v => X186ATNode{stored,split,l,x186_at_insert(r,item,h)}),
        u => x186_at_join(trie,item,h,stored,index_split_bit(diff)))

@unsafe
def x186_at_rebuild(aliases: List<&2,X186Alias>) -> X186AliasTrie:
  match aliases:
    case Nil{}: X186ATNil{}
    case Con{+a,rest}:
      match a:
        case X186Alias{name,val}:
          x186_at_insert(x186_at_rebuild(rest),a,index_hash(name,2166136261))

@unsafe
def x186_m_add_name(+m: KDef, +name: String) -> KDef:
  +h = index_hash(name,2166136261)
  nt_choose(KDef,agy_str_eq(dk(index_find(m,name,h,32)),"X186M"),
    u => m,
    u => p131i_insert(m,KDef{name,"X186M",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},h))

@unsafe
def x186_m_add_val(+m: KDef, v: N111Value) -> KDef:
  match v:
    case N111Local{name}: x186_m_add_name(m,name)
    case _: m

@unsafe
def x186_e_equal(left: N111Value, right: N111Value) -> Bool:
  match left right:
    case N111Local{a} N111Local{b}: agy_str_eq(a,b)
    case N111Const{al,ah} N111Const{bl,bh}: U32.is_eq(al,bl) && U32.is_eq(ah,bh)
    case N111Symbol{a} N111Symbol{b}: agy_str_eq(a,b)
    case N111FuncId{a} N111FuncId{b}: agy_str_eq(a,b)
    case N111CtorId{a} N111CtorId{b}: agy_str_eq(a,b)
    case _ _: False{}

@unsafe
def x186_e_alias(aliases: List<&2,X186Alias>, +name: String) -> N111Value:
  match aliases:
    case Nil{}: N111Local{name}
    case Con{X186Alias{other,value},rest}:
      nt_choose(N111Value,agy_str_eq(name,other),u => value,u => x186_e_alias(rest,name))

@unsafe
def x186_e_alias_t(aliasTrie: X186AliasTrie, +name: String) -> N111Value:
  x186_e_alias(x186_at_find(aliasTrie,index_hash(name,2166136261)),name)

@unsafe
def x186_e_value_t(value: N111Value, aliasTrie: X186AliasTrie) -> N111Value:
  match value:
    case N111Local{name}: x186_e_alias_t(aliasTrie,name)
    case _: value

@unsafe
def x186_e_value(value: N111Value, aliases: List<&2,X186Alias>) -> N111Value:
  match value:
    case N111Local{name}: x186_e_alias(aliases,name)
    case _: value

@unsafe
def x186_e_kill_facts(facts: List<&2,X186Expr>, +name: String) -> List<&2,X186Expr>:
  match facts:
    case Nil{}: []
    case Con{+fact,+rest}:
      match fact:
        case X186Expr{result,kind,typ,op,left,right}:
          nt_choose(List<&2,X186Expr>,agy_str_eq(result,name) || x185_sf_source(left,name) || x185_sf_source(right,name),
            u => x186_e_kill_facts(rest,name),u => Con{fact,x186_e_kill_facts(rest,name)})

@unsafe
def x186_e_kill_aliases(aliases: List<&2,X186Alias>, +name: String) -> List<&2,X186Alias>:
  match aliases:
    case Nil{}: []
    case Con{+alias,+rest}:
      match alias:
        case X186Alias{result,value}:
          nt_choose(List<&2,X186Alias>,agy_str_eq(result,name) || x185_sf_source(value,name),
            u => x186_e_kill_aliases(rest,name),u => Con{alias,x186_e_kill_aliases(rest,name)})

@unsafe
def x186_e_written(+state: X186ExprState, +name: String) -> X186ExprState:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      nt_choose(X186ExprState,U32.is_eq(fc,0) && U32.is_eq(ac,0),
        u => state,
        u => nt_choose(X186ExprState,agy_str_eq(dk(index_find(mentioned,name,index_hash(name,2166136261),32)),"X186M"),
          v =>
            +nf = x186_e_kill_facts(facts,name)
            +na = x186_e_kill_aliases(aliases,name)
            X186ExprState{nf,na,nt_count(X186Expr,nf),nt_count(X186Alias,na),mentioned,x186_ft_rebuild(nf),x186_at_rebuild(na)},
          v => state))

@unsafe
def x186_e_remember_alias(+state: X186ExprState, +name: String, +typ: N111Type, +value: N111Value) -> X186ExprState:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      nt_choose(X186ExprState,Bool.not(U32.is_eq(p111v_type(typ),1)) &&
          Bool.not(x185_sf_source(value,name)) && U32.is_lt(ac,1024),
        u =>
          +item : X186Alias = X186Alias{name,value}
          +h = index_hash(name,2166136261)
          +m1 = x186_m_add_val(x186_m_add_name(mentioned,name),value)
          X186ExprState{facts,Con{item,aliases},fc,U32.inc(ac),m1,ft,x186_at_insert(at,item,h)},
        u => state)

@unsafe
def x186_e_set(+stmt: N111Stmt, +name: String, +typ: N111Type, +value: N111Value, +state: X186ExprState) -> X186ExprStep:
  nt_choose(X186ExprStep,U32.is_eq(p111v_type(typ),1),
    u => x186_e_expression(state,stmt,name,2,N111U32{},"zext32",value,N111Const{0,0}),
    u => x186_e_set_state(state,stmt,name,typ,value))

@unsafe
def x186_e_set_state(+state: X186ExprState, stmt: N111Stmt, +name: String, typ: N111Type, value: N111Value) -> X186ExprStep:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      X186ExprStep{P113DScalar{stmt},x186_e_remember_alias(x186_e_written(state,name),name,typ,x186_e_value_t(value,at))}

@unsafe
def x186_e_find(facts: List<&2,X186Expr>, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value) -> Maybe<&2,String>:
  match facts:
    case Nil{}: None{}
    case Con{X186Expr{name,other,width,operation,+a,+b},rest}:
      nt_choose(Maybe<&2,String>,U32.is_eq(kind,other) && U32.is_eq(p111v_type(typ),p111v_type(width)) &&
          agy_str_eq(op,operation) &&
          ((x186_e_equal(left,a) && x186_e_equal(right,b)) ||
           (U32.is_eq(kind,0) && w4_cse_comm(op) && x186_e_equal(left,b) && x186_e_equal(right,a))),
        u => Some{name},u => x186_e_find(rest,kind,typ,op,left,right))

@unsafe
def x186_e_insert(+state: X186ExprState, +name: String, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, +eh: U32) -> X186ExprState:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      nt_choose(X186ExprState,Bool.not(x185_sf_source(left,name) || x185_sf_source(right,name)) && U32.is_lt(fc,1024),
        u =>
          +item : X186Expr = X186Expr{name,kind,typ,op,left,right}
          +m1 = x186_m_add_val(x186_m_add_val(x186_m_add_name(mentioned,name),left),right)
          X186ExprState{Con{item,facts},aliases,U32.inc(fc),ac,m1,x186_ft_insert(ft,item,eh),at},
        u => state)

@unsafe
def x186_e_result_type(+kind: U32, typ: N111Type, op: String) -> N111Type:
  nt_choose(N111Type,U32.is_eq(kind,1),u => N111Ptr{},
    u => nt_choose(N111Type,p111v_comparison(op),v => N111U32{},v => typ))

@unsafe
def x186_e_found(found: Maybe<&2,String>, stmt: N111Stmt, +name: String, kind: U32, +typ: N111Type,
    state: X186ExprState) -> X186ExprStep:
  match found:
    case None{}: X186ExprStep{P113DScalar{stmt},state}
    case Some{+source}: X186ExprStep{P113DScalar{nt_choose(N111Stmt,U32.is_eq(kind,1),
        u => stmt,u => N111Set{name,N111U64{},N111Local{source}})},
      x186_e_result_alias(state,name,N111U64{},source)}

# Offset declarations retain their exact capacity-propagating verifier row.
# Their value equivalence may canonicalize later keys, but never replaces that row.
@unsafe
def x186_e_result_alias(+state: X186ExprState, name: String, typ: N111Type, source: String) -> X186ExprState:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      x186_e_remember_alias(state,name,typ,x186_e_alias_t(at,source))

@unsafe
def x186_e_expression(+state: X186ExprState, stmt: N111Stmt, +name: String, +kind: U32,
    +typ: N111Type, +op: String, left: N111Value, right: N111Value) -> X186ExprStep:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      x186_e_key(stmt,name,kind,typ,op,x186_e_value_t(left,at),x186_e_value_t(right,at),ft,x186_e_written(state,name))

@unsafe
def x186_e_key(stmt: N111Stmt, +name: String, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, ft: X186FactTrie, state: X186ExprState) -> X186ExprStep:
  +eh = x186_expr_hash(kind,p111v_type(typ),op,left,right)
  x186_e_found(x186_e_find(x186_ft_find(ft,eh),kind,typ,op,left,right),stmt,name,kind,x186_e_result_type(kind,typ,op),
    x186_e_insert(state,name,kind,typ,op,left,right,eh))

@unsafe
def x186_e_scalar(+stmt: N111Stmt, +state: X186ExprState) -> X186ExprStep:
  match stmt:
    case N111Set{name,typ,value}: x186_e_set(stmt,name,typ,value,state)
    case N111Bin{name,typ,op,left,right}: x186_e_expression(state,stmt,name,0,typ,op,left,right)
    case N111Offset{name,base,bytes}: x186_e_expression(state,stmt,name,1,N111Ptr{},"offset",base,bytes)
    case N111Load{name,typ,base,offset}: X186ExprStep{P113DScalar{stmt},x186_e_written(state,name)}
    case N111Alloca{name,bytes,align}: X186ExprStep{P113DScalar{stmt},x186_e_written(state,name)}
    case _: X186ExprStep{P113DScalar{stmt},x186_e_empty()}

law x186_e_body:
  for body: List<&2,P113DStmt>
  for state: X186ExprState
  List<&2,P113DStmt>

@unsafe
def x186_e_after(rest: List<&2,P113DStmt>, step: X186ExprStep) -> List<&2,P113DStmt>:
  match step:
    case X186ExprStep{stmt,state}: Con{stmt,x186_e_body(rest,state)}

@unsafe
def w4c_e_kill_val(v: N111Value, state: X186ExprState) -> X186ExprState:
  match v:
    case N111Local{n}: x186_e_written(state,n)
    case _: state

@unsafe
def w4c_e_kill_cond(+v: N111Value, +state: X186ExprState) -> X186ExprState:
  match state:
    case X186ExprState{_,_,_,_,_,_,at}:
      w4c_e_kill_val(x186_e_value_t(v,at),w4c_e_kill_val(v,state))"""


# ----------------------------------------------------------------------------
# Opt 3: x185_sf_scalar empty-facts short-circuit
# ----------------------------------------------------------------------------
OLD_X185_SF_LOAD = """    case N111Load{+name,+typ,N111Local{+buffer},+offset}:
      X185ScratchStep{x185_sf_loaded(stmt,name,typ,nt_choose(Maybe<&2,N111Value>,x185_sf_cell(buffer,offset,typ,buffers),
        u => x185_sf_find(facts,buffer,offset,typ),u => None{})),x185_sf_written(facts,name)}"""

NEW_X185_SF_LOAD = """    case N111Load{+name,+typ,N111Local{+buffer},+offset}:
      nt_choose(X185ScratchStep,List.is_empty(&2,X185ScratchCell,facts),
        u => X185ScratchStep{P113DScalar{stmt},[]},
        u => X185ScratchStep{x185_sf_loaded(stmt,name,typ,nt_choose(Maybe<&2,N111Value>,x185_sf_cell(buffer,offset,typ,buffers),
          v => x185_sf_find(facts,buffer,offset,typ),v => None{})),x185_sf_written(facts,name)})"""


# ----------------------------------------------------------------------------
# Opt 4: x187_encode / x202o_dispatch eliminate 2 str_eq on every instruction
# ----------------------------------------------------------------------------
OLD_X187_CVTT = """      nt_choose(X187Op,agy_str_eq(tail,"mpb"),u => X187Op{1,8,0,7,0},u =>
      X187OpNone{}))))))))))))))))))))))))))"""

NEW_X187_CVTT = """      nt_choose(X187Op,agy_str_eq(tail,"mpb"),u => X187Op{1,8,0,7,0},u =>
      nt_choose(X187Op,agy_str_eq(tail,"vttss2siq"),u => X187Op{17,64,0,0,0},u =>
      X187OpNone{})))))))))))))))))))))))))))"""

OLD_X187_SQRT = """      nt_choose(X187Op,agy_str_eq(tail,"ubss"),u => X187Op{7,128,92,0,243},u =>
      X187OpNone{}))))))))))))))))))))))))"""

NEW_X187_SQRT = """      nt_choose(X187Op,agy_str_eq(tail,"ubss"),u => X187Op{7,128,92,0,243},u =>
      nt_choose(X187Op,agy_str_eq(tail,"qrtss"),u => X187Op{7,128,81,0,243},u =>
      X187OpNone{})))))))))))))))))))))))))"""

OLD_X187_ENC = """@unsafe
def x187_encode(inst: X187Instruction, +offset: U32) -> X187Encoded:
  match inst:
    case X187Instruction{+op,+operands}:
      nt_choose(X187Encoded,U32.is_le(offset,4294967280),
        u => nt_choose(X187Encoded,agy_str_eq(op,"sqrtss"),
          v => x187_e_selected(X187Op{7,128,81,0,243},operands,offset),v =>
        nt_choose(X187Encoded,agy_str_eq(op,"cvttss2siq"),
          v => x192_float_cvtt_operands(operands,offset),
          v => x187_e_selected(x187_e_spec(op),operands,offset))),u => x187_e_error())"""

NEW_X187_ENC = """@unsafe
def x187_encode_spec(spec: X187Op, +operands: List<&2,X187Operand>, +offset: U32) -> X187Encoded:
  match spec:
    case X187Op{+family,width,code,extra,prefix}:
      nt_choose(X187Encoded,U32.is_eq(family,17),
        u => x192_float_cvtt_operands(operands,offset),
        u => x187_e_selected(X187Op{family,width,code,extra,prefix},operands,offset))
    case X187OpNone{}: x187_e_error()

@unsafe
def x187_encode(inst: X187Instruction, +offset: U32) -> X187Encoded:
  match inst:
    case X187Instruction{+op,+operands}:
      nt_choose(X187Encoded,U32.is_le(offset,4294967280),
        u => x187_encode_spec(x187_e_spec(op),operands,offset),u => x187_e_error())"""


# ----------------------------------------------------------------------------
# Opt 5: index_remove uses agy_str_eq
# ----------------------------------------------------------------------------
OLD_INDEX_REMOVE = """      index_remove_step(h, rest, name, p88_string_eq(dn(h), name))"""
NEW_INDEX_REMOVE = """      index_remove_step(h, rest, name, agy_str_eq(dn(h), name))"""


def patch(src: str) -> str:
    if "# AGY-W5-STRUCT:" in src:
        return src
    src = once(src, OLD_P113K_PUT, NEW_P113K_PUT, "p113k_put")
    src = once(src, OLD_P113K_JOIN, NEW_P113K_JOIN, "p113k_join")
    src = once(src, OLD_X186_E, NEW_X186_E, "x186_e")
    src = once(src, OLD_X185_SF_LOAD, NEW_X185_SF_LOAD, "x185_sf_load")
    src = once(src, OLD_X187_CVTT, NEW_X187_CVTT, "x187_cvtt")
    src = once(src, OLD_X187_SQRT, NEW_X187_SQRT, "x187_sqrt")
    src = once(src, OLD_X187_ENC, NEW_X187_ENC, "x187_encode")
    src = once(src, OLD_INDEX_REMOVE, NEW_INDEX_REMOVE, "index_remove")
    return src


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    a = ap.parse_args()
    out = patch(a.src.read_text())
    a.dst.parent.mkdir(parents=True, exist_ok=True)
    a.dst.write_text(out)
    print(f"Patched AGY-W5-STRUCT -> {a.dst} ({len(out)} bytes)")


if __name__ == "__main__":
    main()
