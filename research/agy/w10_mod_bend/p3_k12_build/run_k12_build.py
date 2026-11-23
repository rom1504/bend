#!/usr/bin/env python3
"""Phase 3 (P3-B): Real K=12 Pure-Bend Modular Self-Build of n2_mod.

Uses ONLY `selfhost/build/agy/wave10_unified/api.mjs` (0 C merge, 0 objcopy, 0 JS iface)
via `bash research/agy/locked_node.sh` (`AGY_NODE_MAX_MB=4096`) and `gcc-10 -O2 -no-pie`.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
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

OUT_DIR = ROOT / "research/agy/w10_mod_bend/p3_k12_build"
NATIVE_DIR = ROOT / "selfhost/build/agy/wave10-native-mod"
N2_MOD = NATIVE_DIR / "n2_mod"
TMP = Path("/tmp/agy_p3_k12")

NODE_LIMIT = 1048576
STR_LIMIT = 65536
FID_LIMIT = 65532

TMPL_1ARG = {
    "kc", "f_choose", "nt_choose", "nt_count_go", "nt_reverse", "p151_choose",
    "nt_count", "nt_append",
}
TMPL_CUSTOM = {
    "p134v_list": "p134v_list(U32, U32.is_eq)",
}
K_PREFIX = "p111_FID_36_112_49_49_49_46_107_46_"


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def parse_p130(path: Path) -> dict:
    txt = path.read_text(encoding="utf-8")
    lo = ord(txt[0]) - 65536
    hi = ord(txt[1]) - 65536
    slen = lo + hi * 65536
    stamp = txt[2 : 2 + slen]
    pos = 2 + slen
    if pos < len(txt) and ord(txt[pos]) == 10:
        pos += 1
    rn = (ord(txt[pos]) - 65536) + (ord(txt[pos + 1]) - 65536) * 65536
    sn = (ord(txt[pos + 2]) - 65536) + (ord(txt[pos + 3]) - 65536) * 65536
    return {
        "bytes": path.stat().st_size,
        "stamp": stamp,
        "nodes": rn,
        "strings": sn,
    }


def run_w10_cli(args: list[str], out_file: Path | None = None, check: bool = True, timeout: int = 900) -> dict:
    cmd = ["bash", str(LOCKED_NODE), str(CLI), str(API), *args]
    env = os.environ.copy()
    env["AGY_NODE_MAX_MB"] = "4096"
    t0 = time.perf_counter()
    if out_file is not None:
        with out_file.open("wb") as f:
            r = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, cwd=ROOT, env=env, timeout=timeout)
        stderr = r.stderr.decode("utf-8", errors="replace").strip()
        stdout = ""
    else:
        r = subprocess.run(cmd, capture_output=True, cwd=ROOT, env=env, timeout=timeout)
        stderr = r.stderr.decode("utf-8", errors="replace").strip()
        stdout = r.stdout.decode("utf-8", errors="replace").strip()
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    if check and r.returncode != 0:
        raise RuntimeError(f"w10 cli failed (rc={r.returncode}) args={args[:3]}: {stderr[:800]}")
    return {
        "rc": r.returncode,
        "ms": ms,
        "stderr": stderr,
        "stdout": stdout,
        "bytes": out_file.stat().st_size if (out_file and out_file.exists()) else 0,
    }


def audit_elf(obj: Path, mod_name: str | None = None, expect_no_c_main: bool = True) -> dict:
    sec_out = subprocess.check_output(["readelf", "-SW", str(obj)], text=True)
    sym_out = subprocess.check_output(["readelf", "-sW", str(obj)], text=True)
    sh_info = None
    for line in sec_out.splitlines():
        m_sec = re.match(
            r"^\s*\[\s*(\d+)\]\s+(\S+)\s+(\S+)\s+[0-9a-f]+\s+[0-9a-f]+\s+([0-9a-f]+)\s+[0-9a-f]+\s*(\S*)\s+(\d+)\s+(\d+)\s+(\d+)",
            line,
        )
        if m_sec and m_sec.group(2) == ".symtab":
            sh_info = int(m_sec.group(7))
    assert sh_info is not None, f"No .symtab in {obj}"

    syms = []
    for line in sym_out.splitlines():
        m = re.match(r"^\s*(\d+):\s+([0-9a-f]+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*(.*)$", line)
        if m:
            syms.append({
                "idx": int(m.group(1)),
                "size": int(m.group(3)),
                "bind": m.group(5),
                "ndx": m.group(7),
                "name": m.group(8).strip(),
            })

    bad_local = [s for s in syms if s["bind"] == "LOCAL" and s["idx"] >= sh_info]
    bad_nonlocal = [s for s in syms if s["bind"] != "LOCAL" and s["idx"] < sh_info]
    assert not bad_local, f"LOCAL >= sh_info in {obj}"
    assert not bad_nonlocal, f"non-LOCAL < sh_info in {obj}"

    if expect_no_c_main:
        c_main = [s for s in syms if s["name"] == "main" and s["ndx"] != "UND"]
        assert not c_main, f"Unexpected C main in {obj}"

    seg_count = None
    if mod_name is not None:
        arity_sym = f"p111_mod_{mod_name}_p111_fid_arity"
        segs_sym = f"p111_mod_{mod_name}_p111_segments"
        for s in syms:
            if s["name"] == arity_sym and s["size"] > 0:
                seg_count = s["size"]
                break
        if seg_count is None:
            for s in syms:
                if s["name"] == segs_sym and s["size"] > 0:
                    seg_count = s["size"] // 8
                    break

    return {
        "bytes": obj.stat().st_size,
        "total_syms": len(syms),
        "sh_info": sh_info,
        "local_def": sum(1 for s in syms if s["bind"] == "LOCAL" and s["ndx"] != "UND"),
        "global_def": sum(1 for s in syms if s["bind"] == "GLOBAL" and s["ndx"] != "UND"),
        "weak_def": sum(1 for s in syms if s["bind"] == "WEAK" and s["ndx"] != "UND"),
        "local_k": sum(1 for s in syms if s["name"].startswith(K_PREFIX) and s["bind"] == "LOCAL"),
        "seg_count": seg_count,
    }


def build_module_source(mod_idx: int, types_text: str, mod_text: str) -> str:
    prefix = (types_text + "\n") if mod_idx == 0 else "import Base\n"
    if mod_idx == 11:
        return prefix + mod_text
    defs = re.findall(r"^def\s+([A-Za-z0-9_.\$]+)\s*[\(:]", mod_text, re.M)
    lines = ["\n@unsafe\ndef main() -> U32:"]
    for d in defs:
        if d in TMPL_CUSTOM:
            lines.append(f"  _ = {TMPL_CUSTOM[d]}")
        elif d in TMPL_1ARG:
            lines.append(f"  _ = {d}(U32)")
        else:
            lines.append(f"  _ = {d}")
    lines.append("  0\n")
    return prefix + mod_text + "\n".join(lines)


def save_results(results: dict) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "results.json").write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    NATIVE_DIR.mkdir(parents=True, exist_ok=True)
    src_dir = TMP / "src"
    iface_dir = TMP / "iface"
    obj_dir = TMP / "obj"
    verify_dir = TMP / "verify"
    for d in [src_dir, iface_dir, obj_dir, verify_dir]:
        d.mkdir(parents=True, exist_ok=True)

    types_text = (K12_DIR / "types.bend").read_text(encoding="utf-8")
    mod_names = [f"m{i:02d}" for i in range(12)]

    results: dict = {
        "status": "in_progress",
        "limits": {
            "p130_max_nodes": NODE_LIMIT,
            "p130_max_strings": STR_LIMIT,
            "fid_max": FID_LIMIT,
        },
        "base_carrier": parse_p130(BASE_CARRIER),
        "iface_chain": [],
        "modules": [],
        "merge": None,
        "link": None,
        "verify_n2_mod": None,
        "body_edit_m11": None,
        "summary": {},
    }
    save_results(results)

    # 1. Prepare module sources
    src_paths: dict[str, Path] = {}
    for i, m in enumerate(mod_names):
        mtxt = (K12_DIR / f"{m}.bend").read_text(encoding="utf-8")
        full = build_module_source(i, types_text, mtxt)
        p = src_dir / f"{m}_src.bend"
        p.write_text(full, encoding="utf-8")
        src_paths[m] = p

    # 2. Cumulative .p130 interface chain: Base -> m00 -> m01 -> ... -> m10
    print("=== Phase A: Cumulative .p130 Interface Chain (Base -> m00 .. m10) ===", flush=True)
    carriers: list[tuple[Path, str]] = [(BASE_CARRIER, BASE_STAMP)]
    iface_total_ms = 0.0
    for i in range(11):
        m = mod_names[i]
        in_carrier, in_stamp = carriers[i]
        out_p130 = iface_dir / f"{m}.p130"
        print(f"  [{i+1}/11] x86-iface {m} (in={in_carrier.name}) ...", flush=True)
        res = run_w10_cli(
            ["x86-iface", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp],
            out_file=out_p130,
            check=False,
        )
        iface_total_ms += res["ms"]
        if res["rc"] != 0:
            err_rec = {
                "module": m,
                "rc": res["rc"],
                "ms": res["ms"],
                "stderr": res["stderr"],
                "in_carrier": parse_p130(in_carrier),
            }
            results["iface_chain"].append(err_rec)
            results["status"] = f"blocked_iface_{m}"
            save_results(results)
            raise RuntimeError(f"x86-iface failed at {m}: {res['stderr']}")
        stamp = res["stderr"].splitlines()[-1].strip()
        info = parse_p130(out_p130)
        assert info["stamp"] == stamp, f"Stamp mismatch: {info['stamp']} != {stamp}"
        rec = {
            "module": m,
            "ms": res["ms"],
            "bytes": info["bytes"],
            "nodes": info["nodes"],
            "strings": info["strings"],
            "node_pct": round(100.0 * info["nodes"] / NODE_LIMIT, 2),
            "string_pct": round(100.0 * info["strings"] / STR_LIMIT, 2),
            "stamp": stamp,
        }
        results["iface_chain"].append(rec)
        carriers.append((out_p130, stamp))
        print(
            f"    OK {m}.p130: {info['bytes']:,} B | nodes={info['nodes']:,}/{NODE_LIMIT:,} ({rec['node_pct']}%) "
            f"| strings={info['strings']:,}/{STR_LIMIT:,} ({rec['string_pct']}%) | {res['ms']} ms",
            flush=True,
        )
        save_results(results)
        if info["nodes"] > NODE_LIMIT or info["strings"] > STR_LIMIT:
            results["status"] = f"carrier_bound_exceeded_at_{m}"
            save_results(results)
            raise RuntimeError(f"Carrier bound exceeded at {m}: nodes={info['nodes']} strings={info['strings']}")

    # 3. Compile all 12 modules (m00.o .. m11.o) with tightly-packed disjoint fid_bases
    print("=== Phase B: Pure-Bend x86-module Compilation (m00.o .. m11.o) ===", flush=True)
    fid_base = 0
    obj_paths: list[Path] = []
    mod_total_ms = 0.0
    for i, m in enumerate(mod_names):
        in_carrier, in_stamp = carriers[i]
        out_o = obj_dir / f"{m}.o"
        print(f"  [{i+1}/12] x86-module {m} (fid_base={fid_base}, carrier={in_carrier.name}) ...", flush=True)
        res = run_w10_cli(
            ["x86-module", str(src_paths[m]), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fid_base), m],
            out_file=out_o,
            check=False,
        )
        mod_total_ms += res["ms"]
        if res["rc"] != 0:
            results["modules"].append({
                "module": m,
                "fid_base": fid_base,
                "rc": res["rc"],
                "ms": res["ms"],
                "stderr": res["stderr"],
            })
            results["status"] = f"blocked_module_{m}"
            save_results(results)
            raise RuntimeError(f"x86-module failed at {m}: {res['stderr']}")
        audit = audit_elf(out_o, mod_name=m, expect_no_c_main=True)
        seg_count = audit["seg_count"]
        assert seg_count is not None and seg_count > 0, f"Could not determine seg_count for {m}"
        rec = {
            "module": m,
            "fid_base": fid_base,
            "seg_count": seg_count,
            "fid_end": fid_base + seg_count - 1,
            "ms": res["ms"],
            "bytes": audit["bytes"],
            "total_syms": audit["total_syms"],
            "sh_info": audit["sh_info"],
            "local_def": audit["local_def"],
            "global_def": audit["global_def"],
            "weak_def": audit["weak_def"],
            "local_k": audit["local_k"],
            "sha256": sha256(out_o),
        }
        results["modules"].append(rec)
        obj_paths.append(out_o)
        print(
            f"    OK {m}.o: {audit['bytes']:,} B | segs={seg_count:,} (fid {fid_base}..{fid_base+seg_count-1}) "
            f"| loc={audit['local_def']} glob={audit['global_def']} weak={audit['weak_def']} | {res['ms']} ms",
            flush=True,
        )
        fid_base += seg_count
        save_results(results)
        if fid_base > FID_LIMIT:
            results["status"] = f"fid_limit_exceeded_at_{m}"
            save_results(results)
            raise RuntimeError(f"Total FIDs {fid_base} exceeded {FID_LIMIT} at {m}")

    # 4. Emit merge.o via pure-Bend x86-merge-obj (0 C!)
    print("=== Phase C: Pure-Bend x86-merge-obj (0 C) ===", flush=True)
    merge_o = obj_dir / "merge.o"
    merge_res = run_w10_cli(["x86-merge-obj", "m11", *mod_names], out_file=merge_o)
    merge_audit = audit_elf(merge_o, mod_name=None, expect_no_c_main=False)
    results["merge"] = {
        "ms": merge_res["ms"],
        "bytes": merge_audit["bytes"],
        "sh_info": merge_audit["sh_info"],
        "total_syms": merge_audit["total_syms"],
        "sha256": sha256(merge_o),
    }
    print(f"  OK merge.o: {merge_audit['bytes']:,} B in {merge_res['ms']} ms", flush=True)
    save_results(results)

    # 5. Link n2_mod via gcc-10 -O2 -no-pie
    print("=== Phase D: Link selfhost/build/agy/wave10-native-mod/n2_mod ===", flush=True)
    t0 = time.perf_counter()
    link_cmd = [CC, "-O2", "-no-pie", str(merge_o), *[str(p) for p in obj_paths], str(RT), "-o", str(N2_MOD), "-lm", "-lpthread"]
    lr = subprocess.run(link_cmd, capture_output=True, text=True, check=True)
    link_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    results["link"] = {
        "ms": link_ms,
        "bytes": N2_MOD.stat().st_size,
        "sha256": sha256(N2_MOD),
        "warnings": lr.stderr.strip(),
        "total_fids": fid_base,
        "fid_budget": FID_LIMIT,
        "fid_pct": round(100.0 * fid_base / FID_LIMIT, 2),
    }
    print(
        f"  OK n2_mod: {N2_MOD.stat().st_size:,} B in {link_ms} ms | total_fids={fid_base:,}/{FID_LIMIT:,} "
        f"| warnings={len(lr.stderr.strip().splitlines())}",
        flush=True,
    )
    save_results(results)

    # 6. Verify n2_mod
    print("=== Phase E: Verify n2_mod (x86-object-fast & --trace) ===", flush=True)
    # 6a. x86-object-fast
    slice_o = verify_dir / "slice.o"
    t0 = time.perf_counter()
    with slice_o.open("wb") as f:
        r1 = subprocess.run(
            [str(N2_MOD), "x86-object-fast", str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
            stdout=f, stderr=subprocess.PIPE, cwd=ROOT, timeout=120, check=True,
        )
    fast_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    slice_exe = verify_dir / "slice_exe"
    subprocess.run([CC, "-no-pie", str(slice_o), str(RT), "-o", str(slice_exe), "-lm", "-lpthread"], check=True)
    run1 = subprocess.run([str(slice_exe)], capture_output=True, text=True, check=True, timeout=15)
    assert run1.stdout.strip() == "34", f"Expected 34, got {run1.stdout!r}"

    # 6b. --trace x86-object-fast
    slice_tr_o = verify_dir / "slice_tr.o"
    t0 = time.perf_counter()
    with slice_tr_o.open("wb") as f:
        r2 = subprocess.run(
            [str(N2_MOD), "--trace", "x86-object-fast", str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
            stdout=f, stderr=subprocess.PIPE, cwd=ROOT, timeout=120, check=True,
        )
    trace_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    trace_lines = [ln for ln in r2.stderr.decode("utf-8", errors="replace").splitlines() if "[bend-trace]" in ln]
    assert len(trace_lines) >= 3, f"Expected [bend-trace] lines, got {trace_lines}"
    slice_tr_exe = verify_dir / "slice_tr_exe"
    subprocess.run([CC, "-no-pie", str(slice_tr_o), str(RT), "-o", str(slice_tr_exe), "-lm", "-lpthread"], check=True)
    run2 = subprocess.run([str(slice_tr_exe)], capture_output=True, text=True, check=True, timeout=15)
    assert run2.stdout.strip() == "34", f"Expected 34 from traced build, got {run2.stdout!r}"

    results["verify_n2_mod"] = {
        "slice_fast_ms": fast_ms,
        "slice_fast_o_bytes": slice_o.stat().st_size,
        "slice_fast_out": run1.stdout.strip(),
        "slice_trace_ms": trace_ms,
        "slice_trace_o_bytes": slice_tr_o.stat().st_size,
        "slice_trace_out": run2.stdout.strip(),
        "trace_lines": trace_lines,
    }
    print(f"  OK n2_mod x86-object-fast: {fast_ms} ms -> '{run1.stdout.strip()}'", flush=True)
    print(f"  OK n2_mod --trace x86-object-fast: {trace_ms} ms ({len(trace_lines)} trace lines) -> '{run2.stdout.strip()}'", flush=True)
    save_results(results)

    # 7. 1-Module Body Edit Test on m11.bend
    print("=== Phase F: 1-Module Body Edit Test (m11.bend) ===", flush=True)
    pre_hashes = {mod_names[i]: sha256(obj_paths[i]) for i in range(11)}
    pre_mtimes = {mod_names[i]: obj_paths[i].stat().st_mtime_ns for i in range(11)}
    merge_pre_hash = sha256(merge_o)

    m11_orig_txt = src_paths["m11"].read_text(encoding="utf-8")
    old_str = '"usage: x86|x86-object|x86-shard|x86-module ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP [SHARD SHARDS | FID_BASE MOD_NAME]"'
    new_str = '"usage[m11-body-edit]: x86|x86-object|x86-shard|x86-module ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP [SHARD SHARDS | FID_BASE MOD_NAME]"'
    assert m11_orig_txt.count(old_str) == 1, "Target usage string not found uniquely in m11"
    m11_edit_src = src_dir / "m11_edit_src.bend"
    m11_edit_src.write_text(m11_orig_txt.replace(old_str, new_str, 1), encoding="utf-8")

    m11_fid_base = results["modules"][11]["fid_base"]
    m10_carrier, m10_stamp = carriers[11]
    m11_edit_o = obj_dir / "m11_edit.o"
    edit_compile = run_w10_cli(
        ["x86-module", str(m11_edit_src), str(BASE_FILE), "cache", str(m10_carrier), m10_stamp, str(m11_fid_base), "m11"],
        out_file=m11_edit_o,
    )
    m11_edit_audit = audit_elf(m11_edit_o, mod_name="m11", expect_no_c_main=True)

    # Relink n2_mod_edit reusing m00.o..m10.o + merge.o untouched
    n2_mod_edit = verify_dir / "n2_mod_edit"
    t0 = time.perf_counter()
    edit_link = subprocess.run(
        [CC, "-O2", "-no-pie", str(merge_o), *[str(p) for p in obj_paths[:11]], str(m11_edit_o), str(RT), "-o", str(n2_mod_edit), "-lm", "-lpthread"],
        capture_output=True, text=True, check=True,
    )
    edit_link_ms = round((time.perf_counter() - t0) * 1000.0, 1)

    # Prove 11/12 .o files untouched
    reused_ok = all(
        sha256(obj_paths[i]) == pre_hashes[mod_names[i]]
        and obj_paths[i].stat().st_mtime_ns == pre_mtimes[mod_names[i]]
        for i in range(11)
    )
    assert reused_ok, "One of m00.o..m10.o was modified!"
    assert sha256(merge_o) == merge_pre_hash, "merge.o was modified!"

    # Verify body edit observable in usage stderr AND compiler_slice still prints 34
    usage_run = subprocess.run([str(n2_mod_edit)], capture_output=True, text=True, timeout=15)
    assert "usage[m11-body-edit]:" in usage_run.stderr, f"Body edit not reflected: {usage_run.stderr!r}"

    slice_edit_o = verify_dir / "slice_edit.o"
    t0 = time.perf_counter()
    with slice_edit_o.open("wb") as f:
        subprocess.run(
            [str(n2_mod_edit), "x86-object-fast", str(SLICE), str(BASE_FILE), "cache", str(BASE_CARRIER), BASE_STAMP],
            stdout=f, stderr=subprocess.PIPE, cwd=ROOT, timeout=120, check=True,
        )
    edit_verify_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    slice_edit_exe = verify_dir / "slice_edit_exe"
    subprocess.run([CC, "-no-pie", str(slice_edit_o), str(RT), "-o", str(slice_edit_exe), "-lm", "-lpthread"], check=True)
    run_edit = subprocess.run([str(slice_edit_exe)], capture_output=True, text=True, check=True, timeout=15)
    assert run_edit.stdout.strip() == "34", f"Expected 34 from n2_mod_edit, got {run_edit.stdout!r}"

    results["body_edit_m11"] = {
        "reused_objs_count": 11,
        "reused_objs_sha256_identical": reused_ok,
        "merge_o_reused": True,
        "m11_edit_compile_ms": edit_compile["ms"],
        "m11_edit_o_bytes": m11_edit_audit["bytes"],
        "m11_edit_seg_count": m11_edit_audit["seg_count"],
        "relink_ms": edit_link_ms,
        "total_edit_rebuild_ms": round(edit_compile["ms"] + edit_link_ms, 1),
        "usage_stderr": usage_run.stderr.strip(),
        "slice_fast_ms": edit_verify_ms,
        "slice_fast_out": run_edit.stdout.strip(),
    }
    print(
        f"  OK 1-Module Body Edit: compile={edit_compile['ms']} ms + relink={edit_link_ms} ms "
        f"= {round(edit_compile['ms'] + edit_link_ms, 1)} ms | 11/12 reused=True | out='{run_edit.stdout.strip()}'",
        flush=True,
    )

    max_mod_ms = max(r["ms"] for r in results["modules"])
    cold_seq_ms = round(iface_total_ms + mod_total_ms + merge_res["ms"] + link_ms, 1)
    cold_par_mod_ms = round(iface_total_ms + max_mod_ms + merge_res["ms"] + link_ms, 1)
    results["summary"] = {
        "iface_chain_total_ms": round(iface_total_ms, 1),
        "modules_seq_total_ms": round(mod_total_ms, 1),
        "modules_max_single_ms": round(max_mod_ms, 1),
        "merge_ms": merge_res["ms"],
        "link_ms": link_ms,
        "cold_k12_seq_total_ms": cold_seq_ms,
        "cold_k12_parallel_modules_projected_ms": cold_par_mod_ms,
        "body_edit_total_ms": round(edit_compile["ms"] + edit_link_ms, 1),
        "total_fids": fid_base,
        "n2_mod_bytes": N2_MOD.stat().st_size,
    }
    results["status"] = "PASS"
    save_results(results)
    print("=== ALL K=12 MODULAR SELF-BUILD GATES PASSED ===", flush=True)


if __name__ == "__main__":
    main()
