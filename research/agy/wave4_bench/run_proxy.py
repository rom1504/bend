#!/usr/bin/env python3
"""Fast CPU-2 proxy benchmark & oracle harness for Wave 4 optimization.

Covers 7 benchmark families (3 upstream-medium + 4 tuned-4) with 100% exact
checksum verification, single-batch Bend compilation, parallel linking, and
cached Handwritten C reference binaries & timings.
"""

import argparse
from concurrent.futures import ThreadPoolExecutor
import fcntl
import hashlib
import json
import math
import os
from pathlib import Path
import re
import shutil
from statistics import median
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
INPUTS_UP = HERE / "inputs" / "upstream"
INPUTS_TUNED = HERE / "inputs" / "tuned"
BATCH_EMIT = REPO / "research" / "agy" / "wave3_fuzz" / "batch_emit.mjs"
DEFAULT_RT = REPO / "selfhost" / "build" / "agy" / "unified" / "runtime-agy.o"
BUILD_ROOT = REPO / "selfhost" / "build" / "agy" / "wave4_bench"
C_REF_DIR = BUILD_ROOT / "c_ref"
SCRATCH_ROOT = BUILD_ROOT / "scratch"

UPSTREAM_FAMILIES = ("histogram", "gameoflife", "nbody")
TUNED_FAMILIES = ("list", "expression", "bst", "editdist")
ALL_FAMILIES = UPSTREAM_FAMILIES + TUNED_FAMILIES

# Verified against upstream TypeScript oracles (inputs/upstream/*/main.ts).
UPSTREAM_EXPECTED = {
    "histogram": {"small": 3825188900, "medium": 3307081914, "upstream": 122845198},
    "gameoflife": {"small": 2601177279, "medium": 3681094808, "upstream": 2016151040},
    "nbody": {"small": 2215450620, "medium": 728502159, "upstream": 3516450380},
}

TUNED_POINTS = {
    "list": {
        "id": "coverage-list-pipeline-128",
        "n": 128,
        "seed": 17,
        "expected": 1904,
        "fixed_reps": 99496,
        "init_reps_bend": 12_000_000,
        "init_reps_c": 20_000_000,
    },
    "expression": {
        "id": "coverage-expression-128",
        "n": 128,
        "seed": 123,
        "expected": 3393903617,
        "fixed_reps": 37732,
        "init_reps_bend": 128_000,
        "init_reps_c": 320_000,
    },
    "bst": {
        "id": "coverage-bst-64",
        "n": 64,
        "seed": 17,
        "expected": 861157620,
        "fixed_reps": 27184,
        "init_reps_bend": 32_000,
        "init_reps_c": 160_000,
    },
    "editdist": {
        "id": "editdist",
        "n": 2,
        "seed": 0,
        "expected": 2065873279,
        "fixed_reps": 240,
        "init_reps_bend": 128,
        "init_reps_c": 1536,
    },
}

# Published Clang-16 Handwritten C baselines (ms) on this Xeon E3-1245 v2 host,
# from inputs/upstream/RESULTS.md and inputs/tuned/RESULTS.md (fixed_reps normalized).
CLANG16_REF_MS = {
    "histogram": 24.0,
    "gameoflife": 241.5,
    "nbody": 74.7,
    "list": 0.0027 * 99496 / 1000.0,        # 0.2686 ms
    "expression": 0.1918 * 37732 / 1000.0,  # 7.2370 ms
    "bst": 0.3986 * 27184 / 1000.0,         # 10.8355 ms
    "editdist": 38.4115 * 240 / 1000.0,     # 9.2188 ms
}

RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]
MASK32 = (1 << 32) - 1


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def find_node() -> str:
    for cand in (
        os.environ.get("NODE"),
        "/home/ai/.nvm/versions/node/v24.22.1/bin/node",
        shutil.which("node"),
    ):
        if cand and Path(cand).is_file():
            return str(cand)
    raise RuntimeError("node binary not found")


def find_linker() -> str:
    for cand in ("gcc-10", "gcc"):
        p = shutil.which(cand)
        if p:
            return p
    raise RuntimeError("gcc-10 / gcc linker not found")


def find_c_compiler():
    """Prefer Clang 16, then Clang, then gcc-10 / gcc."""
    clang16_candidates = [
        shutil.which("clang-16"),
        str(REPO / "selfhost/build/phase1/clang/root/usr/bin/clang-16"),
        "/home/ai/bend2/build/publish/bend/selfhost/build/phase1/clang/root/usr/bin/clang-16",
    ]
    for cand in clang16_candidates:
        if cand and Path(cand).is_file():
            p = Path(cand)
            env = dict(os.environ)
            usr = p.parent.parent
            lib1 = usr / "lib/x86_64-linux-gnu"
            lib2 = usr / "lib/llvm-16/lib"
            if lib1.is_dir() or lib2.is_dir():
                prev = env.get("LD_LIBRARY_PATH", "")
                env["LD_LIBRARY_PATH"] = f"{lib1}:{lib2}" + (f":{prev}" if prev else "")
            return str(p), env, "clang-16"

    for cand in (
        shutil.which("clang"),
        "/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang",
    ):
        if cand and Path(cand).is_file():
            return str(cand), dict(os.environ), "clang"

    for cand in ("gcc-10", "gcc"):
        p = shutil.which(cand)
        if p:
            return p, dict(os.environ), cand

    raise RuntimeError("No C compiler found (tried clang-16, clang, gcc-10, gcc)")


def replace_once(text: str, pattern: str, repl: str) -> str:
    out, n = re.subn(pattern, repl, text, flags=re.M)
    if n != 1:
        raise ValueError(f"expected 1 match for {pattern!r}, found {n}")
    return out


def prepare_upstream_sources(family: str, size: str, up_spec: dict):
    desc = up_spec[family]
    bend_text = (INPUTS_UP / family / "main.bend").read_text()
    c_text = (INPUTS_UP / family / "main.c").read_text()
    defines = []
    if size != "upstream":
        for bname, cname, old, new in zip(
            desc["bendKnobs"], desc["cKnobs"], desc["upstream"], desc[size]
        ):
            bend_text = replace_once(
                bend_text,
                rf"(^def {bname}\(\) -> Nat:\n  ){old}n$",
                rf"\g<1>{new}n",
            )
            if family == "gameoflife":
                c_text = replace_once(
                    c_text,
                    rf"(  uint32_t {cname} = ){old}u;",
                    rf"\g<1>{new}u;",
                )
            else:
                defines.append(f"-D{cname}={new}u")
    return bend_text, c_text, defines


def prepare_tuned_bend(family: str) -> str:
    kernel = (INPUTS_TUNED / "kernels" / f"{family}.bend").read_text()
    driver = (INPUTS_TUNED / "driver.bend").read_text()
    return kernel.rstrip() + "\n\n" + driver


def load_tuned_seed_banks() -> dict:
    """Load precomputed 32-seed banks from inputs/tuned/results.json, fallback to oracle.py."""
    banks = {}
    res_path = INPUTS_TUNED / "results.json"
    if res_path.is_file():
        data = json.loads(res_path.read_text())
        by_id = {row["id"]: row for row in data.get("rows", [])}
        for fam, spec in TUNED_POINTS.items():
            row = by_id.get(spec["id"])
            if (
                row
                and row.get("input") == [spec["n"], spec["seed"]]
                and row.get("expected") == spec["expected"]
                and len(row.get("seed_bank", [])) == 32
            ):
                banks[fam] = row["seed_bank"]

    missing = [f for f in TUNED_FAMILIES if f not in banks]
    if missing:
        sys.path.insert(0, str(INPUTS_TUNED))
        import oracle  # type: ignore

        for fam in missing:
            spec = TUNED_POINTS[fam]
            n, seed = spec["n"], spec["seed"]
            banks[fam] = [
                oracle.value(fam, n, oracle.word(seed + i * 2654435761))
                for i in range(32)
            ]
    return banks


def batch_hash(values, count: int) -> int:
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


def ensure_c_refs(selected, size: str, up_spec: dict):
    """Build & cache Handwritten C reference binaries in C_REF_DIR."""
    C_REF_DIR.mkdir(parents=True, exist_ok=True)
    cc, cc_env, cc_name = find_c_compiler()
    manifest_path = C_REF_DIR / "manifest.json"
    manifest = json.loads(manifest_path.read_text()) if manifest_path.is_file() else {}
    cc_sha = sha256_file(Path(cc))
    flags = ["-std=gnu11", "-O3", "-ffp-contract=off", "-fno-lto"]
    driver_c = INPUTS_TUNED / "driver.c"
    driver_sha = sha256_file(driver_c)

    binaries = {}
    to_build = []

    for fam in selected:
        if fam in UPSTREAM_FAMILIES:
            key = f"{fam}-{size}"
            _, c_text, defines = prepare_upstream_sources(fam, size, up_spec)
            src_sha = sha256_bytes(c_text.encode())
            recipe_hash = sha256_bytes(
                json.dumps(
                    {"cc": cc_sha, "flags": flags, "defines": defines, "src": src_sha},
                    sort_keys=True,
                ).encode()
            )
            out_bin = C_REF_DIR / key
            entry = manifest.get(key)
            if (
                out_bin.is_file()
                and entry
                and entry.get("recipe") == recipe_hash
                and sha256_file(out_bin) == entry.get("bin_sha256")
            ):
                binaries[fam] = (out_bin, entry["bin_sha256"])
            else:
                src_path = C_REF_DIR / f"{key}.c"
                c_out = c_text
                if cc_name.startswith("gcc"):
                    c_out = c_out.replace("__attribute__((musttail)) ", "")
                src_path.write_text(c_out)
                cmd = [cc, *flags, *defines, str(src_path), "-o", str(out_bin), "-lm", "-pthread"]
                to_build.append((fam, key, out_bin, recipe_hash, cmd))
        else:
            key = f"{fam}-tuned"
            kernel_c = INPUTS_TUNED / "kernels" / f"{fam}.c"
            src_sha = sha256_file(kernel_c)
            recipe_hash = sha256_bytes(
                json.dumps(
                    {"cc": cc_sha, "flags": flags, "driver": driver_sha, "src": src_sha},
                    sort_keys=True,
                ).encode()
            )
            out_bin = C_REF_DIR / key
            entry = manifest.get(key)
            if (
                out_bin.is_file()
                and entry
                and entry.get("recipe") == recipe_hash
                and sha256_file(out_bin) == entry.get("bin_sha256")
            ):
                binaries[fam] = (out_bin, entry["bin_sha256"])
            else:
                cmd = [cc, *flags, str(driver_c), str(kernel_c), "-o", str(out_bin), "-lm", "-pthread"]
                to_build.append((fam, key, out_bin, recipe_hash, cmd))

    if to_build:
        def compile_one(item):
            fam, key, out_bin, recipe_hash, cmd = item
            res = subprocess.run(cmd, env=cc_env, capture_output=True, text=True, timeout=60)
            if res.returncode != 0:
                raise RuntimeError(
                    f"C ref compile failed for {key}:\n{res.stderr or res.stdout}"
                )
            return fam, key, out_bin, recipe_hash, sha256_file(out_bin)

        with ThreadPoolExecutor(max_workers=min(4, len(to_build))) as pool:
            for fam, key, out_bin, recipe_hash, bsha in pool.map(compile_one, to_build):
                manifest[key] = {
                    "recipe": recipe_hash,
                    "bin_sha256": bsha,
                    "cc": cc_name,
                    "cc_path": cc,
                }
                binaries[fam] = (out_bin, bsha)
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")

    return binaries, cc_name


def clean_run_env():
    env = dict(os.environ)
    env.pop("BENDRTS", None)
    return env


def run_upstream_once(argv, expected: int, cpu: int, timeout: float = 60.0):
    cmd = ["taskset", "-c", str(cpu), *argv]
    t0 = time.monotonic_ns()
    res = subprocess.run(cmd, env=clean_run_env(), capture_output=True, text=True, timeout=timeout)
    elapsed_ms = (time.monotonic_ns() - t0) / 1e6
    if res.returncode != 0:
        return False, elapsed_ms, f"exit={res.returncode} stderr={res.stderr.strip()[:200]}"
    if res.stderr:
        return False, elapsed_ms, f"unexpected stderr={res.stderr.strip()[:200]}"
    if res.stdout != f"{expected}\n":
        return False, elapsed_ms, f"checksum mismatch: got {res.stdout.strip()!r}, want {expected}"
    return True, elapsed_ms, None


def run_tuned_once(argv, n: int, seed: int, values, reps: int, warm: int, cpu: int, timeout: float = 30.0):
    cmd = ["taskset", "-c", str(cpu), *argv, str(reps), str(warm), str(n), str(seed)]
    res = subprocess.run(cmd, env=clean_run_env(), capture_output=True, text=True, timeout=timeout)
    if res.returncode != 0:
        return False, 0, f"exit={res.returncode} stderr={res.stderr.strip()[:200]}"
    if res.stderr:
        return False, 0, f"unexpected stderr={res.stderr.strip()[:200]}"
    lines = res.stdout.splitlines()
    want = [str(values[0]), str(batch_hash(values, warm)), str(batch_hash(values, reps))]
    if len(lines) != 4 or lines[:3] != want:
        return False, 0, f"checksum mismatch: got {lines[:3]!r}, want {want!r}"
    ms = int(lines[3])
    if ms < 0:
        return False, 0, f"negative timer {ms}"
    return True, ms, None


def measure_tuned(argv, fam: str, values, init_reps: int, runs: int, small: bool, cpu: int):
    spec = TUNED_POINTS[fam]
    n, seed = spec["n"], spec["seed"]
    warm = 3 if small else 32
    reps = 35 if small else init_reps

    samples = []
    if small:
        for _ in range(runs):
            ok, ms, err = run_tuned_once(argv, n, seed, values, reps, warm, cpu)
            if not ok:
                return {"ok": False, "error": err}
            samples.append(ms)
        med_ms = float(median(samples))
        us_per_call = (med_ms * 1000.0) / reps
        norm_ms = us_per_call * spec["fixed_reps"] / 1000.0
        return {
            "ok": True,
            "reps": reps,
            "raw_samples_ms": samples,
            "raw_median_ms": med_ms,
            "us_per_call": us_per_call,
            "ms": norm_ms,
        }

    # Normal mode: first sample also auto-calibrates if Bend/C got much faster (< 30 ms).
    for _ in range(5):
        ok, ms, err = run_tuned_once(argv, n, seed, values, reps, warm, cpu)
        if not ok:
            return {"ok": False, "error": err}
        if ms >= 30 or reps >= 100_000_000:
            samples.append(ms)
            break
        scale = min(16, max(2, math.ceil(64 / max(ms, 1))))
        reps = min(100_000_000, ((reps * scale + 31) // 32) * 32)
    else:
        samples.append(ms)

    while len(samples) < runs:
        ok, ms, err = run_tuned_once(argv, n, seed, values, reps, warm, cpu)
        if not ok:
            return {"ok": False, "error": err}
        samples.append(ms)

    med_ms = float(median(samples))
    if med_ms <= 0:
        return {"ok": False, "error": f"timer resolution 0 ms at reps={reps}"}
    us_per_call = (med_ms * 1000.0) / reps
    norm_ms = us_per_call * spec["fixed_reps"] / 1000.0
    return {
        "ok": True,
        "reps": reps,
        "raw_samples_ms": samples,
        "raw_median_ms": med_ms,
        "us_per_call": us_per_call,
        "ms": norm_ms,
    }


def measure_upstream(argv, fam: str, size: str, runs: int, cpu: int):
    expected = UPSTREAM_EXPECTED[fam][size]
    samples = []
    for _ in range(runs):
        ok, ms, err = run_upstream_once(argv, expected, cpu)
        if not ok:
            return {"ok": False, "error": err}
        samples.append(ms)
    return {
        "ok": True,
        "samples_ms": [round(x, 3) for x in samples],
        "ms": float(median(samples)),
        "expected": expected,
    }


def measure_c_refs(selected, c_bins, size: str, runs: int, small: bool, cpu: int, retime: bool, seed_banks: dict):
    mode = "small" if small else "medium"
    cache_path = C_REF_DIR / f"timings_{mode}_cpu{cpu}.json"
    cache = json.loads(cache_path.read_text()) if (cache_path.is_file() and not retime) else {}
    results = {}
    dirty = False

    for fam in selected:
        c_bin, bsha = c_bins[fam]
        cached = cache.get(fam)
        if (
            not retime
            and cached
            and cached.get("bin_sha256") == bsha
            and cached.get("ok")
        ):
            results[fam] = cached
            continue

        if fam in UPSTREAM_FAMILIES:
            m = measure_upstream([str(c_bin)], fam, size, runs, cpu)
        else:
            m = measure_tuned(
                [str(c_bin)],
                fam,
                seed_banks[fam],
                TUNED_POINTS[fam]["init_reps_c"],
                runs,
                small,
                cpu,
            )
        m["bin_sha256"] = bsha
        results[fam] = m
        if m["ok"]:
            cache[fam] = m
            dirty = True

    if dirty:
        cache_path.write_text(json.dumps(cache, indent=2) + "\n")
    return results


def build_bend_batch(selected, api_path: Path, rt_path: Path, size: str, up_spec: dict, work_dir: Path):
    node = find_node()
    linker = find_linker()
    jobs = []
    for fam in selected:
        src_path = work_dir / f"{fam}.bend"
        obj_path = work_dir / f"{fam}.o"
        if fam in UPSTREAM_FAMILIES:
            bend_text, _, _ = prepare_upstream_sources(fam, size, up_spec)
        else:
            bend_text = prepare_tuned_bend(fam)
        src_path.write_text(bend_text)
        jobs.append({"id": fam, "src": str(src_path), "out": str(obj_path)})

    manifest_path = work_dir / "manifest.json"
    manifest_path.write_text(json.dumps(jobs, indent=2))

    t0 = time.monotonic()
    res = subprocess.run(
        [node, "--stack-size=65536", str(BATCH_EMIT), str(api_path), str(manifest_path)],
        capture_output=True,
        text=True,
        timeout=120,
    )
    emit_s = time.monotonic() - t0
    if res.returncode != 0:
        raise RuntimeError(f"batch_emit.mjs failed:\n{res.stderr or res.stdout}")
    emit_rows = {row["id"]: row for row in json.loads(res.stdout)}

    bins = {}
    errors = {}
    to_link = []
    for fam in selected:
        row = emit_rows.get(fam, {"ok": False, "error": "missing from batch_emit output"})
        if not row.get("ok"):
            errors[fam] = f"emit({row.get('stage', '?')}): {row.get('error', '?')}"
        else:
            to_link.append((fam, work_dir / f"{fam}.o", work_dir / f"{fam}.bin"))

    t1 = time.monotonic()
    if to_link:
        def link_one(item):
            fam, obj_path, bin_path = item
            r = subprocess.run(
                [linker, "-no-pie", str(obj_path), str(rt_path), "-pthread", "-lm", "-o", str(bin_path)],
                capture_output=True,
                text=True,
                timeout=30,
            )
            if r.returncode != 0:
                return fam, None, f"link: {(r.stderr or r.stdout).strip()[:200]}"
            return fam, bin_path, None

        with ThreadPoolExecutor(max_workers=min(7, len(to_link))) as pool:
            for fam, bin_path, err in pool.map(link_one, to_link):
                if err:
                    errors[fam] = err
                else:
                    bins[fam] = bin_path
    link_s = time.monotonic() - t1

    return bins, errors, emit_s, link_s


def geomean(vals):
    if not vals:
        return None
    return math.exp(sum(math.log(v) for v in vals) / len(vals))


def parse_only(raw: str):
    if not raw:
        return list(ALL_FAMILIES)
    selected = []
    for tok in raw.split(","):
        tok = tok.strip()
        if not tok:
            continue
        if tok == "upstream":
            for f in UPSTREAM_FAMILIES:
                if f not in selected:
                    selected.append(f)
        elif tok == "tuned":
            for f in TUNED_FAMILIES:
                if f not in selected:
                    selected.append(f)
        elif tok in ALL_FAMILIES:
            if tok not in selected:
                selected.append(tok)
        else:
            raise ValueError(f"Unknown benchmark {tok!r}; choose from {', '.join(ALL_FAMILIES)}")
    return selected


def main():
    p = argparse.ArgumentParser(description="Wave 4 CPU-2 proxy benchmark & oracle harness")
    p.add_argument("--api", required=True, type=Path, help="Path to compiler api.mjs")
    p.add_argument("--rt", type=Path, default=DEFAULT_RT, help="Path to runtime-agy.o")
    p.add_argument("--only", default="", help="Comma-separated subset of benchmarks (or 'upstream', 'tuned')")
    p.add_argument("--runs", type=int, default=3, help="Number of timed runs per benchmark (default: 3)")
    p.add_argument("--small", action="store_true", help="Instant ~1s smoke test mode")
    p.add_argument("--retime-c", action="store_true", help="Force re-timing Handwritten C references")
    p.add_argument("--cpu", type=int, default=2, help="CPU core for taskset pinning (default: 2)")
    p.add_argument("--json", type=Path, default=None, help="Output JSON report path")
    args = p.parse_args()

    t_start = time.monotonic()
    api_path = args.api.resolve()
    rt_path = args.rt.resolve()
    if not api_path.is_file():
        sys.exit(f"ERROR: api.mjs not found: {api_path}")
    if not rt_path.is_file():
        sys.exit(f"ERROR: runtime.o not found: {rt_path}")

    selected = parse_only(args.only)
    size = "small" if args.small else "medium"
    up_spec = json.loads((INPUTS_UP / "suite.json").read_text())
    seed_banks = load_tuned_seed_banks() if any(f in TUNED_FAMILIES for f in selected) else {}

    c_bins, cc_name = ensure_c_refs(selected, size, up_spec)
    c_results = measure_c_refs(
        selected, c_bins, size, args.runs, args.small, args.cpu, args.retime_c, seed_banks
    )

    work_dir = SCRATCH_ROOT / f"run_{os.getpid()}"
    work_dir.mkdir(parents=True, exist_ok=True)
    try:
        bend_bins, build_errors, emit_s, link_s = build_bend_batch(
            selected, api_path, rt_path, size, up_spec, work_dir
        )

        rows = []
        all_ok = True
        lock_fd = open(f"/tmp/agy_cpu{args.cpu}_bench.lock", "w")
        try:
            fcntl.flock(lock_fd, fcntl.LOCK_EX)
            for fam in selected:
                group = "upstream" if fam in UPSTREAM_FAMILIES else "tuned"
                c_res = c_results[fam]
                if not c_res.get("ok"):
                    all_ok = False
                    rows.append({
                        "name": fam,
                        "group": group,
                        "status": "FAIL",
                        "error": f"C ref failed: {c_res.get('error')}",
                    })
                    continue

                if fam in build_errors:
                    all_ok = False
                    rows.append({
                        "name": fam,
                        "group": group,
                        "c_ms": c_res["ms"],
                        "status": "FAIL",
                        "error": build_errors[fam],
                    })
                    continue

                argv = [str(bend_bins[fam]), *RTS_ARGS]
                if fam in UPSTREAM_FAMILIES:
                    b_res = measure_upstream(argv, fam, size, args.runs, args.cpu)
                else:
                    b_res = measure_tuned(
                        argv,
                        fam,
                        seed_banks[fam],
                        TUNED_POINTS[fam]["init_reps_bend"],
                        args.runs,
                        args.small,
                        args.cpu,
                    )

                if not b_res.get("ok"):
                    all_ok = False
                    rows.append({
                        "name": fam,
                        "group": group,
                        "c_ms": c_res["ms"],
                        "status": "FAIL",
                        "error": b_res.get("error"),
                    })
                    continue

                ratio = b_res["ms"] / c_res["ms"] if c_res["ms"] > 0 else float("nan")
                c16_ms = CLANG16_REF_MS[fam] if not args.small else None
                ratio_c16 = (b_res["ms"] / c16_ms) if (c16_ms and c16_ms > 0) else None
                row = {
                    "name": fam,
                    "group": group,
                    "c_ms": round(c_res["ms"], 4),
                    "bend_ms": round(b_res["ms"], 4),
                    "ratio": round(ratio, 4) if math.isfinite(ratio) else None,
                    "c16_ms": round(c16_ms, 4) if c16_ms is not None else None,
                    "ratio_c16": round(ratio_c16, 4) if ratio_c16 is not None else None,
                    "status": "PASS",
                    "c": c_res,
                    "bend": b_res,
                }
                rows.append(row)
        finally:
            fcntl.flock(lock_fd, fcntl.LOCK_UN)
            lock_fd.close()
    finally:
        shutil.rmtree(work_dir, ignore_errors=True)

    wall_s = time.monotonic() - t_start

    up_ratios = [r["ratio"] for r in rows if r["group"] == "upstream" and r["status"] == "PASS" and r["ratio"]]
    tu_ratios = [r["ratio"] for r in rows if r["group"] == "tuned" and r["status"] == "PASS" and r["ratio"]]
    all_ratios = up_ratios + tu_ratios

    gm_up = geomean(up_ratios)
    gm_tu = geomean(tu_ratios)
    gm_all = geomean(all_ratios)

    up_c16 = [r["ratio_c16"] for r in rows if r["group"] == "upstream" and r["status"] == "PASS" and r.get("ratio_c16")]
    tu_c16 = [r["ratio_c16"] for r in rows if r["group"] == "tuned" and r["status"] == "PASS" and r.get("ratio_c16")]
    all_c16 = up_c16 + tu_c16
    gm_up_c16 = geomean(up_c16)
    gm_tu_c16 = geomean(tu_c16)
    gm_all_c16 = geomean(all_c16)

    print(
        f"Wave 4 Proxy ({size}, CPU {args.cpu}, runs={args.runs}, cc={cc_name}) "
        f"| emit={emit_s:.2f}s link={link_s:.2f}s total={wall_s:.2f}s"
    )
    print(f"API: {api_path}")
    print(f"RT:  {rt_path}")
    print()
    show_c16 = (not args.small) and (cc_name != "clang-16")
    if show_c16:
        print(f"{'Benchmark':<12} {'Group':<9} {'C_ms':>9} {'Bend_ms':>10} {'Bend/C':>8} {'Bend/C16':>9}  {'Status'}")
        print("-" * 71)
    else:
        print(f"{'Benchmark':<12} {'Group':<9} {'C_ms':>10} {'Bend_ms':>10} {'Bend/C':>9}  {'Status'}")
        print("-" * 62)
    for r in rows:
        c_str = f"{r['c_ms']:.3f}" if "c_ms" in r else "-"
        b_str = f"{r['bend_ms']:.3f}" if "bend_ms" in r else "-"
        rat_str = f"{r['ratio']:.2f}x" if r.get("ratio") is not None else "-"
        c16_str = f"{r['ratio_c16']:.2f}x" if r.get("ratio_c16") is not None else "-"
        extra = f"  ({r['error']})" if r.get("error") else ""
        if show_c16:
            print(f"{r['name']:<12} {r['group']:<9} {c_str:>9} {b_str:>10} {rat_str:>8} {c16_str:>9}  {r['status']}{extra}")
        else:
            print(f"{r['name']:<12} {r['group']:<9} {c_str:>10} {b_str:>10} {rat_str:>9}  {r['status']}{extra}")
    print("-" * (71 if show_c16 else 62))
    if gm_up is not None:
        c16_part = f"  | vs Clang-16: {gm_up_c16:.3f}x" if (show_c16 and gm_up_c16) else ""
        print(f"upstream-{size} geomean (Bend/C):   {gm_up:.3f}x{c16_part}")
    if gm_tu is not None:
        c16_part = f"  | vs Clang-16: {gm_tu_c16:.3f}x" if (show_c16 and gm_tu_c16) else ""
        print(f"tuned-4 geomean (Bend/C):           {gm_tu:.3f}x{c16_part}")
    if gm_all is not None:
        c16_part = f"  | vs Clang-16: {gm_all_c16:.3f}x" if (show_c16 and gm_all_c16) else ""
        print(f"7-family overall geomean (Bend/C):  {gm_all:.3f}x{c16_part}")

    report = {
        "mode": size,
        "cpu": args.cpu,
        "runs": args.runs,
        "cc": cc_name,
        "api": str(api_path),
        "api_sha256": sha256_file(api_path),
        "rt": str(rt_path),
        "rt_sha256": sha256_file(rt_path),
        "emit_seconds": round(emit_s, 3),
        "link_seconds": round(link_s, 3),
        "wall_seconds": round(wall_s, 3),
        "all_pass": all_ok,
        "geomean": {
            "upstream": round(gm_up, 4) if gm_up is not None else None,
            "tuned": round(gm_tu, 4) if gm_tu is not None else None,
            "overall": round(gm_all, 4) if gm_all is not None else None,
        },
        "geomean_clang16_ref": {
            "upstream": round(gm_up_c16, 4) if gm_up_c16 is not None else None,
            "tuned": round(gm_tu_c16, 4) if gm_tu_c16 is not None else None,
            "overall": round(gm_all_c16, 4) if gm_all_c16 is not None else None,
        },
        "benchmarks": rows,
    }
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(report, indent=2) + "\n")

    sys.exit(0 if all_ok else 1)


if __name__ == "__main__":
    main()
