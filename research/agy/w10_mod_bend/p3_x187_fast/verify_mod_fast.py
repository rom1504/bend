#!/usr/bin/env python3
"""Verify `x86-module-fast` and `--trace x86-module-fast` on /tmp/agy_p3_x187/api.mjs:
  - Emits modB and modA with `x86-module-fast` (0 objcopy, 0 C)
  - Audits ELF64: `sh_info` valid, `$p111.k.*` & `def main` STB_LOCAL, seed helpers STB_WEAK,
    no C `main`, `p111_cid_hot` in `.data` (Ndx=3, WA), `p111_cid_arity` in `.rodata` (Ndx=2, A)
  - Links with `x86-merge-obj` + `runtime-agy.o` (both fwd & rev order) and executes -> `34`
  - Verifies `--trace x86-module-fast` emits `[bend-trace]` lines with `mode=x86-module-fast`
  - Benchmarks `x86-module` (-O2) vs `x86-module-fast` (-O0) on `modB_v1.bend`
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
API = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/tmp/agy_p3_x187/api.mjs")
CLI = ROOT / "research/agy/w10_mod_bend/compose_w10/run_w10_cli.mjs"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
TMP = Path("/tmp/agy_p3_x187/mod_fast_test")
K_PREFIX = "p111_FID_36_112_49_49_49_46_107_46_"


def run_cli(args: list[str], out_file: Path | None = None) -> dict:
    cmd = ["bash", str(LOCKED_NODE), str(CLI), str(API), *args]
    t0 = time.perf_counter()
    if out_file is not None:
        with out_file.open("wb") as f:
            r = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, cwd=ROOT, timeout=300)
        stderr = r.stderr.decode("utf-8", errors="replace").strip()
    else:
        r = subprocess.run(cmd, capture_output=True, cwd=ROOT, timeout=300)
        stderr = r.stderr.decode("utf-8", errors="replace").strip()
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    if r.returncode != 0:
        raise RuntimeError(f"cli failed rc={r.returncode} args={args[:3]}: {stderr[:500]}")
    return {
        "rc": r.returncode,
        "ms": ms,
        "stderr": stderr,
        "bytes": out_file.stat().st_size if (out_file and out_file.exists()) else 0,
    }


def audit_elf(obj: Path, expect_no_c_main: bool = True) -> dict:
    sec_out = subprocess.check_output(["readelf", "-SW", str(obj)], text=True)
    sym_out = subprocess.check_output(["readelf", "-sW", str(obj)], text=True)
    sh_info = None
    sections = {}
    for line in sec_out.splitlines():
        m = re.match(r"^\s*\[\s*(\d+)\]\s+(\S+)\s+(\S+)\s+[0-9a-f]+\s+[0-9a-f]+\s+([0-9a-f]+)\s+[0-9a-f]+\s*(\S*)\s+(\d+)\s+(\d+)\s+(\d+)", line)
        if m:
            idx, name, typ, sz, flg, lk, inf, al = m.groups()
            sections[name] = {"ndx": int(idx), "type": typ, "flags": flg, "sh_info": int(inf)}
            if name == ".symtab":
                sh_info = int(inf)
    assert sh_info is not None
    syms = []
    for line in sym_out.splitlines():
        m = re.match(r"^\s*(\d+):\s+([0-9a-f]+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*(.*)$", line)
        if m:
            syms.append({"idx": int(m.group(1)), "bind": m.group(5), "ndx": m.group(7), "name": m.group(8).strip()})
    assert not [s for s in syms if s["bind"] == "LOCAL" and s["idx"] >= sh_info]
    assert not [s for s in syms if s["bind"] != "LOCAL" and s["idx"] < sh_info]
    assert not [s for s in syms if s["name"].startswith(K_PREFIX) and s["bind"] != "LOCAL"]
    if expect_no_c_main:
        assert not [s for s in syms if s["name"] == "main" and s["ndx"] != "UND"]
    cid_hot = [s for s in syms if s["name"] == "p111_cid_hot"]
    cid_arity = [s for s in syms if s["name"] == "p111_cid_arity"]
    return {
        "bytes": obj.stat().st_size,
        "sh_info": sh_info,
        "local_def": sum(1 for s in syms if s["bind"] == "LOCAL" and s["ndx"] != "UND"),
        "global_def": sum(1 for s in syms if s["bind"] == "GLOBAL" and s["ndx"] != "UND"),
        "weak_def": sum(1 for s in syms if s["bind"] == "WEAK" and s["ndx"] != "UND"),
        "local_k": sum(1 for s in syms if s["name"].startswith(K_PREFIX) and s["bind"] == "LOCAL"),
        "cid_hot_ndx": cid_hot[0]["ndx"] if cid_hot else None,
        "cid_arity_ndx": cid_arity[0]["ndx"] if cid_arity else None,
        "data_flags": sections.get(".data", {}).get("flags"),
        "rodata_flags": sections.get(".rodata", {}).get("flags"),
    }


def main() -> None:
    TMP.mkdir(parents=True, exist_ok=True)
    full_text = SLICE.read_text(encoding="utf-8")
    idx = full_text.index("\ndef w7_slice_len(")
    prefix = full_text[:idx]
    modB_txt = (
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
    modA_txt = "import Base\n" + full_text[idx:].lstrip()
    (TMP / "modB.bend").write_text(modB_txt, encoding="utf-8")
    (TMP / "modA.bend").write_text(modA_txt, encoding="utf-8")

    merge_o = TMP / "merge.o"
    run_cli(["x86-merge-obj", "modA", "modB", "modA"], out_file=merge_o)

    iface = TMP / "modB.p130"
    if_res = run_cli(["x86-iface", str(TMP / "modB.bend"), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP], out_file=iface)
    stamp = if_res["stderr"].splitlines()[-1].strip()

    modB_o2 = TMP / "modB_o2.o"
    r_o2 = run_cli(["x86-module", str(TMP / "modB.bend"), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP, "0", "modB"], out_file=modB_o2)

    modB_o0 = TMP / "modB_o0.o"
    r_o0 = run_cli(["x86-module-fast", str(TMP / "modB.bend"), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP, "0", "modB"], out_file=modB_o0)
    a_modB = audit_elf(modB_o0)
    assert a_modB["cid_hot_ndx"] == "3" and a_modB["data_flags"] == "WA"
    assert a_modB["cid_arity_ndx"] == "2" and a_modB["rodata_flags"] == "A"
    assert a_modB["local_k"] > 0 and a_modB["weak_def"] > 0

    modA_o0 = TMP / "modA_o0.o"
    r_modA = run_cli(["x86-module-fast", str(TMP / "modA.bend"), str(BASE_FILE), "cache", str(iface), stamp, "512", "modA"], out_file=modA_o0)
    a_modA = audit_elf(modA_o0)

    # Link fwd & rev
    exe_fwd = TMP / "app_fwd"
    exe_rev = TMP / "app_rev"
    subprocess.run([CC, "-no-pie", str(merge_o), str(modB_o0), str(modA_o0), str(RT), "-o", str(exe_fwd), "-lm", "-lpthread"], check=True)
    subprocess.run([CC, "-no-pie", str(merge_o), str(modA_o0), str(modB_o0), str(RT), "-o", str(exe_rev), "-lm", "-lpthread"], check=True)
    out_fwd = subprocess.check_output([str(exe_fwd)], text=True).strip()
    out_rev = subprocess.check_output([str(exe_rev)], text=True).strip()
    assert out_fwd == "34" and out_rev == "34", f"Bad output: {out_fwd}, {out_rev}"

    # Verify --trace x86-module-fast
    modA_tr = TMP / "modA_tr.o"
    r_tr = run_cli(["--trace", "x86-module-fast", str(TMP / "modA.bend"), str(BASE_FILE), "cache", str(iface), stamp, "512", "modA"], out_file=modA_tr)
    assert "mode=x86-module-fast" in r_tr["stderr"], f"Missing mode=x86-module-fast in trace: {r_tr['stderr']}"
    a_tr = audit_elf(modA_tr)
    assert a_tr["sh_info"] == a_modA["sh_info"]

    res = {
        "status": "PASS",
        "modB_x86_module_ms": r_o2["ms"],
        "modB_x86_module_fast_ms": r_o0["ms"],
        "modB_speedup": round(r_o2["ms"] / r_o0["ms"], 2),
        "modB_audit": a_modB,
        "modA_x86_module_fast_ms": r_modA["ms"],
        "modA_audit": a_modA,
        "link_run_fwd": out_fwd,
        "link_run_rev": out_rev,
        "trace_mod_fast_ms": r_tr["ms"],
        "trace_lines": len(r_tr["stderr"].splitlines()),
    }
    print(json.dumps(res, indent=2))


if __name__ == "__main__":
    main()
