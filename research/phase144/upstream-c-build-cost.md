# Upstream C acquisition cost: bounded diagnosis

This is source inspection and existing receipt analysis, not a new compiler run.
The selected experiment keeps the exact Bend source, emitted C, embedded upstream
runtime, pinned Clang and link recipe. Only `-O2` changes to `-O1`.

## Observations

- Successful upstream emission: `phase102/p144-integrated-upstream01/report.json`.
  Its C product is 32,974,652 bytes, SHA256
  `86507cdd1b3a24abdf777b9c47b34b37e0271f54a449ad556e6172d1e36d03d3`.
- The O2 build was stopped by its process-tree RSS guard after 104.302 seconds,
  at 6,442,622,976 bytes against a 6 GiB cap. Its stderr is empty. This is a
  bounded acquisition failure, not evidence identifying the particular LLVM pass
  responsible: `phase144/integrated-c-build01-guard/process.json`.
- The emitted file has 1,104,348 lines. `WL_TABLE` contains 21,973 entries. Every
  segment declaration uses `WL_SIG`: 214 `Term` registers, `rp`, and four
  environment/control arguments (219 formal arguments). The table alone therefore
  implies approximately 4.81 million formal argument slots, before call operands,
  local instructions and optimizer data structures.
- Host `WL_FN` is `noinline` with `preserve_none`; transitions use `musttail`.
  There are also 641 `INLINE Term spin_*` helpers. `INLINE` is ordinary
  `static inline`, with no `always_inline` occurrence in this C product.
- Source byte count does not predict build memory reliably. Phase103's upstream
  bridge built in 191.22 seconds at 4,242 MiB RSS. Phase106's mature self-hosted C
  product was 30,373,059 bytes and built with this same pinned Clang/O2 in
  375.644 seconds at 2,491,012 KiB RSS. These differ in source/backend/ABI and
  are contextual observations, not controlled before/after measurements.

Source references: generated C lines 120–124 (`WL_FN`/tail transfer), 23403
(`WL_SIG`), 23407 (`WL_TABLE`), 49247–49252 (function declarations/table).
Historical receipts: `implementation/phase106/self-clang-clean.json`;
`implementation/phase103/README.md`, build table.

## Interpretation and bounded next step

The large common calling convention is a credible contributor to frontend and
LLVM IR memory. Optimization may amplify that cost, but the existing guard
receipt cannot distinguish parsing, IR generation, optimizer or machine-code
phases. Missing forced inlining is not the only explanation, and suppressing
ordinary inlining indiscriminately could damage the execution comparison.

Try **one O1 build**, unchanged 6 GiB RSS guard and roughly 180-second child
limit, using `selfhost/tools/performance/phase144/build-c-o1-v01.py`. This method
is an exact derivative of `build-c-v02.py`: optimization level, default deadline,
receipt kind and scope description change; identity/admission checks do not.
The parent supervisor still owns CPU, available-memory and disk limits.

O1 retains optimized host calling-convention selection (`__OPTIMIZE__`) and
ordinary optimization, while spending less optimizer effort. It does not remove
the wide ABI or guarantee that the build fits. If it fails, stop this lane and
retain the explicit acquisition blocker; do not expand the memory budget or
start a flag search without a new reason.

A successful binary must pass the existing independent ordinary request oracle
before timing. Label its results **same-source upstream-C/Clang-O1 diagnostic**,
not upstream-O2 parity or a fastest-possible C ceiling. A faster O1 compiler would
be valuable positive evidence of generated-code headroom. A slower result would
be inconclusive about optimized C. Neither observation changes the qualified
native compiler, runtime selection or generated-user-program benchmark.

No C source rewriting, runtime replacement, wider ABI allowance, feature
pruning, or new compiler target execution was performed for this audit.


## 2026-10-26 consolidation update

The proposed O1 attempt has now run and also stopped at the process-tree RSS
limit: 103.464 seconds, following O2's 104.302 seconds. Both failures are retained
at `phase144/integrated-c-{o1-build01,build01}-guard/process.json`. This lane is
stopped; no same-source C executable or runtime ratio was obtained. The earlier
proposal and causal uncertainty remain historical evidence, not a pending retry.
See the [consolidated findings](../../implementation/phase144/profiler-and-cost-findings.md).
