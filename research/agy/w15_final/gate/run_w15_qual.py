#!/usr/bin/env python3
"""W15-GATE Part 1: Full 158/158 Native Qualification + ELF Audit on Native n6_o2.

Runs entirely on native selfhost/build/agy/wave15-native-mod/n6_o2:
  1. 64/64 native64 conformance in x86-object-fast (-O0) and x86-object (-O2)
  2. 15/15 Live-Metadata Observer Gate in x86-object (-O2) and x86-object-fast (-O0)
  3. ELF Section Audit (readelf -SW / -sW) on n6_o2-emitted .o files AND on n6_o2 itself

CPU isolation: strictly pinned to CPUs 0..6 via taskset.
Stack limit: ulimit -s 262144 for every n6_o2 invocation.
Hard timeout: 60s per test/compile/link/exec.
Scratch dir: /tmp/agy_w15_gate/qual/
"""
from __future__ import annotations

import concurrent.futures
import json
import os
import queue
import shutil
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
N6_O2 = ROOT / "selfhost/build/agy/wave15-native-mod/n6_o2"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
QUAL_CAT = ROOT / "selfhost/tests/phase182/qualification-catalog.json"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

OUT_DIR = ROOT / "research/agy/w15_final/gate"
RESULTS_JSON = OUT_DIR / "qual_results.json"
TMP = Path("/tmp/agy_w15_gate/qual")
CPUS = [0, 1, 2, 3, 4, 5, 6]
HARD_TIMEOUT = 60

sys.path.insert(0, str(ROOT / "research/agy/wave3_fuzz"))
import observer_wave2_gate as obs


def run_n6(
    mode: str,
    src: Path,
    out_obj: Path,
    cpu: int,
    timeout: int = HARD_TIMEOUT,
) -> tuple[int, float, str]:
    cmd = [
        "bash",
        "-c",
        'ulimit -s 262144 && exec timeout -k 5 "$1" taskset -c "$2" "$3" "${@:4}"',
        "_",
        str(timeout),
        str(cpu),
        str(N6_O2),
        mode,
        str(src),
        str(BASE_FILE),
        "cache",
        str(BASE_CARRIER),
        BASE_STAMP,
    ]
    t0 = time.perf_counter()
    with out_obj.open("wb") as f:
        r = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, cwd=ROOT, timeout=timeout + 10)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = r.stderr.decode("utf-8", errors="replace")
    return r.returncode, ms, stderr


def run_pinned(
    cmd: list[str],
    cpu: int,
    timeout: int = HARD_TIMEOUT,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["timeout", "-k", "5", str(timeout), "taskset", "-c", str(cpu), *cmd],
        capture_output=True,
        text=True,
        cwd=ROOT,
        env=env,
        timeout=timeout + 10,
    )


def run_single_native64_case(
    idx: int,
    case: dict,
    mode: str,
    work_dir: Path,
    cpu_pool: queue.Queue[int],
) -> dict:
    cpu = cpu_pool.get()
    cid = case["id"]
    name = case["name"]
    src = ROOT / case["source"]["file"]
    exp = case["expect"]
    obj = work_dir / f"{idx:02d}_{name}.o"
    exe = work_dir / f"{idx:02d}_{name}.bin"
    try:
        rc, compile_ms, stderr = run_n6(mode, src, obj, cpu=cpu, timeout=HARD_TIMEOUT)
        obj_bytes = obj.stat().st_size if obj.exists() else 0

        if exp["stage"] != "execute":
            refusal = case.get("refusal", {})
            prefix = refusal.get("prefix", "")
            exact = refusal.get("exact", False)
            if prefix:
                diag_ok = (
                    stderr in (prefix, prefix + "\n")
                    if exact
                    else stderr.startswith(prefix) and bool(stderr[len(prefix) :].strip())
                )
            else:
                diag_ok = True
            ok = (rc == 1) and (obj_bytes == 0) and diag_ok
            return {
                "id": cid,
                "name": name,
                "kind": "refusal",
                "cpu": cpu,
                "status": "pass" if ok else "fail",
                "rc": rc,
                "compile_ms": compile_ms,
                "obj_bytes": obj_bytes,
                "stderr": stderr.strip()[:200],
                "diag_ok": diag_ok,
            }

        if rc != 0 or obj_bytes < 64:
            return {
                "id": cid,
                "name": name,
                "kind": "execute",
                "cpu": cpu,
                "status": "fail",
                "failed_stage": "emit",
                "rc": rc,
                "compile_ms": compile_ms,
                "obj_bytes": obj_bytes,
                "error": stderr.strip()[:300],
            }

        t_lk = time.perf_counter()
        lk = run_pinned(
            [CC, "-O2", "-no-pie", str(obj), str(AGY_RT), "-o", str(exe), "-lm", "-pthread"],
            cpu=cpu,
            timeout=HARD_TIMEOUT,
        )
        link_ms = round((time.perf_counter() - t_lk) * 1000.0, 1)
        if lk.returncode != 0:
            return {
                "id": cid,
                "name": name,
                "kind": "execute",
                "cpu": cpu,
                "status": "fail",
                "failed_stage": "link",
                "compile_ms": compile_ms,
                "link_ms": link_ms,
                "obj_bytes": obj_bytes,
                "error": lk.stderr.strip()[:300],
            }

        t_ex = time.perf_counter()
        ev = run_pinned([str(exe), *RTS_ARGS], cpu=cpu, timeout=HARD_TIMEOUT)
        exec_ms = round((time.perf_counter() - t_ex) * 1000.0, 1)
        ok = (
            ev.returncode == exp["exitCode"]
            and ev.stdout == exp["stdout"]
            and ev.stderr == exp["stderr"]
        )
        res = {
            "id": cid,
            "name": name,
            "kind": "execute",
            "cpu": cpu,
            "status": "pass" if ok else "fail",
            "compile_ms": compile_ms,
            "link_ms": link_ms,
            "exec_ms": exec_ms,
            "obj_bytes": obj_bytes,
        }
        if not ok:
            res["failed_stage"] = "execute"
            res["error"] = (
                f"rc={ev.returncode} exp_rc={exp['exitCode']} "
                f"out={ev.stdout[:80]!r} exp={exp['stdout'][:80]!r} "
                f"err={ev.stderr[:80]!r}"
            )
        return res
    except Exception as e:
        return {
            "id": cid,
            "name": name,
            "kind": "refusal" if exp["stage"] != "execute" else "execute",
            "cpu": cpu,
            "status": "fail",
            "failed_stage": "exception",
            "error": str(e)[:300],
        }
    finally:
        for p in (obj, exe):
            if p.exists():
                try:
                    p.unlink()
                except OSError:
                    pass
        cpu_pool.put(cpu)


def run_native64_mode(mode: str, cases: list[dict]) -> dict:
    print(f"\n=== Native n6_o2 64/64 native64 ({mode}) on CPUs {CPUS} ===", flush=True)
    work_dir = TMP / f"n64_{mode}"
    work_dir.mkdir(parents=True, exist_ok=True)
    cpu_pool: queue.Queue[int] = queue.Queue()
    for c in CPUS:
        cpu_pool.put(c)

    t0 = time.perf_counter()
    rows: list[dict] = [None] * len(cases)  # type: ignore[list-item]
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(CPUS)) as ex:
        futs = {
            ex.submit(run_single_native64_case, i, c, mode, work_dir, cpu_pool): i
            for i, c in enumerate(cases)
        }
        done = 0
        for fut in concurrent.futures.as_completed(futs):
            i = futs[fut]
            r = fut.result()
            rows[i] = r
            done += 1
            if r["status"] != "pass":
                print(
                    f"  [FAIL] ({done:2d}/{len(cases)}) {r['id']} ({r.get('failed_stage', 'refusal')}): {r.get('error', r.get('stderr', ''))}",
                    flush=True,
                )
            elif done % 16 == 0 or done == len(cases):
                print(f"  [PROG] {done:2d}/{len(cases)} completed ({time.perf_counter() - t0:.1f}s)", flush=True)

    wall_s = round(time.perf_counter() - t0, 2)
    passed = sum(1 for r in rows if r["status"] == "pass")
    failed = [r for r in rows if r["status"] != "pass"]
    compile_sum_ms = round(sum(r.get("compile_ms", 0.0) for r in rows), 1)
    print(
        f"  => [{'PASS' if not failed else 'FAIL'}] {mode}: {passed}/{len(cases)} PASS "
        f"(wall={wall_s:.2f}s, compile_sum={compile_sum_ms / 1000.0:.2f}s)",
        flush=True,
    )
    return {
        "mode": mode,
        "passed": passed,
        "total": len(cases),
        "failed_count": len(failed),
        "wall_s": wall_s,
        "compile_sum_ms": compile_sum_ms,
        "failures": failed,
        "cases": rows,
    }


def run_observer_gate_native(modes: list[str]) -> dict:
    print(f"\n=== Native n6_o2 15/15 Live-Metadata Observer Gate ({modes}) on CPUs {CPUS} ===", flush=True)
    obs_dir = TMP / "obs"
    obs_dir.mkdir(parents=True, exist_ok=True)

    hook_o = obs_dir / "hook.o"
    run_pinned(
        [CC, "-std=gnu11", "-O2", "-I", str(obs.RUNTIME_DIR), "-c", str(obs.HOOK_C), "-o", str(hook_o)],
        cpu=CPUS[0],
        timeout=HARD_TIMEOUT,
    )
    if not hook_o.exists():
        raise RuntimeError("Failed to compile observer_gate_hook.c")

    # Compute upstream reference stdout once per probe (pinned to CPU 0)
    probe_srcs: dict[str, Path] = {}
    upstream_out: dict[str, str] = {}
    for name, code in obs.PROBES.items():
        sp = obs_dir / f"{name}.bend"
        sp.write_text(code, encoding="utf-8")
        probe_srcs[name] = sp
        r_up = run_pinned(["bash", str(LOCKED_BUN), str(sp)], cpu=CPUS[0], timeout=HARD_TIMEOUT)
        if r_up.returncode != 0:
            raise RuntimeError(f"Upstream bun failed for {name}: {r_up.stderr[:300]}")
        upstream_out[name] = r_up.stdout
        print(f"  [REF] {name:18s} upstream={r_up.stdout.strip()!r}", flush=True)

    out_by_mode: dict[str, dict] = {}
    for mode in modes:
        print(f"\n  --- Observer mode={mode} ---", flush=True)
        t0 = time.perf_counter()
        cpu_pool: queue.Queue[int] = queue.Queue()
        for c in CPUS:
            cpu_pool.put(c)

        def compile_and_run_probe(name: str) -> dict:
            cpu = cpu_pool.get()
            sp = probe_srcs[name]
            obj = obs_dir / f"{mode}_{name}.o"
            exe = obs_dir / f"{mode}_{name}.exe"
            try:
                rc, compile_ms, stderr = run_n6(mode, sp, obj, cpu=cpu, timeout=HARD_TIMEOUT)
                if rc != 0 or not obj.exists() or obj.stat().st_size < 64:
                    return {
                        "probe": name,
                        "cpu": cpu,
                        "compile_ms": compile_ms,
                        "compile_ok": False,
                        "error": stderr.strip()[:300],
                        "runs": [],
                    }
                lk = run_pinned(
                    [
                        CC,
                        "-no-pie",
                        "-Wl,--wrap=p111_rt_main",
                        "-Wl,--wrap=p125_rt_take1",
                        "-Wl,--wrap=p125_rt_take2",
                        "-Wl,--wrap=p125_rt_take3",
                        "-Wl,--wrap=p125_rt_take4",
                        str(obj),
                        str(hook_o),
                        str(AGY_RT),
                        "-pthread",
                        "-lm",
                        "-o",
                        str(exe),
                    ],
                    cpu=cpu,
                    timeout=HARD_TIMEOUT,
                )
                if lk.returncode != 0:
                    return {
                        "probe": name,
                        "cpu": cpu,
                        "compile_ms": compile_ms,
                        "compile_ok": False,
                        "error": f"link failed: {lk.stderr.strip()[:300]}",
                        "runs": [],
                    }
                runs = []
                for obs_mode in ("normal", "cap-no8", "all-hot"):
                    env = dict(os.environ, OBS_MODE=obs_mode)
                    r = run_pinned([str(exe), *RTS_ARGS], cpu=cpu, timeout=HARD_TIMEOUT, env=env)
                    ok = (
                        r.returncode == 0
                        and r.stdout == upstream_out[name]
                        and "OBSERVER_VIOLATION" not in r.stderr
                        and r.stderr == ""
                    )
                    runs.append(
                        {
                            "obs_mode": obs_mode,
                            "status": "pass" if ok else "fail",
                            "rc": r.returncode,
                            "stdout": r.stdout.strip(),
                            "expected": upstream_out[name].strip(),
                            "stderr": r.stderr.strip()[:200],
                        }
                    )
                return {
                    "probe": name,
                    "cpu": cpu,
                    "compile_ms": compile_ms,
                    "obj_bytes": obj.stat().st_size,
                    "compile_ok": True,
                    "runs": runs,
                }
            finally:
                for p in (obj, exe):
                    if p.exists():
                        try:
                            p.unlink()
                        except OSError:
                            pass
                cpu_pool.put(cpu)

        probe_names = list(obs.PROBES.keys())
        probe_results: dict[str, dict] = {}
        with concurrent.futures.ThreadPoolExecutor(max_workers=len(CPUS)) as ex:
            futs = {ex.submit(compile_and_run_probe, nm): nm for nm in probe_names}
            for fut in concurrent.futures.as_completed(futs):
                nm = futs[fut]
                probe_results[nm] = fut.result()

        ordered = [probe_results[nm] for nm in probe_names]
        passed = 0
        violations = 0
        total = len(probe_names) * 3
        for pr in ordered:
            if not pr["compile_ok"]:
                violations += 3
                print(f"    [FAIL] {pr['probe']:18s} compile/link error: {pr.get('error', '')}", flush=True)
                continue
            for rr in pr["runs"]:
                ok = rr["status"] == "pass"
                if ok:
                    passed += 1
                else:
                    violations += 1
                tag = "PASS" if ok else "FAIL"
                print(
                    f"    [{tag}] {pr['probe']:18s} obs={rr['obs_mode']:8s} out={rr['stdout']!r} err={rr['stderr']!r}",
                    flush=True,
                )
        wall_s = round(time.perf_counter() - t0, 2)
        print(f"  => Observer ({mode}): {passed}/{total} PASS ({violations} violations, wall={wall_s:.2f}s)", flush=True)
        out_by_mode[mode] = {
            "mode": mode,
            "passed": passed,
            "total": total,
            "violations": violations,
            "wall_s": wall_s,
            "probes": ordered,
        }
    return out_by_mode


def parse_readelf_sections(sec_out: str) -> dict[int, dict]:
    sections: dict[int, dict] = {}
    for line in sec_out.splitlines():
        line_s = line.strip()
        if line_s.startswith("["):
            rb = line_s.find("]")
            if rb != -1:
                idx_str = line_s[1:rb].strip()
                if idx_str.isdigit():
                    rest = line_s[rb + 1 :].split()
                    if len(rest) >= 7:
                        sections[int(idx_str)] = {
                            "index": int(idx_str),
                            "name": rest[0],
                            "type": rest[1],
                            "addr_hex": rest[2],
                            "off_hex": rest[3],
                            "size_hex": rest[4],
                            "size_bytes": int(rest[4], 16),
                            "flags": rest[6],
                        }
    return sections


def run_elf_section_audit(modes: list[str]) -> dict:
    print(f"\n=== ELF Section Audit on n6_o2-emitted .o ({SLICE.name}) & n6_o2 binary ===", flush=True)
    audit_dir = TMP / "elf_audit"
    audit_dir.mkdir(parents=True, exist_ok=True)
    audit_by_mode: dict[str, dict] = {}

    for idx, mode in enumerate(modes):
        cpu = CPUS[idx % len(CPUS)]
        obj = audit_dir / f"slice_{mode}.o"
        rc, compile_ms, stderr = run_n6(mode, SLICE, obj, cpu=cpu, timeout=HARD_TIMEOUT)
        if rc != 0 or not obj.exists():
            raise RuntimeError(f"ELF audit compile failed ({mode}): rc={rc} {stderr[:300]}")
        obj_bytes = obj.stat().st_size

        sec_out = subprocess.check_output(["readelf", "-SW", str(obj)], text=True)
        sym_out = subprocess.check_output(["readelf", "-sW", str(obj)], text=True)
        sections = parse_readelf_sections(sec_out)

        wanted = {"p111_cid_hot", "p111_cid_arity", "p111_cid_names_0"}
        symbols: dict[str, dict] = {}
        for line in sym_out.splitlines():
            parts = line.split()
            if len(parts) >= 8 and parts[7] in wanted:
                ndx = int(parts[6]) if parts[6].isdigit() else parts[6]
                sec_info = sections.get(ndx, {}) if isinstance(ndx, int) else {}
                symbols[parts[7]] = {
                    "name": parts[7],
                    "size": int(parts[2], 0),
                    "type": parts[3],
                    "bind": parts[4],
                    "vis": parts[5],
                    "ndx": ndx,
                    "section_name": sec_info.get("name", "?"),
                    "section_flags": sec_info.get("flags", "?"),
                }

        hot_ok = (
            "p111_cid_hot" in symbols
            and symbols["p111_cid_hot"]["section_name"] == ".data"
            and "W" in symbols["p111_cid_hot"]["section_flags"]
            and "A" in symbols["p111_cid_hot"]["section_flags"]
        )
        arity_ok = (
            "p111_cid_arity" in symbols
            and symbols["p111_cid_arity"]["section_name"] == ".rodata"
            and "W" not in symbols["p111_cid_arity"]["section_flags"]
            and "A" in symbols["p111_cid_arity"]["section_flags"]
        )
        names0_ok = (
            "p111_cid_names_0" in symbols
            and symbols["p111_cid_names_0"]["section_name"] == ".rodata"
            and "W" not in symbols["p111_cid_names_0"]["section_flags"]
            and "A" in symbols["p111_cid_names_0"]["section_flags"]
        )
        all_ok = hot_ok and arity_ok and names0_ok
        print(
            f"  [{'PASS' if all_ok else 'FAIL'}] {mode}: obj={obj_bytes} B ({compile_ms} ms) "
            f"hot={symbols.get('p111_cid_hot', {}).get('section_name')}({symbols.get('p111_cid_hot', {}).get('section_flags')}) "
            f"arity={symbols.get('p111_cid_arity', {}).get('section_name')}({symbols.get('p111_cid_arity', {}).get('section_flags')}) "
            f"names_0={symbols.get('p111_cid_names_0', {}).get('section_name')}({symbols.get('p111_cid_names_0', {}).get('section_flags')})",
            flush=True,
        )
        audit_by_mode[mode] = {
            "mode": mode,
            "source": str(SLICE.relative_to(ROOT)),
            "compile_ms": compile_ms,
            "obj_bytes": obj_bytes,
            "pass": all_ok,
            "checks": {
                "p111_cid_hot_in_writable_data": hot_ok,
                "p111_cid_arity_in_rodata": arity_ok,
                "p111_cid_names_0_in_rodata": names0_ok,
            },
            "sections": {str(k): v for k, v in sections.items() if v["name"] in (".text", ".rodata", ".data")},
            "symbols": symbols,
        }
        obj.unlink(missing_ok=True)

    # Also audit n6_o2 binary sections directly
    n6_sec_out = subprocess.check_output(["readelf", "-SW", str(N6_O2)], text=True)
    n6_sections = parse_readelf_sections(n6_sec_out)
    n6_by_name = {v["name"]: v for v in n6_sections.values()}
    text_ok = ".text" in n6_by_name and n6_by_name[".text"]["flags"] == "AX"
    rodata_ok = ".rodata" in n6_by_name and "A" in n6_by_name[".rodata"]["flags"] and "W" not in n6_by_name[".rodata"]["flags"]
    data_ok = ".data" in n6_by_name and "W" in n6_by_name[".data"]["flags"] and "A" in n6_by_name[".data"]["flags"]
    n6_ok = text_ok and rodata_ok and data_ok
    print(
        f"  [{'PASS' if n6_ok else 'FAIL'}] n6_o2 binary: "
        f".text={n6_by_name.get('.text', {}).get('size_bytes', 0):,} B ({n6_by_name.get('.text', {}).get('flags')}) "
        f".rodata={n6_by_name.get('.rodata', {}).get('size_bytes', 0):,} B ({n6_by_name.get('.rodata', {}).get('flags')}) "
        f".data={n6_by_name.get('.data', {}).get('size_bytes', 0):,} B ({n6_by_name.get('.data', {}).get('flags')}) "
        f".bss={n6_by_name.get('.bss', {}).get('size_bytes', 0):,} B ({n6_by_name.get('.bss', {}).get('flags')})",
        flush=True,
    )
    audit_by_mode["n6_o2_binary"] = {
        "binary": str(N6_O2.relative_to(ROOT)),
        "size_bytes": N6_O2.stat().st_size,
        "pass": n6_ok,
        "checks": {
            "text_AX": text_ok,
            "rodata_A_noW": rodata_ok,
            "data_WA": data_ok,
        },
        "sections": {k: n6_by_name[k] for k in (".text", ".rodata", ".data", ".bss") if k in n6_by_name},
    }
    return audit_by_mode


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    if TMP.exists():
        shutil.rmtree(TMP)
    TMP.mkdir(parents=True, exist_ok=True)

    t_all = time.perf_counter()
    cat = json.loads(QUAL_CAT.read_text(encoding="utf-8"))
    cases = cat["cases"]

    results: dict = {
        "compiler": str(N6_O2.relative_to(ROOT)),
        "compiler_bytes": N6_O2.stat().st_size,
        "cpus": CPUS,
        "ulimit_stack_kb": 262144,
        "hard_timeout_s": HARD_TIMEOUT,
        "catalog": str(QUAL_CAT.relative_to(ROOT)),
        "catalog_cases": len(cases),
        "native64": {},
        "observer": {},
        "elf_audit": {},
    }

    try:
        results["native64"]["x86-object-fast"] = run_native64_mode("x86-object-fast", cases)
        results["native64"]["x86-object"] = run_native64_mode("x86-object", cases)
        results["observer"] = run_observer_gate_native(["x86-object", "x86-object-fast"])
        results["elf_audit"] = run_elf_section_audit(["x86-object", "x86-object-fast"])

        results["total_wall_s"] = round(time.perf_counter() - t_all, 2)
        total_passed = (
            results["native64"]["x86-object-fast"]["passed"]
            + results["native64"]["x86-object"]["passed"]
            + results["observer"]["x86-object"]["passed"]
            + results["observer"]["x86-object-fast"]["passed"]
        )
        total_cases = 64 + 64 + 15 + 15
        elf_pass = (
            results["elf_audit"]["x86-object"]["pass"]
            and results["elf_audit"]["x86-object-fast"]["pass"]
            and results["elf_audit"]["n6_o2_binary"]["pass"]
        )
        all_pass = (
            results["native64"]["x86-object-fast"]["passed"] == len(cases)
            and results["native64"]["x86-object"]["passed"] == len(cases)
            and results["observer"]["x86-object"]["passed"] == 15
            and results["observer"]["x86-object"]["violations"] == 0
            and results["observer"]["x86-object-fast"]["passed"] == 15
            and results["observer"]["x86-object-fast"]["violations"] == 0
            and elf_pass
        )
        results["total_passed"] = total_passed
        results["total_cases"] = total_cases
        results["elf_audit_pass"] = elf_pass
        results["all_pass"] = all_pass
        RESULTS_JSON.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
        print(
            f"\n=== W15-GATE QUAL SUMMARY: {total_passed}/{total_cases} PASS, elf_audit={elf_pass}, all_pass={all_pass} (total_wall={results['total_wall_s']:.2f}s) ===",
            flush=True,
        )
    finally:
        if TMP.exists():
            shutil.rmtree(TMP, ignore_errors=True)

    sys.exit(0 if results.get("all_pass") else 1)


if __name__ == "__main__":
    main()
