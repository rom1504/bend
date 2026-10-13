# Phase81: a revised route to compilation parity

Investigation, 2026-10-13. **No production compiler change or new speedup claim.**
Phase78 remains installed. [Design](../../design/phase81/compilation-parity-investigation.md),
[research](../../research/compilers_architecture_and_techniques/phase81/README.md),
[methods](../../selfhost/tools/performance/phase81/),
[clean timings](measurements.json), [CPU/allocation profiles](profiles.json),
[internal regions](regions.json), [qualification](qualification.json).

## Conclusion

Pursue two coordinated changes: remove fixed per-request text/book work, then
replace the annotation→erasure→native-analysis materialization chain with a
small per-function native representation and shared consumers. These are the
best-supported route to another roughly **25–35% reduction in B2 request time**
when combined with selective name-resolution work. That is an engineering
target, not a measured forecast or a guarantee. The components overlap.

Do not begin with another general cache, full typed graph, occurrence-only
summary or complete evaluator replacement. Phase79/80 measured the first three;
the new profiles place a bound on the last. Also distinguish B1 from B2: B1
spends much more on generated trampoline/closure machinery. A fast B2 backend
alone does not eliminate that bootstrap-image cost.

## Metric and controlled observations

We measured checked Bend-to-C requests, with reports, excluding imports,
explicit prepared Bend Base, Clang and program execution. TypeScript checks
Base inside its request. Backend products remain disabled. This is **compiler
latency**, not compiled C program execution. Images are unchanged Phase78 B1
`475610ea…`, genuine B2 `cc99ac9b…`, and upstream `0592662`.

Three fresh samples per role/source, rotated serially on CPU3:

| Source | B1 ms | B2 ms | TypeScript ms | B2 / TS |
|---|---:|---:|---:|---:|
| Numeric |1153.85|944.40|757.39|1.247×|
| Array |1326.27|937.61|764.25|1.227×|
| Lexer |1681.85|1277.43|870.41|1.468×|
| Small, 94 bytes |333.88|343.98|303.94|1.132×|
| Functions65, 3135 bytes |677.28|636.70|369.77|1.722×|

The three-source geometric ratios are **1.722× B1 /1.309× B2**. The previous
qualified comparison was **1.732×/1.382×**. No source changed: the apparent
B2 ratio improvement here is run variability, including slower TS Numeric/Array
samples, not an optimization. Retain the qualified baseline for planning:
B2 needs **27.6% less time**, B1 **42.3%**, to reach 1× on that screen.
Functions65 independently needs about42%; aggregate parity would not mean
parity on every program. Five sources are diagnostic coverage, not a replacement
for broader qualification.

Nine additional B2 requests turn off optional reporting: ratios to reporting
requests are0.9485 Numeric,0.9559 Array,0.9973 Lexer. This API returns different
proof-trust/report information. It is a labelled contract ablation, **not** a
candidate improvement or permission to change the benchmark. Preserving reports
while making them cheaper remains useful, but simply disabling them is too small.

## Fresh profiles change the emphasis

Separate CPU profiles; one per role/source. Instrumented stage clocks are
diagnostic and include JIT/GC effects. Boundaries are different on the two sides:
B2's final native stage has already received annotations/prepared bodies, while
TS emission consumes checked typed terms and does more preparation internally.

| Source | B2 annotation | B2 native preparation | B2 final native stage | TS emission |
|---|---:|---:|---:|---:|
| Numeric |70.0ms|85.9ms|444.7ms|430.2ms|
| Array |72.9ms|54.8ms|451.3ms|438.4ms|
| Lexer |72.2ms|84.4ms|642.1ms|627.9ms|
| Small |<5ms|8.6ms|168.3ms|17.4ms|
| Functions65 |6.4ms|28.4ms|248.8ms|76.3ms|

On the IO screen, final emission is already close; preparation and surrounding
work matter considerably. On the two simpler programs, the fixed backend cost
is striking. Optimizing only large source bodies misses that cost.

A separate generated-B2 diagnostic derivative times coarse internal boundaries.
It always executes the original function, never caches or changes its result,
and reproduces exact C. Its wrappers interrupt some generated tail loops, so
call counts include recursive entries and recursive inclusive totals can exceed
wall time. The following use nonrecursive inclusive or recursive exclusive costs:

| Work | Numeric | Array | Lexer | Small | Functions65 |
|---|---:|---:|---:|---:|---:|
| Runtime template scan |59.0|53.6|65.6|49.1|42.5|
| Complete final renderer, including that scan |89.3|83.6|142.2|85.8|62.5|
| Conservative freshness bound, 5 calls |27.0|25.2|50.1|34.8|29.4|
| Final book construction, 3 calls |17.1|18.6|17.4|18.7|16.6|
| Native worker planning |132.0|129.4|177.2|7.6|63.2|

All values ms. **Rows overlap; do not add them as savings.** Some bound and book
work occurs inside other measured stages. The five bound calls and three book constructions can see different worlds;
these counts do not prove identical repeated queries. Retaining facts must
eliminate work, preserve invalidation, and cost less than recomputation.

Independent CPU stack unions find text helpers at about56–84ms, index/hash/lookup
machinery at29–103ms, and normalization/substitution (including binder-bound
walks) at48–164ms across B2 sources. Unions overlap and are not causal speedup
estimates. The tiny program still pays for large-book metadata and runtime text.

## Allocation is a different problem in B1 and B2

One sampled-allocation profile per compiler on Numeric, including objects
collected during the interval:

| Role | Estimated allocated bytes | Relevant observation |
|---|---:|---|
| B1 |538.2 MB|Anonymous generated closures224.2MB; index_find47.2MB; run_tail28.2MB.|
| B2 |138.2 MB|Runtime-template SCC33.6MB; text-helper stack union50.2MB.|
| TS |147.6 MB|Different pipeline, including Base checking; no general allocation advantage claim.|

These are allocation estimates, not peak live memory. B2 is not globally
allocating several times more than upstream on this source. B1 is. B2 text
handling alone accounts for about36% of its estimated allocation, yet its
sampled CPU share is much smaller: removing it cannot yield36% latency savings.
Source inspection confirms character-by-character tail slicing/concatenation
in generated `ne_template_scan`, `nt_lines_go` and `index_hash`.

## What upstream does differently

At the exact pin, `bend.ts:2795 term_wnf` uses an explicit frame loop and shared
argument cells; `term_higher` supplies higher-order bodies. Checking retains
typed results. In `comp.ts`, `term_open`, `term_spine`, `term_uses`, `tele_unbind`
and `fun_of` reuse object-keyed facts; `file_book` prepares reachable functions;
`memo_gc` bounds temporary memo lifetimes. `compile_book:2768` iterates emission
until ownership facts stabilize, then prunes emitted reachability. **Upstream is
not a one-pass compiler.** Its runtime is assembled from a static template.

We already retain erased bodies, normalized annotation heads, field quantities,
closure-escape facts, static images and worker plans. New work must build on
these. Remaining costs include generic KTerm/list transport between stages,
name hashing through persistent tries, repeated world metadata, explicit
annotation/erasure boundaries and character-level output processing.

Current anchors: `back/native/request.bend`, `book.bend`, `static.bend`,
`flat.bend`, `emit.bend`, `text.bend`, `driver/report.bend`, `check/annotate.bend`,
`core/term.bend`, `core/index.bend`, `core/normalize.bend`, and
`front/contextual.bend`. Generated-code observations use the unchanged pinned
B2 file, not speculative source-level cost assumptions.

## Ranked opportunities

Estimates concern **whole fresh request time**, with current program optimization
quality retained. They are conditional engineering ranges, not confidence
intervals. Implementation times assume one focused worker, include focused
tests, and exclude roughly2–4h for a final shared broad/bootstrap gate; failures
may extend them. Rank balances probable gain, effort and semantic risk.

| Rank | Change | Estimated B2 time reduction | Prototype / implementation | Complexity and risk |
|---|---|---|---|---|
|1|Bind canonical runtime chunks once; carry exact-world binder bound, final index and report dependency facts across requests' internal stages|8–14% screen; potentially15–30% small cases|45–90min /3–6h|Medium. Preserve report output, custom runtime, shadowing and raw-API checks.|
|2|A per-function native operation representation that **replaces** annotated/erased/reconstructed intermediates and feeds all lowering routes|15–25% screen; held-out gain less certain|1.5–3h /12–24h|High. Quantity erasure, demand, products/observers, foreign/device paths and error order.|
|3|Resolve symbols once to compact request-local handles; keep exact names at diagnostics/ABI boundaries|5–10% screen; potentially8–15% definition-heavy sources|1–2h /6–12h|Medium-high. Chronological versus final worlds, namespace identity, collisions, rebuilding costs.|
|4|Replace weak-head body substitution with closure/environment evaluation and bounded sharing|3–10% current screen; potentially more on dependent workloads|2–4h /12–24h|High. Readback, stuck terms, demand and dependent equality. Not the next best investment.|
|5|Refresh an ahead-of-time native executable of the compiler itself|Speculative20–45%; could instead regress|2–4h feasibility /24–60h integration|Very high uncertainty. Driver/IO/diagnostic/cache parity and compiler workload RC costs. Separate host metric.|

Rank1 should first preserve **exact C and report bytes**. A build-bound canonical
runtime can supply pre-split chunks from Bend-produced data; dynamic/raw runtime
input retains its current parser and validation. Do not move language semantics
into JavaScript, or silently treat arbitrary foreign payloads as trusted template
slots. For world metadata, extend the existing private request context and carry
facts only while their source/world binding remains valid. This removes scans;
it does not skip source checks.

Rank2 is the architectural bet. Introduce a small producer that interprets types
and produces runtime operands, resolved calls, field quantities, dependencies
and use information together. Consume it from existing ordinary/product/observer
lowerings. Retain source syntax separately for checking/diagnostics, but avoid
building a new full annotated syntax graph merely to erase it immediately.
Process functions at a time, release temporary facts, and retire replaced walks.
Start with structured operations; no full SSA/e-graph infrastructure is needed.

The first slice fuses annotation and native erasure for an admitted function
class, preserving the existing final-world semantics and fallback. It does not
repeat Phase80's checker-time type capture. Construction cost must be included.
Only broaden once complete requests improve by at least5–8% without a held-out
regression, and the remaining consumer work supports a further double-digit gain.
Reject a prototype whose only win is another isolated2% occurrence optimization.

Rank3 should begin with the already-owned native closure, using dense definition
handles and shared tables instead of repeatedly hashing qualified names. Keep
exact strings for equality/admission and emitted identifiers. Extending this to
frontend symbols is a separate step; a new handle on a freshly rebuilt tree is
not useful reuse. CPU lookup unions give an approximate ceiling, not proof that
all lookup cost can disappear.

For **B1 specifically**, explicit first-order control flow and fewer generated
continuation allocations could plausibly reduce request time15–30%, with a1–2h
discriminator and8–16h implementation. B2 would benefit much less. Prior160-helper
branch expansion failed its complexity/benefit gate, so do not repeat that
mechanically. Test a compact machine for one measured traversal, maintaining
stack safety, instead of scattering more wrappers across the compiler.

## A numerical parity budget, not a promise

From the qualified1.382× B2 baseline, a total28% time reduction gives0.995×;
35% gives0.898×. A plausible **target allocation** is roughly10 percentage points
from fixed work,14 from representation/consumer fusion and4 from symbol work.
These are disjoint savings to demonstrate in a combined run, not multipliers
to collect from overlapping profile rows. Target a measured25–35% combined
reduction, then retest all five sources and broader programs. Functions65 may
need more. Reaching0.5× would require63.8% less B2 time: nothing in these profiles
justifies promising that from this plan.

## Rejected repetitions and separate alternatives

- Phase79 eager native-library products saved only3–5% and added decode/prep
  cost. A future Go-style lazy product requires materially different transport;
  do not expand the old cache first.
- Phase80 retained whole/live type graphs made annotation cheaper but did not
  improve complete requests enough and regressed held-outs. Keep types local,
  not attached indiscriminately to every transported node.
- Phase80 occurrence summaries saved2.15% on B1 and no held-out benefit. They
  may become a consumer of a shared representation, but are not a parity plan.
- Phase77 substitutions for four generic string functions saved only2–3%.
  Rank1 removes whole scans and repeated book work rather than repeating that
  primitive replacement. Phase78 tag classifiers/identifier shortening failed.
- A persistent session already exists; prior five-source warm evidence was
  around1.10× TS. Dependency-directed incremental compilation could make small
  edits much faster, but cannot be claimed as cold-request parity.
- Native compiler hosting has old Phase4/6 experiments and an incomplete driver.
  It is not a new unexplored shortcut and C does not automatically outrun V8.

## Validation and cost of this investigation

All **77 requests** reproduce their role's complete previously qualified C:
54 clean (45 ordinary,9 no-report),15 CPU profiles,3 heap profiles and5 internal
region diagnostics. Three explicit preparations give80 guarded jobs. No failed
job, OOM, new release, production edit, agent or PR comment. Peak guarded tree
RSS is500,285,440bytes (477.1MiB), below the2GiB cap. Guarded execution totals
**198.38s**, with7.86min between first and last guarded-job timestamps; this
excludes design, source/research review, analysis, documentation and archiving.

Exact C preservation is the appropriate execution-regression check for this
unchanged-compiler survey; no new conformance or runtime-speed result is claimed.
All raw profiles, derivation methods and receipts are retained in the verified
[evidence archive](../../selfhost/tools/performance/phase81/evidence01/README.md):
678 files,343 unique objects,7.27MB compressed. Inherited Phase6/68 work and
historical archives are untouched.
