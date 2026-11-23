#!/usr/bin/env python3
"""Wave 16 Final Mint (`n7_o2`, `n7_o2_nodrop`) & Official 8-Core Zero-Cache Cold Self-Compile Benchmarker."""
from __future__ import annotations

import argparse
import concurrent.futures
import json
import queue
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path
from statistics import median

ROOT = Path("/home/ai/bend2_agy")
W16_SRC = ROOT / "selfhost/build/agy/wave16_unified/compiler.bend"
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

ORACLE_K10 = ROOT / "research/agy/s10_campaign/s10a_zero_p130/p113d_oracle_k10.txt"
ORACLE_W16 = ROOT / "research/agy/s10_campaign/w16_final/p113d_oracle_w16.txt"
OUT_DIR = ROOT / "research/agy/s10_campaign/w16_final"

sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/s10a_zero_p130"))
import gen_stubs


def parse_trace_stages(stderr: str) -> dict[str, float]:
    stages: dict[str, float] = {}
    for line in stderr.splitlines():
        m = re.search(r"stage=([A-Za-z0-9_.-]+)\s+ms=([0-9.]+)", line)
        if m:
            stages[m.group(1)] = float(m.group(2))
        m_seg = re.search(r"segs=(\d+)", line)
        if m_seg:
            stages["segs"] = int(m_seg.group(1))
        m2 = re.search(r"stage=(x187_priv_done|x187_pub_done)\s+count=(\d+)\s+elapsed=([0-9.]+)ms", line)
        if m2:
            stages[m2.group(1) + "_count"] = int(m2.group(2))
            stages[m2.group(1) + "_elapsed"] = float(m2.group(3))
        m3 = re.search(r"total_ms=([0-9.]+)ms", line)
        if m3:
            stages["total_ms"] = float(m3.group(1))
    return stages


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


def run_native(
    binary: Path, args: list[str], out_file: Path, err_file: Path, cpu: int, timeout_s: int = 300
) -> tuple[float, str]:
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
        r = subprocess.run(cmd, stdout=of, stderr=ef, cwd=ROOT)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = err_file.read_text(encoding="utf-8", errors="replace").strip()
    if r.returncode != 0:
        raise RuntimeError(f"{binary.name} failed (rc={r.returncode}, cpu={cpu}): {stderr[-1200:]}")
    return ms, stderr


def encode_sym_name(name: str) -> str:
    return "_".join(str(ord(c)) for c in name) + "_"


def decode_sym_name(enc: str) -> str:
    parts = [p for p in enc.split("_") if p]
    return "".join(chr(int(p)) for p in parts)


def extract_global_direct_oracle(obj_dir: Path, mod_names: list[str]) -> set[str]:
    """Extract all Bend def names emitted as GLOBAL p113d_FID_$direct.<name>."""
    direct: set[str] = set()
    pref_enc = encode_sym_name("$direct.")
    full_pref = "p113d_FID_" + pref_enc
    for m in mod_names:
        out = subprocess.check_output(["readelf", "-sW", str(obj_dir / f"{m}.o")], text=True)
        for line in out.splitlines():
            parts = line.split()
            if len(parts) >= 8 and parts[4] == "GLOBAL" and parts[6] != "UND" and parts[7].startswith(full_pref):
                nm = decode_sym_name(parts[7][len(full_pref) :])
                direct.add(nm)
    return direct


def audit_orphan_weaks(obj_dir: Path, mod_names: list[str]) -> list[str]:
    """Verify every WEAK p113d_FID_* symbol has a GLOBAL definition in some module."""
    globals_def: set[str] = set()
    weaks_def: set[str] = set()
    for m in mod_names:
        out = subprocess.check_output(["readelf", "-sW", str(obj_dir / f"{m}.o")], text=True)
        for line in out.splitlines():
            parts = line.split()
            if len(parts) >= 8 and parts[6] != "UND" and parts[7].startswith("p113d_FID_"):
                if parts[4] == "GLOBAL":
                    globals_def.add(parts[7])
                elif parts[4] == "WEAK":
                    weaks_def.add(parts[7])
    return sorted(weaks_def - globals_def)


def weaken_stub_syms_for_bootstrap(obj_dir: Path, stub_meta: dict, mod_names: list[str]) -> float:
    """One-time bootstrap helper for n6_o2 only (predates S10-A)."""
    t0 = time.perf_counter()
    for m in mod_names:
        if m == mod_names[0]:
            continue
        src_p = Path(stub_meta["modules"][m]["path"])
        txt = src_p.read_text(encoding="utf-8")
        i0 = txt.find("# === S10-A ZERO-P130 IMPORTS")
        i1 = txt.find("# === MODULE BODY:")
        stub_sec = txt[i0:i1]
        names = re.findall(r"^def\s+([A-Za-z0-9_.\$]+)\s*\(", stub_sec, re.M)
        syms: list[str] = []
        for nm in names:
            for pref in ("", "$direct.", "$p118borrow.read.", "$p128borrow.owned.", "$product."):
                enc = encode_sym_name(pref + nm)
                syms.append(f"p111_FID_{enc}")
                syms.append(f"p113d_FID_{enc}")
                syms.append(f"p114r_FID_{enc}")
        sym_file = obj_dir / f"{m}_weak.txt"
        sym_file.write_text("\n".join(syms) + "\n", encoding="utf-8")
        obj = obj_dir / f"{m}.o"
        subprocess.run(
            ["timeout", "30", "taskset", "-c", "0", "objcopy", f"--weaken-symbols={sym_file}", str(obj)],
            check=True,
        )
    return round((time.perf_counter() - t0) * 1000.0, 1)


def compile_k_parallel(
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

    # LPT order: largest zero-p130 source file first!
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
            ms, stderr = run_native(compiler_bin, args, obj, err, cpu=cpu, timeout_s=timeout_s)
            stages = parse_trace_stages(stderr) if trace else {}
            segs = get_seg_count(obj, m)
            slot = fid_slots[m]
            ov = " OVERFLOW!" if segs > slot else ""
            print(
                f"  [{m}] cpu={cpu} ms={ms:7.1f} segs={segs:5d}/{slot:5d}{ov} "
                f"(prep={stages.get('prep',0):.0f} plan={stages.get('p86_plan',0):.0f} "
                f"pw={stages.get('x198pw_plan',0):.0f} elf={stages.get('x187_elf',0):.0f})",
                flush=True,
            )
            return {
                "mod": m,
                "cpu": cpu,
                "ms": ms,
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
    total_segs = sum(r["segs"] for r in records)
    return {
        "wall_ms": wall_ms,
        "cpu_sum_ms": round(sum(times), 1),
        "min_ms": min(times),
        "median_ms": round(median(times), 1),
        "max_ms": max(times),
        "total_segs": total_segs,
        "modules": records,
    }


def check_and_fix_fid_overlaps(
    comp_res: dict,
    compiler_bin: Path,
    k_dir: Path,
    src_dir: Path,
    obj_dir: Path,
    cpus: list[int],
    mode_args: list[str],
    timeout_s: int = 300,
    trace: bool = True,
) -> dict:
    """If any module's segs > fid_slot (overlap with next fid_base), repack non-overlapping fid_bases and recompile only shifted modules."""
    mods = comp_res["modules"]
    total_segs = comp_res["total_segs"]
    assert total_segs <= 65532, f"Total segs {total_segs} exceeds 65532!"
    overlaps = []
    for i in range(len(mods) - 1):
        if mods[i]["fid_base"] + mods[i]["segs"] > mods[i + 1]["fid_base"]:
            overlaps.append(mods[i]["mod"])
    if mods[-1]["fid_base"] + mods[-1]["segs"] > 65532:
        overlaps.append(mods[-1]["mod"])
    if not overlaps:
        return comp_res

    print(f"  [FID REPACK] Detected overlaps at {overlaps}; repacking exact fid_bases (total={total_segs}/65532)...", flush=True)
    new_bases: dict[str, int] = {}
    cur = 0
    margin = (65532 - total_segs) // len(mods)
    for r in mods:
        new_bases[r["mod"]] = cur
        cur += r["segs"] + margin
    assert cur <= 65532

    to_recompile = [r["mod"] for r in mods if new_bases[r["mod"]] != r["fid_base"]]
    print(f"  [FID REPACK] Recompiling {len(to_recompile)} modules: {to_recompile}", flush=True)
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
            ms, stderr = run_native(compiler_bin, args, obj, err, cpu=cpu, timeout_s=timeout_s)
            segs = get_seg_count(obj, m)
            return m, {"ms": ms, "segs": segs, "fid_base": new_bases[m], "bytes": obj.stat().st_size}
        finally:
            cpu_q.put(cpu)

    with concurrent.futures.ThreadPoolExecutor(max_workers=len(cpus)) as ex:
        for m, upd in ex.map(worker, to_recompile):
            for r in mods:
                if r["mod"] == m:
                    r.update(upd)
    return comp_res


def merge_and_link(
    compiler_bin: Path, mod_names: list[str], obj_dir: Path, merge_o: Path, out_bin: Path, cpu: int = 0
) -> tuple[float, float]:
    entry_mod = mod_names[-1]
    ordered = [entry_mod] + mod_names[:-1]
    mod_objs = [obj_dir / f"{m}.o" for m in ordered]
    err_file = obj_dir / "merge.err"
    merge_ms, _ = run_native(
        compiler_bin, ["x86-merge-obj", entry_mod] + ordered, merge_o, err_file, cpu=cpu, timeout_s=60
    )
    out_bin.parent.mkdir(parents=True, exist_ok=True)
    t0 = time.perf_counter()
    r = subprocess.run(
        [
            "timeout",
            "60",
            "taskset",
            "-c",
            str(cpu),
            CC,
            "-O2",
            "-no-pie",
            str(merge_o),
            *[str(o) for o in mod_objs],
            str(RT),
            "-o",
            str(out_bin),
            "-lm",
            "-lpthread",
        ],
        capture_output=True,
        text=True,
        cwd=ROOT,
    )
    link_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    if r.returncode != 0:
        raise RuntimeError(f"gcc-10 link failed (rc={r.returncode}): {r.stderr[-1500:]}")
    if r.stderr.strip():
        print(f"  [WARN] link stderr: {r.stderr.strip()[:400]}", flush=True)
    return merge_ms, link_ms


def smoke_binary(compiler_bin: Path, out_dir: Path, cpu: int = 0, run_o2: bool = True) -> dict:
    out_dir.mkdir(parents=True, exist_ok=True)
    res: dict = {}
    for label, mode in ([("o0", "x86-object-fast"), ("o2", "x86-object")] if run_o2 else [("o0", "x86-object-fast")]):
        obj = out_dir / f"slice_{label}.o"
        exe = out_dir / f"slice_{label}"
        ms, _ = run_native(
            compiler_bin,
            [mode, str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
            obj,
            out_dir / f"slice_{label}.err",
            cpu=cpu,
            timeout_s=120,
        )
        subprocess.run(
            ["timeout", "30", "taskset", "-c", str(cpu), CC, "-O2", "-no-pie", str(obj), str(RT), "-o", str(exe), "-lm", "-lpthread"],
            check=True,
        )
        out = subprocess.check_output(["timeout", "30", "taskset", "-c", str(cpu), str(exe), *RTS_ARGS], text=True).strip()
        assert out == "34", f"slice {label} expected 34, got {out!r}"
        res[f"slice_{label}_ms"] = ms
        res[f"slice_{label}_out"] = out
        res[f"slice_{label}_bytes"] = obj.stat().st_size
        print(f"  [SMOKE PASS] {compiler_bin.name} {mode} compiler_slice.bend -> out={out} ({ms:.1f} ms, {obj.stat().st_size:,} B)", flush=True)
    return res


def cmd_split() -> None:
    splitter = ROOT / "research/agy/s10_campaign/s10g_nodrop_and_k24/split_kN_balanced.py"
    for k in (16, 24):
        out_dir = ROOT / f"selfhost/build/agy/k{k}_wave16"
        subprocess.run(
            [sys.executable, str(splitter), "--k", str(k), "--src", str(W16_SRC), "--out-dir", str(out_dir)],
            check=True,
        )


def cmd_mint_n7(cpus: list[int]) -> dict:
    k_dir = ROOT / "selfhost/build/agy/k16_wave16"
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    work = Path("/tmp/agy_w16_mint_n7")
    if work.exists():
        shutil.rmtree(work)
    src_dir = work / "src"
    obj_dir = work / "obj"

    direct_set = {x.strip() for x in ORACLE_K10.read_text().splitlines() if x.strip()}
    print(f"\n=== Minting n7_o2 (-O2) via n6_o2 on K=16 (CPUs {cpus}, oracle={len(direct_set)}) ===", flush=True)
    stub_meta = gen_stubs.generate_all(k_dir, src_dir, abi_mode="oracle", direct_set=direct_set)
    print(f"  gen_stubs: {stub_meta['elapsed_ms']} ms", flush=True)

    comp = compile_k_parallel(N6_O2, k_dir, src_dir, obj_dir, cpus=cpus, mode_args=["x86-module"], timeout_s=600)
    comp = check_and_fix_fid_overlaps(comp, N6_O2, k_dir, src_dir, obj_dir, cpus=cpus, mode_args=["x86-module"], timeout_s=600)
    weak_ms = weaken_stub_syms_for_bootstrap(obj_dir, stub_meta, mod_names)
    orphans = audit_orphan_weaks(obj_dir, mod_names)
    print(f"  bootstrap weaken={weak_ms} ms | total_segs={comp['total_segs']}/65532 | orphan_weaks={len(orphans)}", flush=True)
    assert len(orphans) == 0, f"Found {len(orphans)} orphan weak symbols: {orphans[:10]}"

    # Extract exact Wave 16 G(G(D0)) oracle!
    w16_oracle = extract_global_direct_oracle(obj_dir, mod_names)
    ORACLE_W16.write_text("\n".join(sorted(w16_oracle)) + "\n", encoding="utf-8")
    print(f"  Extracted Wave 16 exact G(G(D0)) oracle: {len(w16_oracle)} direct defs -> {ORACLE_W16}", flush=True)

    merge_ms, link_ms = merge_and_link(N6_O2, mod_names, obj_dir, obj_dir / "merge.o", N7_O2, cpu=cpus[0])
    print(f"  Linked {N7_O2} ({N7_O2.stat().st_size:,} B) | merge={merge_ms} ms link={link_ms} ms", flush=True)

    smoke = smoke_binary(N7_O2, work / "smoke", cpu=cpus[0], run_o2=True)
    shutil.rmtree(work, ignore_errors=True)
    return {
        "n7_o2_bytes": N7_O2.stat().st_size,
        "stub_gen_ms": stub_meta["elapsed_ms"],
        "compile": comp,
        "merge_ms": merge_ms,
        "link_ms": link_ms,
        "oracle_w16_count": len(w16_oracle),
        "smoke": smoke,
    }


def cmd_mint_n7_nodrop(cpus: list[int]) -> dict:
    k_dir = ROOT / "selfhost/build/agy/k16_wave16"
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    work = Path("/tmp/agy_w16_mint_n7_nd")
    if work.exists():
        shutil.rmtree(work)
    src_dir = work / "src"
    obj_dir = work / "obj"

    direct_set = {x.strip() for x in ORACLE_W16.read_text().splitlines() if x.strip()}
    print(f"\n=== Minting n7_o2_nodrop (-O2 --nodrop) via n7_o2 (100% pure-Bend, 0 objcopy, CPUs {cpus}) ===", flush=True)
    stub_meta = gen_stubs.generate_all(k_dir, src_dir, abi_mode="oracle", direct_set=direct_set)
    comp = compile_k_parallel(N7_O2, k_dir, src_dir, obj_dir, cpus=cpus, mode_args=["x86-module-nodrop"], timeout_s=600, trace=False)
    comp = check_and_fix_fid_overlaps(comp, N7_O2, k_dir, src_dir, obj_dir, cpus=cpus, mode_args=["x86-module-nodrop"], timeout_s=600, trace=False)
    orphans = audit_orphan_weaks(obj_dir, mod_names)
    print(f"  total_segs={comp['total_segs']}/65532 | orphan_weaks={len(orphans)}", flush=True)
    assert len(orphans) == 0, f"Found {len(orphans)} orphan weak symbols: {orphans[:10]}"

    merge_ms, link_ms = merge_and_link(N7_O2, mod_names, obj_dir, obj_dir / "merge.o", N7_O2_ND, cpu=cpus[0])
    print(f"  Linked {N7_O2_ND} ({N7_O2_ND.stat().st_size:,} B) | merge={merge_ms} ms link={link_ms} ms", flush=True)
    smoke = smoke_binary(N7_O2_ND, work / "smoke", cpu=cpus[0], run_o2=False)
    shutil.rmtree(work, ignore_errors=True)
    return {
        "n7_o2_nodrop_bytes": N7_O2_ND.stat().st_size,
        "stub_gen_ms": stub_meta["elapsed_ms"],
        "compile": comp,
        "merge_ms": merge_ms,
        "link_ms": link_ms,
        "smoke": smoke,
    }


def run_cold_bench(compiler_bin: Path, label: str, k: int, cpus: list[int]) -> dict:
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
    print(f"\n=== OFFICIAL 8-CORE ZERO-CACHE COLD SELF-COMPILE: {label} K={k} (CPUs {cpus}, EMPTY {work}) ===", flush=True)
    t_total0 = time.perf_counter()
    stub_meta = gen_stubs.generate_all(k_dir, src_dir, abi_mode="oracle", direct_set=direct_set)
    stub_ms = stub_meta["elapsed_ms"]
    print(f"  [1/3] gen_stubs: {stub_ms:.1f} ms", flush=True)

    comp = compile_k_parallel(
        compiler_bin, k_dir, src_dir, obj_dir, cpus=cpus, mode_args=["x86-module-fast"], timeout_s=180, trace=True
    )
    print(f"  [2/3] compile_wall: {comp['wall_ms']:.1f} ms (cpu_sum={comp['cpu_sum_ms']:.1f} ms, total_segs={comp['total_segs']}/65532)", flush=True)

    n8_bin = work / f"n8_{label}_k{k}"
    merge_ms, link_ms = merge_and_link(compiler_bin, mod_names, obj_dir, obj_dir / "merge.o", n8_bin, cpu=cpus[0])
    total_wall_ms = round((time.perf_counter() - t_total0) * 1000.0, 1)
    print(f"  [3/3] merge={merge_ms:.1f} ms | link={link_ms:.1f} ms", flush=True)
    print(
        f"  >>> TOTAL 8-CORE ZERO-CACHE COLD WALL TIME ({label}, K={k}): {total_wall_ms:.1f} ms ({total_wall_ms/1000:.2f} s) <<<",
        flush=True,
    )

    orphans = audit_orphan_weaks(obj_dir, mod_names)
    assert len(orphans) == 0, f"Orphan weaks in cold build: {orphans[:10]}"
    smoke = smoke_binary(n8_bin, work / "smoke", cpu=cpus[0], run_o2=False)
    n8_bytes = n8_bin.stat().st_size
    shutil.rmtree(work, ignore_errors=True)
    return {
        "label": label,
        "compiler": str(compiler_bin.relative_to(ROOT)),
        "k": k,
        "cpus": cpus,
        "stub_gen_ms": stub_ms,
        "compile_wall_ms": comp["wall_ms"],
        "compile_cpu_sum_ms": comp["cpu_sum_ms"],
        "compile_min_ms": comp["min_ms"],
        "compile_median_ms": comp["median_ms"],
        "compile_max_ms": comp["max_ms"],
        "total_segs": comp["total_segs"],
        "merge_ms": merge_ms,
        "link_ms": link_ms,
        "total_cold_wall_ms": total_wall_ms,
        "total_cold_wall_s": round(total_wall_ms / 1000.0, 2),
        "n8_bytes": n8_bytes,
        "orphan_weaks": len(orphans),
        "smoke": smoke,
        "modules": comp["modules"],
    }


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("action", choices=["split", "mint-n7", "mint-n7-nodrop", "bench-cold", "all"])
    ap.add_argument("--cpus", type=str, default="0,1,2,3,4,5,6,7")
    args = ap.parse_args()
    cpus = [int(x) for x in args.cpus.split(",") if x.strip()]

    results_path = OUT_DIR / "bench_cold_results.json"
    res = json.loads(results_path.read_text()) if results_path.exists() else {}

    if args.action in ("split", "all"):
        cmd_split()
    if args.action in ("mint-n7", "all"):
        res["mint_n7"] = cmd_mint_n7(cpus)
        results_path.write_text(json.dumps(res, indent=2) + "\n")
    if args.action in ("mint-n7-nodrop", "all"):
        res["mint_n7_nodrop"] = cmd_mint_n7_nodrop(cpus)
        results_path.write_text(json.dumps(res, indent=2) + "\n")
    if args.action in ("bench-cold", "all"):
        res["cold_benchmarks"] = {}
        for k in (16, 24):
            res["cold_benchmarks"][f"n7_o2_k{k}"] = run_cold_bench(N7_O2, "n7_o2", k, cpus)
            results_path.write_text(json.dumps(res, indent=2) + "\n")
        if N7_O2_ND.exists():
            for k in (16, 24):
                res["cold_benchmarks"][f"n7_o2_nodrop_k{k}"] = run_cold_bench(N7_O2_ND, "n7_o2_nodrop", k, cpus)
                results_path.write_text(json.dumps(res, indent=2) + "\n")


if __name__ == "__main__":
    main()
