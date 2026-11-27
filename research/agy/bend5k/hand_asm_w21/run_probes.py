#!/usr/bin/env python3
"""Verified Hand-ASM Ceiling Probe Runner (Wave 21, CPU 5).

Methodology:
  - Compiles each Bend2 workload with unmodified Proven-20 `bend5k_o2 -O2`.
  - Compiles each C oracle with `gcc-10 -O2 -ffp-contract=off` and
    `gcc-10 -O3 -march=native -ffp-contract=off`.
  - For each hand-assembled x86-64 (.S) probe:
      * Redirects ONLY the target symbol(s) inside the unmodified Proven-20
        ELF64 .o via SHT_SYMTAB SHN_UNDEF redirection.
      * Assembles the .S probe with `gcc-10 -c` and links it with the
        redirected .o and unmodified `runtime-agy.o`.
  - Runs 1 warmup + 5 timed runs pinned to CPU 5 (`taskset -c 5`).
  - Verifies bit-identical U32 stdout checksum across ALL binaries.
  - Writes structured JSON results to `research/agy/bend5k/asm_ceiling_probes_w21.json`.
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
OUT_JSON = REPO_ROOT / "research/agy/bend5k/asm_ceiling_probes_w21.json"
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
        "name": "t4_utf8_state_machine",
        "pool": "retired_w20_test_sealed",
        "description": "Table-driven UTF-8 DFA validator & codepoint accumulator (32768 bytes x 125 rounds = 4.10M bytes)",
        "bend": "research/agy/bend5k/eval_split_w20/test_sealed/t4_utf8_state_machine_std.bend",
        "c": "research/agy/bend5k/eval_split_w20/test_sealed/t4_utf8_state_machine.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.scan_utf8",
        "variants": [
            {
                "name": "a_rodata_lut_unbox_hoist",
                "asm": "research/agy/bend5k/hand_asm_w21/probes/t4_a_lut_unbox.S",
                "symbols": ["$direct.scan_utf8"],
                "note": "Complete 32B .rodata CLS_LUT + 32B TRANS_LUT + URes record unboxing + buf array hoist (standard branch structure).",
            },
            {
                "name": "b_branchless_cp_dfa",
                "asm": "research/agy/bend5k/hand_asm_w21/probes/t4_b_branchless_dfa.S",
                "symbols": ["$direct.scan_utf8"],
                "note": "Variant A + branchless next_cp via cmovne + streamlined DFA state dispatch.",
            },
        ],
    },
    {
        "id": "2",
        "name": "t2_poly_eval_f32",
        "pool": "retired_w20_test_sealed",
        "description": "Degree-7 Horner polynomial + 4-step Newton-Raphson F32 sweep (16384 points x 120 sweeps = 1.97M elems, 7.86M Newton steps)",
        "bend": "research/agy/bend5k/eval_split_w20/test_sealed/t2_poly_eval_f32_std.bend",
        "c": "research/agy/bend5k/eval_split_w20/test_sealed/t2_poly_eval_f32.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.sweep_arr",
        "variants": [
            {
                "name": "a_scalar_xmm_hoisted",
                "asm": "research/agy/bend5k/hand_asm_w21/probes/t2_a_scalar_xmm.S",
                "symbols": ["$direct.sweep_arr"],
                "note": "1-wide scalar XMM with hoisted SPair/xs/out + hoisted F32 constants (0 movd, 0 p111_rt_op).",
            },
            {
                "name": "b_avx1_8wide_64bit_slots",
                "asm": "research/agy/bend5k/hand_asm_w21/probes/t2_b_avx1_8wide_64bit_slots.S",
                "symbols": ["$direct.sweep_arr"],
                "note": "8-wide AVX1 (ymm0..ymm15) gather/scatter directly over Bend's unmodified 64-bit Array<F32> slots (0 ABI change).",
            },
        ],
    },
    {
        "id": "3",
        "name": "v3_base64_codec",
        "pool": "retired_w20_validation",
        "description": "Table-driven 64-entry Base64 encoder + FNV-1a checksum (5461 3-byte groups x 220 rounds = 1.20M groups / 4.81M LUT lookups)",
        "bend": "research/agy/bend5k/eval_split_w20/validation/v3_base64_codec_std.bend",
        "c": "research/agy/bend5k/eval_split_w20/validation/v3_base64_codec.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.scan_groups",
        "variants": [
            {
                "name": "a_inline_64b_lut_hoist",
                "asm": "research/agy/bend5k/hand_asm_w21/probes/v3_a_inline_lut_hoist.S",
                "symbols": ["$direct.scan_groups"],
                "note": "Full 64-entry .rodata B64_LUT (fixes Proven-20 43-entry cutoff) inlined into scan_groups + (buf,h) unboxing + buf hoist.",
            },
        ],
    },
    {
        "id": "4",
        "name": "t1_rle_lz_hash",
        "pool": "retired_w20_test_sealed",
        "description": "Sliding-window LZ77 hash-table match finder over 2 arrays (16382 steps x 260 rounds = 4.26M steps)",
        "bend": "research/agy/bend5k/eval_split_w20/test_sealed/t1_rle_lz_hash_std.bend",
        "c": "research/agy/bend5k/eval_split_w20/test_sealed/t1_rle_lz_hash.c",
        "c_args": ["std"],
        "hot_symbol": "$direct.scan_lz",
        "variants": [
            {
                "name": "a_unbox_dual_hoist",
                "asm": "research/agy/bend5k/hand_asm_w21/probes/t1_a_unbox_dual_hoist.S",
                "symbols": ["$direct.scan_lz"],
                "note": "LSt{src,ht,h} unboxing + dual-array hoist (src + ht) across 5-step continuation chain (0 p113_rt_array_pair, 0 spills).",
            },
        ],
    },
    {
        "id": "5",
        "name": "k1_varint_decode",
        "pool": "fresh_non_suite_w21",
        "description": "LEB128 varint stream decoder + Murmur/XXHash-style 32-bit integer mixer (65536 bytes x 180 rounds = 11.80M bytes)",
        "bend": "research/agy/bend5k/hand_asm_w21/kernels/k1_varint_decode.bend",
        "c": "research/agy/bend5k/hand_asm_w21/kernels/k1_varint_decode.c",
        "c_args": [],
        "hot_symbol": "$direct.scan_varint",
        "variants": [
            {
                "name": "a_unbox_hoist_rol",
                "asm": "research/agy/bend5k/hand_asm_w21/probes/k1_a_unbox_hoist_rol.S",
                "symbols": ["$direct.run_rounds"],
                "note": "Eliminate per-step VSt re-boxing + buf hoist + hardware roll $13 rotate in mix32 (0 spills, 0 ctor).",
            },
        ],
    },
    {
        "id": "6",
        "name": "k2_csr_spmv",
        "pool": "fresh_non_suite_w21",
        "description": "Compressed Sparse Row (CSR) indirect-gather SpMV over 4 arrays (4095 rows x ~8 edges x 160 rounds = 4.91M edges)",
        "bend": "research/agy/bend5k/hand_asm_w21/kernels/k2_csr_spmv.bend",
        "c": "research/agy/bend5k/hand_asm_w21/kernels/k2_csr_spmv.c",
        "c_args": [],
        "hot_symbol": "$direct.scan_rows",
        "variants": [
            {
                "name": "a_quad_hoist_inline",
                "asm": "research/agy/bend5k/hand_asm_w21/probes/k2_a_quad_hoist_inline.S",
                "symbols": ["$direct.scan_rows"],
                "note": "Quad-array hoist (row_ptr, col_idx, vals, x) before outer row loop + inline scan_edges + eliminate CSt/EAcc records.",
            },
        ],
    },
    {
        "id": "7",
        "name": "k3_soa_particle_acc",
        "pool": "fresh_non_suite_w21",
        "description": "Struct-of-Arrays (SoA) 4-array F32 particle integrator (16384 particles x 200 steps = 3.28M updates)",
        "bend": "research/agy/bend5k/hand_asm_w21/kernels/k3_soa_particle_acc.bend",
        "c": "research/agy/bend5k/hand_asm_w21/kernels/k3_soa_particle_acc.c",
        "c_args": [],
        "hot_symbol": "$direct.integrate",
        "variants": [
            {
                "name": "a_quad_hoist_scalar",
                "asm": "research/agy/bend5k/hand_asm_w21/probes/k3_a_quad_hoist_scalar.S",
                "symbols": ["$direct.integrate"],
                "note": "Quad-array hoist (px, py, vx, vy) + P4 unboxing + scalar XMM F32 (0 p111_rt_op, 0 p113_rt_array_pair).",
            },
            {
                "name": "b_avx1_8wide_64bit_slots",
                "asm": "research/agy/bend5k/hand_asm_w21/probes/k3_b_avx1_8wide_64bit_slots.S",
                "symbols": ["$direct.integrate"],
                "note": "8-wide AVX1 (ymm) gather/scatter over Bend's unmodified 64-bit Array<F32> slots for all 4 SoA arrays.",
            },
        ],
    },
]


def main() -> int:
    results: list[dict[str, Any]] = []
    with tempfile.TemporaryDirectory(prefix="hand_asm_w21_") as td:
        tmp = Path(td)
        for w in WORKLOADS:
            name = w["name"]
            bend_src = REPO_ROOT / w["bend"]
            c_src = REPO_ROOT / w["c"]
            print(f"=== [{w['id']}/7] {name} ({w['pool']}) ===", flush=True)

            # 1. Upstream Bend2 typecheck on fresh kernels
            if w["pool"].startswith("fresh"):
                run_cmd(["bash", str(LOCKED_BUN), "--check-only", str(bend_src)])

            # 2. Compile Proven-20 bend5k_o2 -O2
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
        "schema": "agy.bend5k.asm_ceiling_probes.v21",
        "host_pin": f"taskset -c {CPU_PIN}",
        "host_cpu": "Intel(R) Xeon(R) CPU E3-1245 V2 @ 3.40GHz (Ivy Bridge)",
        "host_isa": ["sse4_1", "sse4_2", "popcnt", "avx"],
        "compiler_baseline": {
            "description": "Proven-20 bend5k_o2 -O2 (base commit 89d393d6)",
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
