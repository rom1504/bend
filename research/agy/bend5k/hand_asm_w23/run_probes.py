#!/usr/bin/env python3
"""Verified Hand-ASM Ceiling Probe Runner (Wave 23, CPU 3).

Methodology:
  - Compiles each retired eval_split_w22 workload with unmodified Proven-22 `bend5k_o2 -O2`.
  - Compiles each independent C oracle with `gcc-10 -O2 -ffp-contract=off` and
    `gcc-10 -O3 -march=native -ffp-contract=off`.
  - For each hand-assembled x86-64 (.S) probe:
      * Redirects ONLY the target symbol(s) inside the unmodified Proven-22
        ELF64 .o via SHT_SYMTAB SHN_UNDEF redirection.
      * Assembles the .S probe with `gcc-10 -c` and links it with the
        redirected .o and unmodified `runtime-agy.o`.
  - Runs 1 warmup + 5 timed runs pinned to CPU 3 (`taskset -c 3`).
  - Verifies bit-identical U32 stdout checksum across ALL binaries.
  - Writes structured JSON results to `research/agy/bend5k/hand_asm_w23/asm_ceiling_probes_w23.json`.
"""
from __future__ import annotations

import hashlib
import json
import statistics
import struct
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Any

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parents[3]
BEND5K = Path("/home/ai/bend2_agy/selfhost/build/agy/bend5k/bend5k_o2")
RUNTIME = Path("/home/ai/bend2_agy/selfhost/build/agy/unified/runtime-agy.o")
OUT_JSON = HERE / "asm_ceiling_probes_w23.json"
CPU_PIN = "3"
RUNS = 5


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def redirect_elf64_symbols(src_obj: Path, dst_obj: Path, symbols: list[str]) -> None:
    """Mark target symbols as SHN_UNDEF + STB_GLOBAL in ELF64 SHT_SYMTAB."""
    data = bytearray(src_obj.read_bytes())
    assert data[:4] == b"\x7fELF" and data[4] == 2, "Expected 64-bit ELF"
    e_shoff = struct.unpack_from("<Q", data, 40)[0]
    e_shentsize, e_shnum, _ = struct.unpack_from("<HHH", data, 58)

    symtab = None
    for i in range(e_shnum):
        off = e_shoff + i * e_shentsize
        sh_type = struct.unpack_from("<I", data, off + 4)[0]
        if sh_type == 2:  # SHT_SYMTAB
            sh_offset, sh_size, sh_link = struct.unpack_from("<QQI", data, off + 24)
            sh_entsize = struct.unpack_from("<Q", data, off + 56)[0]
            symtab = (sh_offset, sh_size, sh_link, sh_entsize)
            break
    assert symtab is not None, "No SHT_SYMTAB found"
    sh_offset, sh_size, sh_link, sh_entsize = symtab

    str_hdr = e_shoff + sh_link * e_shentsize
    str_off, str_size = struct.unpack_from("<QQ", data, str_hdr + 24)
    strtab = bytes(data[str_off : str_off + str_size])

    target_set = set(symbols)
    found = set()
    n_syms = sh_size // sh_entsize
    for i in range(n_syms):
        s_off = sh_offset + i * sh_entsize
        st_name, st_info, _st_other, _st_shndx, _st_val, _st_size = struct.unpack_from(
            "<IBBHQQ", data, s_off
        )
        end = strtab.find(b"\x00", st_name)
        name = strtab[st_name:end].decode("utf-8", errors="replace")
        if name in target_set:
            new_info = (1 << 4) | (st_info & 0x0F)  # STB_GLOBAL
            struct.pack_into("<IBBHQQ", data, s_off, st_name, new_info, 0, 0, 0, 0)
            found.add(name)

    missing = target_set - found
    if missing:
        raise RuntimeError(f"Symbols not found in {src_obj}: {missing}")
    dst_obj.write_bytes(data)


def run_cmd(cmd: list[str], cwd: Path | None = None) -> str:
    p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, check=True)
    return p.stdout.strip()


def time_binary(cmd: list[str], runs: int = RUNS) -> tuple[str, float, list[float]]:
    pinned = ["taskset", "-c", CPU_PIN] + cmd
    out0 = run_cmd(pinned)
    raw: list[float] = []
    for _ in range(runs):
        t0 = time.perf_counter()
        out = run_cmd(pinned)
        t1 = time.perf_counter()
        if out != out0:
            raise RuntimeError(f"Nondeterministic output for {cmd}: {out0!r} vs {out!r}")
        raw.append(round((t1 - t0) * 1000.0, 2))
    med = round(statistics.median(raw), 2)
    return out0, med, raw


WORKLOADS: list[dict[str, Any]] = [
    {
        "id": "1",
        "name": "v4_aatree_persist_map",
        "pool": "retired_w22_validation",
        "description": "Persistent AA-Tree balanced BST (skew/split rotations + lookups, 140 rounds x 256 inserts + 512 lookups)",
        "bend": "research/agy/bend5k/eval_split_w22/validation/v4_aatree_persist_map_std.bend",
        "c": "research/agy/bend5k/eval_split_w22/validation/v4_aatree_persist_map.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.aa_insert + $direct.aa_lookup",
        "variants": [
            {
                "name": "a_lookup_direct",
                "asm": "research/agy/bend5k/hand_asm_w23/probes/v4_a_lookup_direct.S",
                "symbols": ["$direct.aa_lookup"],
                "note": "Deforest LookReq continuation-ADT in aa_lookup only; direct iterative BST traversal over unmodified AATree.",
            },
            {
                "name": "b_insert_and_lookup_direct",
                "asm": "research/agy/bend5k/hand_asm_w23/probes/v4_b_insert_and_lookup_direct.S",
                "symbols": ["$direct.aa_insert", "$direct.aa_lookup"],
                "note": "Variant A + deforest InsReq + zero-alloc match-as + FBIP unique-node reuse & in-place skew/split rotations in aa_insert (p111_rt_ctor at Leaf{} only).",
            },
        ],
    },
    {
        "id": "2",
        "name": "t3_kmp_multi_scan",
        "pool": "retired_w22_test_sealed",
        "description": "KMP prefix-function builder + streaming multi-pattern scan (8192 haystack x 140 patterns = 1.15M chars)",
        "bend": "research/agy/bend5k/eval_split_w22/test_sealed/t3_kmp_multi_scan_std.bend",
        "c": "research/agy/bend5k/eval_split_w22/test_sealed/t3_kmp_multi_scan.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.scan_text",
        "variants": [
            {
                "name": "a_scan_text_fused",
                "asm": "research/agy/bend5k/hand_asm_w23/probes/t3_a_scan_text_fused.S",
                "symbols": ["$direct.scan_text"],
                "note": "Hoist text/pat/pi arrays once + fuse kmp_fallback_go inner loop inline (0 per-char p113_rt_array_pair, 0 per-char p111_rt_ctor).",
            },
        ],
    },
    {
        "id": "3",
        "name": "t2_radix2_fft_f32",
        "pool": "retired_w22_test_sealed",
        "description": "Iterative Cooley-Tukey Radix-2 DIT FFT in F32 (N=512, 9 stages, 440 frames with bit-reversal & norm)",
        "bend": "research/agy/bend5k/eval_split_w22/test_sealed/t2_radix2_fft_f32_std.bend",
        "c": "research/agy/bend5k/eval_split_w22/test_sealed/t2_radix2_fft_f32.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.run_stages / $direct.run_frames",
        "variants": [
            {
                "name": "a_stages_scalar_hoist",
                "asm": "research/agy/bend5k/hand_asm_w23/probes/t2_a_stages_scalar_hoist.S",
                "symbols": ["$direct.run_stages"],
                "note": "Hoist 4 Array<F32>s (re,im,twr,twi) once + fuse 3-deep butterfly nest & 6-deep bfly_wr..ui chain in scalar F32 (0 allocs).",
            },
            {
                "name": "b_frames_fused_sse",
                "asm": "research/agy/bend5k/hand_asm_w23/probes/t2_b_frames_fused_sse.S",
                "symbols": ["$direct.run_frames"],
                "note": "Fuse bitrev_perm + run_stages (4-wide SSE mulps/addps/subps for half>=4) + 4-wide SSE norm_loop across all 440 frames.",
            },
        ],
    },
    {
        "id": "4",
        "name": "v3_dsu_kruskal_union",
        "pool": "retired_w22_validation",
        "description": "Disjoint-Set Union with path halving & union by rank (N=4096, 80 rounds x 8192 edges = 655K unions)",
        "bend": "research/agy/bend5k/eval_split_w22/validation/v3_dsu_kruskal_union_std.bend",
        "c": "research/agy/bend5k/eval_split_w22/validation/v3_dsu_kruskal_union.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.run_edges",
        "variants": [
            {
                "name": "a_run_edges_fused",
                "asm": "research/agy/bend5k/hand_asm_w23/probes/v3_a_run_edges_fused.S",
                "symbols": ["$direct.run_edges"],
                "note": "Hoist par & rnk once + inline both dsu_find(u)/dsu_find(v) path-halving loops & union-by-rank (0 per-edge array/ctor calls).",
            },
        ],
    },
    {
        "id": "5",
        "name": "t1_lzw_dict_coder",
        "pool": "retired_w22_test_sealed",
        "description": "LZW dictionary compressor with open-addressed hash table (40 rounds x 16384 bytes, 4096-code dict + resets)",
        "bend": "research/agy/bend5k/eval_split_w22/test_sealed/t1_lzw_dict_coder_std.bend",
        "c": "research/agy/bend5k/eval_split_w22/test_sealed/t1_lzw_dict_coder.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.ht_probe_go / $direct.run_bytes",
        "variants": [
            {
                "name": "a_ht_probe_deforest",
                "asm": "research/agy/bend5k/hand_asm_w23/probes/t1_a_ht_probe_deforest.S",
                "symbols": ["$direct.ht_probe_go"],
                "note": "Deforest 3-ctor ProbeStep (PCont|PHit|PEmpty) + hoist hk/hv inside ht_probe_go only.",
            },
            {
                "name": "b_run_bytes_fused",
                "asm": "research/agy/bend5k/hand_asm_w23/probes/t1_b_run_bytes_fused.S",
                "symbols": ["$direct.run_bytes"],
                "note": "Variant A + hoist hk/hv across entire 16,383-byte round + inline ht_probe, handle_insert, clear_arr & branchless cmov byte gen.",
            },
        ],
    },
    {
        "id": "6",
        "name": "v1_sha256_compress",
        "pool": "retired_w22_validation",
        "description": "FIPS 180-4 SHA-256 64-round ARX compression + message schedule (24,000 blocks x 64 rounds)",
        "bend": "research/agy/bend5k/eval_split_w22/validation/v1_sha256_compress_std.bend",
        "c": "research/agy/bend5k/eval_split_w22/validation/v1_sha256_compress.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.run_rounds / $direct.run_blocks",
        "variants": [
            {
                "name": "a_rounds_regalloc_ror",
                "asm": "research/agy/bend5k/hand_asm_w23/probes/v1_a_rounds_regalloc_ror.S",
                "symbols": ["$direct.run_rounds"],
                "note": "Keep 8-word state (a..h) + w/k pointers in registers (0 loop spills vs 276) + hardware rorl $6/$11/$25/$2/$13/$22.",
            },
            {
                "name": "b_run_blocks_fused",
                "asm": "research/agy/bend5k/hand_asm_w23/probes/v1_b_run_blocks_fused.S",
                "symbols": ["$direct.run_blocks"],
                "note": "Fuse fill_w16 + expand_w (rorl) + run_rounds (rorl, regalloc) + add_state with w/k hoisted across all 24,000 blocks (0 allocs).",
            },
        ],
    },
]


def main() -> int:
    results: list[dict[str, Any]] = []
    with tempfile.TemporaryDirectory(prefix="agy_hand_asm_w23_") as td:
        tmp = Path(td)
        for w in WORKLOADS:
            name = w["name"]
            bend_src = REPO_ROOT / w["bend"]
            c_src = REPO_ROOT / w["c"]
            print(f"=== [{w['id']}/{len(WORKLOADS)}] {name} ({w['pool']}) ===", flush=True)

            bend_o = tmp / f"{name}_bend.o"
            bend_bin = tmp / f"{name}_bend"
            run_cmd([str(BEND5K), "-O2", str(bend_src), "-o", str(bend_o)])
            run_cmd(["gcc-10", "-no-pie", str(bend_o), str(RUNTIME), "-lpthread", "-lm", "-o", str(bend_bin)])

            c_o2_bin = tmp / f"{name}_c_o2"
            c_o3_bin = tmp / f"{name}_c_o3"
            run_cmd(["gcc-10", "-O2", "-ffp-contract=off", str(c_src), "-lm", "-o", str(c_o2_bin)])
            run_cmd(["gcc-10", "-O3", "-march=native", "-ffp-contract=off", str(c_src), "-lm", "-o", str(c_o3_bin)])

            chk_b, bend_ms, raw_b = time_binary([str(bend_bin), "+RTS", "--threads", "1", "--gpu", "off", "-RTS"])
            chk_2, c_o2_ms, raw_2 = time_binary([str(c_o2_bin)] + w["c_args"])
            chk_3, c_o3_ms, raw_3 = time_binary([str(c_o3_bin)] + w["c_args"])
            if not (chk_b == chk_2 == chk_3):
                raise RuntimeError(f"Checksum mismatch on {name}: bend={chk_b} c_o2={chk_2} c_o3={chk_3}")

            print(
                f"  baseline: chk={chk_b}  bend={bend_ms:.2f}ms  c_o2={c_o2_ms:.2f}ms ({bend_ms/c_o2_ms:.2f}x)  "
                f"c_o3={c_o3_ms:.2f}ms ({bend_ms/c_o3_ms:.2f}x)",
                flush=True,
            )

            var_out: list[dict[str, Any]] = []
            for v in w["variants"]:
                vname = v["name"]
                asm_src = REPO_ROOT / v["asm"]
                redir_o = tmp / f"{name}_{vname}_redir.o"
                patch_o = tmp / f"{name}_{vname}_patch.o"
                probe_bin = tmp / f"{name}_{vname}_bin"

                redirect_elf64_symbols(bend_o, redir_o, v["symbols"])
                run_cmd(["gcc-10", "-c", str(asm_src), "-o", str(patch_o)])
                run_cmd(
                    ["gcc-10", "-no-pie", str(redir_o), str(patch_o), str(RUNTIME), "-lpthread", "-lm", "-o", str(probe_bin)]
                )
                chk_p, p_ms, raw_p = time_binary([str(probe_bin), "+RTS", "--threads", "1", "--gpu", "off", "-RTS"])
                if chk_p != chk_b:
                    raise RuntimeError(f"PROBE CHECKSUM MISMATCH {name}/{vname}: expected {chk_b}, got {chk_p}")

                speedup = round(bend_ms / p_ms, 3)
                vs_o2 = round(p_ms / c_o2_ms, 3)
                vs_o3 = round(p_ms / c_o3_ms, 3)
                pct_saved = round((1.0 - p_ms / bend_ms) * 100.0, 1)
                print(
                    f"  probe {vname}: chk={chk_p} OK  {p_ms:.2f}ms  speedup={speedup:.2f}x  "
                    f"vs_O2={vs_o2:.3f}x  vs_O3={vs_o3:.3f}x",
                    flush=True,
                )
                var_out.append(
                    {
                        "name": vname,
                        "asm_file": v["asm"],
                        "redirected_symbols": v["symbols"],
                        "checksum": chk_p,
                        "ms": p_ms,
                        "vs_c_o2": vs_o2,
                        "vs_c_o3_native": vs_o3,
                        "speedup_vs_base": speedup,
                        "pct_saved": pct_saved,
                        "raw_ms": raw_p,
                        "note": v["note"],
                    }
                )

            results.append(
                {
                    "id": w["id"],
                    "name": name,
                    "pool": w["pool"],
                    "description": w["description"],
                    "bend_file": w["bend"],
                    "c_file": w["c"],
                    "hot_symbol": w["hot_symbol"],
                    "checksum": chk_b,
                    "baseline_ms": bend_ms,
                    "c_o2_ms": c_o2_ms,
                    "c_o3_native_ms": c_o3_ms,
                    "baseline_vs_c_o2": round(bend_ms / c_o2_ms, 3),
                    "baseline_vs_c_o3_native": round(bend_ms / c_o3_ms, 3),
                    "raw_baseline_ms": raw_b,
                    "raw_c_o2_ms": raw_2,
                    "raw_c_o3_native_ms": raw_3,
                    "variants": var_out,
                }
            )

    payload = {
        "schema": "agy.bend5k.asm_ceiling_probes.v23",
        "host_pin": f"taskset -c {CPU_PIN}",
        "host_cpu": "Intel(R) Xeon(R) CPU E3-1245 V2 @ 3.40GHz (Ivy Bridge)",
        "host_isa": ["sse4_1", "sse4_2", "popcnt", "avx"],
        "compiler_baseline": {
            "description": "Proven-22 bend5k_o2 -O2 (base commit 8630548f)",
            "path": str(BEND5K),
            "sha256": sha256_file(BEND5K),
        },
        "runtime": {
            "path": str(RUNTIME),
            "sha256": sha256_file(RUNTIME),
        },
        "c_baselines": {
            "gcc10_o2": f"gcc-10 -O2 -ffp-contract=off (5-run median on CPU {CPU_PIN})",
            "gcc10_o3_native": f"gcc-10 -O3 -march=native -ffp-contract=off (5-run median on CPU {CPU_PIN})",
        },
        "probes": results,
    }
    OUT_JSON.write_text(json.dumps(payload, indent=2) + "\n")
    print(f"\nWrote verified probe report to {OUT_JSON}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
