#!/usr/bin/env python3
"""Run 1-pass --trace-slow 500 sweep on m01, m04 (-O0 and -O2), and m05 in parallel
on CPUs 0, 1, 2, 3 using pure-Bend compiled /tmp/agy_p5_trace_slow/api_ts.mjs.
"""
from __future__ import annotations

import concurrent.futures
import json
import os
import re
import subprocess
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
K12_DIR = ROOT / "research/agy/w10_mod_bend/k12_wave10"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
IFACE_DIR = Path("/tmp/agy_k12_iface_cache")
TMP = Path("/tmp/agy_p5_trace_slow")
SRC_DIR = TMP / "src"
API_TS = TMP / "api_ts.mjs"
CLI = ROOT / "research/agy/w10_mod_bend/compose_w10/run_w10_cli.mjs"
NODE_BIN = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"

TMPL_1ARG = {
    "kc", "f_choose", "nt_choose", "nt_count_go", "nt_reverse",
    "p151_choose", "nt_count", "nt_append",
}
TMPL_CUSTOM = {
    "p134v_list": "p134v_list(U32, U32.is_eq)",
}

FID_BASES = {"m01": 5120, "m04": 20480, "m05": 25600}
PREV_IFACE = {"m01": "m00", "m04": "m03", "m05": "m04"}

SLOW_RE = re.compile(r"\[bend-slow\]\s+stage=([A-Za-z0-9_]+)\s+fn=([^\s]+)\s+ms=(\d+)")
ENTER_RE = re.compile(r"\[bend-enter\]\s+stage=([A-Za-z0-9_]+)\s+idx=(\d+)\s+fn=([^\s]+)")
TRACE_STAGE_RE = re.compile(r"\[bend-trace\]\s+stage=([A-Za-z0-9_]+)\s+ms=(\d+)ms")
TRACE_TOTAL_RE = re.compile(r"total_ms=(\d+)ms")


def parse_p130_stamp(path: Path) -> str:
    txt = path.read_text(encoding="utf-8")
    lo = ord(txt[0]) - 65536
    hi = ord(txt[1]) - 65536
    slen = lo + hi * 65536
    return txt[2 : 2 + slen]


def prepare_mod_sources(targets: list[str]) -> dict[str, Path]:
    SRC_DIR.mkdir(parents=True, exist_ok=True)
    mod_names = [f"m{i:02d}" for i in range(12)]
    mod_texts = [(K12_DIR / f"{m}.bend").read_text(encoding="utf-8") for m in mod_names]
    out: dict[str, Path] = {}
    for m in targets:
        i = int(m[1:])
        defs = re.findall(r"^def\s+([A-Za-z0-9_.\$]+)\s*[\(:]", mod_texts[i], re.M)
        later = "\n".join(mod_texts[i + 1 :])
        later_idents = set(re.findall(r"[A-Za-z_][A-Za-z0-9_.\$]*", later))
        exps = [d for d in defs if d in later_idents]
        lines = ["\n@unsafe\ndef main() -> U32:"]
        for d in exps:
            if d in TMPL_CUSTOM:
                lines.append(f"  _ = {TMPL_CUSTOM[d]}")
            elif d in TMPL_1ARG:
                lines.append(f"  _ = {d}(U32)")
            else:
                lines.append(f"  _ = {d}")
        lines.append("  0\n")
        full = "import Base\n" + mod_texts[i] + "\n".join(lines)
        p = SRC_DIR / f"{m}_exp.bend"
        p.write_text(full, encoding="utf-8")
        out[m] = p
    return out


def run_one(mod: str, src_path: Path, mode: str, thresh_ms: int, timeout_s: int, cpu: int) -> dict:
    prev = PREV_IFACE[mod]
    carrier = IFACE_DIR / f"{prev}.p130"
    stamp = parse_p130_stamp(carrier)
    fid_base = FID_BASES[mod]
    args = [
        "--trace-slow", str(thresh_ms),
        mode, str(src_path), str(BASE_FILE), "cache", str(carrier), stamp,
        str(fid_base), mod,
    ]
    cmd = [
        "bash", "-c",
        'ulimit -s 65536 && exec taskset -c "$1" "$2" --stack-size=16384 "$3" "$4" "${@:5}"',
        "_", str(cpu), NODE_BIN, str(CLI), str(API_TS), *args,
    ]
    env = os.environ.copy()
    env["NODE_OPTIONS"] = "--max-old-space-size=3072 --max-semi-space-size=32"
    print(f"[cpu {cpu}] START {mod} mode={mode} --trace-slow {thresh_ms} (timeout={timeout_s}s)", flush=True)
    t0 = time.perf_counter()
    timed_out = False
    rc = None
    stderr_text = ""
    try:
        with open("/dev/null", "wb") as devnull:
            r = subprocess.run(cmd, stdout=devnull, stderr=subprocess.PIPE, cwd=ROOT, env=env, timeout=timeout_s)
        rc = r.returncode
        stderr_text = r.stderr.decode("utf-8", errors="replace")
    except subprocess.TimeoutExpired as e:
        timed_out = True
        stderr_text = (e.stderr or b"").decode("utf-8", errors="replace") if isinstance(e.stderr, bytes) else (e.stderr or "")
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)

    slow_events = []
    stages = {}
    last_enter = None
    trace_lines = []
    for line in stderr_text.splitlines():
        if line.startswith("[bend-trace]"):
            trace_lines.append(line)
            m = TRACE_STAGE_RE.search(line)
            if m:
                stages[m.group(1)] = int(m.group(2))
            m2 = TRACE_TOTAL_RE.search(line)
            if m2:
                stages["total_ms"] = int(m2.group(1))
        elif line.startswith("[bend-slow]"):
            m = SLOW_RE.search(line)
            if m:
                slow_events.append({
                    "module": mod,
                    "mode": mode,
                    "stage": m.group(1),
                    "fn": m.group(2),
                    "ms": int(m.group(3)),
                })
        elif line.startswith("[bend-enter]"):
            m = ENTER_RE.search(line)
            if m:
                last_enter = {"stage": m.group(1), "idx": int(m.group(2)), "fn": m.group(3)}

    print(
        f"[cpu {cpu}] DONE {mod} mode={mode} rc={rc} timed_out={timed_out} "
        f"wall={wall_ms}ms slow_hits={len(slow_events)} last_enter={last_enter}",
        flush=True,
    )
    for tl in trace_lines:
        print(f"    [{mod}/{mode}] {tl}", flush=True)
    for ev in sorted(slow_events, key=lambda x: -x["ms"])[:15]:
        print(f"    [{mod}/{mode}] SLOW: stage={ev['stage']:<10} fn={ev['fn']:<36} ms={ev['ms']}", flush=True)

    return {
        "module": mod,
        "mode": mode,
        "thresh_ms": thresh_ms,
        "timeout_s": timeout_s,
        "cpu": cpu,
        "rc": rc,
        "timed_out": timed_out,
        "wall_ms": wall_ms,
        "stages": stages,
        "trace_lines": trace_lines,
        "slow_events": slow_events,
        "last_enter": last_enter,
    }


def main() -> None:
    targets = ["m01", "m04", "m05"]
    src_paths = prepare_mod_sources(targets)

    jobs = [
        ("m01", src_paths["m01"], "x86-module-fast", 500, 300, 0),
        ("m04", src_paths["m04"], "x86-module-fast", 500, 300, 1),
        ("m05", src_paths["m05"], "x86-module-fast", 500, 300, 2),
        ("m04", src_paths["m04"], "x86-module", 500, 120, 3),
    ]
    runs = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as ex:
        futs = [ex.submit(run_one, *j) for j in jobs]
        for fut in futs:
            runs.append(fut.result())

    # If m04 -O2 timed out, run --trace-slow 0 (live-enter) with 120s timeout on CPU 0
    r_o2 = [r for r in runs if r["module"] == "m04" and r["mode"] == "x86-module"][0]
    if r_o2["timed_out"]:
        print("\n>>> m04 -O2 timed out at 120s! Running --trace-slow 0 to pinpoint exact hanging fn...", flush=True)
        runs.append(run_one("m04", src_paths["m04"], "x86-module", 0, 120, 0))

    out_path = TMP / "sweep_results.json"
    out_path.write_text(json.dumps({"runs": runs}, indent=2) + "\n", encoding="utf-8")
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
