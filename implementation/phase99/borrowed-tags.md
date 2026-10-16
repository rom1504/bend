# Borrowed tag projection: exact obstruction and bounded design

Phase98's own backend borrows the String equality walk but still consumes the
`KTerm` projection and retains both arguments at the public equality boundary.
The obstruction is an intentionally restricted observer language, not a missing
permission bit. A bounded general extension is plausible, but it is not a small
switch or a safe removal of generated reference operations. This investigation
stops at source analysis and design; it prepares no compiler candidate.

The [source audit](../../selfhost/build/phase99/borrowed-tags-audit01/report.json)
passes 18 static assertions against complete pinned inputs. Its
[method](../../selfhost/tools/performance/phase99/borrowed-tags/audit.py) records
exact definition bodies and C spans without executing a compiler or program.
The source is Phase98 `2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051`;
the two C files are upstream-generated `21c0e6b6…` and self-generated `6ae1675a…`.
These observations extend the [Phase98 mechanism audit](../phase98/own-backend-mechanism.md)
and [matched stage analysis](../phase98/origin-stage-profile-comparison.md).
They do not establish a new speedup, runtime-safety result or qualification.

## What actually differs

The upstream C's `spin_2` obtains the `KTerm` fields with `term_peek` and passes
the tag to the borrowed equality walker `spin_3`. It borrows the term, but still
owns and disposes the key argument. The enclosing `spin_1` retains the key and
`spin_7` finally disposes the original term and key. This is a per-parameter
ownership decision, not a claim that the complete tag route has no RC work.

The upstream equality wrapper `spin_5` calls the borrowed walker and then its
owning finisher `spin_6`, without a `term_keep` of either input. In the own C,
`p88_string_eq` retains both arguments before calling the ordinary equality
entry. That entry may redirect shared roots through its observer adapter, which
disposes the temporary owned references after observation. The public finisher
disposes the remaining references. The extra boundary is visible even though
the borrowed loop itself is already active.

The own `p98_tag_eq_read` has `ctr_take`, `spare_free` and unused-field disposal;
there is no `$observer.p98_tag_eq_read` or `$observer.p88_string_eq` worker.
Removing those consuming operations locally would break its current owning
calling convention. An owning adapter or a proven caller-held root is required.

Upstream's `comp.ts` starts eligible boxed parameters borrowed and emits until
its ownership facts stop changing. `node_fields` associates boxed child words
with the parent's borrowed root. `val_own` propagates that root when a child is
passed onward, and marks it owned when the child enters an owning position.
`emit_put` applies this same gate to returns. `emit_args` accounts for subsequent
uses, duplicate arguments, nested argument evaluation and callee borrowing;
the fixed point removes ungrounded borrowing assumptions. That general root
tracking explains why projection and interprocedural borrowing work upstream.
It is substantially wider than the selfhost observer analysis.

## Exact selfhost refusals

`nol_root_ctors` accepts exactly two constructors, with one nullary arm.
`nol_root_fields` accepts scalar payloads plus exactly one recursive field of
the same plain owner type. `KTerm` instead has three non-nullary variants,
String payloads and applied List fields. The actual widths are **8, 8 and 5**
for `KTerm`, `KLambda` and `KLiteral`. They already fit the existing width-eight
limit; an earlier investigation message incorrectly counted `KLambda` as nine.
There is no reason to widen that limit for this task.

Schema acceptance would still be insufficient. `noa_reference` residualizes
recursion only to the function currently being analyzed. It expands ordinary
helpers, then refuses a helper already on its stack. Thus an analysis of
`p98_tag_eq_read` or `p88_string_eq` reaches recursive `p88_string_eq_go` and
cannot retain its call. The residual language has Return, Loop, Let, Match and
Error; `no_emit_let` accepts scalar primitives or atoms, not arbitrary calls.

The two literal tag branches add a separate boundary: their `"Lam"` and `"Lit"`
arguments become virtual constructors during symbolic analysis. These are not
runtime atoms that a borrowed worker can receive. Existing literal stepping
can potentially specialize those short calls, but the helper-cycle refusal
currently stops repeated expansion. Dropping the cycle check alone would still
refuse the generic dynamic String recursion at the depth limit.

## Smallest bounded implementation direction

Keep checked permission, existing owned adapters, runtime operations and the
unique-input fallback. Do not add candidate-name exceptions. The implementation
can be staged so the first stage tests the redundant equality boundary without
changing aggregate layouts:

1. **Calls between proven scalar observers.** Extend the route state with a
   private registry created only after successful worker/adapter admission.
   Each entry must carry the exact parameter types, root slots, scalar result
   type and worker identity from the checked plan. A ready name or a user book
   marker is insufficient. Extend `NO_Context` and plan construction to receive
   this registry. At a saturated call, require each root actual to be a concrete
   borrowed atom with a live entry-root ancestry and exactly matching supported
   type; validate scalar actuals with the existing scalar checks. Emit a new
   scalar-result call node, preserve argument demand, and retain the current
   refusal for ordinary, foreign, bang, dynamic or ownership-taking calls.
2. **Validate and emit the call.** Supply the same trusted registry to emission;
   validate arity, result type, freshness and all atom bindings. Call the private
   borrowed worker directly, never its owning adapter. Use the existing worker
   success/result convention and error checks, then bind the scalar result.
   Add the callee to `NC_Code` dependencies so `nf_admit` checks it. Admission
   must depend only on already admitted callees. A bounded retry/worklist can
   remove source-order dependence; exhausted chains and cycles remain refusals.
   This stage could admit the public String equality wrapper using the existing
   String schemas and original-root cleanup. It needs its own C and timing gate.
3. **Opaque aggregate roots.** Generalize the root schema to a bounded set of
   checked, nondependent user constructors with zero or 2–8 physical fields and
   at least one boxed arm. Preserve `nol_owner`, telescope specialization,
   indexed/dependent refusal and the existing native-representation exclusions.
   Scalar enums must remain scalar. Plain supported field types may be read or
   passed to proven observers. Applied or unsupported fields stay opaque: they
   may be ignored or used to prove unchanged reconstruction, but never matched,
   treated as scalars or passed to a borrowed callee. Do not reuse the current
   `nol_type_names` erasure to identify `List<KTerm>` with `List<String>`.
   A separate opaque marker avoids pretending that an erased owner name is an
   exact type. The existing `term_peek` match emitter can serve 8/8/5 layouts.
4. **Bounded virtual-argument specialization.** Prefer a residual borrowed call
   when all actuals have validated runtime atoms. Otherwise retain symbolic
   expansion for virtual constants. A general helper expansion may permit a
   repeated name while still charging the existing depth-eight/global-4096
   budgets; exhaustion must return refusal, with no partial plan admitted.
   This can potentially unroll three-character tag literals without static
   allocation or new borrowed-constant lifetimes. Validate actual acceptance
   and demand preservation rather than assuming those budgets suffice.

The first two steps already touch analysis, plan plumbing, routing and emission.
The latter two touch schema identity and symbolic recursion. They are a useful
bounded project, not an exact source patch ready for the current scalar cycle.
No patch recipe is marked executable and no partial schema-only candidate is
offered as if it enabled production tag borrowing.

## Safety obligations and refusal controls

Every borrowed child must remain rooted in an owned entry argument until all
synchronous borrowed calls return. A call can return only a proven scalar; the
existing adapter remains responsible for returning or disposing original roots.
Aliased roots and children are allowed only as read-only aliases, with the
original owning handle accounting unchanged. A direct call to an adapter would
dispose borrowed inputs and is therefore forbidden. Preserve the lazy
`noa_below` fix in the exact Phase98 source.

The [control specification](../../selfhost/tools/performance/phase99/borrowed-tags/controls.json)
defines future cases; none has been executed in this investigation. The key
negative cases are returning a child after disposing its parent, storing a
borrowed child in a returned closure or constructor, passing it to an owning or
foreign call, interpreting an opaque applied field as another instantiation,
forging a private worker marker, and admitting cyclic callees without a complete
proof. Non-tail recursive results, indexed layouts, unary packed constructors,
budget exhaustion and disabled permission must retain their refusals.

Positive controls must include all three real `KTerm` variants, same/mismatched
keys, unique and shared roots, two arguments aliasing one root, and a tag also
retained independently of its parent. Compare complete returned values and
retained aliases after the call, not only the Boolean result. A child-escape
program should preserve behavior through ordinary owning fallback; refusing its
observer plan must not reject the source program itself.

The first falsifying target gate should inspect selected residual plans and C:
the public equality borrow worker must have no retain/drop boundary; the tag
borrow worker must use `term_peek` for the parent and only certified borrowed
callees. Adapter root cleanup must occur after the final read. A missing route
is a negative result, not permission to delete C operations. Root-owned checked
B1, focused safety controls and a paired screen precede any B2/full-self or
broad qualification. Runtime atomic access changes remain a separate project.
