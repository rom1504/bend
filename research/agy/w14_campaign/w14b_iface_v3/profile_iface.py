#!/usr/bin/env python3
"""W14-B Step 1: Zero-loss native CPU profile of n5_o2 x86-iface on m06 and m10 (CPU 0)."""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
N5_O2 = ROOT / "selfhost/build/agy/wave13-native-mod/n5_o2"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
K14_DIR = ROOT / "research/agy/w10_mod_bend/k14_wave13"
CACHE_IFACE = Path("/tmp/agy_k14_w13_cache/iface")
SAMPLER_SO = ROOT / "research/agy/w9_ladder/libbend_sample_threads.so"
ANALYZE_PY = ROOT / "selfhost/tools/profiler/analyze.py"
W13_RESULTS = ROOT / "research/agy/w13_campaign/w13_int_n5_o2/results.json"

OUT_DIR = ROOT / "research/agy/w14_campaign/w14b_iface_v3"
TMP = Path("/tmp/agy_w14b")
SRC_DIR = TMP / "src"

MOD_NAMES = [
    "m00a", "m00b", "m01", "m02", "m03", "m04",
    "m05a", "m05b", "m06", "m07", "m08", "m09", "m10", "m11",
]
TMPL_1ARG = {
    "kc", "f_choose", "nt_choose", "nt_count_go", "nt_reverse",
    "p151_choose", "nt_count", "nt_append",
}
TMPL_CUSTOM = {
    "p134v_list": "p134v_list(U32, U32.is_eq)",
}


def compute_reachable_names() -> set[str]:
    from collections import deque
    sys.path.insert(0, str(ROOT / "research/agy/w13_campaign/w13_int_n5_o2"))
    from split_k14_w13 import parse_compiler_bend, strip_strings_and_comments, IDENT_RE
    _, _, decls = parse_compiler_bend(ROOT / "selfhost/build/agy/wave13_unified/compiler.bend")
    name_to_ids: dict[str, list[int]] = {}
    for idx, d in enumerate(decls):
        name_to_ids.setdefault(d["name"], []).append(idx)
    adj: list[list[int]] = [[] for _ in range(len(decls))]
    for u, d in enumerate(decls):
        seen = {m for m in name_to_ids[d["name"]] if m != u}
        for tok in IDENT_RE.findall(strip_strings_and_comments(d["text"])):
            if tok == "main":
                continue
            for v in name_to_ids.get(tok, ()):
                if v != u:
                    seen.add(v)
        adj[u] = list(seen)
    main_id = name_to_ids["main"][0]
    reach = {main_id}
    q = deque([main_id])
    while q:
        u = q.popleft()
        for v in adj[u]:
            if v not in reach:
                reach.add(v)
                q.append(v)
    return {decls[u]["name"] for u in reach}


def prepare_sources(targets: list[str]) -> dict[str, Path]:
    SRC_DIR.mkdir(parents=True, exist_ok=True)
    reach_names = compute_reachable_names()
    types_text = (K14_DIR / "types.bend").read_text(encoding="utf-8")
    mod_texts = [(K14_DIR / f"{m}.bend").read_text(encoding="utf-8") for m in MOD_NAMES]
    src_paths: dict[str, Path] = {}
    for i, m in enumerate(MOD_NAMES):
        if m not in targets:
            continue
        prefix = (types_text + "\n") if i == 0 else "import Base\n"
        if m == "m11":
            full = prefix + mod_texts[i]
        else:
            defs = re.findall(r"^def\s+([A-Za-z0-9_.\$]+)\s*[\(:]", mod_texts[i], re.M)
            later = "\n".join(mod_texts[i + 1 :])
            later_idents = set(re.findall(r"[A-Za-z_][A-Za-z0-9_.\$]*", later))
            exps = [d for d in defs if d in later_idents and d in reach_names]
            lines = ["\n@unsafe\ndef main() -> U32:"]
            for d in exps:
                if d in TMPL_CUSTOM:
                    lines.append(f"  _ = {TMPL_CUSTOM[d]}")
                elif d in TMPL_1ARG:
                    lines.append(f"  _ = {d}(U32)")
                else:
                    lines.append(f"  _ = {d}")
            lines.append("  0\n")
            full = prefix + mod_texts[i] + "\n".join(lines)
        p = SRC_DIR / f"{m}_exp.bend"
        p.write_text(full, encoding="utf-8")
        src_paths[m] = p
    return src_paths


def classify_symbol(decoded: str) -> str:
    # Strip leading p111_FID_... or $direct. or numeric prefix if any
    s = decoded
    if re.search(r"^(term_drop|span_fade|blk_free|free)([.@]|$)", s):
        return "rt:reclamation"
    if re.search(r"^(heap_alloc|blk_new|malloc|calloc|realloc)([.@]|$)", s):
        return "rt:allocation"
    if re.search(r"^(term_keep|rfc_|p\d+_(?:p\d+_)?rt_(?:keep|take|ctor|extend)|root_take)", s):
        return "rt:ownership"
    if re.search(r"^(memcpy|memmove|memset|blk_copy|__mem)", s):
        return "rt:memcpy"
    if re.search(r"^(write|read|__write|__read|syscall)", s) or "File." in s:
        return "io:file_rw"
    if "p88_" in s or "p130m_" in s or "p86_read_file" in s or "String.from_bytes" in s or "Bytes." in s:
        return "1_p130_read_decode"
    if any(k in s for k in ("w10_if_enc_", "w10_if_intern_", "w10_if_emit_", "w10_if_stream_", "w10_if_write_", "w10_if_take_batch", "w10_if_w", "w10_if_push_str", "w10_if_str_len", "w10_if_mark_", "w10_if_cache_", "w10_if_h_", "w10_if_strip_", "w10_if_zero_", "w10_if_build_stub", "w10_if_ready_extend", "w10_if_book_put_fast")):
        return "4_p130_encode_write"
    if any(k in s for k in ("w10_if_fast_abi", "w10_if_split_upstream", "w10_if_drop_upstream", "w10_if_stub_kind", "w10_if_peel_stub", "w10_if_is_direct_call", "w10_if_add_direct", "w10_if_add_public", "w10_if_suffix_set", "p112s_", "p128br_", "p113pl_", "p113d_", "p113e_", "p126sc_", "p167ob_", "w7_filter", "nq_", "nc_", "no_candidate", "p144o_")):
        return "3_fast_abi"
    if any(k in s for k in ("p86_", "f_", "base_prefix", "book_", "index_", "p111v_", "p131i_", "agy_str_eq", "String.", "List.", "Array.", "norm_", "whnf", "infer", "check", "equal", "subst", "fresh", "d_", "k_", "p98_", "dg_", "kw_")):
        return "2_parse_check_or_shared"
    return "5_other"


def profile_module(mod: str, prev_mod: str, prev_stamp: str, src_path: Path, cpu: int = 0) -> dict:
    in_carrier = CACHE_IFACE / f"{prev_mod}.p130"
    out_p130 = TMP / f"prof_{mod}.p130"
    err_file = TMP / f"prof_{mod}.err"
    samp_file = TMP / f"prof_{mod}.samples"
    ana_file = TMP / f"prof_{mod}_analysis.json"
    for f in (out_p130, err_file, samp_file, ana_file):
        if f.exists():
            f.unlink()

    cmd = [
        "timeout", "120",
        "taskset", "-c", str(cpu),
        "bash", "-c",
        'ulimit -s 262144 && LD_PRELOAD="$1" BEND_SAMPLE_OUT="$2" BEND_SAMPLE_PERIOD_US=15000 exec "$3" "${@:4}"',
        "_", str(SAMPLER_SO), str(samp_file), str(N5_O2),
        "x86-iface", str(src_path), str(BASE_FILE), "cache", str(in_carrier), prev_stamp,
    ]
    t0 = time.perf_counter()
    with out_p130.open("wb") as of, err_file.open("wb") as ef:
        r = subprocess.run(cmd, stdout=of, stderr=ef, cwd=ROOT)
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = err_file.read_text(encoding="utf-8", errors="replace").strip()
    if r.returncode != 0:
        raise RuntimeError(f"profile {mod} failed rc={r.returncode}: {stderr[-600:]}")
    out_bytes = out_p130.stat().st_size
    out_p130.unlink()  # free disk immediately

    # Analyze
    subprocess.run(
        ["python3", str(ANALYZE_PY), "--samples", str(samp_file), "--binary", str(N5_O2), "--output", str(ana_file)],
        check=True, capture_output=True, text=True,
    )
    ana = json.loads(ana_file.read_text())
    buckets: dict[str, int] = {}
    total = ana["header"]["samples"]
    for fn in ana["top_functions"]:
        b = classify_symbol(fn["decoded"])
        buckets[b] = buckets.get(b, 0) + fn["samples"]
    bucket_pct = {k: round(100.0 * v / total, 2) for k, v in sorted(buckets.items())}

    print(f"\n=== PROFILE {mod} (in={prev_mod}.p130 {in_carrier.stat().st_size/1e6:.1f}MB -> out {out_bytes/1e6:.1f}MB) ===", flush=True)
    print(f"wall_ms={wall_ms} samples={total} zero_loss={ana['zeroLoss']} usable={ana['usable']} stamp={stderr}", flush=True)
    print("Buckets (%):", json.dumps(bucket_pct, indent=2), flush=True)
    print("Top 35 functions:", flush=True)
    for fn in ana["top_functions"][:35]:
        print(f"  {fn['percent']:5.2f}% ({fn['samples']:4d}) [{classify_symbol(fn['decoded']):24s}] {fn['decoded']}", flush=True)

    return {
        "module": mod,
        "prev_module": prev_mod,
        "in_bytes": in_carrier.stat().st_size,
        "out_bytes": out_bytes,
        "wall_ms": wall_ms,
        "stamp": stderr,
        "samples": total,
        "zero_loss": ana["zeroLoss"],
        "usable": ana["usable"],
        "buckets_pct": bucket_pct,
        "top_40": [
            {"decoded": fn["decoded"], "percent": round(fn["percent"], 2), "samples": fn["samples"], "bucket": classify_symbol(fn["decoded"])}
            for fn in ana["top_functions"][:40]
        ],
    }


def main():
    d = json.loads(W13_RESULTS.read_text())
    recs = {r["module"]: r for r in d["stage2b_true_cold_pipelined_7core_native"]["iface_records"]}
    src_paths = prepare_sources(["m06", "m07", "m10", "m11"])
    res = {}
    res["m06"] = profile_module("m06", "m05b", recs["m05b"]["stamp"], src_paths["m06"], cpu=0)
    res["m10"] = profile_module("m10", "m09", recs["m09"]["stamp"], src_paths["m10"], cpu=0)
    (OUT_DIR / "profile_baseline.json").write_text(json.dumps(res, indent=2))
    print("\nSaved profile_baseline.json", flush=True)


if __name__ == "__main__":
    main()
