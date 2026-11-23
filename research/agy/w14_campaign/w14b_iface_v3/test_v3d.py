#!/usr/bin/env python3
"""W14-B Step 2d: Test v3d (cps0 HO-pruning + skip p128br_scan + skip annotating upstream stubs + FIX B + FIX C)."""
from __future__ import annotations

import hashlib
import json
import subprocess
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
N5_O2 = ROOT / "selfhost/build/agy/wave13-native-mod/n5_o2"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
K14_DIR = ROOT / "research/agy/w10_mod_bend/k14_wave13"
CACHE_IFACE = Path("/tmp/agy_k14_w13_cache/iface")
CACHE_OBJ = Path("/tmp/agy_k14_w13_cache/obj_o0")
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
W13_RESULTS = ROOT / "research/agy/w13_campaign/w13_int_n5_o2/results.json"

OUT_DIR = ROOT / "research/agy/w14_campaign/w14b_iface_v3"
TMP = Path("/tmp/agy_w14b")
MOD_NAMES = [
    "m00a", "m00b", "m01", "m02", "m03", "m04",
    "m05a", "m05b", "m06", "m07", "m08", "m09", "m10", "m11",
]

import sys
sys.path.insert(0, str(OUT_DIR))
import bench_v3_clean as bc


def patch_m11_v3d(src: str) -> str:
    # Start from v3c
    src = bc.patch_m11_v3c(src)

    # 1. Seed cps0 with HO choosers (nt_choose, kc, f_choose, p151_choose) + skip p128br_scan!
    old_prep = """@unsafe
def w10_if_fast_abi_prep(+seed: P86Seed, +suffix: List<&2, KDef>, +names: List<&2, String>, prep: P112SPrepared) -> IO(U32):
  match prep:
    case P112SPrepared{+sbook, nodes, +perr}:
      nt_choose(IO(U32), String.is_empty(perr),
        u =>
          +suf_set = w10_if_suffix_set(suffix, missing())
          +bangs = nc_bangs_names(sbook, names)
          +scan_names = w10_if_drop_upstream_stubs(sbook, suf_set, no_candidate_names(sbook, names, bangs))
          w10_if_fast_abi_scan(seed, suffix, suf_set, sbook, names, bangs,
            p128br_scan(sbook, scan_names, Nil{}, Nil{}, Nil{}, Nil{})),
        u => IO.die(U32, 1, "x86-iface: static prepare: " ++ perr))"""

    new_prep = """@unsafe
def w14d_cps_seed() -> KDef:
  +c0 = p111v_put(missing(), "nt_choose", "W7Rem", 1, 0)
  +c1 = p111v_put(c0, "kc", "W7Rem", 1, 0)
  +c2 = p111v_put(c1, "f_choose", "W7Rem", 1, 0)
  +c3 = p111v_put(c2, "p151_choose", "W7Rem", 1, 0)
  +c4 = p111v_put(c3, "IO.bind", "W7Rem", 1, 0)
  p111v_put(c4, "IO.pure", "W7Rem", 1, 0)

@unsafe
def w10_if_fast_abi_prep(+seed: P86Seed, +suffix: List<&2, KDef>, +names: List<&2, String>, prep: P112SPrepared) -> IO(U32):
  match prep:
    case P112SPrepared{+sbook, nodes, +perr}:
      nt_choose(IO(U32), String.is_empty(perr),
        u =>
          +suf_set = w10_if_suffix_set(suffix, missing())
          +bangs = nc_bangs_names(sbook, names)
          w14a_fast_abi_go(seed, suffix, sbook, names, bangs, Nil{}, w14a_collect_cps(sbook, suf_set, names, missing(), w14d_cps_seed(), Nil{})),
        u => IO.die(U32, 1, "x86-iface: static prepare: " ++ perr))"""
    assert old_prep in src, "old_prep not found"
    src = src.replace(old_prep, new_prep, 1)

    # 2. Skip annotating upstream stubs in w14_plan_checked!
    old_plan = """              kc(P86Plan, String.is_empty(jerr),
                w => p86_plan_context(book_context_world(book, load, world), ""),
                w => P86PlanError{"compile: " ++ jerr}),"""

    new_plan = """              kc(P86Plan, String.is_empty(jerr),
                w => w14d_plan_context(book_context_world(book, load, world), suffix),
                w => P86PlanError{"compile: " ++ jerr}),"""
    assert old_plan in src, "old_plan not found"

    plan_helper = """@unsafe
def w14d_ann_stops(+book: List<&2, KDef>, +suf_set: KDef, rbook: List<&2, KDef>, +acc: List<&2, String>) -> List<&2, String>:
  match rbook:
    case Nil{}: acc
    case Con{d, +rest}:
      +nm0 = dn(d)
      nt_choose(List<&2, String>, w10_if_abi_has(suf_set, nm0),
        u => w14d_ann_stops(book, suf_set, rest, acc),
        u => nt_choose(List<&2, String>, U32.is_gt(w10_if_stub_kind(book, nm0), 0),
          v => w14d_ann_stops(book, suf_set, rest, Con{nm0, acc}),
          v => w14d_ann_stops(book, suf_set, rest, acc)))

@unsafe
def w14d_plan_context(+context: List<&2, KDef>, +suffix: List<&2, KDef>) -> P86Plan:
  +stops = nc_annotation_stops(context)
  +rbook = reach_book(context, ["main"], stops)
  +suf_set = w10_if_suffix_set(suffix, missing())
  +astops = w14d_ann_stops(context, suf_set, rbook, stops)
  p86_plan_annotated(context, stops, "", annotate_selected(context, rbook, astops))

"""
    src = src.replace("@unsafe\ndef w14_plan_checked(", plan_helper + "@unsafe\ndef w14_plan_checked(", 1)
    src = src.replace(old_plan, new_plan, 1)

    # Remove do IO timing block (saves ~15 FIDs) and w14_dec_leaf/node (saves ~25 FIDs; handled by w14_dec_rare_fields)
    src = src.replace("    case 6: w14_dec_leaf(text, nodes, strings, made, sn, begin, end, left)\n", "", 1)
    src = src.replace("    case 7: w14_dec_node(text, nodes, strings, made, sn, begin, end, left)\n", "", 1)

    # Free ~30 FIDs by removing now-dead w10_if_fast_abi_run and w10_if_fast_abi_scan in m11
    for dead in (
        """@unsafe
def w10_if_fast_abi_run(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, split: KDef & List<&2, String>) -> IO(U32):
  (+seeded_sigs, +active_filtered) = split
  +sigs = book_cached(nq_signatures(book, names), 0)
  +raw = p113pl_candidates(book, active_filtered, bangs, sigs)
  +fns0 = p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32)
  +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
  w10_if_emit_seed(seed, suffix, abi)""",
        """@unsafe
def w10_if_fast_abi_scan(+seed: P86Seed, +suffix: List<&2, KDef>, +suf_set: KDef, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, scan: P128BROpen) -> IO(U32):
  match scan:
    case P128BROpen{+workers, helpers, retry, +serr}:
      nt_choose(IO(U32), String.is_empty(serr),
        u =>
          +worker_sigs = p113e_signatures(workers, missing())
          +remaining = p167ob_remaining(book, names, bangs, worker_sigs)
          w14a_fast_abi_go(seed, suffix, book, names, bangs, workers, w14a_collect_cps(book, suf_set, remaining, worker_sigs, missing(), Nil{})),
        u => IO.die(U32, 1, "x86-iface: early scalar scan: " ++ serr))""",
    ):
        assert dead in src, f"dead not found: {dead[:40]}"
        src = src.replace(dead, "", 1)
    return src


def main():
    d = json.loads(W13_RESULTS.read_text())
    recs = {r["module"]: r for r in d["stage2b_true_cold_pipelined_7core_native"]["iface_records"]}

    m11_src = "import Base\n" + (K14_DIR / "m11.bend").read_text(encoding="utf-8")
    p = TMP / "m11_v3d.bend"
    p.write_text(patch_m11_v3d(m11_src), encoding="utf-8")
    o = TMP / "m11_v3d.o"
    print("=== 1. Compiling m11_v3d.o on CPU 1 ===", flush=True)
    cmp_ms, _ = bc.run_native(N5_O2, ["x86-module-fast", str(p), str(BASE_FILE), "cache", str(CACHE_IFACE / "m10.p130"), recs["m10"]["stamp"], "61935", "m11"], o, TMP / "m11_v3d.err", 1)
    print(f"  m11_v3d.o built in {cmp_ms} ms ({o.stat().st_size:,} B)", flush=True)

    n6_v3d = TMP / "n6_v3d"
    bc.link_bin(o, n6_v3d, 1)

    for mod, prev in (("m06", "m05b"), ("m10", "m09")):
        out = TMP / f"v3d_{mod}.p130"
        ms, err = bc.run_native(n6_v3d, ["x86-iface", str(TMP / f"src/{mod}_exp.bend"), str(BASE_FILE), "cache", str(CACHE_IFACE / f"{prev}.p130"), recs[prev]["stamp"]], out, TMP / f"v3d_{mod}.err", 0)
        sz = out.stat().st_size
        out.unlink()
        lines = err.splitlines()
        st = lines[-1]
        print(f"  [v3d] {mod}: {ms} ms ({sz/1e6:.2f} MB) stamp_exact={st == recs[mod]['stamp']} | {' | '.join(lines[:-1])}", flush=True)

    n6_v3d.unlink()
    o.unlink()


if __name__ == "__main__":
    main()
