# Optional composed continuation regions

This isolated prototype keeps the qualified fusion03 and regions02 sources
unchanged. It addresses the remaining case where a function makes multiple
non-tail calls through a sequence of continuations. Source preparation does not
claim a target result or performance gain.

The new scanner recognizes an exact frame-plus-tail-call suffix using one known
scratch buffer. That buffer must be canonical `scratch` or an exact numeric-site
scratch name introduced by an earlier fusion in this body. Every capture store,
frame argument and tail argument store must agree on that same buffer.

Continuation lookup and admission still inspect the original segment through
the qualified `p112f_cont` path. `p112f_fused` performs the existing ordered
capture snapshots, zero frame-result assignment, argument snapshots, private
call, distinct fresh allocation and renamed continuation binding. The scanner
then resumes on this produced list using site number N+1. This exposes the next
frame in a copied continuation without rewriting its already generated prefix.
Original continuations are renamed once into flat numeric-site namespaces.

One monotonically increasing site counter is threaded across continuations,
branches and suffixes. The hard total remains eight sites per transformed body;
each copied original continuation remains limited to 128 statements, with at
most eight captures and eight private callee arguments. Thus introduced copies
are bounded by eight original continuation bodies of at most 128 statements,
plus bounded snapshot/binding scaffolding. Static scratch allocations remain
distinct and are hoisted by the existing emitter. A site cannot reuse an earlier
numeric namespace.

At an unsupported suffix or exhausted budget, generic transport is preserved.
Partial fusion remains valid for a public wrapper. Any returning-path frame
left in a candidate still prevents private admission; exact terminal fail-stop
paths retain the separate pinned runtime premise. A continuation cycle cannot
cause unbounded compile-time expansion because every successful copy advances
the fixed site budget.

The registry uses the previous immutable ready/symbol sets throughout each pass.
It freezes the transformed segment and exact worker plan at first admission,
then never reconstructs that entry against a larger set. All non-self private
edges therefore still point to earlier ranks, while self-tail transfers remain
local loops. Non-tail self and mutual recursion cannot bootstrap private
admission. Six ranks and early fixed-point stopping remain unchanged.

Private worker arity is restored to 32, matching the separately qualified wide
Term ABI. Fusion's private callee limit remains eight. The region planner still
requires exact prior-rank symbol, return type, state pointer, owned argument
count/type and generated-buffer provenance. Terminal operands are snapshotted
before canonical scratch writes by the existing regions02 planner.

Metadata and original `p112f_clean` hygiene are checked once when constructing
typed `P112MultiCandidate` records, including candidates that fuse zero sites.
Immutable passes traverse this filtered list. The whole-program original
continuation index is built once and shared by private admission and public
emission. All admitted private entries are emitted from their frozen plans;
private definitions remain attached to the first public chunk.

Append `model.bend`, `build.bend`, `plan.bend`, `index.bend`, `emit.bend` after
qualified worker, fusion03 and regions02 modules; use `entry.bend` as the final
optional override. A separate conjunctive admission receipt must pin the full
composition and runtime04 CPU fail-stop premise. Earlier final-hook receipts do
not authorize this source. Original whole-program verification remains required
before any transform.

Exports for independent controls are `p112c_index`, `p112c_program_counts`,
`p112c_segment_chunks`, `p112c_plan_index`, `p112c_plan`, `p112c_candidates` and
`p112c_round`, together with the existing original verifier, IDs, fusion index,
worker symbol and region guard APIs. `p112c_program_counts` returns
`admitted-workers/fused-sites-in-frozen-workers`; it does not count additional
public sites. Round controls must pass the typed candidate list returned by
`p112c_candidates(originalSegments, [])` and the original full segment index.

Independent controls live in `../workers/region-multi-controls.mjs`. Native
multi-call witnesses and real ray measurements must precede any full compiler
image qualification. The finite rank, site and signature arguments establish
the intended admission boundary; they are not a proof of native ownership or a
measured speed/memory guarantee.
