# Prepared Base artifacts

**Phase64 State09 is installed and verified.** This describes the selected
implementation. The [Phase64 results](../../implementation/phase64/state09-results.md),
[qualification index](../../implementation/phase64/evidence/state09-qualification.json)
and [release verification](../../implementation/phase64/evidence/state09-release.json)
keep its genuine-B2 measurement and packaged checked-B1 release distinct. The
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
