# Actual guarded scan lowering: first screen passes

The Bend-written selector checked and activated on all three ordinary fold
objects. Complete-program results and independent emitted-worker ABI controls
passed. In the first balanced five-round screen, SIMD elapsed time was about
27% of matched baseline at 4096 cells and 26% at 8192 cells; the 128-cell point
was about 55%. These are three sizes of one family, not independent-family
transfer or broad compiler qualification.

| Point | Live link order 1 SIMD/baseline | Live link order 2 SIMD/baseline | SIMD/mature C, live orders |
| --- | ---: | ---: | ---: |
| 4096 | 0.2743 | 0.2683 | 0.5451 / 0.5455 |
| 128 | 0.5455 | 0.5466 | 1.4338 / 1.4723 |
| 8192 | 0.2614 | 0.2599 | 0.5227 / 0.5234 |

The same candidate object linked against a scalar helper provides a causal
control: SIMD/scalar-delegate ratios were about 0.440, 0.736 and 0.430 for
4096, 128 and 8192. The scalar delegate itself improves substantially over the
old direct loop, so the whole gain cannot be attributed solely to SSE2. The
original runtime linkage also improved at all three points (SIMD/baseline
0.2730, 0.5297, 0.2605). Raw paired samples, including slower observations,
remain in the pinned report. This is one screen with two live link orders and
an original-runtime cross-check, not multiple independent sessions.

Source02 (`ff6e25fa…`) checked successfully on the first acquired candidate API
in 13.85 seconds. All 5 admitted and 28 rejected selector controls passed,
including alpha-renaming, commuted arithmetic, exact scalar fallback, stale
temporary overwrite rejection and preserved error branches. The actual generated
worker then passed 649 trials comparing 39,699 cells. Call counts observed 275
helper invocations, including 80 long raw paths, with no helper calls on
shared/static/uniform fallback paths. These results are owned by the independent
[control harness](../scan-controls/README.md).

Read-only actual ELF analysis confirms exactly one helper relocation per fold
worker, with correct argument snapshots and live owner/result-buffer homes.
The worker grows from 445 to 511 bytes; the per-cell scalar backedge is replaced
by one helper call. Edit-distance and Mandelbrot whole objects are byte-identical
to the qualified baseline. Their ordinary program oracles passed; the first
runtime screen times only the folds. Each fold additionally passed complete
program inputs 0/0, 1/UINT32_MAX and 129/17 against unchanged mature C, across
its matched links. The [machine audit](machine-evidence/report.json) pins each
object and includes a reproducible [read-only method](audit.py).

Guard costs after API acquisition: selector controls 0.52 s, five-object
emission 45.78 s, emitted-worker controls 0.27 s, product/oracle builds 5.98 s,
and timing 51.04 s. [evidence01.json](evidence01.json) pins complete reports,
guards and retention receipts. Compiler implementation is commit `69290f2`;
the independent runtime leaf is a separately required linked object. Maintained
compiler sources and installed selection remain unchanged. Native reproduction,
broader coverage, additional sessions and independent workload transfer are not
claimed by this first result.
