#!/usr/bin/env python3
"""Wave 18 Composer: wave16_unified/compiler.bend -> wave18_unified/compiler.bend.

Applies 8 verified patchers in order:
  1. O2-C: All 3 Wave 16 -O2 bug fixes
  2. O2-F: O(N) w4b_find_loop
  3. O2-A (SAFE 3 HUNKS ONLY): w4b_reg_dead_cap, w14a_sl_rounds_cap, w14a_sl_rounds_cap_h
     (x191_frame_forward_large_call_cap REMOVED to preserve gameoflife -O2 speed)
  4. O2-D: Full p111 stub skip + -O2 direct-stub skip + synthetic .exp direct-worker demand
  5. O2-E: w7c_fast_inst_c + x186/x190/x191 non-loop fast paths + w8_tr_emit_pub cold fast path
  6. B2: Direct-Only FID omission & explicit cross-module contracts (_d/_b/_c/_w)
  7. B3: Residual x187_priv O(N^2) & HAMT-churn killer (p111v_get, w5c_p131i_leaf, x185 delta-union, x192/x190)
  8. B4: x198pw_plan + p86_plan algorithmic hotspot killer (nc_uses_term, nq_layout_subst, pre_bang_index, o2_mod_check)
"""
from __future__ import annotations

import importlib.util
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
SRC = ROOT / "selfhost/build/agy/wave16_unified/compiler.bend"
OUT = ROOT / "selfhost/build/agy/wave18_unified/compiler.bend"

O2A_SAFE_NAMES = {
    "w4b_reg_dead_cap",
    "w14a_sl_rounds_cap",
    "w14a_sl_rounds_cap_h",
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
    print(f"[w18] Loaded {SRC} ({orig_len:,} B)", flush=True)

    # 1. O2-C
    o2c = load_module("apply_o2c", ROOT / "research/agy/o2_50s/o2c_fix_o2_bugs/apply_o2c.py")
    print("[w18] 1/8 Applying O2-C ...", flush=True)
    text = o2c.apply_o2c(text)

    # 2. O2-F
    o2f = load_module("apply_o2f", ROOT / "research/agy/o2_50s/o2f_bomb_killer/apply_o2f.py")
    print("[w18] 2/8 Applying O2-F ...", flush=True)
    text, st_f = o2f.apply_text(text, require_all=True)
    print(f"  [OK] O2-F: {', '.join(st_f)}", flush=True)

    # 3. O2-A (SAFE 3 HUNKS ONLY)
    o2a = load_module("apply_o2a", ROOT / "research/agy/o2_50s/o2a_trace_slow/apply_o2a.py")
    print("[w18] 3/8 Applying O2-A (SAFE 3 HUNKS ONLY) ...", flush=True)
    applied_a = []
    for name, old, new in o2a.PATCHES:
        if name not in O2A_SAFE_NAMES:
            print(f"  [OMIT] O2-A hunk: {name}", flush=True)
            continue
        if new in text:
            applied_a.append(f"{name}:already")
            continue
        cnt = text.count(old)
        if cnt != 1:
            raise RuntimeError(f"O2-A {name}: expected 1 match, found {cnt}")
        text = text.replace(old, new, 1)
        applied_a.append(f"{name}:applied")
    if len(applied_a) != len(O2A_SAFE_NAMES):
        raise RuntimeError(f"Expected {len(O2A_SAFE_NAMES)} O2-A safe hunks, got {len(applied_a)}")
    print(f"  [OK] O2-A safe: {', '.join(applied_a)}", flush=True)

    # 4. O2-D
    o2d = load_module("apply_o2d", ROOT / "research/agy/o2_50s/o2d_full_stub_skip/apply_o2d.py")
    print("[w18] 4/8 Applying O2-D ...", flush=True)
    text, ch_d = o2d.apply_text(text)
    print(f"  [OK] O2-D: changed={ch_d}", flush=True)

    # 5. O2-E
    o2e = load_module("apply_o2e", ROOT / "research/agy/o2_50s/o2e_priv_core/apply_o2e.py")
    print("[w18] 5/8 Applying O2-E ...", flush=True)
    text, st_e = o2e.apply_o2e(text, partial=False)
    print(f"  [OK] O2-E: {', '.join(st_e)}", flush=True)

    # 6. B2
    b2 = load_module("apply_b2", ROOT / "research/agy/boot_200s/b2_direct_fid/apply_b2.py")
    print("[w18] 6/8 Applying B2 ...", flush=True)
    text, ch_b2 = b2.apply_text(text)
    print(f"  [OK] B2: changed={ch_b2}", flush=True)

    # 7. B3
    b3 = load_module("apply_b3", ROOT / "research/agy/boot_200s/b3_priv_killer/apply_b3.py")
    print("[w18] 7/8 Applying B3 ...", flush=True)
    text, st_b3 = b3.apply_text(text, require_all=True)
    print(f"  [OK] B3: {', '.join(st_b3)}", flush=True)

    # 8. B4
    b4 = load_module("apply_b4", ROOT / "research/agy/boot_200s/b4_dfs_and_plan/apply_b4.py")
    print("[w18] 8/8 Applying B4 ...", flush=True)
    text, ch_b4 = b4.apply_patch(text)
    print(f"  [OK] B4: changed={ch_b4}", flush=True)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text, encoding="utf-8")
    print(f"[w18] Wrote {OUT} ({orig_len:,} -> {len(text):,} B, +{len(text) - orig_len:,} B)", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
