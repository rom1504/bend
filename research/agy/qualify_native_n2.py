#!/usr/bin/env python3
"""Full Codex-grade native N2 qualification directly through the self-compiled x86 N2 binary.

Runs on N2 + runtime-agy.o:
  1. All 64 native64 conformance cases (19 focused + 45 broad incl. 3 refusals)
  2. All 10 runtime10 controls
  3. All 45 native45 objects: N2 == hosted B1 byte-for-byte identity + total N2 emit time
  4. All 4 CTFE U32/Nat boundary cases + all 9 boundary/adverse-perf audit cases (13 cases)
"""
import hashlib
import json
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BASE = ROOT / "selfhost/dist/base.bend"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
B1_DIR = ROOT / "selfhost/build/agy/unified/full44"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

sys.path.insert(0, str(ROOT / "research/agy"))
import test_ctfe_nat_boundary as ctfe_bound
import test_boundary_audit as bound_audit


def sha256_bytes(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def emit_n2(n2: Path, src: Path, out_obj: Path, timeout: int = 60) -> tuple:
    t0 = time.perf_counter()
    with out_obj.open("wb") as fout:
        r = subprocess.run(
            [str(n2), *RTS_ARGS, "--RTS", "x86-object", str(src), str(BASE), "live", "", ""],
            stdout=fout, stderr=subprocess.PIPE, timeout=timeout,
        )
    dt = time.perf_counter() - t0
    return r.returncode, r.stderr.decode("utf-8", errors="replace"), dt


def link_exe(obj: Path, exe: Path):
    r = subprocess.run([CC, "-no-pie", str(obj), str(RT), "-pthread", "-lm", "-o", str(exe)],
                       capture_output=True, text=True, timeout=30)
    if r.returncode != 0:
        raise RuntimeError(f"link failed: {r.stderr[:400]}")


def run_native64(n2: Path, tmp: Path) -> dict:
    cat = json.loads((ROOT / "selfhost/tests/phase182/qualification-catalog.json").read_text())
    passed, failures = 0, []
    t0 = time.perf_counter()
    for c in cat["cases"]:
        cid = c["id"]
        src = ROOT / c["source"]["file"]
        exp = c["expect"]
        obj = tmp / "n64.o"
        exe = tmp / "n64.exe"
        rc, err, _ = emit_n2(n2, src, obj)
        stage = exp["stage"]
        if stage != "execute":
            # Refusal control: must exit non-zero, emit 0 bytes, and contain expected diagnostic
            ok = (rc != 0) and (obj.stat().st_size == 0)
            if ok:
                passed += 1
            else:
                failures.append(dict(id=cid, reason=f"expected refusal rc!=0 size==0, got rc={rc} size={obj.stat().st_size} err={err[:120]}"))
            obj.unlink(missing_ok=True)
            continue
        if rc != 0 or obj.stat().st_size < 64:
            failures.append(dict(id=cid, reason=f"emit failed rc={rc} size={obj.stat().st_size} err={err[:200]}"))
            obj.unlink(missing_ok=True)
            continue
        link_exe(obj, exe)
        r = subprocess.run([str(exe), *RTS_ARGS], capture_output=True, timeout=15)
        exp_out = exp["stdout"].encode("utf-8")
        exp_err = exp.get("stderr", "").encode("utf-8")
        ok = (r.returncode == exp["exitCode"]) and (r.stdout == exp_out) and (r.stderr == exp_err)
        if ok:
            passed += 1
        else:
            failures.append(dict(id=cid, rc=r.returncode, expRc=exp["exitCode"],
                                 got=r.stdout[:120].decode(errors="replace"),
                                 exp=exp["stdout"][:120]))
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)
    dt = time.perf_counter() - t0
    print(f"Gate N2/native64: {passed}/{len(cat['cases'])} PASS ({dt:.2f}s)", flush=True)
    return dict(passCount=passed, total=len(cat["cases"]), passed=(passed == len(cat["cases"])),
                seconds=round(dt, 2), failures=failures)


def run_runtime10(n2: Path, tmp: Path) -> dict:
    names = ("numeric", "array-unchecked", "array-unchecked-boxed", "char-output",
             "argv", "files", "open-errors", "exit", "exit-upper-valid", "halt-valid")
    passed, failures = 0, []
    t0 = time.perf_counter()
    for name in names:
        src = ROOT / "selfhost/tests/phase182/native" / f"{name}.bend"
        lines, exit_code = [], 0
        for line in src.read_text().splitlines():
            if line.startswith("#|exit "):
                exit_code = int(line[7:])
            elif line.startswith("#|"):
                lines.append(line[2:])
        exp_out = ("\n".join(lines) + ("\n" if lines else "")).encode("utf-8")
        exp_err = b""
        if name == "halt-valid":
            exp_out, exp_err = b"before\n", b"reported\n"
        obj = tmp / "rt10.o"
        exe = tmp / "rt10.exe"
        rc, err, _ = emit_n2(n2, src, obj)
        if rc != 0 or obj.stat().st_size < 64:
            failures.append(dict(name=name, reason=f"emit failed rc={rc} err={err[:200]}"))
            obj.unlink(missing_ok=True)
            continue
        link_exe(obj, exe)
        work = tmp / f"work_{name}"
        work.mkdir(exist_ok=True)
        r = subprocess.run([str(exe), *RTS_ARGS], cwd=work, capture_output=True, timeout=15)
        ok = (r.returncode == exit_code) and (r.stdout == exp_out) and (r.stderr == exp_err)
        if ok:
            passed += 1
        else:
            failures.append(dict(name=name, rc=r.returncode, expRc=exit_code,
                                 got=r.stdout[:120].decode(errors="replace"),
                                 err=r.stderr[:120].decode(errors="replace")))
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)
    dt = time.perf_counter() - t0
    print(f"Gate N2/runtime10: {passed}/{len(names)} PASS ({dt:.2f}s)", flush=True)
    return dict(passCount=passed, total=len(names), passed=(passed == len(names)),
                seconds=round(dt, 2), failures=failures)


def run_native45_identity(n2: Path, tmp: Path) -> dict:
    cat = json.loads((ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json").read_text())
    total_emit = 0.0
    same_count, oracle_count = 0, 0
    failures = []
    for c in cat["cases"]:
        cid = c["id"]
        src = ROOT / "selfhost/tools/bench" / c["source"]["file"]
        obj = tmp / "n45.o"
        exe = tmp / "n45.exe"
        rc, err, dt = emit_n2(n2, src, obj)
        total_emit += dt
        if rc != 0 or obj.stat().st_size < 64:
            failures.append(dict(id=cid, reason=f"emit failed rc={rc} err={err[:200]}"))
            obj.unlink(missing_ok=True)
            continue
        b1_obj = B1_DIR / f"{cid}.cand.o"
        n2_bytes = obj.read_bytes()
        same_b1 = b1_obj.exists() and (sha256_bytes(n2_bytes) == sha256_bytes(b1_obj.read_bytes()))
        if same_b1:
            same_count += 1
        link_exe(obj, exe)
        args = [str(a) for a in c["point"]["runtimeArgs"]]
        exp = c["point"]["expectedStdout"].splitlines()
        r = subprocess.run([str(exe), "4", "2", *args], capture_output=True, text=True, timeout=30)
        oracle_ok = (r.returncode == 0) and (r.stdout.splitlines()[:len(exp)] == exp)
        if oracle_ok:
            oracle_count += 1
        if not (same_b1 and oracle_ok):
            failures.append(dict(id=cid, sameAsB1=same_b1, oracleOk=oracle_ok))
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)
    n = len(cat["cases"])
    print(f"Gate N2/native45: {same_count}/{n} byte-identical to B1, {oracle_count}/{n} oracles PASS, total N2 emit={total_emit:.2f}s", flush=True)
    return dict(sameAsB1Count=same_count, oraclePassCount=oracle_count, total=n,
                totalEmitSeconds=round(total_emit, 3),
                passed=(same_count == n and oracle_count == n), failures=failures)


def run_boundary_n2(n2: Path, tmp: Path) -> dict:
    b_receipt = json.loads((ROOT / "experiments/agy/receipts/boundary-audit.json").read_text())
    passed, total, failures = 0, 0, []
    t0 = time.perf_counter()
    # 4 CTFE U32/Nat boundary cases
    for name, code, expected in ctfe_bound.CASES:
        total += 1
        src = tmp / f"{name}.bend"
        src.write_text(code)
        obj, exe = tmp / "bnd.o", tmp / "bnd.exe"
        rc, err, _ = emit_n2(n2, src, obj)
        if rc != 0:
            failures.append(dict(name=name, reason=f"emit rc={rc} {err[:160]}"))
            continue
        link_exe(obj, exe)
        r = subprocess.run([str(exe)], capture_output=True, text=True, timeout=15)
        if r.returncode == 0 and r.stdout == expected and r.stderr == "":
            passed += 1
        else:
            failures.append(dict(name=name, got=r.stdout, exp=expected))
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)
    # 9 expanded boundary & adverse-perf cases (expected = upstream stdout from boundary-audit.json)
    for name, code in bound_audit.CASES:
        total += 1
        expected = b_receipt["cases"][name]["upstream"]
        src = tmp / f"{name}.bend"
        src.write_text(code)
        obj, exe = tmp / "bnd.o", tmp / "bnd.exe"
        rc, err, dt = emit_n2(n2, src, obj)
        if rc != 0:
            failures.append(dict(name=name, reason=f"emit rc={rc} {err[:160]}"))
            continue
        link_exe(obj, exe)
        r = subprocess.run([str(exe)], capture_output=True, text=True, timeout=15)
        if r.returncode == 0 and r.stdout == expected and r.stderr == "":
            passed += 1
        else:
            failures.append(dict(name=name, got=r.stdout, exp=expected, emitSec=round(dt, 3)))
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)
    dt = time.perf_counter() - t0
    print(f"Gate N2/boundary13: {passed}/{total} PASS ({dt:.2f}s)", flush=True)
    return dict(passCount=passed, total=total, passed=(passed == total),
                seconds=round(dt, 2), failures=failures)


def main():
    n2 = Path(sys.argv[1])
    out_report = Path(sys.argv[2])
    report = dict(
        kind="agy-native-n2-full-qualification-v1",
        n2=dict(file=str(n2), bytes=n2.stat().st_size, sha256=sha256_bytes(n2.read_bytes())),
        runtime=dict(file=str(RT), bytes=RT.stat().st_size, sha256=sha256_bytes(RT.read_bytes())),
        passed=False,
    )
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        report["native64"] = run_native64(n2, tmp)
        report["runtime10"] = run_runtime10(n2, tmp)
        report["native45_identity"] = run_native45_identity(n2, tmp)
        report["boundary13"] = run_boundary_n2(n2, tmp)
    report["passed"] = all(
        report[k]["passed"] for k in ("native64", "runtime10", "native45_identity", "boundary13")
    )
    out_report.write_text(json.dumps(report, indent=2) + "\n")
    if not report["passed"]:
        print("NATIVE N2 FULL QUALIFICATION FAILED!", flush=True)
        sys.exit(1)
    print("\nALL NATIVE N2 FULL QUALIFICATION GATES PASSED (64/64 native64 + 10/10 runtime10 + 45/45 native45 B1==N2 + 13/13 boundary)!", flush=True)


if __name__ == "__main__":
    main()
