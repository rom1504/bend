#!/usr/bin/env python3
"""Wave 8 Real Cross-Module Call Experiment (A calls B, consumes B's return values).

Uses two real compiler components from `research/agy/w7_bench/compiler_slice.bend`:
  - Module B (`modB`, fid_base=0): real compiler lexer/prefix library (`f_lex_cursor`,
    `base_prefix_stamp`, and 546 compiler definitions).
  - Module A (`modA`, fid_base=512): real consumer (`w7_slice_len`, `main`) that calls
    B's `f_lex_cursor` and `base_prefix_stamp` across `.o` boundaries and consumes
    their returned `List<FToken>` and `U32` values.

Tests:
  1. Clean separate build (`modB.o` + `modA.o` + `p111_link_merge.c` + `runtime-agy.o`)
     vs monolithic build -> exact output parity (`34 == 34`).
  2. Body-only edit to B preserving interface & ABI (`base_prefix_stamp` +10) ->
     rebuild ONLY `modB.o`, prove `modA.o` SHA-256 & mtime unchanged (reused!),
     re-link, verify exact changed output (`44 == 44`).
  3. Incompatible exported-layout/signature change to B (`base_prefix_stamp` adds a
     `U32` parameter) ->
     (a) stale interface stamp rejected cleanly (`rc != 0`);
     (b) old Module A rejected against new B interface (`rc != 0`);
     (c) updated Module A rebuilt against new B interface matches new monolithic (`54 == 54`).
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import subprocess
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
EMIT = ROOT / "research/agy/w8_mod_split/emit_w8_module.mjs"
BUILD_IFACE = ROOT / "research/agy/w7_modules/build_iface_carrier.mjs"
MERGE_C = ROOT / "research/agy/w8_fid_base/p111_link_merge.c"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
BASE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_KEY = "/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
TMP = Path("/tmp/agy_w8_cross_ab")
OUT_JSON = ROOT / "research/agy/w8_mod_split/cross_module_ab_results.json"


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run_emit(
    src: Path,
    out_o: Path,
    *,
    mode: str,
    mod_name: str = "m0",
    fid_base: int = 0,
    base_p: Path = BASE,
    base_key: str = BASE_KEY,
    carrier_p: Path = BASE_CARRIER,
    stamp: str = BASE_STAMP,
    expect_ok: bool = True,
) -> tuple[int, dict | str, float]:
    t0 = time.perf_counter()
    r = subprocess.run(
        [
            "bash", str(LOCKED_NODE), str(EMIT),
            "--src", str(src),
            "--out", str(out_o),
            "--mode", mode,
            "--mod-name", mod_name,
            "--fid-base", str(fid_base),
            "--base", str(base_p),
            "--base-key", base_key,
            "--carrier", str(carrier_p),
            "--stamp", stamp,
        ],
        capture_output=True, text=True, cwd=ROOT,
    )
    wall_ms = round((time.perf_counter() - t0) * 1000, 1)
    if expect_ok and r.returncode != 0:
        raise RuntimeError(f"emit failed (rc={r.returncode}): {r.stderr[:500]} {r.stdout[:500]}")
    if r.returncode == 0:
        return r.returncode, json.loads(r.stdout.strip().splitlines()[-1]), wall_ms
    return r.returncode, (r.stderr.strip() or r.stdout.strip())[:400], wall_ms


def build_iface(prefix_bend: Path, modB_o: Path, top_bend: Path, out_dir: Path) -> tuple[dict, float]:
    out_dir.mkdir(parents=True, exist_ok=True)
    t0 = time.perf_counter()
    r = subprocess.run(
        [
            "bash", str(LOCKED_NODE), str(BUILD_IFACE),
            "--prefix", str(prefix_bend),
            "--prefix-obj", str(modB_o),
            "--top", str(top_bend),
            "--out-dir", str(out_dir),
        ],
        capture_output=True, text=True, cwd=ROOT,
    )
    wall_ms = round((time.perf_counter() - t0) * 1000, 1)
    if r.returncode != 0:
        raise RuntimeError(f"build_iface failed (rc={r.returncode}): {r.stderr[:500]} {r.stdout[:500]}")
    meta = json.loads((out_dir / "iface_meta.json").read_text())
    return meta, wall_ms


def get_globals(obj: Path) -> set[str]:
    out = subprocess.check_output(["nm", "-g", "--defined-only", str(obj)], text=True)
    return {line.split()[2] for line in out.splitlines() if len(line.split()) >= 3}


def prepare_module_objs(modB_o: Path, modA_o: Path, modB_prep: Path, modA_prep: Path) -> float:
    t0 = time.perf_counter()
    # Localize `main`, library-module `def main`, and module-private CPS continuations
    # (`$p111.k.*` = `p111_FID_36_112_49_49_49_46_107_46_*`) in both modules so per-module
    # continuation symbols never collide across TUs (each module's `p111_mod_<M>_p111_segments`
    # references its own local `$p111.k.*`).
    K_PREFIX = "p111_FID_36_112_49_49_49_46_107_46_"
    b_raw_syms = get_globals(modB_o)
    b_cmd = ["objcopy", "-L", "main"]
    for s in sorted(b_raw_syms):
        if s in ("p111_FID_109_97_105_110_", "p113d_FID_109_97_105_110_") or s.startswith(K_PREFIX):
            b_cmd.extend(["-L", s])
    b_cmd.extend([str(modB_o), str(modB_prep)])
    subprocess.run(b_cmd, check=True)
    # Localize modA's private `$p111.k.*` continuations and weaken symbols already defined in modB
    # (Base + B's exported functions that modA compiled against as interface stubs).
    b_syms = get_globals(modB_prep)
    a_syms = get_globals(modA_o)
    cmd = ["objcopy", "-L", "main"]
    for s in sorted(a_syms):
        if s.startswith(K_PREFIX):
            cmd.extend(["-L", s])
        elif s in b_syms and s != "main":
            cmd.extend(["-W", s])
    cmd.extend([str(modA_o), str(modA_prep)])
    subprocess.run(cmd, check=True)
    return round((time.perf_counter() - t0) * 1000, 1)


def link_merged(modB_prep: Path, modA_prep: Path, exe: Path) -> tuple[float, str]:
    t0 = time.perf_counter()
    merge_o = exe.with_suffix(".merge.o")
    subprocess.run(
        [
            CC, "-O2", "-c", str(MERGE_C),
            "-DW8_ENTRY_MOD=modA",
            "-DW8_MODULES(X)=X(modB) X(modA)",
            "-o", str(merge_o),
        ],
        check=True,
    )
    subprocess.run(
        [CC, "-no-pie", str(merge_o), str(modB_prep), str(modA_prep), str(RT), "-o", str(exe), "-lm", "-lpthread"],
        check=True,
    )
    link_ms = round((time.perf_counter() - t0) * 1000, 1)
    out = subprocess.run([str(exe)], capture_output=True, text=True, check=True, timeout=15).stdout.strip()
    return link_ms, out


def link_mono(mono_o: Path, exe: Path) -> tuple[float, str]:
    t0 = time.perf_counter()
    subprocess.run([CC, "-no-pie", str(mono_o), str(RT), "-o", str(exe), "-lm", "-lpthread"], check=True)
    link_ms = round((time.perf_counter() - t0) * 1000, 1)
    out = subprocess.run([str(exe)], capture_output=True, text=True, check=True, timeout=15).stdout.strip()
    return link_ms, out


def split_slice(full_text: str) -> tuple[str, str]:
    marker = "\ndef w7_slice_len("
    idx = full_text.index(marker)
    prefix = full_text[:idx]
    # Module B needs a dummy main so x187 emits a complete module program with B's functions reachable.
    # Call f_lex_cursor and base_prefix_stamp from B's dummy main so reach_book keeps them alive!
    modB_src = (
        prefix
        + "\ndef modB_touch(xs: List<&2, FToken>, acc: U32) -> U32:\n"
        + "  match xs:\n"
        + "    case Nil{}: acc\n"
        + "    case Con{h, t}: modB_touch(t, acc)\n"
        + "\ndef main() -> U32:\n"
        + "  +toks = f_lex_cursor(\"def foo(x: U32) -> U32:\\n  U32.add(x, 1)\\n\", 1, 1, 0, [], 0, 0)\n"
        + "  +n = base_prefix_stamp([], 16)\n"
        + "  modB_touch(toks, n)\n"
    )
    # Module A only has w7_slice_len + main (imports Base + B via .p130 interface carrier)
    modA_src = "import Base\n" + full_text[idx:].lstrip()
    return prefix, modB_src, modA_src


def main() -> None:
    if TMP.exists():
        shutil.rmtree(TMP)
    TMP.mkdir(parents=True)

    full_text = SLICE.read_text()
    prefix_v1, modB_v1_txt, modA_v1_txt = split_slice(full_text)

    # Write clean sources
    mono_v1_src = TMP / "mono_v1.bend"
    mono_v1_src.write_text(full_text)
    prefix_v1_src = TMP / "prefix_v1.bend"
    prefix_v1_src.write_text(prefix_v1)
    modB_v1_src = TMP / "modB_v1.bend"
    modB_v1_src.write_text(modB_v1_txt)
    modA_v1_src = TMP / "modA_v1.bend"
    modA_v1_src.write_text(modA_v1_txt)

    # ------------------------------------------------------------------
    # CASE 1: Clean Separate A -> B Build vs Monolithic
    # ------------------------------------------------------------------
    print("=== CASE 1: Clean Separate A -> B Build vs Monolithic ===", flush=True)
    mono_v1_o = TMP / "mono_v1.o"
    _, mono_v1_meta, mono_v1_wall = run_emit(mono_v1_src, mono_v1_o, mode="mono")
    mono_v1_link_ms, mono_v1_out = link_mono(mono_v1_o, TMP / "mono_v1.exe")

    modB_v1_o = TMP / "modB_v1.o"
    _, modB_v1_meta, modB_v1_wall = run_emit(modB_v1_src, modB_v1_o, mode="module", mod_name="modB", fid_base=0)

    iface_v1_meta, iface_v1_wall = build_iface(prefix_v1_src, modB_v1_o, modA_v1_src, TMP / "iface_v1")
    iface_v1 = Path(iface_v1_meta["carrierPath"])
    iface_v1_stamp = iface_v1_meta["stamp"]
    iface_v1_base = Path(iface_v1_meta["combinedPath"])

    modA_v1_o = TMP / "modA_v1.o"
    _, modA_v1_meta, modA_v1_wall = run_emit(
        modA_v1_src, modA_v1_o,
        mode="module", mod_name="modA", fid_base=512,
        base_p=iface_v1_base, base_key=str(iface_v1_base),
        carrier_p=iface_v1, stamp=iface_v1_stamp,
    )
    modA_v1_sha_before = sha256(modA_v1_o)
    modA_v1_mtime_before = modA_v1_o.stat().st_mtime_ns

    prep_v1_ms = prepare_module_objs(modB_v1_o, modA_v1_o, TMP / "modB_v1.prep.o", TMP / "modA_v1.prep.o")
    link_v1_ms, sep_v1_out = link_merged(TMP / "modB_v1.prep.o", TMP / "modA_v1.prep.o", TMP / "sep_v1.exe")
    assert sep_v1_out == mono_v1_out == "34", f"Case 1 mismatch: sep={sep_v1_out!r} mono={mono_v1_out!r}"
    print(f"  [PASS] Clean A->B: sep={sep_v1_out} == mono={mono_v1_out} (modB={modB_v1_wall}ms, iface={iface_v1_wall}ms, modA={modA_v1_wall}ms, link={link_v1_ms}ms)", flush=True)

    # ------------------------------------------------------------------
    # CASE 2: Body-only Edit to B (preserve interface & ABI) -> Reuse modA.o!
    # ------------------------------------------------------------------
    print("=== CASE 2: Body-Only Edit to B (Reuse modA.o untouched!) ===", flush=True)
    # In compiler_slice.bend, base_prefix_stamp returns `acc` on Nil{}. Edit body to return `U32.add(acc, 10)`.
    old_bps = "def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:\n  match book:\n    case Nil{}: bound"
    new_bps = "def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:\n  match book:\n    case Nil{}: U32.add(bound, 10)"
    assert old_bps in full_text, "base_prefix_stamp anchor not found"
    full_v2 = full_text.replace(old_bps, new_bps, 1)
    _, modB_v2_txt, _ = split_slice(full_v2)

    mono_v2_src = TMP / "mono_v2.bend"
    mono_v2_src.write_text(full_v2)
    mono_v2_o = TMP / "mono_v2.o"
    _, mono_v2_meta, mono_v2_wall = run_emit(mono_v2_src, mono_v2_o, mode="mono")
    mono_v2_link_ms, mono_v2_out = link_mono(mono_v2_o, TMP / "mono_v2.exe")

    modB_v2_src = TMP / "modB_v2.bend"
    modB_v2_src.write_text(modB_v2_txt)
    modB_v2_o = TMP / "modB_v2.o"
    _, modB_v2_meta, modB_v2_wall = run_emit(modB_v2_src, modB_v2_o, mode="module", mod_name="modB", fid_base=0)

    # DO NOT recompile modA_v1_o! Reuse modA_v1_o byte-for-byte!
    assert sha256(modA_v1_o) == modA_v1_sha_before
    assert modA_v1_o.stat().st_mtime_ns == modA_v1_mtime_before
    prep_v2_ms = prepare_module_objs(modB_v2_o, modA_v1_o, TMP / "modB_v2.prep.o", TMP / "modA_v1_reused.prep.o")
    link_v2_ms, sep_v2_out = link_merged(TMP / "modB_v2.prep.o", TMP / "modA_v1_reused.prep.o", TMP / "sep_v2.exe")
    assert sep_v2_out == mono_v2_out == "44", f"Case 2 mismatch: sep={sep_v2_out!r} mono={mono_v2_out!r}"
    print(f"  [PASS] Body-only B edit: sep={sep_v2_out} == mono={mono_v2_out}, modA.o REUSED (sha256 unchanged), B_rebuild={modB_v2_wall}ms, link={link_v2_ms}ms", flush=True)

    # ------------------------------------------------------------------
    # CASE 3: Incompatible Exported-Signature Change to B -> Reject Stale, Rebuild A
    # ------------------------------------------------------------------
    print("=== CASE 3: Incompatible Exported-Signature Change to B ===", flush=True)
    old_bps_sig = "def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:\n  match book:\n    case Nil{}: bound\n    case Con{d, rest}: kc(U32, p88_string_eq(dk(d), \"BookCache\"), u => da(d), u => bound)"
    new_bps_sig = "def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32, +bonus: U32) -> U32:\n  match book:\n    case Nil{}: U32.add(bound, bonus)\n    case Con{d, rest}: kc(U32, p88_string_eq(dk(d), \"BookCache\"), u => da(d), u => U32.add(bound, bonus))"
    assert old_bps_sig in full_text, "base_prefix_stamp full def not found"

    prefix_v3 = prefix_v1.replace(old_bps_sig, new_bps_sig, 1)
    modB_v3_txt = modB_v1_txt.replace(old_bps_sig, new_bps_sig, 1).replace("base_prefix_stamp([], 16)", "base_prefix_stamp([], 16, 20)")
    full_v3 = full_text.replace(old_bps_sig, new_bps_sig, 1).replace("base_prefix_stamp([], 16)", "base_prefix_stamp([], 16, 20)")
    modA_v3_txt = modA_v1_txt.replace("base_prefix_stamp([], 16)", "base_prefix_stamp([], 16, 20)")

    mono_v3_src = TMP / "mono_v3.bend"
    mono_v3_src.write_text(full_v3)
    mono_v3_o = TMP / "mono_v3.o"
    _, mono_v3_meta, mono_v3_wall = run_emit(mono_v3_src, mono_v3_o, mode="mono")
    mono_v3_link_ms, mono_v3_out = link_mono(mono_v3_o, TMP / "mono_v3.exe")

    prefix_v3_src = TMP / "prefix_v3.bend"
    prefix_v3_src.write_text(prefix_v3)
    modB_v3_src = TMP / "modB_v3.bend"
    modB_v3_src.write_text(modB_v3_txt)
    modB_v3_o = TMP / "modB_v3.o"
    _, modB_v3_meta, modB_v3_wall = run_emit(modB_v3_src, modB_v3_o, mode="module", mod_name="modB", fid_base=0)

    modA_v3_src = TMP / "modA_v3.bend"
    modA_v3_src.write_text(modA_v3_txt)
    iface_v3_meta, iface_v3_wall = build_iface(prefix_v3_src, modB_v3_o, modA_v3_src, TMP / "iface_v3")
    iface_v3 = Path(iface_v3_meta["carrierPath"])
    iface_v3_stamp = iface_v3_meta["stamp"]
    iface_v3_base = Path(iface_v3_meta["combinedPath"])
    assert iface_v3_stamp != iface_v1_stamp, "Expected interface stamp to change on signature edit!"

    # 3a: Stale stamp against new carrier must be rejected!
    rc_stale_stamp, err_stale_stamp, stale_stamp_ms = run_emit(
        modA_v1_src, TMP / "modA_stale_stamp.o",
        mode="module", mod_name="modA", fid_base=512,
        base_p=iface_v3_base, base_key=str(iface_v3_base),
        carrier_p=iface_v3, stamp=iface_v1_stamp,
        expect_ok=False,
    )
    assert rc_stale_stamp != 0, "Expected stale stamp to be rejected!"

    # 3b: Old Module A against new B interface must be rejected by type-checker!
    rc_old_a, err_old_a, old_a_ms = run_emit(
        modA_v1_src, TMP / "modA_old_against_v3.o",
        mode="module", mod_name="modA", fid_base=512,
        base_p=iface_v3_base, base_key=str(iface_v3_base),
        carrier_p=iface_v3, stamp=iface_v3_stamp,
        expect_ok=False,
    )
    assert rc_old_a != 0, "Expected incompatible old Module A to be rejected!"

    # 3c: Rebuilt updated Module A against new B interface passes and matches monolithic!
    modA_v3_o = TMP / "modA_v3.o"
    _, modA_v3_meta, modA_v3_wall = run_emit(
        modA_v3_src, modA_v3_o,
        mode="module", mod_name="modA", fid_base=512,
        base_p=iface_v3_base, base_key=str(iface_v3_base),
        carrier_p=iface_v3, stamp=iface_v3_stamp,
    )
    prep_v3_ms = prepare_module_objs(modB_v3_o, modA_v3_o, TMP / "modB_v3.prep.o", TMP / "modA_v3.prep.o")
    link_v3_ms, sep_v3_out = link_merged(TMP / "modB_v3.prep.o", TMP / "modA_v3.prep.o", TMP / "sep_v3.exe")
    assert sep_v3_out == mono_v3_out == "54", f"Case 3 mismatch: sep={sep_v3_out!r} mono={mono_v3_out!r}"
    print(f"  [PASS] Incompatible layout change: stale_stamp rc={rc_stale_stamp}, old_A rc={rc_old_a}, rebuilt A->B={sep_v3_out} == mono={mono_v3_out}", flush=True)

    results = {
        "case1_clean_ab": {
            "mono_out": mono_v1_out,
            "sep_out": sep_v1_out,
            "mono_wall_ms": mono_v1_wall,
            "mono_link_ms": mono_v1_link_ms,
            "modB_wall_ms": modB_v1_wall,
            "modB_segs": modB_v1_meta["segCount"],
            "iface_wall_ms": iface_v1_wall,
            "modA_wall_ms": modA_v1_wall,
            "modA_segs": modA_v1_meta["segCount"],
            "objcopy_ms": prep_v1_ms,
            "merge_link_ms": link_v1_ms,
            "total_sep_ms": round(modB_v1_wall + iface_v1_wall + modA_v1_wall + prep_v1_ms + link_v1_ms, 1),
        },
        "case2_body_only_b_edit": {
            "mono_out": mono_v2_out,
            "sep_out": sep_v2_out,
            "modA_reused_sha256_identical": True,
            "modB_rebuild_wall_ms": modB_v2_wall,
            "objcopy_ms": prep_v2_ms,
            "merge_link_ms": link_v2_ms,
            "total_edit_ms": round(modB_v2_wall + prep_v2_ms + link_v2_ms, 1),
        },
        "case3_incompatible_sig_change": {
            "stamp_changed": True,
            "stale_stamp_rejected": {"rc": rc_stale_stamp, "ms": stale_stamp_ms, "err": err_stale_stamp},
            "old_modA_rejected": {"rc": rc_old_a, "ms": old_a_ms, "err": err_old_a},
            "mono_out": mono_v3_out,
            "sep_out": sep_v3_out,
            "modB_wall_ms": modB_v3_wall,
            "iface_wall_ms": iface_v3_wall,
            "modA_wall_ms": modA_v3_wall,
            "objcopy_ms": prep_v3_ms,
            "merge_link_ms": link_v3_ms,
        },
    }
    OUT_JSON.write_text(json.dumps(results, indent=2) + "\n")
    shutil.rmtree(TMP, ignore_errors=True)
    print(f"\nALL 3 CROSS-MODULE A->B CASES PASSED! Saved {OUT_JSON}", flush=True)


if __name__ == "__main__":
    main()
