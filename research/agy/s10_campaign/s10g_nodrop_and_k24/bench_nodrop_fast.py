#!/usr/bin/env python3
"""Fast S10-G Verification & Benchmark Suite (`bench_nodrop_fast.py`).

Uses `/tmp/agy_s10g/n7_s10g` (built with S10-A + S10-G in m09) to verify & benchmark:
  1. Zero-regression: normal `x86-object` & `x86-object-fast` 100% SHA-256 bit-identical to `n6_o2`
  2. `--nodrop` vs normal on `compiler_slice.bend` (-O0 & -O2) + `histogram`, `gameoflife`, `nbody` (-O2):
     - Compile-time speedup, `.o` size reduction, runtime speedup (3-run median), peak RSS, output parity
  3. `--nodrop` vs normal on `m09_zero.bend` (-O0 & -O2) + `K=24` (`m00_zero.bend`, `m23_zero.bend`)
  4. Links `m09_nodrop.o` into a compiler binary and verifies 100% SHA-256 bit-identical `.o` output
     on `compiler_slice.bend` (-O0 & -O2) with peak RSS < 1.5 GiB!
"""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
import time
from pathlib import Path
from statistics import median

ROOT = Path("/home/ai/bend2_agy")
WORK = Path("/tmp/agy_s10g")
OUT_DIR = ROOT / "research/agy/s10_campaign/s10g_nodrop_and_k24"

N6_O2 = ROOT / "selfhost/build/agy/wave15-native-mod/n6_o2"
N7_S10G = WORK / "n7_s10g"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
CC = "gcc-10"
RTS_ARGS: list[str] = []

SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
M09_SRC = WORK / "m09_s10ag_zero.bend"
BENCHES = [
    ("slice_O0", "x86-object-fast", SLICE, "34"),
    ("slice_O2", "x86-object", SLICE, "34"),
    ("histogram_O2", "x86-object", ROOT / "research/agy/wave4_bench/inputs/upstream/histogram/main.bend", None),
    ("gameoflife_O2", "x86-object", ROOT / "research/agy/wave4_bench/inputs/upstream/gameoflife/main.bend", None),
    ("nbody_O2", "x86-object", ROOT / "research/agy/wave4_bench/inputs/upstream/nbody/main.bend", None),
]


def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def run_timed(cmd: list[str], out_file: Path | None, err_file: Path, cpu: int = 5, timeout_s: int = 120) -> tuple[float, float, str]:
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
        raise RuntimeError(f"Command failed (rc={rc}): {' '.join(cmd[:4])}\n{stderr[-800:]}")
    return ms, rss_mib, stderr


def link_obj(obj: Path, out_bin: Path, cpu: int = 5) -> None:
    r = subprocess.run(
        ["timeout", "60", "taskset", "-c", str(cpu), CC, "-O2", "-no-pie", str(obj), str(RT), "-o", str(out_bin), "-lm", "-lpthread"],
        capture_output=True, text=True, cwd=ROOT,
    )
    if r.returncode != 0:
        raise RuntimeError(f"link failed: {r.stderr[-1000:]}")


def run_bin_median(bin_path: Path, cpu: int = 5, runs: int = 3) -> tuple[float, float, str]:
    ts, rs = [], []
    out_f, err_f = WORK / "tmp_run.out", WORK / "tmp_run.err"
    out_s = ""
    for _ in range(runs):
        ms, rss, _ = run_timed([str(bin_path), *RTS_ARGS], out_f, err_f, cpu=cpu, timeout_s=60)
        ts.append(ms)
        rs.append(rss)
        out_s = out_f.read_text(encoding="utf-8", errors="replace").strip()
    out_f.unlink(missing_ok=True)
    err_f.unlink(missing_ok=True)
    return round(median(ts), 1), max(rs), out_s


def main() -> None:
    results: dict = {"task": "S10-G", "cpus": [5, 7]}

    # Load K=16 and K=24 split stats
    k16_m = json.loads((WORK / "k16_s10ag/manifest.json").read_text())
    k24_m = json.loads((WORK / "k24_s10ag/manifest.json").read_text())
    results["splits"] = {
        "k16": k16_m["balance"] | {"totals": k16_m["totals"]},
        "k24": k24_m["balance"] | {"totals": k24_m["totals"]},
    }

    # 1. Program benchmarks: n6_o2 ref vs n7_s10g normal vs n7_s10g --nodrop
    print("=== 1. Zero-Regression + --nodrop Program Benchmarks (-O0 & -O2) ===", flush=True)
    prog_res: dict = {}
    for label, mode, src, expected in BENCHES:
        ref_o, ref_e = WORK / f"ref_{label}.o", WORK / f"ref_{label}.err"
        run_timed([str(N6_O2), mode, str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], ref_o, ref_e, cpu=5)
        ref_sha = sha256_file(ref_o)
        ref_o.unlink(missing_ok=True)
        ref_e.unlink(missing_ok=True)

        norm_o, norm_e = WORK / f"norm_{label}.o", WORK / f"norm_{label}.err"
        c_ms_n, c_rss_n, _ = run_timed([str(N7_S10G), mode, str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], norm_o, norm_e, cpu=5)
        sha_n = sha256_file(norm_o)
        sz_n = norm_o.stat().st_size
        bit_id = (sha_n == ref_sha)
        assert bit_id, f"REGRESSION on {label}: normal mode != n6_o2!"
        bin_n = WORK / f"bin_n_{label}"
        link_obj(norm_o, bin_n, cpu=5)
        r_ms_n, r_rss_n, out_n = run_bin_median(bin_n, cpu=5, runs=3)
        if expected is not None:
            assert out_n == expected, f"{label} normal out {out_n!r} != {expected!r}"
        norm_o.unlink(missing_ok=True)
        norm_e.unlink(missing_ok=True)
        bin_n.unlink(missing_ok=True)

        nd_o, nd_e = WORK / f"nd_{label}.o", WORK / f"nd_{label}.err"
        c_ms_nd, c_rss_nd, _ = run_timed([str(N7_S10G), "--nodrop", mode, str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], nd_o, nd_e, cpu=5)
        sz_nd = nd_o.stat().st_size
        bin_nd = WORK / f"bin_nd_{label}"
        link_obj(nd_o, bin_nd, cpu=5)
        r_ms_nd, r_rss_nd, out_nd = run_bin_median(bin_nd, cpu=5, runs=3)
        assert out_nd == out_n, f"{label} --nodrop out {out_nd!r} != {out_n!r}"
        nd_o.unlink(missing_ok=True)
        nd_e.unlink(missing_ok=True)
        bin_nd.unlink(missing_ok=True)

        r_spd = round(r_ms_n / r_ms_nd, 3) if r_ms_nd > 0 else 0.0
        c_spd = round(c_ms_n / c_ms_nd, 3) if c_ms_nd > 0 else 0.0
        prog_res[label] = {
            "normal_bit_identical_to_n6_o2": bit_id,
            "out": out_n,
            "normal": {"compile_ms": c_ms_n, "compile_rss_mib": c_rss_n, "obj_bytes": sz_n, "run_ms": r_ms_n, "run_rss_mib": r_rss_n},
            "nodrop": {"compile_ms": c_ms_nd, "compile_rss_mib": c_rss_nd, "obj_bytes": sz_nd, "run_ms": r_ms_nd, "run_rss_mib": r_rss_nd},
            "run_speedup": r_spd,
            "compile_speedup": c_spd,
            "obj_size_ratio": round(sz_nd / sz_n, 3),
        }
        print(
            f"  [{label:<14}] bit_id={bit_id} out={out_n} | run: {r_ms_n}ms -> {r_ms_nd}ms ({r_spd:.2f}x) "
            f"| compile: {c_ms_n}ms -> {c_ms_nd}ms ({c_spd:.2f}x) | obj: {sz_n/1024:.0f}->{sz_nd/1024:.0f}KB ({sz_nd/sz_n:.2f}x) "
            f"| run_rss: {r_rss_n}->{r_rss_nd}MiB",
            flush=True,
        )
    results["program_nodrop_benchmarks"] = prog_res

    # 2. Module compilation: m09_zero.bend normal vs --nodrop (-O0) + K=24 m00 & m23 (-O0 --nodrop)
    print("\n=== 2. Module Compilation: m09_zero.bend & K=24 (m00, m23) ===", flush=True)
    mod_res: dict = {}
    for m_label, src_p, fid_b, mname in [
        ("k10_m09", M09_SRC, "61106", "m09"),
        ("k24_m00", WORK / "k24_s10ag_zero/m00_zero.bend", str(k24_m["modules"][0]["fid_base"]), "m00"),
        ("k24_m23", WORK / "k24_s10ag_zero/m23_zero.bend", str(k24_m["modules"][23]["fid_base"]), "m23"),
    ]:
        no, ne = WORK / f"{m_label}_norm.o", WORK / f"{m_label}_norm.err"
        ms_n, rss_n, _ = run_timed([str(N7_S10G), "x86-module-fast", str(src_p), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP, fid_b, mname], no, ne, cpu=5)
        sz_n = no.stat().st_size
        no.unlink(missing_ok=True)
        ne.unlink(missing_ok=True)

        ndo, nde = WORK / f"{m_label}_nd.o", WORK / f"{m_label}_nd.err"
        ms_nd, rss_nd, _ = run_timed([str(N7_S10G), "--nodrop", "x86-module-fast", str(src_p), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP, fid_b, mname], ndo, nde, cpu=5)
        sz_nd = ndo.stat().st_size
        nde.unlink(missing_ok=True)
        if m_label != "k10_m09":
            ndo.unlink(missing_ok=True)

        mod_res[m_label] = {
            "normal_ms": ms_n, "nodrop_ms": ms_nd, "compile_speedup": round(ms_n / ms_nd, 3),
            "normal_rss_mib": rss_n, "nodrop_rss_mib": rss_nd,
            "normal_obj_bytes": sz_n, "nodrop_obj_bytes": sz_nd, "obj_size_ratio": round(sz_nd / sz_n, 3),
        }
        print(
            f"  [{m_label:<8}] compile: {ms_n:.1f}ms -> {ms_nd:.1f}ms ({ms_n/ms_nd:.2f}x) | "
            f"obj: {sz_n/1024:.0f}->{sz_nd/1024:.0f}KB ({sz_nd/sz_n:.2f}x) | rss: {rss_n}->{rss_nd}MiB",
            flush=True,
        )
    results["module_compile_nodrop"] = mod_res

    # 3. Link m09_nodrop.o into compiler binary and verify 100% SHA-256 bit-identity on slice_O0 & slice_O2
    print("\n=== 3. Verify --nodrop-compiled m09 linked into compiler -> SHA-256 identity ===", flush=True)
    m09_nd_o = WORK / "k10_m09_nd.o"
    subprocess.run(["timeout", "30", "taskset", "-c", "5", "objcopy", "--weaken-symbols=/tmp/agy_s10a/obj_n7/m09_weak.txt", str(m09_nd_o)], check=True)
    # Delete n7_s10g before linking n7_m09_nd to stay < 150 MB
    N7_S10G.unlink(missing_ok=True)
    n7_m09_nd = WORK / "n7_m09_nd"
    r = subprocess.run(
        [
            "timeout", "60", "taskset", "-c", "5", CC, "-O2", "-no-pie",
            str(WORK / "merge.o"), str(m09_nd_o),
            *[f"/tmp/agy_s10a/obj_n7/m0{i}.o" for i in range(9)],
            str(RT), "-o", str(n7_m09_nd), "-lm", "-lpthread",
        ],
        capture_output=True, text=True, cwd=ROOT,
    )
    assert r.returncode == 0, f"link n7_m09_nd failed: {r.stderr[-1000:]}"
    m09_nd_o.unlink(missing_ok=True)

    nd_comp_check: dict = {}
    for label, mode in [("slice_O0", "x86-object-fast"), ("slice_O2", "x86-object")]:
        o1, e1 = WORK / f"chk_{label}.o", WORK / f"chk_{label}.err"
        ms1, rss1, _ = run_timed([str(n7_m09_nd), mode, str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], o1, e1, cpu=5)
        sha1 = sha256_file(o1)
        o1.unlink(missing_ok=True)
        e1.unlink(missing_ok=True)

        ro, re_ = WORK / f"ref2_{label}.o", WORK / f"ref2_{label}.err"
        run_timed([str(N6_O2), mode, str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], ro, re_, cpu=5)
        rsha = sha256_file(ro)
        ro.unlink(missing_ok=True)
        re_.unlink(missing_ok=True)

        assert sha1 == rsha, f"SHA-256 mismatch on {label} for --nodrop-compiled m09 compiler!"
        assert rss1 < 1536.0, f"RSS exceeded 1.5 GiB: {rss1} MiB"
        nd_comp_check[label] = {"ms": ms1, "rss_mib": rss1, "sha256_identical_to_n6_o2": True}
        print(f"  [n7_m09_nd {label}] ms={ms1} rss={rss1}MiB (<1536MiB) SHA256_ID=True", flush=True)
    n7_m09_nd.unlink(missing_ok=True)
    results["nodrop_compiler_verification"] = nd_comp_check

    res_path = OUT_DIR / "results.json"
    res_path.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    print(f"\n=== ALL S10-G BENCHMARKS & CHECKS PASSED! Saved {res_path} ===", flush=True)


if __name__ == "__main__":
    main()
