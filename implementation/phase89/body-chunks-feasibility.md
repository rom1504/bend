# Deferred native body composition: bounded source audit

Initial status: read-only feasibility audit. The later isolated prototype and
retained source-check rejection are recorded below. This lane made no
production, upstream, installed-image or target-execution changes. It preserves
the separately frozen owned match candidate and its source identities.

The root investigator reports 26,639,166 String-append characters and roughly
72 million allocations per Map request for roughly 895 KB of final C. Those
whole-request counts motivate this change; they do **not** establish how much
of either count belongs to `NC_Code.body`. Characters and output bytes are
different units. The diagnostic below must measure the attributable part.

## Smallest coherent representation change

Replace only `NC_Code.body: String` with an ordered, shareable Data tree:
`Empty | Leaf(String) | Join(left, right)`. Keep `N_Segment.body`, `N_Emitted.code`,
and the public C output as String. A join preserves the exact left-to-right
order; it does not evaluate or reorder compiler operations. Existing short
String-producing helpers become leaves. Child bodies remain trees throughout
match, let, pattern, observer, and parallel composition.

Use a body/tree accessor in composers and a visibly separate render operation
at final boundaries. Keeping the old String-valued accessor in composers would
silently reproduce the original copying. Do not use function-valued difference
lists: the native closure-sharing failure from Phase87 is directly relevant.

Flatten iteratively with an explicit Data stack, visiting right children before
left children and prepending each leaf to the accumulated suffix. Thus every
leaf is on the left of String append once per materialization. Do not append
the growing accumulator to each leaf, recursively flatten child trees before
joining them, or build chunk lists by repeatedly appending whole child lists.
The final segment renderer still indents and joins strings as today; that is
bounded linear work outside this first change.

## Exact scope

A static source inventory of the active modules, before the isolated owned
match patch, finds 29 `nc_body` call sites, 35 `NC_Code` construction sites and
9 direct patterns, spread over 43 definitions in 10 modules. These are source
inventory counts, not runtime frequencies. Most constructors merely wrap a
String leaf; unchanged-body patterns carry the tree through.

| Module | Definitions mentioning those interfaces |
| --- | ---: |
| bridge | 14 |
| direct | 4 |
| flat | 5 |
| product | 5 |
| pattern | 2 |
| word-pattern | 2 |
| parallel | 2 |
| book | 3 |
| observer-emitter | 4 |
| observer-adapter | 2 |

The eight String boundaries are `nc_let_cut`, `nc_lambda`, `nd_join`,
`nc_children`, `nc_parallel_finish`, `nc_append_book`, `nf_bodies`, and
`nq_wrap_segment`. Several functions both finalize one child into a segment and
carry another child onward: render **only** the finalized child. In particular,
`nd_join` must carry the base body unchanged. `nc_append_book` must not render an
omitted factory, and `nf_bodies` must not render an unadmitted worker.

Only two body inspections require special treatment:

- `nf_inline` checks `String.length(body) <= 4096`, from both prototype and body
  emission. Use a bounded tree/leaf traversal that stops after 4097 Bend
  characters. Preserve code-point semantics, not UTF-8 bytes or UTF-16 units.
  No full rendering or unbounded Nat length is necessary. An eager cached
  length on every leaf adds work and is not needed for the first prototype.
- `nc_compile_kept` checks whether the body equals `""`. Normalize empty leaves
  and joins, so Empty is an exact constant-time predicate. If joins are left
  unnormalized, an Empty-tag-only test is incorrect.

The existing native text helper `nt_text_finish` already follows the safe
right-suffix accumulation principle. A tree stack extends this principle to
nested bodies; it is not a new output language or optimization IR.

## Invariants and ownership hazards

Keep lowering calls in their current order, including miss lowering after an
errored hit, and retain exact fresh values, first-error priority, segment order,
call lists, guards, whitespace and newlines. Changing the body representation
must not become a shortcut that suppresses work or changes diagnostics.

Carry forward the owned match candidate's consume-once destructuring. Repeated
whole-code projections can retain and later destroy the tree just as they did
strings. Avoid expanding this into an unrelated all-composer ownership rewrite
before the representation discriminator. Ordinary Data sharing is supported;
function-valued closure nodes are not an acceptable substitute. Trees also add
node allocations and destruction, and rejected workers still build bodies.
Deep skewed trees need an explicit traversal stack, including for length checks.

## Fast discriminator and bounds

First check pure rendering controls for ordered joins, empty normalization,
shared subtrees, deeply skewed trees, and Unicode at lengths 4095, 4096, 4097.
Then adapt the existing 19 composition and nine full-lowering controls to
compare the **rendered complete NC_Code product** against baseline, including
segments, fresh, error and calls; the raw internal tree is intentionally not
the same product representation. Run checked JS and native controls.

Next use Map, a nested-match/let case and a shallow case in the same native
request harness. Require exact C and record append characters, allocation
count, request time and peak memory, including final flattening inside the
same timing boundary. Compare to the owned-only derivative so the two changes
remain separable. The compelling discriminator is reduced dynamic append
work on nested bodies without replacing it with similar tree-allocation work.

This is approximately 40–45 definitions to review plus a small tree helper
API, not a two-function patch. A reasonable planning allowance is 2–4 hours
for a coherent prototype and focused controls; full-image builds and release
qualification are additional. No measured speed forecast exists yet. Even
perfect removal of internal-body copying leaves leaf construction, discarded
candidates, semantic lowering, final output scans and allocator behavior.

## Isolated prototype and first source-check result

The complete body-only prototype is now retained under
`selfhost/tools/performance/phase89/chunks-v2/`. It transports 35 construction
sites in ten frozen modules, adds 79 physical lines relative to the owned-match
baseline, replaces 34 declarations and adds 11 in the full native derivative.
The difference from the 43-definition inventory above is that pure field
forwarding/accessors other than body need no source change. Only eight
String-valued body calls remain, exactly the eight listed boundary functions.

The existing `JDText` representation in `back/js/direct/transport.bend` already
provides an ordered Data tree and right-first iterative renderer. The native
prototype reuses that traversal design with a smaller native type, avoiding
JS marker notes, safety flags and eager cached-length scans. This source audit
found no additional body-text consumer beyond length and emptiness.

V1 is preserved under `chunks/`. The root-run small checked acquisition failed
before emission: the capped-length worker matched `current` after an earlier
`todo` binder and then tried to match `todo`. Bend rejects that binder order.
`selfhost/build/phase89/chunks-control01/report.json` records the exact error.
A premature subsequent JS launch also failed because no JS existed; it is a
separate harness sequencing failure. V2 only reorders the helper's parameters
to `(current, todo, remaining)` and all call sites; no semantics or scope change.

Frozen V2 identities:

- Standalone 19-case source: `d35ee61e6c281eadcfba36f5edc8c869f2e8d2082a3dc569b3d4d8f6b0fd8f93`.
- Body-only patch: `0f0e145153830f5ebdee892a336836060045101a8c30fd36447b882f42d5e0d8`.
- Full native derivative: `670204c4898753c29b648ca77cc19c2b3ad33764bfdf2f55598e8957a2310751`,
  1,754,580 bytes. Reverse declaration edits recover the entire frozen owned
  parent, including prepared Base/cache, native equality adaptation and IO.

Python tool syntax, frozen module hashes and the eight-boundary inventory were
checked offline. Root subsequently completed the following guarded validation
and clean comparisons. These are experimental results, not promotion.

## Completed V2 gates and image identity

The [tree controls](../../selfhost/build/phase89/chunks-control02-products.json)
pass all 19 cases and 114 independent assertions in checked raw JS/native.
Their complete 99,759-byte outputs match exactly, SHA256
`f5d914400998afe1775f6044514e312ec3b2e3a3895255216481a747d4cd9c33`.
The [nine actual lowering controls](../../selfhost/build/phase89/chunks-lower02-products.json)
match owned-baseline JS, chunk-candidate JS and native across rendered body,
segments, fresh counter, first error and calls. Their output is 2,614 bytes,
SHA256 `ec2caa0d4a860abfc62181e8ac8569b6b59f97575c5d7e4ed4a45272788889d3`.

The complete compiler source passes checked upstream acquisition at pinned
`059266225b77c8ca256ac6b25ee5c21449bab151`; see the
[acquisition receipt](../../selfhost/build/phase89/chunks02/report.json) and
[O2 build receipt](../../selfhost/build/phase89/compiler-chunks02.build.json).
The source identity above remains unchanged. Generated compiler C is
`08fb3bda86dbcaae55c5cd2e2252359805bd27e11c160694728af301226ed1b0`
(17,725,963 bytes); native executable is
`aaf696033f50228e1157b84bfa91605dca6cd1c9efab6c2ab1e48f1f1712540f`
(9,948,664 bytes). Acquisition takes 78.58 s at 1.19 GiB peak process-tree RSS;
the guarded Clang O2 build takes 176.86 s at 4.00 GiB. Both exit successfully.
These build clocks are costs of producing the experimental B1, not benchmark
request times or native B2 evidence.

## Clean request comparisons

The [cold screen](../../selfhost/build/phase89/chunks-cold01/report.json) checks
three live candidate requests against independent B2 C, then runs two fresh
processes per role/source with the same experimentally authenticated prepared
Base. All 39 C outputs match. The public prepared-cache consumer admission is
unchanged. The six-source medians below measure request compilation to C and
exclude separately reported Base/runtime preparation; these are not generated
program execution clocks.

| Source | Phase88 native02 ms | Owned-only ms | Owned + chunks ms |
| --- | ---: | ---: | ---: |
| Small | 56.5 | 58.0 | 58.0 |
| Numeric | 99.5 | 100.0 | 99.5 |
| Lexer | 465.0 | 443.0 | 442.5 |
| Map | 2,130.5 | 1,755.0 | 1,534.0 |
| Functions65 | 227.5 | 242.5 | 243.5 |
| Unicode | 57.0 | 57.5 | 59.5 |

Map improves 28.00% against native02 and another 12.59% against owned-only.
The unweighted six-source geometric mean of median request ratios is 0.9606
versus native02 and 0.9831 versus owned-only: 3.94% and 1.69% lower time. Do not
generalize the Map gain to every program. Small cases give no clear gain;
Functions65's cold median is 7.03% higher than native02, with only two samples.

The [reused-process screen](../../selfhost/build/phase89/chunks-warm01/report.json)
adds 90 exact C outputs: one process per role/source, five successive requests.
Its three live-gate rows are references to the cold screen, **not** three new
executions. Thus these screens contain 129 distinct checked C outputs together.

| Map request | Native02 ms | Owned-only ms | Owned + chunks ms |
| --- | ---: | ---: | ---: |
| 1 | 2,094 | 1,677 | 1,549 |
| 2 | 2,227 | 1,749 | 1,630 |
| 3 | 2,424 | 1,845 | 1,673 |
| 4 | 2,581 | 1,962 | 1,754 |
| 5 | 2,802 | 2,053 | 1,858 |

The fifth Map request is 33.69% lower than native02 and 9.50% lower than
owned-only. Its progressive slowdown remains: 1,549→1,858 ms. Functions65 is
similar in this sequence (native02 227→234 ms, owned 230→234 ms, chunks
231→235 ms). Lexer also remains similar (468→520, 481→519, 474→525 ms).
One sequence is neither a steady-state estimate nor evidence about the cause of
timing growth. The prior constant-work result belongs to the native02 counter
image; it must not be silently transferred to the new chunk image.

No public compiler/image/cache promotion follows from this report. Exact C
preserves generated-code identity on these checked sources; broader conformance,
JS-host integration and native self-reproduction remain separate gates.

## Remaining ownership mechanisms to measure

The following are specific source/generated-C observations, not new architecture
proposals or measured speed forecasts. All generated line references bind to the
`chunks02/compiler.c` hash above.

1. **Error selection still transports entire products.** `nc_first_error`
   receives two NC_Code values to return one String. Its generated
   `FID_NC_FIRST_ERROR` at line 317839 retains the first product's four reference
   fields, then allocates two five-field closure environments carrying the two
   complete products. The selected closure projects error; the other is dropped.
   This is a concrete small candidate for an error-field-only dispatcher, with
   the same priority and no change to child lowering. Count dynamic entries and
   attribute keep/drop/allocation work to this family before estimating gain.
   Existing first/both-error controls are the fast correctness discriminator.

2. **Let and specialized pattern composers still retain child fields.**
   `nf_bind_boxed`, `nq_bind`, `np_emit_join`, `nw_emit_join`,
   `no_emit_match_layout`, `nd_join` and `nc_parallel_finish` repeatedly project
   their child products. In generated `NF_BIND_BOXED_K8362` (line 234074), eight
   reference fields are retained before `NC_FIRST_ERROR`. `K8365` (line 234311)
   retains value/rest fields again for body-tree projection, then projects
   segments/fresh and explicitly sinks retained value fields. The current
   `spin_143` body accessor (line 18544) sinks the three nonbody reference fields;
   `spin_141` (line 18504) projects calls while sinking body/segments/error.
   This confirms the source pattern survives generation, but not its frequency
   or cost. Rank composers by dynamic calls and sampled caller-attributed
   destruction; apply the already proven consume-once pattern only where it pays.

3. **Tree normalization has constant per-join sharing work.** `nct_cat` retains
   each nonempty argument for its empty predicate. In generated `spin_144` and
   `spin_146`, those retains feed `spin_145`, which consumes the node, sinks its
   one/two child fields and returns the tag predicate. Count joins, empty arms
   and shared constructor takes to test whether this is material. Do not replace
   it speculatively: a destructive pattern rewrite might reconstruct roots and
   add allocations instead. The 19 existing tree controls directly cover this
   helper's semantics if a small alternative becomes justified.

4. **Inline eligibility checks repeat but are already capped.** `nf_prototypes`
   and `nf_bodies` each call `nf_inline` on admitted workers. `NF_BODIES_C16730`
   (line 444341) retains four code reference fields across the predicate before
   final body emission. Count actual visited characters and admitted worker
   sizes before considering a locally shared decision. No global cache or eager
   leaf-length field is justified by this source observation alone.

The renderer itself does not exhibit the old growing-prefix operation: its
`FID_NCT_RENDER_WORK` (line 353029) passes only each leaf as String.append's left
operand and carries the suffix on the right. Its join arm can reuse consumed
worklist and tree-node slots for its two next worklist cells. Similarly,
`nct_leaf` can reuse the consumed String head slot. Therefore counting source
constructors alone would overstate their extra allocation cost. Measure actual
allocations/refcounts, not an assumed allocation per reconstructed constructor.
