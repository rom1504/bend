# Compiler allocation and direct JavaScript generation

This page describes four implemented **Phase58 candidate** changes. Combined
release qualification is pending; the installed-release identity remains in the
[self-hosted compiler index](README.md). The [Phase58 report](../../implementation/phase58/README.md)
records checked artifacts, focused controls, measurements and the eventual
selection decision. Implementation does not by itself establish a speedup.

Three changes improve the JavaScript emitted by the compiler, including a
self-emitted compiler image. One improves the compiler's own constructor queries.
All decisions are implemented in Bend. The runtime and diagnostic tools are
separate: saved-JavaScript derivatives test hypotheses, while private acquisition
and counter tools qualify actual source changes. They are not production passes.

| Change | Work it targets | Main implementation |
| --- | --- | --- |
| Literal record keys | Repeated computed-key property setup in emitted constructors and host conversion clones | `jd_literal_field_key`, [`direct/constructors.bend`](../../selfhost/src/back/js/direct/constructors.bend) |
| Constructor query traversal | Temporary missing records and searches through unrelated constructor owners | `j_find_ctor_children`, `j_arm_type_domain`, [`common/queries.bend`](../../selfhost/src/back/common/queries.bend) |
| Scalar residual reconstruction | Temporary Word lists built only to recover a native U32 | `jd_word_bind`, `jd_scalar_word`, [`direct/pattern.bend`](../../selfhost/src/back/js/direct/pattern.bend), [`direct/constructors.bend`](../../selfhost/src/back/js/direct/constructors.bend) |
| Literal-choice lowering | Selector calls and literal callback transport around a proved conditional | `jd_choice_call`, `jd_choice_body`, [`direct/choices.bend`](../../selfhost/src/back/js/direct/choices.bend) |

These are narrow transformations with explicit facts and fallbacks. They are not
a general escape-analysis, allocation-elimination or memoization pass. The
[backend boundaries](backend-boundaries.md) explain which facts belong to shared
checking, direct JavaScript, legacy JavaScript and native C.

## Ordinary literal record keys

A record field with a known name can be emitted as `"head": value` rather than
`["head"]: value`. Both create the same ordinary own property, but the simpler
syntax gives the JavaScript engine a more direct object layout. This matters for
repeated constructors such as KTerm as well as ordinary user records. Engine
optimization and actual allocation remain measurement questions.

`jd_literal_field_key` has one necessary exception: `__proto__` remains
`["__proto__"]`. In an object initializer, the noncomputed spelling can set the
object's prototype rather than create the intended own field. Quoting alone
does not remove that difference. Names such as `constructor`, `default` and
`field.name` use ordinary quoted keys.

The shared helper is used by `jd_ctor_fields`, `jd_ordered_field_join` in
[`ordered-values.bend`](../../selfhost/src/back/js/direct/ordered-values.bend),
and `jd_host_marshal_field` in
[`host.bend`](../../selfhost/src/back/js/direct/host.bend). Field order, erased
fields, value expressions, conversion calls and getter/error order stay in their
existing emitters. The change does not share objects, replace public data layouts,
or turn constructor results into constants.

## Constructor queries with known owners

For a checked match on `Tree<A>`, the compiler already knows where Tree's
constructors live. `j_arm_type_domain` uses that normalized ADT owner through the
existing `j_layout_ctor`; it then performs the same telescope specialization and
arm-type construction. Admission requires the original function telescope to be
`All` and its normalized input domain to be an ADT. Checked books have globally
unique constructor names, so the owned constructor agrees with the old global
search. Unknown shapes, absent owners and missing owned constructors retain that
search. This does not authorize owner shortcuts for arbitrary malformed books.

The fallback search itself now uses `j_find_ctor_children` to move past empty or
unmatched child lists without manufacturing an Absent record at each step. A
whole-book miss still returns the ordinary fresh missing value. Existing
first-owner/first-child precedence, explicit Absent handling, non-Ctr matches and
BookCache stop behavior remain intact; the indexed compatibility branch may still
construct an absent result. There is no new sentinel, cache or public API.

This reduces compiler work, not a generated program's constructor count. The
[query report](../../implementation/phase58/lookup.md) separates result/fallback
controls and counted helper calls from request timing and physical allocations.
It also distinguishes this change from the earlier typed-arity shortcut.

## Scalar facts through residual Word patterns

Native U32 matching already emits scalar equality and mask tests. A default arm
can nevertheless receive a residual Word suffix, prepend known bits, then call
`word_to_u32` to recover a number. For example, an escape classifier with several
literal cases and a numeric default may allocate temporary Word graphs on its
common path.

`jd_word_row_body` and `jd_word_bind` retain the held scalar origin and the exact
position of each residual bit or suffix. These private facts are created only
under the existing canonical native U32/Word/Bool ownership proof.
`jd_scalar_word` accepts reconstruction only when it covers all 32 positions
using literal Bool heads or same-origin, same-position fragments. It emits
`((origin & keepMask) | literalBits) >>> 0`. Literal prefix replacements are
reproduced, rather than assumed true from the chosen row. This also works for the
last unconditional row. Depth 32 is explicit, avoiding shift-by-32 wraparound.

Ordinary Word use refuses the **entire row** optimization. `jd_word_bind_used`
checks the existing emitted-use metadata, including captured uses; the compiler
then emits the original row, environment and held Word values. A callback may
therefore still receive and mutate a Word tail before reconstruction, and two
escaping references still share the same tail. Moved bits, mixed origins,
unknown fields and incomplete-width proofs likewise fall back.

F32 residual rows are excluded. Existing whole-native inverse-view rules remain
first, so this change does not infer floating equivalence merely from an integer
bit expression. The [scalar report](../../implementation/phase58/scalar-residual.md)
records the default/prefix/width cases, alias and mutation refusals, unchanged F32
bodies, and independent value controls. Static disappearance of Word calls is
not an allocation profile or a predicted speedup. Refused rows may be rendered
once speculatively and again through the original path, so compiler cost also
needs measurement.

## Literal callbacks in a proved choice

A function shaped like `choose(T, condition, u => yes, u => no)` can become a
branch without allocating and transporting those two callbacks. The name does
not establish this meaning. `jd_choice_call`/`jd_choice_named` reuse the existing
structural `j_choice_definition` proof from
[`choice.bend`](../../selfhost/src/back/js/choice.bend), then check the four-slot
signature, erased type argument, canonical live Bool and Unit inputs, full
application and two literal live lambdas. Renamed equivalent selectors can
qualify; changed same-name functions cannot qualify merely by their spelling.

`jd_choice_body` emits branches at a return site and keeps the existing return
continuation. Selected recursive calls can therefore use the existing SCC loop.
`jd_choice_ordered` preserves the ordered emitter's condition prefixes outside
its pending expression; a non-tail expression retains one local IIFE. The
condition runs once and only the selected body runs. Unit binding, captured
values and errors remain under that branch's original demand.

The call-graph scanner uses the same admission predicate and `jd_choice_calls`
to scan both possible callback bodies with their Unit argument. This makes the
new return path visible to existing recursion/stack analysis. Nonliteral
callbacks, incomplete applications, wrong selector bodies and unsupported
signatures retain ordinary call lowering. The generic selector and closure
runtime remain available; this is not general callback inlining or permission
to reorder surrounding expression prefixes. See the
[choice report](../../implementation/phase58/literal-choices.md) for the focused
control and deep-recursion scope.

## Remaining key reuse is a separate, unmeasured proposal

`jd_host_nat_status_on` currently serializes an unseen non-native-Nat ADT twice:
once for membership in its visited set and once for insertion. The isolated
[local-key proposal](../../selfhost/tools/performance/phase58/allocation/README.md)
would share that one immutable String inside the same selected branch. It is not
one of the four implemented changes above and has no measured retention result.
It must retain the native-Nat/non-ADT short circuits, normalization, worklist
order and fuel refusal; moving serialization before those tests changes demand.

The broader compiler already has template-instance memoization and recursive
marshaller tracking. Neither makes pre-lookup key construction free, and neither
justifies a global cache keyed only by term identity. Canonical keys depend on
binder context/depth, stored Var values and Sub reductions. Count callers,
serialized bytes and repeated keys before adding broader reuse. The
[Phase57 analysis](../../implementation/phase57/implementation-comparison.md#7-sk_char-is-canonical-key-escaping-with-a-separate-numeric-lowering-cost)
keeps that question separate from the scalar Word reconstruction removed here.

Final qualification must still distinguish compiler request time, emitted-program
runtime, sampled cumulative allocation, peak memory and source/code size. It must
also preserve public calling behavior, native/legacy support and the compiler's
explicit proof-trust limits. The Phase58 report is the authority for which
candidate eventually passes those gates and is installed.
