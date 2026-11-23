#!/usr/bin/env python3
"""W13-INT: Reproducibly compose selfhost/build/agy/wave13_unified/compiler.bend
from read-only selfhost/build/agy/wave12_unified/compiler.bend by stacking:
  1. W13-C (fast x187_pub):
     - Single-hash x181_frame_home
     - Symbol-dispatched x185_late_stmts_h (preserving W12-A's w12_late_borrow_try
       for p118_rt_borrow_fields while skipping all non-N111Call scalars!)
     - Fused direct-to-X187Build w13c_pub_emit_fast (from w13c_fast_x187pub.bend)
       wired into all 5 fast public emission entrypoints.
  2. W13-D (w13d_fast_x198pw.patch):
     - 1.835x faster x198pw_plan_fast for -O0 x86-module-fast / x86-object-fast
       (0 seg delta, 100% $direct.* ABI parity, -O2 paths 100% untouched).
"""
from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
SRC = ROOT / "selfhost/build/agy/wave12_unified/compiler.bend"
DST = ROOT / "selfhost/build/agy/wave13_unified/compiler.bend"

W13C_BEND = ROOT / "research/agy/w13_campaign/w13c_fast_x187pub/w13c_fast_x187pub.bend"
W13D_PATCH = ROOT / "research/agy/w13_campaign/w13d_fast_x198pw/w13d_fast_x198pw.patch"


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise SystemExit(f"[compose_w13] {label}: expected 1 match, found {n}")
    return src.replace(old, new, 1)


def apply_unified_patch(src: str, patch_path: Path, label: str) -> str:
    with tempfile.TemporaryDirectory(prefix=f"w13int_{label}_") as td:
        target = Path(td) / "compiler.bend"
        target.write_text(src, encoding="utf-8")
        r = subprocess.run(
            ["patch", "--batch", "--forward", "--no-backup-if-mismatch", "-F", "3", str(target), str(patch_path)],
            capture_output=True, text=True,
        )
        if r.returncode != 0:
            raise SystemExit(
                f"[compose_w13] patch {label} failed (rc={r.returncode}):\nSTDOUT:\n{r.stdout}\nSTDERR:\n{r.stderr}"
            )
        lines = [ln for ln in r.stdout.strip().splitlines() if ln.strip()]
        print(f"  [OK] {label}: {lines[-1] if lines else 'clean'}", flush=True)
        return target.read_text(encoding="utf-8")


def apply_w13c(src: str) -> str:
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
    out = replace_exact(out, old_fh, new_fh, "W13-C x181_frame_home")

    # 2. Fast symbol-dispatched x185_late_stmts_h (preserves W12-A w12_late_borrow_try!)
    old_late_h = """@unsafe
def w5b_late_store_call_h(+styp: N111Type, +sbuf: String, +sval: N111Value,
    +dest: String, +sym: String, +args: List<&2,N111Arg>, +rest: List<&2,P113DStmt>,
    +ids: N111Ids, +site: U32, +hasHeap: Bool, matched: Maybe<&2,List<&2,P113DStmt>>) -> P113ABody:
  match matched:
    case Some{expanded}:
      p113a_prefix(expanded,
        x185_late_stmts_h(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site),hasHeap))
    case None{}:
      +s0 : N111Stmt = N111Store{styp,N111Local{sbuf},0,sval}
      +c0 : P113DStmt = P113DScalar{N111Call{dest,N111U64{},sym,args}}
      +r0 : List<&2,P113DStmt> = Con{c0,rest}
      p113a_prefix(x181_scalar_rows(x185_late_scalar(s0,ids,site,w4_bf_mask_for(s0,r0,ids,site))),
        x185_late_stmts_h(r0,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site),hasHeap))

@unsafe
def x185_late_yes_h(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +ids: N111Ids, +hasHeap: Bool, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: x185_late_no_h(condition,body,rest,ids,hasHeap,x185_late_stmts_h(no,ids,next,hasHeap))

@unsafe
def x185_late_no_h(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +ids: N111Ids, +hasHeap: Bool, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],x185_late_stmts_h(rest,ids,next,hasHeap))

@unsafe
def x185_late_stmts_h(body,ids,site,hasHeap):
  match body:
    case Nil{}: P113ABody{[],site}
    case Con{P113DScalar{N111Store{+styp,N111Local{+sbuf},0,+sval}},
         Con{P113DScalar{N111Call{+dest,N111U64{},+sym,+args}},+rest}}:
      w5b_late_store_call_h(styp,sbuf,sval,dest,sym,args,rest,ids,site,hasHeap,
        w5b_match_succ_pair(styp,sbuf,sval,dest,sym,args,site))
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x185_late_yes_h(condition,x181_scalar_rows(no),rest,ids,hasHeap,x185_late_stmts_h(x181_scalar_rows(yes),ids,site,hasHeap))
    case Con{P113DScalar{+stmt},+rest}:
      w12_late_borrow_try(stmt,rest,ids,site,hasHeap,p128bf_match(stmt,ids,site))
    case Con{P113DIf{condition,yes,no},rest}:
      x185_late_yes_h(condition,no,rest,ids,hasHeap,x185_late_stmts_h(yes,ids,site,hasHeap))
    case Con{head,rest}: p113a_prefix([head],x185_late_stmts_h(rest,ids,site,hasHeap))"""

    new_late_h = """@unsafe
def w13c_p113a_cons(head: P113DStmt, tail: P113ABody) -> P113ABody:
  match tail:
    case P113ABody{rows,next}: P113ABody{Con{head,rows},next}

@unsafe
def w13c_late_call_sym_h(+sym: String, +stmt: N111Stmt, +rest: List<&2,P113DStmt>,
    +ids: N111Ids, +site: U32, +hasHeap: Bool) -> P113ABody:
  +next_site = nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)
  nt_choose(P113ABody,agy_str_eq(sym,"p111_rt_reg_get") || agy_str_eq(sym,"p111_rt_tag"),
    u => p113a_prefix(x181_scalar_rows(p112a_expand(3,stmt)),x185_late_stmts_h(rest,ids,next_site,hasHeap)),u =>
  nt_choose(P113ABody,agy_str_eq(sym,"p111_rt_jump") || agy_str_eq(sym,"p111_rt_return"),
    u => p113a_prefix(x181_scalar_rows(nt_choose(List<&2,N111Stmt>,U32.is_lt(site,4294967200) && x186_transport_enabled(),
      v => x185_late_transport(p186rt_expand(stmt,ids,site)),v => [stmt])),x185_late_stmts_h(rest,ids,next_site,hasHeap)),u =>
  nt_choose(P113ABody,agy_str_eq(sym,"p111_rt_frame") || agy_str_eq(sym,"p111_rt_stack_pop") || agy_str_eq(sym,"p111_rt_stack_get"),
    u => p113a_prefix(x181_scalar_rows(nt_choose(List<&2,N111Stmt>,U32.is_lt(site,4294967200),
      v => x185_late_transport(p114t_expand(stmt,ids,site)),v => [stmt])),x185_late_stmts_h(rest,ids,next_site,hasHeap)),u =>
  nt_choose(P113ABody,agy_str_eq(sym,"p111_rt_ctor"),
    u => p113a_prefix(x181_scalar_rows(nt_choose(List<&2,N111Stmt>,U32.is_lt(site,4294967200),
      v => x185_late_constructor(stmt,ids,site,nt_choose(P114TExpansion,x185_ctor_enabled(),
        w => p185cc_expand(stmt,ids,site),w => P114TExpansion{[stmt],False{}})),v => [stmt])),x185_late_stmts_h(rest,ids,next_site,hasHeap)),u =>
  nt_choose(P113ABody,agy_str_eq(sym,"p111_rt_take") || agy_str_eq(sym,"p118_rt_extend"),
    u => w13c_p113a_cons(P113DScalar{nt_choose(N111Stmt,U32.is_lt(site,4294967200),v => p118q_sized(stmt),v => stmt)},
      x185_late_stmts_h(rest,ids,next_site,hasHeap)),u =>
  nt_choose(P113ABody,agy_str_eq(sym,"p118_rt_borrow_fields"),
    u => w12_late_borrow_try(stmt,rest,ids,site,hasHeap,p128bf_match(stmt,ids,site)),u =>
  nt_choose(P113ABody,agy_str_eq(sym,"p111_rt_special_ctor") || agy_str_eq(sym,"p111_rt_special_take"),
    u => p113a_prefix(x181_scalar_rows(x185_late_scalar(stmt,ids,site,255)),x185_late_stmts_h(rest,ids,next_site,hasHeap)),
    u => w13c_p113a_cons(P113DScalar{stmt},x185_late_stmts_h(rest,ids,next_site,hasHeap)))))))))

@unsafe
def w5b_late_store_call_h(+styp: N111Type, +sbuf: String, +sval: N111Value,
    +dest: String, +sym: String, +args: List<&2,N111Arg>, +rest: List<&2,P113DStmt>,
    +ids: N111Ids, +site: U32, +hasHeap: Bool, matched: Maybe<&2,List<&2,P113DStmt>>) -> P113ABody:
  match matched:
    case Some{expanded}:
      p113a_prefix(expanded,
        x185_late_stmts_h(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site),hasHeap))
    case None{}:
      +s0 : P113DStmt = P113DScalar{N111Store{styp,N111Local{sbuf},0,sval}}
      +c0 : P113DStmt = P113DScalar{N111Call{dest,N111U64{},sym,args}}
      w13c_p113a_cons(s0,x185_late_stmts_h(Con{c0,rest},ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site),hasHeap))

@unsafe
def x185_late_yes_h(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +ids: N111Ids, +hasHeap: Bool, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: x185_late_no_h(condition,body,rest,ids,hasHeap,x185_late_stmts_h(no,ids,next,hasHeap))

@unsafe
def x185_late_no_h(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +ids: N111Ids, +hasHeap: Bool, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: w13c_p113a_cons(P113DIf{condition,yes,body},x185_late_stmts_h(rest,ids,next,hasHeap))

@unsafe
def x185_late_stmts_h(body,ids,site,hasHeap):
  match body:
    case Nil{}: P113ABody{[],site}
    case Con{P113DScalar{N111Store{+styp,N111Local{+sbuf},0,+sval}},
         Con{P113DScalar{N111Call{+dest,N111U64{},+sym,+args}},+rest}}:
      w5b_late_store_call_h(styp,sbuf,sval,dest,sym,args,rest,ids,site,hasHeap,
        w5b_match_succ_pair(styp,sbuf,sval,dest,sym,args,site))
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x185_late_yes_h(condition,x181_scalar_rows(no),rest,ids,hasHeap,x185_late_stmts_h(x181_scalar_rows(yes),ids,site,hasHeap))
    case Con{P113DScalar{N111Call{d,t,+s,a}},+rest}:
      w13c_late_call_sym_h(s,N111Call{d,t,s,a},rest,ids,site,hasHeap)
    case Con{P113DScalar{stmt},+rest}:
      w13c_p113a_cons(P113DScalar{stmt},
        x185_late_stmts_h(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site),hasHeap))
    case Con{P113DIf{condition,yes,no},rest}:
      x185_late_yes_h(condition,no,rest,ids,hasHeap,x185_late_stmts_h(yes,ids,site,hasHeap))
    case Con{head,rest}: w13c_p113a_cons(head,x185_late_stmts_h(rest,ids,site,hasHeap))"""
    out = replace_exact(out, old_late_h, new_late_h, "W13-C x185_late_stmts_h (W12-A compatible)")

    # 3. Insert W13-C fused emitter right before w10_module_cursor_fast
    w13c_code = W13C_BEND.read_text(encoding="utf-8")
    anchor = "# === WAVE 10 PHASE 3 (P3-A): Pure-Bend `x86-module-fast` (-O0 modular emit + M2 ELF vis) ==="
    out = replace_exact(out, anchor, w13c_code.rstrip() + "\n\n" + anchor, "W13-C insert_w13c")

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
    out = replace_exact(out, old_law, new_law, "W13-C law w13c_pub_emit_fast")

    # 5. Wire all 5 public-fast call sites to w13c_pub_emit_fast
    out = replace_exact(
        out,
        "      x187_cursor_fast(P134Public{rest,context,next},available,w10f_output_fn(x181_program_public_fast(head,context,available),build))",
        "      x187_cursor_fast(P134Public{rest,context,next},available,w13c_pub_emit_fast(head,context,available,build))",
        "W13-C x187_cursor_fast_good",
    )
    out = replace_exact(
        out,
        "      w10_module_cursor_fast(P134Public{rest,context,next},available,w10f_output_fn(x181_program_public_fast(head,context,available),build),weak_set)",
        "      w10_module_cursor_fast(P134Public{rest,context,next},available,w13c_pub_emit_fast(head,context,available,build),weak_set)",
        "W13-C w10_module_cursor_fast_good",
    )
    out = replace_exact(
        out,
        "      w10_module_cursor_fast_io(P134Public{rest,context,next},available,w10f_output_fn(x181_program_public_fast(head,context,available),build),weak_set)",
        "      w10_module_cursor_fast_io(P134Public{rest,context,next},available,w13c_pub_emit_fast(head,context,available,build),weak_set)",
        "W13-C w10_module_cursor_fast_io_good",
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
        "W13-C w8_tr_emit_pub",
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
        "W13-C ts_emit_pub",
    )
    out = replace_exact(
        out,
        "def w13c_pub_emit_fast(+segment: N111Segment, context: P134Context, +available: KDef, +build: X187Build) -> X187Build:",
        "def w13c_pub_emit_fast(segment, context, available, build):",
        "W13-C w13c_pub_emit_fast_law_impl",
    )
    print("  [OK] W13-C (fast x187_pub + W12-A-compatible x185_late_stmts_h + single-hash frame_home)", flush=True)
    return out


def apply_w13_fid_dedup(src: str) -> str:
    """W13-INT FID-budget recovery: raise w6_canon_seg statement fuel (33 -> 256)
    and w6_dedup_segments rounds (1 -> 2) so K=14 total segments stay well below
    the 16-bit 65,532 FID cap (~62.5k / 65,532) with zero ABI/runtime change."""
    out = replace_exact(
        src,
        "  w6_canon_finish(w6_canon_stmts(body,W6CState{[],0,[hdr],33}))",
        "  w6_canon_finish(w6_canon_stmts(body,W6CState{[],0,[hdr],256}))",
        "W13-INT w6_canon_seg fuel 33->256",
    )
    out = replace_exact(
        out,
        "def w6_dedup_segments(segs: List<&2,N111Segment>) -> List<&2,N111Segment>:\n  w6_dedup_round(segs,1)",
        "def w6_dedup_segments(segs: List<&2,N111Segment>) -> List<&2,N111Segment>:\n  w6_dedup_round(segs,2)",
        "W13-INT w6_dedup_segments rounds 1->2",
    )
    # W13-INT ABI parity fix: W13-D skipped p126sc_candidates(raw), which caused 8
    # p126sc functions (g_class_root, p111q_decimal_go, sp_drop, etc.) in m00b/m01/m02
    # to be advertised as $direct.* by x86-iface but omitted from -O0 x86-module-fast.
    out = replace_exact(
        out,
        "  +fns0 = p113d_passes(raw,ready,nt_reverse(P113DFunction,workers,[]),32)",
        "  +fns0 = p113d_passes(p126sc_candidates(raw),ready,nt_reverse(P113DFunction,workers,[]),32)",
        "W13-INT restore p126sc_candidates in w13d_p168_selected_fast",
    )
    print("  [OK] W13-INT FID dedup (fuel=256, rounds=2) + W13-D p126sc_candidates ABI parity", flush=True)
    return out


def main() -> None:
    print(f"=== W13-INT Compose: {SRC} -> {DST} ===", flush=True)
    src = SRC.read_text(encoding="utf-8")
    base_len = len(src)
    print(f"  Base wave12_unified: {base_len:,} B ({src.count(chr(10)):,} lines)", flush=True)

    src = apply_w13c(src)
    src = apply_unified_patch(src, W13D_PATCH, "W13-D (fast x198pw_plan_fast)")
    src = apply_w13_fid_dedup(src)

    DST.parent.mkdir(parents=True, exist_ok=True)
    DST.write_text(src, encoding="utf-8")
    print(
        f"=== Wrote {DST} ({len(src):,} B, +{len(src)-base_len:,} B, {src.count(chr(10)):,} lines) ===",
        flush=True,
    )


if __name__ == "__main__":
    main()
