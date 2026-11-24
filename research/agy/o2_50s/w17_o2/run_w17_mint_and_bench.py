#!/usr/bin/env python3
"""Wave 17 Mint (Stage 0 -> Stage 1 n8_o2) + Official 8-Core Cold -O2/-O0 Self-Compile Benchmark."""
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
N8_O2 = ROOT / "selfhost/build/agy/wave17-native-mod/n8_o2"
N8_STAGE0 = Path("/tmp/agy_w17q/n8_stage0")
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

ORACLE_W16_O0 = ROOT / "research/agy/s10_campaign/w16_final/p113d_oracle_w16_n7.txt"
ORACLE_W16_O2 = ROOT / "research/agy/s10_campaign/w16_final/p113d_oracle_w16_o2.txt"
OUT_DIR = ROOT / "research/agy/o2_50s/w17_o2"
ORACLE_W17_O2 = OUT_DIR / "p113d_oracle_w17_o2.txt"
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


def decode_p113d_sym(sym: str) -> str:
    tail = sym[len("p113d_FID_"):].split("___")[0]
    nums = [p for p in tail.split("_") if p]
    if nums and all(p.isdigit() for p in nums):
        nm = "".join(chr(int(p)) for p in nums)
        if nm.startswith("$direct."):
            return nm[len("$direct."):]
        return nm
    return ""


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


def stage0_mint_stage0(state: dict, resume: bool = False) -> None:
    k_dir = ROOT / "selfhost/build/agy/wave17_unified/k10_wave17"
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    work = Path("/tmp/agy_w17q/s0")
    src_dir, obj_dir = work / "src", work / "obj"

    o0_set = {x.strip() for x in ORACLE_W16_O0.read_text().splitlines() if x.strip()}
    o2_set = {x.strip() for x in ORACLE_W16_O2.read_text().splitlines() if x.strip()}
    safe_oracle = o0_set & o2_set
    t0 = time.perf_counter()
    if resume and all((obj_dir / f"{m}.o").exists() for m in mod_names):
        print(f"\n=== STAGE 0 (RESUME): Fixing undefined p113d in existing {obj_dir} ===", flush=True)
        # Recompute exact fid_bases from existing objects' seg counts (same formula as repack_if_needed)
        segs_list = [mb.get_seg_count(obj_dir / f"{m}.o", m) for m in mod_names]
        total_segs = sum(segs_list)
        margin = (65532 - total_segs) // len(mod_names)
        fid_bases: dict[str, int] = {}
        cur = 0
        for m, sg in zip(mod_names, segs_list):
            fid_bases[m] = cur
            cur += sg + margin
        comp = {"wall_ms": 0.0, "total_segs": total_segs}
    else:
        if work.exists():
            shutil.rmtree(work)
        print(f"\n=== STAGE 0: Mint n8_stage0 (-O0 via n7_o2 on k10_wave17, oracle={len(safe_oracle)}) ===", flush=True)
        gen_stubs.generate_all(k_dir, src_dir, abi_mode="oracle", direct_set=safe_oracle)
        comp = compile_k_parallel(N7_O2, k_dir, src_dir, obj_dir, CPUS, ["--trace", "x86-module-fast"], timeout_s=180)
        comp, fits, _ = repack_if_needed(comp, N7_O2, src_dir, obj_dir, CPUS, ["--trace", "x86-module-fast"], timeout_s=180)
        assert fits, f"Stage 0 FID overflow: {comp['total_segs']}"
        fid_bases = {r["mod"]: r["fid_base"] for r in comp["modules"]}

    fix_undefined_p113d(N7_O2, k_dir, src_dir, obj_dir, mod_names, fid_bases, safe_oracle, CPUS, ["--trace", "x86-module-fast"], timeout_s=180)
    N8_STAGE0.parent.mkdir(parents=True, exist_ok=True)
    merge_ms, link_ms = mb.merge_and_link(N7_O2, mod_names, obj_dir, obj_dir / "merge.o", N8_STAGE0, cpu=0)
    wall_s = round(time.perf_counter() - t0, 2)
    print(f"  Linked {N8_STAGE0} ({N8_STAGE0.stat().st_size:,} B) | segs={comp['total_segs']}/65532 | wall={wall_s}s", flush=True)
    smoke = mb.smoke_binary(N8_STAGE0, work / "smoke", cpu=0, run_o2=True)
    shutil.rmtree(work, ignore_errors=True)
    state["stage0"] = {
        "n8_stage0_bytes": N8_STAGE0.stat().st_size,
        "wall_s": wall_s,
        "compile_wall_ms": comp["wall_ms"],
        "total_segs": comp["total_segs"],
        "merge_ms": merge_ms,
        "link_ms": link_ms,
        "smoke": smoke,
    }
    STATE_JSON.write_text(json.dumps(state, indent=2) + "\n")


def stage1_mint_n8_o2(state: dict, k: int = 16) -> None:
    k_dir = ROOT / f"selfhost/build/agy/wave17_unified/k{k}_wave17"
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    work = Path("/tmp/agy_w17q/s1")
    if work.exists():
        shutil.rmtree(work)
    src_dir, obj_dir = work / "src", work / "obj"

    o0_set = {x.strip() for x in ORACLE_W16_O0.read_text().splitlines() if x.strip()}
    o2_set = {x.strip() for x in ORACLE_W16_O2.read_text().splitlines() if x.strip()}
    safe_oracle = o0_set & o2_set
    print(f"\n=== STAGE 1: Mint TRUE -O2 n8_o2 (via n8_stage0 x86-module on k{k}_wave17, FULL RECLAMATION) ===", flush=True)
    t0 = time.perf_counter()
    gen_stubs.generate_all(k_dir, src_dir, abi_mode="oracle", direct_set=safe_oracle)
    mode_args = ["--trace", "x86-module"]
    comp = compile_k_parallel(N8_STAGE0, k_dir, src_dir, obj_dir, CPUS, mode_args, timeout_s=600)
    comp, fits, repacked = repack_if_needed(comp, N8_STAGE0, src_dir, obj_dir, CPUS, mode_args, timeout_s=600)
    assert fits, f"Stage 1 K={k} FID overflow: {comp['total_segs']}"
    fid_bases = {r["mod"]: r["fid_base"] for r in comp["modules"]}
    fix_undefined_p113d(N8_STAGE0, k_dir, src_dir, obj_dir, mod_names, fid_bases, safe_oracle, CPUS, mode_args, timeout_s=600)

    N8_O2.parent.mkdir(parents=True, exist_ok=True)
    merge_ms, link_ms = mb.merge_and_link(N8_STAGE0, mod_names, obj_dir, obj_dir / "merge.o", N8_O2, cpu=0)
    wall_s = round(time.perf_counter() - t0, 2)
    print(f"  Linked {N8_O2} ({N8_O2.stat().st_size:,} B) | segs={comp['total_segs']}/65532 | wall={wall_s}s", flush=True)

    # Extract exact Wave 17 -O2 direct oracle from n8_o2 .o files!
    w17_oracle = extract_direct_oracle(obj_dir, mod_names)
    ORACLE_W17_O2.write_text("\n".join(sorted(w17_oracle)) + "\n", encoding="utf-8")
    print(f"  Extracted {len(w17_oracle)} exact Wave 17 -O2 direct symbols -> {ORACLE_W17_O2}", flush=True)

    smoke = mb.smoke_binary(N8_O2, work / "smoke", cpu=0, run_o2=True)
    shutil.rmtree(work, ignore_errors=True)
    if N8_STAGE0.exists():
        N8_STAGE0.unlink()
    state["stage1_n8_o2"] = {
        "k": k,
        "n8_o2_bytes": N8_O2.stat().st_size,
        "wall_s": wall_s,
        "compile_wall_ms": comp["wall_ms"],
        "compile_cpu_sum_ms": comp["cpu_sum_ms"],
        "max_rss_mib": comp["max_rss_mib"],
        "total_segs": comp["total_segs"],
        "repacked": repacked is not None,
        "merge_ms": merge_ms,
        "link_ms": link_ms,
        "w17_o2_oracle_count": len(w17_oracle),
        "smoke": smoke,
        "modules": comp["modules"],
    }
    STATE_JSON.write_text(json.dumps(state, indent=2) + "\n")


def run_cold_bench(label: str, k: int, mode_args: list[str], work_root: Path, run_o2_smoke: bool = True) -> dict:
    k_dir = ROOT / f"selfhost/build/agy/wave17_unified/k{k}_wave17"
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    if work_root.exists():
        shutil.rmtree(work_root)
    work_root.mkdir(parents=True, exist_ok=True)
    src_dir, obj_dir = work_root / "src", work_root / "obj"

    # Use safe Wave 17 oracle (if -O0 mode, intersect with o0_set so -O0 doesn't expect -O2-only direct fns)
    w17_set = {x.strip() for x in ORACLE_W17_O2.read_text().splitlines() if x.strip()}
    if "x86-module-fast" in mode_args:
        o0_set = {x.strip() for x in ORACLE_W16_O0.read_text().splitlines() if x.strip()}
        oracle_set = w17_set & o0_set
    else:
        oracle_set = w17_set

    print(
        f"\n=== OFFICIAL 8-CORE ZERO-CACHE COLD SELF-COMPILE: {label} (K={k}, mode={mode_args}, EMPTY {work_root}) ===",
        flush=True,
    )
    t_all0 = time.perf_counter()
    stub_meta = gen_stubs.generate_all(k_dir, src_dir, abi_mode="oracle", direct_set=oracle_set)
    stub_ms = stub_meta["elapsed_ms"]
    print(f"  [1/3] gen_stubs: {stub_ms:.1f} ms (oracle={len(oracle_set)})", flush=True)

    comp = compile_k_parallel(N8_O2, k_dir, src_dir, obj_dir, CPUS, mode_args, timeout_s=300)
    print(
        f"  [2/3] compile_wall: {comp['wall_ms']:.1f} ms ({comp['wall_ms']/1000:.2f}s) | "
        f"cpu_sum={comp['cpu_sum_ms']:.1f} ms | max_rss={comp['max_rss_mib']:.1f} MiB | "
        f"segs={comp['total_segs']}/65532",
        flush=True,
    )
    comp, fits, repacked = repack_if_needed(comp, N8_O2, src_dir, obj_dir, CPUS, mode_args, timeout_s=300)
    assert fits, f"{label} K={k} FID overflow: {comp['total_segs']}"

    out_bin = work_root / f"n9_{label}"
    merge_ms, link_ms = mb.merge_and_link(N8_O2, mod_names, obj_dir, obj_dir / "merge.o", out_bin, cpu=0)
    total_ms = round((time.perf_counter() - t_all0) * 1000.0, 1)
    print(f"  [3/3] merge={merge_ms:.1f} ms | link={link_ms:.1f} ms", flush=True)
    print(
        f"  >>> TOTAL 8-CORE ZERO-CACHE COLD WALL TIME ({label}, K={k}): "
        f"{total_ms:.1f} ms ({total_ms/1000:.2f} s) | cpu_sum={comp['cpu_sum_ms']:.1f} ms | "
        f"max_rss={comp['max_rss_mib']:.1f} MiB | segs={comp['total_segs']}/65532 <<<",
        flush=True,
    )
    smoke = mb.smoke_binary(out_bin, work_root / "smoke", cpu=0, run_o2=run_o2_smoke)
    bin_bytes = out_bin.stat().st_size
    shutil.rmtree(work_root, ignore_errors=True)
    return {
        "label": label,
        "k": k,
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


def stage2_cold_benchmarks(state: dict, k: int = 16) -> None:
    cold = state.setdefault("stage2_cold", {})
    # 1. Official -O2 Cold (normal mode, full reclamation)
    cold[f"o2_normal_k{k}"] = run_cold_bench(
        f"o2_normal_k{k}", k, ["--trace", "x86-module"], Path("/tmp/agy_w17c_cold_o2"), run_o2_smoke=True
    )
    STATE_JSON.write_text(json.dumps(state, indent=2) + "\n")

    # 2. Official -O0 Cold (normal mode, full reclamation)
    cold[f"o0_normal_k{k}"] = run_cold_bench(
        f"o0_normal_k{k}", k, ["--trace", "x86-module-fast"], Path("/tmp/agy_w17c_cold_o0"), run_o2_smoke=False
    )
    STATE_JSON.write_text(json.dumps(state, indent=2) + "\n")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--stages", type=str, default="0,1,2")
    ap.add_argument("--k", type=int, default=16)
    ap.add_argument("--resume-s0", action="store_true")
    args = ap.parse_args()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    state = json.loads(STATE_JSON.read_text()) if STATE_JSON.exists() else {}
    stages = [int(x) for x in args.stages.split(",") if x.strip()]
    if 0 in stages:
        stage0_mint_stage0(state, resume=args.resume_s0)
    if 1 in stages:
        stage1_mint_n8_o2(state, k=args.k)
    if 2 in stages:
        stage2_cold_benchmarks(state, k=args.k)


if __name__ == "__main__":
    main()
