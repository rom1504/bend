#!/usr/bin/env python3
"""W14-B Step 1c: Fine-grained counts & sub-stage timings for p86_plan_loaded and fast_abi (CPU 1)."""
from __future__ import annotations

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


def patch_m11_fine(src: str) -> str:
    old_run = """@unsafe
def w10_if_fast_abi_run(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, split: KDef & List<&2, String>) -> IO(U32):
  (+seeded_sigs, +active_filtered) = split
  +sigs = book_cached(nq_signatures(book, names), 0)
  +raw = p113pl_candidates(book, active_filtered, bangs, sigs)
  +fns0 = p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32)
  +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
  w10_if_emit_seed(seed, suffix, abi)"""

    new_run = """@unsafe
def w14f_log(+msg: String) -> IO(Unit):
  IO.print_err("[w14-fine] " ++ msg ++ "\\n")

@unsafe
def w14f_ms(+t0: Nat, +t1: Nat) -> String:
  Nat.show(Nat.sub(t1, t0)) ++ "ms"

@unsafe
def w10_if_fast_abi_run(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, split: KDef & List<&2, String>) -> IO(U32):
  (+seeded_sigs, +active_filtered) = split
  do IO<U32>:
    _ : Unit <- w14f_log("counts names=" ++ U32.show(nt_count(String, names)) ++ " suffix=" ++ U32.show(nt_count(KDef, suffix)) ++ " active_filtered=" ++ U32.show(nt_count(String, active_filtered)) ++ " workers=" ++ U32.show(nt_count(P113DFunction, workers)))
    +t0 : Nat <- IO.now()
    +sigs : List<&2, KDef> <- IO.pure(List<&2, KDef>, book_cached(nq_signatures(book, names), 0))
    +raw : List<&2, P113DCandidate> <- IO.pure(List<&2, P113DCandidate>, p113pl_candidates(book, active_filtered, bangs, sigs))
    +t1 : Nat <- IO.now()
    _ : Unit <- w14f_log("p113pl_candidates=" ++ w14f_ms(t0, t1) ++ " raw=" ++ U32.show(nt_count(P113DCandidate, raw)))
    +fns0 : List<&2, P113DFunction> <- IO.pure(List<&2, P113DFunction>, p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32))
    +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
    w10_if_emit_seed(seed, suffix, abi)"""
    assert old_run in src, "old_run not found"
    src = src.replace(old_run, new_run, 1)

    old_trace = """@unsafe
def w10_if_run_trace(+seed: P86Seed, +load: FPrefixLoad) -> IO(U32):
  match load:
    case FPrefixLoad{FLoadTrace{FResult{_, +lerr, _}, _, _}, _, +suffix, _}:
      nt_choose(IO(U32), String.is_empty(lerr),
        z => w10_if_run_fast_plan(seed, suffix, p86_plan_loaded(seed, load)),
        z => IO.die(U32, 1, "x86-iface parse: " ++ lerr))"""

    new_trace = """@unsafe
def w14f_plan_checked(+seed: P86Seed, +load: FPrefixLoad, +suffix: List<&2, KDef>, +world: KBasePreparedWorld, +original: List<&2, KDef>, +t1: Nat, res: DResult) -> IO(U32):
  match res:
    case DResult{+cerr, +cbook, _}:
      nt_choose(IO(U32), String.is_empty(cerr),
        u => do IO<U32>:
          +rep : DR_Report <- IO.pure(DR_Report, driver_report_data(original))
          +t2 : Nat <- IO.now()
          _ : Unit <- w14f_log("plan_2_driver_report=" ++ w14f_ms(t1, t2))
          +oerr : String <- IO.pure(String, driver_emit_owned(cbook))
          +jerr : String <- IO.pure(String, j_compile_error(cbook))
          +t3 : Nat <- IO.now()
          _ : Unit <- w14f_log("plan_3_owned_jerr=" ++ w14f_ms(t2, t3))
          +ctx : List<&2, KDef> <- IO.pure(List<&2, KDef>, book_context_world(cbook, load, world))
          +t4 : Nat <- IO.now()
          _ : Unit <- w14f_log("plan_4_book_ctx_world=" ++ w14f_ms(t3, t4))
          +stops : List<&2, String> <- IO.pure(List<&2, String>, nc_annotation_stops(ctx))
          +rbook : List<&2, KDef> <- IO.pure(List<&2, KDef>, reach_book(ctx, ["main"], stops))
          +t5 : Nat <- IO.now()
          _ : Unit <- w14f_log("plan_5_reach_book=" ++ w14f_ms(t4, t5) ++ " rbook=" ++ U32.show(nt_count(KDef, rbook)))
          +ann : List<&2, KDef> <- IO.pure(List<&2, KDef>, annotate_selected(ctx, rbook, stops))
          +t6 : Nat <- IO.now()
          _ : Unit <- w14f_log("plan_6_annotate_sel=" ++ w14f_ms(t5, t6))
          w10_if_run_fast_plan(seed, suffix, p86_plan_annotated(ctx, stops, "", ann)),
        u => IO.die(U32, 1, "check: " ++ cerr))

@unsafe
def w14f_plan_timed(+seed: P86Seed, +load: FPrefixLoad, +suffix: List<&2, KDef>) -> IO(U32):
  match seed load:
    case P86Seed{base, sbook, fresh, ready, +world} FPrefixLoad{FLoadTrace{FResult{+original, +lerr, _}, _, _}, _, _, _}:
      do IO<U32>:
        +t0 : Nat <- IO.now()
        +res : DResult <- IO.pure(DResult, nt_choose(DResult, p143cg_enough(suffix, 256),
          v => p143cb_program(load, Nil{}, world, True{}),
          v => check_program_diagnostic_world(load, Nil{}, world)))
        +t1 : Nat <- IO.now()
        _ : Unit <- w14f_log("plan_1_typecheck=" ++ w14f_ms(t0, t1))
        w14f_plan_checked(seed, load, suffix, world, original, t1, res)

@unsafe
def w10_if_run_trace(+seed: P86Seed, +load: FPrefixLoad) -> IO(U32):
  match load:
    case FPrefixLoad{FLoadTrace{FResult{_, +lerr, _}, _, _}, _, +suffix, _}:
      nt_choose(IO(U32), String.is_empty(lerr),
        z => w14f_plan_timed(seed, load, suffix),
        z => IO.die(U32, 1, "x86-iface parse: " ++ lerr))"""
    assert old_trace in src, "old_trace not found"
    src = src.replace(old_trace, new_trace, 1)
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
    m11_path = TMP / "m11_fine.bend"
    m11_path.write_text(patch_m11_fine(m11_src), encoding="utf-8")

    m11_o = TMP / "m11_fine.o"
    m11_err = TMP / "m11_fine.err"
    print("Compiling m11_fine.o on CPU 1...", flush=True)
    cmp_ms, _ = run_native(
        N5_O2,
        ["x86-module-fast", str(m11_path), str(BASE_FILE), "cache", str(CACHE_IFACE / "m10.p130"), recs["m10"]["stamp"], "61935", "m11"],
        m11_o, m11_err, cpu=CPU,
    )
    print(f"  m11_fine.o built in {cmp_ms} ms", flush=True)

    n6_fine = TMP / "n6_fine"
    objs = [CACHE_OBJ / f"{m}.o" for m in MOD_NAMES[:-1]] + [m11_o]
    subprocess.run(
        ["timeout", "60", "taskset", "-c", str(CPU), CC, "-O2", "-no-pie",
         str(CACHE_OBJ / "merge_n6_w13.o"), *[str(o) for o in objs], str(RT), "-o", str(n6_fine), "-lm", "-lpthread"],
        check=True,
    )

    for mod, prev in (("m06", "m05b"), ("m10", "m09")):
        out_p130 = TMP / f"fine_{mod}.p130"
        err_f = TMP / f"fine_{mod}.err"
        ms, err = run_native(
            n6_fine,
            ["x86-iface", str(TMP / f"src/{mod}_exp.bend"), str(BASE_FILE), "cache", str(CACHE_IFACE / f"{prev}.p130"), recs[prev]["stamp"]],
            out_p130, err_f, cpu=CPU,
        )
        out_p130.unlink()
        print(f"\n=== FINE BREAKDOWN {mod} (total={ms} ms) ===", flush=True)
        print(err, flush=True)

    n6_fine.unlink()
    m11_o.unlink()


if __name__ == "__main__":
    main()
