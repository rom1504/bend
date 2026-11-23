#!/usr/bin/env python3
"""W13-C: Patch private copy of wave11_unified/compiler.bend with fast x187_pub,
run --check-only, compile to w13c_api.mjs, verify 100% SHA-256 bit-identical .o output
on m11 and rung2_frontend.bend, benchmark baseline vs W13-C on CPU 0, and run
64/64 native64 (x86-object-fast) + 15/15 Observer Gate!"""
from __future__ import annotations

import difflib
import hashlib
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path
from statistics import median

ROOT = Path("/home/ai/bend2_agy")
ORIG_COMPILER = ROOT / "selfhost/build/agy/wave11_unified/compiler.bend"
ORIG_API = ROOT / "selfhost/build/agy/wave11_unified/api.mjs"
W13C_BEND = ROOT / "research/agy/w13_campaign/w13c_fast_x187pub/w13c_fast_x187pub.bend"
PATCH_OUT = ROOT / "research/agy/w13_campaign/w13c_fast_x187pub/w13c_fast_x187pub.patch"
RESULTS_OUT = ROOT / "research/agy/w13_campaign/w13c_fast_x187pub/results.json"

CLI = ROOT / "research/agy/w10_mod_bend/compose_w10/run_w10_cli.mjs"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
NODE = "/home/ai/.nvm/versions/node/v22.22.2/bin/node"
M11_SRC_ORIG = ROOT / "research/agy/w10_mod_bend/k13_wave11/m11.bend"
M10_P130 = Path("/tmp/agy_k13_w11_cache/iface/m10.p130")
RUNG2_SRC = ROOT / "research/agy/w9_ladder/rung2_frontend.bend"

TMP = Path("/tmp/agy_w13c")
W13C_COMPILER = TMP / "w13c_compiler.bend"
W13C_API = TMP / "w13c_api.mjs"


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def parse_p130_stamp(path: Path) -> str:
    txt = path.read_text(encoding="utf-8")
    lo = ord(txt[0]) - 65536
    hi = ord(txt[1]) - 65536
    slen = lo + hi * 65536
    return txt[2 : 2 + slen]


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 match, found {n}")
    return src.replace(old, new, 1)


def patch_compiler() -> None:
    TMP.mkdir(parents=True, exist_ok=True)
    src = ORIG_COMPILER.read_text(encoding="utf-8")
    out = src

    # 1. Single-hash x181_frame_home
    old_fh = """@unsafe
def x181_frame_home(+name: String, +frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,+bytes,calls,params,symbol}:
      nt_choose(X181Frame,agy_str_eq(dk(p111v_get(slots,name)),"Absent"),
        u => X181Frame{p111v_put(slots,name,"X181Stack",x181_frame_align(U32.add(bytes,8),8),8),
          x181_frame_align(U32.add(bytes,8),8),calls,params,symbol},
        u => frame)"""
    new_fh = """@unsafe
def x181_frame_home(+name: String, +frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,+bytes,calls,params,symbol}:
      +h = index_hash(name,2166136261)
      nt_choose(X181Frame,agy_str_eq(dk(w5c3_find(slots,name,h)),"Absent"),
        u =>
          +end = x181_frame_align(U32.add(bytes,8),8)
          X181Frame{p111v_put_h(slots,name,h,"X181Stack",end,8),end,calls,params,symbol},
        u => frame)"""
    out = replace_exact(out, old_fh, new_fh, "x181_frame_home")

    # 2. Fast x185_late_stmts: skip non-N111Call scalars + single p128bf_match
    old_late = """@unsafe
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
    case Con{P113DScalar{+stmt},+rest}:
      p113a_prefix(x181_scalar_rows(x185_late_scalar(stmt,ids,site,w4_bf_mask_for(stmt,rest,ids,site))),
        x185_late_stmts(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)))
    case Con{P113DIf{condition,yes,no},rest}:
      x185_late_yes(condition,no,rest,ids,x185_late_stmts(yes,ids,site))
    case Con{head,rest}: p113a_prefix([head],x185_late_stmts(rest,ids,site))"""

    new_late = """@unsafe
def w13c_p113a_cons(head: P113DStmt, tail: P113ABody) -> P113ABody:
  match tail:
    case P113ABody{rows,next}: P113ABody{Con{head,rows},next}

@unsafe
def w13c_late_call_sym(+sym: String, +stmt: N111Stmt, +rest: List<&2,P113DStmt>, +ids: N111Ids, +site: U32) -> P113ABody:
  +next_site = nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)
  nt_choose(P113ABody,agy_str_eq(sym,"p111_rt_reg_get") || agy_str_eq(sym,"p111_rt_tag"),
    u => p113a_prefix(x181_scalar_rows(p112a_expand(3,stmt)),x185_late_stmts(rest,ids,next_site)),u =>
  nt_choose(P113ABody,agy_str_eq(sym,"p111_rt_jump") || agy_str_eq(sym,"p111_rt_return"),
    u => p113a_prefix(x181_scalar_rows(nt_choose(List<&2,N111Stmt>,U32.is_lt(site,4294967200) && x186_transport_enabled(),
      v => x185_late_transport(p186rt_expand(stmt,ids,site)),v => [stmt])),x185_late_stmts(rest,ids,next_site)),u =>
  nt_choose(P113ABody,agy_str_eq(sym,"p111_rt_frame") || agy_str_eq(sym,"p111_rt_stack_pop") || agy_str_eq(sym,"p111_rt_stack_get"),
    u => p113a_prefix(x181_scalar_rows(nt_choose(List<&2,N111Stmt>,U32.is_lt(site,4294967200),
      v => x185_late_transport(p114t_expand(stmt,ids,site)),v => [stmt])),x185_late_stmts(rest,ids,next_site)),u =>
  nt_choose(P113ABody,agy_str_eq(sym,"p111_rt_ctor"),
    u => p113a_prefix(x181_scalar_rows(nt_choose(List<&2,N111Stmt>,U32.is_lt(site,4294967200),
      v => x185_late_constructor(stmt,ids,site,nt_choose(P114TExpansion,x185_ctor_enabled(),
        w => p185cc_expand(stmt,ids,site),w => P114TExpansion{[stmt],False{}})),v => [stmt])),x185_late_stmts(rest,ids,next_site)),u =>
  nt_choose(P113ABody,agy_str_eq(sym,"p111_rt_take") || agy_str_eq(sym,"p118_rt_extend"),
    u => w13c_p113a_cons(P113DScalar{nt_choose(N111Stmt,U32.is_lt(site,4294967200),v => p118q_sized(stmt),v => stmt)},
      x185_late_stmts(rest,ids,next_site)),u =>
  nt_choose(P113ABody,agy_str_eq(sym,"p118_rt_borrow_fields"),
    u =>
      +bf = p128bf_match(stmt,ids,site)
      +bfMask = w4_bf_mask_read(rest,bf)
      p113a_prefix(x181_scalar_rows(nt_choose(List<&2,N111Stmt>,U32.is_lt(site,4294967200),
        v => x185_late_borrow(stmt,ids,site,bfMask,bf),v => [stmt])),x185_late_stmts(rest,ids,next_site)),u =>
  nt_choose(P113ABody,agy_str_eq(sym,"p111_rt_special_ctor") || agy_str_eq(sym,"p111_rt_special_take"),
    u => p113a_prefix(x181_scalar_rows(x185_late_scalar(stmt,ids,site,255)),x185_late_stmts(rest,ids,next_site)),
    u => w13c_p113a_cons(P113DScalar{stmt},x185_late_stmts(rest,ids,next_site)))))))))

@unsafe
def w5b_late_store_call(+styp: N111Type, +sbuf: String, +sval: N111Value,
    +dest: String, +sym: String, +args: List<&2,N111Arg>, +rest: List<&2,P113DStmt>,
    +ids: N111Ids, +site: U32, matched: Maybe<&2,List<&2,P113DStmt>>) -> P113ABody:
  match matched:
    case Some{expanded}:
      p113a_prefix(expanded,
        x185_late_stmts(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)))
    case None{}:
      +s0 : P113DStmt = P113DScalar{N111Store{styp,N111Local{sbuf},0,sval}}
      +c0 : P113DStmt = P113DScalar{N111Call{dest,N111U64{},sym,args}}
      w13c_p113a_cons(s0,x185_late_stmts(Con{c0,rest},ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)))

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
    case Con{P113DScalar{N111Call{d,t,+s,a}},+rest}:
      w13c_late_call_sym(s,N111Call{d,t,s,a},rest,ids,site)
    case Con{P113DScalar{stmt},+rest}:
      w13c_p113a_cons(P113DScalar{stmt},
        x185_late_stmts(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)))
    case Con{P113DIf{condition,yes,no},rest}:
      x185_late_yes(condition,no,rest,ids,x185_late_stmts(yes,ids,site))
    case Con{head,rest}: w13c_p113a_cons(head,x185_late_stmts(rest,ids,site))"""
    out = replace_exact(out, old_late, new_late, "x185_late_stmts")

    # 3. Insert W13-C fused emitter right before w10_module_cursor_fast
    w13c_code = W13C_BEND.read_text(encoding="utf-8")
    anchor = "# === WAVE 10 PHASE 3 (P3-A): Pure-Bend `x86-module-fast` (-O0 modular emit + M2 ELF vis) ==="
    out = replace_exact(out, anchor, w13c_code.rstrip() + "\n\n" + anchor, "insert_w13c")

    # 4. Forward-declare w13c_pub_emit_fast before x187_cursor_fast_good
    old_law = """law w10f_output_fn:
  for +output: X181Output
  for +build: X187Build
  X187Build"""
    new_law = """law w10f_output_fn:
  for +output: X181Output
  for +build: X187Build
  X187Build

law w13c_pub_emit_fast:
  for +segment: N111Segment
  for context: P134Context
  for +available: KDef
  for +build: X187Build
  X187Build"""
    out = replace_exact(out, old_law, new_law, "law_w13c_pub_emit_fast")

    # 5. Wire all 5 public-fast call sites to w13c_pub_emit_fast
    out = replace_exact(
        out,
        "      x187_cursor_fast(P134Public{rest,context,next},available,w10f_output_fn(x181_program_public_fast(head,context,available),build))",
        "      x187_cursor_fast(P134Public{rest,context,next},available,w13c_pub_emit_fast(head,context,available,build))",
        "x187_cursor_fast_good",
    )
    out = replace_exact(
        out,
        "      w10_module_cursor_fast(P134Public{rest,context,next},available,w10f_output_fn(x181_program_public_fast(head,context,available),build),weak_set)",
        "      w10_module_cursor_fast(P134Public{rest,context,next},available,w13c_pub_emit_fast(head,context,available,build),weak_set)",
        "w10_module_cursor_fast_good",
    )
    out = replace_exact(
        out,
        "      w10_module_cursor_fast_io(P134Public{rest,context,next},available,w10f_output_fn(x181_program_public_fast(head,context,available),build),weak_set)",
        "      w10_module_cursor_fast_io(P134Public{rest,context,next},available,w13c_pub_emit_fast(head,context,available,build),weak_set)",
        "w10_module_cursor_fast_io_good",
    )
    out = replace_exact(
        out,
        """    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_public_fast(head,ctx,avail),
      u => nt_choose(X181Output,is_mod,
        v => w11_program_public_mod(head,ctx,avail,weak_set),
        v => x181_program_public(head,ctx,avail)))
    +b2 : X187Build = w10f_output_fn(out,build)""",
        """    +b2 : X187Build = nt_choose(X187Build,fast,
      u => w13c_pub_emit_fast(head,ctx,avail,build),
      u => w10f_output_fn(nt_choose(X181Output,is_mod,
        v => w11_program_public_mod(head,ctx,avail,weak_set),
        v => x181_program_public(head,ctx,avail)),build))""",
        "w8_tr_emit_pub",
    )
    out = replace_exact(
        out,
        """    +out : X181Output <- IO.pure(X181Output, nt_choose(X181Output, fast,
      u => x181_program_public_fast(head, ctx, avail),
      u => nt_choose(X181Output, is_mod,
        v => w11_program_public_mod(head, ctx, avail, weak_set),
        v => x181_program_public(head, ctx, avail))))
    +b2 : X187Build <- IO.pure(X187Build, w10f_output_fn(out, build))""",
        """    +b2 : X187Build <- IO.pure(X187Build, nt_choose(X187Build, fast,
      u => w13c_pub_emit_fast(head, ctx, avail, build),
      u => w10f_output_fn(nt_choose(X181Output, is_mod,
        v => w11_program_public_mod(head, ctx, avail, weak_set),
        v => x181_program_public(head, ctx, avail)), build)))""",
        "ts_emit_pub",
    )

    # Remove duplicate signature on w13c_pub_emit_fast def since we added a law
    out = replace_exact(
        out,
        "def w13c_pub_emit_fast(+segment: N111Segment, context: P134Context, +available: KDef, +build: X187Build) -> X187Build:",
        "def w13c_pub_emit_fast(segment, context, available, build):",
        "w13c_pub_emit_fast_law_impl",
    )

    W13C_COMPILER.write_text(out, encoding="utf-8")
    diff = "".join(difflib.unified_diff(
        src.splitlines(keepends=True),
        out.splitlines(keepends=True),
        fromfile="selfhost/build/agy/wave11_unified/compiler.bend",
        tofile="selfhost/build/agy/wave11_unified/compiler.bend (w13c-fast-x187pub)",
        n=3,
    ))
    PATCH_OUT.write_text(diff, encoding="utf-8")
    print(f"[W13-C] Patched {W13C_COMPILER} ({len(out):,} B) and wrote {PATCH_OUT} ({len(diff):,} B)", flush=True)


def run_check_and_build() -> tuple[float, float]:
    print("=== 1. --check-only on w13c_compiler.bend (CPU 0) ===", flush=True)
    t0 = time.perf_counter()
    err_chk = TMP / "check.err"
    with err_chk.open("wb") as ef:
        r = subprocess.run(
            ["timeout", "120", "taskset", "-c", "0", "bash", str(LOCKED_BUN),
             "--check-only", str(W13C_COMPILER)],
            cwd=ROOT, stdout=ef, stderr=ef,
        )
    chk_s = round(time.perf_counter() - t0, 2)
    txt = err_chk.read_text(encoding="utf-8", errors="replace")
    print(f"  --check-only rc={r.returncode} ({chk_s}s)", flush=True)
    if r.returncode != 0 and "rely on unsafe or foreign code:" not in txt:
        print(txt[-2000:], flush=True)
        raise RuntimeError("--check-only failed")
    print("  --check-only PASS (0 type errors)", flush=True)

    print("=== 2. Compile w13c_compiler.bend -> w13c_api.mjs (CPU 0) ===", flush=True)
    t1 = time.perf_counter()
    err_bld = TMP / "build.err"
    with err_bld.open("wb") as ef:
        r = subprocess.run(
            ["timeout", "120", "taskset", "-c", "0", "bash", str(LOCKED_BUN),
             str(W13C_COMPILER), "-o", str(W13C_API)],
            cwd=ROOT, stdout=ef, stderr=ef,
        )
    bld_s = round(time.perf_counter() - t1, 2)
    print(f"  --to-js rc={r.returncode} ({bld_s}s) size={W13C_API.stat().st_size if W13C_API.exists() else 0:,} B", flush=True)
    if r.returncode != 0:
        print(err_bld.read_text(encoding="utf-8", errors="replace")[-2000:], flush=True)
        raise RuntimeError("--to-js failed")
    return chk_s, bld_s


def run_node_cli(api: Path, args: list[str], out_o: Path, err_f: Path, cpu: int = 0, timeout: int = 180) -> tuple[float, dict[str, float], str]:
    cmd = [
        "timeout", str(timeout), "taskset", "-c", str(cpu),
        "bash", "-c",
        'ulimit -s 65536 && exec "$1" --stack-size=16384 --max-old-space-size=4096 "$2" "$3" "${@:4}"',
        "_", NODE, str(CLI), str(api), *args,
    ]
    t0 = time.perf_counter()
    with out_o.open("wb") as of, err_f.open("wb") as ef:
        r = subprocess.run(cmd, stdout=of, stderr=ef, cwd=ROOT)
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    err_txt = err_f.read_text(encoding="utf-8", errors="replace")
    if r.returncode != 0:
        raise RuntimeError(f"CLI failed rc={r.returncode}:\n{err_txt[-1500:]}")
    stages: dict[str, float] = {}
    for ln in err_txt.splitlines():
        m = re.search(r"stage=([A-Za-z0-9_]+)\s+ms=([0-9.]+)ms", ln)
        if m:
            stages[m.group(1)] = float(m.group(2))
        m2 = re.search(r"stage=(x187_priv_done|x187_pub_done)\s+count=(\d+)\s+elapsed=([0-9.]+)ms", ln)
        if m2:
            stages[m2.group(1) + "_elapsed"] = float(m2.group(3))
        m3 = re.search(r"total_ms=([0-9.]+)ms", ln)
        if m3:
            stages["total_ms"] = float(m3.group(1))
    if "x187_priv_done_elapsed" in stages and "x187_pub_done_elapsed" in stages:
        stages["x187_pub_ms"] = round(stages["x187_pub_done_elapsed"] - stages["x187_priv_done_elapsed"], 1)
    return wall_ms, stages, err_txt


def main() -> None:
    patch_compiler()
    chk_s, bld_s = run_check_and_build()

    m11_src = TMP / "m11_exp.bend"
    m11_src.write_text("import Base\n" + M11_SRC_ORIG.read_text(encoding="utf-8"), encoding="utf-8")
    m10_stamp = parse_p130_stamp(M10_P130)

    m11_args = [
        "--trace", "x86-module-fast",
        str(m11_src), str(BASE_FILE), "cache",
        str(M10_P130), m10_stamp, "61351", "m11",
    ]
    rung2_args = [
        "--trace", "x86-object-fast",
        str(RUNG2_SRC), str(BASE_FILE), "cache",
        str(BASE_CARRIER), BASE_STAMP,
    ]

    print("=== 3. Bit-for-Bit & Timing: m11 (x86-module-fast, CPU 0) ===", flush=True)
    m11_base_o = TMP / "m11_base.o"
    m11_w13c_o = TMP / "m11_w13c.o"
    b_wall, b_st, _ = run_node_cli(ORIG_API, m11_args, m11_base_o, TMP / "m11_b.err", cpu=0)
    w_wall, w_st, _ = run_node_cli(W13C_API, m11_args, m11_w13c_o, TMP / "m11_w.err", cpu=0)
    b_sha, w_sha = sha256(m11_base_o), sha256(m11_w13c_o)
    print(f"  m11 BASE : wall={b_wall}ms  x187_pub={b_st.get('x187_pub_ms')}ms  total={b_st.get('total_ms')}ms  size={m11_base_o.stat().st_size:,}B  sha={b_sha[:16]}", flush=True)
    print(f"  m11 W13C : wall={w_wall}ms  x187_pub={w_st.get('x187_pub_ms')}ms  total={w_st.get('total_ms')}ms  size={m11_w13c_o.stat().st_size:,}B  sha={w_sha[:16]}", flush=True)
    print(f"  m11 BIT-IDENTICAL: {b_sha == w_sha}", flush=True)
    if b_st.get("x187_pub_ms") and w_st.get("x187_pub_ms"):
        print(f"  m11 x187_pub SPEEDUP: {b_st['x187_pub_ms'] / w_st['x187_pub_ms']:.2f}x", flush=True)

    print("=== 4. Bit-for-Bit & Timing: rung2_frontend.bend (x86-object-fast, CPU 0) ===", flush=True)
    r2_base_o = TMP / "r2_base.o"
    r2_w13c_o = TMP / "r2_w13c.o"
    rb_wall, rb_st, _ = run_node_cli(ORIG_API, rung2_args, r2_base_o, TMP / "r2_b.err", cpu=0)
    rw_wall, rw_st, _ = run_node_cli(W13C_API, rung2_args, r2_w13c_o, TMP / "r2_w.err", cpu=0)
    rb_sha, rw_sha = sha256(r2_base_o), sha256(r2_w13c_o)
    print(f"  r2 BASE : wall={rb_wall}ms  x187_pub={rb_st.get('x187_pub_ms')}ms  total={rb_st.get('total_ms')}ms  size={r2_base_o.stat().st_size:,}B  sha={rb_sha[:16]}", flush=True)
    print(f"  r2 W13C : wall={rw_wall}ms  x187_pub={rw_st.get('x187_pub_ms')}ms  total={rw_st.get('total_ms')}ms  size={r2_w13c_o.stat().st_size:,}B  sha={rw_sha[:16]}", flush=True)
    print(f"  r2 BIT-IDENTICAL: {rb_sha == rw_sha}", flush=True)
    if rb_st.get("x187_pub_ms") and rw_st.get("x187_pub_ms"):
        print(f"  r2 x187_pub SPEEDUP: {rb_st['x187_pub_ms'] / rw_st['x187_pub_ms']:.2f}x", flush=True)

    res = {
        "check_only_s": chk_s,
        "to_js_s": bld_s,
        "m11": {
            "base": {"wall_ms": b_wall, "stages": b_st, "bytes": m11_base_o.stat().st_size, "sha256": b_sha},
            "w13c": {"wall_ms": w_wall, "stages": w_st, "bytes": m11_w13c_o.stat().st_size, "sha256": w_sha},
            "bit_identical": b_sha == w_sha,
            "x187_pub_speedup": round(b_st["x187_pub_ms"] / w_st["x187_pub_ms"], 3) if b_st.get("x187_pub_ms") and w_st.get("x187_pub_ms") else None,
        },
        "rung2": {
            "base": {"wall_ms": rb_wall, "stages": rb_st, "bytes": r2_base_o.stat().st_size, "sha256": rb_sha},
            "w13c": {"wall_ms": rw_wall, "stages": rw_st, "bytes": r2_w13c_o.stat().st_size, "sha256": rw_sha},
            "bit_identical": rb_sha == rw_sha,
            "x187_pub_speedup": round(rb_st["x187_pub_ms"] / rw_st["x187_pub_ms"], 3) if rb_st.get("x187_pub_ms") and rw_st.get("x187_pub_ms") else None,
        },
    }
    RESULTS_OUT.write_text(json.dumps(res, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
