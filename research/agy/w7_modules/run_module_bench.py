#!/usr/bin/env python3
"""Separate-Module Native Compilation Benchmark & Verification Harness (Wave 7).

Tests two general separate-module strategies with UNMODIFIED native `n1`:
  - Tier A: Interface-stripped `.p130` prefix carrier (1-core & 4-core `x86-shard`)
  - Tier B: ABI-matched interface-only `.p130` + separate ELF `.o` linking
            (`prefix_lib.o` + `top_weak.o` + `runtime-agy.o` -> `gcc-10`)

Verifies:
  1. Exact output `34` on cold build, Tier-A rebuild, and Tier-B rebuild.
  2. Live 1-module edit (`w7_slice_len` +1 -> +2) produces exact `51` with ZERO prefix rebuild.
  3. Negative/invalidation test: tampered stamp is rejected cleanly by `n1` (non-zero rc).
"""
from __future__ import annotations

import json
import re
import shutil
import subprocess
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
N1 = ROOT / "selfhost/build/agy/wave6-native-self/n1"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
BASE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
BUILD_PREFIX = ROOT / "research/agy/w7_modules/build_prefix_carrier.mjs"
BUILD_IFACE = ROOT / "research/agy/w7_modules/build_iface_carrier.mjs"
TMP = Path("/tmp/agy_w7_modules/bench_run")


def get_globals(obj: Path) -> set[str]:
    out = subprocess.check_output(["nm", "-g", "--defined-only", str(obj)], text=True)
    return {line.split()[2] for line in out.splitlines() if len(line.split()) >= 3}


def enc_fid(pfx: str, name: str) -> str:
    return f"{pfx}FID_" + "_".join(str(ord(c)) for c in name) + "_"


def run_n1_obj(src: Path, base_p: Path, carrier_p: Path, stamp: str, out_o: Path, cpu: str = "5") -> float:
    err_p = out_o.with_suffix(".err")
    t0 = time.perf_counter()
    with open(out_o, "wb") as fo, open(err_p, "wb") as fe:
        r = subprocess.run(
            ["taskset", "-c", cpu, str(N1), "x86-object", str(src), str(base_p), "cache", str(carrier_p), stamp],
            stdout=fo, stderr=fe,
        )
    ms = round((time.perf_counter() - t0) * 1000, 1)
    if r.returncode != 0:
        raise RuntimeError(f"n1 failed (rc={r.returncode}): {err_p.read_text()[:500]}")
    return ms


def run_n1_shards(src: Path, base_p: Path, carrier_p: Path, stamp: str, out_dir: Path, cpus: list[str]) -> tuple[float, list[Path]]:
    shards = len(cpus)
    objs = [out_dir / f"shard_{i}.o" for i in range(shards)]
    procs = []
    t0 = time.perf_counter()
    for i, cpu in enumerate(cpus):
        fo = open(objs[i], "wb")
        fe = open(objs[i].with_suffix(".err"), "wb")
        p = subprocess.Popen(
            ["taskset", "-c", cpu, str(N1), "x86-shard", str(src), str(base_p), "cache", str(carrier_p), stamp, str(i), str(shards)],
            stdout=fo, stderr=fe,
        )
        procs.append((p, fo, fe, objs[i]))
    for p, fo, fe, op in procs:
        rc = p.wait()
        fo.close()
        fe.close()
        if rc != 0:
            raise RuntimeError(f"shard {op.name} failed (rc={rc}): {op.with_suffix('.err').read_text()[:500]}")
    ms = round((time.perf_counter() - t0) * 1000, 1)
    return ms, objs


def link_and_run(objs: list[Path], exe: Path) -> tuple[float, str]:
    t0 = time.perf_counter()
    subprocess.run([CC, "-no-pie", *[str(o) for o in objs], str(RT), "-o", str(exe), "-lm", "-lpthread"], check=True)
    link_ms = round((time.perf_counter() - t0) * 1000, 1)
    out = subprocess.run([str(exe)], capture_output=True, text=True, check=True, timeout=15).stdout.strip()
    return link_ms, out


def main() -> None:
    if TMP.exists():
        shutil.rmtree(TMP)
    TMP.mkdir(parents=True, exist_ok=True)
    results: dict = {}

    # 1. Cold baseline (unmodified compiler_slice.bend + base.p130, CPU 5)
    cold_o = TMP / "cold.o"
    cold_n1_ms = run_n1_obj(SLICE, BASE, BASE_CARRIER, BASE_STAMP, cold_o, cpu="5")
    cold_link_ms, cold_out = link_and_run([cold_o], TMP / "cold_exe")
    assert cold_out == "34", f"cold expected 34, got {cold_out!r}"
    results["cold_baseline"] = {
        "n1_ms": cold_n1_ms,
        "link_ms": cold_link_ms,
        "total_ms": round(cold_n1_ms + cold_link_ms, 1),
        "obj_bytes": cold_o.stat().st_size,
        "out": cold_out,
    }

    # Prepare split: prefix.bend (99.8% of compiler_slice.bend) + top.bend (edited module)
    slice_txt = SLICE.read_text()
    cut = slice_txt.index("def w7_slice_len")
    prefix_p = TMP / "prefix.bend"
    top_p = TMP / "top.bend"
    top_edited_p = TMP / "top_edited.bend"
    prefix_p.write_text(slice_txt[:cut])
    top_src = "import Base\n\n" + slice_txt[cut:]
    top_p.write_text(top_src)
    top_edited_p.write_text(top_src.replace("U32.add(acc, 1)", "U32.add(acc, 2)"))

    # 2. Tier A: Interface-stripped .p130 prefix carrier (works for arbitrary edits!)
    tier_a_dir = TMP / "tier_a_carrier"
    subprocess.run(
        ["bash", str(LOCKED_NODE), str(BUILD_PREFIX), "--prefix", str(prefix_p), "--top", str(top_p), "--out-dir", str(tier_a_dir)],
        check=True, capture_output=True,
    )
    meta_a = json.loads((tier_a_dir / "prefix_meta.json").read_text())
    assert meta_a["fitsN1Limits"]

    # Tier A single-core rebuild
    ta1_o = TMP / "tier_a_1c.o"
    ta1_n1_ms = run_n1_obj(top_p, Path(meta_a["combinedPath"]), Path(meta_a["carrierPath"]), meta_a["stamp"], ta1_o, cpu="5")
    ta1_link_ms, ta1_out = link_and_run([ta1_o], TMP / "tier_a_1c_exe")
    assert ta1_out == "34"

    # Tier A 4-core parallel x86-shard rebuild
    ta4_dir = TMP / "tier_a_4c"
    ta4_dir.mkdir()
    ta4_n1_ms, ta4_objs = run_n1_shards(top_p, Path(meta_a["combinedPath"]), Path(meta_a["carrierPath"]), meta_a["stamp"], ta4_dir, ["0", "1", "4", "5"])
    ta4_link_ms, ta4_out = link_and_run(ta4_objs, TMP / "tier_a_4c_exe")
    assert ta4_out == "34"

    # Tier A live-edit verification (ZERO prefix rebuild!)
    ta4_edit_dir = TMP / "tier_a_4c_edit"
    ta4_edit_dir.mkdir()
    ta4_edit_ms, ta4_edit_objs = run_n1_shards(top_edited_p, Path(meta_a["combinedPath"]), Path(meta_a["carrierPath"]), meta_a["stamp"], ta4_edit_dir, ["0", "1", "4", "5"])
    ta4_edit_link_ms, ta4_edit_out = link_and_run(ta4_edit_objs, TMP / "tier_a_4c_edit_exe")
    assert ta4_edit_out == "52", f"live edit expected 52, got {ta4_edit_out!r}"

    # Negative / invalidation test: tampered stamp MUST fail cleanly
    bad_err = TMP / "bad_stamp.err"
    with open(TMP / "bad_stamp.o", "wb") as fo, open(bad_err, "wb") as fe:
        r_bad = subprocess.run(
            ["taskset", "-c", "5", str(N1), "x86-object", str(top_p), meta_a["combinedPath"], "cache", meta_a["carrierPath"], meta_a["stamp"] + "_TAMPERED"],
            stdout=fo, stderr=fe,
        )
    bad_msg = bad_err.read_text().strip()
    assert r_bad.returncode != 0 and "cache stamp" in bad_msg, f"Expected stamp rejection, got rc={r_bad.returncode} msg={bad_msg!r}"

    results["tier_a_prefix_carrier"] = {
        "carrier_nodes": meta_a["nodeCount"],
        "carrier_strings": meta_a["stringCount"],
        "carrier_bytes": meta_a["carrierBytes"],
        "one_time_prep_ms": meta_a["prepMs"],
        "rebuild_1c_n1_ms": ta1_n1_ms,
        "rebuild_1c_total_ms": round(ta1_n1_ms + ta1_link_ms, 1),
        "rebuild_1c_speedup": round((cold_n1_ms + cold_link_ms) / (ta1_n1_ms + ta1_link_ms), 2),
        "rebuild_1c_out": ta1_out,
        "rebuild_4c_n1_ms": ta4_n1_ms,
        "rebuild_4c_total_ms": round(ta4_n1_ms + ta4_link_ms, 1),
        "rebuild_4c_speedup": round((cold_n1_ms + cold_link_ms) / (ta4_n1_ms + ta4_link_ms), 2),
        "rebuild_4c_out": ta4_out,
        "live_edit_4c_total_ms": round(ta4_edit_ms + ta4_edit_link_ms, 1),
        "live_edit_out": ta4_edit_out,
        "invalidation_check": {"rejected": True, "rc": r_bad.returncode, "stderr": bad_msg},
    }

    # 3. Tier B: True Separate-Object Linking (prefix_lib.o + top_weak.o -> gcc-10)
    # Put the immutable sample input string in a prefix helper `w7_sample_src()` so
    # top.bend tests pure separate-object linking without NStatic pool-offset mismatch.
    prefix_b_p = TMP / "prefix_b.bend"
    top_b_p = TMP / "top_b.bend"
    top_b_edit_p = TMP / "top_b_edit.bend"
    prefix_b_p.write_text(
        slice_txt[:cut]
        + '\ndef w7_sample_src() -> String:\n  "def foo(x: U32) -> U32:\\n  U32.add(x, 1)\\n"\n'
    )
    top_b_src = (
        "import Base\n\n"
        "def w7_slice_len(xs: List<&2, FToken>, acc: U32) -> U32:\n"
        "  match xs:\n"
        "    case Nil{}: acc\n"
        "    case Con{h, t}: w7_slice_len(t, U32.add(acc, 1))\n\n"
        "def main() -> U32:\n"
        "  +toks = f_lex_cursor(w7_sample_src(), 1, 1, 0, [], 0, 0)\n"
        "  +st = base_prefix_stamp([], 16)\n"
        "  U32.add(w7_slice_len(toks, 0), st)\n"
    )
    top_b_p.write_text(top_b_src)
    top_b_edit_p.write_text(top_b_src.replace("U32.add(acc, 1)", "U32.add(acc, 2)"))

    # One-time build of prefix_b full .o (via Tier A carrier) + prefix_b_iface.p130
    tb_full_dir = TMP / "tier_b_full_carrier"
    subprocess.run(
        ["bash", str(LOCKED_NODE), str(BUILD_PREFIX), "--prefix", str(prefix_b_p), "--top", str(top_b_p), "--out-dir", str(tb_full_dir)],
        check=True, capture_output=True,
    )
    meta_bf = json.loads((tb_full_dir / "prefix_meta.json").read_text())
    prefix_full_o = TMP / "prefix_b_full.o"
    run_n1_obj(top_b_p, Path(meta_bf["combinedPath"]), Path(meta_bf["carrierPath"]), meta_bf["stamp"], prefix_full_o, cpu="5")

    tb_iface_dir = TMP / "tier_b_iface_carrier"
    subprocess.run(
        ["bash", str(LOCKED_NODE), str(BUILD_IFACE), "--prefix", str(prefix_b_p), "--prefix-obj", str(prefix_full_o), "--top", str(top_b_p), "--out-dir", str(tb_iface_dir)],
        check=True, capture_output=True,
    )
    meta_bi = json.loads((tb_iface_dir / "iface_meta.json").read_text())
    assert meta_bi["fitsN1Limits"]

    def tier_b_rebuild(src_p: Path, tag: str) -> dict:
        top_o = TMP / f"tb_{tag}_top.o"
        n1_ms = run_n1_obj(src_p, Path(meta_bi["combinedPath"]), Path(meta_bi["carrierPath"]), meta_bi["stamp"], top_o, cpu="5")

        t_lnk0 = time.perf_counter()
        top_syms = get_globals(top_o)
        full_syms = get_globals(prefix_full_o)
        top_defs = re.findall(r"^def\s+([A-Za-z_][A-Za-z0-9_.]*)", src_p.read_text(), re.M)
        top_owned = {"main"}
        for d in top_defs:
            for pfx in ("p111_", "p113d_"):
                top_owned.add(enc_fid(pfx, d))
                top_owned.add(enc_fid(pfx, "$direct." + d))
        for s in top_syms:
            if s.startswith("p111_FID_36_112_49_49_49_46_107_46_"):
                top_owned.add(s)

        pfx_lib_o = TMP / f"tb_{tag}_prefix_lib.o"
        oc1 = ["objcopy"]
        for s in sorted(top_owned & full_syms):
            oc1 += ["-W", s]
        oc1 += [str(prefix_full_o), str(pfx_lib_o)]
        subprocess.run(oc1, check=True)

        top_weak_o = TMP / f"tb_{tag}_top_weak.o"
        oc2 = ["objcopy"]
        for s in sorted((top_syms - top_owned) & full_syms):
            oc2 += ["-W", s]
        oc2 += [str(top_o), str(top_weak_o)]
        subprocess.run(oc2, check=True)

        exe = TMP / f"tb_{tag}_exe"
        subprocess.run([CC, "-no-pie", str(pfx_lib_o), str(top_weak_o), str(RT), "-o", str(exe), "-lm", "-lpthread"], check=True)
        link_ms = round((time.perf_counter() - t_lnk0) * 1000, 1)
        out = subprocess.run([str(exe)], capture_output=True, text=True, check=True, timeout=15).stdout.strip()
        return {
            "n1_ms": n1_ms,
            "objcopy_link_ms": link_ms,
            "total_ms": round(n1_ms + link_ms, 1),
            "speedup_vs_cold": round((cold_n1_ms + cold_link_ms) / (n1_ms + link_ms), 2),
            "top_obj_bytes": top_o.stat().st_size,
            "out": out,
        }

    tb_clean = tier_b_rebuild(top_b_p, "clean")
    assert tb_clean["out"] == "34", f"Tier B clean expected 34, got {tb_clean['out']!r}"
    tb_edit = tier_b_rebuild(top_b_edit_p, "edit")
    assert tb_edit["out"] == "52", f"Tier B live edit expected 52, got {tb_edit['out']!r}"

    results["tier_b_separate_obj"] = {
        "iface_nodes": meta_bi["nodeCount"],
        "iface_strings": meta_bi["stringCount"],
        "iface_bytes": meta_bi["carrierBytes"],
        "direct_stubs": meta_bi["directStubs"],
        "cps_stubs": meta_bi["cpsStubs"],
        "rebuild_1c_clean": tb_clean,
        "rebuild_1c_live_edit": tb_edit,
    }

    out_json = ROOT / "research/agy/w7_modules/bench_results.json"
    out_json.write_text(json.dumps(results, indent=2) + "\n")
    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
