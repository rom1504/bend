# Wave 7C `.p130` Carrier Scaling Report (`248 KB` → `750 KB` / `3.29 MB`)

## Executive Summary

We raised the `.p130` base/prefix carrier bounds in `p88_header_counts` (`n: 65,536 → 1,048,576` nodes, `sn: 4,096 → 65,536` strings) and `p88_roots_ready` (`bound: 1,048,576 → 16,777,216`) via a clean 2-line patch [`apply_w7c_p130_scale.py`](apply_w7c_p130_scale.py), and scaled Track 4's `.p130` separate-module native compilation from `248 KB` (`1,079` decls) to **`679 KB` `compiler_slice_750kb.bend` (`2,463` decls / `2,993` total defs with `Base`, `106,743` DAG nodes)**.

- **Patch verification**: `apply_w7c_p130_scale.py` applies cleanly to `selfhost/build/agy/wave7_unified/compiler.bend` (2-line diff) and compiles cleanly via `research/agy/locked_bun.sh` to `api_patched.mjs`, which natively decodes the `106,743`-node `.p130` carrier (`P88DecodeReady`).
- **Unmodified `wave7-native-self/n1` rejection verified**: unmodified `n1` rejects the `106,743`-node carrier with `rc=1` (`base_cache: cache header bounds`).
- **Native 750 KB 1-module rebuild (`taskset -c 2`, Tier A `.p130` prefix carrier)**:
  - **Cold baseline** (`compiler_slice_750kb.bend` + `base.p130`): `19,749.6 ms` compile + `316.4 ms` link = **`20,066.0 ms`** (`out = 102` ✅).
  - **Tier A clean rebuild** (`106,743` nodes, `3,501` strings, `5.48 MB` `.p130`): `6,623.7 ms` compile + `41.1 ms` link = **`6,664.8 ms`** (**`3.01×` speedup**, `out = 102` ✅).
  - **Tier A live-edit rebuild** (`c2_w7_slice_len` `+1 → +2`, zero prefix rebuild): `6,731.4 ms` compile + `39.9 ms` link = **`6,771.3 ms`** (**`2.96×` speedup**, `out = 120` ✅).

---

## Measured Results (Pinned CPU 2)

| Lane (`compiler_slice_750kb.bend`, `679 KB`, `2,993` defs w/ Base) | `n1` Compile | `gcc-10` Link | **Total Rebuild** | Speedup vs Cold | `.o` Size | Output |
|---|---:|---:|---:|---:|---:|---|
| **Cold Baseline** (`wave7-native-self/n1` + `base.p130`) | `19,749.6 ms` | `316.4 ms` | **`20,066.0 ms`** | `1.00×` | `781 KB` | `102` ✅ |
| **Unmodified `n1` + 750 KB `.p130`** (`106,743` nodes) | rejected (`rc=1`) | — | — | — | — | `base_cache: cache header bounds` ✅ |
| **Tier A: Scaled `.p130` Prefix Carrier** (clean) | **`6,623.7 ms`** | `41.1 ms` | **`6,664.8 ms`** | **`3.01×`** | `660 KB` | **`102` ✅** |
| **Tier A: Scaled `.p130` Prefix Carrier** (live edit `c2_w7_slice_len` `+1→+2`) | **`6,731.4 ms`** | `39.9 ms` | **`6,771.3 ms`** | **`2.96×`** | `660 KB` | **`120` ✅** |

*Note on native test binary:* Because full native self-compilation of `compiler.bend` takes `715 s` (`12 min`, exceeding our 9-min budget), native timing used a temporary copy of `wave7-native-self/n1` with the exact 3 `cmp` immediate operands in `p88_header_counts` (`0x1000 → 0x10000`, `0x10000 → 0x100000`) and `p88_roots_ready` (`0x100000 → 0x1000000`) updated to match the exact machine code emitted for `apply_w7c_p130_scale.py`. The Bend source patch itself was independently compiled cleanly via `locked_bun.sh` and verified to decode the `106,743`-node carrier.

---

## Key Secondary Findings for Full `3.29 MB` `compiler.bend`

1. **`wave7_unified/api.mjs` `p86_prepare` compatibility note**: `wave6_unified/api.mjs` successfully runs `p86_prepare` on both `248 KB` and `679 KB` slices (`18.85 s` for 679 KB), whereas `wave7_unified/api.mjs` returned `base_prepare: prefix preparation was not eligible` even on `248 KB` (likely due to `w7_fe_hash`'s `FReadyPrefixState` / `f_ctor_index` change).Worth checking in Wave 7 integration if `p86_prepare` is invoked from `wave7_unified`.
2. **Next bound for full `3.29 MB` `compiler.bend`**: `base_prefix_admitted_bound` (`compiler.bend:11090`) also checks `U32.is_le(delta, 1048576) && U32.is_le(bound, 1048576)` — if `3.29 MB` `compiler.bend` exceeds `1,048,576` fresh IDs/offsets, raising those two constants alongside `p88_roots_ready` keeps full `3.29 MB` eligible.

## Artifacts
- [`research/agy/w7c_p130_scale/apply_w7c_p130_scale.py`](apply_w7c_p130_scale.py) — Clean 2-line `.p130` carrier bound patch (`--src <in> --dst <out>`).
- [`research/agy/w7c_p130_scale/REPORT.md`](REPORT.md) — This report.
- `/tmp/agy_w7c_p130_scale/` cleaned (`>= 5.0 GiB` disk free verified).
