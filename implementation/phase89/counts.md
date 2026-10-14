# Per-request native compiler work counters

This records disposable operation-count diagnostics of Phase88 native02 and the
checked Phase89 owned-result/body-chunk candidate. Counter instrumentation changes
no compiler algorithm, upstream source, runtime guard or historical artifact.
Root owns compilation and target execution; this lane prepares tools and analyzes
their evidence offline.

## Owned results and body chunks: completed v2 comparison

The [new three-source run](../../selfhost/build/phase89/counts-chunks-run02/report.json)
passes **15/15 complete C comparisons**, including every repeated request. All
three counter analyses have14 phase marks, zero foreign-thread events and zero
overflow. Input hashes remain unchanged. This compares native02 with the combined
owned-result plus body-chunk candidate, not an ablation isolating either change.

The baseline diagnostic uses Clang `-O2`; the new one uses `-O1`. Both define
`__OPTIMIZE__` and retain the runtime's `preserve_none`/`preserve_most` calling
conventions. Their31 shared counters have the same definitions and source hooks;
v2 omits `match_joins`, whose generated continuation identity changes. The unique
append-return continuation is discovered and checked instead of hardcoding its
numeric suffix. These are observed operation counts from differently optimized,
instrumented binaries. **Do not infer compiler speed from their diagnostic clocks
or treat the optimization levels as an otherwise controlled timing comparison.**
Use the [clean three-way comparison](../../selfhost/build/phase89/chunks-cold01/report.json)
for speed evidence.

The following exact counts use request2; each repeats unchanged in requests3–5.
Percentages describe counted work, not elapsed-time savings.

| Source | Append characters, old → new | Allocation calls, old → new | Requested allocation words, old → new |
| --- | ---: | ---: | ---: |
| [Map](../../selfhost/build/phase89/counts-chunks-run02/map_closed-counts.json) | 26,639,166 →16,041,108 (−39.78%) | 72,050,847 →50,882,736 (−29.38%) | 139,968,521 →108,139,891 (−22.74%) |
| [Lexer](../../selfhost/build/phase89/counts-chunks-run02/lexer_original-counts.json) | 7,416,105 →6,976,089 (−5.93%) | 18,706,857 →17,828,069 (−4.70%) | 36,256,558 →34,922,435 (−3.68%) |
| [Numeric](../../selfhost/build/phase89/counts-chunks-run02/numeric_closed-counts.json) | 372,386 →339,094 (−8.94%) | 1,743,733 →1,677,312 (−3.81%) | 4,694,356 →4,593,058 (−2.16%) |

At8bytes per word, the new cumulative requested capacities are865,119,128bytes
for Map,279,379,480 for Lexer and36,744,464 for Numeric. These include allocator
reuse and are not live-memory measurements. Final C sizes remain895,710,
418,969 and116,011bytes respectively. Map still performs substantial copying,
but the candidate removes10,598,058 append-character traversals per request.

| Source | Drop child fields, old → new | Refcount wrappers, old → new | Shared constructor/fade calls, old → new | `nt_choose` calls, unchanged |
| --- | ---: | ---: | ---: | ---: |
| Map | 44,200,086 →24,393,848 (−44.81%) | 29,389,249 →18,849,908 (−35.86%) | 30,454,455 →20,775,028 (−31.78%) | 6,068,096 |
| Lexer | 6,051,989 →5,201,854 (−14.05%) | 8,133,428 →7,705,074 (−5.27%) | 6,717,758 →6,206,912 (−7.60%) | 846,000 |
| Numeric | 1,456,998 →1,393,694 (−4.34%) | 510,457 →478,411 (−6.28%) | 1,874,127 →1,841,665 (−1.73%) | 172,175 |

Thus the measured reduction includes destruction and sharing work alongside
copying. The unchanged choice count is a useful semantic-work control. The
effect is much larger on Map than on Lexer/Numeric; these three sources do not
establish a uniform reduction across all compiler inputs.

### Repeat behavior and allocator limits

**All31 new counters are exactly identical across requests2–5 for all three
sources**, as the original32 counters were in the baseline. Request1 differs
by two additional one-word wrapper allocations and two fewer retain units, plus
initial allocator population. No later request acquires fresh corpus capacity.
This again rules out growth in these counted operations over requests2–5; it
does not identify the cause of any remaining clean-run timing trend.

| Source | Hot-list misses, old → new, requests2–5 | Generation handoffs, old → new | New fresh corpus events, request1 →2–5 |
| --- | ---: | ---: | ---: |
| Map | 4,358 →1,972 (−54.75%) | 4,276 →1,889 (−55.82%) | 248 →0 |
| Lexer | 1,006 →1,232 (+22.47%) | 968 →1,194 (+23.35%) | 14 →0 |
| Numeric | 26 →32 (+23.08%) | 15 →21 (+40.00%) | 6 →0 |

Lexer and Numeric make more allocator slow-path visits despite requesting fewer
allocations overall. Count reductions therefore do not establish uniformly better
locality or allocator efficiency. Addresses, cache misses and cycles per operation
remain unmeasured. The earlier proposed allocator-capacity experiment below is
still unimplemented; these results do not justify a runtime allocator change.

Final process allocation/free calls and words balance exactly in every new run:
Map257,876,151calls/546,870,269words; Lexer92,613,466/180,798,964;
Numeric11,846,775/29,132,720. Each number is equal on the allocation and free
sides. The original caveats remain: final aggregate balance is not a leak proof,
peak-live measurement or per-object lifetime audit.

### New source, build and failure bindings

The [checked acquisition](../../selfhost/build/phase89/chunks02/report.json)
uses upstream`059266225b77c8ca256ac6b25ee5c21449bab151`. Its Bend source is
`670204c4898753c29b648ca77cc19c2b3ad33764bfdf2f55598e8957a2310751` and clean C is
`08fb3bda86dbcaae55c5cd2e2252359805bd27e11c160694728af301226ed1b0`.
The [counter derivation](../../selfhost/build/phase89/counts-chunks-source02/derivation.json)
binds14 reversible edit groups,31 fields and `STRING_APPEND_K21819`. Reversing
the edits recovers every original C byte; the first/last1,024bytes are unchanged.
Its instrumented C is
`494523b8341f57ccd02ca185d7e4b57246d89d84abd4b78cc38080765ec6cff8`.

The [guarded O1 build](../../selfhost/build/phase89/counts-chunks-build02-guard/process.json)
passes in189.48s, peaking at4,285,968,384bytes (4.286GB/3.992GiB) under the explicit
6GiB guard. Its binary is
`eb29b5894d7d9ac9700e5d3f8610653b566cfde599379e292287a7837683082c`
(12,546,184bytes). The successful run report SHA256 is
`7c1717f7e7165f19b0eda5db65c218ecd8afd71ed97cf4eb8d1afebd766ce865`;
it binds acquisition, derivation, build inputs/command, binary, source fixtures,
authenticated Base/runtime/effects/cache, each output and all three analyses.
The [v2 runner](../../selfhost/tools/performance/phase89/counts-v2/README.md)
checks the clean parent's live Small/Map/Unicode gates before diagnostic-only
carrier reuse. Original B2 C files were archived, so retained full-C copies are
verified against their historical B2 hashes and lengths; both identities are
recorded. This does not promote a new public cache consumer or native release.

The new diagnostic build and all three request jobs succeeded; no failed target
was excluded. The earlier [chunk-v1 checked failure](../../selfhost/build/phase89/chunks-control01/report.json)
remains preserved: it matched `todo` after a later binder. The
[v2 correction](../../selfhost/tools/performance/phase89/chunks-v2/v2-correction.json)
changes worker argument order and all call sites before checked acquisition.
An offline runner preflight also detected missing archived oracle paths; the
verified-copy handling above resolved it without regenerating targets. This
report update ran no compiler or benchmark.

## Original native02 counter results (retained baseline)


Root's [three-source run](../../selfhost/build/phase89/counts-run01/report.json)
passes all15 complete C comparisons (five each for Map, Lexer and Numeric).
The diagnostic executable is SHA256
`eb14e879cf9ccff700febc181595a55010a2612b27dd0c099628286d4f51def3`, built from the
recorded C derivative below. All three analyses have14 exact phase marks, zero
foreign-thread events and zero overflow; their counter consistency checks pass.

**All32 measured work counters are exactly identical in requests2–5 for each
source, while Map time still increases18.9% from request2 to request5.** This
falsifies increasing counted copy/allocation/ownership work as the cause of that
progressive slowdown in this diagnostic. It does not establish a particular
cache/locality cause. Counter clocks remain instrumented, not release timings.

| Source | Instrumented request ms, calls1–5 | Append characters per request | Allocation calls, requests2–5 | Requested allocation bytes per request |
| --- | --- | ---: | ---: | ---: |
| [Map](../../selfhost/build/phase89/counts-run01/map_closed-counts.json) | 2,662 /2,801 /2,976 /3,130 /3,330 | 26,639,166 | 72,050,847 | 1,119,748,168 |
| [Lexer](../../selfhost/build/phase89/counts-run01/lexer_original-counts.json) | 601 /604 /612 /628 /640 | 7,416,105 | 18,706,857 | 290,052,464 |
| [Numeric](../../selfhost/build/phase89/counts-run01/numeric_closed-counts.json) | 127 /126 /130 /135 /126 | 372,386 | 1,743,733 | 37,554,848 |

Requested bytes are `alloc_words ×8`: cumulative size-class capacity handed out,
including repeated reuse, not live heap or RSS. Map creates an895,710-byte final
C output but traverses/reconstructs26.64million String.append characters and
requests1.120GB of aggregate allocations. Lexer produces418,969bytes of C and
Numeric116,011bytes. This supports reducing avoidable body copying even if the
separate progressive slowdown ultimately has a different cause.

Map's stable per-request work also includes48,458,618 `term_drop` calls,
69,936,260 outer drop work items,44,200,086 child fields examined,
30,454,455 shared constructor-consumption/fade operations and97,646,245 fade
fields. There are6,068,096 `nt_choose` calls and951 ordinary match-result joins.
None grows across these five requests. The first request allocates just two
more one-word wrappers; subsequent requests perform two additional retain units
instead. That16-byte transition is separate from the large timing trend.

### Allocator behavior changes once, then its counts plateau

| Map allocator counter | Request1 | Each request2–5 |
| --- | ---: | ---: |
| Hot-list misses | 2,889 | 4,358 |
| Miss resolved from parked cold list | 1,992 | 3,727 |
| Miss resolved from bank | 590 | 631 |
| Fresh corpus allocations | 307 | 0 |
| Hot-generation handoffs | 2,537 | 4,276 |

The first-to-second transition is real. It cannot by itself explain further
second-to-fifth growth because every listed count is then identical. Lexer
similarly changes748→1,006 misses and697→968 handoffs, then stays fixed. Numeric
changes32→26 misses while handoffs stay15. No request after the first asks for
fresh corpus capacity in any of these three runs.

The actual runtime explains what these counts represent. In native02 C,
`heap_alloc` uses an O(1) per-class HOT LIFO chain; a miss takes COLD, then a bank
entry, then a fresh quantum. `heap_free` parks HOT at `KEEP_WORDS`, banking the
previous COLD generation. The bank is an indexed stack, not a linearly scanned
free list. CPU setup sets `KEEP_WORDS=CAP_WORDS=32768` words (256KiB) per size
class; initial `QUANTUM` is capped at4096words. Identical operation and branch
counts can still visit different addresses or encounter different CPU/cache
conditions. These counters capture neither address order nor cache misses.

### Allocation balance is narrower than a leak proof

All three final process snapshots have exact equality of allocation/free calls
and requested words. In Map that is363,716,608 calls and706,013,272 words on each
side. At request boundaries, outstanding requested capacity also stabilizes:
Map requests2–5 each begin with6,404,944 net bytes and end with27,855,496; Lexer
begins6,532,504 and ends16,541,272; Numeric begins6,377,632 and ends9,115,408.
After result writing/consumption, the next boundary returns to its stable start.
This does not support accumulating previous output graphs at those boundaries.

It does not prove absence of every leak or retention problem. These are aggregate
size-class accounting, not individual-allocation lifetime tracing, OS allocation
accounting, or measurements of the peak live graph within a request. Memory
freed to a runtime pool need not leave RSS. Final process cleanup could free
objects retained too long earlier. Measured peak process-tree RSS is77.3MiB Map,
60.8MiB Lexer and57.0MiB Numeric. Do not describe the1.120GB churn as live memory
or infer a runtime correctness theorem from balanced totals.

### Cheapest next discriminators

First finish the already-authorized consume-once `NC_Code` candidate. The known
26.64million copied characters and concrete child-body destruction sites are
actionable regardless of the repeat-growth explanation. Compare exact complete
C and first/fifth clocks against the same native02 baseline, keeping Map and
Lexer plus Numeric. This reuses the active candidate build and existing guards;
there is no reason to delay it for a new profiler installation.

For the allocator hypothesis, the smallest causal follow-up would be **one
explicit C-only diagnostic derivative exposing CPU generation capacity before
`corpus_setup`**, with the current32768-word setting as an exact control and
4096/131072-word settings as bounded probes. One build can serve all settings;
keep guards/refcount semantics unchanged and test full C identity. A few serial
Map COUNT5 processes would test sensitivity to allocation reuse policy in under
a minute of target time after the several-minute build. Smaller capacity changes
handoff/bank frequency as well as address reuse, so even a win would establish
allocator-policy sensitivity, not prove cache locality. Validate count changes
and RSS alongside the repeated timing slope; no production promotion from one
setting/source. Do not change capacity during a request or after free-list
generations have formed, since `KEEP(cls)` assumes their construction size.

If hardware cache/cycle counters become available, measure them on the existing
unmodified binary before paying for that build. The earlier system perf wrapper
is unusable here; spending another cycle installing tools is not justified by
the current evidence. The generation-capacity experiment is only a proposal:
no new instrumentation, runtime mutation or target run was made for this analysis.

## Question and decision

In the Phase88 five-request Map profile, elapsed request time grows from2,083ms
to2,803ms. The append family rises from128 to238 samples, accounting for roughly
61% of the181 added samples. Sampling cannot tell whether the compiler does
more allocation/copy/destruction work, or does the same work less efficiently.
This diagnostic counts those operations between the existing exact IO.now
boundaries. It requires one Clang build of an instrumented copy, with no Bend
compiler acquisition or profiling-tool installation.

One cached Map process with COUNT5 is the decisive first run. Compare every
produced C file against the existing native02/B2 oracle; this is mandatory
because instrumentation is not permission to relax correctness. If work counts
stay constant while time grows, prioritize allocator address reuse/cache locality
and instruction/cache-miss counters. If work counts increase, locate the changing
copy/share/drop paths before trying allocator tuning. A second branch-light source
can distinguish a general session effect from one exposed primarily by large
generated bodies. Do not start another broad compiler suite for this diagnostic.

## Counters and their meaning

The32 unsigned counters have these groups:

| Group | Counts | What it distinguishes |
| --- | --- | --- |
| Generated String.append | Left-input characters, completed appends, reconstructed characters | Exact append work; empty appends separately from characters copied |
| Heap | Allocation/free calls and logical words, misses, cold/bank/fresh miss sources, fresh quantum words, generation handoffs | Changed allocation volume versus changed free-list generations and corpus growth |
| Destruction | Calls, outer work items, child fields examined, nontrivial nodes destroyed | The cost of a drop call depends on the graph traversed; calls alone are insufficient |
| Refcounts | Releases, retained/shared outcomes, last-owner outcomes, new wrappers, retain calls/units | Changing graph sharing despite identical source/output |
| Constructor consumption | Calls/fields, direct, last-reference and shared branches; span_fade calls/fields | Whether consuming the same Data increasingly requires shared-field retention |
| Measured code patterns | nt_choose calls and ordinary match-result joins | Stable semantic work controls beside changing String/ownership work |

`drop_items` includes the existing outer-loop pass after a retained reference
sets the local term to zero; it is work, not a count of destroyed objects.
`drop_nodes` excludes that zero/trivial case. `drop_fields` includes trivial
child fields inspected during traversal. `alloc_words` is requested size-class
capacity, not committed RAM; `fresh_words` is newly requested corpus quantum
capacity, not an RSS or leak measurement. `take_fields` counts constructor
fields read before ownership handling. String.append counts cover this actual
generated function and its continuation; they do not count unrelated direct
String construction. `match_joins` counts the general compiler composition
continuation identified in the profile, never a benchmark function name.

## Boundaries and perturbation

`counters.h` uses ordinary owner-thread increments, initialized on the main
thread by an early constructor. A different thread entering any counted path
increments a separate atomic rejection flag, and analysis refuses all attribution.
Run only the ordinary `--threads 1 --gpu off` compiler pilot. This avoids silently
dropping worker activity or adding an atomic increment to every hot operation.
It is intentionally not a general parallel runtime profiler.

The15 source edits include a replacement of the sole `io_now_run` return with
the same `io_tick()/1000000` value plus an in-memory counter snapshot. Existing
Base, runtime and request clocks are unchanged in meaning. The maximum16 marks
covers the six/14 marks from COUNT1/COUNT5. All JSON is printed by an exit handler,
after requests finish; no per-event logging occurs in timed regions. The analyzer
requires the exact mark count, matching printed millisecond durations, monotonic
counters, complete final output and zero foreign activity/overflow. It also checks
balanced append characters/returns and the constructor/drop/allocator branch sums.

Expect material observer overhead: many small increments and a predictable
owner-thread branch affect inlining, register pressure and data-cache traffic.
An append character reaches several instrumented helpers, so this is not a
one-increment-per-character experiment. Tens of percent overhead or more is
plausible; there is no measured estimate yet. Root should allow a bounded60–120s
COUNT5 job. Instrumented clocks are diagnostic context only: no performance gain
or regression may be inferred by comparing them directly with production.
Even constant operation counts do not prove locality; they only falsify the
specific counted-work-growth hypotheses and justify the next hardware diagnostic.

## Source binding and commands

Input C SHA256:
`8a636bf108bcc7f8378975b0077a8886be7300556be044b53e27a1023f09c659`.
The source mutator refuses every other image and requires each edited original
anchor to occur exactly once. It writes a fresh directory containing a complete
self-contained C derivative and a receipt binding original/output, instrumenter,
header and old/new hashes for each edit. It leaves the original17.8MB C untouched.

Source-only validation, already performed without output creation:

```sh
python3 selfhost/tools/performance/phase89/counts/instrument.py \
  selfhost/build/phase88/native02/compiler.c /tmp/phase89-unused --check-only
```

This passed15 unique edit groups and predicts derivative C SHA256
`5494712cd2778dc6ef8302497bb893fb5ef7faf996a1c2fbe3a146b856a4e792`.

Root's acquisition sequence:

```sh
python3 selfhost/tools/performance/phase89/counts/instrument.py \
  selfhost/build/phase88/native02/compiler.c NEW_DIRECTORY
# Root builds NEW_DIRECTORY/compiler.c under the existing bounded Clang guard.
# Root runs the resulting diagnostic binary with authenticated native02 inputs.
python3 selfhost/tools/performance/phase89/counts/analyze.py \
  RUN_DIRECTORY/stderr.log NEW_ANALYSIS.json
```

The ordinary launcher correctly refuses this derivative as a cached consumer;
do not add its digest to the qualified native consumer list. Root must authenticate
the original inputs with `native_support.authenticate`, independently verify this
derivation/build and deliberately substitute only the diagnostic binary for its
guarded experiment. The analyzer validates the counter stream, not the executable
or emitted C; those identities and correctness checks stay in root's run receipt.
Failed builds, incomplete counters and incorrect outputs remain diagnostic failures.

No instrumented build or target run was performed by this lane. Root subsequently
built and ran the diagnostic successfully; the results above bind that evidence.
