# Wave 16 `<= 10 s` Cold Self-Compile Campaign Scorecard

## Composition, Mint & Gate Status
| Deliverable | Status | Artifact / Exact Metric |
|---|---|---|
| **8-Patch Unified Composition** (`S10-D`+`S10-E --no-lexer`+`S10-A`+`S10-C`+`S10-H`+`S10-F`+`S10-B`+`S10-G`) | **PASS** | [wave16_unified/compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend) (`3,497,142 B`, `82,253 lines`, `-9.74%` vs W15) |
| **`locked_bun.sh --check-only`** | **PASS** | **0 type errors, 0 linearity errors** (`9,127` `@unsafe` defs) |
| **Balanced Acyclic Splits (`K=10/16/24`)** | **PASS** | `K=10` `1.002x`, `K=16` `1.009x`, `K=24` `1.005x` (`0` lost/dup/cycles) |
| **`n7_o2` Mint (`10/10 -O2` via `n6_o2` `.p130` pipelined)** | **PASS** | [n7_o2](file:///home/ai/bend2_agy/selfhost/build/agy/wave16-native-mod/n7_o2) (`79.1 MB`, `63,354/65,532` FIDs, `merge=127.8 ms`, `link=456.2 ms`, `compiler_slice` `-O0` `2.77s` & `-O2` `4.99s` `out=34`) |
| **8-Core Zero-Cache Cold Compile (`n7_o2`, `K=10`, CPUs `0..7`)** | **MEASURED** | **`62.87 s` compile wall** (`~64.4 s` E2E, **`1.74×` vs W15 `112 s`**; `361.1 s` 1-core sum, `540.7 MiB` max RSS, `64,660/65,532` segs; link hit 4 S10-H `p111->p113d` stub wrapper refs) |
| **Zero-Regression Gate (`n7_o2`)** | **PARTIAL (`132/158`)** | **`-O0`: `79/79` (`100%`) PASS** (`64/64` native64 in `7.34 s`, `15/15` Observer in `1.22 s`) + **ELF Audit PASS**; **`-O2`: `53/64` + `0/15` Observer** (16 hangs in `n6_o2`-emitted `x198o_progress_get` thunk); `n6_o2` kept hot |

## Wave 17 Exact Millisecond Target Breakdown (`361.1 s` 1-Core Sum -> `<= 72 s`)
| Stage | 1-Core Sum (ms) | Share | `m00` (ms) | `m09` (ms) | Wave 17 Attack |
|---|---:|---:|---:|---:|---|
| **`x198pw_plan`** | **`154,592`** | **`42.8%`** | `8,519` | `15,245` | Skip stub `p111` lowering completely (also unlocks `K=16`/`K=24` & fixes S10-H link!) |
| **`p86_plan`** | **`103,043`** | **`28.5%`** | `9,024` | `8,814` | Shared `types.p130` / binary stub header + fast lexer/parser |
| **`x187_pub`** | **`65,633`** | **`18.2%`** | `2,101` | `7,297` | Eliminating stub + Base `p111` segments halves segment count (`64.6k -> ~30k`) |
| **`x187_elf`** | **`24,146`** | **`6.7%`** | `1,932` | `2,128` | Scales directly with segment count |
| **`x187_priv`** | **`8,145`** | **`2.3%`** | `1,677` | `48` | Already crushed by `S10-C` + `S10-H`! |
| **`read` + `prep`** | **`2,728`** | **`0.8%`** | `283` | `271` | Negligible |
