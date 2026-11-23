#!/usr/bin/env python3
"""Native wave8-native-self/n1 Cross-Module A -> B Benchmark (Task 5).

Ports `research/agy/w8_mod_split/test_cross_module_ab.py` Case 1 (Clean A -> B)
and Case 2 (Body-Only B Edit reusing modA.o byte-for-byte) from JS `api.mjs` to
native `selfhost/build/agy/wave8-native-self/n1` (`x86-object` and `x86-module`).
"""
from __future__ import annotations

import hashlib
import json
import os
import resource
import shutil
import subprocess
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
N1 = ROOT / "selfhost/build/agy/wave8-native-self/n1"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
BUILD_IFACE = ROOT / "research/agy/w7_modules/build_iface_carrier.mjs"
MERGE_C = ROOT / "research/agy/w8_fid_base/p111_link_merge.c"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
BASE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
TMP = Path("/tmp/agy_w9_mod_compiler/native_ab")


def set_stack_limit():
    limit = 262144 * 1024
    resource.setrlimit(resource.RLIMIT_STACK, (limit, limit))


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def inspect_obj(obj_path: Path) -> dict:
    obj_bytes = obj_path.stat().st_size
    text_bytes = 0
    out_s = subprocess.check_output(["readelf", "-SW", str(obj_path)], text=True)
    for line in out_s.splitlines():
        parts = line.split()
        if len(parts) >= 7:
            idx = 1 if parts[0].startswith("[") and parts[0].endswith("]") else 2
            if idx < len(parts) and parts[idx] == ".text" and idx + 4 < len(parts):
                text_bytes = int(parts[idx + 4], 16)
    nm_out = subprocess.check_output(["nm", "-S", "--defined-only", str(obj_path)], text=True)
    p111_syms = 0
    p113d_syms = 0
    mod_segs = None
    for line in nm_out.splitlines():
        parts = line.split()
        if len(parts) < 3:
            continue
        if len(parts) >= 4:
            sz_hex, typ, sym = parts[1], parts[2], parts[3]
            if sym.endswith("_p111_fid_arity") or sym == "p111_fid_arity":
                mod_segs = int(sz_hex, 16)
        else:
            typ, sym = parts[1], parts[2]
        if typ in ("T", "t"):
            if sym.startswith("p111_FID_"):
                p111_syms += 1
            elif sym.startswith("p113d_FID_"):
                p113d_syms += 1
    return {
        "obj_bytes": obj_bytes,
        "text_bytes": text_bytes,
        "seg_count": mod_segs if mod_segs is not None else p111_syms,
        "p111_syms": p111_syms,
        "p113d_syms": p113d_syms,
    }


def run_n1(
    src: Path,
    out_o: Path,
    *,
    mode: str,
    mod_name: str = "m0",
    fid_base: int = 0,
    base_p: Path = BASE,
    carrier_p: Path = BASE_CARRIER,
    stamp: str = BASE_STAMP,
    cpu: str = "0",
) -> dict:
    err_p = out_o.with_suffix(".err")
    if mode == "mono":
        cmd = ["taskset", "-c", cpu, str(N1), "x86-object", str(src), str(base_p), "cache", str(carrier_p), stamp]
    else:
        cmd = [
            "taskset", "-c", cpu, str(N1), "x86-module",
            str(src), str(base_p), "cache", str(carrier_p), stamp,
            str(fid_base), mod_name,
        ]
    t0 = time.perf_counter()
    with open(out_o, "wb") as fo, open(err_p, "wb") as fe:
        p = subprocess.Popen(cmd, stdout=fo, stderr=fe, preexec_fn=set_stack_limit)
        _, status, ru = os.wait4(p.pid, 0)
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    rc = os.waitstatus_to_exitcode(status)
    rss_mib = round(ru.ru_maxrss / 1024.0, 1)
    if rc != 0:
        raise RuntimeError(f"n1 {mode} failed on {src.name} (rc={rc}): {err_p.read_text(errors='replace')[:500]}")
    return {"wall_ms": wall_ms, "rss_mib": rss_mib, **inspect_obj(out_o)}


def build_iface(prefix_bend: Path, modB_o: Path, top_bend: Path, out_dir: Path) -> tuple[dict, float]:
    out_dir.mkdir(parents=True, exist_ok=True)
    t0 = time.perf_counter()
    r = subprocess.run(
        [
            "bash", str(LOCKED_NODE), str(BUILD_IFACE),
            "--prefix", str(prefix_bend),
            "--prefix-obj", str(modB_o),
            "--top", str(top_bend),
            "--out-dir", str(out_dir),
        ],
        capture_output=True, text=True, cwd=ROOT,
    )
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    if r.returncode != 0:
        raise RuntimeError(f"build_iface failed (rc={r.returncode}): {r.stderr[:500]} {r.stdout[:500]}")
    meta = json.loads((out_dir / "iface_meta.json").read_text())
    return meta, wall_ms


def get_globals(obj: Path) -> set[str]:
    out = subprocess.check_output(["nm", "-g", "--defined-only", str(obj)], text=True)
    return {line.split()[2] for line in out.splitlines() if len(line.split()) >= 3}


def prepare_module_objs(modB_o: Path, modA_o: Path, modB_prep: Path, modA_prep: Path) -> float:
    t0 = time.perf_counter()
    K_PREFIX = "p111_FID_36_112_49_49_49_46_107_46_"
    b_raw_syms = get_globals(modB_o)
    b_cmd = ["objcopy", "-L", "main"]
    for s in sorted(b_raw_syms):
        if s in ("p111_FID_109_97_105_110_", "p113d_FID_109_97_105_110_") or s.startswith(K_PREFIX):
            b_cmd.extend(["-L", s])
    b_cmd.extend([str(modB_o), str(modB_prep)])
    subprocess.run(b_cmd, check=True)

    b_syms = get_globals(modB_prep)
    a_syms = get_globals(modA_o)
    cmd = ["objcopy", "-L", "main"]
    for s in sorted(a_syms):
        if s.startswith(K_PREFIX):
            cmd.extend(["-L", s])
        elif s in b_syms and s != "main":
            cmd.extend(["-W", s])
    cmd.extend([str(modA_o), str(modA_prep)])
    subprocess.run(cmd, check=True)
    return round((time.perf_counter() - t0) * 1000.0, 1)


def link_merged(modB_prep: Path, modA_prep: Path, exe: Path) -> tuple[float, str]:
    t0 = time.perf_counter()
    merge_o = exe.with_suffix(".merge.o")
    subprocess.run(
        [
            CC, "-O2", "-c", str(MERGE_C),
            "-DW8_ENTRY_MOD=modA",
            "-DW8_MODULES(X)=X(modB) X(modA)",
            "-o", str(merge_o),
        ],
        check=True,
    )
    subprocess.run(
        [CC, "-no-pie", str(merge_o), str(modB_prep), str(modA_prep), str(RT), "-o", str(exe), "-lm", "-lpthread"],
        check=True,
    )
    link_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    out = subprocess.run([str(exe)], capture_output=True, text=True, check=True, timeout=15).stdout.strip()
    return link_ms, out


def link_mono(mono_o: Path, exe: Path) -> tuple[float, str]:
    t0 = time.perf_counter()
    subprocess.run([CC, "-no-pie", str(mono_o), str(RT), "-o", str(exe), "-lm", "-lpthread"], check=True)
    link_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    out = subprocess.run([str(exe)], capture_output=True, text=True, check=True, timeout=15).stdout.strip()
    return link_ms, out


def split_slice(full_text: str) -> tuple[str, str, str]:
    marker = "\ndef w7_slice_len("
    idx = full_text.index(marker)
    prefix = full_text[:idx]
    modB_src = (
        prefix
        + "\ndef modB_touch(xs: List<&2, FToken>, acc: U32) -> U32:\n"
        + "  match xs:\n"
        + "    case Nil{}: acc\n"
        + "    case Con{h, t}: modB_touch(t, acc)\n"
        + "\ndef main() -> U32:\n"
        + '  +toks = f_lex_cursor("def foo(x: U32) -> U32:\\n  U32.add(x, 1)\\n", 1, 1, 0, [], 0, 0)\n'
        + "  +n = base_prefix_stamp([], 16)\n"
        + "  modB_touch(toks, n)\n"
    )
    modA_src = "import Base\n" + full_text[idx:].lstrip()
    return prefix, modB_src, modA_src


def main() -> None:
    if TMP.exists():
        shutil.rmtree(TMP)
    TMP.mkdir(parents=True)

    full_text = SLICE.read_text()
    prefix_v1, modB_v1_txt, modA_v1_txt = split_slice(full_text)

    mono_v1_src = TMP / "mono_v1.bend"
    mono_v1_src.write_text(full_text)
    prefix_v1_src = TMP / "prefix_v1.bend"
    prefix_v1_src.write_text(prefix_v1)
    modB_v1_src = TMP / "modB_v1.bend"
    modB_v1_src.write_text(modB_v1_txt)
    modA_v1_src = TMP / "modA_v1.bend"
    modA_v1_src.write_text(modA_v1_txt)

    # Case 1: Clean A -> B vs Monolithic (all compiles on native n1)
    mono_v1_o = TMP / "mono_v1.o"
    mono_v1 = run_n1(mono_v1_src, mono_v1_o, mode="mono")
    mono_v1_link_ms, mono_v1_out = link_mono(mono_v1_o, TMP / "mono_v1.exe")

    modB_v1_o = TMP / "modB_v1.o"
    modB_v1 = run_n1(modB_v1_src, modB_v1_o, mode="module", mod_name="modB", fid_base=0)

    iface_v1_meta, iface_v1_wall = build_iface(prefix_v1_src, modB_v1_o, modA_v1_src, TMP / "iface_v1")
    iface_v1 = Path(iface_v1_meta["carrierPath"])
    iface_v1_stamp = iface_v1_meta["stamp"]
    iface_v1_base = Path(iface_v1_meta["combinedPath"])

    modA_v1_o = TMP / "modA_v1.o"
    modA_v1 = run_n1(
        modA_v1_src, modA_v1_o,
        mode="module", mod_name="modA", fid_base=512,
        base_p=iface_v1_base, carrier_p=iface_v1, stamp=iface_v1_stamp,
    )
    modA_sha_before = sha256(modA_v1_o)
    modA_mtime_before = modA_v1_o.stat().st_mtime_ns

    prep_v1_ms = prepare_module_objs(modB_v1_o, modA_v1_o, TMP / "modB_v1.prep.o", TMP / "modA_v1.prep.o")
    link_v1_ms, sep_v1_out = link_merged(TMP / "modB_v1.prep.o", TMP / "modA_v1.prep.o", TMP / "sep_v1.exe")
    assert sep_v1_out == mono_v1_out == "34", f"Case 1 mismatch: sep={sep_v1_out} mono={mono_v1_out}"

    # Case 2: Body-only edit to B -> rebuild ONLY modB.o with native n1, reuse modA.o!
    old_bps = "def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:\n  match book:\n    case Nil{}: bound"
    new_bps = "def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:\n  match book:\n    case Nil{}: U32.add(bound, 10)"
    full_v2 = full_text.replace(old_bps, new_bps, 1)
    _, modB_v2_txt, _ = split_slice(full_v2)

    mono_v2_src = TMP / "mono_v2.bend"
    mono_v2_src.write_text(full_v2)
    mono_v2_o = TMP / "mono_v2.o"
    mono_v2 = run_n1(mono_v2_src, mono_v2_o, mode="mono")
    mono_v2_link_ms, mono_v2_out = link_mono(mono_v2_o, TMP / "mono_v2.exe")

    modB_v2_src = TMP / "modB_v2.bend"
    modB_v2_src.write_text(modB_v2_txt)
    modB_v2_o = TMP / "modB_v2.o"
    modB_v2 = run_n1(modB_v2_src, modB_v2_o, mode="module", mod_name="modB", fid_base=0)

    assert sha256(modA_v1_o) == modA_sha_before
    assert modA_v1_o.stat().st_mtime_ns == modA_mtime_before
    prep_v2_ms = prepare_module_objs(modB_v2_o, modA_v1_o, TMP / "modB_v2.prep.o", TMP / "modA_v1_reused.prep.o")
    link_v2_ms, sep_v2_out = link_merged(TMP / "modB_v2.prep.o", TMP / "modA_v1_reused.prep.o", TMP / "sep_v2.exe")
    assert sep_v2_out == mono_v2_out == "44", f"Case 2 mismatch: sep={sep_v2_out} mono={mono_v2_out}"

    res = {
        "compiler": str(N1),
        "case1_clean_ab": {
            "mono_out": mono_v1_out,
            "sep_out": sep_v1_out,
            "mono": mono_v1,
            "mono_link_ms": mono_v1_link_ms,
            "modB": modB_v1,
            "iface_js_wall_ms": iface_v1_wall,
            "modA": modA_v1,
            "objcopy_ms": prep_v1_ms,
            "merge_link_ms": link_v1_ms,
            "total_sep_ms": round(modB_v1["wall_ms"] + iface_v1_wall + modA_v1["wall_ms"] + prep_v1_ms + link_v1_ms, 1),
            "total_sep_no_iface_ms": round(modB_v1["wall_ms"] + modA_v1["wall_ms"] + prep_v1_ms + link_v1_ms, 1),
        },
        "case2_body_only_b_edit": {
            "mono_out": mono_v2_out,
            "sep_out": sep_v2_out,
            "mono": mono_v2,
            "mono_link_ms": mono_v2_link_ms,
            "modA_reused_sha256_identical": True,
            "modB_rebuild": modB_v2,
            "objcopy_ms": prep_v2_ms,
            "merge_link_ms": link_v2_ms,
            "total_edit_ms": round(modB_v2["wall_ms"] + prep_v2_ms + link_v2_ms, 1),
        },
    }
    out_p = ROOT / "research/agy/w9_mod_compiler/native_ab_results.json"
    out_p.write_text(json.dumps(res, indent=2) + "\n")
    print(json.dumps(res, indent=2))


if __name__ == "__main__":
    main()
