# Two-function tail SCC prototype

This optional checked-Bend candidate transform turns an exact two-function tail
cycle into one existing `P113DFunction` loop. It changes only `p113pl_plan`, before
the existing closed-call DAG admission. It introduces no IR node, emitter,
runtime helper, public calling convention, or new source-language semantics.

Admission requires two error-free candidates with distinct unique identities,
one result each, at most eight Term arguments, and mutual calls in their actual
bodies. Every call within the pair must be followed by exactly one terminal
`Result` of that call's one destination. Its actual arity must match the target.
Existing terminal self `Again` is also supported. Non-tail calls within the pair,
wrong result forwarding, wider result vectors, duplicate identities and a
collision with the generated worker name retain the original candidates.
Partners must occur later in the original candidate order, preventing an earlier
already-preserved candidate from being reintroduced as a duplicate wrapper.

The generated private worker has a full-U64 discriminator and up to eight
full-Term lanes. It branches into two hygienically renamed original bodies.
The existing `Again` emitter snapshots all outgoing values before rebinding
parameters, including permutations, repeated values and high bits. The shorter
signature's unused lanes receive raw zero. Every original ownership operation,
ordinary external call, scalar operation and failure edge stays in source order.
No parent/root is published early, and no new borrowing or ownership fact is
inferred. The helper owns exactly the original live arguments for its current
member; old lane values have already been transferred or dropped by that
member's unchanged ownership code before a transition.

Two existing hygienic prefixes, `p113i_14_` and `p113i_15_`, preserve the current
scratch-provenance rules. Their local-name images are disjoint; the original
`state` pointer remains shared. Existing stack-allocation discovery hoists both
renamed scratch regions outside the loop. Wrapper functions keep their exact
name, parameters, result count and public flag; they transfer arguments into the
joined worker and return its result. A source member can have eight arguments;
the private joined ABI then has nine full words including the discriminator,
within the existing direct ABI's 255-word bound.

The joined worker lists all external body calls as dependencies. The unchanged
`p113d_passes` admits it and then its wrappers only after those dependencies are
ready. Larger or externally connected cycles remain unavailable and therefore
keep generic fallback. The existing final static/direct/namespace verifier and
emitter still process the complete resulting program. This is an internal
checked-source factory, not acceptance of externally supplied candidate records.

`model.bend`, `plan.bend`, `entry.bend`, then `controls.bend` are the module order.
The only replacement declaration is `p113pl_plan`. Export `p126sc_controls` for
`phase126/finite-tail-scc.mjs` (16 pure predicates); `cases.json` supplies an
ordinary source/oracle for the existing semantic runner. Neither has been run by
the author. `inspect.mjs` transports actual checked candidate bodies only.

Evidence: `tail-scc-inspect01/report.json` preserves the existing checked bodies
of `U32.show.go/fin` and `Nat.show.go/fin`. All four cross-call edges have the
required terminal shape. Nat's `show.put` remains an external dependency.
Formatting names play no role in the recognizer. No timing or speedup is claimed.

The first experiment should verify those actual workers are admitted, execute
the independent ordinary source under parent and candidate, inspect the selected
worker for local backedges and absence of mutual native recursion, then compare
existing formatting-heavy workloads. Source discovery adds one hash index and
candidate-name count/call index, plus body checks only after a reciprocal indexed call is found; its compiler cost has
not been measured. This prototype does not combine arbitrary SCCs, non-tail
recursion, multiple results, or unbounded call graphs.

Actual selected entry reaches this plan through `p111_emit_admitted` →
`p113a_lower_request` → `p114s_lower_request` → `p113pl_lower_request` →
`p113pl_prepared`. The later observer `p126bp_close` seeds readiness with the
already merged functions. Its raw candidate retry skips ready wrapper names;
the joined private worker remains in that seeded function list. This does not
claim that a diagnostic candidate alone is an executed worker: actual emission
must still confirm joined symbols and the ordinary source observations.
