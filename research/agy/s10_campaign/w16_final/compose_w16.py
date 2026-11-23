#!/usr/bin/env python3
"""Wave 16 Final Composer: Composes all 8 verified S10 optimizations onto
`selfhost/build/agy/wave15_unified/compiler.bend` ->
`selfhost/build/agy/wave16_unified/compiler.bend`.

Stacking order (zero conflicts, 100% pure Bend):
  1. S10-D: 5-line `w5_g11_b` fallthrough cmov fix (restores editdist 1.59x C, 7-family 1.059x C)
  2. S10-E: Fast direct lexer + fast `p86_plan` (`s10e_plan`), extended to skip S10-A stubs in `-O0`
  3. S10-A: Zero-`.p130` `STB_WEAK` stub & template visibility (`w10_weak_from_plan`)
  4. S10-C: Fast `-O0` backend (`s10c_priv_emit_fast`, `s10c_plan_fast`)
  5. S10-H: Unified S10-A stub skipping + O(1) `bangMap` + p112s direct-stub skip in `s10c_plan_fast`
  6. S10-F: Unboxed `S10fT` `x187_pub` + 8x-unrolled hot-8 `x187_elf` + 7 bare `-O2` sink upgrades
  7. S10-B: Reachability tree-shaker + constant flag folding + comment stripping
  8. S10-G: Compiler-only `--nodrop` mode (`x86-module-nodrop` / `x86-module-fast-nodrop` / `--nodrop`)
"""
from __future__ import annotations

import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
SRC = ROOT / "selfhost/build/agy/wave15_unified/compiler.bend"
OUT = ROOT / "selfhost/build/agy/wave16_unified/compiler.bend"
TMP = Path("/tmp/agy_w16_compose")

sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/s10d_frontend_and_o2"))
sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/s10e_fast_p86"))
sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/s10a_zero_p130"))
sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/s10c_fast_o0_backend"))
sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/s10h_fast_x198pw"))
sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/s10f_elf_and_drop"))
sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/s10g_nodrop_and_k24"))

import apply_s10d
import apply_s10e
import apply_s10a
import apply_s10c
import apply_s10h
import apply_s10f
import apply_s10g


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    cnt = text.count(old)
    if cnt != 1:
        raise RuntimeError(f"[{label}] expected 1 match, found {cnt}\n--- OLD ---\n{old[:240]}")
    print(f"  [OK] {label}", flush=True)
    return text.replace(old, new, 1)


def main() -> None:
    t0 = time.perf_counter()
    TMP.mkdir(parents=True, exist_ok=True)
    text = SRC.read_text(encoding="utf-8")
    print(f"Loaded {SRC} ({len(text):,} B, {len(text.splitlines()):,} lines)", flush=True)

    # 1. S10-D
    print("\n--- Step 1: S10-D (w5_g11_b -O2 codegen restoration) ---", flush=True)
    text = apply_s10d.apply_s10d(text, with_imm8=False)

    # 2. S10-E (--no-lexer: 9 safe frontend/parser/check/annotate hunks) + extend -O0 stub skip to S10-A stubs
    print("\n--- Step 2: S10-E (fast p86_plan, --no-lexer) ---", flush=True)
    text = apply_s10e.apply_s10e(text, include_lexer=False)
    text = replace_exact(
        text,
        "    case True{}: s10e_skip_def_stub(du(d) && db(d) && U32.is_gt(w10_if_peel_stub(dn(d), dv(d), 0), 0), d, is_mod)",
        "    case True{}: s10e_skip_def_stub(du(d) && U32.is_gt(w10_if_peel_stub(dn(d), dv(d), 0), 0), d, is_mod)",
        "s10e_skip_s10a_stubs_in_typecheck",
    )
    text = replace_exact(
        text,
        """    case Con{d, rest}:
      +nm0 : String = dn(d)
      s10e_ann_stops_step(U32.is_gt(w10_if_stub_kind(book, nm0), 0), book, nm0, rest, acc)""",
        """    case Con{+d, rest}:
      +nm0 : String = dn(d)
      s10e_ann_stops_step(du(d) && agy_str_eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && U32.is_gt(w10_if_peel_stub(nm0, dv(d), 0), 0), book, nm0, rest, acc)""",
        "s10e_skip_s10a_stubs_in_annotate",
    )

    # 3. S10-A (preserving S10-E's s10e_plan calls while computing w10_weak_from_plan)
    print("\n--- Step 3: S10-A (zero-.p130 STB_WEAK stub & template visibility) ---", flush=True)
    text = replace_exact(text, apply_s10a.ANCHOR_PREP_RUN, apply_s10a.REPLACE_PREP_RUN, "s10a_prep_run")
    text = replace_exact(
        text,
        """@unsafe
def w10_module_prep_run_fast(+path: String, +source: String, +fid_base: U32, +mod_name: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      w10_module_prepared_fast_io(x198pw_plan_fast(s10e_plan(seed,path,source,True{},True{})),w10_weak_from_seed(seed),fid_base,mod_name)""",
        """@unsafe
def w10_module_prep_run_fast(+path: String, +source: String, +fid_base: U32, +mod_name: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      +plan = s10e_plan(seed,path,source,True{},True{})
      w10_module_prepared_fast_io(x198pw_plan_fast(plan),w10_weak_from_plan(seed,plan),fid_base,mod_name)""",
        "s10a_module_prep_run_fast_with_s10e",
    )
    text = replace_exact(
        text,
        """    case P86PreparationReady{+seed}:
      do IO<W10TrCompiled>:
        +weak_set : KDef = nt_choose(KDef,is_mod,u => w10_weak_from_seed(seed),u => missing())
        +plan : P86Plan <- IO.pure(P86Plan,s10e_plan(seed,path,source,fast,is_mod))""",
        """    case P86PreparationReady{+seed}:
      do IO<W10TrCompiled>:
        +plan : P86Plan <- IO.pure(P86Plan,s10e_plan(seed,path,source,fast,is_mod))
        +weak_set : KDef = nt_choose(KDef,is_mod,u => w10_weak_from_plan(seed,plan),u => missing())""",
        "s10a_w8_tr_compile_prep_with_s10e",
    )
    text = replace_exact(text, apply_s10a.CALL_SITES[3][0], apply_s10a.CALL_SITES[3][1], "s10a_ts_p86_plan")

    # 4. S10-C (fast -O0 backend: s10c_priv_emit_fast + s10c_plan_fast)
    print("\n--- Step 4: S10-C (fast -O0 backend) ---", flush=True)
    text, changed_c = apply_s10c.patch_text(text)
    assert changed_c, "S10-C did not apply!"
    print("  [OK] s10c_fast_o0_backend", flush=True)

    # 5. S10-H (unified S10-A stub skip + O(1) bangMap in s10c_plan_fast)
    print("\n--- Step 5: S10-H (fast -O0 x198pw_plan_fast) ---", flush=True)
    text, changed_h = apply_s10h.patch_text(text)
    assert changed_h, "S10-H did not apply!"
    print("  [OK] s10h_plan_fast", flush=True)

    # 6. S10-F (unboxed S10fT x187_pub + 8x-unrolled hot-8 x187_elf + 7 bare -O2 sinks)
    print("\n--- Step 6: S10-F (unboxed x187_pub + fast x187_elf + -O2 sinks) ---", flush=True)
    anchor_f = "# === WAVE 10 PHASE 3 (P3-A): Pure-Bend `x86-module-fast` (-O0 modular emit + M2 ELF vis) ==="
    fwd_laws = """
law w10_module_cursor_fast_io:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  IO(U32)
"""
    dup_law = """law w10_module_cursor_fast_io:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  IO(U32)
"""
    if dup_law in text:
        text = text.replace(dup_law, "", 1)
    text = replace_exact(text, anchor_f, fwd_laws + "\n" + apply_s10f.S10F_CODE + "\n" + anchor_f, "s10f_insert_code")
    tr_anchor = "@unsafe\ndef w8_tr_emit_good("
    text = replace_exact(text, tr_anchor, apply_s10f.S10F_TR_CODE + "\n" + tr_anchor, "s10f_insert_tr_code")

    # Wire S10-F pub loop & ELF finish into w10_module_cursor_fast_io (superseding s10c_elf_finish_io)
    text = replace_exact(
        text,
        """    case P134Public{Con{head,rest},+context,next}:
      w10_module_cursor_fast_io(P134Public{rest,context,next},available,w13c_pub_emit_fast(head,context,available,build),weak_set)
    case P134Tables{Nil{}}: w10_module_cursor_fast_io(P134Main{},available,build,weak_set)
    case P134Tables{Con{head,rest}}:
      w10_module_cursor_fast_io(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: s10c_elf_finish_io(build,True{},weak_set)""",
        """    case P134Public{Con{head,rest},+context,next}:
      s10f_mod_pub_loop(Con{head,rest},context,next,available,build,weak_set,s10f_init_pub_ctx())
    case P134Tables{Nil{}}: w10_module_cursor_fast_io(P134Main{},available,build,weak_set)
    case P134Tables{Con{head,rest}}:
      w10_module_cursor_fast_io(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: s10f_elf_finish_io(build,True{},weak_set)""",
        "s10f_wire_mod_pub_and_elf",
    )
    # Wire S10-F pub loop into w8_tr_emit_good
    text = replace_exact(text, apply_s10f.WIRE_REPLACES[1][0], apply_s10f.WIRE_REPLACES[1][1], "s10f_wire_tr_pub")
    # Wire S10-F ELF finish into w8_tr_emit_good (superseding S10-C's fast/slow split so both -O0 and -O2 use s10f_elf_finish_io)
    text = replace_exact(
        text,
        """        +rc : U32 <- nt_choose(IO(U32),fast,
          u => nt_choose(IO(U32),is_mod,
            v => s10c_elf_finish_io(build,True{},weak_set),
            v => s10c_elf_finish_io(x187_build_seq(x181_program_main(),build),False{},missing())),
          u => nt_choose(IO(U32),is_mod,
            v => w10_x202p_x201f_finish(build,weak_set),
            v => x202p_x201f_finish(x187_build_seq(x181_program_main(),build))))""",
        """        +rc : U32 <- nt_choose(IO(U32),is_mod,
          u => s10f_elf_finish_io(build,True{},weak_set),
          u => s10f_elf_finish_io(x187_build_seq(x181_program_main(),build),False{},missing()))""",
        "s10f_wire_tr_elf",
    )
    # Apply S10-F -O2 bare sink upgrades
    for idx, (old, new) in enumerate(apply_s10f.O2_SINK_REPLACES):
        text = replace_exact(text, old, new, f"s10f_o2_sink_{idx}")

    # Write pre-treeshake file
    pre_ts = TMP / "compiler_pre_treeshake.bend"
    pre_ts.write_text(text, encoding="utf-8")
    print(f"\nWrote pre-treeshake {pre_ts} ({len(text):,} B, {len(text.splitlines()):,} lines)", flush=True)

    # 7. S10-B Tree-Shaker
    print("\n--- Step 7: S10-B (reachability tree-shaker + constant flag folding) ---", flush=True)
    post_ts = TMP / "compiler_post_treeshake.bend"
    stats_json = ROOT / "research/agy/s10_campaign/w16_final/treeshake_stats.json"
    subprocess.run(
        [
            sys.executable,
            str(ROOT / "research/agy/s10_campaign/s10b_treeshake/treeshake_w15.py"),
            "--src",
            str(pre_ts),
            "--out",
            str(post_ts),
            "--stats-json",
            str(stats_json),
        ],
        check=True,
    )

    # 8. S10-G (--nodrop mode, applied AFTER S10-B so w8_dispatch_args includes --nodrop!)
    print("\n--- Step 8: S10-G (compiler-only --nodrop mode) ---", flush=True)
    ts_text = post_ts.read_text(encoding="utf-8")
    final_text = apply_s10g.apply_patch(ts_text)
    assert final_text != ts_text, "S10-G did not apply!"

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(final_text, encoding="utf-8")
    elapsed = round(time.perf_counter() - t0, 2)
    print(
        f"\n=== WAVE 16 UNIFIED COMPOSED ({elapsed}s) -> {OUT} "
        f"({len(final_text):,} B, {len(final_text.splitlines()):,} lines) ===",
        flush=True,
    )


if __name__ == "__main__":
    main()
