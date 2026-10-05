# Caller-side intrinsic emission: bounded next experiment

Status: read-only proposal, 2026-10-05. No compiler change, target execution,
or isolated gain is established here. Wait for the complete candidate05 corpus
comparison before deciding whether to run this experiment. The unresolved F32
NaN/table case remains a separate correctness issue.

## What already exists

[`primitive.bend`](../../selfhost/src/back/js/direct/primitive.bend) contains
89 `JDPrimitive` templates ported from pinned upstream
`018751270e800bc222a93dad7f257083ee53a5f7`. They cover U32/F32/Nat operations,
Bool/String operations and native Array operations. Fourteen templates contain
at least one repeated argument placeholder. This is a static table count,
not a measure of executed calls.

`jd_intrinsic` already checks the native definition identity, excludes foreign
definitions, verifies the live telescope and checks the actual live argument
count. Same-named ordinary source functions retain their bodies. Currently
[`jd_definition_native`](../../selfhost/src/back/js/direct/core.bend) substitutes
only positional parameter names into these templates. `jd_call` still emits a
named function call, with a `JD_REF` reachability marker, at every caller.

The pinned TypeScript backend instead expands the template in `js_call`
(`bend2/comp.ts:3060`). It first emits ordered `const` bindings through
`emit_hold` (`2144`) for every operand outside its `ATOM`/`STRLIT` classes.
This is an evaluation-order mechanism as well as an optimization.

The inspected direct03 expression evaluator and local-row cell helpers retain
small arithmetic/Array wrappers where the reference emits arithmetic and array
access in the caller. This could obstruct local inlining or aggregate
elimination. V8 may already remove the wrappers: source differences alone do
not establish their cost, and earlier subset ratios are not an estimate of the
gain from this change.

## Minimal prototype

Keep the 89 templates and their admission rules unchanged. Add a decision at
`jd_call`, after the existing live-argument and saturation logic:

1. For an admitted intrinsic whose actuals are proven inert locals/literals,
   emit its parenthesized template directly.
2. Otherwise emit the existing named call unchanged.
3. Omit only the callee's `JD_REF` marker in the inline branch. Keep every
   argument's `JD_USE` and `JD_REF` metadata. Exported/selected intrinsic roots
   still retain their ordinary definitions.

This is a small core change plus an explicit operand classifier. It is general
across the intrinsic table and programs, but deliberately does not cover every
operand expression. Do not infer inertness just from a source `Var`: the direct
environment also contains demanded `$JD.View` expressions such as Word
conversion and Char projection.

Prefer provenance from the emitter over permissive JavaScript string matching.
If the first prototype classifies generated strings, accept only exact forms
created by known local/literal producers, preserve their usage comments, and
reject all projections, native views, calls, arbitrary identifiers and unknown
forms. Function parameters and immutable local bindings are sufficient for an
initial test. Do not broaden eligibility to get a benchmark to activate.

All-operand coverage is a separate step. It must produce the equivalent of:

```js
const p0 = actual0;
const p1 = actual1;
// Only now evaluate the intrinsic expression and its host-method lookups.
return Math.imul(p0, p1) >>> 0;
```

The current expression API returns only a string. A local IIFE containing these
bindings can preserve the ordering at the same expression position, but adds a
new function boundary and is only an experimental fallback. Replacing named
wrappers with IIFEs is not automatically a simplification or a speedup. A later
statement-prefix/value result can match upstream more directly; do not introduce
that wider emitter refactor until the small experiment shows useful opportunity.

## Legality and compatibility constraints

| Case | Required behavior |
| --- | --- |
| `Nat.double(f())` | Evaluate `f()` once, despite two template uses. |
| `Bool.or(f(), g())` | Evaluate both live actuals in source order before the template's short-circuit operation. |
| `U32.div(f(), 0)` | Evaluate `f()` even though the zero branch does not use its value. |
| `Math.imul`/`Math.fround` getter | Evaluate effectful actuals before looking up the method, as the existing wrapper and upstream held operands do. |
| `Array.set(make(), index(), value())` | Evaluate all three actuals once before length/read/write effects; return the same array identity. |
| Array swap/atomics | Evaluate the update actual before `array_rmw` reads the old element; retain the template callback and read/write order. |
| F32 values | Retain every existing `Math.fround`, conversion and exceptional-value behavior; do not reassociate arithmetic or fold NaNs. |
| Deferred invalid Nat | Preserve when arithmetic actually coerces or throws; an operand binding alone must not coerce it. |
| Partial intrinsic application | Keep current eta staging: supplied expressions remain in the eventual saturated body. Do not evaluate them at closure creation. |
| Erasure/overapplication | Preserve `jd_arguments`/`jd_over`; do not evaluate erased actuals or move later applications ahead of the intrinsic. |
| Same-named source/foreign function | Keep the ordinary call and its reference marker. Native spelling is insufficient. |
| Lazy local or match view | Preserve emitted demand metadata and bind demanded computed operands exactly once at their original expression position. |

The existing call analysis treats admitted intrinsic bodies as terminal native
operations. This proposal does not add named recursion, change SCC transfer,
remove closure bounce handling, or infer effects from a function's name.
Before pruning, verify that the analysis/emission join remains valid when an
intrinsic definition becomes unreachable. Runtime helpers such as `nat_chk`
belong to the fixed direct runtime and are not source-definition `JD_REF` edges.

## Evidence required before promotion

Use one candidate derived from the same checked source as its baseline. First
inspect emitted caller bodies to establish actual intrinsic expansion and
correct reference pruning. An intrinsic-only selected root must still export;
an internal wrapper with no emitted callers may disappear. A source function
with native-like spelling must remain reachable and ordinary.

Run independent operation-family cases, effect/throw order and repeated-view
controls covering the table above. Include early/late partial application,
erased arguments, exceptional F32 values, Array aliasing and post-import Math
accessor mutations. Count effectful operand executions rather than merely
comparing final numbers. Preserve the existing known NaN/table discrepancy as a
separate result; do not silently alter its oracle for this experiment.

Then run a short paired screen across expression evaluation, array/row work,
numeric work and closure/control canaries. Use clean timing separately from
profiles, and stop if activation produces no useful or consistent improvement.
Only a surviving candidate warrants the full 45-point comparison. Also record
generated bytes, retained declarations and checked acquisition time: repeated
template/telescope queries may raise compiler cost even if emitted programs get
smaller. No new cache or generic optimization framework is needed to answer the
initial question.
