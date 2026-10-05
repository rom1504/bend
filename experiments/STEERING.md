# Current compiler: Phase52 direct06

The user authorized a direct-backend prototype followed by full implementation
if it proved valuable. The one-hour prototype gate passed; direct06 is installed
with all42 legacy and18 direct CLI checks plus release verification passing.
The final portable replay also passes 3 cases/27 samples. All raw writers are
closed; the compact packet and complete raw archive are published with hashes
in the [publication receipt](../selfhost/tools/performance/phase52/publication.json). See the
[report](../implementation/phase52/README.md), [results](../implementation/phase52/results.md),
[direct guide](../selfhost/docs/direct-javascript.md), and
[benchmark recipes](../selfhost/tools/performance/phase52/README.md).
No PR comment is authorized. Preserve all103 unrelated starting files and closed
historical evidence. New investigations must use a new phase and fresh outputs.

API: `472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a`.
Source: `3c5671579628de5c113907403188df17e3d35a15dd520bc1d20b6dc3263d3513`.
Direct runtime: `417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a`.
Compatibility runtime: `3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46`.
Upstream: `018751270e800bc222a93dad7f257083ee53a5f7`.

## Selected behavior and limits

`--direct-js` uses lexical functions, native closures/data, demand-sensitive
views, native intrinsics with inert actuals, self/mutual tail loops, program IO
and foreign modules. Ordinary compilation runs Bend code. The old mutable-G
interface remains default compatibility mode; no legacy guard was silently
removed. The 37 pinned Base JS effect providers are vendored for relocation.

All101 live source modules match frozen06; all92 original modules match Phase51.
The new backend adds1,746 code lines in nine modules; keeping both interfaces
increases total physical Bend source9.0%. Generated whole-module bytes fall
about75% relative to Phase51. These are different size measures.

Independent semantics pass95/96 scenarios across29 checked fixtures. The source
NaN-payload oracle is40; TS returns1 and direct39. This remains an unwaived failure,
not full conformance. The direct JS census agrees on26 rows (18 runtime passes,
four expected compiler rejections, four N/A); all eight maintained suites pass.
Legacy core8 is byte-identical to Phase51 and passes a separate120-sample gate;
its earlier20s budget-exhausted attempt remains failed. Broader native/frontend
inventories are historical. No new self-emitted fixed point or compiler-throughput
parity is established. Direct analysis currently refuses beyond512 definitions
and other documented bounds. Arbitrary numeric-table/global-hook identity is
not promised.

## Measured results and rejected work

All45 points /23 sources /669 fresh samples pass. Equal-point Phase51/TS is
2.630605× and direct06/TS1.123799×: a2.340815× speedup. Equal-source values are
3.582113× and1.129112×: a3.172504× speedup. Historical Phase51's2.928× result is
not the denominator. Twenty-nine points are within10% of TS; nine are faster;
the worst direct/TS point is1.994×. This maintained corpus informed development.

Seven points regress against Phase51, five by more than10%. Closures256 and
list512 lose2.217×/1.781× against already-faster legacy specializations while
remaining1.038×/1.020× TS. Keep them visible. Three descriptive drift/spread
flags remain; no rows are excluded and no significance/JIT-convergence claim
follows from unflagged rows.

P52-002's atomic intrinsic expansion gains7.4% in its own paired screen, missing
its prewritten10% target. It was retained by an explicit separate engineering
decision: five sources improve>5%, none regress>10%, and exact byte attribution
plus semantic controls pass within the known NaN limitation. P52-003's computed
operand IIFEs lose25.75% overall and3.568× on Mandelbrot. They are rejected and
preserved. Do not reintroduce that lowering merely because it removes wrappers.

## Next investigations

1. **Ordered expression lowering:** emit statement prefixes plus one value,
   materializing earlier effectful operands before later prefixes. Keep work
   inside its original branch/closure/demand scope. Compare actual straight-line
   arithmetic with pinned `js_call`/`emit_hold`; preserve once-only evaluation,
   Math getter/coercion order, partial calls and aliasing. The IIFE failure does
   not establish a specific V8 mechanism or prove this successor faster.
2. **NaN and numeric tables:** first localize cold/repeated raw-bit differences.
   Separately evaluate bounded constant folding and scalar match tables, which
   explain some raytrace code differences. Do not canonicalize payloads, change
   the oracle, or warm up a failing first call to hide it.
3. **Retain the best private optimizations:** investigate why legacy closure/list
   workloads beat TS, and port a general proved transformation into direct mode.
   Avoid benchmark-name selection or a per-program backend selector.
4. **Scale compiler-sized inputs:** replace conservative call-analysis limits
   with a scalable bounded graph implementation, then measure compiler requests
   and a direct self-emission. Existing small-program timings cannot establish
   self-host throughput or fixed-point correctness.

Use the three-minute checked build/eight-emission/short-screen loop for narrow
candidates. Independent agents can write source, controls, analysis and reviews;
serialize heavy targets and keep clean timing free of compilation/compression.
A final45 campaign costs about22 minutes including acquisition. Freeze once and
run it only after smaller falsifiers survive. Reuse exact emitted-byte evidence
where valid; keep failed protocols and their successors distinct. Resource
limits remain1GiB heap,2GiB tree RSS and4GiB available memory. No OOM occurred in
this phase's guarded builds; the largest build was below1.5GB tree RSS.
