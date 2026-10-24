# Constructor ownership as a prepared semantic fact

Status: isolated source prototype; source checking, all 29 finite controls and
18 complete frozen QBE comparisons pass. The hosted performance screen is mixed;
**no default integration or native speed claim** is justified. Parent is frozen Phase134 session source04
`1cadf44f…aea7be45`, checked by `p134-session-api02`; this lane does not alter it.

The complete private-candidate cache is not yet a justified small change.
`p113pl_candidates` consumes prepared bodies, bang/arity admission, signatures,
worker kinds, constructor/layout information, type normalization and several
cross-function optimizations. A source-body or Ref-only key misses dependencies.

A much smaller measured opportunity is `nc_ctor_owned`: it repeatedly scans the
whole book, then searches each ADT's children. Phase131's full-source active
context profile attributed7.48% to this query. That is an old workload-specific
ceiling, **not** a promised gain or a measurement of Phase135. Hosted raw candidate
preparation previously accounted for9.0%/13.3%/25.9% of Lexer/Closures/Map backend
time; those proportions neither isolate ownership queries nor establish native
self-build shares.

## Exact fact and reuse contract

The semantic key is the ordered list of top-level ADTs, their `db` flags, and
each ordered direct child's exact name and whether its kind is `Ctr`. Other
definition bodies, constructor field types, fresh counters and static offsets
are not read by the original ownership query and are deliberately excluded.
This key is sufficient only for **this Boolean query**, not for layout or general
candidate lowering.

This distinction matters for the next incremental step. The current candidate
path also reads the complete signature of a callee, missing/admission decisions,
prepared callee bodies used for inlining or fusion, constructor ownership and
layout, native/foreign/bang flags, and worker kinds derived from types.
`p113pl_flat_entry` obtains its fresh counter and result shape from the signature;
static references already contain IDs assigned by preparation. An unchanged
owner body does not imply unchanged facts at any of these boundaries. Reusing
the raw candidate solely by source body or a list of present `Ref` names could
therefore reuse stale rejection decisions, representation choices or IDs. The
ownership table below is deliberately a much narrower exact fact.

The builder preserves:

- The first matching ADT, including an owned=False answer that blocks later True.
- The first direct child of each name. A non-Ctr child shadows a later Ctr in
  that ADT, but does not block a later ADT's matching constructor.
- Exact names, including hash collisions and Unicode; hashes are indices, not
  identity proofs.
- Absent names=False, ignored non-ADT entries and ignored nested children.

`lookup` treats a child `BookCache` specially. Such rows are conservatively
refused rather than assuming their enumerable children describe that lookup.
An invalid summary uses the exact copied legacy query. No cached-child book is
silently projected into an incomplete index.

Across requests, `p135co_reuse` recomputes this small key and compares it exactly
with an actual prior cache from the same producer. A hit reuses the ownership
index, not the candidate IR or its verification. A cold request still pays to
build the index once. Most potential saving is eliminating repeated queries
inside a request; avoiding the next index build is a separate, likely small
incremental effect. Both must be charged and reported separately.

The cache and attached metadata are trusted internal products. Forging a valid
cache can change answers; the data type is not an authenticated certificate.
No external serialization, persistent cache or cross-producer reuse is exposed.

## Late-only integration and limitations

`ownership-request-v01.bend` prepares the fact after `p112s_prepare`, before
generic/private lowering. It preserves the original `NR_Request.source`, compile
admission and all existing verifier/proof declarations. The sidecar is placed
under the existing `NativeCtorIndex`; its original constructor index remains
first, and unknown trailing context fields survive. Ordinary books without the
sidecar use the legacy query.

The global query overlay adds metadata lookup cost before fallback. Therefore
this source is an isolated experiment, **not** an automatic improvement to the
ordinary route. Compare against the unchanged parent API as well as the overlay
without preparation. The latter alone would hide the wrapper's overhead.

The late insertion misses earlier uses during `nr_walk` erasure and
`nc_constructors(source,source)`. The old active-context profile does not locate
their inclusive callers, so late caller coverage is unknown. An earlier adapter
at `nr_prepare_annotated` might cover them, but changes the private metadata of
`NR_Request.source`. It is deliberately **not implemented or selected** before
the small correctness and coverage tests justify the additional boundary.
Source checking must still consume the original book and preserve its verdict.

## Frozen source and planned checks

Source preparation is metadata-only and has run:

```sh
python3 selfhost/tools/performance/phase135/preparation/prepare.py \
  --out selfhost/build/phase135/ownership-source01
```

The source is `6dbd5ad7dc7022c683a4c507442acd56d9938b83dfcb0d2aff037a800e62c8c9`.
Exactly one original declaration is overridden: `nc_ctor_owned`; the request
entry, source checker, admission, final verifiers and proof bodies remain exact.
The29 finite controls include real FNV collision names `costarring`/`liquid`,
BMP/astral Unicode, duplicate names, non-Ctr shadowing, owned=False ordering,
cached-child refusal, unknown context, repeated attachment, body-edit hits and
ownership/order invalidation. The independent oracle is the copied legacy
linear query, plus explicit expected answers for adversarial fixtures.

The root executed the following checked-API and finite commands. Receipts are
`selfhost/build/phase111/p135-ownership-api01/report.json` and
`selfhost/build/phase135/ownership-finite01/report.json` (29/29). The API took
approximately15.3s; the finite guard took2.06s. No native image was built:

```sh
python3 selfhost/tools/performance/phase131/native/check-guard.py \
  --out selfhost/build/phase135/ownership-api-guard01 --seconds 90 -- \
  python3 -B selfhost/tools/performance/phase111/check-api.py \
  --source selfhost/build/phase135/ownership-source01/compiler.bend \
  --out selfhost/build/phase111/p135-ownership-api01 \
  p88_cache_prepare p86_plan p111_runtime_admission p111_emit_admitted \
  p135co_emit p135co_lower_request p135co_empty p135co_controls \
  p135co_prepare_book p135co_rows p135co_legacy p135co_owned p135co_reuse p135co_query

python3 selfhost/tools/performance/phase131/native/check-guard.py \
  --out selfhost/build/phase135/ownership-finite-guard01 --seconds 30 -- \
  node selfhost/tools/performance/phase135/preparation/finite-v01.mjs \
  selfhost/build/phase111/p135-ownership-api01/report.json \
  selfhost/build/phase135/ownership-finite01 '{"p135co_controls":29}'
```

The completed comparison covers all three frozen small requests from
`selfhost/build/phase134/reference03.json`: unchanged parent API ordinary output,
overlay ordinary output, and overlay `p135co_emit` with empty/retained cache.
All 18 complete QBE products equal their frozen oracle. The paired geometric
ratios below use both execution orders; lower is faster:

| Workload | Indexed / parent backend | Indexed / wrapper backend | Indexed / parent frontend+backend |
|---|---:|---:|---:|
| Lexer | 0.865× | 0.875× | 0.853× |
| Closures | 1.215× | 1.473× | 1.196× |
| Map churn | 0.929× | 1.065× | 0.921× |

Lexer improved against both controls in both observations. Closures and Map
lost to the same wrapper in both orders. Map's indexed/parent backend ratio
reversed from 1.095× to 0.788×; its mean alone would give a misleading positive
signal. These are only two hosted observations with JIT/GC variance, and the
first indexed round builds the cache while the second reuses it. Execution
order and cache state therefore cannot be separated. No native improvement,
cross-family aggregate gain or real-edit acceleration follows from this screen.
The repeated source is identical; the finite body-edit/invalidation controls
are separate correctness evidence.

The screen took 90.824 s guarded and 954,867,712 peak RSS bytes. Exact receipts:
`selfhost/build/phase135/ownership-compare01/report.json` and its adjacent
`ownership-compare-guard01/process.json`. Reproducible paired derivation and a
concise result are in `implementation/phase135/preparation/{summary.json,README.md}`;
`summarize-v01.py` reads completed metadata only. The candidate stays unselected.

For a full compiler-source test, first collect the real checked book's ADT key
and query answers using this small API; do not run another native acquisition to
discover a basic key mistake. If the late path has no net gain, retain the
negative result and investigate caller coverage before any earlier adapter or
full self-hosting campaign. The existing Phase135 native session remains the
independent real-edit baseline.

## Native stage diagnostic: checked composition and full-source observation

The full compiler-source session reused 1,387/1,507 inline and range units, but
its A and edited B requests took 362.510 s and 374.922 s. Both 107 MB outputs
matched their independent oracles. This establishes full-scale correctness of
that reuse; it does not establish a speedup, nor a cache regression against an
uncached B. The existing profiles do not assign the uncached work to stages.

`stages-v02.bend` therefore adds four coarse intervals only to the experimental
framed mode. It replaces `p135ms_prepared`, retains the ordinary request route,
and calls the existing stage implementations and independent final verifier:

| Reported interval | Work completed before its ending clock |
|---|---|
| `frontend_ms` | `p86_plan`, through checked annotation and `nr_prepare_annotated` |
| `lowering_ms` | Runtime/compile admission, certificate, static and constructor preparation, generic code, raw candidates and initial candidate closure |
| `optimize_ms` | Opening verification, cached inline/range processing, final verification, borrowed-helper closure and sealed emission plan |
| `render_ms` | Render context, text, file writes/close and downstream FIFO backpressure |

The source audit confirms ordered native evaluation: constructor/call arguments
become explicit lets (`nc_sequence`, `nd_bind_value`), and generic continuation
cuts evaluate their value before resuming its consumer. The frontend clock is
inside the `P86PlanReady` branch; the lowering clock additionally matches the
actual `P128RawLowering`; the optimization clock matches `P134UEmission`.
These records contain evaluated data, not promises for those computations.
Rendering is intentionally deferred by `P134Planned` and starts in the writer.
No extra deep traversal is used to force a stage. The intervals still include
ownership cleanup and orchestration costs; they are not pure algorithm self-times.
`IO.now` returns monotonic milliseconds in the pinned runtime.

The new composition has passed a checked-API bridge against the unchanged
`p134ns_planned`, including real Lexer and Closures edits. A outputs equal their
frozen QBE; B outputs equal independent fresh compilation; both routes return
identical complete caches and statistics. Three error/admission short circuits
also match. The bridge took 28.50 s internally (29.44 s guarded) and used about
490 MiB peak RSS. The surrounding framed candidate passed all 121 finite
controls. The subsequent native framed experiment also completed; its exact
current outputs and machine consumers are reported separately in
`selfhost/build/phase135/machine-session01/report.json`.

- Checked framed source: `selfhost/build/phase135/machine-source02/compiler.bend`,
  SHA256 `391a6f2dde2ef960a2d8b33a3100a0d9ba53ff68848a2279d502f7858019091c`.
- Checked API: `selfhost/build/phase111/p135-machine-api02/report.json`.
- Pure bridge: `selfhost/build/phase135/stage-bridge01/report.json`.
- Finite controls: `selfhost/build/phase135/machine-finite02/report.json`.
- Reproducer: `stage-bridge-v01.mjs`; detailed source audit and measurement limits:
  [native-stage-audit.md](native-stage-audit.md).

The ownership prototype is not included in that framed source. The separate
native edited B request took 378.296 s: frontend 175.080 s, lowering 62.179 s,
optimization 68.360 s, rendering 72.677 s. The late attachment misses the 46.3%
spent before lowering, as well as some initial constructor preparation. These
coarse totals do not measure which stage owns the earlier ownership-query
samples. The old 7.48% ownership context share includes 3.97% of all samples in
destruction/reclamation and 0.73% in borrowed String equality; it is not an
additional gain on top of those costs. No native ownership candidate was built
or adopted, and the hosted screen does not justify one without a better
coverage and profitability discriminator.
