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
append-owned-suffix and recursive-fallback-shapes. Three paired kernels improve
only2.83% in geometric mean elapsed time, still11.16× upstream on that selected
set. This establishes limited reach and motivates representation/control work;
it does not justify a broad performance claim.

The ambitious prototype keeps a recursive constructor spine in a local
descent/unwind region while preserving the original explicit frame stack and
allocation order. Candidate04 passes source checking, actual admission and seven
ordinary complete-output gates. List-pipeline improves700→464ms over three
paired rounds (1.509×). Tree and lexer QBE remain byte-identical; their small
timing changes are noise. Initial checker failures are retained. A bounded
general continuation extension is under development, not yet qualified.

The next representation experiment restores mature unary constructor packing
at the shared constructor lowerer. Source checking, exact runtime admission,
all four ordinary output checks and27 benchmark observations pass. Three paired
rounds give tree554→490ms (11.55% less elapsed time), expression488→459ms (5.94%),
and list700→699ms (effectively unchanged). The three-case geometric mean improves
5.995%, still10.723× upstream. This is separate from the recursive candidate.
See [P114-003](../../experiments/phase114/P114-003-unary-representation.md).

Restoring the mature product signature index also preserves exact QBE on both
small staged kernels. Its small measured contribution does not establish the
large-source benefit; the full scaling gate remains outstanding.

The eight-program development screen is frozen before candidate timing, uses
unchanged original45 sources/oracles/repetitions and includes scalar, arrays,
ray, lexer, list, tree, expression and map workloads. It does not replace45.
All target work is serial on CPU3 with memory/time guards. No PR comments.
