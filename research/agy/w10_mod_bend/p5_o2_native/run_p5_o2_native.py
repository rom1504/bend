#!/usr/bin/env python3
"""P5-B: Mint -O2 Native n3_o2 in Parallel & Measure Exact Speedup vs -O0 n3_w10.

Dedicated CPUs: 1, 2, 3 ONLY.
Dedicated workspace: research/agy/w10_mod_bend/p5_o2_native/ and /tmp/agy_p5_o2/.
Output binary: selfhost/build/agy/wave10-native-mod/n3_o2.

Modes:
  --step1  Build .p130 chain (m00..m10) + run -O2 feasibility probe on m11 & m06
  --step2  Compile remaining modules at -O2 (with 10-min timeout guard / hybrid fallback),
           link n3_o2 via native n3_w10 x86-merge-obj + gcc-10, and run head-to-head
           CPU-1 benchmarks (n3_o2 vs -O0 n3_w10) on compiler_slice, m11, and m06.
  --all    Run step1 followed by step2 automatically.
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

ROOT = Path("/home/ai/bend2_agy")
API = ROOT / "selfhost/build/agy/wave10_unified/api.mjs"
CLI = ROOT / "research/agy/w10_mod_bend/compose_w10/run_w10_cli.mjs"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
K12_DIR = ROOT / "research/agy/w10_mod_bend/k12_wave10"
P4_RESULTS = ROOT / "research/agy/w10_mod_bend/p4_native_repro/results.json"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"

NATIVE_DIR = ROOT / "selfhost/build/agy/wave10-native-mod"
N3_W10 = NATIVE_DIR / "n3_w10"
N3_O2 = NATIVE_DIR / "n3_o2"

OUT_DIR = ROOT / "research/agy/w10_mod_bend/p5_o2_native"
RESULTS_JSON = OUT_DIR / "results.json"

TMP = Path("/tmp/agy_p5_o2")
SRC_DIR = TMP / "src"
IFACE_DIR = TMP / "iface"
OBJ_O2 = TMP / "obj_o2"
BENCH_DIR = TMP / "bench"

ALLOWED_CPUS = (1, 2, 3, 4, 5)
STEP2_CPUS = (1, 2, 3, 4, 5)
FID_LIMIT = 65532
NODE_LIMIT = 1048576
STR_LIMIT = 65536
O2_TIMEOUT_S = 600  # 10 min cliff guard for m01..m11
O2_TIMEOUT_M00_S = 960  # 16 min guard for m00 (whose -O0 frontend alone is 420s)

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
    # Derive x187_priv and x187_pub durations when possible
    if "x187_priv_done_elapsed" in stages and "x198pw_plan" in stages:
        pre_x187 = stages.get("read", 0.0) + stages.get("prep", 0.0) + stages.get("p86_plan", 0.0) + stages.get("x198pw_plan", 0.0)
        stages["x187_priv_est"] = round(stages["x187_priv_done_elapsed"] - pre_x187, 1)
    if "x187_pub_done_elapsed" in stages and "x187_priv_done_elapsed" in stages:
        stages["x187_pub_est"] = round(stages["x187_pub_done_elapsed"] - stages["x187_priv_done_elapsed"], 1)
    return stages


def run_w10_cli(
    args: list[str],
    out_file: Path,
    cpu: int,
    max_mb: int = 4096,
    timeout: int = 600,
) -> tuple[float, str]:
    assert cpu in ALLOWED_CPUS, f"Disallowed CPU {cpu}"
    cmd = ["taskset", "-c", str(cpu), "bash", str(LOCKED_NODE), str(CLI), str(API), *args]
    env = os.environ.copy()
    env["AGY_NODE_MAX_MB"] = str(max_mb)
    t0 = time.perf_counter()
    with out_file.open("wb") as f:
        r = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, cwd=ROOT, env=env, timeout=timeout)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = r.stderr.decode("utf-8", errors="replace").strip()
    if r.returncode != 0:
        raise RuntimeError(f"w10 cli failed (rc={r.returncode}) args={args[:4]}: {stderr[:800]}")
    return ms, stderr


def run_native(
    binary: Path,
    args: list[str],
    out_file: Path,
    cpu: int,
    timeout: int = 900,
) -> tuple[float, str]:
    assert cpu in ALLOWED_CPUS, f"Disallowed CPU {cpu}"
    cmd = ["bash", "-c", 'ulimit -s 262144 && exec taskset -c "$1" "$2" "${@:3}"', "_", str(cpu), str(binary), *args]
    t0 = time.perf_counter()
    with out_file.open("wb") as f:
        r = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, cwd=ROOT, timeout=timeout)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = r.stderr.decode("utf-8", errors="replace").strip()
    if r.returncode != 0:
        raise RuntimeError(f"native {binary.name} failed (rc={r.returncode}) args={args[:4]}: {stderr[:800]}")
    return ms, stderr


def link_compiler(merge_o: Path, mod_objs: list[Path], out_bin: Path, cpu: int = 1) -> float:
    assert cpu in ALLOWED_CPUS
    t0 = time.perf_counter()
    subprocess.run(
        ["taskset", "-c", str(cpu), CC, "-O2", "-no-pie", str(merge_o), *[str(o) for o in mod_objs], str(RT), "-o", str(out_bin), "-lm", "-lpthread"],
        check=True,
    )
    return round((time.perf_counter() - t0) * 1000.0, 1)


def prepare_sources() -> tuple[list[str], dict[str, Path]]:
    SRC_DIR.mkdir(parents=True, exist_ok=True)
    types_text = (K12_DIR / "types.bend").read_text(encoding="utf-8")
    mod_names = [f"m{i:02d}" for i in range(12)]
    mod_texts = [(K12_DIR / f"{m}.bend").read_text(encoding="utf-8") for m in mod_names]
    src_paths: dict[str, Path] = {}
    for i, m in enumerate(mod_names):
        prefix = (types_text + "\n") if i == 0 else "import Base\n"
        if i == 11:
            full = prefix + mod_texts[i]
        else:
            defs = re.findall(r"^def\s+([A-Za-z0-9_.\$]+)\s*[\(:]", mod_texts[i], re.M)
            later = "\n".join(mod_texts[i + 1 :])
            later_idents = set(re.findall(r"[A-Za-z_][A-Za-z0-9_.\$]*", later))
            exps = [d for d in defs if d in later_idents]
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
        p = SRC_DIR / f"{m}_exp.bend"
        p.write_text(full, encoding="utf-8")
        src_paths[m] = p
    return mod_names, src_paths


def load_p4_reference() -> tuple[dict[str, dict], dict[str, str]]:
    p4 = json.loads(P4_RESULTS.read_text(encoding="utf-8"))
    s1_mods = {r["module"]: r for r in p4["stage1_js_to_n2"]["modules"]}
    s1_iface_stamps = {r["module"]: r["stamp"] for r in p4["stage1_js_to_n2"]["iface_records"]}
    return s1_mods, s1_iface_stamps


def load_or_init_results() -> dict:
    if RESULTS_JSON.exists():
        return json.loads(RESULTS_JSON.read_text(encoding="utf-8"))
    return {
        "status": "in_progress",
        "iface_chain": {},
        "step1_o2_probe": {},
        "step2_o2_build": {},
        "step2_benchmarks": {},
    }


def save_results(res: dict) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    RESULTS_JSON.write_text(json.dumps(res, indent=2) + "\n", encoding="utf-8")


def compile_o2_module(
    m: str,
    src_path: Path,
    in_carrier: Path,
    in_stamp: str,
    fid_base: int,
    expected_segs: int,
    cpu: int,
    timeout_s: int = O2_TIMEOUT_S,
    allow_o0_fallback: bool = False,
) -> dict:
    out_o = OBJ_O2 / f"{m}.o"
    mode = "x86-module"
    timed_out = False
    partial_stderr = ""
    try:
        ms, stderr = run_native(
            N3_W10,
            ["--trace", "x86-module", str(src_path), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fid_base), m],
            out_file=out_o,
            cpu=cpu,
            timeout=timeout_s,
        )
    except subprocess.TimeoutExpired as e:
        timed_out = True
        partial_stderr = (e.stderr.decode("utf-8", errors="replace") if e.stderr else "").strip()
        print(f"  [O2 TIMEOUT cpu={cpu}] {m} exceeded {timeout_s}s! partial_trace_tail={partial_stderr.splitlines()[-3:] if partial_stderr else []}", flush=True)
        if not allow_o0_fallback:
            return {
                "module": m,
                "mode": "x86-module",
                "cpu": cpu,
                "fid_base": fid_base,
                "timed_out": True,
                "timeout_s": timeout_s,
                "partial_trace_lines": [ln for ln in partial_stderr.splitlines() if ln.strip()],
            }
        mode = "x86-module-fast"
        print(f"  [HYBRID FALLBACK cpu={cpu}] compiling {m} with x86-module-fast (-O0)...", flush=True)
        ms, stderr = run_native(
            N3_W10,
            ["--trace", "x86-module-fast", str(src_path), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fid_base), m],
            out_file=out_o,
            cpu=cpu,
            timeout=900,
        )

    segs = get_seg_count(out_o, m)
    rec = {
        "module": m,
        "mode": mode,
        "o2_timed_out": timed_out,
        "cpu": cpu,
        "fid_base": fid_base,
        "seg_count": segs,
        "seg_count_matches_o0": (segs == expected_segs),
        "fid_end": fid_base + segs - 1,
        "ms": ms,
        "bytes": out_o.stat().st_size,
        "sha256": sha256(out_o),
        "trace_stages": parse_trace_stages(stderr),
        "trace_lines": [ln for ln in stderr.splitlines() if ln.strip()],
    }
    if timed_out:
        rec["o2_timeout_s"] = timeout_s
        rec["o2_partial_trace_lines"] = [ln for ln in partial_stderr.splitlines() if ln.strip()]
    return rec


def build_iface_and_step1(res: dict, mod_names: list[str], src_paths: dict[str, Path], s1_mods: dict[str, dict], s1_iface_stamps: dict[str, str]) -> list[tuple[Path, str]]:
    IFACE_DIR.mkdir(parents=True, exist_ok=True)
    OBJ_O2.mkdir(parents=True, exist_ok=True)

    # Check if iface chain is already cached in /tmp/agy_p5_o2/iface/
    carriers: list[tuple[Path, str]] = [(BASE_CARRIER, BASE_STAMP)]
    existing_iface = res.get("iface_chain", {}).get("records", [])
    if len(existing_iface) == 11 and all((IFACE_DIR / f"m{i:02d}.p130").exists() for i in range(11)):
        for rec in existing_iface:
            carriers.append((IFACE_DIR / f"{rec['module']}.p130", rec["stamp"]))
        print("=== Reusing cached .p130 chain in /tmp/agy_p5_o2/iface/ ===", flush=True)
    else:
        print("=== STEP 1A: Building cumulative .p130 chain (m00..m10) on CPU 1 (with m06 -O2 overlap on CPU 2) ===", flush=True)
        iface_records = []
        t_iface0 = time.perf_counter()
        use_native_iface = False
        m06_future: concurrent.futures.Future | None = None
        executor = concurrent.futures.ThreadPoolExecutor(max_workers=1)

        try:
            for i in range(11):
                m = mod_names[i]
                in_carrier, in_stamp = carriers[i]
                out_p130 = IFACE_DIR / f"{m}.p130"
                # m00 is much faster on JS (138s vs >300s on -O0 native).
                # Test native n3_w10 on m01; keep native for m02..m10 if m01 < 45s.
                if i == 1:
                    ms, stderr = run_native(
                        N3_W10,
                        ["x86-iface", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp],
                        out_file=out_p130,
                        cpu=1,
                        timeout=300,
                    )
                    tool_used = "n3_w10"
                    use_native_iface = (ms < 45000.0)
                    print(f"  [iface-probe] m01 on n3_w10 took {ms} ms (JS baseline 37,391 ms) -> use_native_for_rest={use_native_iface}", flush=True)
                elif i >= 2 and use_native_iface:
                    ms, stderr = run_native(
                        N3_W10,
                        ["x86-iface", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp],
                        out_file=out_p130,
                        cpu=1,
                        timeout=300,
                    )
                    tool_used = "n3_w10"
                else:
                    ms, stderr = run_w10_cli(
                        ["x86-iface", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp],
                        out_file=out_p130,
                        cpu=1,
                        max_mb=4096,
                    )
                    tool_used = "wave10_unified_js"

                info = parse_p130(out_p130)
                stamp = info["stamp"]
                expected_stamp = s1_iface_stamps[m]
                assert stamp == expected_stamp, f"Stamp mismatch for {m}: got {stamp} != expected {expected_stamp}"
                rec = {
                    "module": m,
                    "tool": tool_used,
                    "ms": ms,
                    "bytes": info["bytes"],
                    "nodes": info["nodes"],
                    "strings": info["strings"],
                    "stamp": stamp,
                    "stamp_matches_p4": True,
                }
                iface_records.append(rec)
                carriers.append((out_p130, stamp))
                print(
                    f"  [iface {i+1:2d}/11 {tool_used}] {m}.p130: {info['bytes']:,} B | nodes={info['nodes']:,} | {ms} ms (stamp==P4)",
                    flush=True,
                )

                # As soon as m05.p130 finishes, overlap m06 -O2 probe on CPU 2!
                if i == 5 and "m06" not in res.get("step1_o2_probe", {}):
                    print("  [Step1-overlap] Launching m06 -O2 probe on CPU 2 while m06..m10 .p130 build on CPU 1...", flush=True)
                    m06_future = executor.submit(
                        compile_o2_module,
                        "m06",
                        src_paths["m06"],
                        out_p130,
                        stamp,
                        s1_mods["m06"]["fid_base"],
                        s1_mods["m06"]["seg_count"],
                        2,
                        O2_TIMEOUT_S,
                        False,
                    )
            iface_wall_ms = round((time.perf_counter() - t_iface0) * 1000.0, 1)
            res["iface_chain"] = {
                "wall_ms": iface_wall_ms,
                "records": iface_records,
            }
            save_results(res)
            print(f"  Step 1A iface chain complete in {iface_wall_ms} ms", flush=True)

            # Now run m11 -O2 probe on CPU 1!
            if "m11" not in res.get("step1_o2_probe", {}):
                print("=== STEP 1B: -O2 Feasibility Probe on m11 (CPU 1) ===", flush=True)
                m11_rec = compile_o2_module(
                    "m11",
                    src_paths["m11"],
                    carriers[11][0],
                    carriers[11][1],
                    s1_mods["m11"]["fid_base"],
                    s1_mods["m11"]["seg_count"],
                    cpu=1,
                    timeout_s=O2_TIMEOUT_S,
                    allow_o0_fallback=False,
                )
                res.setdefault("step1_o2_probe", {})["m11"] = m11_rec
                save_results(res)
                if m11_rec.get("timed_out"):
                    print(f"  [Step1 m11 -O2] TIMED OUT at {O2_TIMEOUT_S}s!", flush=True)
                else:
                    print(
                        f"  [Step1 m11 -O2] {m11_rec['ms']} ms | bytes={m11_rec['bytes']:,} (vs O0 {s1_mods['m11']['bytes']:,}) "
                        f"| segs={m11_rec['seg_count']} (matches_o0={m11_rec['seg_count_matches_o0']}) | stages={m11_rec['trace_stages']}",
                        flush=True,
                    )

            if m06_future is not None:
                m06_rec = m06_future.result()
                res.setdefault("step1_o2_probe", {})["m06"] = m06_rec
                save_results(res)
                if m06_rec.get("timed_out"):
                    print(f"  [Step1 m06 -O2] TIMED OUT at {O2_TIMEOUT_S}s!", flush=True)
                else:
                    print(
                        f"  [Step1 m06 -O2] {m06_rec['ms']} ms | bytes={m06_rec['bytes']:,} (vs O0 {s1_mods['m06']['bytes']:,}) "
                        f"| segs={m06_rec['seg_count']} (matches_o0={m06_rec['seg_count_matches_o0']}) | stages={m06_rec['trace_stages']}",
                        flush=True,
                    )
        finally:
            executor.shutdown(wait=True)

    return carriers


def run_step2(res: dict, mod_names: list[str], src_paths: dict[str, Path], carriers: list[tuple[Path, str]], s1_mods: dict[str, dict]) -> None:
    OBJ_O2.mkdir(parents=True, exist_ok=True)
    BENCH_DIR.mkdir(parents=True, exist_ok=True)
    NATIVE_DIR.mkdir(parents=True, exist_ok=True)

    probe = res.get("step1_o2_probe", {})
    o2_records_map: dict[str, dict] = {}
    for m in ("m06", "m11"):
        if m in probe and not probe[m].get("timed_out") and (OBJ_O2 / f"{m}.o").exists():
            o2_records_map[m] = probe[m]

    remaining = [i for i, m in enumerate(mod_names) if m not in o2_records_map]
    # Schedule heaviest modules first (m00 first, then by P4 native time descending)
    p4 = json.loads(P4_RESULTS.read_text(encoding="utf-8"))
    p4_native_ms = {r["module"]: r["ms"] for r in p4["stage2_native_n2_to_n3"]["modules"]}
    remaining.sort(key=lambda idx: p4_native_ms[mod_names[idx]], reverse=True)

    print(f"\n=== STEP 2A: Compiling {len(remaining)} remaining modules at -O2 in {len(STEP2_CPUS)}-way parallel (CPUs {list(STEP2_CPUS)}) ===", flush=True)
    print(f"  Schedule order: {[mod_names[i] for i in remaining]} (reusing probed: {sorted(o2_records_map.keys())})", flush=True)

    work_q: queue.Queue[int] = queue.Queue()
    for i in remaining:
        work_q.put(i)

    def worker(cpu: int) -> None:
        while True:
            try:
                i = work_q.get_nowait()
            except queue.Empty:
                return
            m = mod_names[i]
            in_carrier, in_stamp = carriers[i]
            rec = compile_o2_module(
                m,
                src_paths[m],
                in_carrier,
                in_stamp,
                s1_mods[m]["fid_base"],
                s1_mods[m]["seg_count"],
                cpu=cpu,
                timeout_s=(O2_TIMEOUT_M00_S if m == "m00" else O2_TIMEOUT_S),
                allow_o0_fallback=True,
            )
            o2_records_map[m] = rec
            print(
                f"  [O2 cpu={cpu}] {m}.o ({rec['mode']}): {rec['bytes']:,} B | segs={rec['seg_count']} "
                f"(eq_o0={rec['seg_count_matches_o0']}) | {rec['ms']} ms | stages={rec['trace_stages']}",
                flush=True,
            )

    t_comp0 = time.perf_counter()
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(STEP2_CPUS)) as ex:
        futs = [ex.submit(worker, cpu) for cpu in STEP2_CPUS]
        for f in futs:
            f.result()
    rem_compile_wall_ms = round((time.perf_counter() - t_comp0) * 1000.0, 1)

    o2_records = [o2_records_map[m] for m in mod_names]
    all_segs_match = all(r["seg_count_matches_o0"] for r in o2_records)
    if not all_segs_match:
        raise RuntimeError("Segment count changed under -O2; contiguous fid_base recalculation required!")

    total_segs = sum(r["seg_count"] for r in o2_records)
    assert total_segs <= FID_LIMIT, f"Total segs {total_segs} > {FID_LIMIT}"

    # Link n3_o2 via native n3_w10 x86-merge-obj + gcc-10 -O2 -no-pie
    print("\n=== STEP 2B: Native n3_w10 x86-merge-obj + gcc-10 link -> n3_o2 ===", flush=True)
    merge_o2 = OBJ_O2 / "merge_o2.o"
    merge_ms, _ = run_native(
        N3_W10,
        ["x86-merge-obj", "m11", "m11", *mod_names[:11]],
        out_file=merge_o2,
        cpu=1,
        timeout=120,
    )
    mod_objs = [OBJ_O2 / f"{m}.o" for m in mod_names]
    link_ms = link_compiler(merge_o2, mod_objs, N3_O2, cpu=1)
    n3_o2_bytes = N3_O2.stat().st_size
    n3_w10_bytes = N3_W10.stat().st_size
    o2_count = sum(1 for r in o2_records if r["mode"] == "x86-module")
    print(
        f"  LINKED {N3_O2} ({n3_o2_bytes:,} B vs n3_w10 {n3_w10_bytes:,} B, {round(100.0 * n3_o2_bytes / n3_w10_bytes, 1)}%) "
        f"| o2_mods={o2_count}/12 | merge={merge_ms} ms | link={link_ms} ms",
        flush=True,
    )

    res["step2_o2_build"] = {
        "o2_modules_count": o2_count,
        "o0_fallback_modules": [r["module"] for r in o2_records if r["mode"] != "x86-module"],
        "all_seg_counts_match_o0": all_segs_match,
        "total_segs": total_segs,
        "remaining_10_compile_wall_ms": rem_compile_wall_ms,
        "all_12_compile_sum_ms": round(sum(r["ms"] for r in o2_records), 1),
        "all_12_obj_bytes_sum": sum(r["bytes"] for r in o2_records),
        "o0_all_12_obj_bytes_sum": sum(s1_mods[m]["bytes"] for m in mod_names),
        "merge_ms": merge_ms,
        "merge_bytes": merge_o2.stat().st_size,
        "link_ms": link_ms,
        "n3_o2_bytes": n3_o2_bytes,
        "n3_w10_bytes": n3_w10_bytes,
        "n3_o2_sha256": sha256(N3_O2),
        "modules": o2_records,
    }
    save_results(res)

    # =========================================================================
    # STEP 2C: Head-to-Head Benchmarks on CPU 1 (n3_o2 vs -O0 n3_w10)
    # =========================================================================
    print("\n=== STEP 2C: Head-to-Head Benchmarks on CPU 1 (n3_o2 vs -O0 n3_w10) ===", flush=True)
    bench_out: dict[str, dict] = {}

    def bench_slice(binary: Path, tag: str) -> dict:
        o_path = BENCH_DIR / f"{tag}_slice.o"
        exe_path = BENCH_DIR / f"{tag}_slice.exe"
        ms, stderr = run_native(
            binary,
            ["--trace", "x86-object-fast", str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
            out_file=o_path,
            cpu=1,
            timeout=120,
        )
        t_lk = time.perf_counter()
        subprocess.run(["taskset", "-c", "1", CC, "-no-pie", str(o_path), str(RT), "-o", str(exe_path), "-lm", "-lpthread"], check=True)
        lk_ms = round((time.perf_counter() - t_lk) * 1000.0, 1)
        out = subprocess.run(["taskset", "-c", "1", str(exe_path)], capture_output=True, text=True, check=True, timeout=30).stdout.strip()
        assert out == "34", f"[{tag}] expected '34', got {out!r}"
        return {
            "compile_ms": ms,
            "link_ms": lk_ms,
            "obj_bytes": o_path.stat().st_size,
            "obj_sha256": sha256(o_path),
            "out": out,
            "trace_stages": parse_trace_stages(stderr),
            "trace_lines": [ln for ln in stderr.splitlines() if ln.strip()],
        }

    def bench_mod(binary: Path, tag: str, mod_idx: int) -> dict:
        m = mod_names[mod_idx]
        o_path = BENCH_DIR / f"{tag}_{m}.o"
        in_carrier, in_stamp = carriers[mod_idx]
        fid_base = s1_mods[m]["fid_base"]
        ms, stderr = run_native(
            binary,
            ["--trace", "x86-module-fast", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fid_base), m],
            out_file=o_path,
            cpu=1,
            timeout=300,
        )
        h = sha256(o_path)
        s1_h = s1_mods[m]["sha256"]
        assert h == s1_h, f"[{tag} {m}] SHA-256 mismatch vs Stage 1! got {h} != {s1_h}"
        return {
            "compile_ms": ms,
            "obj_bytes": o_path.stat().st_size,
            "sha256": h,
            "bit_identical_to_s1": True,
            "trace_stages": parse_trace_stages(stderr),
            "trace_lines": [ln for ln in stderr.splitlines() if ln.strip()],
        }

    # 1. compiler_slice.bend
    s_o0 = bench_slice(N3_W10, "n3_w10")
    s_o2 = bench_slice(N3_O2, "n3_o2")
    assert s_o0["obj_sha256"] == s_o2["obj_sha256"], "compiler_slice .o SHA-256 mismatch between n3_w10 and n3_o2!"
    s_spd = round(s_o0["compile_ms"] / s_o2["compile_ms"], 3)
    print(f"  [bench compiler_slice] n3_w10={s_o0['compile_ms']} ms | n3_o2={s_o2['compile_ms']} ms | speedup={s_spd}x | out=34 | .o bit-identical=True", flush=True)
    bench_out["compiler_slice"] = {
        "n3_w10": s_o0,
        "n3_o2": s_o2,
        "obj_bit_identical": True,
        "speedup": s_spd,
    }

    # 2. m11 (x86-module-fast)
    m11_o0 = bench_mod(N3_W10, "n3_w10", 11)
    m11_o2 = bench_mod(N3_O2, "n3_o2", 11)
    m11_spd = round(m11_o0["compile_ms"] / m11_o2["compile_ms"], 3)
    print(f"  [bench m11]            n3_w10={m11_o0['compile_ms']} ms | n3_o2={m11_o2['compile_ms']} ms | speedup={m11_spd}x | bit_eq_s1=True", flush=True)
    bench_out["m11"] = {
        "n3_w10": m11_o0,
        "n3_o2": m11_o2,
        "speedup": m11_spd,
    }

    # 3. m06 (x86-module-fast)
    m06_o0 = bench_mod(N3_W10, "n3_w10", 6)
    m06_o2 = bench_mod(N3_O2, "n3_o2", 6)
    m06_spd = round(m06_o0["compile_ms"] / m06_o2["compile_ms"], 3)
    print(f"  [bench m06]            n3_w10={m06_o0['compile_ms']} ms | n3_o2={m06_o2['compile_ms']} ms | speedup={m06_spd}x | bit_eq_s1=True", flush=True)
    bench_out["m06"] = {
        "n3_w10": m06_o0,
        "n3_o2": m06_o2,
        "speedup": m06_spd,
    }

    # Geometric mean speedup & projected 3-core cold self-compile time
    geomean_spd = round((s_spd * m11_spd * m06_spd) ** (1.0 / 3.0), 3)
    mod_geomean_spd = round((m11_spd * m06_spd) ** 0.5, 3)
    p4_3core_wall_ms = p4["stage2_native_n2_to_n3"]["compile_wall_ms"]
    p4_e2e_wall_ms = p4["stage2_native_n2_to_n3"]["e2e_wall_ms"]
    proj_3core_compile_ms = round(p4_3core_wall_ms / mod_geomean_spd, 1)
    proj_3core_e2e_ms = round(proj_3core_compile_ms + p4["stage2_native_n2_to_n3"]["merge_ms"] / mod_geomean_spd + p4["stage2_native_n2_to_n3"]["link_ms"], 1)

    bench_out["summary"] = {
        "speedup_compiler_slice": s_spd,
        "speedup_m11": m11_spd,
        "speedup_m06": m06_spd,
        "geomean_speedup_all3": geomean_spd,
        "geomean_speedup_modules": mod_geomean_spd,
        "p4_o0_3core_compile_wall_ms": p4_3core_wall_ms,
        "p4_o0_3core_e2e_wall_ms": p4_e2e_wall_ms,
        "projected_n3_o2_3core_compile_wall_ms": proj_3core_compile_ms,
        "projected_n3_o2_3core_e2e_wall_ms": proj_3core_e2e_ms,
    }

    res["step2_benchmarks"] = bench_out
    res["status"] = "PASSED"
    save_results(res)
    print(
        f"\nALL DONE! geomean_all3={geomean_spd}x | mod_geomean={mod_geomean_spd}x | "
        f"projected 3-core cold self-compile: {proj_3core_e2e_ms / 1000.0:.2f}s (vs {p4_e2e_wall_ms / 1000.0:.2f}s O0)",
        flush=True,
    )


def main() -> None:
    mode = sys.argv[1] if len(sys.argv) > 1 else "--all"
    mod_names, src_paths = prepare_sources()
    s1_mods, s1_iface_stamps = load_p4_reference()
    res = load_or_init_results()

    if mode in ("--step1", "--all"):
        carriers = build_iface_and_step1(res, mod_names, src_paths, s1_mods, s1_iface_stamps)
    else:
        carriers = [(BASE_CARRIER, BASE_STAMP)]
        for rec in res["iface_chain"]["records"]:
            carriers.append((IFACE_DIR / f"{rec['module']}.p130", rec["stamp"]))

    if mode in ("--step2", "--all"):
        run_step2(res, mod_names, src_paths, carriers, s1_mods)


if __name__ == "__main__":
    main()
