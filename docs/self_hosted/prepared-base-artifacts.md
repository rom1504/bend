# Prepared Base artifacts

**Phase65 State10 is installed and verified.** The first sections describe
retained Phase64 mechanisms; the [Phase65 additions](#phase65-selected-integration-candidate)
appear below. The [Phase65 results](../../implementation/phase65/state10-results.md),
[compiler qualification](../../implementation/phase65/evidence/state10-qualification.json)
and [release verification](../../implementation/phase65/evidence/state10-release.json)
keep genuine-B2 measurement and packaged checked-B1 release distinct. The
[request pipeline](compiler-request-pipeline.md) describes the surrounding compiler.

## Compiler work and host transport

Parsing, checking, freshness, TODO counting, specialization, context construction
and code generation remain implemented in Bend. The host reads files, binds
cache identities and transports the resulting immutable ADT graph. Frame4 changes
that transport; it does not implement a checker or generate semantic facts in JS.

The Bend producer
[`base_prefix_world_prepare`](../../selfhost/src/check/prefix-state.bend)
retains the already prepared Base world and two additional facts:

| Fact | Exact producer input | Consumer |
| --- | --- | --- |
| `todos` | Final **original** Base declaration events, including nested constructors, open laws and holes | Successful program completion adds the count from final original suffix events. |
| `checkedBound` | `norm_max_book(kw_checked(world))`, the actual checked Base output | Backend context construction combines it with the maximum in the actual assembled suffix. |

Neither fact is guessed from the raw source maximum or assumed to be zero.
Checking can introduce identifiers, so the checked-output bound is distinct from
the raw prefix bound. Counting original declarations preserves the existing TODO
contract even when elaboration rewrites a body. Suffix counting still happens
only after successful checking; checker errors retain precedence.

## Coupling and fallback

The host admits prepared-world **version3**, producer `base_prefix_world_prepare`,
only with valid U32 facts and the same decoded objects:
`world.prefix === cached.book` and
`world.state === cached.checkedPrefixState`. The state must itself pass its
producer/version/digest admission. The native loader's actual leading Base seed
and produced suffix supply the private source provenance.

Bend rechecks prefix/suffix eligibility, including name/constructor separation and
freshness bounds. Under that admitted partition, finalizing suffix declarations
cannot replace a Base event, making the TODO counts additive. Failed eligibility
uses ordinary checking and completion.

`book_context_world` is private to the successful result from that same driver
request. It checks eligibility again before dropping the known checked-prefix
list cells and scanning only the remaining output terms for their maximum ID.
Checking only prepends to the saved reverse checked list; assembling reverses
that list and therefore preserves the checked prefix. This is the invariant
behind the count-based split. An unrelated public book does not acquire this
permission. Public `book_context` and ordinary checking retain their full paths.

## Frame4 layout and validation

[`base-cache-graph.mjs`](../../selfhost/tools/base-cache-graph.mjs) shares one
constructor schema and exact record interning between JSON frame3 and indexed
frame4. Each frame has a JSON header and two independently hashed segments:
mandatory raw Base, followed by optional checked/fresh/world/frontend state.
The optional graph can reference mandatory nodes and strings, preserving sharing
and the object identity required above.

Frame4 segments contain a fixed header, root IDs, byte constructor tags, U32
record offsets and fields, string offsets, and UTF16LE string data. Strings retain
JavaScript code units; String literal payloads additionally retain the existing
Unicode-scalar validation. The `.json` filename is historical: a frame4 payload
is binary and must go through `decodeBaseCacheFrame`.

Admission validates **every record eagerly**, including unused records: field
counts, scalar and Boolean domains, source intervals, typed backward references,
roots, lengths, offsets, padding and limits. The arena writer rejects noncanonical
unsigned values before interning, including negative zero. The reader eagerly
materializes the complete ordinary ADT graph; it is not lazy loading or a new
compiler IR.

Mandatory graph corruption cannot grant a usable cached book. An invalid optional
hash or graph discards all optional roots and retains the valid Base for fallback.
Individual capability/version failures also remove the corresponding accelerator.
Old world layouts remain readable, but missing `todos` or `checkedBound` cannot
grant version3 permission. Digests and structural validation do not prove the
semantic truth of user-invented facts; this remains a trusted local producer
contract.

## Invalidation, preparation and measurement

The [driver](../../selfhost/tools/typed-driver.mjs) keys caches by compiler API
bytes, Base bytes and canonical Base path, and validates term/span ABI, source
interval and producer/version metadata. A changed compiler, Base or source
location cannot reuse facts under the old identity. Persistent inspection also
rereads/hashes artifact bytes and freezes its admitted graph.

When a newer filename is absent, readers try frame4 → frame3 → frame2 → frame1.
A present corrupt frame4 does **not** trigger selection of an older filename.
Explicit `prepareBase` writes the selected frame4 when only a compatible older
file exists, using a temporary file and rename. Legacy JSON reading/writing
remains available.

Measure preparation separately: parsing/checking Base, producing facts,
interning and encoding are preparation costs. A fresh compilation with a prepared
cache still pays file read, digest checking, complete decoding, admission and the
source request. API/module import is a separate clock unless explicitly included.
The [local codec probe](../../implementation/phase64/cache-artifact.md) measures
only its stated decode scope; it establishes neither whole-compiler gain nor
compiled-program speed. The separate [207-worker compiler comparison](../../implementation/phase64/state09-results.md)
measures the complete selected bundle: compilation 1.64387× → 1.43894× TS and
import plus first compilation 1.18920× → 1.06173×. Those are distinct clocks,
with all 23 sources improving. Qualification and installation passed; the
measured image is genuine B2 and the installed package is equality-derived
checked B1. These results make no new generated-program execution-speed claim.

<a id="phase65-selected-integration-candidate"></a>

## Phase65 installed integration

**State10 combines H2 and H6 and is installed and verified.** The
[Phase65 report](../../implementation/phase65/README.md) binds completed compiler,
host, performance and release gates. The compiler remains written in Bend.
Relative to intermediate State09, State10 keeps the selected Bend/B1/B2 algorithms
unchanged and adds exact Base-content gates in the host plus a whitespace-only
decoder trim. Final measurements bind its actual helper and driver bytes.

### Static transport readers

The frame4 decoder splits its twelve existing constructor cases into static
readers. A small loop checks record geometry, selects the reader and publishes
the validated node/kind. One decode-state object serves the static readers;
there is no per-record dispatch closure or tuple. The binary format, tag schema,
field order, typed backward references, Unicode/span checks and roots are
unchanged. All records in a loaded arena remain eagerly validated and fully
materialized, including unused records.

This change belongs to `tools/base-cache-graph.mjs`, the host transport layer.
It does not move parsing, checking, annotation, layout or emission into JS. The
[decoder investigation](../../implementation/phase65/decoder.md) separates
isolated first-decode measurements from complete fresh compiler requests.

### Optional Bend-produced annotations

Preparation uses the actual ready checked Base world, preserving world version3.
The new Bend module `src/check/base-products.bend` supplies four private APIs:

| API | Responsibility |
| --- | --- |
| `base_annotation_prepare(world, minimumWork)` | Verify the closed checked Base and implicit literal dependencies, then retain eligible complete `ka_def` results. |
| `base_annotation_wanted(selected, stops, keys)` | Decide whether actual selected non-stopped definitions could use an optional product. |
| `base_annotation_allowed(load, world)` | Reestablish current prefix/suffix eligibility and reject relevant full-hash collisions. |
| `annotate_selected_base(context, selected, stops, products)` | Preserve selected order and stops; use admitted complete products, or ordinary `ka_def` on misses. |

The selected threshold is 64 syntactic body terms, counted by Bend. It names no
program or Base function. Preparation returns `KBaseAnnotationState{keys,book}`;
the envelope is not a new transport constructor. Existing string/definition graph
records carry the keys and products. This producer is optional and scoped to the
pinned Base whose complete preparation was observed to terminate. It does not
license eagerly annotating arbitrary unselected unsafe user definitions.

### Exact Base-content permission

State10 permits optional annotation production and sidecar reading only when
the actual Base bytes have SHA256
`c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`.
This gate runs before calling the producer and before opening an optional
sidecar. A matching cached filename, path, header or ready world cannot bypass
it. All existing API/path/ABI/source-interval and graph-parent bindings still
apply after this content permission.

This restriction captures a real demand boundary: preparing products may
normalize definitions the current program never selects. Termination was
qualified for the exact pinned Base, not for arbitrary custom or future Base
content. A changed Base therefore uses ordinary request-demanded annotation,
without optional production or sidecar reads. Updating upstream does not
silently extend permission; a new Base needs independent preparation/semantic
qualification before its hash may be admitted. Custom Base compilation remains
available through the ordinary path.

Explicit `prepareBase()` produces a separate optional sidecar under
`build/typed/base-products`. The basename ends in `-annotations64-v1.bin`. Normal
inspection does not create it, including inspection's implicit ordinary Base
preparation. Deleting this optional artifact restores ordinary annotation;
regenerate it through explicit preparation, not by editing its header or graph.

### Request admission and deferred body loading

The exact Base-content permission above is required first. The driver must also
be using its own API and the actual successful prepared-world check route for
this request. A world object merely being present is not
permission. Current carrier, context and selected definitions remain coupled.
The optional read then proceeds in this order:

1. Read a bounded header and small independent key arena; bind exact compiler
   API, Base bytes/path/source interval, ABI and producer/threshold identity.
2. Ask Bend's `base_annotation_wanted` using the actual selected definitions and
   current stops. A miss leaves the heavy body unread.
3. Ask Bend's `base_annotation_allowed` for current load/world eligibility.
   Refusal also leaves the heavy body unread.
4. Read, hash and fully validate the product arena against its declared length
   and both actual parent Base/prepared graph digests, then invoke the admitted
   Bend consumer. Product references may point only into that exact parent graph.

The sidecar starts with a four-byte little-endian JSON-header length, capped at
64 KiB, followed by the header and product bytes. The header binds its key arena
and body digests as well as both parent segment digests. The host privately
retains the validated parent graph needed to interpret references; its memory
cost belongs in whole-request measurement.

Missing, malformed, stale, source-incompatible or ineligible optional products
fall back to ordinary annotation. Mandatory frame validation remains independent; corrupt data cannot grant a
usable cached book. The optional reader has no cross-request result memo, so a
replaced/deleted artifact cannot leave a previously granted product capability
active in a persistent inspector. Injected public APIs do not acquire the private
owned-route permission.

### Measurement and qualification boundary

Explicit preparation, key/body bytes, no-hit header work, admission, hashing,
validation/materialization and retained-parent memory are separate costs. Fresh
request timing must include all work the selected ordinary driver performs; it
must pin the sidecar and directory inventory even for programs that miss it.
A warmed decoder or instrumented saved-work estimate cannot substitute for that
measurement.

Focused semantic and transport controls, candidate screens and their failures
are retained in the [Phase65 report](../../implementation/phase65/README.md).
The final [State10 broad campaign](../../implementation/phase65/evidence/state10-b2-broad.json)
passes 207 exact-output checks over 23 sources. Compilation alone improves
**1.41737× → 1.28945× TS (9.025% less time)**; imports plus compilation improve
**1.04969× → 0.969256× (7.662% less time)**, against the same-campaign baseline.
All sources improve; 21 have nonoverlapping sample ranges. These measure the
selected H2+H6 bundle in fresh genuine-B2 processes with prepared artifacts,
not the isolated decoder, installed CLI or generated-program execution.
A separate [same-B2 sidecar ablation](../../implementation/phase65/evidence/base-annotations-incremental-b2.json)
finds Map −5.13% and map-churn −3.15%, with H2 code and H6 unchanged.
It tests artifact presence on three selected sources, not complete H2 removal
or H2's isolated contribution to the final broad mean.

The final State10 actual-owned B2 product and custom-Base fallback controls pass,
as do the complete compiler and release gates. Evidence reuse explicitly binds
unchanged inputs and the new host permission gate.
A sub-1× import-inclusive ratio does not establish compilation-only parity.
