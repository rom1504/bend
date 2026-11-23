#!/usr/bin/env python3
"""S10-A End-to-End Zero-.p130 Verification & Benchmark Runner.

Stage 1: Bootstrap `n7_s10a` from `n6_o2` using zero-`.p130` stubbed sources
         (against `base.p130` ONLY, ZERO `x86-iface`!). Uses `objcopy -W` ONLY
         for this 1-time bootstrap since `n6_o2` predates `apply_s10a.py`.
Stage 2: Self-compile `n7_s10a -> n8_s10a` with 100% pure-Bend zero-`.p130`
         (ZERO `x86-iface`, ZERO `.p130` chain, ZERO `objcopy`, ZERO
         `--allow-multiple-definition`, ZERO link warnings!).
Stage 3: Verify `n8_s10a` on `compiler_slice.bend` (-O0 & -O2, `out=34`) and
         `histogram.bend` (-O2 checksum `3307081914` + runtime parity).
Stage 4: Optional 7-core parallel benchmark (`--parallel7`) measuring true-cold
         wall time from t = 0.00 s vs `177.22 s` baseline!
"""
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
K10_DIR = ROOT / "selfhost/build/agy/k10_wave15"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
N6_O2 = ROOT / "selfhost/build/agy/wave15-native-mod/n6_o2"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
HIST = ROOT / "research/agy/wave4_bench/inputs/upstream/histogram.bend"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

S10A_DIR = ROOT / "research/agy/s10_campaign/s10a_zero_p130"
sys.path.insert(0, str(S10A_DIR))
import apply_s10a
import gen_stubs

WORK = Path("/tmp/agy_s10a")
MOD_NAMES = [f"m{i:02d}" for i in range(10)]
FID_BASES_DEFAULT = {
    "m00": 0,
    "m01": 6690,
    "m02": 12650,
    "m03": 18640,
    "m04": 24140,
    "m05": 28600,
    "m06": 34150,
    "m07": 39600,
    "m08": 51100,
    "m09": 60600,
}


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


def run_native(binary: Path, args: list[str], out_file: Path, err_file: Path, cpu: int, timeout_s: int = 180) -> tuple[float, str]:
    out_file.parent.mkdir(parents=True, exist_ok=True)
    err_file.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "timeout", str(timeout_s),
        "bash", "-c", 'ulimit -s 262144 && exec taskset -c "$1" "$2" "${@:3}"',
        "_", str(cpu), str(binary), *args,
    ]
    t0 = time.perf_counter()
    with out_file.open("wb") as of, err_file.open("wb") as ef:
        r = subprocess.run(cmd, stdout=of, stderr=ef, cwd=ROOT)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = err_file.read_text(encoding="utf-8", errors="replace").strip()
    if r.returncode != 0:
        raise RuntimeError(f"{binary.name} failed (rc={r.returncode}, cpu={cpu}): {stderr[-1200:]}")
    return ms, stderr


def compile_all_zero_p130(
    compiler_bin: Path,
    src_dir: Path,
    obj_dir: Path,
    cpus: list[int],
    fid_bases: dict[str, int],
    mode: str = "x86-module-fast",
) -> dict:
    obj_dir.mkdir(parents=True, exist_ok=True)
    cpu_q: queue.Queue[int] = queue.Queue()
    for c in cpus:
        cpu_q.put(c)

    # LPT order: heaviest modules first (m07, m08, m03, m04, m00, m01, m02, m05, m06, m09)
    order = ["m07", "m08", "m03", "m04", "m00", "m01", "m02", "m05", "m06", "m09"]

    def worker(m: str) -> dict:
        cpu = cpu_q.get()
        try:
            src = src_dir / f"{m}_zero.bend"
            obj = obj_dir / f"{m}.o"
            err = obj_dir / f"{m}.err"
            args = [
                "--trace", mode,
                str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP,
                str(fid_bases[m]), m,
            ]
            ms, stderr = run_native(compiler_bin, args, obj, err, cpu=cpu, timeout_s=180)
            stages = parse_trace_stages(stderr)
            segs = get_seg_count(obj, m)
            print(
                f"  [{m}] cpu={cpu} ms={ms:.1f} segs={segs} "
                f"(prep={stages.get('prep',0):.0f} plan={stages.get('p86_plan',0):.0f} "
                f"pw={stages.get('x198pw_plan',0):.0f} elf={stages.get('x187_elf',0):.0f})",
                flush=True,
            )
            return {"mod": m, "cpu": cpu, "ms": ms, "segs": segs, "bytes": obj.stat().st_size, "stages": stages}
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
    cpu_sum_ms = round(sum(r["ms"] for r in records), 1)
    total_segs = sum(r["segs"] for r in records)
    return {
        "wall_ms": wall_ms,
        "cpu_sum_ms": cpu_sum_ms,
        "total_segs": total_segs,
        "modules": records,
    }


def encode_sym_name(name: str) -> str:
    return "_".join(str(ord(c)) for c in name) + "_"


def weaken_stub_syms_for_bootstrap(obj_dir: Path, stub_meta: dict) -> float:
    """One-time bootstrap helper for unmodified n6_o2 only (not used by n7_s10a!)."""
    t0 = time.perf_counter()
    # Build per-module weak symbol list from stubs in each module's zero file
    for m in MOD_NAMES:
        if m == "m00":
            continue
        src_p = Path(stub_meta["modules"][m]["path"])
        txt = src_p.read_text(encoding="utf-8")
        # Extract stub def names between S10-A header and MODULE BODY
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


def merge_and_link(compiler_bin: Path, obj_dir: Path, merge_o: Path, out_bin: Path, cpu: int = 0) -> tuple[float, float]:
    entry_mod = MOD_NAMES[-1]
    ordered = [entry_mod] + MOD_NAMES[:-1]
    mod_objs = [obj_dir / f"{m}.o" for m in ordered]
    err_file = obj_dir / "merge.err"
    merge_ms, _ = run_native(compiler_bin, ["x86-merge-obj", entry_mod] + ordered, merge_o, err_file, cpu=cpu, timeout_s=60)
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
        print(f"  [WARN] link stderr: {r.stderr.strip()[:400]}", flush=True)
    return merge_ms, link_ms


def smoke_binary(compiler_bin: Path, out_dir: Path, cpu: int = 0) -> dict:
    out_dir.mkdir(parents=True, exist_ok=True)
    res: dict = {}

    # 1. compiler_slice.bend (-O0)
    o0_obj = out_dir / "slice_o0.o"
    o0_bin = out_dir / "slice_o0"
    ms_o0, _ = run_native(
        compiler_bin,
        ["x86-object-fast", str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
        o0_obj, out_dir / "slice_o0.err", cpu=cpu,
    )
    subprocess.run(["timeout", "30", "taskset", "-c", str(cpu), CC, "-O2", "-no-pie", str(o0_obj), str(RT), "-o", str(o0_bin), "-lm", "-lpthread"], check=True)
    out = subprocess.check_output(["timeout", "30", "taskset", "-c", str(cpu), str(o0_bin), *RTS_ARGS], text=True).strip()
    assert out == "34", f"slice -O0 expected 34, got {out!r}"
    res["slice_o0"] = {"compile_ms": ms_o0, "out": out}
    print(f"  [smoke] slice -O0: compile={ms_o0}ms out={out}", flush=True)

    # 2. histogram.bend (-O2) + 3-run median
    h_obj = out_dir / "hist_o2.o"
    h_bin = out_dir / "hist_o2"
    ms_h, _ = run_native(
        compiler_bin,
        ["x86-object", str(HIST), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
        h_obj, out_dir / "hist_o2.err", cpu=cpu,
    )
    subprocess.run(["timeout", "30", "taskset", "-c", str(cpu), CC, "-O2", "-no-pie", str(h_obj), str(RT), "-o", str(h_bin), "-lm", "-lpthread"], check=True)
    run_times: list[float] = []
    h_out = ""
    for _ in range(3):
        t0 = time.perf_counter()
        h_out = subprocess.check_output(["timeout", "30", "taskset", "-c", str(cpu), str(h_bin), *RTS_ARGS], text=True).strip()
        run_times.append(round((time.perf_counter() - t0) * 1000.0, 2))
    assert h_out == "3307081914", f"histogram -O2 expected 3307081914, got {h_out!r}"
    res["histogram_o2"] = {"compile_ms": ms_h, "run_median_ms": median(run_times), "runs_ms": run_times, "out": h_out}
    print(f"  [smoke] histogram -O2: compile={ms_h}ms run_median={median(run_times)}ms out={h_out}", flush=True)
    return res


def check_weak_visibility(obj_path: Path, sample_stub: str = "agy_str_eq") -> dict:
    enc = encode_sym_name(sample_stub)
    sym = f"p111_FID_{enc}"
    out = subprocess.check_output(["readelf", "-sW", str(obj_path)], text=True)
    found = None
    weak_count = 0
    global_count = 0
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 8:
            bind = parts[4]
            ndx = parts[6]
            name = parts[7]
            if ndx != "UND" and name.startswith("p111_FID_"):
                if bind == "WEAK":
                    weak_count += 1
                elif bind == "GLOBAL":
                    global_count += 1
            if name == sym:
                found = {"symbol": sym, "bind": bind, "ndx": ndx}
    return {"sample_stub": found, "p111_weak_defined": weak_count, "p111_global_defined": global_count}


def prepare_patched_k10(tmp_k10: Path) -> None:
    tmp_k10.mkdir(parents=True, exist_ok=True)
    for item in K10_DIR.iterdir():
        if item.is_file():
            dst = tmp_k10 / item.name
            if item.name == "m09.bend":
                dst.write_text(apply_s10a.patch_text(item.read_text(encoding="utf-8")), encoding="utf-8")
            else:
                shutil.copy2(item, dst)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--cpus", type=str, default="0,1", help="CPUs for dev/self-compile (default: 0,1)")
    ap.add_argument("--parallel7", action="store_true", help="Also run brief 7-core parallel benchmark on CPUs 0..6")
    ap.add_argument("--abi", choices=["auto", "cps", "cps-shared", "direct", "oracle"], default="auto")
    ap.add_argument("--oracle", type=Path, default=None, help="Path to direct_set symbol names file (for --abi oracle)")
    args = ap.parse_args()

    cpus = [int(x) for x in args.cpus.split(",")]
    direct_set = set(args.oracle.read_text(encoding="utf-8").splitlines()) if args.oracle else None
    results: dict = {"abi": args.abi, "dev_cpus": cpus}

    # Prepare patched K=10 copy (only m09.bend gets apply_s10a.py)
    patched_k10 = WORK / "k10_s10a"
    prepare_patched_k10(patched_k10)

    # Generate zero-.p130 stubbed sources
    src_dir = WORK / f"src_{args.abi}"
    print(f"=== Generating zero-.p130 stubbed sources (abi={args.abi}) ===", flush=True)
    stub_meta = gen_stubs.generate_all(patched_k10, src_dir, abi_mode=args.abi, direct_set=direct_set)
    results["stub_gen"] = stub_meta
    print(f"Stub gen: {stub_meta['elapsed_ms']} ms", flush=True)

    # Stage 1: Bootstrap n7_s10a from n6_o2 (ZERO .p130!)
    print(f"\n=== Stage 1: Bootstrap n6_o2 -> n7_s10a (ZERO .p130, CPUs={cpus}) ===", flush=True)
    obj1 = WORK / "obj_n7"
    fid_bases = dict(FID_BASES_DEFAULT)
    try:
        s1 = compile_all_zero_p130(N6_O2, src_dir, obj1, cpus=cpus, fid_bases=fid_bases)
    except RuntimeError as e:
        if "exceeds 16-bit FID capacity" in str(e):
            print("  [INFO] Recomputing exact fid_bases from seg counts...", flush=True)
            raise
        raise

    # Check if any module's fid_base + segs overlaps next module's fid_base
    print(f"Stage 1 compile: wall={s1['wall_ms']}ms cpu_sum={s1['cpu_sum_ms']}ms total_segs={s1['total_segs']}/65532", flush=True)
    # Recompute exact tight fid_bases if needed for Stage 2
    cur_fb = 0
    tight_fb: dict[str, int] = {}
    overlaps = False
    for r in s1["modules"]:
        m = r["mod"]
        tight_fb[m] = cur_fb
        if m != "m09":
            next_m = f"m{int(m[1:])+1:02d}"
            if fid_bases[m] + r["segs"] > fid_bases[next_m]:
                overlaps = True
                print(f"  [WARN] FID overlap: {m} ({fid_bases[m]}+{r['segs']}={fid_bases[m]+r['segs']} > {fid_bases[next_m]})", flush=True)
        cur_fb += r["segs"] + 5
    print(f"Tight FID total needed: {cur_fb}/65532 (overlaps={overlaps})", flush=True)
    if overlaps:
        assert cur_fb <= 65532, f"Total FIDs {cur_fb} exceeds 65532!"
        print(f"  Recompiling Stage 1 with tight fid_bases: {tight_fb}", flush=True)
        fid_bases = tight_fb
        s1 = compile_all_zero_p130(N6_O2, src_dir, obj1, cpus=cpus, fid_bases=fid_bases)

    weak_ms = weaken_stub_syms_for_bootstrap(obj1, stub_meta)
    n7_bin = WORK / "n7_s10a"
    merge_ms1, link_ms1 = merge_and_link(N6_O2, obj1, obj1 / "merge.o", n7_bin, cpu=cpus[0])
    print(f"Stage 1 linked n7_s10a ({n7_bin.stat().st_size} B): weaken={weak_ms}ms merge={merge_ms1}ms link={link_ms1}ms", flush=True)
    results["stage1_bootstrap"] = {**s1, "fid_bases": fid_bases, "weaken_ms": weak_ms, "merge_ms": merge_ms1, "link_ms": link_ms1, "bin_bytes": n7_bin.stat().st_size}

    # Stage 2: 100% Pure-Bend Zero-.p130 Self-Compile (n7_s10a -> n8_s10a), ZERO objcopy!
    print(f"\n=== Stage 2: Pure-Bend Zero-.p130 n7_s10a -> n8_s10a (ZERO objcopy, ZERO .p130, CPUs={cpus}) ===", flush=True)
    obj2 = WORK / "obj_n8"
    s2 = compile_all_zero_p130(n7_bin, src_dir, obj2, cpus=cpus, fid_bases=fid_bases)
    vis = check_weak_visibility(obj2 / "m09.o", "agy_str_eq")
    print(f"m09.o ELF visibility check: {vis}", flush=True)
    assert vis["sample_stub"] and vis["sample_stub"]["bind"] == "WEAK", f"Expected WEAK stub in m09.o, got {vis}"
    n8_bin = WORK / "n8_s10a"
    merge_ms2, link_ms2 = merge_and_link(n7_bin, obj2, obj2 / "merge.o", n8_bin, cpu=cpus[0])
    e2e_2c_ms = round(stub_meta["elapsed_ms"] + s2["wall_ms"] + merge_ms2 + link_ms2, 1)
    print(f"Stage 2 linked n8_s10a ({n8_bin.stat().st_size} B): wall={s2['wall_ms']}ms merge={merge_ms2}ms link={link_ms2}ms e2e_2c={e2e_2c_ms}ms", flush=True)
    results["stage2_pure_bend"] = {**s2, "vis_m09": vis, "merge_ms": merge_ms2, "link_ms": link_ms2, "e2e_ms": e2e_2c_ms, "bin_bytes": n8_bin.stat().st_size}

    # Stage 3: Smoke & -O2 Runtime Parity on n8_s10a
    print(f"\n=== Stage 3: Verify n8_s10a (compiler_slice -O0 + histogram -O2 parity) ===", flush=True)
    smoke = smoke_binary(n8_bin, WORK / "smoke_n8", cpu=cpus[0])
    results["stage3_smoke"] = smoke

    # Stage 4: Optional brief 7-core parallel benchmark (n7_s10a or n6_o2-like speed? Use n7_s10a -> n8_par7!)
    if args.parallel7:
        print(f"\n=== Stage 4: Brief 7-Core Parallel Zero-.p130 Benchmark (CPUs 0..6, t=0.00s!) ===", flush=True)
        obj7 = WORK / "obj_par7"
        t_all = time.perf_counter()
        stub_meta7 = gen_stubs.generate_all(patched_k10, src_dir, abi_mode=args.abi, direct_set=direct_set)
        s7 = compile_all_zero_p130(n7_bin, src_dir, obj7, cpus=[0, 1, 2, 3, 4, 5, 6], fid_bases=fid_bases)
        n8_par7 = WORK / "n8_par7"
        m7, l7 = merge_and_link(n7_bin, obj7, obj7 / "merge.o", n8_par7, cpu=0)
        e2e_7c = round((time.perf_counter() - t_all) * 1000.0, 1)
        print(f"Stage 4 7-core TRUE-COLD ZERO-.p130 E2E: {e2e_7c} ms ({e2e_7c/1000:.2f} s) vs 177.22 s baseline ({177216.6/e2e_7c:.2f}x faster!)", flush=True)
        results["stage4_par7_n7"] = {
            **s7,
            "stub_gen_ms": stub_meta7["elapsed_ms"],
            "merge_ms": m7,
            "link_ms": l7,
            "e2e_ms": e2e_7c,
            "speedup_vs_177s": round(177216.6 / e2e_7c, 2),
        }

    out_json = S10A_DIR / "results.json"
    out_json.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    print(f"\nSaved results to {out_json}", flush=True)


if __name__ == "__main__":
    main()
