# Effect-preserving leaf inlining

The optional `nx_inline_leaf(program,budget)` fills a deliberate gap in the first
scalar inliner: a small pointer-reading/writing helper can be inlined while
preserving every effect. It does not need to be pure. This is the implementation
for [P107-003](../../experiments/phase107/P107-003-effectful-inline.md); performance
and promotion remain gated on the parent campaign's measurements.

Admission requires a verified closed IR graph and a call-free, loop-free helper
with U32/U64/Ptr parameters, locals and result. Bounds are16 parameters,32 locals,
256 body nodes,256 program functions,65536 program nodes and4096 global expansion
budget. A callee may contain root loads/allocation, stores/free, pointer offsets
and function-address values. Return-free branches followed by a terminal return,
or terminal nested branches, are supported. A return mixed with a later reachable
continuation is refused. Indirect calls and recursion cannot be admitted because
all calls are excluded from this policy.

The pass uses the existing entry-first expander, fresh parameter snapshots,
per-call local initialization, terminal-result assignment and continuation helper.
The only shared transformation change adds renaming for memory expressions and
store/free statements. The old scalar eligibility and outputs should remain
identical; this requires comparison against a frozen previous API, not just tests
of the new policy. The new API verifies its result and returns the input on a
verification failure.

Aliasing is preserved by keeping pointers as values and retaining statement
order. No read/write is moved or deleted. Local pointer zero initialization is
performed inside the inlined call site, so a caller loop cannot inherit an old
pointer from a previous iteration. The synthetic reference-count loads/stores in
`shared` are all retained; any subsequent machine-backend simplification is a
separate compiler effect. No ownership, borrowing, escape or lifetime claim is made.

Eight constructed control families freeze64 input/results: aliased and distinct
pointer parameters, a returned interior pointer, stored pointer plus parameter
mutation, explicit allocation/free, allocated pointer return, pointer-local reset
in a caller loop and conditional memory updates. The aliasing and reset cases
have specified output-mutation witnesses. Source probes and production compiler
programs remain separate from these finite memory controls.

Source acquisition must concatenate `inline/leaf.bend` after `entry.bend` and
`inline/leaf-fixtures.bend` after the core fixture helpers, then export
`nx_inline_leaf` and `nx_l_fixture`. The frozen inputs are in
`inline/leaf-controls.json`. Check budgets0,1,32,4096, complete native results,
growth bounds, invalid/refusal identity and unchanged original scalar policies.
Allocation safety and termination of arbitrary IR memory programs are outside the
structural verifier and are not proved by this experiment.

Status at preparation: static checks only. No compiler build, backend run,
performance result or default change was performed by this implementation agent.
