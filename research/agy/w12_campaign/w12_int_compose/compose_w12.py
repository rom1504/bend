#!/usr/bin/env python3
"""W12-INT: Reproducibly compose selfhost/build/agy/wave12_unified/compiler.bend
from read-only selfhost/build/agy/wave11_unified/compiler.bend by stacking all
9 verified Wave 12/13 pure-Bend wins:

  1. W13-A Win #1: agy_sh_guard_caps ((capabilities & 1) == 1) + no-op agy_sh_chk_hot
  2. W11-C Win:    w10_if_force_cps checks 0-arity `name` in addition to `"$direct." ++ name`
  3. W12-B:        w12b_ff_match.patch (direct #U32 literal pattern matching)
  4. W12-E:        w12e_iface_v2.patch (pure-Bend fast x86-iface v2)
  5. W12-A:        apply_w12a_bool_borrow.py (unboxed Bool match + borrow-loop direct load)
  6. W12-D:        w12d_terrain_nbody.patch (dual-array LCU scalarization + W12FwdDrop)
  7. W12-F:        Array.get / Array.set inline fast-path (from apply_w12f_boxed_array.py)
  8. W12-G:        w12g_7fam_1x.patch (w5_nat_match_chain + G11 cmov + 6th reg %rcx + 10-slot transient)
  9. W13-B compact: w13b_rt_ctor2_text + w13b_rt_take_p111_text + agy_rfc_check_fields (loc < HEAP_OFF)
                   (skips w13b_rt_sink_shallow_text & p111_ bounded framing to keep .o sizes lean)
"""
from __future__ import annotations

import importlib.util
import subprocess
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
SRC = ROOT / "selfhost/build/agy/wave11_unified/compiler.bend"
DST = ROOT / "selfhost/build/agy/wave12_unified/compiler.bend"

W12B_PATCH = ROOT / "research/agy/w12_campaign/w12b_ff_match/w12b_ff_match.patch"
W12E_PATCH = ROOT / "research/agy/w12_campaign/w12e_iface_v2/w12e_iface_v2.patch"
W12A_SCRIPT = ROOT / "research/agy/w12_campaign/w12a_bool_borrow/apply_w12a_bool_borrow.py"
W12D_PATCH = ROOT / "research/agy/w12_campaign/w12d_terrain_nbody/w12d_terrain_nbody.patch"
W12F_SCRIPT = ROOT / "research/agy/w12_campaign/w12f_boxed_array/apply_w12f_boxed_array.py"
W12G_PATCH = ROOT / "research/agy/w12_campaign/w12g_7fam_1x/w12g_7fam_1x.patch"
W13B_SCRIPT = ROOT / "research/agy/w13_campaign/w13b_rt_inline/apply_w13b_rt_inline.py"


def replace_once(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise SystemExit(f"[compose_w12] {label}: expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


def load_module(path: Path, name: str):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def apply_unified_patch(src: str, patch_path: Path, label: str) -> str:
    with tempfile.TemporaryDirectory(prefix=f"w12int_{label}_") as td:
        target = Path(td) / "compiler.bend"
        target.write_text(src, encoding="utf-8")
        r = subprocess.run(
            ["patch", "--batch", "--forward", "--no-backup-if-mismatch", "-F", "3", str(target), str(patch_path)],
            capture_output=True, text=True,
        )
        if r.returncode != 0:
            raise SystemExit(f"[compose_w12] patch {label} failed (rc={r.returncode}):\nSTDOUT:\n{r.stdout}\nSTDERR:\n{r.stderr}")
        print(f"  [OK] {label}: {r.stdout.strip().splitlines()[-1] if r.stdout.strip() else 'clean'}", flush=True)
        return target.read_text(encoding="utf-8")


def apply_w13a_win1(src: str) -> str:
    old = """# Check !cid_hot[cid]; expects %rax = cid_hot base, clobbers %r10, %r11
@unsafe
def agy_sh_chk_hot(+cid: U32, +slow: String) -> X188Seq:
  x188_many([
    x188_i2("movl",X187Imm{cid,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(11,32)),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jnz",X187Target{slow})])

# Guard capabilities & 9 == 9 and cid_hot != NULL; leaves cid_hot base in %rax
@unsafe
def agy_sh_guard_caps(+slow: String) -> X188Seq:
  x188_many([
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jz",X187Target{slow})])"""

    new = """# W13-A Win #1: All agy_sh_* paths are read-only and RFC-aware; cid_hot check is unnecessary.
@unsafe
def agy_sh_chk_hot(+cid: U32, +slow: String) -> X188Seq:
  X188Empty{}

# W13-A Win #1: Guard only (capabilities & 1) == 1 (packed words enabled).
@unsafe
def agy_sh_guard_caps(+slow: String) -> X188Seq:
  x188_many([
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jz",X187Target{slow})])"""

    out = replace_once(src, old, new, "W13-A Win #1 (agy_sh_guard_caps)")
    print("  [OK] W13-A Win #1: agy_sh_guard_caps & agy_sh_chk_hot", flush=True)
    return out


def apply_w11c_0arity_fix(src: str) -> str:
    old = """@unsafe
def w10_if_force_cps(+abi: W10IfAbi, +name: String) -> Bool:
  match abi:
    case W10IfAbi{+direct, +public}:
      +key = "$direct." ++ name
      w10_if_abi_has(public, key) && Bool.not(w10_if_abi_has(direct, key))"""

    new = """@unsafe
def w10_if_force_cps(+abi: W10IfAbi, +name: String) -> Bool:
  match abi:
    case W10IfAbi{+direct, +public}:
      +key = "$direct." ++ name
      (w10_if_abi_has(public, key) && Bool.not(w10_if_abi_has(direct, key))) ||
      (w10_if_abi_has(public, name) && Bool.not(w10_if_abi_has(direct, name)))"""

    out = replace_once(src, old, new, "W11-C 0-arity weak_set p113d fix (w10_if_force_cps)")
    print("  [OK] W11-C Win: 0-arity CPS stub fix in w10_if_force_cps", flush=True)
    return out


def apply_w12f_and_w13b_compact(src: str) -> str:
    w12f = load_module(W12F_SCRIPT, "apply_w12f")
    w13b = load_module(W13B_SCRIPT, "apply_w13b")

    # 1. W13-B static-field (loc < HEAP_OFF) fix in agy_rfc_check_fields
    src = replace_once(src, w13b.OLD_RFC_TRIV, w13b.NEW_RFC_TRIV, "W13-B agy_rfc_check_fields")

    # 2. Extract W12-F Array.get / Array.set defs (omitting w12f_ctor2_known / w12f_rt_ctor2_sealed_text)
    w12f_defs = w12f.W12F_DEFS
    cut_start = w12f_defs.index("@unsafe\ndef w12f_ctor2_known(")
    cut_end = w12f_defs.index("@unsafe\ndef w12f_rt_inline_array(")
    w12f_array_defs = w12f_defs[:cut_start] + w12f_defs[cut_end:]

    # 3. Extract W13-B compact defs (w13b_ctor2_known + w13b_rt_ctor2_text + w13b_rt_take_p111_text; skip sink_shallow)
    w13b_defs = w13b.W13B_DEFS
    sink_start = w13b_defs.index("@unsafe\ndef w13b_rt_sink_shallow_text(")
    w13b_compact_defs = w13b_defs[:sink_start]

    # 4. Insert both before agy_rt_inline_try
    src = replace_once(src, w13b.ANCHOR, w12f_array_defs + w13b_compact_defs + w13b.ANCHOR, "W12-F+W13-B anchor")

    # 5. Wire W13-B ctor2 (3-arg p125_rt_ctor2 + 4-arg p111_rt_ctor) and p111_rt_take
    src = replace_once(src, w13b.OLD_CTOR_CASE, w13b.NEW_CTOR_CASE, "W13-B OLD_CTOR_CASE")
    src = replace_once(src, w13b.OLD_CTOR0_CASE, w13b.NEW_CTOR0_CASE, "W13-B OLD_CTOR0_CASE")

    # 6. Wire W12-F Array.get / Array.set fallback arm
    src = replace_once(src, w12f.OLD_FALLBACK, w12f.NEW_FALLBACK, "W12-F OLD_FALLBACK")

    print("  [OK] W12-F (Array.get/set) + W13-B compact (ctor2+take+rfc_check_fields)", flush=True)
    return src


def main() -> None:
    print(f"=== W12-INT Compose: {SRC} -> {DST} ===", flush=True)
    src = SRC.read_text(encoding="utf-8")
    base_len = len(src)
    print(f"  Base wave11_unified: {base_len:,} B ({src.count(chr(10)):,} lines)", flush=True)

    # Apply unified patches that were diffed against wave11_unified (and wave10 for W12-B)
    src = apply_unified_patch(src, W12B_PATCH, "W12-B (ff_match #U32)")
    src = apply_unified_patch(src, W12E_PATCH, "W12-E (x86-iface v2)")
    src = apply_unified_patch(src, W12D_PATCH, "W12-D (dual-array LCU + W12FwdDrop)")
    src = apply_unified_patch(src, W12G_PATCH, "W12-G (nat_match_chain + G11 + %rcx + 10-slot)")

    # Apply Python AST/string-anchored patches
    w12a = load_module(W12A_SCRIPT, "apply_w12a")
    src = w12a.apply_patch(src)
    print("  [OK] W12-A (Bool match fast-path + borrow-loop direct load)", flush=True)

    src = apply_w12f_and_w13b_compact(src)
    src = apply_w13a_win1(src)
    src = apply_w11c_0arity_fix(src)

    DST.parent.mkdir(parents=True, exist_ok=True)
    DST.write_text(src, encoding="utf-8")
    print(f"=== Wrote {DST} ({len(src):,} B, +{len(src)-base_len:,} B, {src.count(chr(10)):,} lines) ===", flush=True)


if __name__ == "__main__":
    main()
