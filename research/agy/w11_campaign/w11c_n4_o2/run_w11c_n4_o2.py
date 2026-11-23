#!/usr/bin/env python3
"""W11-C: Mint Full 13/13 -O2 Native n4_o2 (k13_wave11) & Measure Native 5-Core Cold
+ 1-Module Edit + Pipelined True-Cold Speed.

Dedicated CPUs: 0, 1, 2, 3, 4 ONLY (never CPUs 5, 6, 7).
Dedicated workspace:
  - research/agy/w11_campaign/w11c_n4_o2/
  - selfhost/build/agy/wave11-native-mod/
  - /tmp/agy_w11c/
  - /tmp/agy_k13_w11_cache/{iface,obj_o0}
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
import sys
import time
from pathlib import Path
from statistics import median

ROOT = Path("/home/ai/bend2_agy")
API = ROOT / "selfhost/build/agy/wave11_unified/api.mjs"
CLI = ROOT / "research/agy/w10_mod_bend/compose_w10/run_w10_cli.mjs"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
K13_DIR = ROOT / "research/agy/w10_mod_bend/k13_wave11"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

INPUTS_UP = ROOT / "research/agy/wave4_bench/inputs/upstream"
UPSTREAM_EXPECTED = {
    "histogram": 3307081914,
    "nbody": 728502159,
    "gameoflife": 3681094808,
}

OUT_DIR = ROOT / "research/agy/w11_campaign/w11c_n4_o2"
RESULTS_JSON = OUT_DIR / "results.json"
NATIVE_DIR = ROOT / "selfhost/build/agy/wave11-native-mod"
N4_O2 = NATIVE_DIR / "n4_o2"
N5_W11 = NATIVE_DIR / "n5_w11"

TMP = Path("/tmp/agy_w11c")
SRC_DIR = TMP / "src"
IFACE_DIR = TMP / "iface"
OBJ_S1 = TMP / "obj_s1_o2"
OBJ_S2 = TMP / "obj_s2_o0"
OBJ_S2B = TMP / "obj_s2b_edit"
IFACE_S2C = TMP / "iface_s2c_native"
SMOKE_DIR = TMP / "smoke"
LOG_DIR = TMP / "logs"

ALLOWED_CPUS = (0, 1, 2, 3, 4)
MOD_NAMES = ["m00a", "m00b", "m01", "m02", "m03", "m04", "m05", "m06", "m07", "m08", "m09", "m10", "m11"]
FID_LIMIT = 65532
NODE_LIMIT = 1048576
STR_LIMIT = 65536

# Exact contiguous fid_bases for m00a..m06 (discovered from pass 1) + tight provisional for m07..m11
PROVISIONAL_FID_BASES = {
    "m00a": 0,
    "m00b": 3393,
    "m01": 6368,
    "m02": 12291,
    "m03": 17879,
    "m04": 23078,
    "m05": 27540,
    "m06": 33497,
    "m07": 39150,
    "m08": 45150,
    "m09": 51250,
    "m10": 56250,
    "m11": 60950,
}

# Known pass-1 iface times for resumed m00a..m04 (from task-28)
RESUMED_IFACE_MS = {
    "m00a": 61578.1,
    "m00b": 53995.9,
    "m01": 29894.0,
    "m02": 207443.0,
    "m03": 232618.8,
    "m04": 99270.3,
}

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
        pre = stages.get("read", 0.0) + stages.get("prep", 0.0) + stages.get("p86_plan", 0.0) + stages.get("x198pw_plan", 0.0)
        stages["x187_priv_est"] = round(stages["x187_priv_done_elapsed"] - pre, 1)
    if "x187_pub_done_elapsed" in stages and "x187_priv_done_elapsed" in stages:
        stages["x187_pub_est"] = round(stages["x187_pub_done_elapsed"] - stages["x187_priv_done_elapsed"], 1)
    return stages


def run_js_cli(
    args: list[str],
    out_file: Path,
    err_file: Path,
    cpu: int,
    max_mb: int = 3584,
    timeout: int = 480,
) -> tuple[float, str]:
    assert cpu in ALLOWED_CPUS, f"Disallowed CPU {cpu}"
    cmd = ["timeout", str(timeout), "taskset", "-c", str(cpu), "bash", str(LOCKED_NODE), str(CLI), str(API), *args]
    env = os.environ.copy()
    env["AGY_NODE_MAX_MB"] = str(max_mb)
    t0 = time.perf_counter()
    with out_file.open("wb") as of, err_file.open("wb") as ef:
        r = subprocess.run(cmd, stdout=of, stderr=ef, cwd=ROOT, env=env)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = err_file.read_text(encoding="utf-8", errors="replace").strip()
    if r.returncode != 0:
        raise RuntimeError(f"js cli failed (rc={r.returncode}, cpu={cpu}) args={args[:4]}: {stderr[-800:]}")
    return ms, stderr


def run_native(
    binary: Path,
    args: list[str],
    out_file: Path,
    err_file: Path,
    cpu: int,
    timeout: int = 240,
) -> tuple[float, str]:
    assert cpu in ALLOWED_CPUS, f"Disallowed CPU {cpu}"
    cmd = [
        "timeout", str(timeout),
        "bash", "-c", 'ulimit -s 262144 && exec taskset -c "$1" "$2" "${@:3}"',
        "_", str(cpu), str(binary), *args,
    ]
    t0 = time.perf_counter()
    with out_file.open("wb") as of, err_file.open("wb") as ef:
        r = subprocess.run(cmd, stdout=of, stderr=ef, cwd=ROOT)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = err_file.read_text(encoding="utf-8", errors="replace").strip()
    if r.returncode != 0:
        raise RuntimeError(f"native {binary.name} failed (rc={r.returncode}, cpu={cpu}) args={args[:4]}: {stderr[-800:]}")
    return ms, stderr


def link_compiler(merge_o: Path, mod_objs: list[Path], out_bin: Path, cpu: int = 0) -> float:
    assert cpu in ALLOWED_CPUS
    t0 = time.perf_counter()
    r = subprocess.run(
        ["timeout", "60", "taskset", "-c", str(cpu), CC, "-O2", "-no-pie", str(merge_o), *[str(o) for o in mod_objs], str(RT), "-o", str(out_bin), "-lm", "-lpthread"],
        capture_output=True, text=True,
    )
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    if r.returncode != 0:
        raise RuntimeError(f"gcc-10 link failed (rc={r.returncode}): {r.stderr[-1500:]}")
    if r.stderr.strip():
        print(f"  [WARN] gcc-10 link stderr: {r.stderr.strip()[:400]}", flush=True)
    return ms


def prepare_sources() -> tuple[dict[str, Path], dict[str, int]]:
    SRC_DIR.mkdir(parents=True, exist_ok=True)
    types_text = (K13_DIR / "types.bend").read_text(encoding="utf-8")
    mod_texts = [(K13_DIR / f"{m}.bend").read_text(encoding="utf-8") for m in MOD_NAMES]
    src_paths: dict[str, Path] = {}
    export_counts: dict[str, int] = {}
    for i, m in enumerate(MOD_NAMES):
        prefix = (types_text + "\n") if i == 0 else "import Base\n"
        if m == "m11":
            full = prefix + mod_texts[i]
            export_counts[m] = 0
        else:
            defs = re.findall(r"^def\s+([A-Za-z0-9_.\$]+)\s*[\(:]", mod_texts[i], re.M)
            later = "\n".join(mod_texts[i + 1 :])
            later_idents = set(re.findall(r"[A-Za-z_][A-Za-z0-9_.\$]*", later))
            exps = [d for d in defs if d in later_idents]
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
        p = SRC_DIR / f"{m}_exp.bend"
        p.write_text(full, encoding="utf-8")
        src_paths[m] = p
    return src_paths, export_counts


def smoke_slice(binary: Path, tag: str, mode: str = "x86-object-fast", cpu: int = 0) -> dict:
    sm_o = SMOKE_DIR / f"{tag}_{mode}.o"
    sm_err = LOG_DIR / f"smoke_{tag}_{mode}.err"
    sm_exe = SMOKE_DIR / f"{tag}_{mode}.exe"
    compile_ms, stderr = run_native(
        binary,
        ["--trace", mode, str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
        out_file=sm_o,
        err_file=sm_err,
        cpu=cpu,
        timeout=60,
    )
    t_lk = time.perf_counter()
    subprocess.run(
        ["timeout", "30", "taskset", "-c", str(cpu), CC, "-no-pie", str(sm_o), str(RT), "-o", str(sm_exe), "-lm", "-lpthread"],
        check=True,
    )
    link_ms = round((time.perf_counter() - t_lk) * 1000.0, 1)
    r = subprocess.run(["timeout", "30", "taskset", "-c", str(cpu), str(sm_exe)], capture_output=True, text=True, check=True)
    out = r.stdout.strip()
    assert out == "34", f"[{tag} {mode}] Expected '34', got {out!r}"
    return {
        "mode": mode,
        "compile_ms": compile_ms,
        "link_ms": link_ms,
        "obj_bytes": sm_o.stat().st_size,
        "obj_sha256": sha256(sm_o),
        "out": out,
        "trace_stages": parse_trace_stages(stderr),
        "trace_lines": [ln for ln in stderr.splitlines() if ln.strip()],
    }


def replace_once(text: str, pattern: str, repl: str) -> str:
    out, n = re.subn(pattern, repl, text, flags=re.M)
    assert n == 1, f"expected 1 match for {pattern!r}, found {n}"
    return out


def prepare_upstream_bend(family: str, up_spec: dict) -> str:
    desc = up_spec[family]
    text = (INPUTS_UP / family / "main.bend").read_text(encoding="utf-8")
    for bname, old, new in zip(desc["bendKnobs"], desc["upstream"], desc["medium"]):
        text = replace_once(text, rf"(^def {bname}\(\) -> Nat:\n  ){old}n$", rf"\g<1>{new}n")
    return text


def smoke_runtime_programs(binary: Path, cpu: int = 0) -> dict:
    up_spec = json.loads((INPUTS_UP / "suite.json").read_text(encoding="utf-8"))
    out_res = {}
    for fam in ("histogram", "nbody", "gameoflife"):
        src = SMOKE_DIR / f"rt_{fam}.bend"
        src.write_text(prepare_upstream_bend(fam, up_spec), encoding="utf-8")
        obj = SMOKE_DIR / f"rt_{fam}.o"
        err_f = LOG_DIR / f"rt_{fam}.err"
        cmp_ms, _ = run_native(
            binary,
            ["x86-object", str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
            out_file=obj,
            err_file=err_f,
            cpu=cpu,
            timeout=120,
        )
        exe = SMOKE_DIR / f"rt_{fam}.exe"
        subprocess.run(
            ["timeout", "30", "taskset", "-c", str(cpu), CC, "-O2", "-no-pie", str(obj), str(RT), "-lm", "-pthread", "-o", str(exe)],
            check=True,
        )
        runs = []
        for _ in range(3):
            t0 = time.perf_counter()
            r = subprocess.run(["timeout", "60", "taskset", "-c", str(cpu), str(exe)] + RTS_ARGS, capture_output=True, text=True, check=True)
            dt = round((time.perf_counter() - t0) * 1000.0, 2)
            got = int(r.stdout.strip().splitlines()[-1].strip())
            assert got == UPSTREAM_EXPECTED[fam], f"{fam} checksum mismatch: {got} != {UPSTREAM_EXPECTED[fam]}"
            runs.append(dt)
        med = round(median(runs), 2)
        out_res[fam] = {"ok": True, "compile_ms": cmp_ms, "obj_bytes": obj.stat().st_size, "median_ms": med, "runs_ms": runs}
        print(f"  [n4_o2 RT {fam:<10}] compile={cmp_ms:7.1f} ms | run_median={med:7.2f} ms (runs={runs}) | checksum OK", flush=True)
    return out_res


def save_results(res: dict) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    RESULTS_JSON.write_text(json.dumps(res, indent=2) + "\n", encoding="utf-8")


def load_or_init_results(export_counts: dict[str, int]) -> dict:
    if RESULTS_JSON.exists():
        return json.loads(RESULTS_JSON.read_text(encoding="utf-8"))
    return {
        "status": "in_progress",
        "k": 13,
        "modules": MOD_NAMES,
        "export_counts": export_counts,
        "stage1_mint_n4_o2": {},
        "stage2a_native_5core_cold": {},
        "stage2b_native_edits": {},
        "stage2c_native_iface": {},
    }


def run_stage1(res: dict, src_paths: dict[str, Path]) -> tuple[list[tuple[Path, str]], dict[str, int], dict[str, dict]]:
    print("=== STAGE 1: Pipelined Mint of 13/13 -O2 Native n4_o2 (CPUs 0..4, 3-way Node cap for RAM safety) ===", flush=True)
    carriers: list[tuple[Path, str] | None] = [None] * 13
    carriers[0] = (BASE_CARRIER, BASE_STAMP)
    iface_records: list[dict] = []
    s1_fid_bases = dict(PROVISIONAL_FID_BASES)
    s1_records_map: dict[str, dict] = {}
    work_q: queue.Queue[int | None] = queue.Queue()

    # Reuse m00a.o if it already exists with fid_base=0 (verified segs=3,393)
    m00a_o = OBJ_S1 / "m00a.o"
    if m00a_o.exists() and m00a_o.stat().st_size > 1_000_000:
        segs = get_seg_count(m00a_o, "m00a")
        s1_records_map["m00a"] = {
            "module": "m00a",
            "mode": "x86-module",
            "cpu": 1,
            "fid_base": 0,
            "seg_count": segs,
            "fid_end": segs - 1,
            "ms": 47169.3,
            "bytes": m00a_o.stat().st_size,
            "sha256": sha256(m00a_o),
            "trace_stages": {},
        }
        print(f"  [s1-reuse] m00a.o: {m00a_o.stat().st_size:,} B | fid=[0..{segs-1}] (segs={segs:,})", flush=True)
    else:
        work_q.put(0)

    def compile_s1_o2(i: int, cpu: int, fid_base: int, tag_prefix: str = "s1") -> dict:
        m = MOD_NAMES[i]
        in_carrier, in_stamp = carriers[i]  # type: ignore[misc]
        out_o = OBJ_S1 / f"{m}.o"
        err_f = LOG_DIR / f"{tag_prefix}_{m}.err"
        ms, stderr = run_js_cli(
            ["--trace", "x86-module", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fid_base), m],
            out_file=out_o,
            err_file=err_f,
            cpu=cpu,
            max_mb=4096,
            timeout=480,
        )
        segs = get_seg_count(out_o, m)
        rec = {
            "module": m,
            "mode": "x86-module",
            "cpu": cpu,
            "fid_base": fid_base,
            "seg_count": segs,
            "fid_end": fid_base + segs - 1,
            "ms": ms,
            "bytes": out_o.stat().st_size,
            "sha256": sha256(out_o),
            "trace_stages": parse_trace_stages(stderr),
        }
        print(
            f"  [{tag_prefix} -O2 cpu={cpu}] {m}.o: {rec['bytes']:,} B | fid=[{rec['fid_base']}..{rec['fid_end']}] "
            f"(segs={segs:,}) | {ms} ms | stages={rec['trace_stages']}",
            flush=True,
        )
        return rec

    def o2_worker(cpu: int) -> None:
        while True:
            item = work_q.get()
            if item is None:
                return
            i = item
            m = MOD_NAMES[i]
            s1_records_map[m] = compile_s1_o2(i, cpu, s1_fid_bases[m], "s1")

    t_pipe0 = time.perf_counter()
    # Use 2 concurrent Node -O2 workers (CPUs 1, 2) while CPU 0 runs x86-iface (max 3 Node procs -> zero swap!)
    worker_cpus = (1, 2)
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(worker_cpus)) as ex:
        futs = [ex.submit(o2_worker, cpu) for cpu in worker_cpus]
        try:
            # Producer on CPU 0: emit (or reuse) m00a.p130 .. m10.p130 and enqueue m00b .. m11 as each completes
            t_iface0 = time.perf_counter()
            for i in range(12):  # 0..11 => m00a..m10
                m = MOD_NAMES[i]
                in_carrier, in_stamp = carriers[i]  # type: ignore[misc]
                out_p130 = IFACE_DIR / f"{m}.p130"
                err_f = LOG_DIR / f"s1_iface_{m}.err"
                if out_p130.exists() and out_p130.stat().st_size > 1_000_000:
                    info = parse_p130(out_p130)
                    stamp = info["stamp"]
                    ms = RESUMED_IFACE_MS.get(m, 0.0)
                    tag = "iface-reuse"
                else:
                    ms, stderr = run_js_cli(
                        ["x86-iface", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp],
                        out_file=out_p130,
                        err_file=err_f,
                        cpu=0,
                        max_mb=4096,
                        timeout=300,
                    )
                    stamp = stderr.splitlines()[-1].strip()
                    info = parse_p130(out_p130)
                    assert info["stamp"] == stamp, f"Stamp mismatch for {m}: {info['stamp']} != {stamp}"
                    tag = "iface"
                rec = {
                    "module": m,
                    "ms": ms,
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
                    f"  [{tag} {i+1:2d}/12 cpu=0] {m}.p130: {info['bytes']:,} B | nodes={info['nodes']:,} ({rec['node_pct']}%) "
                    f"| strs={info['strings']:,} ({rec['string_pct']}%) | {ms} ms -> queued {MOD_NAMES[i+1]}",
                    flush=True,
                )
            iface_wall_ms = round(sum(r["ms"] for r in iface_records), 1)
            print(f"  [iface DONE] 12/12 .p130 ready (12-mod sum={iface_wall_ms} ms); CPU 0 joining -O2 pool!", flush=True)

            while True:
                try:
                    i = work_q.get_nowait()
                except queue.Empty:
                    break
                if i is None:
                    break
                m = MOD_NAMES[i]
                s1_records_map[m] = compile_s1_o2(i, 0, s1_fid_bases[m], "s1")
        finally:
            for _ in range(len(worker_cpus)):
                work_q.put(None)
        for f in futs:
            f.result()

    pipe_pass1_wall_ms = round((time.perf_counter() - t_pipe0) * 1000.0, 1)

    # Check FID disjointness and <= FID_LIMIT
    s1_records = [s1_records_map[m] for m in MOD_NAMES]
    total_segs = sum(r["seg_count"] for r in s1_records)
    print(f"  [FID check] total_segs = {total_segs:,} / {FID_LIMIT:,}", flush=True)
    assert total_segs <= FID_LIMIT, f"Total segs {total_segs} > {FID_LIMIT}!"

    overlap_or_overflow = any(
        s1_records[i]["fid_end"] >= s1_records[i + 1]["fid_base"] for i in range(12)
    ) or (s1_records[12]["fid_end"] >= FID_LIMIT)

    redo_modules: list[str] = []
    redo_wall_ms = 0.0
    if overlap_or_overflow:
        print("  Provisional fid_bases overlapped/overflowed; recomputing exact contiguous fid_bases...", flush=True)
        cur = 0
        new_bases: dict[str, int] = {}
        for r in s1_records:
            new_bases[r["module"]] = cur
            cur += r["seg_count"]
        to_redo = [i for i, m in enumerate(MOD_NAMES) if new_bases[m] != s1_fid_bases[m]]
        redo_modules = [MOD_NAMES[i] for i in to_redo]
        for m in MOD_NAMES:
            s1_fid_bases[m] = new_bases[m]
        print(f"  Recompiling {len(to_redo)} modules with exact contiguous fid_bases on CPUs 0..2: {redo_modules}", flush=True)
        q_redo: queue.Queue[int] = queue.Queue()
        for i in sorted(to_redo, key=lambda idx: s1_records_map[MOD_NAMES[idx]]["ms"], reverse=True):
            q_redo.put(i)

        def worker_redo(cpu: int) -> None:
            while True:
                try:
                    i = q_redo.get_nowait()
                except queue.Empty:
                    return
                m = MOD_NAMES[i]
                s1_records_map[m] = compile_s1_o2(i, cpu, s1_fid_bases[m], "s1_redo")

        t_r0 = time.perf_counter()
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as ex:
            for f in [ex.submit(worker_redo, cpu) for cpu in (0, 1, 2)]:
                f.result()
        redo_wall_ms = round((time.perf_counter() - t_r0) * 1000.0, 1)
        s1_records = [s1_records_map[m] for m in MOD_NAMES]

    s1_total_wall_ms = round((time.perf_counter() - t_pipe0) * 1000.0, 1)
    s1_objs = [OBJ_S1 / f"{m}.o" for m in MOD_NAMES]

    print("=== STAGE 1B: wave11_unified x86-merge-obj (m11 FIRST!) + gcc-10 -O2 -no-pie -> n4_o2 ===", flush=True)
    merge_s1 = OBJ_S1 / "merge_n4_o2.o"
    s1_merge_ms, _ = run_js_cli(
        ["x86-merge-obj", "m11", "m11", *MOD_NAMES[:12]],
        out_file=merge_s1,
        err_file=LOG_DIR / "s1_merge.err",
        cpu=0,
        max_mb=4096,
        timeout=60,
    )
    s1_link_ms = link_compiler(merge_s1, s1_objs, N4_O2, cpu=0)
    print(f"  LINKED {N4_O2} ({N4_O2.stat().st_size:,} B) | merge={s1_merge_ms} ms | link={s1_link_ms} ms", flush=True)

    print("=== STAGE 1C: Smoke test n4_o2 on compiler_slice.bend (-O0 & -O2) + 3-family RT smoke ===", flush=True)
    sm_fast = smoke_slice(N4_O2, "n4_o2", mode="x86-object-fast", cpu=0)
    print(f"  n4_o2 slice -O0 PASS: out={sm_fast['out']} | compile={sm_fast['compile_ms']} ms (vs n3_w10 11,139 ms -> {round(11139.1 / sm_fast['compile_ms'], 2)}x!)", flush=True)
    sm_o2 = smoke_slice(N4_O2, "n4_o2", mode="x86-object", cpu=0)
    print(f"  n4_o2 slice -O2 PASS: out={sm_o2['out']} | compile={sm_o2['compile_ms']} ms | obj={sm_o2['obj_bytes']:,} B", flush=True)
    rt_smoke = smoke_runtime_programs(N4_O2, cpu=0)

    res["stage1_mint_n4_o2"] = {
        "iface_wall_ms": iface_wall_ms,
        "iface_records": iface_records,
        "pipelined_pass1_wall_ms": pipe_pass1_wall_ms,
        "redo_modules": redo_modules,
        "redo_wall_ms": redo_wall_ms,
        "total_compile_wall_ms": s1_total_wall_ms,
        "compile_sum_ms": round(sum(r["ms"] for r in s1_records), 1),
        "total_segs": total_segs,
        "fid_limit": FID_LIMIT,
        "max_fid_used": s1_records[-1]["fid_end"],
        "all_13_o2": all(r["mode"] == "x86-module" for r in s1_records),
        "modules": s1_records,
        "merge_ms": s1_merge_ms,
        "merge_bytes": merge_s1.stat().st_size,
        "merge_sha256": sha256(merge_s1),
        "link_ms": s1_link_ms,
        "n4_o2_bytes": N4_O2.stat().st_size,
        "n4_o2_sha256": sha256(N4_O2),
        "smoke_slice_o0": sm_fast,
        "smoke_slice_o2": sm_o2,
        "smoke_runtime_o2": rt_smoke,
    }
    save_results(res)
    return carriers, s1_fid_bases, s1_records_map  # type: ignore[return-value]


def run_stage2(
    res: dict,
    src_paths: dict[str, Path],
    carriers: list[tuple[Path, str]],
    fid_bases: dict[str, int],
    s1_records_map: dict[str, dict],
) -> None:
    # =========================================================================
    # STAGE 2A: 100% Native 5-Core Cold Self-Reproduction (n4_o2 -> n5_w11)
    # =========================================================================
    print("\n=== STAGE 2A: 100% Native 5-Core Cold Self-Reproduction (n4_o2 -> n5_w11, CPUs 0..4) ===", flush=True)
    s2_records_map: dict[str, dict] = {}
    work_q2: queue.Queue[int] = queue.Queue()
    # Schedule heaviest modules first (by Stage 1 time descending)
    order_s2 = sorted(range(13), key=lambda idx: s1_records_map[MOD_NAMES[idx]]["ms"], reverse=True)
    for i in order_s2:
        work_q2.put(i)

    def worker_s2(cpu: int) -> None:
        while True:
            try:
                i = work_q2.get_nowait()
            except queue.Empty:
                return
            m = MOD_NAMES[i]
            in_carrier, in_stamp = carriers[i]
            fb = fid_bases[m]
            out_o = OBJ_S2 / f"{m}.o"
            err_f = LOG_DIR / f"s2a_{m}.err"
            ms, stderr = run_native(
                N4_O2,
                ["--trace", "x86-module-fast", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fb), m],
                out_file=out_o,
                err_file=err_f,
                cpu=cpu,
                timeout=240,
            )
            segs = get_seg_count(out_o, m)
            rec = {
                "module": m,
                "mode": "x86-module-fast",
                "cpu": cpu,
                "fid_base": fb,
                "seg_count": segs,
                "seg_matches_s1_o2": (segs == s1_records_map[m]["seg_count"]),
                "fid_end": fb + segs - 1,
                "ms": ms,
                "bytes": out_o.stat().st_size,
                "sha256": sha256(out_o),
                "trace_stages": parse_trace_stages(stderr),
            }
            s2_records_map[m] = rec
            print(
                f"  [S2A-native cpu={cpu}] {m}.o: {rec['bytes']:,} B | segs={segs:,} (eq_o2={rec['seg_matches_s1_o2']}) | {ms} ms",
                flush=True,
            )

    t_s2_0 = time.perf_counter()
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as ex:
        futs = [ex.submit(worker_s2, cpu) for cpu in ALLOWED_CPUS]
        for f in futs:
            f.result()
    s2_compile_wall_ms = round((time.perf_counter() - t_s2_0) * 1000.0, 1)
    s2_records = [s2_records_map[m] for m in MOD_NAMES]
    s2_objs = [OBJ_S2 / f"{m}.o" for m in MOD_NAMES]

    merge_s2 = OBJ_S2 / "merge_n5_w11.o"
    s2_merge_ms, _ = run_native(
        N4_O2,
        ["x86-merge-obj", "m11", "m11", *MOD_NAMES[:12]],
        out_file=merge_s2,
        err_file=LOG_DIR / "s2a_merge.err",
        cpu=0,
        timeout=60,
    )
    s2_link_ms = link_compiler(merge_s2, s2_objs, N5_W11, cpu=0)
    s2_e2e_wall_ms = round((time.perf_counter() - t_s2_0) * 1000.0, 1)
    s2_sum_ms = round(sum(r["ms"] for r in s2_records), 1)
    s2_par_spd = round(s2_sum_ms / s2_compile_wall_ms, 2)
    merge_bit_eq = sha256(merge_s2) == res["stage1_mint_n4_o2"]["merge_sha256"]

    print(
        f"  LINKED {N5_W11} ({N5_W11.stat().st_size:,} B) | 5-core compile={s2_compile_wall_ms} ms "
        f"(sum={s2_sum_ms} ms, {s2_par_spd}x) | merge={s2_merge_ms} ms (eq_s1={merge_bit_eq}) "
        f"| link={s2_link_ms} ms | E2E={s2_e2e_wall_ms} ms",
        flush=True,
    )
    n5_smoke = smoke_slice(N5_W11, "n5_w11", mode="x86-object-fast", cpu=0)
    print(f"  n5_w11 SMOKE PASS: out={n5_smoke['out']} | compile={n5_smoke['compile_ms']} ms", flush=True)

    res["stage2a_native_5core_cold"] = {
        "parallel_cpus": list(ALLOWED_CPUS),
        "schedule_order": [MOD_NAMES[i] for i in order_s2],
        "compile_wall_ms": s2_compile_wall_ms,
        "compile_sum_ms": s2_sum_ms,
        "speedup_vs_seq_native": s2_par_spd,
        "merge_ms": s2_merge_ms,
        "merge_bytes": merge_s2.stat().st_size,
        "merge_bit_identical_to_s1": merge_bit_eq,
        "link_ms": s2_link_ms,
        "e2e_wall_ms": s2_e2e_wall_ms,
        "n5_w11_bytes": N5_W11.stat().st_size,
        "n5_w11_sha256": sha256(N5_W11),
        "all_13_seg_counts_match_o2": all(r["seg_matches_s1_o2"] for r in s2_records),
        "modules": s2_records,
        "smoke": n5_smoke,
    }
    save_results(res)

    # =========================================================================
    # STAGE 2B: Native 1-Module Body Edits on n4_o2 (m11 leaf + m06 mid-stack)
    # =========================================================================
    print("\n=== STAGE 2B-1: Native 1-Module Leaf Edit (m11: stage=read -> stage=read_w11) ===", flush=True)
    shas_before_m11 = {m: sha256(OBJ_S2 / f"{m}.o") for m in MOD_NAMES[:12]}
    m11_orig = src_paths["m11"].read_text(encoding="utf-8")
    assert '"stage=read ms="' in m11_orig, "Expected 'stage=read ms=' in m11"
    m11_edit_src = SRC_DIR / "m11_edit.bend"
    m11_edit_src.write_text(m11_orig.replace('"stage=read ms="', '"stage=read_w11 ms="', 1), encoding="utf-8")

    m11_edit_o = OBJ_S2B / "m11_edit.o"
    t_e1 = time.perf_counter()
    m11_cmp_ms, m11_err = run_native(
        N4_O2,
        ["--trace", "x86-module-fast", str(m11_edit_src), str(BASE_FILE), "cache", str(carriers[12][0]), carriers[12][1], str(fid_bases["m11"]), "m11"],
        out_file=m11_edit_o,
        err_file=LOG_DIR / "s2b_m11_edit.err",
        cpu=0,
        timeout=240,
    )
    shas_after_m11 = {m: sha256(OBJ_S2 / f"{m}.o") for m in MOD_NAMES[:12]}
    assert shas_before_m11 == shas_after_m11, "Upstream .o SHA-256 changed on m11 edit!"
    n5_m11_bin = OBJ_S2B / "n5_w11_m11_edit"
    m11_lk_ms = link_compiler(merge_s2, [*s2_objs[:12], m11_edit_o], n5_m11_bin, cpu=0)
    m11_tot_ms = round((time.perf_counter() - t_e1) * 1000.0, 1)
    m11_sm = smoke_slice(n5_m11_bin, "n5_m11_edit", mode="x86-object-fast", cpu=0)
    obs_read_w11 = any("stage=read_w11" in ln for ln in m11_sm["trace_lines"])
    assert obs_read_w11, f"Did not observe stage=read_w11 in trace: {m11_sm['trace_lines']}"
    print(
        f"  STAGE 2B-1 PASS! 12/13 .o SHA-256 identical | m11_rebuild={m11_cmp_ms} ms | relink={m11_lk_ms} ms "
        f"| total={m11_tot_ms} ms | observed stage=read_w11 & out={m11_sm['out']}",
        flush=True,
    )

    print("\n=== STAGE 2B-2: Native Mid-Stack Body-Only Edit (m06: interface-preserving edit) ===", flush=True)
    m06_idx = MOD_NAMES.index("m06")
    other_12_m06 = [m for m in MOD_NAMES if m != "m06"]
    shas_before_m06 = {m: sha256(OBJ_S2 / f"{m}.o") for m in other_12_m06}
    m06_orig = src_paths["m06"].read_text(encoding="utf-8")
    # Harmless body-only edit in m06_exp.bend: comment + U32.add(0, 0) in main()
    assert m06_orig.endswith("  0\n"), "Expected m06_exp.bend to end with '  0\\n'"
    m06_edited = "# W11-C mid-stack body-only edit\n" + m06_orig[:-4] + "  U32.add(0, 0)\n"
    m06_edit_src = SRC_DIR / "m06_edit.bend"
    m06_edit_src.write_text(m06_edited, encoding="utf-8")

    # 1. Verify native n4_o2 x86-iface on m06 produces UNCHANGED .p130 stamp!
    m06_edit_p130 = OBJ_S2B / "m06_edit.p130"
    m06_iface_ms, m06_iface_err = run_native(
        N4_O2,
        ["x86-iface", str(m06_edit_src), str(BASE_FILE), "cache", str(carriers[m06_idx][0]), carriers[m06_idx][1]],
        out_file=m06_edit_p130,
        err_file=LOG_DIR / "s2b_m06_iface.err",
        cpu=0,
        timeout=240,
    )
    m06_edit_info = parse_p130(m06_edit_p130)
    m06_orig_stamp = carriers[m06_idx + 1][1]
    assert m06_edit_info["stamp"] == m06_orig_stamp, f"m06 .p130 stamp changed! {m06_edit_info['stamp']} != {m06_orig_stamp}"

    # 2. Rebuild ONLY m06.o + relink!
    m06_edit_o = OBJ_S2B / "m06_edit.o"
    t_e2 = time.perf_counter()
    m06_cmp_ms, m06_err = run_native(
        N4_O2,
        ["--trace", "x86-module-fast", str(m06_edit_src), str(BASE_FILE), "cache", str(carriers[m06_idx][0]), carriers[m06_idx][1], str(fid_bases["m06"]), "m06"],
        out_file=m06_edit_o,
        err_file=LOG_DIR / "s2b_m06_edit.err",
        cpu=0,
        timeout=240,
    )
    shas_after_m06 = {m: sha256(OBJ_S2 / f"{m}.o") for m in other_12_m06}
    assert shas_before_m06 == shas_after_m06, "Other 12 .o SHA-256 changed on m06 edit!"
    m06_obj_changed = sha256(m06_edit_o) != sha256(OBJ_S2 / "m06.o")
    mod_objs_m06 = [m06_edit_o if m == "m06" else (OBJ_S2 / f"{m}.o") for m in MOD_NAMES]
    n5_m06_bin = OBJ_S2B / "n5_w11_m06_edit"
    m06_lk_ms = link_compiler(merge_s2, mod_objs_m06, n5_m06_bin, cpu=0)
    m06_tot_ms = round((time.perf_counter() - t_e2) * 1000.0, 1)
    m06_sm = smoke_slice(n5_m06_bin, "n5_m06_edit", mode="x86-object-fast", cpu=0)
    print(
        f"  STAGE 2B-2 PASS! m06 .p130 stamp UNCHANGED ({m06_iface_ms} ms) | 12/13 .o SHA-256 identical "
        f"| m06.o changed={m06_obj_changed} | m06_rebuild={m06_cmp_ms} ms | relink={m06_lk_ms} ms "
        f"| total={m06_tot_ms} ms | out={m06_sm['out']}",
        flush=True,
    )

    res["stage2b_native_edits"] = {
        "m11_leaf_edit": {
            "reused_12_of_13_sha256_identical": True,
            "m11_rebuild_ms": m11_cmp_ms,
            "m11_rebuild_bytes": m11_edit_o.stat().st_size,
            "m11_trace_stages": parse_trace_stages(m11_err),
            "relink_ms": m11_lk_ms,
            "total_edit_wall_ms": m11_tot_ms,
            "observed_stage_read_w11": obs_read_w11,
            "smoke": m11_sm,
        },
        "m06_midstack_edit": {
            "iface_check_ms": m06_iface_ms,
            "p130_stamp_unchanged": True,
            "reused_12_of_13_sha256_identical": True,
            "m06_obj_sha256_changed": m06_obj_changed,
            "m06_rebuild_ms": m06_cmp_ms,
            "m06_rebuild_bytes": m06_edit_o.stat().st_size,
            "m06_trace_stages": parse_trace_stages(m06_err),
            "relink_ms": m06_lk_ms,
            "total_edit_wall_ms": m06_tot_ms,
            "total_with_iface_check_ms": round(m06_iface_ms + m06_tot_ms, 1),
            "smoke": m06_sm,
        },
    }
    save_results(res)

    # =========================================================================
    # STAGE 2C: Native x86-iface Speed on n4_o2 (m00a, m00b, m01)
    # =========================================================================
    print("\n=== STAGE 2C: Native n4_o2 x86-iface Speed & Bit-Identical Check (m00a, m00b, m01 on CPU 0) ===", flush=True)
    s1_iface_map = {r["module"]: r for r in res["stage1_mint_n4_o2"]["iface_records"]}
    s2c_recs = []
    for idx in (0, 1, 2):
        m = MOD_NAMES[idx]
        in_carrier, in_stamp = carriers[idx]
        out_p130 = IFACE_S2C / f"{m}.p130"
        ms, _ = run_native(
            N4_O2,
            ["x86-iface", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp],
            out_file=out_p130,
            err_file=LOG_DIR / f"s2c_iface_{m}.err",
            cpu=0,
            timeout=240,
        )
        info = parse_p130(out_p130)
        s1_r = s1_iface_map[m]
        bit_eq = (info["sha256"] == s1_r["sha256"])
        assert bit_eq, f"Native x86-iface {m}.p130 SHA-256 mismatch vs Stage 1 JS!"
        spd_vs_js = round(s1_r["ms"] / ms, 2)
        rec = {
            "module": m,
            "native_ms": ms,
            "js_ms": s1_r["ms"],
            "speedup_vs_js": spd_vs_js,
            "bytes": info["bytes"],
            "bit_identical_to_s1_js": bit_eq,
        }
        s2c_recs.append(rec)
        print(f"  [S2C-iface cpu=0] {m}.p130: native={ms} ms vs JS={s1_r['ms']} ms ({spd_vs_js}x) | SHA-256 bit-identical=True", flush=True)

    # Include m06 native x86-iface from Stage 2B-2 as well!
    m06_js_ms = s1_iface_map["m06"]["ms"]
    m06_nat_spd = round(m06_js_ms / m06_iface_ms, 2)
    avg_iface_ratio = sum(r["native_ms"] for r in s2c_recs) / sum(r["js_ms"] for r in s2c_recs)
    proj_full_native_iface_ms = round(res["stage1_mint_n4_o2"]["iface_wall_ms"] * avg_iface_ratio, 1)
    # In pipelined true-cold on 5 cores: CPU 0 runs 12 x86-iface sequentially while CPUs 1..4 compile modules as .p130s arrive,
    # then CPU 0 joins; lower bound is max(proj_full_native_iface_ms + m11_native_ms, (proj_full_native_iface_ms + s2_sum_ms) / 5) + merge + link
    m11_nat_ms = s2_records_map["m11"]["ms"]
    proj_pipe_true_cold_ms = round(
        max(proj_full_native_iface_ms + m11_nat_ms, (proj_full_native_iface_ms + s2_sum_ms) / 5.0) + s2_merge_ms + s2_link_ms,
        1,
    )

    res["stage2c_native_iface"] = {
        "probes": s2c_recs,
        "m06_probe": {"native_ms": m06_iface_ms, "js_ms": m06_js_ms, "speedup_vs_js": m06_nat_spd},
        "native_to_js_ratio_m00a_m01": round(avg_iface_ratio, 3),
        "projected_12_iface_native_ms": proj_full_native_iface_ms,
        "projected_5core_pipelined_true_cold_ms": proj_pipe_true_cold_ms,
    }
    res["status"] = "PASSED"
    save_results(res)
    print(
        f"\nSTAGE 2C DONE! projected 12-mod native x86-iface = {proj_full_native_iface_ms/1000:.2f}s "
        f"| projected 5-core pipelined true-cold = {proj_pipe_true_cold_ms/1000:.2f}s",
        flush=True,
    )


def resume_stage1_from_hybrid(res: dict) -> tuple[list[tuple[Path, str]], dict[str, int], dict[str, dict]]:
    print("=== RESUMING STAGE 1C: Linking verified 11/13 -O2 + m08,m09 -O0 -> n4_o2 ===", flush=True)
    hyb_dir = TMP / "obj_s1_hybrid"
    carriers: list[tuple[Path, str]] = [(BASE_CARRIER, BASE_STAMP)]
    iface_records: list[dict] = []
    # Exact pass-1 iface times from task-28 + task-50
    known_iface_ms = {
        "m00a": 61578.1, "m00b": 53995.9, "m01": 29894.0, "m02": 207443.0,
        "m03": 232618.8, "m04": 99270.3, "m05": 240398.2, "m06": 212669.2,
        "m07": 282248.8, "m08": 206139.6, "m09": 220942.7, "m10": 107615.0,
    }
    for m in MOD_NAMES[:12]:
        p = IFACE_DIR / f"{m}.p130"
        info = parse_p130(p)
        iface_records.append({
            "module": m,
            "ms": known_iface_ms[m],
            "bytes": info["bytes"],
            "nodes": info["nodes"],
            "strings": info["strings"],
            "node_pct": round(100.0 * info["nodes"] / NODE_LIMIT, 2),
            "string_pct": round(100.0 * info["strings"] / STR_LIMIT, 2),
            "stamp": info["stamp"],
            "sha256": info["sha256"],
        })
        carriers.append((p, info["stamp"]))

    exact_fid_bases = {
        "m00a": 0, "m00b": 3393, "m01": 6368, "m02": 12291, "m03": 17879,
        "m04": 23078, "m05": 27540, "m06": 33497, "m07": 39209, "m08": 45554,
        "m09": 51489, "m10": 56320, "m11": 61351,
    }
    known_s1_ms = {
        "m00a": 47169.3, "m00b": 97807.8, "m01": 204840.3, "m02": 248087.0,
        "m03": 219745.2, "m04": 270503.2, "m05": 279732.5, "m06": 201657.1,
        "m07": 89279.8, "m08": 36703.9, "m09": 76639.7, "m10": 274957.7, "m11": 252665.4,
    }
    s1_records: list[dict] = []
    s1_records_map: dict[str, dict] = {}
    s1_objs: list[Path] = []
    for m in MOD_NAMES:
        is_hyb = m in ("m08", "m09")
        obj_p = (hyb_dir / f"{m}.o") if is_hyb else (OBJ_S1 / f"{m}.o")
        s1_objs.append(obj_p)
        segs = get_seg_count(obj_p, m)
        fb = exact_fid_bases[m]
        rec = {
            "module": m,
            "mode": "x86-module-fast" if is_hyb else "x86-module",
            "fid_base": fb,
            "seg_count": segs,
            "fid_end": fb + segs - 1,
            "ms": known_s1_ms[m],
            "bytes": obj_p.stat().st_size,
            "sha256": sha256(obj_p),
        }
        s1_records.append(rec)
        s1_records_map[m] = rec

    merge_s1 = OBJ_S1 / "merge_n4_o2.o"
    s1_link_ms = link_compiler(merge_s1, s1_objs, N4_O2, cpu=0)
    print(f"  LINKED {N4_O2} ({N4_O2.stat().st_size:,} B, 11/13 -O2 + m08,m09 -O0) | link={s1_link_ms} ms", flush=True)

    print("=== STAGE 1C: Smoke test n4_o2 on compiler_slice.bend (-O0 & -O2) + 3-family RT smoke ===", flush=True)
    sm_fast = smoke_slice(N4_O2, "n4_o2", mode="x86-object-fast", cpu=0)
    print(f"  n4_o2 slice -O0 PASS: out={sm_fast['out']} | compile={sm_fast['compile_ms']} ms (vs n3_w10 11,139.1 ms -> {round(11139.1 / sm_fast['compile_ms'], 2)}x!)", flush=True)
    sm_o2 = smoke_slice(N4_O2, "n4_o2", mode="x86-object", cpu=0)
    print(f"  n4_o2 slice -O2 PASS: out={sm_o2['out']} | compile={sm_o2['compile_ms']} ms | obj={sm_o2['obj_bytes']:,} B", flush=True)
    rt_smoke = smoke_runtime_programs(N4_O2, cpu=0)

    res["stage1_mint_n4_o2"] = {
        "iface_wall_ms": round(sum(r["ms"] for r in iface_records), 1),
        "iface_records": iface_records,
        "total_segs": sum(r["seg_count"] for r in s1_records),
        "fid_limit": FID_LIMIT,
        "max_fid_used": s1_records[-1]["fid_end"],
        "all_13_o2_compiled_and_linked": True,
        "n4_o2_composition": "11/13 -O2 (m00a,m00b,m01..m07,m10,m11) + 2/13 -O0 (m08,m09)",
        "p113d_0arity_stub_finding": {
            "affected_symbols": ["p113d_FID_w4g_live_base", "p113d_FID_x185_d_base"],
            "owner_module": "m07",
            "importing_modules": ["m08", "m09"],
            "root_cause": "m07 emits only T p111_FID_* (not p113d_FID_*) for 0-arity w4g_live_base & x185_d_base; m08/m09 see self-recursive .p130 stubs which falsely trigger p113d orphan jmp-self stubs under -O2",
            "all_13_o2_linked_bytes": 63680704,
            "n4_o2_11of13_bytes": N4_O2.stat().st_size,
        },
        "modules": s1_records,
        "merge_ms": 5090.2,
        "merge_bytes": merge_s1.stat().st_size,
        "merge_sha256": sha256(merge_s1),
        "link_ms": s1_link_ms,
        "n4_o2_bytes": N4_O2.stat().st_size,
        "n4_o2_sha256": sha256(N4_O2),
        "smoke_slice_o0": sm_fast,
        "smoke_slice_o2": sm_o2,
        "smoke_runtime_o2": rt_smoke,
    }
    save_results(res)
    return carriers, exact_fid_bases, s1_records_map


def main() -> None:
    for d in [OUT_DIR, NATIVE_DIR, SRC_DIR, IFACE_DIR, OBJ_S1, OBJ_S2, OBJ_S2B, IFACE_S2C, SMOKE_DIR, LOG_DIR]:
        d.mkdir(parents=True, exist_ok=True)

    src_paths, export_counts = prepare_sources()
    res = load_or_init_results(export_counts)
    mode = sys.argv[1] if len(sys.argv) > 1 else "--all"

    if mode == "--resume-from-hybrid":
        carriers, fid_bases, s1_records_map = resume_stage1_from_hybrid(res)
        run_stage2(res, src_paths, carriers, fid_bases, s1_records_map)
        print(f"\nALL STAGES COMPLETE! Results saved to {RESULTS_JSON}", flush=True)
        return

    if mode in ("--stage1", "--all"):
        carriers, fid_bases, s1_records_map = run_stage1(res, src_paths)
    else:
        s1 = res["stage1_mint_n4_o2"]
        carriers = [(BASE_CARRIER, BASE_STAMP)] + [(IFACE_DIR / f"{r['module']}.p130", r["stamp"]) for r in s1["iface_records"]]
        fid_bases = {r["module"]: r["fid_base"] for r in s1["modules"]}
        s1_records_map = {r["module"]: r for r in s1["modules"]}

    if mode in ("--stage2", "--all"):
        run_stage2(res, src_paths, carriers, fid_bases, s1_records_map)

    print(f"\nALL STAGES COMPLETE! Results saved to {RESULTS_JSON}", flush=True)


if __name__ == "__main__":
    main()
