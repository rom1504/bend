# Phase64: indexed prepared Base artifact

Status: data census and demand-instrumentation prototype. No indexed artifact
or selective materialization is selected. Phase63's closed evidence is unchanged.

## What the current artifact contains

The [read-only State09 census](cache-record-census01.json) verifies both frame3
segment digests and their backward-reference graph before counting records:

| Quantity | Result |
|---|---:|
| Distinct graph nodes | 46,757 |
| Mandatory raw Base nodes | 35,378 |
| Additional prepared-state nodes | 11,379 |
| Nodes reachable without following any `KDef.value` | 14,578 (31.18%) |
| Nodes reachable without following `KDef.typ` or `KDef.value` | 4,449 (9.52%) |
| String occurrences / distinct strings | 39,987 / 874 |
| Expanded / interned UTF-16 string bytes | 231,122 / 24,442 |

The 68.82% body-only difference is a potential materialization opportunity, not
executed demand. Current TODO scanning visits Base terms even when compilation
does not otherwise need their bodies. The independently owned prepared TODO
fact must remove that forced traversal before laziness can save much work.
Other checker/backend traversals may still demand most bodies; measure them.

Fresh State09 CPU profiles attribute roughly 100–110 ms to Base-cache ancestry
on Numeric, Lexer and Map. Those sample-derived durations are not isolated clean
request clocks. They establish a fixed-cost budget; eliminating this stage alone
cannot close the entire compilation gap on the larger inputs.

Reproduce the static census without running a compiler:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase64/cache-artifact/census.py \
  EXACT_FRAME3.json NEW_OUTPUT.json
```

## Admission rules constrain the representation

Simply splitting JSON into lazily parsed definition chunks would change current
behavior: malformed unused records are rejected during admission today. A digest
establishes byte identity, not schema/source-range validity or checked semantics.
Therefore the candidate must still validate **all** mandatory records eagerly,
and discard optional acceleration on invalid optional records.

The distinct experiment is an indexed fixed-schema arena:

1. Tiny metadata retains API/Base/path/ABI/producer identities and independent
   mandatory/optional segment digests.
2. Typed tables hold constructor tags, record offsets, scalar/reference fields,
   string offsets and UTF-16 string bytes. Constructor schemas determine field
   counts; references remain strictly backward and type checked.
3. Admission validates the tables, source intervals, literal Unicode, scalar
   domains and every child reference without allocating a JSON row array or a
   compiler ADT for each record. Optional-state failure keeps the full fallback.
4. Only demanded ADTs are subsequently materialized, preserving graph sharing.
   Compiler parsing, checking, reachability and emission still execute Bend.

A simple storage model is 1,159,051 bytes before metadata/hashes/alignment. That
is similar in scale to frame3, so byte reduction is **not** the hypothesis. The
claim is fewer parser/row allocations and fewer materialized compiler objects.
The earlier rejected generic binary codec still counts as rejected evidence;
this proposal must demonstrate an advantage after complete admission.

## Smallest discriminating experiments

First collect actual property demand. The
[`make-demand-helper.py`](../../selfhost/tools/performance/phase64/cache-artifact/make-demand-helper.py)
factory creates a separate diagnostic decoder. It preserves validation and the
original decoded graph, then returns shared read-only Proxy views of its roots.
Every original node keeps one identity across book and prepared roots.

The exported `setDemandPhase(name)` returns the previous phase; a diagnostic API
wrapper restores that value in `finally`. `getDemandReport()` reports decoded,
wrapped and accessed node counts, record IDs, property counts and definition-body
reads per phase. This is deliberately **not a timing experiment**. Proxy overhead
can be large. A returned body root does not imply its descendants were read.
Use one fresh request; persistent freezing is unsupported by these diagnostic
views. Frozen helper identity and transformation manifest are recorded beside it.

Run Numeric and Map first; repeat after the prepared TODO fact. Add Lexer if
body demand differs materially. The report should separate admission, source
loading, checking, annotation, reach/lowering and final host emission. The
current decoded-node count is the denominator; overlapping phase sets must not
be summed into a false unique total.

Then implement one standalone arena encoder and **eager** reader before adding
laziness. Compare fresh-process complete admission plus reconstruction against
the selected specialized frame3 decoder, using identical decoded graph values,
sharing, malformed-record controls and mandatory/optional failure behavior.
This isolates whether avoiding JSON rows pays for the representation itself.

Only a surviving representation should add a selective boundary. The first
candidate is `KDef.value`, because it isolates 68.82% of static records while
leaving ordinary term objects with fixed property shapes. A Proxy on every term
or changing accessor shapes throughout hot traversals is a substantial risk:
Phase63 showed that object construction shapes affect later compilation, not
only decoding. Measure full requests including first-use materialization; never
report deferred work as eliminated work.

Reject selective materialization if remaining phases touch most body nodes or
if accessors consume the saved admission time. Keep the eager arena only if its
own complete fresh-request gain survives. This sequence avoids a large new
storage subsystem based solely on a promising node count.

## Coordinated TODO-fact schema extension

The independent TODO experiment appends `todos: U32` to `KBasePreparedWorld`.
This agent updated the graph schema and fixed constructor decoder only, then
froze the helper. Root owns the corresponding driver ABI/version admission.

The decoder accepts the previous seven-element world row and the new eight-
element row; the old decoded object lacks `todos`. Version2 host admission
requires the actual unsigned count. This allows old optional state to be
decoded without granting the new semantic capability. Semantic count validity
comes from the identity-bound Bend producer; structural validation alone is not
a proof of the count. Missing/invalid optional facts retain fallback checking.

## Isolated eager arena prototype

The standalone [`indexed-codec-v1.mjs`](../../selfhost/tools/performance/phase64/cache-artifact/indexed-codec-v1.mjs)
implements the eager discriminator, without changing the production reader.
Each mandatory/optional segment contains bounded typed tables for constructors,
record offsets, U32 fields, string offsets and UTF-16 text. The reader preserves
the fixed named object layouts of the selected decoder. Both old worlds and
worlds carrying the TODO fact are supported. Every record validates before the
segment is returned, including records unreachable from its roots.

The prototype has independent mandatory/optional digests and preserves optional
failure fallback. It handles unaligned input slices and uses an explicit
little-endian conversion path on other hosts. There is no lazy accessor or
compiler representation change in this first experiment.

The companion controller checks full graph values and identity sharing, format
bounds, unused-record rejection, reference types, source ranges, scalar fields,
optional failure and both world versions before writing the benchmark manifest.
Then each worker measures its first decode in a separate process:

```sh
node selfhost/tools/performance/phase64/cache-artifact/indexed-probe-v1.mjs \
  prepare EXACT_DRIVER.mjs EXACT_FRAME3.json NEW_DIRECTORY

node selfhost/tools/performance/phase64/cache-artifact/indexed-probe-v1.mjs \
  worker NEW_DIRECTORY/manifest.json frame3 NEW_FRAME3_REPORT.json

node selfhost/tools/performance/phase64/cache-artifact/indexed-probe-v1.mjs \
  worker NEW_DIRECTORY/manifest.json indexed NEW_INDEXED_REPORT.json
```

Root runs these serially under the existing resource guard, alternating roles.
The clock includes file reading, outer hashes, parsing, complete graph schema
validation and eager materialization. Driver/API import, source identity
discovery, semantic prepared-state admission and post-return graph comparison
are outside this **codec** clock. Input hashes are verified before timing, so
it is not OS-cold storage measurement. A gain here requires subsequent complete
compiler requests before any production decision.

Before its first target execution, independent review prompted two refinements:
the manifest now pins the imported baseline graph helper, probe and Node binary,
and the writer explicitly refuses a numeric `-0` field. A handwritten JSON frame
can contain that spelling, while genuine `JSON.stringify` producer frames cannot.
The controller tests this canonical-input refusal. Thus the encoder does not
claim conversion of every arbitrarily constructed accepted frame3 byte encoding.
It also requires a valid optional input segment; ordinary frame3 decoding may
instead drop corrupted optional state. Migration of arbitrary older caches would
need to preserve that fallback separately. Literal Unicode and Boolean domains
remain separate validations. The unused duplicate probe draft was removed before
execution; there is one v1 controller and no rewritten run evidence.

No Node/compiler targets were launched by this agent. Static data inspection
used CPU0. All target execution and selection remain root-owned.

## Eager discriminator result and isolated integration

Root ran the preserved prototype in four balanced fresh-process role pairs.
All 18 preparation controls and all eight workers passed. The complete local
codec clock was:

| Representation | Four first-decode samples, ms | Median, ms |
| --- | --- | ---: |
| Existing frame3 | 128.894, 129.616, 129.981, 123.221 | 129.255 |
| Indexed arena prototype | 91.972, 71.057, 57.081, 71.271 | 71.164 |

This saves **58.091 ms (44.94%) in the measured codec scope**. It is not a
whole-compiler speed result. The indexed samples have substantial variation;
the complete request screen remains necessary. Artifact sizes are 1,198,875
versus 1,160,392 bytes, only a 3.21% reduction. The mechanism is avoiding JSON
record arrays and repeated string materialization, not a large disk-byte saving.
The prototype writer took 165.545 ms outside the measured request clock.
Raw evidence is retained under
`selfhost/build/phase64/indexed-eager01/{manifest,0-frame3,0-indexed,...}.json`.

The result justifies a production integration candidate, not promotion.
[`arena-integration-v1.json`](../../selfhost/tools/performance/phase64/cache-artifact/arena-integration-v1.json)
pins three **unapplied** patches against the exact State08 checked-bound source:

- Fold `encodeBaseArena` and `decodeBaseArena` into the existing
  `base-cache-graph.mjs`. The constructor schema and exact structural interning
  are shared with the unchanged JSON encoding. There is no new production
  import, snapshot dependency or generic storage framework.
- Keep the old frame2/frame3 writer behavior for compatibility. Explicit Base
  preparation uses the new frame4 writer for the existing prepared-world API.
  The envelope retains the two independent graph digests and all identity,
  producer and version metadata. The decoder validates every record eagerly.
- Select filenames in order frame4, frame3, frame2, frame1 only when the newer
  file is absent. A corrupt present frame4 does not fall through to stale
  bytes. Explicit preparation upgrades a fallback-only cache to frame4.
  The workflow cache selector recognizes the same order.

World record sizes from the original six fields through TODO and checked-bound
facts remain readable. Actual permission to consume a fact still requires the
matching producer/version and exact Base/state root binding in the driver.
Invalid optional arenas drop every optional accelerator; the mandatory Base
book remains available to the existing fallback checker. Invalid mandatory
arenas refuse the cache. Neither a digest nor a valid record schema proves the
semantic contents of a prepared world; the trusted local producer contract is
unchanged.

The strict successor
[`arena-controls-v1.mjs`](../../selfhost/tools/performance/phase64/cache-artifact/arena-controls-v1.mjs)
is prepared for root execution. It checks actual graph values and bijective
sharing, unchanged JSON writer bytes, every constructor and unsigned endpoint,
old world layouts, reference/root subtypes, malformed lengths and offsets,
nonzero padding, scalar Unicode versus ordinary code-unit strings, and invalid
unused records in both segments. A separate driver controller covers metadata,
root admission, fallback and persistent-cache invalidation. No pass is claimed
for these successor controls until their recorded execution.

The active latency setup also requires a fresh method version accepting the
frame4 filename; its semantic cache versions remain 4/6. Its one-cache-file
assertion should run in a fresh preparation directory. Historical frame3
controllers and their consumed source remain unchanged. The shared helper's
existing bootstrap/snapshot/release provenance binding covers the new codec.

Root subsequently ran the production domain controller against the State08
frame: **85/85 controls passed**, recorded in
`selfhost/build/phase64/arena-domain01/report.json`. The checked-context and
world-version-three gates also passed independently. These passes establish
more than the earlier standalone prototype, but still do not measure full
request speed or authorize a semantic claim about arbitrary prepared facts.

Independent review then identified an encoder-domain edge outside the genuine
producer frames: JSON-based structural interning could merge a `-0` field into
an earlier equivalent `0` record before the arena writer rejected `-0`.
The consumed v1 helper/controller and their successful result remain unchanged.
[`arena-integration-v2.json`](../../selfhost/tools/performance/phase64/cache-artifact/arena-integration-v2.json)
selects a small isolated successor: the shared record builder optionally checks
original unsigned fields **before** interning, and only the arena writer enables
that check. Legacy JSON encoding retains its prior behavior and bytes.
[`arena-controls-v2.mjs`](../../selfhost/tools/performance/phase64/cache-artifact/arena-controls-v2.mjs)
retains the 85 controls and adds both `[0, -0]` and `[-0, 0]` root orderings.
The reviewed driver/workflow patches are unchanged. v2 remains an unapplied
candidate pending root execution and integration.
