#!/usr/bin/env python3
"""W14-B Step 1b: Exact wall-clock sub-stage timing of x86-iface on m06 & m10 via 1-module m11 rebuild (CPU 1)."""
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


def patch_m11_stage_trace(src: str) -> str:
    """Instrument w10_iface_request and its sub-stages with IO.now() timestamps."""
    # 1. Replace w10_iface_request..w10_if_fast_abi_run..w10_if_emit_checked with timed versions
    old_req = """@unsafe
def w10_iface_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32), cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        w10_if_run_prepared(path, source, p88_cache_prepare(base_path, base, carrier, stamp)),
      u => w10_if_run_prepared(path, source, p86_prepare(base_path, base)))"""

    new_req = """@unsafe
def w10_iface_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +t0 : Nat <- IO.now()
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32), cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        +t1 : Nat <- IO.now()
        _ : Unit <- w14t_log("1a_read_files", t0, t1)
        +prep : P86Preparation <- IO.pure(P86Preparation, p88_cache_prepare(base_path, base, carrier, stamp))
        +t2 : Nat <- IO.now()
        _ : Unit <- w14t_log("1b_p88_decode", t1, t2)
        w10_if_run_prepared(path, source, prep),
      u => w10_if_run_prepared(path, source, p86_prepare(base_path, base)))"""
    assert old_req in src, "old_req not found"
    src = src.replace(old_req, new_req, 1)

    old_trace = """@unsafe
def w10_if_run_trace(+seed: P86Seed, +load: FPrefixLoad) -> IO(U32):
  match load:
    case FPrefixLoad{FLoadTrace{FResult{_, +lerr, _}, _, _}, _, +suffix, _}:
      nt_choose(IO(U32), String.is_empty(lerr),
        z => w10_if_run_fast_plan(seed, suffix, p86_plan_loaded(seed, load)),
        z => IO.die(U32, 1, "x86-iface parse: " ++ lerr))"""

    new_trace = """@unsafe
def w10_if_run_trace(+seed: P86Seed, +load: FPrefixLoad) -> IO(U32):
  match load:
    case FPrefixLoad{FLoadTrace{FResult{_, +lerr, _}, _, _}, _, +suffix, _}:
      nt_choose(IO(U32), String.is_empty(lerr),
        z => do IO<U32>:
          +t0 : Nat <- IO.now()
          +plan : P86Plan <- IO.pure(P86Plan, p86_plan_loaded(seed, load))
          +t1 : Nat <- IO.now()
          _ : Unit <- w14t_log("2b_p86_plan_loaded", t0, t1)
          w10_if_run_fast_plan(seed, suffix, plan),
        z => IO.die(U32, 1, "x86-iface parse: " ++ lerr))"""
    assert old_trace in src, "old_trace not found"
    src = src.replace(old_trace, new_trace, 1)

    old_hdr = """@unsafe
def w10_if_run_prepared(+path: String, +text: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32, 1, error)
    case P86PreparationReady{+seed}:
      match seed:
        case P86Seed{+base, +book, +fresh, +ready, world}:
          +begin = f_source_end(base)
          +source = f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1))
          w10_if_run_hdr(seed, base, book, fresh, ready, source, f_source_header(source))"""

    new_hdr = """@unsafe
def w10_if_run_prepared(+path: String, +text: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32, 1, error)
    case P86PreparationReady{+seed}:
      match seed:
        case P86Seed{+base, +book, +fresh, +ready, world}:
          do IO<U32>:
            +t0 : Nat <- IO.now()
            +begin : U32 <- IO.pure(U32, f_source_end(base))
            +source : FSource <- IO.pure(FSource, f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1)))
            +hdr : FHeader <- IO.pure(FHeader, f_source_header(source))
            +t1 : Nat <- IO.now()
            _ : Unit <- w14t_log("2a_hdr_start", t0, t1)
            w10_if_run_hdr(seed, base, book, fresh, ready, source, hdr)"""
    assert old_hdr in src, "old_hdr not found"
    src = src.replace(old_hdr, new_hdr, 1)

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
  do IO<U32>:
    +t0 : Nat <- IO.now()
    +sigs : List<&2, KDef> <- IO.pure(List<&2, KDef>, book_cached(nq_signatures(book, names), 0))
    +t1 : Nat <- IO.now()
    _ : Unit <- w14t_log("3d_nq_signatures", t0, t1)
    +raw : List<&2, P113DCandidate> <- IO.pure(List<&2, P113DCandidate>, p113pl_candidates(book, active_filtered, bangs, sigs))
    +t2 : Nat <- IO.now()
    _ : Unit <- w14t_log("3e_p113pl_candidates", t1, t2)
    +fns0 : List<&2, P113DFunction> <- IO.pure(List<&2, P113DFunction>, p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32))
    +t3 : Nat <- IO.now()
    _ : Unit <- w14t_log("3f_p113d_passes", t2, t3)
    +abi : W10IfAbi <- IO.pure(W10IfAbi, W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())})
    +t4 : Nat <- IO.now()
    _ : Unit <- w14t_log("3g_build_abi_maps", t3, t4)
    w10_if_emit_seed(seed, suffix, abi)

@unsafe
def w10_if_fast_abi_scan(+seed: P86Seed, +suffix: List<&2, KDef>, +suf_set: KDef, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, scan: P128BROpen) -> IO(U32):
  match scan:
    case P128BROpen{+workers, helpers, retry, +serr}:
      nt_choose(IO(U32), String.is_empty(serr),
        u => do IO<U32>:
          +t0 : Nat <- IO.now()
          +worker_sigs : KDef <- IO.pure(KDef, p113e_signatures(workers, missing()))
          +remaining : List<&2, String> <- IO.pure(List<&2, String>, p167ob_remaining(book, names, bangs, worker_sigs))
          +filtered : List<&2, String> <- IO.pure(List<&2, String>, w7_filter_remaining(book, remaining, bangs))
          +split : KDef & List<&2, String> <- IO.pure(KDef & List<&2, String>, w10_if_split_upstream(book, suf_set, filtered, worker_sigs, Nil{}))
          +t1 : Nat <- IO.now()
          _ : Unit <- w14t_log("3c_filter_split", t0, t1)
          w10_if_fast_abi_run(seed, suffix, book, names, bangs, workers, split),
        u => IO.die(U32, 1, "x86-iface: early scalar scan: " ++ serr))

@unsafe
def w10_if_fast_abi_prep(+seed: P86Seed, +suffix: List<&2, KDef>, +names: List<&2, String>, prep: P112SPrepared) -> IO(U32):
  match prep:
    case P112SPrepared{+sbook, nodes, +perr}:
      nt_choose(IO(U32), String.is_empty(perr),
        u => do IO<U32>:
          +t0 : Nat <- IO.now()
          +suf_set : KDef <- IO.pure(KDef, w10_if_suffix_set(suffix, missing()))
          +bangs : List<&2, String> <- IO.pure(List<&2, String>, nc_bangs_names(sbook, names))
          +scan_names : List<&2, String> <- IO.pure(List<&2, String>, w10_if_drop_upstream_stubs(sbook, suf_set, no_candidate_names(sbook, names, bangs)))
          +scan : P128BROpen <- IO.pure(P128BROpen, p128br_scan(sbook, scan_names, Nil{}, Nil{}, Nil{}, Nil{}))
          +t1 : Nat <- IO.now()
          _ : Unit <- w14t_log("3b_p128br_scan", t0, t1)
          w10_if_fast_abi_scan(seed, suffix, suf_set, sbook, names, bangs, scan),
        u => IO.die(U32, 1, "x86-iface: static prepare: " ++ perr))

@unsafe
def w10_if_fast_abi_req(+seed: P86Seed, +suffix: List<&2, KDef>, request: NR_Request) -> IO(U32):
  match request:
    case NR_Request{+source, +book, +names, paths, scope, +bound}:
      +err = nc_compile_error_known(source, bound)
      nt_choose(IO(U32), String.is_empty(err),
        u => do IO<U32>:
          +t0 : Nat <- IO.now()
          +ctors : List<&2, N_Constructor> <- IO.pure(List<&2, N_Constructor>, nc_add_ctors(nc_default_ctors(), p144o_constructors(source, source, p144o_payload(nc_ctor_context(book)))))
          +prep : P112SPrepared <- IO.pure(P112SPrepared, p112s_prepare(book, names, ctors))
          +t1 : Nat <- IO.now()
          _ : Unit <- w14t_log("3a_p112s_prepare", t0, t1)
          w10_if_fast_abi_prep(seed, suffix, names, prep),
        u => IO.die(U32, 1, "x86-iface: " ++ err))"""
    assert old_abi in src, "old_abi not found"
    src = src.replace(old_abi, new_abi, 1)

    old_emit = """@unsafe
def w10_if_emit_freshened(+stamp: String, +base_book: List<&2, KDef>, +base_ready: FReadyPrefixState, +base_world: KBasePreparedWorld, fdefs: FFreshDefs) -> IO(U32):
  match fdefs:
    case FFreshDefs{+fresh_suffix, +next_id}:
      +s_book = List.append(&2, KDef, base_book, fresh_suffix)
      +s_fresh : FFreshPrefixState = FFreshPrefixState{next_id, True{}}
      nt_choose(IO(U32), w10_if_all_stub_defs(fresh_suffix),
        u =>
          +s_ready : FReadyPrefixState = w10_if_ready_extend(base_ready, s_book, fresh_suffix)
          w10_if_emit_extended(stamp, s_book, s_fresh, s_ready, base_world, fresh_suffix),"""

    new_emit = """@unsafe
def w14t_log(+tag: String, +t0: Nat, +t1: Nat) -> IO(Unit):
  IO.print_err("[w14-stage] " ++ tag ++ "=" ++ Nat.show(Nat.sub(t1, t0)) ++ "ms\\n")

@unsafe
def w10_if_emit_freshened(+stamp: String, +base_book: List<&2, KDef>, +base_ready: FReadyPrefixState, +base_world: KBasePreparedWorld, fdefs: FFreshDefs) -> IO(U32):
  match fdefs:
    case FFreshDefs{+fresh_suffix, +next_id}:
      +s_book = List.append(&2, KDef, base_book, fresh_suffix)
      +s_fresh : FFreshPrefixState = FFreshPrefixState{next_id, True{}}
      nt_choose(IO(U32), w10_if_all_stub_defs(fresh_suffix),
        u => do IO<U32>:
          +t0 : Nat <- IO.now()
          +s_ready : FReadyPrefixState <- IO.pure(FReadyPrefixState, w10_if_ready_extend(base_ready, s_book, fresh_suffix))
          +t1 : Nat <- IO.now()
          _ : Unit <- w14t_log("4b_ready_extend", t0, t1)
          +rc : U32 <- w10_if_emit_extended(stamp, s_book, s_fresh, s_ready, base_world, fresh_suffix)
          +t2 : Nat <- IO.now()
          _ : Unit <- w14t_log("4c_world_encode_stream", t1, t2)
          IO.pure(U32, rc),"""
    assert old_emit in src, "old_emit not found"
    src = src.replace(old_emit, new_emit, 1)

    old_emit_seed = """@unsafe
def w10_if_emit_seed(+base_seed: P86Seed, +suffix: List<&2, KDef>, +abi: W10IfAbi) -> IO(U32):
  match base_seed:
    case P86Seed{base_src, +base_book, FFreshPrefixState{+base_next, _}, +base_ready, +base_world}:
      +stamp = w10_if_stamp_str(w10_if_h_defs(w10_if_h_init(), suffix, abi))
      +stripped = w10_if_strip_suffix(suffix, abi, missing())
      w10_if_emit_freshened(stamp, base_book, base_ready, base_world, f_fresh_defs(stripped, base_next))"""

    new_emit_seed = """@unsafe
def w10_if_emit_seed(+base_seed: P86Seed, +suffix: List<&2, KDef>, +abi: W10IfAbi) -> IO(U32):
  match base_seed:
    case P86Seed{base_src, +base_book, FFreshPrefixState{+base_next, _}, +base_ready, +base_world}:
      do IO<U32>:
        +t0 : Nat <- IO.now()
        +stamp : String <- IO.pure(String, w10_if_stamp_str(w10_if_h_defs(w10_if_h_init(), suffix, abi)))
        +stripped : List<&2, KDef> <- IO.pure(List<&2, KDef>, w10_if_strip_suffix(suffix, abi, missing()))
        +fdefs : FFreshDefs <- IO.pure(FFreshDefs, f_fresh_defs(stripped, base_next))
        +t1 : Nat <- IO.now()
        _ : Unit <- w14t_log("4a_stamp_strip_fresh", t0, t1)
        w10_if_emit_freshened(stamp, base_book, base_ready, base_world, fdefs)"""
    assert old_emit_seed in src, "old_emit_seed not found"
    src = src.replace(old_emit_seed, new_emit_seed, 1)

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
    m11_patched = patch_m11_stage_trace(m11_src)
    m11_path = TMP / "m11_stage.bend"
    m11_path.write_text(m11_patched, encoding="utf-8")

    m11_o = TMP / "m11_stage.o"
    m11_err = TMP / "m11_stage.err"
    print("Compiling instrumented m11_stage.o on CPU 1...", flush=True)
    cmp_ms, _ = run_native(
        N5_O2,
        ["x86-module-fast", str(m11_path), str(BASE_FILE), "cache", str(CACHE_IFACE / "m10.p130"), recs["m10"]["stamp"], "61935", "m11"],
        m11_o, m11_err, cpu=CPU,
    )
    print(f"  m11_stage.o built in {cmp_ms} ms ({m11_o.stat().st_size:,} B)", flush=True)

    # Link n6_stage
    n6_stage = TMP / "n6_stage"
    objs = [CACHE_OBJ / f"{m}.o" for m in MOD_NAMES[:-1]] + [m11_o]
    subprocess.run(
        ["timeout", "60", "taskset", "-c", str(CPU), CC, "-O2", "-no-pie",
         str(CACHE_OBJ / "merge_n6_w13.o"), *[str(o) for o in objs], str(RT), "-o", str(n6_stage), "-lm", "-lpthread"],
        check=True,
    )
    print(f"  Linked {n6_stage} ({n6_stage.stat().st_size:,} B)", flush=True)

    stage_results = {}
    for mod, prev in (("m06", "m05b"), ("m10", "m09")):
        out_p130 = TMP / f"stage_{mod}.p130"
        err_f = TMP / f"stage_{mod}.err"
        ms, err = run_native(
            n6_stage,
            ["x86-iface", str(TMP / f"src/{mod}_exp.bend"), str(BASE_FILE), "cache", str(CACHE_IFACE / f"{prev}.p130"), recs[prev]["stamp"]],
            out_p130, err_f, cpu=CPU,
        )
        out_p130.unlink()
        print(f"\n=== STAGE BREAKDOWN {mod} (n6_stage -O0, total={ms} ms) ===", flush=True)
        print(err, flush=True)
        stage_results[mod] = {"total_ms": ms, "stderr": err.splitlines()}

    # Cleanup large temp files
    n6_stage.unlink()
    m11_o.unlink()
    (OUT_DIR / "stage_breakdown.json").write_text(json.dumps(stage_results, indent=2))
    print("\nSaved stage_breakdown.json", flush=True)


if __name__ == "__main__":
    main()
