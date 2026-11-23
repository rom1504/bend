#!/usr/bin/env python3
"""S10-F Verification & Benchmark Suite (strictly pinned to CPU 6, ulimit -s 262144).

1. Benchmarks `n6_s10f` vs `n6_o2` (and `n7_s10a` if present) on `m00_bench.bend`
   and `m09_zero.bend`, recording `x187_pub`, `x187_elf`, and `.o` size.
2. Runs `compiler_slice.bend` (-O0 & -O2, expected `34`) and `histogram.bend` (-O2, expected `3307081914`).
3. Runs 64/64 native64 conformance in `-O0` (`x86-object-fast`) and `-O2` (`x86-object`).
4. Runs 15/15 Live-Metadata Observer Gate in `-O2` (`0` violations).
5. Writes `results.json` and cleans all temporary `.o` / executables.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
N6_S10F = Path("/tmp/agy_s10f/n6_s10f")
N6_O2 = ROOT / "selfhost/build/agy/wave15-native-mod/n6_o2"
N7_S10A = Path("/tmp/agy_s10a/n7_s10a")
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
QUAL_CAT = ROOT / "selfhost/tests/phase182/qualification-catalog.json"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
HIST = ROOT / "research/agy/wave4_bench/inputs/upstream/histogram.bend"
M00_BENCH = Path("/tmp/agy_s10f/m00_bench.bend")
M09_BENCH = Path("/tmp/agy_s10f/m09_stub/m09_zero.bend")
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

OUT_DIR = ROOT / "research/agy/s10_campaign/s10f_elf_and_drop"
TMP = Path("/tmp/agy_s10f/verify")
CPU = 6

sys.path.insert(0, str(ROOT / "research/agy/wave3_fuzz"))
import observer_wave2_gate as obs


def run_cmd(cmd: list[str], timeout_s: int = 90, stdout_path: Path | None = None) -> tuple[int, float, str, str]:
    full = [
        "bash", "-c",
        'ulimit -s 262144 && exec timeout -k 5 "$1" taskset -c "$2" "$3" "${@:4}"',
        "_", str(timeout_s), str(CPU), *cmd,
    ]
    t0 = time.perf_counter()
    if stdout_path is not None:
        with stdout_path.open("wb") as of:
            r = subprocess.run(full, stdout=of, stderr=subprocess.PIPE, cwd=ROOT)
        out = ""
        err = r.stderr.decode("utf-8", errors="replace")
    else:
        r = subprocess.run(full, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=ROOT)
        out = r.stdout.decode("utf-8", errors="replace")
        err = r.stderr.decode("utf-8", errors="replace")
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    return r.returncode, ms, out, err


def parse_trace(stderr: str) -> dict[str, float]:
    st: dict[str, float] = {}
    for line in stderr.splitlines():
        m = re.search(r"stage=([A-Za-z0-9_.-]+)\s+ms=([0-9.]+)", line)
        if m:
            st[m.group(1)] = float(m.group(2))
        m2 = re.search(r"stage=(x187_priv_done|x187_pub_done)\s+count=(\d+)\s+elapsed=([0-9.]+)ms", line)
        if m2:
            st[m2.group(1) + "_count"] = int(m2.group(2))
            st[m2.group(1) + "_elapsed"] = float(m2.group(3))
        m3 = re.search(r"total_ms=([0-9.]+)ms", line)
        if m3:
            st["total_ms"] = float(m3.group(1))
    if "x187_priv_done_elapsed" in st and "x187_pub_done_elapsed" in st:
        st["x187_pub_ms"] = round(st["x187_pub_done_elapsed"] - st["x187_priv_done_elapsed"], 1)
    if "x187_pub_ms" in st and "x187_elf" in st:
        st["pub_plus_elf_ms"] = round(st["x187_pub_ms"] + st["x187_elf"], 1)
    return st


def bench_mod(binary: Path, src: Path, fid_base: int, mod_name: str, label: str) -> dict:
    obj = TMP / f"{label}.o"
    rc, wall_ms, _, err = run_cmd(
        [str(binary), "--trace", "x86-module-fast", str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP, str(fid_base), mod_name],
        timeout_s=150,
        stdout_path=obj,
    )
    sz = obj.stat().st_size if obj.exists() else 0
    if obj.exists():
        obj.unlink()
    if rc != 0:
        raise RuntimeError(f"bench_mod {label} failed rc={rc}: {err[-500:]}")
    tr = parse_trace(err)
    tr["obj_bytes"] = sz
    tr["wall_ms"] = wall_ms
    print(f"  [{label}] x187_pub={tr.get('x187_pub_ms')}ms  x187_elf={tr.get('x187_elf')}ms  pub+elf={tr.get('pub_plus_elf_ms')}ms  obj={sz/1e6:.2f}MB")
    return tr


def compile_and_run(binary: Path, mode: str, src: Path, tag: str) -> tuple[bool, str, float]:
    obj = TMP / f"{tag}.o"
    exe = TMP / f"{tag}.bin"
    rc, _, _, err = run_cmd(
        [str(binary), mode, str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
        timeout_s=60,
        stdout_path=obj,
    )
    if rc != 0 or not obj.exists() or obj.stat().st_size == 0:
        if obj.exists():
            obj.unlink()
        return False, f"compile rc={rc}: {err[-200:]}", 0.0
    rc_l, _, _, err_l = run_cmd([CC, "-no-pie", "-o", str(exe), str(obj), str(AGY_RT), "-lm", "-lpthread"], timeout_s=30)
    obj.unlink(missing_ok=True)
    if rc_l != 0:
        exe.unlink(missing_ok=True)
        return False, f"link rc={rc_l}: {err_l[-200:]}", 0.0
    rc_r, run_ms, out, err_r = run_cmd([str(exe), *RTS_ARGS], timeout_s=30)
    exe.unlink(missing_ok=True)
    if rc_r != 0:
        return False, f"run rc={rc_r}: {err_r[-200:]}", run_ms
    return True, out.strip(), run_ms


def run_native64(binary: Path, mode: str) -> dict:
    cat = json.loads(QUAL_CAT.read_text(encoding="utf-8"))
    cases = cat.get("cases", cat) if isinstance(cat, dict) else cat
    passed = 0
    failed = []
    t0 = time.perf_counter()
    for i, c in enumerate(cases):
        src = ROOT / c["path"]
        expected = "\n".join(c["expected"]).strip() if isinstance(c.get("expected"), list) else str(c.get("expected", "")).strip()
        ok, out, _ = compile_and_run(binary, mode, src, f"n64_{mode}_{i}")
        if ok and out == expected:
            passed += 1
        else:
            failed.append({"name": c.get("name", src.name), "expected": expected, "got": out})
    sec = round(time.perf_counter() - t0, 2)
    print(f"  [native64 {mode}] {passed}/{len(cases)} passed in {sec}s (failed={len(failed)})")
    if failed:
        for f in failed[:5]:
            print("    FAIL:", f)
    return {"passed": passed, "total": len(cases), "failed": failed, "elapsed_s": sec}


def run_observer_o2(binary: Path) -> dict:
    # Build observer hook if needed
    hook_so = TMP / "observer_hook.so"
    hook_c = ROOT / "research/agy/wave3_fuzz/observer_gate_hook.c"
    rc, _, _, err = run_cmd([CC, "-O2", "-shared", "-fPIC", "-o", str(hook_so), str(hook_c), "-ldl"], timeout_s=30)
    if rc != 0:
        raise RuntimeError(f"hook build failed: {err}")
    programs = obs.PROGRAMS
    passed = 0
    violations_total = 0
    failed = []
    t0 = time.perf_counter()
    for i, (name, code, expected) in enumerate(programs):
        src = TMP / f"obs_{i}.bend"
        src.write_text(code, encoding="utf-8")
        obj = TMP / f"obs_{i}.o"
        exe = TMP / f"obs_{i}.bin"
        rc_c, _, _, err_c = run_cmd(
            [str(binary), "x86-object", str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
            timeout_s=60,
            stdout_path=obj,
        )
        if rc_c != 0:
            failed.append({"name": name, "err": f"compile rc={rc_c}"})
            obj.unlink(missing_ok=True)
            continue
        rc_l, _, _, _ = run_cmd([CC, "-no-pie", "-o", str(exe), str(obj), str(AGY_RT), "-lm", "-lpthread"], timeout_s=30)
        obj.unlink(missing_ok=True)
        if rc_l != 0:
            failed.append({"name": name, "err": f"link rc={rc_l}"})
            exe.unlink(missing_ok=True)
            continue
        env = dict(os.environ)
        env["LD_PRELOAD"] = str(hook_so)
        cmd = ["bash", "-c", 'ulimit -s 262144 && exec timeout -k 5 30 taskset -c 6 "$1" "${@:2}"', "_", str(exe), *RTS_ARGS]
        r = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env, cwd=ROOT)
        exe.unlink(missing_ok=True)
        src.unlink(missing_ok=True)
        out = r.stdout.decode("utf-8", errors="replace").strip()
        err_r = r.stderr.decode("utf-8", errors="replace")
        m_v = re.search(r"violations=(\d+)", err_r)
        viols = int(m_v.group(1)) if m_v else 0
        violations_total += viols
        if r.returncode == 0 and out == str(expected).strip() and viols == 0:
            passed += 1
        else:
            failed.append({"name": name, "rc": r.returncode, "expected": str(expected), "got": out, "viols": viols})
    hook_so.unlink(missing_ok=True)
    sec = round(time.perf_counter() - t0, 2)
    print(f"  [observer -O2] {passed}/{len(programs)} passed, violations={violations_total} in {sec}s")
    return {"passed": passed, "total": len(programs), "violations": violations_total, "failed": failed, "elapsed_s": sec}


def main() -> None:
    TMP.mkdir(parents=True, exist_ok=True)
    results: dict = {}

    print("=== 1. Module Compile Benchmarks (CPU 6) ===")
    results["bench_slice_s10f"] = bench_mod(N6_S10F, SLICE, 0, "slice", "slice_s10f")
    results["bench_slice_n6_o2"] = bench_mod(N6_O2, SLICE, 0, "slice", "slice_n6_o2")
    if N7_S10A.exists():
        results["bench_slice_n7_s10a"] = bench_mod(N7_S10A, SLICE, 0, "slice", "slice_n7_s10a")
    if M09_BENCH.exists():
        results["bench_m09_s10f"] = bench_mod(N6_S10F, M09_BENCH, 61106, "m09", "m09_s10f")
        results["bench_m09_n6_o2"] = bench_mod(N6_O2, M09_BENCH, 61106, "m09", "m09_n6_o2")
        if N7_S10A.exists():
            results["bench_m09_n7_s10a"] = bench_mod(N7_S10A, M09_BENCH, 61106, "m09", "m09_n7_s10a")

    print("=== 2. Smoke & Hot-Bench Parity ===")
    ok_s0, out_s0, ms_s0 = compile_and_run(N6_S10F, "x86-object-fast", SLICE, "slice_o0")
    ok_s2, out_s2, ms_s2 = compile_and_run(N6_S10F, "x86-object", SLICE, "slice_o2")
    ok_h2, out_h2, ms_h2 = compile_and_run(N6_S10F, "x86-object", HIST, "hist_o2")
    ok_h2_b, out_h2_b, ms_h2_b = compile_and_run(N6_O2, "x86-object", HIST, "hist_o2_base")
    results["smoke"] = {
        "slice_o0": {"ok": ok_s0 and out_s0 == "34", "out": out_s0, "ms": ms_s0},
        "slice_o2": {"ok": ok_s2 and out_s2 == "34", "out": out_s2, "ms": ms_s2},
        "histogram_o2_s10f": {"ok": ok_h2 and out_h2 == "3307081914", "out": out_h2, "ms": ms_h2},
        "histogram_o2_base": {"ok": ok_h2_b and out_h2_b == "3307081914", "out": out_h2_b, "ms": ms_h2_b},
    }
    print("  smoke:", results["smoke"])

    print("=== 3. 64/64 native64 -O0 & -O2 ===")
    results["native64_o0"] = run_native64(N6_S10F, "x86-object-fast")
    results["native64_o2"] = run_native64(N6_S10F, "x86-object")

    print("=== 4. 15/15 Observer -O2 ===")
    results["observer_o2"] = run_observer_o2(N6_S10F)

    (OUT_DIR / "results.json").write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    print("Wrote", OUT_DIR / "results.json")


if __name__ == "__main__":
    main()
