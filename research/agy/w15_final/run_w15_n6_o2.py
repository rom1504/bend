#!/usr/bin/env python3
"""W15-INT: Pure-Native K/K -O2 Mint (n5_o2 -> n6_o2) + 7-Core Native Self-Repro
(Stage 2A Zero-Cache True-Cold, Stage 2B Warm-.p130, Stage 2C 1-Mod Edits,
Stage 2D Pure-Bend bend_build_real, Stage 2E n7_cold -> n8 Bit-Identity).

All workers pinned to CPUs 0..6 (ulimit -s 262144), 0 JS, 0 C, 0 objcopy!
"""
from __future__ import annotations

import argparse
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
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

N5_O2 = ROOT / "selfhost/build/agy/wave13-native-mod/n5_o2"
NATIVE_DIR = ROOT / "selfhost/build/agy/wave15-native-mod"
N6_O2 = NATIVE_DIR / "n6_o2"
BEND_BUILD_REAL = ROOT / "research/agy/w14_campaign/w14d_bend_build_real/bend_build_real"

INPUTS_UP = ROOT / "research/agy/wave4_bench/inputs/upstream"
UPSTREAM_EXPECTED = {
    "histogram": 3307081914,
    "nbody": 728502159,
    "gameoflife": 3681094808,
}

OUT_DIR = ROOT / "research/agy/w15_final"
RESULTS_JSON = OUT_DIR / "results.json"

TMP = Path("/tmp/agy_w15_work")
COLD_DIR = Path("/tmp/agy_w15_cold")

ALLOWED_CPUS = (0, 1, 2, 3, 4, 5, 6)
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
    return stages


def run_native(
    binary: Path,
    args: list[str],
    out_file: Path,
    err_file: Path,
    cpu: int,
    timeout: int = 240,
) -> tuple[float, str]:
    assert cpu in ALLOWED_CPUS, f"Disallowed CPU {cpu}"
    out_file.parent.mkdir(parents=True, exist_ok=True)
    err_file.parent.mkdir(parents=True, exist_ok=True)
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
        raise RuntimeError(f"native {binary.name} failed (rc={r.returncode}, cpu={cpu}) args={args[:4]}: {stderr[-1200:]}")
    return ms, stderr


def merge_and_link(
    compiler_bin: Path,
    mod_names: list[str],
    obj_dir: Path,
    merge_o: Path,
    out_bin: Path,
    err_file: Path,
    cpu: int = 0,
) -> tuple[float, float]:
    """Run native x86-merge-obj (entry module m11 FIRST!) and link with gcc-10."""
    entry_mod = mod_names[-1]
    ordered = [entry_mod] + [m for m in mod_names[:-1]]
    mod_objs = [obj_dir / f"{m}.o" for m in ordered]
    merge_args = ["x86-merge-obj", entry_mod] + ordered
    merge_ms, _ = run_native(compiler_bin, merge_args, merge_o, err_file, cpu=cpu, timeout=60)
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
    if r.stderr.strip():
        print(f"  [WARN] gcc-10 link stderr: {r.stderr.strip()[:400]}", flush=True)
    return merge_ms, link_ms


def compute_reachable_names(compiler_bend: Path) -> set[str]:
    from collections import deque
    sys.path.insert(0, str(OUT_DIR))
    from split_k14_w15 import parse_compiler_bend, strip_strings_and_comments, IDENT_RE
    _, _, decls = parse_compiler_bend(compiler_bend)
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


def prepare_sources(k_dir: Path, mod_names: list[str], src_dir: Path, compiler_bend: Path) -> tuple[dict[str, Path], dict[str, int]]:
    src_dir.mkdir(parents=True, exist_ok=True)
    reach_names = compute_reachable_names(compiler_bend)
    types_text = (k_dir / "types.bend").read_text(encoding="utf-8")
    mod_texts = [(k_dir / f"{m}.bend").read_text(encoding="utf-8") for m in mod_names]
    src_paths: dict[str, Path] = {}
    export_counts: dict[str, int] = {}
    entry_mod = mod_names[-1]
    for i, m in enumerate(mod_names):
        prefix = (types_text + "\n") if i == 0 else "import Base\n"
        if m == entry_mod:
            full = prefix + mod_texts[i]
            export_counts[m] = 0
            (k_dir / f"{m}.exp").write_text("", encoding="utf-8")
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
            exp_text = "\n".join(lines)
            (k_dir / f"{m}.exp").write_text(exp_text, encoding="utf-8")
            full = prefix + mod_texts[i] + exp_text
        p = src_dir / f"{m}_exp.bend"
        p.write_text(full, encoding="utf-8")
        src_paths[m] = p
    return src_paths, export_counts


def smoke_slice(binary: Path, tag: str, work_dir: Path, mode: str = "x86-object-fast", cpu: int = 0) -> dict:
    sm_o = work_dir / f"{tag}_{mode}.o"
    sm_err = work_dir / f"{tag}_{mode}.err"
    sm_exe = work_dir / f"{tag}_{mode}.exe"
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
    res = {
        "mode": mode,
        "compile_ms": compile_ms,
        "link_ms": link_ms,
        "obj_bytes": sm_o.stat().st_size,
        "obj_sha256": sha256(sm_o),
        "out": out,
        "trace_stages": parse_trace_stages(stderr),
    }
    sm_o.unlink(missing_ok=True)
    sm_exe.unlink(missing_ok=True)
    return res


def smoke_runtime_programs(binary: Path, work_dir: Path, cpu: int = 0) -> dict:
    up_spec = json.loads((INPUTS_UP / "suite.json").read_text(encoding="utf-8"))
    out_res = {}
    for fam in ("histogram", "nbody", "gameoflife"):
        desc = up_spec[fam]
        text = (INPUTS_UP / fam / "main.bend").read_text(encoding="utf-8")
        for bname, old, new in zip(desc["bendKnobs"], desc["upstream"], desc["medium"]):
            text, n = re.subn(rf"(^def {bname}\(\) -> Nat:\n  ){old}n$", rf"\g<1>{new}n", text, flags=re.M)
            assert n == 1
        src = work_dir / f"rt_{fam}.bend"
        src.write_text(text, encoding="utf-8")
        obj = work_dir / f"rt_{fam}.o"
        err_f = work_dir / f"rt_{fam}.err"
        cmp_ms, _ = run_native(
            binary,
            ["x86-object", str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
            out_file=obj,
            err_file=err_f,
            cpu=cpu,
            timeout=120,
        )
        exe = work_dir / f"rt_{fam}.exe"
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
        print(f"  [n6_o2 RT {fam:<10}] compile={cmp_ms:7.1f} ms | run_median={med:7.2f} ms (runs={runs}) | checksum OK", flush=True)
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)
    return out_res


def pipelined_native_build(
    compiler_bin: Path,
    mode: str,
    mod_names: list[str],
    src_paths: dict[str, Path],
    fid_bases: dict[str, int],
    iface_dir: Path,
    obj_dir: Path,
    log_dir: Path,
    tag: str,
    reuse_iface: bool = False,
    reuse_obj: bool = False,
) -> dict:
    """Pipelined 7-core native build:
    - CPU 0 runs sequential x86-iface chain (m00a -> m(K-2))
    - CPUs 1..6 run x86-module / x86-module-fast immediately as upstream .p130 lands!
    Automatically checks FID ranges and recompiles shifted modules if any overlap/overflow.
    """
    K = len(mod_names)
    iface_dir.mkdir(parents=True, exist_ok=True)
    obj_dir.mkdir(parents=True, exist_ok=True)
    log_dir.mkdir(parents=True, exist_ok=True)

    carriers: list[tuple[Path, str] | None] = [None] * K
    carriers[0] = (BASE_CARRIER, BASE_STAMP)
    iface_records: list[dict] = []
    mod_records_map: dict[str, dict] = {}
    work_q: queue.Queue[int | None] = queue.Queue()
    work_q.put(0)

    def compile_one(i: int, cpu: int, fb: int, sub_tag: str, force: bool = False) -> dict:
        m = mod_names[i]
        in_carrier, in_stamp = carriers[i]  # type: ignore[misc]
        out_o = obj_dir / f"{m}.o"
        err_f = log_dir / f"{sub_tag}_{m}.err"
        if (not force) and reuse_obj and out_o.exists() and out_o.stat().st_size > 1_000_000:
            ms, stderr = 0.0, ""
        else:
            ms, stderr = run_native(
                compiler_bin,
                ["--trace", mode, str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fb), m],
                out_file=out_o,
                err_file=err_f,
                cpu=cpu,
                timeout=900,
            )
        segs = get_seg_count(out_o, m)
        rec = {
            "module": m,
            "mode": mode,
            "cpu": cpu,
            "fid_base": fb,
            "seg_count": segs,
            "fid_end": fb + segs - 1,
            "ms": ms,
            "bytes": out_o.stat().st_size,
            "sha256": sha256(out_o),
            "trace_stages": parse_trace_stages(stderr),
        }
        print(
            f"  [{sub_tag} cpu={cpu}] {m:<4}.o: {rec['bytes']:>10,} B | fid=[{rec['fid_base']:5d}..{rec['fid_end']:5d}] "
            f"(segs={segs:5d}) | {ms:7.1f} ms",
            flush=True,
        )
        return rec

    def worker(cpu: int) -> None:
        while True:
            item = work_q.get()
            if item is None:
                return
            mod_records_map[mod_names[item]] = compile_one(item, cpu, fid_bases[mod_names[item]], tag)

    t_pipe0 = time.perf_counter()
    worker_cpus = (1, 2, 3, 4, 5, 6)
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(worker_cpus)) as ex:
        futs = [ex.submit(worker, cpu) for cpu in worker_cpus]
        try:
            t_iface0 = time.perf_counter()
            for i in range(K - 1):
                m = mod_names[i]
                in_carrier, in_stamp = carriers[i]  # type: ignore[misc]
                out_p130 = iface_dir / f"{m}.p130"
                err_f = log_dir / f"{tag}_iface_{m}.err"
                if reuse_iface and out_p130.exists() and out_p130.stat().st_size > 1_000_000:
                    info = parse_p130(out_p130)
                    stamp = info["stamp"]
                    ms = 0.0
                else:
                    ms, stderr = run_native(
                        compiler_bin,
                        ["x86-iface", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp],
                        out_file=out_p130,
                        err_file=err_f,
                        cpu=0,
                        timeout=240,
                    )
                    stamp = stderr.splitlines()[-1].strip()
                    info = parse_p130(out_p130)
                    assert info["stamp"] == stamp, f"Stamp mismatch for {m}: {info['stamp']} != {stamp}"
                rec = {
                    "module": m,
                    "ms": ms,
                    "bytes": info["bytes"],
                    "nodes": info["nodes"],
                    "strings": info["strings"],
                    "stamp": stamp,
                    "sha256": info["sha256"],
                }
                iface_records.append(rec)
                print(
                    f"  [{tag}-iface cpu=0] {m:<4}.p130: {info['bytes']:>10,} B | nodes={info['nodes']:>7,} "
                    f"strs={info['strings']:>5,} | {ms:7.1f} ms",
                    flush=True,
                )
                carriers[i + 1] = (out_p130, stamp)
                work_q.put(i + 1)
            iface_wall_ms = round((time.perf_counter() - t_iface0) * 1000.0, 1)
        finally:
            for _ in worker_cpus:
                work_q.put(None)
        for f in futs:
            f.result()

    pipe_compile_ms = round((time.perf_counter() - t_pipe0) * 1000.0, 1)
    tail_ms = round(pipe_compile_ms - iface_wall_ms, 1)

    # Check FID totals & overlap
    total_segs = sum(mod_records_map[m]["seg_count"] for m in mod_names)
    print(f"  [{tag}] Total FIDs = {total_segs:,} / {FID_LIMIT:,} (headroom = {FID_LIMIT - total_segs:,})", flush=True)
    if total_segs > FID_LIMIT:
        return {
            "fid_overflow": True,
            "total_segs": total_segs,
            "fid_limit": FID_LIMIT,
            "mod_records": [mod_records_map[m] for m in mod_names],
            "iface_records": iface_records,
        }

    # Check if any module overlapped or overflowed its provisional slot; if so, pack contiguously and recompile shifted ones
    exact_bases: dict[str, int] = {}
    cur = 0
    need_redo: list[int] = []
    for i, m in enumerate(mod_names):
        exact_bases[m] = cur
        if cur != mod_records_map[m]["fid_base"]:
            need_redo.append(i)
        cur += mod_records_map[m]["seg_count"]

    # Only redo if there was an actual overlap or out-of-range fid_end
    has_overlap = False
    for i, m in enumerate(mod_names):
        r = mod_records_map[m]
        if r["fid_end"] >= FID_LIMIT:
            has_overlap = True
        if i + 1 < K and r["fid_end"] >= mod_records_map[mod_names[i + 1]]["fid_base"]:
            has_overlap = True

    redo_ms = 0.0
    if has_overlap:
        print(f"  [{tag}] Provisional FID overlap detected; recompiling {len(need_redo)} shifted modules with exact contiguous bases...", flush=True)
        t_r0 = time.perf_counter()
        redo_q: queue.Queue[int | None] = queue.Queue()
        for idx in need_redo:
            redo_q.put(idx)
        for _ in ALLOWED_CPUS:
            redo_q.put(None)

        def redo_worker(cpu: int) -> None:
            while True:
                item = redo_q.get()
                if item is None:
                    return
                m = mod_names[item]
                mod_records_map[m] = compile_one(item, cpu, exact_bases[m], tag + "_redo", force=True)

        with concurrent.futures.ThreadPoolExecutor(max_workers=len(ALLOWED_CPUS)) as ex:
            rfuts = [ex.submit(redo_worker, cpu) for cpu in ALLOWED_CPUS]
            for f in rfuts:
                f.result()
        redo_ms = round((time.perf_counter() - t_r0) * 1000.0, 1)

    return {
        "fid_overflow": False,
        "total_segs": total_segs,
        "exact_fid_bases": exact_bases,
        "iface_wall_ms": iface_wall_ms,
        "pipe_compile_ms": pipe_compile_ms,
        "tail_ms": tail_ms,
        "redo_ms": redo_ms,
        "iface_records": iface_records,
        "mod_records": [mod_records_map[m] for m in mod_names],
        "carriers": carriers,
    }


def warm_7core_build(
    compiler_bin: Path,
    mode: str,
    mod_names: list[str],
    src_paths: dict[str, Path],
    fid_bases: dict[str, int],
    carriers: list[tuple[Path, str]],
    obj_dir: Path,
    log_dir: Path,
    tag: str,
    lpt_order: list[int],
) -> dict:
    """7-core warm-.p130 build on CPUs 0..6."""
    obj_dir.mkdir(parents=True, exist_ok=True)
    log_dir.mkdir(parents=True, exist_ok=True)
    work_q: queue.Queue[int | None] = queue.Queue()
    for idx in lpt_order:
        work_q.put(idx)
    for _ in ALLOWED_CPUS:
        work_q.put(None)
    mod_records_map: dict[str, dict] = {}

    def worker(cpu: int) -> None:
        while True:
            item = work_q.get()
            if item is None:
                return
            m = mod_names[item]
            in_carrier, in_stamp = carriers[item]
            out_o = obj_dir / f"{m}.o"
            err_f = log_dir / f"{tag}_{m}.err"
            ms, stderr = run_native(
                compiler_bin,
                ["--trace", mode, str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fid_bases[m]), m],
                out_file=out_o,
                err_file=err_f,
                cpu=cpu,
                timeout=240,
            )
            segs = get_seg_count(out_o, m)
            mod_records_map[m] = {
                "module": m,
                "cpu": cpu,
                "fid_base": fid_bases[m],
                "seg_count": segs,
                "fid_end": fid_bases[m] + segs - 1,
                "ms": ms,
                "bytes": out_o.stat().st_size,
                "sha256": sha256(out_o),
            }
            print(f"  [{tag} cpu={cpu}] {m:<4}.o: {out_o.stat().st_size:>10,} B | {ms:7.1f} ms", flush=True)

    t0 = time.perf_counter()
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(ALLOWED_CPUS)) as ex:
        futs = [ex.submit(worker, cpu) for cpu in ALLOWED_CPUS]
        for f in futs:
            f.result()
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    return {
        "compile_wall_ms": wall_ms,
        "compile_sum_ms": round(sum(r["ms"] for r in mod_records_map.values()), 1),
        "mod_records": [mod_records_map[m] for m in mod_names],
    }


def save_results(res: dict) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    RESULTS_JSON.write_text(json.dumps(res, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--k", type=int, choices=(10, 12, 13, 14), default=10)
    ap.add_argument("--stage", choices=("all", "s1", "s2", "s2_tail", "s2_de"), default="all")
    ap.add_argument("--reuse-o2", action="store_true")
    args = ap.parse_args()

    compiler_bend = ROOT / "selfhost/build/agy/wave15_unified/compiler.bend"
    k_dir = ROOT / f"selfhost/build/agy/k{args.k}_wave15"
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    prov_fid_bases = {m["name"]: m["fid_base"] for m in manifest["modules"]}
    K = len(mod_names)

    TMP.mkdir(parents=True, exist_ok=True)
    src_dir = TMP / f"src_k{K}"
    log_dir = TMP / "logs"
    smoke_dir = TMP / "smoke"
    smoke_dir.mkdir(parents=True, exist_ok=True)

    src_paths, export_counts = prepare_sources(k_dir, mod_names, src_dir, compiler_bend)
    res: dict = {}
    if RESULTS_JSON.exists() and args.stage in ("s2", "s2_tail", "s2_de"):
        res = json.loads(RESULTS_JSON.read_text(encoding="utf-8"))
    res["k"] = K
    res["k_dir"] = str(k_dir)
    res["mod_names"] = mod_names
    res["export_counts"] = export_counts

    # ------------------------------------------------------------------
    # STAGE 1: Mint K/K -O2 Native n6_o2 using existing n5_o2 (0 JS, 0 C!)
    # ------------------------------------------------------------------
    if args.stage in ("all", "s1"):
        print(f"=== STAGE 1: Pure-Native {K}/{K} -O2 Mint (n5_o2 -> n6_o2, CPUs 0..6) ===", flush=True)
        s1_iface = TMP / f"s1_iface_k{K}"
        s1_obj = TMP / f"s1_obj_o2_k{K}"
        t_s1_0 = time.perf_counter()
        s1 = pipelined_native_build(
            N5_O2, "x86-module", mod_names, src_paths, prov_fid_bases,
            s1_iface, s1_obj, log_dir, f"s1_k{K}", reuse_iface=True, reuse_obj=args.reuse_o2,
        )
        if s1["fid_overflow"]:
            print(f"[OVERFLOW] K={K} total FIDs = {s1['total_segs']:,} > {FID_LIMIT:,}! Re-run with --k {K-1}!", flush=True)
            res["stage1_overflow"] = {k: v for k, v in s1.items() if k != "carriers"}
            save_results(res)
            return 2

        NATIVE_DIR.mkdir(parents=True, exist_ok=True)
        merge_o = s1_obj / "merge_n6_o2.o"
        merge_ms, link_ms = merge_and_link(N5_O2, mod_names, s1_obj, merge_o, N6_O2, log_dir / "s1_merge.err", cpu=0)
        s1_total_ms = round((time.perf_counter() - t_s1_0) * 1000.0, 1)
        print(
            f"  [n6_o2 LINKED] {N6_O2} ({N6_O2.stat().st_size:,} B) | merge={merge_ms} ms | link={link_ms} ms | total={s1_total_ms/1000:.2f} s",
            flush=True,
        )

        sm_o0 = smoke_slice(N6_O2, "n6_o2", smoke_dir, "x86-object-fast", cpu=0)
        sm_o2 = smoke_slice(N6_O2, "n6_o2", smoke_dir, "x86-object", cpu=0)
        print(f"  [n6_o2 smoke -O0] {sm_o0['compile_ms']} ms | out={sm_o0['out']}", flush=True)
        print(f"  [n6_o2 smoke -O2] {sm_o2['compile_ms']} ms | out={sm_o2['out']}", flush=True)
        rt_sm = smoke_runtime_programs(N6_O2, smoke_dir, cpu=0)

        res["stage1"] = {
            "total_segs": s1["total_segs"],
            "exact_fid_bases_o2": s1["exact_fid_bases"],
            "iface_wall_ms": s1["iface_wall_ms"],
            "pipe_compile_ms": s1["pipe_compile_ms"],
            "tail_ms": s1["tail_ms"],
            "redo_ms": s1["redo_ms"],
            "merge_ms": merge_ms,
            "link_ms": link_ms,
            "total_ms": s1_total_ms,
            "n6_o2_bytes": N6_O2.stat().st_size,
            "n6_o2_sha256": sha256(N6_O2),
            "smoke_o0": sm_o0,
            "smoke_o2": sm_o2,
            "smoke_rt": rt_sm,
            "mod_records": s1["mod_records"],
        }
        save_results(res)

        # Clean up Stage 1 large .o files immediately to keep /dev/md2 >= 5.0 GiB!
        shutil.rmtree(s1_obj, ignore_errors=True)
        shutil.rmtree(s1_iface, ignore_errors=True)
        print("  [CLEANUP] Removed Stage 1 temp .o/.p130 to preserve disk headroom", flush=True)

    if args.stage == "s1":
        return 0

    cold_iface = COLD_DIR / "iface"
    cold_obj = COLD_DIR / "obj"
    cold_logs = COLD_DIR / "logs"
    n7_cold = COLD_DIR / "n7_cold"

    if args.stage in ("s2_tail", "s2_de"):
        s2a_data = res["stage2a_zero_cache_cold"]
        cold_sha = {r["module"]: r["sha256"] for r in s2a_data["mod_records"]}
        cold_merge_sha = s2a_data["merge_sha256"]
        cold_used_bases = {r["module"]: r["fid_base"] for r in s2a_data["mod_records"]}
        lpt_order = sorted(range(K), key=lambda idx: s2a_data["mod_records"][idx]["ms"], reverse=True)
        carriers_2a = [(BASE_CARRIER, BASE_STAMP)] + [
            (cold_iface / f"{r['module']}.p130", r["stamp"]) for r in s2a_data["iface_records"]
        ]
        s2a = {"carriers": carriers_2a}
    else:
        # ------------------------------------------------------------------
        # STAGE 2A: ZERO-CACHE TRUE-COLD (n6_o2 -> n7_cold, CPUs 0..6, EMPTY dir!)
        # ------------------------------------------------------------------
        print(f"\n=== STAGE 2A: ZERO-CACHE TRUE-COLD ({K}/{K}, n6_o2 -> n7_cold, CPUs 0..6) ===", flush=True)
        shutil.rmtree(COLD_DIR, ignore_errors=True)
        COLD_DIR.mkdir(parents=True, exist_ok=True)
        o2_bases = res.get("stage1", {}).get("exact_fid_bases_o2")
        o2_recs = res.get("stage1", {}).get("mod_records")
        if o2_bases and o2_recs:
            total_o2 = res["stage1"]["total_segs"]
            pad = max(0, min(20, (FID_LIMIT - total_o2 - 100) // K))
            s2_prov_bases = {}
            cur = 0
            for r in o2_recs:
                s2_prov_bases[r["module"]] = cur
                cur += r["seg_count"] + pad
        else:
            s2_prov_bases = prov_fid_bases

        t_2a_0 = time.perf_counter()
        s2a = pipelined_native_build(
            N6_O2, "x86-module-fast", mod_names, src_paths, s2_prov_bases,
            cold_iface, cold_obj, cold_logs, "s2a_cold", reuse_iface=False,
        )
        assert not s2a["fid_overflow"], f"Stage 2A -O0 FID overflow: {s2a['total_segs']} > {FID_LIMIT}"
        merge_cold = cold_obj / "merge_cold.o"
        m2a_ms, l2a_ms = merge_and_link(N6_O2, mod_names, cold_obj, merge_cold, n7_cold, cold_logs / "merge.err", cpu=0)
        e2e_2a_ms = round((time.perf_counter() - t_2a_0) * 1000.0, 1)
        sm_n7 = smoke_slice(n7_cold, "n7_cold", smoke_dir, "x86-object-fast", cpu=0)
        print(
            f"  [STAGE 2A ZERO-CACHE TRUE-COLD] iface={s2a['iface_wall_ms']/1000:.2f}s | pipe={s2a['pipe_compile_ms']/1000:.2f}s "
            f"(tail={s2a['tail_ms']/1000:.2f}s) | merge={m2a_ms}ms | link={l2a_ms}ms | E2E={e2e_2a_ms/1000:.2f}s | n7_cold smoke={sm_n7['compile_ms']}ms out={sm_n7['out']}",
            flush=True,
        )
        cold_sha = {r["module"]: r["sha256"] for r in s2a["mod_records"]}
        cold_merge_sha = sha256(merge_cold)
        cold_used_bases = {r["module"]: r["fid_base"] for r in s2a["mod_records"]}
        lpt_order = sorted(range(K), key=lambda idx: s2a["mod_records"][idx]["ms"], reverse=True)

        res["stage2a_zero_cache_cold"] = {
            "total_segs": s2a["total_segs"],
            "iface_wall_ms": s2a["iface_wall_ms"],
            "pipe_compile_ms": s2a["pipe_compile_ms"],
            "tail_ms": s2a["tail_ms"],
            "redo_ms": s2a["redo_ms"],
            "merge_ms": m2a_ms,
            "link_ms": l2a_ms,
            "e2e_ms": e2e_2a_ms,
            "n7_cold_bytes": n7_cold.stat().st_size,
            "merge_sha256": cold_merge_sha,
            "smoke_o0": sm_n7,
            "iface_records": s2a["iface_records"],
            "mod_records": s2a["mod_records"],
        }
        save_results(res)

        # ------------------------------------------------------------------
        # STAGE 2B: WARM-.p130 7-CORE COLD (n6_o2 -> n7_warm, CPUs 0..6)
        # ------------------------------------------------------------------
        print(f"\n=== STAGE 2B: WARM-.p130 7-CORE COLD (n6_o2 -> n7_warm, CPUs 0..6) ===", flush=True)
        warm_obj = COLD_DIR / "obj_warm"
        warm_logs = COLD_DIR / "logs_warm"
        t_2b_0 = time.perf_counter()
        s2b = warm_7core_build(
            N6_O2, "x86-module-fast", mod_names, src_paths, cold_used_bases,
            s2a["carriers"], warm_obj, warm_logs, "s2b_warm", lpt_order,
        )
        merge_warm = warm_obj / "merge_warm.o"
        n7_warm = COLD_DIR / "n7_warm"
        m2b_ms, l2b_ms = merge_and_link(N6_O2, mod_names, warm_obj, merge_warm, n7_warm, warm_logs / "merge.err", cpu=0)
        e2e_2b_ms = round((time.perf_counter() - t_2b_0) * 1000.0, 1)

        warm_sha = {r["module"]: r["sha256"] for r in s2b["mod_records"]}
        warm_merge_sha = sha256(merge_warm)
        matches = sum(1 for m in mod_names if warm_sha[m] == cold_sha[m])
        assert matches == K, f"2A vs 2B .o mismatch: {matches}/{K}"
        assert warm_merge_sha == cold_merge_sha, "2A vs 2B merge.o mismatch!"
        scaling = round(s2b["compile_sum_ms"] / s2b["compile_wall_ms"], 2)
        print(
            f"  [STAGE 2B WARM-.p130] compile={s2b['compile_wall_ms']/1000:.2f}s (sum={s2b['compile_sum_ms']/1000:.2f}s, {scaling}x on 7c) "
            f"| merge={m2b_ms}ms | link={l2b_ms}ms | E2E={e2e_2b_ms/1000:.2f}s | SHA-256={matches}/{K} + merge.o BIT-IDENTICAL!",
            flush=True,
        )
        res["stage2b_warm_p130"] = {
            "compile_wall_ms": s2b["compile_wall_ms"],
            "compile_sum_ms": s2b["compile_sum_ms"],
            "scaling_7c": scaling,
            "merge_ms": m2b_ms,
            "link_ms": l2b_ms,
            "e2e_ms": e2e_2b_ms,
            "bit_identical_to_2a": f"{matches}/{K} + merge.o",
            "mod_records": s2b["mod_records"],
        }
        save_results(res)
        shutil.rmtree(warm_obj, ignore_errors=True)
        n7_warm.unlink(missing_ok=True)

    # ------------------------------------------------------------------
    # STAGE 2C: 1-MODULE NATIVE EDITS (Leaf m11 + Mid-Stack m06, CPU 0)
    # ------------------------------------------------------------------
    entry_mod = mod_names[-1]
    if args.stage != "s2_de":
        print("\n=== STAGE 2C: 1-MODULE NATIVE EDITS (n6_o2, CPU 0) ===", flush=True)
        edit_dir = COLD_DIR / "edits"
        edit_dir.mkdir(parents=True, exist_ok=True)

        # 2C-1: Leaf m11 body edit
        entry_mod = mod_names[-1]
        entry_idx = K - 1
        m11_orig_text = src_paths[entry_mod].read_text(encoding="utf-8")
        assert '"stage=read ms="' in m11_orig_text, "Could not find stage=read ms= in entry module"
        m11_edit_src = edit_dir / f"{entry_mod}_edit.bend"
        m11_edit_src.write_text(m11_orig_text.replace('"stage=read ms="', '"stage=read_w15 ms="', 1), encoding="utf-8")

        # Copy cold_obj to edit_obj (hardlink unchanged .o files = 0 extra disk!)
        edit_obj1 = edit_dir / "obj_m11"
        edit_obj1.mkdir(parents=True, exist_ok=True)
        for m in mod_names:
            if m != entry_mod:
                os.link(cold_obj / f"{m}.o", edit_obj1 / f"{m}.o")

        t_c1_0 = time.perf_counter()
        c1_in_carrier, c1_in_stamp = s2a["carriers"][entry_idx]
        c1_compile_ms, _ = run_native(
            N6_O2,
            ["--trace", "x86-module-fast", str(m11_edit_src), str(BASE_FILE), "cache", str(c1_in_carrier), c1_in_stamp, str(cold_used_bases[entry_mod]), entry_mod],
            out_file=edit_obj1 / f"{entry_mod}.o",
            err_file=edit_dir / "c1_m11.err",
            cpu=0,
            timeout=120,
        )
        c1_merge_ms, c1_link_ms = merge_and_link(N6_O2, mod_names, edit_obj1, edit_obj1 / "merge.o", edit_dir / "n7_m11", edit_dir / "c1_merge.err", cpu=0)
        c1_total_ms = round((time.perf_counter() - t_c1_0) * 1000.0, 1)
        c1_sm = smoke_slice(edit_dir / "n7_m11", "c1_m11", smoke_dir, "x86-object-fast", cpu=0)
        assert "read_w15" in c1_sm["trace_stages"], f"Expected read_w15 trace stage, got {c1_sm['trace_stages']}"
        c1_m11_changed = sha256(edit_obj1 / f"{entry_mod}.o") != cold_sha[entry_mod]
        assert c1_m11_changed
        print(
            f"  [2C-1 Leaf {entry_mod} edit] compile={c1_compile_ms/1000:.2f}s | merge={c1_merge_ms}ms | link={c1_link_ms}ms "
            f"| total={c1_total_ms/1000:.2f}s | {K-1}/{K} .o untouched | live stage=read_w15 OK",
            flush=True,
        )
        shutil.rmtree(edit_obj1, ignore_errors=True)
        (edit_dir / "n7_m11").unlink(missing_ok=True)

        # 2C-2: Mid-stack m06 body edit (type-safe error string literal change -> AST & .o change, interface stamp unchanged!)
        m06_idx = mod_names.index("m06")
        m06_orig_text = src_paths["m06"].read_text(encoding="utf-8")
        assert '"w13e_muladd_loop bad args"' in m06_orig_text, "Could not find anchor string in m06"
        m06_edit_text = m06_orig_text.replace('"w13e_muladd_loop bad args"', '"w13e_muladd_loop bad args [w15]"', 1)
        m06_edit_src = edit_dir / "m06_edit.bend"
        m06_edit_src.write_text(m06_edit_text, encoding="utf-8")

        edit_obj2 = edit_dir / "obj_m06"
        edit_obj2.mkdir(parents=True, exist_ok=True)
        for m in mod_names:
            if m != "m06":
                os.link(cold_obj / f"{m}.o", edit_obj2 / f"{m}.o")

        c2_in_carrier, c2_in_stamp = s2a["carriers"][m06_idx]
        orig_m06_stamp = s2a["carriers"][m06_idx + 1][1]
        t_c2_0 = time.perf_counter()
        c2_iface_ms, c2_iface_err = run_native(
            N6_O2,
            ["x86-iface", str(m06_edit_src), str(BASE_FILE), "cache", str(c2_in_carrier), c2_in_stamp],
            out_file=edit_dir / "m06_edit.p130",
            err_file=edit_dir / "c2_m06_iface.err",
            cpu=0,
            timeout=120,
        )
        new_m06_stamp = c2_iface_err.splitlines()[-1].strip()
        stamp_unchanged = (new_m06_stamp == orig_m06_stamp)
        assert stamp_unchanged, f"m06 body edit changed stamp! {orig_m06_stamp} -> {new_m06_stamp}"

        t_c2_cmp0 = time.perf_counter()
        c2_compile_ms, _ = run_native(
            N6_O2,
            ["--trace", "x86-module-fast", str(m06_edit_src), str(BASE_FILE), "cache", str(c2_in_carrier), c2_in_stamp, str(cold_used_bases["m06"]), "m06"],
            out_file=edit_obj2 / "m06.o",
            err_file=edit_dir / "c2_m06.err",
            cpu=0,
            timeout=120,
        )
        c2_merge_ms, c2_link_ms = merge_and_link(N6_O2, mod_names, edit_obj2, edit_obj2 / "merge.o", edit_dir / "n7_m06", edit_dir / "c2_merge.err", cpu=0)
        c2_compile_link_ms = round((time.perf_counter() - t_c2_cmp0) * 1000.0, 1)
        c2_seq_total_ms = round((time.perf_counter() - t_c2_0) * 1000.0, 1)
        c2_sm = smoke_slice(edit_dir / "n7_m06", "c2_m06", smoke_dir, "x86-object-fast", cpu=0)
        print(
            f"  [2C-2 Mid-stack m06 edit] iface={c2_iface_ms/1000:.2f}s (stamp UNCHANGED!) | compile={c2_compile_ms/1000:.2f}s "
            f"| merge={c2_merge_ms}ms | link={c2_link_ms}ms | compile+link={c2_compile_link_ms/1000:.2f}s | {K-1}/{K} .o untouched | out={c2_sm['out']}",
            flush=True,
        )
        shutil.rmtree(edit_obj2, ignore_errors=True)
        (edit_dir / "n7_m06").unlink(missing_ok=True)
        (edit_dir / "m06_edit.p130").unlink(missing_ok=True)

        res["stage2c_edits"] = {
            "leaf_m11": {
                "compile_ms": c1_compile_ms,
                "merge_ms": c1_merge_ms,
                "link_ms": c1_link_ms,
                "total_ms": c1_total_ms,
                "unchanged_objs": f"{K-1}/{K}",
                "smoke_out": c1_sm["out"],
                "live_trace_tag": "read_w15",
            },
            "mid_m06": {
                "iface_ms": c2_iface_ms,
                "stamp_unchanged": stamp_unchanged,
                "stamp": new_m06_stamp,
                "compile_ms": c2_compile_ms,
                "merge_ms": c2_merge_ms,
                "link_ms": c2_link_ms,
                "compile_and_link_ms": c2_compile_link_ms,
                "seq_total_ms": c2_seq_total_ms,
                "unchanged_objs": f"{K-1}/{K}",
                "smoke_out": c2_sm["out"],
            },
        }
        save_results(res)

    # ------------------------------------------------------------------
    # STAGE 2D: PURE-BEND bend_build_real DRIVER END-TO-END PROOF
    # ------------------------------------------------------------------
    print("\n=== STAGE 2D: PURE-BEND bend_build_real DRIVER PROOF (n6_o2, CPUs 0..6) ===", flush=True)
    bbr_dir = COLD_DIR / "bbr"
    bbr_dir.mkdir(parents=True, exist_ok=True)
    bbr_cache = bbr_dir / "cache"
    bbr_obj = bbr_dir / "obj"
    bbr_cache.mkdir(parents=True, exist_ok=True)
    bbr_obj.mkdir(parents=True, exist_ok=True)
    # Pre-seed .p130s (hardlink = 0 extra disk!) & .o's for --adopt-p130 + no-op + leaf edit test
    for i in range(K - 1):
        m = mod_names[i]
        os.link(cold_iface / f"{m}.p130", bbr_cache / f"{m}.p130")
    for m in mod_names:
        os.link(cold_obj / f"{m}.o", bbr_obj / f"{m}.o")

    # Build 6-column manifest for bend_build_real
    import_base_f = bbr_dir / "import_base.bend"
    import_base_f.write_text("import Base\n", encoding="utf-8")
    bbr_manifest = bbr_dir / "manifest.txt"
    mlines = []
    for i, m in enumerate(mod_names):
        pfx = str(k_dir / "types.bend") if i == 0 else str(import_base_f)
        ftr = "-" if i == K - 1 else str(k_dir / f"{m}.exp")
        mlines.append(f"{m} {k_dir / (m + '.bend')} {cold_used_bases[m]} {bbr_obj / (m + '.o')} {pfx} {ftr}")
    bbr_manifest.write_text("\n".join(mlines) + "\n", encoding="utf-8")

    bbr_bin = bbr_dir / "n7_bbr"
    # First run with --adopt-p130 (adopts .p130 stamps & builds/verifies cache)
    # Wait: if .o files are already present, bend_build_real checks .okey sidecars; let's run --adopt-p130 with --jobs 7!
    # Actually let's remove bbr_obj/*.o so --adopt-p130 does a clean warm build OR test no-op right after!
    # To save time & disk, let's test bend_build_real on a clean --adopt-p130 warm build (--jobs 7, ~50s),
    # then 3x no-op rebuilds (~150 ms each!), then 1-module leaf edit!
    for f in bbr_obj.glob("*.o"):
        f.unlink()

    def run_bbr(extra_args: list[str], err_name: str) -> tuple[float, str, str]:
        cmd = [
            "timeout", "240",
            "bash", "-c", 'ulimit -s 262144 && exec taskset -c 0-6 "$1" "${@:2}"',
            "_", str(BEND_BUILD_REAL),
            "--jobs", "7", *extra_args,
            str(bbr_manifest), str(N6_O2), str(BASE_FILE), str(BASE_CARRIER), BASE_STAMP,
            str(bbr_cache), str(RT), entry_mod, str(bbr_bin),
        ]
        t0 = time.perf_counter()
        r = subprocess.run(cmd, capture_output=True, text=True, cwd=ROOT)
        ms = round((time.perf_counter() - t0) * 1000.0, 1)
        (bbr_dir / err_name).write_text(r.stdout + "\n---STDERR---\n" + r.stderr, encoding="utf-8")
        if r.returncode != 0:
            raise RuntimeError(f"bend_build_real failed (rc={r.returncode}): {r.stdout[-600:]} {r.stderr[-600:]}")
        return ms, r.stdout, r.stderr

    bbr_warm_ms, bbr_warm_out, _ = run_bbr(["--adopt-p130"], "bbr_warm.log")
    bbr_matches = sum(1 for m in mod_names if sha256(bbr_obj / f"{m}.o") == cold_sha[m])
    assert bbr_matches == K, f"bend_build_real .o mismatch: {bbr_matches}/{K}"
    print(f"  [2D-1 bend_build_real warm --jobs 7] {bbr_warm_ms/1000:.2f}s | {bbr_matches}/{K} .o BIT-IDENTICAL!", flush=True)

    noop_runs = []
    for k_i in range(3):
        nms, nout, _ = run_bbr([], f"bbr_noop_{k_i}.log")
        noop_runs.append(nms)
    noop_med = round(median(noop_runs), 1)
    print(f"  [2D-2 bend_build_real no-op] median={noop_med} ms (runs={noop_runs})", flush=True)

    # 2D-3: Incremental 1-module leaf edit via bend_build_real (copy m11 to bbr_dir so we don't mutate k14_wave15!)
    m11_bbr_copy = bbr_dir / f"{entry_mod}.bend"
    m11_bbr_copy.write_text((k_dir / f"{entry_mod}.bend").read_text(encoding="utf-8").replace('"stage=read ms="', '"stage=read_bbr ms="', 1), encoding="utf-8")
    mlines_edit = mlines[:-1] + [f"{entry_mod} {m11_bbr_copy} {cold_used_bases[entry_mod]} {bbr_obj / (entry_mod + '.o')} {import_base_f} -"]
    bbr_manifest.write_text("\n".join(mlines_edit) + "\n", encoding="utf-8")
    bbr_inc_ms, bbr_inc_out, _ = run_bbr([], "bbr_inc.log")
    bbr_sm = smoke_slice(bbr_bin, "bbr_inc", smoke_dir, "x86-object-fast", cpu=0)
    assert "read_bbr" in bbr_sm["trace_stages"]
    print(f"  [2D-3 bend_build_real leaf {entry_mod} edit] {bbr_inc_ms/1000:.2f}s | smoke out={bbr_sm['out']} stage=read_bbr OK", flush=True)

    res["stage2d_bend_build_real"] = {
        "warm_7c_ms": bbr_warm_ms,
        "warm_bit_identical": f"{bbr_matches}/{K}",
        "noop_median_ms": noop_med,
        "noop_runs_ms": noop_runs,
        "leaf_edit_ms": bbr_inc_ms,
        "leaf_edit_smoke_out": bbr_sm["out"],
    }
    save_results(res)
    shutil.rmtree(bbr_dir, ignore_errors=True)

    # ------------------------------------------------------------------
    # STAGE 2E: SELF-REPRO BIT-IDENTITY (n7_cold -> n8_warm, 7 cores!)
    # ------------------------------------------------------------------
    print(f"\n=== STAGE 2E: SELF-REPRO BIT-IDENTITY (n7_cold -> n8_check, {K}/{K} on CPUs 0..6) ===", flush=True)
    n8_obj = COLD_DIR / "obj_n8"
    n8_logs = COLD_DIR / "logs_n8"
    t_2e_0 = time.perf_counter()
    s2e = warm_7core_build(
        n7_cold, "x86-module-fast", mod_names, src_paths, cold_used_bases,
        s2a["carriers"], n8_obj, n8_logs, "s2e_n8", lpt_order,
    )
    merge_n8 = n8_obj / "merge_n8.o"
    n8_merge_ms, _ = run_native(
        n7_cold, ["x86-merge-obj", mod_names[-1], mod_names[-1], *mod_names[:-1]],
        merge_n8, n8_logs / "merge.err", cpu=0, timeout=60,
    )
    e2e_2e_ms = round((time.perf_counter() - t_2e_0) * 1000.0, 1)
    n8_sha = {r["module"]: r["sha256"] for r in s2e["mod_records"]}
    n8_merge_sha = sha256(merge_n8)
    n8_matches = sum(1 for m in mod_names if n8_sha[m] == cold_sha[m])
    assert n8_matches == K, f"n7_cold vs n6_o2 .o mismatch: {n8_matches}/{K}"
    assert n8_merge_sha == cold_merge_sha, "n7_cold vs n6_o2 merge.o mismatch!"
    print(
        f"  [STAGE 2E SELF-REPRO BIT-IDENTITY] {n8_matches}/{K} .o + merge.o 100% SHA-256 BIT-IDENTICAL "
        f"(n6_o2 == n7_cold) in {e2e_2e_ms/1000:.2f}s!",
        flush=True,
    )
    res["stage2e_self_repro_identity"] = {
        "compile_wall_ms": s2e["compile_wall_ms"],
        "merge_ms": n8_merge_ms,
        "total_ms": e2e_2e_ms,
        "bit_identical_objs": f"{n8_matches}/{K} + merge.o",
        "merge_sha256": n8_merge_sha,
    }
    save_results(res)

    print("\n=== ALL WAVE 15 STAGES PASSED 100%! ===", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
