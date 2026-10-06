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
