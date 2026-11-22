#!/usr/bin/env python3
"""Wave 4 Phase 2 Track W4-8 — Expanded Grammar-Based Differential Fuzzer.

Generates 90 deterministic, well-typed random Bend programs (30 per family across
3 new Wave 4 families) and asserts bit-exact stdout equality between:
  1. Upstream Bend (`bun /home/ai/bend2_agy/bend2/main.ts`)
  2. Wave 4A Unified (`wave4a_unified/api.mjs` + `unified/runtime-agy.o`)
  3. On ANY mismatch, also isolates against `wave2_unified/api.mjs` + `unified/runtime-agy.o`.

Families:
  - Family 8 (`8_array_fork_licm`): Array fork/join/get/set/swap/size/OOB/clone (W4-2 TAG_BUF 0x04 & 0x84 + p117v LICM)
  - Family 9 (`9_f32_multicarried_cf`): F32 constant folding + 8..18 carried XMM loop state + -0.0/NaN/non-contraction (W4-1 + W4-3)
  - Family 10 (`10_scalar_x86_lcg`): U32.mod/div (3,5,9,...), pow2 mul/shifts, bitops, Bool.to_u32/Bool.pick, leaf functions, odd-parity LCG & stalling loops (W4-1 + W4-4)
"""
from __future__ import annotations
import argparse
import hashlib
import json
import random
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BATCH_EMIT = ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"

W4A_API = ROOT / "selfhost/build/agy/wave4a_unified/api.mjs"
W2_API = ROOT / "selfhost/build/agy/wave2_unified/api.mjs"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
WORK_DIR = ROOT / "selfhost/build/agy/wave4_fuzz/run_tmp"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

DYN_ZERO = """
def dyn_zero_go(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: dyn_zero_go(p, U32.and(acc, 0))

def dyn_zero() -> U32:
  dyn_zero_go(U32.to_nat(300000), 0)
"""

COMMON_HELPERS = """
def f32_canon_go(x: F32, is_nan: Bool) -> U32:
  match is_nan:
    case True{}: 2143289344
    case False{}: F32.bits(x)

def f32_cbits(+x: F32) -> U32:
  f32_canon_go(x, F32.is_ne(x, x))
"""

U32_EDGES = [
    0, 1, 2, 3, 4, 5, 7, 8, 9, 15, 16, 31, 32, 33, 63, 64, 127, 255,
    65535, 65536, 2147483647, 2147483648, 4294967294, 4294967295,
]


# =============================================================================
# Family 8: Array fork / join / get / set / swap / size / OOB / clone (W4-2)
# =============================================================================
def gen_family8_array_fork_licm(rng: random.Random, idx: int) -> str:
    cls = rng.choice([1, 2, 3, 4, 5, 6, 7])
    size = 1 << cls
    init_val = rng.choice([0, 1, 3, 17, 42, 4294967295, rng.randint(0, 100000)])
    stride1 = rng.choice([1, 3, 5, 7, 13, 19])
    stride2 = rng.choice([1, 2, 7, 11, 17])
    fill_n = rng.randint(1, min(size * 2, 96))
    sum_n = rng.randint(1, min(size + 8, 80))
    start_i1 = rng.choice([0, 1, size - 1, size, size + 3, 4294967290, 4294967295])
    start_i2 = rng.choice([0, 2, size // 2, size + 5, 4294967293])
    swap_idx = rng.choice([0, 1, size - 1, size, size + 7, 4294967295])
    swap_val = rng.choice([0, 777, 123456, 4294967295])
    do_nested = (idx % 3 == 0)
    do_clone = (idx % 3 == 1)
    do_oob_heavy = (idx % 3 == 2)
    mask_k = rng.randint(1, cls)
    mask_val = (1 << mask_k) - 1

    if do_nested:
        fork_body = f"""
def after_read_y(x3: Array<U32>, +z: U32, r: Array<U32> & U32) -> U32:
  (y1, h1) = r
  a3 = Array.join(U32, x3, y1)
  after_swap(h1, z, Array.swap(U32, a3, U32.add(z, {swap_idx}), {swap_val}))

def after_inner(y: Array<U32>, +z: U32, p: Array<U32> & Array<U32>) -> U32:
  (x1, x2) = p
  x1b = fill_loop({fill_n}n, U32.add(z, {start_i1}), U32.add(z, {init_val}), x1)
  x2b = x2[U32.add(z, {swap_idx})] <- U32.xor({swap_val}, z)
  x3 = Array.join(U32, x1b, x2b)
  after_read_y(x3, z, sum_loop({sum_n}n, U32.add(z, {start_i2}), 17, y[U32.add(z, {start_i2})]))

def after_outer(+z: U32, p: Array<U32> & Array<U32>) -> U32:
  (x, y) = p
  after_inner(y, z, Array.fork(U32, x))
"""
    elif do_clone:
        fork_body = f"""
def read_clone(r: Array<U32> & U32) -> U32:
  (c, v) = r
  v

def after_clone(a2: Array<U32>, +z: U32, p: Array<U32> & Array<U32>) -> U32:
  (a1b, c0) = p
  c1 = fill_loop({min(fill_n, 24)}n, U32.add(z, {start_i2}), 999, c0)
  a2b = bump_loop({min(fill_n, 32)}n, U32.add(z, {start_i1}), a2[U32.add(z, {start_i1})])
  a3 = Array.join(U32, a1b, a2b)
  h_c = read_clone(sum_loop({min(sum_n, 24)}n, U32.add(z, {start_i2}), 31, c1[U32.add(z, {start_i2})]))
  after_swap(h_c, z, Array.swap(U32, a3, U32.add(z, {swap_idx}), {swap_val}))

def after_outer(+z: U32, p: Array<U32> & Array<U32>) -> U32:
  (a1, a2) = p
  a1w = a1[U32.add(z, {start_i1})] <- U32.add(z, {swap_val})
  after_clone(a2, z, Array.clone(U32, a1w))
"""
    else:
        fork_body = f"""
def after_outer(+z: U32, p: Array<U32> & Array<U32>) -> U32:
  (a1, a2) = p
  a1b = fill_loop({fill_n}n, U32.add(z, {start_i1}), U32.add(z, {init_val}), a1)
  a2b = bump_loop({fill_n}n, U32.add(z, {start_i2}), a2[U32.add(z, {start_i2})])
  a3 = Array.join(U32, a1b, a2b)
  after_swap(U32.add(z, 5), z, Array.swap(U32, a3, U32.add(z, {swap_idx}), {swap_val}))
"""

    oob_extra = (
        f"a[U32.add(i, {stride1})] <- U32.xor(v, U32.add(i, {stride2}))"
        if do_oob_heavy
        else f"a[U32.and(i, {mask_val})] <- U32.add(v, {stride2})"
    )

    return f"""import Base
{DYN_ZERO}
def fill_loop(n: Nat, +i: U32, +v: U32, a: Array<U32>) -> Array<U32>:
  match n:
    case 0n: a
    case 1n+p: fill_loop(p, U32.add(i, {stride1}), U32.add(v, {stride2}), {oob_extra})

def bump_loop(n: Nat, +i: U32, r: Array<U32> & U32) -> Array<U32>:
  match n r:
    case 0n Tuple{{a, old}}: a[i] <- U32.xor(U32.mul(old, 3), i)
    case 1n+p Tuple{{a, old}}:
      a1 = a[i] <- U32.xor(U32.mul(old, 3), i)
      bump_loop(p, U32.add(i, {stride2}), a1[U32.add(i, {stride2})])

def sum_loop(n: Nat, +i: U32, +acc: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  match n r:
    case 0n Tuple{{a, v}}: (a, U32.xor(U32.mul(acc, 16777619), v))
    case 1n+p Tuple{{a, v}}: sum_loop(p, U32.add(i, {stride1}), U32.xor(U32.mul(acc, 16777619), v), a[U32.add(i, {stride1})])

def finish_sum(+h: U32, +sz: U32, r: Array<U32> & U32) -> U32:
  (a, s) = r
  U32.xor(s, U32.add(U32.mul(h, 31), sz))

def after_size(+h: U32, +z: U32, r: Array<U32> & U32) -> U32:
  (a, sz) = r
  finish_sum(h, sz, sum_loop({sum_n}n, U32.add(z, 0), h, a[U32.add(z, 0)]))

def after_swap(+h: U32, +z: U32, r: Array<U32> & U32) -> U32:
  (a, old) = r
  after_size(U32.xor(h, old), z, Array.size(U32, a))
{fork_body}
def main() -> IO(Unit):
  +z = dyn_zero()
  a0 = fill_loop({min(size, 16)}n, z, U32.add(z, {init_val}), Array.new(U32, {cls}n, U32.add(z, {init_val})))
  IO.print(U32.show(after_outer(z, Array.fork(U32, a0))))
"""


# =============================================================================
# Family 9: F32 Constant Folding + Multi-Carried (8..18) XMM Loop State (W4-1 + W4-3)
# =============================================================================
def gen_family9_f32_multicarried(rng: random.Random, idx: int) -> str:
    n_car = rng.randint(8, 18)
    n_inv = rng.randint(1, 3)
    iters = rng.randint(6, 28)

    car_names = [f"c{i}" for i in range(n_car)]
    inv_names = [f"k{i}" for i in range(n_inv)]
    params_sig = ", ".join([f"+{v}: F32" for v in car_names + inv_names])

    # Small inlineable helper like nbody's fl(u) to exercise W4-1 F32 constant folding
    f32_ops = ["F32.add", "F32.sub", "F32.mul", "F32.div"]
    const_u = [rng.randint(1, 500) for _ in range(6)]
    cf_exprs = [
        f"F32.div(fl({const_u[0]}), fl({const_u[1]}))",
        f"F32.add(F32.mul(fl({const_u[2]}), 0.125), F32.sub(fl({const_u[3]}), 1.5))",
        f"F32.mul(F32.sub(0.0, 1.0), 0.0)",  # -0.0
        f"F32.add(F32.mul(F32.sub(0.0, 1.0), 0.0), F32.mul(F32.sub(0.0, 1.0), 0.0))",  # -0.0 + -0.0 = -0.0
        f"F32.div(0.0, 0.0)",  # NaN
        f"F32.add(F32.mul(1.0000001, 1.0000001), F32.sub(0.0, 1.0000002))",  # non-contraction check!
    ]
    cf_chosen = rng.choice(cf_exprs)

    body_lines = []
    next_cars = []
    for i in range(n_car):
        a = car_names[i]
        b = car_names[(i + 1) % n_car]
        inv = inv_names[i % n_inv]
        kind = rng.randint(0, 4)
        if kind == 0:
            # Non-contraction sensitive: a * inv + b
            expr = f"F32.add(F32.mul({a}, {inv}), {b})"
        elif kind == 1:
            expr = f"F32.sub({a}, F32.mul({b}, fl({rng.randint(1, 7)})))"
        elif kind == 2:
            expr = f"F32.div(F32.add({a}, {inv}), F32.add(F32.mul({b}, {b}), 2.5))"
        elif kind == 3:
            expr = f"F32.sqrt(F32.add(F32.mul({a}, {a}), F32.add(F32.mul({b}, {b}), 0.25)))"
        else:
            expr = f"mix_f({a}, {b}, {inv})"
        nv = f"n{i}"
        body_lines.append(f"      +{nv} = {expr}")
        next_cars.append(nv)

    # Fold all carried floats into a hash on exit
    hash_expr = "h"
    for v in car_names:
        hash_expr = f"U32.xor(U32.mul({hash_expr}, 31), f32_cbits({v}))"

    init_pool = [
        "0.0", "1.0", "0.5", "1.25", "2.75", "0.125",
        "F32.sub(0.0, 0.5)", "F32.sub(0.0, 1.25)",
        "F32.mul(F32.sub(0.0, 1.0), 0.0)",  # -0.0
        "F32.div(fl(3), fl(7))",
        "F32.div(fl(11), fl(13))",
    ]
    init_cars = [rng.choice(init_pool) for _ in range(n_car)]
    init_invs = [rng.choice(["0.25", "0.5", "0.75", "F32.sub(0.0, 0.125)", "F32.div(fl(5), fl(16))"]) for _ in range(n_inv)]
    init_all = ", ".join(init_cars + init_invs)
    rec_args = ", ".join(next_cars + inv_names)

    return f"""import Base
{DYN_ZERO}
{COMMON_HELPERS}
def fl(u: U32) -> F32:
  U32.to_f32(u)

def mix_f(+a: F32, +b: F32, +k: F32) -> F32:
  F32.sub(F32.mul(a, k), F32.div(b, F32.add(F32.mul(k, k), 1.5)))

def floop(n: Nat, {params_sig}, +h: U32) -> U32:
  match n:
    case 0n: {hash_expr}
    case 1n+p:
{chr(10).join(body_lines)}
      +h2 = U32.xor(U32.mul(h, 131), f32_cbits(n0))
      floop(p, {rec_args}, h2)

def main() -> IO(Unit):
  +z = dyn_zero()
  +cf = {cf_chosen}
  +r1 = floop(U32.to_nat(U32.add(z, {iters})), {init_all}, U32.add(z, 19))
  +r2 = f32_cbits(cf)
  +r3 = f32_cbits(F32.add(F32.mul(F32.add(1.0000001, U32.to_f32(z)), 1.0000001), F32.sub(0.0, 1.0000002)))
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3))
"""


# =============================================================================
# Family 10: U32.mod/div, pow2 mul/shifts, Bool.to_u32/pick, leaf shrink-wrap, LCG (W4-1 + W4-4)
# =============================================================================
def gen_family10_scalar_x86_lcg(rng: random.Random, idx: int) -> str:
    # Odd-parity LCG (no fixed point) vs even/stalling loop
    is_odd_lcg = (idx % 3 != 2)
    if is_odd_lcg:
        a = rng.choice([1, 3, 5, 9, 13, 1103515245, 1664525, 2147483647, 4294967295])
        b = rng.choice([1, 3, 5, 7, 12345, 1013904223, 4294967295])
        lcg_op = rng.choice(["U32.add", "U32.sub", "U32.xor"])
    else:
        # Even / potentially stalling recurrence
        a = rng.choice([0, 2, 4, 6, 16])
        b = rng.choice([0, 2, 4, 8])
        lcg_op = rng.choice(["U32.add", "U32.and", "U32.mul"])

    mod_d1 = rng.choice([3, 5, 9, 7, 10, 13, 16, 0])
    mod_d2 = rng.choice([3, 5, 9, 11, 17, 32])
    pow2_k1 = rng.choice([0, 1, 2, 3, 4, 5, 8, 16, 31])
    pow2_m1 = 1 << pow2_k1
    pow2_k2 = rng.choice([1, 2, 3, 6, 10, 20])
    pow2_m2 = 1 << pow2_k2
    sh_n = rng.choice([0, 1, 2, 7, 15, 31, 32, 33])
    cmp1 = rng.choice(["U32.is_eq", "U32.is_ne", "U32.is_lt", "U32.is_le", "U32.is_gt", "U32.is_ge"])
    cmp2 = rng.choice(["U32.is_eq", "U32.is_ne", "U32.is_lt", "U32.is_le", "U32.is_gt", "U32.is_ge"])
    iters = rng.randint(10, 60)
    seed0 = rng.choice(U32_EDGES)
    seed1 = rng.randint(0, 4294967295)

    return f"""import Base
{DYN_ZERO}
def leaf_arith(+x: U32, +y: U32, +w: U32) -> U32:
  +m1 = U32.mod(x, {mod_d1})
  +d1 = U32.div(y, {mod_d2})
  +m2 = U32.mod(U32.add(x, y), {mod_d2})
  +p1 = U32.mul(m1, {pow2_m1})
  +p2 = U32.mul(d1, {pow2_m2})
  +sh = U32.xor(U32.shln(w, {sh_n}n), U32.shrn(x, {sh_n}n))
  +b1 = Bool.to_u32({cmp1}(x, y))
  +b2 = Bool.pick(U32, {cmp2}(y, w), 1, 0)
  +b3 = Bool.pick(U32, Bool.not({cmp1}(m2, w)), 0, 1)
  +bm = U32.mul(U32.xor(p1, p2), b1)
  +bm2 = U32.mul(sh, b2)
  U32.xor(U32.add(bm, bm2), U32.add(m2, b3))

def leaf_empty_go(is_z: Bool, +n: U32, +x: U32) -> U32:
  match is_z:
    case True{{}}: U32.mul(x, {pow2_m1})
    case False{{}}: U32.add(U32.mod(x, {mod_d2}), U32.mul(n, Bool.to_u32(U32.is_lt(n, x))))

def leaf_empty(+n: U32, +x: U32) -> U32:
  leaf_empty_go(U32.is_eq(n, 0), n, x)

def lcg_loop(n: Nat, +s: U32, +acc: U32) -> U32:
  match n:
    case 0n: U32.xor(s, acc)
    case 1n+p:
      +ns = {lcg_op}(U32.mul(s, {a}), {b})
      +m3 = U32.mod(ns, 3)
      +m5 = U32.mod(ns, 5)
      +m9 = U32.mod(ns, 9)
      +cond = U32.is_lt(m3, m5)
      +inc = U32.mul(U32.add(m9, 1), Bool.to_u32(cond))
      +nacc = U32.xor(U32.add(acc, inc), U32.mul(m5, {pow2_m1}))
      lcg_loop(p, ns, nacc)

def main() -> IO(Unit):
  +z = dyn_zero()
  +x0 = U32.add(z, {seed0})
  +x1 = U32.add(z, {seed1})
  +r1 = leaf_arith(x0, x1, U32.xor(x0, x1))
  +r2 = U32.xor(leaf_empty(z, x1), leaf_empty(U32.add(z, 7), x0))
  +r3 = lcg_loop(U32.to_nat(U32.add(z, {iters})), x0, x1)
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3))
"""


FAMILIES = [
    ("8_array_fork_licm", gen_family8_array_fork_licm),
    ("9_f32_multicarried_cf", gen_family9_f32_multicarried),
    ("10_scalar_x86_lcg", gen_family10_scalar_x86_lcg),
]


def run_upstream(src: Path) -> tuple[bool, str]:
    try:
        r = subprocess.run(
            ["bash", str(LOCKED_BUN), str(src)],
            capture_output=True, text=True, timeout=65,
        )
        if r.returncode != 0:
            return False, f"UP_ERR({r.returncode}): {r.stderr.strip()[:240]}"
        return True, r.stdout
    except subprocess.TimeoutExpired:
        return False, "UP_TIMEOUT"


def batch_emit(api: Path, jobs: list, manifest: Path) -> dict:
    manifest.write_text(json.dumps(jobs))
    r = subprocess.run(
        ["bash", str(LOCKED_NODE), "--stack-size=8192", str(BATCH_EMIT), str(api), str(manifest)],
        capture_output=True, text=True, timeout=600,
    )
    if r.returncode != 0:
        raise RuntimeError(f"batch_emit failed rc={r.returncode}: {r.stderr[:400]}")
    return {item["id"]: item for item in json.loads(r.stdout)}


def link_run_cleanup(obj: Path, rt: Path, exe: Path) -> tuple[bool, str]:
    try:
        r_cc = subprocess.run(
            [CC, "-no-pie", str(obj), str(rt), "-pthread", "-lm", "-o", str(exe)],
            capture_output=True, text=True, timeout=30,
        )
        if r_cc.returncode != 0:
            return False, f"LINK_ERR: {r_cc.stderr.strip()[:240]}"
        try:
            r_run = subprocess.run(
                [str(exe), *RTS_ARGS],
                capture_output=True, text=True, timeout=30,
            )
            if r_run.returncode != 0:
                return False, f"RUN_ERR({r_run.returncode}): stderr={r_run.stderr.strip()[:200]} stdout={r_run.stdout.strip()[:120]}"
            if r_run.stderr:
                return False, f"RUN_STDERR: {r_run.stderr.strip()[:200]}"
            return True, r_run.stdout
        except subprocess.TimeoutExpired:
            return False, "RUN_TIMEOUT"
    finally:
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=2026112204)
    ap.add_argument("--per-family", type=int, default=30)
    ap.add_argument("--workers", type=int, default=8)
    ap.add_argument("--out-json", type=Path, default=ROOT / "experiments/agy/receipts/wave4-fuzz-report.json")
    ap.add_argument("--only-family", type=str, default=None)
    args = ap.parse_args()

    t0 = time.perf_counter()
    WORK_DIR.mkdir(parents=True, exist_ok=True)
    src_dir = WORK_DIR / "src"
    obj_dir = WORK_DIR / "obj"
    exe_dir = WORK_DIR / "exe"
    for d in (src_dir, obj_dir, exe_dir):
        d.mkdir(parents=True, exist_ok=True)

    cases = []
    seen_hashes = set()
    for f_idx, (fname, gen_fn) in enumerate(FAMILIES):
        if args.only_family and fname != args.only_family:
            continue
        fam_rng = random.Random(args.seed + f_idx * 100003)
        generated = 0
        attempt = 0
        while generated < args.per_family and attempt < args.per_family * 5:
            attempt += 1
            code = gen_fn(fam_rng, generated)
            h = hashlib.sha256(code.encode("utf-8")).hexdigest()[:16]
            if h in seen_hashes:
                continue
            seen_hashes.add(h)
            cid = f"{fname}__{generated:03d}"
            sp = src_dir / f"{cid}.bend"
            sp.write_text(code)
            cases.append({
                "id": cid,
                "family": fname,
                "idx": generated,
                "sha256_16": h,
                "src": sp,
                "obj": obj_dir / f"{cid}.o",
                "exe": exe_dir / f"{cid}.exe",
            })
            generated += 1

    print(f"Generated {len(cases)} distinct Wave 4 programs ({args.per_family}/family, seed={args.seed})", flush=True)

    # Step 1: Wave 4A batch_emit + Upstream oracle in parallel
    t_emit = time.perf_counter()
    w4_jobs = [{"id": c["id"], "src": str(c["src"]), "out": str(c["obj"])} for c in cases]
    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        f_w4 = ex.submit(batch_emit, W4A_API, w4_jobs, WORK_DIR / "w4_manifest.json")
        f_ups = {c["id"]: ex.submit(run_upstream, c["src"]) for c in cases}
        w4_emitted = f_w4.result()
        up_results = {cid: fut.result() for cid, fut in f_ups.items()}
    emit_sec = round(time.perf_counter() - t_emit, 2)
    print(f"Wave 4A batch emit + Upstream oracle finished in {emit_sec:.2f}s", flush=True)

    # Step 2: Link & execute all Wave 4A objects in parallel, deleting .o/.exe immediately
    t_exec = time.perf_counter()
    w4_run_results = {}
    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        futs = {}
        for c in cases:
            cid = c["id"]
            em = w4_emitted[cid]
            if not em["ok"]:
                w4_run_results[cid] = (False, f"W4A_{em['stage'].upper()}_ERR: {em['error'][:240]}")
                c["obj"].unlink(missing_ok=True)
            else:
                futs[ex.submit(link_run_cleanup, c["obj"], AGY_RT, c["exe"])] = cid
        for fut in as_completed(futs):
            w4_run_results[futs[fut]] = fut.result()
    exec_sec = round(time.perf_counter() - t_exec, 2)
    print(f"Wave 4A link + exec finished in {exec_sec:.2f}s", flush=True)

    # Step 3: Compare results & isolate any mismatch against Wave 2
    family_stats = {fname: {"total": 0, "pass": 0, "fail": 0, "up_err": 0} for fname, _ in FAMILIES}
    mismatches = []
    for c in cases:
        cid = c["id"]
        fname = c["family"]
        family_stats[fname]["total"] += 1
        up_ok, up_out = up_results[cid]
        w4_ok, w4_out = w4_run_results[cid]
        if not up_ok:
            family_stats[fname]["up_err"] += 1
            mismatches.append({"id": cid, "family": fname, "kind": "upstream_error", "up": up_out, "w4a": w4_out, "src": str(c["src"])})
        elif w4_ok and up_out == w4_out:
            family_stats[fname]["pass"] += 1
            c["src"].unlink(missing_ok=True)
        else:
            family_stats[fname]["fail"] += 1
            mismatches.append({"id": cid, "family": fname, "kind": "mismatch", "up": up_out, "w4a": w4_out, "src": str(c["src"])})

    real_mismatches = [m for m in mismatches if m["kind"] == "mismatch"]
    if real_mismatches:
        print(f"!!! FOUND {len(real_mismatches)} MISMATCH(ES) — isolating with Wave 2...", flush=True)
        w2_jobs = [{"id": m["id"], "src": m["src"], "out": str(obj_dir / f"{m['id']}.w2.o")} for m in real_mismatches]
        w2_em = batch_emit(W2_API, w2_jobs, WORK_DIR / "w2_manifest.json")
        for m in real_mismatches:
            cid = m["id"]
            em = w2_em[cid]
            if not em["ok"]:
                m["w2"] = f"W2_{em['stage'].upper()}_ERR: {em['error'][:240]}"
            else:
                ok, out = link_run_cleanup(obj_dir / f"{cid}.w2.o", AGY_RT, exe_dir / f"{cid}.w2.exe")
                m["w2"] = out
            print(f"  FAIL {cid}: up={m['up'].strip()!r} | w4a={m['w4a'].strip()!r} | w2={m['w2'].strip()!r}", flush=True)
    for m in mismatches:
        if m["kind"] == "upstream_error":
            print(f"  UP_ERR {m['id']}: {m['up'][:180]}", flush=True)

    total_sec = round(time.perf_counter() - t0, 2)
    total_pass = sum(s["pass"] for s in family_stats.values())
    total_all = sum(s["total"] for s in family_stats.values())
    total_up_err = sum(s["up_err"] for s in family_stats.values())
    total_fail = sum(s["fail"] for s in family_stats.values())

    print("\n=== WAVE 4 DIFFERENTIAL FUZZER SUMMARY ===")
    for fname, st in family_stats.items():
        print(f"  {fname:24s}: {st['pass']:3d}/{st['total']:3d} PASS (fail={st['fail']}, up_err={st['up_err']})")
    print(f"  TOTAL                   : {total_pass:3d}/{total_all:3d} PASS (fail={total_fail}, up_err={total_up_err}) in {total_sec:.2f}s")

    report = {
        "seed": args.seed,
        "per_family": args.per_family,
        "total": total_all,
        "pass": total_pass,
        "fail": total_fail,
        "up_err": total_up_err,
        "emit_sec": emit_sec,
        "exec_sec": exec_sec,
        "total_sec": total_sec,
        "families": family_stats,
        "mismatches": mismatches,
    }
    if args.out_json:
        args.out_json.parent.mkdir(parents=True, exist_ok=True)
        args.out_json.write_text(json.dumps(report, indent=2) + "\n")
    sys.exit(0 if (total_fail == 0 and total_up_err == 0) else 1)


if __name__ == "__main__":
    main()
