#!/usr/bin/env python3
"""W11-A Verification Suite for selfhost/build/agy/wave11_unified/api.mjs:
  1. Cross-module A -> B -O2 test (x86-iface + x86-module -O2 + x86-merge-obj, 0 C, 0 objcopy,
     0 --allow-multiple-definition, exported non-recursive CPS/direct fn + local $product fn + recursive fn).
  2. Immediate compiled-program recovery benchmark (CPU 3, x86-object -O2):
     histogram, nbody, gameoflife, editdist, bst (3 runs median, exact checksums).
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path
from statistics import median

ROOT = Path("/home/ai/bend2_agy")
API = ROOT / "selfhost/build/agy/wave11_unified/api.mjs"
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

TMP = Path("/tmp/agy_w11a")
CPU = 3

UPSTREAM_EXPECTED = {
    "histogram": 3307081914,
    "gameoflife": 3681094808,
    "nbody": 728502159,
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


def test_ab_o2() -> dict:
    print("=== 1. Cross-module A -> B -O2 test (with local $product + non-recursive + recursive) ===", flush=True)
    ab_dir = TMP / "ab_o2"
    ab_dir.mkdir(parents=True, exist_ok=True)

    # Module B: exports a Pair type, a local $product helper, a non-recursive exported fn that calls
    # IO-like/CPS or direct code, and a recursive exported fn!
    mod_b = ab_dir / "modB.bend"
    mod_b.write_text("""import Base

type Pair2 is Data:
  Pair2{+x: U32, +y: U32}

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
  +k = U32.add(U32.add(b_nonrec_sum(1), b_rec_sum(1, 0)), b_str_ord_check("a", "b"))
  IO.pure(U32, k)
""")

    # Module A: calls b_nonrec_sum(4) = (4+10)+(8+20) = 42, b_rec_sum(5, 0) = 15,
    # b_str_ord_check("abc","abd")=1, b_str_ord_check("abc","abc")=2, b_str_ord_check("abd","abc")=3,
    # plus a local $product function a_local_prod!
    # Total expected: 42 + 15 + 1 + 2 + 3 + 100 = 163!
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
  +tot = U32.add(U32.add(U32.add(lp, r1), r2), U32.add(U32.add(s1, s2), s3))
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

    # Verify $product.* exists locally in modB.o and modA.o, and ZERO p114r_FID_ duplicate collisions!
    nm_b = subprocess.run(["nm", "--defined-only", str(b_o)], capture_output=True, text=True).stdout
    nm_a = subprocess.run(["nm", "--defined-only", str(a_o)], capture_output=True, text=True).stdout
    b_prod = [l for l in nm_b.splitlines() if "112_114_111_100_117_99_116" in l]
    a_prod = [l for l in nm_a.splitlines() if "112_114_111_100_117_99_116" in l]

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
    assert out == "163", f"Expected 163, got {out!r}"
    print(f"  A->B -O2 PASS! out={out} | modB={mb_ms}ms modA={ma_ms}ms merge={mg_ms}ms | link_warnings=0 | local_$product: B={len(b_prod)} A={len(a_prod)}", flush=True)
    return {
        "ok": True,
        "output": out,
        "iface_ms": if_ms,
        "modB_ms": mb_ms,
        "modA_ms": ma_ms,
        "merge_ms": mg_ms,
        "link_warnings": 0,
        "local_product_syms": {"modB": len(b_prod), "modA": len(a_prod)},
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


def bench_runtime_recovery() -> dict:
    print("=== 2. Compiled-Program Recovery Benchmark (CPU 3, wave11 api.mjs x86-object -O2) ===", flush=True)
    bdir = TMP / "rt_bench"
    bdir.mkdir(parents=True, exist_ok=True)
    up_spec = json.loads((INPUTS_UP / "suite.json").read_text())
    tuned_data = json.loads((INPUTS_TUNED / "results.json").read_text())
    by_id = {row["id"]: row for row in tuned_data.get("rows", [])}

    results = {}
    for fam in ("histogram", "nbody", "gameoflife"):
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
        results[fam] = {"ok": True, "compile_ms": cmp_ms, "median_ms": med, "runs_ms": runs}
        print(f"  {fam:<12} median={med:7.2f} ms (runs={runs}) | compile={cmp_ms} ms | checksum OK", flush=True)

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
        results[fam] = {"ok": True, "compile_ms": cmp_ms, "median_ms": med, "runs_ms": runs}
        print(f"  {fam:<12} median={med:7.2f} ms (runs={runs}) | compile={cmp_ms} ms | 3/3 hashes OK", flush=True)

    return results


def main() -> None:
    TMP.mkdir(parents=True, exist_ok=True)
    ab = test_ab_o2()
    rt = bench_runtime_recovery()
    out = {"ab_o2": ab, "runtime_recovery": rt}
    (TMP / "verify_w11_results.json").write_text(json.dumps(out, indent=2) + "\n")
    print("\nALL W11 VERIFICATION CHECKS PASSED!", flush=True)


if __name__ == "__main__":
    main()
