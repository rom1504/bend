# Independent source review: reachable bangs and partial closure factories

Reviewed proposed changes in `book.bend`, `flat.bend` and
`../closure-factory/direct-v1.patch`. This is source inspection, not checked
compiler or execution evidence. No production source was edited by this lane.

## Reachable bang metadata

No source-level blocker found. The new walk uses `nc_live_names` with the same
`main` root and `lookup` semantics already used by native emission and foreign
path discovery. Each definition is interpreted through `nc_definition`, so
native intrinsic bodies, foreign wrappers and erased ordinary definitions have
the same runtime reference boundary. Lambdas are traversed recursively; calling
through a stored closure does not hide references in its defining body. The
erased annotation/type subtrees correctly cannot introduce runtime bang sites.

The native emitter additionally applies `nc_compact`; the shared reachability
walk does not. Thus some syntactically reachable but compacted-away references
may remain conservatively marked. This is a potential missed optimization, not
permission to drop any remaining runtime mark.

Raw books need tests because the old scan visited every list entry and the new
scan resolves only selected names. First-match definitions, a shadowed later
duplicate, missing names and dead erroneous definitions are explicit controls.
The expected intentional change is metadata for dead code; evaluation results
and established live-reference diagnostics must agree. `nc_compile` still
checks no-main, foreign IO-main, ownership and binder range before this walk.

The change does not analyze arbitrary C code embedded in a foreign effect.
That is appropriate: such code cannot spell an otherwise undefined Bend FID
and establish it as a new language root. Callback values reachable through
foreign argument expressions remain in the normal reference closure. Existing
foreign callback registration tests must still run because they test the
runtime ABI separately from this reasoning.

Use `controls/README.md` for seven source and five raw controls. A native CPU
result alone is insufficient to establish preservation of live offload marks;
check `BANGS` and the reached worker's bit in `FID_FLAG_T` as well.

## Partial closure factory bypass

No blocker found in version 1's intended domain. Admission requires an ordinary
named definition, a positive proper prefix, and a complete syntactic leading
live lambda telescope equal to runtime arity. Foreign, intrinsic and explicitly
bang-marked heads retain their prior path. Looking only at a declared function
type would be unsound for raw demand/error order; the actual body condition is
essential and must stay.

The replacement sequences captures in source order before constructing the
remaining lambdas. It reserves the entire arity's temporary binder range before
lowering, reuses ordinary closure capture/drop handling and eventually calls the
existing full-arity direct entry. It does not assume that an argument is cheap,
duplicable or unevaluated just because it becomes a capture. Multiple missing
arguments preserve the curried closure ABI.

Required controls are the closure lane's stored/erased, shared captured String,
multiple missing and mixed ordinary/bang inputs, plus existing overapplication,
unused malformed argument, error-order and foreign callback controls. If a
definition is bang-reachable at another call site, its ordinary partial call
still targets a direct entry created by `nd_extend`; verify this mixed case in
generated C rather than assuming the ordinary-only entry constructor ran.

The review does not claim full compiler soundness, GPU qualification or final
promotion. It identifies narrowly justified transforms and observable boundary
tests for root's serial guarded lane.
