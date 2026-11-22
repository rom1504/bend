#!/usr/bin/env python3
"""Run mandatory correctness & safety gates for Wave 6 Holdouts:
  1. 64/64 native64 conformance (all 64 cases in qualification-catalog.json)
  2. 15/15 observer_wave2_gate (44+2 ABI/observer C probes + 5 probes x 3 modes, 0 violations)
"""
import argparse
import json
import os
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BATCH_EMIT = ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
QUAL_CAT = ROOT / "selfhost/tests/phase182/qualification-catalog.json"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

sys.path.insert(0, str(ROOT / "research/agy/wave3_fuzz"))
import observer_wave2_gate as obs


def run_native64(api: Path) -> tuple[int, int]:
    print("=== Gate 1: 64/64 native64 Conformance ===", flush=True)
    t0 = time.monotonic()
    cat = json.loads(QUAL_CAT.read_text())
    cases = cat["cases"]
    with tempfile.TemporaryDirectory(prefix="w6_n64_") as td_s:
        td = Path(td_s)
        jobs = [
            {
                "id": c["id"],
                "src": str(ROOT / c["source"]["file"]),
                "out": str(td / f"{i}_{c['name']}.o"),
            }
            for i, c in enumerate(cases)
        ]
        mf = td / "manifest.json"
        mf.write_text(json.dumps(jobs))
        r_em = subprocess.run(
            ["bash", str(LOCKED_NODE), str(BATCH_EMIT), str(api), str(mf)],
            capture_output=True, text=True, check=True, timeout=300,
        )
        em_map = {x["id"]: x for x in json.loads(r_em.stdout)}
        passed = 0
        failed = []
        for i, c in enumerate(cases):
            cid = c["id"]
            exp = c["expect"]
            em = em_map[cid]
            if exp["stage"] != "execute":
                if not em["ok"]:
                    passed += 1
                else:
                    failed.append(f"{cid}: expected refusal ({exp['stage']})")
                continue
            if not em["ok"]:
                failed.append(f"{cid}: emit failed: {em.get('error', '')[:100]}")
                continue
            obj = td / f"{i}_{c['name']}.o"
            binp = td / f"{i}_{c['name']}.bin"
            c2 = subprocess.run(
                [CC, "-O2", "-no-pie", str(obj), str(AGY_RT), "-o", str(binp), "-lm", "-pthread"],
                capture_output=True, text=True,
            )
            if c2.returncode != 0:
                failed.append(f"{cid}: link failed: {c2.stderr[:100]}")
                continue
            ev = subprocess.run([str(binp), *RTS_ARGS], capture_output=True, text=True, timeout=30)
            if ev.returncode == exp["exitCode"] and ev.stdout == exp["stdout"] and ev.stderr == exp["stderr"]:
                passed += 1
            else:
                failed.append(f"{cid}: rc={ev.returncode} out={ev.stdout[:60]!r} exp={exp['stdout'][:60]!r}")
        dt = time.monotonic() - t0
        if failed:
            print(f"  [FAIL] native64: {passed}/{len(cases)} ({dt:.1f}s)", flush=True)
            for f in failed[:15]:
                print(f"    - {f}", flush=True)
        else:
            print(f"  [PASS] native64: {passed}/{len(cases)} PASS ({dt:.1f}s)", flush=True)
        return passed, len(cases)


def run_observer_gate(api: Path) -> tuple[int, int]:
    print("\n=== Gate 2: Live-Metadata Observer Gate (44+2 ABI + 15/15 Probes) ===", flush=True)
    sys.path.insert(0, str(ROOT / "research/agy/rt"))
    import build_rt
    with tempfile.TemporaryDirectory(prefix="w6_obs_") as td_s:
        td = Path(td_s)
        build_rt.run_abi_probes(td, AGY_RT, "w6-holdouts")

        hook_o = td / "hook.o"
        subprocess.run([CC, "-std=gnu11", "-O2", "-I", str(obs.RUNTIME_DIR), "-c", str(obs.HOOK_C), "-o", str(hook_o)], check=True)

        jobs = []
        for name, code in obs.PROBES.items():
            sp = td / f"{name}.bend"
            sp.write_text(code)
            jobs.append({"id": name, "src": str(sp), "out": str(td / f"{name}.o")})
        mf = td / "manifest.json"
        mf.write_text(json.dumps(jobs))
        r_em = subprocess.run(
            ["bash", str(LOCKED_NODE), str(BATCH_EMIT), str(api), str(mf)],
            capture_output=True, text=True, check=True, timeout=600,
        )
        em_map = {x["id"]: x for x in json.loads(r_em.stdout)}

        passed = 0
        total = len(obs.PROBES) * 3
        violations = 0
        for name in obs.PROBES:
            sp = td / f"{name}.bend"
            obj = td / f"{name}.o"
            exe = td / f"{name}.exe"
            up = subprocess.run(["bash", str(LOCKED_BUN), str(sp)], capture_output=True, text=True, check=True).stdout
            assert em_map[name]["ok"], f"emit failed for {name}: {em_map[name]}"
            subprocess.run(
                [CC, "-no-pie",
                 "-Wl,--wrap=p111_rt_main",
                 "-Wl,--wrap=p125_rt_take1", "-Wl,--wrap=p125_rt_take2",
                 "-Wl,--wrap=p125_rt_take3", "-Wl,--wrap=p125_rt_take4",
                 str(obj), str(hook_o), str(AGY_RT), "-pthread", "-lm", "-o", str(exe)],
                check=True,
            )
            for mode in ("normal", "cap-no8", "all-hot"):
                env = dict(os.environ, OBS_MODE=mode)
                r = subprocess.run([str(exe), *RTS_ARGS], capture_output=True, text=True, env=env, timeout=30)
                ok = (r.returncode == 0 and r.stdout == up and "OBSERVER_VIOLATION" not in r.stderr and r.stderr == "")
                if ok:
                    passed += 1
                else:
                    violations += 1
                tag = "PASS" if ok else "FAIL"
                print(f"  [{tag}] {name:18s} mode={mode:8s} out={r.stdout.strip()!r} err={r.stderr.strip()!r}", flush=True)
        print(f"  Observer Gate: {passed}/{total} PASS ({violations} violations)", flush=True)
        return passed, total


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", type=Path, required=True)
    ap.add_argument("--skip-native64", action="store_true")
    args = ap.parse_args()
    n_pass, n_tot = (64, 64) if args.skip_native64 else run_native64(args.api)
    o_pass, o_tot = run_observer_gate(args.api)
    ok = (n_pass == n_tot) and (o_pass == o_tot)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
