# Phase173 general tail-SCC fusion: independent audit

Status: bounded source audit, not execution qualification. No target/compiler
runs, production edits, or subagents were used by this audit. The proposal is
the experimental `selfhost/tests/phase173/scc.bend` replacement for
`p126sc_candidates`; the installed compiler is outside this audit's scope.

## What changes, and what remains independently checked

The existing fuser admits two functions with one result. The proposed transform
finds larger mutually recursive components, creates a private tagged worker,
and keeps wrappers under the original function identities. Exact tail calls
between members become `P113DAgain` transfers within that worker. Result vectors
of one through eight words are supported when all component members have the
same result width.

This occurs before the existing `p113d_passes` admission and final direct-program
verification. Unlike the separate Phase173 record-reuse emitter, the rewritten
SCC body itself goes through the existing independent structural/type/ABI
verifier. That verifier checks calls against already-verified functions in
order, preventing residual native call cycles. It does not prove semantic
equivalence or affine ownership; preserving source lowering's ownership actions
remains a transformation obligation.

Relevant existing mechanisms:

- `selfhost/src/back/qbe/product-composition.bend`: original pair fuser, lane
  binding/padding, candidate indexing.
- `selfhost/src/back/qbe/verify-direct.bend`: `p113e_snapshot`, `p113e_moves`,
  direct call/result emission, scratch allocation, and original verifier.
- `selfhost/src/back/qbe/verify-compact.bend`: selected `p147d_functions` and
  direct-flow verifier.
- `selfhost/src/back/qbe/direct-lower.bend`: dependency-ready admission.
- `selfhost/src/back/qbe/inline.bend`: alpha-renaming helpers, scratch analysis,
  size and stack accounting.

## Definite issue discovered during review

The initial `p173sc_size` and `p173sc_stack` both combined costs with
`p113i_add`, whose saturation limit is **4096**. Their comparisons against
8192 statements and 16384 stack bytes therefore always succeeded. In addition,
`p113i_size` itself saturates an individual function at 4096, so merely replacing
the outer sum does not establish an exact 8192-node bound for a larger body.

This was reported immediately to the author and coordinator and corrected:
individual node counts saturated at 4096 now conservatively reject with sentinel
8193, aggregate node costs saturate at 8193, and stack accounting uses
`p113i_stack_add` with its 65536-byte saturation. Aggregate 9000-statement and
24-KiB controls were added. Controls should additionally
exercise a single oversized body, combined oversized bodies, and the exact
accepted/rejected boundaries. The total physical frame also includes the
emitter's base scratch, multi-result buffer and register spills; the proposed
budget is a bound on explicit/synthesized allocations, not a measured machine
stack bound.

## Transfer and ownership argument

1. The worker transports every original argument as a full 64-bit word, with
   an additional scalar tag and zero padding up to the widest member. The
   existing `P113DAgain` emitter first snapshots **all** outgoing words, then
   writes **all** worker parameters, then jumps to the loop header. Swapping or
   rotating owned values therefore does not clobber an incoming source value.
2. Original scalar statements, including keep/sink/constructor operations, are
   preserved with consistent alpha-renaming. The transform does not insert
   ownership increments/decrements for transfers: source lowering has already
   established the legal ownership movement. Extra inactive lanes contain
   zero and carry no ownership credit.
3. An internal call is eligible only when its whole remaining block is exactly
   a result of its destination locals, in the same order, with the common
   result width. Argument count must match the target. This forbids moving
   cleanup, effects, arithmetic, result permutation, or any other work across a
   call. Existing self-loop transfers must also be terminal and preserve their
   original function's arity.
4. Nonmember calls remain ordinary calls with renamed argument/destination
   locals. Terminal results use the existing scalar or multi-result ABI. The
   wrappers preserve original names, formal arguments, result widths and public
   flags. The private worker does not become a new public ABI entry.
5. A worker dispatch tag originates only from a generated wrapper or an admitted
   member transfer. Its final dispatch arm is unconditional; this is correct
   only under that closed construction invariant, not for arbitrary malformed
   calls to the private symbol.
6. The final verifier rejects pointer-valued escapes through ordinary word
   arguments/results and validates scratch capacities and direct import
   contracts. Source-level aliases still require the original ownership
   credits; the transform itself does not establish them from pointer equality.

No additional obvious ownership-transfer or result-order defect was found in
the inspected rewrite. This remains conditional on execution controls and the
budget correction above.

## Graph completeness and complexity

The explicit DFS frames implement the standard Tarjan discipline: unseen
eligible successors are entered, active successors contribute discovery index,
completed DFS children contribute lowlink, and roots pop the active stack.
There is no DFS-fuel cutoff that could silently divide a traversed component.

However, the initial index contains only unique, error-free candidates with at
most 31 arguments and result width 1–8. Consequently its components are SCCs of
the **eligible induced graph**, not necessarily complete SCCs of the original
candidate graph. A cycle through an excluded function can remain outside the
chosen group. This is not inherently a semantic error: unrewritten external
calls remain dependencies, and final topological direct verification rejects a
remaining native cycle. It can reduce coverage and must not be described as
complete whole-program SCC discovery.

The first version read adjacency from `candidate.calls` through the old counts
helper. Following review, `p173sc_counts` now derives it once from actual
`P113DCall` bodies, with a stale auxiliary metadata control. Rewritten
workers/wrappers also regenerate their own dependency lists from their bodies.

With accurate adjacency, graph traversal is O(V+E) dictionary operations, plus
name hashing/equality, persistent-map updates, and component-body scans. It is
not constant-allocation linear time: names are hashed repeatedly, metadata
updates allocate persistent paths, and adjacency is represented through KTerm
lists. Components and bodies have bounded rewrite admission, but discovery
still scans the full candidate graph. Measure added complete request time;
do not infer cheap compilation solely from the textbook graph complexity.

Worker dispatch is a linear tag-test chain, up to 64 members. Large SCC fusion
can remove scheduler transitions yet introduce many comparisons, larger live
sets and spills. This is a profitability risk, not a reason to weaken semantic
admission. The 6–11-member compiler kernels and 36-member compact kernel need
separate runtime measurements.

## Names, scratch, and integration risks

- Prefixing every member local with a distinct numeric member prefix is
  injective within a worker. `state` remains the one shared runtime parameter.
  Generated tag/lane/test names are separate from prefixed locals. Wrapper
  result destinations are distinct.
- Each member receives a separately renamed scratch allocation; existing
  explicit allocas are renamed and hoisted by normal emission. Iterations
  reuse a bounded frame, rather than adding one native frame per recursive
  edge. Multi-result calls share the existing worker-level result buffer.
- The initial `p173sc_*_local_scratch` names are not accepted by the existing
  authenticated factory-name recognizer. This is **also a final-verifier
  blocker** for array pair imports: `p147d_product_call` calls
  `p113p_array_call` / `p113j_array_call`, which authenticate input/output
  names through `p113j_buffer_origin`. Other runtime-helper fast paths can also
  decline these names. Following review, the author replaced this with a fixed
  two-digit base-16 combination of existing `p113i_0..15_local_` prefixes,
  preserving authentication without changing the verifier. Controls now include
  an array-import body, maximum tag63 authentication, tag16/tag1 distinction,
  and both original and selected final verifiers. Their execution remains the
  coordinator's qualification responsibility.
- Generated `$p173scc.N` collisions are checked against raw candidates. The
  downstream ready index can also contain previously constructed workers. A
  collision there would cause `p113d_passes` to skip the proposed worker while
  wrappers refer to the existing identity. The current experimental phase
  prefix is absent from existing seed factories, but broader integration must
  check the full occupied namespace or carry a certified fresh allocator. The
  final verifier alone cannot detect a same-signature wrong-identity collision.

## Cheapest meaningful controls

Compiler-data controls should check exact graph membership and transformed
structure, then the unchanged final verifier should accept valid outputs and
reject invalid ones. Ordinary checked Bend programs should execute against the
unchanged backend and an independent output oracle.

1. Three-member and larger tail cycles; a cycle with a leaf external call; two
   SCCs joined in one direction; an active back edge and a completed-component
   cross edge. Include source order permutations and duplicate graph edges.
2. An excluded-shape member on a cycle, mixed result widths, duplicate function
   identities, unknown external dependencies, and a generated-name collision.
   They must retain fallback / fail admission without introducing native
   recursion. Include stale candidate adjacency if it remains trusted.
3. One-, two-, and eight-result cycles. Refuse reordered, missing, extra, or
   computed tail results. Keep a genuine non-tail internal call unchanged by
   rejecting its whole component.
4. Different argument counts and owned-value swaps/rotations, with surviving
   aliases. Include high 64-bit payloads, constructor/list values, explicit
   drops before transfer, and repeated self-loop edges inside the SCC.
5. Multiple scratch-using members and explicit local allocas. Exercise a
   multi-result external call followed by another internal transition, then
   compare all results after ordinary teardown.
6. Deep bounded recursion whose result is independently known, demonstrating
   loop execution without growing native stack. Inspect generated QBE to
   confirm the relevant mutual calls became `Again` jumps rather than merely
   observing a fallback pass.
7. Limits just below/above argument, component, body and stack budgets. The
   initial broken budget implementation specifically requires regression
   controls, not only tests of small successful SCCs.

After these cheap gates, measure the extracted real import/export/compaction
workloads before considering full self-build qualification. A large SCC can be
correct and still slower due to dispatch or code generation; retain negative
evidence and the original fallback path.
