# Phase65 Base backend product contract

The next experiment should measure the cost of Base-owned annotation and local
call rows before adding another cached root. Both products fit existing
`KDef`/`KTerm` graphs, so the first diagnostic needs **no production transport
change**. Compiler algorithms, ownership decisions and semantic fact production
remain in Bend. This document records preparation/admission constraints and
host-side measurement support; it does not select a caching implementation.

## Current selected boundary

[Phase64's prepared artifact contract](../../docs/self_hosted/prepared-base-artifacts.md)
is the authority. The selected genuine B2 is
`b09fe54ad58d105d1c77ccb399f4076660d6109cf2a7f4b21e13933b89c22c2e`;
world version3 has `state,prefix,final,book,checked,seen,todos,checkedBound`.
The raw prefix, checked output, final declaration events and lookup context are
separate values. In particular, `world.checked` is the saved reverse checked
list, not automatically the completed backend input.

Frame4 has mandatory Base and optional prepared-state arenas. Every record is
validated and eagerly materialized. API bytes, Base bytes, canonical source
path, span/term ABI, interval and producer/version bind admission. The world
must share the exact admitted raw prefix and checker state objects. Successful
request/world coupling grants the private checked-context entry; an arbitrary
public book does not. Missing optional facts retain the ordinary path.

A data-only census of the selected genuine-B2 artifact finds:

| Segment | Bytes | New records | New strings |
| --- | ---: | ---: | ---: |
| Mandatory raw Base | 905,484 | 35,378 | 872 |
| Optional prepared state | 253,672 | 11,379 | 2 |
| Complete file, including header | 1,160,384 | 46,757 | 874 |

The prepared world's checked-list closure reaches 29,424 records; its raw
prefix reaches 35,378. These closures overlap extensively and are **not additive
storage costs**. Removing definition-value edges leaves 14,578 reachable records,
but earlier demand profiling showed that static exclusion potential did not
predict actual request savings. Do not revive lazy loading from this census.

The source/data-only tool is
[`inspect-frame.py`](../../selfhost/tools/performance/phase65/cache-contract/inspect-frame.py).
Its receipt is `selfhost/build/phase65/cache-contract/state09-frame4-census01.json`.
It reads the closed Phase64 artifact without modifying it and writes only a new
Phase65 receipt. It checks table geometry/digests for its census; the production
reader remains the admission validator. No compiler or Node target ran here.

## Candidate products and proof obligations

| Product | Feasible preparation | Required request work / remaining dependency |
| --- | --- | --- |
| Annotated Base definitions | Run the existing Bend annotation on the exact completed checked Base definitions, retaining body/type sharing. | Select by exact authenticated ownership and the actual stop set; preserve source order and annotation lookup semantics. |
| Local `JDCall` rows | Existing Bend `jd_calls_rows` produces per-definition edges, unknown-call bit and retained arity using `KDef` rows. | Rebuild selected membership, reverse edges, SCCs, bounce propagation and component order for this request. Preserve global budgets. |
| Per-definition layout dependencies | Potentially retain the result of the existing term traversal for a proved context-independent Base definition. | Keep runtime reachability, stop handling and the first open-array diagnostic request-local. Not yet proposed for implementation. |
| Rendered JavaScript / whole `JDPlan` | Already useful within the single immutable request that owns the current plan. | Depends on selected definitions, SCC/bounce decisions, exports and request context; do not persist across requests without a separate stronger proof. |

`ka_def` reconstructs annotation types through the immutable book, WNF and
substitution. Inspection found no direct fresh-bound query in `annotate.bend`;
`kw_initial` is constructed, but that alone does not establish dependence on the
global fresh counter. Closed, unchanged Base lookups may therefore be enough.
The discriminator must compare **exact annotation values**, including identifiers
and origins, between Base preparation and the actual successful request. A
hypothetical need for rebasing is not an observed result. If a mismatch appears,
keep the counterexample and identify its lookup or specialization cause.

Name membership alone is not a completed proof. The producer must distinguish:

- Original checked Base definitions from raw Base and from request-generated
  specializations, even when generated code originated in a Base template.
- Runtime definitions from native stops, absent bodies, foreigns and templates.
- Dependencies whose names are all in Base from dependencies whose *resolved
  definitions, constructors or native policy* can differ in the request context.

Reuse must not alter error or budget behavior. Current call analysis consumes a
4,096-definition budget, an 8,192-node budget per scanned body and a separate
4,194,304-edge budget during graph construction. Reused rows still consume their
original definition/edge charges; a local successful row is not permission to
skip global target validation or SCC refusal. Cached layout results cannot
suppress an error in a selected suffix or cause an error from unused Base code.

## Smallest diagnostic sequence

1. Attribute real annotation, call-row, layout and lowering work to exact Base
   names and actual source definitions. Counters are diagnostic; use a clean
   uninstrumented request for latency.
2. Recompute the candidate Base product using existing Bend functions and compare
   it against the corresponding actual request product. Include Numeric, Map,
   Lexer and one recursive/higher-order case; add synthetic suffix constructors,
   templates, high binder IDs, stop/native and rejection boundaries as needed.
3. Serialize the **actual** product through `encodeBaseArena`, with existing
   mandatory/prepared record interning as its base, and count marginal records,
   strings and bytes. All present graph families already fit this diagnostic.
   This establishes transport size only, not reusable semantics or speed.
4. Measure first-process additional read/hash/decode/admission separately, then
   the complete request with cached-product consumption. Preserve an ablation
   that uses the same artifact but discards the new product. Preparation and
   product generation remain outside the prepared-request clock and are reported
   separately.

The upper-bound saving is the removed Base work. The useful saving subtracts
extra eager decode/allocation, admission, selection/overlay, and any downstream
cost from changed object sharing or string representation. Added annotated bodies
could be expensive even when their encoded bytes are modest. No current profile
supports a numeric gain claim for this extension yet.

## If a product survives

Prefer a distinct private immutable backend-product envelope with an exact
producer/version and an explicit link to the admitted world. Keep source,
checker and backend capabilities separate. The existing API hash already binds
compiler source and policy; changed Base/path/ABI metadata must invalidate the
product along with its owning world. The host transports and validates schema,
identity and producer metadata; it does not calculate annotations, call edges,
closure proofs or validity summaries in JavaScript.

A new envelope type/root requires an explicit codec/ABI admission change. Frame4
currently expects four optional roots, so silently appending a fifth is not
backward compatible. Decide the minimal version/root layout only after measured
benefit; preserve old-frame reading, absent-state fallback and corrupt mandatory
refusal. Invalid product metadata should discard that capability, while malformed
optional graph bytes keep the current all-optional fallback contract. Test
same-process edits, wrong Base/API/path, uncoupled product/world roots, missing
and damaged optional state, and ordinary public API callers without private
permission. Semantic content still depends on the trusted bound Bend producer;
a checksum or U32 field is not a proof of its truth.

## Measurement-tool review

The Phase65 latency method and bindings factories were independently read and
the four materialized method derivations replayed byte-for-byte. All 16 initial
recipe input hashes matched. The additional historical workflow mapping is
restricted to the exact Phase64 emission and generator-attempt hashes plus the
same original/frozen canonical path and bytes; it does not weaken normal input
pinning. Clocks, selected-decoder frame1–4 admission, immutable audit imports and
resource guards are unchanged. The initial two-role baseline-four recipe uses
two rotated rounds; the three-round broad recipe is fully position-balanced
when used with its intended three roles. No target execution or candidate
selection was performed by this reviewer.

## H2 isolated deferred annotation transport

The later artifact discriminator justified a bounded implementation experiment,
not promotion. The host candidate is
[`base-annotations-v2.patch`](../../selfhost/tools/performance/phase65/cache-contract/base-annotations-v2.patch),
pinned by its [manifest](../../selfhost/tools/performance/phase65/cache-contract/base-annotations-v2.json).
It adds 78 driver lines; it adds no codec constructor, frame format or world
field. The separate Bend source candidate owns annotation production, the
generic minimum-work threshold of 64, the wanted decision and semantic admission.

`prepareBase()` explicitly prepares the optional artifact from the admitted
world3 through `base_annotation_prepare(world, 64)`. The new returned
`KBaseAnnotationState` has `keys` and `book`; those existing list/definition graph
types are serialized separately, so the new envelope does not enter the arena
schema. The host re-encodes the parent mandatory and prepared graphs outside the
request clock, requiring both exact segment digests before extending their node
numbering. It validates the resulting key and product arenas before publishing.

One sidecar lives in the exported `baseAnnotationDirectory`, the sibling
`build/typed/base-products` directory. Its basename replaces the parent cache's
`-frame4.json` with `-annotations64-v1.bin`. The first four little-endian bytes
give a JSON header length capped at 64 KiB. The header binds format/version,
producer, threshold, exact API/Base/path/interval/ABI identity, both parent arena
digests, a small independent key arena and its digest, and the product length and
digest. The remaining bytes form one product arena referring backwards into the
exact admitted parent graph. There is no executable JavaScript in the artifact.

The existing decoder retains its validated graph privately in a WeakMap keyed
by the world object. Every read still validates the ordinary mandatory cache
first. Only the actual successful owned prepared-world request can attempt
reuse. At annotation, the host reads the bounded header and keys, then asks Bend
`base_annotation_wanted(selected, stops, keys)`. If wanted, Bend's
`base_annotation_allowed(load, world)` verifies request eligibility. Only after
both checks does the host read, hash and fully validate the product arena, then
pass it to `annotate_selected_base` with the unchanged request context, selected
definitions and stops. The first experiment enables this only for direct JS.

Missing, malformed, stale or ineligible optional products retain ordinary
annotation. The optional reader has no cross-request result memo; persistent
inspectors therefore cannot retain a capability after product replacement or
deletion. Ordinary inspection never creates the sidecar, including its implicit
Base preparation path. Explicit preparation validates an existing sidecar or
rebuilds it. Keeping the parent graph arrays alive until annotation has a memory
cost; complete-request measurements must include this and the no-hit header work.

The source owner reviewed the four-API coupling and found no source-level
semantic blocker. Independent host boundary controls and a fresh latency method
must cover product identity, malformed data, optional fallback, private API
permission and source changes. The new method must pin sidecar bytes and
directory membership even for no-hit programs; the historical one-frame cache
inventory alone does not cover this new input. No host target or promotion is
claimed by this source-only implementation.

The first host patch remains preserved. Export admission rejected its initial
launch before compilation because the new export declaration tested module
presence without the factory's required source-text capability check. Version2
changes exactly that declaration to the admitted conditional; all runtime code
and the 78-line delta remain unchanged. The failed launch is not a compiler or
semantic test failure and establishes no runtime result.

Before consumption, independent source review of the new host controller found
two setup errors: its relocated project lacked the manifest read at driver
import, and it expected freezing from a no-memo cache read. Both were corrected
before execution. The reviewed controller
`controls/base-annotations-host-v1.mjs` has SHA
`a029d33ccd6c412fc7f6e87e890cb1ae98b95114586de35d70525bec9587645c`.
It uses actual admission/writer/reader functions and explicitly scopes its stub
producer to transport checks, including read-offset evidence that a miss or
refusal leaves the product body unread. Real semantic annotation and private
inspection routing require the separate compiler controller.

The measurement-method review caught another binding error before materializing
the successor: decoded cache metadata intentionally omits the two graph digests.
The corrected factory reads the actual frame header, verifies both segment
digests over their bytes, and binds sidecar identity to those values. Every
worker checks the sidecar's presence, inventory and hashes outside the measured
clock, including programs whose keys do not request it. These are source-review
results, not target pass or speed claims.

Root subsequently ran the [host boundary controller](../../selfhost/build/phase65/base-annotations-host-state08-01/report.json):
all 56 transport/admission checks passed. Actual State08 explicit preparation
also published the expected sidecar: 438,959 total bytes, including a 437,464-byte
product and 520-byte key arena. This establishes production of the bound
artifact, not successful semantic reuse or a net request speed gain.

The first owned semantic-control launch selected the raw bootstrap API instead
of the checked attempt's qualified derived B1. Its ordinary Lexer path reported
a stack error before entering world/context/annotation hooks. The failed
receipt is preserved; that run does not establish an H2 defect or its precise
stack cause. A separately reviewed successor binds the qualified API through
the equality derivation and parent identities, preserving the earlier semantic
assertions. Its runtime result is a separate gate.

## Same-B2 incremental artifact ablation

A separate [source-reviewed diagnostic](../../selfhost/tools/performance/phase65/cache-contract/annotation-ablation.derivation.json)
compared the same actual combined State09 B2 image, H6 helper, driver, runtime,
Base and mandatory frame with the exact prepared sidecar present or absent.
Preparation copied immutable projects and did not prime either clone afterwards.
Each worker verified full project membership and file hashes, including the
explicit presence or absence of the product directory, before and after the
request. The inherited clocks remained unchanged; complete emitted module
bytes had to match the pinned oracle after timing. This is a fresh-process,
warm-filesystem diagnostic, not an OS-cold benchmark or production qualification.

Two balanced rounds over three sources passed all 12 fresh workers in 36.70 s.
The [compact data-only analysis](evidence/base-annotations-incremental-b2.json)
binds the complete raw receipts and records every sample:

| Source | Sidecar absent, ms | Sidecar present, ms | First-request change |
| --- | ---: | ---: | ---: |
| Numeric recurrence | 191.316 | 190.427 | -0.46% |
| Map set operations | 985.535 | 934.946 | -5.13% |
| Map churn | 639.985 | 619.846 | -3.15% |

The equal-case geometric mean improved 2.93% for the compilation request and
3.40% for host import plus API loading plus the first request. Numeric has no
product hit; its sub-percent request change is noise. Both hit cases improved
in each round. Their median savings were 50.59 ms and 20.14 ms respectively.
Map churn's source uses Base map update/delete operations, and its pinned output
contains the retained put/pop/ins bodies; the diagnostic itself does not add
hook counters to clean timings.

This supports retaining the optional products as a modest incremental gain
alongside H6. Both roles retain the H2 compiler code and driver branch, so the
measurement does not equal comparison against complete H2 source removal.
Three targeted cases are also insufficient to claim a broad compiler ratio or
TypeScript parity. The approximately 439 KiB artifact and additional source
complexity remain costs to consider against the measured benefit.

## Exact standard-Base eligibility correction

A later correctness review identified a demand gap for arbitrary custom Base
content: preparing additional annotations may normalize a type that ordinary
checking did not need to normalize. Successful old checking alone therefore
cannot authorize this extra work for every custom Base.

The isolated [host v3 patch](../../selfhost/tools/performance/phase65/cache-contract/base-annotations-v3.patch)
adds five lines relative to v2: a documented exact standard-Base SHA-256 constant
and early guards at optional file admission and product preparation. The
qualified content hash is
`c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`.
The guard tests content identity, not the source path. A changed or custom Base
uses the ordinary annotation route before any optional file read, producer,
wanted or allowed call. Existing mandatory checking and all path/API/frame
identity rules remain in effect. Future Base updates disable products until
independently qualified. The Bend source, compiler images and arena schema are
unchanged; root owns applying and qualifying this correction.

The accompanying [H6 formatting recipe](../../selfhost/tools/performance/phase65/cache-contract/static-tags-format-v1.json)
removes two spaces from one otherwise empty line. Its recorded inverse restores
the exact tested helper bytes; it changes no JavaScript token or field order.
This isolated formatting derivative is not a new optimization result.
