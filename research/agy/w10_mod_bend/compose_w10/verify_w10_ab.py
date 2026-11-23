#!/usr/bin/env python3
"""100% Pure-Bend End-to-End A -> B Proof & ELF/Data-Section Audit on wave10_unified.

Uses ONLY `selfhost/build/agy/wave10_unified/api.mjs` (via `run_w10_cli.mjs` + `locked_node.sh`)
and `gcc-10` — ZERO C merge driver, ZERO `objcopy`, ZERO `build_iface_carrier.mjs`:
  1. `p111_cid_hot` in `.data` (Ndx=3, WA) & immutable tables in `.rodata` (Ndx=2, A) audit via `readelf`.
  2. Clean A -> B:
     - `x86-iface` on `prefix_v1.bend` -> `iface_v1.p130` + `stamp_v1`
     - `x86-module` on `modB_v1.bend` (fid_base=0, modB) -> `modB_v1.o` (0 objcopy)
     - `x86-module` on `modA_v1.bend` (fid_base=512, modA, using `iface_v1.p130` + `stamp_v1`) -> `modA_v1.o` (0 objcopy)
     - `x86-merge-obj modA modB modA` -> `merge.o` (0 C)
     - `readelf -SW` & `readelf -sW` audit of `modB_v1.o`, `modA_v1.o`, `merge.o`
     - `gcc-10 -no-pie merge.o modB_v1.o modA_v1.o runtime-agy.o -o app_v1 -lm -lpthread` -> exact `34`
     - Reverse link order `modA_v1.o modB_v1.o` -> exact `34`
  3. Body-only B edit (`base_prefix_stamp` `+10`):
     - `x86-iface` on `prefix_v2.bend` -> `iface_v2.p130` + `stamp_v2`
     - Verify `stamp_v2 == stamp_v1` (IDENTICAL!)
     - Rebuild ONLY `modB_v2.o`; reuse `modA_v1.o` untouched (verify SHA-256 & mtime unchanged)
     - Direct link with `merge.o` -> exact `44`
  4. Incompatible signature change (`base_prefix_stamp` adds `+bonus: U32`):
     - `x86-iface` on `prefix_v3.bend` -> `iface_v3.p130` + `stamp_v3`
     - Verify `stamp_v3 != stamp_v1` (CHANGED!)
     - Negative gate 1: stale `stamp_v1` against `iface_v3.p130` rejected (`rc != 0`)
     - Negative gate 2: stale `modA_v1.bend` against `iface_v3.p130` + `stamp_v3` rejected (`rc != 0`)
     - Rebuild `modB_v3.o` + `modA_v3.o` -> link with `merge.o` -> exact `54`
  5. `--trace x86-module` smoke check (confirms `--trace` preserved + M2 ELF vis intact).
  6. Cleans `/tmp/agy_w10_compose/` on exit.
"""
from __future__ import annotations

import hashlib
import json
import re
import shutil
import subprocess
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
API = ROOT / "selfhost/build/agy/wave10_unified/api.mjs"
CLI = ROOT / "research/agy/w10_mod_bend/compose_w10/run_w10_cli.mjs"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
TMP = Path("/tmp/agy_w10_compose")
OUT_JSON = ROOT / "research/agy/w10_mod_bend/compose_w10/ab_proof.json"

K_PREFIX = "p111_FID_36_112_49_49_49_46_107_46_"
MAIN_SYMS = {"p111_FID_109_97_105_110_", "p113d_FID_109_97_105_110_"}


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run_w10_cli(args: list[str], out_file: Path | None = None, check: bool = True) -> dict:
    cmd = ["bash", str(LOCKED_NODE), str(CLI), str(API), *args]
    t0 = time.perf_counter()
    if out_file is not None:
        with out_file.open("wb") as f:
            r = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, cwd=ROOT, timeout=300)
        stderr = r.stderr.decode("utf-8", errors="replace").strip()
        stdout = ""
    else:
        r = subprocess.run(cmd, capture_output=True, cwd=ROOT, timeout=300)
        stderr = r.stderr.decode("utf-8", errors="replace").strip()
        stdout = r.stdout.decode("utf-8", errors="replace").strip()
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    if check and r.returncode != 0:
        raise RuntimeError(f"w10 cli failed (rc={r.returncode}) args={args[:3]}: {stderr[:500]}")
    return {
        "rc": r.returncode,
        "ms": ms,
        "stderr": stderr,
        "stdout": stdout,
        "bytes": out_file.stat().st_size if (out_file and out_file.exists()) else 0,
    }


def audit_elf(obj: Path, expect_no_c_main: bool = True) -> dict:
    sec_out = subprocess.check_output(["readelf", "-SW", str(obj)], text=True)
    sym_out = subprocess.check_output(["readelf", "-sW", str(obj)], text=True)

    sh_info = None
    sections = {}
    for line in sec_out.splitlines():
        m_sec = re.match(r"^\s*\[\s*(\d+)\]\s+(\S+)\s+(\S+)\s+[0-9a-f]+\s+[0-9a-f]+\s+([0-9a-f]+)\s+[0-9a-f]+\s*(\S*)\s+(\d+)\s+(\d+)\s+(\d+)", line)
        if m_sec:
            idx, name, typ, sz, flg, lk, inf, al = m_sec.groups()
            sections[name] = {"ndx": int(idx), "type": typ, "flags": flg, "sh_info": int(inf)}
            if name == ".symtab":
                sh_info = int(inf)
    assert sh_info is not None, f"No .symtab in {obj}"

    syms = []
    for line in sym_out.splitlines():
        m = re.match(r"^\s*(\d+):\s+([0-9a-f]+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*(.*)$", line)
        if m:
            syms.append({
                "idx": int(m.group(1)),
                "size": int(m.group(3)),
                "type": m.group(4),
                "bind": m.group(5),
                "ndx": m.group(7),
                "name": m.group(8).strip(),
            })

    bad_local = [s for s in syms if s["bind"] == "LOCAL" and s["idx"] >= sh_info]
    bad_nonlocal = [s for s in syms if s["bind"] != "LOCAL" and s["idx"] < sh_info]
    assert not bad_local, f"LOCAL >= sh_info in {obj}: {bad_local[:3]}"
    assert not bad_nonlocal, f"non-LOCAL < sh_info in {obj}: {bad_nonlocal[:3]}"

    nonlocal_k = [s for s in syms if s["name"].startswith(K_PREFIX) and s["bind"] != "LOCAL"]
    assert not nonlocal_k, f"$p111.k.* non-LOCAL in {obj}: {nonlocal_k[:3]}"

    if expect_no_c_main:
        c_main = [s for s in syms if s["name"] == "main" and s["ndx"] != "UND"]
        assert not c_main, f"Unexpected C main in {obj}: {c_main}"

    cid_hot = [s for s in syms if s["name"] == "p111_cid_hot"]
    cid_arity = [s for s in syms if s["name"] == "p111_cid_arity"]

    return {
        "bytes": obj.stat().st_size,
        "total_syms": len(syms),
        "sh_info": sh_info,
        "local_def": sum(1 for s in syms if s["bind"] == "LOCAL" and s["ndx"] != "UND"),
        "global_def": sum(1 for s in syms if s["bind"] == "GLOBAL" and s["ndx"] != "UND"),
        "weak_def": sum(1 for s in syms if s["bind"] == "WEAK" and s["ndx"] != "UND"),
        "local_k": sum(1 for s in syms if s["name"].startswith(K_PREFIX) and s["bind"] == "LOCAL"),
        "cid_hot_ndx": cid_hot[0]["ndx"] if cid_hot else None,
        "cid_arity_ndx": cid_arity[0]["ndx"] if cid_arity else None,
        "rodata_sec": sections.get(".rodata"),
        "data_sec": sections.get(".data"),
        "sh_info_valid": True,
    }


def link_and_run(objs: list[Path], exe: Path) -> dict:
    t0 = time.perf_counter()
    r = subprocess.run(
        [CC, "-no-pie", *[str(o) for o in objs], str(RT), "-o", str(exe), "-lm", "-lpthread"],
        capture_output=True, text=True, check=True,
    )
    link_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    run = subprocess.run([str(exe)], capture_output=True, text=True, check=True, timeout=15)
    return {"link_ms": link_ms, "warnings": r.stderr.strip(), "output": run.stdout.strip()}


def split_slice(full_text: str) -> tuple[str, str, str]:
    marker = "\ndef w7_slice_len("
    idx = full_text.index(marker)
    prefix = full_text[:idx]
    modB_v1 = (
        prefix
        + "\ndef modB_touch(xs: List<&2, FToken>, acc: U32) -> U32:\n"
        + "  match xs:\n"
        + "    case Nil{}: acc\n"
        + "    case Con{h, t}: modB_touch(t, acc)\n"
        + "\ndef main() -> U32:\n"
        + "  +toks = f_lex_cursor(\"def foo(x: U32) -> U32:\\n  U32.add(x, 1)\\n\", 1, 1, 0, [], 0, 0)\n"
        + "  +n = base_prefix_stamp([], 16)\n"
        + "  modB_touch(toks, n)\n"
    )
    modA_v1 = "import Base\n" + full_text[idx:].lstrip()
    return prefix, modB_v1, modA_v1


def main() -> None:
    shutil.rmtree(TMP, ignore_errors=True)
    TMP.mkdir(parents=True)
    try:
        full_text = SLICE.read_text(encoding="utf-8")
        prefix_v1, modB_v1_txt, modA_v1_txt = split_slice(full_text)

        # v2: body-only edit to base_prefix_stamp (+10)
        old_bps_v1 = (
            "def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:\n"
            "  match book:\n"
            "    case Nil{}: bound\n"
            "    case Con{d, rest}: kc(U32, p88_string_eq(dk(d), \"BookCache\"), u => da(d), u => bound)"
        )
        new_bps_v2 = (
            "def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:\n"
            "  match book:\n"
            "    case Nil{}: U32.add(bound, 10)\n"
            "    case Con{d, rest}: kc(U32, p88_string_eq(dk(d), \"BookCache\"), u => da(d), u => U32.add(bound, 10))"
        )
        assert prefix_v1.count(old_bps_v1) == 1
        prefix_v2 = prefix_v1.replace(old_bps_v1, new_bps_v2, 1)
        modB_v2_txt = modB_v1_txt.replace(old_bps_v1, new_bps_v2, 1)

        # v3: incompatible signature change to base_prefix_stamp (+bonus: U32)
        new_bps_v3 = (
            "def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32, +bonus: U32) -> U32:\n"
            "  match book:\n"
            "    case Nil{}: U32.add(bound, bonus)\n"
            "    case Con{d, rest}: kc(U32, p88_string_eq(dk(d), \"BookCache\"), u => da(d), u => U32.add(bound, bonus))"
        )
        prefix_v3 = prefix_v1.replace(old_bps_v1, new_bps_v3, 1)
        modB_v3_txt = (
            modB_v1_txt
            .replace(old_bps_v1, new_bps_v3, 1)
            .replace("base_prefix_stamp([], 16)", "base_prefix_stamp([], 16, 20)", 1)
        )
        modA_v3_txt = modA_v1_txt.replace("base_prefix_stamp([], 16)", "base_prefix_stamp([], 16, 20)", 1)
        assert modA_v3_txt != modA_v1_txt

        for name, txt in [
            ("prefix_v1.bend", prefix_v1), ("modB_v1.bend", modB_v1_txt), ("modA_v1.bend", modA_v1_txt),
            ("prefix_v2.bend", prefix_v2), ("modB_v2.bend", modB_v2_txt),
            ("prefix_v3.bend", prefix_v3), ("modB_v3.bend", modB_v3_txt), ("modA_v3.bend", modA_v3_txt),
        ]:
            (TMP / name).write_text(txt, encoding="utf-8")

        # --- Step 1: Pure-Bend x86-merge-obj (0 C) ---
        print("=== Step 1: Pure-Bend x86-merge-obj (0 C) ===", flush=True)
        merge_o = TMP / "merge.o"
        merge_res = run_w10_cli(["x86-merge-obj", "modA", "modB", "modA"], out_file=merge_o)
        merge_audit = audit_elf(merge_o, expect_no_c_main=False)
        print(f"  merge.o: {merge_res['bytes']:,} B in {merge_res['ms']} ms", flush=True)

        # --- Step 2: Case 1 Clean A -> B (0 C, 0 objcopy, 0 JS iface) ---
        print("=== Step 2: Case 1 Clean A -> B ===", flush=True)
        iface_v1 = TMP / "iface_v1.p130"
        if1 = run_w10_cli(["x86-iface", str(TMP / "modB_v1.bend"), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], out_file=iface_v1)
        stamp_v1 = if1["stderr"].splitlines()[-1].strip()
        assert stamp_v1.startswith("p130-word-pair-v1:w10-iface-v1:"), f"Bad stamp_v1: {stamp_v1}"

        modB_v1_o = TMP / "modB_v1.o"
        mb1 = run_w10_cli(["x86-module", str(TMP / "modB_v1.bend"), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP, "0", "modB"], out_file=modB_v1_o)
        modB_v1_audit = audit_elf(modB_v1_o)

        # Verify p111_cid_hot in .data (Ndx=3, WA) and p111_cid_arity in .rodata (Ndx=2, A)
        assert modB_v1_audit["cid_hot_ndx"] == "3", f"p111_cid_hot not in .data (3): {modB_v1_audit}"
        assert modB_v1_audit["data_sec"]["flags"] == "WA", f".data flags not WA: {modB_v1_audit['data_sec']}"
        assert modB_v1_audit["cid_arity_ndx"] == "2", f"p111_cid_arity not in .rodata (2): {modB_v1_audit}"
        assert modB_v1_audit["rodata_sec"]["flags"] == "A", f".rodata flags not A: {modB_v1_audit['rodata_sec']}"

        modA_v1_o = TMP / "modA_v1.o"
        ma1 = run_w10_cli(["x86-module", str(TMP / "modA_v1.bend"), str(BASE_FILE), "cache", str(iface_v1), stamp_v1, "512", "modA"], out_file=modA_v1_o)
        modA_v1_audit = audit_elf(modA_v1_o)
        modA_v1_sha = sha256(modA_v1_o)
        modA_v1_mtime = modA_v1_o.stat().st_mtime_ns

        link_v1 = link_and_run([merge_o, modB_v1_o, modA_v1_o], TMP / "app_v1")
        link_v1_rev = link_and_run([merge_o, modA_v1_o, modB_v1_o], TMP / "app_v1_rev")
        assert link_v1["output"] == "34", f"Expected 34, got {link_v1}"
        assert link_v1_rev["output"] == "34", f"Expected 34 (rev), got {link_v1_rev}"
        print(f"  [PASS] Case 1 Clean A->B: stamp={stamp_v1} out={link_v1['output']} (rev={link_v1_rev['output']})", flush=True)

        # --- Step 3: Case 2 Body-only B edit (+10) -> modA_v1.o reused untouched -> 44 ---
        print("=== Step 3: Case 2 Body-only B edit (+10) ===", flush=True)
        iface_v2 = TMP / "iface_v2.p130"
        if2 = run_w10_cli(["x86-iface", str(TMP / "modB_v2.bend"), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], out_file=iface_v2)
        stamp_v2 = if2["stderr"].splitlines()[-1].strip()
        assert stamp_v2 == stamp_v1, f"Body-only edit changed stamp! {stamp_v1} vs {stamp_v2}"

        modB_v2_o = TMP / "modB_v2.o"
        mb2 = run_w10_cli(["x86-module", str(TMP / "modB_v2.bend"), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP, "0", "modB"], out_file=modB_v2_o)
        assert sha256(modA_v1_o) == modA_v1_sha and modA_v1_o.stat().st_mtime_ns == modA_v1_mtime
        link_v2 = link_and_run([merge_o, modB_v2_o, modA_v1_o], TMP / "app_v2")
        assert link_v2["output"] == "44", f"Expected 44, got {link_v2}"
        print(f"  [PASS] Case 2 Body-only B edit: stamp IDENTICAL ({stamp_v2}), modA_v1.o reused untouched -> out={link_v2['output']}", flush=True)

        # --- Step 4: Case 3 Incompatible signature change (+bonus: U32) -> stale rejected, rebuilt -> 54 ---
        print("=== Step 4: Case 3 Incompatible signature change (+bonus: U32) ===", flush=True)
        iface_v3 = TMP / "iface_v3.p130"
        if3 = run_w10_cli(["x86-iface", str(TMP / "modB_v3.bend"), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], out_file=iface_v3)
        stamp_v3 = if3["stderr"].splitlines()[-1].strip()
        assert stamp_v3 != stamp_v1, f"Sig change did not change stamp! {stamp_v3}"

        neg_stale_stamp = run_w10_cli(
            ["x86-module", str(TMP / "modA_v1.bend"), str(BASE_FILE), "cache", str(iface_v3), stamp_v1, "512", "modA"],
            out_file=TMP / "neg1.o", check=False,
        )
        assert neg_stale_stamp["rc"] != 0, f"Stale stamp should have been rejected: {neg_stale_stamp}"

        neg_stale_modA = run_w10_cli(
            ["x86-module", str(TMP / "modA_v1.bend"), str(BASE_FILE), "cache", str(iface_v3), stamp_v3, "512", "modA"],
            out_file=TMP / "neg2.o", check=False,
        )
        assert neg_stale_modA["rc"] != 0, f"Stale modA_v1 should have been rejected: {neg_stale_modA}"

        modB_v3_o = TMP / "modB_v3.o"
        mb3 = run_w10_cli(["x86-module", str(TMP / "modB_v3.bend"), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP, "0", "modB"], out_file=modB_v3_o)
        modA_v3_o = TMP / "modA_v3.o"
        ma3 = run_w10_cli(["x86-module", str(TMP / "modA_v3.bend"), str(BASE_FILE), "cache", str(iface_v3), stamp_v3, "512", "modA"], out_file=modA_v3_o)
        link_v3 = link_and_run([merge_o, modB_v3_o, modA_v3_o], TMP / "app_v3")
        assert link_v3["output"] == "54", f"Expected 54, got {link_v3}"
        print(f"  [PASS] Case 3 Sig change: stamp CHANGED ({stamp_v3}), stale rejected (rc={neg_stale_stamp['rc']},{neg_stale_modA['rc']}), rebuilt -> out={link_v3['output']}", flush=True)

        # --- Step 5: --trace x86-module smoke check ---
        print("=== Step 5: --trace x86-module smoke check ===", flush=True)
        modA_tr_o = TMP / "modA_tr.o"
        tr_res = run_w10_cli(["--trace", "x86-module", str(TMP / "modA_v1.bend"), str(BASE_FILE), "cache", str(iface_v1), stamp_v1, "512", "modA"], out_file=modA_tr_o)
        tr_audit = audit_elf(modA_tr_o)
        assert "[bend-trace]" in tr_res["stderr"] and "stage=x187_elf" in tr_res["stderr"], f"Missing trace lines: {tr_res['stderr']}"
        print(f"  [PASS] --trace x86-module: {len(tr_res['stderr'].splitlines())} trace lines, ELF sh_info valid", flush=True)

        out = {
            "merge_obj": {"ms": merge_res["ms"], "bytes": merge_res["bytes"], "audit": merge_audit},
            "case1_clean": {
                "stamp": stamp_v1,
                "iface_ms": if1["ms"], "iface_bytes": if1["bytes"],
                "modB_ms": mb1["ms"], "modB_audit": modB_v1_audit,
                "modA_ms": ma1["ms"], "modA_audit": modA_v1_audit,
                "link_forward": link_v1, "link_reverse": link_v1_rev,
            },
            "case2_body_only": {
                "stamp": stamp_v2, "stamp_identical": stamp_v2 == stamp_v1,
                "iface_ms": if2["ms"], "modB_ms": mb2["ms"],
                "modA_reused_untouched": True, "link": link_v2,
            },
            "case3_sig_change": {
                "stamp": stamp_v3, "stamp_changed": stamp_v3 != stamp_v1,
                "iface_ms": if3["ms"],
                "neg_stale_stamp": {"rc": neg_stale_stamp["rc"], "stderr": neg_stale_stamp["stderr"][:200]},
                "neg_stale_modA": {"rc": neg_stale_modA["rc"], "stderr": neg_stale_modA["stderr"][:200]},
                "modB_ms": mb3["ms"], "modA_ms": ma3["ms"], "link": link_v3,
            },
            "trace_x86_module": {
                "ms": tr_res["ms"], "lines": tr_res["stderr"].splitlines(), "audit": tr_audit,
            },
        }
        OUT_JSON.write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
        print(f"[DONE] Saved {OUT_JSON}", flush=True)
    finally:
        shutil.rmtree(TMP, ignore_errors=True)


if __name__ == "__main__":
    main()
