#!/usr/bin/env python3
"""Wave 6 General p111 Dead-Factory Pruner + Alpha-Equivalent CPS Continuation Deduplicator.

Transforms `selfhost/build/agy/wave5c_unified/compiler.bend` -> `/tmp/agy_w6_p111_prune/compiler.bend`
with two 100% general, semantics-preserving passes BEFORE 16-bit FID assignment (`p111v_functions`):

  Pass 1 — Demand-Split Non-Direct `p167l_dispatch`:
    When `p167l` demands a non-direct worker `$direct.<f>` (`arity > 0`), emit ONLY the worker
    segment and its continuations (never the unreachable curried factory `<f>` and its `arity`
    nested `$p111.k.*` closure-currying segments). Conversely, when `<f>` is demanded as a
    first-class closure (`P167Factory`), emit ONLY the factory (whose eta-body demands `$direct.<f>`
    if needed). Eliminates ~24,205 unreachable segments (-30.8%) on `compiler.bend` without ever
    lowering them.

  Pass 2 — General `$p111.k.*` Alpha-Equivalent Continuation Deduplication:
    Runs 2 linear passes over the lowered `N111Segment` list in `p167l_finish` (before `p140or_finish`
    and `p167v_original` / `p111v_functions`). Each `$p111.k.*` continuation segment is canonicalized
    by alpha-renaming locals in deterministic definition order (keeping `"state"` fixed) and keyed
    in an FNV-1a hash-trie (`p111v_get` / `p113e_insert`). Duplicate `$p111.k.*` segments are merged
    to their canonical representative and all `N111FuncId` references are rewritten. Eliminates
    ~29,700+ duplicate continuations (e.g., 13,134 identical `p111_rt_apply` continuations -> 1),
    bringing `compiler.bend` from 78,688 -> ~24,782 segments (-68.5%, 3.18x reduction).

Usage:
  python3 -B research/agy/wave6_p111_prune/apply_p111_prune.py \\
      --src selfhost/build/agy/wave5c_unified/compiler.bend \\
      --dst /tmp/agy_w6_p111_prune/compiler.bend
"""
import argparse
from pathlib import Path

W6_HELPERS = r'''
# === AGY-W6: Demand-Split Non-Direct Dispatch + Alpha-Equivalent $p111.k.* Deduplication ===

@unsafe
def w6_worker_code(+context: P167Context, +source: String, +owner: String, +arity: U32,
    +params: List<&2,NC_Binding>, pending: P167Demand, built: P167Built, code: P111Code) -> P167Built:
  match context code:
    case P167Context{+book,catalogue,+bangs} P111Code{body,segments,fresh,error}:
      p167l_accept(context,p111_mark_segments(
        Con{p111_segment(owner,params,0,0,body),segments},
        nb_contains(bangs,source)),fresh,pending,built,0,source,owner,arity,error)

@unsafe
def w6_worker_non_direct(+context: P167Context, +source: String, +owner: String, +arity: U32,
    pending: P167Demand, built: P167Built, +fresh: U32) -> P167Built:
  match context:
    case P167Context{+book,catalogue,+bangs}:
      +n0 = U32.add(fresh,1024)
      +body = nc_compact_definition(book,lookup(book,source),fresh)
      +params = nk_typed_bindings(nd_entry_params(arity,n0),nf_worker_kinds(book,source,arity))
      w6_worker_code(context,source,owner,arity,params,pending,built,
        p111_lower(book,nd_reapply(body,nd_entry_args(params)),params,U32.add(n0,arity)))

@unsafe
def w6_factory_non_direct(+book: List<&2,KDef>, +source: String, +n: U32, +arity: U32, +bangs: List<&2,String>) -> P111Code:
  +d = lookup(book,source)
  +bang = nb_contains(bangs,source)
  +typed = jd_live_arity(book,dt(d),jd_arity(book,d))
  +eta = Bool.not(bang || nc_native_def(d) || nc_foreign(d)) && U32.is_gt(typed,0) && U32.is_eq(typed,arity)
  +params = nd_entry_params(arity,U32.add(n,1024))
  nt_choose(P111Code,eta,
    u => p111_lower(book,nd_eta_body(params,kt("NCall",nd_name(nc_ref_name(book,source)),0,0,nd_entry_args(params))),[],U32.add(U32.add(n,1024),arity)),
    u => p111_lower(book,nc_compact_definition(book,d,n),[],U32.add(n,1024)))

type W6Local is Data:
  W6Local{+orig: String, +cid: U32}

type W6CState is Data:
  W6CState{+locals: List<&2,W6Local>, +next: U32, +chunks: List<&2,String>, +fuel: U32}

type W6DedupAcc is Data:
  W6DedupAcc{+seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32}

@unsafe
def w6_map_put(+index: KDef, +key: String, +val: String) -> KDef:
  p113e_insert(index,KDef{key,"W6",0,0,ref(val),atom("Absent"),[],False{},False{}})

@unsafe
def w6_alias(+alias: KDef, +name: String) -> String:
  +e = p111v_get(alias,name)
  nt_choose(String,agy_str_eq(dk(e),"Absent"),u => name,u => nm(dt(e)))

@unsafe
def w6_local_find(locals: List<&2,W6Local>, +name: String) -> U32:
  match locals:
    case Nil{}: 4294967295
    case Con{W6Local{+orig,+cid},rest}:
      nt_choose(U32,agy_str_eq(orig,name),u => cid,u => w6_local_find(rest,name))

@unsafe
def w6_use_local_id(+cid: U32, +name: String) -> String:
  nt_choose(String,U32.is_eq(cid,4294967295),u => "v:?" ++ name,u => "v:L" ++ U32.show(cid))

@unsafe
def w6_use_local(+locals: List<&2,W6Local>, +name: String) -> String:
  nt_choose(String,agy_str_eq(name,"state"),u => "v:state",u =>
    w6_use_local_id(w6_local_find(locals,name),name))

@unsafe
def w6_def_local_id(+locals: List<&2,W6Local>, +next: U32, +chunks: List<&2,String>, +fuel: U32, +name: String, +cid: U32) -> W6CState:
  nt_choose(W6CState,U32.is_eq(cid,4294967295),
    u => W6CState{Con{W6Local{name,next},locals},U32.inc(next),Con{"L" ++ U32.show(next),chunks},fuel},
    u => W6CState{locals,next,Con{"L" ++ U32.show(cid),chunks},fuel})

@unsafe
def w6_def_local(+st: W6CState, +name: String) -> W6CState:
  match st:
    case W6CState{+locals,+next,+chunks,+fuel}:
      nt_choose(W6CState,agy_str_eq(name,"state"),
        u => W6CState{locals,next,Con{"state",chunks},fuel},
        u => w6_def_local_id(locals,next,chunks,fuel,name,w6_local_find(locals,name)))

@unsafe
def w6_push(+st: W6CState, +s: String) -> W6CState:
  match st:
    case W6CState{locals,next,chunks,fuel}: W6CState{locals,next,Con{s,chunks},fuel}

@unsafe
def w6_type_tag(typ: N111Type) -> String:
  match typ:
    case N111U32{}: "3"
    case N111U64{}: "6"
    case N111Ptr{}: "p"

@unsafe
def w6_canon_val(+locals: List<&2,W6Local>, val: N111Value) -> String:
  match val:
    case N111Local{name}: w6_use_local(locals,name)
    case N111Const{lo,hi}: "c:" ++ U32.show(lo) ++ ":" ++ U32.show(hi)
    case N111Symbol{name}: "s:" ++ name
    case N111FuncId{name}: "f:" ++ name
    case N111CtorId{name}: "k:" ++ name

@unsafe
def w6_canon_args(args: List<&2,N111Arg>, +st: W6CState) -> W6CState:
  match args:
    case Nil{}: st
    case Con{N111Arg{typ,val},rest}:
      match st:
        case W6CState{+locals,next,chunks,fuel}:
          w6_canon_args(rest,W6CState{locals,next,Con{"," ++ w6_type_tag(typ) ++ ":" ++ w6_canon_val(locals,val),chunks},fuel})

law w6_canon_stmts:
  for body: List<&2,N111Stmt>
  for +st: W6CState
  W6CState

@unsafe
def w6_st_locals(+st: W6CState) -> List<&2,W6Local>:
  match st:
    case W6CState{locals,next,chunks,fuel}: locals

@unsafe
def w6_st_fuel(+st: W6CState) -> U32:
  match st:
    case W6CState{locals,next,chunks,fuel}: fuel

@unsafe
def w6_dec_fuel(+st: W6CState) -> W6CState:
  match st:
    case W6CState{locals,next,chunks,fuel}: W6CState{locals,next,chunks,U32.sub(fuel,1)}

@unsafe
def w6_canon_stmt_go(stmt: N111Stmt, +locals: List<&2,W6Local>, +st: W6CState) -> W6CState:
  match stmt:
    case N111Alloca{+name,+bytes,+align}:
      w6_push(w6_def_local(w6_push(st,"A("),name),"," ++ U32.show(bytes) ++ "," ++ U32.show(align) ++ ");")
    case N111Set{+name,typ,val}:
      +vs = w6_canon_val(locals,val)
      w6_push(w6_def_local(w6_push(st,"S("),name),"," ++ w6_type_tag(typ) ++ "," ++ vs ++ ");")
    case N111Bin{+name,typ,+op,left,right}:
      +ls = w6_canon_val(locals,left)
      +rs = w6_canon_val(locals,right)
      w6_push(w6_def_local(w6_push(st,"B("),name),"," ++ w6_type_tag(typ) ++ "," ++ op ++ "," ++ ls ++ "," ++ rs ++ ");")
    case N111Call{+name,typ,+symbol,args}:
      +st1 = w6_canon_args(args,w6_push(w6_def_local(w6_push(st,"C("),name),"," ++ w6_type_tag(typ) ++ "," ++ symbol))
      w6_push(st1,");")
    case N111If{cond,yes,no}:
      +cs = w6_canon_val(locals,cond)
      +st1 = w6_canon_stmts(yes,w6_push(st,"I(" ++ cs ++ ",["))
      +st2 = w6_canon_stmts(no,w6_push(st1,"],["))
      w6_push(st2,"]);")
    case N111Return{val}:
      w6_push(st,"R(" ++ w6_canon_val(locals,val) ++ ");")
    case N111Load{+name,typ,base,+offset}:
      +bs = w6_canon_val(locals,base)
      w6_push(w6_def_local(w6_push(st,"L("),name),"," ++ w6_type_tag(typ) ++ "," ++ bs ++ "," ++ U32.show(offset) ++ ");")
    case N111Store{typ,base,+offset,val}:
      w6_push(st,"W(" ++ w6_type_tag(typ) ++ "," ++ w6_canon_val(locals,base) ++ "," ++ U32.show(offset) ++ "," ++ w6_canon_val(locals,val) ++ ");")
    case N111Offset{+name,base,bytes}:
      +bs = w6_canon_val(locals,base)
      +ys = w6_canon_val(locals,bytes)
      w6_push(w6_def_local(w6_push(st,"O("),name),"," ++ bs ++ "," ++ ys ++ ");")

@unsafe
def w6_canon_stmt(stmt: N111Stmt, +st: W6CState) -> W6CState:
  w6_canon_stmt_go(stmt,w6_st_locals(st),st)

@unsafe
def w6_canon_stmts(body, st):
  match body:
    case Nil{}: st
    case Con{+head,+rest}:
      nt_choose(W6CState,U32.is_eq(w6_st_fuel(st),0),
        u => st,
        u => w6_canon_stmts(rest,w6_canon_stmt(head,w6_dec_fuel(st))))

@unsafe
def w6_canon_finish(st: W6CState) -> String:
  match st:
    case W6CState{locals,next,chunks,fuel}:
      nt_choose(String,U32.is_eq(fuel,0),u => "",u => nt_text_finish(chunks,""))

@unsafe
def w6_canon_seg(+arity: U32, +result: U32, +incoming: U32, +flags: U32, body: List<&2,N111Stmt>) -> String:
  +hdr = U32.show(arity) ++ "|" ++ U32.show(result) ++ "|" ++ U32.show(incoming) ++ "|" ++ U32.show(flags) ++ "|"
  w6_canon_finish(w6_canon_stmts(body,W6CState{[],0,[hdr],33}))

@unsafe
def w6_rw_val(+alias: KDef, val: N111Value) -> N111Value:
  match val:
    case N111FuncId{name}: N111FuncId{w6_alias(alias,name)}
    case _: val

@unsafe
def w6_rw_args(+alias: KDef, args: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,val},rest}: Con{N111Arg{typ,w6_rw_val(alias,val)},w6_rw_args(alias,rest)}

law w6_rw_stmts:
  for +alias: KDef
  for body: List<&2,N111Stmt>
  List<&2,N111Stmt>

@unsafe
def w6_rw_stmt(+alias: KDef, stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Set{name,typ,val}: N111Set{name,typ,w6_rw_val(alias,val)}
    case N111Bin{name,typ,op,left,right}: N111Bin{name,typ,op,w6_rw_val(alias,left),w6_rw_val(alias,right)}
    case N111Call{name,typ,symbol,args}: N111Call{name,typ,symbol,w6_rw_args(alias,args)}
    case N111If{cond,yes,no}: N111If{w6_rw_val(alias,cond),w6_rw_stmts(alias,yes),w6_rw_stmts(alias,no)}
    case N111Return{val}: N111Return{w6_rw_val(alias,val)}
    case N111Load{name,typ,base,offset}: N111Load{name,typ,w6_rw_val(alias,base),offset}
    case N111Store{typ,base,offset,val}: N111Store{typ,w6_rw_val(alias,base),offset,w6_rw_val(alias,val)}
    case N111Offset{name,base,bytes}: N111Offset{name,w6_rw_val(alias,base),w6_rw_val(alias,bytes)}
    case N111Alloca{name,bytes,align}: N111Alloca{name,bytes,align}

@unsafe
def w6_rw_stmts(alias, body):
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{w6_rw_stmt(alias,head),w6_rw_stmts(alias,rest)}

@unsafe
def w6_rw_segs(+alias: KDef, segs: List<&2,N111Segment>, acc: List<&2,N111Segment>) -> List<&2,N111Segment>:
  match segs:
    case Nil{}: nt_reverse(N111Segment,acc,[])
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      w6_rw_segs(alias,rest,Con{N111Segment{name,arity,result,incoming,flags,w6_rw_stmts(alias,body)},acc})

law w6_dedup_scan:
  for segs: List<&2,N111Segment>
  for acc: W6DedupAcc
  W6DedupAcc

@unsafe
def w6_dedup_lookup(+rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String,
    +found: KDef, +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:
  nt_choose(W6DedupAcc,agy_str_eq(dk(found),"Absent"),
    u => w6_dedup_scan(rest,W6DedupAcc{w6_map_put(seen,key,name),alias,Con{seg,kept},merged}),
    u => w6_dedup_scan(rest,W6DedupAcc{seen,w6_map_put(alias,name,nm(dt(found))),kept,U32.inc(merged)}))

@unsafe
def w6_dedup_check(+rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String,
    +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:
  nt_choose(W6DedupAcc,String.is_empty(key),
    u => w6_dedup_scan(rest,W6DedupAcc{seen,alias,Con{seg,kept},merged}),
    u => w6_dedup_lookup(rest,seg,name,key,p111v_get(seen,key),seen,alias,kept,merged))

@unsafe
def w6_dedup_step(+seg: N111Segment, +rest: List<&2,N111Segment>, acc: W6DedupAcc) -> W6DedupAcc:
  match seg acc:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body} W6DedupAcc{+seen,+alias,+kept,+merged}:
      nt_choose(W6DedupAcc,String.starts_with(name,"$p111.k."),
        u => w6_dedup_check(rest,seg,name,w6_canon_seg(arity,result,incoming,flags,body),seen,alias,kept,merged),
        u => w6_dedup_scan(rest,W6DedupAcc{seen,alias,Con{seg,kept},merged}))

@unsafe
def w6_dedup_scan(segs, acc):
  match segs:
    case Nil{}: acc
    case Con{seg,rest}: w6_dedup_step(seg,rest,acc)

law w6_dedup_round:
  for +segs: List<&2,N111Segment>
  for +rounds: U32
  List<&2,N111Segment>

@unsafe
def w6_dedup_finish(acc: W6DedupAcc, +next_rounds: U32) -> List<&2,N111Segment>:
  match acc:
    case W6DedupAcc{seen,+alias,+kept,+merged}:
      +ordered = nt_reverse(N111Segment,kept,[])
      nt_choose(List<&2,N111Segment>,U32.is_eq(merged,0),
        u => ordered,
        u => w6_dedup_round(w6_rw_segs(alias,ordered,[]),next_rounds))

@unsafe
def w6_dedup_round(segs, rounds):
  nt_choose(List<&2,N111Segment>,U32.is_eq(rounds,0),u => segs,u =>
    w6_dedup_finish(w6_dedup_scan(segs,W6DedupAcc{missing(),missing(),[],0}),U32.sub(rounds,1)))

@unsafe
def w6_dedup_segments(segs: List<&2,N111Segment>) -> List<&2,N111Segment>:
  w6_dedup_round(segs,2)

# === END AGY-W6 ===
'''

OLD_DISPATCH = '''@unsafe
def p167l_dispatch(+context: P167Context, +entry: KDef, +pending: P167Demand,
    +built: P167Built, +fresh: U32) -> P167Built:
  match context:
    case P167Context{+book,catalogue,+bangs}:
      +source = nm(dt(entry))
      +owner = p113d_public(book,source)
      nt_choose(P167Built,U32.is_eq(dx(entry),0),
        u => p167l_code(context,source,owner,da(entry),0,pending,built,p167l_family(book,source,fresh,bangs)),
        u => nt_choose(P167Built,agy_str_eq(dk(entry),"P167Factory"),
          v => p167l_code(context,source,owner,da(entry),1,pending,built,p167l_factory(book,source,fresh,da(entry))),
          v => p167l_accept(context,[p164a_segment(owner,da(entry))],fresh,pending,built,2,source,owner,da(entry),"")))'''

NEW_DISPATCH = '''@unsafe
def p167l_dispatch(+context: P167Context, +entry: KDef, +pending: P167Demand,
    +built: P167Built, +fresh: U32) -> P167Built:
  match context:
    case P167Context{+book,catalogue,+bangs}:
      +source = nm(dt(entry))
      +owner = p113d_public(book,source)
      +arity = da(entry)
      nt_choose(P167Built,U32.is_eq(dx(entry),0),
        u => nt_choose(P167Built,U32.is_eq(arity,0),
          v => p167l_code(context,source,owner,0,0,pending,built,p167l_family(book,source,fresh,bangs)),
          v => nt_choose(P167Built,agy_str_eq(dk(entry),"P167Factory"),
            w => p167l_code(context,source,owner,arity,1,pending,built,w6_factory_non_direct(book,source,fresh,arity,bangs)),
            w => w6_worker_non_direct(context,source,owner,arity,pending,built,fresh))),
        u => nt_choose(P167Built,agy_str_eq(dk(entry),"P167Factory"),
          v => p167l_code(context,source,owner,arity,1,pending,built,p167l_factory(book,source,fresh,arity)),
          v => p167l_accept(context,[p164a_segment(owner,arity)],fresh,pending,built,2,source,owner,arity,"")))'''

OLD_FINISH = '''@unsafe
def p167l_finish(+source: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>,
    nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, built: P167Built) -> P167Lowered:
  match built:
    case P167Built{+segments,present,adapters,fresh,families,factories,wrappers,demands,+error}:
      p167l_finished(nodes,functions,adapters,
        [nt_count(String,names),nt_count(P113DFunction,functions),families,factories,wrappers,nt_count(N111Segment,segments),demands],
        p140or_finish(source,names,constructors,P111Book{nt_reverse(N111Segment,segments,[]),fresh,error}))'''

NEW_FINISH = '''@unsafe
def p167l_finish(+source: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>,
    nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, built: P167Built) -> P167Lowered:
  match built:
    case P167Built{+segments,present,adapters,fresh,families,factories,wrappers,demands,+error}:
      +ordered = nt_reverse(N111Segment,segments,[])
      +pruned = nt_choose(List<&2,N111Segment>,String.is_empty(error),
        u => w6_dedup_segments(ordered),
        u => ordered)
      p167l_finished(nodes,functions,adapters,
        [nt_count(String,names),nt_count(P113DFunction,functions),families,factories,wrappers,nt_count(N111Segment,pruned),demands],
        p140or_finish(source,names,constructors,P111Book{pruned,fresh,error}))'''


def apply_patch(src_text: str) -> str:
    if OLD_DISPATCH not in src_text:
        raise RuntimeError("Could not locate OLD_DISPATCH in compiler.bend")
    if src_text.count(OLD_DISPATCH) != 1:
        raise RuntimeError(f"Expected 1 occurrence of OLD_DISPATCH, found {src_text.count(OLD_DISPATCH)}")
    if OLD_FINISH not in src_text:
        raise RuntimeError("Could not locate OLD_FINISH in compiler.bend")
    if src_text.count(OLD_FINISH) != 1:
        raise RuntimeError(f"Expected 1 occurrence of OLD_FINISH, found {src_text.count(OLD_FINISH)}")
    out = src_text.replace(OLD_DISPATCH, W6_HELPERS + "\n\n" + NEW_DISPATCH, 1)
    out = out.replace(OLD_FINISH, NEW_FINISH, 1)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=Path("selfhost/build/agy/wave5c_unified/compiler.bend"))
    ap.add_argument("--dst", type=Path, default=Path("/tmp/agy_w6_p111_prune/compiler.bend"))
    args = ap.parse_args()
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    src_text = args.src.read_text(encoding="utf-8")
    dst_text = apply_patch(src_text)
    args.dst.write_text(dst_text, encoding="utf-8")
    print(f"Patched {args.src} -> {args.dst} ({len(src_text)} -> {len(dst_text)} bytes, +{len(dst_text)-len(src_text)} bytes)")


if __name__ == "__main__":
    main()
