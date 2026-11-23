#!/usr/bin/env python3
"""Phase 4: Native Wave 10 K=12 Parallel Self-Reproduction (n2_w10 -> n3_w10).

Stage 1: wave10_unified/api.mjs -> n2_w10 (0 C, 0 objcopy, 0 --allow-multiple-definition)
Stage 2: Native n2_w10 (3-core parallel CPUs 0,1,2) -> n3_w10 (0 JS, 0 C, 0 objcopy)
Stage 3: Native n2_w10 1-module body edit on m11 (stage=read -> stage=read_n3) + relink
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
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"

OUT_DIR = ROOT / "research/agy/w10_mod_bend/p4_native_repro"
RESULTS_JSON = OUT_DIR / "results.json"
NATIVE_DIR = ROOT / "selfhost/build/agy/wave10-native-mod"
N2_W10 = NATIVE_DIR / "n2_w10"
N3_W10 = NATIVE_DIR / "n3_w10"

TMP = Path("/tmp/agy_p4_w10")
SRC_DIR = TMP / "src"
IFACE_DIR = TMP / "iface"
OBJ_S1 = TMP / "obj_s1"
OBJ_S2 = TMP / "obj_s2"
OBJ_S3 = TMP / "obj_s3"
SMOKE_DIR = TMP / "smoke"

FID_LIMIT = 65532
NODE_LIMIT = 1048576
STR_LIMIT = 65536
PROVISIONAL_STRIDE = 5400

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


def run_w10_cli(
    args: list[str],
    out_file: Path,
    max_mb: int = 4096,
    cpu: int | None = None,
    timeout: int = 600,
) -> tuple[float, str]:
    base_cmd = ["bash", str(LOCKED_NODE), str(CLI), str(API), *args]
    cmd = (["taskset", "-c", str(cpu)] + base_cmd) if cpu is not None else base_cmd
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
    # Use bash -c with ulimit -s 262144 and exec taskset -c <cpu> <binary> ...
    cmd = ["bash", "-c", 'ulimit -s 262144 && exec taskset -c "$1" "$2" "${@:3}"', "_", str(cpu), str(binary), *args]
    t0 = time.perf_counter()
    with out_file.open("wb") as f:
        r = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, cwd=ROOT, timeout=timeout)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = r.stderr.decode("utf-8", errors="replace").strip()
    if r.returncode != 0:
        raise RuntimeError(f"native {binary.name} failed (rc={r.returncode}) args={args[:4]}: {stderr[:800]}")
    return ms, stderr


def parse_trace_stages(stderr: str) -> dict[str, float]:
    stages: dict[str, float] = {}
    for line in stderr.splitlines():
        m = re.search(r"stage=([A-Za-z0-9_.-]+)\s+ms=([0-9.]+)", line)
        if m:
            stages[m.group(1)] = float(m.group(2))
    return stages


def link_compiler(merge_o: Path, mod_objs: list[Path], out_bin: Path) -> float:
    t0 = time.perf_counter()
    subprocess.run(
        [CC, "-O2", "-no-pie", str(merge_o), *[str(o) for o in mod_objs], str(RT), "-o", str(out_bin), "-lm", "-lpthread"],
        check=True,
    )
    return round((time.perf_counter() - t0) * 1000.0, 1)


def smoke_test(binary: Path, tag: str, cpu: int = 2) -> dict:
    sm_o = SMOKE_DIR / f"{tag}_smoke.o"
    sm_exe = SMOKE_DIR / f"{tag}_smoke.exe"
    compile_ms, stderr = run_native(
        binary,
        ["--trace", "x86-object-fast", str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
        out_file=sm_o,
        cpu=cpu,
        timeout=120,
    )
    t_lk = time.perf_counter()
    subprocess.run([CC, "-no-pie", str(sm_o), str(RT), "-o", str(sm_exe), "-lm", "-lpthread"], check=True)
    link_ms = round((time.perf_counter() - t_lk) * 1000.0, 1)
    out = subprocess.run([str(sm_exe)], capture_output=True, text=True, check=True, timeout=30).stdout.strip()
    assert out == "34", f"[{tag}] Expected '34', got {out!r}"
    trace_lines = [ln for ln in stderr.splitlines() if ln.strip()]
    return {
        "compile_ms": compile_ms,
        "link_ms": link_ms,
        "obj_bytes": sm_o.stat().st_size,
        "out": out,
        "trace_lines": trace_lines,
        "trace_stages": parse_trace_stages(stderr),
    }


def save_results(res: dict) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    RESULTS_JSON.write_text(json.dumps(res, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    for d in [OUT_DIR, NATIVE_DIR, SRC_DIR, IFACE_DIR, OBJ_S1, OBJ_S2, OBJ_S3, SMOKE_DIR]:
        d.mkdir(parents=True, exist_ok=True)

    types_text = (K12_DIR / "types.bend").read_text(encoding="utf-8")
    mod_names = [f"m{i:02d}" for i in range(12)]
    mod_texts = [(K12_DIR / f"{m}.bend").read_text(encoding="utf-8") for m in mod_names]

    # Prepare exports-only sources for m00..m10; m11 keeps compiler main
    src_paths: dict[str, Path] = {}
    export_counts: dict[str, int] = {}
    for i, m in enumerate(mod_names):
        prefix = (types_text + "\n") if i == 0 else "import Base\n"
        if i == 11:
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

    from_stage2 = "--from-stage2" in sys.argv
    if from_stage2:
        results = json.loads(RESULTS_JSON.read_text(encoding="utf-8"))
        s1 = results["stage1_js_to_n2"]
        s1_records = s1["modules"]
        s1_records_map = {r["module"]: r for r in s1_records}
        s1_fid_bases = {r["module"]: r["fid_base"] for r in s1_records}
        carriers: list[tuple[Path, str]] = [(BASE_CARRIER, BASE_STAMP)]
        for rec in s1["iface_records"]:
            carriers.append((IFACE_DIR / f"{rec['module']}.p130", rec["stamp"]))
        merge_s1 = OBJ_S1 / "merge.o"
        print("=== RESUMING FROM STAGE 2 (using Stage 1 n2_w10, carriers, and exact fid_bases) ===", flush=True)
    else:
        results = {
            "status": "in_progress",
            "export_counts": export_counts,
            "stage1_js_to_n2": {},
            "stage2_native_n2_to_n3": {},
            "stage3_native_edit_m11": {},
        }
        save_results(results)

        # =========================================================================
        # STAGE 1: Mint n2_w10 via wave10_unified/api.mjs
        # =========================================================================
        print("=== STAGE 1A: x86-iface chain (m00.p130 .. m10.p130) via wave10_unified/api.mjs ===", flush=True)
        carriers = [(BASE_CARRIER, BASE_STAMP)]
        iface_records = []
        t_iface0 = time.perf_counter()
        for i in range(11):
            m = mod_names[i]
            in_carrier, in_stamp = carriers[i]
            out_p130 = IFACE_DIR / f"{m}.p130"
            ms, stderr = run_w10_cli(
                ["x86-iface", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp],
                out_file=out_p130,
                max_mb=4096,
                cpu=0,
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
                "node_pct": round(100.0 * info["nodes"] / NODE_LIMIT, 2),
                "string_pct": round(100.0 * info["strings"] / STR_LIMIT, 2),
                "stamp": stamp,
            }
            iface_records.append(rec)
            carriers.append((out_p130, stamp))
            print(
                f"  [iface {i+1:2d}/11] {m}.p130: {info['bytes']:,} B | nodes={info['nodes']:,} ({rec['node_pct']}%) "
                f"| strs={info['strings']:,} ({rec['string_pct']}%) | {ms} ms",
                flush=True,
            )
        iface_wall_ms = round((time.perf_counter() - t_iface0) * 1000.0, 1)
        print(f"  Stage 1A iface total: {iface_wall_ms} ms", flush=True)

        print("=== STAGE 1B: x86-module-fast (m00.o .. m11.o) via wave10_unified/api.mjs (2-way parallel CPUs 0,1) ===", flush=True)
        s1_fid_bases = {mod_names[i]: i * PROVISIONAL_STRIDE for i in range(12)}
        s1_records_map = {}

        def compile_s1_mod(i: int, cpu: int, fid_base: int) -> dict:
            m = mod_names[i]
            in_carrier, in_stamp = carriers[i]
            out_o = OBJ_S1 / f"{m}.o"
            ms, _ = run_w10_cli(
                ["x86-module-fast", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fid_base), m],
                out_file=out_o,
                max_mb=3072,
                cpu=cpu,
            )
            segs = get_seg_count(out_o, m)
            return {
                "module": m,
                "cpu": cpu,
                "fid_base": fid_base,
                "seg_count": segs,
                "fid_end": fid_base + segs - 1,
                "ms": ms,
                "bytes": out_o.stat().st_size,
                "sha256": sha256(out_o),
            }

        t_s1b0 = time.perf_counter()
        work_q1: queue.Queue[int] = queue.Queue()
        for i in [11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]:
            work_q1.put(i)

        def worker_s1(cpu: int) -> None:
            while True:
                try:
                    i = work_q1.get_nowait()
                except queue.Empty:
                    return
                m = mod_names[i]
                rec = compile_s1_mod(i, cpu, s1_fid_bases[m])
                s1_records_map[m] = rec
                print(
                    f"  [S1 cpu={cpu}] {m}.o: {rec['bytes']:,} B | fid=[{rec['fid_base']}..{rec['fid_end']}] "
                    f"(segs={rec['seg_count']:,}) | {rec['ms']} ms",
                    flush=True,
                )

        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as ex:
            futs = [ex.submit(worker_s1, cpu) for cpu in (0, 1)]
            for f in futs:
                f.result()

        # Verify non-overlapping FIDs and <= FID_LIMIT; if any overlap or overflow, recompile with exact contiguous bases
        s1_records = [s1_records_map[m] for m in mod_names]
        total_segs = sum(r["seg_count"] for r in s1_records)
        assert total_segs <= FID_LIMIT, f"Total segs {total_segs} > {FID_LIMIT}!"
        overlap_or_overflow = any(
            s1_records[i]["fid_end"] >= s1_records[i + 1]["fid_base"] for i in range(11)
        ) or (s1_records[11]["fid_end"] >= FID_LIMIT)
        if overlap_or_overflow:
            print("  Provisional 5400 stride overlapped/overflowed; recomputing exact contiguous fid_bases...", flush=True)
            cur = 0
            new_bases: dict[str, int] = {}
            for r in s1_records:
                new_bases[r["module"]] = cur
                cur += r["seg_count"]
            to_redo = [i for i, m in enumerate(mod_names) if new_bases[m] != s1_fid_bases[m]]
            for m in mod_names:
                s1_fid_bases[m] = new_bases[m]
            q_redo: queue.Queue[int] = queue.Queue()
            for i in to_redo:
                q_redo.put(i)

            def worker_redo(cpu: int) -> None:
                while True:
                    try:
                        i = q_redo.get_nowait()
                    except queue.Empty:
                        return
                    m = mod_names[i]
                    rec = compile_s1_mod(i, cpu, s1_fid_bases[m])
                    s1_records_map[m] = rec
                    print(f"  [S1-redo cpu={cpu}] {m}.o: fid=[{rec['fid_base']}..{rec['fid_end']}] | {rec['ms']} ms", flush=True)

            with concurrent.futures.ThreadPoolExecutor(max_workers=2) as ex:
                for f in [ex.submit(worker_redo, cpu) for cpu in (0, 1)]:
                    f.result()
            s1_records = [s1_records_map[m] for m in mod_names]

        s1_compile_wall_ms = round((time.perf_counter() - t_s1b0) * 1000.0, 1)
        s1_objs = [OBJ_S1 / f"{m}.o" for m in mod_names]

        print("=== STAGE 1C: x86-merge-obj + gcc-10 link -> n2_w10 ===", flush=True)
        merge_s1 = OBJ_S1 / "merge.o"
        s1_merge_ms, _ = run_w10_cli(["x86-merge-obj", "m11", "m11", *mod_names[:11]], out_file=merge_s1, max_mb=4096, cpu=0)
        s1_link_ms = link_compiler(merge_s1, s1_objs, N2_W10)
        print(f"  LINKED {N2_W10} ({N2_W10.stat().st_size:,} B) | merge={s1_merge_ms} ms | link={s1_link_ms} ms", flush=True)

        print("=== STAGE 1D: Smoke test n2_w10 on compiler_slice.bend ===", flush=True)
        s1_smoke = smoke_test(N2_W10, "n2_w10", cpu=2)
        print(f"  n2_w10 SMOKE PASS: out={s1_smoke['out']} | compile={s1_smoke['compile_ms']} ms | link={s1_smoke['link_ms']} ms", flush=True)

        results["stage1_js_to_n2"] = {
            "iface_wall_ms": iface_wall_ms,
            "iface_records": iface_records,
            "compile_wall_ms": s1_compile_wall_ms,
            "compile_sum_ms": round(sum(r["ms"] for r in s1_records), 1),
            "total_segs": total_segs,
            "fid_limit": FID_LIMIT,
            "max_fid_used": s1_records[11]["fid_end"],
            "modules": s1_records,
            "merge_ms": s1_merge_ms,
            "merge_bytes": merge_s1.stat().st_size,
            "link_ms": s1_link_ms,
            "n2_w10_bytes": N2_W10.stat().st_size,
            "n2_w10_sha256": sha256(N2_W10),
            "smoke": s1_smoke,
        }
        save_results(results)

    # =========================================================================
    # STAGE 2: 100% NATIVE Parallel Self-Reproduction (n2_w10 -> n3_w10)
    # =========================================================================
    print("\n=== STAGE 2A: 100% NATIVE 3-core parallel n2_w10 --trace x86-module-fast (CPUs 0,1,2) ===", flush=True)
    s2_records_map: dict[str, dict] = {}
    work_q2: queue.Queue[int] = queue.Queue()
    # Schedule heaviest/slowest modules first for optimal 3-core load balance
    order_s2 = sorted(range(12), key=lambda idx: s1_records[idx]["ms"], reverse=True)
    for i in order_s2:
        work_q2.put(i)

    def worker_s2(cpu: int) -> None:
        while True:
            try:
                i = work_q2.get_nowait()
            except queue.Empty:
                return
            m = mod_names[i]
            in_carrier, in_stamp = carriers[i]
            fid_base = s1_fid_bases[m]
            out_o = OBJ_S2 / f"{m}.o"
            ms, stderr = run_native(
                N2_W10,
                ["--trace", "x86-module-fast", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fid_base), m],
                out_file=out_o,
                cpu=cpu,
                timeout=900,
            )
            segs = get_seg_count(out_o, m)
            s2_sha = sha256(out_o)
            rec = {
                "module": m,
                "cpu": cpu,
                "fid_base": fid_base,
                "seg_count": segs,
                "fid_end": fid_base + segs - 1,
                "ms": ms,
                "bytes": out_o.stat().st_size,
                "sha256": s2_sha,
                "bit_identical_to_s1": (s2_sha == s1_records_map[m]["sha256"]),
                "trace_stages": parse_trace_stages(stderr),
                "trace_lines": [ln for ln in stderr.splitlines() if ln.strip()],
            }
            s2_records_map[m] = rec
            print(
                f"  [S2-native cpu={cpu}] {m}.o: {rec['bytes']:,} B | segs={segs:,} | {ms} ms "
                f"| bit_eq_s1={rec['bit_identical_to_s1']}",
                flush=True,
            )

    t_s2_total0 = time.perf_counter()
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as ex:
        futs = [ex.submit(worker_s2, cpu) for cpu in (0, 1, 2)]
        for f in futs:
            f.result()
    s2_compile_wall_ms = round((time.perf_counter() - t_s2_total0) * 1000.0, 1)
    s2_records = [s2_records_map[m] for m in mod_names]
    s2_objs = [OBJ_S2 / f"{m}.o" for m in mod_names]

    print("=== STAGE 2B: Native n2_w10 x86-merge-obj + gcc-10 link -> n3_w10 ===", flush=True)
    merge_s2 = OBJ_S2 / "merge_n3.o"
    s2_merge_ms, _ = run_native(
        N2_W10,
        ["x86-merge-obj", "m11", "m11", *mod_names[:11]],
        out_file=merge_s2,
        cpu=0,
        timeout=120,
    )
    s2_link_ms = link_compiler(merge_s2, s2_objs, N3_W10)
    s2_e2e_wall_ms = round((time.perf_counter() - t_s2_total0) * 1000.0, 1)
    n3_sha = sha256(N3_W10)
    print(
        f"  LINKED {N3_W10} ({N3_W10.stat().st_size:,} B) | compile_wall={s2_compile_wall_ms} ms "
        f"| merge={s2_merge_ms} ms | link={s2_link_ms} ms | E2E={s2_e2e_wall_ms} ms "
        f"| n3==n2: {n3_sha == sha256(N2_W10)}",
        flush=True,
    )

    print("=== STAGE 2C: Smoke test n3_w10 on compiler_slice.bend ===", flush=True)
    s2_smoke = smoke_test(N3_W10, "n3_w10", cpu=2)
    print(f"  n3_w10 SMOKE PASS: out={s2_smoke['out']} | compile={s2_smoke['compile_ms']} ms | link={s2_smoke['link_ms']} ms", flush=True)

    results["stage2_native_n2_to_n3"] = {
        "parallel_cpus": [0, 1, 2],
        "schedule_order": [mod_names[i] for i in order_s2],
        "compile_wall_ms": s2_compile_wall_ms,
        "compile_sum_ms": round(sum(r["ms"] for r in s2_records), 1),
        "speedup_vs_seq_native": round(sum(r["ms"] for r in s2_records) / s2_compile_wall_ms, 2),
        "merge_ms": s2_merge_ms,
        "merge_bytes": merge_s2.stat().st_size,
        "merge_bit_identical_to_s1": (sha256(merge_s2) == sha256(merge_s1)),
        "link_ms": s2_link_ms,
        "e2e_wall_ms": s2_e2e_wall_ms,
        "n3_w10_bytes": N3_W10.stat().st_size,
        "n3_w10_sha256": n3_sha,
        "n3_bit_identical_to_n2": (n3_sha == sha256(N2_W10)),
        "all_12_objs_bit_identical_to_s1": all(r["bit_identical_to_s1"] for r in s2_records),
        "modules": s2_records,
        "smoke": s2_smoke,
    }
    save_results(results)

    # =========================================================================
    # STAGE 3: Native 1-Module Body Edit (n2_w10 rebuilding ONLY m11.o + relink)
    # =========================================================================
    print("\n=== STAGE 3: Native 1-Module Body Edit (m11: stage=read -> stage=read_n3) ===", flush=True)
    shas_before = {m: sha256(OBJ_S2 / f"{m}.o") for m in mod_names[:11]}
    m11_orig = src_paths["m11"].read_text(encoding="utf-8")
    assert '"stage=read ms="' in m11_orig, "Expected 'stage=read ms=' in m11"
    m11_edited = m11_orig.replace('"stage=read ms="', '"stage=read_n3 ms="', 1)
    assert m11_edited != m11_orig
    m11_edit_src = SRC_DIR / "m11_edit.bend"
    m11_edit_src.write_text(m11_edited, encoding="utf-8")

    m11_edit_o = OBJ_S3 / "m11_edit.o"
    t_s3_0 = time.perf_counter()
    s3_compile_ms, s3_stderr = run_native(
        N2_W10,
        ["--trace", "x86-module-fast", str(m11_edit_src), str(BASE_FILE), "cache", str(carriers[11][0]), carriers[11][1], str(s1_fid_bases["m11"]), "m11"],
        out_file=m11_edit_o,
        cpu=0,
        timeout=300,
    )
    shas_after = {m: sha256(OBJ_S2 / f"{m}.o") for m in mod_names[:11]}
    assert shas_before == shas_after, "Upstream .o SHA-256 changed!"
    n3_edit_bin = OBJ_S3 / "n3_w10_edit"
    s3_link_ms = link_compiler(merge_s2, [*s2_objs[:11], m11_edit_o], n3_edit_bin)
    s3_total_ms = round((time.perf_counter() - t_s3_0) * 1000.0, 1)

    s3_smoke = smoke_test(n3_edit_bin, "n3_w10_edit", cpu=2)
    observed_read_n3 = any("stage=read_n3" in ln for ln in s3_smoke["trace_lines"])
    assert observed_read_n3, f"Did not observe stage=read_n3 in trace: {s3_smoke['trace_lines']}"
    print(
        f"  STAGE 3 PASS! 11/12 .o SHA-256 identical | m11_rebuild={s3_compile_ms} ms | relink={s3_link_ms} ms "
        f"| total={s3_total_ms} ms | observed stage=read_n3 & out={s3_smoke['out']}!",
        flush=True,
    )

    results["stage3_native_edit_m11"] = {
        "reused_11_of_12_sha256_identical": True,
        "m11_rebuild_ms": s3_compile_ms,
        "m11_rebuild_bytes": m11_edit_o.stat().st_size,
        "m11_trace_stages": parse_trace_stages(s3_stderr),
        "m11_trace_lines": [ln for ln in s3_stderr.splitlines() if ln.strip()],
        "relink_ms": s3_link_ms,
        "total_edit_wall_ms": s3_total_ms,
        "observed_stage_read_n3": observed_read_n3,
        "smoke": s3_smoke,
    }
    results["status"] = "PASSED"
    save_results(results)
    print(f"\nALL 3 STAGES PASSED! Saved {RESULTS_JSON}", flush=True)


if __name__ == "__main__":
    main()
