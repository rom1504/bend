#!/usr/bin/env python3
"""W12-INT Verification Suite for selfhost/build/agy/wave12_unified/api.mjs:
  1. Cross-module A -> B -O2 test INCLUDING both 0-arity CPS (`b_zero_cps`, reproducing
     W11-C's `w4g_live_base`/`x185_d_base` pattern) and 0-arity direct (`b_zero_direct`)
     exported defs + local `$product` + non-recursive + recursive + `String.order`.
  2. Combined Runtime Verification on CPU 4 (`x86-object -O2`, 3-run medians):
     terrain, hashmap, histogram, gameoflife, nbody, editdist, bst.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import time
from pathlib import Path
from statistics import median

ROOT = Path("/home/ai/bend2_agy")
API = ROOT / "selfhost/build/agy/wave12_unified/api.mjs"
CLI = ROOT / "research/agy/w10_mod_bend/compose_w10/run_w10_cli.mjs"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

PROXY_DIR = ROOT / "research/agy/wave4_bench"
INPUTS_UP = PROXY_DIR / "inputs/upstream"
INPUTS_TUNED = PROXY_DIR / "inputs/tuned"

TMP = Path("/tmp/agy_w12int")
CPU = 4

UPSTREAM_EXPECTED = {
    "histogram": 3307081914,
    "gameoflife": 3681094808,
    "nbody": 728502159,
}

BIG_EXPECTED = {
    "terrain": (ROOT / "bench/runtime/terrain/main.bend", 2572468224),
    "hashmap": (ROOT / "bench/runtime/hashmap/main.bend", 1307803744),
}

TUNED_POINTS = {
    "bst": {"id": "coverage-bst-64", "n": 64, "seed": 17, "expected": 861157620, "fixed_reps": 27184},
    "editdist": {"id": "editdist", "n": 2, "seed": 0, "expected": 2065873279, "fixed_reps": 240},
}

MASK32 = (1 << 32) - 1


def run_cli(args: list[str], out_file: Path | None, err_file: Path, timeout: int = 180) -> tuple[int, float, str]:
    env = dict(os.environ)
    env["AGY_NODE_MAX_MB"] = "4096"
    cmd = ["timeout", str(timeout), "taskset", "-c", str(CPU), "bash", str(LOCKED_NODE), str(CLI), str(API)] + args
    t0 = time.perf_counter()
    with err_file.open("wb") as ef:
        if out_file is not None:
            with out_file.open("wb") as of:
                r = subprocess.run(cmd, stdout=of, stderr=ef, cwd=ROOT, env=env)
        else:
            r = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=ef, cwd=ROOT, env=env)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    err = err_file.read_text(encoding="utf-8", errors="replace")
    return r.returncode, ms, err


def test_ab_o2_with_zero_arity() -> dict:
    print("=== 1. Cross-module A -> B -O2 test (with 0-arity CPS & direct exported defs) ===", flush=True)
    ab_dir = TMP / "ab_o2"
    ab_dir.mkdir(parents=True, exist_ok=True)

    mod_b = ab_dir / "modB.bend"
    mod_b.write_text("""import Base

type Pair2 is Data:
  Pair2{+x: U32, +y: U32}

# 0-arity CPS exported def (reproduces W11-C w4g_live_base / x185_d_base pattern!)
@unsafe
def b_zero_cps() -> U32:
  _f : U32 -> U32 = x => x
  b_rec_sum(5, 2)

# 0-arity direct exported def
def b_zero_direct() -> U32:
  23

def b_local_prod(p: Pair2) -> Pair2:
  match p:
    case Pair2{a, b}: Pair2{U32.add(a, 10), U32.add(b, 20)}

def b_pair_sum(p: Pair2) -> U32:
  match p:
    case Pair2{u, v}: U32.add(u, v)

def b_nonrec_sum(+n: U32) -> U32:
  b_pair_sum(b_local_prod(Pair2{n, U32.mul(n, 2)}))

@unsafe
def b_rec_sum(+n: U32, +acc: U32) -> U32:
  match n:
    case 0: acc
    case k: b_rec_sum(U32.sub(k, 1), U32.add(acc, k))

def b_cmp_to_u32(c: Cmp) -> U32:
  match c:
    case LT{}: 1
    case EQ{}: 2
    case GT{}: 3

def b_str_ord_check(+a: String, +b: String) -> U32:
  b_cmp_to_u32(String.order(a, b))

def main() -> IO(U32):
  +k = U32.add(U32.add(b_zero_cps(), b_zero_direct()), U32.add(U32.add(b_nonrec_sum(1), b_rec_sum(1, 0)), b_str_ord_check("a", "b")))
  IO.pure(U32, k)
""")

    # Expected: lp(100) + r1(42) + r2(15) + s1(1) + s2(2) + s3(3) + z1(17) + z2(23) = 203
    mod_a = ab_dir / "modA.bend"
    mod_a.write_text("""import Base

def a_local_prod(p: Pair2) -> Pair2:
  match p:
    case Pair2{u, v}: Pair2{U32.add(u, 40), U32.add(v, 60)}

def a_pair_sum(p: Pair2) -> U32:
  match p:
    case Pair2{u, v}: U32.add(u, v)

def main() -> IO(U32):
  +lp = a_pair_sum(a_local_prod(Pair2{0, 0}))
  +r1 = b_nonrec_sum(4)
  +r2 = b_rec_sum(5, 0)
  +s1 = b_str_ord_check("abc", "abd")
  +s2 = b_str_ord_check("abc", "abc")
  +s3 = b_str_ord_check("abd", "abc")
  +z1 = b_zero_cps()
  +z2 = b_zero_direct()
  +tot = U32.add(U32.add(U32.add(lp, r1), U32.add(r2, z1)), U32.add(U32.add(s1, s2), U32.add(s3, z2)))
  do IO<U32>:
    _ : Unit <- IO.print(U32.show(tot) ++ "\\n")
    IO.pure(U32, 0)
""")

    b_p130 = ab_dir / "modB.p130"
    rc, if_ms, err = run_cli(
        ["x86-iface", str(mod_b), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
        b_p130, ab_dir / "iface_b.err", timeout=180
    )
    assert rc == 0, f"x86-iface modB failed rc={rc}: {err}"
    stamp_b = err.strip().splitlines()[-1].strip()
    print(f"  x86-iface modB: {if_ms} ms | stamp={stamp_b}", flush=True)

    b_o = ab_dir / "modB.o"
    rc, mb_ms, err = run_cli(
        ["--trace", "x86-module", str(mod_b), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP, "0", "modB"],
        b_o, ab_dir / "modB.err", timeout=180
    )
    assert rc == 0, f"x86-module modB failed rc={rc}: {err}"

    a_o = ab_dir / "modA.o"
    rc, ma_ms, err = run_cli(
        ["--trace", "x86-module", str(mod_a), str(BASE_FILE), "cache", str(b_p130), stamp_b, "2000", "modA"],
        a_o, ab_dir / "modA.err", timeout=180
    )
    assert rc == 0, f"x86-module modA failed rc={rc}: {err}"

    merge_o = ab_dir / "merge.o"
    rc, mg_ms, err = run_cli(
        ["x86-merge-obj", "modA", "modB", "modA"],
        merge_o, ab_dir / "merge.err", timeout=60
    )
    assert rc == 0, f"x86-merge-obj failed rc={rc}: {err}"

    # Verify ZERO orphan weak p113d_FID_ for b_zero_cps (98_95_122_101_114_111_95_99_112_115) in modA.o!
    nm_b = subprocess.run(["nm", "--defined-only", str(b_o)], capture_output=True, text=True).stdout
    nm_a = subprocess.run(["nm", "--defined-only", str(a_o)], capture_output=True, text=True).stdout
    zcps_enc = "98_95_122_101_114_111_95_99_112_115"
    b_zcps_p113d = [l for l in nm_b.splitlines() if zcps_enc in l and "p113d_FID_" in l]
    a_zcps_p113d = [l for l in nm_a.splitlines() if zcps_enc in l and "p113d_FID_" in l]
    assert len(b_zcps_p113d) == 0, f"Expected modB b_zero_cps to be CPS-only, got {b_zcps_p113d}"
    assert len(a_zcps_p113d) == 0, f"W11-C regression! Orphan p113d_FID_ stub for b_zero_cps in modA.o: {a_zcps_p113d}"

    exe = ab_dir / "ab_o2_bin"
    link = subprocess.run(
        [CC, "-O2", "-no-pie", str(b_o), str(a_o), str(merge_o), str(AGY_RT), "-lm", "-pthread", "-o", str(exe)],
        capture_output=True, text=True, timeout=60
    )
    assert link.returncode == 0, f"gcc link failed: {link.stderr}"
    assert link.stderr.strip() == "", f"unexpected link warnings: {link.stderr}"

    run = subprocess.run(
        ["timeout", "15", "taskset", "-c", str(CPU), str(exe)] + RTS_ARGS,
        capture_output=True, text=True
    )
    assert run.returncode == 0, f"ab_o2_bin failed rc={run.returncode} stderr={run.stderr}"
    out = run.stdout.strip()
    assert out == "203", f"Expected 203, got {out!r}"
    print(f"  A->B -O2 PASS! out={out} | modB={mb_ms}ms modA={ma_ms}ms merge={mg_ms}ms | orphan_0arity_p113d=0 | link_warnings=0", flush=True)
    return {
        "ok": True,
        "output": out,
        "iface_ms": if_ms,
        "modB_ms": mb_ms,
        "modA_ms": ma_ms,
        "merge_ms": mg_ms,
        "orphan_0arity_p113d": 0,
        "link_warnings": 0,
    }


def replace_once(text: str, pattern: str, repl: str) -> str:
    out, n = re.subn(pattern, repl, text, flags=re.M)
    assert n == 1, f"expected 1 match for {pattern!r}, found {n}"
    return out


def prepare_upstream_bend(family: str, up_spec: dict) -> str:
    desc = up_spec[family]
    text = (INPUTS_UP / family / "main.bend").read_text()
    for bname, old, new in zip(desc["bendKnobs"], desc["upstream"], desc["medium"]):
        text = replace_once(text, rf"(^def {bname}\(\) -> Nat:\n  ){old}n$", rf"\g<1>{new}n")
    return text


def prepare_tuned_bend(family: str) -> str:
    kernel = (INPUTS_TUNED / "kernels" / f"{family}.bend").read_text()
    driver = (INPUTS_TUNED / "driver.bend").read_text()
    return kernel.rstrip() + "\n\n" + driver


def batch_hash(values: list[int], count: int) -> int:
    mult = 16777619
    block = 0
    for v in values:
        block = (mult * block + v) & MASK32
    factor = pow(mult, 32, 1 << 32)
    repeats, tail = divmod(count, 32)
    h = 0
    while repeats:
        if repeats & 1:
            h = (factor * h + block) & MASK32
        block = (factor * block + block) & MASK32
        factor = (factor * factor) & MASK32
        repeats >>= 1
    for v in values[:tail]:
        h = (mult * h + v) & MASK32
    return h


def bench_runtime_suite() -> dict:
    print("=== 2. Combined Runtime Verification (CPU 4, wave12 api.mjs x86-object -O2) ===", flush=True)
    bdir = TMP / "rt_bench"
    bdir.mkdir(parents=True, exist_ok=True)
    up_spec = json.loads((INPUTS_UP / "suite.json").read_text())
    tuned_data = json.loads((INPUTS_TUNED / "results.json").read_text())
    by_id = {row["id"]: row for row in tuned_data.get("rows", [])}

    results = {}

    # Big upstream holdouts: terrain, hashmap
    for fam, (src_path, expected) in BIG_EXPECTED.items():
        obj = bdir / f"{fam}.o"
        rc, cmp_ms, err = run_cli(
            ["x86-object", str(src_path), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
            obj, bdir / f"{fam}.err", timeout=180
        )
        assert rc == 0, f"compile {fam} failed: {err[:400]}"
        exe = bdir / fam
        link = subprocess.run([CC, "-O2", "-no-pie", str(obj), str(AGY_RT), "-lm", "-pthread", "-o", str(exe)], capture_output=True, text=True)
        assert link.returncode == 0, f"link {fam} failed: {link.stderr}"
        runs = []
        for _ in range(3):
            t0 = time.perf_counter()
            r = subprocess.run(["timeout", "60", "taskset", "-c", str(CPU), str(exe)] + RTS_ARGS, capture_output=True, text=True)
            dt = (time.perf_counter() - t0) * 1000.0
            assert r.returncode == 0, f"run {fam} failed: {r.stderr}"
            got = int(r.stdout.strip().splitlines()[-1].strip())
            assert got == expected, f"{fam} checksum mismatch: {got} != {expected}"
            runs.append(round(dt, 2))
        med = round(median(runs), 2)
        results[fam] = {"ok": True, "obj_bytes": obj.stat().st_size, "compile_ms": cmp_ms, "median_ms": med, "runs_ms": runs}
        print(f"  {fam:<12} median={med:9.2f} ms (runs={runs}) | obj={obj.stat().st_size:,} B | compile={cmp_ms} ms | checksum OK", flush=True)

    # Medium upstream families: histogram, gameoflife, nbody
    for fam in ("histogram", "gameoflife", "nbody"):
        src = bdir / f"{fam}.bend"
        src.write_text(prepare_upstream_bend(fam, up_spec))
        obj = bdir / f"{fam}.o"
        rc, cmp_ms, err = run_cli(
            ["x86-object", str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
            obj, bdir / f"{fam}.err", timeout=180
        )
        assert rc == 0, f"compile {fam} failed: {err[:400]}"
        exe = bdir / fam
        link = subprocess.run([CC, "-O2", "-no-pie", str(obj), str(AGY_RT), "-lm", "-pthread", "-o", str(exe)], capture_output=True, text=True)
        assert link.returncode == 0, f"link {fam} failed: {link.stderr}"
        runs = []
        for _ in range(3):
            t0 = time.perf_counter()
            r = subprocess.run(["timeout", "60", "taskset", "-c", str(CPU), str(exe)] + RTS_ARGS, capture_output=True, text=True)
            dt = (time.perf_counter() - t0) * 1000.0
            assert r.returncode == 0, f"run {fam} failed: {r.stderr}"
            got = int(r.stdout.strip().splitlines()[-1].strip())
            assert got == UPSTREAM_EXPECTED[fam], f"{fam} checksum mismatch: {got} != {UPSTREAM_EXPECTED[fam]}"
            runs.append(round(dt, 2))
        med = round(median(runs), 2)
        results[fam] = {"ok": True, "obj_bytes": obj.stat().st_size, "compile_ms": cmp_ms, "median_ms": med, "runs_ms": runs}
        print(f"  {fam:<12} median={med:9.2f} ms (runs={runs}) | obj={obj.stat().st_size:,} B | compile={cmp_ms} ms | checksum OK", flush=True)

    # Tuned families: editdist, bst
    for fam in ("editdist", "bst"):
        spec = TUNED_POINTS[fam]
        bank = by_id[spec["id"]]["seed_bank"]
        src = bdir / f"{fam}.bend"
        src.write_text(prepare_tuned_bend(fam))
        obj = bdir / f"{fam}.o"
        rc, cmp_ms, err = run_cli(
            ["x86-object", str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
            obj, bdir / f"{fam}.err", timeout=180
        )
        assert rc == 0, f"compile {fam} failed: {err[:400]}"
        exe = bdir / fam
        link = subprocess.run([CC, "-O2", "-no-pie", str(obj), str(AGY_RT), "-lm", "-pthread", "-o", str(exe)], capture_output=True, text=True)
        assert link.returncode == 0, f"link {fam} failed: {link.stderr}"
        reps = spec["fixed_reps"]
        warm = 32
        want = [str(bank[0]), str(batch_hash(bank, warm)), str(batch_hash(bank, reps))]
        runs = []
        for _ in range(3):
            r = subprocess.run(
                ["timeout", "60", "taskset", "-c", str(CPU), str(exe)] + RTS_ARGS + [str(reps), str(warm), str(spec["n"]), str(spec["seed"])],
                capture_output=True, text=True
            )
            assert r.returncode == 0, f"run {fam} failed: {r.stderr}"
            lines = r.stdout.splitlines()
            assert len(lines) == 4 and lines[:3] == want, f"{fam} mismatch: got {lines!r} want {want!r}"
            runs.append(round(int(lines[3]) / 1e6, 2))
        med = round(median(runs), 2)
        results[fam] = {"ok": True, "obj_bytes": obj.stat().st_size, "compile_ms": cmp_ms, "median_ms": med, "runs_ms": runs}
        print(f"  {fam:<12} median={med:9.2f} ms (runs={runs}) | obj={obj.stat().st_size:,} B | compile={cmp_ms} ms | 3/3 hashes OK", flush=True)

    return results


def main() -> None:
    TMP.mkdir(parents=True, exist_ok=True)
    ab = test_ab_o2_with_zero_arity()
    rt = bench_runtime_suite()
    out = {"ab_o2": ab, "runtime_bench": rt}
    (TMP / "verify_w12_results.json").write_text(json.dumps(out, indent=2) + "\n")
    print("\nALL W12 VERIFICATION CHECKS PASSED!", flush=True)


if __name__ == "__main__":
    main()
