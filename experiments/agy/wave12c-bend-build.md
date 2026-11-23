# Wave 12-C: Pure-Bend Pipelined `bend_build_pipe` Driver

**Status:** PASSED | **CPU:** `7` | **Source:** [`research/agy/w12_campaign/w12c_bend_build/bend_build_pipe.bend`](../../research/agy/w12_campaign/w12c_bend_build/bend_build_pipe.bend) | **Receipts:** [`results.json`](../../research/agy/w12_campaign/w12c_bend_build/results.json)

## Objective
Replace Python build orchestration (`run_p4_native_repro.py`) with a 100% pure-Bend standalone native binary (`bend_build_pipe`) supporting `--jobs N` parallel `IO.fork`/`IO.join`/`Chan.*` + `Process.run` workers, pipelined `x86-iface` + `x86-module-fast` execution, dual FNV-1a content + `.p130` stamp caching, and native `x86-merge-obj` + `gcc-10 -O2 -no-pie` linking.

## Key Results
- **Typecheck & Purity:** `ALL PROOFS CHECK`, `0` `@unsafe` declarations.
- **Native Binary:** Compiled to a standalone **655 KB** native x86-64 ELF binary (`bend_build_pipe`) with zero Python and zero JS/Bun at runtime. (Note: `n3_w10 x86-object` type-checked `bend_build_pipe.bend` cleanly but rejected `Chan.close` at its ABI11102 fixed-runtime gate, since `runtime-agy.o` does not include `Process.run` / `Chan.*`.)
- **4-Scenario 3-Module DAG Verification (`modA -> modB -> modC`, `n3_w10`, `--jobs 2`, CPU `7`):**
  1. **Cold pipelined:** `3/3` rebuilt, `iface_ms=19935`, `compile_ms=20626` (`modA.o` + `modB.o` 100% overlapped behind `x86-iface`, saving `2,821 ms`), `merge_ms=66`, `link_ms=38`, `total_ms=20730`, `out=42`.
  2. **No-op rebuild:** `0/3` rebuilt, `total_ms=1 ms` (`< 100 ms`), all 3 `.o` SHA-256 untouched, `out=42`.
  3. **Mid-stack body-only edit (`modB`: `20 -> 30`):** `modB.p130` stamp identical (`f5c7e17ef48e3b09`) → **only `1/3` module (`modB.o`) rebuilt**, `modA.o` and `modC.o` SHA-256 untouched, `total_ms=9962`, `out=52`.
  4. **Interface-changing edit (`modB`: `+extra_b`):** `modB.p130` stamp changed (`f5c7e17ef48e3b09 -> f47801cbb3a1ee37`) → `2/3` modules (`modB.o`, `modC.o`) rebuilt, `modA.o` SHA-256 untouched, `total_ms=10750`, `out=52`.

Full details in [`research/agy/w12_campaign/w12c_bend_build/REPORT.md`](../../research/agy/w12_campaign/w12c_bend_build/REPORT.md).
