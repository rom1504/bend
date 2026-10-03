# P41-L1: eliminate private next-argument tuples

2026-10-03. Owner: list investigator. First investigation bounded to 20 minutes.
Correctness unchecked; measurement not run; decision investigate. The comparison
is installed Phase40 checked06 direct **unfused** output, never Phase39 generic.

Hypothesis: replacing a nonescaping `$next=[e0,e1,...]` literal with fresh
`const $p41next0=e0; const $p41next1=e1; ...` lowers worker allocations and improves
list-pipeline execution. Existing `$sN` assignments follow evaluation of every
RHS, preserving parallel transfer and exact left-to-right expression order.
No change to List constructors, intermediate stages, BigInt countdown, U32
operations, continuation frames, before/args snapshots, guards or fallback.

Inspection finds the tuple in `j_component_enter`, direct-tail
`j_linear_finish` and one-child `j_linear_split`, all in
`selfhost/src/back/js/tree.bend`. Actual fixture workers contain three copies
for each producer/map/filter and four for each tail fold because the generic
continuation skeleton emits unreachable phase branches too. Only a single
copy executes per visited node. The Phase40 residual list profile samples GC
and direct workers; this suggests allocation pressure but does not isolate this
tuple's cost. V8 may already eliminate some tuple allocations.

Select this smallest ablation before compacting frame args/before storage or
removing continuation-prefix replay. Compact frames need a new liveness proof;
fusion additionally needs proven nonescaping intermediates and complete demand
and error-order preservation. The rejected Phase39 callback idea is not retried.

Saved-JS transformation requires a const array with no holes/spreads, lexical
block ownership, fresh temporary names, no tuple aliases/escapes, and exactly
one constant-index read per slot, each the RHS of its matching `$sN=` assignment.
It refuses every other shape. No tagged value escapes are eliminated.

The isolated source proposal evaluates erased argument positions as `null`
and advances the normalized dependent telescope exactly as `j_apply_args`.
The existing `j_expr` remains responsible for live expression/type emission.
It affects all already-admitted structural components, so source promotion
requires independent mixed unary/binary tree controls as well as List/Chain.
There is no new proof admission, runtime, IR or type domain.

Falsifiers: complete stage/export oracle disagreement; changed aliases/fresh
Nil or getter/exception/reentry order; changed dependency/host/raw-entry refusal;
stack growth; changed parallel-transfer RHS observations; an unproved escape;
or no repeatable execution improvement against direct unfused. Reject source
promotion on source type-check refusal, missing temporary scope or changed
stronger scalar-island selection. Low/no allocation benefit would favor stopping
this ablation before broader source work.

Root owns all derivation execution, controls, acquisition, profiles and timing.
Start with existing checked06 diagnostic complete-stage/refusal suite, compare
clean benchmark copies at sizes128/512, then source controls only if useful.
Counter modules are never timed. Keep exact Phase40 baseline bytes and source/API
identities; clean derived output is a manual prototype, not checked emission.
