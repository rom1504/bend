#!/usr/bin/env python3
"""Run mandatory correctness & safety gates for Wave 5B Track W5B-C3:
  1. 19/19 focused19 conformance on wave5b_c3/api.mjs (via batch emit)
  2. 15/15 observer_wave2_gate (44+2 ABI + 5 probes x 3 modes: normal, cap-no8, all-hot, 0 violations)
"""
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BATCH_EMIT = ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"
W5B_API = ROOT / "selfhost/build/agy/wave5b_c3/api.mjs"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
QUAL_CAT = ROOT / "selfhost/tests/phase182/qualification-catalog.json"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

# Reuse PROBES and ABI probe from observer_wave2_gate.py
sys.path.insert(0, str(ROOT / "research/agy/wave3_fuzz"))
import observer_wave2_gate as obs


def run_focused19(api: Path) -> tuple[int, int]:
    print("=== Gate 1: focused19 Conformance ===", flush=True)
    cat = json.loads(QUAL_CAT.read_text())
    focused = [c for c in cat["cases"] if c.get("suite") == "focused19" or "focused19" in c.get("suites", [])]
    if not focused:
        focused = cat["cases"][:19]
    with tempfile.TemporaryDirectory(prefix="w5b_f19_") as td_s:
        td = Path(td_s)
        jobs = []
        for c in focused:
            jobs.append({
                "id": c["id"],
                "src": str(ROOT / c["source"]["file"]),
                "out": str(td / f"{c['name']}.o"),
            })
        mf = td / "manifest.json"
        mf.write_text(json.dumps(jobs))
        r_em = subprocess.run(
            ["bash", str(LOCKED_NODE), str(BATCH_EMIT), str(api), str(mf)],
            capture_output=True, text=True, check=True, timeout=180,
        )
        em_map = {x["id"]: x for x in json.loads(r_em.stdout)}
        passed = 0
        failed = []
        for c in focused:
            cid = c["id"]
            exp = c["expect"]
            em = em_map[cid]
            if exp["stage"] != "execute":
                if not em["ok"]:
                    passed += 1
                else:
                    failed.append(f"{cid}: expected refusal")
                continue
            if not em["ok"]:
                failed.append(f"{cid}: emit failed: {em.get('error', '')[:100]}")
                continue
            obj = td / f"{c['name']}.o"
            binp = td / f"{c['name']}.bin"
            c2 = subprocess.run([CC, "-O2", "-no-pie", str(obj), str(AGY_RT), "-o", str(binp), "-lm", "-pthread"], capture_output=True, text=True)
            if c2.returncode != 0:
                failed.append(f"{cid}: link failed: {c2.stderr[:100]}")
                continue
            ev = subprocess.run([str(binp), *RTS_ARGS], capture_output=True, text=True, timeout=30)
            if ev.returncode == exp["exitCode"] and ev.stdout == exp["stdout"] and ev.stderr == exp["stderr"]:
                passed += 1
            else:
                failed.append(f"{cid}: rc={ev.returncode} out={ev.stdout!r} exp={exp['stdout']!r}")
        if failed:
            print(f"  [FAIL] focused19: {passed}/{len(focused)} ({failed})", flush=True)
        else:
            print(f"  [PASS] focused19: {passed}/{len(focused)} PASS", flush=True)
        return passed, len(focused)


def run_observer_gate(api: Path) -> tuple[int, int]:
    print("\n=== Gate 2: Live-Metadata Observer Gate (44+2 ABI + 15/15 Probes) ===", flush=True)
    with tempfile.TemporaryDirectory(prefix="w5b_obs_") as td_s:
        td = Path(td_s)
        # 1. ABI + observer C probes (separate binaries, matching observer_wave2_gate.py)
        abi_bin = td / "abi_probe"
        subprocess.run(
            [CC, "-O2", "-no-pie", "-I", str(obs.RUNTIME_DIR),
             str(obs.RUNTIME_DIR / "abi-contract.c"),
             str(AGY_RT), "-pthread", "-lm", "-o", str(abi_bin)],
            check=True, capture_output=True,
        )
        r_abi = subprocess.run([str(abi_bin)], capture_output=True, text=True, check=True)
        obs_bin = td / "obs_probe"
        subprocess.run(
            [CC, "-O2", "-no-pie", "-I", str(obs.RUNTIME_DIR),
             str(obs.RUNTIME_DIR / "observer.c"),
             str(AGY_RT), "-pthread", "-lm", "-o", str(obs_bin)],
            check=True, capture_output=True,
        )
        r_obs = subprocess.run([str(obs_bin)], capture_output=True, text=True, check=True)
        print(f"  [PASS] ABI+observer probes: abi={r_abi.stdout.strip()} | obs={r_obs.stdout.strip()}", flush=True)

        # 2. Build hook
        hook_o = td / "hook.o"
        subprocess.run([CC, "-O2", "-c", str(obs.HOOK_C), "-o", str(hook_o)], check=True)

        # 3. Emit all probes with wave5b_c3/api.mjs
        jobs = []
        for name, code in obs.PROBES.items():
            sp = td / f"{name}.bend"
            sp.write_text(code)
            jobs.append({"id": name, "src": str(sp), "out": str(td / f"{name}.o")})
        mf = td / "manifest.json"
        mf.write_text(json.dumps(jobs))
        r_em = subprocess.run(
            ["bash", str(LOCKED_NODE), str(BATCH_EMIT), str(api), str(mf)],
            capture_output=True, text=True, check=True, timeout=180,
        )
        em_map = {x["id"]: x for x in json.loads(r_em.stdout)}

        passed = 0
        total = len(obs.PROBES) * 3
        violations = 0
        for name in obs.PROBES:
            sp = td / f"{name}.bend"
            obj = td / f"{name}.o"
            exe = td / f"{name}.exe"
            up = subprocess.run([str(BUN), str(ROOT / "bend2/main.ts"), str(sp)], capture_output=True, text=True, check=True).stdout
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
    f_pass, f_tot = run_focused19(W5B_API)
    o_pass, o_tot = run_observer_gate(W5B_API)
    ok = (f_pass == f_tot) and (o_pass == o_tot)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
