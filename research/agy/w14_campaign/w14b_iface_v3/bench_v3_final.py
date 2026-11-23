#!/usr/bin/env python3
"""W14-B Final Native Benchmark & Parity Gate for x86-iface v3 (v3e):
- Combines FIX A+ (CPS+HO transitive pruning + w13d_p113pl_candidates_fast + skip p128br_scan)
- FIX B+ (Zero-fallback direct-dispatch .p130 decoder: Con+KTerm+Leaf+Node inline = 92.5% of recs)
- FIX C+ (Strictly-linear fast .p130 encoder: pre-interned top-10 strs + Absent + ADT/Ref leaf interning)
- OPT #4 (Fast p86_plan: skip driver_report_data, suffix-only owned, skip annotating upstream stubs)
Dedicated CPUs: 0 and 1 ONLY.
"""
from __future__ import annotations

import hashlib
import json
import subprocess
import sys
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

sys.path.insert(0, str(OUT_DIR))
import bench_v3_clean as bc


def patch_v3_final(src: str) -> str:
    """Apply complete x86-iface v3 (FIX A+ + B+ + C+ + OPT #4) to m11.bend or compiler.bend."""
    src = bc.patch_m11_v3c(src)

    # 1. Replace w10_if_fast_abi_prep with CPS+HO-seeded pruning & skip p128br_scan
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

    # 2. Skip annotating upstream stubs in w14_plan_checked
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

    # 3. Remove dead w10_if_fast_abi_run and w10_if_fast_abi_scan (frees ~30 FIDs!)
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

    # 1. Build m11_v3_final.o at -O0 on CPU 1
    m11_src = "import Base\n" + (K14_DIR / "m11.bend").read_text(encoding="utf-8")
    m11_p = TMP / "m11_v3_final.bend"
    m11_p.write_text(patch_v3_final(m11_src), encoding="utf-8")
    m11_o = TMP / "m11_v3_final.o"
    print("=== 1. Building native m11_v3_final.o (-O0) on CPU 1 ===", flush=True)
    cmp_ms, _ = bc.run_native(
        N5_O2,
        ["x86-module-fast", str(m11_p), str(BASE_FILE), "cache", str(CACHE_IFACE / "m10.p130"), recs["m10"]["stamp"], "61935", "m11"],
        m11_o, TMP / "m11_v3_final.err", 1,
    )
    print(f"  m11_v3_final.o built in {cmp_ms} ms ({m11_o.stat().st_size:,} B)", flush=True)

    # Also build m11_v3_final_o2.o at -O2 on CPU 1 to measure -O2 speedup of m11!
    m11_o2 = TMP / "m11_v3_final_o2.o"
    print("=== 1b. Building native m11_v3_final_o2.o (-O2) on CPU 1 ===", flush=True)
    cmp_o2_ms, _ = bc.run_native(
        N5_O2,
        ["x86-module", str(m11_p), str(BASE_FILE), "cache", str(CACHE_IFACE / "m10.p130"), recs["m10"]["stamp"], "61935", "m11"],
        m11_o2, TMP / "m11_v3_final_o2.err", 1,
    )
    print(f"  m11_v3_final_o2.o built in {cmp_o2_ms} ms ({m11_o2.stat().st_size:,} B)", flush=True)

    n6_base = TMP / "n6_base"
    n6_v3 = TMP / "n6_v3_final"
    n6_v3_o2 = TMP / "n6_v3_final_o2"
    bc.link_bin(CACHE_OBJ / "m11.o", n6_base, 1)
    bc.link_bin(m11_o, n6_v3, 1)
    bc.link_bin(m11_o2, n6_v3_o2, 1)

    results = {
        "m11_build_o0_ms": cmp_ms,
        "m11_build_o2_ms": cmp_o2_ms,
        "modules": {},
    }

    for mod, prev, down_mod, down_fb in (("m06", "m05b", "m07", 39837), ("m10", "m09", "m11", 61935)):
        print(f"\n=== 2. Benchmarking {mod} on CPU 0 (n6_base vs n6_v3 vs n6_v3_o2) ===", flush=True)
        out_b = TMP / f"fb_{mod}.p130"
        out_v = TMP / f"fv_{mod}.p130"
        out_v2 = TMP / f"fv2_{mod}.p130"

        b_ms, b_st = bc.run_native(n6_base, ["x86-iface", str(TMP / f"src/{mod}_exp.bend"), str(BASE_FILE), "cache", str(CACHE_IFACE / f"{prev}.p130"), recs[prev]["stamp"]], out_b, TMP / f"fb_{mod}.err", 0)
        b_sz = out_b.stat().st_size

        v_ms, v_st = bc.run_native(n6_v3, ["x86-iface", str(TMP / f"src/{mod}_exp.bend"), str(BASE_FILE), "cache", str(CACHE_IFACE / f"{prev}.p130"), recs[prev]["stamp"]], out_v, TMP / f"fv_{mod}.err", 0)
        v_sz = out_v.stat().st_size

        v2_ms, v2_st = bc.run_native(n6_v3_o2, ["x86-iface", str(TMP / f"src/{mod}_exp.bend"), str(BASE_FILE), "cache", str(CACHE_IFACE / f"{prev}.p130"), recs[prev]["stamp"]], out_v2, TMP / f"fv2_{mod}.err", 0)
        out_v2.unlink()

        assert b_st == v_st == v2_st == recs[mod]["stamp"], f"stamp mismatch on {mod}"
        sp_o0 = round(b_ms / v_ms, 3)
        sp_o2 = round(b_ms / v2_ms, 3)
        print(f"  {mod}: n6_base={b_ms} ms ({b_sz/1e6:.2f} MB) | n6_v3(-O0)={v_ms} ms ({sp_o0}x, {v_sz/1e6:.2f} MB) | n6_v3(m11 -O2)={v2_ms} ms ({sp_o2}x) | stamp_exact=True", flush=True)

        # Downstream parity: compile down_mod with n5_o2 from BOTH out_b and out_v!
        o_b = TMP / f"fpar_b_{down_mod}.o"
        o_v = TMP / f"fpar_v_{down_mod}.o"
        bc.run_native(N5_O2, ["x86-module-fast", str(TMP / f"src/{down_mod}_exp.bend"), str(BASE_FILE), "cache", str(out_b), b_st, str(down_fb), down_mod], o_b, TMP / f"fpar_b_{down_mod}.err", 0)
        bc.run_native(N5_O2, ["x86-module-fast", str(TMP / f"src/{down_mod}_exp.bend"), str(BASE_FILE), "cache", str(out_v), v_st, str(down_fb), down_mod], o_v, TMP / f"fpar_v_{down_mod}.err", 0)
        sh_b, sh_v = bc.sha256(o_b), bc.sha256(o_v)
        print(f"  {down_mod}.o SHA-256 parity={sh_b == sh_v} ({sh_v})", flush=True)
        assert sh_b == sh_v

        for f in (out_b, out_v, o_b, o_v):
            f.unlink()

        results["modules"][mod] = {
            "n6_base_o0_ms": b_ms,
            "n6_v3_o0_ms": v_ms,
            "n6_v3_m11_o2_ms": v2_ms,
            "speedup_o0_vs_o0": sp_o0,
            "speedup_m11_o2_vs_o0": sp_o2,
            "base_p130_bytes": b_sz,
            "v3_p130_bytes": v_sz,
            "p130_size_reduction_pct": round(100.0 * (1.0 - v_sz / b_sz), 2),
            "stamp": v_st,
            "stamp_exact": True,
            "downstream_mod": down_mod,
            "downstream_o_sha256": sh_v,
            "downstream_o_bit_identical": True,
            "n5_o2_baseline_ms": recs[mod]["ms"],
            "projected_n5_o2_v3_ms": round(recs[mod]["ms"] / sp_o0, 1),
        }

    for f in (n6_base, n6_v3, n6_v3_o2, m11_o, m11_o2):
        f.unlink()

    (OUT_DIR / "bench_v3_final.json").write_text(json.dumps(results, indent=2))
    print("\nALL BENCHMARKS & PARITY PASSED! Saved bench_v3_final.json", flush=True)


if __name__ == "__main__":
    main()
