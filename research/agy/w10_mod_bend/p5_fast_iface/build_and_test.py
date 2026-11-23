#!/usr/bin/env python3
"""Patch a private copy of wave10_unified/compiler.bend with fast_iface_emit.bend,
run --check-only, compile to fast_api.mjs, and verify bit-identical .p130 + speedup on m00..m02."""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
ORIG_COMPILER = ROOT / "selfhost/build/agy/wave10_unified/compiler.bend"
FAST_IFACE_SRC = ROOT / "research/agy/w10_mod_bend/p5_fast_iface/fast_iface_emit.bend"
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
CLI = ROOT / "research/agy/w10_mod_bend/compose_w10/run_w10_cli.mjs"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"

TMP = Path("/tmp/agy_p5_iface")
FAST_COMPILER = TMP / "fast_compiler.bend"
FAST_API = TMP / "fast_api.mjs"
FAST_IFACE_DIR = TMP / "fast_iface_js"
BASE_IFACE_DIR = TMP / "base_iface"
SRC_DIR = TMP / "src"

def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()

def patch_compiler() -> None:
    src = ORIG_COMPILER.read_text(encoding="utf-8")
    start_marker = "# --- Dual 32-bit FNV-1a interface hasher (alpha-invariant, ignores spans & bodies) ---"
    end_marker = "@unsafe\ndef w8_module_entry("
    i0 = src.index(start_marker)
    i1 = src.index(end_marker, i0)
    fast_body = FAST_IFACE_SRC.read_text(encoding="utf-8")
    patched = src[:i0] + fast_body.rstrip() + "\n\n" + src[i1:]
    FAST_COMPILER.write_text(patched, encoding="utf-8")
    print(f"Wrote {FAST_COMPILER} ({len(patched):,} B)", flush=True)

def main() -> None:
    FAST_IFACE_DIR.mkdir(parents=True, exist_ok=True)
    patch_compiler()

    print("=== 1. Running --check-only on fast_compiler.bend (CPU 6) ===", flush=True)
    t0 = time.perf_counter()
    r = subprocess.run(
        ["taskset", "-c", "6", "bash", str(LOCKED_BUN), str(FAST_COMPILER), "--check-only"],
        capture_output=True, text=True, cwd=ROOT, timeout=180
    )
    chk_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    if r.returncode != 0 and "rely on unsafe or foreign code:" not in (r.stdout + r.stderr):
        print("CHECK FAILED:", r.stdout, r.stderr, flush=True)
        sys.exit(r.returncode)
    print(f"  --check-only PASS (0 type errors) in {chk_ms} ms", flush=True)

    print("=== 2. Compiling fast_compiler.bend -> fast_api.mjs (CPU 6) ===", flush=True)
    t0 = time.perf_counter()
    r = subprocess.run(
        ["taskset", "-c", "6", "bash", str(LOCKED_BUN), str(FAST_COMPILER), "-o", str(FAST_API)],
        capture_output=True, text=True, cwd=ROOT, timeout=180
    )
    comp_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    if r.returncode != 0:
        print("COMPILE FAILED:", r.stdout, r.stderr, flush=True)
        sys.exit(r.returncode)
    print(f"  compiled {FAST_API.stat().st_size:,} B in {comp_ms} ms", flush=True)

    if "--build-only" in sys.argv:
        return

    env = os.environ.copy()
    env["AGY_NODE_MAX_MB"] = "4096"

    # Quick test on m01 first, then full m00..m02 (or m00..m10 if --all)
    n_mods = 11 if "--all" in sys.argv else 3
    carriers = [(BASE_CARRIER, BASE_STAMP)]
    records = []
    for i in range(n_mods):
        m = f"m{i:02d}"
        in_carrier, in_stamp = carriers[i]
        out_p130 = FAST_IFACE_DIR / f"{m}.p130"
        t0 = time.perf_counter()
        with out_p130.open("wb") as f:
            rr = subprocess.run(
                ["taskset", "-c", "6", "bash", str(LOCKED_NODE), str(CLI), str(FAST_API),
                 "x86-iface", str(SRC_DIR / f"{m}_exp.bend"), str(BASE_FILE), "cache", str(in_carrier), in_stamp],
                stdout=f, stderr=subprocess.PIPE, cwd=ROOT, env=env, timeout=600
            )
        ms = round((time.perf_counter() - t0) * 1000.0, 1)
        stderr = rr.stderr.decode("utf-8", errors="replace").strip()
        if rr.returncode != 0:
            print(f"  [{m}] FAILED rc={rr.returncode}: {stderr[:800]}", flush=True)
            sys.exit(rr.returncode)
        stamp = stderr.splitlines()[-1].strip()
        base_p130 = BASE_IFACE_DIR / f"{m}.p130"
        bit_eq = (out_p130.read_bytes() == base_p130.read_bytes()) if base_p130.exists() else None
        rec = {
            "module": m,
            "ms": ms,
            "bytes": out_p130.stat().st_size,
            "sha256": sha256(out_p130),
            "stamp": stamp,
            "bit_identical_to_baseline": bit_eq,
        }
        records.append(rec)
        carriers.append((out_p130, stamp))
        print(f"  [fast JS {m}] {ms:8.1f} ms | bytes={rec['bytes']:,} | bit_identical={bit_eq} | stamp={stamp}", flush=True)

    (TMP / "fast_js_results.json").write_text(json.dumps({
        "check_only_ms": chk_ms,
        "compile_ms": comp_ms,
        "records": records,
        "total_ms": round(sum(r["ms"] for r in records), 1),
    }, indent=2) + "\n", encoding="utf-8")
    print(f"\nDONE! Total fast JS ({n_mods} mods): {sum(r['ms'] for r in records):.1f} ms", flush=True)

if __name__ == "__main__":
    main()
