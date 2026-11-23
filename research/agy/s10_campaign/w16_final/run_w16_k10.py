#!/usr/bin/env python3
"""Wave 16 Fast K=10 Split, Mint (`n7_o0`), Pure-Bend 8-Core Cold Self-Compile (`n7_o0 -> n8_cold`),
and Exact Stage Breakdown."""
from __future__ import annotations

import json
import shutil
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
W16_SRC = ROOT / "selfhost/build/agy/wave16_unified/compiler.bend"
K10_DIR = ROOT / "selfhost/build/agy/k10_wave16"
N6_O2 = ROOT / "selfhost/build/agy/wave15-native-mod/n6_o2"
N7_O0 = ROOT / "selfhost/build/agy/wave16-native-mod/n7_o0"
ORACLE_K10 = ROOT / "research/agy/s10_campaign/s10a_zero_p130/p113d_oracle_k10.txt"
ORACLE_W16 = ROOT / "research/agy/s10_campaign/w16_final/p113d_oracle_w16.txt"
OUT_DIR = ROOT / "research/agy/s10_campaign/w16_final"

sys.path.insert(0, str(OUT_DIR))
sys.path.insert(0, str(ROOT / "research/agy/s10_campaign/s10a_zero_p130"))
import gen_stubs
import mint_and_bench_w16 as mb

CPUS = [0, 1, 2, 3, 4, 5, 6, 7]


def main() -> None:
    t0 = time.perf_counter()
    # 1. Split K=10 balanced
    splitter = ROOT / "research/agy/s10_campaign/s10g_nodrop_and_k24/split_kN_balanced.py"
    subprocess.run(
        [sys.executable, str(splitter), "--k", "10", "--src", str(W16_SRC), "--out-dir", str(K10_DIR)],
        check=True,
    )
    manifest = json.loads((K10_DIR / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]

    # 2. Mint n7_o0 via n6_o2 (-O0 x86-module-fast, 8-core parallel)
    work = Path("/tmp/agy_w16_mint_n7o0")
    if work.exists():
        shutil.rmtree(work)
    src_dir = work / "src"
    obj_dir = work / "obj"
    direct_set = {x.strip() for x in ORACLE_K10.read_text().splitlines() if x.strip()}
    print(f"\n=== [1/2] Minting n7_o0 (-O0) via n6_o2 on K=10 (CPUs {CPUS}, oracle={len(direct_set)}) ===", flush=True)
    stub_meta = gen_stubs.generate_all(K10_DIR, src_dir, abi_mode="oracle", direct_set=direct_set)
    comp = mb.compile_k_parallel(N6_O2, K10_DIR, src_dir, obj_dir, cpus=CPUS, mode_args=["x86-module-fast"], timeout_s=180)
    comp = mb.check_and_fix_fid_overlaps(comp, N6_O2, K10_DIR, src_dir, obj_dir, cpus=CPUS, mode_args=["x86-module-fast"], timeout_s=180)
    weak_ms = mb.weaken_stub_syms_for_bootstrap(obj_dir, stub_meta, mod_names)
    orphans = mb.audit_orphan_weaks(obj_dir, mod_names)
    print(f"  bootstrap weaken={weak_ms} ms | total_segs={comp['total_segs']}/65532 | orphan_weaks={len(orphans)}", flush=True)
    assert len(orphans) == 0, f"Orphan weaks: {orphans[:10]}"

    w16_oracle = mb.extract_global_direct_oracle(obj_dir, mod_names)
    ORACLE_W16.write_text("\n".join(sorted(w16_oracle)) + "\n", encoding="utf-8")
    print(f"  Extracted Wave 16 exact G(G(D0)) oracle: {len(w16_oracle)} direct defs", flush=True)

    merge_ms, link_ms = mb.merge_and_link(N6_O2, mod_names, obj_dir, obj_dir / "merge.o", N7_O0, cpu=0)
    print(f"  Linked {N7_O0} ({N7_O0.stat().st_size:,} B) | merge={merge_ms} ms link={link_ms} ms", flush=True)
    smoke_n7 = mb.smoke_binary(N7_O0, work / "smoke", cpu=0, run_o2=True)
    shutil.rmtree(work, ignore_errors=True)

    # 3. Official 8-core ZERO-CACHE cold self-compile: n7_o0 -> n8_cold (100% pure-Bend, 0 objcopy!)
    cold_work = Path("/tmp/agy_w16_cold/n7_o0_k10")
    if cold_work.exists():
        shutil.rmtree(cold_work)
    cold_work.mkdir(parents=True, exist_ok=True)
    c_src = cold_work / "src"
    c_obj = cold_work / "obj"
    print(f"\n=== [2/2] OFFICIAL 8-CORE ZERO-CACHE COLD SELF-COMPILE: n7_o0 -> n8_cold (K=10, CPUs {CPUS}, EMPTY {cold_work}) ===", flush=True)
    t_cold0 = time.perf_counter()
    c_stubs = gen_stubs.generate_all(K10_DIR, c_src, abi_mode="oracle", direct_set=w16_oracle)
    c_comp = mb.compile_k_parallel(N7_O0, K10_DIR, c_src, c_obj, cpus=CPUS, mode_args=["x86-module-fast"], timeout_s=180, trace=True)
    c_comp = mb.check_and_fix_fid_overlaps(c_comp, N7_O0, K10_DIR, c_src, c_obj, cpus=CPUS, mode_args=["x86-module-fast"], timeout_s=180, trace=True)
    n8_bin = cold_work / "n8_cold"
    c_merge_ms, c_link_ms = mb.merge_and_link(N7_O0, mod_names, c_obj, c_obj / "merge.o", n8_bin, cpu=0)
    cold_wall_ms = round((time.perf_counter() - t_cold0) * 1000.0, 1)
    c_orphans = mb.audit_orphan_weaks(c_obj, mod_names)
    assert len(c_orphans) == 0, f"Orphan weaks in n8_cold: {c_orphans[:10]}"
    smoke_n8 = mb.smoke_binary(n8_bin, cold_work / "smoke", cpu=0, run_o2=False)
    n8_bytes = n8_bin.stat().st_size
    shutil.rmtree(cold_work, ignore_errors=True)

    print(
        f"\n>>> TOTAL 8-CORE ZERO-CACHE COLD WALL TIME (n7_o0 -> n8_cold, K=10): "
        f"{cold_wall_ms:.1f} ms ({cold_wall_ms/1000:.2f} s) | total_segs={c_comp['total_segs']}/65532 | 0 objcopy | 0 orphans <<<",
        flush=True,
    )

    out = {
        "mint_n7_o0": {
            "binary": str(N7_O0.relative_to(ROOT)),
            "bytes": N7_O0.stat().st_size,
            "stub_gen_ms": stub_meta["elapsed_ms"],
            "compile": comp,
            "merge_ms": merge_ms,
            "link_ms": link_ms,
            "oracle_w16_count": len(w16_oracle),
            "smoke": smoke_n7,
        },
        "cold_n7_o0_k10": {
            "stub_gen_ms": c_stubs["elapsed_ms"],
            "compile_wall_ms": c_comp["wall_ms"],
            "compile_cpu_sum_ms": c_comp["cpu_sum_ms"],
            "compile_min_ms": c_comp["min_ms"],
            "compile_median_ms": c_comp["median_ms"],
            "compile_max_ms": c_comp["max_ms"],
            "total_segs": c_comp["total_segs"],
            "merge_ms": c_merge_ms,
            "link_ms": c_link_ms,
            "total_cold_wall_ms": cold_wall_ms,
            "total_cold_wall_s": round(cold_wall_ms / 1000.0, 2),
            "n8_bytes": n8_bytes,
            "orphan_weaks": len(c_orphans),
            "smoke": smoke_n8,
            "modules": c_comp["modules"],
        },
        "total_script_s": round(time.perf_counter() - t0, 2),
    }
    (OUT_DIR / "k10_cold_results.json").write_text(json.dumps(out, indent=2) + "\n")


if __name__ == "__main__":
    main()
