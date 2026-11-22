#!/usr/bin/env python3
"""Wave 5 Native Self-Compilation (N0 -> N1 -> N2 -> N3) & Byte-Exact Fixed-Point Verification.

Stages:
  1. N0 (Wave 2 native n2) -> N1 (Wave 5 Final compiler.bend)
  2. N1 -> N2 (Wave 5 native self-compile, pinned CPU 2, apples-to-apples 'live' mode vs Wave 2 512.4s)
  3. N2 -> N3 (Wave 5 native self-compile, pinned CPU 2, 'live' mode -> checks SHA256(n2.o) == SHA256(n3.o))
  4. Native N2 vs Hosted api.mjs byte-exact transfer + compile-speed comparison on 6 diverse programs.
"""
import argparse
import hashlib
import json
import os
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
DEFAULT_SOURCE = ROOT / "selfhost/build/agy/wave5c_trimmed/compiler.bend"
DEFAULT_HOSTED_API = ROOT / "selfhost/build/agy/wave5c_trimmed/api.mjs"
BASE = ROOT / "selfhost/dist/base.bend"
CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP_PATH = "/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend"
STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
N0_BIN = ROOT / "selfhost/build/agy/wave2-native-self/n2"
OUT_DIR = ROOT / "selfhost/build/agy/wave5-native-self"


def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def emit_native(compiler: Path, src: Path, out_obj: Path, err_log: Path, mode: str = "live", cpu: int = 2) -> float:
    if mode == "cache":
        args = ["x86-object", str(src), BASE_STAMP_PATH, "cache", str(CARRIER), STAMP]
    else:
        args = ["x86-object", str(src), str(BASE), "live", "", ""]
    cmd = ["bash", str(ROOT / "research/agy/locked_native.sh"), "taskset", "-c", str(cpu), str(compiler), "+RTS", "--threads", "1", "--gpu", "off", "-RTS", "--RTS", *args]
    t0 = time.perf_counter()
    with out_obj.open("wb") as fout, err_log.open("wb") as ferr:
        r = subprocess.run(cmd, stdout=fout, stderr=ferr)
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        err = err_log.read_text(errors="replace")[:600]
        raise RuntimeError(f"{compiler.name} failed on {src.name} (rc={r.returncode}): {err}")
    if out_obj.stat().st_size < 64:
        raise RuntimeError(f"{compiler.name} produced tiny object ({out_obj.stat().st_size}B)")
    return dt


def link_obj(obj: Path, rt: Path, exe: Path) -> float:
    t0 = time.perf_counter()
    r = subprocess.run([CC, "-no-pie", str(obj), str(rt), "-pthread", "-lm", "-o", str(exe)],
                       capture_output=True, text=True)
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        raise RuntimeError(f"link failed for {obj.name}: {r.stderr[:400]}")
    return dt


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    ap.add_argument("--api", type=Path, default=DEFAULT_HOSTED_API)
    ap.add_argument("--out-dir", type=Path, default=OUT_DIR)
    ap.add_argument("--cpu", type=int, default=2)
    args = ap.parse_args()
    SOURCE = args.source.resolve()
    HOSTED_API = args.api.resolve()
    out_dir = args.out_dir.resolve()
    cpu = args.cpu

    out_dir.mkdir(parents=True, exist_ok=True)
    report = dict(
        kind="agy-wave5-native-selfbuild-v1",
        source=dict(file=str(SOURCE), bytes=SOURCE.stat().st_size, sha256=sha256_file(SOURCE)),
        runtime=dict(file=str(RT), bytes=RT.stat().st_size, sha256=sha256_file(RT)),
        n0=str(N0_BIN),
        stages={},
        native_6prog={},
        complete=False,
    )
    def save():
        (out_dir / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    save()

    # Stage 1: N0 (Wave 2 native n2) -> N1 (Wave 5)
    print(f"=== Stage 1: N0 (Wave 2 n2) -> N1 (Wave 5, {SOURCE.stat().st_size} B) ===", flush=True)
    n1_o, n1 = out_dir / "n1.o", out_dir / "n1"
    t1 = emit_native(N0_BIN, SOURCE, n1_o, out_dir / "n1.stderr", mode="live", cpu=cpu)
    l1 = link_obj(n1_o, RT, n1)
    report["stages"]["n1"] = dict(
        emitSeconds=round(t1, 3), linkSeconds=round(l1, 3), totalSeconds=round(t1 + l1, 3),
        objBytes=n1_o.stat().st_size, objSha256=sha256_file(n1_o),
        exeBytes=n1.stat().st_size, exeSha256=sha256_file(n1),
    )
    print(f"N1 built: emit={t1:.2f}s link={l1:.2f}s obj={n1_o.stat().st_size}B sha={report['stages']['n1']['objSha256'][:16]}", flush=True)
    n1_o.unlink()
    save()

    # Stage 2: N1 -> N2 (Wave 5 native self-compile!)
    print(f"=== Stage 2: N1 (Wave 5) -> N2 (Wave 5 self-compiled, 'live' mode, CPU {cpu}) ===", flush=True)
    n2_o, n2 = out_dir / "n2.o", out_dir / "n2"
    t2 = emit_native(n1, SOURCE, n2_o, out_dir / "n2.stderr", mode="live", cpu=cpu)
    l2 = link_obj(n2_o, RT, n2)
    n2_sha = sha256_file(n2_o)
    n2_bytes = n2_o.stat().st_size
    report["stages"]["n2"] = dict(
        emitSeconds=round(t2, 3), linkSeconds=round(l2, 3), totalSeconds=round(t2 + l2, 3),
        objBytes=n2_bytes, objSha256=n2_sha,
        exeBytes=n2.stat().st_size, exeSha256=sha256_file(n2),
        speedupVsWave2=round(512.415 / t2, 3),
    )
    print(f"N2 built: emit={t2:.2f}s ({512.415/t2:.2f}x vs Wave 2 512.4s!) link={l2:.2f}s obj={n2_bytes}B sha={n2_sha[:16]}", flush=True)
    n1.unlink()
    save()

    # Stage 3: N2 -> N3 (Exact fixed-point verification!)
    print(f"=== Stage 3: N2 (Wave 5) -> N3 (Exact Fixed-Point Check, 'live' mode, CPU {cpu}) ===", flush=True)
    n3_o = out_dir / "n3.o"
    t3 = emit_native(n2, SOURCE, n3_o, out_dir / "n3.stderr", mode="live", cpu=cpu)
    n3_sha = sha256_file(n3_o)
    n3_bytes = n3_o.stat().st_size
    exact_fp = (n2_sha == n3_sha) and (n2_bytes == n3_bytes)
    report["stages"]["n3"] = dict(
        emitSeconds=round(t3, 3),
        objBytes=n3_bytes, objSha256=n3_sha,
        exactFixedPoint=exact_fp,
        speedupVsWave2=round(496.855 / t3, 3),
    )
    print(f"N3 built: emit={t3:.2f}s ({496.855/t3:.2f}x vs Wave 2 496.9s!) obj={n3_bytes}B sha={n3_sha[:16]} EXACT_FIXED_POINT={exact_fp}", flush=True)
    n2_o.unlink()
    n3_o.unlink()
    save()
    assert exact_fp, f"FIXED POINT MISMATCH: N2={n2_sha} vs N3={n3_sha}"

    # Stage 4: Native N2 vs Hosted api.mjs on 5 diverse programs (live mode, CPU 2)
    print("\n=== Stage 4: Native N2 ('live' mode) vs Hosted api.mjs (5 diverse programs) ===", flush=True)
    cases = [
        ("lexer", ROOT / "selfhost/tests/consolidation/native-broad/lexer.bend"),
        ("raytrace", ROOT / "selfhost/tests/consolidation/native-broad/raytrace.bend"),
        ("histogram", ROOT / "research/agy/wave4_bench/inputs/upstream/histogram/main.bend"),
        ("gameoflife", ROOT / "research/agy/wave4_bench/inputs/upstream/gameoflife/main.bend"),
        ("nbody", ROOT / "research/agy/wave4_bench/inputs/upstream/nbody/main.bend"),
    ]
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        # Emit hosted reference .o
        jobs = [{"id": name, "src": str(p), "out": str(td / f"{name}.js.o")} for name, p in cases]
        jf = td / "jobs.json"; jf.write_text(json.dumps(jobs))
        subprocess.run(["bash", str(ROOT / "research/agy/locked_node.sh"), str(ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"), str(HOSTED_API), str(jf)], check=True, capture_output=True)
        tot_native = 0.0
        for name, p in cases:
            no = td / f"{name}.n2.o"
            dt = emit_native(n2, p, no, td / f"{name}.err", mode="live", cpu=cpu)
            tot_native += dt
            n_sha = sha256_file(no)
            j_sha = sha256_file(td / f"{name}.js.o")
            exact = (n_sha == j_sha)
            report["native_6prog"][name] = dict(nativeLiveSeconds=round(dt, 3), bytes=no.stat().st_size, exactMatchHosted=exact)
            print(f"  {name:12s}: native(live)={dt:6.2f}s  bytes={no.stat().st_size:7d}  native==hosted: {exact}", flush=True)
        print(f"  TOTAL (5 programs, native live incl. base.bend): {tot_native:.2f}s", flush=True)

    report["complete"] = True
    save()
    print("\nWAVE 5 NATIVE SELF-COMPILATION (N0->N1->N2->N3 EXACT FIXED-POINT) COMPLETE!", flush=True)


if __name__ == "__main__":
    main()
