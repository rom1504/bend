#!/usr/bin/env python3
"""Compose Wave 8 Unified Compiler from Wave 7C Unified + Wave 8 Modular & x198pw Tracks.

Pipeline:
  1. selfhost/build/agy/wave7c_unified/compiler.bend
  2. + research/agy/w8_rodata_str/apply_w8_rodata_str.py (zero cross-TU p111_static_image + .rodata tables)
  3. + research/agy/w8_fid_base/apply_w8_fid_base.py     (x86-module FID_BASE MOD_NAME + p111_link_merge.c)
  4. + research/agy/w8_pw_3mb/apply_w8_pw_3mb.py         (p113pl_candidates + p112s_prepare 3.33MB O(N^2) killer)
  5. -> selfhost/build/agy/wave8_unified/{compiler.bend,api.mjs}
"""
from __future__ import annotations

import argparse
import subprocess
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
W7C_SRC = ROOT / "selfhost/build/agy/wave7c_unified/compiler.bend"
DEFAULT_OUT = ROOT / "selfhost/build/agy/wave8_unified"

STEPS = [
    ("w8_rodata_str", ROOT / "research/agy/w8_rodata_str/apply_w8_rodata_str.py"),
    ("w8_fid_base",   ROOT / "research/agy/w8_fid_base/apply_w8_fid_base.py"),
    ("w8_pw_3mb",     ROOT / "research/agy/w8_pw_3mb/apply_w8_pw_3mb.py"),
]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=W7C_SRC)
    ap.add_argument("--out-dir", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--skip", nargs="*", default=[])
    ap.add_argument("--skip-build", action="store_true")
    args = ap.parse_args()

    out_dir = args.out_dir.resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    dst_bend = out_dir / "compiler.bend"
    dst_api = out_dir / "api.mjs"

    with tempfile.TemporaryDirectory(prefix="agy_compose_w8_") as tmp:
        tdir = Path(tmp)
        cur = args.src
        for i, (name, script) in enumerate(STEPS):
            if name in args.skip:
                print(f"[compose_wave8] SKIP {name}", flush=True)
                continue
            nxt = dst_bend if i == len(STEPS) - 1 else (tdir / f"s{i}_{name}.bend")
            t0 = time.perf_counter()
            res = subprocess.run(["python3", "-B", str(script), "--src", str(cur), "--dst", str(nxt)], cwd=ROOT)
            if res.returncode != 0:
                raise SystemExit(f"[compose_wave8] FAILED at {name} (rc={res.returncode})")
            print(f"[compose_wave8] {name} OK ({time.perf_counter()-t0:.2f}s, {nxt.stat().st_size:,} B)", flush=True)
            cur = nxt
        if cur != dst_bend:
            dst_bend.write_bytes(cur.read_bytes())

    # Raise x187 ELF section-size guard from 32 MiB -> 128 MiB so monolithic -O0
    # self-compilation (48+ MiB .text/.o) succeeds cleanly without touching CTR tag 33554432.
    txt = dst_bend.read_text()
    for old_guard, new_guard in [
        (
            'nt_choose(X187Build,U32.is_gt(count,33554432) || U32.is_gt(cur,U32.sub(33554432,count)),\n'
            '        u => x187_build_error("x86 object section exceeds 32 MiB bound",build),',
            'nt_choose(X187Build,U32.is_gt(count,134217728) || U32.is_gt(cur,U32.sub(134217728,count)),\n'
            '        u => x187_build_error("x86 object section exceeds 128 MiB bound",build),',
        ),
        (
            'nt_choose(X187Build,U32.is_gt(x187_build_offset(build),U32.sub(33554432,count)),\n'
            '          v => x187_build_error("x86 object section exceeds 32 MiB bound",build),',
            'nt_choose(X187Build,U32.is_gt(x187_build_offset(build),U32.sub(134217728,count)),\n'
            '          v => x187_build_error("x86 object section exceeds 128 MiB bound",build),',
        ),
    ]:
        if old_guard in txt:
            txt = txt.replace(old_guard, new_guard, 1)
    dst_bend.write_text(txt)

    if not args.skip_build:
        t0 = time.perf_counter()
        res = subprocess.run(["bash", str(ROOT / "research/agy/locked_bun.sh"), str(dst_bend), "-o", str(dst_api)], cwd=ROOT)
        if res.returncode != 0:
            raise SystemExit(f"[compose_wave8] Build FAILED (rc={res.returncode})")
        print(f"[compose_wave8] Built {dst_api} ({dst_api.stat().st_size:,} B) in {time.perf_counter()-t0:.2f}s", flush=True)


if __name__ == "__main__":
    main()
