# Phase173: indexed semantic store and a complete native consumer

Status: experimental implementation, source checking/controls pending. No speed
claim or production selection. The independent native verifier is unchanged.

## Question and falsifier

Does a durable graph of semantic IDs make a complete compiler computation cheaper
than repeated owning KTerm traversal, after charging its representation boundaries?
The first falsifier is exact `nc_compact` plus ordered `nc_refs` on real erased
compiler bodies. Importing a body for one getter is not the experiment. Full typed
erasure is deliberately **not** claimed: it depends on normalization, substitution,
constructor telescopes and a book. Those must move into the store as complete
consumers if this execution model first demonstrates a credible payoff.

This slice cannot establish a 2× full-build result by itself. Its whole-build
ceiling is the measured compaction/references/boundary share, which has not yet
been attributed. A successful local result would justify broader semantic
consumers; a failed result identifies representation and ABI costs before paying
for a compiler acquisition.

## Interface and semantic contracts

Sources: `selfhost/tests/phase173/store.bend`, `store-compact.bend` and
`store-controls.bend`.

- `p173s_new` creates a linearly owned store.
- `p173s_import(store,term,fuel)` imports a complete KTerm tree and returns its ID.
- `p173s_compact(store,id,fuel)` performs native compaction directly on IDs.
- `p173s_refs(store,id,fuel)` preserves the complete ordered reference list,
  including repeats and references nested in `NStatic` values.
- `p173s_export(store,id,fuel)` reconstructs KTerm only at the terminal boundary.
- `p173s_valid(store,fuel)` independently checks ranges and strict postorder edges.
- `p173s_ok` exposes sticky bounds/resource refusal. A false result is never a
  valid compile product. Root0 is the exact ordinary `Absent` node used by the
  existing missing-child semantics, rather than an invalid memory address.

Nodes preserve all KTerm, KLambda and KLiteral fields: variant, tag, name,
occurrence ID, quantity, removed names, source origins, literal kind/number/text,
and Lambda quantity-presence. Child pointers are replaced by a start/count into
an Array of U32 IDs. Strings and removed-name lists remain existing immutable
values; this is not a second string-interning system.

IDs are append-only postorder positions. A node can reference only earlier nodes.
Old imported graphs remain valid after transformations; transformed nodes append
new edges/nodes. There is no array alias, `Array.fork`, foreign allocator, FFI or
runtime edit. Capacity doubles with explicit linear ownership. Explicit worklists
bound import, export and compaction independently of host recursion depth. Fuel
exhaustion is an observable refusal, not partial success.

The implementation of `nc_compact` is complete for the existing KTerm API,
including legacy KTerm/Lam versus KLambda syntax, NStatic bypass, arbitrary literal
kinds, UTF String expansion, words, Nat overflow, malformed constructor arities,
and the existing Succ-chain behavior. This is not a restriction to expected
benchmark shapes. It never reconstructs a KTerm inside a consumer or delegates
individual indexed nodes back to the old compiler.

## Important runtime correction

The Base definition of Array is a binary tree, but that does **not** imply
logarithmic native reads for this experiment. The selected compiler already lowers
Array.get/set to native array operations even when File effects deny the optional
scalar-array packing capability. The denial affects slot width/packing rather
than whether the array is native. U32 edges are immediate terms. Inspect emitted
QBE/machine code to establish actual read/write costs; do not infer them from the
Base equations alone. Growth via ANode can copy arrays, but doubling amortizes
copied capacity. Remaining likely costs are owning node reads, Store/tuple
reconstruction, worklist dispatch and boundary allocation; these remain hypotheses
until the actual generated program is inspected and timed.

## Gates and retained costs

1. Independent source checking of all experimental definitions.
2. 26 finite controls compare every original field against a complete roundtrip,
   then compare actual compaction and ordered references against unchanged
   `nc_compact` / `nc_refs`. Include metadata, Lambda presence, repeated aliases,
   malformed finite shapes, string/word/nat boundaries, overflow and static bypass.
3. Three refusal controls exercise ordinary checked-data bounds and fuel; no
   malformed machine code, foreign memory or crash probes are involved.
4. Real compiler-body workloads compare the **entire** body/reference products,
   not counts or selected digests. Time import, direct consumers, export and
   destruction together as well as separated diagnostic boundaries.
5. A complete request overlay preserves the independent lowerer/verifier and
   requires byte-identical generated QBE. Its per-body import/export is explicitly
   charged and is not evidence of a durable whole-compiler indexed architecture.
6. Only meaningful end-to-end gains justify additional semantic consumers or a
   full experimental compiler acquisition. Keep the installed compiler unchanged.

The `law` declarations are checked function signatures. They are not mathematical
proofs, BendTT equivalence theorems, or replacements for independent oracles.
Named branch helpers accommodate Bend's requirement that match scrutinees be
parameters or constructor fields; they do not introduce additional semantic IRs.

## Known risks and next decision

The indexed graph adds two memory domains while the old KTerm graph is retained
at the boundary. A single pass may lose to allocation-free borrowed traversal.
Import currently preserves observable structure but does not detect pointer
sharing: identical/shared subtrees receive separate IDs. Append-only transformed
versions also retain dead prior nodes until store retirement. These are explicit
lifetime and cost questions, not solved by calling the representation compact.

A positive result must transfer from real compiler bodies to an unrelated program,
retain generated-code identity, and remain positive when boundary costs are paid.
A negative result should identify whether ownership-neutral store reads, bulk
access or a different primary representation is needed. Do not add a cache,
second backend or source-to-source bridge to make a narrow timing look better.

## Implementation qualification notes

The pinned frontend has stricter match elaboration than the current upstream Base
examples: computed tuple destructures, computed match scrutinees and a second
match after an earlier local computation require named definitions. Initial
source-check attempts exposed these syntax restrictions before native execution.
The checked shape uses at most one match per function, explicit pair consumers,
and typed constructor lets. This introduces substantial helper/signature source,
which is an implementation cost to report rather than hide.

After the first checked snapshot, 13 unused helper argument slots were removed
(including retained outer node aliases). Definitions were ordered by dependency;
forward signatures remain only for recursive groups. The final public store API,
algorithms and emitted semantic products are unchanged. This cleanup is not a
performance result. Current storage plus compaction implementation is 1,932 lines
and 54,402 bytes; the complete controls add 183 lines/8,156 bytes. The full checked
store is only a bounded falsifier, not an argument that this amount of machinery
should be integrated into the production compiler.

The validator also compares declared capacity/counts against physical Array sizes
before iterating initialized nodes. Its postorder/range scan is independent from
the import/compaction worklists. Bounds and fuel refusal remain distinct from an
independent kernel proof and from an ordinary semantic-output comparison.

## First observed gate (frozen source05)

`selfhost/build/phase173/store-verifier-controls01/report.json` records a passing
independent hosted comparison on 101 actual erased verifier bodies. Complete
candidate/baseline pass products agree across 321,590 compared values; complete
input and request products also agree. The harness's 16 finite controls and
roundtrips pass, and deliberate comparator field/order mutations are rejected.
This is evidence for that frozen source05 implementation. The subsequently
simplified helper signatures still require their own source check and controls.

The shared-process compaction/reference interval was 0.4083s baseline versus
0.3871s candidate in this one diagnostic observation. API loading and frontend
intervals differ, no native execution oracle ran in that job, and this is neither
a native speed result nor a cold-build improvement. The larger 26-case store
metadata/overflow suite and three explicit refusal cases remain separate gates;
do not count them as run merely because the vertical harness passed.

## Native falsifier and flat-carrier follow-up

The first native whole-corpus run, reported by the coordinating measurement lane,
produces the exact independently expected output on all 101 bodies, but takes
0.157692s versus 0.078725s for the old computation: **2.003× slower**. This defeats
any inference of a native speedup from the initial hosted interval.

The architecture audit identifies two independent suspects: the explicit import,
export and reference machines have mutually recursive helper groups larger than
the current local tail-SCC optimizer accepts; and the nine-field Store root
exceeds a useful flat-product admission limit. The coordinator is testing the
SCC limitation separately. Neither explanation is a demonstrated performance
recovery yet.

`store-flat7.bend` is a deliberately isolated alternative to the frozen source05
base store. Select it **instead of** `store.bend`; keep source05 compaction and
controls unchanged. It removes the stored node/edge depth fields and their helper
arguments. All capacities remain powers of two; only a growth operation computes
`U32.log2(capacity)` for `Array.new`. Reads, writes, node identities, edge positions,
metadata, range/fuel behavior and all public p173s APIs remain the same.

This changes the root from nine to seven fields without introducing an external
second store type, a new representation, foreign runtime code or a SoA rewrite.
The expected benefit is conditional on actual flat admission removing carrier
allocation/ownership/dispatch. The source change alone removes only two redundant
scalars; if the emitted native computation remains boxed, a major gain is not
expected. Inspect emitted code and compare the same native corpus before adopting
it. Growth adds a bounded log2 computation (five steps in the pinned Base helper)
per capacity doubling, which must remain included in the benchmark.

The flat7 refinement relies on the store-construction invariant
`nodeCapacity = 2^nodeDepth` and `edgeCapacity = 2^edgeDepth` in source05. It holds
at capacity16/depth4 and is preserved by every doubling. Capacity growth is
refused at the existing bound before U32 multiplication can wrap. On reachable
stores, replacing the stored depth by log2(capacity) therefore gives exactly the
same new array and subsequent IDs. This is an inspected refinement argument,
not a BendTT-checked theorem. The API does not serialize or expose depth values;
arbitrarily forged private Store constructor fields are outside this refinement.

`store-flat7-readgates.bend` is an optional further ablation, not part of the pure
flat7 change. The existing node/edge bounds helper takes ten arguments after depth
removal. The ablation carries the seven-field root with ID and Bool through that
branch and unpacks the selected case, reducing this source call boundary to three
arguments. Its risk is an extra materialized root when flat-product elimination
fails. Test only if code inspection implicates that boundary; a broader SCC
optimizer may make the old arity obstruction irrelevant. No target jobs were run
by the store implementation agent for either variant.
