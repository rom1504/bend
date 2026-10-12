# Native compilation: repeated preparation and candidate work

This source-only audit finds a small, low-complexity body-reuse change and two
larger opportunities to avoid repeated work. It does **not** establish a new
compiler speedup. The strongest easy candidate is to stop rescanning already
compacted request-owned bodies; the larger opportunity is to share runtime
reachability and erased bodies within one native request. Eager demand scans in
`nq_bind_choose` belong to the separate P70-004 lane.

Inputs are the unchanged Phase69 B1/B2 profiles in
[`compiler69-profile02-summary.json`](../../selfhost/build/phase70/compiler69-profile02-summary.json),
the [Phase68 occurrence-summary report](../phase68/occurrence-summary.md),
[local reuse report](../phase68/occurrence-reuse.md), and
[Phase69 implementation](../phase69/README.md). Raw and tools from those phases
were read only. All new methods and proposals are under
[`compiler-work/`](../../selfhost/tools/performance/phase70/compiler-work/).

## What the saved profiles permit us to claim

The [data-only reduction](../../selfhost/tools/performance/phase70/compiler-work/profile-work-v2.json)
reopens the four CPU profiles against the original summary's hashes, decodes
generated names, and measures unions of sampled stacks containing each function.
The [producer](../../selfhost/tools/performance/phase70/compiler-work/profile-work.py)
is also pinned. It runs Python on CPU0; no compiler, Node, Clang or native target
was executed. The earlier exploratory `profile-work-v1.json` remains preserved.

| Sampled stack union, ms | Numeric B2 | Array B2 | Lexer B2 | Numeric B1 |
| --- | ---: | ---: | ---: | ---: |
| Complete captured profile | 1,706.6 | 1,746.0 | 2,206.3 | 2,548.5 |
| `nc_erase` | 132.6 | 129.0 | 148.7 | not recovered |
| `nc_live_names` | 79.3 | 66.1 | 131.6 | not recovered |
| `nc_compact` | 17.1 | 17.3 | 20.3 | not recovered |
| `nc_compile_def` | 93.3 | 101.9 | 152.7 | 155.8 |
| `nf_candidate` | 126.9 | 113.4 | 173.5 | 222.0 |
| `nq_candidate` | 6.2 | 8.7 | 11.8 | 8.4 |
| `nf_retry` | 19.5 | 26.7 | 61.8 | 24.3 |
| `nq_signatures` | 32.4 | 43.7 | 44.6 | 56.0 |
| `nf_admit_pass` | 1.1 | 2.0 | 1.1 | 2.1 |
| `nf_worker_kinds` | 3.4 | 3.1 | 4.8 | 3.1 |

Rows overlap and must not be added. Missing B1 frames are not zero work:
trampolining/inlining loses attribution. These are sampled diagnostics, not clean
wall clocks, invocation counts, or a causal timing bound. In particular, the
137.6–210.3 ms `nf_finish_retry` row from the original summary includes final
rendering through `nf_finish_ready`; actual `nf_retry` stacks are much smaller.
Calling that entire parent row wasted retries would overstate the opportunity.

## Source pipeline and repeated work

The ordinary checked host path asks `nc_foreign_paths` to identify foreign
sources. That independently runs `nc_live_names`, which calls `nc_definition`
and erases ordinary bodies to discover runtime references. Later:

1. `nc_compile_checked` computes runtime names again for array/ownership
   certificates. It has no static-body facts yet.
2. After validation, `ns_compile` strips stale private payloads with `ns_source`,
   computes names again, and calls `ns_prepare`.
3. `ns_defs` erases, compacts and statically transforms each reachable ordinary
   body, saving it as a `NativeStaticBody` in the request-local cache. This already
   reuses erasure across later consumers: a proposal to add that cache anew
   would duplicate Phase69 functionality.
4. `nc_compile_def` retrieves each prepared body, **compacts it again**, scans
   references/fork facts, and emits the scheduler form.
5. `nf_finish_show` recomputes names and bangs on the prepared book, derives
   product signatures, then builds ordinary and product worker candidates.
   Both candidate builders **compact prepared bodies again**.
6. Admission reaches a fixed point. Nonadmitted ordinary candidates without
   lowering errors are rebuilt against product signatures filtered to admitted
   routes. A second admission pass can then rescue ordinary callers.
7. `nf_wrap_segments` substitutes admitted worker adapters into scheduler
   segments already constructed in step 4; final C rendering follows.

Current anchors: `book.bend` functions `nc_definition`, `nc_compile_def`,
`nc_live_names`, `nc_bangs_names`, `nc_foreign_paths`; `static.bend` functions
`ns_defs`, `ns_source`, `ns_compile`; `flat.bend` functions `nf_candidate`,
`nf_retry`, `nf_finish_show`; `product.bend` function `nq_candidate`.

## Ranked proposals and cheapest discriminators

The percentages below are investigation estimates for complete C requests,
not measured gains or additive promises. The ranking balances likely savings,
implementation size and semantic risk.

| Rank | Concrete change | Estimated request reduction | Implementation / bounded validation | Cheapest discriminator |
| --- | --- | --- | --- | --- |
| 1 | Reuse already compact `NativeStaticBody` at three entry builders | Usually 0–1%; likely below 0.5% on these B2 profiles | +6 Bend lines; one short helper/build/emission loop | Exact prepared term vs its second compaction, then complete C byte equality |
| 2 | Retry ordinary workers only when product-signature availability actually changes | 0–3%; corpus dependent | ~15–45 lines, 30–60 minutes including counters/controls | Count rejected product signatures and ordinary retries with unchanged signatures before changing policy |
| 3 | Share runtime names, erased bodies and bang facts within one validated native request | ~3–8% plausible; needs direct counters | ~80–180 lines, 2–4 hours including raw/cache/foreign gates | Count repeated `(request, definition, source identity)` erasures, separating pre/post preparation |
| 4 | Construct worker plans first and avoid scheduler bodies later replaced by adapters | ~3–8% plausible, cannot infer from all `nc_compile_def` time | ~150–300 lines, 3–6 hours; C shape can change | Count scheduler segments actually replaced and time only their generation |
| 5 | Reuse arity/type-telescope facts between product signatures and typed workers | ~0–2% initially | ~30–80 lines, 1–2 hours | Per-definition telescope visits; compare parameter/shape facts before any emission change |

P70-004 should be evaluated before pursuing ranks 3–5. Phase68 already showed
that removing repeated ownership traversal mattered more than renderer shortcuts.
This audit does not find evidence for another 2× gain in compaction or retries.

### 1. Fact-aware compact-body access: source proposal ready

[P70-005](../../experiments/phase70/P70-005-compact-body-reuse.md) was registered
before constructing the [patch](../../selfhost/tools/performance/phase70/compiler-work/compact-body-v1.patch).
The manifest pins all three baseline and proposed source files. Production was
not edited. The new accessor returns `dv(fact)` only for `NativeStaticBody`;
otherwise it evaluates exactly `nc_compact(nc_definition_plain(book,d,n))`.
The old `nc_definition` remains unchanged for reference/bang consumers.

The restricted source argument is in
[the proposal notes](../../selfhost/tools/performance/phase70/compiler-work/README.md).
Independent review agrees that the current fresh producer's transformations
cannot enable another literal or successor fold; this is not a claim that
arbitrary repeated compiler transformations are redundant. The
[helper controls](../../selfhost/tools/performance/phase70/compiler-work/compact-body-controls-v1.mjs)
are prepared but unexecuted. No candidate is qualified by the source review.

The directly observed `nc_compact` stacks under the three removable consumers
are only a few milliseconds per B2 profile; mandatory first compaction in
`ns_defs` occupies most recovered compaction samples. The six-line simplicity
benefit can justify the change, but it should not consume a large timing campaign
merely to resolve a sub-percent effect. Prefer exact-byte inheritance plus the
same controlled timing gate used for a larger compilation improvement.

### 2. NF retry: preserve the rescue mechanism, avoid unchanged work

`nf_retry` is necessary: a speculative product route may fail while the ordinary
callee is valid. Removing the retry pass can leave a whole chain of ordinary
callers on scheduler paths and regress generated-program execution.

The safest first improvement is a **global unchanged-signatures gate**. If
`nf_ready_signatures` would remove no `NQSig` entries, every retry uses the same
available product information. Keep all candidates and the already fixed-point
ready set; rebuilding identical bodies cannot admit another worker. Detect this
while traversing the existing signature list, excluding the expected `BookCache`
wrapper removal. Do not use list size alone when duplicate/context facts matter.

A narrower per-worker gate might compare dependencies with removed product
routes, but it needs a stronger proof. `nq_call_shape` can consult a signature to
choose result transport before final call-edge collection, so `nc_calls(code)`
must not be assumed to record every queried fact. If that proof is awkward,
record a tiny "used speculative product information" bit during existing
lowering, or stop at the global gate.

The first discriminator needs only diagnostic counts: initial ordinary/product
candidates, lowering failures, admitted names, dropped signatures, retries, and
retried code/edges equal to their old values. Include a rejected product route
with a recoverable ordinary caller, a dependency chain rescued on second
admission, an ordinary recursive worker, bangs, foreign calls, and already
admitted product workers. Existing errors and final admitted workers must agree.

### 3. Request-owned preparation instead of repeated erasure

Within `ns_compile`, a compact private plan can carry names/bangs into final
worker planning and preserve ordering; that is a smaller first slice than
changing the host API. It avoids the final runtime closure/bang rediscovery but
leaves the larger pre-preparation erasures intact.

The larger extension should produce runtime reachability together with erased
bodies once, then let static preparation consume those bodies. Foreign telescopes
depend on fresh IDs, so cache only ordinary source erasure or keep their exact
current fallback. Intrinsic/native facts, source lookup identity and reachability
order must remain unchanged. Carry source closure, post-compaction emission
closure and prepared body facts separately: malformed raw terms can lose
children during literal folding, so these are not automatically the same graph.

Moving this preparation earlier across `nc_foreign_paths` changes a host/native
boundary and validation/error order. First use the existing request memo identity
or an explicitly bound plan; do not trust a user-supplied `BookCache` marker.
Custom Base, changed imports, forged/stale facts, foreign requests, dead bangs,
missing definitions and raw first-error behavior are required controls.

### 4. Avoid scheduler emission that adapters supersede

`nc_compile_def` and worker generation are not simple duplicate functions: their
destinations, continuations, errors and admission rules differ. The valid idea is
to select the worker plan before expensive scheduler body construction, then
emit only the necessary adapter for a proved admitted worker. Preserve generic
fallbacks, closure entry segments, bang scheduling, device paths and first-error
selection. Any changed C ordering/segment numbering needs fresh runtime gates;
this is not suitable for the cheap exact-C-only phase.

### 5. Telescope reuse and rejected distractions

`nq_signature_user` computes native/live arity and layout telescopes;
`nf_candidate` repeats arity, while `nf_worker_kinds` traverses types again for
typed parameters. One definition plan could retain these results. However,
worker kinds account for only 3–5 recovered B2 milliseconds, so implementing a
general type-fact cache before counting the exact duplicated visits is premature.
Likewise `nf_admit_pass` is only about 1–2 ms: replacing it with a sophisticated
graph algorithm is not supported by these profiles.

## Handoff and limits

This lane produced source proposals, controls and a hash-verified data reduction.
It executed no compiler or benchmark, changed no production code, and made no
commits. Root owns candidate integration and the serialized guarded CPU3 lane.
Timing gains, emitted-C identity and broader correctness remain unmeasured until
those gates run. New observer code may change the cost distribution; profile the
selected integrated compiler separately rather than mixing Phase69 and Phase70
stack samples.
