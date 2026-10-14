# Ownership attribution for the native compiler

Final phase results and integration decisions are in [README.md](README.md).
The audit/proposal narrative below records its original stage; statements about
what this lane ran are not the final root-run qualification or speed result.


This lane prepares source/offline diagnostics; root executes all targets. It
changes no production source, runtime guard or existing native image. The
current experiment workflow and Phase87 evidence remain authoritative.

## Native02 Map: remaining request costs

The new [Map profile](../../selfhost/build/phase88/ownership02-map.analysis.json)
measures the cache/equality native02 image, SHA256
`5babec07f3ff4c3a8c8e7be00566a681a4068b098349f9ee5207e53aa3231c9c`.
Its exact checked C is `native02/compiler.c`, SHA256
`8a636bf108bcc7f8378975b0077a8886be7300556be044b53e27a1023f09c659`.
The samples hash is
`47ed34d87df777d1e5ca86aaa62432a6747bdfdcca4f03fb5c6325e8661e5ad6`.
All clock boundaries pass, process CPU coverage is 99.998%, and no samples
overrun or drop. Cached Base takes 58 ms; its 14 samples are too few for
attribution. The five requests provide 3,015 samples, including 1,849 ownership
samples whose physical caller is recovered. These are diagnostic clocks, not
a new controlled comparison against upstream.

| Request | Wall ms | Samples | Ownership | Append plus its direct ownership costs | Match-result body destruction |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 | 2,083 | 520 | 341 | 128 | 63 |
| 2 | 2,208 | 552 | 339 | 161 | 70 |
| 3 | 2,383 | 596 | 367 | 185 | 61 |
| 4 | 2,586 | 646 | 391 | 213 | 75 |
| 5 | 2,803 | 701 | 411 | 238 | 80 |

The clearest individual remaining destruction site is
`WL_FID_NC_MATCH_APPLY_ORIGINAL_TO_K9473`: **349/3,015 samples (11.58%)**.
This continuation finishes the ordinary match composition in
`src/back/native/bridge.bend:nc_match_apply_slow_to`. The source constructs a
parent `NC_Code` using multiple projections of both complete child results:
body, segments, freshness, errors and calls. At generated C line259942, the
child body strings remain retained after parent body construction. `spin_143`
(line18567, the segments projection) sinks its input's body/error/calls; the
continuation later sinks the miss fields after reading freshness.

The two sampled sites account for 348 of those 349 samples. Disassembly binds
return-minus-one `0x42cf70` to destruction of `STK(0)` / `_hit_80`, the hit body
(197 samples), and `0x42d29d` to `STK(5)` / `_miss_70`, the miss body
(151 samples). Thus this budget is specifically whole child-body destruction
after constructing parent output, not generic unexplained reference counting.
The continuation's name reflects upstream inlining; it is not evidence that
the scheduler-route predicate itself costs 11.58%.

Two further general patterns remain:

- `nt_choose` destroys its unchosen closure: 231 samples (7.66%). Generated
  C line571925 directly shows `term_sink(no)` / `term_sink(yes)` followed by
  `CLO_APPLY`. That dispatch has another161 leaf samples (5.34%) across all
  callers. Tail transfers prevent attributing either bucket to particular Bend
  choice sites; the two buckets are not a proven removable combined gain.
- `String.append` and its return continuation take461 leaf samples (15.29%).
  Their directly recovered `span_fade`, `term_drop`, and `rfc_wrap` callers
  add464, giving **925 samples (30.68%)** for the disjoint append family.
  Generated C line592865 opens/frees each left-input character; line592902
  allocates and seals a new character on return. This is still substantial
  string materialization after the earlier three linear-builder fixes. Its
  semantic emitting callers are not recoverable from this physical stack.

The smaller projection examples are still identifiable: `spin_1` is `tg`
(159 ownership samples, 5.27%), `spin_33` is `ks` (79, 2.62%). `spin_2` is now
the consuming String equality helper (156, 5.17%), not the old String.order
pair reconstruction. Its remaining input-tail destruction is expected ownership
work and should not be mistaken for failure to apply the earlier fix.

### Strongest next experiments

1. **Consume an `NC_Code` product once when combining children.** Start with
   the measured ordinary match composition: destructure hit/miss once and pass
   owned body/segment/error/call fields to the final constructor, preserving
   original evaluation, first-error, freshness and segment order. This is a
   general match-lowering change, with no program-name special case. It aims
   to remove the extra retained child bodies exposed by the two exact sites.
   The11.58% measured destruction budget is a ceiling on directly removing
   those two sites, not a predicted gain: useful body construction/destruction
   can move elsewhere. First compare complete `NC_Code` products on nested
   branches and errors, then full C on Map and a non-Map branch-heavy control.
2. **Carry output chunks through nested code composition, flatten once.**
   If the owned-field prototype still copies every child body into every
   enclosing parent, move body assembly to an ordered chunk representation
   shared by the relevant native composers. This targets the measured append
   family and the child-body lifetime together; their budgets must not be
   added as promised speedups. Preserve emitted bytes and avoid pushing work
   into a later unmeasured flatten. This is a larger representation experiment
   than the single-combiner prototype.
3. **Use direct branching at proven costly closure-choice sites.** The
   common mechanism is certain but its source attribution is incomplete.
   A bounded compiler-host derivation or a few statically verified source
   rewrites can test the value; do not blindly rewrite every thunk or infer
   all `CLO_APPLY` samples belong to `nt_choose`.

### What repeat growth does and does not establish

Request5 is34.6% slower than request1. Samples increase181; the append family
increases110, explaining approximately61% of that sampled increase. Total
ownership increases70, but this overlaps the append family. The matched
body-drop sites increase17 and discarded-choice destruction10. This shows
growth is concentrated in allocation/materialization work rather than a new
dominant semantic pass. Equal emitted C does not prove equal operation counts.

The profile has no allocation/count/cache-miss counters. It cannot distinguish
additional refcount/copy work from the same work becoming less cache-local, and
does not prove a leak, retained old outputs, growing reference-count depth or
a particular allocator defect. The immutable prepared Base and source-level
request loop do not intentionally accumulate compiler results. Output writing
is outside the request timer, so file-writing time itself cannot explain this
in-timer growth. A causal discriminator would count append input characters,
allocations and drop/fade work per request in a disposable bounded diagnostic;
constant work with slower clocks would prioritize cache/locality counters.
No runtime/production/tool changes or target execution were made for this audit.

## Validated phase and caller evidence

Root's [Small profile](../../selfhost/build/phase88/ownership-small.analysis.json)
passes the exact clock checks and recovers a physical owner for all 512 Base
ownership samples. Base is 3,075 ms with 768 samples; the request is 83.6 ms
with only 21 samples. The latter is too sparse for ranking small request costs.

The leading Base ownership caller is **String.order result destruction**:
172 of 768 samples, or 22.40% of the complete Base phase, are in `term_drop`
called from `WL_FID_STRING_ORDER_K25276`. This is a concrete allocation/use
pattern, rather than an unidentified allocator bill. The other clear Base
examples are `kc` dropping the unchosen thunk (48 samples, 6.25%) and the term
tag projection `spin_11` (24 drop plus 17 fade samples, 5.34%).

Root's [five-request Lexer profile](../../selfhost/build/phase88/ownership-lexer.analysis.json)
independently recovers all 588 request ownership samples:

| Phase | Wall clock | Samples | Ownership samples | String.order destruction samples |
| --- | ---: | ---: | ---: | ---: |
| Base | 3,094 ms | 773 | 522 | 189 (24.45%) |
| Request 1 | 649 ms | 162 | 113 | 43 (26.54%) |
| Request 2 | 721 ms | 181 | 116 | 44 (24.31%) |
| Request 3 | 774 ms | 193 | 113 | 33 (17.10%) |
| Request 4 | 814 ms | 203 | 126 | 46 (22.66%) |
| Request 5 | 841 ms | 210 | 120 | 41 (19.52%) |

Across those five requests, String.order destruction is 207/949 samples
(21.81%). Refcount wrapping called from String.append's return continuation
adds 50/949 samples (5.27%); `kc` destruction adds 29/949 (3.06%). These are
sampled leaf/caller buckets, not independent measured optimization gains.
The first three individual requests remain below the tool's 200-sample precision
threshold; aggregation supports the common mechanism more strongly than small
differences between request percentages. The remaining repeat slowdown is still
not explained by instruction/cache counters.

### Concrete source and machine-code cross-check

Pinned `base.bend:1952` implements `String.order` as
`Pair.snd(String & String, Cmp, String.cmp(a,b))`. `String.cmp` reconstructs both
strings as it returns the comparison. `String.eq` uses this order operation.
In the exact Phase87 `linear-acquire/compiler.c:665243`, its return continuation
constructs a tuple of the two returned strings, seals them, and passes it to
`spin_341`. That inline helper (`compiler.c:25558`) calls `term_sink` on the
tuple and returns only the comparison. Disassembly shows the corresponding
`term_drop` call at `0x95b798`; the sampled return site is `0x95b79c` after the
analyzer's return-address-minus-one convention. This substantiates the source
interpretation with the actual executed call site.

`spin_11` (`compiler.c:16541`) is the shape of `core/term.bend:tg`: it opens
`KTerm`, returns its tag and sinks name/kids/removed; the other constructor arms
return literal tags and sink their unused fields. Thus the smaller projection
budget is also real, although broader semantic callers have been erased by
musttail transfers. `kc` identifies the dropped alternative, not the Bend site
which constructed it; it must not be assigned to a specific checker pass yet.

The strongest next ownership candidate is therefore an equality/order consumer
which computes only the answer it needs, avoiding reconstruction and destruction
of both String inputs. Preserve Unicode character comparison, ordering, empty
prefix behavior and linear ownership. A naïve source replacement could lose
the JS target's primitive String fast path, so prototype its native benefit and
JS lowering separately. No such compiler change is implemented by this lane.

## What the previous profile establishes

After the general linear String builders, native append samples fall sharply.
The absolute sampled `term_drop`/`span_fade` estimate remains approximately
3.8 s for the full five-Lexer process, becoming a majority of its samples.
That process includes roughly 3 s of Base preparation. It does **not** establish
that most individual request time is spent dropping objects, nor does a generic
ownership leaf name identify the compiler pass that produced the objects.

The pinned runtime uses immediate reference counting and bounded-generation
free lists. It neither scans a growing free list nor adds a redirect layer on
each retain. A low peak RSS does not establish good locality or balanced counts,
but timing growth alone does not establish a leak. No allocator change is
justified by those observations.

## Diagnostic delivered

[Tools and commands](../../selfhost/tools/performance/phase88/ownership/README.md).
The derivative retains the Phase68 sampler's all-created-thread timers,
per-thread capacity, coverage checks and final process mappings. It adds sample
timestamps and two narrowly scoped mechanisms:

1. The existing `io_now_run` function in the Phase87 binary calls
   `clock_gettime@plt` directly. A preload intercepts only calls whose physical
   return address lies inside that exact function. This records actual existing
   Base/runtime/request boundary clocks without modifying the entry or inferring
   boundaries from delayed output. The analyzer must match every printed
   millisecond interval exactly and require six marks for COUNT1 or fourteen
   for COUNT5.
2. The existing unstripped executable also contains `.eh_frame` data, despite
   lacking source-level DWARF. Offline extraction finds 55 supported unwind rows
   for `term_drop`, `span_fade` and `rfc_wrap`. The sampler recovers up to three
   physical return addresses through only these functions. It checks every read
   against the interrupted thread's known stack bounds and does not assume that
   `rbp` is a frame pointer. In this binary `span_fade` actually calls
   `term_drop`, so the second recovered physical address can expose its generated
   caller rather than stopping at another runtime name.

The table is bound to the complete Phase87 `compiler-linear-o2` SHA256
`0c93d7c5cc24f0b86662573c9ba47cbe5cb854c7e72ad4f747d9ba24ca83c98f`.
The full image remains unchanged. A repaired image requires its own freshly
generated table and small preload build; it does not require another diagnostic
compiler build. Python syntax and offline table extraction were checked in this
lane. Compilation, execution and actual sample outcomes belong to root's run
receipts, not to these preparation checks.

The analyzer groups leaf and ownership-caller samples by Base, runtime, each
request and outside time. It retains ELF return sites for source/disassembly
inspection. Musttail-eliminated Bend frames cannot be recovered; a physical
segment caller must not be presented as a full semantic caller stack. Low-sample
request intervals remain low precision even if Base supplies thousands of
samples. Profiler overhead and output correctness need separate validation.

## Concrete source candidates to evaluate after attribution

### Reuse the checked Base world in preparation

`phase86/entry.bend:p86_prepare_loaded` calls `check_book(book)`, which reaches
`check_book_diagnostic` and `dg_check_world`. On success,
`p86_prepare_checked` then calls `base_prefix_prepare(book)`, which invokes
`dg_check_world` again. This constructs and discards a full checked world twice
before creating the persistent prefix products.

The conservative replacement is to retain the first `DChecking`, derive the
same ordinary diagnostic/error from it, and on success feed that same result
and its world into `base_prefix_prepare_fresh`. Existing admission/replay checks
must remain. Do not simply skip `check_book` and turn detailed Base errors into
an eligibility error. Compare the complete prefix-state/prepared-world products
on the authenticated Base plus invalid/ineligible controls before measuring.

This is an identifiable duplicated computation with startup-only benefit; it
cannot by itself accelerate a request using an already prepared Base. Its gain
is bounded by the cost of one check and its associated destruction, not all
native Base time. A root-owned Base lane can use the phase profile to establish
that budget. Keeping a session alive already amortizes the whole preparation
cost and should remain explicit in cold-versus-session comparisons.

An isolated implementation now exists at
[`phase88/entry.bend`](../../selfhost/tools/performance/phase88/entry.bend), copied
from the Phase86 entry. SHA256:
`7e6b4f01c4b8f489618838800178b216468a59bd37801323aee5961cc3983db5`.
`p86_prepare_check` derives the identical `dg_legacy_result`/`dg_result_error`
diagnostic from the retained check. `p86_checked_prefix` uses the same result,
its world, `norm_max_book` and `kw_fresh` with the existing
`base_prefix_prepare_fresh`. World preparation and all three readiness checks
remain in their original order. This is a source-only candidate until root
validates the complete checked acquisition and native outputs.

[`base-products.mjs`](../../selfhost/tools/performance/phase88/ownership/base-products.mjs)
compares the complete returned preparation Data DAG from baseline and candidate
checked JS sibling images. It removes only their exact IO-main footer, exports
the existing pure preparation function and verifies every scalar/constructor
field using memoized pairs, including nested terms, source ranges and prepared
world fields. It also checks the world-prefix/book alias. Controls include the
authenticated full Base, empty/closed polymorphic prefixes, parse failure,
unbound-name checking failure and an open declaration. Full diagnostic strings
must match, not just success flags. Root executes it under the existing Node
adapter and primitive-equality sibling scope; this lane has not run the target.

### Project or reconstruct owned records once

`check/kernel.bend:kw_with_book` constructs a `KWorld` using three separate
accessors over the same shared world (`kw_memo`, `kw_fresh`, `kw_checked`). A
single direct match can carry those fields into the replacement world once.
Other reconstruction helpers such as `kw_restore_definition` similarly read
several fields of one `KChecking` through separate accessor calls.

These are concrete, small candidates for reducing retain/project/drop work
while preserving representation and semantics. They are not yet established
hotspots: upstream product flattening, inlining and demand analysis can already
remove accessor overhead. Inspect the recovered generated caller and compare
generated ownership operations before changing source. A retained-field change
must preserve all world fields, fresh/deferred state, order and first-error
behavior. It should not expand into a new typed graph or paired representation;
Phase80/84 already contain negative evidence for those broader approaches.

### Replace ownership-heavy eager choices with exclusive control flow

Many helpers build two thunk environments for `kc`/`nt_choose`. If both capture
a large immutable record, constructing the alternatives can retain it twice
before discarding the unchosen closure. A direct Bool match in a helper with
explicit threaded arguments expresses exclusive use without those environments.
The native observer repair is the correctness-critical instance; ordinary Data
captures are legal but can still cost time.

Only convert sites appearing in ownership-caller evidence. Check exact output
and error order, and compare generated C use counts so a source rearrangement
with unchanged native code does not consume another full-image build. This is a
general control-flow mechanism, not a blanket claim that every thunk is slow.

## Fast decision sequence

Use the existing linear native image for a Small COUNT1 diagnostic to validate
clock marks, stack recovery and output identity. Then collect a five-request
Lexer profile. Prioritize source changes separately for Base and request phases;
do not spend a 200 s compiler build on a change that only moves a handful of
samples. After the observer repair, generate a new table and profile successful
Map to avoid inferring its costs from a fail-stop. A useful candidate must reduce
whole declared phase time in a clean run and preserve exact C/diagnostic output.

Broader borrow-aware projection or ownership lowering may eventually be useful,
but altering the runtime's closure/task sharing rules is outside this lane and
would not solve the source's affine-continuation contract. The next experiment
should exploit measured caller sites, not disable the guard that exposed them.
