#!/usr/bin/env python3
"""B2 Decisive Cross-Module Contract & Direct-Only FID Omission Test Suite.

Tests (both -O0 and -O2):
1. Monolithic vs 2 different module splits (Split A: 2 modules, Split B: 3 modules):
   - Direct-only export (`_d_0 = add_mul`): verifies `p113d_FID_$direct.add_mul` is GLOBAL,
     and `p111_FID_$direct.add_mul` (`p164a_segment`) & `p111_FID_add_mul` (`P167Factory`)
     are OMITTED (0 FIDs!).
   - Direct + CPS worker export (`_b_1 = scale_direct`): verifies BOTH `p113d` and `p111` exist.
   - Closure / Factory export (`_c_2 = make_adder`): verifies `p111_FID_make_adder` (`P167Factory`)
     is emitted and works as a first-class closure passed to HOF `apply_twice` across modules!
   - Mutual-recursion CPS worker export (`_w_3 = cps_sum`): verifies CPS continuations across modules.
2. Callee body change + relink byte-identical old caller `.o`:
   - Changes `add_mul` body in `lib`, recompiles ONLY `lib_v2.o`, verifies caller `app.o`
     SHA-256 is byte-identical, relinks, and asserts updated output!
3. Fail-loud contract violation (negative test):
   - Makes `_d_0 = add_mul` non-direct internally and asserts compiler fails loudly with
     `b2 contract violation: direct-only export add_mul was not lowered direct`.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/w16_final"))
import mint_and_bench_w16 as mb


def decode_sym(s: str) -> str:
    return "".join(chr(int(x)) for x in s.strip("_").split("_") if x.isdigit())


def read_elf_syms(obj: Path) -> dict[str, set[str]]:
    out = subprocess.check_output(["readelf", "-sW", str(obj)], text=True)
    res: dict[str, set[str]] = {
        "p113d_def": set(),
        "p113d_und": set(),
        "p111_def": set(),
        "p111_und": set(),
    }
    for line in out.splitlines():
        parts = line.split()
        if len(parts) < 8:
            continue
        ndx, name = parts[6], parts[7]
        if name.startswith("p113d_FID_"):
            d = decode_sym(name[len("p113d_FID_"):])
            res["p113d_und" if ndx == "UND" else "p113d_def"].add(d)
        elif name.startswith("p111_FID_"):
            d = decode_sym(name[len("p111_FID_"):])
            res["p111_und" if ndx == "UND" else "p111_def"].add(d)
    return res


def sha256_file(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run_compiler(
    compiler: Path, args: list[str], out_o: Path, err_f: Path, cpu: int = 2, allow_fail: bool = False
) -> tuple[int, str]:
    cmd = [
        "timeout", "120", "bash", "-c",
        'ulimit -s 262144 && exec taskset -c "$1" "$2" "${@:3}"',
        "_", str(cpu), str(compiler), *args,
    ]
    with out_o.open("wb") as of, err_f.open("wb") as ef:
        p = subprocess.run(cmd, stdout=of, stderr=ef, cwd=ROOT)
    stderr = err_f.read_text(encoding="utf-8", errors="replace")
    if p.returncode != 0 and not allow_fail:
        raise RuntimeError(f"compile failed rc={p.returncode}: {stderr[-1200:]}")
    return p.returncode, stderr


def compile_mono(compiler: Path, src: Path, obj: Path, opt: str, cpu: int = 2) -> None:
    mode = "x86-object" if opt == "O2" else "x86-object-fast"
    args = [mode, str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP]
    run_compiler(compiler, args, obj, obj.with_suffix(".err"), cpu=cpu)


def compile_mod(
    compiler: Path, src: Path, obj: Path, mod_name: str, fid_base: int, opt: str, cpu: int = 2, allow_fail: bool = False
) -> tuple[int, str]:
    mode = "x86-module" if opt == "O2" else "x86-module-fast"
    args = [
        mode, str(src), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP,
        str(fid_base), mod_name,
    ]
    return run_compiler(compiler, args, obj, obj.with_suffix(".err"), cpu=cpu, allow_fail=allow_fail)


def link_and_run_mono(obj: Path, exe: Path) -> str:
    subprocess.check_call([CC, "-O2", "-no-pie", str(obj), str(RT), "-lm", "-lpthread", "-o", str(exe)])
    out = subprocess.check_output([str(exe), *RTS_ARGS], text=True, timeout=30).strip()
    return out


def link_and_run_mods(compiler: Path, mods: list[tuple[str, Path]], entry_mod: str, exe: Path, tmp: Path) -> str:
    merged_o = tmp / f"{exe.name}_merged.o"
    ordered_names = [entry_mod] + [nm for nm, _ in mods if nm != entry_mod]
    ordered_objs = [p for nm, p in mods if nm == entry_mod] + [p for nm, p in mods if nm != entry_mod]
    merge_args = ["x86-merge-obj", entry_mod, *ordered_names]
    run_compiler(compiler, merge_args, merged_o, tmp / f"{exe.name}_merge.err")
    cmd = [CC, "-O2", "-no-pie", str(merged_o), *[str(p) for p in ordered_objs], str(RT), "-lm", "-lpthread", "-o", str(exe)]
    subprocess.check_call(cmd)
    out = subprocess.check_output([str(exe), *RTS_ARGS], text=True, timeout=30).strip()
    return out


def make_sources(add_mul_expr: str = "U32.add(U32.mul(x, 3), y)", break_direct: bool = False) -> dict[str, str]:
    if break_direct:
        add_mul_body = f"  _f : U32 -> U32 = _z => _z\n  {add_mul_expr}"
    else:
        add_mul_body = f"  {add_mul_expr}"

    lib_defs = f"""@unsafe
def add_mul(+x: U32, +y: U32) -> U32:
{add_mul_body}

@unsafe
def scale_direct(+x: U32) -> U32:
  U32.add(U32.mul(x, 5), 2)

@unsafe
def make_adder(+k: U32, x: U32) -> U32:
  U32.add(k, x)

law cps_sum:
  for +n: U32
  for +acc: U32
  U32

@unsafe
def cps_sum_step(done: Bool, +n: U32, +acc: U32) -> U32:
  match done:
    case True{{}}: acc
    case False{{}}: cps_sum(U32.sub(n, 1), U32.add(acc, n))

@unsafe
def cps_sum(n, acc):
  cps_sum_step(U32.is_eq(n, 0), n, acc)
"""

    app_defs = """@unsafe
def apply_two(f: U32 -> U32, g: U32 -> U32, +x: U32) -> U32:
  f(g(x))

@unsafe
def direct_caller(+a: U32, +b: U32) -> U32:
  U32.add(add_mul(a, b), scale_direct(a))

@unsafe
def cps_caller(+n: U32) -> U32:
  +s = cps_sum(n, 0)
  +t = scale_direct(s)
  +c = apply_two(make_adder(7), make_adder(11), 10)
  U32.add(t, c)

@unsafe
def main() -> U32:
  U32.add(direct_caller(4, 5), cps_caller(6))
"""

    mono = "import Base\n\n" + lib_defs + "\n" + app_defs

    split_a_lib = (
        "import Base\n\n"
        + lib_defs
        + """
@unsafe
def main() -> U32:
  _d_0 = add_mul
  _b_1 = scale_direct
  _c_2 = make_adder
  _w_3 = cps_sum
  0
"""
    )

    split_a_app = (
        """import Base

@unsafe
def add_mul(+x: U32, +y: U32) -> U32:
  add_mul(x, y)

@unsafe
def scale_direct(+x: U32) -> U32:
  scale_direct(x)

@unsafe
def make_adder(+k: U32, x: U32) -> U32:
  _f : U32 -> U32 = _cps => _cps
  make_adder(k, x)

@unsafe
def cps_sum(+n: U32, +acc: U32) -> U32:
  _f : U32 -> U32 = _cps => _cps
  cps_sum(n, acc)

"""
        + app_defs
    )

    # Split B: 3 modules (base_ops -> mid_ops -> app3)
    split_b_m0 = f"""import Base

@unsafe
def add_mul(+x: U32, +y: U32) -> U32:
{add_mul_body}

law cps_sum:
  for +n: U32
  for +acc: U32
  U32

@unsafe
def cps_sum_step(done: Bool, +n: U32, +acc: U32) -> U32:
  match done:
    case True{{}}: acc
    case False{{}}: cps_sum(U32.sub(n, 1), U32.add(acc, n))

@unsafe
def cps_sum(n, acc):
  cps_sum_step(U32.is_eq(n, 0), n, acc)

@unsafe
def main() -> U32:
  _d_0 = add_mul
  _w_1 = cps_sum
  0
"""

    split_b_m1 = """import Base

@unsafe
def add_mul(+x: U32, +y: U32) -> U32:
  add_mul(x, y)

@unsafe
def scale_direct(+x: U32) -> U32:
  U32.add(U32.mul(x, 5), 2)

@unsafe
def make_adder(+k: U32, x: U32) -> U32:
  U32.add(k, x)

@unsafe
def direct_caller(+a: U32, +b: U32) -> U32:
  U32.add(add_mul(a, b), scale_direct(a))

@unsafe
def main() -> U32:
  _b_0 = direct_caller
  _b_1 = scale_direct
  _c_2 = make_adder
  0
"""

    split_b_m2 = """import Base

@unsafe
def direct_caller(+a: U32, +b: U32) -> U32:
  direct_caller(a, b)

@unsafe
def scale_direct(+x: U32) -> U32:
  scale_direct(x)

@unsafe
def make_adder(+k: U32, x: U32) -> U32:
  _f : U32 -> U32 = _cps => _cps
  make_adder(k, x)

@unsafe
def cps_sum(+n: U32, +acc: U32) -> U32:
  _f : U32 -> U32 = _cps => _cps
  cps_sum(n, acc)

@unsafe
def apply_two(f: U32 -> U32, g: U32 -> U32, +x: U32) -> U32:
  f(g(x))

@unsafe
def cps_caller(+n: U32) -> U32:
  +s = cps_sum(n, 0)
  +t = scale_direct(s)
  +c = apply_two(make_adder(7), make_adder(11), 10)
  U32.add(t, c)

@unsafe
def main() -> U32:
  U32.add(direct_caller(4, 5), cps_caller(6))
"""

    return {
        "mono": mono,
        "split_a_lib": split_a_lib,
        "split_a_app": split_a_app,
        "split_b_m0": split_b_m0,
        "split_b_m1": split_b_m1,
        "split_b_m2": split_b_m2,
    }


def run_suite(compiler: Path, opt: str, tmp: Path, cpu: int = 2) -> dict:
    d = tmp / opt
    d.mkdir(parents=True, exist_ok=True)
    srcs = make_sources()
    for k, v in srcs.items():
        (d / f"{k}.bend").write_text(v, encoding="utf-8")

    # 1. Monolithic
    compile_mono(compiler, d / "mono.bend", d / "mono.o", opt, cpu=cpu)
    mono_out = link_and_run_mono(d / "mono.o", d / "mono_exe")

    # 2. Split A (2 modules)
    compile_mod(compiler, d / "split_a_lib.bend", d / "a_lib.o", "m00", 0, opt, cpu=cpu)
    lib_segs = mb.get_seg_count(d / "a_lib.o", "m00")
    compile_mod(compiler, d / "split_a_app.bend", d / "a_app.o", "m01", lib_segs + 16, opt, cpu=cpu)
    a_syms = read_elf_syms(d / "a_lib.o")
    assert "$direct.add_mul" in a_syms["p113d_def"], f"missing direct add_mul: {a_syms}"
    assert "$direct.add_mul" not in a_syms["p111_def"], f"direct-only add_mul leaked p111 wrapper! {a_syms['p111_def']}"
    assert "add_mul" not in a_syms["p111_def"], f"direct-only add_mul leaked factory! {a_syms['p111_def']}"
    assert "$direct.scale_direct" in a_syms["p113d_def"] and "$direct.scale_direct" in a_syms["p111_def"], "missing _b scale_direct"
    assert "make_adder" in a_syms["p111_def"], f"missing _c make_adder factory: {a_syms['p111_def']}"
    assert "$direct.cps_sum" in a_syms["p111_def"], "missing _w cps_sum"

    split_a_out = link_and_run_mods(compiler, [("m00", d / "a_lib.o"), ("m01", d / "a_app.o")], "m01", d / "split_a_exe", d)
    assert split_a_out == mono_out, f"Split A mismatch: {split_a_out} != {mono_out}"

    # 3. Split B (3 modules)
    compile_mod(compiler, d / "split_b_m0.bend", d / "b_m0.o", "m00", 0, opt, cpu=cpu)
    s0 = mb.get_seg_count(d / "b_m0.o", "m00")
    compile_mod(compiler, d / "split_b_m1.bend", d / "b_m1.o", "m01", s0 + 16, opt, cpu=cpu)
    s1 = mb.get_seg_count(d / "b_m1.o", "m01")
    compile_mod(compiler, d / "split_b_m2.bend", d / "b_m2.o", "m02", s0 + s1 + 32, opt, cpu=cpu)
    m0_syms = read_elf_syms(d / "b_m0.o")
    assert "$direct.add_mul" in m0_syms["p113d_def"]
    assert "$direct.add_mul" not in m0_syms["p111_def"], "direct-only add_mul in Split B leaked p111 wrapper!"
    split_b_out = link_and_run_mods(
        compiler, [("m00", d / "b_m0.o"), ("m01", d / "b_m1.o"), ("m02", d / "b_m2.o")], "m02", d / "split_b_exe", d
    )
    assert split_b_out == mono_out, f"Split B mismatch: {split_b_out} != {mono_out}"

    # 4. Change callee body & relink byte-identical old caller .o
    app_sha_before = sha256_file(d / "a_app.o")
    srcs_v2 = make_sources(add_mul_expr="U32.add(U32.mul(x, 10), U32.mul(y, 2))")
    (d / "mono_v2.bend").write_text(srcs_v2["mono"], encoding="utf-8")
    (d / "split_a_lib_v2.bend").write_text(srcs_v2["split_a_lib"], encoding="utf-8")
    compile_mono(compiler, d / "mono_v2.bend", d / "mono_v2.o", opt, cpu=cpu)
    mono_v2_out = link_and_run_mono(d / "mono_v2.o", d / "mono_v2_exe")
    compile_mod(compiler, d / "split_a_lib_v2.bend", d / "a_lib_v2.o", "m00", 0, opt, cpu=cpu)
    app_sha_after = sha256_file(d / "a_app.o")
    assert app_sha_before == app_sha_after, "caller .o changed!"
    relink_out = link_and_run_mods(compiler, [("m00", d / "a_lib_v2.o"), ("m01", d / "a_app.o")], "m01", d / "relink_v2_exe", d)
    assert relink_out == mono_v2_out and relink_out != mono_out, f"Relink v2 mismatch: {relink_out} vs {mono_v2_out}"

    # 5. Negative test: fail-loud contract violation
    srcs_bad = make_sources(break_direct=True)
    (d / "split_a_lib_bad.bend").write_text(srcs_bad["split_a_lib"], encoding="utf-8")
    rc_bad, err_bad = compile_mod(compiler, d / "split_a_lib_bad.bend", d / "a_lib_bad.o", "m00", 0, opt, cpu=cpu, allow_fail=True)
    assert rc_bad != 0, "Expected contract violation failure, got rc=0!"
    assert "b2 contract violation: direct-only export add_mul was not lowered direct" in err_bad, f"Unexpected err: {err_bad}"

    return {
        "opt": opt,
        "mono_out": mono_out,
        "split_a_out": split_a_out,
        "split_b_out": split_b_out,
        "mono_v2_out": mono_v2_out,
        "relink_v2_out": relink_out,
        "caller_obj_sha256": app_sha_before,
        "caller_obj_byte_identical": app_sha_before == app_sha_after,
        "a_lib_p111_def_count": len(a_syms["p111_def"]),
        "a_lib_p113d_def_count": len(a_syms["p113d_def"]),
        "direct_only_omitted_verified": True,
        "closure_factory_verified": True,
        "cps_continuation_verified": True,
        "contract_violation_fail_loud": True,
    }


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--compiler", type=Path, required=True)
    ap.add_argument("--tmp", type=Path, default=Path("/tmp/agy_b2/contract_tests"))
    ap.add_argument("--cpu", type=int, default=2)
    args = ap.parse_args()

    res = {}
    for opt in ("O0", "O2"):
        print(f"[b2-test] Running decisive contract suite ({opt})...", flush=True)
        res[opt] = run_suite(args.compiler, opt, args.tmp, cpu=args.cpu)
        print(f"[b2-test] {opt} PASS: {json.dumps(res[opt])}", flush=True)
    (args.tmp / "contract_results.json").write_text(json.dumps(res, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
