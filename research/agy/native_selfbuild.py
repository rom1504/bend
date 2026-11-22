#!/usr/bin/env python3
"""Native N0 -> N1 -> N2 -> N3 self-build and byte-exact fixed-point verification of unified selfhost/agy compiler."""
import gzip
import hashlib
import json
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
SOURCE = Path(os.environ.get("AGY_SOURCE", str(ROOT / "selfhost/build/agy/unified/compiler.bend")))
BASE = ROOT / "selfhost/dist/base.bend"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
N0_GZ = ROOT / "selfhost/build/agy/bootstrap/p205-compiler.gz"
B1_DIR = Path(os.environ.get("AGY_B1_DIR", str(ROOT / "selfhost/build/agy/unified/full44")))
CATALOG = {c["id"]: c for c in json.loads((ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json").read_text())["cases"]}


def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def emit_native(compiler: Path, src: Path, out_obj: Path, err_log: Path) -> float:
    t0 = time.perf_counter()
    with out_obj.open("wb") as fout, err_log.open("wb") as ferr:
        r = subprocess.run(
            [str(compiler), "+RTS", "--threads", "1", "--gpu", "off", "-RTS",
             "--RTS", "x86-object", str(src), str(BASE), "live", "", ""],
            stdout=fout, stderr=ferr,
        )
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        err = err_log.read_text(errors="replace")[:500]
        raise RuntimeError(f"{compiler.name} failed on {src.name} (rc={r.returncode}): {err}")
    if out_obj.stat().st_size < 64:
        raise RuntimeError(f"{compiler.name} produced empty/tiny object ({out_obj.stat().st_size}B)")
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
    out = Path(sys.argv[1])
    out.mkdir(parents=True, exist_ok=True)
    report = dict(
        kind="agy-native-selfbuild-v1",
        source=dict(file=str(SOURCE), bytes=SOURCE.stat().st_size, sha256=sha256_file(SOURCE)),
        runtime=dict(file=str(RT), bytes=RT.stat().st_size, sha256=sha256_file(RT)),
        base=dict(file=str(BASE), bytes=BASE.stat().st_size, sha256=sha256_file(BASE)),
        stages={},
        transfer={},
        complete=False,
    )
    def save():
        (out / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    save()

    # Decompress N0 (Phase 205 producer)
    n0 = out / "n0"
    n0.write_bytes(gzip.decompress(N0_GZ.read_bytes()))
    os.chmod(n0, 0o755)

    # Stage 1: N0 -> N1
    print("=== Stage 1: N0 (Phase 205) -> N1 (unified) ===", flush=True)
    n1_o, n1 = out / "n1.o", out / "n1"
    t_emit1 = emit_native(n0, SOURCE, n1_o, out / "n1.stderr")
    t_link1 = link_obj(n1_o, RT, n1)
    report["stages"]["n1"] = dict(
        emitSeconds=round(t_emit1, 3), linkSeconds=round(t_link1, 3),
        totalSeconds=round(t_emit1 + t_link1, 3),
        objBytes=n1_o.stat().st_size, objSha256=sha256_file(n1_o),
        exeBytes=n1.stat().st_size, exeSha256=sha256_file(n1),
    )
    print(f"N1 built: emit={t_emit1:.2f}s link={t_link1:.2f}s obj={n1_o.stat().st_size}B sha={report['stages']['n1']['objSha256'][:16]}", flush=True)
    n0.unlink()
    n1_o.unlink()
    save()

    # Stage 2: N1 -> N2
    print("=== Stage 2: N1 -> N2 (self-compiled unified) ===", flush=True)
    n2_o, n2 = out / "n2.o", out / "n2"
    t_emit2 = emit_native(n1, SOURCE, n2_o, out / "n2.stderr")
    t_link2 = link_obj(n2_o, RT, n2)
    report["stages"]["n2"] = dict(
        emitSeconds=round(t_emit2, 3), linkSeconds=round(t_link2, 3),
        totalSeconds=round(t_emit2 + t_link2, 3),
        objBytes=n2_o.stat().st_size, objSha256=sha256_file(n2_o),
        exeBytes=n2.stat().st_size, exeSha256=sha256_file(n2),
    )
    print(f"N2 built: emit={t_emit2:.2f}s link={t_link2:.2f}s obj={n2_o.stat().st_size}B sha={report['stages']['n2']['objSha256'][:16]}", flush=True)
    n1.unlink()
    save()

    # Stage 3: N2 -> N3 (byte-exact fixed-point verification)
    print("=== Stage 3: N2 -> N3 (byte-exact fixed-point check) ===", flush=True)
    n3_o = out / "n3.o"
    t_emit3 = emit_native(n2, SOURCE, n3_o, out / "n3.stderr")
    n3_sha = sha256_file(n3_o)
    n2_sha = report["stages"]["n2"]["objSha256"]
    exact_fp = (n2_sha == n3_sha) and (n2_o.stat().st_size == n3_o.stat().st_size)
    report["stages"]["n3"] = dict(
        emitSeconds=round(t_emit3, 3),
        objBytes=n3_o.stat().st_size, objSha256=n3_sha,
        exactFixedPoint=exact_fp,
    )
    print(f"N3 built: emit={t_emit3:.2f}s obj={n3_o.stat().st_size}B sha={n3_sha[:16]} EXACT_FIXED_POINT={exact_fp}", flush=True)
    n2_o.unlink()
    n3_o.unlink()
    save()
    assert exact_fp, f"N2 != N3: {n2_sha} vs {n3_sha}"

    # Stage 4: Verify N2 emits byte-identical objects to hosted B1 and passes execution oracles
    print("=== Stage 4: N2 vs Hosted B1 transfer check (5 native45 programs) ===", flush=True)
    transfer_cases = ["raytrace", "mandelbrot", "coverage-bst-64", "test-morning-program", "test-evening-program"]
    for cid in transfer_cases:
        c = CATALOG[cid]
        src = ROOT / "selfhost/tools/bench" / c["source"]["file"]
        exp = c["point"]["expectedStdout"].splitlines()
        args = [str(a) for a in c["point"]["runtimeArgs"]]
        obj = out / f"{cid}.n2.o"
        exe = out / f"{cid}.n2"
        dt = emit_native(n2, src, obj, out / f"{cid}.stderr")
        link_obj(obj, RT, exe)
        b1_obj = B1_DIR / f"{cid}.cand.o"
        same_as_b1 = b1_obj.exists() and (sha256_file(obj) == sha256_file(b1_obj))
        r = subprocess.run([str(exe), "4", "2", *args], capture_output=True, text=True, check=True)
        lines = r.stdout.splitlines()
        oracle_ok = (lines[:len(exp)] == exp)
        report["transfer"][cid] = dict(
            emitSeconds=round(dt, 3), objBytes=obj.stat().st_size,
            objSha256=sha256_file(obj), sameAsHostedB1=same_as_b1, oracleOk=oracle_ok,
        )
        print(f"  {cid:24s} emit={dt:.2f}s sameAsB1={same_as_b1} oracleOk={oracle_ok}", flush=True)
        obj.unlink()
        exe.unlink()
        assert oracle_ok, (cid, lines[:len(exp)], exp)
        assert same_as_b1, f"N2 object differed from hosted B1 on {cid}"

    report["complete"] = True
    save()
    print("\nALL NATIVE SELF-BUILD STAGES (N0->N1->N2->N3 + B1==N2 TRANSFER) PASSED!", flush=True)


if __name__ == "__main__":
    main()
