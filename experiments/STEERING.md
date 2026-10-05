# Current compiler: Phase48 RNFA04; latest investigation: Phase49

RNFA04 is installed. Release verification, all 42 ordinary/relocated CLI checks
and portable replay pass. The [report](../implementation/phase48/README.md),
[results](../implementation/phase48/results.md),
[compiler costs](../implementation/phase48/compiler-cost-final.md),
[representation guide](../docs/self_hosted/phase48-representations.md) and
[portable benchmark guide](../selfhost/tools/performance/phase48/README.md)
describe the selected version. Preserve all 103 unrelated starting files and
closed historical evidence. No PR comment is authorized.

Selected API: `6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100`.
The runtime remains byte-identical to array06:
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.

## Selected mechanisms and scope

RNFA04 retains the existing typed private calls, layouts, bounded native recursion,
continuation fallback and private Array regions. It adds four composable slices:
handle-preserving public composite results (R), proved native String operations
(N), finite F32 literal decoding with the original shared-view write retained
(F), and typed Array effects/literal handles (A). A bounded general count mapping
declines unprofitable direct zero/one-trip literal entry. Existing selector
precedence, dependency/host checks and ordinary fallbacks remain. There is no
program-name recognizer, mutable-host permission cache or target migration.

All focused controls and eight maintained semantic suites pass. Fresh backend
agreement covers all 81 observations: **69 execution passes, eight N/A and four
shared failures**. The 3,026-main / 196-broader frontend inventories remain
historical unchanged-frontend evidence, not new Phase48 executions. These counts
have overlapping scopes and must not be summed. This remains a checked B1
derivative, not a new self-emitted fixed point. Native IO.args remains a known
gap; broad native/GPU execution and independent proof validity are unestablished.

## Current measurements and tradeoffs

All **45 points / 23 sources / 669 fresh samples** pass. Equal-point slowdown
changes **2.9024375× → 2.6789370× TypeScript**, a **1.08343× speedup**: 8.34% faster
or 7.70% less execution time. Equal-source slowdown changes 3.9789231× →
3.6792514×; equal-family changes 4.4796607× → 3.9120521×. Historical array06's
2.919418× result is not this campaign's fresh denominator.

Generic row improves **13.467×**, with its complete four-array result observed.
Unicode16/64 improve **1.257× / 1.462×**; numeric1024 improves **1.062×**. Generic
row accounts for **72.1% of net equal-point logarithmic gain**; the other 44
points collectively improve **1.0231×**. The aggregate does not establish a large
gain for most programs or universal TypeScript parity. Morning, scalar-zero,
RLE, Map/Set and Evening remain approximately 49–62× TypeScript time.

Twenty-three medians improve and 22 regress. The largest regressions are closures64
3.25%, lists512 2.49% and tree-bitonic 2.31%, with byte-identical program output.
Short fold has changed output and regresses 2.12%; the static fallback-guard
addition does not prove that guard executed in timing. Signs and drift are not
significance tests, and the regressions are retained. The supplementary literal
screen still has **30.63% / 18.64%** zero/one-trip overhead despite strong gains
at 128/8192 iterations; those extra points do not alter the primary weighting.

Source grows **406 physical lines (+1.75%)** to **23,660**, with 19,489 code lines,
2,673 definitions, 87 types and 92 modules. Generated output across 24 distinct
source/output pairs grows 0.72%. All 18 fresh compiler requests match expected
outputs, but median requests regress **3.274% Evening / 4.411% lexer**. This
two-source screen is separate from program execution and self-compilation. No
source simplification or compiler-throughput improvement is claimed.

## Next experiments after Phase49 V8 diagnosis

The [Phase49 investigation](../implementation/phase49/README.md) changes the
priority. Installed RNFA04's RLE output is byte-identical to retained array06.
Five named guard routines account for 79.44% of sampled baseline self time, and
reflection dominates roughly 33KB of estimated allocation per public call.
A controlled but unsafe guard bypass changes 39.343µs to 0.804µs, against 0.589µs
for TS. String-check omission alone reaches 22.370µs. These are one fixed
six-element source's diagnostics, not legal optimizations or a new corpus ratio.

First derive **required guard effects from complete original-source and runtime
observations**, including forcing, errors, mutation and reentry. Test one omitted
category with adversarial controls before implementing a compiler pass. Static
absence of String operations among 17 dependencies is not enough. Preserve fresh
validation where needed; do not cache permission across public calls or assume
immutable host prototypes. Also investigate cheaper checks retaining the same
coverage and safe amortization inside a genuinely established region.

V8 already inlines the RLE step and optimizes both loops before measurement.
The rejected tuple pass removes real allocation sites but adds shared-context
loads/stores, initialization and barrier paths. In the bypass pair it allocates
about 2,549→1,770B/call yet is 3.88% slower. Test caller-local scalar transport with
one saved-output ablation before building another broad convention. Do not infer
speed from fewer IR nodes or constructors.

Matched recursive function families, expression producer/fold fusion and larger
program admission remain open, as documented in
[Phase48 opportunities](../implementation/phase48/remaining-opportunities.md).
Require actual hot-path activation and cheap clean speed evidence before a
checked compiler implementation. The new
[V8-aware guide](../selfhost/tools/performance/phase49/README.md) complements the
20/60/300-second benchmark selections with separate profiles, inlining traces and
filtered optimizer/code dumps. No compiler build or full-corpus rerun was needed
for Phase49. All unsafe derivatives remain uninstalled.

Keep JS primary. The preserved [Phase46 JS/C study](../implementation/phase46/README.md)
shows allocation and curried-call/continuation transport must improve before
switching backend: our C lost to our JS on five of six batch workloads. LLVM and
assembly remain deferred. The upstream pin is `018751270e800bc222a93dad7f257083ee53a5f7`.
