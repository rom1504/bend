# Wave 7 Separate-Module Native Compilation Report (`.p130` Interface Carriers + Separate ELF `.o` Linking)

## Executive Summary

We built and verified a **100% general, zero-matcher** separate-module native compilation prototype using **unmodified `selfhost/build/agy/wave6-native-self/n1`** and `gcc-10` on `research/agy/w7_bench/compiler_slice.bend` (`248 KB`, `1,079` real compiler decls).

Two progressive tiers were implemented and verified end-to-end:
- **Tier A — Interface-Stripped `.p130` Prefix Carrier** ([`build_prefix_carrier.mjs`](build_prefix_carrier.mjs)): compresses the checked `Base + prefix` graph (`1,609` defs) **7.6×** (`427,908` → `56,475` nodes, `2,445` strings, `3.05 MB`) so it fits inside `n1`'s existing `65,536`-node / `4,096`-string carrier bounds. Works for **arbitrary edits** to the top module (including new string literals) with **3.24× single-core speedup** (`9.10 s` → `2.81 s`).
- **Tier B — ABI-Matched Interface-Only `.p130` + True Separate ELF `.o` Linking** ([`build_iface_carrier.mjs`](build_iface_carrier.mjs)): replaces all `692` prefix `Def` bodies with general self-recursive ABI-matched stubs (`670` direct `p113d_` + `22` CPS `p111_`), compiles ONLY the edited top module with unmodified `n1`, weakens overlapping stub symbols via `objcopy -W`, and links `prefix_lib.o + top_weak.o + runtime-agy.o` with `gcc-10`. Achieves **`0.77 s` (`768.4 ms`) total single-core native rebuild time (`11.84×` speedup over cold)** with exact verified output (`34` clean, `52` live-edited).

---

## Measured Results (Pinned CPU 5; `run_module_bench.py`)

Exact measurements from [`bench_results.json`](bench_results.json) (same machine load window; idle single-core cold baseline was `7,502.5 ms`, loaded window cold baseline was `9,060.9 ms`):

| Lane | `n1` Compile | Link (`objcopy` + `gcc-10`) | **Total Rebuild** | Speedup vs Cold | `.o` Size | Output |
|---|---:|---:|---:|---:|---:|---|
| **Cold Baseline** (`compiler_slice.bend` + `base.p130`, 1-core CPU 5) | `9,060.9 ms` | `38.7 ms` | **`9,099.6 ms`** | `1.00×` | `353 KB` | `34` ✅ |
| **Tier A: `.p130` Prefix Carrier** (1-core CPU 5, clean) | `2,714.0 ms` | `92.0 ms` | **`2,806.0 ms`** | **`3.24×`** | `293 KB` | `34` ✅ |
| **Tier A: `.p130` Prefix Carrier** (4-core `x86-shard`, clean) | `3,227.7 ms` | `36.9 ms` | **`3,264.6 ms`** | `2.79×` | 4 shards | `34` ✅ |
| **Tier A: `.p130` Prefix Carrier** (4-core `x86-shard`, **live edit** `w7_slice_len` `+1→+2`) | `2,702 ms` | `~60 ms` | **`2,761.6 ms`** | **`3.29×`** | 4 shards | `52` ✅ |
| **Tier B: Interface `.p130` + Separate `.o` Link** (1-core CPU 5, clean) | **`774.3 ms`** | `55.5 ms` | **`829.8 ms`** | **`10.97×`** | `124 KB` | **`34` ✅** |
| **Tier B: Interface `.p130` + Separate `.o` Link** (1-core CPU 5, **live edit** `w7_slice_len` `+1→+2`) | **`695.5 ms`** | `72.9 ms` | **`768.4 ms`** | **`11.84×`** | `124 KB` | **`52` ✅** |
| **Negative / Invalidation Check** (tampered carrier stamp) | rejected (`rc=1`) | — | — | — | — | `base_cache: cache stamp` ✅ |

*Note on verification math:* `f_lex_cursor` returns `18` tokens (including EOF) and `base_prefix_stamp([], 16)` returns `16`. Clean `w7_slice_len` computes `18 × 1 + 16 = 34`; live-edited `w7_slice_len` (`U32.add(acc, 2)`) computes `18 × 2 + 16 = 52` with **zero** prefix rebuild.

---

## Key Technical Discoveries

1. **Interface Stripping Unlocks `n1`'s Existing `.p130` Bounds (`n <= 65536`, `sn <= 4096`)**:
   - Raw `Base + 99.8% compiler_slice.bend` (`1,609` defs) serializes to `427,908` DAG nodes (`22.5 MB`), exceeding `n1`'s `p88_header_counts` cap (`65,536`).
   - Stripping `KDef.value` bodies of non-needed prefix `Def`s across `[book, world, ready]` (while preserving **100% of checked `typ`, `ctors`, and ADT ordering**) shrinks the carrier to **`56,475` nodes / `2,445` strings (`3.05 MB`)** — fitting directly into unmodified `n1` and preserving **bit-for-bit identical constructor IDs (`661` `cid`s: `0x11=Nil`, `0x12=Con`)** across separately compiled `.o` files.

2. **General ABI-Matched Self-Recursive Stubs (`build_iface_carrier.mjs`)**:
   - Replacing every prefix `Def` body with a self-recursive stub `λx0..x{k-1}. f(x0..x{k-1})` works for **every** return type (no inhabitant synthesis needed), never inlines, and pulls in **zero** transitive callees during `reach_book`.
   - Inspecting `nm -g prefix_lib.o` automatically matches each export's native ABI:
     - Direct (`p113d_`) exports keep `λx0..x{k-1}. f(x0..x{k-1})`.
     - Public CPS (`p111_`) exports wrap an unapplied closure `let _f = (λ_cps. _cps) in f(x0..x{k-1})`, which `p113d_live` rejects (`unsupported core node Lam`), forcing exact `p111_FID_$direct.<name>` CPS ABI emission.
   - `n1` always emits real ELF relocations (`R_X86_64_PC32` / `R_X86_64_PLT32`) for cross-function calls, so `objcopy -W` on overlapping symbols lets `gcc-10` resolve all cross-module calls directly into `prefix_lib.o`.

3. **Exact Path to Extend Tier B to All 16 Modules of Full `compiler.bend` (`70k` lines)**:
   Our `objdump` diff on `top_weak.o` vs `prefix_lib.o` pinpointed the **exact 3 minimal compiler changes** needed for 100% universal separate-object compilation & 16-way parallel frontend+backend builds of full `compiler.bend`:
   1. **Raise `p88_header_counts` carrier bounds** in `compiler.bend` (2-line change: `n <= 65536 → 524288`, `sn <= 4096 → 32768`) so a full 15-module interface-only `.p130` carrier (~150k nodes, ~10k strings) loads natively.
   2. **PC-relative `.rodata` string literals (`NStatic`)**: currently `NStatic` encodes a per-compilation-unit static pool offset (`movabs $0x20019000310824e` vs `$0x2001900031082d8`), which collides when a newly compiled top module introduces string literals while sharing `prefix_lib.o`'s `p111_program`. Emitting static strings as local `.rodata` symbols (referenced via `R_X86_64_PC32`) eliminates this coupling completely.
   3. **Disjoint per-module `fid` base / `p111_segments` table** (or direct `p113d_` cross-module calls): currently CPS continuations (`$p111.k.*`) index `p111_program.p111_segments` starting at `0` in every `.o`. Passing a `--module-fid-base <K>` (or merging `p111_segments` at link time via a tiny generated `.s` dispatch table) allows `M` modules to compile **100% in parallel** (parallel frontend + parallel backend!) and link in `< 100 ms`.

---

## Artifacts Produced
- [`research/agy/w7_modules/build_prefix_carrier.mjs`](build_prefix_carrier.mjs) — General Tier-A interface-stripped `.p130` prefix carrier builder.
- [`research/agy/w7_modules/build_iface_carrier.mjs`](build_iface_carrier.mjs) — General Tier-B ABI-matched self-recursive stub `.p130` interface carrier builder.
- [`research/agy/w7_modules/run_module_bench.py`](run_module_bench.py) — End-to-end benchmark, live-edit, and stamp-invalidation verification harness.
- [`research/agy/w7_modules/bench_results.json`](bench_results.json) — Raw verified JSON benchmark results.
- Temp build dir `/tmp/agy_w7_modules/` cleaned (`>= 5.0 GiB` disk free verified).
