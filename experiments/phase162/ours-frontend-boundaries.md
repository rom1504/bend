# Phase162 — our frontend work, measured boundaries and cheapest falsifiers

Offline audit at `6c645c34e789b3c7de9229b86e809a7d84dab55e`. No compiler,
build, benchmark or new capture was executed. The evidence is the accepted
Phase153 and Phase161 captures of the same qualified Phase152 compiler object,
plus maintained source. This document does not substitute their diagnostic
stage clocks for clean request timings.

## What the existing samples actually distinguish

Primary receipts are Phase161's
[full summary](../../selfhost/build/phase161/profile-full01/summary.json),
[closure summary](../../selfhost/build/phase161/profile-closure01/summary.json),
[stage contract](../../selfhost/build/phase161/profile-prep04/spec.json) and
[committed profile metrics](../../implementation/phase161/profile-metrics.json).
Both captures pass the existing loss, CPU coverage, ELF/FID and complete-output
contracts. The closure output matches its own clean output; it is **not** equal
to the qualified full-source product and is not a qualified replacement compiler.

| Region | Exact entry boundaries | Full CPU seconds / samples | Closure CPU seconds / samples |
| --- | --- | ---: | ---: |
| Parse/load | `p86_plan` → `p86_plan_loaded` | 29.51885 / 920 | 18.89184 / 588 |
| Checking/publication | `p86_plan_loaded` → `p86_plan_checked` | 33.68414 / 1,051 | 19.29050 / 601 |
| Proof reporting | `p86_plan_checked` → `p86_plan_reported` | 3.31685 / 102 | 1.20571 / 36 |

The first two regions independently meet the maintained 500-sample admission
threshold. Proof-report samples are descriptive only. Boundaries exclude two
edge samples per interval. The full/closure experiments reduce source bytes to
55.03% and textual declarations to 60.58%; parse/load retains 64.00% of time and
checking/publication 57.27%. Different definition/type/pattern composition makes
these useful workload sensitivities, **not** asymptotic complexity fits or an
estimate of execution speed per semantic operation.

The following are **active-owner samples**, not logical call stacks or inclusive
function costs. Each cell is count / fraction of its own stage. Only published
top-owner rows are used; an unlisted function is not a zero.

| Parse/load owner | Full | Closure | Concrete work |
| --- | ---: | ---: | --- |
| `f_eq` | 97 / 10.54% | 71 / 12.07% | String comparison, including syntax/tag/name decisions |
| `f_prec` | 48 / 5.22% | Not in top 12 | Chain of operator-spelling tests |
| `f_grow_base` | 48 / 5.22% | 21 / 3.57% | Contextual application/operator decisions |
| `f_pattern_sub` | 37 / 4.02% | 32 / 5.44% | Recursive pattern substitution and child reconstruction |
| `f_find` | 32 / 3.48% | 14 / 2.38% | Linear declaration search |
| `f_grow_existing` | 28 / 3.04% | 16 / 2.72% | Continuing an already-parsed expression |
| `f_ctor_lookup` | 26 / 2.83% | Not in top 12 | Constructor search through declarations/children |
| `ffw_walk_existing` | 23 / 2.50% | Not in top 12 | Freshening/binder traversal |
| `k_with_children` | Not in top 12 | 14 / 2.38% | Rebuilding a term with new children |

The scalar lexer is already integrated. These observations do not support
assuming that byte scanning alone explains the remaining parse/load cost.

| Checking/publication owner or explicit group | Full | Closure |
| --- | ---: | ---: |
| Five `book_final_*` helpers below | **252 / 23.98%** | **100 / 16.64%** |
| `p131i_insert` | 100 / 9.51% | 54 / 8.99% |
| `index_remove` | 53 / 5.04% | 36 / 5.99% |
| `lookup` | 49 / 4.66% | 43 / 7.15% |
| `p88_string_eq` | 48 / 4.57% | 27 / 4.49% |
| `constructor_exists` | 48 / 4.57% | 18 / 3.00% |
| `index_hash` | 36 / 3.43% | 15 / 2.50% |

The five-helper group is exactly `book_final_seen`, `book_final_names_valid`,
`book_final_filter`, `book_final_step`, `book_final_scan`: full counts
58+55+54+46+39; closure 18+16+20+28+18. It excludes their index/hash/runtime
callees and any unlisted book-final owners. Phase153 independently recorded
243 named book-final samples out of 1,047 check-stage samples (23.21%), with
33.56818 diagnostic stage seconds. The repeated signal is strong enough to
prioritize a work census, but is not “24% can be removed” or a causal assignment
of all hash/reclamation time to publication.

Physical leaves provide a different, overlapping view. `term_drop + span_fade`
account for 155/920 (16.85%) and 102/588 (17.35%) parse samples, and 227/1,051
(21.60%) and 113/601 (18.80%) checking samples. These are reclamation execution
sites, not allocation origins. Do not add their percentages to active-owner
percentages. Normalization is not among the top 12 checking owners; neither
normalization's total cost nor the cost of its callees is established by that
absence.

## Which operations should be counted, and what each count would falsify

1. **Publication/list coherence first.** Count `p143cp_canon` requests, which
   publication reason requires them, raw declarations visited by
   `book_final_names_valid/scan/filter/reverse`, canonical rows retained,
   index-node inserts/removals, and childless versus datatype/other events.
   Count traversed rows, not just top-level calls. The current
   [`p143cp_put_log`](../../selfhost/src/check/compact-schedule.bend#L59)
   canonicalizes before non-childless publication. The large-book path
   [`book_final_fast`](../../selfhost/src/core/index.bend#L411) validates names,
   reverses, scans through a seen index, filters and reverses again. A few calls
   can therefore visit many old declarations. If repeated visited rows vastly
   exceed newly published rows, the gap includes avoidable repeated work. If
   not, prioritize per-row representation/ownership cost rather than another
   coherence cache. Phase156 already provides a real-work provenance candidate;
   measuring its remaining traversal count is more informative than rediscovering
   its local replay win.

2. **Search work, separated by namespace.** Count successful/missing declaration
   and constructor queries, list rows visited, index nodes/bucket comparisons,
   and characters hashed/compared. Keep parser searches, constructor collision
   validation and ordinary semantic lookup separate.
   [`f_find`](../../selfhost/src/front/declarations.bend#L167) is a linear search;
   [`f_ctor_lookup`](../../selfhost/src/front/validate.bend#L75) also visits child
   constructor lists; [`constructor_exists`](../../selfhost/src/check/kernel.bend#L1156)
   scans declarations to enforce constructor-name uniqueness. Existing indexed
   `lookup` does not eliminate those distinct searches. More visited rows per
   declared name supports better fact ownership/indexing; similar visits but high
   CPU/allocation per visit supports representation/generated-code investigation.
   Preserve collision behavior and duplicate/error order.

3. **Parser decisions and term reconstruction.** Count parsed tokens/terms,
   `f_prec` calls, spelling comparisons and compared characters; count nodes
   visited and replaced by `f_pattern_sub`, and output nodes reconstructed by
   `k_with_children`/freshening. [`f_prec`](../../selfhost/src/front/parser.bend#L520)
   tests a spelling chain and `f_grow_base` repeats token-text decisions.
   [`f_pattern_sub`](../../selfhost/src/front/elaborate.bend#L216) walks children
   even when the current node is not the target binder. A high visits-to-produced-
   term ratio identifies repeated work; a low ratio with expensive visits points
   to term/child/ownership representation. A token enum alone is not yet an
   end-to-end win: count creation and all conversion consumers too.

4. **Normalization as a competing explanation, not an assumed hotspot.** Count
   conversion requests, rigid-pass successes, unfold fallbacks, graph-cell hits/
   misses, `g_get/g_put` node visits, beta steps and substituted/rebuilt terms.
   Our [`norm_convert`](../../selfhost/src/core/normalize.bend#L628) and
   [`GHeap`](../../selfhost/src/core/graph.bend#L293) already memoize with separate
   rigid/full-book state. Few normalization operations falsify it as the primary
   frontend algorithmic gap; many visits per comparison motivate a scoped
   representation experiment. Comparing memo hit counts alone is insufficient.

The distinction “more work versus slower work” requires both a semantic unit
and its complete CPU/allocation cost. On the **same implementation** built by
QBE and bendc/C, matching semantic counters but different CPU per unit implicates
execution/representation. On two different compiler implementations, query,
term and comparison units require explicit matching definitions; raw function
invocation counts are not comparable semantic work.

## Existing counters and what they cannot establish

The maintained [diagnostic runtime](../../selfhost/tools/profiler/runtime-support.inc.c)
already measures allocation/free calls and requested words, keep/sink/drop/take,
frame/register transport and dispatches. They can expose cost per completed
frontend request, but allocation requests are cumulative rather than retained
memory, drop entries are not traversed nodes, and inline operations may bypass
hooks. Private synchronous calls retain their caller's dispatch identity.
Consequently, a dispatch histogram alone is not an exact lookup/term-visit census.

The existing [stage observer](../../selfhost/tools/profiler/stages-runtime-v1.inc.c)
counts selected FID entries but intentionally forbids simultaneous event-counter
collection. Do not bypass that admission rule or divide independently measured
stage clocks by whole-request counts. Either make a separate exact-output event
capture or introduce a narrowly specified stage-counter snapshot mechanism with
its own overhead/output gates. For generated loops/inlined helpers, count the
actual iteration/operation site; a function-entry probe may miss recursive work
lowered to a loop. No new such instrumentation has been implemented here.

## Native command and exact stop boundary

There is **no check-only mode on the inspected qualified QBE N2 entry**.
[`qbe-main`](../../selfhost/src/host/qbe-main.bend) calls
[`p111_native_args`](../../selfhost/src/back/qbe/lower.bend#L789), which supports
ordinary emission plus batch/session contracts. The maintained request adapter's
[`qbe-source-v1`](../../selfhost/tools/build/request.py#L204) requires QBE emission.
The public native-C CLI likewise requires an output path. Hosted/upstream
`--check-only` controls are different executables/contracts and cannot stand in
for this native compiler measurement.

The qualified source-emission command shape, **not executed by this audit**, is:

```text
selfhost/build/phase152/native-n2/program --threads 1 --gpu off --
  phase111 ABS_INPUT ABS_BASE cache ABS_CARRIER EXACT_STAMP
```

Use the authenticated maintained assets and request wrapper for an actual run;
paths/stamp and resource guard must be supplied explicitly. Phase161's recipe
uses the diagnostic relink instead of this qualified executable and supplies
the exact source, Base, carrier and stamp in its
[full recipe](../../selfhost/build/phase161/profile-full01/recipe.json).

Entry to [`p86_plan_loaded`](../../selfhost/src/host/native-plan.bend#L143)
means the parser/loader has produced `FPrefixLoad`. Entry to `p86_plan_checked`
at line 159 means `DResult` has been computed, including the selected large-suffix
checker or original small-suffix fallback. It is before proof reporting,
owned/foreign and main eligibility, annotation, erasure and backend work.
`p86_plan_reported` additionally includes `driver_report_data(original)`; that is
an unsafe/dependency report, not independent BendTT proof execution.

A signal/forced exit at either marker is **not successful check-only completion**:
it omits outcome observation, normal destruction and later semantic eligibility.
A new valid terminal observer should inspect the exact `DResult` success/error,
serialize its complete checked book/diagnostic outside the measured checking
interval, and finish normally. Its result contract must be compared to the
original qualified route, including failing inputs. Such an observer would be
an experimental harness requiring acquisition; it is not an existing qualified
command and should not silently replace the normal check contract.

## Cheapest useful falsifier

Start with the existing full-source profile, not another full benchmark: repeated
book canonicalization is the best-supported concrete algorithmic lead. The next
new measurement should count **rows visited per publication** and constructor
collision-search work on one real checker input, paired with exact full checked
outcome. Use the original and already-reviewed Phase156 provenance routes when
available. If traversal amplification does not fall materially, reject a broad
book rewrite as the current speed priority; do not infer a gain from source size.

For the cross-implementation question, use identical input/Base and stop at
equivalent observed parser/checker outcomes. Keep parse, checking and report
separate. The current 645-declaration checker pilot is cheap but was neutral for
publication: it has only 23 datatypes versus 369 in the full source. It is useful
for observer/control validation, not a sufficient performance surrogate for the
full source's publication workload. Escalate to full source only once the counter
definition, outcome equality and instrumentation overhead are established.

This is a bounded information-gathering recommendation. It does not recommend
another common compacted-body cache, unchecked compilation, disabled correctness
gates or an unqualified compiler promotion.
