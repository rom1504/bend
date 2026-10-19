# Phase112: measured effects of semantic lowering and bounded regions

The compiler allocation hypothesis is confirmed: on the same `lexer-scan`
compilation request, the new compiler makes **86.75% fewer allocation-helper
calls**. Its U32-to-Word conversions and WCon takes disappear. The bounded-region
experiment has a different result: it removes only 512 ray dispatches and no
frames; five other workloads have identical dynamic event counts.

These are diagnostic event counts, not CPU-time shares or speed ratios. Root ran
the targets; this comparison only reads completed receipts. Exact inputs, hashes,
counts and extracted function-body hashes are in
[`profile-improvement-counts.json`](profile-improvement-counts.json).

## Compiler: the representation cliff was real

Both compiler profiles use the same request arguments and source assets, with the
same instrumented runtime04. Each instrumented compiler reproduced its own prior
uninstrumented output exactly. The expected output changes from 204,540 to 205,140
SSA bytes across compiler versions; this comparison does **not** assert old/new
SSA identity. The profile receipts are
[`profile-compiler01`](../../selfhost/build/phase112/profile-compiler01/report.json)
and [`profile-word-compiler01`](../../selfhost/build/phase112/profile-word-compiler01/report.json).

| Event | Baseline | New compiler | Change |
|---|---:|---:|---:|
| Heap allocation helper | 124,677,389 | 16,515,651 | −86.75% |
| Reference-count wrapper creation | 59,036,946 | 7,234,837 | −87.75% |
| U32 special take | 1,625,654 | 0 | Eliminated |
| WCon constructor take | 23,670,366 | 0 | Eliminated |
| Public closure creation | 2,149,393 | 3,020 | −99.86% |
| Public closure application | 1,075,823 | 2,599 | −99.76% |
| Public runtime calls | 170,233,886 | 121,343,692 | −28.72% |
| Segment dispatch | 28,422,884 | 22,794,443 | −19.80% |
| Continuation frame creation | 13,652,223 | 11,437,689 | −16.22% |
| Requested register-word clearing | 659,583,196 | 549,446,618 | −16.70% |

The original runtime materializes each U32 Word with 32 constructor allocations
and 31 reference-count wrappers. Its 1,625,654 conversions therefore account for
102,416,202 allocation calls and 50,395,274 wrapper creations. Eliminating that
category explains most of the observed reduction. The total allocation reduction
is larger, at 108,161,738, because this compiler snapshot composes several changes.
In particular, general selector specialization also removes closure machinery:
`nt_choose` dispatches fall from 252,295 to zero, and `kc` from 758,368 to zero.
The closure reduction must not be attributed to word-pattern recovery alone.

Two stable functions provide a useful check that the compiler still performs the
same scanning work while lowering it more directly:

| Function | Dispatches, unchanged | Public calls before → after | Public QBE body bytes before → after |
|---|---:|---:|---:|
| `p88_digits` | 1,087,899 | 25,988,788 → 11,105,052 | 257,833 → 90,931 |
| `p88_field_number` | 228,745 | 6,622,347 → 1,370,957 | 668,588 → 6,886 |

The complete compiler QBE shrinks from 44,349,671 to 28,462,589 bytes, and its
segment count from 39,957 to 27,853. That creates a plausible machine-build
benefit as well as less executed work, but requires uninstrumented measurement.

Not every event declines. Public `sink` calls rise from 10,512,452 to 11,344,477
(7.91%); internally counted `term_sink` calls slightly decline. Nested counters
overlap and cannot be summed into a time model. Heap allocations and frees agree
in both runs, but this is not a complete memory-safety proof.

## Generated programs: scalar gains, continuation work remains

The six-program
[`static → word comparison`](../../selfhost/build/phase112/profile-static-word-comparison01/report.json)
also spans composed scalar/private-worker/selector changes. It is not an isolated
measurement of word-pattern recovery.

Ray's primitive calls fall from **1,957,364 to 54,680**: exactly **1,902,684**
calls disappear, matching the baseline profile's F32 opportunity. Numeric's
primitive calls fall from 10,291 to 2,095. In ray, however, frame creation falls
by only seven calls, from **334,018 to 334,011**. Stack field reads remain almost
unchanged at 2,709,242, and 932,373 Succ special-takes remain. Removing primitive
boundaries succeeds while ordinary call/continuation transport remains frequent.

All six programs lose just 127 allocations and 62 reference-count wrappers each,
consistent with removing two common U32 special-takes plus one WCon construction.
The compiler's repeated Word-materialization pathology is not representative of
these generated workloads. Optimizing it can strongly improve compiler execution
without producing a comparable generated-program gain.

## Bounded regions: admission misses the hot call graph

The isolated
[`word → region comparison`](../../selfhost/build/phase112/profile-word-region-comparison01/report.json)
finds identical scalar counters, dispatch totals and public-call totals in lexer,
closures, unicode, map and numeric. Ray changes only as follows:

| Ray event | Word | Region | Difference |
|---|---:|---:|---:|
| Dispatches | 683,959 | 683,447 | −512 |
| Public runtime calls | 6,694,462 | 6,693,950 | −512 |
| Public jumps | 349,845 | 349,333 | −512 |
| Frame creation | 334,011 | 334,011 | 0 |
| Heap allocation | 4,108 | 4,108 | 0 |

The only stable function-dispatch reduction is `clamp01`, 512 → 0. The source
audit already identified its two changed call sites. The larger set of admitted
private definitions does not translate to a broadly changed executed graph.
This is evidence that the current admission boundary misses the dominant work,
not evidence that eliminating continuation transport is ineffective.
[`region-profile-followup.md`](region-profile-followup.md) records the exact
arity, capture and continuation restrictions and unchanged hot bodies.

## What the evidence supports next

1. Qualify the compiler representation and selector changes with the existing
   independent semantic gates and matched uninstrumented compilation timings.
   The mechanism is demonstrated; its time benefit must use those measurements.
2. For generated programs, prioritize admitted returning call paths and their
   continuations. Require fewer hot frame/jump events before another broad timing
   campaign. Creating more private definitions is not a useful success metric.
3. Reprofile the resulting compiler before pursuing a new allocator or backend.
   Its remaining costs include 11.44 million frames, 23.43 million stack field
   reads, and 549.45 million requested register-word clears. String equality,
   append, comparison and digit processing are prominent stable dispatch names.
   Counts identify frequent mechanisms; they do not establish their CPU-cost rank.

The same diagnostic runtime, source-level counters and exact-output gates make
these comparisons reproducible. Instrumentation can perturb execution, so none
of its elapsed times are used as performance claims. Per-function attribution
uses the last dispatched segment, not a native call stack; anonymous continuation
names are not paired across compiler snapshots.
