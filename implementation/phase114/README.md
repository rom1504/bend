# Phase114 — visible runtime semantics and bounded compilation

Work in progress, started 2026-10-20 21:31 UTC from `6259718`.
[Design](../../design/phase114/qbe-parity-and-staged-runtime.md) ·
[Architectural comparison](../../design/phase114/architecture-options.md).

The starting candidate31 is 7.088× pinned upstream C/Clang program runtime over
44 timed points of the original45 corpus. Its full native image acquisition
times out during lowering. Phase112 facts remains the qualified native compiler;
installed selection is unchanged. New observations below are not a new broad
ratio or a native self-hosting claim.

## Verification reuse: first completed change

The Bend optimizer now has an internal verification session: validate the
unchanged original graph once, retain its IDs, and validate each changed direct
function graph. The independent final verifier remains. Invalid transformations
keep the prior valid graph. No external certificate authorizes emission.

All18 positive controls pass. Ten ordinary source requests in two A/B/A/C/A
sequences preserve exact QBE and constructor catalogues across the baseline and
candidate, including repeated names with different layouts. Local-pair and the
list-pipeline workload also emit byte-identical whole QBE files before/after.
This establishes generated-product nonregression for these requests, not a
whole-compiler theorem.

Single-run stage diagnostics, seconds (not a qualified speed benchmark):

| Source | Prior inline + range stages | New boundary + inline + range stages |
|---|---:|---:|
| local-pair | 4.702 | 3.242 |
| coverage-list-pipeline-128 | 1.622 | 0.636 |

The separate final verifier remains in both cases. Full-image scaling remains
unmeasured. Exact receipts are under `selfhost/build/phase114/`: baseline/cached
split reports, `scaling-controls01`, `scaling-session01`, and associated guards.
Compiler source: `phase113/p114-scaling-source01/compiler.bend`, SHA256
`57247caf806136c4581ae23191449775348246a496852a9f14c174dde0373685`.

## Runtime experiments in progress

The first runtime template exposes two-field constructor consumption to QBE,
with ordinary runtime fallback for shared/static/allocator-boundary cases. It
uses the unchanged authenticated runtime object. Its source API and exact
source/runtime admission pass. Five ordinary generated programs pass complete
outputs: two-owned-fields, nested-owned-fields, string-field-alias,
append-owned-suffix and recursive-fallback-shapes. Timing remains pending.

The ambitious prototype keeps a recursive constructor spine in a local
descent/unwind region while preserving the original explicit frame stack and
allocation order. This aims to remove repeated global dispatch without arbitrary
native recursion. It remains unqualified until source checking, actual admission
and complete-output gates pass. Initial checker failures are retained; they are
not program performance observations.

The eight-program development screen is frozen before candidate timing, uses
unchanged original45 sources/oracles/repetitions and includes scalar, arrays,
ray, lexer, list, tree, expression and map workloads. It does not replace45.
All target work is serial on CPU3 with memory/time guards. No PR comments.
