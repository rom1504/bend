# Experiment: Wave 12-E — Pure-Bend `x86-iface v2` (`2×` Faster Interface Carrier Emission)

- **Date:** 2026-11-23
- **Status:** **PASSED — Ready for Wave 12 Unified Integration**
- **Workspace:** `research/agy/w12_campaign/w12e_iface_v2/`
- **Report:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12e_iface_v2/REPORT.md)
- **Patch:** [w12e_iface_v2.patch](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12e_iface_v2/w12e_iface_v2.patch)
- **Evidence:** [results.json](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12e_iface_v2/results.json)

## Hypothesis
Wave 11's `x86-iface` (P5-D) still spends `76–77%` of its non-parse/check runtime in three O(K²) / redundant sub-stages:
1. Global `rm` Patricia-trie record hash-consing (425k+ entries) plus 5–6× re-encoding of 319 `base.bend` patched defs and ~889 `law`+`def` pairs (`16.3 s` on `m09`);
2. Full-prefix `base_prefix_resume_world` + `p86_checked_prefix` + `base_prefix_world_prepare` replay on stub-only suffixes that produce `0` new patches (`12.8 s` on `m05`, `5.9 s` on `m09`);
3. Re-scanning ~755 already-stubbed upstream defs in `p128br_scan` and `p113pl_candidates` (`5.2 s` on `m09`).

Replacing these in pure Bend (0 new types, 0 C, 0 JS) with (1) zero-`rm` + 4-cache (`ucache`/`lcache`/`fcache`/`pcache`) `.p130` encoding, (2) incremental O(|suffix|) `base_world`/`base_ready` extension for stub-only suffixes, and (3) O(1) `w10_if_strip_ann`-aware upstream stub classification in `w10_if_fast_abi` should deliver `~2×` additional speedup while preserving 100% exact interface stamps and 100% SHA-256 bit-identical downstream `.o` files.

## Measured Results (CPU `5`, Same-Load A/B vs Wave 11 Baseline)
- **`--check-only`** (9,082 defs): **PASS (0 type errors, `15,036.8 ms`)**
- **`m02`**: `29,226.1 ms` → **`19,712.6 ms`** (**`1.48×`**), `277,137` nodes (`26.4%` of 1M), `stamp_identical = True`
- **`m06`**: `25,337.6 ms` → **`12,552.5 ms`** (**`2.02×`**), `503,759` nodes (`48.0%` of 1M), `stamp_identical = True`
- **`m10`** *(largest prefix)*: `34,114.0 ms` → **`17,205.1 ms`** (**`1.98×`**), `741,321` nodes (`70.7%` of 1M, `307,255` nodes headroom), `stamp_identical = True`
- **Downstream `x86-module-fast` `.o` parity:**
  - `m02.o` (`8,899,248 B`), `m07.o` (`9,414,976 B`), `m10.o` (`7,267,832 B`), `m11.o` (`6,510,272 B`): **4/4 `SHA256_IDENTICAL = True`**

## Decision
**Accept / Promote** [w12e_iface_v2.patch](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12e_iface_v2/w12e_iface_v2.patch) into the Wave 12 unified compiler candidate. No protected files were modified; `/tmp/agy_w12e/` cleaned after verification.
