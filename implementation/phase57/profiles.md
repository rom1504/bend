# Phase57 profile comparison

The [data-only analyzer](../../selfhost/tools/performance/phase57/analysis/profiles-v2.py)
compares completed CPU and allocation diagnostics from the matched-request
latency worker. It imports no compiler, starts no profiler and executes no
generated program. The first completed allocation comparison is below. The method distinguishes
measured frame attribution from proposed explanations; it does not establish
a speedup by itself.

## Lexer allocation observations

All four captures passed the same fresh library-output oracle after the first
request and three warm requests. The [joined data-only report](../../selfhost/build/phase57/allocation-analysis01/report.json)
revalidated all four completed workers, their prepared outputs, sampled
profiles and exact image-to-definition mappings. Its SHA-256 is
`765dda156f3ae6e88619b4111f14fcd221bd2995180bc43859f40b9b1a9a6b05`.

| Compiler image | Profiled requests | Allocation samples | Estimated MB/request | Relative to TS |
|---|---:|---:|---:|---:|
| Pinned TypeScript | 32 | 14,369 | 59.02 | 1.00× |
| Raw checked B1 | 2 | 66,720 | 4,384.68 | 74.29× |
| Derived B1 | 5 | 35,094 | 927.36 | 15.71× |
| Direct B2 | 3 | 49,609 | 2,177.76 | 36.90× |

MB means decimal million sampled allocated bytes, including objects collected
by both minor and major GC. These numbers are cumulative allocation estimates
per completed request, **not retained memory or peak RSS**, and the ratios are
allocation ratios, not execution-time ratios. This is one source and one fresh
sampled process per role; repeated requests inside a process do not supply
independent process-level confidence intervals. TypeScript reached its
32-request cap at 4.38 s, before the nominal 5 s target; the three Bend captures
ran for 5.44–5.82 s and reached that target. This difference is retained in the
report and prevents treating total captured bytes as comparable workloads.

The largest self-attributed allocation frames give concrete follow-up targets:

| Image | Leading self frames | Estimated MB/request in those frames |
|---|---|---|
| TypeScript | `term_higher`, `term_wnf`, `term_infer` | 9.28, 4.02, 3.40 |
| Raw checked B1 | `String.cmp.fin`, `String.cmp`, `String.eq` | 1,281.63, 435.69, 237.81 |
| Derived B1 | `sk_char`, `subst_terms`, `subst_node` | 206.28, 33.85, 24.46 |
| Direct B2 | `sk_char`, `subst_terms`, `kid`, `run_clo`, `subst_node` | 218.91, 98.90, 87.20, 80.11, 79.99 |

Direct B2 allocates an estimated 2.35× as many bytes per lexer request as
derived B1. This does not concentrate solely in `run_clo`: that runtime frame
accounts for 3.68% of B2's sampled self allocation. The named `terms_at` frame
and one separately mapped anonymous closure inside it contribute 44.56 and
53.62 MB/request; the named derived-B1 `terms_at` frame contributes 0.18 MB.
Those are exact frame/span observations, not complete dynamic totals for every
closure belonging to that source definition. Allocation beneath a caller also
appears in its inclusive weight and must not be added again.

`sk_char` is a shared allocation target (206–219 MB/request for derived B1 and
B2), while term substitution, term access and runtime closure handling are
useful discriminators for the B2/derived-B1 gap. The inference is that source
representation and emitted call/closure structure both merit investigation.
A profile does not prove which transformation would remove those allocations,
whether V8 inlining changed their attribution, or how much runtime a fix would
save. Pair a bounded generated-code change with fresh equivalent request
oracles and unprofiled latency before accepting that conclusion.

The analyzer keeps all sampled mass. Unattributed allocations were 0 bytes
for TypeScript and respectively 347,472, 487,208 and 692,696 bytes across the
raw/derived/direct captures (all under 0.011% of their totals). Tree
`selfSize` totals disagree slightly with sampled totals; the signed
differences and every node discrepancy remain in the report. No discrepancy
is added to the denominator or assigned a guessed stack. Fair self-group
compiler shares are 88.38% for the combined TypeScript `bend.ts`/`comp.ts`
group, and 96.09%, 94.94%, 93.18% for mapped Bend definitions. The remaining
runtime, driver, Node, harness, unknown and unattributed shares remain visible.

The failed CPU v1 summary is preserved separately. Its timestamp correction
and the new weighted/count views are documented in [profiling.md](profiling.md);
these allocation results do not depend on any CPU timestamp normalization.

## Lexer CPU observations

The fresh v3 capture completed all four roles and the [CPU analysis](../../selfhost/build/phase57/cpu-analysis02/report.json)
passed all image, request, output, raw-profile and summary joins. Its SHA-256 is
`5b759a62dfb43f61445ea16fddc2ceee7bba8a6ff9adfe964eb14b38fe817aa0`.
All four weighted views were admitted with **zero negative-delta correction**.
The failed earlier CPU receipt remains failed; this is a separate new capture.

| Compiler image | Profiled requests | CPU samples | Leading weighted self-attributed frames |
|---|---:|---:|---|
| TypeScript | 32 | 2,544 | GC 21.39%; `match_flatten` 7.16%; `term_higher` 6.31%; `term_check` 4.14% |
| Raw checked B1 | 3 | 5,645 | `String.cmp` 14.10%; `String.cmp.fin` 13.20%; `run_loop` 11.34%; GC 4.45% |
| Derived B1 | 6 | 4,383 | `run_loop` 20.19%; GC 6.06%; `validateSpanCache` 4.94%; `sk_char` 4.17% |
| Direct B2 | 4 | 5,409 | `run_loop` 15.15%; `kt` 9.28%; GC 4.29%; `jd_primitive_table` 2.93% |

These percentages weight sampled stacks by their recorded time increments.
The independent count view can differ materially: TypeScript's GC share is
21.39% by time increments and 5.78% by sample count; derived B1's corresponding
shares are 6.06% and 2.90%. Both views remain in the report. Unequal sample
intervals are visible, and neither view is an instrumented measurement of every
function or a basis for comparing clean compiler latency. TypeScript again
hit the 32-request cap before five seconds; whole Bend requests overshot the
nominal target. Three warm requests define the protocol; they do not prove
that V8 has finished optimizing every function. No samples or elapsed residuals were reassigned to a frame.

CPU and allocation evidence identify different costs. In direct B2,
`run_loop` receives 15.15% of weighted self CPU attribution but no sampled self
allocation. `run_clo` receives 3.68% of allocation attribution (80.11 MB/request)
but only 0.33% of weighted self CPU attribution. The named `kt` frame receives
9.28% of weighted self CPU attribution versus 0.33% of allocations. Conversely,
`subst_terms` receives 4.54% of allocations versus 1.02% of weighted self CPU.
These are separately captured, role-matched observations, not aligned samples
or causal decomposition. Optimizing one category need not improve the other
in proportion.

The strongest next discriminators are therefore broad dispatch/tag access
(`run_loop`, `kt`), repeated primitive lookup (`jd_primitive_table`), and the
allocation-heavy source representation paths identified above. A change should
be judged by exact outputs and fresh unprofiled requests; the observed shares
are neither promised gains nor additive upper bounds. Derived B1 also places
12.25% of its weighted self total in the ordinary host-driver group, including
Base-cache reading/validation; B2 places 6.96% there. Those percentages have
different total denominators and do not establish that either driver's absolute
cost changed.

For stack context, `check_program_diagnostic` has 41.08% inclusive weighted
attribution in B2 and 35.01% in derived B1. This call also includes completion
and specialization. Its descendants' weights overlap with it, so this does not
supply an independent pure-checking stage duration. Timestamped stage captures
and own-source checks are separate evidence with separate request boundaries.

## Complete own-source checking

The separate [own-source analysis](../../selfhost/build/phase57/check-profile-analysis01/report.json)
passed all three image/source/profile joins (SHA-256
`5599d37e36cdb25a585ed174de2cae987c35c34be2504563885a8ad34b9b4759`).
Each image performed **one ordinary complete check of the same compiler
source**, using its prepared private Base cache, with no preceding warm
compiler request. Import and setup were outside the inspector. All three
returned `checked: true` and `typeAccepted: true`, with the exactly expected
unsafe-trust verdict for the 3,012 source definitions. This is successful
completed type checking with preserved proof-trust failure; it is not a
mathematical-proof claim or a fresh Base check.

| Image | Profiled request seconds | Samples | Leading weighted self frames |
|---|---:|---:|---|
| Derived B1 | 16.265 | 12,018 | `run_loop` 14.72%; GC 11.68%; `validateSpanBook` 4.31%; `index_remove` 3.74%; `f_find` 2.79% |
| Direct B2 | 32.961 | 25,366 | `run_loop` 11.74%; GC 10.21%; `kt` 9.32%; `f_find` 2.96%; `validateSpanBook` 2.41% |
| Raw checked B1 | 54.373 | 44,701 | `String.cmp` 12.46%; `String.cmp.fin` 11.52%; `run_loop` 8.41%; GC 8.01%; `index_remove` 6.47% |

These are one-shot diagnostic request durations under the inspector, **not
fresh clean latency ratios**. They exclude the rest of their worker setup and
post-capture summarization, and are not interchangeable with the worker's total
wall time. Weighted and sample-count rankings are both retained. The raw B1
capture contained 2 µs of negative increments, admitted at 0.0367 ppm under the
bounded policy; the other two needed no correction. The original raw data and
all signed accounting remain unchanged.

The B2 `kt` self share is similar across two different requests: 9.28% for
lexer library compilation and 9.32% for complete compiler-source checking.
That supports testing tag-access cost as a general mechanism rather than a
lexer-specific pattern. It does not establish a removable 9% runtime fraction.
String comparison remains prominent in raw B1, while source lookup/index
operations become prominent in all three large-source checks.

`discoverSources` has 51.85%/51.86%/46.72% inclusive weighted attribution in
derived B1/direct B2/raw B1 respectively; `f_complete_aliases` has
42.70%/44.96%/41.84%. These are nested stack shares, not independent stages that
can be added. The discovery path includes completion work as well as host I/O;
this observation does not justify calling half the request pure parsing or
pure kernel checking. Per-stage emission profiles cover another distinct
operation and will be reported separately.

The small [own-source reader](../../selfhost/tools/performance/phase57/analysis/check-profiles.py)
reuses the frozen CPU-view validator, but verifies the source/trust oracle
instead of borrowing the library output oracle. Its source-name mapping is
intentionally narrower: only exact named identifiers within the matching
whole-image inventory are mapped. Anonymous closures stay unmapped, so its
named-definition group share must not be compared directly with the library
reader's containing-function-span group.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase57/analysis/profiles-v2.py \
  --report selfhost/build/phase57/CPU_RUN/report.json \
  --report selfhost/build/phase57/ALLOCATION_RUN/report.json \
  --inventory selfhost/tools/performance/phase57/static/code-shapes.json \
  --out selfhost/build/phase57/NEW_PROFILE_COMPARISON
```

Each supplied campaign must be an explicit `cpu` or `allocation` run. The
analyzer checks its role/case/round matrix, each guarded worker completion,
the selected preparation and output oracle, three warm requests, and the
separate profiler receipt. Profile producer/summary-method/Node identities
must match the worker's configuration. It rehashes the actual raw profile,
summary, input source and output files. Historical Node identities are joined
to the recorded configuration, not treated as a new execution of that binary.
Failed or missing rows remain visible and make the analysis receipt fail;
they are not silently dropped.

## Comparable frame attribution

The existing profiler's single-URL `generated` category is not used to compare
compiler shares. The analyzer groups both TypeScript `bend.ts` and `comp.ts`
as TypeScript compiler work. For the three Bend images it distinguishes
mapped compiler definitions from embedded runtime or unmapped image frames.
Ordinary driver/helper frames remain a separate host-driver group. Harness,
Node, garbage collector, idle/program/root, unattributed and other frames all
remain in the sampled denominator. The self groups form a complete partition;
no frame is discarded merely because it is outside the primary module URL.

The [static inventory](../../selfhost/tools/performance/phase57/static/code-shapes.json)
maps raw checked B1, derived B1 and direct B2 functions to source names. The
analyzer requires each profiled private API copy to match the inventory's
whole-image hash. It reconstructs each named function's exact byte span from
the saved start line, encoded identifier, byte length and body hash, checking
every span before using it. V8's zero-based line and UTF-16 column are converted
to a byte offset, then joined to the containing top-level function.

Nested closures keep their actual frame name and location. A containing Bend
definition describes where that closure was emitted; it does not assert the
closure is the entire function or reveal why it became hot. Unavailable,
out-of-range and non-generated positions stay unmapped. TypeScript frames keep
their actual function names and file positions; Bend name decoding is not
applied to TypeScript source functions.

## Quantities and limits

CPU v1 totals require a nonnegative raw `timeDeltas` sum. For v2, the analyzer
recomputes the explicit 2 µs-per-negative and 10 ppm aggregate policy from raw
signed deltas, then checks the recorded admission/refusal, all correction
indices and every total/residual. It separately validates the count summary's
sample units and full denominator. Both views get the same fair source/frame
grouping. A refused weighted view remains visibly refused; count-only totals
cannot become time estimates. The output shows self and inclusive top frames, preserving the original full-frame
summaries and raw profile hashes. Inclusive weights overlap and are never summed
into a total or a stage duration. The signed difference between profile wall
duration and sampled deltas remains separate.

Allocation totals are independently checked against raw `samples[].size`.
Both minor- and major-GC-collected objects must have been included. The output
records estimated sampled bytes per **completed profiled request**, together
with request count, target/cap flags, the tree-versus-sample discrepancy and
unattributed allocation mass. These are not retained heap, exact allocations
or counts of allocation events. The same request/output oracle is required,
but one role may complete more repetitions inside the nominal five seconds.

`report.json` keeps compact top-self/top-inclusive tables and every input hash;
`report.md` gives the corresponding per-role/case overview. Raw files and full
frame summaries remain linked by exact path/hash. Profiled request durations
and CPU sample weights must not be substituted for clean latency medians or
turned into optimization speedup claims.

Stage windows and V8 optimization/deoptimization/GC event logs belong to the
separate trace analysis. This analyzer assigns no stage durations from function
names alone. The general [profiling notes](profiling.md) describe the actual
composite driver calls and instrumentation boundaries.
