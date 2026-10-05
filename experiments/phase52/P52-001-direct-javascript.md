# P52-001: upstream-compatible direct JavaScript backend

Status: prototype value gate passed on eight points; expansion and independent
semantic qualification in progress. No direct-backend release promotion claimed.

Hypothesis: making direct calls/native closures the ordinary lowering strategy
removes descriptor/guard overhead for a broad range of checked Bend programs.

See the [design](../../design/phase52/direct-javascript.md). The new mode has the
upstream callable interface; the existing mutable descriptor interface remains
available. The TypeScript implementation is a reference/bootstrap only.

Falsifiers: incorrect erasure, staging, effects or representation; hidden legacy
runtime dependency; no executed code-shape change; wins limited to renamed
special cases; or clean multi-shape execution failing to show substantial gains.

Outcome and evidence will be recorded in
[implementation/phase52](../../implementation/phase52/README.md).

## Measured prototype outcomes, 2026-10-05

The complete [prototype report](../../implementation/phase52/prototype.md)
preserves both measured images, exact timings, resources, identities and limits.
The same eight diverse points were acquired from each checked compiler, passed
all exact-output smoke checks, then completed 72 fresh three-role samples using
the unchanged 60-profile timing protocol.

| Checked image | Direct / same-run TypeScript, eight-point GM | Phase51 / same-run TypeScript | Phase51 / direct speedup | Screen wall |
|---|---:|---:|---:|---:|
| direct02 | 3.070041× | 5.170823× | 1.684285× | 57.658 s |
| direct03 | 1.035221× | 5.239968× | 5.061691× | 58.487 s |

Direct02 regressed lexer, numeric recurrence, closures and tree relative to
Phase51; those observations remain in the original completed receipt. Direct03
improved every selected point relative to Phase51. Its ratios against TypeScript
range from 0.87772× to 1.12016×. Each checked build took about 56.9 s and each
eight-source acquisition about 42 s; no heap or RSS limit was raised.

The evidence supports the general architectural hypothesis: ordinary direct
calls/native closures and upstream-compatible values can remove much of the
execution gap without benchmark-name specialization. Direct03 combines call
analysis/selective forcing, arity raising and tail/expression refinements; this
experiment does not isolate the contribution of each change. It also changes
the public contract explicitly, so the result is not evidence that legacy
mutable descriptor semantics can simply be discarded without consequence.

The independent direct03 library gate subsequently passed55/55 scenarios across
14 fixtures against upstream. The explicit subset excludes four program/FFI
fixtures, which remain unqualified at this checkpoint. Verbatim timing,
semantic and acquisition receipts are in the
[tracked prototype packet](../../selfhost/tools/performance/phase52/evidence/prototype/README.md).

This is a prototype subset, not full45 parity or completed semantic/FFI
conformance. Later source/runtime images need fresh gates. The report provides
the pending full45 acquisition and three fifteen-point comparison commands.
