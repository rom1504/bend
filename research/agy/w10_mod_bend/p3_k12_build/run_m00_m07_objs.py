#!/usr/bin/env python3
"""Compile m00.o..m07.o (the 8 modules whose input .p130 <= 16 MiB) and merge.o,
recording exact segment counts, ELF audits, and timings into results.json."""
from __future__ import annotations

import json
import subprocess
import time
from pathlib import Path

from run_k12_build import (
    BASE_CARRIER,
    BASE_FILE,
    BASE_STAMP,
    FID_LIMIT,
    OUT_DIR,
    TMP,
    audit_elf,
    run_w10_cli,
    sha256,
)


def main() -> None:
    res_path = OUT_DIR / "results.json"
    results = json.loads(res_path.read_text(encoding="utf-8"))

    src_dir = TMP / "src"
    iface_dir = TMP / "iface"
    obj_dir = TMP / "obj"
    obj_dir.mkdir(parents=True, exist_ok=True)

    # Reconstruct carrier list for m00..m07
    carriers: list[tuple[Path, str]] = [(BASE_CARRIER, BASE_STAMP)]
    for rec in results["iface_chain"]:
        if "stamp" in rec:
            carriers.append((iface_dir / f"{rec['module']}.p130", rec["stamp"]))

    mod_names = [f"m{i:02d}" for i in range(12)]
    results["modules"] = []
    fid_base = 0
    mod_total_ms = 0.0

    print("=== Compiling m00.o .. m07.o via wave10_unified x86-module ===", flush=True)
    for i in range(8):
        m = mod_names[i]
        in_carrier, in_stamp = carriers[i]
        out_o = obj_dir / f"{m}.o"
        print(f"  [{i+1}/8] x86-module {m} (fid_base={fid_base}, carrier={in_carrier.name}) ...", flush=True)
        res = run_w10_cli(
            ["x86-module", str(src_dir / f"{m}_src.bend"), str(BASE_FILE), "cache", str(in_carrier), in_stamp, str(fid_base), m],
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
            res_path.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
            raise RuntimeError(f"x86-module failed at {m}: {res['stderr']}")
        audit = audit_elf(out_o, mod_name=m, expect_no_c_main=True)
        seg_count = audit["seg_count"]
        assert seg_count is not None and seg_count > 0
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
        print(
            f"    OK {m}.o: {audit['bytes']:,} B | segs={seg_count:,} (fid {fid_base}..{fid_base+seg_count-1}) "
            f"| loc={audit['local_def']} glob={audit['global_def']} weak={audit['weak_def']} | {res['ms']} ms",
            flush=True,
        )
        fid_base += seg_count
        res_path.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")

    # Also test pure-Bend x86-merge-obj for all 12 modules!
    print("=== Emitting K=12 merge.o via pure-Bend x86-merge-obj (0 C) ===", flush=True)
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
    print(f"  OK merge.o (K=12): {merge_audit['bytes']:,} B in {merge_res['ms']} ms", flush=True)

    results["summary"] = {
        "blocker": {
            "module": "m08",
            "input_carrier": "m07.p130",
            "observed_bytes": 18728816,
            "configured_limit_bytes": 16777216,
            "configured_limit_label": "16 MiB (p86_read_sized at wave10_unified/compiler.bend:32913)",
            "error_message": "input exceeds 16 MiB",
            "nodes_at_m07": 348610,
            "nodes_limit": 1048576,
            "strings_at_m07": 9361,
            "strings_limit": 65536,
        },
        "m00_m07_iface_total_ms": round(sum(r["ms"] for r in results["iface_chain"] if "stamp" in r), 1),
        "m00_m07_modules_total_ms": round(mod_total_ms, 1),
        "m00_m07_total_segs": fid_base,
        "projected_k12_total_segs": round(fid_base * 12 / 8),
        "fid_limit": FID_LIMIT,
        "merge_k12_ms": merge_res["ms"],
        "merge_k12_bytes": merge_audit["bytes"],
    }
    res_path.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    print("=== Done m00..m07 + merge.o ===", flush=True)


if __name__ == "__main__":
    main()
