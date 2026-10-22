# Independent review: conditional preparation before local descent

Reviewed `selfhost/tools/performance/phase126/scalar-resume/model.bend` and its
13 finite controls against the selected Phase125 source and Phase124 frame
lowering. No target or compiler was executed by this reviewer. No semantic
blocker was found in the proposed admission extension.

The only hook changed is `p114h_scan_frame` for an own-function descent.
`p126r_arguments` still requires the original `p112t_tail` suffix: exactly one
store per argument at its original scratch offset, the exact owner/arity jump,
and its matching terminal return. The new prefix can contain nested `N111If`
whose arms contain only previously admitted private-safe operations. A branch
cannot return, change frames, read the scheduler register bank, make an unknown
call, mutate state directly or assign a pointer. The existing original IR
verifier remains responsible for condition types, definite assignment and
runtime-helper argument validity.

The transformation preserves both arms and their order. The old
`p114r_without_transition` removes only the authenticated final jump/return;
it does not recursively remove operations inside the newly permitted branch.
`p112f_rename` recursively renames branches, and `p111q_stmts` emits all
preparation before `p114h_snapshots` captures every argument slot and before
parameter rebinding. Original capture stores/frame creation and depth increment
remain before preparation. No ownership operation is moved across a frame or
deleted. The existing H owner/case size limits, complete continuation closure,
local-name hygiene and original fallback remain prerequisites. Old R/G and
nonself ready-helper admission are unchanged.

Terminology matters: inherited `p112t_scalar_safe` permits allowlisted
keep/sink/constructor/take/primitive helpers as well as arithmetic, with
`p112t_runtime_args` validation. These are nontransitioning private-safe
operations, not necessarily pure arithmetic. Their exact execution is retained.

The 13 controls cover old successes, simple/nested conditional preparation and
important refusals; the branch-preservation control checks retained node count,
not full structural equality. An ordinary unrelated recursive control with a
retained owning capture, argument permutation and a conditional preparation
on both outcomes would strengthen executable transfer evidence. This is a
recommended control, not a claim that it was run.
