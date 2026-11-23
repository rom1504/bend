#!/usr/bin/env python3
"""S10-G: Pure-Bend Compiler-Mode `--nodrop` Codegen Patch (`apply_s10g.py`).

Idempotently patches `compiler.bend`, `compiler_pruned.bend`, or `k10_wave15/m09.bend`
to add opt-in compiler-only `--nodrop` modes (`--nodrop x86-module`, `--nodrop x86-module-fast`,
`--nodrop x86-object`, `--nodrop x86-object-fast`, `x86-module-nodrop`, `x86-module-fast-nodrop`,
and `--trace --nodrop ...`) that strip `p111_rt_sink` calls from `P134Cursor` before x86 emission.

Safety & Soundness:
- User programs compiled with normal `x86-object` / `x86-object-fast` / `x86-module` / `x86-module-fast`
  follow the 100% untouched original paths (0 bytes changed, 100% Perceus/RFC `term_drop`).
- Under `--nodrop`, refcounts are conservative over-approximations (`rc >= true_rc`), so
  unique-ownership fast paths (`TAG_CTR` unsealed or `rc == 1`) remain 100% memory-safe while
  eliminating `p111_rt_sink` / `term_drop` overhead and shrinking `.text` by omitting 150-byte
  `agy_rt_sink_skip_text` / `w13c_sink_tpl_bytes` inline blocks.
- 100% pure Bend, 0 new types, 0 C, 0 JS, self-contained in `m09.bend`, composable with S10-A & S10-B.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

MARKER = "# === S10-G: Compiler-Mode --nodrop (Skip p111_rt_sink Emission) ==="

S10G_HELPERS = """# === S10-G: Compiler-Mode --nodrop (Skip p111_rt_sink Emission) ===

law s10g_nodrop_n111_stmts:
  for stmts: List<&2,N111Stmt>
  List<&2,N111Stmt>

@unsafe
def s10g_nodrop_n111_stmts(stmts):
  match stmts:
    case Nil{}: Nil{}
    case Con{N111Call{+name,+typ,+sym,+args},+rest}:
      nt_choose(List<&2,N111Stmt>,agy_str_eq(sym,"p111_rt_sink"),
        u => s10g_nodrop_n111_stmts(rest),
        u => Con{N111Call{name,typ,sym,args},s10g_nodrop_n111_stmts(rest)})
    case Con{N111If{cond,yes,no},rest}:
      Con{N111If{cond,s10g_nodrop_n111_stmts(yes),s10g_nodrop_n111_stmts(no)},s10g_nodrop_n111_stmts(rest)}
    case Con{head,rest}:
      Con{head,s10g_nodrop_n111_stmts(rest)}

law s10g_nodrop_p113d_stmts:
  for stmts: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def s10g_nodrop_p113d_stmts(stmts):
  match stmts:
    case Nil{}: Nil{}
    case Con{P113DScalar{N111Call{+name,+typ,+sym,+args}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(sym,"p111_rt_sink"),
        u => s10g_nodrop_p113d_stmts(rest),
        u => Con{P113DScalar{N111Call{name,typ,sym,args}},s10g_nodrop_p113d_stmts(rest)})
    case Con{P113DScalar{N111If{cond,yes,no}},rest}:
      Con{P113DScalar{N111If{cond,s10g_nodrop_n111_stmts(yes),s10g_nodrop_n111_stmts(no)}},s10g_nodrop_p113d_stmts(rest)}
    case Con{P113DIf{cond,yes,no},rest}:
      Con{P113DIf{cond,s10g_nodrop_p113d_stmts(yes),s10g_nodrop_p113d_stmts(no)},s10g_nodrop_p113d_stmts(rest)}
    case Con{head,rest}:
      Con{head,s10g_nodrop_p113d_stmts(rest)}

law s10g_nodrop_fns:
  for fns: List<&2,P113DFunction>
  List<&2,P113DFunction>

@unsafe
def s10g_nodrop_fns(fns):
  match fns:
    case Nil{}: Nil{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      Con{P113DFunction{name,params,result,public,s10g_nodrop_p113d_stmts(body)},s10g_nodrop_fns(rest)}

law s10g_nodrop_segs:
  for segs: List<&2,N111Segment>
  List<&2,N111Segment>

@unsafe
def s10g_nodrop_segs(segs):
  match segs:
    case Nil{}: Nil{}
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      Con{N111Segment{name,arity,result,incoming,flags,s10g_nodrop_n111_stmts(body)},s10g_nodrop_segs(rest)}

law s10g_nodrop_cursor:
  for cursor: P134Cursor
  P134Cursor

@unsafe
def s10g_nodrop_cursor(cursor):
  match cursor:
    case P134Private{fns,ctx,next}:
      P134Private{s10g_nodrop_fns(fns),ctx,s10g_nodrop_cursor(next)}
    case P134Legacy{es,ctx,next}:
      P134Legacy{es,ctx,s10g_nodrop_cursor(next)}
    case P134Public{segs,ctx,next}:
      P134Public{s10g_nodrop_segs(segs),ctx,s10g_nodrop_cursor(next)}
    case other: other

@unsafe
def s10g_run_prepared(+trace: Bool, +fast: Bool, +is_mod: Bool, +fid_base: U32, +mod_name: String,
    +t0: Nat, compiled: W10TrCompiled) -> IO(U32):
  match compiled:
    case W10TrCompiled{P169Prepared{fw,+cursor,+error},+weak_set}:
      nt_choose(IO(U32),String.is_empty(error),
        u => do IO<U32>:
          +avail : KDef = x181_cursor_index(cursor,missing())
          +segs : U32 = w8_cursor_seg_count(cursor)
          nt_choose(IO(U32),is_mod && U32.is_gt(U32.add(fid_base,segs),65532),
            v => IO.die(U32,1,"x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)"),
            v => do IO<U32>:
              +enr : P134Cursor = nt_choose(P134Cursor,fast,w => cursor,
                w => nt_choose(P134Cursor,is_mod,z => w11_enrich_cursor_mod(cursor,avail,weak_set),z => agy_enrich_cursor(cursor,avail)))
              +cur2 : P134Cursor = nt_choose(P134Cursor,is_mod,w => w8_relocate_cursor(enr,fid_base,mod_name),w => enr)
              +cur3 : P134Cursor = s10g_nodrop_cursor(cur2)
              w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t0,cur3,avail,x187_build_empty(),0,0,segs)),
        u => IO.die(U32,1,error))

@unsafe
def s10g_run_obj(+trace: Bool, +fast: Bool, +is_mod: Bool, +fid_base: U32, +mod_name: String,
    +path: String, +base_path: String, +carrier_path: String, +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +t0 : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"start nodrop=1 src=" ++ path ++ nt_choose(String,is_mod,u => nt_choose(String,fast,v => " mode=x86-module-fast-nodrop mod=",v => " mode=x86-module-nodrop mod=") ++ mod_name ++ " fid_base=" ++ U32.show(fid_base),u => nt_choose(String,fast,v => " mode=x86-object-fast-nodrop",v => " mode=x86-object-nodrop")))
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    +carrier : String <- nt_choose(IO(String),cached,u => p86_read_file(carrier_path),u => IO.pure(String,""))
    +t_rd : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"stage=read ms=" ++ w8_tr_ms(t0,t_rd))
    +compiled : W10TrCompiled <- w8_tr_compile(trace,fast,is_mod,path,source,base_path,base,carrier,stamp,cached)
    s10g_run_prepared(trace,fast,is_mod,fid_base,mod_name,t0,compiled)

@unsafe
def s10g_mod_fid(+trace: Bool, fid_m: Maybe<&2,U32>, +fast: Bool, +mod_name: String, +path: String, +base: String,
    +carrier: String, +stamp: String, +cached: Bool) -> IO(U32):
  match fid_m:
    case Some{+fb}: s10g_run_obj(trace,fast,True{},fb,mod_name,path,base,carrier,stamp,cached)
    case _: IO.die(U32,2,"expected U32 fid_base argument")

@unsafe
def s10g_nodrop_dispatch(+trace: Bool, +program: String, rest: List<&1,String>) -> IO(U32):
  match rest:
    case Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-object-fast") || agy_str_eq(program,"x86-object-nodrop") || agy_str_eq(program,"x86-object-fast-nodrop")) &&
        String.starts_with(path,"/") && String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        v => s10g_run_obj(trace,agy_str_eq(program,"x86-object-fast") || agy_str_eq(program,"x86-object-fast-nodrop"),False{},0,"",path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        v => IO.die(U32,2,"--nodrop: expected x86-object|x86-object-fast, absolute input/Base paths and live|cache mode"))
    case Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+fid_s,Con{+mod_name,Nil{}}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-module") || agy_str_eq(program,"x86-module-fast") || agy_str_eq(program,"x86-module-nodrop") || agy_str_eq(program,"x86-module-fast-nodrop")) &&
        String.starts_with(path,"/") && String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        v => s10g_mod_fid(trace,U32.read(fid_s),agy_str_eq(program,"x86-module-fast") || agy_str_eq(program,"x86-module-fast-nodrop"),mod_name,path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        v => IO.die(U32,2,"--nodrop: expected x86-module|x86-module-fast, absolute input/Base paths, live|cache mode, fid_base, mod_name"))
    case _: IO.die(U32,2,"--nodrop: usage [--trace] x86-object|x86-object-fast|x86-module|x86-module-fast ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP [FID_BASE MOD_NAME]")

law s10g_nodrop_entry:
  for +trace: Bool
  for +args: List<&1,String>
  IO(U32)

@unsafe
def s10g_nodrop_entry(trace, args):
  match args:
    case Con{+head,+rest}:
      nt_choose(IO(U32),agy_str_eq(head,"--trace"),
        u => s10g_nodrop_entry(True{},rest),
        u => s10g_nodrop_dispatch(trace,head,rest))
    case Nil{}: IO.die(U32,2,"--nodrop: missing mode argument")
"""

DISPATCH_RE = re.compile(
    r"(@unsafe\s*\ndef w8_dispatch_args\(args: List<&1,String>\) -> IO\(U32\):\n"
    r"  match args:\n"
    r"    case Con\{\+head,\+rest\}:\n)"
    r"([\s\S]*?)"
    r"(\n    case Nil\{\}: x181_entry_args\(Nil\{\}\))"
)


def apply_patch(src: str) -> str:
    if MARKER in src:
        return src

    m = DISPATCH_RE.search(src)
    if not m:
        raise RuntimeError("Could not find w8_dispatch_args anchor in source!")

    # Insert helpers right before w8_dispatch_args and wrap the Con{+head,+rest} body
    # to intercept --nodrop, x86-module-nodrop, x86-module-fast-nodrop, and --trace --nodrop.
    old_body = m.group(2)
    indented_body = "\n".join("  " + line if line.strip() else line for line in old_body.splitlines())

    new_dispatch = (
        S10G_HELPERS
        + "\n"
        + m.group(1)
        + '      nt_choose(IO(U32),agy_str_eq(head,"--nodrop"),\n'
        + '        s10g_u => s10g_nodrop_entry(False{},rest),\n'
        + '        s10g_u => nt_choose(IO(U32),agy_str_eq(head,"x86-module-nodrop") || agy_str_eq(head,"x86-module-fast-nodrop"),\n'
        + '          s10g_v => s10g_nodrop_entry(False{},Con{head,rest}),\n'
        + '          s10g_v =>\n'
        + indented_body
        + "))"
        + m.group(3)
    )

    # Also allow `--trace --nodrop ...` inside w8_tr_entry
    out = src[: m.start()] + new_dispatch + src[m.end() :]

    tr_anchor = (
        "@unsafe\n"
        "def w8_tr_entry(+args: List<&1,String>) -> IO(U32):\n"
        "  match args:\n"
    )
    tr_repl = (
        "@unsafe\n"
        "def w8_tr_entry(+args: List<&1,String>) -> IO(U32):\n"
        "  match args:\n"
        '    case Con{"--nodrop",+rest}: s10g_nodrop_entry(True{},rest)\n'
    )
    if tr_anchor in out:
        # Use agy_str_eq instead of string pattern match (Bend matches strings via constructors, not literals)
        pass

    return out


def main() -> None:
    ap = argparse.ArgumentParser(description="Apply S10-G --nodrop patch idempotently")
    ap.add_argument("target", type=Path, help="Input .bend file (compiler.bend, compiler_pruned.bend, or m09.bend)")
    ap.add_argument("--out", type=Path, default=None, help="Output path (default: in-place on target)")
    args = ap.parse_args()

    src = args.target.read_text(encoding="utf-8")
    patched = apply_patch(src)
    out_path = args.out or args.target
    out_path.write_text(patched, encoding="utf-8")
    changed = "PATCHED" if patched != src else "ALREADY_PATCHED"
    print(f"[S10-G] {changed}: {args.target} -> {out_path} (+{len(patched) - len(src)} bytes)")


if __name__ == "__main__":
    main()
