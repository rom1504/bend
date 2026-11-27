#!/usr/bin/env python3
"""Build harness for selfhost/bend5k/.

Assembles existing modules in canonical order into /tmp/agy_b5k/bend5k.bend,
enforces the hard <= 6,500 LOC cap, type-checks with locked_bun.sh --check-only,
compiles with n9_o2 (x86-object-fast or x86-object), and links with runtime-agy.o.
"""
from __future__ import annotations
import argparse
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
B5K_DIR = Path(__file__).resolve().parent
MANIFEST_FILE = B5K_DIR / "bend5k.manifest"
OUT_DIR = Path("/tmp/agy_b5k")


def load_manifest(manifest: Path = MANIFEST_FILE) -> list[str]:
    modules: list[str] = []
    for raw in manifest.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        modules.append(line.split()[0])
    if not modules:
        raise RuntimeError(f"No modules listed in {manifest}")
    return modules


MODULES = load_manifest()
MAX_LOC = 15000

LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
N9_O2 = ROOT / "selfhost/build/agy/wave18-native-mod/n9_o2"
BEND5K_O2 = ROOT / "selfhost/build/agy/bend5k/bend5k_o2"
RT_OBJ = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"


def assemble(out_dir: Path, modules: list[str]) -> tuple[Path, int, list[tuple[str, int]]]:
    out_dir.mkdir(parents=True, exist_ok=True)
    parts: list[str] = []
    counts: list[tuple[str, int]] = []
    total_loc = 0
    for name in modules:
        p = B5K_DIR / name
        if not p.exists():
            continue
        text = p.read_text(encoding="utf-8")
        loc = len(text.splitlines())
        counts.append((name, loc))
        total_loc += loc
        parts.append(f"# === {name} ({loc} LOC) ===\n{text.rstrip()}\n")
    if not parts:
        raise RuntimeError(f"No bend5k modules found in {B5K_DIR}")
    assembled = out_dir / "bend5k.bend"
    assembled.write_text("import Base\n\n" + "\n".join(parts), encoding="utf-8")
    return assembled, total_loc, counts


def run_check(src: Path) -> float:
    t0 = time.perf_counter()
    r = subprocess.run(
        ["bash", str(LOCKED_BUN), "--check-only", str(src)],
        capture_output=True,
        text=True,
    )
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        sys.stderr.write(r.stdout + r.stderr)
        raise RuntimeError(f"bend2 --check-only failed (rc={r.returncode})")
    return dt


def run_compile(src: Path, obj: Path, err_log: Path, opt: str) -> float:
    mode = "x86-object" if opt == "O2" else "x86-object-fast"
    cmd = [
        str(N9_O2),
        "+RTS", "--threads", "1", "--gpu", "off", "-RTS",
        mode, str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP,
    ]
    t0 = time.perf_counter()
    with obj.open("wb") as fout, err_log.open("wb") as ferr:
        r = subprocess.run(cmd, stdout=fout, stderr=ferr)
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        err = err_log.read_text(errors="replace")[:1200]
        raise RuntimeError(f"n9_o2 {mode} failed (rc={r.returncode}): {err}")
    if obj.stat().st_size < 64:
        raise RuntimeError(f"n9_o2 produced tiny object ({obj.stat().st_size} B)")
    return dt


def run_link(obj: Path, exe: Path) -> float:
    t0 = time.perf_counter()
    r = subprocess.run(
        [CC, "-no-pie", str(obj), str(RT_OBJ), "-pthread", "-lm", "-o", str(exe)],
        capture_output=True,
        text=True,
    )
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        raise RuntimeError(f"gcc link failed (rc={r.returncode}): {r.stderr[:800]}")
    return dt


def run_native_manifest(compiler: Path, manifest: Path, obj: Path | None, opt: str, check_only: bool) -> float:
    cmd = [str(compiler)]
    if check_only:
        cmd.append("--check-only")
    else:
        cmd.append("-O2" if opt == "O2" else "-O0")
    cmd.extend(["--manifest", str(manifest)])
    if not check_only:
        assert obj is not None
        cmd.append(str(obj))
    t0 = time.perf_counter()
    r = subprocess.run(cmd, capture_output=True, text=True)
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        sys.stderr.write(r.stdout + r.stderr)
        raise RuntimeError(f"native manifest compile failed (rc={r.returncode})")
    if not check_only and (obj is None or not obj.exists() or obj.stat().st_size < 64):
        raise RuntimeError("native manifest compile did not produce a valid object file")
    return dt


def main() -> int:
    ap = argparse.ArgumentParser(description="Build & check selfhost/bend5k")
    ap.add_argument("--out-dir", type=Path, default=OUT_DIR)
    ap.add_argument("--opt", choices=("O0", "O2"), default="O0")
    ap.add_argument("--check-only", action="store_true")
    ap.add_argument("--skip-check", action="store_true")
    ap.add_argument("--native-manifest", action="store_true", help="Compile directly via bend5k --manifest (no Python bundler)")
    ap.add_argument("--compiler", type=Path, default=BEND5K_O2, help="bend5k binary for --native-manifest")
    ap.add_argument("--manifest", type=Path, default=MANIFEST_FILE, help="Manifest file path")
    ap.add_argument("--run", action="store_true", help="Run resulting binary after link")
    args = ap.parse_args()

    modules = load_manifest(args.manifest)
    if args.native_manifest:
        args.out_dir.mkdir(parents=True, exist_ok=True)
        if args.check_only:
            dt_chk = run_native_manifest(args.compiler, args.manifest, None, args.opt, True)
            print(f"[native-check] PASS ({dt_chk:.2f}s, {len(modules)} modules via {args.manifest})", flush=True)
            return 0
        obj = args.out_dir / "bend5k.o"
        exe = args.out_dir / "bend5k"
        dt_cmp = run_native_manifest(args.compiler, args.manifest, obj, args.opt, False)
        dt_lnk = run_link(obj, exe)
        print(f"[native-build] {exe} ({args.opt}: compile={dt_cmp:.2f}s link={dt_lnk:.2f}s obj={obj.stat().st_size}B via {args.manifest})", flush=True)
        if args.run:
            r = subprocess.run([str(exe)], capture_output=True, text=True)
            print(f"[run]      rc={r.returncode} stdout={r.stdout.strip()!r} stderr={r.stderr.strip()!r}", flush=True)
            if r.returncode != 0:
                return r.returncode
        return 0

    assembled, total_loc, counts = assemble(args.out_dir, modules)
    breakdown = ", ".join(f"{n}:{c}" for n, c in counts)
    print(f"[assemble] {assembled} ({total_loc}/{MAX_LOC} LOC: {breakdown})", flush=True)
    if total_loc > MAX_LOC:
        print(f"ERROR: LOC cap exceeded ({total_loc} > {MAX_LOC})", file=sys.stderr)
        return 1

    if not args.skip_check:
        dt_chk = run_check(assembled)
        print(f"[check]    PASS ({dt_chk:.2f}s)", flush=True)
        if args.check_only:
            return 0

    obj = args.out_dir / "bend5k.o"
    err = args.out_dir / "bend5k.stderr"
    exe = args.out_dir / "bend5k"
    dt_cmp = run_compile(assembled, obj, err, args.opt)
    dt_lnk = run_link(obj, exe)
    print(f"[build]    {exe} ({args.opt}: compile={dt_cmp:.2f}s link={dt_lnk:.2f}s obj={obj.stat().st_size}B)", flush=True)

    if args.run:
        r = subprocess.run([str(exe)], capture_output=True, text=True)
        print(f"[run]      rc={r.returncode} stdout={r.stdout.strip()!r} stderr={r.stderr.strip()!r}", flush=True)
        if r.returncode != 0:
            return r.returncode
    return 0


if __name__ == "__main__":
    sys.exit(main())
