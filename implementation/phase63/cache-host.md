# Phase63 prepared-state transport and host integration

Status: source prototype frozen for State01; initial codec probe passed. Complete
request qualification and selected-source status belong to the phase report.

## Hypothesis and falsifier

Phase62 measured approximately 173 ms for prepared Base admission, including
89 ms JSON parsing/conversion and 52 ms tree validation. Serializing a prepared
checker world as ordinary JSON would duplicate terms in its raw book, indexes,
checked definitions and event history. A smaller file alone does not establish a
speed gain: Phase61's binary codec was slower after mandatory validation.

The candidate uses a closed-schema DAG record format. Preparation interns exact
structurally equal nodes, including origin intervals and all flags. Loading
parses compact records, allocates each distinct named ADT once, and validates
its scalar fields, source ranges and child types during reconstruction. A
backward-only reference order excludes cycles and dangling references.

The falsifier is decode plus required validation versus frame2, followed by
complete fresh-request compilation. A smaller wire representation or faster
unchecked decoder is insufficient. Preparation cost remains separately visible.

## Representation and admission

`selfhost/tools/base-cache-graph.mjs` owns the fixed constructor schema. The
format accepts Nil/Con, the three KTerm constructors, KDef/index nodes, existing
checked/fresh prefix states and the new prepared checker/frontend states. Lists
retain element categories. Fixed field names avoid dynamic prototype assignment.
The decoder caps a segment at 128 MiB and the graph at 1,048,576 records.

Frame3 contains two independently hashed segments:

1. A mandatory raw Base book graph.
2. Optional checked/fresh/checker-world/frontend state, sharing nodes with the
   book graph. The optional roots may be null.

Invalid mandatory graph bytes or shape are rejected. Invalid optional bytes or
shape discard all optional accelerators, preserving the ordinary checker path.
Malformed-but-present mandatory frame3 never silently selects an older cache.
Absent frame3 may use frame2, then frame1. The logical source-range/term ABI
versions remain unchanged; the distinct frame3 format controls transport.

The host still verifies exact API bytes, Base bytes, canonical path, source
interval, ABI/version and producer metadata. The mandatory graph digest binds
the transport; the previous expanded-book digest remains compatibility metadata.
Frame3 admission does not recompute an expanded JSON representation. Its
node-by-node range/type validation replaces the tree walk, rather than omitting
validation. Public `validateSpanCache` retains its original full behavior.

Prepared-world admission additionally requires that its `prefix` be the exact
decoded mandatory book root and its `state` be the exact admitted checked-prefix
root. Structural interning makes these relationships explicit. Request use also
requires the driver's private owned-API path and native loader provenance; a
caller-supplied API does not obtain that permission. Public raw seed/check APIs
retain their original path.

This remains trusted-local preparation, like the previous checked-prefix patch
cache. A hash and shape validation are not a semantic checking certificate for a
hostile cache writer. The producer's Bend checks establish readiness; host
identity and coupling preserve the producer/consumer relationship. The transport
does not prove that arbitrary supplied indexes describe a book correctly.

Existing persistent parse/check inspectors freeze the newly admitted world and
frontend state along with the book. This patch does not expand their supported
modes. Fresh requests still discover and read current user sources/imports.

## Host integration

The host discovers and exports the new Bend preparation/consumption APIs only
when present in the source snapshot. Existing images retain their old API path.
New API preparation upgrades an already admitted frame2 book without rechecking
the same Base; its previously admitted checked state remains the capability.

The new frontend seed accepts the prepared parser/constructor indexes. The
checker accepts the prepared world only alongside an authenticated native loader
carrier. The new backend plan is selected for direct JavaScript library mode
when all four plan APIs exist; other modes and older images use the existing
reachability/emission path. These compiler algorithms remain in Bend. The host
only marshals values and selects APIs.

The helper is included in both bootstrap provenance and workflow snapshots.
`validatedCache` prefers frame3 and invokes the common decoder; source/API/Base
metadata checks remain in place. Measurement tooling must bind the new helper
alongside the exact driver; copying only the driver is insufficient.

## Transport probe

`selfhost/tools/performance/phase63/cache-codec-probe.mjs FRAME2 OUTPUT.json`
reads an existing prepared cache without importing a compiler image. It checks
exact expanded values for the raw book and both existing states, malformed
references/constructors/scalars/ranges/literals and shared-root reconstruction.
Five alternating in-process rounds compare frame2 decode plus its tree validator
against graph decode plus its schema validator. The probe reports encoding cost,
wire bytes, distinct node counts and every timing sample.

The probe excludes graph outer-frame hashing/header dispatch and does not carry
a newly produced checker world or frontend state. It is a cheap direction test,
not complete request timing or semantic qualification. Root owns serial guarded
execution; this agent launched no Node or compiler target.

The [first executed probe](../../selfhost/build/phase63/codec01/report.json)
passed all 11 controls and exact values. Frame2 occupies 5,667,458 bytes; graph
segments occupy 1,145,743 bytes (header excluded). The graph has 35,378 book
records and 8,573 additional state records. Encoding took 306.73 ms.

Five-round medians were 105.53 ms for frame2 and 29.50 ms for the graph. However,
the first timed graph round was **130.12 ms versus frame2's 118.82 ms**, despite
an earlier untimed exact-value decode. This is evidence of important VM/JIT
effects, not a demonstrated cold-request saving. Root ran the supervised probe
in 1.61 s, with approximately 253 MiB peak RSS.

`cache-cold-probe.mjs prepare FRAME2 DIRECTORY` creates equivalent frame2/3
fixtures containing only the old book/checked/fresh state. Separate fresh-process
`worker DRIVER CACHE BASE OUTPUT.json` invocations measure the first real private
`readBaseCache`, including outer hashes and optional-state admission. Driver
import and API/Base identity discovery remain outside that diagnostic clock.

Two further ideas are retained as **unapplied patch proposals**:

- [Private ABI ownership](cache-owned-abi.patch): convert all five admitted roots
  together once, retaining read-only native views so later API calls unwrap them
  instead of copying the Base graph repeatedly. Public mutable input conversion
  remains unchanged. Named graphs are admitted/frozen before conversion; Proxy
  views must not be passed to `Object.freeze`.
- [Literal decoder shapes](cache-literal-shapes.patch): keep the same validation,
  but construct each known ADT with a fixed object literal instead of adding
  dynamically named properties. It must improve fresh-process costs as well as
  warm decoding to justify the extra constructor-specific code.

The adjacent JSON files pin before/after/patch hashes. Root decides whether and
when to apply these in a subsequent explicitly identified state.

## State05 diagnosis and host-only decoder experiments

The [State05 host admission controls](../../selfhost/build/phase63/state05-cache-admission01/report.json)
pass **28/28** cases, including metadata binding, world-root coupling, optional
failure, memo invalidation/freezing and old-frame fallback. These controls use
the real private admission functions through an export-only driver copy and do
not execute a compiler image.

Current B2 profiling found **zero ABI adapter encoding work**: this image uses
named layouts. The owned-ABI patch is therefore an untested alternate, not a
selected solution to this workload. The full prepared frame's cold admission
instead regressed from roughly 153 ms to 179–183 ms in the two profiled cases.
Book reconstruction took approximately 119 ms and prepared-state reconstruction
another 53–54 ms. This confirms why the earlier warm codec median was insufficient.

The [fast-constructor patch](cache-fast-constructors.patch) keeps the wire format
and validations but specializes every constructor's fixed fields, reference
types and literal object layout. It does not mutate numeric wire arrays into
object arrays. Private per-node type masks replace string-category dispatch;
the same helper must decode both segments. The decoded root values and sharing
are unchanged. Fixed object shapes may affect subsequent compiler accesses as
well as decoder time, so the discriminating experiment measures complete requests.

In the [first host-only screen](../../selfhost/build/phase63/state05-host-fast01/screen/report.json),
the fast-constructor variant used 337.21 ms versus its baseline's 417.73 ms on
Numeric, and 1,231.98 ms versus 1,337.22 ms on MapSet. All four complete raw-module
oracles passed. Each input has only one fixed-order pair, so these are provisional
19.3% and 7.9% reductions, not a broad or balanced result. API, Base, cache and
driver bytes were unchanged; only the helper differed. No compiler rebuild was
needed for this diagnostic.

`cache-decoder-differential.mjs OLD_HELPER NEW_HELPER FRAME3 OUTPUT.json` compares
accepted/rejected domains across all twelve constructor schemas and compares
complete real-frame roots and sharing. That and balanced fresh-request timings
are required before choosing the faster helper.

## Required integration controls

Before selecting the candidate: malformed optional state fallback; mandatory
corruption rejection; API/Base/path/span/version mismatch; decoded world/book
and world/state coupling; source/import edits across requests; prepared/off
output equivalence; old API/frame compatibility; and source checking followed
by the relevant direct/native/legacy and reproduction gates. Backend context
reuse requires its separate validity review and cannot be established by this
transport probe.
