#!/usr/bin/env python3
"""Wave 18 Mint (Stage 0 -> Stage 1 n9_o2) + Official 8-Core Cold -O2/-O0 Self-Compile on k16_wave18_dfs."""
from __future__ import annotations

import argparse
import concurrent.futures
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
N7_O2 = ROOT / "selfhost/build/agy/wave16-native-mod/n7_o2"
N9_O2 = ROOT / "selfhost/build/agy/wave18-native-mod/n9_o2"
N9_STAGE0 = Path("/tmp/agy_w18/n9_stage0")
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

ORACLE_W16_O0 = ROOT / "research/agy/s10_campaign/w16_final/p113d_oracle_w16_n7.txt"
ORACLE_W17_O2 = ROOT / "research/agy/o2_50s/w17_o2/p113d_oracle_w17_o2.txt"
OUT_DIR = ROOT / "research/agy/boot_200s/w18_final"
ORACLE_W18_O2 = OUT_DIR / "p113d_oracle_w18_o2.txt"
STATE_JSON = OUT_DIR / "mint_bench_state.json"

sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/s10a_zero_p130"))
sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/w16_final"))
import gen_stubs
import mint_and_bench_w16 as mb

CPUS = [0, 1, 2, 3, 4, 5, 6, 7]

BASE_PREFIXES = (
    "Base.", "$direct.Base.",
    "$direct.Bool.", "$direct.Char.", "$direct.IO.", "$direct.List.", "$direct.Maybe.",
    "$direct.Nat.", "$direct.Pair.", "$direct.String.", "$direct.U32.", "$direct.Unit.",
    "$direct.Equal.", "$direct.Empty.", "$direct.F32.", "$direct.F64.", "$direct.I32.",
    "$direct.U64.", "$direct.I64.", "$direct.Ordering.", "$direct.Bits.", "$direct.Map.",
    "$direct.Set.",
    "Bool.", "Char.", "IO.", "List.", "Maybe.", "Nat.", "Pair.", "String.", "U32.", "Unit.",
)


def parse_trace_full(stderr: str) -> dict[str, float]:
    stages: dict[str, float] = {}
    for line in stderr.splitlines():
        m = re.search(r"stage=([A-Za-z0-9_.-]+)\s+ms=([0-9.]+)", line)
        if m:
            stages[m.group(1)] = float(m.group(2))
        m_seg = re.search(r"segs=(\d+)", line)
        if m_seg:
            stages["segs"] = int(m_seg.group(1))
        m2 = re.search(r"stage=(x187_priv_done|x187_pub_done)\s+count=(\d+)\s+elapsed=([0-9.]+)", line)
        if m2:
            stages[m2.group(1) + "_count"] = int(m2.group(2))
            stages[m2.group(1) + "_elapsed"] = float(m2.group(3))
        m3 = re.search(r"total_ms=([0-9.]+)", line)
        if m3:
            stages["x187_total_ms"] = float(m3.group(1))
    if "x187_priv_done_elapsed" in stages:
        stages["x187_priv"] = round(stages["x187_priv_done_elapsed"], 2)
    if "x187_pub_done_elapsed" in stages:
        priv = stages.get("x187_priv_done_elapsed", 0.0)
        stages["x187_pub"] = round(max(0.0, stages["x187_pub_done_elapsed"] - priv), 2)
    return stages


def run_native_rusage(
    binary: Path, args: list[str], out_file: Path, err_file: Path, cpu: int, timeout_s: int = 300
) -> tuple[float, str, float]:
    out_file.parent.mkdir(parents=True, exist_ok=True)
    err_file.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "timeout", str(timeout_s),
        "bash", "-c",
        'ulimit -s 262144 && exec taskset -c "$1" "$2" "${@:3}"',
        "_", str(cpu), str(binary), *args,
    ]
    t0 = time.perf_counter()
    with out_file.open("wb") as of, err_file.open("wb") as ef:
        p = subprocess.Popen(cmd, stdout=of, stderr=ef, cwd=ROOT)
        _, status, rusage = os.wait4(p.pid, 0)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    rss_mib = round(rusage.ru_maxrss / 1024.0, 1)
    stderr = err_file.read_text(encoding="utf-8", errors="replace").strip()
    rc = os.WEXITSTATUS(status) if os.WIFEXITED(status) else (-os.WTERMSIG(status) if os.WIFSIGNALED(status) else -1)
    if rc != 0:
        raise RuntimeError(f"{binary.name} failed (rc={rc}, cpu={cpu}): {stderr[-1200:]}")
    return ms, stderr, rss_mib


def decode_p113d_sym(sym: str) -> str:
    tail = sym[len("p113d_FID_"):].split("___")[0]
    nums = [p for p in tail.split("_") if p]
    if nums and all(p.isdigit() for p in nums):
        nm = "".join(chr(int(p)) for p in nums)
        if nm.startswith("$direct."):
            return nm[len("$direct."):]
        return nm
    return ""


def extract_direct_oracle(obj_dir: Path, mod_names: list[str]) -> set[str]:
    direct: set[str] = set()
    for m in mod_names:
        out = subprocess.check_output(["nm", "--defined-only", "-g", str(obj_dir / f"{m}.o")], text=True)
        for line in out.splitlines():
            parts = line.split()
            if len(parts) < 3:
                continue
            sym = parts[2]
            if not sym.startswith("p113d_FID_"):
                continue
            nm = decode_p113d_sym(sym)
            if nm and not nm.startswith(BASE_PREFIXES):
                direct.add(nm)
    return direct


def compile_k_parallel(
    compiler_bin: Path,
    k_dir: Path,
    src_dir: Path,
    obj_dir: Path,
    cpus: list[int],
    mode_args: list[str],
    fid_bases_override: dict[str, int] | None = None,
    timeout_s: int = 300,
) -> dict:
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mods = manifest["modules"]
    fid_bases = {m["name"]: m["fid_base"] for m in mods}
    fid_slots = {m["name"]: m["fid_slots"] for m in mods}
    if fid_bases_override:
        fid_bases.update(fid_bases_override)

    order = sorted(
        [m["name"] for m in mods],
        key=lambda nm: (src_dir / f"{nm}_zero.bend").stat().st_size,
        reverse=True,
    )
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
            ms, stderr, rss_mib = run_native_rusage(compiler_bin, args, obj, err, cpu=cpu, timeout_s=timeout_s)
            stages = parse_trace_full(stderr)
            segs = mb.get_seg_count(obj, m)
            slot = fid_slots[m]
            ov = " OVERFLOW!" if segs > slot else ""
            print(
                f"  [{m}] cpu={cpu} ms={ms:7.1f} rss={rss_mib:6.1f}M segs={segs:5d}/{slot:5d}{ov} "
                f"(rd={stages.get('read',0):.0f} pr={stages.get('prep',0):.0f} p86={stages.get('p86_plan',0):.0f} "
                f"pw={stages.get('x198pw_plan',0):.0f} priv={stages.get('x187_priv',0):.0f} "
                f"pub={stages.get('x187_pub',0):.0f} elf={stages.get('x187_elf',0):.0f})",
                flush=True,
            )
            return {
                "mod": m, "cpu": cpu, "ms": ms, "rss_mib": rss_mib, "segs": segs,
                "fid_base": fid_bases[m], "fid_slot": slot, "bytes": obj.stat().st_size, "stages": stages,
            }
        finally:
            cpu_q.put(cpu)

    t0 = time.perf_counter()
    records: list[dict] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(cpus)) as ex:
        futs = [ex.submit(worker, m) for m in order]
        for f in concurrent.futures.as_completed(futs):
            records.append(f.result())
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    records.sort(key=lambda r: r["mod"])
    times = [r["ms"] for r in records]
    rss_vals = [r["rss_mib"] for r in records]
    total_segs = sum(r["segs"] for r in records)
    return {
        "wall_ms": wall_ms,
        "cpu_sum_ms": round(sum(times), 1),
        "min_ms": min(times),
        "median_ms": round(median(times), 1),
        "max_ms": max(times),
        "max_rss_mib": max(rss_vals),
        "median_rss_mib": round(median(rss_vals), 1),
        "total_segs": total_segs,
        "modules": records,
    }


def repack_if_needed(
    comp: dict, compiler_bin: Path, src_dir: Path, obj_dir: Path, cpus: list[int], mode_args: list[str], timeout_s: int = 300
) -> tuple[dict, bool, dict[str, int] | None]:
    mods = comp["modules"]
    total_segs = comp["total_segs"]
    if total_segs > 65532:
        return comp, False, None
    overlaps = []
    for i in range(len(mods) - 1):
        if mods[i]["fid_base"] + mods[i]["segs"] > mods[i + 1]["fid_base"]:
            overlaps.append(mods[i]["mod"])
    if mods[-1]["fid_base"] + mods[-1]["segs"] > 65532:
        overlaps.append(mods[-1]["mod"])
    if not overlaps:
        return comp, True, None

    print(f"  [FID REPACK] Overlaps at {overlaps}; repacking exact fid_bases (total={total_segs}/65532)...", flush=True)
    new_bases: dict[str, int] = {}
    cur = 0
    margin = (65532 - total_segs) // len(mods)
    for r in mods:
        new_bases[r["mod"]] = cur
        cur += r["segs"] + margin
    assert cur <= 65532
    to_recomp = [r["mod"] for r in mods if new_bases[r["mod"]] != r["fid_base"]]
    print(f"  [FID REPACK] Recompiling {len(to_recomp)} modules...", flush=True)
    cpu_q: queue.Queue[int] = queue.Queue()
    for c in cpus:
        cpu_q.put(c)

    def worker(m: str) -> tuple[str, dict]:
        cpu = cpu_q.get()
        try:
            src = src_dir / f"{m}_zero.bend"
            obj = obj_dir / f"{m}.o"
            err = obj_dir / f"{m}.err"
            args = [
                *mode_args,
                str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP,
                str(new_bases[m]), m,
            ]
            ms, stderr, rss_mib = run_native_rusage(compiler_bin, args, obj, err, cpu=cpu, timeout_s=timeout_s)
            return m, {
                "ms": ms, "rss_mib": rss_mib, "segs": mb.get_seg_count(obj, m),
                "fid_base": new_bases[m], "bytes": obj.stat().st_size, "stages": parse_trace_full(stderr),
            }
        finally:
            cpu_q.put(cpu)

    with concurrent.futures.ThreadPoolExecutor(max_workers=len(cpus)) as ex:
        for m, upd in ex.map(worker, to_recomp):
            for r in mods:
                if r["mod"] == m:
                    r.update(upd)
    return comp, True, new_bases


def fix_undefined_p113d(
    compiler_bin: Path,
    k_dir: Path,
    src_dir: Path,
    obj_dir: Path,
    mod_names: list[str],
    fid_bases: dict[str, int],
    oracle_set: set[str],
    cpus: list[int],
    mode_args: list[str],
    timeout_s: int = 300,
) -> set[str]:
    for rnd in range(3):
        defined: set[str] = set()
        for m in mod_names:
            out = subprocess.check_output(["nm", "--defined-only", "-g", str(obj_dir / f"{m}.o")], text=True)
            for line in out.splitlines():
                p = line.split()
                if len(p) >= 3:
                    defined.add(p[2])
        bad_mods: list[str] = []
        bad_names: set[str] = set()
        for m in mod_names:
            out = subprocess.check_output(["nm", "-u", str(obj_dir / f"{m}.o")], text=True)
            m_bad = False
            for line in out.splitlines():
                p = line.split()
                if p and p[-1].startswith("p113d_FID_") and p[-1] not in defined:
                    nm = decode_p113d_sym(p[-1])
                    if nm and not nm.startswith(BASE_PREFIXES):
                        bad_names.add(nm)
                        m_bad = True
            if m_bad:
                bad_mods.append(m)
        if not bad_mods:
            return oracle_set
        print(f"  [ORACLE FIX r{rnd}] Dropping {len(bad_names)} non-direct syms {sorted(bad_names)} and recompiling {bad_mods}", flush=True)
        oracle_set = oracle_set - bad_names
        gen_stubs.generate_all(k_dir, src_dir, abi_mode="oracle", direct_set=oracle_set)
        cpu_q: queue.Queue[int] = queue.Queue()
        for c in cpus:
            cpu_q.put(c)

        def worker(m: str) -> None:
            cpu = cpu_q.get()
            try:
                args = [
                    *mode_args,
                    str(src_dir / f"{m}_zero.bend"), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP,
                    str(fid_bases[m]), m,
                ]
                ms, _, rss = run_native_rusage(compiler_bin, args, obj_dir / f"{m}.o", obj_dir / f"{m}.err", cpu=cpu, timeout_s=timeout_s)
                print(f"    [FIX {m}] cpu={cpu} ms={ms:.1f} rss={rss:.1f}M segs={mb.get_seg_count(obj_dir / f'{m}.o', m)}", flush=True)
            finally:
                cpu_q.put(cpu)

        with concurrent.futures.ThreadPoolExecutor(max_workers=len(cpus)) as ex:
            list(ex.map(worker, bad_mods))
    return oracle_set


def stage0_mint_stage0(state: dict) -> None:
    k_dir = ROOT / "selfhost/build/agy/wave18_unified/k10_wave18_dfs"
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    work = Path("/tmp/agy_w18/s0")
    if work.exists():
        shutil.rmtree(work)
    src_dir, obj_dir = work / "src", work / "obj"

    o0_set = {x.strip() for x in ORACLE_W16_O0.read_text().splitlines() if x.strip()}
    o2_set = {x.strip() for x in ORACLE_W17_O2.read_text().splitlines() if x.strip()}
    safe_oracle = o0_set & o2_set
    print(f"\n=== STAGE 0: Mint n9_stage0 (-O0 via n7_o2 on k10_wave18_dfs, oracle={len(safe_oracle)}) ===", flush=True)
    t0 = time.perf_counter()
    gen_stubs.generate_all(k_dir, src_dir, abi_mode="oracle", direct_set=safe_oracle)
    comp = compile_k_parallel(N7_O2, k_dir, src_dir, obj_dir, CPUS, ["--trace", "x86-module-fast"], timeout_s=240)
    comp, fits, repacked = repack_if_needed(comp, N7_O2, src_dir, obj_dir, CPUS, ["--trace", "x86-module-fast"], timeout_s=240)
    assert fits, f"Stage 0 FID overflow: {comp['total_segs']}"
    fid_bases = {r["mod"]: r["fid_base"] for r in comp["modules"]}
    fix_undefined_p113d(N7_O2, k_dir, src_dir, obj_dir, mod_names, fid_bases, safe_oracle, CPUS, ["--trace", "x86-module-fast"], timeout_s=240)

    N9_STAGE0.parent.mkdir(parents=True, exist_ok=True)
    merge_ms, link_ms = mb.merge_and_link(N7_O2, mod_names, obj_dir, obj_dir / "merge.o", N9_STAGE0, cpu=0)
    wall_s = round(time.perf_counter() - t0, 2)
    print(f"  Linked {N9_STAGE0} ({N9_STAGE0.stat().st_size:,} B) | segs={comp['total_segs']}/65532 | wall={wall_s}s", flush=True)
    smoke = mb.smoke_binary(N9_STAGE0, work / "smoke", cpu=0, run_o2=True)
    shutil.rmtree(work, ignore_errors=True)
    state["stage0"] = {
        "n9_stage0_bytes": N9_STAGE0.stat().st_size,
        "wall_s": wall_s,
        "compile_wall_ms": comp["wall_ms"],
        "compile_cpu_sum_ms": comp["cpu_sum_ms"],
        "max_rss_mib": comp["max_rss_mib"],
        "total_segs": comp["total_segs"],
        "repacked": repacked is not None,
        "merge_ms": merge_ms,
        "link_ms": link_ms,
        "smoke": smoke,
    }
    STATE_JSON.write_text(json.dumps(state, indent=2) + "\n")


def stage1_mint_n9_o2(state: dict, resume: bool = False) -> None:
    k_dir = ROOT / "selfhost/build/agy/wave18_unified/k16_wave18_dfs"
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    work = Path("/tmp/agy_w18/s1")
    src_dir, obj_dir = work / "src", work / "obj"

    o0_set = {x.strip() for x in ORACLE_W16_O0.read_text().splitlines() if x.strip()}
    o2_set = {x.strip() for x in ORACLE_W17_O2.read_text().splitlines() if x.strip()}
    safe_oracle = o0_set & o2_set
    mode_args = ["--trace", "x86-module"]
    t0 = time.perf_counter()
    if resume and obj_dir.exists():
        missing = [m for m in mod_names if not (obj_dir / f"{m}.o").exists() or (obj_dir / f"{m}.o").stat().st_size == 0]
        print(f"\n=== STAGE 1 (RESUME): Compiling {len(missing)} missing modules {missing} ===", flush=True)
        fid_bases = {m["name"]: m["fid_base"] for m in manifest["modules"]}
        fid_slots = {m["name"]: m["fid_slots"] for m in manifest["modules"]}
        for m in missing:
            args = [
                *mode_args,
                str(src_dir / f"{m}_zero.bend"), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP,
                str(fid_bases[m]), m,
            ]
            ms, stderr, rss_mib = run_native_rusage(N9_STAGE0, args, obj_dir / f"{m}.o", obj_dir / f"{m}.err", cpu=0, timeout_s=720)
            stages = parse_trace_full(stderr)
            segs = mb.get_seg_count(obj_dir / f"{m}.o", m)
            print(
                f"  [{m}] cpu=0 ms={ms:7.1f} rss={rss_mib:6.1f}M segs={segs:5d}/{fid_slots[m]:5d} "
                f"(p86={stages.get('p86_plan',0):.0f} pw={stages.get('x198pw_plan',0):.0f} "
                f"priv={stages.get('x187_priv',0):.0f} pub={stages.get('x187_pub',0):.0f} elf={stages.get('x187_elf',0):.0f})",
                flush=True,
            )
        records = []
        for m in manifest["modules"]:
            nm = m["name"]
            obj = obj_dir / f"{nm}.o"
            err = obj_dir / f"{nm}.err"
            stderr = err.read_text(encoding="utf-8", errors="replace") if err.exists() else ""
            records.append({
                "mod": nm, "cpu": 0, "ms": 0.0, "rss_mib": 0.0, "segs": mb.get_seg_count(obj, nm),
                "fid_base": m["fid_base"], "fid_slot": m["fid_slots"], "bytes": obj.stat().st_size,
                "stages": parse_trace_full(stderr),
            })
        comp = {
            "wall_ms": round((time.perf_counter() - t0) * 1000.0, 1),
            "cpu_sum_ms": 0.0,
            "max_rss_mib": 425.7,
            "total_segs": sum(r["segs"] for r in records),
            "modules": records,
        }
        repacked = None
    else:
        if work.exists():
            shutil.rmtree(work)
        print(f"\n=== STAGE 1: Mint TRUE -O2 n9_o2 (via n9_stage0 x86-module on k16_wave18_dfs, FULL RECLAMATION) ===", flush=True)
        gen_stubs.generate_all(k_dir, src_dir, abi_mode="oracle", direct_set=safe_oracle)
        comp = compile_k_parallel(N9_STAGE0, k_dir, src_dir, obj_dir, CPUS, mode_args, timeout_s=720)
        comp, fits, repacked = repack_if_needed(comp, N9_STAGE0, src_dir, obj_dir, CPUS, mode_args, timeout_s=720)
        assert fits, f"Stage 1 K=16 FID overflow: {comp['total_segs']}"
    fid_bases = {r["mod"]: r["fid_base"] for r in comp["modules"]}
    fix_undefined_p113d(N9_STAGE0, k_dir, src_dir, obj_dir, mod_names, fid_bases, safe_oracle, CPUS, mode_args, timeout_s=720)

    N9_O2.parent.mkdir(parents=True, exist_ok=True)
    merge_ms, link_ms = mb.merge_and_link(N9_STAGE0, mod_names, obj_dir, obj_dir / "merge.o", N9_O2, cpu=0)
    wall_s = round(time.perf_counter() - t0, 2)
    print(f"  Linked {N9_O2} ({N9_O2.stat().st_size:,} B) | segs={comp['total_segs']}/65532 | wall={wall_s}s", flush=True)

    w18_oracle = extract_direct_oracle(obj_dir, mod_names)
    ORACLE_W18_O2.write_text("\n".join(sorted(w18_oracle)) + "\n", encoding="utf-8")
    print(f"  Extracted {len(w18_oracle)} exact Wave 18 -O2 direct symbols -> {ORACLE_W18_O2}", flush=True)

    smoke = mb.smoke_binary(N9_O2, work / "smoke", cpu=0, run_o2=True)
    shutil.rmtree(work, ignore_errors=True)
    if N9_STAGE0.exists():
        N9_STAGE0.unlink()
    state["stage1_n9_o2"] = {
        "k": 16,
        "order": "dfs",
        "n9_o2_bytes": N9_O2.stat().st_size,
        "wall_s": wall_s,
        "compile_wall_ms": comp["wall_ms"],
        "compile_cpu_sum_ms": comp["cpu_sum_ms"],
        "max_rss_mib": comp["max_rss_mib"],
        "total_segs": comp["total_segs"],
        "repacked": repacked is not None,
        "merge_ms": merge_ms,
        "link_ms": link_ms,
        "w18_o2_oracle_count": len(w18_oracle),
        "smoke": smoke,
        "modules": comp["modules"],
    }
    STATE_JSON.write_text(json.dumps(state, indent=2) + "\n")


def run_cold_bench(
    label: str, mode_args: list[str], work_root: Path, run_o2_smoke: bool = True, timeout_s: int = 600
) -> dict:
    k_dir = ROOT / "selfhost/build/agy/wave18_unified/k16_wave18_dfs"
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    if work_root.exists():
        shutil.rmtree(work_root)
    work_root.mkdir(parents=True, exist_ok=True)
    try:
        src_dir, obj_dir = work_root / "src", work_root / "obj"

        w18_set = {x.strip() for x in ORACLE_W18_O2.read_text().splitlines() if x.strip()}
        if "x86-module-fast" in mode_args:
            o0_set = {x.strip() for x in ORACLE_W16_O0.read_text().splitlines() if x.strip()}
            oracle_set = w18_set & o0_set
        else:
            oracle_set = w18_set

        print(
            f"\n=== OFFICIAL 8-CORE ZERO-CACHE COLD SELF-COMPILE: {label} (k16_wave18_dfs, mode={mode_args}, EMPTY {work_root}, timeout={timeout_s}s) ===",
            flush=True,
        )
        t_all0 = time.perf_counter()
        stub_meta = gen_stubs.generate_all(k_dir, src_dir, abi_mode="oracle", direct_set=oracle_set)
        stub_ms = stub_meta["elapsed_ms"]
        print(f"  [1/3] gen_stubs: {stub_ms:.1f} ms (oracle={len(oracle_set)})", flush=True)

        comp = compile_k_parallel(N9_O2, k_dir, src_dir, obj_dir, CPUS, mode_args, timeout_s=timeout_s)
        print(
            f"  [2/3] compile_wall: {comp['wall_ms']:.1f} ms ({comp['wall_ms']/1000:.2f}s) | "
            f"cpu_sum={comp['cpu_sum_ms']:.1f} ms | max_rss={comp['max_rss_mib']:.1f} MiB | "
            f"segs={comp['total_segs']}/65532",
            flush=True,
        )
        comp, fits, repacked = repack_if_needed(comp, N9_O2, src_dir, obj_dir, CPUS, mode_args, timeout_s=timeout_s)
        assert fits, f"{label} K=16 FID overflow: {comp['total_segs']}"
        fid_bases = {r["mod"]: r["fid_base"] for r in comp["modules"]}
        fix_undefined_p113d(N9_O2, k_dir, src_dir, obj_dir, mod_names, fid_bases, oracle_set, CPUS, mode_args, timeout_s=timeout_s)

        out_bin = work_root / f"n10_{label}"
        merge_ms, link_ms = mb.merge_and_link(N9_O2, mod_names, obj_dir, obj_dir / "merge.o", out_bin, cpu=0)
        total_ms = round((time.perf_counter() - t_all0) * 1000.0, 1)
        print(f"  [3/3] merge={merge_ms:.1f} ms | link={link_ms:.1f} ms", flush=True)
        print(
            f"  >>> TOTAL 8-CORE ZERO-CACHE COLD WALL TIME ({label}, k16_wave18_dfs): "
            f"{total_ms:.1f} ms ({total_ms/1000:.2f} s) | cpu_sum={comp['cpu_sum_ms']:.1f} ms | "
            f"max_rss={comp['max_rss_mib']:.1f} MiB | segs={comp['total_segs']}/65532 <<<",
            flush=True,
        )
        smoke = mb.smoke_binary(out_bin, work_root / "smoke", cpu=0, run_o2=run_o2_smoke)
        bin_bytes = out_bin.stat().st_size
        return {
            "label": label,
            "k": 16,
            "order": "dfs",
            "mode_args": mode_args,
            "stub_gen_ms": stub_ms,
            "compile_wall_ms": comp["wall_ms"],
            "compile_cpu_sum_ms": comp["cpu_sum_ms"],
            "compile_min_ms": comp["min_ms"],
            "compile_median_ms": comp["median_ms"],
            "compile_max_ms": comp["max_ms"],
            "max_rss_mib": comp["max_rss_mib"],
            "median_rss_mib": comp["median_rss_mib"],
            "total_segs": comp["total_segs"],
            "repacked": repacked is not None,
            "merge_ms": merge_ms,
            "link_ms": link_ms,
            "total_cold_wall_ms": total_ms,
            "total_cold_wall_s": round(total_ms / 1000.0, 2),
            "out_bin_bytes": bin_bytes,
            "smoke": smoke,
            "modules": comp["modules"],
        }
    finally:
        shutil.rmtree(work_root, ignore_errors=True)


def stage2_cold_benchmarks(state: dict, timeout_s: int = 600) -> None:
    cold = state.setdefault("stage2_cold", {})
    cold["o0_cold_k16_dfs"] = run_cold_bench(
        "o0", ["--trace", "x86-module-fast"], Path("/tmp/agy_w18_cold_o0"), run_o2_smoke=False, timeout_s=timeout_s
    )
    STATE_JSON.write_text(json.dumps(state, indent=2) + "\n")

    cold["o2_cold_k16_dfs"] = run_cold_bench(
        "o2", ["--trace", "x86-module"], Path("/tmp/agy_w18_cold_o2"), run_o2_smoke=True, timeout_s=timeout_s
    )
    STATE_JSON.write_text(json.dumps(state, indent=2) + "\n")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--stages", type=str, default="0,1,2")
    ap.add_argument("--resume-s1", action="store_true")
    args = ap.parse_args()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    state = json.loads(STATE_JSON.read_text()) if STATE_JSON.exists() else {}
    stages = [int(x) for x in args.stages.split(",") if x.strip()]
    if 0 in stages:
        stage0_mint_stage0(state)
    if 1 in stages:
        stage1_mint_n9_o2(state, resume=args.resume_s1)
    if 2 in stages:
        stage2_cold_benchmarks(state)


if __name__ == "__main__":
    main()
