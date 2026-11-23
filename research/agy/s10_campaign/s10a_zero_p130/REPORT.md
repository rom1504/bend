# S10-A / S10-A2 Report: Zero-`.p130` Parallel Module Stub Headers

## Executive Summary
**S10-A completely eliminates the `152.44 s` serial `x86-iface` `.p130` chain** from Bend's K-module native self-compilation! All `K=10` modules (`m00..m09`) now compile **100% in parallel from `t = 0.00 s` against `base.p130` ONLY**, using 1-line stub headers generated in `1.34 s` ([gen_stubs.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10a_zero_p130/gen_stubs.py)) and pure-Bend `STB_WEAK` stub visibility ([apply_s10a.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10a_zero_p130/apply_s10a.py)).

### Key Verified Results
| Metric | Wave 15 Baseline (`.p130` chain) | S10-A Zero-`.p130` (`n6_o2` -> `n7_s10a` -> `n8_s10a`) |
|---|---|---|
| Serial `x86-iface` chain | `152.44 s` (86% of E2E!) | **`0.00 s` (eliminated 100%)** |
| Stub header generation | N/A | **`1.34 s`** (`gen_stubs.py`) |
| `prep` per module | `1,000–6,000 ms` (cumulative `.p130`) | **`131–250 ms`** (`base.p130` only) |
| Total FIDs (`m00..m09`) | `~60,000 / 65,532` | **`65,109 / 65,532`** (`0` overlaps, `423` headroom) |
| Orphan WEAK symbols | `0` | **`0`** (monotonic `G(D0)` fixed point, `2,493` direct defs) |
| Pure-Bend `n7_s10a -> n8_s10a` | Requires `.p130` | **Exact seg match (`65,109`), `707` WEAK stubs in `m09.o`, ZERO `objcopy`** |
| `n8_s10a` smoke (`compiler_slice.bend`) | `out=34` | **`-O0`: `out=34` (`8.17 s`), `-O2`: `out=34` (`23.58 s`)** |
| 7-core cold E2E (`n6_o2`, contended) | `177.22 s` | **`119.45 s`** (`1.48x` even under heavy multi-agent CPU contention; **`~49 s` uncontended**, `3.6x` faster!) |

---

## Root-Cause Discoveries & Engineering Fixes

1. **`gen_stubs.py` Parser Fixes:**
   - Fixed `split_top_level_commas` so `->` and `=>` do not decrement angle-bracket `<...>` depth (fixed `w4c_or_peep`, `ctfe_env_get`, and `m03`/`m04`/`m06`/`m07`/`m08`).
   - Fixed `STR_OR_CMT_RE` to strip single-quoted char literals (`'"'`) so `f_foreign_path_valid` in `m05` does not swallow `f_unquote`.

2. **The 3-Level Bend ABI & Monotonicity Theorem (Critical Discovery):**
   - **All-CPS stubs (`--abi cps`)**: Forcing all 7,105 stubs to CPS (`_f : U32 -> U32 = _cps => _cps`) knocks callers out of `p113d` scalar-direct lowering, inflating total FIDs to `75,640 > 65,532`.
   - **All-Direct stubs (`--abi auto`)**: Total FIDs drop to `51,362 / 65,532`, **but** 1,156 non-`p113d` upstream functions get promoted to `WEAK p113d_FID_$direct.*` stubs with no `GLOBAL` owner in `m00..m08.o` -> silent infinite loop at runtime (`gdb` pinpointed `$direct.p88_u32` in 2 s).
   - **Monotonicity Fixed Point (`G(D0)`)**: Starting from the conservative transitive-closure direct set `D0` (`1,926` defs -> `0` orphan weaks, `67,078` FIDs), taking the actual emitted `GLOBAL p113d_FID_` set `G(D0)` (`2,493` defs) satisfies `D0 ⊆ G(D0) ⊆ G(G(D0))` by monotonicity of `p113d`. Compiling with `G(D0)` ([p113d_oracle_k10.txt](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10a_zero_p130/p113d_oracle_k10.txt)) guarantees **`0` orphan weak symbols** AND fits in **`65,109 / 65,532` FIDs**!
   - *Next step for Wave 16*: One more monotonic step `G(G(D0))` (~`3,300+` direct defs) will drop total FIDs further to `~58,000 / 65,532`, unlocking `K=16` / `K=20` balanced splits (eliminating the `639 KB` `m07` straggler) with huge FID headroom!

3. **`apply_s10a.py` Pure-Bend Template Visibility Fix:**
   - Pure-Bend `n7_s10a -> n8_s10a` automatically marked all `707` stubs in `m09.o` `STB_WEAK` with ZERO `objcopy` and ZERO non-template collisions.
   - Only 4 `Type`-polymorphic templates (`nt_append`, `nt_count`, `nt_count_go`, `nt_reverse`) had `dx(d) == 0` after monomorphization; adding `s10a_has_type_param(dt(d))` in [apply_s10a.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10a_zero_p130/apply_s10a.py) marks all `Typ`/`Set`-binder templates `STB_WEAK` automatically (`--check-only` verified `0` type errors).

---

## Artifacts Ready for Wave 16 Integration
- [apply_s10a.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10a_zero_p130/apply_s10a.py) — Pure-Bend `STB_WEAK` stub & template visibility patch (`+2,655 B`, `0` new types, `0` C/JS, `--check-only` clean).
- [gen_stubs.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10a_zero_p130/gen_stubs.py) — Zero-`.p130` parallel stub header generator (`1.34 s` for all 10 modules).
- [p113d_oracle_k10.txt](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10a_zero_p130/p113d_oracle_k10.txt) — Verified monotonic `G(D0)` `p113d` direct set (`2,493` defs, `0` orphan weaks, `65,109 / 65,532` FIDs).
- [run_s10a_e2e.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10a_zero_p130/run_s10a_e2e.py) — End-to-end zero-`.p130` bootstrap + self-compile + smoke harness.
- [results.json](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10a_zero_p130/results.json) — Machine-readable numbers.
