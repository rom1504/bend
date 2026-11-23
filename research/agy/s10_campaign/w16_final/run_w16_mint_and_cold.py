#!/usr/bin/env python3
"""Wave 16 Complete Mint & Official 8-Core Zero-Cache Cold Self-Compile Driver (Stages 1-3)."""
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
N6_O2 = ROOT / "selfhost/build/agy/wave15-native-mod/n6_o2"
N7_O2 = ROOT / "selfhost/build/agy/wave16-native-mod/n7_o2"
N7_O2_ND = ROOT / "selfhost/build/agy/wave16-native-mod/n7_o2_nodrop"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

ORACLE_W16 = ROOT / "research/agy/s10_campaign/w16_final/p113d_oracle_w16_n7.txt"
ORACLE_W16_O2 = ROOT / "research/agy/s10_campaign/w16_final/p113d_oracle_w16_o2.txt"
OUT_DIR = ROOT / "research/agy/s10_campaign/w16_final"
STATE_JSON = OUT_DIR / "stage1_3_results.json"

W16_SRC = ROOT / "selfhost/build/agy/wave16_unified/compiler.bend"
sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/s10a_zero_p130"))
sys.path.insert(0, str(ROOT / "research/agy/w15_final"))
sys.path.insert(0, str(OUT_DIR))
import gen_stubs
import mint_and_bench_w16 as mb
import run_w15_n6_o2 as w15

w15.ALLOWED_CPUS = (0, 1, 2, 3, 4, 5, 6, 7)

CPUS = [0, 1, 2, 3, 4, 5, 6, 7]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


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
    """Run native binary pinned to cpu, returning (elapsed_ms, stderr_text, max_rss_mib)."""
    out_file.parent.mkdir(parents=True, exist_ok=True)
    err_file.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "timeout",
        str(timeout_s),
        "bash",
        "-c",
        'ulimit -s 262144 && exec taskset -c "$1" "$2" "${@:3}"',
        "_",
        str(cpu),
        str(binary),
        *args,
    ]
    t0 = time.perf_counter()
    with out_file.open("wb") as of, err_file.open("wb") as ef:
        p = subprocess.Popen(cmd, stdout=of, stderr=ef, cwd=ROOT)
        _, status, rusage = os.wait4(p.pid, 0)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    rss_mib = round(rusage.ru_maxrss / 1024.0, 1)
    stderr = err_file.read_text(encoding="utf-8", errors="replace").strip()
    if os.WIFEXITED(status):
        rc = os.WEXITSTATUS(status)
    elif os.WIFSIGNALED(status):
        rc = -os.WTERMSIG(status)
    else:
        rc = -1
    if rc != 0:
        raise RuntimeError(f"{binary.name} failed (rc={rc}, cpu={cpu}): {stderr[-1200:]}")
    return ms, stderr, rss_mib


def compile_k_parallel_rusage(
    compiler_bin: Path,
    k_dir: Path,
    src_dir: Path,
    obj_dir: Path,
    cpus: list[int],
    mode_args: list[str],
    fid_bases_override: dict[str, int] | None = None,
    timeout_s: int = 300,
    trace: bool = True,
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
            prefix = ["--trace"] if trace else []
            args = [
                *prefix,
                *mode_args,
                str(src),
                str(BASE_FILE),
                "cache",
                str(BASE_CARRIER),
                BASE_STAMP,
                str(fid_bases[m]),
                m,
            ]
            ms, stderr, rss_mib = run_native_rusage(compiler_bin, args, obj, err, cpu=cpu, timeout_s=timeout_s)
            stages = parse_trace_full(stderr) if trace else {}
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
                "mod": m,
                "cpu": cpu,
                "ms": ms,
                "rss_mib": rss_mib,
                "segs": segs,
                "fid_base": fid_bases[m],
                "fid_slot": slot,
                "bytes": obj.stat().st_size,
                "stages": stages,
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


def check_and_repack_if_needed(
    comp_res: dict,
    compiler_bin: Path,
    k_dir: Path,
    src_dir: Path,
    obj_dir: Path,
    cpus: list[int],
    mode_args: list[str],
    timeout_s: int = 300,
    trace: bool = True,
) -> tuple[dict, bool, dict[str, int] | None]:
    mods = comp_res["modules"]
    total_segs = comp_res["total_segs"]
    if total_segs > 65532:
        return comp_res, False, None
    overlaps = []
    for i in range(len(mods) - 1):
        if mods[i]["fid_base"] + mods[i]["segs"] > mods[i + 1]["fid_base"]:
            overlaps.append(mods[i]["mod"])
    if mods[-1]["fid_base"] + mods[-1]["segs"] > 65532:
        overlaps.append(mods[-1]["mod"])
    if not overlaps:
        return comp_res, True, None

    print(f"  [FID REPACK] Overlaps at {overlaps}; repacking exact fid_bases (total={total_segs}/65532)...", flush=True)
    new_bases: dict[str, int] = {}
    cur = 0
    margin = (65532 - total_segs) // len(mods)
    for r in mods:
        new_bases[r["mod"]] = cur
        cur += r["segs"] + margin
    assert cur <= 65532

    to_recompile = [r["mod"] for r in mods if new_bases[r["mod"]] != r["fid_base"]]
    print(f"  [FID REPACK] Recompiling {len(to_recompile)} shifted modules: {to_recompile}", flush=True)
    cpu_q: queue.Queue[int] = queue.Queue()
    for c in cpus:
        cpu_q.put(c)

    def worker(m: str) -> tuple[str, dict]:
        cpu = cpu_q.get()
        try:
            src = src_dir / f"{m}_zero.bend"
            obj = obj_dir / f"{m}.o"
            err = obj_dir / f"{m}.err"
            prefix = ["--trace"] if trace else []
            args = [
                *prefix,
                *mode_args,
                str(src),
                str(BASE_FILE),
                "cache",
                str(BASE_CARRIER),
                BASE_STAMP,
                str(new_bases[m]),
                m,
            ]
            ms, stderr, rss_mib = run_native_rusage(compiler_bin, args, obj, err, cpu=cpu, timeout_s=timeout_s)
            segs = mb.get_seg_count(obj, m)
            stages = parse_trace_full(stderr) if trace else {}
            return m, {
                "ms": ms,
                "rss_mib": rss_mib,
                "segs": segs,
                "fid_base": new_bases[m],
                "bytes": obj.stat().st_size,
                "stages": stages,
            }
        finally:
            cpu_q.put(cpu)

    with concurrent.futures.ThreadPoolExecutor(max_workers=len(cpus)) as ex:
        for m, upd in ex.map(worker, to_recompile):
            for r in mods:
                if r["mod"] == m:
                    r.update(upd)
    return comp_res, True, new_bases


K10_EXACT_FID_BASES = {
    "m00": 0,
    "m01": 7520,
    "m02": 14350,
    "m03": 20726,
    "m04": 27126,
    "m05": 32986,
    "m06": 39704,
    "m07": 46810,
    "m08": 54006,
    "m09": 60355,
}
K10_O2_LPT_ORDER = ["m03", "m04", "m01", "m00", "m02", "m05", "m07", "m06", "m08", "m09"]


BASE_PREFIXES = (
    "Base.", "$direct.Base.",
    "$direct.Bool.", "$direct.Char.", "$direct.IO.", "$direct.List.", "$direct.Maybe.",
    "$direct.Nat.", "$direct.Pair.", "$direct.String.", "$direct.U32.", "$direct.Unit.",
    "$direct.Equal.", "$direct.Empty.", "$direct.F32.", "$direct.F64.", "$direct.I32.",
    "$direct.U64.", "$direct.I64.", "$direct.Ordering.", "$direct.Bits.", "$direct.Map.",
    "$direct.Set.",
    "Bool.", "Char.", "IO.", "List.", "Maybe.", "Nat.", "Pair.", "String.", "U32.", "Unit.",
)


def is_non_base_orphan(sym: str) -> bool:
    if not sym.startswith("p113d_FID_"):
        return False
    tail = sym[len("p113d_FID_"):].split("___")[0]
    parts = [p for p in tail.split("_") if p]
    if not parts or not all(p.isdigit() for p in parts):
        return False
    nm = "".join(chr(int(p)) for p in parts)
    return not nm.startswith(BASE_PREFIXES)


def stage1_mint_n7_o2(state: dict) -> None:
    k_dir = ROOT / "selfhost/build/agy/k10_wave16"
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    prov_bases = {m["name"]: m["fid_base"] for m in manifest["modules"]}
    work = Path("/tmp/agy_w16_mint_n7_o2")
    if work.exists():
        shutil.rmtree(work)
    src_dir = work / "src"
    iface_dir = work / "iface"
    obj_dir = work / "obj"
    log_dir = work / "logs"

    print(f"\n=== STAGE 1: Mint n7_o2 (10/10 -O2 pipelined .p130 via n6_o2 on k10_wave16, 0 stubs, 0 objcopy) ===", flush=True)
    src_paths, exp_counts = w15.prepare_sources(k_dir, mod_names, src_dir, W16_SRC)
    build = w15.pipelined_native_build(
        N6_O2, "x86-module", mod_names, src_paths, prov_bases,
        iface_dir=iface_dir, obj_dir=obj_dir, log_dir=log_dir, tag="n7_o2",
    )
    assert not build.get("fid_overflow"), f"FID overflow in n7_o2 mint: {build['total_segs']}"

    merge_ms, link_ms = mb.merge_and_link(N6_O2, mod_names, obj_dir, obj_dir / "merge.o", N7_O2, cpu=0)
    print(f"  Linked {N7_O2} ({N7_O2.stat().st_size:,} B) | total_segs={build['total_segs']}/65532 | merge={merge_ms} ms link={link_ms} ms", flush=True)

    smoke = mb.smoke_binary(N7_O2, work / "smoke", cpu=0, run_o2=True)

    # Check n7_o2 --trace stage breakdown on k10_wave16/m09 (zero-.p130 with -O0 oracle)
    print("\n=== STAGE 1b: n7_o2 --trace stage breakdown on k10_wave16/m09 (zero-.p130) ===", flush=True)
    o0_set = {x.strip() for x in ORACLE_W16.read_text().splitlines() if x.strip()}
    o0_src_dir = work / "src_o0"
    gen_stubs.generate_all(k_dir, o0_src_dir, abi_mode="oracle", direct_set=o0_set)
    m09_base = prov_bases["m09"]
    m09_obj = work / "trace_m09.o"
    m09_err = work / "trace_m09.err"
    m09_ms, m09_stderr, m09_rss = run_native_rusage(
        N7_O2,
        [
            "--trace",
            "x86-module-fast",
            str(o0_src_dir / "m09_zero.bend"),
            str(BASE_FILE),
            "cache",
            str(BASE_CARRIER),
            BASE_STAMP,
            str(m09_base),
            "m09",
        ],
        m09_obj,
        m09_err,
        cpu=0,
        timeout_s=120,
    )
    m09_stages = parse_trace_full(m09_stderr)
    m09_segs = mb.get_seg_count(m09_obj, "m09")
    print(f"  n7_o2 m09: wall={m09_ms} ms rss={m09_rss} MiB segs={m09_segs} stages={m09_stages}", flush=True)

    shutil.rmtree(work, ignore_errors=True)
    state["stage1_mint_n7_o2"] = {
        "n7_o2_bytes": N7_O2.stat().st_size,
        "iface_wall_ms": build["iface_wall_ms"],
        "compile_wall_ms": build["pipe_compile_ms"],
        "total_segs": build["total_segs"],
        "merge_ms": merge_ms,
        "link_ms": link_ms,
        "smoke": smoke,
        "m09_trace": {
            "wall_ms": m09_ms,
            "rss_mib": m09_rss,
            "segs": m09_segs,
            "stages": m09_stages,
        },
    }
    STATE_JSON.write_text(json.dumps(state, indent=2) + "\n")


def run_one_cold_bench(
    compiler_bin: Path, label: str, k: int, cpus: list[int], expected_hashes: dict[str, str] | None = None
) -> dict:
    k_dir = ROOT / f"selfhost/build/agy/k{k}_wave16"
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    work = Path(f"/tmp/agy_w16_cold/{label}_k{k}")
    if work.exists():
        shutil.rmtree(work)
    work.mkdir(parents=True, exist_ok=True)
    src_dir = work / "src"
    obj_dir = work / "obj"

    direct_set = {x.strip() for x in ORACLE_W16.read_text().splitlines() if x.strip()}
    print(
        f"\n=== OFFICIAL 8-CORE ZERO-CACHE COLD SELF-COMPILE: {label} K={k} (CPUs {cpus}, EMPTY {work}) ===",
        flush=True,
    )
    t_total0 = time.perf_counter()
    stub_meta = gen_stubs.generate_all(k_dir, src_dir, abi_mode="oracle", direct_set=direct_set)
    stub_ms = stub_meta["elapsed_ms"]
    print(f"  [1/3] gen_stubs: {stub_ms:.1f} ms", flush=True)

    fid_ov = K10_EXACT_FID_BASES if k == 10 else None
    comp = compile_k_parallel_rusage(
        compiler_bin, k_dir, src_dir, obj_dir, cpus=cpus, mode_args=["x86-module-fast"],
        fid_bases_override=fid_ov, timeout_s=180, trace=True
    )
    print(
        f"  [2/3] compile_wall: {comp['wall_ms']:.1f} ms (cpu_sum={comp['cpu_sum_ms']:.1f} ms, "
        f"max_rss={comp['max_rss_mib']:.1f} MiB, total_segs={comp['total_segs']}/65532)",
        flush=True,
    )

    if comp["total_segs"] > 65532:
        print(f"  [SKIP] K={k} exceeds 65,532 FIDs ({comp['total_segs']})", flush=True)
        shutil.rmtree(work, ignore_errors=True)
        return {
            "label": label,
            "k": k,
            "fits_fid_budget": False,
            "total_segs": comp["total_segs"],
            "compile_wall_ms": comp["wall_ms"],
            "compile_cpu_sum_ms": comp["cpu_sum_ms"],
            "max_rss_mib": comp["max_rss_mib"],
        }

    comp, fits, repacked_bases = check_and_repack_if_needed(
        comp, compiler_bin, k_dir, src_dir, obj_dir, cpus=cpus, mode_args=["x86-module-fast"], timeout_s=180, trace=True
    )
    assert fits

    # If manifest needed repacking, measure a clean 1-pass cold run using the repacked fid_bases!
    # First finish this build so we can verify link+smoke.
    n8_bin = work / f"n8_{label}_k{k}"
    merge_ms, link_ms = mb.merge_and_link(compiler_bin, mod_names, obj_dir, obj_dir / "merge.o", n8_bin, cpu=cpus[0])
    total_wall_ms = round((time.perf_counter() - t_total0) * 1000.0, 1)
    print(f"  [3/3] merge={merge_ms:.1f} ms | link={link_ms:.1f} ms", flush=True)
    print(
        f"  >>> TOTAL 8-CORE ZERO-CACHE COLD WALL TIME ({label}, K={k}): "
        f"{total_wall_ms:.1f} ms ({total_wall_ms/1000:.2f} s) | cpu_sum={comp['cpu_sum_ms']:.1f} ms | "
        f"max_rss={comp['max_rss_mib']:.1f} MiB | segs={comp['total_segs']}/65532 <<<",
        flush=True,
    )

    orphans = mb.audit_orphan_weaks(obj_dir, mod_names)
    non_base_orphans = [s for s in orphans if is_non_base_orphan(s)]
    print(f"  orphan_weaks={len(orphans)} (non_base={len(non_base_orphans)})", flush=True)
    assert len(non_base_orphans) == 0, f"Non-Base orphan weaks in {label} K={k}: {non_base_orphans[:10]}"

    obj_hashes = {m: sha256_file(obj_dir / f"{m}.o") for m in mod_names}
    hash_match = None
    if expected_hashes is not None:
        mismatches = [m for m in mod_names if obj_hashes.get(m) != expected_hashes.get(m)]
        hash_match = len(mismatches) == 0
        print(
            f"  [BIT-IDENTITY vs n8_cold] match={hash_match} ({len(mod_names)-len(mismatches)}/{len(mod_names)} .o files identical)",
            flush=True,
        )
        assert hash_match, f"SHA-256 mismatch on modules: {mismatches}"

    smoke = mb.smoke_binary(n8_bin, work / "smoke", cpu=cpus[0], run_o2=False)
    n8_bytes = n8_bin.stat().st_size
    shutil.rmtree(work, ignore_errors=True)

    return {
        "label": label,
        "compiler": str(compiler_bin.relative_to(ROOT)),
        "k": k,
        "cpus": cpus,
        "fits_fid_budget": True,
        "repacked": repacked_bases is not None,
        "stub_gen_ms": stub_ms,
        "compile_wall_ms": comp["wall_ms"],
        "compile_cpu_sum_ms": comp["cpu_sum_ms"],
        "compile_min_ms": comp["min_ms"],
        "compile_median_ms": comp["median_ms"],
        "compile_max_ms": comp["max_ms"],
        "max_rss_mib": comp["max_rss_mib"],
        "median_rss_mib": comp["median_rss_mib"],
        "total_segs": comp["total_segs"],
        "merge_ms": merge_ms,
        "link_ms": link_ms,
        "total_cold_wall_ms": total_wall_ms,
        "total_cold_wall_s": round(total_wall_ms / 1000.0, 2),
        "n8_bytes": n8_bytes,
        "orphan_weaks": len(orphans),
        "non_base_orphan_weaks": len(non_base_orphans),
        "sha256_match_vs_n8_cold": hash_match,
        "obj_sha256": obj_hashes,
        "smoke": smoke,
        "modules": comp["modules"],
    }


def stage2_cold_n7_o2(state: dict) -> None:
    cold_root = Path("/tmp/agy_w16_cold")
    if cold_root.exists():
        shutil.rmtree(cold_root)
    res = state.setdefault("stage2_cold_n7_o2", {})
    for k in (10, 16, 24):
        res[f"k{k}"] = run_one_cold_bench(N7_O2, "n7_o2", k, CPUS)
        STATE_JSON.write_text(json.dumps(state, indent=2) + "\n")
    shutil.rmtree(cold_root, ignore_errors=True)


def stage3_mint_nodrop_and_cold(state: dict) -> None:
    k_dir = ROOT / "selfhost/build/agy/k10_wave16"
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    prov_bases = {m["name"]: m["fid_base"] for m in manifest["modules"]}
    work = Path("/tmp/agy_w16_mint_n7_nd")
    if work.exists():
        shutil.rmtree(work)
    src_dir = work / "src"
    iface_dir = work / "iface"
    obj_dir = work / "obj"
    log_dir = work / "logs"

    print(f"\n=== STAGE 3a: Mint n7_o2_nodrop (10/10 -O2 --nodrop pipelined .p130 via n7_o2 on k10_wave16, 0 stubs, 0 objcopy) ===", flush=True)
    src_paths, _ = w15.prepare_sources(k_dir, mod_names, src_dir, W16_SRC)
    build = w15.pipelined_native_build(
        N7_O2, "x86-module-nodrop", mod_names, src_paths, prov_bases,
        iface_dir=iface_dir, obj_dir=obj_dir, log_dir=log_dir, tag="n7_o2_nodrop",
    )
    assert not build.get("fid_overflow"), f"FID overflow in n7_o2_nodrop mint: {build['total_segs']}"

    merge_ms, link_ms = mb.merge_and_link(N7_O2, mod_names, obj_dir, obj_dir / "merge.o", N7_O2_ND, cpu=0)
    print(f"  Linked {N7_O2_ND} ({N7_O2_ND.stat().st_size:,} B) | total_segs={build['total_segs']}/65532 | merge={merge_ms} ms link={link_ms} ms", flush=True)
    smoke = mb.smoke_binary(N7_O2_ND, work / "smoke", cpu=0, run_o2=False)
    shutil.rmtree(work, ignore_errors=True)

    state["stage3_mint_n7_o2_nodrop"] = {
        "n7_o2_nodrop_bytes": N7_O2_ND.stat().st_size,
        "iface_wall_ms": build["iface_wall_ms"],
        "compile_wall_ms": build["pipe_compile_ms"],
        "total_segs": build["total_segs"],
        "merge_ms": merge_ms,
        "link_ms": link_ms,
        "smoke": smoke,
    }
    STATE_JSON.write_text(json.dumps(state, indent=2) + "\n")

    # Stage 3b: Cold benchmarks for n7_o2_nodrop on every K that fit in Stage 2!
    cold_root = Path("/tmp/agy_w16_cold")
    if cold_root.exists():
        shutil.rmtree(cold_root)
    nd_res = state.setdefault("stage3_cold_n7_o2_nodrop", {})
    s2 = state.get("stage2_cold_n7_o2", {})
    for k in (10, 16, 24):
        s2_k = s2.get(f"k{k}", {})
        if s2_k and not s2_k.get("fits_fid_budget", False):
            continue
        expected_hashes = s2_k.get("obj_sha256")
        nd_res[f"k{k}"] = run_one_cold_bench(
            N7_O2_ND, "n7_o2_nodrop", k, CPUS, expected_hashes=expected_hashes
        )
        STATE_JSON.write_text(json.dumps(state, indent=2) + "\n")
    shutil.rmtree(cold_root, ignore_errors=True)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--stages", type=str, default="1,2,3")
    args = ap.parse_args()
    stages = [int(x) for x in args.stages.split(",") if x.strip()]
    state = json.loads(STATE_JSON.read_text()) if STATE_JSON.exists() else {}

    if 1 in stages:
        stage1_mint_n7_o2(state)
    if 2 in stages:
        stage2_cold_n7_o2(state)
    if 3 in stages:
        stage3_mint_nodrop_and_cold(state)


if __name__ == "__main__":
    main()
