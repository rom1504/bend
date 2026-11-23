#!/usr/bin/env python3
"""Assemble unified research/agy/w9_mod_compiler/results.json from measured runs."""
from __future__ import annotations

import json
from pathlib import Path

DIR = Path("/home/ai/bend2_agy/research/agy/w9_mod_compiler")
real_mods = json.loads((DIR / "real_mods_results.json").read_text())
native_ab = json.loads((DIR / "native_ab_results.json").read_text())
js_ab = json.loads(Path("/home/ai/bend2_agy/research/agy/w8_mod_split/cross_module_ab_results.json").read_text())

m1_seq = real_mods["sequential"]["mod1"]
m2_seq = real_mods["sequential"]["mod2"]
par = real_mods["parallel_2core"]
m1_par = par["per_mod"]["mod1"]
m2_par = par["per_mod"]["mod2"]

meta_by_mod = {m["mod"]: m for m in real_mods["extract_meta"]}
m1_meta = meta_by_mod[1]
m2_meta = meta_by_mod[2]

# Empirical rates
m1_ms_per_seg = m1_seq["wall_ms"] / m1_seq["mod_seg_count"]
m2_ms_per_seg = m2_seq["wall_ms"] / m2_seq["mod_seg_count"]
comb_segs = m1_seq["mod_seg_count"] + m2_seq["mod_seg_count"]
comb_seq_ms = m1_seq["wall_ms"] + m2_seq["wall_ms"]
comb_par_sum_ms = m1_par["wall_ms"] + m2_par["wall_ms"]
comb_obj_bytes = m1_seq["obj_bytes"] + m2_seq["obj_bytes"]
comb_text_bytes = m1_seq["text_bytes"] + m2_seq["text_bytes"]
comb_body_kb = (m1_meta["body_bytes"] + m2_meta["body_bytes"]) / 1024.0

mean_seq_ms_per_seg = comb_seq_ms / comb_segs
mean_par_ms_per_seg = comb_par_sum_ms / comb_segs

CODEX_SEGS = 59598
CODEX_OBJ_MB = 48.3
TYPE_HDR_OVERHEAD_S = 30.0  # ~30s frontend overhead per extra module (observed mod1/mod2 frontend ~30.6-30.8s)

def recalibrate(k: int, ms_per_seg: float) -> dict:
    # Total 1-core work = Codex segments * ms_per_seg + (k - 1) * type-header overhead
    base_work_s = (CODEX_SEGS * ms_per_seg) / 1000.0
    dup_hdr_s = (k - 1) * TYPE_HDR_OVERHEAD_S
    total_1c_s = base_work_s + dup_hdr_s
    per_mod_s = total_1c_s / k
    # Balanced schedule on P physical cores (ceil(k / P) waves of balanced modules)
    def wall_s(cores: int) -> float:
        waves = (k + cores - 1) // cores
        return round(waves * per_mod_s, 1)
    return {
        "k": k,
        "avg_segs_per_mod": round(CODEX_SEGS / k, 1),
        "base_1c_s": round(base_work_s, 1),
        "dup_type_hdr_s": round(dup_hdr_s, 1),
        "total_1c_s": round(total_1c_s, 1),
        "balanced_per_mod_s": round(per_mod_s, 1),
        "balanced_4c_s": wall_s(4),
        "balanced_8c_s": wall_s(8),
        "balanced_16c_s": wall_s(16),
    }

unified = {
    "compiler_bin": real_mods["compiler"],
    "source_compiler_bend": "/home/ai/bend2_agy/selfhost/build/agy/wave8_unified/compiler.bend",
    "codex_full_compiler_ref": {
        "segments": CODEX_SEGS,
        "obj_mb": CODEX_OBJ_MB,
        "obj_bytes_per_seg": round((CODEX_OBJ_MB * 1024 * 1024) / CODEX_SEGS, 1),
    },
    "real_modules": {
        "mod1": {
            "source_meta": m1_meta,
            "sequential_cpu0": m1_seq,
            "parallel_cpu0": m1_par,
            "ms_per_seg_seq": round(m1_ms_per_seg, 2),
            "ms_per_seg_par": round(m1_par["wall_ms"] / m1_par["mod_seg_count"], 2),
            "ms_per_body_kb_seq": round(m1_seq["wall_ms"] / (m1_meta["body_bytes"] / 1024.0), 1),
            "obj_bytes_per_seg": round(m1_seq["obj_bytes"] / m1_seq["mod_seg_count"], 1),
            "text_bytes_per_seg": round(m1_seq["text_bytes"] / m1_seq["mod_seg_count"], 1),
            "segs_per_body_kb": round(m1_seq["mod_seg_count"] / (m1_meta["body_bytes"] / 1024.0), 2),
        },
        "mod2": {
            "source_meta": m2_meta,
            "sequential_cpu0": m2_seq,
            "parallel_cpu1": m2_par,
            "ms_per_seg_seq": round(m2_ms_per_seg, 2),
            "ms_per_seg_par": round(m2_par["wall_ms"] / m2_par["mod_seg_count"], 2),
            "ms_per_body_kb_seq": round(m2_seq["wall_ms"] / (m2_meta["body_bytes"] / 1024.0), 1),
            "obj_bytes_per_seg": round(m2_seq["obj_bytes"] / m2_seq["mod_seg_count"], 1),
            "text_bytes_per_seg": round(m2_seq["text_bytes"] / m2_seq["mod_seg_count"], 1),
            "segs_per_body_kb": round(m2_seq["mod_seg_count"] / (m2_meta["body_bytes"] / 1024.0), 2),
        },
        "combined_mod1_mod2": {
            "total_body_kb": round(comb_body_kb, 1),
            "total_segs": comb_segs,
            "share_of_codex_segs_pct": round(100.0 * comb_segs / CODEX_SEGS, 2),
            "total_obj_bytes": comb_obj_bytes,
            "total_text_bytes": comb_text_bytes,
            "obj_bytes_per_seg": round(comb_obj_bytes / comb_segs, 1),
            "text_bytes_per_seg": round(comb_text_bytes / comb_segs, 1),
            "seq_sum_wall_ms": round(comb_seq_ms, 1),
            "par_2core_wall_ms": par["total_wall_ms"],
            "par_2core_speedup_actual": round(comb_seq_ms / par["total_wall_ms"], 3),
            "mod1_contention_ratio": round(m1_seq["wall_ms"] / m1_par["wall_ms"], 3),
            "mod2_contention_ratio": round(m2_seq["wall_ms"] / m2_par["wall_ms"], 3),
            "straggler_skew_mod2_over_mod1": round(m2_par["wall_ms"] / m1_par["wall_ms"], 2),
            "mean_ms_per_seg_seq": round(mean_seq_ms_per_seg, 2),
            "mean_ms_per_seg_par": round(mean_par_ms_per_seg, 2),
            "mean_ms_per_body_kb_seq": round(comb_seq_ms / comb_body_kb, 1),
        },
    },
    "native_cross_module_ab": native_ab,
    "js_cross_module_ab_ref": js_ab,
    "recalibrated_full_compiler_estimates": {
        "note": "Grounded in measured real K=8 compiler modules (mod1: 53.55 ms/seg; mod1+mod2 mean: 110.78-117.06 ms/seg) scaled to Codex 59,598 segments, with 30s per extra module for duplicate 53.1 KB type-header frontend parsing/checking.",
        "k8_mod1_rate": recalibrate(8, m1_ms_per_seg),
        "k8_mean_par_rate": recalibrate(8, mean_par_ms_per_seg),
        "k8_mean_seq_rate": recalibrate(8, mean_seq_ms_per_seg),
        "k12_mod1_rate": recalibrate(12, m1_ms_per_seg),
        "k12_mean_par_rate": recalibrate(12, mean_par_ms_per_seg),
        "k12_mean_seq_rate": recalibrate(12, mean_seq_ms_per_seg),
        "naive_w8_mod_split_old_pred": {
            "k8_4c_s": 25.8, "k8_8c_s": 13.3, "k8_16c_s": 13.3,
            "k12_4c_s": 27.3, "k12_8c_s": 18.0, "k12_16c_s": 9.3,
            "why_off": "Extrapolated 28 ms/KB from compiler_slice.bend (256 KB, only 103 live segments = 0.40 segs/KB) vs real K=8 compiler modules (15.9-18.7 segs/KB, 40-46x higher live-segment density).",
        },
    },
}

(DIR / "results.json").write_text(json.dumps(unified, indent=2) + "\n")
print("Wrote", DIR / "results.json")
