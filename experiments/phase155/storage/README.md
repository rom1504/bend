# Storage screens 19–20

These are two private Bend storage designs, not size variations of one benchmark.
Neither changes production. Root owns source checking, native acquisition and
execution; preparation here ran no Bend targets. The four entry points accept
`+n: U32` and return `String`. `n` controls both the changing input seed and the
number of updates/batches; it is not a request to reuse a previous result.

| ID | Reference | Candidate |
| --- | --- | --- |
| 19 | `p155s_dense_old` directly constructs `P154Facts` and repeatedly replaces a numeric fact. | `p155s_dense_new` directly constructs a dense array of three-word records and updates it in place. |
| 20 | `p155s_sparse_old` directly constructs `P154Facts`, then inserts every member of a sorted update batch individually. | `p155s_sparse_new` directly constructs sorted sparse records and merges each sorted batch into a fresh flat buffer. |

Both roles use identical formulas and observation order. Each step reads a
changing key, folds the old complete scalar record into an observed rolling
checksum, and derives new values from that read. The returned text contains the
checksum **and every final key, low word, high word and version**, in key order.
Absent sparse keys are explicit. The native harness must consume the complete
String, check exact output before/after timing, and include child cleanup.
Returning a stable Boolean or sampling just one final fact is insufficient.

## Direct construction and complete lifetime

ID19 has 64 dense identities. Every fact is present and exact, with bound64,
two value words and a version. The reference uses the actual Phase154 Patricia
tree and `P154FCell` layout, without inventing generic `KDef` facts. The candidate
omits the invariant fields and stores three scalar words per key. It allocates
256 cells for 192 used cells, initializes every used record and pays all array
reads/writes. It never packs an already-built tree. Observation is completed
before mutation by a scalar helper boundary.

ID20 addresses 64 possible keys spread over a roughly four-million-wide numeric
domain; 32 even-position keys exist initially. Each iteration creates eight
sorted updates, with both replacements and insertions as the residue changes.
The reference and candidate both pay creation of that same batch. The reference
performs eight actual `p154f_put` calls; the candidate performs a linear sorted
merge with last-update-wins equality and allocates a fresh 256-cell output buffer.
Candidate point queries use binary search. This tests bulk update, sparse
identity storage and query costs together, not insertion throughput alone.
It does not convert a trie to manufacture the initial candidate input.

All construction, intermediate arrays, copied records, branch dispatch, full
final-map rendering and reclamation are inside each invocation. No array-bearing
wrapper is shared: merge's affine `Array<U32> & U32` result is consumed once.
Old buffers and batches are not retained between iterations. No new primitive,
unchecked native helper or altered runtime policy is introduced.

## Controls and falsifiers

`spec.json` lists the common harness rows. `controls.json` records literal full
Strings for n=0,1,2,7,31,64,129. `oracle.py` is an independently structured Python
dictionary reference, with explicit modulo-U32 arithmetic; it contains no trie,
array, binary search or merge. It is an output oracle, not a compiler algorithm.
Controls include empty update streams, initially missing sparse queries,
replacement, insertion, full-domain cycling and overwritten values. They do not
prove general equivalence. Larger n can be checked against the same reference.

First require hosted exact output and small ordinary-native exact output. Then
use the same executable, runtime flags and alternated complete old/new calls;
calibrate n beyond startup/formatting noise while keeping memory bounded.
Retain failures. Inspect the actual scalar-array capability and reader machine
code: array cells might be eight bytes in a combined image, and source-level
numeric access is not evidence of a direct load. A standalone scalar-only image
must not silently replace the combined screen for a favorable result.

Reject or retain only as negative evidence if array helpers, copying, queries or
ownership erase the full-lifetime gain. A winning micro-screen is a gate to an
actual compiler-function transfer experiment, never a cold-build speed forecast.

## Why these differ from earlier negatives

[Phase148](../../../implementation/phase148/README.md) paid late packing and
unpacking; its complete unit pipeline was neutral and Map slower. These inputs
are created in their final representation. [Phase154](../../../implementation/phase154/README.md)
introduced numeric identities but retained persistent owned fact cells, lookup
continuations and reclamation. ID19 removes those records for a restricted dense
fact domain; ID20 replaces repeated tree insertion with one streaming merge.
Neither assumes those removals translate automatically to cheap native code.

Limits: fixed maximum64 live keys; numeric identities only; exact scalar facts
with no relation/predicate provenance; no branches, snapshot sharing or joins;
no cost for assigning IDs to arbitrary strings; and sorted batches are produced
directly, so sorting arbitrary updates is not measured. Dense mutation cannot
replace persistent snapshots without separately charging clones. Sparse merge
rebuilds the whole small map and can lose badly for large maps/small batches.
The initial sparse domain becomes fully populated after eight batches, while
remaining sparse with respect to its numeric key space. Common final text work
can dilute the signal and must remain inside the headline result.
