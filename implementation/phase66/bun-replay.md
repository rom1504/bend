# Focused Bun replay

The closed Node campaigns each retain 1,170 JavaScript observations. Both have
the same 51 runtime rows reporting unavailable `bun:ffi`. The explicitly
authorized additions are `base/read_bounds`, `io/file_open_mode`,
`io/stderr_failure`, `io/process_run`, and `io/process_run_parallel`. These
cover libc error text and `Bun.spawnSync` behavior. The known NaN reference
failure is excluded from this runtime-specific selector.

The [controller](../../selfhost/tools/performance/phase66/controls/bun-replay-v1.mjs)
and [method](../../selfhost/tools/performance/phase66/controls/bun-replay-v1.json)
reuse the retained TypeScript `.cjs` and Bend `.mjs` programs. They do not compile
again. Both roles must have checked runtime provenance and a retained module;
otherwise the case is recorded as `no-paired-replay`. Programs execute only
from fresh copies of their artifact directories. The original frozen fixture
description and judge supply every expected output and exit behavior.

The selector yields 56 cases. `gfx/app_linear` is conservatively deferred along
with any selected window/audio case; it is not counted as passed. With complete
paired artifacts this leaves 110 Bun executions. The official Bun 1.4.2 binary,
release metadata and downloaded archive are pinned. Its binary SHA-256 is
`a83d263767d839e4d2649ca8e35d07159c7afc99afdc96d731ced29e056dda0c`.

The root-only recipe is `selfhost/build/phase66/bun-replay01-recipe.json`, SHA-256
`494d1948e386f62212fc1777e4406e22a24028cd6a1f78cc402994f2adae0b1d`.
It uses the existing sole serial guard: CPU3, 1 GiB Node heap, 4 MiB stack,
2 GiB process-tree RSS limit and 4 GiB available-memory floor. Each Bun program
has a ten-second deadline and one MiB combined output limit. A positional shell
forwarder preserves stdout/stderr order; it passes no Node flags to Bun and
kills the process group on timeout, overflow or completion.

Partial JSON observations are saved throughout. Original Node results remain
unchanged, and original input/artifact identities are checked again afterward.
A completed replay can still report failures or deferrals and exit nonzero.
The method and selector above were frozen before execution. The completed
result follows; failures and deferrals remain visible.

The completed [audit receipt](evidence/bun-replay01.json) records **54 paired
passes, one shared failure and one graphics deferral** across 56 selected cases.
All 55 executed pairs produced byte-identical output and equal exit codes. This
includes two tests whose golden behavior requires a nonzero exit. There were
110 Bun actions, no compiler invocations and no rewritten Node observations.
The data-only audit rehashed 3,254 identities and rechecked the complete file
inventories of 112 original artifact directories.

The sole executed failure is `io/process_run.bend`. Both programs pass its first
14 checks, then print `inherited pipe: unexpected failure` and
`descendant output: unexpected failure`, where the golden output requires
`True`. Their identical 321-byte output has SHA-256
`e192ca277f6e8e28886dad3c0a27a351610c9143b69307fb734b16fd4c61d4d1`.
The two checks launch `sleep 3 & echo hi` and `yes & echo hi` with a 1,500 ms
limit. Our provider is byte-identical to the pinned upstream provider: it calls
`Bun.spawnSync`, captures pipes and converts timeout, output-limit or spawn
errors into a failed result. The fixture hides the actual error code, so these
observations identify shared process-provider/runtime behavior without proving
which failure branch fired. They do not identify a difference between the
compilers. A future focused provider diagnostic can expose that code if this
shared upstream behavior becomes a priority.

The guarded run took 19.486 seconds, peaked at 301.3 MiB process-tree RSS and
had at least 26.13 GiB available memory. No deadline, output or resource limit
stopped a program. The replay report is `complete: true, pass: false`; the guard
retains exit 1 and `complete: false` because its completion flag also requires
exit 0. That distinction preserves the shared oracle failure and deferred gfx
case rather than silently declaring the campaign fully conformant.

Raw results remain in `selfhost/build/phase66/bun-replay01/report.json`, with
supervisor data in `bun-replay01-exec/process.json`. The
[data-only audit](../../selfhost/tools/performance/phase66/controls/audit-bun-replay-v1.py)
records both parent Node reports, the frozen judge, Bun acquisition, exact
emitted modules and each paired result. This evidence covers the retained
State04 Bend programs and pinned upstream TypeScript programs under Bun 1.4.2.
It does not independently qualify a later compiler image or turn the original
Node failures into passes.

A separate [State07 reuse audit](../../selfhost/tools/performance/phase66/controls/bun-reuse-final07-v1.py)
is prepared for the final closed Node campaign. It binds the selected checked
image and derivation, both project snapshots, each source/golden request, the
unchanged judge, every emitted module and auxiliary payload file, and the full
JavaScript runtime/provider inventory. A prior Bun outcome transfers only when
these program and runtime bytes match. Changed or absent programs produce an
explicit focused replay request. The shared failure and graphics deferral keep
their original status. The producer is data-only; preparing it does not claim
that any State07 observation has been transferred yet.

The completed [State07 byte-reuse receipt](evidence/bun-reuse-final07-v1.json)
now qualifies all **55 previously executed pairs** for the selected compiler.
There are no changed program or runtime/provider bytes and no focused replay
requests. The inherited results remain **54 paired passes, one shared
`Process.run` failure and one unexecuted graphics deferral**. This is a checked
transfer of existing finite runtime observations, not 110 new executions.
The data-only audit ran in 4.25 seconds and pinned the final closed 1,170-row
Node report, selected `bb6c6e2a…` image, its checked parent and derivation, and
both frozen project closures. The original Bun and Node reports remain intact.
