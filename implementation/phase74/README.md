# Phase74: a structural path to C compilation parity

Investigation only, 2026-10-12. Installed Phase73 is unchanged. No agents,
production edits, installation changes or PR comments. [Prospective design](../../design/phase74/compilation-parity-investigation.md),
[experiment](../../experiments/phase74/P74-001-work-amplification.md),
[measurements](measurements.json), [methods](../../selfhost/tools/performance/phase74/).
All297 raw files are archived with a verified
[manifest](../../selfhost/tools/performance/phase74/evidence/manifest.json).

## Conclusion

The next experiment should change how the native backend schedules its work:
prepare one native representation, select host/device routes, and lower only the
required implementations. Couple this with reusable standard-library facts.
More local caches cannot plausibly deliver the requested threefold improvement.
Parity remains an engineering target, not a demonstrated or guaranteed result.

The relevant metric is **checked Bend-to-C request latency**, excluding compiler
imports, explicit Bend Base preparation, Clang and generated-program execution.
Upstream checks Base inside its request. These are JS-hosted B1/B2 compiler
images emitting C, not the execution time of a compiler executable built with C.
Prior balanced medians remain the reference: B1 **3.59582x**, B2 **2.29667x**
upstream. B2 needs **56.46% less request time** to reach parity; B1 needs72.19%.

## What was measured

Fresh diagnostic work used one CPU3 process tree at a time, a2GiB RSS limit,
4GiB available-memory floor, Node1GiB heap/4MiB stack. The selected images are
Phase73 B1`c2705793…`, B2`25d4ca2e…`, upstream0592662. Independent Base caches
were prepared before clocks. Three sources are Numeric, Array and Lexer from
the existing C request screen, with the same checked/report-producing API.

There are54 ordinary first/repeated requests and3 counter-only requests.
Every complete generated C result matches the previously qualified full-byte
oracle. This establishes diagnostic output preservation for these sources; it
does not expand conformance or establish a new runtime result. The ordinary
worker's original version is retained as `request-warm-v1.mjs`; the subsequent
`request.mjs` adds only the diagnostic counter-start hook. All54 requests used
the original method hash78d93304…. No timing interval spans a method change.

The first counter derivation was prepared but never measured: review found its
list reader used `h` rather than the generated ABI's `head`. `counters-v2.py`
and a fresh independent project correct it. Both attempts are preserved.
Counters rename selected internal function declarations and insert observational
wrappers. They never memoize results. Recursive inclusive times overlap; these
clocks must not be presented as removable CPU time or clean speedups. Tail-loop
iterations and SCC internal dispatch do not necessarily re-enter the wrappers.

## Work amplification, not just slow individual operations

| Observation | Numeric | Array | Lexer |
| --- | ---: | ---: | ---: |
| Our generated C bytes |1,153,845|1,185,447|1,461,280|
| Upstream generated C bytes |117,622|118,820|144,943|
| Our generic segments before/final emission |416/416|428/428|583/583|
| Ordinary worker attempts / distinct function names |54/36|57/39|82/58|
| All candidates before observer routing / admitted names |41/16|48/23|66/31|
| Native reachability entry calls |6|6|6|
| Definition-query calls / distinct exact argument tuples |512/192|520/195|688/258|
| Occurrence-set queries / distinct exact argument tuples |14,939/14,562|15,166/14,750|18,883/18,274|

`ns_compile` first prepares the book and calls `nc_compile_defs`; only later
does `nf_finish_show` produce ordinary/product candidates, `nf_finish_retry`
retry candidates, and `nf_finish_ready` build observer routes and wrap segments.
`nf_wrap_segments` and `no_wrap_routes` preserve the segment list. `ne_program`
renders it all. Generic body strings alone total489/498/612KB before wrapping.

The pinned upstream `compile_book` also re-emits while ownership facts converge;
it is **not** a universal one-pass implementation. However, its function facts
are prepared in `file_book`, and it filters both segments and spins against the
actual emitted reference graph before output. Its `term_uses` retains per-node
summaries. These are specific mechanisms to transfer, not a proposal to copy
TypeScript algorithms into the host driver.

Our larger C is partly functional: `nq_wrap_segment` retains generic device
bodies beneath `#else`, and observers sometimes require both unique and shared
paths. Removing those unconditionally would lose functionality. A new plan
must distinguish host demand, device demand, escaping closures, partial calls,
foreign calls and required fallback implementations. It must preserve error
demand and stack safety. Shortening FID/NF/CID names alone leaves1.04/1.06/1.25MB,
so long identifiers do not explain the size gap.

A conservative *lexical screen*, rooting private-worker FID references and
fixed runtime cases and retaining both preprocessor branches, leaves201/205/272
case labels unreached versus one per upstream output. This is evidence to
investigate final reachability, **not a semantic deletion proof**: indirect
dispatch/device roots need explicit compiler metadata. Dead-output pruning by
itself also cannot recover lowering work already performed.

The occurrence counters reject the easy identity-cache story:97% of `nc_uses`
entry argument identities are distinct. `nq_uses` also has very few duplicate
full tuples. The promising change is stable prepared bodies with bottom-up
use/ownership summaries, shared by all lowering routes, rather than adding a
map around the existing repeated reconstruction. The earlier failed Phase70
duplicate-insertion shortcut is a different experiment and remains rejected.

Fifty library definition names occur in all three native closures, out of
64/65/86 compiled definitions. This is an opportunity for relocatable prepared
library products. Name overlap alone proves neither identical specialized
bodies nor the fraction of CPU saved. The shared benchmark harness also makes
these three sources insufficient for a broad scalability claim.

## Both sides of the latency budget matter

Existing B2 instrumented profiles spend1.16–1.28s inside native emission and
0.68–0.96s around it. Existing upstream clean median emission is428/416/590ms;
load/check is297/296/309ms. Instrumented B2 and clean upstream clocks cannot
form an exact attributable ratio, but show that neither backend work alone nor
frontend work alone explains the complete gap.

Outside emission, the Bend driver performs source completion, report/name
construction, annotation, layout validation and foreign-path discovery. Several
walks rediscover erasure/reachability before the final prepared native book
exists. Native requests do not consume the prepared Base backend products used
by the direct JS path. A typed native request context should carry the facts
across these boundaries. Keep the same checks and reports; silently dropping
them would change the benchmark contract.

An illustrative **target budget**, not a measured forecast, is to move a
roughly2.0s profiled request from1.2s native +0.8s surrounding work to
0.45s +0.30s. The resulting0.75s is in the existing upstream request range.
This requires roughly2.7x faster major components. A20% helper optimization is
structurally too small. New clean, paired timings must replace this sketch
before any performance claim.

## Ranked opportunities and falsifiers

Estimates below concern whole B2 fresh requests on the small current screen.
They are conditional engineering estimates, not measured gains, and **overlap**.
Times include focused implementation/debugging; broad qualification can add
hours, especially if device or demand behavior exposes a problem.

| Rank | Change | Plausible request speedup | Prototype / implementation estimate | First falsifier |
| --- | --- | --- | --- | --- |
|1|Plan ordinary/product/observer/device routes before body lowering; propagate changes over the call graph; emit only required variants|1.3–1.6x|1–2h /8–16h|Fail the large-rewrite case if it cannot remove about half of native emission work or25% of complete request time while preserving required routes.|
|2|Reusable checked Base/module products: erased bodies, type/layout summaries and symbolic native plans, with ID relocation late|1.2–1.5x on import-heavy small sources; less on large new user code|1–2h /6–12h|Measure reusable work by exact body/context, not names; reject if materialization/invalidation costs consume the saving.|
|3|Compact native nodes with stable IDs and one bottom-up occurrence/ownership analysis, consumed by all routes|1.15–1.35x|1–2h /8–16h|Count nodes visited/allocated and analysis time; reject a cache that simply indexes freshly rebuilt trees.|
|4|One checked request context shared across report, annotation, foreign paths and native emission|1.1–1.25x|30–60min /3–6h|Exact C and diagnostics must match; measure eliminated walks, with no report/check omission.|

Ranks1/3 should become one small native representation change, not two new
frameworks. Rank2 reuses it across immutable library boundaries. Rank4 supplies
it earlier in the request. Together their target is roughly2–2.7x faster B2
requests, enough to aim at0.85–1.15x upstream. This is a **target range to test**,
not a multiplication of the table or a promise of parity.

Use the existing research: [Go's export summaries and ordered lowering](../../research/compilers_architecture_and_techniques/go.md),
[Zig's indexed typed representation and separate liveness](../../research/compilers_architecture_and_techniques/zig.md),
and [our context-keyed query audit](../../research/compilers_architecture_and_techniques/phase62-query-reuse.md).
The transfer is staged analysis and reusable facts. It does not require a new
typechecker, switching implementation language, adding general SSA immediately,
or weakening the generated-program optimizations that now approach parity.

## Two practical speed options with separate metrics

Shipping the genuine B2 image instead of current B1 would lower these requests
by about36% using the existing balanced measurements (1.57x speedup). B2 is
self-reproducing, but the current release tooling only admits B1 artifact kinds;
changing the default needs explicit B2 lineage/release qualification. This is
an actionable packaging option, not a newly faster B2 algorithm. Estimated
2–4h if no CLI/ABI issue appears.

Warm ordinary B2 requests substantially improve absolute latency. Medians of
the five repeats are697/692/853ms; upstream is442/429/547ms. The geometric ratio
is1.58x, versus2.40x on the first request in this single-process screen. Using
only the last three samples gives1.73x because upstream continues warming.
There is only one process per role/source, so neither number is a stable
steady-state result. B1 stays roughly3.9–4.2x upstream warm. A persistent B2
service could improve the edit loop, but cannot be claimed as fresh-process
parity. The existing persistent inspector supports parse/check only; native
support, memory bounds, cache invalidation and error isolation need qualification.

## Recommended next decision

Spend the first bounded prototype on the native plan, without a wholesale
rewrite. Record a route table and actual host/device edges for each definition;
prove which lowerings are avoidable; try one demand-driven lowering path. Use
Numeric/Array/Lexer plus at least one small source without the shared IO harness
and one larger source dominated by user definitions. If the component gain is
real, integrate stable use facts and reusable Base products. Do not spend hours
on full bootstrap/conformance before this gain has survived the small screen.

For unchanged output, require exact full C and diagnostics. Where dead-code
pruning/renumbering changes C, require native semantics, raw/API and deep-stack
controls, threaded/device coverage where available, generated-program timing,
then B1/B2 self-hosting qualification. Compare identical warm/cold and cache
contracts on each side. Keep raw/device fallbacks and retire superseded passes
so the implementation becomes simpler as work is removed.

No compiler candidate was implemented or promoted in this investigation.
