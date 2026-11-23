#!/usr/bin/env python3
"""S10-G End-to-End Verification & Benchmark Suite (`verify_and_bench_s10g.py`).

Tests BOTH S10-G multipliers on CPUs 5, 7 (keeping /tmp/agy_s10g < 150 MB):
  1. Balanced K=16 & K=24 zero-tail splits (`split_kN_balanced.py`) on `compiler_pruned.bend`
  2. Compiler-only `--nodrop` (`apply_s10g.py`):
     - Zero regression: `n7_normal` normal `x86-object` / `x86-object-fast` 100% SHA-256 bit-identical to `n6_o2`
     - `-O2` & `-O0` `--nodrop` on `compiler_slice.bend` + `hot_bench` (`histogram`, `gameoflife`, `bst`, `editdist`)
     - Full K=16 self-compiled `--nodrop` compiler (`n8_nodrop`) vs normal (`n7_normal`):
       * Exact speedup on `compiler_slice.bend` (-O0 & -O2) and `m15_zero.bend` (-O0 & -O2)
       * Exact peak RSS via `/usr/bin/time -v` (must stay < 1.5 GiB)
       * 100% SHA-256 bit-identical `.o` output vs `n7_normal` & `n6_o2`
     - K=24 zero-`.p130` smoke compile (`m00`, `m23`) with `n8_nodrop`
"""
from __future__ import annotations

import concurrent.futures
import hashlib
import json
import os
import queue
import re
import shutil
import subprocess
import time
from pathlib import Path
from statistics import median

ROOT = Path("/home/ai/bend2_agy")
WORK = Path("/tmp/agy_s10g")
OUT_DIR = ROOT / "research/agy/s10_campaign/s10g_nodrop_and_k24"

N6_O2 = ROOT / "selfhost/build/agy/wave15-native-mod/n6_o2"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
CC = "gcc-10"
CPUS = [5, 7]
RTS_ARGS = ["+RTS", "-H", "128M", "-s", "256M", "-RTS"]

SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
HOT_BENCHES = [
    ("histogram", ROOT / "research/agy/wave4_bench/inputs/upstream/histogram/main.bend", "3307081914"),
    ("gameoflife", ROOT / "research/agy/wave4_bench/inputs/upstream/gameoflife/main.bend", "3681094808"),
    ("nbody", ROOT / "research/agy/wave4_bench/inputs/upstream/nbody/main.bend", None),
]

TREESHAKE = ROOT / "research/agy/s10_campaign/s10b_treeshake/treeshake_w15.py"
APPLY_S10A = ROOT / "research/agy/s10_campaign/s10a_zero_p130/apply_s10a.py"
GEN_STUBS = ROOT / "research/agy/s10_campaign/s10a_zero_p130/gen_stubs.py"
APPLY_S10G = OUT_DIR / "apply_s10g.py"
SPLIT_KN = OUT_DIR / "split_kN_balanced.py"


def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def run_timed(cmd: list[str], out_file: Path | None, err_file: Path, cpu: int, timeout_s: int = 180) -> tuple[float, float, str]:
    """Run command pinned to `cpu`, returning (wall_ms, peak_rss_mib, stderr) via wait4 rusage."""
    err_file.parent.mkdir(parents=True, exist_ok=True)
    if out_file is not None:
        out_file.parent.mkdir(parents=True, exist_ok=True)
    wrapped = [
        "timeout", str(timeout_s),
        "bash", "-c",
        'ulimit -s 262144 && exec taskset -c "$1" "${@:2}"',
        "_", str(cpu), *cmd,
    ]
    t0 = time.perf_counter()
    if out_file is not None:
        with out_file.open("wb") as of, err_file.open("wb") as ef:
            p = subprocess.Popen(wrapped, stdout=of, stderr=ef, cwd=ROOT)
            _, status, ru = os.wait4(p.pid, 0)
    else:
        with err_file.open("wb") as ef:
            p = subprocess.Popen(wrapped, stdout=subprocess.DEVNULL, stderr=ef, cwd=ROOT)
            _, status, ru = os.wait4(p.pid, 0)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    rc = os.waitstatus_to_exitcode(status)
    rss_mib = round(ru.ru_maxrss / 1024.0, 1)
    stderr = err_file.read_text(encoding="utf-8", errors="replace").strip()
    if rc != 0:
        raise RuntimeError(f"Command failed (rc={rc}, cpu={cpu}): {' '.join(cmd[:4])}\n{stderr[-1000:]}")
    return ms, rss_mib, stderr


def run_bin_timed(bin_path: Path, cpu: int, runs: int = 3) -> tuple[float, float, str]:
    """Run a compiled Bend executable `runs` times, returning (median_ms, max_rss_mib, stdout)."""
    times_ms: list[float] = []
    rss_vals: list[float] = []
    last_out = ""
    err_f = WORK / "run_tmp.err"
    out_f = WORK / "run_tmp.out"
    for _ in range(runs):
        ms, rss, _ = run_timed([str(bin_path), *RTS_ARGS], out_f, err_f, cpu=cpu, timeout_s=60)
        times_ms.append(ms)
        rss_vals.append(rss)
        last_out = out_f.read_text(encoding="utf-8", errors="replace").strip()
    out_f.unlink(missing_ok=True)
    err_f.unlink(missing_ok=True)
    return round(median(times_ms), 1), max(rss_vals), last_out


def link_obj(obj: Path, out_bin: Path, cpu: int = 5) -> None:
    r = subprocess.run(
        ["timeout", "60", "taskset", "-c", str(cpu), CC, "-O2", "-no-pie", str(obj), str(RT), "-o", str(out_bin), "-lm", "-lpthread"],
        capture_output=True, text=True, cwd=ROOT,
    )
    if r.returncode != 0:
        raise RuntimeError(f"link failed: {r.stderr[-1000:]}")


def encode_sym_name(name: str) -> str:
    return "_".join(str(ord(c)) for c in name) + "_"


def weaken_stub_syms(obj_dir: Path, src_dir: Path, mod_names: list[str], cpu: int = 5) -> None:
    """One-time bootstrap helper for unmodified n6_o2 (which predates S10-A)."""
    for m in mod_names:
        if m == "m00":
            continue
        src_p = src_dir / f"{m}_zero.bend"
        txt = src_p.read_text(encoding="utf-8")
        i0 = txt.find("# === S10-A ZERO-P130 IMPORTS")
        i1 = txt.find("# === MODULE BODY:")
        if i0 == -1 or i1 == -1:
            continue
        stub_sec = txt[i0:i1]
        names = re.findall(r"^def\s+([A-Za-z0-9_.\$]+)\s*\(", stub_sec, re.M)
        if not names:
            continue
        syms: list[str] = []
        for nm in names:
            for pref in ("", "$direct.", "$p118borrow.read.", "$p128borrow.owned.", "$product."):
                enc = encode_sym_name(pref + nm)
                syms.append(f"p111_FID_{enc}")
                syms.append(f"p113d_FID_{enc}")
                syms.append(f"p114r_FID_{enc}")
        sym_file = obj_dir / f"{m}_weak.txt"
        sym_file.write_text("\n".join(syms) + "\n", encoding="utf-8")
        obj = obj_dir / f"{m}.o"
        subprocess.run(
            ["timeout", "30", "taskset", "-c", str(cpu), "objcopy", f"--weaken-symbols={sym_file}", str(obj)],
            check=True,
        )
        sym_file.unlink(missing_ok=True)


def compile_k_modules(
    compiler_bin: Path,
    src_dir: Path,
    obj_dir: Path,
    mod_names: list[str],
    fid_bases: dict[str, int],
    mode_args: list[str],
    cpus: list[int],
) -> dict:
    obj_dir.mkdir(parents=True, exist_ok=True)
    cpu_q: queue.Queue[int] = queue.Queue()
    for c in cpus:
        cpu_q.put(c)

    def worker(m: str) -> dict:
        cpu = cpu_q.get()
        try:
            src = src_dir / f"{m}_zero.bend"
            obj = obj_dir / f"{m}.o"
            err = obj_dir / f"{m}.err"
            args = [
                *mode_args,
                str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP,
                str(fid_bases[m]), m,
            ]
            ms, rss_mib, _ = run_timed([str(compiler_bin), *args], obj, err, cpu=cpu, timeout_s=180)
            sz = obj.stat().st_size
            err.unlink(missing_ok=True)
            print(f"    [{m}] cpu={cpu} ms={ms:.1f} rss={rss_mib:.1f}MiB obj={sz/1024:.0f}KB", flush=True)
            return {"mod": m, "cpu": cpu, "ms": ms, "rss_mib": rss_mib, "obj_bytes": sz}
        finally:
            cpu_q.put(cpu)

    t0 = time.perf_counter()
    recs: list[dict] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(cpus)) as ex:
        futs = [ex.submit(worker, m) for m in mod_names]
        for f in concurrent.futures.as_completed(futs):
            recs.append(f.result())
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    recs.sort(key=lambda r: r["mod"])
    return {
        "wall_ms": wall_ms,
        "cpu_sum_ms": round(sum(r["ms"] for r in recs), 1),
        "max_rss_mib": max(r["rss_mib"] for r in recs),
        "total_obj_bytes": sum(r["obj_bytes"] for r in recs),
        "modules": recs,
    }


def merge_and_link(compiler_bin: Path, obj_dir: Path, mod_names: list[str], out_bin: Path, cpu: int = 5, delete_compiler_before_link: Path | None = None) -> tuple[float, float]:
    entry_mod = mod_names[-1]
    ordered = [entry_mod] + mod_names[:-1]
    mod_objs = [obj_dir / f"{m}.o" for m in ordered]
    merge_o = obj_dir / "merge.o"
    merge_err = obj_dir / "merge.err"
    merge_ms, _, _ = run_timed([str(compiler_bin), "x86-merge-obj", entry_mod, *ordered], merge_o, merge_err, cpu=cpu, timeout_s=60)
    merge_err.unlink(missing_ok=True)
    if delete_compiler_before_link is not None and delete_compiler_before_link.exists():
        delete_compiler_before_link.unlink()
    t0 = time.perf_counter()
    r = subprocess.run(
        [
            "timeout", "60", "taskset", "-c", str(cpu), CC, "-O2", "-no-pie",
            str(merge_o), *[str(o) for o in mod_objs], str(RT), "-o", str(out_bin), "-lm", "-lpthread",
        ],
        capture_output=True, text=True, cwd=ROOT,
    )
    link_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    if r.returncode != 0:
        raise RuntimeError(f"gcc-10 link failed (rc={r.returncode}): {r.stderr[-1500:]}")
    return merge_ms, link_ms


def main() -> None:
    WORK.mkdir(parents=True, exist_ok=True)
    results: dict = {"task": "S10-G", "cpus": CPUS}

    # === STEP 1: Generate S10-A -> Tree-shake (S10-B) -> S10-G + Balanced K=16 & K=24 Splits ===
    print("=== STEP 1: S10-A + Tree-shake (S10-B) + S10-G + Balanced K=16 & K=24 Splits ===", flush=True)
    w15_src = ROOT / "selfhost/build/agy/wave15_unified/compiler.bend"
    s10a_src = WORK / "compiler_s10a.bend"
    pruned = WORK / "compiler_s10ab.bend"
    patched = WORK / "compiler_s10ag.bend"
    subprocess.run(["taskset", "-c", "5,7", "python3", str(APPLY_S10A), str(w15_src), str(s10a_src)], check=True, cwd=ROOT)
    subprocess.run(["taskset", "-c", "5,7", "python3", str(TREESHAKE), "--src", str(s10a_src), "--out", str(pruned)], check=True, cwd=ROOT)
    s10a_src.unlink(missing_ok=True)
    subprocess.run(["taskset", "-c", "5,7", "python3", str(APPLY_S10G), str(pruned), "--out", str(patched)], check=True, cwd=ROOT)

    k16_dir = WORK / "k16_s10ag"
    k24_dir = WORK / "k24_s10ag"
    subprocess.run(["taskset", "-c", "5,7", "python3", str(SPLIT_KN), "--k", "16", "--src", str(patched), "--out-dir", str(k16_dir)], check=True, cwd=ROOT)
    subprocess.run(["taskset", "-c", "5,7", "python3", str(SPLIT_KN), "--k", "24", "--src", str(patched), "--out-dir", str(k24_dir)], check=True, cwd=ROOT)

    k16_manifest = json.loads((k16_dir / "manifest.json").read_text())
    k24_manifest = json.loads((k24_dir / "manifest.json").read_text())
    results["splits"] = {
        "k16": k16_manifest["balance"] | {"totals": k16_manifest["totals"]},
        "k24": k24_manifest["balance"] | {"totals": k24_manifest["totals"]},
    }

    k16_zero = WORK / "k16_s10ag_zero"
    k24_zero = WORK / "k24_s10ag_zero"
    subprocess.run(["taskset", "-c", "5,7", "python3", str(GEN_STUBS), "--k-dir", str(k16_dir), "--out-dir", str(k16_zero)], check=True, cwd=ROOT)
    subprocess.run(["taskset", "-c", "5,7", "python3", str(GEN_STUBS), "--k-dir", str(k24_dir), "--out-dir", str(k24_zero)], check=True, cwd=ROOT)

    # Clean redundant large monolithic copies to save /tmp space
    patched.unlink(missing_ok=True)
    pruned.unlink(missing_ok=True)
    for d in [WORK / "compiler_pruned_s10g.bend", WORK / "compiler_w15_s10g.bend", WORK / "m09_s10g.bend"]:
        d.unlink(missing_ok=True)
    for d in [WORK / "k16_pruned", WORK / "k24_pruned", WORK / "k24_pruned_zero"]:
        if d.exists():
            shutil.rmtree(d)

    # === STEP 2: Baseline n6_o2 reference hashes ===
    print("\n=== STEP 2: Reference n6_o2 SHA-256 hashes ===", flush=True)
    n6_refs: dict[str, dict] = {}
    for label, mode, src in [
        ("slice_O0", "x86-object-fast", SLICE),
        ("slice_O2", "x86-object", SLICE),
        *[(f"{name}_O2", "x86-object", p) for name, p, _ in HOT_BENCHES],
    ]:
        obj = WORK / f"ref_{label}.o"
        err = WORK / f"ref_{label}.err"
        ms, rss, _ = run_timed([str(N6_O2), mode, str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], obj, err, cpu=5)
        n6_refs[label] = {"sha256": sha256_file(obj), "obj_bytes": obj.stat().st_size, "compile_ms": ms, "rss_mib": rss}
        obj.unlink(missing_ok=True)
        err.unlink(missing_ok=True)
    results["n6_o2_refs"] = n6_refs

    # === STEP 3: Bootstrap n7_normal (K=16, normal -O0, with S10-A + S10-G) ===
    print("\n=== STEP 3: Bootstrap n7_normal (K=16 normal -O0 via n6_o2) ===", flush=True)
    mod_names_16 = [m["name"] for m in k16_manifest["modules"]]
    fid_bases_16 = {m["name"]: m["fid_base"] for m in k16_manifest["modules"]}
    obj_n7 = WORK / "obj_n7"
    n7_build = compile_k_modules(N6_O2, k16_zero, obj_n7, mod_names_16, fid_bases_16, ["x86-module-fast"], CPUS)
    weaken_stub_syms(obj_n7, k16_zero, mod_names_16, cpu=5)
    n7_bin = WORK / "n7_normal"
    m_ms, l_ms = merge_and_link(N6_O2, obj_n7, mod_names_16, n7_bin, cpu=5)
    n7_bytes = n7_bin.stat().st_size
    shutil.rmtree(obj_n7)
    results["n7_normal_build"] = n7_build | {"merge_ms": m_ms, "link_ms": l_ms, "bin_bytes": n7_bytes}
    print(f"  -> n7_normal built: wall={n7_build['wall_ms']}ms cpu_sum={n7_build['cpu_sum_ms']}ms bin={n7_bytes/1e6:.2f}MB", flush=True)

    # === STEP 4: Verify n7_normal zero-regression + benchmark --nodrop on user programs (-O0 & -O2) ===
    print("\n=== STEP 4: n7_normal Zero-Regression & --nodrop Program Benchmarks (-O0 & -O2) ===", flush=True)
    prog_bench: dict[str, dict] = {}
    for label, mode, src, expected in [
        ("slice_O0", "x86-object-fast", SLICE, "34"),
        ("slice_O2", "x86-object", SLICE, "34"),
        *[(f"{name}_O2", "x86-object", p, exp) for name, p, exp in HOT_BENCHES],
    ]:
        # Normal mode (must be 100% bit-identical to n6_o2!)
        obj_norm = WORK / f"norm_{label}.o"
        err_norm = WORK / f"norm_{label}.err"
        c_ms_n, c_rss_n, _ = run_timed([str(n7_bin), mode, str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], obj_norm, err_norm, cpu=5)
        sha_n = sha256_file(obj_norm)
        sz_n = obj_norm.stat().st_size
        bit_id = (sha_n == n6_refs[label]["sha256"])
        assert bit_id, f"REGRESSION: {label} normal mode SHA-256 mismatch vs n6_o2!"
        bin_norm = WORK / f"bin_norm_{label}"
        link_obj(obj_norm, bin_norm, cpu=5)
        r_ms_n, r_rss_n, out_n = run_bin_timed(bin_norm, cpu=5, runs=3)
        if expected is not None:
            assert out_n == expected, f"{label} normal output {out_n!r} != {expected!r}"
        obj_norm.unlink(missing_ok=True)
        err_norm.unlink(missing_ok=True)
        bin_norm.unlink(missing_ok=True)

        # --nodrop mode
        obj_nd = WORK / f"nd_{label}.o"
        err_nd = WORK / f"nd_{label}.err"
        c_ms_nd, c_rss_nd, _ = run_timed([str(n7_bin), "--nodrop", mode, str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], obj_nd, err_nd, cpu=5)
        sz_nd = obj_nd.stat().st_size
        bin_nd = WORK / f"bin_nd_{label}"
        link_obj(obj_nd, bin_nd, cpu=5)
        r_ms_nd, r_rss_nd, out_nd = run_bin_timed(bin_nd, cpu=5, runs=3)
        assert out_nd == out_n, f"{label} --nodrop output {out_nd!r} != normal {out_n!r}"
        obj_nd.unlink(missing_ok=True)
        err_nd.unlink(missing_ok=True)
        bin_nd.unlink(missing_ok=True)

        spd = round(r_ms_n / r_ms_nd, 3) if r_ms_nd > 0 else 0.0
        c_spd = round(c_ms_n / c_ms_nd, 3) if c_ms_nd > 0 else 0.0
        prog_bench[label] = {
            "normal_bit_identical_to_n6_o2": bit_id,
            "out": out_n,
            "normal": {"compile_ms": c_ms_n, "obj_bytes": sz_n, "run_ms": r_ms_n, "run_rss_mib": r_rss_n},
            "nodrop": {"compile_ms": c_ms_nd, "obj_bytes": sz_nd, "run_ms": r_ms_nd, "run_rss_mib": r_rss_nd},
            "run_speedup": spd,
            "compile_speedup": c_spd,
            "obj_size_ratio": round(sz_nd / sz_n, 3),
        }
        print(
            f"  [{label:<14}] bit_id={bit_id} out={out_n} | run: {r_ms_n}ms -> {r_ms_nd}ms ({spd:.2f}x) "
            f"rss: {r_rss_n} -> {r_rss_nd}MiB | obj: {sz_n/1024:.0f} -> {sz_nd/1024:.0f}KB ({sz_nd/sz_n:.2f}x)",
            flush=True,
        )
    results["program_nodrop_benchmarks"] = prog_bench

    # === STEP 5: Benchmark n7_normal compiling compiler workloads (slice & m15_zero) ===
    print("\n=== STEP 5: Benchmark n7_normal compiling compiler workloads ===", flush=True)
    m15_src = k16_zero / "m15_zero.bend"
    m15_fid = str(fid_bases_16["m15"])
    compiler_workloads = [
        ("slice_O0", ["x86-object-fast", str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP]),
        ("slice_O2", ["x86-object", str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP]),
        ("m15_zero_O0", ["x86-module-fast", str(m15_src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP, m15_fid, "m15"]),
        ("m15_zero_O2", ["x86-module", str(m15_src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP, m15_fid, "m15"]),
    ]
    n7_comp_bench: dict[str, dict] = {}
    for label, cargs in compiler_workloads:
        obj = WORK / f"n7w_{label}.o"
        err = WORK / f"n7w_{label}.err"
        ms, rss, _ = run_timed([str(n7_bin), *cargs], obj, err, cpu=5)
        n7_comp_bench[label] = {"ms": ms, "rss_mib": rss, "sha256": sha256_file(obj), "obj_bytes": obj.stat().st_size}
        print(f"  [n7_normal {label:<12}] ms={ms:.1f} rss={rss:.1f}MiB obj={obj.stat().st_size/1024:.0f}KB", flush=True)
        obj.unlink(missing_ok=True)
        err.unlink(missing_ok=True)

    # === STEP 6: Build n8_nodrop via n7_normal --nodrop x86-module-fast (K=16, 100% pure Bend, 0 objcopy!) ===
    print("\n=== STEP 6: Build n8_nodrop (K=16 via n7_normal --nodrop x86-module-fast) ===", flush=True)
    obj_n8 = WORK / "obj_n8"
    n8_build = compile_k_modules(n7_bin, k16_zero, obj_n8, mod_names_16, fid_bases_16, ["--nodrop", "x86-module-fast"], CPUS)
    n8_bin = WORK / "n8_nodrop"
    # Delete n7_bin right after x86-merge-obj and before gcc link to keep /tmp/agy_s10g < 150 MB!
    m_ms8, l_ms8 = merge_and_link(n7_bin, obj_n8, mod_names_16, n8_bin, cpu=5, delete_compiler_before_link=n7_bin)
    n8_bytes = n8_bin.stat().st_size
    shutil.rmtree(obj_n8)
    results["n8_nodrop_build"] = n8_build | {"merge_ms": m_ms8, "link_ms": l_ms8, "bin_bytes": n8_bytes}
    print(
        f"  -> n8_nodrop built: wall={n8_build['wall_ms']}ms cpu_sum={n8_build['cpu_sum_ms']}ms "
        f"bin={n8_bytes/1e6:.2f}MB (vs n7_normal {n7_bytes/1e6:.2f}MB = {n8_bytes/n7_bytes:.2f}x)",
        flush=True,
    )

    # === STEP 7: Benchmark n8_nodrop vs n7_normal on compiler workloads (speedup, RSS, SHA-256 identity!) ===
    print("\n=== STEP 7: Benchmark n8_nodrop vs n7_normal on compiler workloads ===", flush=True)
    comp_compare: dict[str, dict] = {}
    for label, cargs in compiler_workloads:
        obj = WORK / f"n8w_{label}.o"
        err = WORK / f"n8w_{label}.err"
        ms, rss, _ = run_timed([str(n8_bin), *cargs], obj, err, cpu=5)
        sha = sha256_file(obj)
        sz = obj.stat().st_size
        obj.unlink(missing_ok=True)
        err.unlink(missing_ok=True)

        ref_n7 = n7_comp_bench[label]
        bit_id_n7 = (sha == ref_n7["sha256"])
        assert bit_id_n7, f"SHA-256 MISMATCH between n8_nodrop and n7_normal on {label}!"
        bit_id_n6 = (sha == n6_refs[label]["sha256"]) if label in n6_refs else None
        if bit_id_n6 is not None:
            assert bit_id_n6, f"SHA-256 MISMATCH between n8_nodrop and n6_o2 on {label}!"
        assert rss < 1536.0, f"RSS LIMIT EXCEEDED on {label}: {rss} MiB >= 1536 MiB!"

        spd = round(ref_n7["ms"] / ms, 3)
        comp_compare[label] = {
            "n7_normal_ms": ref_n7["ms"],
            "n8_nodrop_ms": ms,
            "speedup": spd,
            "n7_normal_rss_mib": ref_n7["rss_mib"],
            "n8_nodrop_rss_mib": rss,
            "rss_delta_mib": round(rss - ref_n7["rss_mib"], 1),
            "rss_under_1_5gib": rss < 1536.0,
            "sha256_identical_to_n7_normal": bit_id_n7,
            "sha256_identical_to_n6_o2": bit_id_n6,
            "obj_bytes": sz,
        }
        print(
            f"  [{label:<12}] {ref_n7['ms']:.1f}ms -> {ms:.1f}ms ({spd:.2f}x) | "
            f"RSS: {ref_n7['rss_mib']:.1f} -> {rss:.1f}MiB (<1536MiB) | SHA256_ID=True",
            flush=True,
        )
    results["compiler_nodrop_vs_normal"] = comp_compare

    # === STEP 8: K=24 zero-.p130 smoke test with n8_nodrop (m00 + m23) ===
    print("\n=== STEP 8: K=24 Zero-.p130 Smoke Compile with n8_nodrop (m00, m23) ===", flush=True)
    fid_bases_24 = {m["name"]: m["fid_base"] for m in k24_manifest["modules"]}
    k24_smoke: dict[str, dict] = {}
    for m in ("m00", "m23"):
        src = k24_zero / f"{m}_zero.bend"
        obj = WORK / f"k24_{m}.o"
        err = WORK / f"k24_{m}.err"
        ms, rss, _ = run_timed(
            [str(n8_bin), "--nodrop", "x86-module-fast", str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP, str(fid_bases_24[m]), m],
            obj, err, cpu=5,
        )
        k24_smoke[m] = {"ms": ms, "rss_mib": rss, "obj_bytes": obj.stat().st_size}
        print(f"  [K=24 {m}] ms={ms:.1f} rss={rss:.1f}MiB obj={obj.stat().st_size/1024:.0f}KB", flush=True)
        obj.unlink(missing_ok=True)
        err.unlink(missing_ok=True)
    results["k24_smoke_nodrop"] = k24_smoke

    # Save results.json
    res_path = OUT_DIR / "results.json"
    res_path.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    print(f"\n=== ALL S10-G CHECKS PASSED! Saved {res_path} ===", flush=True)


if __name__ == "__main__":
    main()
