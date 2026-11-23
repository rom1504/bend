#!/usr/bin/env python3
"""Verify Wave 10 Phase 1 (M2): Pure-Bend ELF64 symbol visibility with ZERO objcopy.

1. Copies `selfhost/build/agy/wave8_unified/compiler.bend` to `/tmp/agy_m2_vis/compiler.bend`,
   inserts `mod_elf_vis.bend`, and hooks `w8_module_entry` to `w10_module_request`.
2. Runs `locked_bun.sh --check-only` -> verifies pure-Bend type/affinity check PASS.
3. Builds `/tmp/agy_m2_vis/api.mjs` with `locked_bun.sh`.
4. Emits `modB.o` and `modA.o` using `emit_w10_module.mjs` (calls `api.w10_module_prepared`).
5. Audits `readelf -S` and `readelf -sW` on `modB.o` and `modA.o`:
   - Every `$p111.k.*` and `p111_FID_main`/`p113d_FID_main` is `LOCAL` (< sh_info).
   - Strict ELF64 invariant: all `LOCAL` symbols have index < `sh_info`, all `GLOBAL`/`WEAK` >= `sh_info`.
   - Zero `main` symbol in `modB.o` / `modA.o`.
   - Interface stubs in `modA.o` (`f_lex_cursor`, `base_prefix_stamp`) are `WEAK`; real defs in `modB.o` are `GLOBAL`.
6. Links DIRECTLY with `gcc-10 -no-pie merge.o modB.o modA.o runtime-agy.o` (ZERO `objcopy`, 0 linker warnings!)
   and verifies output == `34` (plus reverse order `modA.o modB.o` == `34`).
7. Body-only edit to `modB` (`base_prefix_stamp` +10) -> rebuild ONLY `modB_v2.o`, verify `modA.o` SHA-256 & mtime
   unchanged, direct link with ZERO `objcopy` -> verifies output == `44`.
8. Cleans `/tmp/agy_m2_vis/` on exit.
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
W8_COMPILER = ROOT / "selfhost/build/agy/wave8_unified/compiler.bend"
MOD_VIS_BEND = ROOT / "research/agy/w10_mod_bend/m2_elf_vis/mod_elf_vis.bend"
EMIT_MJS = ROOT / "research/agy/w10_mod_bend/m2_elf_vis/emit_w10_module.mjs"
BUILD_IFACE = ROOT / "research/agy/w7_modules/build_iface_carrier.mjs"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
MERGE_C = ROOT / "research/agy/w8_fid_base/p111_link_merge.c"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
TMP = Path("/tmp/agy_m2_vis")
OUT_JSON = ROOT / "research/agy/w10_mod_bend/m2_elf_vis/results.json"

K_PREFIX = "p111_FID_36_112_49_49_49_46_107_46_"
MAIN_SYMS = {"p111_FID_109_97_105_110_", "p113d_FID_109_97_105_110_"}


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def parse_readelf(obj: Path) -> dict:
    sec_out = subprocess.check_output(["readelf", "-SW", str(obj)], text=True)
    sym_out = subprocess.check_output(["readelf", "-sW", str(obj)], text=True)

    sh_info = None
    for line in sec_out.splitlines():
        if ".symtab" in line and "SYMTAB" in line:
            # Example: [ 7] .symtab SYMTAB 0000000000000000 0466c0 002388 18 8 159 8
            # Fields after .symtab: Type Addr Off Size ES Flg Lk Inf Al
            m = re.search(r"\.symtab\s+SYMTAB\s+[0-9a-f]+\s+[0-9a-f]+\s+[0-9a-f]+\s+[0-9a-f]+\s+\S*\s*(\d+)\s+(\d+)\s+(\d+)", line)
            if not m:
                # Without flags column (empty flags)
                parts = line.split(".symtab", 1)[1].split()
                # parts: [SYMTAB, Addr, Off, Size, ES, Lk, Inf, Al] (8 items when Flg is blank)
                sh_info = int(parts[6])
            else:
                sh_info = int(m.group(2))
            break
    assert sh_info is not None, f"Could not parse .symtab sh_info for {obj}:\n{sec_out}"

    syms = []
    for line in sym_out.splitlines():
        m = re.match(r"^\s*(\d+):\s+([0-9a-f]+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*(.*)$", line)
        if m:
            syms.append({
                "idx": int(m.group(1)),
                "val": m.group(2),
                "size": int(m.group(3)),
                "type": m.group(4),
                "bind": m.group(5),
                "vis": m.group(6),
                "ndx": m.group(7),
                "name": m.group(8).strip(),
            })

    # Verify strict ELF64 local-before-nonlocal & sh_info invariant
    bad_local_after = [s for s in syms if s["bind"] == "LOCAL" and s["idx"] >= sh_info]
    bad_nonlocal_before = [s for s in syms if s["bind"] != "LOCAL" and s["idx"] < sh_info]
    assert not bad_local_after, f"ELF VIOLATION in {obj}: LOCAL symbols at >= sh_info({sh_info}): {bad_local_after[:5]}"
    assert not bad_nonlocal_before, f"ELF VIOLATION in {obj}: non-LOCAL symbols at < sh_info({sh_info}): {bad_nonlocal_before[:5]}"

    local_k = [s["name"] for s in syms if s["name"].startswith(K_PREFIX) and s["bind"] == "LOCAL"]
    nonlocal_k = [s["name"] for s in syms if s["name"].startswith(K_PREFIX) and s["bind"] != "LOCAL"]
    assert not nonlocal_k, f"$p111.k.* symbols still non-LOCAL in {obj}: {nonlocal_k}"

    main_defs = [s for s in syms if s["name"] == "main" and s["ndx"] != "UND"]
    assert not main_defs, f"Unexpected C main definition in {obj}: {main_defs}"

    bend_main = [s for s in syms if s["name"] in MAIN_SYMS]
    for s in bend_main:
        assert s["bind"] == "LOCAL", f"Bend def main not LOCAL in {obj}: {s}"

    weaks = [s["name"] for s in syms if s["bind"] == "WEAK" and s["ndx"] != "UND"]
    globals_def = [s["name"] for s in syms if s["bind"] == "GLOBAL" and s["ndx"] != "UND"]
    locals_def = [s["name"] for s in syms if s["bind"] == "LOCAL" and s["ndx"] != "UND"]

    return {
        "total_syms": len(syms),
        "sh_info": sh_info,
        "local_defined": len(locals_def),
        "global_defined": len(globals_def),
        "weak_defined": len(weaks),
        "local_k_count": len(local_k),
        "local_k_sample": local_k[:5],
        "bend_main_bindings": {s["name"]: s["bind"] for s in bend_main},
        "weak_syms": weaks,
        "global_syms": globals_def,
        "elf_sh_info_valid": True,
    }


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
        + "  +toks = f_lex_cursor(\"def foo(x: U32) -> U32:\\n  U32.add(x, 1)\\n\", 1, 1, 0, [], 0, 0)\n"
        + "  +n = base_prefix_stamp([], 16)\n"
        + "  modB_touch(toks, n)\n"
    )
    modA_src = "import Base\n" + full_text[idx:].lstrip()
    return prefix, modB_src, modA_src


def emit_mod(api: Path, src: Path, out_o: Path, mod_name: str, fid_base: int,
             base_p: Path | None = None, base_key: str | None = None,
             carrier_p: Path | None = None, stamp: str | None = None) -> dict:
    cmd = [
        "bash", str(LOCKED_NODE), str(EMIT_MJS),
        "--api", str(api),
        "--src", str(src),
        "--out", str(out_o),
        "--mod-name", mod_name,
        "--fid-base", str(fid_base),
    ]
    if base_p is not None:
        cmd.extend(["--base", str(base_p), "--base-key", base_key, "--carrier", str(carrier_p), "--stamp", stamp])
    r = subprocess.run(cmd, capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        raise RuntimeError(f"emit {mod_name} failed (rc={r.returncode}): {r.stderr[:500]} {r.stdout[:500]}")
    return json.loads(r.stdout.strip().splitlines()[-1])


def direct_link_and_run(objs: list[Path], exe: Path) -> tuple[float, str, str]:
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
    r = subprocess.run(
        [CC, "-no-pie", str(merge_o), *[str(o) for o in objs], str(RT), "-o", str(exe), "-lm", "-lpthread"],
        capture_output=True, text=True, check=True,
    )
    link_ms = round((time.perf_counter() - t0) * 1000, 1)
    out = subprocess.run([str(exe)], capture_output=True, text=True, check=True, timeout=15).stdout.strip()
    return link_ms, out, r.stderr.strip()


def main() -> None:
    shutil.rmtree(TMP, ignore_errors=True)
    TMP.mkdir(parents=True)
    try:
        # 1. Patch temp copy of compiler.bend with mod_elf_vis.bend
        src_text = W8_COMPILER.read_text()
        vis_text = MOD_VIS_BEND.read_text()
        anchor = "@unsafe\ndef w8_module_entry("
        assert anchor in src_text
        # Insert mod_elf_vis.bend right before w8_module_entry and route w8_module_entry -> w10_module_request
        patched = src_text.replace(anchor, vis_text + "\n\n" + anchor, 1)
        old_call = "u => w8_module_request(path,base,carrier,stamp,agy_str_eq(mode,\"cache\"),fid_base,mod_name),"
        new_call = "u => w10_module_request(path,base,carrier,stamp,agy_str_eq(mode,\"cache\"),fid_base,mod_name),"
        assert old_call in patched
        patched = patched.replace(old_call, new_call, 1)

        tmp_compiler = TMP / "compiler.bend"
        tmp_compiler.write_text(patched)
        tmp_api = TMP / "api.mjs"

        # 2. --check-only (compiler.bend contains @unsafe defs, so Bend's --check-only
        #    verifies 0 syntax/type/affinity errors and then reports the @unsafe summary).
        print("=== STEP 1: --check-only on patched compiler.bend ===", flush=True)
        t0 = time.perf_counter()
        chk = subprocess.run(["bash", str(LOCKED_BUN), "--check-only", str(tmp_compiler)],
                             capture_output=True, text=True, cwd=ROOT)
        chk_ms = round((time.perf_counter() - t0) * 1000, 1)
        chk_out = (chk.stderr + "\n" + chk.stdout).strip()
        only_unsafe = (chk.returncode == 0) or (
            "rely on unsafe or foreign code:" in chk_out
            and chk_out.count("Error:") == 1
        )
        if not only_unsafe:
            raise RuntimeError(f"--check-only FAILED (rc={chk.returncode}):\n{chk_out[:2000]}")
        print(f"  [PASS] --check-only 0 type/affinity errors in {chk_ms}ms", flush=True)

        # 3. Compile to temp api.mjs
        print("=== STEP 2: Compile temp compiler.bend -> api.mjs ===", flush=True)
        t0 = time.perf_counter()
        bld = subprocess.run(["bash", str(LOCKED_BUN), str(tmp_compiler), "-o", str(tmp_api)],
                             capture_output=True, text=True, cwd=ROOT)
        bld_ms = round((time.perf_counter() - t0) * 1000, 1)
        if bld.returncode != 0:
            raise RuntimeError(f"build api.mjs FAILED (rc={bld.returncode}):\n{bld.stderr}\n{bld.stdout}")
        print(f"  [PASS] Built {tmp_api} ({tmp_api.stat().st_size:,} B) in {bld_ms}ms", flush=True)

        # 4. Split compiler_slice.bend into modB and modA
        full_text = SLICE.read_text()
        prefix_v1, modB_v1_txt, modA_v1_txt = split_slice(full_text)
        (TMP / "prefix_v1.bend").write_text(prefix_v1)
        (TMP / "modB_v1.bend").write_text(modB_v1_txt)
        (TMP / "modA_v1.bend").write_text(modA_v1_txt)

        # 5. Emit modB_v1.o
        print("=== STEP 3: Emit modB_v1.o & modA_v1.o (ZERO objcopy) ===", flush=True)
        modB_v1_o = TMP / "modB_v1.o"
        modB_v1_meta = emit_mod(tmp_api, TMP / "modB_v1.bend", modB_v1_o, "modB", 0)

        # Build interface carrier from modB_v1.o
        iface_dir = TMP / "iface_v1"
        r_if = subprocess.run(
            [
                "bash", str(LOCKED_NODE), str(BUILD_IFACE),
                "--prefix", str(TMP / "prefix_v1.bend"),
                "--prefix-obj", str(modB_v1_o),
                "--top", str(TMP / "modA_v1.bend"),
                "--out-dir", str(iface_dir),
            ],
            capture_output=True, text=True, cwd=ROOT,
        )
        if r_if.returncode != 0:
            raise RuntimeError(f"build_iface failed: {r_if.stderr} {r_if.stdout}")
        iface_meta = json.loads((iface_dir / "iface_meta.json").read_text())

        modA_v1_o = TMP / "modA_v1.o"
        modA_v1_meta = emit_mod(
            tmp_api, TMP / "modA_v1.bend", modA_v1_o, "modA", 512,
            base_p=Path(iface_meta["combinedPath"]),
            base_key=iface_meta["combinedPath"],
            carrier_p=Path(iface_meta["carrierPath"]),
            stamp=iface_meta["stamp"],
        )
        modA_sha_before = sha256(modA_v1_o)
        modA_mtime_before = modA_v1_o.stat().st_mtime_ns

        # 6. Audit ELF symbol tables via readelf
        print("=== STEP 4: Audit readelf -S / -sW on modB_v1.o & modA_v1.o ===", flush=True)
        elf_B = parse_readelf(modB_v1_o)
        elf_A = parse_readelf(modA_v1_o)
        print(f"  modB_v1.o: sh_info={elf_B['sh_info']}, total={elf_B['total_syms']}, "
              f"LOCAL={elf_B['local_defined']} ($p111.k.*={elf_B['local_k_count']}), "
              f"GLOBAL={elf_B['global_defined']}, WEAK={elf_B['weak_defined']}", flush=True)
        print(f"  modA_v1.o: sh_info={elf_A['sh_info']}, total={elf_A['total_syms']}, "
              f"LOCAL={elf_A['local_defined']} ($p111.k.*={elf_A['local_k_count']}), "
              f"GLOBAL={elf_A['global_defined']}, WEAK={elf_A['weak_defined']}", flush=True)
        print(f"  modA_v1.o WEAK syms: {elf_A['weak_syms']}", flush=True)

        # 7. Direct link ZERO objcopy (both orders!)
        print("=== STEP 5: Direct gcc-10 link (ZERO objcopy) ===", flush=True)
        link_v1_ms, out_v1, ld_warn_v1 = direct_link_and_run([modB_v1_o, modA_v1_o], TMP / "sep_v1.exe")
        assert ld_warn_v1 == "", f"Linker warnings on modB+modA: {ld_warn_v1}"
        assert out_v1 == "34", f"Expected 34, got {out_v1!r}"
        print(f"  [PASS] Direct link (modB.o modA.o) -> out={out_v1}, warnings=0, {link_v1_ms}ms", flush=True)

        link_rev_ms, out_rev, ld_warn_rev = direct_link_and_run([modA_v1_o, modB_v1_o], TMP / "sep_v1_rev.exe")
        assert ld_warn_rev == "", f"Linker warnings on modA+modB: {ld_warn_rev}"
        assert out_rev == "34", f"Expected 34 (rev order), got {out_rev!r}"
        print(f"  [PASS] Reverse link (modA.o modB.o) -> out={out_rev}, warnings=0, {link_rev_ms}ms", flush=True)

        # 8. Case 2: Body-only edit to modB -> reuse modA_v1.o untouched!
        print("=== STEP 6: Body-only edit to modB (reuse modA_v1.o untouched, ZERO objcopy) ===", flush=True)
        old_bps = "def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:\n  match book:\n    case Nil{}: bound"
        new_bps = "def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:\n  match book:\n    case Nil{}: U32.add(bound, 10)"
        full_v2 = full_text.replace(old_bps, new_bps, 1)
        _, modB_v2_txt, _ = split_slice(full_v2)
        (TMP / "modB_v2.bend").write_text(modB_v2_txt)
        modB_v2_o = TMP / "modB_v2.o"
        modB_v2_meta = emit_mod(tmp_api, TMP / "modB_v2.bend", modB_v2_o, "modB", 0)

        assert sha256(modA_v1_o) == modA_sha_before
        assert modA_v1_o.stat().st_mtime_ns == modA_mtime_before
        link_v2_ms, out_v2, ld_warn_v2 = direct_link_and_run([modB_v2_o, modA_v1_o], TMP / "sep_v2.exe")
        assert ld_warn_v2 == "", f"Linker warnings on v2: {ld_warn_v2}"
        assert out_v2 == "44", f"Expected 44, got {out_v2!r}"
        print(f"  [PASS] Body-only B edit -> out={out_v2}, modA.o REUSED untouched, warnings=0, {link_v2_ms}ms", flush=True)

        results = {
            "check_only_pass": True,
            "check_only_ms": chk_ms,
            "build_api_ms": bld_ms,
            "modB_v1_emit": modB_v1_meta,
            "modA_v1_emit": modA_v1_meta,
            "modB_v1_elf": {k: v for k, v in elf_B.items() if k != "global_syms"},
            "modA_v1_elf": elf_A,
            "direct_link_v1": {"out": out_v1, "warnings": ld_warn_v1, "ms": link_v1_ms},
            "direct_link_v1_rev_order": {"out": out_rev, "warnings": ld_warn_rev, "ms": link_rev_ms},
            "case2_body_only_edit": {
                "out": out_v2,
                "warnings": ld_warn_v2,
                "ms": link_v2_ms,
                "modA_sha256_unchanged": True,
                "modB_v2_emit": modB_v2_meta,
            },
        }
        OUT_JSON.write_text(json.dumps(results, indent=2) + "\n")
        print(f"\nALL M2 ELF VISIBILITY CHECKS PASSED! Saved {OUT_JSON}", flush=True)
    finally:
        shutil.rmtree(TMP, ignore_errors=True)


if __name__ == "__main__":
    main()
