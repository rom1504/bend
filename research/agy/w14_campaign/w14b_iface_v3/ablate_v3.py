#!/usr/bin/env python3
"""W14-B Step 2a: Clean native ablation of OPT #1 (fast_abi) + OPT #4 (fast_plan) in m11 (CPU 1)."""
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
CPU = 1

OPT14_BEND = r'''
# === AGY-W14B OPT #1 + #4: Fast ABI + Fast Plan (strictly linear, ~15 FIDs) ===

@unsafe
def w14_p112s_light_book(+book: List<&2, KDef>, +constructors: List<&2, N_Constructor>) -> P112SPrepared:
  match book:
    case Con{+cache, +rest}:
      nt_choose(P112SPrepared, agy_str_eq(dk(cache), "BookCache"),
        v => P112SPrepared{Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache),
          [index_first(dc(cache)), KDef{"$native.static", "NativeStaticContext", 0, 0, kt("P112StaticImage", "", 0, 0, []), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, [missing(), nc_ctor_prepare(Con{cache, rest}), p112s_ctors(constructors, 0, missing()), missing()], False{}, False{}}], db(cache), du(cache)}, rest}, [], ""},
        v => P112SPrepared{book, [], "static preparation requires a fresh cached request"})
    case _: P112SPrepared{book, [], "static preparation requires a fresh cached request"}

@unsafe
def w14_p112s_light(+book: List<&2, KDef>, +constructors: List<&2, N_Constructor>) -> P112SPrepared:
  nt_choose(P112SPrepared, nc_pack_foreign(book), u => P112SPrepared{book, [], ""},
    u => w14_p112s_light_book(book, constructors))

@unsafe
def w14_plan_checked(+load: FPrefixLoad, +world: KBasePreparedWorld, +suffix: List<&2, KDef>, result: DResult) -> P86Plan:
  match result:
    case DResult{+error, +book, diagnostic}:
      kc(P86Plan, String.is_empty(error),
        u =>
          +oerr = driver_emit_owned(suffix)
          kc(P86Plan, String.is_empty(oerr),
            v =>
              +jerr = j_compile_error(book)
              kc(P86Plan, String.is_empty(jerr),
                w => p86_plan_context(book_context_world(book, load, world), ""),
                w => P86PlanError{"compile: " ++ jerr}),
            v => P86PlanError{"compile: " ++ oerr}),
        u => P86PlanError{"check: " ++ error})

@unsafe
def w14_plan_loaded(+seed: P86Seed, +load: FPrefixLoad) -> P86Plan:
  match seed load:
    case P86Seed{base, book, fresh, ready, +world} FPrefixLoad{FLoadTrace{FResult{original, +error, imports}, done, sources}, prefix, +suffix, eligible}:
      kc(P86Plan, String.is_empty(error),
        u => w14_plan_checked(load, world, suffix, nt_choose(DResult, p143cg_enough(suffix, 256),
          v => p143cb_program(load, Nil{}, world, True{}),
          v => check_program_diagnostic_world(load, Nil{}, world))),
        u => P86PlanError{"parse: " ++ error})
'''


def patch_opt14(src: str) -> str:
    anchor = "@unsafe\ndef w10_if_emit_freshened("
    assert anchor in src
    src = src.replace(anchor, OPT14_BEND + "\n" + anchor, 1)

    old_abi = """@unsafe
def w10_if_fast_abi_run(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, split: KDef & List<&2, String>) -> IO(U32):
  (+seeded_sigs, +active_filtered) = split
  +sigs = book_cached(nq_signatures(book, names), 0)
  +raw = p113pl_candidates(book, active_filtered, bangs, sigs)
  +fns0 = p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32)
  +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
  w10_if_emit_seed(seed, suffix, abi)

@unsafe
def w10_if_fast_abi_scan(+seed: P86Seed, +suffix: List<&2, KDef>, +suf_set: KDef, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, scan: P128BROpen) -> IO(U32):
  match scan:
    case P128BROpen{+workers, helpers, retry, +serr}:
      nt_choose(IO(U32), String.is_empty(serr),
        u =>
          +worker_sigs = p113e_signatures(workers, missing())
          +remaining = p167ob_remaining(book, names, bangs, worker_sigs)
          +filtered = w7_filter_remaining(book, remaining, bangs)
          w10_if_fast_abi_run(seed, suffix, book, names, bangs, workers, w10_if_split_upstream(book, suf_set, filtered, worker_sigs, Nil{})),
        u => IO.die(U32, 1, "x86-iface: early scalar scan: " ++ serr))

@unsafe
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
        u => IO.die(U32, 1, "x86-iface: static prepare: " ++ perr))

@unsafe
def w10_if_fast_abi_req(+seed: P86Seed, +suffix: List<&2, KDef>, request: NR_Request) -> IO(U32):
  match request:
    case NR_Request{+source, +book, +names, paths, scope, +bound}:
      +err = nc_compile_error_known(source, bound)
      nt_choose(IO(U32), String.is_empty(err),
        u =>
          +ctors = nc_add_ctors(nc_default_ctors(), p144o_constructors(source, source, p144o_payload(nc_ctor_context(book))))
          w10_if_fast_abi_prep(seed, suffix, names, p112s_prepare(book, names, ctors)),
        u => IO.die(U32, 1, "x86-iface: " ++ err))"""

    new_abi = """@unsafe
def w10_if_fast_abi_run(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, split: KDef & List<&2, String>) -> IO(U32):
  (+seeded_sigs, +active_filtered) = split
  +raw = w13d_p113pl_candidates_fast(book, active_filtered, bangs)
  +fns0 = p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32)
  +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
  w10_if_emit_seed(seed, suffix, abi)

@unsafe
def w10_if_fast_abi_prep(+seed: P86Seed, +suffix: List<&2, KDef>, +names: List<&2, String>, prep: P112SPrepared) -> IO(U32):
  match prep:
    case P112SPrepared{+sbook, nodes, +perr}:
      nt_choose(IO(U32), String.is_empty(perr),
        u =>
          +suf_set = w10_if_suffix_set(suffix, missing())
          +bangs = nc_bangs_names(sbook, names)
          +filtered = w7_filter_remaining(sbook, names, bangs)
          w10_if_fast_abi_run(seed, suffix, sbook, names, bangs, Nil{}, w10_if_split_upstream(sbook, suf_set, filtered, missing(), Nil{})),
        u => IO.die(U32, 1, "x86-iface: static prepare: " ++ perr))

@unsafe
def w10_if_fast_abi_req(+seed: P86Seed, +suffix: List<&2, KDef>, request: NR_Request) -> IO(U32):
  match request:
    case NR_Request{+source, +book, +names, paths, scope, +bound}:
      +err = nc_compile_error_known(source, bound)
      nt_choose(IO(U32), String.is_empty(err),
        u =>
          +ctors = nc_add_ctors(nc_default_ctors(), p144o_constructors(source, source, p144o_payload(nc_ctor_context(book))))
          w10_if_fast_abi_prep(seed, suffix, names, w14_p112s_light(book, ctors)),
        u => IO.die(U32, 1, "x86-iface: " ++ err))"""
    assert old_abi in src
    src = src.replace(old_abi, new_abi, 1)
    src = src.replace("p86_plan_loaded(seed, load)", "w14_plan_loaded(seed, load)", 1)
    return src


def run_native(binary: Path, args: list[str], out_f: Path, err_f: Path, cpu: int) -> tuple[float, str]:
    cmd = [
        "timeout", "120",
        "bash", "-c", 'ulimit -s 262144 && exec taskset -c "$1" "$2" "${@:3}"',
        "_", str(cpu), str(binary), *args,
    ]
    t0 = time.perf_counter()
    with out_f.open("wb") as of, err_f.open("wb") as ef:
        r = subprocess.run(cmd, stdout=of, stderr=ef, cwd=ROOT)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    err = err_f.read_text(encoding="utf-8", errors="replace").strip()
    if r.returncode != 0:
        raise RuntimeError(f"native failed rc={r.returncode}: {err[-800:]}")
    return ms, err


def main():
    d = json.loads(W13_RESULTS.read_text())
    recs = {r["module"]: r for r in d["stage2b_true_cold_pipelined_7core_native"]["iface_records"]}

    m11_src = "import Base\n" + (K14_DIR / "m11.bend").read_text(encoding="utf-8")
    p = TMP / "m11_opt14.bend"
    p.write_text(patch_opt14(m11_src), encoding="utf-8")
    o = TMP / "m11_opt14.o"
    run_native(N5_O2, ["x86-module-fast", str(p), str(BASE_FILE), "cache", str(CACHE_IFACE / "m10.p130"), recs["m10"]["stamp"], "61935", "m11"], o, TMP / "m11_opt14.err", CPU)

    bin_opt14 = TMP / "n6_opt14"
    objs = [CACHE_OBJ / f"{m}.o" for m in MOD_NAMES[:-1]] + [o]
    subprocess.run(
        ["timeout", "60", "taskset", "-c", str(CPU), CC, "-O2", "-no-pie",
         str(CACHE_OBJ / "merge_n6_w13.o"), *[str(x) for x in objs], str(RT), "-o", str(bin_opt14), "-lm", "-lpthread"],
        check=True,
    )

    for mod, prev in (("m06", "m05b"), ("m10", "m09")):
        out = TMP / f"opt14_{mod}.p130"
        ms, st = run_native(
            bin_opt14,
            ["x86-iface", str(TMP / f"src/{mod}_exp.bend"), str(BASE_FILE), "cache", str(CACHE_IFACE / f"{prev}.p130"), recs[prev]["stamp"]],
            out, TMP / f"opt14_{mod}.err", CPU,
        )
        sz = out.stat().st_size
        out.unlink()
        print(f"  [OPT #1+#4] {mod}: {ms} ms ({sz/1e6:.2f} MB) stamp_exact={st == recs[mod]['stamp']}", flush=True)

    bin_opt14.unlink()
    o.unlink()


if __name__ == "__main__":
    main()
