#!/usr/bin/env python3
"""Verified Hand-ASM Ceiling Probe Runner (Wave 22, CPU 5).

Methodology:
  - Compiles each Bend2 workload with unmodified Proven-21 `bend5k_o2 -O2`.
  - Compiles each C oracle with `gcc-10 -O2 -ffp-contract=off` and
    `gcc-10 -O3 -march=native -ffp-contract=off`.
  - For each hand-assembled x86-64 (.S) probe:
      * Redirects ONLY the target symbol(s) inside the unmodified Proven-21
        ELF64 .o via SHT_SYMTAB SHN_UNDEF redirection.
      * Assembles the .S probe with `gcc-10 -c` and links it with the
        redirected .o and unmodified `runtime-agy.o`.
  - Runs 1 warmup + 5 timed runs pinned to CPU 5 (`taskset -c 5`).
  - Verifies bit-identical U32 stdout checksum across ALL binaries.
  - Writes structured JSON results to `research/agy/bend5k/asm_ceiling_probes_w22.json`.
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
LOCKED_BUN = REPO_ROOT / "research/agy/locked_bun.sh"
OUT_JSON = REPO_ROOT / "research/agy/bend5k/asm_ceiling_probes_w22.json"
CPU_PIN = "5"
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
        "name": "t4_interval_tree_query",
        "pool": "retired_w21_test_sealed",
        "description": "Persistent Augmented Interval Tree with two-sided overlap pruning (512 intervals, 512 queries, 65 rounds)",
        "bend": "research/agy/bend5k/eval_split_w21/test_sealed/t4_interval_tree_query_std.bend",
        "c": "research/agy/bend5k/eval_split_w21/test_sealed/t4_interval_tree_query.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.insert_iv + $direct.query_overlap",
        "variants": [
            {
                "name": "a_query_direct_tree",
                "asm": "research/agy/bend5k/hand_asm_w22/probes/t4_a_query_direct_tree.S",
                "symbols": ["$direct.query_overlap"],
                "note": "Deforest QReq continuation-ADT in query_overlap only; direct recursion with tail-call right descent over unmodified ITree.",
            },
            {
                "name": "b_insert_and_query_direct",
                "asm": "research/agy/bend5k/hand_asm_w22/probes/t4_b_insert_and_query_direct.S",
                "symbols": ["$direct.insert_iv", "$direct.query_overlap"],
                "note": "Variant A + deforest InsReq continuation-ADT + FBIP unique-node reuse in insert_iv (allocating real Bend INodes at Empty leaves via p111_rt_ctor).",
            },
        ],
    },
    {
        "id": "2",
        "name": "v4_huffman_trie_codec",
        "pool": "retired_w21_validation",
        "description": "Binary Prefix-Code Trie builder & bit-by-bit decoder (depth-6 trie, 45 rounds x 2048 words x 32 bits = 2.95M bits)",
        "bend": "research/agy/bend5k/eval_split_w21/validation/v4_huffman_trie_codec_std.bend",
        "c": "research/agy/bend5k/eval_split_w21/validation/v4_huffman_trie_codec.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.decode_words / $direct.decode_bits",
        "variants": [
            {
                "name": "a_decode_bits_zero_alloc",
                "asm": "research/agy/bend5k/hand_asm_w22/probes/v4_a_decode_bits_zero_alloc.S",
                "symbols": ["$direct.decode_bits"],
                "note": "Eliminate TNode{l,r} identity reconstruction in check_leaf + unbox DSt across 32-bit loop (1 p111_rt_ctor at exit).",
            },
            {
                "name": "b_decode_words_fused",
                "asm": "research/agy/bend5k/hand_asm_w22/probes/v4_b_decode_words_fused.S",
                "symbols": ["$direct.decode_words"],
                "note": "Variant A + fuse decode_bits into decode_words + unboxed RSt multi-return (0 heap allocations in entire 65,536-bit round).",
            },
        ],
    },
    {
        "id": "3",
        "name": "t2_chacha20_quarter",
        "pool": "retired_w21_test_sealed",
        "description": "RFC-7539 ChaCha20 20-round ARX stream cipher block generator (48,000 blocks x 10 double-rounds)",
        "bend": "research/agy/bend5k/eval_split_w21/test_sealed/t2_chacha20_quarter_std.bend",
        "c": "research/agy/bend5k/eval_split_w21/test_sealed/t2_chacha20_quarter.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.run_blocks",
        "variants": [
            {
                "name": "a_scalar_unbox_rol",
                "asm": "research/agy/bend5k/hand_asm_w22/probes/t2_a_scalar_unbox_rol.S",
                "symbols": ["$direct.run_blocks"],
                "note": "2-level nested record unboxing (ChaMat -> 4x Row4 -> 16 U32s) + hardware roll $16/$12/$8/$7 (0 heap allocs).",
            },
            {
                "name": "b_sse2_4wide_rows",
                "asm": "research/agy/bend5k/hand_asm_w22/probes/t2_b_sse2_4wide_rows.S",
                "symbols": ["$direct.run_blocks"],
                "note": "4-wide SSE2/SSSE3 vectorization (Row4 = __m128i, paddd/pxor/pshufb/pshufd, 0 heap allocs, 0 loop spills).",
            },
        ],
    },
    {
        "id": "4",
        "name": "t1_csr_dijkstra_relax",
        "pool": "retired_w21_test_sealed",
        "description": "Weighted CSR graph shortest-path relaxation over 5 Array<U32>s (V=2048, deg=8, 24 sources x 12 sweeps)",
        "bend": "research/agy/bend5k/eval_split_w21/test_sealed/t1_csr_dijkstra_relax_std.bend",
        "c": "research/agy/bend5k/eval_split_w21/test_sealed/t1_csr_dijkstra_relax.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.run_sweeps",
        "variants": [
            {
                "name": "a_5array_hoist_fused",
                "asm": "research/agy/bend5k/hand_asm_w22/probes/t1_a_5array_hoist_fused.S",
                "symbols": ["$direct.run_sweeps"],
                "note": "Hoist ALL 5 arrays (rptr, rlen, col, wt, dist) once before 12-sweep loop + fuse sweep_vertices/relax_edges + Graph unboxing.",
            },
        ],
    },
    {
        "id": "5",
        "name": "v3_bloom_dedup_ring",
        "pool": "retired_w21_validation",
        "description": "3-probe bit-packed Bloom filter + circular ring-buffer dedup (24 rounds x 65,536 keys = 1.57M keys)",
        "bend": "research/agy/bend5k/eval_split_w21/validation/v3_bloom_dedup_ring_std.bend",
        "c": "research/agy/bend5k/eval_split_w21/validation/v3_bloom_dedup_ring.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.step_keys",
        "variants": [
            {
                "name": "a_dual_hoist_rmw",
                "asm": "research/agy/bend5k/hand_asm_w22/probes/v3_a_dual_hoist_rmw.S",
                "symbols": ["$direct.step_keys"],
                "note": "Dual-array preheader hoist (bloom + ring) + 5-step continuation fusion + direct bit RMW (0 p113_rt_array_pair, 0 p111_rt_op).",
            },
        ],
    },
    {
        "id": "6",
        "name": "k1_bsearch_branchless",
        "pool": "fresh_non_suite_w22",
        "description": "Power-of-2 lower-bound binary search over 16,384 sorted U32s (1,000,000 queries x 14 levels)",
        "bend": "research/agy/bend5k/hand_asm_w22/kernels/k1_bsearch_branchless.bend",
        "c": "research/agy/bend5k/hand_asm_w22/kernels/k1_bsearch_branchless.c",
        "c_args": [],
        "hot_symbol": "$direct.run_queries",
        "variants": [
            {
                "name": "a_hoist_branch",
                "asm": "research/agy/bend5k/hand_asm_w22/probes/k1_a_hoist_branch.S",
                "symbols": ["$direct.run_queries"],
                "note": "Control: hoist arr + fuse bsearch_step + unbox BS, keeping conditional branch (ja) to isolate branch-mispredict cost.",
            },
            {
                "name": "b_hoist_cmov",
                "asm": "research/agy/bend5k/hand_asm_w22/probes/k1_b_hoist_cmov.S",
                "symbols": ["$direct.run_queries"],
                "note": "Variant A + branchless hardware cmovbel for unpredictable 50/50 binary-search comparison.",
            },
        ],
    },
    {
        "id": "7",
        "name": "k2_tree_nontail_fold",
        "pool": "fresh_non_suite_w22",
        "description": "Pure non-tail recursive ADT binary tree fold (depth-10 tree, 2047 nodes, 12,000 folds = 24.56M node visits)",
        "bend": "research/agy/bend5k/hand_asm_w22/kernels/k2_tree_nontail_fold.bend",
        "c": "research/agy/bend5k/hand_asm_w22/kernels/k2_tree_nontail_fold.c",
        "c_args": [],
        "hot_symbol": "$direct.fold_tree",
        "variants": [
            {
                "name": "a_lean_recursion",
                "asm": "research/agy/bend5k/hand_asm_w22/probes/k2_a_lean_recursion.S",
                "symbols": ["$direct.fold_tree"],
                "note": "Shrink-wrapped BLeaf fast-path (0 stack frame) + minimal 24B BNode frame + invariant heap base register.",
            },
            {
                "name": "b_leaf_inline",
                "asm": "research/agy/bend5k/hand_asm_w22/probes/k2_b_leaf_inline.S",
                "symbols": ["$direct.fold_tree"],
                "note": "Variant A + child-leaf specialization (inline BLeaf evaluation at call site -> eliminates 50% of all recursive calls).",
            },
        ],
    },
]


def main() -> int:
    results: list[dict[str, Any]] = []
    with tempfile.TemporaryDirectory(prefix="hand_asm_w22_") as td:
        tmp = Path(td)
        for w in WORKLOADS:
            name = w["name"]
            bend_src = REPO_ROOT / w["bend"]
            c_src = REPO_ROOT / w["c"]
            print(f"=== [{w['id']}/{len(WORKLOADS)}] {name} ({w['pool']}) ===", flush=True)

            # 1. Upstream Bend2 typecheck on fresh kernels
            if w["pool"].startswith("fresh"):
                run_cmd(["bash", str(LOCKED_BUN), "--check-only", str(bend_src)])

            # 2. Compile Proven-21 bend5k_o2 -O2
            bend_o = tmp / f"{name}_bend.o"
            bend_bin = tmp / f"{name}_bend"
            run_cmd([str(BEND5K), "-O2", str(bend_src), "-o", str(bend_o)])
            run_cmd(["gcc-10", "-no-pie", str(bend_o), str(RUNTIME), "-lpthread", "-lm", "-o", str(bend_bin)])

            # 3. Compile C baselines
            c_o2_bin = tmp / f"{name}_c_o2"
            c_o3_bin = tmp / f"{name}_c_o3"
            run_cmd(["gcc-10", "-O2", "-ffp-contract=off", str(c_src), "-lm", "-o", str(c_o2_bin)])
            run_cmd(["gcc-10", "-O3", "-march=native", "-ffp-contract=off", str(c_src), "-lm", "-o", str(c_o3_bin)])

            # 4. Time baselines on CPU 5
            chk_b, bend_ms, raw_b = time_binary([str(bend_bin)])
            chk_2, c_o2_ms, raw_2 = time_binary([str(c_o2_bin)] + w["c_args"])
            chk_3, c_o3_ms, raw_3 = time_binary([str(c_o3_bin)] + w["c_args"])
            if not (chk_b == chk_2 == chk_3):
                raise RuntimeError(f"Checksum mismatch on {name}: bend={chk_b} c_o2={chk_2} c_o3={chk_3}")

            print(
                f"  baseline: chk={chk_b}  bend={bend_ms:.2f}ms  c_o2={c_o2_ms:.2f}ms ({bend_ms/c_o2_ms:.2f}x)  "
                f"c_o3={c_o3_ms:.2f}ms ({bend_ms/c_o3_ms:.2f}x)",
                flush=True,
            )

            # 5. Build, verify, and time each hand-ASM probe
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
                chk_p, p_ms, raw_p = time_binary([str(probe_bin)])
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
        "schema": "agy.bend5k.asm_ceiling_probes.v22",
        "host_pin": f"taskset -c {CPU_PIN}",
        "host_cpu": "Intel(R) Xeon(R) CPU E3-1245 V2 @ 3.40GHz (Ivy Bridge)",
        "host_isa": ["sse4_1", "sse4_2", "popcnt", "avx"],
        "compiler_baseline": {
            "description": "Proven-21 bend5k_o2 -O2 (base commit 2f59e12b)",
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
