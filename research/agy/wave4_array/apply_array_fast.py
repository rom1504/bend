#!/usr/bin/env python3
"""Wave 4 Phase 1 Track W4-2: Per-Function / Runtime-Guarded p113a Array Fast-Path + p117v Array LICM.

Composable patcher transforming `wave3b_unified/compiler.bend` -> `wave4_array/compiler.bend`:
  1. Lift `p113a_enabled` from whole-program `scalar && unshared` to `scalar`:
     - `NATIVE_SCALAR_ARRAYS` (`capabilities & 2`) depends ONLY on `ns_definitions` (`scalar`),
       independent of handle sharing (`runtime.c:1292`).
     - Programs with `Array.fork`/`Array.join` or parallel forks (`histogram`, `editdist`) now
       enable `mode = 2`, packed 4-byte `TAG_BUF` arrays, `p113a`, `p117h`, and `p117v`.
  2. Extend `p113a_template` and `p117h_metadata` to admit BOTH raw `TAG_BUF` (`tag == 4`) and
     RFC-wrapped `TAG_BUF` (`tag == 0x84`, `term_tag == 4 && term_rfc == 1`), resolving the
     backing heap location via `rfc_cell >> 24` (hoisted once out of inner loops by `p117h`/`p117v`).
     Non-`TAG_BUF` (`TAG_ARR`, static arrays, invalid handles) transparently fall back to the
     original runtime call (`p113_rt_array_pair` / `p111_rt_op`).
  3. Sink cold `scratch` argument stores into the slow fallback branch in `p113a_scan`,
     `p117h_rewrite`, and `p117v_rewrite` (eliminating 2-3 dead stack stores per array op on
     the hot path in `p113a`/`p117h` and 100% of them in `p117v`).
"""
import argparse
from pathlib import Path

DEFAULT_SRC = Path("/home/ai/bend2_agy/selfhost/build/agy/wave3b_unified/compiler.bend")
DEFAULT_DST = Path("/home/ai/bend2_agy/selfhost/build/agy/wave4_array/compiler.bend")


def once(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


OLD_ENABLED = """@unsafe
def p113a_enabled(certificate: P113ACertificate) -> Bool:
  match certificate:
    case P113ACertificate{scalar,unshared}: scalar && unshared"""

NEW_ENABLED = """@unsafe
def p113a_enabled(certificate: P113ACertificate) -> Bool:
  match certificate:
    case P113ACertificate{scalar,unshared}: scalar"""


OLD_TEMPLATE = """@unsafe
def p113a_template(+original: N111Stmt, +n: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{+destination,N111U64{},+symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_choose(List<&2,N111Stmt>,U32.is_eq(id,0),u => [original],u =>
        nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),[
          N111Bin{p113a_name(n,"tag"),N111U64{},"shr",p113a_value(n,"array"),N111Const{56,0}},
          N111Bin{p113a_name(n,"raw"),N111U64{},"eq",p113a_value(n,"tag"),N111Const{4,0}},
          N111Bin{p113a_name(n,"location"),N111U64{},"and",p113a_value(n,"array"),N111Const{4294967295,255}},
          N111Bin{p113a_name(n,"dynamic"),N111U64{},"uge",p113a_value(n,"location"),N111Const{heap_min,0}},
          N111Bin{p113a_name(n,"admitted"),N111U32{},"and",p113a_value(n,"raw"),p113a_value(n,"dynamic")},
          N111If{p113a_value(n,"admitted"),p113a_raw(id,destination,p111v_arg(args,4),original,n),[original]}]))
    case _: [original]"""

NEW_TEMPLATE = """type P113ASunk is Data:
  P113ASunkNo{}
  P113ASunkYes{+stmt: N111Stmt, +id: U32, +pre: List<&2,P113DStmt>,
    +v0: N111Value, +v1: N111Value, +v2: N111Value, +rest: List<&2,P113DStmt>}


@unsafe
def p113a_val_name(v: N111Value) -> String:
  match v:
    case N111Local{name}: name
    case _: ""


@unsafe
def p113a_input_name(stmt: N111Stmt) -> String:
  match stmt:
    case N111Call{destination,N111U64{},symbol,args}: p113a_val_name(p111v_arg(args,2))
    case _: ""


@unsafe
def p113a_sunk_sets(+id: U32, +n: U32, +v0: N111Value, +v1: N111Value, +v2: N111Value) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[N111Set{p113a_name(n,"array"),N111U64{},v0}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),u => [],u =>
      nt_append(N111Stmt,[N111Set{p113a_name(n,"index"),N111U64{},v1}],
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73) || U32.is_eq(id,74),
          v => [N111Set{p113a_name(n,"new"),N111U64{},v2}],v => []))))


@unsafe
def p113a_sunk_stores(+id: U32, +input: N111Value, +n: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[N111Store{N111U64{},input,0,p113a_value(n,"array")}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),u => [],u =>
      nt_append(N111Stmt,[N111Store{N111U64{},input,8,p113a_value(n,"index")}],
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73) || U32.is_eq(id,74),
          v => [N111Store{N111U64{},input,16,p113a_value(n,"new")}],v => []))))


@unsafe
def p113a_rfc_fallback(+id: U32, +destination: String, +output: N111Value, +original: N111Stmt, +n: U32, +heap_min: U32, +slow: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
    u => [
      N111Bin{p113a_name(n,"rfc"),N111U64{},"eq",p113a_value(n,"tag"),N111Const{132,0}},
      N111Bin{p113a_name(n,"rfc_ok"),N111U32{},"and",p113a_value(n,"rfc"),p113a_value(n,"dynamic")},
      N111If{p113a_value(n,"rfc_ok"),p113a_raw(id,destination,output,original,n),slow}],
    u => [
      N111Bin{p113a_name(n,"rfc"),N111U64{},"eq",p113a_value(n,"tag"),N111Const{132,0}},
      N111Bin{p113a_name(n,"rfc_ok"),N111U32{},"and",p113a_value(n,"rfc"),p113a_value(n,"dynamic")},
      N111If{p113a_value(n,"rfc_ok"),[
        N111Bin{p113a_name(n,"rbytes"),N111U64{},"shl",p113a_value(n,"location"),N111Const{3,0}},
        N111Offset{p113a_name(n,"rptr"),N111Local{"p113a_heap_base"},p113a_value(n,"rbytes")},
        N111Load{p113a_name(n,"rcell"),N111U64{},p113a_value(n,"rptr"),0},
        N111Bin{p113a_name(n,"location"),N111U64{},"shr",p113a_value(n,"rcell"),N111Const{24,0}},
        N111Bin{p113a_name(n,"rdyn"),N111U64{},"uge",p113a_value(n,"location"),N111Const{heap_min,0}},
        N111If{p113a_value(n,"rdyn"),p113a_raw(id,destination,output,original,n),slow}],slow}])


@unsafe
def p113a_template_core(+original: N111Stmt, +n: U32, +heap_min: U32, +in_stmts: List<&2,N111Stmt>, +slow: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  match original:
    case N111Call{+destination,N111U64{},+symbol,+args}:
      +id = p113a_call_id(symbol,args)
      +output = p111v_arg(args,4)
      nt_choose(List<&2,N111Stmt>,U32.is_eq(id,0),u => [original],u =>
        nt_append(N111Stmt,in_stmts,[
          N111Bin{p113a_name(n,"tag"),N111U64{},"shr",p113a_value(n,"array"),N111Const{56,0}},
          N111Bin{p113a_name(n,"raw"),N111U64{},"eq",p113a_value(n,"tag"),N111Const{4,0}},
          N111Bin{p113a_name(n,"location"),N111U64{},"and",p113a_value(n,"array"),N111Const{4294967295,255}},
          N111Bin{p113a_name(n,"dynamic"),N111U64{},"uge",p113a_value(n,"location"),N111Const{heap_min,0}},
          N111Bin{p113a_name(n,"admitted"),N111U32{},"and",p113a_value(n,"raw"),p113a_value(n,"dynamic")},
          N111If{p113a_value(n,"admitted"),p113a_raw(id,destination,output,original,n),
            p113a_rfc_fallback(id,destination,output,original,n,heap_min,slow)}]))
    case _: [original]


@unsafe
def p113a_template(+original: N111Stmt, +n: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      p113a_template_core(original,n,heap_min,p113a_inputs(id,p111v_arg(args,2),n),[original])
    case _: [original]


@unsafe
def p113a_template_sunk(+original: N111Stmt, +n: U32, +heap_min: U32, +v0: N111Value, +v1: N111Value, +v2: N111Value) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      p113a_template_core(original,n,heap_min,p113a_sunk_sets(id,n,v0,v1,v2),
        nt_append(N111Stmt,p113a_sunk_stores(id,p111v_arg(args,2),n),[original]))
    case _: [original]


@unsafe
def p113a_match_sunk(body: List<&2,P113DStmt>) -> P113ASunk:
  match body:
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,+v1}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b2},16,+v2}},
         Con{P113DScalar{N111Alloca{+out,16,8}},
         Con{P113DScalar{+stmt},+rest}}}}}:
      +id = p113a_stmt_id(stmt)
      nt_choose(P113ASunk,U32.is_eq(id,74) && agy_str_eq(b0,"scratch") && agy_str_eq(b1,"scratch") &&
          agy_str_eq(b2,"scratch") && agy_str_eq(p113a_input_name(stmt),"scratch") && Bool.not(agy_str_eq(out,"scratch")),
        u => P113ASunkYes{stmt,74,[P113DScalar{N111Alloca{out,16,8}}],v0,v1,v2,rest},
        u => P113ASunkNo{})
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,+v1}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b2},16,+v2}},
         Con{P113DScalar{+stmt},+rest}}}}:
      +id = p113a_stmt_id(stmt)
      nt_choose(P113ASunk,U32.is_eq(id,73) && agy_str_eq(b0,"scratch") && agy_str_eq(b1,"scratch") &&
          agy_str_eq(b2,"scratch") && agy_str_eq(p113a_input_name(stmt),"scratch"),
        u => P113ASunkYes{stmt,73,[],v0,v1,v2,rest},
        u => P113ASunkNo{})
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,+v1}},
         Con{P113DScalar{N111Alloca{+out,16,8}},
         Con{P113DScalar{+stmt},+rest}}}}:
      +id = p113a_stmt_id(stmt)
      nt_choose(P113ASunk,U32.is_eq(id,72) && agy_str_eq(b0,"scratch") && agy_str_eq(b1,"scratch") &&
          agy_str_eq(p113a_input_name(stmt),"scratch") && Bool.not(agy_str_eq(out,"scratch")),
        u => P113ASunkYes{stmt,72,[P113DScalar{N111Alloca{out,16,8}}],v0,v1,N111Const{0,0},rest},
        u => P113ASunkNo{})
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Alloca{+out,16,8}},
         Con{P113DScalar{+stmt},+rest}}}:
      +id = p113a_stmt_id(stmt)
      nt_choose(P113ASunk,U32.is_eq(id,75) && agy_str_eq(b0,"scratch") &&
          agy_str_eq(p113a_input_name(stmt),"scratch") && Bool.not(agy_str_eq(out,"scratch")),
        u => P113ASunkYes{stmt,75,[P113DScalar{N111Alloca{out,16,8}}],v0,N111Const{0,0},N111Const{0,0},rest},
        u => P113ASunkNo{})
    case _: P113ASunkNo{}"""


OLD_SCAN = """@unsafe
def p113a_scan(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      nt_choose(P113ABody,U32.is_gt(p113a_stmt_id(stmt),0),
        u => p113a_prefix(p113d_scalars(p113a_template(stmt,n,heap_min)),p113a_scan(rest,U32.inc(n),heap_min)),
        u => p113a_prefix([P113DScalar{stmt}],p113a_scan(rest,n,heap_min)))
    case Con{P113DIf{condition,yes,no},rest}:
      p113a_scan_yes(condition,no,rest,heap_min,p113a_scan(yes,n,heap_min))
    case Con{head,rest}: p113a_prefix([head],p113a_scan(rest,n,heap_min))"""

NEW_SCAN = """@unsafe
def p113a_scan_step(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      nt_choose(P113ABody,U32.is_gt(p113a_stmt_id(stmt),0),
        u => p113a_prefix(p113d_scalars(p113a_template(stmt,n,heap_min)),p113a_scan(rest,U32.inc(n),heap_min)),
        u => p113a_prefix([P113DScalar{stmt}],p113a_scan(rest,n,heap_min)))
    case Con{P113DIf{condition,yes,no},rest}:
      p113a_scan_yes(condition,no,rest,heap_min,p113a_scan(yes,n,heap_min))
    case Con{head,rest}: p113a_prefix([head],p113a_scan(rest,n,heap_min))


@unsafe
def p113a_scan_sunk(sunk: P113ASunk, body: List<&2,P113DStmt>, +n: U32, +heap_min: U32) -> P113ABody:
  match sunk:
    case P113ASunkYes{stmt,id,pre,v0,v1,v2,rest}:
      p113a_prefix(nt_append(P113DStmt,pre,p113d_scalars(p113a_template_sunk(stmt,n,heap_min,v0,v1,v2))),
        p113a_scan(rest,U32.inc(n),heap_min))
    case P113ASunkNo{}: p113a_scan_step(body,n,heap_min)


@unsafe
def p113a_scan(+body: List<&2,P113DStmt>, +n: U32, +heap_min: U32) -> P113ABody:
  p113a_scan_sunk(p113a_match_sunk(body),body,n,heap_min)"""


OLD_HOIST_META = """@unsafe
def p117h_metadata(+name: String, +origin: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  [N111Set{p117h_name(origin,"array"),N111U64{},N111Local{name}},
   N111Bin{p117h_name(origin,"tag"),N111U64{},"shr",p117h_ref(origin,"array"),N111Const{56,0}},
   N111Bin{p117h_name(origin,"raw"),N111U64{},"eq",p117h_ref(origin,"tag"),N111Const{p117h_raw_tag(),0}},
   N111Bin{p117h_name(origin,"location"),N111U64{},"and",p117h_ref(origin,"array"),N111Const{4294967295,255}},
   N111Bin{p117h_name(origin,"dynamic"),N111U64{},"uge",p117h_ref(origin,"location"),N111Const{heap_min,0}},
   N111Bin{p117h_name(origin,"admitted"),N111U32{},"and",p117h_ref(origin,"raw"),p117h_ref(origin,"dynamic")},
   N111Bin{p117h_name(origin,"class"),N111U64{},"shr",p117h_ref(origin,"array"),N111Const{40,0}},
   N111Bin{p117h_name(origin,"class"),N111U64{},"and",p117h_ref(origin,"class"),N111Const{31,0}},
   N111Bin{p117h_name(origin,"size"),N111U64{},"shl",N111Const{1,0},p117h_ref(origin,"class")},
   N111Bin{p117h_name(origin,"mask"),N111U64{},"sub",p117h_ref(origin,"size"),N111Const{1,0}},
   N111Bin{p117h_name(origin,"bytes"),N111U64{},"shl",p117h_ref(origin,"location"),N111Const{3,0}},
   N111Offset{p117h_name(origin,"base"),N111Local{"p113a_heap_base"},p117h_ref(origin,"bytes")}]"""

NEW_HOIST_META = """@unsafe
def p117h_metadata(+name: String, +origin: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  [N111Set{p117h_name(origin,"array"),N111U64{},N111Local{name}},
   N111Bin{p117h_name(origin,"tag"),N111U64{},"shr",p117h_ref(origin,"array"),N111Const{56,0}},
   N111Bin{p117h_name(origin,"btag"),N111U64{},"and",p117h_ref(origin,"tag"),N111Const{127,0}},
   N111Bin{p117h_name(origin,"raw"),N111U64{},"eq",p117h_ref(origin,"btag"),N111Const{p117h_raw_tag(),0}},
   N111Bin{p117h_name(origin,"location"),N111U64{},"and",p117h_ref(origin,"array"),N111Const{4294967295,255}},
   N111Bin{p117h_name(origin,"dynamic"),N111U64{},"uge",p117h_ref(origin,"location"),N111Const{heap_min,0}},
   N111Bin{p117h_name(origin,"admitted"),N111U32{},"and",p117h_ref(origin,"raw"),p117h_ref(origin,"dynamic")},
   N111Bin{p117h_name(origin,"rfc"),N111U64{},"shr",p117h_ref(origin,"tag"),N111Const{7,0}},
   N111Bin{p117h_name(origin,"rfc_ok"),N111U32{},"and",p117h_ref(origin,"admitted"),p117h_ref(origin,"rfc")},
   N111If{p117h_ref(origin,"rfc_ok"),[
     N111Bin{p117h_name(origin,"rbytes"),N111U64{},"shl",p117h_ref(origin,"location"),N111Const{3,0}},
     N111Offset{p117h_name(origin,"rptr"),N111Local{"p113a_heap_base"},p117h_ref(origin,"rbytes")},
     N111Load{p117h_name(origin,"rcell"),N111U64{},p117h_ref(origin,"rptr"),0},
     N111Bin{p117h_name(origin,"location"),N111U64{},"shr",p117h_ref(origin,"rcell"),N111Const{24,0}},
     N111Bin{p117h_name(origin,"rdyn"),N111U64{},"uge",p117h_ref(origin,"location"),N111Const{heap_min,0}},
     N111Bin{p117h_name(origin,"admitted"),N111U32{},"and",p117h_ref(origin,"admitted"),p117h_ref(origin,"rdyn")}],[]},
   N111Bin{p117h_name(origin,"class"),N111U64{},"shr",p117h_ref(origin,"array"),N111Const{40,0}},
   N111Bin{p117h_name(origin,"class"),N111U64{},"and",p117h_ref(origin,"class"),N111Const{31,0}},
   N111Bin{p117h_name(origin,"size"),N111U64{},"shl",N111Const{1,0},p117h_ref(origin,"class")},
   N111Bin{p117h_name(origin,"mask"),N111U64{},"sub",p117h_ref(origin,"size"),N111Const{1,0}},
   N111Bin{p117h_name(origin,"bytes"),N111U64{},"shl",p117h_ref(origin,"location"),N111Const{3,0}},
   N111Offset{p117h_name(origin,"base"),N111Local{"p113a_heap_base"},p117h_ref(origin,"bytes")}]"""


OLD_P117H_REWRITE = """@unsafe
def p117h_template(+original: N111Stmt, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),[
        N111If{p117h_ref(origin,"admitted"),
          nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
            u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
            u => nt_append(N111Stmt,p117h_address(id,n,origin),p113a_success(id,destination,p111v_arg(args,4),n))),[original]}])
    case _: [original]


@unsafe
def p117h_rewrite(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      +origin = p117h_get(sites,U32.show(n))
      nt_choose(P113ABody,U32.is_eq(p113a_stmt_id(stmt),0),
        u => p113a_prefix([P113DScalar{stmt}],p117h_rewrite(rest,n,heap_min,used,sites)),u =>
        p113a_prefix(p113d_scalars(nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template(stmt,n,heap_min),v => p117h_template(stmt,n,origin))),
          p117h_rewrite(rest,U32.inc(n),heap_min,used,sites)))
    case Con{P113DIf{condition,yes,no},rest}:
      p117h_rewrite_yes(condition,no,rest,heap_min,used,sites,p117h_rewrite(yes,n,heap_min,used,sites))
    case Con{head,rest}: p113a_prefix([head],p117h_rewrite(rest,n,heap_min,used,sites))"""

NEW_P117H_REWRITE = """@unsafe
def p117h_template(+original: N111Stmt, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),[
        N111If{p117h_ref(origin,"admitted"),
          nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
            u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
            u => nt_append(N111Stmt,p117h_address(id,n,origin),p113a_success(id,destination,p111v_arg(args,4),n))),[original]}])
    case _: [original]


@unsafe
def p117h_template_sunk(+original: N111Stmt, +n: U32, +origin: U32, +v0: N111Value, +v1: N111Value, +v2: N111Value) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_sunk_sets(id,n,v0,v1,v2),[
        N111If{p117h_ref(origin,"admitted"),
          nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
            u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
            u => nt_append(N111Stmt,p117h_address(id,n,origin),p113a_success(id,destination,p111v_arg(args,4),n))),
          nt_append(N111Stmt,p113a_sunk_stores(id,p111v_arg(args,2),n),[original])}])
    case _: [original]


@unsafe
def p117h_rewrite_step(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      +origin = p117h_get(sites,U32.show(n))
      nt_choose(P113ABody,U32.is_eq(p113a_stmt_id(stmt),0),
        u => p113a_prefix([P113DScalar{stmt}],p117h_rewrite(rest,n,heap_min,used,sites)),u =>
        p113a_prefix(p113d_scalars(nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template(stmt,n,heap_min),v => p117h_template(stmt,n,origin))),
          p117h_rewrite(rest,U32.inc(n),heap_min,used,sites)))
    case Con{P113DIf{condition,yes,no},rest}:
      p117h_rewrite_yes(condition,no,rest,heap_min,used,sites,p117h_rewrite(yes,n,heap_min,used,sites))
    case Con{head,rest}: p113a_prefix([head],p117h_rewrite(rest,n,heap_min,used,sites))


@unsafe
def p117h_rewrite_sunk(sunk: P113ASunk, body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match sunk:
    case P113ASunkYes{stmt,id,pre,v0,v1,v2,rest}:
      +origin = p117h_get(sites,U32.show(n))
      p113a_prefix(nt_append(P113DStmt,pre,p113d_scalars(
        nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template_sunk(stmt,n,heap_min,v0,v1,v2),
          v => p117h_template_sunk(stmt,n,origin,v0,v1,v2)))),
        p117h_rewrite(rest,U32.inc(n),heap_min,used,sites))
    case P113ASunkNo{}: p117h_rewrite_step(body,n,heap_min,used,sites)


@unsafe
def p117h_rewrite(+body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  p117h_rewrite_sunk(p113a_match_sunk(body),body,n,heap_min,used,sites)"""


OLD_P117V_REWRITE = """@unsafe
def p117v_template(+original: N111Stmt, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
          u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
          u => nt_append(N111Stmt,p117h_address(id,n,origin),p113a_success(id,destination,p111v_arg(args,4),n))))
    case _: [original]


@unsafe
def p117v_rewrite(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      +origin = p117h_get(sites,U32.show(n))
      nt_choose(P113ABody,U32.is_eq(p113a_stmt_id(stmt),0),
        u => p113a_prefix([P113DScalar{stmt}],p117v_rewrite(rest,n,heap_min,used,sites)),u =>
        p113a_prefix(p113d_scalars(nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template(stmt,n,heap_min),v => p117v_template(stmt,n,origin))),
          p117v_rewrite(rest,U32.inc(n),heap_min,used,sites)))
    case Con{P113DIf{condition,yes,no},rest}:
      p117v_rewrite_yes(condition,no,rest,heap_min,used,sites,p117v_rewrite(yes,n,heap_min,used,sites))
    case Con{head,rest}: p113a_prefix([head],p117v_rewrite(rest,n,heap_min,used,sites))"""

NEW_P117V_REWRITE = """@unsafe
def p117v_template(+original: N111Stmt, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
          u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
          u => nt_append(N111Stmt,p117h_address(id,n,origin),p113a_success(id,destination,p111v_arg(args,4),n))))
    case _: [original]


@unsafe
def p117v_template_sunk(+original: N111Stmt, +n: U32, +origin: U32, +v0: N111Value, +v1: N111Value, +v2: N111Value) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_sunk_sets(id,n,v0,v1,v2),
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
          u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
          u => nt_append(N111Stmt,p117h_address(id,n,origin),p113a_success(id,destination,p111v_arg(args,4),n))))
    case _: [original]


@unsafe
def p117v_rewrite_step(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      +origin = p117h_get(sites,U32.show(n))
      nt_choose(P113ABody,U32.is_eq(p113a_stmt_id(stmt),0),
        u => p113a_prefix([P113DScalar{stmt}],p117v_rewrite(rest,n,heap_min,used,sites)),u =>
        p113a_prefix(p113d_scalars(nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template(stmt,n,heap_min),v => p117v_template(stmt,n,origin))),
          p117v_rewrite(rest,U32.inc(n),heap_min,used,sites)))
    case Con{P113DIf{condition,yes,no},rest}:
      p117v_rewrite_yes(condition,no,rest,heap_min,used,sites,p117v_rewrite(yes,n,heap_min,used,sites))
    case Con{head,rest}: p113a_prefix([head],p117v_rewrite(rest,n,heap_min,used,sites))


@unsafe
def p117v_rewrite_sunk(sunk: P113ASunk, body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match sunk:
    case P113ASunkYes{stmt,id,pre,v0,v1,v2,rest}:
      +origin = p117h_get(sites,U32.show(n))
      p113a_prefix(nt_append(P113DStmt,pre,p113d_scalars(
        nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template_sunk(stmt,n,heap_min,v0,v1,v2),
          v => p117v_template_sunk(stmt,n,origin,v0,v1,v2)))),
        p117v_rewrite(rest,U32.inc(n),heap_min,used,sites))
    case P113ASunkNo{}: p117v_rewrite_step(body,n,heap_min,used,sites)


@unsafe
def p117v_rewrite(+body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  p117v_rewrite_sunk(p113a_match_sunk(body),body,n,heap_min,used,sites)"""


def patch(src: str) -> str:
    src = once(src, OLD_ENABLED, NEW_ENABLED, "p113a_enabled")
    src = once(src, OLD_TEMPLATE, NEW_TEMPLATE, "p113a_template + sunk + rfc")
    src = once(src, OLD_SCAN, NEW_SCAN, "p113a_scan")
    src = once(src, OLD_HOIST_META, NEW_HOIST_META, "p117h_metadata")
    src = once(src, OLD_P117H_REWRITE, NEW_P117H_REWRITE, "p117h_rewrite")
    src = once(src, OLD_P117V_REWRITE, NEW_P117V_REWRITE, "p117v_rewrite")
    return src


def main():
    ap = argparse.ArgumentParser(description="Wave 4 W4-2: p113a/p117v array fast-path patcher")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    a = ap.parse_args()
    out = patch(a.src.read_text())
    a.dst.parent.mkdir(parents=True, exist_ok=True)
    a.dst.write_text(out)
    print(f"Patched AGY-W4-ARRAY -> {a.dst} ({len(out)} bytes)")


if __name__ == "__main__":
    main()
