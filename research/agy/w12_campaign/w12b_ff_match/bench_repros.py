#!/usr/bin/env python3
"""Benchmark & verify the 4 match-bomb micro-repros on CPU 6."""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
CLI = ROOT / "research/agy/w10_mod_bend/compose_w10/run_w10_cli.mjs"
NODE_BIN = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
W12B = ROOT / "research/agy/w12_campaign/w12b_ff_match"
TMP = Path("/tmp/agy_w12b")

REPROS = [
    "repro_p186ch",
    "repro_w2_asr",
    "repro_w5b_rol16",
    "repro_w5b_cmp_jcc",
]

TRACE_RE = re.compile(r"\[bend-trace\]\s+stage=([A-Za-z0-9_]+)\s+ms=(\d+)ms")
ELAPSED_RE = re.compile(r"\[bend-trace\]\s+stage=([A-Za-z0-9_]+)\s+.*elapsed=(\d+)ms")
TOTAL_RE = re.compile(r"total_ms=(\d+)ms")
SEGS_RE = re.compile(r"segs=(\d+)")


def run_repro(api_path: Path, name: str, mode: str, timeout_s: int = 60, cpu: int = 6) -> dict:
    src = W12B / f"{name}.bend"
    obj = TMP / f"{name}_{mode}.o"
    err = TMP / f"{name}_{mode}.err"
    exe = TMP / f"{name}_{mode}.bin"
    args = ["--trace", mode, str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP]
    cmd = [
        "bash", "-c",
        'ulimit -s 65536 && exec taskset -c "$1" "$2" --stack-size=16384 "$3" "$4" "${@:5}"',
        "_", str(cpu), NODE_BIN, str(CLI), str(api_path), *args,
    ]
    env = os.environ.copy()
    env["NODE_OPTIONS"] = "--max-old-space-size=3072 --max-semi-space-size=32"
    t0 = time.perf_counter()
    timed_out = False
    rc = None
    with obj.open("wb") as fout, err.open("wb") as ferr:
        try:
            r = subprocess.run(cmd, stdout=fout, stderr=ferr, cwd=ROOT, env=env, timeout=timeout_s)
            rc = r.returncode
        except subprocess.TimeoutExpired:
            timed_out = True
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr_txt = err.read_text(encoding="utf-8", errors="replace") if err.exists() else ""
    stages = {}
    elapsed = {}
    segs = None
    total_ms = None
    for line in stderr_txt.splitlines():
        m = TRACE_RE.search(line)
        if m:
            stages[m.group(1)] = int(m.group(2))
        me = ELAPSED_RE.search(line)
        if me:
            elapsed[me.group(1)] = int(me.group(2))
        m2 = TOTAL_RE.search(line)
        if m2:
            total_ms = int(m2.group(1))
        m3 = SEGS_RE.search(line)
        if m3:
            segs = int(m3.group(1))
    if "x187_priv_done" in elapsed and "x187_pub_done" in elapsed:
        stages["x187_pub"] = elapsed["x187_pub_done"] - elapsed["x187_priv_done"]
    if "x187_priv_done" in elapsed:
        pre = sum(stages.get(k, 0) for k in ("read", "prep", "p86_plan", "x198pw_plan"))
        stages["x187_priv"] = max(0, elapsed["x187_priv_done"] - pre)

    run_out = None
    run_rc = None
    if not timed_out and rc == 0 and obj.exists() and obj.stat().st_size > 0:
        lr = subprocess.run(
            ["taskset", "-c", str(cpu), CC, "-no-pie", str(obj), str(AGY_RT), "-lm", "-lpthread", "-o", str(exe)],
            capture_output=True, text=True, timeout=30,
        )
        if lr.returncode == 0:
            rr = subprocess.run(
                ["taskset", "-c", str(cpu), str(exe), "+RTS", "--threads", "1", "--gpu", "off", "-RTS"],
                capture_output=True, text=True, timeout=15,
            )
            run_rc = rr.returncode
            run_out = rr.stdout.strip()
        else:
            run_rc = lr.returncode
            run_out = f"LINK_ERR: {lr.stderr[:200]}"

    return {
        "name": name,
        "mode": mode,
        "rc": rc,
        "timed_out": timed_out,
        "wall_ms": wall_ms,
        "total_ms": total_ms,
        "segs": segs,
        "stages": stages,
        "obj_bytes": obj.stat().st_size if obj.exists() else 0,
        "run_rc": run_rc,
        "run_out": run_out,
        "err_tail": stderr_txt.splitlines()[-5:] if timed_out or rc != 0 else [],
    }


def main() -> None:
    TMP.mkdir(parents=True, exist_ok=True)
    api = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "selfhost/build/agy/wave10_unified/api.mjs"
    mode = sys.argv[2] if len(sys.argv) > 2 else "x86-object"
    timeout_s = int(sys.argv[3]) if len(sys.argv) > 3 else 60
    results = []
    for name in REPROS:
        res = run_repro(api, name, mode, timeout_s=timeout_s)
        results.append(res)
        st = res["stages"]
        print(
            f"{name:18s} {mode:15s} rc={res['rc']} to={res['timed_out']} "
            f"wall={res['wall_ms']:7.1f}ms p86={st.get('p86_plan','-')} "
            f"x198={st.get('x198pw_plan','-')} x187={st.get('x187_pub','-')} "
            f"segs={res['segs']} out={res['run_out']}",
            flush=True,
        )
    if len(sys.argv) > 4:
        Path(sys.argv[4]).write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
