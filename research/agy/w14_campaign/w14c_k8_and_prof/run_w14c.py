#!/usr/bin/env python3
"""W14-C: Native n5_o2 m11 Zero-Loss Profile (CPU 2) + K=8 True-Cold Pipelining Experiment (CPUs 2, 3)."""
from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import heapq
import json
import os
import queue
import re
import resource
import subprocess
import sys
import time
from collections import deque
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
N5_O2 = ROOT / "selfhost/build/agy/wave13-native-mod/n5_o2"
K14_DIR = ROOT / "research/agy/w10_mod_bend/k14_wave13"
K8_DIR = ROOT / "research/agy/w10_mod_bend/k8_wave13"
CACHE_W13 = Path("/tmp/agy_k14_w13_cache")
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
ANALYZE_PY = ROOT / "selfhost/tools/profiler/analyze.py"

OUT_DIR = ROOT / "research/agy/w14_campaign/w14c_k8_and_prof"
RESULTS_JSON = OUT_DIR / "results.json"

TMP = Path("/tmp/agy_w14c")
PROF_DIR = TMP / "prof"
LIB_SAMPLE = PROF_DIR / "libsample.so"
K8_TMP = TMP / "k8"
K8_SRC = K8_TMP / "src"
K8_IFACE = K8_TMP / "iface"
K8_OBJ = K8_TMP / "obj"
K8_LOGS = K8_TMP / "logs"
K8_SMOKE = K8_TMP / "smoke"

ALLOWED_CPUS = (2, 3)
K8_MODS = [f"m{i:02d}" for i in range(8)]
FID_LIMIT = 65532
NODE_LIMIT = 1048576
STR_LIMIT = 65536

TMPL_1ARG = {
    "kc", "f_choose", "nt_choose", "nt_count_go", "nt_reverse",
    "p151_choose", "nt_count", "nt_append",
}
TMPL_CUSTOM = {
    "p134v_list": "p134v_list(U32, U32.is_eq)",
}


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


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


def parse_trace_stages(stderr: str) -> dict[str, float]:
    stages: dict[str, float] = {}
    for line in stderr.splitlines():
        m = re.search(r"stage=([A-Za-z0-9_.-]+)\s+ms=([0-9.]+)", line)
        if m:
            stages[m.group(1)] = float(m.group(2))
        else:
            m2 = re.search(r"stage=(x187_priv_done|x187_pub_done)\s+count=(\d+)\s+elapsed=([0-9.]+)ms", line)
            if m2:
                stages[m2.group(1) + "_elapsed"] = float(m2.group(3))
            m3 = re.search(r"total_ms=([0-9.]+)ms", line)
            if m3:
                stages["total_ms"] = float(m3.group(1))
    if "x187_priv_done_elapsed" in stages and "x198pw_plan" in stages:
        pre = (
            stages.get("read", 0.0)
            + stages.get("prep", 0.0)
            + stages.get("p86_plan", 0.0)
            + stages.get("x198pw_plan", 0.0)
        )
        stages["x187_priv_est"] = round(stages["x187_priv_done_elapsed"] - pre, 1)
    if "x187_pub_done_elapsed" in stages and "x187_priv_done_elapsed" in stages:
        stages["x187_pub_est"] = round(stages["x187_pub_done_elapsed"] - stages["x187_priv_done_elapsed"], 1)
    return stages


def run_native(
    binary: Path,
    args: list[str],
    out_file: Path,
    err_file: Path,
    cpu: int,
    timeout: int = 180,
    extra_env: dict[str, str] | None = None,
) -> tuple[float, str, float]:
    assert cpu in ALLOWED_CPUS, f"Disallowed CPU {cpu}"
    if extra_env:
        env_args = ["env", *[f"{k}={v}" for k, v in extra_env.items()]]
        cmd = [
            "timeout", str(timeout),
            "bash", "-c", 'ulimit -s 262144 && exec taskset -c "$1" "${@:2}"',
            "_", str(cpu), *env_args, str(binary), *args,
        ]
    else:
        cmd = [
            "timeout", str(timeout),
            "bash", "-c", 'ulimit -s 262144 && exec taskset -c "$1" "$2" "${@:3}"',
            "_", str(cpu), str(binary), *args,
        ]
    t0 = time.perf_counter()
    with out_file.open("wb") as of, err_file.open("wb") as ef:
        p = subprocess.Popen(cmd, stdout=of, stderr=ef, cwd=ROOT)
        _, status, ru = os.wait4(p.pid, 0)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    cpu_s = round(ru.ru_utime + ru.ru_stime, 4)
    rc = os.waitstatus_to_exitcode(status)
    stderr = err_file.read_text(encoding="utf-8", errors="replace").strip()
    if rc != 0:
        raise RuntimeError(f"native {binary.name} failed (rc={rc}, cpu={cpu}) args={args[:4]}: {stderr[-800:]}")
    return ms, stderr, cpu_s


def load_results() -> dict:
    if RESULTS_JSON.exists():
        return json.loads(RESULTS_JSON.read_text(encoding="utf-8"))
    return {}


def save_results(res: dict) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    RESULTS_JSON.write_text(json.dumps(res, indent=2) + "\n", encoding="utf-8")


def run_part1_m11_profile() -> None:
    print("=== PART 1: Zero-Loss Native Profile of n5_o2 Compiling m11 on CPU 2 ===", flush=True)
    PROF_DIR.mkdir(parents=True, exist_ok=True)
    m11_src = PROF_DIR / "m11_exp.bend"
    m11_src.write_text("import Base\n" + (K14_DIR / "m11.bend").read_text(encoding="utf-8"), encoding="utf-8")

    m10_p130 = CACHE_W13 / "iface/m10.p130"
    m10_info = parse_p130(m10_p130)
    m10_stamp = m10_info["stamp"]
    fid_base = 61881

    # 1A: Clean un-instrumented run on CPU 2
    clean_o = PROF_DIR / "m11_clean.o"
    clean_err = PROF_DIR / "m11_clean.err"
    clean_ms, clean_stderr, clean_cpu_s = run_native(
        N5_O2,
        ["--trace", "x86-module-fast", str(m11_src), str(BASE_FILE), "cache", str(m10_p130), m10_stamp, str(fid_base), "m11"],
        out_file=clean_o,
        err_file=clean_err,
        cpu=2,
        timeout=180,
    )
    clean_stages = parse_trace_stages(clean_stderr)
    clean_sha = sha256(clean_o)
    cached_m11 = CACHE_W13 / "obj_o0/m11.o"
    matches_cache = cached_m11.exists() and (clean_sha == sha256(cached_m11))
    print(
        f"  [m11 CLEAN cpu=2] wall={clean_ms} ms | cpu={clean_cpu_s} s | bytes={clean_o.stat().st_size:,} "
        f"| eq_cache={matches_cache} | stages={clean_stages}",
        flush=True,
    )

    # 1B: Profiled run on CPU 2 with sample-threads.c (period=1000 us -> ~19k samples < 25k cap)
    prof_o = PROF_DIR / "m11_prof.o"
    prof_err = PROF_DIR / "m11_prof.err"
    samples_file = PROF_DIR / "m11.samples"
    if samples_file.exists():
        samples_file.unlink()
    prof_ms, prof_stderr, prof_cpu_s = run_native(
        N5_O2,
        ["--trace", "x86-module-fast", str(m11_src), str(BASE_FILE), "cache", str(m10_p130), m10_stamp, str(fid_base), "m11"],
        out_file=prof_o,
        err_file=prof_err,
        cpu=2,
        timeout=180,
        extra_env={
            "LD_PRELOAD": str(LIB_SAMPLE),
            "BEND_SAMPLE_OUT": str(samples_file),
            "BEND_SAMPLE_PERIOD_US": "5000",
        },
    )
    prof_sha = sha256(prof_o)
    assert prof_sha == clean_sha, "Profiled m11.o differs from clean m11.o!"
    print(
        f"  [m11 PROF  cpu=2] wall={prof_ms} ms | cpu={prof_cpu_s} s | samples_bytes={samples_file.stat().st_size:,} "
        f"| bit_identical=True",
        flush=True,
    )

    # 1C: Offline analyze.py
    analysis_out = OUT_DIR / "m11_profile.json"
    if analysis_out.exists():
        analysis_out.unlink()
    r = subprocess.run(
        [
            "python3", str(ANALYZE_PY),
            "--samples", str(samples_file),
            "--binary", str(N5_O2),
            "--output", str(analysis_out),
            "--clean-cpu-seconds", str(clean_cpu_s),
        ],
        capture_output=True, text=True, check=True, cwd=ROOT,
    )
    prof_data = json.loads(analysis_out.read_text(encoding="utf-8"))
    qual = prof_data["quality"]
    print(
        f"  [m11 ANALYZE] samples={prof_data['header']['samples']} | dropped={prof_data['header']['dropped']} "
        f"| overruns={prof_data['header']['overruns']} | zero_loss={qual['zero_loss']} | usable={qual['usable_for_process_cpu_attribution']}",
        flush=True,
    )
    print("  Groups:", flush=True)
    for g in prof_data["groups"]:
        print(f"    {g['name']:<24} {g['percent']:6.2f}% ({g['samples']:5d} samples, {g.get('estimated_clean_cpu_seconds', 0):.3f}s)", flush=True)
    print("  Top 20 leaf functions:", flush=True)
    for idx, fn in enumerate(prof_data["top_functions"][:20], 1):
        print(
            f"    {idx:2d}. {fn['percent']:6.2f}% ({fn['samples']:4d}, {fn.get('estimated_clean_cpu_seconds', 0):.3f}s) "
            f"{fn['decoded']}",
            flush=True,
        )

    res = load_results()
    res["part1_m11_profile"] = {
        "cpu": 2,
        "m10_p130_bytes": m10_info["bytes"],
        "m10_p130_nodes": m10_info["nodes"],
        "m10_p130_strings": m10_info["strings"],
        "m10_stamp": m10_stamp,
        "clean_wall_ms": clean_ms,
        "clean_cpu_s": clean_cpu_s,
        "clean_obj_bytes": clean_o.stat().st_size,
        "clean_obj_sha256": clean_sha,
        "matches_w13_cache": matches_cache,
        "clean_trace_stages": clean_stages,
        "clean_trace_lines": [ln for ln in clean_stderr.splitlines() if ln.strip()],
        "prof_wall_ms": prof_ms,
        "prof_cpu_s": prof_cpu_s,
        "prof_overhead_pct": round(100.0 * (prof_ms - clean_ms) / clean_ms, 2),
        "samples": prof_data["header"]["samples"],
        "dropped": prof_data["header"]["dropped"],
        "overruns": prof_data["header"]["overruns"],
        "quality": qual,
        "groups": prof_data["groups"],
        "top_25_functions": prof_data["top_functions"][:25],
        "profile_json_path": str(analysis_out),
    }
    save_results(res)


def compute_reachable_names() -> set[str]:
    sys.path.insert(0, str(OUT_DIR))
    from split_k8_w13 import parse_compiler_bend, strip_strings_and_comments, IDENT_RE
    _, _, decls = parse_compiler_bend(ROOT / "selfhost/build/agy/wave13_unified/compiler.bend")
    name_to_ids: dict[str, list[int]] = {}
    for idx, d in enumerate(decls):
        name_to_ids.setdefault(d["name"], []).append(idx)
    adj: list[list[int]] = [[] for _ in range(len(decls))]
    for u, d in enumerate(decls):
        seen = {m for m in name_to_ids[d["name"]] if m != u}
        for tok in IDENT_RE.findall(strip_strings_and_comments(d["text"])):
            if tok == "main":
                continue
            for v in name_to_ids.get(tok, ()):
                if v != u:
                    seen.add(v)
        adj[u] = list(seen)
    main_id = name_to_ids["main"][0]
    reach = {main_id}
    q = deque([main_id])
    while q:
        u = q.popleft()
        for v in adj[u]:
            if v not in reach:
                reach.add(v)
                q.append(v)
    return {decls[u]["name"] for u in reach}


def prepare_k8_sources() -> tuple[dict[str, Path], dict[str, int]]:
    K8_SRC.mkdir(parents=True, exist_ok=True)
    reach_names = compute_reachable_names()
    types_text = (K8_DIR / "types.bend").read_text(encoding="utf-8")
    mod_texts = [(K8_DIR / f"{m}.bend").read_text(encoding="utf-8") for m in K8_MODS]
    src_paths: dict[str, Path] = {}
    export_counts: dict[str, int] = {}
    for i, m in enumerate(K8_MODS):
        prefix = (types_text + "\n") if i == 0 else "import Base\n"
        if m == "m07":
            full = prefix + mod_texts[i]
            export_counts[m] = 0
        else:
            defs = re.findall(r"^def\s+([A-Za-z0-9_.\$]+)\s*[\(:]", mod_texts[i], re.M)
            later = "\n".join(mod_texts[i + 1 :])
            later_idents = set(re.findall(r"[A-Za-z_][A-Za-z0-9_.\$]*", later))
            exps = [d for d in defs if d in later_idents and d in reach_names]
            export_counts[m] = len(exps)
            lines = ["\n@unsafe\ndef main() -> U32:"]
            for d in exps:
                if d in TMPL_CUSTOM:
                    lines.append(f"  _ = {TMPL_CUSTOM[d]}")
                elif d in TMPL_1ARG:
                    lines.append(f"  _ = {d}(U32)")
                else:
                    lines.append(f"  _ = {d}")
            lines.append("  0\n")
            full = prefix + mod_texts[i] + "\n".join(lines)
        p = K8_SRC / f"{m}_exp.bend"
        p.write_text(full, encoding="utf-8")
        src_paths[m] = p
    return src_paths, export_counts


def simulate_pipelined_true_cold(iface_ms: list[float], mod_ms: list[float], num_workers: int, merge_ms: float, link_ms: float) -> dict:
    """Exact discrete-event simulation of 1 iface CPU + `num_workers` compile CPUs.
    mod 0 ready at t=0; mod i (i>=1) ready at sum(iface_ms[:i]).
    """
    ready_times = [0.0]
    acc = 0.0
    for dt in iface_ms:
        acc += dt
        ready_times.append(acc)
    iface_chain_ms = acc

    worker_free = [0.0] * num_workers
    heapq.heapify(worker_free)
    schedule = []
    for i, (rt, dur) in enumerate(zip(ready_times, mod_ms)):
        wf = heapq.heappop(worker_free)
        start = max(rt, wf)
        end = start + dur
        heapq.heappush(worker_free, end)
        schedule.append({"module": i, "ready_ms": round(rt, 1), "start_ms": round(start, 1), "end_ms": round(end, 1), "dur_ms": round(dur, 1)})
    compile_wall = max(r["end_ms"] for r in schedule)
    tail_ms = max(0.0, compile_wall - iface_chain_ms)
    e2e = compile_wall + merge_ms + link_ms
    return {
        "num_workers": num_workers,
        "total_cpus": num_workers + 1,
        "iface_chain_ms": round(iface_chain_ms, 1),
        "compile_wall_ms": round(compile_wall, 1),
        "tail_after_iface_ms": round(tail_ms, 1),
        "merge_ms": round(merge_ms, 1),
        "link_ms": round(link_ms, 1),
        "e2e_wall_ms": round(e2e, 1),
        "schedule": schedule,
    }


def simulate_warm_lpt(mod_ms: list[float], num_cpus: int, merge_ms: float, link_ms: float) -> dict:
    """Exact LPT scheduling across `num_cpus` when all .p130 are warm."""
    order = sorted(range(len(mod_ms)), key=lambda i: mod_ms[i], reverse=True)
    loads = [0.0] * num_cpus
    heapq.heapify(loads)
    for i in order:
        lf = heapq.heappop(loads)
        heapq.heappush(loads, lf + mod_ms[i])
    compile_wall = max(loads)
    e2e = compile_wall + merge_ms + link_ms
    return {
        "num_cpus": num_cpus,
        "compile_sum_ms": round(sum(mod_ms), 1),
        "compile_wall_ms": round(compile_wall, 1),
        "parallel_scaling": round(sum(mod_ms) / compile_wall, 2),
        "e2e_wall_ms": round(e2e, 1),
    }


def run_part2_k8() -> None:
    print("\n=== PART 2: K=8 Native n5_o2 True-Cold Experiment (CPUs 2, 3) ===", flush=True)
    for d in (K8_SRC, K8_IFACE, K8_OBJ, K8_LOGS, K8_SMOKE):
        d.mkdir(parents=True, exist_ok=True)
    src_paths, export_counts = prepare_k8_sources()
    print(f"  Export counts: {export_counts}", flush=True)

    K = len(K8_MODS)
    carriers: list[tuple[Path, str] | None] = [None] * K
    carriers[0] = (BASE_CARRIER, BASE_STAMP)
    iface_records: list[dict] = []
    mod_records_map: dict[str, dict] = {}
    work_q: queue.Queue[int | None] = queue.Queue()
    work_q.put(0)

    # Safe provisional fid_bases (m07 at 55000 avoids overflow since ~8k segs < 10.5k room)
    provisional_bases = {f"m{i:02d}": i * 7800 for i in range(K)}
    exact_next_fid = [0]  # updated if preceding modules finished in order
    fid_lock_state: dict[int, int] = {}  # module idx -> seg_count

    def compile_mod(i: int, cpu: int, fid_base: int, tag: str = "k8") -> dict:
        m = K8_MODS[i]
        in_carrier, in_stamp = carriers[i]  # type: ignore[misc]
        out_o = K8_OBJ / f"{m}.o"
        err_f = K8_LOGS / f"{tag}_{m}.err"
        ms, stderr, cpu_s = run_native(
            N5_O2,
            ["--trace", "x86-module-fast", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fid_base), m],
            out_file=out_o,
            err_file=err_f,
            cpu=cpu,
            timeout=180,
        )
        segs = get_seg_count(out_o, m)
        fid_lock_state[i] = segs
        rec = {
            "module": m,
            "mode": "x86-module-fast",
            "cpu": cpu,
            "fid_base": fid_base,
            "seg_count": segs,
            "fid_end": fid_base + segs - 1,
            "ms": ms,
            "cpu_s": cpu_s,
            "bytes": out_o.stat().st_size,
            "sha256": sha256(out_o),
            "trace_stages": parse_trace_stages(stderr),
        }
        print(
            f"  [{tag} cpu={cpu}] {m}.o: {rec['bytes']:,} B | fid=[{rec['fid_base']}..{rec['fid_end']}] "
            f"(segs={segs:,}) | {ms} ms | stages={rec['trace_stages']}",
            flush=True,
        )
        return rec

    def pick_fid_base(i: int) -> int:
        # If all 0..i-1 have known seg_counts, use exact contiguous fid_base!
        if all(j in fid_lock_state for j in range(i)):
            return sum(fid_lock_state[j] for j in range(i))
        return provisional_bases[K8_MODS[i]]

    def worker_cpu3() -> None:
        while True:
            item = work_q.get()
            if item is None:
                return
            m = K8_MODS[item]
            fb = pick_fid_base(item)
            mod_records_map[m] = compile_mod(item, 3, fb, "k8_p1")

    t_all0 = time.perf_counter()
    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as ex:
        fut3 = ex.submit(worker_cpu3)
        try:
            t_iface0 = time.perf_counter()
            for i in range(K - 1):  # m00..m06 (7 hops)
                m = K8_MODS[i]
                in_carrier, in_stamp = carriers[i]  # type: ignore[misc]
                out_p130 = K8_IFACE / f"{m}.p130"
                err_f = K8_LOGS / f"k8_iface_{m}.err"
                ms, stderr, cpu_s = run_native(
                    N5_O2,
                    ["x86-iface", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp],
                    out_file=out_p130,
                    err_file=err_f,
                    cpu=2,
                    timeout=180,
                )
                stamp = stderr.splitlines()[-1].strip()
                info = parse_p130(out_p130)
                assert info["stamp"] == stamp, f"Stamp mismatch for {m}: {info['stamp']} != {stamp}"
                rec = {
                    "module": m,
                    "cpu": 2,
                    "ms": ms,
                    "cpu_s": cpu_s,
                    "bytes": info["bytes"],
                    "nodes": info["nodes"],
                    "strings": info["strings"],
                    "node_pct": round(100.0 * info["nodes"] / NODE_LIMIT, 2),
                    "string_pct": round(100.0 * info["strings"] / STR_LIMIT, 2),
                    "stamp": stamp,
                    "sha256": info["sha256"],
                }
                iface_records.append(rec)
                carriers[i + 1] = (out_p130, stamp)
                work_q.put(i + 1)
                print(
                    f"  [k8-iface {i+1}/7 cpu=2] {m}.p130: {info['bytes']:,} B | nodes={info['nodes']:,} ({rec['node_pct']}%) "
                    f"| strs={info['strings']:,} ({rec['string_pct']}%) | {ms} ms -> queued {K8_MODS[i+1]}",
                    flush=True,
                )
            iface_wall_ms = round((time.perf_counter() - t_iface0) * 1000.0, 1)
            print(f"  [k8-iface DONE] 7/7 .p130 ready ({iface_wall_ms} ms); CPU 2 joining compile pool!", flush=True)

            # CPU 2 helps drain remaining modules
            while True:
                try:
                    item = work_q.get_nowait()
                except queue.Empty:
                    break
                if item is None:
                    break
                m = K8_MODS[item]
                fb = pick_fid_base(item)
                mod_records_map[m] = compile_mod(item, 2, fb, "k8_p1")
        finally:
            work_q.put(None)
        fut3.result()

    pass1_wall_ms = round((time.perf_counter() - t_all0) * 1000.0, 1)
    p1_records = [mod_records_map[m] for m in K8_MODS]
    total_segs = sum(r["seg_count"] for r in p1_records)
    print(f"  [K=8 FID check] total_segs = {total_segs:,} / {FID_LIMIT:,}", flush=True)
    assert total_segs <= FID_LIMIT, f"K=8 total_segs {total_segs} > {FID_LIMIT}"

    # Check if any module needs exact contiguous fid_base redo
    exact_bases: dict[str, int] = {}
    cur = 0
    for r in p1_records:
        exact_bases[r["module"]] = cur
        cur += r["seg_count"]
    to_redo = [i for i, m in enumerate(K8_MODS) if mod_records_map[m]["fid_base"] != exact_bases[m]]
    redo_modules = [K8_MODS[i] for i in to_redo]
    redo_wall_ms = 0.0
    if to_redo:
        print(f"  Recompiling {len(to_redo)} modules with exact contiguous fid_bases on CPUs 2,3: {redo_modules}", flush=True)
        q_redo: queue.Queue[int] = queue.Queue()
        for i in sorted(to_redo, key=lambda idx: mod_records_map[K8_MODS[idx]]["ms"], reverse=True):
            q_redo.put(i)

        def redo_worker(cpu: int) -> None:
            while True:
                try:
                    i = q_redo.get_nowait()
                except queue.Empty:
                    return
                m = K8_MODS[i]
                mod_records_map[m] = compile_mod(i, cpu, exact_bases[m], "k8_redo")

        t_r0 = time.perf_counter()
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as ex:
            for f in [ex.submit(redo_worker, cpu) for cpu in (2, 3)]:
                f.result()
        redo_wall_ms = round((time.perf_counter() - t_r0) * 1000.0, 1)

    final_records = [mod_records_map[m] for m in K8_MODS]
    for i in range(K - 1):
        assert final_records[i]["fid_end"] < final_records[i + 1]["fid_base"]
    assert final_records[-1]["fid_end"] < FID_LIMIT

    # Native x86-merge-obj + gcc-10 link -> n6_k8
    merge_o = K8_OBJ / "merge_n6_k8.o"
    merge_ms, _, _ = run_native(
        N5_O2,
        ["x86-merge-obj", "m07", "m07", *K8_MODS[: K - 1]],
        out_file=merge_o,
        err_file=K8_LOGS / "k8_merge.err",
        cpu=2,
        timeout=60,
    )
    n6_k8 = K8_TMP / "n6_k8"
    t_lk = time.perf_counter()
    mod_objs = [K8_OBJ / f"{m}.o" for m in K8_MODS]
    r_lk = subprocess.run(
        [
            "timeout", "60", "taskset", "-c", "2", CC, "-O2", "-no-pie",
            str(merge_o), *[str(o) for o in mod_objs], str(RT), "-o", str(n6_k8), "-lm", "-lpthread",
        ],
        capture_output=True, text=True,
    )
    link_ms = round((time.perf_counter() - t_lk) * 1000.0, 1)
    if r_lk.returncode != 0:
        raise RuntimeError(f"gcc-10 link n6_k8 failed: {r_lk.stderr[-1500:]}")
    print(f"  LINKED {n6_k8} ({n6_k8.stat().st_size:,} B) | merge={merge_ms} ms | link={link_ms} ms", flush=True)

    # Smoke test n6_k8 on compiler_slice.bend
    sm_o = K8_SMOKE / "slice.o"
    sm_err = K8_LOGS / "k8_smoke.err"
    sm_exe = K8_SMOKE / "slice.exe"
    sm_compile_ms, sm_stderr, _ = run_native(
        n6_k8,
        ["--trace", "x86-object-fast", str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
        out_file=sm_o,
        err_file=sm_err,
        cpu=2,
        timeout=60,
    )
    subprocess.run(
        ["timeout", "30", "taskset", "-c", "2", CC, "-no-pie", str(sm_o), str(RT), "-o", str(sm_exe), "-lm", "-lpthread"],
        check=True,
    )
    r_sm = subprocess.run(["timeout", "30", "taskset", "-c", "2", str(sm_exe)], capture_output=True, text=True, check=True)
    sm_out = r_sm.stdout.strip()
    assert sm_out == "34", f"n6_k8 smoke expected '34', got {sm_out!r}"
    print(f"  n6_k8 SMOKE PASS: out={sm_out} | compile={sm_compile_ms} ms | obj={sm_o.stat().st_size:,} B", flush=True)

    # Compute exact 7-core pipelined true-cold & warm-cold simulations from measured pass-1 native times
    iface_ms_list = [r["ms"] for r in iface_records]
    mod_ms_list = [r["ms"] for r in p1_records]
    sim_7core_cold = simulate_pipelined_true_cold(iface_ms_list, mod_ms_list, 6, merge_ms, link_ms)
    sim_5core_cold = simulate_pipelined_true_cold(iface_ms_list, mod_ms_list, 4, merge_ms, link_ms)
    sim_7core_warm = simulate_warm_lpt(mod_ms_list, 7, merge_ms, link_ms)

    print("\n  === K=8 vs K=14 SUMMARY ===", flush=True)
    print(f"  K=8  7-hop iface chain:          {iface_wall_ms/1000.0:.2f} s (vs K=14 13-hop: 196.34 s -> {196344.9/iface_wall_ms:.2f}x!)", flush=True)
    print(f"  K=8  compile sum (8 mods):       {sum(mod_ms_list)/1000.0:.2f} s (vs K=14 14 mods: 342.45 s in S2B / 476.37 s in S2A)", flush=True)
    print(f"  K=8  7-core pipelined true-cold: {sim_7core_cold['e2e_wall_ms']/1000.0:.2f} s (tail={sim_7core_cold['tail_after_iface_ms']/1000.0:.2f} s) vs K=14 216.38 s!", flush=True)
    print(f"  K=8  5-core pipelined true-cold: {sim_5core_cold['e2e_wall_ms']/1000.0:.2f} s (tail={sim_5core_cold['tail_after_iface_ms']/1000.0:.2f} s)", flush=True)
    print(f"  K=8  7-core warm-.p130 E2E:      {sim_7core_warm['e2e_wall_ms']/1000.0:.2f} s (vs K=14 76.93 s)", flush=True)

    res = load_results()
    res["part2_k8_experiment"] = {
        "k": K,
        "modules": K8_MODS,
        "export_counts": export_counts,
        "exact_contiguous_fid_bases": exact_bases,
        "total_segs": total_segs,
        "fid_limit": FID_LIMIT,
        "iface_chain_wall_ms": iface_wall_ms,
        "iface_records": iface_records,
        "pass1_2cpu_pipelined_wall_ms": pass1_wall_ms,
        "pass1_compile_sum_ms": round(sum(mod_ms_list), 1),
        "pass1_modules": p1_records,
        "redo_modules": redo_modules,
        "redo_wall_ms": redo_wall_ms,
        "final_modules": final_records,
        "merge_ms": merge_ms,
        "merge_bytes": merge_o.stat().st_size,
        "link_ms": link_ms,
        "n6_k8_bytes": n6_k8.stat().st_size,
        "smoke": {
            "out": sm_out,
            "compile_ms": sm_compile_ms,
            "obj_bytes": sm_o.stat().st_size,
            "obj_sha256": sha256(sm_o),
            "trace_stages": parse_trace_stages(sm_stderr),
        },
        "sim_7core_true_cold": sim_7core_cold,
        "sim_5core_true_cold": sim_5core_cold,
        "sim_7core_warm_p130": sim_7core_warm,
    }
    save_results(res)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--part", choices=["1", "2", "all"], default="all")
    args = ap.parse_args()
    if args.part in ("1", "all"):
        run_part1_m11_profile()
    if args.part in ("2", "all"):
        run_part2_k8()


if __name__ == "__main__":
    main()
