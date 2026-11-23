#!/usr/bin/env python3
"""W14-B Step 2b: Test FIX A (CPS-aware transitive pruning before p113pl_candidates) on m06 & m10 (CPU 1)."""
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

TMP = Path("/tmp/agy_w14b")
MOD_NAMES = [
    "m00a", "m00b", "m01", "m02", "m03", "m04",
    "m05a", "m05b", "m06", "m07", "m08", "m09", "m10", "m11",
]
CPU = 1

FIXA_BEND = r'''
# === AGY-W14B FIX A: CPS-Aware Transitive Pruning before p113pl_candidates ===

@unsafe
def w14a_collect_cps(+book: List<&2, KDef>, +suf_set: KDef, names: List<&2, String>, +sigs: KDef, +cps: KDef, +active: List<&2, String>) -> (KDef & KDef) & List<&2, String>:
  match names:
    case Nil{}: ((sigs, cps), nt_reverse(String, active, Nil{}))
    case Con{+name, +rest}:
      nt_choose((KDef & KDef) & List<&2, String>, w10_if_abi_has(suf_set, name),
        u => w14a_collect_cps(book, suf_set, rest, sigs, cps, Con{name, active}),
        u =>
          +sk = w10_if_stub_kind(book, name)
          nt_choose((KDef & KDef) & List<&2, String>, U32.is_ge(sk, 1000),
            v => w14a_collect_cps(book, suf_set, rest, p111v_put(sigs, p113d_public(book, name), "P113Direct", U32.sub(sk, 1000), 0), cps, active),
            v => nt_choose((KDef & KDef) & List<&2, String>, U32.is_eq(sk, 2),
              w => w14a_collect_cps(book, suf_set, rest, sigs, p111v_put(cps, name, "W7Rem", 1, 0), active),
              w => w14a_collect_cps(book, suf_set, rest, sigs, cps, Con{name, active}))))

@unsafe
def w14a_prune_active(+book: List<&2, KDef>, +active: List<&2, String>, +bangs: List<&2, String>, +cps: KDef) -> List<&2, String>:
  +remSet = w7_pre_build_set(book, active, bangs, cps)
  w7_pre_peel(w7_pre_nodes(book, active, remSet, []), missing(), [], 32)

@unsafe
def w14a_fast_abi_go(+seed: P86Seed, +suffix: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +workers: List<&2, P113DFunction>, res: (KDef & KDef) & List<&2, String>) -> IO(U32):
  (pair, +active0) = res
  (+seeded_sigs, +cps) = pair
  +pruned = w14a_prune_active(book, active0, bangs, cps)
  do IO<U32>:
    _ : Unit <- IO.print_err("[w14a] active0=" ++ U32.show(nt_count(String, active0)) ++ " pruned=" ++ U32.show(nt_count(String, pruned)) ++ "\n")
    +raw : List<&2, P113DCandidate> <- IO.pure(List<&2, P113DCandidate>, w13d_p113pl_candidates_fast(book, pruned, bangs))
    +fns0 : List<&2, P113DFunction> <- IO.pure(List<&2, P113DFunction>, p113d_passes(p126sc_candidates(raw), seeded_sigs, nt_reverse(P113DFunction, workers, Nil{}), 32))
    +abi : W10IfAbi = W10IfAbi{w10_if_add_direct(fns0, missing()), w10_if_add_public_names(book, names, missing())}
    w10_if_emit_seed(seed, suffix, abi)
'''


def patch_fixa(src: str) -> str:
    anchor = "@unsafe\ndef w10_if_fast_abi_run("
    assert anchor in src
    src = src.replace(anchor, FIXA_BEND + "\n" + anchor, 1)

    old_scan = """@unsafe
def w10_if_fast_abi_scan(+seed: P86Seed, +suffix: List<&2, KDef>, +suf_set: KDef, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, scan: P128BROpen) -> IO(U32):
  match scan:
    case P128BROpen{+workers, helpers, retry, +serr}:
      nt_choose(IO(U32), String.is_empty(serr),
        u =>
          +worker_sigs = p113e_signatures(workers, missing())
          +remaining = p167ob_remaining(book, names, bangs, worker_sigs)
          +filtered = w7_filter_remaining(book, remaining, bangs)
          w10_if_fast_abi_run(seed, suffix, book, names, bangs, workers, w10_if_split_upstream(book, suf_set, filtered, worker_sigs, Nil{})),
        u => IO.die(U32, 1, "x86-iface: early scalar scan: " ++ serr))"""

    new_scan = """@unsafe
def w10_if_fast_abi_scan(+seed: P86Seed, +suffix: List<&2, KDef>, +suf_set: KDef, +book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, scan: P128BROpen) -> IO(U32):
  match scan:
    case P128BROpen{+workers, helpers, retry, +serr}:
      nt_choose(IO(U32), String.is_empty(serr),
        u =>
          +worker_sigs = p113e_signatures(workers, missing())
          +remaining = p167ob_remaining(book, names, bangs, worker_sigs)
          w14a_fast_abi_go(seed, suffix, book, names, bangs, workers, w14a_collect_cps(book, suf_set, remaining, worker_sigs, missing(), Nil{})),
        u => IO.die(U32, 1, "x86-iface: early scalar scan: " ++ serr))"""
    assert old_scan in src
    src = src.replace(old_scan, new_scan, 1)
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
    p = TMP / "m11_fixa.bend"
    p.write_text(patch_fixa(m11_src), encoding="utf-8")
    o = TMP / "m11_fixa.o"
    run_native(N5_O2, ["x86-module-fast", str(p), str(BASE_FILE), "cache", str(CACHE_IFACE / "m10.p130"), recs["m10"]["stamp"], "61935", "m11"], o, TMP / "m11_fixa.err", CPU)

    bin_a = TMP / "n6_fixa"
    objs = [CACHE_OBJ / f"{m}.o" for m in MOD_NAMES[:-1]] + [o]
    subprocess.run(
        ["timeout", "60", "taskset", "-c", str(CPU), CC, "-O2", "-no-pie",
         str(CACHE_OBJ / "merge_n6_w13.o"), *[str(x) for x in objs], str(RT), "-o", str(bin_a), "-lm", "-lpthread"],
        check=True,
    )

    for mod, prev in (("m06", "m05b"), ("m10", "m09")):
        out = TMP / f"fixa_{mod}.p130"
        ms, err = run_native(
            bin_a,
            ["x86-iface", str(TMP / f"src/{mod}_exp.bend"), str(BASE_FILE), "cache", str(CACHE_IFACE / f"{prev}.p130"), recs[prev]["stamp"]],
            out, TMP / f"fixa_{mod}.err", CPU,
        )
        out.unlink()
        lines = err.splitlines()
        st = lines[-1]
        print(f"  [FIX A] {mod}: {ms} ms | stamp_exact={st == recs[mod]['stamp']} | {lines[0]}", flush=True)

    bin_a.unlink()
    o.unlink()


if __name__ == "__main__":
    main()
