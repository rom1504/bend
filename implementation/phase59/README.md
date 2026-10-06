# Phase59: where the remaining compiler gap comes from

The repeat confirms **2.604× TypeScript on Lexer and 2.400× on Evening** for
the unchanged Phase58 B2's **import + API load + first library compilation**.
This measures the compiler executing, not the execution speed of the programs it
produces. We changed measurement tools only. The compiler written in Bend,
runtime, ordinary driver and installed release remain unchanged.

The useful new finding is that the workloads have different bottlenecks. Lexer
leans toward checking/completion and persistent term/book reconstruction.
Evening exposes much more allocation in generated-string processing and emitted
dependency discovery. Startup already favors B2, so optimizing module import is
not the main route to parity.

## The controlled comparison

| Input | B2 first combined | TypeScript first combined | B2 / TS | First compile alone, B2 / TS |
| --- | ---: | ---: | ---: | ---: |
| Lexer | 1,687 ms | 648 ms | 2.604× | 4.169× |
| Evening | 2,270 ms | 946 ms | 2.400× | 3.204× |

These are clean medians from three fresh processes per role/input. B2 startup
takes about 106–109 ms versus TypeScript's 269–271 ms. Three later requests per
process remain a separate, still-warming statistic: 2.938× for Lexer and 2.550×
for Evening. They are not steady-state throughput.

The pinned TypeScript commit is `018751270e800bc222a93dad7f257083ee53a5f7`;
the genuine last01 B2 SHA256 is
`a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`.
Private Base disk caches were primed outside measurement. Each request used the
ordinary compiler API and fresh book, with complete output-byte validation
against its independently prepared, executed value oracle.

Unlike the previous after-warmup profiles, the new CPU/allocation captures start
before the actual compiler imports and end after exactly one first compilation.
Output checking, hashing and saving happen afterward. The same output checks
also passed with private diagnostic stage clocks and counters.

See [all clean timings and profile figures](measurements.md),
[the design](../../design/phase59/first-request-attribution.md), and
[repeatable commands](../../selfhost/tools/performance/phase59/latency/README.md).

## What consumes the request

These are **separate diagnostic stage means**, not the clean medians above.
Nested clocks partition their parent; inclusive and exclusive costs are never
added together.

| Selected stage | Lexer B2 | Evening B2 | TypeScript comparison / scope |
| --- | ---: | ---: | --- |
| Base cache and input identity | 201 ms | 189 ms | B2 host/cache work; no identical TS stage |
| Check and complete API | 686 ms | 638 ms | TS `book_valid`: 163 / 162 ms; B2 also bundles specialization/completion |
| Emitted dependency discovery | 152 ms | 553 ms | Part of the backend; no identical TS stage |
| Final library rendering | 101 ms | 313 ms | TS **whole** `js_lib`: 59 / 357 ms |

This table deliberately selects important stages rather than pretending they
sum to the whole request. Source loading/completion, annotation, source reach,
layout and source-span validation are included in the complete
[stage partition and diagram](stages.md).
TS and B2 organize this work differently; the stage names do not establish
equivalent algorithms or the same amount of work.

## Allocation and executed work

| One first window | Lexer | Evening |
| --- | ---: | ---: |
| B2 sampled allocation | 246 MB | 898 MB |
| TypeScript sampled allocation | 65 MB | 124 MB |
| Allocation ratio | 3.79× | 7.25× |
| Primitive table constructions | 711 | 2,595 |
| Retained list links reconstructed by `index_remove` | 329,274 | 374,623 |
| Generic substitution visits | 155,141 | 511,645 |
| Nonliteral substitution rebuild entries | 109,461 | 365,305 |

MB means decimal megabytes. Allocation is sampled cumulative allocated bytes,
including import/API initialization and collected objects, not peak memory or
exact object counts. Counters start after API load and cover only the first
compilation request. They are separate source-operation observations, not
physical allocation estimates.

On Evening, the shared workers labelled `String.contains.if` and
`jd_reach_refs_unique` account for **54.16% of sampled allocation**. Independently,
exact ancestor-stack attribution places **50.77%** under emitted reachability.
Those figures overlap and must not be added. On Lexer, checking/completion
accounts for 38.01% of sampled allocation; substitution and persistent indexes
are more prominent. Unknown ancestry stays unassigned.

The primitive table has **90 entries**, and every lookup constructs it anew.
The count therefore implies 63,990 / 233,550 executed primitive-record literal
sites, before its list links; it does not prove that V8 allocates each record.
The existing stable-substitution proof already succeeds 944 / 1,590 times, so
adding another identical proof pass would duplicate work.

The quantity-list hypothesis is lower priority on these workloads: get/delete
visits total only 26,270 / 25,848, about 2.83 visits per merged left entry.
Wide synthetic cases could behave differently.

See [counter findings](counter-findings.md), [source audit](source-analysis.md),
and [conservative profile-to-stage attribution](profile-stage-attribution.md).

## The next experiments, in order

1. **Eliminate reconstructed original strings.** The generated `String.contains`
   loop extracts a Unicode head and tail, then passes `head + tail` to a prefix
   test. That round trip can use the original matched string when provenance
   proves the pieces unchanged. This is a general lowering improvement, analogous
   to the earlier U32 reconstruction work. The shape plus allocation profile
   makes it a strong first hypothesis; repeated V8 flattening/copying is not yet
   proven. A tiny length-scaling experiment and diagnostic rewrite can test it
   before implementing the corresponding Bend compiler change. Include empty,
   astral, prefix-failure and overlapping-search controls.
2. **Stop rebuilding/scanning the primitive table.** A direct name dispatch or
   shared immutable representation can preserve the same admission/type checks.
   This is a small, bounded experiment with an exact output oracle. Its measured
   work is real, but it alone cannot remove the overall gap.
3. **Reduce index event-list copying and unchanged term reconstruction.** Index
   removal reconstructs far more retained links than trie nodes. Audit update
   callers and preserved duplicate/precedence semantics before changing storage.
   For substitution, extend existing valid reuse proofs rather than assuming
   absence of a variable permits skipping beta/canonical reconstruction. These
   are stronger candidates for the Lexer/frontend gap, with higher semantic risk.
4. **Carry uses and references with emitted code.** After the small string test,
   compare an emitter result containing text plus dependency/use information
   against rendering and scanning strings. This could remove repeated work more
   fundamentally. Preserve demand/erasure, SCC, foreign reachability and context
   changes; cached rendered text alone is not automatically reusable.
5. **Reduce cache validation passes and locate repeated completion.** The first
   request still reads, decodes, hashes and validates the Base graph. A persistent
   in-memory cache helps later requests, not this fresh-process metric. Any new
   format or fused traversal must retain corruption/schema/span checks. The
   checking API also bundles completion and specialization; split its diagnostic
   attribution before committing to a checker representation rewrite.

No speedup for these proposals is established by this investigation. Removing
all of the measured cache work would still leave most of the gap; eliminating a
large fraction of allocated bytes need not save the same fraction of time.

## Scope, cost and preservation

There were 38 serial target processes: preparation, 12 clean workers, five CPU
captures (including one retry), four allocation captures, 12 stage workers, and
three counter preparation/sample processes. Their recorded process wall time
totals **180.2 seconds** ([recorded accounting](../../selfhost/build/phase59/work-accounting.json)). This excludes parallel source analysis, tool development,
reviews and publication. Maximum observed target process-tree RSS was
**622.6 MiB**, under the 2 GiB guard. Targets stayed on CPU3; analysis used CPU0.

All workload/output checks passed. One CPU capture had timestamp deltas outside
the existing weighted-attribution policy; its count view remains valid, and the
failed weighted view and separate retry are both retained. It is not silently
replaced or pooled. [Independent review](method-review.md) covers measurement
boundaries and diagnostic derivatives.

The preservation audit passed for the closed Phase58 campaign's 30,169 files,
seven installed files, selected compiler/runtime/driver sources and 103 inherited
protected files. No compiler release, broad conformance rerun or generated-program
performance claim was made. No PR comment was posted. This phase supplies a
ranked, reproducible starting point for the next optimization pass.

All **518 raw files** are preserved in the verified
[5.33 MB evidence capsule](../../selfhost/tools/performance/phase59/artifacts/raw/README.md).
Report links into `selfhost/build/phase59/` refer to capsule members; the reports
and standalone SVG diagrams are committed directly. Raw writers are closed.
