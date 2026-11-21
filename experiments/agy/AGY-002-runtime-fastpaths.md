# AGY-002 · ABI-11102 Runtime Fast Paths (`ctor`/`take`/`rfc`/`sink`)

- **Status**: **Measured win** (correctness & ABI verified; ready for broad 44-case native45 timing and combination with compiler passes).
- **Target**: Reduce constructor allocation/deconstruction and single-mutator refcount overhead in `selfhost/src/runtime/qbe/runtime.c` (which SIGPROF showed accounted for **26–47%** of `test-rle-roundtrip`, `coverage-bst-64`, `test-evening-program`, and `coverage-record-aggregation-256`).
- **Artifacts**:
  - Build & ABI verifier: `research/agy/rt/build_rt.py`
  - Benchmark runner: `research/agy/rt/bench_rt.py`
  - Optimized runtime object: `selfhost/build/agy/rt/runtime-opt.o` (`132,504` bytes, SHA-256 `464e88f399c53d23c615bcb136b1337ae4c7c110a5b437243a30ad6f71e952af`)
  - Raw results: `selfhost/build/agy/rt/bench/results.json`

## Changes (ABI-11102 & live-descriptor sound)
1. Cache physical corpus boundary `p111_heap_off = STAT_OFF + PAGE_UP(program->static_words)` once in `p111_bind` (does **not** cache mutable constructor metadata `cid_hot`, `cid_arity`, `constructor_count`, or `capabilities`).
2. Inline `rfc_wrap_ctr` / `rfc_wrap` in `rfc_seal` and add a leaf-fast batch class-0 sealing path in `p125_rt_ctor1..4`.
3. Explicitly unroll `N = 1..4` field copies (`P198_COPY_1..4`) and eliminate callee-saved pushes / stack frames on raw `p125_rt_take1..4` via cold tail-call helpers + fast tail-called `p198_rfc_take1..4`.
4. Under `P144_SINGLE_MUTATOR_RFC == 1`, replace 32-bit atomic loads + `a32_acq` in `rfc_view`, `rfc_bump`, `term_drop`, and `p111_rt_sink` with direct 64-bit loads/stores and an inline leaf fast path for shared RFC (`cnt > 1`).
5. Add `__builtin_expect` hints on cold allocator/take/ctor branches.

## Correctness
- **70 / 70** exact exported symbol match vs `runtime-live-scan.o`.
- **44 / 44** ABI contract tests (`selfhost/tests/phase183/abi-contract.c`) + **2 / 2** live mutable metadata controls (`research/phase198/runtime-broad/observer.c`: `owner-hot`, `owner-cap` → `sealed 1 field 13`) **PASSED**.
- Exact stdout verified on all 6 linked `native45` executables.

## Measurements (`runtime-opt.o` vs `runtime-live-scan.o`, `taskset -c 1`, 8 alternating rounds)

| Case | Reps | Base median | Opt median | Ratio (opt/base) |
|---|---:|---:|---:|---:|
| `test-rle-roundtrip` | 229,376 | 260.5 ms | 223.5 ms | **0.8580×** |
| `coverage-record-aggregation-256` | 192 | 197.0 ms | 172.0 ms | **0.8731×** |
| `coverage-bst-64` | 16,384 | 274.0 ms | 244.0 ms | **0.8905×** |
| `test-evening-program` | 49,152 | 171.5 ms | 158.0 ms | **0.9213×** |
| `coverage-map-churn-128` | 256 | 169.5 ms | 164.0 ms | **0.9676×** |
| `tree-bitonic` | 1,152 | 238.0 ms | 233.5 ms | **0.9811×** |
| **Geomean (6 cases)** | | | | **0.9141× (−8.6%)** |
