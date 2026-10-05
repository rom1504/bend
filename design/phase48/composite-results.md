# Composite result adapter: original handles first

Hypothesis: a scalar-input root returning a flat canonical user record of arrays
can reuse the existing complete private region and restore its public record shell
once. It need not change array representation to remove generic curried dispatch.
The first candidate retains original Array handles throughout private execution.
Raw-to-public wrapping and identity registries are deliberately outside this slice.

Concrete falsifier: a renamed result with the same handle in two fields must
return `result.a[0] === result.a[1]`, and two separately allocated handles must
remain distinct even with equal elements. Mutation through a returned handle and
through an exported source helper must reach the same backing storage. A constructor
field containing an ignored failing read must fail in the original order. A changed
host allocation/prototype hook must select the old path with the same full trace.

## Admission

A positive-arity lambda root has only canonical scalar inputs. Its result is a
flat, nonnative, monomorphic, single-constructor user record with 1–32 live fields;
each field is a canonical scalar or an existing canonical local Array type, with
at least one array field. No nested record, function field, dependent telescope,
public array parameter, generic callback, or native constructor escapes.
Reuse the existing bounded complete region planner, its local types and helper
proofs, plus the closed executable-node audit from array-view. Require Array.new
among the original guarded native dependencies. All arrays originate inside the
root because inputs are scalar and the complete graph has no unknown producer.
Unknown syntax, recursion shape or exhausted fuel refuses optimization.

## Execution and boundary

Use the unflagged book and original Array.new/get/set emissions. Handle creation
remains at its source allocation site; reads/writes carry and return those same
objects, preserving alias identity without reconstruction. Private user records
remain existing local vectors. The final root computation returns its vector;
one `ctor(originalConstructorName, vector)` constructs the normal public shell.
The public tag, `$`/`a` own fields, field order, backing handle objects and standard
prototypes match ordinary runtime construction. There is no per-array wrapper,
copy of backing data, proxy, freeze or persistent ownership state.

The final shell is created only after the private body completes. Original public
forcing traverses final constructor fields in order; private vector evaluation
must retain that order and all demanded failures. Reuse existing statement/vector
and self-tail lowering, without moving writes or reads. Flat output avoids a
recursive materializer and repeated-record identity problem. Single public output
means an internal private record's identity cannot be observed before escape;
array handles, whose sharing is observable, are never replaced.

Before canonical-input/dependency checks, use fresh arrayViewHostGuard with its
full host set. Keep the original root and helper dependency guard. The current
active-proof refusal remains. Failure selects the exact original generic body;
there was no previously eligible composite region root, so no earlier private
selection is skipped. Exceptions do not open a region proof or mutate runtime
mode. No reusable permission and no workload-name or loop-count threshold exists.

## Integration and validation

New module `selfhost/src/back/js/array-result.bend` owns shape, signature, complete
plan and final shell emission. Root integrates its import and one selector fallback
when the existing region root plan is empty. Shared region/emit/tree/runtime files
are not edited by this agent. Array-effect ownership can reuse local-array type
proofs without selecting raw representation at this public boundary.

Root runs checked emission then renamed sharing/distinctness/zero-trip/order/error,
post-return mutation and public-source-helper controls. Host changes, Array.new
replacement, numeric setters and reentry must execute identical old traces or
refuse. Require activation markers on selected renamed and maintained row roots,
and absence on nested/public-array/function/dependent output fixtures.
Only after semantic controls: generic row canary and matched repeated timing;
no gain estimate follows from Phase47 scalar-array results. Record generated size
and compiler work, since additional private declarations still cost resources.

This is a handle-preserving bounded adapter, not a general public aggregate ABI,
raw-array escape permission, or proof that all composite return types are safe.
