#!/usr/bin/env python3
"""Apply trace_slow.bend to copies of compiler.bend and m11.bend, run --check-only,
and build native /tmp/agy_p5_trace_slow/n3_trace_slow on CPU 0.
"""
from __future__ import annotations

import difflib
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
W10_COMP = ROOT / "selfhost/build/agy/wave10_unified/compiler.bend"
M11_SRC = ROOT / "research/agy/w10_mod_bend/k12_wave10/m11.bend"
TS_BEND = ROOT / "research/agy/w10_mod_bend/p5_trace_slow/trace_slow.bend"
PATCH_OUT = ROOT / "research/agy/w10_mod_bend/p5_trace_slow/trace_slow.patch"

LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
N3_O2 = ROOT / "selfhost/build/agy/wave10-native-mod/n3_w10"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
IFACE_M10 = Path("/tmp/agy_k12_iface_cache/m10.p130")
OBJ_O2_DIR = Path("/tmp/agy_p5_o2/obj_o2")
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"

TMP = Path("/tmp/agy_p5_trace_slow")

OLD_DISPATCH = """@unsafe
def w8_dispatch_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+head,+rest}:
      nt_choose(IO(U32),agy_str_eq(head,"--trace"),
        u => w8_tr_entry(rest),
        u => nt_choose(IO(U32),agy_str_eq(head,"x86-merge-obj"),
          v => w10_merge_entry(rest),
          v => x181_entry_args(Con{head,rest})))
    case Nil{}: x181_entry_args(Nil{})"""

NEW_DISPATCH = """@unsafe
def w8_dispatch_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+head,+rest}:
      nt_choose(IO(U32),agy_str_eq(head,"--trace-slow"),
        u => ts_parse_thresh(rest),
        u => nt_choose(IO(U32),agy_str_eq(head,"--trace"),
          v => w8_tr_entry(rest),
          v => nt_choose(IO(U32),agy_str_eq(head,"x86-merge-obj"),
            w => w10_merge_entry(rest),
            w => x181_entry_args(Con{head,rest}))))
    case Nil{}: x181_entry_args(Nil{})"""


def parse_p130_stamp(path: Path) -> str:
    txt = path.read_text(encoding="utf-8")
    lo = ord(txt[0]) - 65536
    hi = ord(txt[1]) - 65536
    slen = lo + hi * 65536
    return txt[2 : 2 + slen]


def get_seg_count(obj: Path, mod_name: str) -> int:
    out = subprocess.check_output(["readelf", "-sW", str(obj)], text=True)
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 8 and parts[7] == f"p111_mod_{mod_name}_p111_fid_arity":
            return int(parts[2], 0)
    raise RuntimeError(f"Could not find seg count for {mod_name} in {obj}")


def patch_text(src: str, ts_code: str) -> str:
    assert src.count(OLD_DISPATCH) == 1, f"Expected 1 occurrence of w8_dispatch_args, got {src.count(OLD_DISPATCH)}"
    return src.replace(OLD_DISPATCH, ts_code.strip() + "\n\n" + NEW_DISPATCH, 1)


def main() -> None:
    TMP.mkdir(parents=True, exist_ok=True)
    ts_code = TS_BEND.read_text(encoding="utf-8")

    # 1. Patch compiler.bend copy & emit unified diff patch
    comp_orig = W10_COMP.read_text(encoding="utf-8")
    comp_patched = patch_text(comp_orig, ts_code)
    comp_ts_path = TMP / "compiler_ts.bend"
    comp_ts_path.write_text(comp_patched, encoding="utf-8")

    diff_lines = list(
        difflib.unified_diff(
            comp_orig.splitlines(keepends=True),
            comp_patched.splitlines(keepends=True),
            fromfile="selfhost/build/agy/wave10_unified/compiler.bend",
            tofile="selfhost/build/agy/wave10_unified/compiler.bend",
        )
    )
    PATCH_OUT.write_text("".join(diff_lines), encoding="utf-8")
    print(f"Wrote {PATCH_OUT} ({len(diff_lines)} lines)")

    # 2. Run --check-only on CPU 0 (unless --skip-check)
    if "--skip-check" not in sys.argv:
        print("Running --check-only on compiler_ts.bend (CPU 0)...")
        t0 = time.perf_counter()
        r = subprocess.run(
            ["taskset", "-c", "0", "bash", str(LOCKED_BUN), str(comp_ts_path), "--check-only"],
            capture_output=True,
            text=True,
            cwd=ROOT,
        )
        dt = time.perf_counter() - t0
        only_unsafe_audit = (
            r.returncode == 1
            and "rely on unsafe or foreign code:" in r.stderr
            and r.stderr.count("Error:") == 1
        )
        print(f"--check-only rc={r.returncode} only_unsafe_audit={only_unsafe_audit} ({dt:.2f}s)")
        if r.returncode != 0 and not only_unsafe_audit:
            if r.stdout:
                print("STDOUT:", r.stdout[:1000])
            if r.stderr:
                print("STDERR:", r.stderr[:1000])
            raise SystemExit(r.returncode)

    # 3. Patch m11.bend copy & compile m11_ts.o with n3_o2 on CPU 0
    m11_orig = M11_SRC.read_text(encoding="utf-8")
    m11_patched = "import Base\n" + patch_text(m11_orig, ts_code)
    m11_ts_path = TMP / "m11_ts.bend"
    m11_ts_path.write_text(m11_patched, encoding="utf-8")

    m10_stamp = parse_p130_stamp(IFACE_M10)
    m11_o = TMP / "m11_ts.o"
    print(f"Compiling m11_ts.bend -> {m11_o} with n3_o2 x86-module-fast (CPU 0)...")
    t0 = time.perf_counter()
    cmd = [
        "bash", "-c",
        'ulimit -s 262144 && exec taskset -c 0 "$1" "${@:2}"',
        "_", str(N3_O2),
        "--trace", "x86-module-fast",
        str(m11_ts_path), str(BASE_FILE), "cache", str(IFACE_M10), m10_stamp,
        "59979", "m11",
    ]
    with m11_o.open("wb") as f:
        r = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, cwd=ROOT)
    dt = time.perf_counter() - t0
    print(f"m11_ts.o rc={r.returncode} ({dt:.2f}s) size={m11_o.stat().st_size}")
    print(r.stderr.decode("utf-8", errors="replace").strip())
    if r.returncode != 0:
        raise SystemExit(r.returncode)

    # 4. Run x86-merge-obj for m00..m10 (from /tmp/agy_p5_o2/obj_o2) + m11_ts.o
    mod_specs = []
    fid = 0
    mod_objs = []
    for i in range(12):
        m = f"m{i:02d}"
        obj = m11_o if i == 11 else (OBJ_O2_DIR / f"{m}.o")
        segs = get_seg_count(obj, m)
        mod_specs.append(f"{m}:{fid}:{segs}")
        fid += segs
        mod_objs.append(obj)
    print(f"Total merged segments: {fid} (m11_ts segs={mod_specs[-1]})")

    merge_o = TMP / "merge_ts.o"
    cmd_merge = [
        "bash", "-c",
        'ulimit -s 262144 && exec taskset -c 0 "$1" "${@:2}"',
        "_", str(N3_O2), "x86-merge-obj", *mod_specs,
    ]
    with merge_o.open("wb") as f:
        r = subprocess.run(cmd_merge, stdout=f, stderr=subprocess.PIPE, cwd=ROOT)
    if r.returncode != 0:
        print(r.stderr.decode("utf-8", errors="replace"))
        raise SystemExit(r.returncode)

    # 5. Link n3_trace_slow
    out_bin = TMP / "n3_trace_slow"
    subprocess.run(
        ["taskset", "-c", "0", CC, "-O2", "-no-pie", str(merge_o), *[str(o) for o in mod_objs], str(RT), "-o", str(out_bin), "-lm", "-lpthread"],
        check=True,
    )
    print(f"Built {out_bin} ({out_bin.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
