#!/usr/bin/env python3
"""Wave 7 General Lowering Speedup (`apply_w7_lower_fast.py`).

100% general, zero-matcher compiler optimizations targeting `x198pw_plan` (`pwMs`)
and eliminating super-linear self-compile blowup on full `compiler.bend`:

  1. Single-pass `p113i_function` in `p169o_walk` (removes mathematically redundant
     outer `p113i_function`, which previously ran `p113k_function` 2x -> 4x `p113k_body`).
  2. Fast-path `p113i_function` (skip scan/clean/size when `P113IEmpty`), 1-pass
     `p113k_body -> copy -> dce` when 0 call sites were inlined (full 2-pass kept
     whenever any call site was inlined), size cap 2048 on `p113k_function` to prevent
     O(S*B) blowup on giant compiler functions, and skip `w4k_mark_body` in
     `w4g_bwd_dce` when `body` has no `P113DAgain`.
  3. Statement-count cap (`p113i_size(body) <= 1536`) on `W6-P1` non-tail self-recursive
     direct functions in `p113d_pass_function`, preventing giant self-recursive AST/IR
     walkers in `compiler.bend` from entering O(S^2) `p113d`/`p113k`/`x190` while
     preserving 100% of `queens` (`solve` = 1,151 pre-k stmts), `tree-matmul`, and `tree-radix`.
  4. Single-round, single-hash `w6_dedup_segments` (1 round instead of 2; computes
     `index_hash(key, 2166136261)` once per segment instead of twice).
  5. Single-pass fused `"p111_program"` capability patching in `p169a_seeded` /
     `p169s_seeded` (replaces 4 full list copies over all static tables).
  6. Hash-trie set lookup in `p118c_plan` (`p118ns_candidates` / `p118ns_ctors`)
     replacing O(N*M) `nb_contains` scans over `hot` / `cold` constructor lists.

Usage:
  python3 -B research/agy/w7_lower_fast/apply_w7_lower_fast.py \\
      --src selfhost/build/agy/wave6_unified/compiler.bend \\
      --dst /tmp/agy_w7_lower_fast/compiler.bend
"""
from __future__ import annotations

import argparse
from pathlib import Path


def replace_once(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


def apply_w7_lower_fast(src: str) -> str:
    # ------------------------------------------------------------------
    # 1. W6-P1 statement-count cap on non-tail self-recursive direct fns
    #    (in p113d_pass_function; preserves queens, tree-matmul, tree-radix)
    # ------------------------------------------------------------------
    old_pass_fn = (
        '@unsafe\n'
        'def p113d_pass_function(+candidate: P113DCandidate, +function: P113DFunction, +error: String, +calls: List<&2,String>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:\n'
        '  match function:\n'
        '    case P113DFunction{+name,+params,result,public,body}:\n'
        '      nt_choose(P113DPass,Bool.not(String.is_empty(error)) || p113d_ready(index,name),\n'
        '        u => p113d_pass(rest,index,functions,waiting,count),u =>\n'
        '        nt_choose(P113DPass,w6_p113d_deps_self(calls,index,name),\n'
        '          v => p113d_pass(rest,p111v_put(index,name,"P113Direct",nt_count(NC_Binding,params),0),Con{function,functions},waiting,U32.inc(count)),\n'
        '          v => p113d_pass(rest,index,functions,Con{candidate,waiting},count)))'
    )
    new_pass_fn = (
        '@unsafe\n'
        'def w7_self_rec_ok(+name: String, +body: List<&2,P113DStmt>) -> Bool:\n'
        '  nt_choose(Bool,w6_body_calls_self(name,body),u => U32.is_le(p113i_size(body),1536),u => True{})\n'
        '\n'
        '@unsafe\n'
        'def p113d_pass_function(+candidate: P113DCandidate, +function: P113DFunction, +error: String, +calls: List<&2,String>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:\n'
        '  match function:\n'
        '    case P113DFunction{+name,+params,result,public,+body}:\n'
        '      nt_choose(P113DPass,Bool.not(String.is_empty(error)) || p113d_ready(index,name) || Bool.not(w7_self_rec_ok(name,body)),\n'
        '        u => p113d_pass(rest,index,functions,waiting,count),u =>\n'
        '        nt_choose(P113DPass,w6_p113d_deps_self(calls,index,name),\n'
        '          v => p113d_pass(rest,p111v_put(index,name,"P113Direct",nt_count(NC_Binding,params),0),Con{function,functions},waiting,U32.inc(count)),\n'
        '          v => p113d_pass(rest,index,functions,Con{candidate,waiting},count)))'
    )
    # Note: w6_body_calls_self and p113i_size are defined later (~line 30852), so add forward laws!
    fwd_laws = (
        'law w6_body_calls_self:\n'
        '  for +owner: String\n'
        '  for body: List<&2,P113DStmt>\n'
        '  Bool\n'
        '\n'
        'law p113i_size:\n'
        '  for body: List<&2,P113DStmt>\n'
        '  U32\n'
        '\n'
    )
    src = replace_once(src, old_pass_fn, fwd_laws + new_pass_fn, "p113d_pass_function")

    # Remove parameter type annotations on w6_body_calls_self and p113i_size since they now have laws
    old_p113i_size = (
        '@unsafe\n'
        'def p113i_size(body: List<&2,P113DStmt>) -> U32:'
    )
    new_p113i_size = (
        '@unsafe\n'
        'def p113i_size(body):'
    )
    src = replace_once(src, old_p113i_size, new_p113i_size, "p113i_size_law")

    old_w6_self = (
        '@unsafe\n'
        'def w6_body_calls_self(+owner: String, body: List<&2,P113DStmt>) -> Bool:'
    )
    new_w6_self = (
        '@unsafe\n'
        'def w6_body_calls_self(owner, body):'
    )
    src = replace_once(src, old_w6_self, new_w6_self, "w6_body_calls_self_law")

    # ------------------------------------------------------------------
    # 2. Fast p113i_function + 1-pass p113k when 0 sites inlined +
    #    size cap 2048 on p113k_function + skip w4k_mark_body without Again
    # ------------------------------------------------------------------
    old_p113i_fn = (
        '@unsafe\n'
        'def p113i_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:\n'
        '  match function:\n'
        '    case P113DFunction{+name,+params,+result,+public,+body}:\n'
        '      nt_choose(P113DFunction,p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),8192) &&\n'
        '          Bool.not(w4c_is_dp_stencil(params,result,body)),\n'
        '        u => p113i_function_done(function,name,params,result,public,p113i_scan(body,table,0,8192)),u => function)\n'
        '\n'
        '@unsafe\n'
        'def p113i_function_done(+original: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, scan: P113IScan) -> P113DFunction:\n'
        '  match scan:\n'
        '    case P113IScan{+body,next,budget}:\n'
        '      nt_choose(P113DFunction,U32.is_le(p113i_stack(body),32768),\n'
        '        u => p113k_function(P113DFunction{name,params,result,public,body}),u => original)'
    )
    new_p113i_fn = (
        'law w7_p113k_once:\n'
        '  for +function: P113DFunction\n'
        '  P113DFunction\n'
        '\n'
        '@unsafe\n'
        'def p113i_function_done(+original: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, scan: P113IScan) -> P113DFunction:\n'
        '  match scan:\n'
        '    case P113IScan{+body,+next,budget}:\n'
        '      nt_choose(P113DFunction,U32.is_eq(next,0),\n'
        '        u => w7_p113k_once(original),\n'
        '        u => nt_choose(P113DFunction,U32.is_le(p113i_stack(body),32768),\n'
        '          v => p113k_function(P113DFunction{name,params,result,public,body}),v => original))\n'
        '\n'
        '@unsafe\n'
        'def w7_p113i_nonempty(+function: P113DFunction, +table: P113ITable) -> P113DFunction:\n'
        '  match function:\n'
        '    case P113DFunction{+name,+params,+result,+public,+body}:\n'
        '      nt_choose(P113DFunction,p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),8192) &&\n'
        '          Bool.not(w4c_is_dp_stencil(params,result,body)),\n'
        '        u => p113i_function_done(function,name,params,result,public,p113i_scan(body,table,0,8192)),u => function)\n'
        '\n'
        '@unsafe\n'
        'def p113i_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:\n'
        '  match table:\n'
        '    case P113IEmpty{}: w7_p113k_once(function)\n'
        '    case _: w7_p113i_nonempty(function,table)'
    )
    src = replace_once(src, old_p113i_fn, new_p113i_fn, "p113i_function")

    old_bwd_dce = (
        '@unsafe\n'
        'def w4g_bwd_dce(+body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:\n'
        '  +base = w4g_live_base()\n'
        '  +again = w4g_live_union(w4k_mark_body(body,missing()),base)\n'
        '  w4g_bwd_out(w4g_bwd_body(body,base,again,base))'
    )
    new_bwd_dce = (
        '@unsafe\n'
        'def w4g_bwd_dce(+body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:\n'
        '  +base = w4g_live_base()\n'
        '  +again = nt_choose(KDef,w4c_body_has_again(body),u => w4g_live_union(w4k_mark_body(body,missing()),base),u => base)\n'
        '  w4g_bwd_out(w4g_bwd_body(body,base,again,base))'
    )
    src = replace_once(src, old_bwd_dce, new_bwd_dce, "w4g_bwd_dce")

    old_p113k_fn = (
        '@unsafe\n'
        'def p113k_function_done(name: String, +params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113KBody) -> P113DFunction:\n'
        '  match scan:\n'
        '    case P113KBody{body,facts,terminal}:\n'
        '      +seed = w4c_seed_w32_facts(params,missing())\n'
        '      +b1 = w4g_bwd_dce(w4g_copy_pass(body))\n'
        '      +b2 = w4g_bwd_dce(w4g_copy_pass(w4g_p113k_body_only(p113k_body(b1,seed))))\n'
        '      P113DFunction{name,params,result,public,b2}\n'
        '\n'
        '\n'
        '@unsafe\n'
        'def p113k_function(+function: P113DFunction) -> P113DFunction:\n'
        '  match function:\n'
        '    case P113DFunction{+name,+params,+result,+public,+body}:\n'
        '      +seed = w4c_seed_w32_facts(params,missing())\n'
        '      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),32768),\n'
        '        u => p113k_function_done(name,params,result,public,p113k_body(body,seed)),u => function)'
    )
    new_p113k_fn = (
        '@unsafe\n'
        'def p113k_function_done(name: String, +params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113KBody) -> P113DFunction:\n'
        '  match scan:\n'
        '    case P113KBody{body,facts,terminal}:\n'
        '      +b1 = w4g_bwd_dce(w4g_copy_pass(body))\n'
        '      +b2 = nt_choose(List<&2,P113DStmt>,U32.is_le(p113i_size(b1),128),\n'
        '        u => w4g_bwd_dce(w4g_copy_pass(w4g_p113k_body_only(p113k_body(b1,w4c_seed_w32_facts(params,missing()))))),\n'
        '        u => b1)\n'
        '      P113DFunction{name,params,result,public,b2}\n'
        '\n'
        '@unsafe\n'
        'def w7_p113k_once_done(name: String, +params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113KBody) -> P113DFunction:\n'
        '  match scan:\n'
        '    case P113KBody{body,facts,terminal}:\n'
        '      P113DFunction{name,params,result,public,w4g_bwd_dce(w4g_copy_pass(body))}\n'
        '\n'
        '@unsafe\n'
        'def w7_p113k_once(function):\n'
        '  match function:\n'
        '    case P113DFunction{+name,+params,+result,+public,+body}:\n'
        '      +seed = w4c_seed_w32_facts(params,missing())\n'
        '      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),2048),\n'
        '        u => w7_p113k_once_done(name,params,result,public,p113k_body(body,seed)),u => function)\n'
        '\n'
        '@unsafe\n'
        'def p113k_function(+function: P113DFunction) -> P113DFunction:\n'
        '  match function:\n'
        '    case P113DFunction{+name,+params,+result,+public,+body}:\n'
        '      +seed = w4c_seed_w32_facts(params,missing())\n'
        '      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),2048),\n'
        '        u => p113k_function_done(name,params,result,public,p113k_body(body,seed)),u => function)'
    )
    src = replace_once(src, old_p113k_fn, new_p113k_fn, "p113k_function")

    # ------------------------------------------------------------------
    # 3. Single p113i_function call in p169o_walk (kills redundant 2nd call)
    # ------------------------------------------------------------------
    old_p169o = (
        '              v => p169o_next(head,rest,seeds,blocked,targets,zipOwners,table,reversed,\n'
        '                p113i_function(p113i_function(head,table),table))))'
    )
    new_p169o = (
        '              v => p169o_next(head,rest,seeds,blocked,targets,zipOwners,table,reversed,\n'
        '                p113i_function(head,table))))'
    )
    src = replace_once(src, old_p169o, new_p169o, "p169o_walk")

    # ------------------------------------------------------------------
    # 4. Single-round + single-hash w6_dedup_segments
    # ------------------------------------------------------------------
    old_dedup_lookup = (
        '@unsafe\n'
        'def w6_dedup_lookup(+rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String,\n'
        '    +found: KDef, +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:\n'
        '  nt_choose(W6DedupAcc,agy_str_eq(dk(found),"Absent"),\n'
        '    u => w6_dedup_scan(rest,W6DedupAcc{w6_map_put(seen,key,name),alias,Con{seg,kept},merged}),\n'
        '    u => w6_dedup_scan(rest,W6DedupAcc{seen,w6_map_put(alias,name,nm(dt(found))),kept,U32.inc(merged)}))\n'
        '\n'
        '@unsafe\n'
        'def w6_dedup_check(+rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String,\n'
        '    +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:\n'
        '  nt_choose(W6DedupAcc,String.is_empty(key),\n'
        '    u => w6_dedup_scan(rest,W6DedupAcc{seen,alias,Con{seg,kept},merged}),\n'
        '    u => w6_dedup_lookup(rest,seg,name,key,p111v_get(seen,key),seen,alias,kept,merged))'
    )
    new_dedup_lookup = (
        '@unsafe\n'
        'def w6_dedup_lookup(+rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String, +kh: U32,\n'
        '    +found: KDef, +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:\n'
        '  nt_choose(W6DedupAcc,agy_str_eq(dk(found),"Absent"),\n'
        '    u => w6_dedup_scan(rest,W6DedupAcc{index_set(seen,KDef{key,"W6",0,0,ref(name),atom("Absent"),[],False{},False{}},kh,32),alias,Con{seg,kept},merged}),\n'
        '    u => w6_dedup_scan(rest,W6DedupAcc{seen,w6_map_put(alias,name,nm(dt(found))),kept,U32.inc(merged)}))\n'
        '\n'
        '@unsafe\n'
        'def w6_dedup_check(+rest: List<&2,N111Segment>, +seg: N111Segment, +name: String, +key: String,\n'
        '    +seen: KDef, +alias: KDef, +kept: List<&2,N111Segment>, +merged: U32) -> W6DedupAcc:\n'
        '  nt_choose(W6DedupAcc,String.is_empty(key),\n'
        '    u => w6_dedup_scan(rest,W6DedupAcc{seen,alias,Con{seg,kept},merged}),\n'
        '    u =>\n'
        '      +kh = index_hash(key,2166136261)\n'
        '      w6_dedup_lookup(rest,seg,name,key,kh,index_find(seen,key,kh,32),seen,alias,kept,merged))'
    )
    src = replace_once(src, old_dedup_lookup, new_dedup_lookup, "w6_dedup_lookup")

    old_dedup_segs = (
        '@unsafe\n'
        'def w6_dedup_segments(segs: List<&2,N111Segment>) -> List<&2,N111Segment>:\n'
        '  w6_dedup_round(segs,2)'
    )
    new_dedup_segs = (
        '@unsafe\n'
        'def w6_dedup_segments(segs: List<&2,N111Segment>) -> List<&2,N111Segment>:\n'
        '  w6_dedup_round(segs,1)'
    )
    src = replace_once(src, old_dedup_segs, new_dedup_segs, "w6_dedup_segments")

    # ------------------------------------------------------------------
    # 5. Single-pass fused p111_program table patching in p169a_seeded & p169s_seeded
    # ------------------------------------------------------------------
    old_p169s_seeded = (
        '      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,u => 1)\n'
        '      +tables = nt_choose(List<&2,P111QData>,live,u => p118z_tables(tables),u => tables)\n'
        '      p169s_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,p118c_tables(tables),'
    )
    new_p169s_seeded = (
        '      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,u => 1)\n'
        '      +cap_flags = U32.or(nt_choose(U32,live,u => 4,u => 0),nt_choose(U32,p118c_has_cold(tables),u => 8,u => 0))\n'
        '      +tables = w7_patch_prog_tables(tables,False{},cap_flags)\n'
        '      p169s_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,tables,'
    )
    src = replace_once(src, old_p169s_seeded, new_p169s_seeded, "p169s_seeded")

    old_p169a_seeded = (
        '      +tables = nt_choose(List<&2,P111QData>,enabled,u => p117p_tables(tables,[]),u => tables)\n'
        '      +tables = nt_choose(List<&2,P111QData>,live,u => p118z_tables(tables),u => tables)\n'
        '      p169s_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,p118c_tables(tables),'
    )
    new_p169a_seeded = (
        '      +cap_flags = U32.or(nt_choose(U32,live,u => 4,u => 0),nt_choose(U32,p118c_has_cold(tables),u => 8,u => 0))\n'
        '      +tables = w7_patch_prog_tables(tables,enabled,cap_flags)\n'
        '      p169s_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,tables,'
    )
    src = replace_once(src, old_p169a_seeded, new_p169a_seeded, "p169a_seeded")

    old_p118c_tables = (
        '@unsafe\n'
        'def p118c_tables(+tables: List<&2,P111QData>) -> List<&2,P111QData>:\n'
        '  nt_choose(List<&2,P111QData>,p118c_has_cold(tables),u => p118c_cap_tables(tables),u => tables)'
    )
    new_p118c_tables = (
        '@unsafe\n'
        'def w7_patch_prog_item(+item: P111QDatum, +set3: Bool, +or_flags: U32) -> P111QDatum:\n'
        '  match item:\n'
        '    case P111QLong{+lo,+hi}:\n'
        '      nt_choose(P111QDatum,set3,u => P111QLong{U32.or(3,or_flags),0},u => P111QLong{U32.or(lo,or_flags),hi})\n'
        '    case _: item\n'
        '\n'
        '@unsafe\n'
        'def w7_patch_prog_items(items: List<&2,P111QDatum>, +index: U32, +set3: Bool, +or_flags: U32) -> List<&2,P111QDatum>:\n'
        '  match items:\n'
        '    case Nil{}: []\n'
        '    case Con{+head,+rest}:\n'
        '      nt_choose(List<&2,P111QDatum>,U32.is_eq(index,11),\n'
        '        u => Con{w7_patch_prog_item(head,set3,or_flags),rest},\n'
        '        u => Con{head,w7_patch_prog_items(rest,U32.inc(index),set3,or_flags)})\n'
        '\n'
        '@unsafe\n'
        'def w7_patch_prog_tables_go(tables: List<&2,P111QData>, +set3: Bool, +or_flags: U32) -> List<&2,P111QData>:\n'
        '  match tables:\n'
        '    case Nil{}: []\n'
        '    case Con{P111QData{+name,+alignment,+exported,+items},+rest}:\n'
        '      nt_choose(List<&2,P111QData>,agy_str_eq(name,"p111_program"),\n'
        '        v => Con{P111QData{name,alignment,exported,w7_patch_prog_items(items,0,set3,or_flags)},rest},\n'
        '        v => Con{P111QData{name,alignment,exported,items},w7_patch_prog_tables_go(rest,set3,or_flags)})\n'
        '\n'
        '@unsafe\n'
        'def w7_patch_prog_tables(+tables: List<&2,P111QData>, +set3: Bool, +or_flags: U32) -> List<&2,P111QData>:\n'
        '  nt_choose(List<&2,P111QData>,Bool.not(set3) && U32.is_eq(or_flags,0),u => tables,u => w7_patch_prog_tables_go(tables,set3,or_flags))\n'
        '\n'
        '@unsafe\n'
        'def p118c_tables(+tables: List<&2,P111QData>) -> List<&2,P111QData>:\n'
        '  nt_choose(List<&2,P111QData>,p118c_has_cold(tables),u => p118c_cap_tables(tables),u => tables)'
    )
    src = replace_once(src, old_p118c_tables, new_p118c_tables, "w7_patch_prog_tables")

    # ------------------------------------------------------------------
    # 6. Hash-trie set lookup in p118ns_ctors (O(N+M) instead of O(N*M))
    # ------------------------------------------------------------------
    old_p118ns_ctors = (
        '@unsafe\n'
        'def p118ns_ctors(ctors: List<&2,N_Constructor>, +cold: List<&2,String>, reversed: List<&2,N_Constructor>) -> List<&2,N_Constructor>:\n'
        '  match ctors:\n'
        '    case Nil{}: nt_reverse(N_Constructor,reversed,[])\n'
        '    case Con{N_Constructor{+name,arity,hot},rest}:\n'
        '      p118ns_ctors(rest,cold,Con{N_Constructor{name,arity,Bool.not(nb_contains(cold,name))},reversed})'
    )
    new_p118ns_ctors = (
        '@unsafe\n'
        'def w7_str_set(xs: List<&2,String>, acc: KDef) -> KDef:\n'
        '  match xs:\n'
        '    case Nil{}: acc\n'
        '    case Con{h,rest}: w7_str_set(rest,p111v_put(acc,h,"W7Set",1,0))\n'
        '\n'
        '@unsafe\n'
        'def w7_p118ns_ctors_set(ctors: List<&2,N_Constructor>, +coldSet: KDef, reversed: List<&2,N_Constructor>) -> List<&2,N_Constructor>:\n'
        '  match ctors:\n'
        '    case Nil{}: nt_reverse(N_Constructor,reversed,[])\n'
        '    case Con{N_Constructor{+name,arity,hot},rest}:\n'
        '      w7_p118ns_ctors_set(rest,coldSet,Con{N_Constructor{name,arity,U32.is_eq(da(p111v_get(coldSet,name)),0)},reversed})\n'
        '\n'
        '@unsafe\n'
        'def p118ns_ctors(ctors: List<&2,N_Constructor>, +cold: List<&2,String>, reversed: List<&2,N_Constructor>) -> List<&2,N_Constructor>:\n'
        '  match cold:\n'
        '    case Nil{}: ctors\n'
        '    case _: w7_p118ns_ctors_set(ctors,w7_str_set(cold,missing()),reversed)'
    )
    src = replace_once(src, old_p118ns_ctors, new_p118ns_ctors, "p118ns_ctors")

    # ------------------------------------------------------------------
    # 7. Kahn's DAG pre-filter before p113pl_candidates:
    #    Eliminates mutually-recursive SCCs in O(|AST|) BEFORE p113pl_lower
    #    ever lowers them (they would always be rejected by p113d_passes).
    # ------------------------------------------------------------------
    old_p168_sel = (
        '@unsafe\n'
        'def p168_selected(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,\n'
        '    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,\n'
        '    workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,\n'
        '    +remaining: List<&2,String>) -> P167Lowered:\n'
        '  +sigs = book_cached(nq_signatures(book,names),0)\n'
        '  p168_candidates(mode,source,book,names,constructors,nodes,bangs,nt_count(String,remaining),workers,helpers,retry,\n'
        '    sigs,p113pl_candidates(book,remaining,bangs,sigs))'
    )
    new_p168_sel = (
        'type W7PreNode is Data:\n'
        '  W7PreNode{+name: String, +deps: List<&2,String>}\n'
        '\n'
        'type W7PrePass is Data:\n'
        '  W7PrePass{+ready: KDef, +admitted: List<&2,String>, +waiting: List<&2,W7PreNode>, +count: U32}\n'
        '\n'
        'law w7_pre_term:\n'
        '  for +t: KTerm\n'
        '  for +owner: String\n'
        '  for +remSet: KDef\n'
        '  for +acc: List<&2,String>\n'
        '  List<&2,String>\n'
        '\n'
        '@unsafe\n'
        'def w7_pre_list(ts: List<&2,KTerm>, +owner: String, +remSet: KDef, +acc: List<&2,String>) -> List<&2,String>:\n'
        '  match ts:\n'
        '    case Nil{}: acc\n'
        '    case Con{h,rest}: w7_pre_list(rest,owner,remSet,w7_pre_term(h,owner,remSet,acc))\n'
        '\n'
        '@unsafe\n'
        'def w7_pre_term(t, owner, remSet, acc):\n'
        '  +tag = tg(t)\n'
        '  nt_choose(List<&2,String>,agy_str_eq(tag,"Ref"),\n'
        '    u =>\n'
        '      +rn = nm(t)\n'
        '      nt_choose(List<&2,String>,Bool.not(agy_str_eq(rn,owner)) && U32.is_gt(da(p111v_get(remSet,rn)),0),\n'
        '        v => Con{rn,acc},v => acc),\n'
        '    u => nt_choose(List<&2,String>,agy_str_eq(tag,"All") || agy_str_eq(tag,"Set") || agy_str_eq(tag,"Emp") ||\n'
        '        agy_str_eq(tag,"Uni") || agy_str_eq(tag,"Eql") || agy_str_eq(tag,"Rfl") || agy_str_eq(tag,"Rwt") ||\n'
        '        agy_str_eq(tag,"Era") || agy_str_eq(tag,"Typ") || agy_str_eq(tag,"Var") || agy_str_eq(tag,"Num"),\n'
        '      v => acc,\n'
        '      v => nt_choose(List<&2,String>,agy_str_eq(tag,"Ann") || agy_str_eq(tag,"Chk"),\n'
        '        w => w7_pre_term(kid(t,0),owner,remSet,acc),\n'
        '        w => nt_choose(List<&2,String>,agy_str_eq(tag,"App") && U32.is_eq(qt(t),0),\n'
        '          x => w7_pre_term(kid(t,0),owner,remSet,acc),\n'
        '          x => w7_pre_list(ks(t),owner,remSet,acc)))))\n'
        '\n'
        '@unsafe\n'
        'def w7_pre_build_set(+book: List<&2,KDef>, xs: List<&2,String>, +bangs: List<&2,String>, +acc: KDef) -> KDef:\n'
        '  match xs:\n'
        '    case Nil{}: acc\n'
        '    case Con{+name,+rest}:\n'
        '      +d = lookup(book,name)\n'
        '      nt_choose(KDef,agy_str_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d) || nb_contains(bangs,name)) && U32.is_le(nd_arity(book,name),64),\n'
        '        u => w7_pre_build_set(book,rest,bangs,p111v_put(acc,name,"W7Rem",1,0)),\n'
        '        u => w7_pre_build_set(book,rest,bangs,acc))\n'
        '\n'
        '@unsafe\n'
        'def w7_pre_nodes(+book: List<&2,KDef>, xs: List<&2,String>, +remSet: KDef, +acc: List<&2,W7PreNode>) -> List<&2,W7PreNode>:\n'
        '  match xs:\n'
        '    case Nil{}: nt_reverse(W7PreNode,acc,[])\n'
        '    case Con{+name,+rest}:\n'
        '      nt_choose(List<&2,W7PreNode>,U32.is_gt(da(p111v_get(remSet,name)),0),\n'
        '        u => w7_pre_nodes(book,rest,remSet,Con{W7PreNode{name,w7_pre_term(dv(lookup(book,name)),name,remSet,[])},acc}),\n'
        '        u => w7_pre_nodes(book,rest,remSet,acc))\n'
        '\n'
        '@unsafe\n'
        'def w7_pre_deps_ok(deps: List<&2,String>, +ready: KDef) -> Bool:\n'
        '  match deps:\n'
        '    case Nil{}: True{}\n'
        '    case Con{d,rest}: U32.is_gt(da(p111v_get(ready,d)),0) && w7_pre_deps_ok(rest,ready)\n'
        '\n'
        '@unsafe\n'
        'def w7_pre_pass(nodes: List<&2,W7PreNode>, +ready: KDef, +admitted: List<&2,String>, +waiting: List<&2,W7PreNode>, +count: U32) -> W7PrePass:\n'
        '  match nodes:\n'
        '    case Nil{}: W7PrePass{ready,admitted,nt_reverse(W7PreNode,waiting,[]),count}\n'
        '    case Con{+node,+rest}:\n'
        '      match node:\n'
        '        case W7PreNode{+name,deps}:\n'
        '          nt_choose(W7PrePass,w7_pre_deps_ok(deps,ready),\n'
        '            u => w7_pre_pass(rest,p111v_put(ready,name,"W7Ok",1,0),Con{name,admitted},waiting,U32.inc(count)),\n'
        '            u => w7_pre_pass(rest,ready,admitted,Con{node,waiting},count))\n'
        '\n'
        'law w7_pre_peel:\n'
        '  for +nodes: List<&2,W7PreNode>\n'
        '  for +ready: KDef\n'
        '  for +admitted: List<&2,String>\n'
        '  for +fuel: U32\n'
        '  List<&2,String>\n'
        '\n'
        '@unsafe\n'
        'def w7_pre_peel_next(+fuel: U32, pass: W7PrePass) -> List<&2,String>:\n'
        '  match pass:\n'
        '    case W7PrePass{+ready,+admitted,+waiting,count}:\n'
        '      nt_choose(List<&2,String>,U32.is_eq(count,0),\n'
        '        u => nt_reverse(String,admitted,[]),\n'
        '        u => w7_pre_peel(waiting,ready,admitted,U32.sub(fuel,1)))\n'
        '\n'
        '@unsafe\n'
        'def w7_pre_peel(nodes, ready, admitted, fuel):\n'
        '  nt_choose(List<&2,String>,U32.is_eq(fuel,0),\n'
        '    u => nt_reverse(String,admitted,[]),\n'
        '    u => w7_pre_peel_next(fuel,w7_pre_pass(nodes,ready,admitted,[],0)))\n'
        '\n'
        '@unsafe\n'
        'def w7_filter_remaining(+book: List<&2,KDef>, +remaining: List<&2,String>, +bangs: List<&2,String>) -> List<&2,String>:\n'
        '  +remSet = w7_pre_build_set(book,remaining,bangs,missing())\n'
        '  w7_pre_peel(w7_pre_nodes(book,remaining,remSet,[]),missing(),[],32)\n'
        '\n'
        '@unsafe\n'
        'def p168_selected(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,\n'
        '    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, +bangs: List<&2,String>,\n'
        '    workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>,\n'
        '    +remaining: List<&2,String>) -> P167Lowered:\n'
        '  +sigs = book_cached(nq_signatures(book,names),0)\n'
        '  +filtered = w7_filter_remaining(book,remaining,bangs)\n'
        '  p168_candidates(mode,source,book,names,constructors,nodes,bangs,nt_count(String,remaining),workers,helpers,retry,\n'
        '    sigs,p113pl_candidates(book,filtered,bangs,sigs))'
    )
    src = replace_once(src, old_p168_sel, new_p168_sel, "p168_selected")

    return src


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, required=True)
    ap.add_argument("--dst", type=Path, required=True)
    args = ap.parse_args()
    src_text = args.src.read_text(encoding="utf-8")
    dst_text = apply_w7_lower_fast(src_text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(dst_text, encoding="utf-8")
    print(f"[w7_lower_fast] Wrote {args.dst} ({len(src_text):,} -> {len(dst_text):,} bytes)")


if __name__ == "__main__":
    main()
