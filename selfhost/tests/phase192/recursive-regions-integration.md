# Experimental H-plan structured x86 worker

`recursive-regions-experimental.bend` consumes the existing `p114h_plan`
certificate. It adds no region recognizer and does not relax the original
readiness, source/case hygiene, arity, incoming/result, node-budget or eight-case
closure gates. H hygiene is already enforced by `p114h_plan` and closure;
there is no separate `p114h_hygiene` function.

Assemble from the **full canonical declaration inventory** with the new module
and `x192h_public` root. The planner-only probe snapshot omits QBE-emitter-only
`p114h_prefix`, `p114h_rename` and `p114r_symbol`; this prototype intentionally
reuses those canonical factories instead of duplicating them. Root's
`prepare-experiment.py --module ... --root-symbol x192h_public` plus maintained
source assembly supplies the complete dependency closure.

## Integration entry and precedence

```text
x192h_public(segment, index, ids, ready, available) -> X181Output
x192h_public_planned(segment, ids, available, plan) -> X181Output
```

The ordinary entry queries only `p114h_plan(segment,index,ready)`. Do not pass
the extended callable `view` in place of the original `ready` in this first
prototype. The planned entry is useful for finite compiler-data controls;
production callers must obtain its plan from the unchanged checked planner.

Root's `x181_program_public` override must retain the existing raw-symbol check
and invoke the new entry only under the selected experiment flag, nonzero
context mode, and absence of a complete public direct worker:

```text
function = p111v_get(direct,name)
completeDirect = String.eq(dk(function),"P113Direct")
                 && U32.is_eq(ix(dv(function)),1)
```

`p124r_public` gives complete direct workers precedence over original H;
`p134e_public`/`p149r_selected` bypass these selections in mode zero. Keep
the existing `x181_segment(segment,ids)` route for those cases and all refusals.
The new entry checks generated setup, worker body and adapter with
`x181_program_stmts(...,available)`, plus x86 name hygiene, before emission.
Any unavailable ready-helper symbol or ordinary emission error selects the
original segment. It never publishes a partial worker/adapter pair.

## Exact execution state and ordering

The private symbol is the canonical `p114r_symbol(name)`. Its machine arguments
are `state`, the ordered H-plan parameters, `p114h_mode`, `p114r_depth` and
`p114r_value`. The public adapter reproduces the original ordered
`p111_rt_reg_get` reads, initializes the final three arguments to zero, calls
the worker, stores its one result in an eight-byte buffer, and invokes the
original one-result `p111_rt_return` transition.

Setup allocates the ordinary scratch buffer and one separately named 2048-byte
scratch buffer for each case, using the unchanged `p114h_prefix`/`p112f_name`
factories. These allocations run once per worker invocation.

Mode zero executes the descend body; mode one executes unwind. `P113DAgain`
loops locally. Its values exclude leading `state` because `x181_tail_args`
already removes that invariant formal. It transports the ordered parameters
plus mode/depth/value through existing parallel-move/snapshot machinery.

| H node | Ordered structured behavior |
| --- | --- |
| Scalar / If | Original scalar or recursively preserved branch |
| Descend | Original frame statements; increment depth; original argument statements; snapshot every scratch argument; Again in descend mode |
| Again | Original argument statements; snapshot every argument; Again in descend mode, preserving depth |
| Result | Again in unwind mode with the actual result word |
| Failure | Original failure statements and terminal return |
| ResumeReady | Original frame statements; increment depth; original helper call statements; Again in unwind mode with helper result |
| PushFrame | Original frame statements; increment depth; continue |

The unwind sequence matches QBE: compare depth against zero first. Zero depth
returns the worker value **without touching the caller's continuation frame**.
Otherwise decrement depth, `stack_pop(1)`, then `stack_get(0)` to recover the
popped function id. Compare against the closed cases in their original order.
For the selected case, pop its capture count when nonzero; bind the optional
pop-result local to zero; fetch each popped capture in ascending order; bind
the case result; then execute the canonically renamed case body. Unknown ids
retain QBE's `p111_rt_fail(state,4)` followed by return.

The runtime API deliberately reads popped storage after moving SP. Reversing
pop/get order would be incorrect. Frame statements are retained and can use
the existing late runtime expansion; this prototype does not invent a second
stack layout or frame ownership rule. It creates no recursive native call to
its own worker. Existing admitted ready-helper calls retain their original
single-word ABI and runtime-stack contract.

## Direct worker controls

For a trusted fixture `P114HPlan{valid,params,body,cases}`, construct the exact
same worker under a convenient C-visible test symbol with:

```text
x185_function_setup(symbol, x192h_formals(params),
  Con{P113DScalar{N111Alloca{"scratch",2048,8}}, x192h_buffers(cases,0)},
  x192h_worker_body(params,body,cases), ids)
```

The C caller passes zero mode/depth/value after the ordinary parameters.
This bypasses only the public `rt_return` adapter so the observer can check
the external SP, sentinel continuation, registers, rn/next/seq and returned word
directly. It exercises the same setup/body factories as the public prototype.

Require source checking, general-H and ready-helper controls, depth-zero
sentinels, deep runtime recursion, multiple case dispatch, capture restoration,
argument swaps, ownership/shared values and original-fallback controls before
measurement. Compiler-data admission, generated runtime output and stack-space
behavior are separate evidence. The six ordinary source controls supplied by
the other agent require actual H-hit confirmation; source shape alone does
not prove admission or refusal.

No compiler or target job was run by this implementation agent. This is an
experimental consumer of checked plans, not a newly qualified compiler or
whole-compiler correctness claim.
