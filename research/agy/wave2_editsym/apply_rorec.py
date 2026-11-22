#!/usr/bin/env python3
"""Standalone composable patcher on top of unified/compiler.bend:
AGY-W2-ROREC: Borrowed Native-Recursion Fast Path for Read-Only ADT->U32 Evaluators/Folds.

General, sound compiler optimization:
1. At KTerm annotation time (x198pw_annotate), scans scope Defs of arity 1 (T -> U32)
   or arity 2 (T -> U32 -> U32) where T is a non-indexed, non-erased 0-param ADT.
2. Certifies that the body is a total match on arg 0 (T) where every constructor arm
   has arity <= 2 (fields typed U32 or T) and its body is a pure U32 expression built
   from U32 literals, the optional U32 parameter x, U32 fields of the matched ctor,
   recursive self-calls on T-typed fields (passing x unchanged), and pure U32 binary
   primitives (add, sub, mul, xor, and, or).
3. At x86 emit time (x198pw_worker), wraps certified p114r_ workers with a native x86
   recursive fast path:
   - On entry, if mode != 0 or depth != 0 -> jmp slow (original p114r_ worker).
   - If arg 0 is nullary (tag 0x01) -> run native helper directly (no refcount).
   - If arg 0 is RFC-shared (tag 0x82) with rc >= 2 -> run pure read-only native
     recursion (budget=256; handles both 0x02 direct and 0x82 RFC sub-nodes without
     allocating or mutating any child refcounts). Only on success (bail==0),
     decrements root rc by 1 and returns U32. On bail (depth limit / unexpected tag),
     zero heap mutation occurred -> jmp slow.
   - Otherwise (unique 0x02 or rc == 1) -> jmp slow to free cleanly.
"""
import sys
from pathlib import Path

ROREC_BEND = r'''
# ============================================================================
# AGY-W2-ROREC: Borrowed Native-Recursion Fast Path for Read-Only ADT->U32
# ============================================================================

# Compact expression encoding in KTerm:
#   kt("RoConst", "", val, 0, [])
#   kt("RoParamX", "", 0, 0, [])
#   kt("RoField", "", field_idx, 0, [])
#   kt("RoRec", "", field_idx, 0, [])
#   kt("RoBin", op, 0, 0, [left, right])
# Case encoding in KTerm:
#   kt("RoCase", ctor_identity, ctor_arity, 0, [expr])
# Plan stored in N111Ids fs under "$agy.rorec/" ++ "$direct." ++ owner:
#   KDef{key, "AgyRoRecCertified", arity, 0, kt("RoCases", "", 0, 0, cases), kt("None", "", 0, 0, []), [], False{}, False{}}

def agy_ro_key(owner: String) -> String:
  "$agy.rorec/" ++ owner

def agy_ro_ty(+t: KTerm, +name: String) -> Bool:
  +u = nc_unann(t)
  (String.eq(tg(u),"Ref") || String.eq(tg(u),"ADT")) && String.eq(nm(u),name) && List.is_empty(&2,KTerm,ks(u))

@unsafe
def agy_ro_ctor_fields(+t: KTerm, +adt: String, +acc: List<&2,U32>) -> Maybe<&2,List<&2,U32>>:
  # Returns field kinds (1 = U32, 2 = ADT) in reverse order, or None if unsupported
  +u = nc_unann(t)
  nt_choose(Maybe<&2,List<&2,U32>>,String.eq(tg(u),"All") && U32.is_gt(qt(u),0) && U32.is_eq(terms_len(ks(u)),2),
    v => nt_choose(Maybe<&2,List<&2,U32>>,agy_ro_ty(kid(u,0),"U32"),
      w => agy_ro_ctor_fields(kid(u,1),adt,Con{1,acc}),
      w => nt_choose(Maybe<&2,List<&2,U32>>,agy_ro_ty(kid(u,0),adt),
        z => agy_ro_ctor_fields(kid(u,1),adt,Con{2,acc}),
        z => None{})),
    v => nt_choose(Maybe<&2,List<&2,U32>>,agy_ro_ty(u,adt),
      w => Some{acc},
      w => None{}))

def agy_ro_rev_u32(xs: List<&2,U32>, acc: List<&2,U32>) -> List<&2,U32>:
  match xs:
    case Nil{}: acc
    case Con{h,t}: agy_ro_rev_u32(t,Con{h,acc})

@unsafe
def agy_ro_find_ctor(cs: List<&2,KDef>, +name: String) -> KDef:
  match cs:
    case Nil{}: missing()
    case Con{+c,rest}:
      nt_choose(KDef,String.eq(dk(c),"Ctr") && String.eq(dn(c),name),u => c,u => agy_ro_find_ctor(rest,name))

def agy_ro_prim_op(+name: String) -> String:
  nt_choose(String,String.eq(name,"u32_add"),u => "addl",u =>
    nt_choose(String,String.eq(name,"u32_sub"),u => "subl",u =>
      nt_choose(String,String.eq(name,"u32_mul"),u => "imull",u =>
        nt_choose(String,String.eq(name,"u32_xor"),u => "xorl",u =>
          nt_choose(String,String.eq(name,"u32_and"),u => "andl",u =>
            nt_choose(String,String.eq(name,"u32_or"),u => "orl",u => ""))))))

@unsafe
def agy_ro_lookup_var(+vid: U32, +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool) -> Maybe<&2,KTerm>:
  nt_choose(Maybe<&2,KTerm>,has_x && U32.is_eq(vid,x_id),
    u => Some{kt("RoParamX","",0,0,[])},u =>
    nt_choose(Maybe<&2,KTerm>,U32.is_eq(f0_k,1) && U32.is_eq(vid,f0_id),
      v => Some{kt("RoField","",0,0,[])},v =>
      nt_choose(Maybe<&2,KTerm>,U32.is_eq(f1_k,1) && U32.is_eq(vid,f1_id),
        w => Some{kt("RoField","",1,0,[])},w => None{})))

@unsafe
def agy_ro_rec_field(+t: KTerm, +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32) -> U32:
  # Returns 1 for field 0, 2 for field 1, 0 for invalid
  +u = nc_unann(t)
  nt_choose(U32,String.eq(tg(u),"Var"),
    v => nt_choose(U32,U32.is_eq(f0_k,2) && U32.is_eq(ix(u),f0_id),
      w => 1,
      w => nt_choose(U32,U32.is_eq(f1_k,2) && U32.is_eq(ix(u),f1_id),z => 2,z => 0)),
    v => 0)

@unsafe
def agy_ro_is_x(+t: KTerm, +x_id: U32, +has_x: Bool) -> Bool:
  +u = nc_unann(t)
  has_x && String.eq(tg(u),"Var") && U32.is_eq(ix(u),x_id)

law agy_ro_parse_expr:
  for +book: List<&2,KDef>
  for +owner: String
  for +t: KTerm
  for +f0_id: U32
  for +f0_k: U32
  for +f1_id: U32
  for +f1_k: U32
  for +x_id: U32
  for +has_x: Bool
  for +fuel: U32
  Maybe<&2,KTerm>

@unsafe
def agy_ro_parse_bin_r(+op: String, ea: KTerm, rb: Maybe<&2,KTerm>) -> Maybe<&2,KTerm>:
  match rb:
    case None{}: None{}
    case Some{eb}: Some{kt("RoBin",op,0,0,[ea,eb])}

@unsafe
def agy_ro_parse_bin_l(+book: List<&2,KDef>, +owner: String, +op: String, +b: KTerm,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool, +fuel: U32,
    ra: Maybe<&2,KTerm>) -> Maybe<&2,KTerm>:
  match ra:
    case None{}: None{}
    case Some{ea}:
      agy_ro_parse_bin_r(op,ea,agy_ro_parse_expr(book,owner,b,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel))

@unsafe
def agy_ro_parse_bin(+book: List<&2,KDef>, +owner: String, +op: String, +a: KTerm, +b: KTerm,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool, +fuel: U32) -> Maybe<&2,KTerm>:
  agy_ro_parse_bin_l(book,owner,op,b,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel,
    agy_ro_parse_expr(book,owner,a,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel))

@unsafe
def agy_ro_parse_prim(+book: List<&2,KDef>, +owner: String, +fn_name: String, +a: KTerm, +b: KTerm,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool, +fuel: U32) -> Maybe<&2,KTerm>:
  +d = lookup(book,fn_name)
  +op = agy_ro_prim_op(nc_primitive_name(dn(d)))
  nt_choose(Maybe<&2,KTerm>,nc_native_def(d) && U32.is_eq(da(d),2) && Bool.not(String.is_empty(op)),
    u => agy_ro_parse_bin(book,owner,op,a,b,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel),
    u => None{})

@unsafe
def agy_ro_parse_app(+book: List<&2,KDef>, +owner: String, spine: KPChain,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool, +fuel: U32) -> Maybe<&2,KTerm>:
  match spine:
    case KPChain{Con{+a,Nil{}},+hd}:
      +hu = nc_unann(hd)
      nt_choose(Maybe<&2,KTerm>,Bool.not(has_x) && String.eq(tg(hu),"Ref") && String.eq(nm(hu),owner),
        u => nt_choose(Maybe<&2,KTerm>,U32.is_gt(agy_ro_rec_field(a,f0_id,f0_k,f1_id,f1_k),0),
          v => Some{kt("RoRec","",U32.sub(agy_ro_rec_field(a,f0_id,f0_k,f1_id,f1_k),1),0,[])},
          v => None{}),
        u => None{})
    case KPChain{Con{+a,Con{+b,Nil{}}},+hd}:
      +hu = nc_unann(hd)
      nt_choose(Maybe<&2,KTerm>,String.eq(tg(hu),"Ref"),
        u => nt_choose(Maybe<&2,KTerm>,has_x && String.eq(nm(hu),owner) && agy_ro_is_x(b,x_id,has_x),
          v => nt_choose(Maybe<&2,KTerm>,U32.is_gt(agy_ro_rec_field(a,f0_id,f0_k,f1_id,f1_k),0),
            w => Some{kt("RoRec","",U32.sub(agy_ro_rec_field(a,f0_id,f0_k,f1_id,f1_k),1),0,[])},
            w => None{}),
          v => agy_ro_parse_prim(book,owner,nm(hu),a,b,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel)),
        u => None{})
    case _: None{}

@unsafe
def agy_ro_parse_expr(book,owner,t,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel):
  +u = nc_unann(t)
  nt_choose(Maybe<&2,KTerm>,U32.is_eq(fuel,0),u0 => None{},u0 =>
    nt_choose(Maybe<&2,KTerm>,String.eq(tg(u),"Lit") && String.eq(nm(u),"U32"),
      u1 => Some{kt("RoConst","",kl_number(u),0,[])},u1 =>
      nt_choose(Maybe<&2,KTerm>,String.eq(tg(u),"Var"),
        u2 => agy_ro_lookup_var(ix(u),f0_id,f0_k,f1_id,f1_k,x_id,has_x),u2 =>
        nt_choose(Maybe<&2,KTerm>,String.eq(tg(u),"App"),
          u3 => agy_ro_parse_app(book,owner,x198pw_spine(u,[],4),f0_id,f0_k,f1_id,f1_k,x_id,has_x,U32.sub(fuel,1)),
          u3 => None{}))))

@unsafe
def agy_ro_peel_x(+book: List<&2,KDef>, +owner: String, +body: KTerm,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +has_x: Bool) -> Maybe<&2,KTerm>:
  +u = nc_unann(body)
  nt_choose(Maybe<&2,KTerm>,has_x,
    v => nt_choose(Maybe<&2,KTerm>,String.eq(tg(u),"Lam") && U32.is_eq(terms_len(ks(u)),1),
      w => agy_ro_parse_expr(book,owner,kid(u,0),f0_id,f0_k,f1_id,f1_k,ix(u),True{},32),
      w => None{}),
    v => agy_ro_parse_expr(book,owner,u,f0_id,f0_k,f1_id,f1_k,0,False{},32))

@unsafe
def agy_ro_peel_arm2(+book: List<&2,KDef>, +owner: String, +body: KTerm, +f0_id: U32, +k0: U32, +k1: U32, +has_x: Bool) -> Maybe<&2,KTerm>:
  +u1 = nc_unann(body)
  nt_choose(Maybe<&2,KTerm>,String.eq(tg(u1),"Lam") && U32.is_eq(terms_len(ks(u1)),1),
    v => agy_ro_peel_x(book,owner,kid(u1,0),f0_id,k0,ix(u1),k1,has_x),
    v => None{})

@unsafe
def agy_ro_peel_arm(+book: List<&2,KDef>, +owner: String, +arm: KTerm, +fields: List<&2,U32>, +has_x: Bool) -> Maybe<&2,KTerm>:
  match fields:
    case Nil{}:
      agy_ro_peel_x(book,owner,arm,0,0,0,0,has_x)
    case Con{+k0,Nil{}}:
      +u0 = nc_unann(arm)
      nt_choose(Maybe<&2,KTerm>,String.eq(tg(u0),"Lam") && U32.is_eq(terms_len(ks(u0)),1),
        v => agy_ro_peel_x(book,owner,kid(u0,0),ix(u0),k0,0,0,has_x),
        v => None{})
    case Con{+k0,Con{+k1,Nil{}}}:
      +u0 = nc_unann(arm)
      nt_choose(Maybe<&2,KTerm>,String.eq(tg(u0),"Lam") && U32.is_eq(terms_len(ks(u0)),1),
        v => agy_ro_peel_arm2(book,owner,kid(u0,0),ix(u0),k0,k1,has_x),
        v => None{})
    case _: None{}

@unsafe
def agy_ro_expr_has_rec(+e: KTerm) -> Bool:
  nt_choose(Bool,String.eq(tg(e),"RoRec"),u => True{},u =>
    nt_choose(Bool,String.eq(tg(e),"RoBin") && U32.is_eq(terms_len(ks(e)),2),
      v => agy_ro_expr_has_rec(kid(e,0)) || agy_ro_expr_has_rec(kid(e,1)),
      v => False{}))

law agy_ro_walk_mats:
  for +book: List<&2,KDef>
  for +owner: String
  for +adt: String
  for +ctors: List<&2,KDef>
  for +t: KTerm
  for +has_x: Bool
  for +has_rec: Bool
  for +acc: List<&2,KTerm>
  for +fuel: U32
  Maybe<&2,List<&2,KTerm>>

@unsafe
def agy_ro_walk_mat_expr(+book: List<&2,KDef>, +owner: String, +adt: String, +ctors: List<&2,KDef>,
    +cname: String, +carity: U32, +inline_u32: U32, +rest: KTerm, +has_x: Bool, +has_rec: Bool, +acc: List<&2,KTerm>,
    +fuel: U32, parsed: Maybe<&2,KTerm>) -> Maybe<&2,List<&2,KTerm>>:
  match parsed:
    case None{}: None{}
    case Some{+expr}:
      +cid = nc_ctor_identity(book,cname)
      +item = kt("RoCase",cid,carity,inline_u32,[expr])
      agy_ro_walk_mats(book,owner,adt,ctors,rest,has_x,has_rec || agy_ro_expr_has_rec(expr),Con{item,acc},fuel)

def agy_ro_is_inline_u32(fs: List<&2,U32>) -> U32:
  match fs:
    case Con{k0,Nil{}}: nt_choose(U32,U32.is_eq(k0,1),u => 1,u => 0)
    case _: 0

@unsafe
def agy_ro_walk_mat_fields(+book: List<&2,KDef>, +owner: String, +adt: String, +ctors: List<&2,KDef>,
    +cname: String, +carity: U32, +arm: KTerm, +rest: KTerm, +has_x: Bool, +has_rec: Bool, +acc: List<&2,KTerm>,
    +fuel: U32, fields: Maybe<&2,List<&2,U32>>) -> Maybe<&2,List<&2,KTerm>>:
  match fields:
    case None{}: None{}
    case Some{rev_fs}:
      +fs = agy_ro_rev_u32(rev_fs,[])
      agy_ro_walk_mat_expr(book,owner,adt,ctors,cname,carity,agy_ro_is_inline_u32(fs),rest,has_x,has_rec,acc,fuel,
        agy_ro_peel_arm(book,owner,arm,fs,has_x))

@unsafe
def agy_ro_walk_mat_one(+book: List<&2,KDef>, +owner: String, +adt: String, +ctors: List<&2,KDef>,
    +cname: String, +arm: KTerm, +rest: KTerm, +has_x: Bool, +has_rec: Bool, +acc: List<&2,KTerm>, +fuel: U32) -> Maybe<&2,List<&2,KTerm>>:
  +cd = agy_ro_find_ctor(ctors,cname)
  nt_choose(Maybe<&2,List<&2,KTerm>>,String.eq(dk(cd),"Ctr") && U32.is_eq(dx(cd),0) && U32.is_le(da(cd),2),
    u => agy_ro_walk_mat_fields(book,owner,adt,ctors,cname,da(cd),arm,rest,has_x,has_rec,acc,fuel,
      agy_ro_ctor_fields(dt(cd),adt,[])),
    u => None{})

@unsafe
def agy_ro_walk_mats(book,owner,adt,ctors,t,has_x,has_rec,acc,fuel):
  +u = nc_unann(t)
  nt_choose(Maybe<&2,List<&2,KTerm>>,U32.is_eq(fuel,0),v => None{},v =>
    nt_choose(Maybe<&2,List<&2,KTerm>>,String.eq(tg(u),"Mat") && U32.is_eq(terms_len(ks(u)),2),
      w => agy_ro_walk_mat_one(book,owner,adt,ctors,nm(u),kid(u,0),kid(u,1),has_x,has_rec,acc,U32.sub(fuel,1)),
      w => nt_choose(Maybe<&2,List<&2,KTerm>>,has_rec && Bool.not(List.is_empty(&2,KTerm,acc)),
        z => Some{acc},z => None{})))

@unsafe
def agy_ro_check_finish(+owner: String, +arity: U32, res: Maybe<&2,List<&2,KTerm>>) -> Maybe<&2,KDef>:
  match res:
    case None{}: None{}
    case Some{cases}:
      +key = agy_ro_key("$direct." ++ owner)
      Some{KDef{key,"AgyRoRecCertified",arity,0,kt("RoCases","",0,0,cases),kt("None","",0,0,[]),[],False{},False{}}}

@unsafe
def agy_ro_check_adt(+book: List<&2,KDef>, +d: KDef, +adt_name: String, +arity: U32, +has_x: Bool) -> Maybe<&2,KDef>:
  +adt = lookup(book,adt_name)
  +valid_sig = nt_choose(Bool,has_x,
    v => x198pw_tel(dt(d),[adt_name,"U32"],"U32"),
    v => x198pw_tel(dt(d),[adt_name],"U32"))
  nt_choose(Maybe<&2,KDef>,valid_sig && String.eq(dk(adt),"ADT") && U32.is_eq(da(adt),0) &&
      U32.is_eq(dx(adt),0) && Bool.not(db(adt)),
    u => agy_ro_check_finish(dn(d),arity,agy_ro_walk_mats(book,dn(d),adt_name,dc(adt),dv(d),has_x,False{},[],16)),
    u => None{})

@unsafe
def agy_ro_check_def(+book: List<&2,KDef>, +d: KDef) -> Maybe<&2,KDef>:
  +arity = da(d)
  +has_x = U32.is_eq(arity,2)
  +ty_t = nc_unann(dt(d))
  nt_choose(Maybe<&2,KDef>,String.eq(dk(d),"Def") && (U32.is_eq(arity,1) || U32.is_eq(arity,2)) &&
      Bool.not(db(d) || du(d)) && String.eq(tg(nc_unann(dv(d))),"Mat") &&
      String.eq(tg(ty_t),"All") && U32.is_eq(terms_len(ks(ty_t)),2),
    u => agy_ro_check_adt(book,d,nm(nc_unann(kid(ty_t,0))),arity,has_x),
    u => None{})

@unsafe
def agy_ro_add_entry(entry: Maybe<&2,KDef>, acc: List<&2,KDef>) -> List<&2,KDef>:
  match entry:
    case None{}: acc
    case Some{e}: Con{e,acc}

@unsafe
def agy_ro_owners(scope: List<&2,KDef>, +book: List<&2,KDef>, +acc: List<&2,KDef>) -> List<&2,KDef>:
  match scope:
    case Nil{}: acc
    case Con{+d,rest}:
      agy_ro_owners(rest,book,agy_ro_add_entry(agy_ro_check_def(book,d),acc))

@unsafe
def agy_ro_mark(entries: List<&2,KDef>, ids: N111Ids) -> N111Ids:
  match entries ids:
    case Con{+entry,rest} N111Ids{+fs,cs}:
      +key = dn(entry)
      agy_ro_mark(rest,N111Ids{nt_choose(KDef,String.eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

def agy_ro_context(+entries: List<&2,KDef>, ctx: P134Context) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      P134Context{agy_ro_mark(entries,ids),idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_ro_cursor(+entries: List<&2,KDef>, cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_ro_context(entries,c),agy_ro_cursor(entries,next)}
    case P134Public{ss,c,next}: P134Public{ss,agy_ro_context(entries,c),agy_ro_cursor(entries,next)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_ro_context(entries,c),agy_ro_cursor(entries,next)}
    case p: p

@unsafe
def agy_ro_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r prepared:
    case NR_Request{source,+book,names,paths,scope,bound} P169Prepared{forwards,+cursor,+error}:
      +entries = agy_ro_owners(scope,book,[])
      P169Prepared{forwards,nt_choose(P134Cursor,String.is_empty(error) && Bool.not(List.is_empty(&2,KDef,entries)),
        u => agy_ro_cursor(entries,cursor),u => cursor),error}

@unsafe
def agy_ro_get_mark(name: String, ids: N111Ids) -> KDef:
  match ids:
    case N111Ids{fs,cs}: p111v_get(fs,agy_ro_key(name))

# ---- x86 code emission for certified read-only native recursion ----
# Register convention inside <rec_lbl>:
#   %r12 (12): heap base pointer (u64*)
#   %r13 (13): x (u32, if arity == 2)
#   %r14 (14): current node payload heap-word index (callee-saved inside boxed arms)
#   %ecx (1) : recursion depth budget (starts at 256)
#   %rsi (6) : incoming node word
#   %eax (0) : U32 result
#   %r11d(11): bail flag (0 = ok, 1 = bail to slow path)
#   %rbx (3) : callee-saved scratch for Bin(left, right)

@unsafe
def agy_ro_check_cids(cases: List<&2,KTerm>, +ids: N111Ids) -> Bool:
  match cases:
    case Nil{}: True{}
    case Con{+c,rest}:
      +cid = x198pw_cid(nm(c),ids)
      x198pw_has_cid(cid,ix(c)) && agy_ro_check_cids(rest,ids)

@unsafe
def agy_ro_emit_bin_op(+op: String, +left_reg: U32) -> X188Seq:
  # left is in left_reg (32-bit), right is in %eax (reg 0, 32-bit), result in %eax
  nt_choose(X188Seq,String.eq(op,"subl"),
    u => x188_many([
      x188_i2("subl",x188_reg(0,32),x188_reg(left_reg,32)),
      x188_i2("movl",x188_reg(left_reg,32),x188_reg(0,32))]),
    u => x188_i2(op,x188_reg(left_reg,32),x188_reg(0,32)))

law agy_ro_emit_expr:
  for +e: KTerm
  for +rec_lbl: String
  for +bail_lbl: String
  for +tag: String
  for +inline_f0: Bool
  X188Seq

@unsafe
def agy_ro_emit_bin(+op: String, +left: KTerm, +right: KTerm, +rec_lbl: String, +bail_lbl: String, +tag: String, +inline_f0: Bool) -> X188Seq:
  +rb_bail = bail_lbl ++ "_p" ++ tag
  +rb_done = bail_lbl ++ "_d" ++ tag
  nt_choose(X188Seq,String.eq(tg(right),"RoBin") || String.eq(tg(right),"RoRec"),
    u => x188_many([
      agy_ro_emit_expr(left,rec_lbl,bail_lbl,tag ++ "l",inline_f0),
      x188_i1("pushq",x188_reg(3,64)),
      x188_i2("movl",x188_reg(0,32),x188_reg(3,32)),
      agy_ro_emit_expr(right,rec_lbl,rb_bail,tag ++ "r",inline_f0),
      agy_ro_emit_bin_op(op,3),
      x188_i1("popq",x188_reg(3,64)),
      x188_i1("jmp",X187Target{rb_done}),
      x188_label(rb_bail),
      x188_i1("popq",x188_reg(3,64)),
      x188_i1("jmp",X187Target{bail_lbl}),
      x188_label(rb_done)]),
    u => x188_many([
      agy_ro_emit_expr(left,rec_lbl,bail_lbl,tag ++ "l",inline_f0),
      x188_i2("movl",x188_reg(0,32),x188_reg(2,32)),
      agy_ro_emit_expr(right,rec_lbl,bail_lbl,tag ++ "r",inline_f0),
      agy_ro_emit_bin_op(op,2)]))

@unsafe
def agy_ro_emit_expr(e,rec_lbl,bail_lbl,tag,inline_f0):
  +t = tg(e)
  nt_choose(X188Seq,String.eq(t,"RoConst"),
    u => x188_i2("movl",X187Imm{ix(e),0},x188_reg(0,32)),u =>
    nt_choose(X188Seq,String.eq(t,"RoParamX"),
      v => x188_i2("movl",x188_reg(13,32),x188_reg(0,32)),v =>
      nt_choose(X188Seq,String.eq(t,"RoField"),
        w => nt_choose(X188Seq,inline_f0 && U32.is_eq(ix(e),0),
          k => x188_i2("movl",x188_reg(6,32),x188_reg(0,32)),
          k => x188_i2("movl",X187Indexed{12,14,8,U32.mul(ix(e),8)},x188_reg(0,32))),w =>
        nt_choose(X188Seq,String.eq(t,"RoRec"),
          z => x188_many([
            x188_i2("movq",X187Indexed{12,14,8,U32.mul(ix(e),8)},x188_reg(6,64)),
            x188_i1("call",X187Target{rec_lbl}),
            x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
            x188_i1("jne",X187Target{bail_lbl})]),
          z => nt_choose(X188Seq,String.eq(t,"RoBin") && U32.is_eq(terms_len(ks(e)),2),
            q => agy_ro_emit_bin(nm(e),kid(e,0),kid(e,1),rec_lbl,bail_lbl,tag,inline_f0),
            q => X188Empty{})))))

@unsafe
def agy_ro_emit_nullary_dispatch(cases: List<&2,KTerm>, +ids: N111Ids, +prefix: String, +idx: U32) -> X188Seq:
  match cases:
    case Nil{}: x188_i1("jmp",X187Target{prefix ++ "_bail"})
    case Con{+c,+rest}:
      nt_choose(X188Seq,U32.is_eq(ix(c),0),
        u => x188_many([
          x188_i2("cmpl",X187Imm{da(x198pw_cid(nm(c),ids)),0},x188_reg(0,32)),
          x188_i1("je",X187Target{prefix ++ "_c" ++ U32.show(idx)}),
          agy_ro_emit_nullary_dispatch(rest,ids,prefix,U32.inc(idx))]),
        u => nt_choose(X188Seq,U32.is_eq(qt(c),1),
          v => x188_many([
            x188_i2("cmpl",X187Imm{da(x198pw_cid(nm(c),ids)),0},x188_reg(0,32)),
            x188_i1("je",X187Target{prefix ++ "_in" ++ U32.show(idx)}),
            agy_ro_emit_nullary_dispatch(rest,ids,prefix,U32.inc(idx))]),
          v => agy_ro_emit_nullary_dispatch(rest,ids,prefix,U32.inc(idx))))

@unsafe
def agy_ro_emit_boxed_dispatch(cases: List<&2,KTerm>, +ids: N111Ids, +prefix: String, +idx: U32) -> X188Seq:
  match cases:
    case Nil{}: x188_i1("jmp",X187Target{prefix ++ "_bail"})
    case Con{+c,+rest}:
      nt_choose(X188Seq,U32.is_gt(ix(c),0),
        u => x188_many([
          x188_i2("cmpl",X187Imm{da(x198pw_cid(nm(c),ids)),0},x188_reg(0,32)),
          x188_i1("je",X187Target{prefix ++ "_c" ++ U32.show(idx)}),
          agy_ro_emit_boxed_dispatch(rest,ids,prefix,U32.inc(idx))]),
        u => agy_ro_emit_boxed_dispatch(rest,ids,prefix,U32.inc(idx)))

@unsafe
def agy_ro_emit_arms(cases: List<&2,KTerm>, +prefix: String, +idx: U32) -> X188Seq:
  match cases:
    case Nil{}: X188Empty{}
    case Con{+c,rest}:
      +lbl = prefix ++ "_c" ++ U32.show(idx)
      +rec_lbl = prefix ++ "_rec"
      +expr = kid(c,0)
      +inline_arm = nt_choose(X188Seq,U32.is_eq(qt(c),1),
        u => x188_many([
          x188_label(prefix ++ "_in" ++ U32.show(idx)),
          agy_ro_emit_expr(expr,rec_lbl,prefix ++ "_bail","i",True{}),
          x188_i0("ret")]),
        u => X188Empty{})
      +arm_code = nt_choose(X188Seq,U32.is_eq(ix(c),0),
        u => x188_many([
          x188_label(lbl),
          agy_ro_emit_expr(expr,rec_lbl,prefix ++ "_bail","0",False{}),
          x188_i0("ret")]),
        u => x188_many([
          inline_arm,
          x188_label(lbl),
          x188_i1("pushq",x188_reg(14,64)),
          x188_i2("movq",x188_reg(8,64),x188_reg(14,64)),
          x188_i2("subl",X187Imm{1,0},x188_reg(1,32)),
          agy_ro_emit_expr(expr,rec_lbl,lbl ++ "_b","0",False{}),
          x188_i2("addl",X187Imm{1,0},x188_reg(1,32)),
          x188_i1("popq",x188_reg(14,64)),
          x188_i0("ret"),
          x188_label(lbl ++ "_b"),
          x188_i2("addl",X187Imm{1,0},x188_reg(1,32)),
          x188_i1("popq",x188_reg(14,64)),
          x188_i0("ret")]))
      x188_cat(arm_code,agy_ro_emit_arms(rest,prefix,U32.inc(idx)))

@unsafe
def agy_ro_emit_wrapper(+symbol: String, +slow: String, +arity: U32, +cases: List<&2,KTerm>, +ids: N111Ids) -> X181Output:
  +prefix = ".Lagyro_" ++ symbol
  +rec_lbl = prefix ++ "_rec"
  +has_x = U32.is_eq(arity,2)
  # Check mode == 0 and depth == 0:
  # arity 1: rdi=state, rsi=e, rdx=mode, rcx=depth, r8=value
  # arity 2: rdi=state, rsi=e, rdx=x, rcx=mode, r8=depth, r9=value
  +mode_reg = nt_choose(U32,has_x,u => 1,u => 2)
  +depth_reg = nt_choose(U32,has_x,u => 8,u => 1)
  +entry = x188_many([
    x188_i2("cmpq",X187Imm{0,0},x188_reg(mode_reg,64)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("cmpq",X187Imm{0,0},x188_reg(depth_reg,64)),
    x188_i1("jne",X187Target{slow}),
    # Check tag of e (%rsi)
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{1,0},x188_reg(0,64)),
    x188_i1("je",X187Target{prefix ++ "_null_entry"}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{slow}),
    # tag == 0x82 (130): check rc >= 2
    x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(11,64)),
    x188_i2("andq",x188_reg(6,64),x188_reg(11,64)),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{2,0},x188_reg(0,32)),
    x188_i1("jb",X187Target{slow}),
    # Save callee-saved regs + state/e/x for possible bailout
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i1("pushq",x188_reg(7,64)),
    x188_i1("pushq",x188_reg(6,64)),
    x188_i2("movq",x188_reg(10,64),x188_reg(12,64)),
    x188_i2("movq",x188_reg(11,64),x188_reg(15,64)),
    nt_choose(X188Seq,has_x,u => x188_i2("movl",x188_reg(2,32),x188_reg(13,32)),u => X188Empty{}),
    x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
    x188_i2("movl",X187Imm{256,0},x188_reg(1,32)),
    x188_i1("call",X187Target{rec_lbl}),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jne",X187Target{prefix ++ "_miss"}),
    # Success! Decrement root refcount by 1
    x188_i2("movq",X187Indexed{12,15,8,0},x188_reg(10,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),X187Indexed{12,15,8,0}),
    x188_i2("movl",x188_reg(0,32),x188_reg(0,32)),
    x188_i2("addq",X187Imm{16,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    # Nullary entry (tag == 1): no refcount to decrement
    x188_label(prefix ++ "_null_entry"),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i1("pushq",x188_reg(7,64)),
    x188_i1("pushq",x188_reg(6,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(12,64)),
    nt_choose(X188Seq,has_x,u => x188_i2("movl",x188_reg(2,32),x188_reg(13,32)),u => X188Empty{}),
    x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
    x188_i2("movl",X187Imm{256,0},x188_reg(1,32)),
    x188_i1("call",X187Target{rec_lbl}),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jne",X187Target{prefix ++ "_miss"}),
    x188_i2("movl",x188_reg(0,32),x188_reg(0,32)),
    x188_i2("addq",X187Imm{16,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    # Miss / bailout: restore all incoming registers and jump to slow
    x188_label(prefix ++ "_miss"),
    x188_i1("popq",x188_reg(6,64)),
    x188_i1("popq",x188_reg(7,64)),
    nt_choose(X188Seq,has_x,
      u => x188_many([
        x188_i2("movl",x188_reg(13,32),x188_reg(2,32)),
        x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
        x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
        x188_i2("xorl",x188_reg(9,32),x188_reg(9,32))]),
      u => x188_many([
        x188_i2("xorl",x188_reg(2,32),x188_reg(2,32)),
        x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
        x188_i2("xorl",x188_reg(8,32),x188_reg(8,32))])),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("jmp",X187Target{slow}),
    # Internal recursive helper
    x188_label(rec_lbl),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("je",X187Target{prefix ++ "_bail"}),
    x188_i2("movq",x188_reg(6,64),x188_reg(9,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{65535,0},x188_reg(0,32)),
    x188_i2("cmpq",X187Imm{1,0},x188_reg(9,64)),
    x188_i1("je",X187Target{prefix ++ "_null"}),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(8,64)),
    x188_i2("andq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(9,64)),
    x188_i1("je",X187Target{prefix ++ "_boxed"}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(9,64)),
    x188_i1("jne",X187Target{prefix ++ "_bail"}),
    x188_i2("movq",X187Indexed{12,8,8,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_label(prefix ++ "_boxed"),
    agy_ro_emit_boxed_dispatch(cases,ids,prefix,0),
    x188_label(prefix ++ "_null"),
    agy_ro_emit_nullary_dispatch(cases,ids,prefix,0),
    agy_ro_emit_arms(cases,prefix,0),
    x188_label(prefix ++ "_bail"),
    x188_i2("movl",X187Imm{1,0},x188_reg(11,32)),
    x188_i0("ret")])
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    entry,X188One{PSize{symbol}}])],""}

@unsafe
def agy_ro_h_args(ps: List<&2,String>, +arity: U32) -> Bool:
  match ps:
    case Con{state,Con{a,Con{mode,Con{depth,Con{value,Nil{}}}}}}:
      U32.is_eq(arity,1) && String.eq(state,"state") && String.eq(mode,"p114h_mode") && String.eq(depth,"p114r_depth") && String.eq(value,"p114r_value")
    case Con{state,Con{a,Con{b,Con{mode,Con{depth,Con{value,Nil{}}}}}}}:
      U32.is_eq(arity,2) && String.eq(state,"state") && String.eq(mode,"p114h_mode") && String.eq(depth,"p114r_depth") && String.eq(value,"p114r_value")
    case _: False{}

@unsafe
def agy_ro_worker(+name: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  +symbol = p114r_symbol(name)
  +entry = agy_ro_get_mark(name,ids)
  +slow = "p198w_original_" ++ symbol
  +arity = da(entry)
  +cases = ks(dt(entry))
  nt_choose(X181Output,String.eq(dk(entry),"AgyRoRecCertified") && agy_ro_h_args(params,arity) && agy_ro_check_cids(cases,ids),
    u => x181_program_join(agy_ro_emit_wrapper(symbol,slow,arity,cases,ids),
      x185_function_setup(slow,params,setup,body,ids)),
    u => x185_function_setup(symbol,params,setup,body,ids))
'''

def once(s: str, old: str, new: str, label: str) -> str:
    n = s.count(old)
    if n != 1:
        raise RuntimeError(f"{label}: expected 1 match, got {n}")
    return s.replace(old, new, 1)

def apply(src: str) -> str:
    # 1. Insert ROREC_BEND right before x198pw_annotate
    anchor = "@unsafe\ndef x198pw_annotate(r: NR_Request,+prepared: P169Prepared) -> P169Prepared:"
    src = once(src, anchor, ROREC_BEND + "\n\n" + anchor, "insert agy_rorec")

    # 2. Chain agy_ro_annotate after x198pw_annotate
    old_ann = (
        "def x198pw_annotate(r: NR_Request,+prepared: P169Prepared) -> P169Prepared:\n"
        "  match r:\n"
        "    case NR_Request{source,+book,names,paths,scope,bound}:\n"
        "      x198pw_ready(x198pw_owners(scope,book,[]),prepared)"
    )
    new_ann = (
        "def x198pw_annotate(+r: NR_Request,+prepared: P169Prepared) -> P169Prepared:\n"
        "  match r:\n"
        "    case NR_Request{source,+book,names,paths,scope,bound}:\n"
        "      agy_ro_annotate(r,x198pw_ready(x198pw_owners(scope,book,[]),prepared))"
    )
    src = once(src, old_ann, new_ann, "hook x198pw_annotate")

    # 3. Hook agy_ro_worker in x198pw_worker fallback branch
    old_w = (
        "def x198pw_worker(+name: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,+body: List<&2,P113DStmt>,\n"
        "    +ids: N111Ids,+entry: KDef) -> X181Output:\n"
        "  +symbol = p114r_symbol(name)\n"
        "  nt_choose(X181Output,String.eq(dk(entry),\"X198PWCertified\") && x198pw_h_args(params),\n"
        "    u => x198pw_worker_cids(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry))),\n"
        "    u => x185_function_setup(symbol,params,setup,body,ids))"
    )
    new_w = (
        "def x198pw_worker(+name: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,+body: List<&2,P113DStmt>,\n"
        "    +ids: N111Ids,+entry: KDef) -> X181Output:\n"
        "  +symbol = p114r_symbol(name)\n"
        "  nt_choose(X181Output,String.eq(dk(entry),\"X198PWCertified\") && x198pw_h_args(params),\n"
        "    u => x198pw_worker_cids(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry))),\n"
        "    u => agy_ro_worker(name,params,setup,body,ids))"
    )
    src = once(src, old_w, new_w, "hook x198pw_worker")
    return src

def main():
    src_path = Path(sys.argv[1])
    dst_path = Path(sys.argv[2])
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    dst_path.write_text(apply(src_path.read_text()))
    print(f"Patched {dst_path} ({dst_path.stat().st_size} bytes)")

if __name__ == "__main__":
    main()
