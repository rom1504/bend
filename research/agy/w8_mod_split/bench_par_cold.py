#!/usr/bin/env python3
"""Benchmark 3-core (+main on 4th core) parallel cold native build of
compiler_slice_750kb.bend on wave7-native-self/n1 vs 1-core cold baseline.

Tests both `x86-object` (-O2) and `x86-object-fast` (-O0) modes.
Pins processes to CPUs 0,1,4,5 and verifies exact output `102` on every lane.
"""
from __future__ import annotations

import json
import os
import re
import resource
import shutil
import subprocess
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
SLICE_750 = ROOT / "research/agy/w7_bench/compiler_slice_750kb.bend"
N1 = ROOT / "selfhost/build/agy/wave7-native-self/n1"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
BASE = ROOT / "selfhost/dist/base.bend"
CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
TMP = Path("/tmp/agy_w8_mod_split")
OUT_JSON = ROOT / "research/agy/w8_mod_split/par_cold_results.json"
EXPECTED_OUT = "102"
CPUS = ["0", "1", "4", "5"]


def enc_fid_prefix(name: str) -> str:
    return "FID_" + "_".join(str(ord(c)) for c in name) + "_"


def get_defined_globals(obj: Path) -> set[str]:
    out = subprocess.check_output(["nm", "-g", "--defined-only", str(obj)], text=True)
    syms = set()
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3:
            syms.add(parts[2])
    return syms


def split_750kb(out_dir: Path) -> dict[str, Path]:
    """Split compiler_slice_750kb.bend into 3 disjoint modules + main module."""
    text = SLICE_750.read_text()
    lines = text.splitlines(keepends=True)

    # Locate boundaries:
    # Header: lines before first c0_ def (including preceding @unsafe)
    def find_first_def(prefix: str) -> int:
        pat = re.compile(rf"^def {re.escape(prefix)}")
        for i, l in enumerate(lines):
            if pat.match(l):
                if i > 0 and lines[i - 1].startswith("@unsafe"):
                    return i - 1
                return i
        raise RuntimeError(f"Could not find def {prefix}")

    i_c0 = find_first_def("c0_")
    i_c1 = find_first_def("c1_")
    i_c2 = find_first_def("c2_")
    i_main = find_first_def("main")

    header = "".join(lines[:i_c0])
    c0_body = "".join(lines[i_c0:i_c1])
    c1_body = "".join(lines[i_c1:i_c2])
    c2_body = "".join(lines[i_c2:i_main])
    main_body = "".join(lines[i_main:])

    def mod_main_for(p: str) -> str:
        return (
            f"\ndef main() -> U32:\n"
            f'  +t = {p}_f_lex_cursor("def foo(x: U32) -> U32:\\n  U32.add(x, 1)\\n", 1, 1, 0, [], 0, 0)\n'
            f"  U32.add({p}_w7_slice_len(t, 0), {p}_base_prefix_stamp([], 16))\n"
        )

    # Self-recursive ABI-matched stubs for the 9 functions called by main()
    stubs = []
    for p in ("c0", "c1", "c2"):
        stubs.append(
            f"@unsafe\n"
            f"def {p}_f_lex_cursor(+s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:\n"
            f"  {p}_f_lex_cursor(s, l, c, d, acc, offset, previous)\n\n"
            f"@unsafe\n"
            f"def {p}_w7_slice_len(xs: List<&2, FToken>, acc: U32) -> U32:\n"
            f"  {p}_w7_slice_len(xs, acc)\n\n"
            f"@unsafe\n"
            f"def {p}_base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:\n"
            f"  {p}_base_prefix_stamp(book, bound)\n\n"
        )

    paths = {
        "c0": out_dir / "mod_c0.bend",
        "c1": out_dir / "mod_c1.bend",
        "c2": out_dir / "mod_c2.bend",
        "main": out_dir / "mod_main.bend",
    }
    paths["c0"].write_text(header + c0_body + mod_main_for("c0"))
    paths["c1"].write_text(header + c1_body + mod_main_for("c1"))
    paths["c2"].write_text(header + c2_body + mod_main_for("c2"))
    paths["main"].write_text(header + "".join(stubs) + main_body)
    return paths


def run_n1_single(mode: str, src: Path, out_o: Path, cpu: str) -> tuple[float, int]:
    err_p = out_o.with_suffix(".err")
    t0 = time.perf_counter()
    with open(out_o, "wb") as fo, open(err_p, "wb") as fe:
        r = subprocess.run(
            ["taskset", "-c", cpu, str(N1), mode, str(src), str(BASE), "cache", str(CARRIER), STAMP],
            stdout=fo, stderr=fe,
        )
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    if r.returncode != 0:
        raise RuntimeError(f"n1 {mode} failed on {src.name} (rc={r.returncode}): {err_p.read_text()[:500]}")
    return ms, out_o.stat().st_size


def run_n1_parallel(mode: str, jobs: list[tuple[str, Path, Path, str]]) -> tuple[float, dict[str, dict]]:
    """Launch all jobs simultaneously, each pinned to its own CPU."""
    procs = []
    t_wall0 = time.perf_counter()
    for name, src, out_o, cpu in jobs:
        fo = open(out_o, "wb")
        fe = open(out_o.with_suffix(".err"), "wb")
        ts = time.perf_counter()
        p = subprocess.Popen(
            ["taskset", "-c", cpu, str(N1), mode, str(src), str(BASE), "cache", str(CARRIER), STAMP],
            stdout=fo, stderr=fe,
        )
        procs.append((name, p, fo, fe, out_o, cpu, ts))

    per_mod = {}
    # Wait for each to finish (poll in order of completion using waitpid)
    remaining = {p.pid: item for item in procs for p in [item[1]]}
    while remaining:
        pid, status = os.waitpid(-1, 0)
        if pid not in remaining:
            continue
        name, p, fo, fe, out_o, cpu, ts = remaining.pop(pid)
        elapsed = round((time.perf_counter() - ts) * 1000.0, 1)
        fo.close()
        fe.close()
        rc = os.waitstatus_to_exitcode(status)
        if rc != 0:
            raise RuntimeError(f"parallel n1 {mode} failed on {name} (rc={rc}): {out_o.with_suffix('.err').read_text()[:500]}")
        per_mod[name] = {"cpu": cpu, "ms": elapsed, "obj_bytes": out_o.stat().st_size}

    wall_ms = round((time.perf_counter() - t_wall0) * 1000.0, 1)
    return wall_ms, per_mod


def is_module_export(sym: str, mod_prefix: str) -> bool:
    """True if ELF symbol corresponds to a top-level def starting with mod_prefix."""
    # Encoded forms: p111_FID_<ascii>_ or p113d_FID_<ascii>_ or $direct.<name>
    pfx_plain = enc_fid_prefix(mod_prefix)
    pfx_direct = enc_fid_prefix("$direct." + mod_prefix)
    # Remove trailing underscore so we match prefix!
    return (
        ("_" + pfx_plain[:-1]) in sym
        or ("_" + pfx_direct[:-1]) in sym
    )


def prepare_and_link_modules(objs: dict[str, Path], exe: Path) -> tuple[float, float, str]:
    """Localize private/static symbols, weaken duplicate Base/stub symbols, link & run."""
    t_oc0 = time.perf_counter()
    syms = {k: get_defined_globals(p) for k, p in objs.items()}

    # Identify Base symbols: symbols present in ALL 4 objects that are NOT main and NOT private static/k
    # Actually even simpler:
    # - For c0, c1, c2: keep ONLY their own c{i}_* exports global (plus Base in c0).
    #   Wait: if c1, c2, main call Base helpers, c0 provides strong Base; OR even cleaner:
    #   localize all per-object static pool / continuation / data symbols that are NOT callable defs,
    #   and weaken Base in c1, c2, main!
    # Let's distinguish callable defs (`p111_FID_` / `p113d_FID_` excluding `$p111.k.` continuations)
    # from non-export per-object symbols (static pools, `.rodata` labels, `$p111.k.*`, `main`).
    K_PREFIX = "p111_FID_36_112_49_49_49_46_107_46_"  # $p111.k.

    adj_objs = []
    for mod in ("c0", "c1", "c2", "main"):
        src_o = objs[mod]
        dst_o = src_o.with_name(src_o.stem + "_adj.o")
        to_localize = []
        to_weaken = []

        for s in sorted(syms[mod]):
            if s == "main" or is_module_export(s, "main"):
                if mod != "main":
                    to_localize.append(s)
                continue
            # Private continuations & static pools / non-FID runtime glue: ALWAYS localize!
            if s.startswith(K_PREFIX) or ("_FID_" not in s):
                to_localize.append(s)
                continue
            # Module-owned exports
            if mod in ("c0", "c1", "c2"):
                if is_module_export(s, f"{mod}_"):
                    continue  # Keep STRONG GLOBAL!
                # Otherwise it's a Base def (or shared helper): keep strong in c0, weaken in c1/c2
                if mod != "c0":
                    to_weaken.append(s)
            else:
                # mod == "main": weaken ALL stubs (c0_, c1_, c2_) and Base defs!
                to_weaken.append(s)

        cmd = ["objcopy"]
        for s in to_localize:
            cmd += ["-L", s]
        for s in to_weaken:
            cmd += ["-W", s]
        cmd += [str(src_o), str(dst_o)]
        subprocess.run(cmd, check=True)
        adj_objs.append(dst_o)

    oc_ms = round((time.perf_counter() - t_oc0) * 1000.0, 1)

    t_lnk0 = time.perf_counter()
    subprocess.run(
        [CC, "-no-pie", *[str(o) for o in adj_objs], str(RT), "-o", str(exe), "-lm", "-lpthread"],
        check=True,
    )
    link_ms = round((time.perf_counter() - t_lnk0) * 1000.0, 1)
    out = subprocess.run([str(exe)], capture_output=True, text=True, check=True, timeout=15).stdout.strip()
    if out != EXPECTED_OUT:
        raise RuntimeError(f"Parallel linked binary wrong output: got {out!r}, expected {EXPECTED_OUT!r}")
    return oc_ms, link_ms, out


def link_single_and_run(obj: Path, exe: Path) -> tuple[float, str]:
    t0 = time.perf_counter()
    subprocess.run([CC, "-no-pie", str(obj), str(RT), "-o", str(exe), "-lm", "-lpthread"], check=True)
    link_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    out = subprocess.run([str(exe)], capture_output=True, text=True, check=True, timeout=15).stdout.strip()
    if out != EXPECTED_OUT:
        raise RuntimeError(f"Single binary wrong output: got {out!r}, expected {EXPECTED_OUT!r}")
    return link_ms, out


def main() -> None:
    if TMP.exists():
        shutil.rmtree(TMP)
    TMP.mkdir(parents=True, exist_ok=True)

    mod_srcs = split_750kb(TMP)
    mod_sizes = {k: p.stat().st_size for k, p in mod_srcs.items()}
    print("Split module sizes (bytes):", mod_sizes, flush=True)

    results: dict = {
        "compiler": str(N1),
        "input": str(SLICE_750),
        "input_bytes": SLICE_750.stat().st_size,
        "module_source_bytes": mod_sizes,
        "cpus": CPUS,
        "lanes": {},
    }

    for mode in ("x86-object", "x86-object-fast"):
        tag = "o2" if mode == "x86-object" else "o0_fast"
        print(f"\n--- Mode: {mode} ---", flush=True)

        # 1. Monolithic 1-core cold baseline (CPU 0)
        mono_o = TMP / f"mono_{tag}.o"
        mono_exe = TMP / f"mono_{tag}"
        mono_n1_ms, mono_bytes = run_n1_single(mode, SLICE_750, mono_o, cpu="0")
        mono_link_ms, mono_out = link_single_and_run(mono_o, mono_exe)
        mono_total_ms = round(mono_n1_ms + mono_link_ms, 1)
        print(f"  1-core cold ({mode}): n1={mono_n1_ms} ms, link={mono_link_ms} ms, total={mono_total_ms} ms, out={mono_out}", flush=True)

        # 2. Parallel 3-core (+main on 4th core) cold build (CPUs 0,1,4,5)
        par_objs = {k: TMP / f"par_{tag}_{k}.o" for k in ("c0", "c1", "c2", "main")}
        jobs = [
            ("c0", mod_srcs["c0"], par_objs["c0"], CPUS[0]),
            ("c1", mod_srcs["c1"], par_objs["c1"], CPUS[1]),
            ("c2", mod_srcs["c2"], par_objs["c2"], CPUS[2]),
            ("main", mod_srcs["main"], par_objs["main"], CPUS[3]),
        ]
        par_n1_ms, per_mod = run_n1_parallel(mode, jobs)
        oc_ms, par_link_ms, par_out = prepare_and_link_modules(par_objs, TMP / f"par_{tag}_exe")
        par_total_ms = round(par_n1_ms + oc_ms + par_link_ms, 1)
        speedup_n1 = round(mono_n1_ms / par_n1_ms, 2)
        speedup_total = round(mono_total_ms / par_total_ms, 2)
        print(
            f"  3+1 core par ({mode}): n1_wall={par_n1_ms} ms ({speedup_n1}x), "
            f"objcopy={oc_ms} ms, link={par_link_ms} ms, total={par_total_ms} ms ({speedup_total}x), out={par_out}",
            flush=True,
        )
        print(f"    per-mod: {per_mod}", flush=True)

        results["lanes"][mode] = {
            "mono_1c": {
                "cpu": "0",
                "n1_ms": mono_n1_ms,
                "link_ms": mono_link_ms,
                "total_ms": mono_total_ms,
                "obj_bytes": mono_bytes,
                "out": mono_out,
            },
            "par_3plus1c": {
                "n1_wall_ms": par_n1_ms,
                "objcopy_ms": oc_ms,
                "link_ms": par_link_ms,
                "total_ms": par_total_ms,
                "speedup_n1": speedup_n1,
                "speedup_total": speedup_total,
                "per_mod": per_mod,
                "out": par_out,
            },
        }

    peak_rss_mib = round(resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss / 1024.0, 1)
    results["peak_child_rss_mib"] = peak_rss_mib
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUT_JSON.write_text(json.dumps(results, indent=2) + "\n")
    print(f"\nSaved results to {OUT_JSON} (peak child RSS: {peak_rss_mib} MiB)")


if __name__ == "__main__":
    main()
