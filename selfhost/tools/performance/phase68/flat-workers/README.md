# Phase68 flat-worker prototype

`flat-v2.patch` is a source-only proposal, SHA256
`78bfbf12d1a45e6ea79337319e762bc0c4436e5c6eea3c9e3e59f4f516459759`.
It adds 218 physical lines across six production paths, including one 212-line
module. `flat-v2.json` binds the exact before/after sources. The frozen basis is
arity-v1, shared arity extraction, eta-adapter-v2 and the prefix affine fix.
The earlier composition and its original basis are preserved in `draft-v1`.
No compiler/native/Node target was executed by this owner.

The [registration](../../../../../experiments/phase68/P68-005-flat-workers.md)
precedes source application. Source motivation and rejected narrow alternatives
are in the [audit](../../../../../research/phase68/upstream-native.md).

## Result protocol

`nc_lower` retains its public scheduler entry and calls `nc_lower_to` with an
explicit `NC_Target`. Scheduler mode uses the previous continuation behavior.
Worker mode uses `NC_Destination` with a word destination, optional join label,
current definition and parameter list, and a tail-position flag.

An ordinary worker has the C signature:

```c
INLINE Term NF_name(Env e, bool seq, Term* nf_out, Term parameter, ...);
```

Return zero means fail-stop/control-flow failure; return one means the value was
assigned. Runtime error state remains authoritative, with the existing ordered
checkpoints and bounded self-loop polling. The result word may itself be zero.
All constructors and arrays retain the boxed one-word value ABI.

A let creates a scoped C RHS whose terminal paths assign its destination and
jump to the continuation label. The body uses the same live environment and
sharing logic as the scheduler path. A self-call may become `goto nf_again`
only at the worker's return destination; argument expressions are held in fresh
locals before parameter reassignment. Local destinations clear the tail flag.
The worker has no `sp`, continuation frame or scheduler registers.

## Admission and adapters

The common lowerer generates provisional worker bodies. Escaping closures or
matchers, dynamic/partial/bang calls, foreign/absent calls, parallel lets,
scheduler-only IR and non-tail self calls reject the candidate. Native
primitives use the same `N_Emitted` expression producers as the prefix step.
Nat chain lowering uses the generic common matcher in worker mode, avoiding an
accidental path back into scheduler lowering.

Starting with no admitted definitions, each pass admits only successful
candidates whose non-self dependencies are native primitives or already
admitted workers. Mutual recursion cannot enter this fixed point. Ordinary C
stack depth is bounded by the admitted call DAG; it is not zero, and no separate
absolute stack-byte/depth cap is claimed.

Existing scheduler segment identity, argument and result metadata are retained.
Only an admitted exact worker entry receives a host adapter. `#if !DEVICE`
calls the worker; `#else` contains the prior scheduler body. Host worker
prototypes and definitions are also guarded by `#if !DEVICE`. Bang-referenced
definitions are excluded from candidate generation. The runtime file is
unchanged.

## Review and first checks

Independent native-owner source review found no blocker in destination
assignment, failure status, self-tail staging, shared matcher ownership or the
admission graph. Static source inspection found balanced delimiters, no duplicate
or missing combined compiler definitions, and exact current-basis hashes. This
is not Bend typechecking or C compilation. The first checked build may still
expose source-affinity, syntax or backend constraints.

After root-owned emission, inspect generated source on CPU0:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase68/flat-workers/check-workers.py   <program.c> --require-workers --out <fresh-receipt.json>
```

This gate rejects scheduler macros or unbound sentinels in worker bodies,
undefined worker callees and C recursion cycles; it reports the call DAG depth.
It neither compiles nor executes the program. Run focused one/four-thread
ownership, diagnostics, recursion exclusion, partial/bang/foreign controls and
numeric/array independent digests before performance conclusions. Device code
is preserved by construction but still needs the appropriate qualification.

`build-proposal.py` performs data-only source composition from `baseline` into
`candidate` and creates patch/hash metadata; it does not execute a compiler.
Do not rerun it after closure of this proposal without creating a new version.
