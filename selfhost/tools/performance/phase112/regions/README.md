# Optional frozen continuation regions

This source prototype extends private admission to functions containing an
eligible non-tail call. It carries no target result until the coordinator runs
the compiler, independent controls, native witnesses and measurements.

The registry starts empty and makes at most six immutable passes. In each pass,
each original segment is fused using only the previous pass's ready callees and
the index of original continuations. The resulting segment is checked by the
region planner against that same previous set. First admission stores the exact
transformed segment, exact worker plan and rank. Later passes skip that name.
Private emission uses the frozen pair directly; it never replans against the
final ready set. A pass admitting no new workers ends the iteration early.

Every non-self private edge therefore points to an earlier rank. Non-tail self
recursion and mutually recursive cycles cannot bootstrap admission. Recognized
self-tail edges remain local worker loops with simultaneous argument snapshots.
The public wrappers keep the generic state/Reply ABI and may use the final ready
set because their calls enter already frozen private bodies. This is a bounded
call-graph argument under the stated admission premises, not a native ownership
proof or a claim about arbitrary caller-provided IR.

The private planner accepts a new nonterminal call only when its exact symbol
occurs in previous-rank symbol metadata. It requires a U64 result, the exact
leading state pointer, and precisely the recorded number of U64 arguments.
Ordinary runtime helper admission remains a separate signature and buffer gate.
The original verifier must run before transformation.

Original bodies must pass `p112f_clean`, including candidates with zero fused
sites. Thus source locals cannot forge generated names. The only additional
buffers are the exact `p112f_SITE_local_scratch` allocations introduced by the
authenticated fusion transform, with SITE below that plan's recorded count.
Every nonterminal load, store and helper pointer keeps its original buffer.
All buffers remain distinct static allocations in the native frame.

An exact terminal suffix may use a fresh continuation buffer. The region plan
copies every pure terminal-store operand to `p112f_region_exit_N` locals before
writing any canonical scratch slot, then uses the existing worker result, call
or loop node. Exact terminal matching rejects mixed buffers, wrong slot order,
wrong counts and intervening operations. The original suffix has only value
stores and its terminal transfer, so this replaces transport without moving or
removing an owning helper call. Generated numeric-site locals cannot collide
with the region-exit namespace, and source hygiene rejects both.

The prototype retains the separately pinned CPU fail-stop premise for exact
terminal failure paths: runtime04 `err_post` reaches `_exit(1)`. It must have a
new conjunctive admission receipt pinning all region declarations and the final
hook as well as worker, fusion and runtime dependencies. An older worker/fusion
receipt does not authorize this profile.

The existing fusion bounds remain: eight callee arguments, eight captures,
eight sites and 128 statements per copied continuation. Region workers have at
most eight parameters independently of the optional wide32 worker overlay.
Each rank uses the checked one-level fusion transform on original segments; a
second returning-path frame inside an inlined continuation still refuses
private admission. This version targets nested call graphs rather than recursive
inlining of continuation chains within one body.

Append `model.bend`, `safe.bend`, `terminal.bend`, `plan.bend`, `index.bend` and
`emit.bend` after the qualified worker/fail-stop/early-refusal and fusion03
modules. Use `entry.bend` as the final optional override. `modules02.json`
records exact source hashes and the explicit local-type fix found by the first
coordinator compile check; `modules01.json` preserves the earlier inventory.
Export `p112r_index`, `p112r_program_counts`,
`p112r_segment_chunks`, `p112r_private_call`, `p112r_buffer` and `p112w_symbol`
for the independent controls in `../workers/region-controls.mjs`.

`p112r_program_counts` returns `admitted-workers/fused-sites-in-frozen-workers`.
It does not count additional public fusion sites. `p112r_index` exposes typed
entries and the name/symbol arity metadata for inspection. Every admitted frozen
worker is emitted, including currently unreferenced entries; no reachability
optimization is attempted. Private definitions are attached to the first public
chunk, retaining one chunk per original segment for metadata consumers. Emission
still requires whole-program output. The finite rank and site bounds constrain
the prototype but are not measured performance or memory guarantees.
