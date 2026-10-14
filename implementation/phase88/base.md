# Phase88: prepared Base for fresh native compiler processes

Final phase results and integration decisions are in [README.md](README.md).
The audit/proposal narrative below records its original stage; statements about
what this lane ran are not the final root-run qualification or speed result.


This is a bounded source/transport audit, not a native performance result. No
compiler image, native program, benchmark or build was run. The only execution
was an offline arena inspection on CPU0. Production and upstream are unchanged.

## Recommendation

Reuse the already specified **typed Base arena** as the first implementation
contract. Decode its named Data constructors in Bend, preserving graph sharing,
then form the existing `P86Seed`. Keep the existing preparation path as fallback.
This removes repeated parsing/checking/state construction if transport is faster;
that speed difference has not been measured. A native static Data image is an
attractive second step, but neither arbitrary heap snapshots nor a large literal
should be the first full compiler rebuild.

The immediate cheap discriminator is a tiny prepared-Data fixture, independent of
the compiler image: one term, two shared references, an index, fresh/frontend
states and a world. Compare live versus decoded construction and exact products.
Also emit a literal version and inspect whether the current upstream emitter
actually puts it into `STAT_IMG`. This isolates lifetime/layout questions before
another roughly three-minute optimized compiler build.

The resident-process option is useful for repeated development requests, but
does not address fresh CLI startup. The Phase86 entry already reuses the same
seed across its one/five-request experiment.

## What the native entry repeats

[`entry.bend`](../../selfhost/tools/performance/phase86/entry.bend) runs:

1. `p86_prepare`: source interval construction, then `f_load_graph("Base", ...)`.
2. `p86_prepare_loaded`: `check_book(book)`.
3. `p86_prepare_checked`: `f_fresh_prefix_prepare`, `f_ready_prefix_prepare`,
   `base_prefix_prepare`, then `base_prefix_world_prepare`.
4. `p86_prepare_states`: requires the three ready flags, returning
   `P86Seed{source, book, fresh, ready, world}`.

`P86Seed` and all those fields are declared Data. There is no reason to serialize
compiler closures, scheduler state, request results or open files to persist it.
Preserve the located `FSource`: suffix parsing begins at `f_source_end(base)`;
discarding origins or changing the Base path changes the source contract.

The [Phase87 report](../phase87/README.md) records Base preparation around3.1s.
That stopwatch excludes the preceding Base/input file reads. The startup-heavy
profile combines Base, the small request and teardown; its46.69% `term_drop` and
15.86% `span_fade` leaves do not establish which preparation function owns those
costs. Do not label all those samples removable Base work.

## Existing artifact and exact shape

There is already a compact prepared artifact at:

```text
selfhost/build/phase83/survey01/b2/project/build/typed/cache/
base-098320e8f3e40894156790d740ad205e386f375195b3c6741d67cca96e94e092-
99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf-
92673856f81bb146473729c6b1e427023a37d5cbcf3fb32d7f6805bfbbee4396-frame4.json
```

The filename above is wrapped for readability; join its three filename lines.
Whole-file SHA256:
`97368c6813bad695800b1404af84ab13e5e34b1d5f575828f8fcb681aa2b5627`.
It is1,182,240bytes. The producer is the Phase82 B2 API image, **not** the native
B1 image. This is a useful format/oracle fixture; its header must not be relabeled
as native-produced preparation.

[`typed-driver.mjs`](../../selfhost/tools/typed-driver.mjs) defines
`baseCacheInfo`, `encodeBaseCacheGraphFrame`, `decodeBaseCacheGraphFrame`,
`readBaseCache`, and `prepareBase`. The format is a newline-terminated JSON header
followed by two binary arenas,926,240 and254,772bytes. The first has one book root;
the second extends its node/string numbering and has roots in this exact order:
checked-prefix state, fresh-prefix state, prepared world, frontend-ready state.

The header binds compiler SHA, Base SHA, canonical source path, producer,
termAbi1, spanAbi3, source interval `[1,75066)`, checked/fresh/frontend versions1,
and prepared-world version3. The world fields are
`state,prefix,final,book,checked,seen,todos,checkedBound`. Here `world.prefix` is
the exact decoded book object and `world.state` the exact checked state.

[`base-cache-graph.mjs`](../../selfhost/tools/base-cache-graph.mjs) contains the
schema and strict decoder. The binary arena has an8-word header, roots, one-byte
tags, u32 field offsets/fields, u32 string offsets and UTF16LE text. References
are strictly backward. New prepared records can refer to the first arena. It
bounds bytes, nodes, strings and roots; checks constructor arities, integer
domains, reference kinds, source spans and strings. It is explicitly **not a
checking certificate**. Header producer names and self-declared hashes do not
make an arbitrary file trusted.

The offline inspector
[`inspect-cache.mjs`](../../selfhost/tools/performance/phase88/base/inspect-cache.mjs)
imports only that transport codec. Invoke it with the path and expected
whole-file SHA; it never loads a compiler API. Its observed counts are:

| Item | Value |
| --- | ---: |
| Unique graph records |47,662 |
| Book arena records |36,207 |
| Additional prepared records |11,455 |
| Distinct strings across both arenas |884 |
| KTerm / KLambda / KLiteral |17,901 /3,127 /119 |
| KDef / index leaf / index node |836 /517 /515 |
| Con records |24,642 |

These are shape counts, not native allocation measurements.

## Why not immediately generate one enormous Bend literal?

The checked upstream C emitter already has the required constant machinery:
`term_const`, `emit_ctr`, `ctr_build(..., stat=true)`, `FL.img`, and `STAT_IMG` in
[`bend2/comp.ts`](../../bend2/comp.ts). `corpus_setup` copies the table below
`HEAP_OFF`. `term_triv` recognizes locations below that boundary; `term_keep`
usually returns them unchanged and `term_drop` skips their graph. `spare_free`
does not free their storage. This can avoid both reconstruction and substantial
ownership work. It is a mechanism, not yet evidence of the compiler seed's cost.

The audited comp.ts hashes identically to pinned upstream0592662:
`2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c`.
This is the native B1 producer's runtime. It must not be confused with the
separately retained runtime our selfhost emits for user programs.

The existing graph expands as follows when sharing is replaced by nested
constructor expressions. Byte counts approximate constructor/scalar spellings,
excluding type annotations and the Base source literal:

| Root | Expanded constructor occurrences | Approximate bytes | Maximum depth |
| --- | ---: | ---: | ---: |
| Book |86,073 |1,201,035 |618 |
| Checked prefix |53,570 |737,773 |450 |
| Fresh prefix |1 |31 |1 |
| Prepared world |634,114 |8,850,212 |619 |
| Frontend-ready |87,859 |1,232,841 |258 |

P86Seed's book/fresh/world/frontend literals therefore total about11.28MB before
embedding source text. The separately listed checked root is already inside the
world and must not be added again. Sharing selected named roots can reduce this,
but whether helpers remain constants must be verified. One helper per arena
record creates47,662 definitions and is not a reasonable default.

The emitter's folding fuel is8,192. `term_const` recognizes literal/constructor
trees; a named helper is not itself a constant. `emit_unfold` additionally needs
the callable's flattening conditions. A chunked literal can consequently create
runtime assembly and a large function graph rather than one static seed. Deep
syntax can also stress parsing/checking independently of emitted-table size.

There are ABI traps in manually manufacturing a `STAT_IMG` replacement:
constructor IDs depend on the emitted book; fields may be erased, inline,
packed or boxed; scalar words must not be treated as references; strings use
native character nodes rather than JS UTF16 storage; static locations are
relative to the complete image; and `rfc_seal` can introduce a wrapper even
around a static CTR. Arbitrary raw heap bytes additionally contain redirects,
reference counts, allocator state, tasks/closures and image-specific offsets.
Do not reconstruct these using guessed tag numbers or freeze them wholesale.

## Smallest implementation sequence

### 1. Fixture and transport contract (estimated1–2hours)

Create an isolated Bend fixture using the real compiler Data declarations. Cover
empty lists of each family, every term constructor, packed booleans/integers,
Unicode text/origins, shared subterms and the world/frontend indexes. A literal
variant gives the cheap static-table test. Root can compile/run it under the
existing small-control guard; this audit did not do so.

Use the current codec as an independent graph oracle. The prepared artifact must
come from one actual successful preparation with its full receipt. Native
preparation or a separately identified checked sibling can produce it; do not
claim native self-reproduction when using a JS-hosted producer.

### 2. Pure Bend Data decoder (estimated4–8hours prototype)

Use a closed `P88Node is Data` sum for term, definition, each list family and the
four preparation states; an empty-list marker can serve the three valid empty
families. Walk records forward and construct only the named Bend Data values.
No runtime tag/CID lowering is required. This makes `TAG_CLO`/`TAG_TSK` impossible
as payload constructors and avoids extending native ownership rules.

Store decoded nodes and strings in an owned `Array<P88Node>`/`Array<String>`;
thread the array returned by `Array.get` and `Array.set`. Check index bounds
**before** calling `Array.get`: Base's `Array.get.at` masks the index to capacity,
so it is not a validating lookup. Preserve a kind mask separately or in the
sum and reject forward/wrong-kind references. Never use repeated `List.at` on
the47k-node table or recursively expand shared graphs.

Read the two segments sequentially, retaining the first table for the delta.
Check field counts, total sizes and multiplication overflow before allocation.
Decode UTF16 surrogate pairs to the native String representation while keeping
source offsets in the original UTF16 units. Keep exactly the current decoder's
accepted string domain; do not silently replace invalid text. Consume temporary
tables after producing the retained root and include that destruction in startup.

The current `File.read_bytes` returns `List<&2,U32>`, whose native `io_list`
allocates list cells. A1.18MB compact file is therefore not a1.18MB native buffer.
For the first prototype this is still a bounded, existing I/O route. Keep reads
chunked and sequential and account for list construction/drop in the clock. If
profiles show that transport dominates, a narrow native byte-buffer I/O adapter
can replace it; parsing, admission and compiler algorithms should remain Bend.

### 3. Trust integration and total-process measurement (estimated1–2days)

Bind artifact bytes to the exact preparation producer/source manifest, Base
bytes, canonical path, term/span/schema versions and source interval. If native
layout is ever serialized, additionally bind runtime/image/architecture and
layout schema. A digest supplied inside the same untrusted file is insufficient:
use a trusted build receipt/embedded expected digest or regenerate from Base.
Preserve the fallback preparation for absent/stale caches. Corrupt artifacts
must be refused or trigger deliberate full preparation, never partial readiness.

The standalone native pilot currently relies on the harness to authenticate
Base/runtime/effect inputs. A release must move that guarantee into its own
host contract. Do not silently turn a pilot's pinned cache into public checker
permission. The compiler must still validate the input program and use the
same prepared-world eligibility checks.

After the decoder works, compare the same native binary's prepared/live modes
on fresh processes. Clock cache reading, validation, graph reconstruction,
temporary destruction, first request and total process lifetime separately.
Do not include one-time producer cost in every hit; do report miss/generation
cost. Do not reuse a resident process for a claimed fresh-start comparison.

## Controls and stop conditions

Require exact complete C output and reports on Small, functions65, Numeric,
Lexer and Map once its separate continuation bug is repaired, plus a located
error, Unicode and an unsafe/transitive report case. Do not exclude Map from
an aggregate while it fails. Compare canonical decoded Data/full preparation
products where accessible, not just the ready bits or a successful exit.

Negative controls: altered Base/path/compiler identity, each schema version,
wrong interval, truncation, wrong segment digest, excess size, wrong root kind,
forward reference/cycle, invalid constructor/boolean/integer/string and forged
ready state. Decode two requests from one seed to exercise sharing/destruction.
Check that prepared-world book/state references retain the intended aliases.

Stop the static-literal path before a full compiler build if the tiny fixture
does not remain static, if expansion exceeds a predeclared acquisition budget,
or if helpers introduce proportional runtime construction. Stop a proposed
native serializer if it requires duplicating the compiler's whole layout
algorithm. Stop claiming a startup win if reading/decoding/dropping the tables
costs as much as preparation. These are falsifiable engineering choices; no
startup reduction percentage has been measured in this audit.

## Other options

| Option | Scope and effort estimate | Main limitation |
| --- | --- | --- |
| Resident native request loop |1–3hours experimental framing; more for robust public host |Amortizes Base only; request failure may kill the process; no fresh-start win |
| Full nested Bend seed literal |1–2hours generator, uncertain checked build cost |Observed11.28MB expansion/depth619; static lowering must be proved |
| Existing typed arena with Bend decoder |4–8hours prototype,1–2days integration |Native byte-list and temporary-table ownership costs are unmeasured |
| Native immutable static Data artifact |Later targeted work after small fixture |Image/layout coupling, initialization and ownership admission are more complex |
| Raw corpus/heap snapshot |Do not pursue for this phase |Captures runtime execution state far beyond the needed immutable Data |

All effort ranges are planning estimates. The request-time compiler algorithms
and generated user-program speed are not changed by this proposal. Extending
Phase79's backend annotation cache is a different experiment: this task targets
the Base preparation already repeated by the native entry.

## Follow-up prototype requested during this audit

Root requested a bounded implementation after the initial findings. The private
[`prototype directory`](../../selfhost/tools/performance/phase88/base/README.md)
now contains a roughly380-line Bend decoder, serialization-only carrier
generator, and a small16-case control source generator. The initial generated
`fixtures01/controls.bend` is pinned in its adjacent JSON. It copies only six
real Data declarations, allowing a cheap standalone checked native control.

The carrier uses decimal fields and length-prefixed Unicode strings rather
than runtime layouts. The existing cache's47,662 nodes remain shared through
owned Arrays; no Base literal is embedded. A receipt binds exact cache/API/Base
bytes and the wire schema. The native caller still requires trusted external
byte authentication and consumer-image binding; the decoder's routing stamp is
not a substitute. This is a private pilot, not public cache admission.

Only offline JavaScript syntax checks, carrier inspection/serialization and
source generation have been performed by this agent. Root's first two small
acquisitions failed binder-order/list-pattern syntax; preserved fixtures01/02
retain both mistakes. After syntax corrections, root checked fixtures03 and
all16 controls returned `True{}` in raw JS and native C. No acceptance condition
was weakened. Root's full-product differential gate subsequently passed, as
recorded below. Native load timing remains a separate root-owned gate; there
is no evidence yet that this text transport beats live Base preparation. Its
String and temporary-field allocation may consume the available gain.

`entry-cache.bend` now composes the decoder with a copy of the latest Phase88
entry, preserving six-argument live mode and adding optional `CACHE STAMP`.
It times the carrier read and decoder inside Base preparation and refuses cache
failure. The serialization-only carrier is1,100,924bytes. The JS harness forces
the generated trampoline before comparing complete products. These artifacts
are candidates, not public admission or a new native compiler release.

## Complete product gate

Root ran
[`cache-products01/report.json`](../../selfhost/build/phase88/cache-products01/report.json)
with the checked cache-entry JS sibling and the existing equality-only
derivative. The report is complete and all three full Data comparisons pass:

| Comparison | Object pairs | Scalar checks | Result |
| --- | ---: | ---: | --- |
| Bend-decoded products versus source cache |88,575 |221,911 |Exact |
| Fresh preparation versus source cache |120,669 |313,958 |Exact |
| Complete cached seed versus live seed |125,089 |318,383 |Exact |

The comparison covers all named constructor fields, source origins, fresh and
frontend state, the complete checked world, and the located Base source in the
last row. Pair memoization avoids expanding the shared DAG into a huge tree.
The separate cached-world prefix/book alias assertion also passes. All three
full-payload negatives—wrong stamp, truncation and trailing bytes—return
`P86PreparationError` with a `base_cache:` diagnostic.

Canonical product arena SHA256:
`7e4cf42f60e38660008f1ed746f4a69bb39b6269acd286807f582dad6f6bf1ce`.
The report pins decoder
`296b7c1ce16476ee5e1e433efb8a86c69dd1279ddedd16a7a0734fed83c13480`,
carrier `07af8cdd…b186a7`, source cache `97368c68…b5627`, producer API
`098320e8…e94e092`, and the checked sibling/derivative. Native acquisition can
now be justified, but this is still a JS correctness gate, not native startup
evidence. Its diagnostic wall times include comparisons and are not benchmark
samples. Peak RSS for the whole diagnostic was382,580KiB.

## Bounded read-only decoder review after the gate

No source or build input changed during this review. Source inspection found
no path returning a partial successful product, no unchecked Array read, and
no overflowing accepted integer. The relevant invariants are:

* `p86_read_file` caps the physical carrier at16MiB and verifies EOF. A short
  read with remaining data refuses rather than silently accepting a prefix.
  `p88_roots_done` additionally requires a successful cursor with no remaining
  characters after exactly five roots.
* `p88_digits` requires a terminating newline,1–10 ASCII decimal digits,
  canonical zero spelling, and the pre-multiply U32 bound. Invalid/truncated
  reads propagate a failed cursor and then refuse; overflow is not accepted.
* Header validation precedes allocation. There are at most65,536 records and
  4,096 strings. Array capacities are the next power of two; the growth loop
  reaches at most65,536, so its multiply cannot wrap for admitted counts.
  Records are written once at indexes0 through `n-1`; the loop invariant is
  `made + left = n`. String writes similarly stop at `sn`.
* Every reference checks `id < made` or `id < sn` before `Array.get`, whose
  masking behavior therefore cannot turn an invalid index into an accepted
  different record. Backward references rule out cycles. The fixed width for
  each tag is checked before reading fields. Closed constructor patterns
  reject wrong field/root kinds; only the three list families accept Nil.
* String framing counts Unicode scalars, requires an explicit delimiter and
  rejects surrogates/out-of-range characters. Origins are either0/0 or inside
  the supplied source interval. KLiteral kinds/text rules and Bool0/1 domains
  are checked. The native file reader can replace invalid UTF8 during decoding,
  so byte-level identity still belongs to the external authenticated receipt.
* Arrays are owned and threaded through reads/writes; decoded payloads contain
  only Data, with no closures or generic native Terms. At most nine fields are
  materialized per record. Work is bounded by admitted text plus record/reference
  processing and Array access; no list-index lookup or logical-tree expansion
  is used by the decoder.

There are intentional trust and resource limits beyond those invariants:

* The routing stamp is not a MAC, proof or recomputed payload digest. Shape and
  true ready bits do not prove a book was checked. The private wrapper must bind
  complete carrier bytes, producer/API, Base bytes/canonical path, term/span/
  schema versions and the exact consumer image before invocation.
* The extra checked-state root is required to have the right type, but the
  decoder does not compare it with `world.state`. It does not recompute the
  world-prefix/book alias or producer transformations. Those relationships
  are verified when serializing this pinned artifact and by the full-product
  comparison; they are not permissions available to arbitrary raw callers.
* Decimal spelling is canonical; the entire graph is not normalized on input.
  Duplicate equal strings/records, unreachable records and other semantically
  shaped graphs can be accepted by the shape decoder. Whole-artifact binding
  makes these different files ineligible for this private fast path. A future
  public cache API would need its own explicit admission design.
* The16MiB physical bound is a caller precondition, not enforced by the pure
  `p88_decode_admitted` function. Native strings allocate substantially more
  memory than their wire bytes, and disposal of temporary tables is real work.
  There is no claim that every maximally sized malformed/private input meets
  the ordinary2GiB time/RSS budget. Keep the serial process guard, and measure
  the current authenticated1.10MB artifact before extrapolating.

These findings support proceeding with the pinned private native experiment.
They do not establish a public parser/security boundary or native performance
gain, and do not remove any root-owned native correctness or resource gate.
