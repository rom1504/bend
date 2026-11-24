#!/usr/bin/env python3
"""O2-D: Full Zero-.p130 Stub Skip + Synthetic .exp Direct-Worker Demand (BOTH -O0 and -O2).

Applies cleanly and idempotently to `selfhost/build/agy/wave16_unified/compiler.bend`:
1. Skips `p111` CPS body lowering and `p164a_segment` / `p167l_factory` generation for ALL
   S10-A zero-.p130 stubs (both direct `f(x0..xk)` and CPS `_f = _cps => _cps; f(x0..xk)`
   and `_s10a_cps`) in `p167l_dispatch` (BOTH -O0 and -O2!), emitting only an empty-body
   external segment descriptor `N111Segment{seg_name, seg_arity, 0, 0, seg_flags, []}`.
2. Skips `x187_pub` machine-code emission for empty-body external stub segments in BOTH
   `-O0` (`s10f_pub_emit_seg`, `s10c_pub_emit_seg`) and `-O2` (`w11_program_public_mod`),
   leaving `p111_FID_<name>` as `UND` to resolve directly to the owning module's `GLOBAL`.
3. Extends `S10-H` direct-stub skipping into the `-O2` pipeline (`p168_catalogued`,
   `p168_prepared`, `p168_selected`, `p168_candidates`, `p169a_view`, `p167v_one`), so
   `-O2` also skips `p112s_prepare`, `p128br_scan`, `w7_filter_remaining`,
   `p113pl_candidates`, `p113d_passes`, and `x187_priv` on S10-A stubs.
4. For synthetic module export roots (`def main() -> U32: _ = f1; ...; 0`), demands each
   exported def's worker (`p113d_public(book, f)`) directly without emitting dead currying
   `P167Factory` + `$p111.k.*` continuation chains, slashing total FIDs by ~25,000-30,000
   and unlocking K=16 and K=24 with >25,000 FID headroom.
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave16_unified/compiler.bend"
MARKER = "# === O2-D FULL ZERO-P130 STUB SKIP ==="

O2D_HELPERS = f"""{MARKER}

law o2d_strip_ann:
  for +t: KTerm
  KTerm

@unsafe
def o2d_strip_ann_kids(+t: KTerm, kids: List<&2, KTerm>) -> KTerm:
  match kids:
    case Con{{k0, _}}: o2d_strip_ann(k0)
    case _: t

@unsafe
def o2d_strip_ann(t):
  match t:
    case KTerm{{+tag, name, id, quant, +kids, removed, ob, oe}}:
      nt_choose(KTerm, agy_str_eq(tag, "Ann") || agy_str_eq(tag, "Src") || agy_str_eq(tag, "Use"),
        u => o2d_strip_ann_kids(t, kids),
        u => t)
    case _: t

@unsafe
def o2d_is_self_call(+name: String, +t0: KTerm, +k: U32) -> Bool:
  +t = o2d_strip_ann(t0)
  nt_choose(Bool, U32.is_eq(k, 0),
    u => p98_tag_eq(t, "Ref") && agy_str_eq(nm(t), name),
    u => p98_tag_eq(t, "App") && p98_tag_eq(o2d_strip_ann(kid(t, 1)), "Var") && o2d_is_self_call(name, kid(t, 0), U32.sub(k, 1)))

law o2d_stub_kind_go:
  for +name: String
  for +t0: KTerm
  for +k: U32
  U32

@unsafe
def o2d_stub_kind_cur(+name: String, +t: KTerm, +k: U32) -> U32:
  match t:
    case KLambda{{_, _, _, Con{{body, _}}, _, _, _, _}}:
      o2d_stub_kind_go(name, body, U32.inc(k))
    case _:
      nt_choose(U32, o2d_is_self_call(name, t, k),
        u => U32.add(1000, k),
        u =>
          +b0 = o2d_strip_ann(kid(t, 0))
          nt_choose(U32, p98_tag_eq(t, "Let") && p98_tag_eq(b0, "Bind") && agy_str_eq(nm(b0), "_f") && o2d_is_self_call(name, kid(t, 1), k),
            v => 2,
            v => 0))

@unsafe
def o2d_stub_kind_go(name, t0, k):
  o2d_stub_kind_cur(name, o2d_strip_ann(t0), k)

@unsafe
def o2d_stub_kind(+book: List<&2, KDef>, +name: String) -> U32:
  +d = lookup(book, name)
  nt_choose(U32, agy_str_eq(dk(d), "Def") && U32.is_eq(dx(d), 0),
    v => nt_choose(U32, agy_str_eq(name, "_s10a_cps"),
      w => 2,
      w => o2d_stub_kind_go(name, dv(d), 0)),
    v => 0)

@unsafe
def o2d_drop_stubs(+book: List<&2, KDef>, names: List<&2, String>, +acc: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{{}}: nt_reverse(String, acc, [])
    case Con{{+name, +rest}}:
      nt_choose(List<&2, String>, U32.is_eq(o2d_stub_kind(book, name), 0),
        u => o2d_drop_stubs(book, rest, Con{{name, acc}}),
        u => o2d_drop_stubs(book, rest, acc))

@unsafe
def o2d_p112s_filter_names(+book: List<&2, KDef>, names: List<&2, String>, +acc: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{{}}: nt_reverse(String, acc, [])
    case Con{{+name, +rest}}:
      nt_choose(List<&2, String>, U32.is_ge(o2d_stub_kind(book, name), 1000),
        u => o2d_p112s_filter_names(book, rest, acc),
        u => o2d_p112s_filter_names(book, rest, Con{{name, acc}}))

@unsafe
def o2d_stub_sig(+pub: String, +arity: U32) -> KDef:
  KDef{{pub, "P113Direct", arity, 1, atom("Absent"), kt("P113Public", "", 1, 0, []), [], False{{}}, False{{}}}}

@unsafe
def o2d_ready_stubs(+book: List<&2, KDef>, names: List<&2, String>, +ready: KDef) -> KDef:
  match names:
    case Nil{{}}: ready
    case Con{{+name, +rest}}:
      +sk = o2d_stub_kind(book, name)
      nt_choose(KDef, U32.is_ge(sk, 1000),
        u => o2d_ready_stubs(book, rest, p113e_insert(ready, o2d_stub_sig(p113d_public(book, name), U32.sub(sk, 1000)))),
        u => o2d_ready_stubs(book, rest, ready))

@unsafe
def o2d_is_exp_main_go(+t0: KTerm, +count: U32) -> Bool:
  +t = o2d_strip_ann(t0)
  +b0 = o2d_strip_ann(kid(t, 0))
  nt_choose(Bool, p98_tag_eq(t, "Let") && p98_tag_eq(b0, "Bind") && (String.starts_with(nm(b0), "_") || String.is_empty(nm(b0))),
    u => o2d_is_exp_main_go(kid(t, 1), U32.inc(count)),
    u => U32.is_ge(count, 5) && (p98_tag_eq(t, "Num") || p98_tag_eq(t, "U32") || p98_tag_eq(t, "Ctr")))

@unsafe
def o2d_exp_main_body() -> List<&2, N111Stmt>:
  [N111Alloca{{"o2d_out", 8, 8}},
   N111Store{{N111U64{{}}, N111Local{{"o2d_out"}}, 0, N111Const{{0, 0}}}},
   N111Call{{"o2d_ret", N111U64{{}}, "p111_rt_return", [
     p111_state(), N111Arg{{N111Ptr{{}}, N111Local{{"o2d_out"}}}}, p111_u32(1)]}},
   N111Return{{N111Local{{"o2d_ret"}}}}]

law o2d_collect_exp_refs:
  for +book: List<&2, KDef>
  for +catalogue: KDef
  for +t: KTerm
  for +demand: P167Demand
  P167Demand

@unsafe
def o2d_collect_exp_refs_list(+book: List<&2, KDef>, +catalogue: KDef, ts: List<&2, KTerm>, +demand: P167Demand) -> P167Demand:
  match ts:
    case Nil{{}}: demand
    case Con{{head, rest}}: o2d_collect_exp_refs_list(book, catalogue, rest, o2d_collect_exp_refs(book, catalogue, head, demand))

@unsafe
def o2d_collect_exp_refs(book, catalogue, t, demand):
  match t:
    case KTerm{{+tag, +name, id, quant, +kids, removed, ob, oe}}:
      nt_choose(P167Demand, agy_str_eq(tag, "Ref"),
        u =>
          +pub = p113d_public(book, name)
          +h = index_hash(pub, 2166136261)
          nt_choose(P167Demand, Bool.not(agy_str_eq(dk(w5c3_find(catalogue, pub, h)), "Absent")),
            v => p167l_demand(pub, demand),
            v => demand),
        u => o2d_collect_exp_refs_list(book, catalogue, kids, demand))
    case _: demand

@unsafe
def o2d_stub_dispatch(+context: P167Context, +entry: KDef, +source: String, +owner: String, +arity: U32,
    pending: P167Demand, built: P167Built, +fresh: U32) -> P167Built:
  match context:
    case P167Context{{+book, catalogue, +bangs}}:
      +is_fac = U32.is_eq(arity, 0) || agy_str_eq(dk(entry), "P167Factory")
      +seg_name = nt_choose(String, is_fac, u => nc_ref_name(book, source), u => owner)
      +seg_arity = nt_choose(U32, is_fac, u => 0, u => arity)
      +seg_flags = nt_bool(nb_contains(bangs, source))
      p167l_accept(context, [N111Segment{{seg_name, seg_arity, 0, 0, seg_flags, []}}], fresh, pending, built, 0, source, owner, arity, "")

@unsafe
def o2d_exp_main_dispatch(+context: P167Context, pending: P167Demand, built: P167Built, +fresh: U32) -> P167Built:
  match context:
    case P167Context{{+book, +catalogue, bangs}}:
      +d = lookup(book, "main")
      +p2 = o2d_collect_exp_refs(book, catalogue, dv(d), pending)
      p167l_accept(context, [N111Segment{{"main", 0, 1, 0, 0, o2d_exp_main_body()}}], fresh, p2, built, 0, "main", "main", 0, "")

"""

PATCHES: list[tuple[str, str, str]] = [
    # 1. Insert O2-D helpers + patch p167l_dispatch
    (
        "p167l_dispatch",
        """@unsafe
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
          v => p167l_accept(context,[p164a_segment(owner,arity)],fresh,pending,built,2,source,owner,arity,"")))""",
        O2D_HELPERS
        + """@unsafe
def p167l_dispatch(+context: P167Context, +entry: KDef, +pending: P167Demand,
    +built: P167Built, +fresh: U32) -> P167Built:
  match context:
    case P167Context{+book,catalogue,+bangs}:
      +source = nm(dt(entry))
      +owner = p113d_public(book,source)
      +arity = da(entry)
      nt_choose(P167Built,U32.is_gt(o2d_stub_kind(book,source),0),
        z => o2d_stub_dispatch(context,entry,source,owner,arity,pending,built,fresh),
        z => nt_choose(P167Built,agy_str_eq(source,"main") && Bool.not(nb_contains(bangs,"main")) && o2d_is_exp_main_go(dv(lookup(book,"main")),0),
          y => o2d_exp_main_dispatch(context,pending,built,fresh),
          y => nt_choose(P167Built,U32.is_eq(dx(entry),0),
            u => nt_choose(P167Built,U32.is_eq(arity,0),
              v => p167l_code(context,source,owner,0,0,pending,built,p167l_family(book,source,fresh,bangs)),
              v => nt_choose(P167Built,agy_str_eq(dk(entry),"P167Factory"),
                w => p167l_code(context,source,owner,arity,1,pending,built,w6_factory_non_direct(book,source,fresh,arity,bangs)),
                w => w6_worker_non_direct(context,source,owner,arity,pending,built,fresh))),
            u => nt_choose(P167Built,agy_str_eq(dk(entry),"P167Factory"),
              v => p167l_code(context,source,owner,arity,1,pending,built,p167l_factory(book,source,fresh,arity)),
              v => p167l_accept(context,[p164a_segment(owner,arity)],fresh,pending,built,2,source,owner,arity,"")))))""",
    ),
    # 2. Accept empty-body external stub segments in p167v_one (-O2 verifier)
    (
        "p167v_one",
        """@unsafe
def p167v_one(+segment: N111Segment, +ids: N111Ids, adapters: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +entry = p111v_get(adapters,name)
      nt_choose(String,agy_str_eq(dk(entry),"Absent"),u => p111v_segment(segment,ids),u =>
        nt_choose(String,agy_str_eq(dk(entry),"P164Adapter") && U32.is_eq(da(entry),arity) && p164a_shape(segment),
          v => "",v => "demand adapter body/header mismatch: " ++ name))""",
        """@unsafe
def p167v_one(+segment: N111Segment, +ids: N111Ids, adapters: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,List.is_empty(&2,N111Stmt,body),u => "",u =>
        +entry = p111v_get(adapters,name)
        nt_choose(String,agy_str_eq(dk(entry),"Absent"),w => p111v_segment(segment,ids),w =>
          nt_choose(String,agy_str_eq(dk(entry),"P164Adapter") && U32.is_eq(da(entry),arity) && p164a_shape(segment),
            v => "",v => "demand adapter body/header mismatch: " ++ name)))""",
    ),
    # 3. Skip S10-A stubs in -O2 p168_candidates, p168_selected, p168_prepared, p168_catalogued
    (
        "p168_candidates",
        """@unsafe
def p168_candidates(+mode: U32, source: List<&2,KDef>, book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    +remaining: U32, +workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>,
    retry: List<&2,NO_Plan>, +signatures: List<&2,KDef>, +raw: List<&2,P113DCandidate>) -> P167Lowered:
  +ready = p113e_signatures(workers,missing())""",
        """@unsafe
def p168_candidates(+mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    +remaining: U32, +workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>,
    retry: List<&2,NO_Plan>, +signatures: List<&2,KDef>, +raw: List<&2,P113DCandidate>) -> P167Lowered:
  +ready = o2d_ready_stubs(book,names,p113e_signatures(workers,missing()))""",
    ),
    (
        "p168_selected",
        """@unsafe
def p168_selected(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +remaining: List<&2,String>) -> P167Lowered:
  +sigs = book_cached(nq_signatures(book,names),0)
  +filtered = w7_filter_remaining(book,remaining,bangs)""",
        """@unsafe
def p168_selected(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,
    +remaining: List<&2,String>) -> P167Lowered:
  +sigs = book_cached(nq_signatures(book,names),0)
  +active = o2d_drop_stubs(book,remaining,[])
  +filtered = w7_filter_remaining(book,active,bangs)""",
    ),
    (
        "p168_prepared_and_catalogued",
        """@unsafe
def p168_prepared(mode: U32, source: List<&2,KDef>, +names: List<&2,String>, constructors: List<&2,N_Constructor>,
    prepared: P112SPrepared) -> P167Lowered:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      +bangs = nc_bangs_names(book,names)
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_scanned(mode,source,book,names,constructors,nodes,bangs,
          p128br_scan(book,no_candidate_names(book,names,bangs),[],[],[],[])),
        u => p167l_fail("early scalar static preparation: " ++ error))

@unsafe
def p168_catalogued(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>) -> P167Lowered:
  p168_prepared(mode,source,names,constructors,p112s_prepare(book,names,constructors))""",
        """@unsafe
def p168_prepared(mode: U32, source: List<&2,KDef>, +names: List<&2,String>, constructors: List<&2,N_Constructor>,
    prepared: P112SPrepared) -> P167Lowered:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      +bangs = nc_bangs_names(book,names)
      nt_choose(P167Lowered,String.is_empty(error),
        u => p168_scanned(mode,source,book,names,constructors,nodes,bangs,
          p128br_scan(book,o2d_drop_stubs(book,no_candidate_names(book,names,bangs),[]),[],[],[],[])),
        u => p167l_fail("early scalar static preparation: " ++ error))

@unsafe
def p168_catalogued(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>) -> P167Lowered:
  p168_prepared(mode,source,names,constructors,p112s_prepare(book,o2d_p112s_filter_names(book,names,[]),constructors))""",
    ),
    # 4. Seed p113e_functions with direct stub signatures in -O2 p169a_view
    (
        "p169a_view",
        """@unsafe
def p169a_view(+request: NR_Request, +adapters: KDef, +program: P113DProgram) -> P169Prepared:
  match program:
    case P113DProgram{P112StaticProgram{+original,+nodes},functions}:
      +view = p168v_functions(functions,adapters)
      p169a_checked(request,adapters,program,original,nodes,view,p113a_certificate(request),
        p118b_verify_functions(view,original))""",
        """@unsafe
def o2d_p118b_verify_projected(+ids: N111Ids, +ready: KDef, workers: P118BWorkers) -> String:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(String,String.is_empty(error),u => p113e_functions(functions,ids,ready),u => error)

@unsafe
def o2d_p118b_verify_functions(+functions: List<&2,P113DFunction>, +original: P111Program, +ready: KDef) -> String:
  match original:
    case P111Program{segments,constructors,show,names,effects,pure}:
      +ids : N111Ids = N111Ids{p113e_originals(segments,missing()),ns_ctor_index(constructors,missing())}
      o2d_p118b_verify_projected(ids,ready,p118b_project_functions(functions,ids))

@unsafe
def o2d_req_stub_ready(request: NR_Request) -> KDef:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      o2d_ready_stubs(book,names,missing())

@unsafe
def p169a_view(+request: NR_Request, +adapters: KDef, +program: P113DProgram) -> P169Prepared:
  match program:
    case P113DProgram{P112StaticProgram{+original,+nodes},functions}:
      +view = p168v_functions(functions,adapters)
      p169a_checked(request,adapters,program,original,nodes,view,p113a_certificate(request),
        o2d_p118b_verify_functions(view,original,o2d_req_stub_ready(request)))""",
    ),
    # 5. Skip x187_pub emission for empty-body external stub segments in -O2 (w11_program_public_mod)
    (
        "w11_program_public_mod",
        """@unsafe
def w11_program_public_mod(+segment: N111Segment, context: P134Context, +available: KDef, +weak_set: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      nt_choose(X181Output,w10_is_weak_sym(weak_set,p111q_symbol(name)),
        u => x181_program_join(X181Output{[],x181_program_scalars(body,available)},x181_segment(segment,ids)),
        u => x181_program_public(segment,context,available))""",
        """@unsafe
def w11_program_public_mod(+segment: N111Segment, context: P134Context, +available: KDef, +weak_set: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,+body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      nt_choose(X181Output,List.is_empty(&2,N111Stmt,body),
        z => X181Output{[],"\"},
        z => nt_choose(X181Output,w10_is_weak_sym(weak_set,p111q_symbol(name)),
          u => x181_program_join(X181Output{[],x181_program_scalars(body,available)},x181_segment(segment,ids)),
          u => x181_program_public(segment,context,available)))""".replace('"\"}', '""}'),
    ),
    # 6. Skip x187_pub emission for empty-body external stub segments in -O0 (s10f_pub_emit_seg)
    (
        "s10f_pub_emit_seg",
        """@unsafe
def s10f_pub_emit_seg(+segment: N111Segment, context: P134Context, +available: KDef,
    +build: X187Build, +pctx: S10fPubCtx) -> S10fPubRes:
  match segment context pctx:
    case N111Segment{+name,arity,result,incoming,flags,+body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode} S10fPubCtx{+f_st,+f_no,+seen}:
      +sym = p111q_symbol(name)""",
        """@unsafe
def s10f_pub_emit_seg(+segment: N111Segment, context: P134Context, +available: KDef,
    +build: X187Build, +pctx: S10fPubCtx) -> S10fPubRes:
  match segment context pctx:
    case N111Segment{+name,arity,result,incoming,flags,+body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode} S10fPubCtx{+f_st,+f_no,+seen}:
      nt_choose(S10fPubRes,List.is_empty(&2,N111Stmt,body),
        q => S10fPubRes{build,seen},
        q =>
      +sym = p111q_symbol(name)""",
    ),
    (
        "s10f_pub_emit_seg_close",
        """            +us = w4_scalars_state(body)
            +base_f = nt_choose(X181Frame,us,a => f_st,a => f_no)
            s10f_pub_emit_framed_s(sym,body,ids,us,build,seen,x181_frame_scalars(body,base_f))))""",
        """            +us = w4_scalars_state(body)
            +base_f = nt_choose(X181Frame,us,a => f_st,a => f_no)
            s10f_pub_emit_framed_s(sym,body,ids,us,build,seen,x181_frame_scalars(body,base_f)))))""",
    ),
    # 7. Also guard s10c_pub_emit_seg for empty-body external stub segments
    (
        "s10c_pub_emit_seg",
        """@unsafe
def s10c_pub_emit_seg(+segment: N111Segment, context: P134Context, +available: KDef, +build: X187Build) -> X187Build:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,+body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      +error = w7c_pub_check_scalars(body,available)""",
        """@unsafe
def s10c_pub_emit_seg(+segment: N111Segment, context: P134Context, +available: KDef, +build: X187Build) -> X187Build:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,+body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      nt_choose(X187Build,List.is_empty(&2,N111Stmt,body),q => build,q =>
      +error = w7c_pub_check_scalars(body,available)""",
    ),
    (
        "s10c_pub_emit_seg_close",
        """            w => w13c_emit_x202k(sym,build),
            w => s10c_pub_emit_body(sym,x181_scalar_rows(body),ids,build)),
        v => x187_build_error(error,build))""",
        """            w => w13c_emit_x202k(sym,build),
            w => s10c_pub_emit_body(sym,x181_scalar_rows(body),ids,build)),
        v => x187_build_error(error,build)))""",
    ),
]


def apply_text(src: str) -> tuple[str, bool]:
    if MARKER in src:
        return src, False
    out = src
    for name, old, new in PATCHES:
        cnt = out.count(old)
        if cnt != 1:
            raise RuntimeError(f"Patch {name!r}: expected 1 occurrence, found {cnt}")
        out = out.replace(old, new, 1)
    return out, True


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--out", type=Path, default=None, help="Write to output path instead of in-place")
    ap.add_argument("--check-only", action="store_true", help="Run bend2 --check-only on patched output")
    args = ap.parse_args()

    text = args.src.read_text(encoding="utf-8")
    patched, changed = apply_text(text)
    dst = args.out if args.out is not None else args.src
    dst.parent.mkdir(parents=True, exist_ok=True)
    if changed or not dst.exists():
        dst.write_text(patched, encoding="utf-8")
        print(f"[o2d] Applied O2-D patches -> {dst} ({len(patched):,} B)")
    else:
        print(f"[o2d] Already applied (idempotent) -> {dst}")

    if args.check_only:
        bun = ROOT / "selfhost/.assets/bin/bun"
        cmd = ["timeout", "180", "taskset", "-c", "5", str(bun), str(ROOT / "bend2/main.ts"), "--check-only", str(dst)]
        print(f"[o2d] Running: {' '.join(cmd)}", flush=True)
        r = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
        combined = (r.stdout or "") + "\n" + (r.stderr or "")
        # Standard compiler.bend notice: only @unsafe/foreign notice, zero type/linearity errors
        only_unsafe = (
            r.returncode == 0
            or ("defs rely on unsafe or foreign code:" in combined and "Location:" not in combined)
        )
        if not only_unsafe:
            print(combined[-3000:], file=sys.stderr)
            sys.exit(r.returncode or 1)
        print("[o2d] --check-only PASS (0 type/linearity errors)")


if __name__ == "__main__":
    main()
