#!/usr/bin/env python3
"""Phase 3B-fast: Compile K=12 modules (m00..m11) using cached .p130 interfaces,
exports-only root `main()` (eliminating ~3,600 forced internal CPS wrappers),
`x86-module-fast`, and pure-Bend `x86-merge-obj` -> `wave10-native-mod/n2_mod`.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
API = ROOT / "selfhost/build/agy/wave10_unified/api.mjs"
CLI = ROOT / "research/agy/w10_mod_bend/compose_w10/run_w10_cli.mjs"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
K12_DIR = ROOT / "research/agy/w10_mod_bend/k12_modules"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"

TMP = Path("/tmp/agy_p3_k12")
IFACE_DIR = TMP / "iface"
SRC_DIR = TMP / "src_exp"
OBJ_DIR = TMP / "obj_exp"
NATIVE_DIR = ROOT / "selfhost/build/agy/wave10-native-mod"
N2_MOD = NATIVE_DIR / "n2_mod"
OUT_JSON = ROOT / "research/agy/w10_mod_bend/p3_k12_build/k12_n2_mod_results.json"

TMPL_1ARG = {"kc", "f_choose", "nt_choose", "nt_count_go", "nt_reverse", "p151_choose", "nt_count", "nt_append"}
TMPL_CUSTOM = {"p134v_list": "p134v_list(U32, U32.is_eq)"}


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def parse_p130_stamp(path: Path) -> str:
    txt = path.read_text(encoding="utf-8")
    lo = ord(txt[0]) - 65536
    hi = ord(txt[1]) - 65536
    slen = lo + hi * 65536
    return txt[2 : 2 + slen]


def get_seg_count(obj: Path, mod_name: str) -> int:
    out = subprocess.check_output(["readelf", "-sW", str(obj)], text=True)
    target = f"p111_mod_{mod_name}_p111_segments"
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 8 and parts[7] == target:
            sz = int(parts[2], 0)
            return sz // 8
    raise RuntimeError(f"Could not find {target} in {obj}")


def run_w10_cli(args: list[str], out_file: Path, timeout: int = 300) -> tuple[float, str]:
    cmd = ["bash", str(LOCKED_NODE), str(CLI), str(API), *args]
    env = os.environ.copy()
    env["AGY_NODE_MAX_MB"] = "4096"
    t0 = time.perf_counter()
    with out_file.open("wb") as f:
        r = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, cwd=ROOT, env=env, timeout=timeout)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = r.stderr.decode("utf-8", errors="replace").strip()
    if r.returncode != 0:
        raise RuntimeError(f"w10 cli failed (rc={r.returncode}) args={args[:3]}: {stderr[:600]}")
    return ms, stderr


def main() -> None:
    SRC_DIR.mkdir(parents=True, exist_ok=True)
    OBJ_DIR.mkdir(parents=True, exist_ok=True)
    NATIVE_DIR.mkdir(parents=True, exist_ok=True)

    types_text = (K12_DIR / "types.bend").read_text(encoding="utf-8")
    mod_names = [f"m{i:02d}" for i in range(12)]
    mod_texts = [ (K12_DIR / f"{m}.bend").read_text(encoding="utf-8") for m in mod_names ]

    # Build exports-only sources for m00..m10; m11 keeps real compiler `main`.
    # Note: m00 imports Base + defines all 391 types; m01..m11 get all 391 types from m{i-1}.p130!
    src_paths: dict[str, Path] = {}
    for i, m in enumerate(mod_names):
        prefix = (types_text + "\n") if i == 0 else "import Base\n"
        if i == 11:
            full = prefix + mod_texts[i]
            n_exp = 0
        else:
            defs = re.findall(r"^def\s+([A-Za-z0-9_.\$]+)\s*[\(:]", mod_texts[i], re.M)
            later = "\n".join(mod_texts[i + 1 :])
            later_idents = set(re.findall(r"[A-Za-z_][A-Za-z0-9_.\$]*", later))
            exps = [d for d in defs if d in later_idents]
            n_exp = len(exps)
            lines = ["\n@unsafe\ndef main() -> U32:"]
            for d in exps:
                if d in TMPL_CUSTOM:
                    lines.append(f"  _ = {TMPL_CUSTOM[d]}")
                elif d in TMPL_1ARG:
                    lines.append(f"  _ = {d}(U32)")
                else:
                    lines.append(f"  _ = {d}")
            lines.append("  0\n")
            full = prefix + mod_texts[i] + "\n".join(lines)
        p = SRC_DIR / f"{m}_exp.bend"
        p.write_text(full, encoding="utf-8")
        src_paths[m] = p

    # Load cached .p130 chain from /tmp/agy_p3_k12/iface/
    carriers: list[tuple[Path, str]] = [(BASE_CARRIER, BASE_STAMP)]
    for i in range(11):
        p130 = IFACE_DIR / f"m{i:02d}.p130"
        assert p130.exists(), f"Missing cached carrier {p130}"
        carriers.append((p130, parse_p130_stamp(p130)))

    print("=== Phase B (exports-only + x86-module-fast): m00.o .. m11.o ===", flush=True)
    fid_base = 0
    mod_records = []
    mod_objs: list[Path] = []
    t_all0 = time.perf_counter()
    for i, m in enumerate(mod_names):
        in_carrier, in_stamp = carriers[i]
        out_o = OBJ_DIR / f"{m}.o"
        print(f"  [{i+1}/12] x86-module-fast {m} (fid_base={fid_base}, carrier={in_carrier.name}) ...", flush=True)
        ms, _ = run_w10_cli(
            ["x86-module-fast", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fid_base), m],
            out_file=out_o,
        )
        segs = get_seg_count(out_o, m)
        rec = {
            "module": m,
            "fid_base": fid_base,
            "seg_count": segs,
            "fid_end": fid_base + segs - 1,
            "ms": ms,
            "bytes": out_o.stat().st_size,
            "sha256": sha256(out_o),
        }
        mod_records.append(rec)
        mod_objs.append(out_o)
        fid_base += segs
        print(f"    OK {m}.o: {rec['bytes']:,} B | segs={segs:,} (total_fids={fid_base:,}/65,532) | {ms} ms", flush=True)

    # Pure-Bend x86-merge-obj (0 C!) — put entry module m11 first so p111_program inherits m11's IO(U32) metadata!
    merge_o = OBJ_DIR / "merge.o"
    print("=== Phase C: Pure-Bend x86-merge-obj (0 C) + gcc-10 link (0 objcopy) ===", flush=True)
    merge_ms, _ = run_w10_cli(["x86-merge-obj", "m11", "m11", *mod_names[:11]], out_file=merge_o)
    print(f"  OK merge.o: {merge_o.stat().st_size:,} B | {merge_ms} ms", flush=True)

    t_lk0 = time.perf_counter()
    subprocess.run(
        [CC, "-O2", "-no-pie", str(merge_o), *[str(o) for o in mod_objs], str(RT), "-o", str(N2_MOD), "-lm", "-lpthread"],
        check=True,
    )
    link_ms = round((time.perf_counter() - t_lk0) * 1000.0, 1)
    total_wall_ms = round((time.perf_counter() - t_all0) * 1000.0, 1)
    print(f"  LINKED {N2_MOD} ({N2_MOD.stat().st_size:,} B) in {link_ms} ms! (Phase B+C total={total_wall_ms} ms)", flush=True)

    # Verify n2_mod --trace x86-object-fast on compiler_slice.bend
    print("=== Phase D: Verify n2_mod --trace x86-object-fast on compiler_slice.bend ===", flush=True)
    sm_o = OBJ_DIR / "smoke.o"
    sm_exe = OBJ_DIR / "smoke.exe"
    t_sm0 = time.perf_counter()
    with sm_o.open("wb") as f:
        r_sm = subprocess.run(
            ["bash", "-c", f"ulimit -s 262144 && taskset -c 2 {N2_MOD} --trace x86-object-fast {SLICE} {BASE_FILE} cache {BASE_CARRIER} {BASE_STAMP}"],
            stdout=f, stderr=subprocess.PIPE, check=True, timeout=120,
        )
    sm_ms = round((time.perf_counter() - t_sm0) * 1000.0, 1)
    trace_lines = r_sm.stderr.decode("utf-8", errors="replace").strip().splitlines()
    subprocess.run([CC, "-no-pie", str(sm_o), str(RT), "-o", str(sm_exe), "-lm", "-lpthread"], check=True)
    sm_out = subprocess.run([str(sm_exe)], capture_output=True, text=True, check=True, timeout=30).stdout.strip()
    print(f"  N2_MOD SMOKE_OUT={sm_out!r} in {sm_ms} ms ({len(trace_lines)} --trace lines)", flush=True)
    for tl in trace_lines:
        print(f"    {tl}", flush=True)
    assert sm_out == "34", f"Expected 34, got {sm_out!r}"

    # Phase E: 1-Module Body Edit on m11 (reuse m00.o .. m10.o untouched!)
    print("=== Phase E: 1-Module Body Edit on m11 (11/12 .o reused untouched!) ===", flush=True)
    shas_before = {m: sha256(OBJ_DIR / f"{m}.o") for m in mod_names[:11]}
    m11_edit_src = SRC_DIR / "m11_edit.bend"
    m11_orig = src_paths["m11"].read_text(encoding="utf-8")
    # Body-only edit to a trace string in m11
    m11_edited = m11_orig.replace('"[bend-trace] "', '"[bend-trace-v2] "', 1)
    assert m11_edited != m11_orig
    m11_edit_src.write_text(m11_edited, encoding="utf-8")
    m11_edit_o = OBJ_DIR / "m11_edit.o"
    m11_fid_base = mod_records[11]["fid_base"]
    edit_compile_ms, _ = run_w10_cli(
        ["x86-module-fast", str(m11_edit_src), str(BASE_FILE), "cache", str(carriers[11][0]), carriers[11][1], str(m11_fid_base), "m11"],
        out_file=m11_edit_o,
    )
    shas_after = {m: sha256(OBJ_DIR / f"{m}.o") for m in mod_names[:11]}
    assert shas_before == shas_after, "Upstream .o SHA mismatch!"
    n2_edit = OBJ_DIR / "n2_mod_edit"
    t_elk0 = time.perf_counter()
    subprocess.run(
        [CC, "-O2", "-no-pie", str(merge_o), *[str(o) for o in mod_objs[:11]], str(m11_edit_o), str(RT), "-o", str(n2_edit), "-lm", "-lpthread"],
        check=True,
    )
    edit_link_ms = round((time.perf_counter() - t_elk0) * 1000.0, 1)
    with sm_o.open("wb") as f:
        r_ed = subprocess.run(
            ["bash", "-c", f"ulimit -s 262144 && taskset -c 2 {n2_edit} --trace x86-object-fast {SLICE} {BASE_FILE} cache {BASE_CARRIER} {BASE_STAMP}"],
            stdout=f, stderr=subprocess.PIPE, check=True, timeout=120,
        )
    ed_trace = r_ed.stderr.decode("utf-8", errors="replace")
    assert "[bend-trace-v2]" in ed_trace, f"Expected [bend-trace-v2] in stderr: {ed_trace[:300]}"
    print(f"  1-MODULE EDIT PASS! 11/12 .o SHA-256 untouched, m11 rebuild={edit_compile_ms} ms, relink={edit_link_ms} ms, observed [bend-trace-v2]!", flush=True)

    out = {
        "total_fids": fid_base,
        "fid_limit": 65532,
        "modules": mod_records,
        "merge_ms": merge_ms,
        "link_ms": link_ms,
        "n2_mod_bytes": N2_MOD.stat().st_size,
        "smoke_out": sm_out,
        "smoke_ms": sm_ms,
        "trace_lines": trace_lines,
        "edit_m11": {
            "reused_11_of_12_sha256_identical": True,
            "m11_rebuild_ms": edit_compile_ms,
            "relink_ms": edit_link_ms,
            "total_edit_ms": round(edit_compile_ms + edit_link_ms, 1),
            "observed_v2_trace": True,
        },
    }
    OUT_JSON.write_text(json.dumps(out, indent=2) + "\n")
    print(f"\nALL K=12 MODULAR SELF-BUILD PHASES PASSED! Saved {OUT_JSON}", flush=True)


if __name__ == "__main__":
    main()
