# Phase131 exact-identity experiment

The candidate removes the preliminary `index_tip` traversal from canonical
Patricia insertion. It does not change names, hash functions, collision buckets,
payloads, verifier checks, diagnostics, or generated QBE.

`patricia.bend` overrides only `index_set`. `p131i_original_set` retains its
selected Phase130 expression and calls the unchanged `index_tip`/`index_insert`.
It is both the compatibility path for legacy indexes and the differential
oracle. `controls.bend` is a separate API-only module, not required by the
production candidate.

## Integration

Use Phase131 `prepare.py` with `--module identity/patricia.bend` and
`--overrides index_set`. Add `identity/controls.bend` only to a diagnostic image.
The composer protects all original verifier declarations.

For each seed, length and hash mode, compare the **complete** returned KDef
from `p131ic_case(seed, length, mode, True{})` and the same call with `False{}`.
Do the same for `p131ic_legacy_case`. The latter begins with a recursively
converted legacy index and then mixes fresh canonical nodes with old nodes.
Suggested bounded screen: seeds 0, 1, 17 and 4294967295; lengths 0, 1, 2, 17,
64 and 257; modes 0 through 6. Modes cover real FNV, all-zero collisions,
all-U32-max collisions, highest-bit splitting, high-16-bit splitting, dense
small keys and multiplicative hashes. Repeated keys replace rich payloads.
`p131ic_queries(tree, 0, 33, mode)` supplies hits and misses for an additional
lookup check. Exact tree equality also checks bucket order and every payload
field; a digest or membership-only test would be weaker.

Then compare ordinary request QBE bytes against the qualified parent before
native timing. Keep an original/candidate same-source pair and measure complete
requests, not only an index microbenchmark. Native checking and measurement are
owned by the coordinating agent; the completed bounded API checks are below.

## Invariant and scope

At a canonical nonzero-mask node, all descendant hashes share every bit below
the split, and descendant splits are larger powers of two. The stored hash is
a representative of that subtree. Consequently, the lowest set bit of
`incoming_hash xor stored_hash` either:

1. lies below the node split, so the original algorithm must insert above this
   node; or
2. is zero or at/above the split, so both algorithms descend into the same child.

Repeating that argument gives the same insertion point. Existing ancestor
hashes and splits are copied verbatim; leaves use the original `index_leaf`,
including exact-name removal and insertion at the front of the bucket.

`KDef` legacy forms and zero-mask nodes execute the original implementation.
This is not a claim of equivalence on arbitrary malformed nonzero-mask trees.
Production concrete nodes originate in `index_node` via `index_join` and
`index_insert`, or are decoded from the pinned prepared-Base artifacts produced
from those structures. A private routing stamp alone is not cryptographic
authentication. The final compiler verifier remains unchanged.

## What this does not demonstrate

There is no new resolved-name service, no global interning cache, and no proof
that the compiler is already faster. One traversal disappears, but each
remaining node performs an extra XOR/lowest-bit calculation. The cost of the
new calling convention and register transport can outweigh the saved walk.
Full source-to-QBE requests decide whether to retain the candidate.

## Semantic screen completed

The coordinating lane checked the diagnostic compiler and ran
`identity-controls01`: 336 exact whole-tree comparisons and 11,088 lookup
comparisons passed, including independent replacement-payload expectations.

The bounded CPU6 lane then ran `identity-request-check01`, retaining all 12
outputs: lexer, closures and Map, two alternating rounds each for the qualified
Phase130 API and candidate. Every output was byte-identical to its independently
qualified frozen native QBE oracle. The guard completed in 95.26 seconds with
906 MB peak process-tree RSS. These hosted correctness timings are not native
compiler-performance measurements. Native proxy and complete native-request
timings remain the next discriminator.

`proxy-cases.json` contains two ordinary programs with the same extracted
compiler KDef/index definitions and 256 actual compiler declaration names.
Each measured repetition constructs an index, updates every payload, queries
all names, and reclaims the result. `proxy-manifest.json` pins source extraction
and the independent checksum oracle. This controls a real representation and
algorithm but does not model every full compiler cost. The original extraction
omitted three existing law signatures and failed parsing; preserve that failure.
`proxy-v02-cases.json` is the corrected source extraction with those signatures
restored, and unchanged names, algorithms, workload and independent outputs.

## Read-side continuation

The separate `read-loop-v01.bend` overrides only `index_find`, unfolding its
legacy helper dispatch to close a single self-tail loop. It preserves the
original lookup behavior even on finite malformed trees; it adds no canonical
index precondition. Exact original clones live in `read-controls-v01.bend`.

`read-loop-finite01` passed 11,088 full-payload lookups across 336 generated
trees plus 840 malformed cases. `read-loop-request-check01` passed all six
whole-QBE comparisons on lexer, closures and Map against frozen native oracles.
The `read-proxy-cases.json` native discriminator subsequently passed, with
construction outside its timing window and the unchanged independent timing
oracle. Five paired measurements reduced timed read work from 283 ms to 214 ms
(24.38%); this is an extracted-workload result, not whole-compiler throughput.
See [the read-side assessment](../../../../../research/phase131/read-side-identity.md)
for exact selected machine evidence and remaining limits.

## Current integration and next isolated experiment

The tested integrated algorithm candidate uses `patricia-v02.bend`,
`read-loop-v01.bend` and `lookup-loop-v01.bend`. Exact-source controls and the
combined usage candidate are recorded in `combined-fast-source02` and its
`combined-fast-*02` finite/whole-QBE receipts. The source hash and limitations
are recorded in the read-side assessment. The older v01 insertion proxy gave
only 3.80% improvement; v02 removes its newly introduced mutual helper boundary
but has not received a separate insertion-proxy timing.

`missing-static-v01.bend` is a separate, unintegrated experiment. Its checked
emission eliminates all three constructor callsites in `missing()` using the
already verified static-data pass. Run the **mixed found/missing** discriminator
from `missing-mixed-manifest-v02.json`, with `missing-timing-oracle.py`, before
claiming runtime gains. The initial mixed manifest omitted conventional status
and stderr fields from its expected-output JSON; v02 fixes that metadata while
preserving the source and independent checksum. No target used the incomplete
v01 expected schema.

`bucket-consuming-v01.bend` is another unintegrated ablation: it uses the same
consuming string equality directly at the collision-bucket boundary. Its
`bucket-proxy-manifest.json` pins a reusable existing native baseline. It has
not yet demonstrated a gain and is lower priority than constant allocation
elimination.
