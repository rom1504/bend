#!/usr/bin/env python3
"""W13-INT: Mint Full 14/14 -O2 Native n5_o2 (k14_wave13) & Run 7-Core Native
Self-Reproduction (Warm-.p130 2A, Zero-Cache Pipelined True-Cold 2B, 1-Module Edits 2C).

Dedicated CPUs: 0, 1, 2, 3, 4, 5, 6 ONLY (NEVER CPU 7).
RAM Guardrail: Stage 1 JS (-O2) capped to at most 4 concurrent Node V8 processes (CPUs 0..3,
--max-old-space-size=4096). Stage 2 native n5_o2 uses all 7 CPUs (0..6).
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
API = ROOT / "selfhost/build/agy/wave13_unified/api.mjs"
CLI = ROOT / "research/agy/w10_mod_bend/compose_w10/run_w10_cli.mjs"
NODE = "/home/ai/.nvm/versions/node/v22.22.2/bin/node"
K14_DIR = ROOT / "research/agy/w10_mod_bend/k14_wave13"
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

OUT_DIR = ROOT / "research/agy/w13_campaign/w13_int_n5_o2"
RESULTS_JSON = OUT_DIR / "results.json"
NATIVE_DIR = ROOT / "selfhost/build/agy/wave13-native-mod"
N5_O2 = NATIVE_DIR / "n5_o2"
N6_W13 = NATIVE_DIR / "n6_w13"

TMP = Path("/tmp/agy_w13int")
SRC_DIR = TMP / "src"
IFACE_S1 = TMP / "iface_s1"
OBJ_S1 = TMP / "obj_s1_o2"
OBJ_S2A = TMP / "obj_s2a_o0"
IFACE_S2B = TMP / "iface_s2b_cold"
OBJ_S2B = TMP / "obj_s2b_cold"
OBJ_S2C = TMP / "obj_s2c_edit"
SMOKE_DIR = TMP / "smoke"
LOG_DIR = TMP / "logs"

CACHE_W13 = Path("/tmp/agy_k14_w13_cache")
CACHE_W11 = Path("/tmp/agy_k13_w11_cache")

ALLOWED_CPUS = (0, 1, 2, 3, 4, 5, 6)
JS_CPUS = (0, 1, 2, 3)
MOD_NAMES = [
    "m00a", "m00b", "m01", "m02", "m03", "m04",
    "m05a", "m05b", "m06", "m07", "m08", "m09", "m10", "m11",
]
K = len(MOD_NAMES)
assert K == 14
FID_LIMIT = 65532
NODE_LIMIT = 1048576
STR_LIMIT = 65536

# Tight provisional fid_bases for K=14 with w6_dedup(fuel=256, rounds=2) (~62-63k total <= 65,531); auto-redo if any overlap/overflow.
PROVISIONAL_FID_BASES = {
    "m00a": 0,
    "m00b": 3450,
    "m01": 6450,
    "m02": 12450,
    "m03": 18050,
    "m04": 23350,
    "m05a": 27900,
    "m05b": 31200,
    "m06": 34900,
    "m07": 40800,
    "m08": 47100,
    "m09": 53100,
    "m10": 58200,
    "m11": 62000,
}

# Exact contiguous -O0 fid_bases for Stage 2 (total=65,234 <= 65,532; m00b/m01/m02 have +7/+29/+18 segs in -O0 vs -O2)
O0_FID_BASES = {
    "m00a": 0,
    "m00b": 3426,
    "m01": 6428,
    "m02": 12381,
    "m03": 17987,
    "m04": 23123,
    "m05a": 27507,
    "m05b": 30568,
    "m06": 34085,
    "m07": 39837,
    "m08": 46227,
    "m09": 52142,
    "m10": 57084,
    "m11": 61935,
}
# Measured native -O0 weights (descending) for optimal 7-core LPT bin-packing
O0_LPT_ORDER = ["m07", "m01", "m02", "m03", "m10", "m06", "m11", "m04", "m08", "m09", "m05b", "m00b", "m05a", "m00a"]

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


def run_js_cli(
    args: list[str],
    out_file: Path,
    err_file: Path,
    cpu: int,
    max_mb: int = 4096,
    timeout: int = 480,
) -> tuple[float, str]:
    assert cpu in JS_CPUS, f"Disallowed JS CPU {cpu}"
    cmd = [
        "timeout", str(timeout),
        "bash", "-c",
        'ulimit -s 65536 && exec taskset -c "$1" "$2" --stack-size=16384 --max-old-space-size="$3" "$4" "$5" "${@:6}"',
        "_", str(cpu), NODE, str(max_mb), str(CLI), str(API), *args,
    ]
    t0 = time.perf_counter()
    with out_file.open("wb") as of, err_file.open("wb") as ef:
        r = subprocess.run(cmd, stdout=of, stderr=ef, cwd=ROOT)
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
    timeout: int = 180,
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
        [
            "timeout", "60", "taskset", "-c", str(cpu), CC, "-O2", "-no-pie",
            str(merge_o), *[str(o) for o in mod_objs], str(RT), "-o", str(out_bin), "-lm", "-lpthread",
        ],
        capture_output=True, text=True,
    )
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    if r.returncode != 0:
        raise RuntimeError(f"gcc-10 link failed (rc={r.returncode}): {r.stderr[-1500:]}")
    if r.stderr.strip():
        print(f"  [WARN] gcc-10 link stderr: {r.stderr.strip()[:400]}", flush=True)
    return ms


def compute_reachable_names() -> set[str]:
    """Compute exact set of def/law names reachable from m11's main() (< 0.5s)."""
    from collections import deque
    sys.path.insert(0, str(OUT_DIR))
    from split_k14_w13 import parse_compiler_bend, strip_strings_and_comments, IDENT_RE
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


def prepare_sources() -> tuple[dict[str, Path], dict[str, int]]:
    SRC_DIR.mkdir(parents=True, exist_ok=True)
    reach_names = compute_reachable_names()
    types_text = (K14_DIR / "types.bend").read_text(encoding="utf-8")
    mod_texts = [(K14_DIR / f"{m}.bend").read_text(encoding="utf-8") for m in MOD_NAMES]
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
        print(f"  [n5_o2 RT {fam:<10}] compile={cmp_ms:7.1f} ms | run_median={med:7.2f} ms (runs={runs}) | checksum OK", flush=True)
    return out_res


def save_results(res: dict) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    RESULTS_JSON.write_text(json.dumps(res, indent=2) + "\n", encoding="utf-8")


def run_stage1(res: dict, src_paths: dict[str, Path]) -> tuple[list[tuple[Path, str]], dict[str, int], dict[str, dict]]:
    print("=== STAGE 1: Pipelined Mint of Full 14/14 -O2 Native n5_o2 (4-way V8 cap on CPUs 0..3) ===", flush=True)
    carriers: list[tuple[Path, str] | None] = [None] * K
    carriers[0] = (BASE_CARRIER, BASE_STAMP)
    iface_records: list[dict] = []
    s1_fid_bases = dict(PROVISIONAL_FID_BASES)
    s1_records_map: dict[str, dict] = {}
    work_q: queue.Queue[int | None] = queue.Queue()
    work_q.put(0)  # m00a ready immediately (uses base.p130)

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
            f"  [{tag_prefix} -O2 cpu={cpu}] {m:<4}.o: {rec['bytes']:,} B | fid=[{rec['fid_base']}..{rec['fid_end']}] "
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
    worker_cpus = (1, 2, 3)  # + CPU 0 running x86-iface = max 4 concurrent Node V8 processes
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(worker_cpus)) as ex:
        futs = [ex.submit(o2_worker, cpu) for cpu in worker_cpus]
        try:
            t_iface0 = time.perf_counter()
            for i in range(K - 1):  # 0..12 => m00a..m10
                m = MOD_NAMES[i]
                in_carrier, in_stamp = carriers[i]  # type: ignore[misc]
                out_p130 = IFACE_S1 / f"{m}.p130"
                err_f = LOG_DIR / f"s1_iface_{m}.err"
                if out_p130.exists() and out_p130.stat().st_size > 1_000_000:
                    info = parse_p130(out_p130)
                    stamp = info["stamp"]
                    ms = 0.0
                    tag = "s1-iface-reuse"
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
                    tag = "s1-iface"
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
                    f"  [{tag} {i+1:2d}/13 cpu=0] {m:<4}.p130: {info['bytes']:,} B | nodes={info['nodes']:,} ({rec['node_pct']}%) "
                    f"| strs={info['strings']:,} ({rec['string_pct']}%) | {ms} ms -> queued {MOD_NAMES[i+1]}",
                    flush=True,
                )
            iface_wall_ms = round((time.perf_counter() - t_iface0) * 1000.0, 1)
            print(f"  [s1-iface DONE] 13/13 .p130 ready ({iface_wall_ms} ms); CPU 0 joining -O2 pool!", flush=True)

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

    s1_records = [s1_records_map[m] for m in MOD_NAMES]
    total_segs = sum(r["seg_count"] for r in s1_records)
    print(f"  [FID check] total_segs = {total_segs:,} / {FID_LIMIT:,}", flush=True)
    assert total_segs <= FID_LIMIT, f"Total segs {total_segs} > {FID_LIMIT}!"

    overlap_or_overflow = any(
        s1_records[i]["fid_end"] >= s1_records[i + 1]["fid_base"] for i in range(K - 1)
    ) or (s1_records[K - 1]["fid_end"] >= FID_LIMIT)

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
        print(f"  Recompiling {len(to_redo)} modules with exact contiguous fid_bases on CPUs 0..3: {redo_modules}", flush=True)
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
        with concurrent.futures.ThreadPoolExecutor(max_workers=len(JS_CPUS)) as ex:
            for f in [ex.submit(worker_redo, cpu) for cpu in JS_CPUS]:
                f.result()
        redo_wall_ms = round((time.perf_counter() - t_r0) * 1000.0, 1)
        s1_records = [s1_records_map[m] for m in MOD_NAMES]

    s1_total_wall_ms = round((time.perf_counter() - t_pipe0) * 1000.0, 1)
    s1_objs = [OBJ_S1 / f"{m}.o" for m in MOD_NAMES]

    print("=== STAGE 1B: wave13_unified x86-merge-obj (m11 FIRST!) + gcc-10 -O2 -no-pie -> n5_o2 ===", flush=True)
    merge_s1 = OBJ_S1 / "merge_n5_o2.o"
    s1_merge_ms, _ = run_js_cli(
        ["x86-merge-obj", "m11", "m11", *MOD_NAMES[: K - 1]],
        out_file=merge_s1,
        err_file=LOG_DIR / "s1_merge.err",
        cpu=0,
        max_mb=4096,
        timeout=60,
    )
    NATIVE_DIR.mkdir(parents=True, exist_ok=True)
    s1_link_ms = link_compiler(merge_s1, s1_objs, N5_O2, cpu=0)
    print(f"  LINKED {N5_O2} ({N5_O2.stat().st_size:,} B) | merge={s1_merge_ms} ms | link={s1_link_ms} ms", flush=True)

    print("=== STAGE 1C: Smoke test n5_o2 on compiler_slice.bend (-O0 & -O2) + 3-family RT smoke ===", flush=True)
    sm_fast = smoke_slice(N5_O2, "n5_o2", mode="x86-object-fast", cpu=0)
    print(
        f"  n5_o2 slice -O0 PASS: out={sm_fast['out']} | compile={sm_fast['compile_ms']} ms "
        f"(vs n4_o2 8,013 ms -> {round(8013.0 / sm_fast['compile_ms'], 2)}x!)",
        flush=True,
    )
    sm_o2 = smoke_slice(N5_O2, "n5_o2", mode="x86-object", cpu=0)
    print(f"  n5_o2 slice -O2 PASS: out={sm_o2['out']} | compile={sm_o2['compile_ms']} ms | obj={sm_o2['obj_bytes']:,} B", flush=True)
    rt_smoke = smoke_runtime_programs(N5_O2, cpu=0)

    res["stage1_mint_n5_o2"] = {
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
        "all_14_o2": all(r["mode"] == "x86-module" for r in s1_records),
        "modules": s1_records,
        "merge_ms": s1_merge_ms,
        "merge_bytes": merge_s1.stat().st_size,
        "merge_sha256": sha256(merge_s1),
        "link_ms": s1_link_ms,
        "n5_o2_bytes": N5_O2.stat().st_size,
        "n5_o2_sha256": sha256(N5_O2),
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
    # STAGE 2A: Warm-.p130 7-Core Native Cold Self-Reproduction (n5_o2 -> n6_w13)
    # =========================================================================
    print("\n=== STAGE 2A: Warm-.p130 7-Core Native Cold (n5_o2 -> n6_w13, CPUs 0..6, 0 JS/C/objcopy) ===", flush=True)
    s2a_records_map: dict[str, dict] = {}
    work_q2a: queue.Queue[int] = queue.Queue()
    order_s2a = [MOD_NAMES.index(m) for m in O0_LPT_ORDER]
    for i in order_s2a:
        work_q2a.put(i)

    def worker_s2a(cpu: int) -> None:
        while True:
            try:
                i = work_q2a.get_nowait()
            except queue.Empty:
                return
            m = MOD_NAMES[i]
            in_carrier, in_stamp = carriers[i]
            fb = fid_bases[m]
            out_o = OBJ_S2A / f"{m}.o"
            err_f = LOG_DIR / f"s2a_{m}.err"
            ms, stderr = run_native(
                N5_O2,
                ["--trace", "x86-module-fast", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fb), m],
                out_file=out_o,
                err_file=err_f,
                cpu=cpu,
                timeout=180,
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
            s2a_records_map[m] = rec
            print(
                f"  [S2A-native cpu={cpu}] {m:<4}.o: {rec['bytes']:,} B | segs={segs:,} (eq_o2={rec['seg_matches_s1_o2']}) | {ms} ms",
                flush=True,
            )

    t_2a0 = time.perf_counter()
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(ALLOWED_CPUS)) as ex:
        futs = [ex.submit(worker_s2a, cpu) for cpu in ALLOWED_CPUS]
        for f in futs:
            f.result()
    s2a_compile_wall_ms = round((time.perf_counter() - t_2a0) * 1000.0, 1)
    s2a_records = [s2a_records_map[m] for m in MOD_NAMES]
    s2a_total_segs = sum(r["seg_count"] for r in s2a_records)
    assert s2a_total_segs <= FID_LIMIT, f"S2A total_segs {s2a_total_segs} > {FID_LIMIT}"
    for idx in range(K - 1):
        assert s2a_records[idx]["fid_end"] < s2a_records[idx + 1]["fid_base"], (
            f"S2A FID overlap: {MOD_NAMES[idx]} end={s2a_records[idx]['fid_end']} >= {MOD_NAMES[idx+1]} base={s2a_records[idx+1]['fid_base']}"
        )
    assert s2a_records[K - 1]["fid_end"] < FID_LIMIT, f"S2A m11 fid_end {s2a_records[K-1]['fid_end']} >= {FID_LIMIT}"
    s2a_objs = [OBJ_S2A / f"{m}.o" for m in MOD_NAMES]

    merge_s2a = OBJ_S2A / "merge_n6_w13.o"
    s2a_merge_ms, _ = run_native(
        N5_O2,
        ["x86-merge-obj", "m11", "m11", *MOD_NAMES[: K - 1]],
        out_file=merge_s2a,
        err_file=LOG_DIR / "s2a_merge.err",
        cpu=0,
        timeout=60,
    )
    s2a_link_ms = link_compiler(merge_s2a, s2a_objs, N6_W13, cpu=0)
    s2a_e2e_wall_ms = round((time.perf_counter() - t_2a0) * 1000.0, 1)
    s2a_sum_ms = round(sum(r["ms"] for r in s2a_records), 1)
    s2a_par_spd = round(s2a_sum_ms / s2a_compile_wall_ms, 2)
    merge_bit_eq = sha256(merge_s2a) == res["stage1_mint_n5_o2"]["merge_sha256"]

    print(
        f"  LINKED {N6_W13} ({N6_W13.stat().st_size:,} B) | 7-core compile={s2a_compile_wall_ms} ms "
        f"(sum={s2a_sum_ms} ms, {s2a_par_spd}x) | merge={s2a_merge_ms} ms (eq_s1={merge_bit_eq}) "
        f"| link={s2a_link_ms} ms | E2E={s2a_e2e_wall_ms} ms ({s2a_e2e_wall_ms/1000.0:.2f} s)",
        flush=True,
    )
    n6_smoke = smoke_slice(N6_W13, "n6_w13", mode="x86-object-fast", cpu=0)
    print(f"  n6_w13 SMOKE PASS: out={n6_smoke['out']} | compile={n6_smoke['compile_ms']} ms", flush=True)

    res["stage2a_warm_p130_7core_native"] = {
        "parallel_cpus": list(ALLOWED_CPUS),
        "schedule_order": [MOD_NAMES[i] for i in order_s2a],
        "compile_wall_ms": s2a_compile_wall_ms,
        "compile_sum_ms": s2a_sum_ms,
        "speedup_vs_seq_native": s2a_par_spd,
        "merge_ms": s2a_merge_ms,
        "merge_bytes": merge_s2a.stat().st_size,
        "merge_bit_identical_to_s1": merge_bit_eq,
        "link_ms": s2a_link_ms,
        "e2e_wall_ms": s2a_e2e_wall_ms,
        "n6_w13_bytes": N6_W13.stat().st_size,
        "n6_w13_sha256": sha256(N6_W13),
        "all_14_seg_counts_match_o2": all(r["seg_matches_s1_o2"] for r in s2a_records),
        "modules": s2a_records,
        "smoke": n6_smoke,
    }
    save_results(res)

    # =========================================================================
    # STAGE 2B: ZERO-CACHE TRUE-COLD PIPELINED 100% NATIVE (.bend -> n6_cold)
    # =========================================================================
    print("\n=== STAGE 2B: ZERO-CACHE TRUE-COLD PIPELINED 100% NATIVE (CPU 0 iface + CPUs 1..6 compile -> n6_cold) ===", flush=True)
    cold_carriers: list[tuple[Path, str] | None] = [None] * K
    cold_carriers[0] = (BASE_CARRIER, BASE_STAMP)
    cold_iface_records: list[dict] = []
    cold_mod_map: dict[str, dict] = {}
    cold_q: queue.Queue[int | None] = queue.Queue()
    cold_q.put(0)  # m00a ready at t=0!

    def compile_cold_o0(i: int, cpu: int) -> dict:
        m = MOD_NAMES[i]
        in_carrier, in_stamp = cold_carriers[i]  # type: ignore[misc]
        fb = fid_bases[m]
        out_o = OBJ_S2B / f"{m}.o"
        err_f = LOG_DIR / f"s2b_cold_{m}.err"
        ms, stderr = run_native(
            N5_O2,
            ["--trace", "x86-module-fast", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fb), m],
            out_file=out_o,
            err_file=err_f,
            cpu=cpu,
            timeout=180,
        )
        h = sha256(out_o)
        bit_eq_2a = (h == s2a_records_map[m]["sha256"])
        rec = {
            "module": m,
            "cpu": cpu,
            "ms": ms,
            "bytes": out_o.stat().st_size,
            "sha256": h,
            "bit_identical_to_s2a": bit_eq_2a,
            "trace_stages": parse_trace_stages(stderr),
        }
        print(
            f"  [S2B-cold cpu={cpu}] {m:<4}.o: {rec['bytes']:,} B | {ms} ms | eq_2a={bit_eq_2a}",
            flush=True,
        )
        return rec

    def cold_worker(cpu: int) -> None:
        while True:
            item = cold_q.get()
            if item is None:
                return
            m = MOD_NAMES[item]
            cold_mod_map[m] = compile_cold_o0(item, cpu)

    t_2b0 = time.perf_counter()
    cold_worker_cpus = (1, 2, 3, 4, 5, 6)
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(cold_worker_cpus)) as ex:
        futs = [ex.submit(cold_worker, cpu) for cpu in cold_worker_cpus]
        try:
            t_cif0 = time.perf_counter()
            for i in range(K - 1):  # 0..12 => m00a..m10
                m = MOD_NAMES[i]
                in_carrier, in_stamp = cold_carriers[i]  # type: ignore[misc]
                out_p130 = IFACE_S2B / f"{m}.p130"
                err_f = LOG_DIR / f"s2b_iface_{m}.err"
                ms, stderr = run_native(
                    N5_O2,
                    ["x86-iface", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp],
                    out_file=out_p130,
                    err_file=err_f,
                    cpu=0,
                    timeout=180,
                )
                stamp = stderr.splitlines()[-1].strip()
                info = parse_p130(out_p130)
                assert info["stamp"] == stamp, f"Cold iface stamp mismatch for {m}: {info['stamp']} != {stamp}"
                js_sha = res["stage1_mint_n5_o2"]["iface_records"][i]["sha256"]
                p130_eq_js = (info["sha256"] == js_sha)
                cold_iface_records.append({
                    "module": m,
                    "ms": ms,
                    "bytes": info["bytes"],
                    "nodes": info["nodes"],
                    "strings": info["strings"],
                    "stamp": stamp,
                    "sha256": info["sha256"],
                    "bit_identical_to_s1_js": p130_eq_js,
                })
                cold_carriers[i + 1] = (out_p130, stamp)
                cold_q.put(i + 1)
                print(
                    f"  [S2B-iface {i+1:2d}/13 cpu=0] {m:<4}.p130: {info['bytes']:,} B | {ms} ms | eq_js={p130_eq_js} -> queued {MOD_NAMES[i+1]}",
                    flush=True,
                )
            cold_iface_wall_ms = round((time.perf_counter() - t_cif0) * 1000.0, 1)
            print(f"  [S2B-iface DONE] 13/13 native .p130 ready ({cold_iface_wall_ms} ms); CPU 0 joining compile pool!", flush=True)
            while True:
                try:
                    item = cold_q.get_nowait()
                except queue.Empty:
                    break
                if item is None:
                    break
                m = MOD_NAMES[item]
                cold_mod_map[m] = compile_cold_o0(item, 0)
        finally:
            for _ in range(len(cold_worker_cpus)):
                cold_q.put(None)
        for f in futs:
            f.result()

    cold_compile_wall_ms = round((time.perf_counter() - t_2b0) * 1000.0, 1)
    cold_mod_records = [cold_mod_map[m] for m in MOD_NAMES]
    cold_objs = [OBJ_S2B / f"{m}.o" for m in MOD_NAMES]

    merge_s2b = OBJ_S2B / "merge_n6_cold.o"
    cold_merge_ms, _ = run_native(
        N5_O2,
        ["x86-merge-obj", "m11", "m11", *MOD_NAMES[: K - 1]],
        out_file=merge_s2b,
        err_file=LOG_DIR / "s2b_merge.err",
        cpu=0,
        timeout=60,
    )
    n6_cold_bin = OBJ_S2B / "n6_cold"
    cold_link_ms = link_compiler(merge_s2b, cold_objs, n6_cold_bin, cpu=0)
    cold_e2e_wall_ms = round((time.perf_counter() - t_2b0) * 1000.0, 1)

    all_o_eq = all(r["bit_identical_to_s2a"] for r in cold_mod_records)
    all_p130_eq = all(r["bit_identical_to_s1_js"] for r in cold_iface_records)
    cold_smoke = smoke_slice(n6_cold_bin, "n6_cold", mode="x86-object-fast", cpu=0)
    print(
        f"  STAGE 2B TRUE-COLD DONE! E2E={cold_e2e_wall_ms} ms ({cold_e2e_wall_ms/1000.0:.2f} s) | "
        f"iface_chain={cold_iface_wall_ms} ms | pipe_compile={cold_compile_wall_ms} ms | merge={cold_merge_ms} ms | link={cold_link_ms} ms | "
        f"14/14 .o bit-identical to 2A={all_o_eq} | 13/13 .p130 bit-identical to JS={all_p130_eq} | smoke out={cold_smoke['out']}",
        flush=True,
    )
    assert all_o_eq, "Cold pipelined .o SHA-256 mismatch vs Stage 2A!"

    res["stage2b_true_cold_pipelined_7core_native"] = {
        "iface_cpu": 0,
        "worker_cpus": list(cold_worker_cpus),
        "iface_chain_wall_ms": cold_iface_wall_ms,
        "pipelined_compile_wall_ms": cold_compile_wall_ms,
        "merge_ms": cold_merge_ms,
        "link_ms": cold_link_ms,
        "e2e_wall_ms": cold_e2e_wall_ms,
        "all_14_obj_bit_identical_to_s2a": all_o_eq,
        "all_13_p130_bit_identical_to_s1_js": all_p130_eq,
        "n6_cold_bytes": n6_cold_bin.stat().st_size,
        "n6_cold_sha256": sha256(n6_cold_bin),
        "iface_records": cold_iface_records,
        "modules": cold_mod_records,
        "smoke": cold_smoke,
    }
    save_results(res)

    # =========================================================================
    # STAGE 2C: Native 1-Module Body Edits on n5_o2 (m11 leaf + m06 mid-stack)
    # =========================================================================
    print("\n=== STAGE 2C-1: Native 1-Module Leaf Edit (m11: stage=read -> stage=read_w13) ===", flush=True)
    shas_before_m11 = {m: sha256(OBJ_S2A / f"{m}.o") for m in MOD_NAMES[: K - 1]}
    m11_orig = src_paths["m11"].read_text(encoding="utf-8")
    assert '"stage=read ms="' in m11_orig, "Expected 'stage=read ms=' in m11"
    m11_edit_src = SRC_DIR / "m11_edit.bend"
    m11_edit_src.write_text(m11_orig.replace('"stage=read ms="', '"stage=read_w13 ms="', 1), encoding="utf-8")

    m11_edit_o = OBJ_S2C / "m11_edit.o"
    t_e1 = time.perf_counter()
    m11_cmp_ms, m11_err = run_native(
        N5_O2,
        ["--trace", "x86-module-fast", str(m11_edit_src), str(BASE_FILE), "cache", str(carriers[K - 1][0]), carriers[K - 1][1], str(fid_bases["m11"]), "m11"],
        out_file=m11_edit_o,
        err_file=LOG_DIR / "s2c_m11_edit.err",
        cpu=0,
        timeout=180,
    )
    shas_after_m11 = {m: sha256(OBJ_S2A / f"{m}.o") for m in MOD_NAMES[: K - 1]}
    assert shas_before_m11 == shas_after_m11, "Upstream .o SHA-256 changed on m11 edit!"
    n6_m11_bin = OBJ_S2C / "n6_w13_m11_edit"
    m11_lk_ms = link_compiler(merge_s2a, [*s2a_objs[: K - 1], m11_edit_o], n6_m11_bin, cpu=0)
    m11_tot_ms = round((time.perf_counter() - t_e1) * 1000.0, 1)
    m11_sm = smoke_slice(n6_m11_bin, "n6_m11_edit", mode="x86-object-fast", cpu=0)
    obs_read_w13 = any("stage=read_w13" in ln for ln in m11_sm["trace_lines"])
    assert obs_read_w13, f"Did not observe stage=read_w13 in trace: {m11_sm['trace_lines']}"
    print(
        f"  STAGE 2C-1 PASS! 13/14 .o SHA-256 identical | m11_rebuild={m11_cmp_ms} ms | relink={m11_lk_ms} ms "
        f"| total={m11_tot_ms} ms ({m11_tot_ms/1000.0:.2f} s) | observed stage=read_w13 & out={m11_sm['out']}",
        flush=True,
    )

    print("\n=== STAGE 2C-2: Native Mid-Stack Body-Only Edit (m06: interface-preserving edit) ===", flush=True)
    m06_idx = MOD_NAMES.index("m06")
    other_13_m06 = [m for m in MOD_NAMES if m != "m06"]
    shas_before_m06 = {m: sha256(OBJ_S2A / f"{m}.o") for m in other_13_m06}
    m06_orig = src_paths["m06"].read_text(encoding="utf-8")
    assert m06_orig.endswith("  0\n"), "Expected m06_exp.bend to end with '  0\\n'"
    m06_edited = "# W13-INT mid-stack body-only edit\n" + m06_orig[:-4] + "  U32.add(0, 0)\n"
    m06_edit_src = SRC_DIR / "m06_edit.bend"
    m06_edit_src.write_text(m06_edited, encoding="utf-8")

    m06_edit_p130 = OBJ_S2C / "m06_edit.p130"
    m06_iface_ms, _ = run_native(
        N5_O2,
        ["x86-iface", str(m06_edit_src), str(BASE_FILE), "cache", str(carriers[m06_idx][0]), carriers[m06_idx][1]],
        out_file=m06_edit_p130,
        err_file=LOG_DIR / "s2c_m06_iface.err",
        cpu=0,
        timeout=180,
    )
    m06_edit_info = parse_p130(m06_edit_p130)
    m06_orig_stamp = carriers[m06_idx + 1][1]
    assert m06_edit_info["stamp"] == m06_orig_stamp, f"m06 .p130 stamp changed! {m06_edit_info['stamp']} != {m06_orig_stamp}"

    m06_edit_o = OBJ_S2C / "m06_edit.o"
    t_e2 = time.perf_counter()
    m06_cmp_ms, m06_err = run_native(
        N5_O2,
        ["--trace", "x86-module-fast", str(m06_edit_src), str(BASE_FILE), "cache", str(carriers[m06_idx][0]), carriers[m06_idx][1], str(fid_bases["m06"]), "m06"],
        out_file=m06_edit_o,
        err_file=LOG_DIR / "s2c_m06_edit.err",
        cpu=0,
        timeout=180,
    )
    shas_after_m06 = {m: sha256(OBJ_S2A / f"{m}.o") for m in other_13_m06}
    assert shas_before_m06 == shas_after_m06, "Other 13 .o SHA-256 changed on m06 edit!"
    m06_obj_changed = sha256(m06_edit_o) != sha256(OBJ_S2A / "m06.o")
    mod_objs_m06 = [m06_edit_o if m == "m06" else (OBJ_S2A / f"{m}.o") for m in MOD_NAMES]
    n6_m06_bin = OBJ_S2C / "n6_w13_m06_edit"
    m06_lk_ms = link_compiler(merge_s2a, mod_objs_m06, n6_m06_bin, cpu=0)
    m06_tot_ms = round((time.perf_counter() - t_e2) * 1000.0, 1)
    m06_sm = smoke_slice(n6_m06_bin, "n6_m06_edit", mode="x86-object-fast", cpu=0)
    print(
        f"  STAGE 2C-2 PASS! m06 .p130 stamp UNCHANGED ({m06_iface_ms} ms) | 13/14 .o SHA-256 identical "
        f"| m06.o changed={m06_obj_changed} | m06_rebuild={m06_cmp_ms} ms | relink={m06_lk_ms} ms "
        f"| total={m06_tot_ms} ms ({m06_tot_ms/1000.0:.2f} s) | out={m06_sm['out']}",
        flush=True,
    )

    res["stage2c_native_edits"] = {
        "m11_leaf_edit": {
            "reused_13_of_14_sha256_identical": True,
            "m11_rebuild_ms": m11_cmp_ms,
            "m11_rebuild_bytes": m11_edit_o.stat().st_size,
            "relink_ms": m11_lk_ms,
            "total_ms": m11_tot_ms,
            "observed_stage_read_w13": obs_read_w13,
            "trace_stages": parse_trace_stages(m11_err),
            "smoke": m11_sm,
        },
        "m06_midstack_body_edit": {
            "reused_13_of_14_sha256_identical": True,
            "p130_stamp_unchanged": True,
            "p130_iface_ms": m06_iface_ms,
            "m06_obj_changed": m06_obj_changed,
            "m06_rebuild_ms": m06_cmp_ms,
            "m06_rebuild_bytes": m06_edit_o.stat().st_size,
            "relink_ms": m06_lk_ms,
            "total_ms": m06_tot_ms,
            "trace_stages": parse_trace_stages(m06_err),
            "smoke": m06_sm,
        },
    }
    save_results(res)

    # =========================================================================
    # Populate /tmp/agy_k14_w13_cache/{iface,obj_o0} & remove old k13_w11 cache
    # =========================================================================
    print("\n=== Updating Cache: /tmp/agy_k14_w13_cache/{iface,obj_o0} ===", flush=True)
    if CACHE_W13.exists():
        shutil.rmtree(CACHE_W13)
    (CACHE_W13 / "iface").mkdir(parents=True, exist_ok=True)
    (CACHE_W13 / "obj_o0").mkdir(parents=True, exist_ok=True)
    for m in MOD_NAMES[: K - 1]:
        shutil.copy2(IFACE_S2B / f"{m}.p130", CACHE_W13 / "iface" / f"{m}.p130")
    for m in MOD_NAMES:
        shutil.copy2(OBJ_S2A / f"{m}.o", CACHE_W13 / "obj_o0" / f"{m}.o")
    shutil.copy2(merge_s2a, CACHE_W13 / "obj_o0" / "merge_n6_w13.o")
    if CACHE_W11.exists():
        shutil.rmtree(CACHE_W11)
        print(f"  Removed legacy cache {CACHE_W11}", flush=True)
    print(f"  Populated verified cache {CACHE_W13} (13 .p130 + 14 .o + merge.o)", flush=True)


def main() -> None:
    for d in (SRC_DIR, IFACE_S1, OBJ_S1, OBJ_S2A, IFACE_S2B, OBJ_S2B, OBJ_S2C, SMOKE_DIR, LOG_DIR):
        d.mkdir(parents=True, exist_ok=True)

    src_paths, export_counts = prepare_sources()
    if RESULTS_JSON.exists():
        res = json.loads(RESULTS_JSON.read_text(encoding="utf-8"))
    else:
        res = {
            "status": "in_progress",
            "k": K,
            "modules": MOD_NAMES,
            "export_counts": export_counts,
            "stage1_mint_n5_o2": {},
            "stage2a_warm_p130_7core_native": {},
            "stage2b_true_cold_pipelined_7core_native": {},
            "stage2c_native_edits": {},
        }
    save_results(res)

    if N5_O2.exists() and res.get("stage1_mint_n5_o2", {}).get("all_14_o2"):
        print("=== Reusing verified Stage 1 n5_o2 + 13/13 .p130 carriers from results.json ===", flush=True)
        s1 = res["stage1_mint_n5_o2"]
        carriers: list[tuple[Path, str]] = [(BASE_CARRIER, BASE_STAMP)]
        for r in s1["iface_records"]:
            carriers.append((IFACE_S1 / f"{r['module']}.p130", r["stamp"]))
        fid_bases = {r["module"]: r["fid_base"] for r in s1["modules"]}
        s1_records_map = {r["module"]: r for r in s1["modules"]}
    else:
        carriers, fid_bases, s1_records_map = run_stage1(res, src_paths)
    run_stage2(res, src_paths, carriers, fid_bases, s1_records_map)

    res["status"] = "passed"
    save_results(res)
    print("\n=== ALL W13-INT STAGES PASSED! ===", flush=True)


if __name__ == "__main__":
    main()
