#!/usr/bin/env python3
"""S10-B Verification & Benchmark Harness (pinned strictly to CPUs 5,6,7).

1. Runs treeshake_w15.py -> /tmp/agy_s10b/compiler_pruned.bend
2. Splits into K=10 acyclic modules -> /tmp/agy_s10b/k10_pruned/
3. Compiles K=10 natively with n6_o2 (x86-iface on CPU 5, x86-module-fast on CPU 6,
   ulimit -s 262144), links /tmp/agy_s10b/n7_pruned via x86-merge-obj + gcc-10.
4. Compares FIDs, .p130 sizes, 1-core CPU sum, and estimated 7-core wall time vs
   unpruned W15-INT baseline (research/agy/w15_final/results.json).
5. Verifies ZERO -O2 regression on 7 benchmarks (compiler_slice -O0/-O2, gameoflife,
   histogram, bst, editdist, expression, terrain): exact .o SHA-256 comparison
   between n6_o2 and n7_pruned + runtime execution & checksum verification!
6. Writes research/agy/s10_campaign/s10b_treeshake/results.json.
"""
from __future__ import annotations

import concurrent.futures
import hashlib
import json
import os
import queue
import re
import subprocess
import sys
import time
from pathlib import Path
from statistics import median

ROOT = Path("/home/ai/bend2_agy")
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
N6_O2 = ROOT / "selfhost/build/agy/wave15-native-mod/n6_o2"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
INPUTS_UP = ROOT / "research/agy/wave4_bench/inputs/upstream"
INPUTS_TUNED = ROOT / "research/agy/wave4_bench/inputs/tuned"
TERRAIN_SRC = ROOT / "bench/runtime/terrain/main.bend"

W15_RESULTS = ROOT / "research/agy/w15_final/results.json"
OUT_DIR = ROOT / "research/agy/s10_campaign/s10b_treeshake"
TMP = Path("/tmp/agy_s10b")

TMPL_1ARG = {
    "kc", "f_choose", "nt_choose", "nt_count_go", "nt_reverse",
    "p151_choose", "nt_count", "nt_append",
}
TMPL_CUSTOM = {
    "p134v_list": "p134v_list(U32, U32.is_eq)",
}

UPSTREAM_EXPECTED = {
    "histogram": 3307081914,
    "gameoflife": 3681094808,
}


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run_native(
    binary: Path,
    args: list[str],
    out_file: Path,
    err_file: Path,
    cpu: int,
    timeout: int = 180,
) -> tuple[float, str]:
    cmd = [
        "bash", "-c",
        'ulimit -s 262144 && exec timeout -k 5 "$1" taskset -c "$2" "$3" "${@:4}"',
        "_", str(timeout), str(cpu), str(binary), *args,
    ]
    t0 = time.perf_counter()
    with out_file.open("wb") as fout, err_file.open("wb") as ferr:
        r = subprocess.run(cmd, stdout=fout, stderr=ferr, cwd=ROOT, timeout=timeout + 15)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = err_file.read_text(encoding="utf-8", errors="replace")
    if r.returncode != 0:
        raise RuntimeError(f"Native failed rc={r.returncode} ({binary.name} {args[:2]}): {stderr[-1000:]}")
    return ms, stderr


def parse_p130(path: Path) -> dict:
    txt = path.read_text(encoding="utf-8")
    lo = ord(txt[0]) - 65536
    hi = ord(txt[1]) - 65536
    slen = lo + hi * 65536
    stamp = txt[2 : 2 + slen]
    pos = 2 + slen
    if pos < len(txt) and ord(txt[pos]) == 10:
        pos += 1
    rn = (ord(txt[pos]) - 65536) + (ord(txt[pos + 1]) - 65536) * 65536
    sn = (ord(txt[pos + 2]) - 65536) + (ord(txt[pos + 3]) - 65536) * 65536
    return {
        "bytes": path.stat().st_size,
        "stamp": stamp,
        "nodes": rn,
        "strings": sn,
        "sha256": sha256(path),
    }


def get_seg_count(obj: Path, mod_name: str) -> int:
    out = subprocess.check_output(["readelf", "-sW", str(obj)], text=True)
    target_arity = f"p111_mod_{mod_name}_p111_fid_arity"
    target_segs = f"p111_mod_{mod_name}_p111_segments"
    seg_from_segs = None
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 8:
            if parts[7] == target_arity:
                sz = int(parts[2], 0)
                if sz > 0:
                    return sz
            elif parts[7] == target_segs:
                sz = int(parts[2], 0)
                if sz > 0:
                    seg_from_segs = sz // 8
    if seg_from_segs is not None:
        return seg_from_segs
    raise RuntimeError(f"Could not find segment count symbol for {mod_name} in {obj}")


def prepare_sources(k_dir: Path, mod_names: list[str], src_dir: Path, compiler_bend: Path) -> dict[str, Path]:
    sys.path.insert(0, str(ROOT / "research/agy/w15_final"))
    from run_w15_n6_o2 import prepare_sources as w15_prepare_sources
    src_paths, _ = w15_prepare_sources(k_dir, mod_names, src_dir, compiler_bend)
    return src_paths


def simulate_7core_pipelined(iface_ms_list: list[float], compile_ms_list: list[float]) -> float:
    """Exact discrete-event simulation of 7-core pipelined build (1 iface core + 6 compile cores)."""
    # iface_ms_list has len K-1 (m00..m08); m00 needs base.p130 (ready at t=0),
    # m_i (i>=1) needs m_{i-1}.p130 (ready at sum(iface_ms_list[:i])).
    ready_t = [0.0]
    acc = 0.0
    for im in iface_ms_list:
        acc += im
        ready_t.append(acc)
    # 6 compile workers
    workers = [0.0] * 6
    for i, cm in enumerate(compile_ms_list):
        r = ready_t[i]
        # pick worker that can start earliest
        best = min(range(6), key=lambda w: max(workers[w], r))
        workers[best] = max(workers[best], r) + cm
    return round(max(workers), 1)


def main() -> None:
    TMP.mkdir(parents=True, exist_ok=True)
    pruned_bend = TMP / "compiler_pruned.bend"
    stats_json = TMP / "treeshake_stats.json"
    k_dir = TMP / "k10_pruned"

    # 1. Run treeshake_w15.py
    print("=== Step 1: Tree-shake compiler.bend ===", flush=True)
    subprocess.run(
        ["timeout", "60", "python3", str(OUT_DIR / "treeshake_w15.py"),
         "--out", str(pruned_bend), "--stats-json", str(stats_json)],
        check=True,
    )
    ts_stats = json.loads(stats_json.read_text())

    # 2. Split K=10
    print("=== Step 2: Split K=10 ===", flush=True)
    subprocess.run(
        ["timeout", "60", "python3", str(ROOT / "research/agy/w15_final/split_k14_w15.py"),
         "--k", "10", "--src", str(pruned_bend), "--out-dir", str(k_dir)],
        check=True,
    )
    manifest = json.loads((k_dir / "manifest.json").read_text())
    mod_names = [m["name"] for m in manifest["modules"]]
    fid_bases = {m["name"]: m["fid_base"] for m in manifest["modules"]}

    src_dir = TMP / "src_exp"
    iface_dir = TMP / "iface"
    obj_dir = TMP / "obj"
    err_dir = TMP / "err"
    for d in (src_dir, iface_dir, obj_dir, err_dir):
        d.mkdir(parents=True, exist_ok=True)

    src_paths = prepare_sources(k_dir, mod_names, src_dir, pruned_bend)

    # 3. 2-core pipelined native compile of K=10 with n6_o2 (CPU 5 = x86-iface, CPU 6 = x86-module-fast)
    print("=== Step 3: Native K=10 -O0 compile with n6_o2 (CPUs 5,6) ===", flush=True)
    ready_q: queue.Queue[tuple[int, str, Path, str] | None] = queue.Queue()
    iface_records = []
    mod_records = []

    def iface_worker():
        cur_carrier = BASE_CARRIER
        cur_stamp = BASE_STAMP
        # m00 is immediately ready with base.p130
        ready_q.put((0, mod_names[0], cur_carrier, cur_stamp))
        for i, m in enumerate(mod_names[:-1]):
            out_p130 = iface_dir / f"{m}.p130"
            err_f = err_dir / f"iface_{m}.err"
            ms, _ = run_native(
                N6_O2,
                ["x86-iface", str(src_paths[m]), str(BASE_FILE), "cache", str(cur_carrier), cur_stamp],
                out_p130, err_f, cpu=5, timeout=180,
            )
            info = parse_p130(out_p130)
            rec = {"name": m, "iface_ms": ms, "bytes": info["bytes"], "nodes": info["nodes"], "strings": info["strings"]}
            iface_records.append(rec)
            print(f"  [iface CPU5] {m}: {ms:7.1f} ms | {info['bytes']//1024:4d} KB | nodes={info['nodes']:6d} strs={info['strings']:5d}", flush=True)
            cur_carrier = out_p130
            cur_stamp = info["stamp"]
            ready_q.put((i + 1, mod_names[i + 1], cur_carrier, cur_stamp))
        ready_q.put(None)

    def compile_worker():
        while True:
            item = ready_q.get()
            if item is None:
                break
            i, m, carrier, stamp = item
            out_o = obj_dir / f"{m}.o"
            err_f = err_dir / f"mod_{m}.err"
            ms, _ = run_native(
                N6_O2,
                ["x86-module-fast", str(src_paths[m]), str(BASE_FILE), "cache", str(carrier), stamp, str(fid_bases[m]), m],
                out_o, err_f, cpu=6, timeout=180,
            )
            segs = get_seg_count(out_o, m)
            rec = {"name": m, "compile_ms": ms, "obj_bytes": out_o.stat().st_size, "segs": segs, "fid_base": fid_bases[m]}
            mod_records.append(rec)
            print(f"  [mod-O0 CPU6] {m}: {ms:7.1f} ms | segs={segs:5d} | {out_o.stat().st_size//1024:4d} KB", flush=True)

    t_build0 = time.perf_counter()
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as ex:
        f_if = ex.submit(iface_worker)
        f_cg = ex.submit(compile_worker)
        f_if.result()
        f_cg.result()
    build_2c_ms = round((time.perf_counter() - t_build0) * 1000.0, 1)

    total_segs = sum(r["segs"] for r in mod_records)
    iface_sum_ms = round(sum(r["iface_ms"] for r in iface_records), 1)
    mod_sum_ms = round(sum(r["compile_ms"] for r in mod_records), 1)
    cpu_sum_ms = round(iface_sum_ms + mod_sum_ms, 1)
    est_7c_compile_ms = simulate_7core_pipelined(
        [r["iface_ms"] for r in iface_records],
        [r["compile_ms"] for r in mod_records],
    )

    # 4. Link n7_pruned via x86-merge-obj + gcc-10
    print("=== Step 4: Native x86-merge-obj + gcc-10 link ===", flush=True)
    entry_mod = mod_names[-1]
    ordered = [entry_mod] + mod_names[:-1]
    merge_o = obj_dir / "merge.o"
    n7_pruned = TMP / "n7_pruned"
    merge_ms, _ = run_native(
        N6_O2, ["x86-merge-obj", entry_mod] + ordered, merge_o, err_dir / "merge.err", cpu=5, timeout=60,
    )
    t_lk = time.perf_counter()
    subprocess.run(
        ["timeout", "60", "taskset", "-c", "5", CC, "-O2", "-no-pie",
         str(merge_o), *[str(obj_dir / f"{m}.o") for m in ordered], str(RT),
         "-o", str(n7_pruned), "-lm", "-lpthread"],
        check=True,
    )
    link_ms = round((time.perf_counter() - t_lk) * 1000.0, 1)
    n7_bytes = n7_pruned.stat().st_size
    est_7c_e2e_ms = round(est_7c_compile_ms + merge_ms + link_ms, 1)

    print(f"  n7_pruned linked: {n7_bytes:,} B | total_segs={total_segs}/65532 | iface_sum={iface_sum_ms/1000:.2f}s | mod_sum={mod_sum_ms/1000:.2f}s | 1c_sum={cpu_sum_ms/1000:.2f}s | est_7c_e2e={est_7c_e2e_ms/1000:.2f}s", flush=True)

    # Compare vs W15-INT baseline
    w15 = json.loads(W15_RESULTS.read_text())
    s2a = w15["stage2a_zero_cache_cold"]
    base_segs = s2a["total_segs"]
    base_iface_ms = s2a["iface_wall_ms"]
    base_mod_sum_ms = round(sum(r.get("compile_ms", r.get("ms", 0.0)) for r in s2a["mod_records"]), 1)
    base_cpu_sum_ms = round(base_iface_ms + base_mod_sum_ms, 1)
    base_7c_e2e_ms = s2a["e2e_ms"]

    # 5. Verify CLI modes & ZERO -O2 regression on 7 benchmarks (n6_o2 vs n7_pruned)
    print("=== Step 5: Verify ZERO -O2 regression (n6_o2 vs n7_pruned on CPU 5) ===", flush=True)
    bench_dir = TMP / "bench"
    bench_dir.mkdir(parents=True, exist_ok=True)
    up_spec = json.loads((INPUTS_UP / "suite.json").read_text())

    def prep_up(fam: str) -> Path:
        desc = up_spec[fam]
        txt = (INPUTS_UP / fam / "main.bend").read_text()
        for bname, old, new in zip(desc["bendKnobs"], desc["upstream"], desc["medium"]):
            txt, n = re.subn(rf"(^def {bname}\(\) -> Nat:\n  ){old}n$", rf"\g<1>{new}n", txt, flags=re.M)
            assert n == 1
        p = bench_dir / f"{fam}.bend"
        p.write_text(txt, encoding="utf-8")
        return p

    def prep_tuned(fam: str) -> Path:
        k = (INPUTS_TUNED / "kernels" / f"{fam}.bend").read_text()
        d = (INPUTS_TUNED / "driver.bend").read_text()
        p = bench_dir / f"{fam}.bend"
        p.write_text(k.rstrip() + "\n\n" + d, encoding="utf-8")
        return p

    bench_cases = [
        ("compiler_slice_O0", SLICE, "x86-object-fast", "34", []),
        ("compiler_slice_O2", SLICE, "x86-object", "34", []),
        ("gameoflife", prep_up("gameoflife"), "x86-object", str(UPSTREAM_EXPECTED["gameoflife"]), RTS_ARGS),
        ("histogram", prep_up("histogram"), "x86-object", str(UPSTREAM_EXPECTED["histogram"]), RTS_ARGS),
        ("bst", prep_tuned("bst"), "x86-object", None, ["64", "17", "100"]),
        ("editdist", prep_tuned("editdist"), "x86-object", None, ["2", "0", "10"]),
        ("expression", prep_tuned("expression"), "x86-object", None, ["128", "123", "100"]),
        ("terrain", TERRAIN_SRC, "x86-object", None, None), # compile-only .o identity check (terrain run takes ~15s)
    ]

    bench_results = []
    all_bit_identical = True
    for name, bsrc, mode, expected_out, run_args in bench_cases:
        o_n6 = bench_dir / f"{name}_n6.o"
        o_n7 = bench_dir / f"{name}_n7.o"
        ms_n6, _ = run_native(N6_O2, [mode, str(bsrc), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], o_n6, bench_dir / f"{name}_n6.err", cpu=5, timeout=120)
        ms_n7, _ = run_native(n7_pruned, [mode, str(bsrc), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], o_n7, bench_dir / f"{name}_n7.err", cpu=5, timeout=120)
        h_n6 = sha256(o_n6)
        h_n7 = sha256(o_n7)
        same_o = (h_n6 == h_n7)
        if not same_o:
            all_bit_identical = False

        run_info = {}
        if run_args is not None:
            exe = bench_dir / f"{name}_n7.exe"
            subprocess.run(
                ["timeout", "30", "taskset", "-c", "5", CC, "-O2", "-no-pie", str(o_n7), str(RT), "-lm", "-pthread", "-o", str(exe)],
                check=True,
            )
            times = []
            last_out = ""
            for _ in range(3):
                tr0 = time.perf_counter()
                r = subprocess.run(["timeout", "60", "taskset", "-c", "5", str(exe)] + run_args, capture_output=True, text=True, check=True)
                times.append(round((time.perf_counter() - tr0) * 1000.0, 2))
                last_out = r.stdout.strip().splitlines()[-1].strip()
            if expected_out is not None:
                assert last_out == expected_out, f"{name}: got {last_out!r} != {expected_out!r}"
            run_info = {"out": last_out, "median_ms": round(median(times), 2), "runs_ms": times}
            exe.unlink(missing_ok=True)

        rec = {
            "name": name,
            "mode": mode,
            "n6_compile_ms": ms_n6,
            "n7_pruned_compile_ms": ms_n7,
            "n6_obj_bytes": o_n6.stat().st_size,
            "n7_obj_bytes": o_n7.stat().st_size,
            "obj_bit_identical": same_o,
            "sha256": h_n7,
            "run": run_info,
        }
        bench_results.append(rec)
        print(f"  [{name:<18}] .o identical={same_o} | size={o_n7.stat().st_size:7,d} B | n6={ms_n6:6.1f}ms n7={ms_n7:6.1f}ms | run={run_info}", flush=True)
        o_n6.unlink(missing_ok=True)
        o_n7.unlink(missing_ok=True)

    # Also test --trace and x86-iface on n7_pruned
    print("=== Step 6: Smoke-test --trace & x86-iface on n7_pruned ===", flush=True)
    tr_o = bench_dir / "trace_slice.o"
    tr_err = bench_dir / "trace_slice.err"
    tr_ms, tr_stderr = run_native(n7_pruned, ["--trace", "x86-object-fast", str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], tr_o, tr_err, cpu=5, timeout=60)
    assert "stage=p86_plan" in tr_stderr and "stage=x187_elf" in tr_stderr, f"Missing trace stages: {tr_stderr}"
    if_p130 = bench_dir / "slice.p130"
    if_ms, _ = run_native(n7_pruned, ["x86-iface", str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], if_p130, bench_dir / "slice_if.err", cpu=5, timeout=60)
    if_info = parse_p130(if_p130)
    tr_o.unlink(missing_ok=True)
    if_p130.unlink(missing_ok=True)
    print(f"  --trace OK ({tr_ms} ms) | x86-iface OK ({if_ms} ms, {if_info['bytes']} B)", flush=True)

    results = {
        "treeshake": ts_stats,
        "self_compile_k10_o0": {
            "total_segs": total_segs,
            "fid_headroom": 65532 - total_segs,
            "iface_sum_ms": iface_sum_ms,
            "mod_sum_ms": mod_sum_ms,
            "cpu_sum_1core_ms": cpu_sum_ms,
            "build_2core_wall_ms": build_2c_ms,
            "est_7core_compile_ms": est_7c_compile_ms,
            "merge_ms": merge_ms,
            "link_ms": link_ms,
            "est_7core_e2e_ms": est_7c_e2e_ms,
            "n7_pruned_bytes": n7_bytes,
            "iface_records": iface_records,
            "mod_records": mod_records,
        },
        "baseline_w15_unpruned": {
            "total_segs": base_segs,
            "fid_headroom": 65532 - base_segs,
            "iface_sum_ms": base_iface_ms,
            "mod_sum_ms": base_mod_sum_ms,
            "cpu_sum_1core_ms": base_cpu_sum_ms,
            "actual_7core_e2e_ms": base_7c_e2e_ms,
            "n7_cold_bytes": s2a["n7_cold_bytes"],
        },
        "delta_vs_unpruned": {
            "segs": base_segs - total_segs,
            "segs_pct": round((base_segs - total_segs) / base_segs * 100.0, 2),
            "iface_sum_ms": round(base_iface_ms - iface_sum_ms, 1),
            "iface_sum_pct": round((base_iface_ms - iface_sum_ms) / base_iface_ms * 100.0, 2),
            "mod_sum_ms": round(base_mod_sum_ms - mod_sum_ms, 1),
            "mod_sum_pct": round((base_mod_sum_ms - mod_sum_ms) / base_mod_sum_ms * 100.0, 2),
            "cpu_sum_1core_ms": round(base_cpu_sum_ms - cpu_sum_ms, 1),
            "cpu_sum_1core_pct": round((base_cpu_sum_ms - cpu_sum_ms) / base_cpu_sum_ms * 100.0, 2),
            "est_7core_e2e_ms": round(base_7c_e2e_ms - est_7c_e2e_ms, 1),
            "est_7core_e2e_pct": round((base_7c_e2e_ms - est_7c_e2e_ms) / base_7c_e2e_ms * 100.0, 2),
            "binary_bytes": s2a["n7_cold_bytes"] - n7_bytes,
        },
        "o2_regression_gate": {
            "all_obj_bit_identical": all_bit_identical,
            "benchmarks": bench_results,
        },
        "cli_smoke": {
            "trace_ms": tr_ms,
            "iface_ms": if_ms,
            "iface_bytes": if_info["bytes"],
        },
    }

    (OUT_DIR / "results.json").write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    print(f"\n=== ALL DONE -> {OUT_DIR / 'results.json'} (all_obj_bit_identical={all_bit_identical}) ===", flush=True)


if __name__ == "__main__":
    main()
