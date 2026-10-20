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

The separate final verifier remains in both cases. Full-image scaling now completes; see the acquisition result below. Exact receipts are under `selfhost/build/phase114/`: baseline/cached
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

## Full compiler acquisition now completes

Verification reuse plus the mature product signature index emits the complete
compiler's own source in502.479s guard wall, peak3.547GiB. The output contains
60,356,569 QBE bytes,33,800 segments and808 direct functions. Stage seconds:
frontend206.715; product planning96.965; verification boundary33.149;
inlining/direct check30.502; ranges/direct check28.769; final verifier43.014;
QBE emission59.808. The signature index preserves first-definition lookup and
exact QBE on the two small staged kernels.

The QBE/as/link machine build completes in7.969s. Its native image passes all
five fast-suite programs in5.777s. This clears the prior600s lowering timeout;
these changed-source observations are not a controlled speed ratio. N2/full
self-reproduction are not yet established. The image contains the scaling/index
changes only; the runtime experiments remain separate at this point.
Receipts: `phase114/catalogue-full01`, `phase111/p114-catalogue-native01`,
`phase111/p114-catalogue-native-fast01`, and corresponding Phase114 guards.

## General continuation result

The next prototype admits a bounded captured environment and a checked local
resume helper, preserving operations after recursion. Both independent ordinary
controls (zero captures and multiple owning captures) pass complete outputs.
The initial second fixture had a frontend-invalid local match; its preserved
v2 gives that match an explicit helper argument, with unchanged expected bytes.

In three paired rounds, list pipeline falls766→360ms (2.128× faster than31),
while lexer393→392ms is unchanged. All18 measured outputs/counts pass. The list
remains6.923× upstream; the two-case geometric mean is7.295×. This is a broader
local-control mechanism, not aggregate45 parity. Source/receipts:
`phase113/p114-general-source01`, `phase114/general-controls-plan02`,
`phase112/p114-general-screen01-measure`.

The final-emission frame/pop/get expansion passes source/runtime admission,
12 structural groups,11 ordinary programs and36 benchmark output/count checks.
Four-case elapsed time falls5.47% geometrically (tree555→523ms, lexer358→345,
list707→674, expression489→451), still9.830× upstream on that subset.
See [P114-005](../../experiments/phase114/P114-005-fixed-transport.md).
A combined candidate is being checked; none of these isolated ratios is a
combined or broad45 result.

The eight-program development screen is frozen before candidate timing, uses
unchanged original45 sources/oracles/repetitions and includes scalar, arrays,
ray, lexer, list, tree, expression and map workloads. It does not replace45.
All target work is serial on CPU3 with memory/time guards. No PR comments.
