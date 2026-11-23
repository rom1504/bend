#!/usr/bin/env python3
"""Benchmark REAL K=8 compiler modules from wave8_unified/compiler.bend
using native selfhost/build/agy/wave8-native-self/n1 x86-module.

Measures for each real module (mod0, mod1, mod2):
  - Source bytes, live def count, emitted segment count (nm/readelf),
    emitted .o bytes, .text bytes, wall time (1-core seq vs 2-core parallel on CPUs 0 & 1),
    peak RSS (MiB), and stage trace from n1 stderr.
"""
from __future__ import annotations

import json
import os
import re
import resource
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
N1 = ROOT / "selfhost/build/agy/wave8-native-self/n1"
BASE = ROOT / "selfhost/dist/base.bend"
CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
TMP = Path("/tmp/agy_w9_mod_compiler")


def set_stack_limit():
    # ulimit -s 262144 (256 MiB)
    limit = 262144 * 1024
    resource.setrlimit(resource.RLIMIT_STACK, (limit, limit))


def inspect_obj(obj_path: Path) -> dict:
    obj_bytes = obj_path.stat().st_size
    # .text size via readelf -S
    text_bytes = 0
    rodata_bytes = 0
    data_bytes = 0
    out_s = subprocess.check_output(["readelf", "-SW", str(obj_path)], text=True)
    for line in out_s.splitlines():
        parts = line.split()
        if len(parts) >= 7:
            # Handle "[ 1] .text ..." vs "[12] .text ..."
            idx = 1 if parts[0].startswith("[") and parts[0].endswith("]") else 2
            if idx < len(parts):
                sec = parts[idx]
                if sec in (".text", ".rodata", ".data") and idx + 4 < len(parts):
                    sz = int(parts[idx + 4], 16)
                    if sec == ".text":
                        text_bytes = sz
                    elif sec == ".rodata":
                        rodata_bytes = sz
                    elif sec == ".data":
                        data_bytes = sz
    # Count emitted segments / functions via nm -S
    nm_out = subprocess.check_output(["nm", "-S", "--defined-only", str(obj_path)], text=True)
    p111_syms = 0
    p113d_syms = 0
    k_syms = 0
    total_text_syms = 0
    mod_seg_count = None
    for line in nm_out.splitlines():
        parts = line.split()
        if len(parts) < 3:
            continue
        if len(parts) >= 4:
            sz_hex, typ, sym = parts[1], parts[2], parts[3]
            if sym.endswith("_p111_fid_arity"):
                mod_seg_count = int(sz_hex, 16)
        else:
            typ, sym = parts[1], parts[2]
        if typ in ("T", "t"):
            total_text_syms += 1
            if sym.startswith("p111_FID_"):
                p111_syms += 1
                if sym.startswith("p111_FID_36_112_49_49_49_46_107_46_"):
                    k_syms += 1
            elif sym.startswith("p113d_FID_"):
                p113d_syms += 1
    return {
        "obj_bytes": obj_bytes,
        "text_bytes": text_bytes,
        "rodata_bytes": rodata_bytes,
        "data_bytes": data_bytes,
        "mod_seg_count": mod_seg_count,
        "nm_text_syms": total_text_syms,
        "p111_syms": p111_syms,
        "p113d_syms": p113d_syms,
        "k_cont_syms": k_syms,
    }


def parse_trace(err_text: str) -> dict:
    info = {"trace_lines": []}
    for line in err_text.splitlines():
        if "[bend-trace]" in line:
            info["trace_lines"].append(line.strip())
            m = re.search(r"segs=(\d+)", line)
            if m:
                info["trace_segs"] = int(m.group(1))
    return info


def run_n1_mod(src: Path, out_o: Path, mod_name: str, fid_base: int, cpu: str) -> dict:
    err_p = out_o.with_suffix(".err")
    cmd = [
        "taskset", "-c", cpu,
        str(N1), "x86-module",
        str(src), str(BASE), "cache", str(CARRIER), STAMP,
        str(fid_base), mod_name,
    ]
    t0 = time.perf_counter()
    with open(out_o, "wb") as fo, open(err_p, "wb") as fe:
        p = subprocess.Popen(cmd, stdout=fo, stderr=fe, preexec_fn=set_stack_limit)
        _, status, ru = os.wait4(p.pid, 0)
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    rc = os.waitstatus_to_exitcode(status)
    rss_mib = round(ru.ru_maxrss / 1024.0, 1)
    err_txt = err_p.read_text(errors="replace")
    if rc != 0:
        return {
            "ok": False, "rc": rc, "mod": mod_name, "cpu": cpu,
            "wall_ms": wall_ms, "rss_mib": rss_mib,
            "err_tail": err_txt[-800:],
        }
    obj_info = inspect_obj(out_o)
    tr = parse_trace(err_txt)
    return {
        "ok": True, "rc": 0, "mod": mod_name, "cpu": cpu,
        "fid_base": fid_base, "wall_ms": wall_ms, "rss_mib": rss_mib,
        **obj_info, **tr,
    }


def run_n1_parallel(jobs: list[tuple[Path, Path, str, int, str]]) -> dict:
    procs = []
    t_wall0 = time.perf_counter()
    for src, out_o, mod_name, fid_base, cpu in jobs:
        err_p = out_o.with_suffix(".err")
        fo = open(out_o, "wb")
        fe = open(err_p, "wb")
        cmd = [
            "taskset", "-c", cpu,
            str(N1), "x86-module",
            str(src), str(BASE), "cache", str(CARRIER), STAMP,
            str(fid_base), mod_name,
        ]
        ts = time.perf_counter()
        p = subprocess.Popen(cmd, stdout=fo, stderr=fe, preexec_fn=set_stack_limit)
        procs.append((p.pid, mod_name, cpu, fid_base, out_o, err_p, fo, fe, ts))

    remaining = {item[0]: item for item in procs}
    per_mod = {}
    while remaining:
        pid, status, ru = os.wait4(-1, 0)
        if pid not in remaining:
            continue
        _, mod_name, cpu, fid_base, out_o, err_p, fo, fe, ts = remaining.pop(pid)
        elapsed_ms = round((time.perf_counter() - ts) * 1000.0, 1)
        fo.close()
        fe.close()
        rc = os.waitstatus_to_exitcode(status)
        rss_mib = round(ru.ru_maxrss / 1024.0, 1)
        err_txt = err_p.read_text(errors="replace")
        if rc != 0:
            per_mod[mod_name] = {
                "ok": False, "rc": rc, "cpu": cpu, "wall_ms": elapsed_ms,
                "rss_mib": rss_mib, "err_tail": err_txt[-800:],
            }
        else:
            obj_info = inspect_obj(out_o)
            tr = parse_trace(err_txt)
            per_mod[mod_name] = {
                "ok": True, "rc": 0, "cpu": cpu, "fid_base": fid_base,
                "wall_ms": elapsed_ms, "rss_mib": rss_mib,
                **obj_info, **tr,
            }
    total_wall_ms = round((time.perf_counter() - t_wall0) * 1000.0, 1)
    return {"total_wall_ms": total_wall_ms, "per_mod": per_mod}


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "test0"
    if mode == "test0":
        res = run_n1_mod(TMP / "mod0.bend", TMP / "mod0.o", "mod0", 0, "0")
        print(json.dumps(res, indent=2))
    elif mode == "test1":
        res = run_n1_mod(TMP / "mod1.bend", TMP / "mod1.o", "mod1", 10000, "0")
        print(json.dumps(res, indent=2))
    elif mode == "test2":
        res = run_n1_mod(TMP / "mod2.bend", TMP / "mod2.o", "mod2", 20000, "0")
        print(json.dumps(res, indent=2))
    elif mode == "par01":
        res = run_n1_parallel([
            (TMP / "mod0.bend", TMP / "mod0_par.o", "mod0", 0, "0"),
            (TMP / "mod1.bend", TMP / "mod1_par.o", "mod1", 10000, "1"),
        ])
        print(json.dumps(res, indent=2))
    elif mode == "par012":
        res = run_n1_parallel([
            (TMP / "mod0.bend", TMP / "mod0_par3.o", "mod0", 0, "0"),
            (TMP / "mod1.bend", TMP / "mod1_par3.o", "mod1", 10000, "1"),
            (TMP / "mod2.bend", TMP / "mod2_par3.o", "mod2", 20000, "2"),
        ])
        print(json.dumps(res, indent=2))
    elif mode == "run_all":
        out_p = ROOT / "research/agy/w9_mod_compiler/real_mods_results.json"
        meta_p = TMP / "extract_meta.json"
        results = {
            "compiler": str(N1),
            "extract_meta": json.loads(meta_p.read_text()) if meta_p.exists() else [],
            "sequential": {},
            "parallel_2core": None,
        }
        for name, fn, fb in [("mod0", "mod0.bend", 0), ("mod1", "mod1.bend", 15000), ("mod2", "mod2.bend", 30000)]:
            print(f"=== Sequential {name} (CPU 0) ===", flush=True)
            r = run_n1_mod(TMP / fn, TMP / f"{name}_seq.o", name, fb, "0")
            results["sequential"][name] = r
            out_p.write_text(json.dumps(results, indent=2) + "\n")
            print(json.dumps(r), flush=True)
            # Remove large .o immediately after inspecting to keep /dev/md2 free
            p_o = TMP / f"{name}_seq.o"
            if p_o.exists():
                p_o.unlink()

        # Run 2-core parallel on distinct physical cores (CPU 0 and CPU 1)
        ok_mods = [m for m in ("mod0", "mod1", "mod2") if results["sequential"].get(m, {}).get("ok")]
        if len(ok_mods) >= 2:
            m_a, m_b = ok_mods[0], ok_mods[1]
            print(f"=== Parallel 2-core {m_a} (CPU 0) + {m_b} (CPU 1) ===", flush=True)
            par = run_n1_parallel([
                (TMP / f"{m_a}.bend", TMP / f"{m_a}_par2.o", m_a, 0, "0"),
                (TMP / f"{m_b}.bend", TMP / f"{m_b}_par2.o", m_b, 15000, "1"),
            ])
            results["parallel_2core"] = par
            out_p.write_text(json.dumps(results, indent=2) + "\n")
            print(json.dumps(par), flush=True)
            for m in (m_a, m_b):
                p_o = TMP / f"{m}_par2.o"
                if p_o.exists():
                    p_o.unlink()
        print("DONE run_all ->", out_p, flush=True)
