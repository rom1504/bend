# Read-only observer emission and owned adapters

Status: source-only integration proposal. No production edits or target runs.
This implements the emission half of the
[bounded observer design](../phase69/root-preserving-observers.md); the
independent origin/identity analysis must pass its gate first.

## Integration boundary

Keep ordinary native workers, admission, scheduler segments and product workers
unchanged. A function rejected as an ordinary worker can still qualify as an
observer: its source recursion may reconstruct constructors after returning,
while the proved residual recursion becomes a self-tail loop. Therefore an
observer must not depend on admission of the original function's NF_Worker.

The compiler creates a separate private `NF_Worker` named from a fresh internal
`$observer.` identity, with the original ordered live parameters, one immediate
result in `nf_out[0]`, and `Absent` result shape. The observer's only dependencies
would be scalar workers already present in the final ordinary admitted closure;
the v1 proposal refuses NFCall entirely and needs only existing scalar NOp.
Rejected optional plans leave the complete previous worker/segment lists alone.

A second private `$observer.adapter.` worker owns the roots and lowers the
wrapper with ordinary `nc_lower_to`. This isolates normal lowering's labels in
its own C function and avoids duplicating constructor emission. The scheduler
hook calls this owned worker and returns its single boxed result. It must not
insert ordinary wrapper gotos directly into the shared scheduler switch.

First run existing `nf_wrap_segments`. Then wrap the matching original/direct
entry segment with the observer adapter. Its fallback is the **entire resulting
segment body**, including any ordinary host-worker route. Selection is:

```c
#if !DEVICE && NATIVE_READONLY_OBSERVERS
/* owned-root adapter */
#else
/* exact previously selected segment body */
#endif
```

`ne_segment` emits `ne_take(params,frame)` and `WL_OPEN` before segment body.
The adapter must use the already captured parameter-local names returned by
`nf_segment_args(params)`, never `r0`, `r1`, etc., which `WL_OPEN` may shadow.
This preserves the pre-existing scheduler entry error check. Exact entry name
and ordered live arity must match the plan; do not patch continuation segments.

The new permission is supplied by the checked compilation boundary. Its proof
must exclude external observers/mutators of retained identity, not merely reuse
the scalar-array certificate. Root and review lanes own this admission gate.
Raw `nc_compile` and device compilation use the original bodies. A user book
marker, synthetic-looking definition name or annotation does not grant it.
Root will thread an explicit Bool from checked compilation through the compiler
planning pipeline; raw compilation passes False and skips observer planning,
worker creation and adapters entirely. The C macro is an additional routing
guard, never the authority: caller-supplied runtime text cannot activate a
prebuilt observer. A separate reachable-foreign audit permits only actual
native primitives and the hash-audited Base args/print/now wrappers. Root types
exclude arrays without unnecessarily excluding unrelated arrays in the program.

## Plan shared with the analysis lane

The provisional v1 plan is one record, backed by existing KTerm atoms and a
small residual grammar. It carries:

| Field | Contract |
| --- | --- |
| owner | Original exact definition identity; fresh private worker name checked against the book. |
| params | Ordered live `{id,kind}` bindings; kind is borrowed root descriptor or immediate scalar layout. |
| roots | Original parameter indices, distinct and mapped exactly once into wrapper. |
| descriptors | Identity, instantiated owner, actual constructor identity, live width, ordered field kinds, and read storage mode. |
| wrapper | Existing Ctr tree using only original root Vars and fresh scalar `resultId`; at most two shells. |
| resultId/resultKind | Fresh ID and checked immediate scalar representation. |
| residual | Ordered statements and terminal branch/return/self-tail transitions below. |
| dependencies | Exact scalar worker names and checked immediate result facts from the final admitted closure. |
| fresh | Next counter after generated runtime IDs, not an absolute binder ID. Owned wrapper lowering verifies a free 64-ID span against all formals, result and wrapper, and stays within it. |
| bounds/refusal | Visits, expansion depth/nodes, fresh-ID collision result and deterministic refusal reason. |

Residual nodes have these exact tentative encodings:

| Node | KTerm encoding | Meaning |
| --- | --- | --- |
| Return | `NO_Return`, kids `[atom]` | Return one immediate word. |
| Let | `NO_Let`, ix=binder, kids `[value,body]` | Evaluate scalar atom, NOp, or admitted scalar NFCall once, in order. |
| Match | `NO_Match`, name=descriptor identity, kids `[scrutVar,NO_Fields(Var binders),hit,miss]` | Test actual constructor and borrow its descriptor-qualified fields only in hit branch. |
| Loop | `NO_Loop`, kids=ordered argument atoms | Simultaneously update observer parameters and jump to `nf_again`. |
| Error | `NO_Error`, name=`ERR_FIDS` | Preserve explicit match failure. |

Atoms are bound Vars, existing NWord literals, or validated immediate nullary
constructor constants. Every scalar evaluation, including an unused result
that may fail, remains a statement. No residual node allocates a box, owns a
box, calls the scheduler, suspends, captures a cursor, or returns a cursor.
Scalar helper calls require both immediate arguments and an immediate result;
an ordinary admitted worker alone is not sufficient proof of that property.
They remain refused in the first source proposal. The actual initial Map and
String residuals need only existing native scalar primitives.

## Reuse existing code rather than duplicate the backend

The observer emitter returns `NC_Code` with no continuation segments and a
normal dependency list. `NF_Worker`, `nf_prototypes`, `nf_bodies`, `nf_inline`
and their `err_spun` envelope remain responsible for private C functions.
Use existing `NC_Binding{id,word}` only as a lexical name map: every value in
this map is borrowed or immediate. Never pass it through `nc_prepare_env`,
`nc_keep_uses`, `nc_destructure`, `nc_lower_to`, or ordinary ownership lowering.

Reuse `nd_scalar_word` for scalar primitive expressions and `nc_condition` for
the descriptor's approved constructor predicate. Keep local scalar variables
as `Term` initially; source U32 arithmetic still uses the existing explicit
primitive casts, and Nat widening never changes because of C integer promotion.
No new scalar arithmetic catalog or special function-name rule is required.

Borrowed match reads are explicit and descriptor-qualified:

- **Boxed**: compute `Loc no_loc_N = term_peek(e,cursor)` once in the hit
  branch, then load `e.mem[no_loc_N+i]`. Require live width at least two and the
  checked concrete layout; RFC and immutable static storage follow existing
  `term_peek` semantics.
- **Nat successor**: one field `cursor - 1`, only after nonzero predicate.
- **Char identity**: one field `cursor`; this is the existing Chr representation.
- **Nullary**: no field read; use the existing predicate for its scalar or
  constructor representation.

No broad call to `nc_field_word` is allowed: U32/F32 Word views allocate, arrays
have different lifetime/storage rules, and a unary user constructor may be
packed. Unknown modes fail optional compilation rather than emitting a guess.

Self-tail transitions reuse `nf_self_temps` and `nf_self_moves`. Every right-hand
side is saved before any formal parameter is overwritten. Descriptor/type
compatibility is checked for all transition slots; moving two compatible
cursors must not accidentally read an already overwritten first slot. This
adds no C recursion and never writes the adapter's retained root locals.

## Adapter ownership and public result

The adapter stores each owned input root in a stable `no_root_N` local and passes
copies of those Term words as borrowed cursors. Roots stay alive until the
observer returns, including through RFC wrappers and aliased/shared tails.
Two root parameters require the caller's original two ownership references;
the pass creates none. Observer locals never call keep, seal, sink, ctr_take,
spare_free or heap_free.

After success, bind the scalar result and construct the original wrapper from
the retained roots using ordinary `nc_constructor_value`/owned lowering. Do not
hand-write seal/allocation policy. Each retained root occurs exactly once in
this wrapper, and its constructor order is the original template order. The
wrapper may allocate and seal; only the read-only worker forbids those actions.
After transfer the adapter returns the same one-word boxed ABI with `ne_ret`.
Only the owned wrapper environment may enter ordinary native lowering.

Concretely, the owned private adapter lowers the wrapper to
`NC_Destination{["nf_out[0]"],Absent,...}` and returns its success bit. The tiny
scheduler hook calls it, checks success/shared error, and uses `ne_ret` for the
boxed word. The adapter independently checks one or two distinct valid root
indices, a fresh result ID, exactly-once wrapper leaves, at most two actual
constructor shells, no continuation segments and collision-free fresh IDs.

The current native mapping is `nc_id(n) = 4294967295 - n`. The plan's `fresh`
is this descending-ID generator's next **counter**, after every parameter,
result and residual binding. This differs from the primitive-wrapper range
`4000000000 + i` and from the Python reference diagnostic's absolute IDs.
Require `fresh <= 294967231`; even `fresh + 64` then maps to at least
4000000000, keeping the entire lowering span above admitted source IDs without
U32 wrap. Check collisions against all formal parameters, including unused
scalar parameters, as well as the result and wrapper; require the returned
counter to stay within that span. The analyzer confirmed it threads this
counter through both branches rather than restarting it per branch.

## Error and cancellation policy

Keep the original scheduler `WL_OPEN` check before invoking the observer.
The existing `nf_bodies` envelope supplies the entry/self-loop `err_spun` poll.
Each retained scalar statement follows the ordinary native join convention:

```c
Term v_id = scalar_expression;
if (!seq && err_seen(e.mem)) { return 0; }
```

Scalar worker calls retain their success test and the subsequent join check;
the observer does not replace a failing/dead scalar computation with its later
result. `NO_Error` preserves the original match error. On observer success,
check `!seq && err_seen(e.mem)` before constructing or publishing the wrapper,
so short observers do not bypass shared asynchronous failure.
The v1 `NO_Return` also checks the same nonsequential error state before writing
its scalar result. The owned adapter checks before and after the observer call;
the unchanged NF envelope still owns periodic self-loop polling.

On failure propagate zero using the existing fail-stop convention. Do not add
ad hoc drops of retained roots: ordinary worker early-error paths also abandon
their remaining ownership to request teardown. This policy requires an explicit
error/cancellation control; it is not a claim that the saved-C prototype already
qualified asynchronous behavior. Source sequenced operations and non-tail
effects must not disappear during origin simplification.

## Integration order and review gates

1. Analysis-only query accepts both witnessed shapes and unrelated user ADTs,
   with changed-field/effect/non-tail/packed-layout refusals. Generated C stays
   unchanged during this gate.
2. Add one small observer emitter module and the independent adapter hook.
   Reuse existing worker envelope and ownership implementation; gate checked
   host selection explicitly. Exact fallback and failed-plan preservation are
   asserted in source controls.
3. Verify empty/early exits, static/RFC/shared-tail/two-aliased-root inputs,
   unused failing scalar evaluations, high-word scalar values, simultaneous
   loop moves, pre-existing shared errors, scalar-helper errors and cancellation.
4. Only then measure against the Phase69 installed/current selected baseline.
   Check allocation and keep/seal counts to show reconstruction was removed.

Initial emission budget is roughly 100–160 Bend lines for residual code and
50–90 for adapters/hooks/validation, dependent on the finalized plan accessors.
This is a scope estimate, not a promise. If it starts needing general owned
values, scheduler continuations or boxed helper results, stop and revisit the
binding-provenance design instead of growing a second general backend.

The current source proposals in
`selfhost/tools/performance/phase70/observers-emitter/` are 129 lines for the
read-only emitter and 102 for owned adapter helpers. They are unparsed and
untested, with only source delimiter balance checked. This is not a production
size/performance/conformance result. Independent review confirms the ownership
separation but requires typed plan validation: structural emission checks alone
do not prove scalar returns/operands, compatible tail slots, correct descriptor
owners or canonical numeric atoms.

The source-only integration proposal is now concrete in
`observers-emitter/integration-v1.patch`, paired with a 97-line late-routing
module and a derivation receipt recording the exact five source bases. It
threads both the checked Bool and prefiltered names through final worker
stages. Plans are evaluated only after ordinary retry/admission; a direct-entry
index excludes unused or incompatible segments. Both private workers must be
admitted before the route is retained. Name collisions with the book, ordinary
workers, product workers and earlier observer pairs decline the optional plan.
Raw False skips every observer-specific scan except the constant-time empty
route wrapper. This remains an unparsed proposal pending root's source and
runtime gates, not an installed optimization.
