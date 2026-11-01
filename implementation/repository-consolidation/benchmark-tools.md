# Benchmark tool consolidation smoke

The maintained acquisition and timing workflow passed a real two-case smoke on
`mandelbrot` and `tree-bitonic`. Both roles passed independent complete-result
and success-count checks; the frozen outputs then passed two balanced rounds in
both the program runner and cold-request runner. This audit read existing root-run
receipts and executed no new compiler or program targets.

[Machine-readable evidence](benchmark-tools-smoke.json) records exact source
receipt hashes, host/stage/target, clocks, samples and the tracked-code audit.
The receipts are `selfhost/build/consolidation/bench-acquire01/report.json`,
`bench-programs01/report.json` and `bench-compiler01/report.json`.

| Gate | Result | Recorded wall time |
| --- | --- | --- |
| Catalog acquisition, upstream C and native N2 QBE | 2/2 cases, all products and independent oracles pass | Acquisition excluded from speed clocks |
| Prepared-program timing | 8/8 samples pass; two rounds per role/case | 5.151 s of a 20 s ceiling |
| Fresh compiler requests | 8/8 samples reproduce complete frozen outputs | 16.526 s of a 20 s ceiling |

The program intervals retain their original workload semantics: native elapsed
milliseconds cover the repeated Bend workload, complete result checks and count
printing, divided by repetitions. JS uses the preserved callable worker with
first-call/warmup/calibration separated from timed calls. Acquisition, compiler
execution and native machine construction occur before program timing.

Cold requests start a fresh compiler child and time its whole lifetime. Startup,
source/Base reads and output writes are included, as are any checks performed
inside a hosted/reference adapter. Parent preflight and complete-output comparison
are outside the clock. A prepared Base is explicit; operating-system caches are
not flushed. Machine construction is a different scope. B1/B2 and native N1/N2
identify actual producer generations, not interchangeable aliases.

The smoke compares an upstream TypeScript compiler emitting **C** with a native
N2 compiler emitting **QBE**. Its request ratios are not same-target compiler
parity. These two cases also do not establish representative program speed:

| Case | Upstream C program ms/call | N2 QBE program ms/call | N2/upstream | Upstream C request ms | N2 QBE request ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| mandelbrot | 0.024015 | 0.080235 | 3.341× | 2209.544 | 2295.448 |
| tree-bitonic | 0.127445 | 0.581601 | 4.564× | 2089.863 | 1199.024 |

These are migration evidence, not new speed gains. The maintained catalogs still
contain all 45 input points from 23 sources; native timing has 44 eligible points
and one correctness-only zero-work point. A full score requires its complete
selected corpus. The 20/60/300/600 second tiers are ceilings, not guaranteed
coverage on every machine.

The source review confirmed current upstream `book_load`, `book_valid`,
`js_lib(book,true)` and `compile_book` signatures and the actual hosted library
operation. Future catalog additions with fixture-local imports must authenticate
those dependencies too. Failed references remain failures. Existing 13 offline
Python controls and JS synthetic execution, AST and CPU/allocation controls are
recorded in [validation status](../../selfhost/tools/bench/validation.json).
This native smoke does not additionally qualify the JS real-product acquisition,
native-C telemetry replay or full B1/N2 same-target campaign.

At audited HEAD `739cb09dff785ef14ee4ba4a97b74a9f8ef58f9f`, old JS benchmark workers
and the selected C93/QBE144/compiler105/145/146 campaign runners are no longer
tracked. Historical catalogs, expected outputs, independent oracles and C harnesses
remain evidence. Two compatibility methods remain: the 163-line
`performance/programs/support.py` supervisor and `performance/phase86/guard.py`.
The supervisor equals maintained `tools/execution.py` after its root-path change;
the old native launcher/assets/build adapter still reference both historical paths.
The current retention guard already uses `tools/execution.py`. Those compatibility
paths need a separate launcher-retirement gate; this report does not claim that
all duplicated tool implementation has vanished. Untracked recovered historical
files are outside this tracked-HEAD audit.

The final identity audit found that `build/request.py` changed after these stored
smokes; the benchmark runner itself still matches its recorded pin. Both stored
manifests correctly reject that method drift on reuse. The recorded passes remain
evidence for their consumed methods. Regenerate the current acquisition/manifest
explicitly before a fresh run; do not rewrite consumed receipts or relabel these
timings as validation of the later request adapter.

Current commands and target boundaries are in the [maintained workflow](../../docs/self_hosted/workflow.md)
and [benchmark guide](../../selfhost/tools/bench/README.md). No frozen compiler,
asset, runner or timing method was edited for this final documentation audit.
