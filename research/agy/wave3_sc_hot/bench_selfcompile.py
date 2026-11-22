#!/usr/bin/env python3
"""Wave 3 Track S2 native self-build & ablation benchmark:
  Stage 1: n2 -> n_w3_s1 (compiled with Wave 2 codegen, linked with runtime-opt-w3.o)
  Stage 2: n_w3_s1 -> n_w3_s2 (compiled with Wave 3 C1-C4 codegen, linked with both runtime-agy.o and runtime-opt-w3.o)
  Stage 3: n_w3_s2 -> n_w3_s3.o (exact fixed-point check + full self-compile timing!)
  Plus fast 5-case compile-speed & transfer oracle comparison (n2 vs n_w3_s2_oldrt vs n_w3_s2).
"""
import hashlib
import json
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
N2 = ROOT / "selfhost/build/agy/wave2-native-self/n2"
SRC = ROOT / "selfhost/build/agy/wave3_sc_hot/compiler.bend"
BASE = ROOT / "selfhost/dist/base.bend"
OLD_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
NEW_RT = ROOT / "selfhost/build/agy/wave3_sc_hot/runtime-opt-w3.o"
OUT = ROOT / "selfhost/build/agy/wave3_sc_hot/selfbuild"
CATALOG = {c["id"]: c for c in json.loads((ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json").read_text())["cases"]}


def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def emit_native(compiler: Path, src: Path, out_obj: Path, err_log: Path, cpu: int = 2) -> float:
    t0 = time.perf_counter()
    with out_obj.open("wb") as fout, err_log.open("wb") as ferr:
        r = subprocess.run(
            ["taskset", "-c", str(cpu), str(compiler), "+RTS", "--threads", "1", "--gpu", "off", "-RTS",
             "--RTS", "x86-object", str(src), str(BASE), "live", "", ""],
            stdout=fout, stderr=ferr,
        )
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        err = err_log.read_text(errors="replace")[:500]
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
    OUT.mkdir(parents=True, exist_ok=True)
    report = dict(kind="agy-wave3-sc-hot-selfbuild-v1", stages={}, transfer={}, ablation_5case={})

    def save():
        (OUT / "report.json").write_text(json.dumps(report, indent=2) + "\n")

    # Stage 1: n2 -> n_w3_s1
    print("=== Stage 1: n2 -> n_w3_s1 (C3 + runtime-opt-w3.o) ===", flush=True)
    s1_o, s1 = OUT / "s1.o", OUT / "n_w3_s1"
    t1 = emit_native(N2, SRC, s1_o, OUT / "s1.stderr")
    l1 = link_obj(s1_o, NEW_RT, s1)
    s1_sha = sha256_file(s1_o)
    s1_bytes = s1_o.stat().st_size
    s1_o.unlink()
    report["stages"]["s1"] = dict(emitSeconds=round(t1, 3), linkSeconds=round(l1, 3),
                                  objBytes=s1_bytes, objSha256=s1_sha, exeBytes=s1.stat().st_size)
    print(f"S1 built: emit={t1:.2f}s link={l1:.2f}s obj={s1_bytes}B sha={s1_sha[:16]}", flush=True)
    save()

    # Stage 2: n_w3_s1 -> n_w3_s2 (full C1-C4)
    print("=== Stage 2: n_w3_s1 -> n_w3_s2 (full C1-C4 codegen) ===", flush=True)
    s2_o, s2, s2_oldrt = OUT / "s2.o", OUT / "n_w3_s2", OUT / "n_w3_s2_oldrt"
    t2 = emit_native(s1, SRC, s2_o, OUT / "s2.stderr")
    l2 = link_obj(s2_o, NEW_RT, s2)
    link_obj(s2_o, OLD_RT, s2_oldrt)
    s2_sha = sha256_file(s2_o)
    s2_bytes = s2_o.stat().st_size
    s2_o.unlink()
    s1.unlink()
    report["stages"]["s2"] = dict(emitSeconds=round(t2, 3), linkSeconds=round(l2, 3),
                                  objBytes=s2_bytes, objSha256=s2_sha, exeBytes=s2.stat().st_size)
    print(f"S2 built: emit={t2:.2f}s link={l2:.2f}s obj={s2_bytes}B sha={s2_sha[:16]}", flush=True)
    save()

    # Stage 3: n_w3_s2 -> n_w3_s3.o (exact fixed point + full self-compile timing!)
    print("=== Stage 3: n_w3_s2 -> n_w3_s3.o (full Wave 3 self-compile + fixed-point check) ===", flush=True)
    s3_o = OUT / "s3.o"
    t3 = emit_native(s2, SRC, s3_o, OUT / "s3.stderr")
    s3_sha = sha256_file(s3_o)
    s3_bytes = s3_o.stat().st_size
    exact_fp = (s2_sha == s3_sha) and (s2_bytes == s3_bytes)
    s3_o.unlink()
    report["stages"]["s3"] = dict(emitSeconds=round(t3, 3), objBytes=s3_bytes,
                                  objSha256=s3_sha, exactFixedPoint=exact_fp)
    print(f"S3 built: emit={t3:.2f}s obj={s3_bytes}B sha={s3_sha[:16]} EXACT_FIXED_POINT={exact_fp}", flush=True)
    save()
    assert exact_fp, f"S2 != S3: {s2_sha} vs {s3_sha}"

    # 5-case compile-speed ablation (n2 vs n_w3_s2_oldrt vs n_w3_s2) + execution oracle
    print("=== Stage 4: 5-case compile-speed ablation & oracle check ===", flush=True)
    cases = ["raytrace", "mandelbrot", "coverage-bst-64", "test-morning-program", "test-evening-program"]
    for cid in cases:
        c = CATALOG[cid]
        src = ROOT / "selfhost/tools/bench" / c["source"]["file"]
        exp = c["point"]["expectedStdout"].splitlines()
        args = [str(a) for a in c["point"]["runtimeArgs"]]
        obj = OUT / f"{cid}.o"
        exe = OUT / f"{cid}.bin"
        t_n2 = emit_native(N2, src, obj, OUT / f"{cid}.n2.err")
        obj.unlink()
        t_oldrt = emit_native(s2_oldrt, src, obj, OUT / f"{cid}.oldrt.err")
        obj.unlink()
        t_new = emit_native(s2, src, obj, OUT / f"{cid}.new.err")
        link_obj(obj, NEW_RT, exe)
        r = subprocess.run([str(exe), "4", "2", *args], capture_output=True, text=True, check=True)
        ok = (r.stdout.splitlines()[:len(exp)] == exp)
        assert ok, (cid, r.stdout.splitlines()[:len(exp)], exp)
        obj.unlink(); exe.unlink()
        report["ablation_5case"][cid] = dict(
            n2=round(t_n2, 3), w3_oldrt=round(t_oldrt, 3), w3_full=round(t_new, 3),
            speedup_compiler=round(t_n2 / t_oldrt, 3),
            speedup_full=round(t_n2 / t_new, 3),
            oracleOk=ok,
        )
        print(f"  {cid:24s} n2={t_n2:.2f}s  w3_oldrt={t_oldrt:.2f}s ({t_n2/t_oldrt:.2f}x)  w3_full={t_new:.2f}s ({t_n2/t_new:.2f}x)  oracle={ok}", flush=True)
    s2_oldrt.unlink()
    save()
    print("\nALL WAVE 3 TRACK S2 SELF-BUILD & ABLATION STAGES PASSED!", flush=True)


if __name__ == "__main__":
    main()
