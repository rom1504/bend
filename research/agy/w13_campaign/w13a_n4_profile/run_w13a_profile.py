#!/usr/bin/env python3
"""W13-A: Zero-Loss Native CPU Re-Profile of n4_o2 Self-Compiling m11 & m05 on CPU 6."""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
N4_O2 = ROOT / "selfhost/build/agy/wave11-native-mod/n4_o2"
K13_DIR = ROOT / "research/agy/w10_mod_bend/k13_wave11"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
IFACE_CACHE = Path("/tmp/agy_k13_w11_cache/iface")
BUILD_SAMPLER = ROOT / "selfhost/tools/profiler/build-sampler.py"
ANALYZE_PY = ROOT / "selfhost/tools/profiler/analyze.py"

OUT_DIR = ROOT / "research/agy/w13_campaign/w13a_n4_profile"
TMP = Path("/tmp/agy_w13a")
SAMPLER_DIR = TMP / "sampler"
SRC_DIR = TMP / "src"
OBJ_DIR = TMP / "obj"
PROF_DIR = TMP / "prof"
LOG_DIR = TMP / "logs"

CPU = 6
MOD_NAMES = ["m00a", "m00b", "m01", "m02", "m03", "m04", "m05", "m06", "m07", "m08", "m09", "m10", "m11"]
FID_BASES = {"m05": 27540, "m11": 61351}

TMPL_1ARG = {
    "kc", "f_choose", "nt_choose", "nt_count_go", "nt_reverse",
    "p151_choose", "nt_count", "nt_append",
}
TMPL_CUSTOM = {
    "p134v_list": "p134v_list(U32, U32.is_eq)",
}


def parse_p130_stamp(path: Path) -> str:
    txt = path.read_text(encoding="utf-8")
    lo = ord(txt[0]) - 65536
    hi = ord(txt[1]) - 65536
    slen = lo + hi * 65536
    return txt[2 : 2 + slen]


def prepare_target_sources() -> dict[str, Path]:
    SRC_DIR.mkdir(parents=True, exist_ok=True)
    mod_texts = [(K13_DIR / f"{m}.bend").read_text(encoding="utf-8") for m in MOD_NAMES]
    src_paths: dict[str, Path] = {}
    for target in ("m05", "m11"):
        i = MOD_NAMES.index(target)
        prefix = "import Base\n"
        if target == "m11":
            full = prefix + mod_texts[i]
        else:
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
            full = prefix + mod_texts[i] + "\n".join(lines)
        p = SRC_DIR / f"{target}_exp.bend"
        p.write_text(full, encoding="utf-8")
        src_paths[target] = p
    return src_paths


def parse_trace_stages(stderr_text: str) -> dict[str, float]:
    stages: dict[str, float] = {}
    for line in stderr_text.splitlines():
        m = re.search(r"stage=([A-Za-z0-9_]+)\s+ms=([0-9.]+)", line)
        if m:
            stages[m.group(1)] = float(m.group(2))
    return stages


def build_sampler() -> Path:
    so = SAMPLER_DIR / "sampler.so"
    if so.exists():
        return so
    subprocess.run(
        [sys.executable, str(BUILD_SAMPLER), "--out", str(SAMPLER_DIR), "--all-threads"],
        check=True,
        cwd=ROOT,
    )
    assert so.exists()
    return so


def profile_module(
    mod: str,
    src_path: Path,
    in_carrier: Path,
    sampler_so: Path,
    period_us: int,
) -> dict:
    in_stamp = parse_p130_stamp(in_carrier)
    out_o = OBJ_DIR / f"{mod}.o"
    err_f = LOG_DIR / f"{mod}.err"
    samples_f = PROF_DIR / f"{mod}.samples"
    analysis_f = PROF_DIR / f"{mod}.analysis.json"
    for f in (out_o, err_f, samples_f, analysis_f):
        if f.exists():
            f.unlink()

    args = [
        "--trace", "x86-module-fast",
        str(src_path), str(BASE_FILE), "cache",
        str(in_carrier), in_stamp, str(FID_BASES[mod]), mod,
    ]
    # Pin CPU FIRST, then inside bash set ulimit -s 262144 and LD_PRELOAD only for exec n4_o2
    cmd = [
        "timeout", "180",
        "taskset", "-c", str(CPU),
        "bash", "-c",
        'ulimit -s 262144 && LD_PRELOAD="$1" BEND_SAMPLE_OUT="$2" BEND_SAMPLE_PERIOD_US="$3" exec "$4" "${@:5}"',
        "_",
        str(sampler_so),
        str(samples_f),
        str(period_us),
        str(N4_O2),
        *args,
    ]
    print(f"[W13-A] Profiling {mod} on CPU {CPU} (period_us={period_us})...", flush=True)
    t0 = time.perf_counter()
    with out_o.open("wb") as of, err_f.open("wb") as ef:
        r = subprocess.run(cmd, stdout=of, stderr=ef, cwd=ROOT)
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr_text = err_f.read_text(encoding="utf-8", errors="replace")
    if r.returncode != 0:
        raise RuntimeError(f"{mod} failed rc={r.returncode}:\n{stderr_text[-1200:]}")
    stages = parse_trace_stages(stderr_text)
    print(f"[W13-A] {mod} DONE in {wall_ms} ms | obj={out_o.stat().st_size:,} B | stages={stages}", flush=True)

    # Analyze with analyze.py
    subprocess.run(
        [
            sys.executable, str(ANALYZE_PY),
            "--samples", str(samples_f),
            "--binary", str(N4_O2),
            "--output", str(analysis_f),
            "--clean-cpu-seconds", str(round(wall_ms / 1000.0, 4)),
        ],
        check=True,
        cwd=ROOT,
        stdout=subprocess.DEVNULL,
    )
    analysis = json.loads(analysis_f.read_text(encoding="utf-8"))
    q = analysis["quality"]
    print(
        f"[W13-A] {mod} analysis: samples={analysis['header']['samples']:,} "
        f"dropped={analysis['header']['dropped']} overruns={analysis['header']['overruns']} "
        f"zeroLoss={analysis['zeroLoss']} usable={analysis['usable']} "
        f"resolved={q['resolved_sample_fraction']*100:.2f}%",
        flush=True,
    )
    return {
        "module": mod,
        "cpu": CPU,
        "period_us": period_us,
        "wall_ms": wall_ms,
        "obj_bytes": out_o.stat().st_size,
        "trace_stages_ms": stages,
        "trace_lines": [ln for ln in stderr_text.splitlines() if ln.strip()],
        "header": analysis["header"],
        "quality": analysis["quality"],
        "usable": analysis["usable"],
        "zeroLoss": analysis["zeroLoss"],
        "groups": analysis["groups"],
        "categories": analysis["categories"],
        "libraries": analysis["libraries"],
        "top_50_functions": analysis["top_functions"][:50],
    }


def main() -> None:
    for d in (TMP, OBJ_DIR, PROF_DIR, LOG_DIR, OUT_DIR):
        d.mkdir(parents=True, exist_ok=True)
    sampler_so = build_sampler()
    src_paths = prepare_target_sources()

    m11_res = profile_module(
        "m11", src_paths["m11"], IFACE_CACHE / "m10.p130", sampler_so, period_us=2500
    )
    m05_res = profile_module(
        "m05", src_paths["m05"], IFACE_CACHE / "m04.p130", sampler_so, period_us=8000
    )

    out = {
        "binary": str(N4_O2),
        "cpu": CPU,
        "m11": m11_res,
        "m05": m05_res,
    }
    (OUT_DIR / "profile_raw.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
    print(f"[W13-A] Wrote {OUT_DIR / 'profile_raw.json'}", flush=True)


if __name__ == "__main__":
    main()
