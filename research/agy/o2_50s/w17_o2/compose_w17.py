#!/usr/bin/env python3
"""Wave 17 Composer: wave16_unified/compiler.bend -> wave17_unified/compiler.bend.

Applies 5 verified patchers in order:
  1. O2-C: All 3 Wave 16 -O2 bug fixes (caps=7 AND, x198o_progress_get nq_sigs, w11_cmp_jcc_emit liveness)
  2. O2-F: O(N) w4b_find_loop (kills 80% x187_priv quadratic bomb, bit-identical -O2)
  3. O2-A (SAFE 4 HUNKS ONLY): w4b_reg_dead_cap, w14a_sl_rounds_cap, w14a_sl_rounds_cap_h,
     x191_frame_forward_large_call_cap (omits patches 5-7 which regressed w13c_sink_tpl_bytes)
  4. O2-D: Full p111 stub skip + -O2 direct-stub skip + synthetic .exp direct-worker demand
  5. O2-E: w7c_fast_inst_c + x186/x190/x191 non-loop fast paths + w8_tr_emit_pub cold fast path
"""
from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
SRC = ROOT / "selfhost/build/agy/wave16_unified/compiler.bend"
OUT = ROOT / "selfhost/build/agy/wave17_unified/compiler.bend"

O2A_SAFE_NAMES = {
    "w4b_reg_dead_cap",
    "w14a_sl_rounds_cap",
    "w14a_sl_rounds_cap_h",
    "x191_frame_forward_large_call_cap",
}


def load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main() -> int:
    text = SRC.read_text(encoding="utf-8")
    orig_len = len(text)
    print(f"[w17] Loaded {SRC} ({orig_len:,} B)", flush=True)

    # 1. O2-C
    o2c = load_module("apply_o2c", ROOT / "research/agy/o2_50s/o2c_fix_o2_bugs/apply_o2c.py")
    print("[w17] 1/5 Applying O2-C ...", flush=True)
    text = o2c.apply_o2c(text)

    # 2. O2-F
    o2f = load_module("apply_o2f", ROOT / "research/agy/o2_50s/o2f_bomb_killer/apply_o2f.py")
    print("[w17] 2/5 Applying O2-F ...", flush=True)
    text, st_f = o2f.apply_text(text, require_all=True)
    print(f"  [OK] O2-F: {', '.join(st_f)}", flush=True)

    # 3. O2-A (SAFE 4 HUNKS ONLY)
    o2a = load_module("apply_o2a", ROOT / "research/agy/o2_50s/o2a_trace_slow/apply_o2a.py")
    print("[w17] 3/5 Applying O2-A (SAFE 4 HUNKS ONLY) ...", flush=True)
    applied_a = []
    for name, old, new in o2a.PATCHES:
        if name not in O2A_SAFE_NAMES:
            print(f"  [OMIT] O2-A unsafe hunk: {name}", flush=True)
            continue
        if new in text:
            applied_a.append(f"{name}:already")
            continue
        cnt = text.count(old)
        if cnt != 1:
            raise RuntimeError(f"O2-A {name}: expected 1 match, found {cnt}")
        text = text.replace(old, new, 1)
        applied_a.append(f"{name}:applied")
    if len(applied_a) != 4:
        raise RuntimeError(f"Expected 4 O2-A safe hunks, got {len(applied_a)}")
    print(f"  [OK] O2-A safe: {', '.join(applied_a)}", flush=True)

    # 4. O2-D
    o2d = load_module("apply_o2d", ROOT / "research/agy/o2_50s/o2d_full_stub_skip/apply_o2d.py")
    print("[w17] 4/5 Applying O2-D ...", flush=True)
    text, ch_d = o2d.apply_text(text)
    print(f"  [OK] O2-D: changed={ch_d}", flush=True)

    # 5. O2-E
    o2e = load_module("apply_o2e", ROOT / "research/agy/o2_50s/o2e_priv_core/apply_o2e.py")
    print("[w17] 5/5 Applying O2-E ...", flush=True)
    text, st_e = o2e.apply_o2e(text, partial=False)
    print(f"  [OK] O2-E: {', '.join(st_e)}", flush=True)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text, encoding="utf-8")
    print(f"[w17] Wrote {OUT} ({orig_len:,} -> {len(text):,} B, +{len(text) - orig_len:,} B)", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
