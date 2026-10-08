# Compiler allocation and direct JavaScript generation

This page describes six retained changes introduced in **Phase58 last01**.
For installed **Phase61 state08**, see the [self-hosted compiler index](README.md)
and [compiler-request guide](compiler-request-pipeline.md). The
[Phase58 report](../../implementation/phase58/README.md) preserves these mechanisms'
original checked artifacts, controls, measurements and selection decision.
Implementation does not by itself establish a speedup.

Four changes target the JavaScript emitted by the compiler, including a
self-emitted compiler image. Two target the compiler's constructor queries and
emitted-dependency traversal.
All decisions are implemented in Bend. The runtime and diagnostic tools are
separate: saved-JavaScript derivatives test hypotheses, while private acquisition
and counter tools qualify actual source changes. They are not production passes.

| Change | Work it targets | Main implementation |
| --- | --- | --- |
| Record-key placement | Constructor key syntax and host conversion clones, with a general final-live-field rule | `jd_ctor_field_join`, `jd_literal_field_key`, [`direct/constructors.bend`](../../selfhost/src/back/js/direct/constructors.bend) |
| Constructor query traversal | Temporary missing records and searches through unrelated constructor owners | `j_find_ctor_children`, `j_arm_type_domain`, [`common/queries.bend`](../../selfhost/src/back/common/queries.bend) |
| Scalar residual reconstruction | Temporary Word lists built only to recover a native U32 | `jd_word_bind`, `jd_scalar_word`, [`direct/pattern.bend`](../../selfhost/src/back/js/direct/pattern.bend), [`direct/constructors.bend`](../../selfhost/src/back/js/direct/constructors.bend) |
| Literal-choice lowering | Selector calls and literal callback transport around a proved conditional | `jd_choice_call`, `jd_choice_body`, [`direct/choices.bend`](../../selfhost/src/back/js/direct/choices.bend) |
| Distinct dependency edges | Repeated reachability work for the same target within one emitted definition | `jd_reach_refs_unique`, `jd_reach_marker_done`, [`direct/reach.bend`](../../selfhost/src/back/js/direct/reach.bend) |
| Shared recursive dispatcher | Complete mutual-tail loop bodies copied into every named entry | `jd_component_definition`, `jd_component_shared`, [`direct/core.bend`](../../selfhost/src/back/js/direct/core.bend) |

These are narrow transformations with explicit facts and fallbacks. They are not
a general escape-analysis, allocation-elimination or memoization pass. The
[backend boundaries](backend-boundaries.md) explain which facts belong to shared
checking, direct JavaScript, legacy JavaScript and native C.

## Record keys and the final live field

Ordinary direct constructors emit quoted keys for the preceding live fields and
one computed key for the final live field. For example, a two-field constructor
uses `"head": first, ["tail"]: last`. Native representations and the tag remain
unchanged. The rule has no record-name, program-name or field-count selector.

`jd_ctor_field_join` shares the rule between `jd_ctor_fields` and
`jd_ordered_field_join` in
[`ordered-values.bend`](../../selfhost/src/back/js/direct/ordered-values.bend).
It tests whether the rendered field suffix is empty, so erased trailing fields
do not move the boundary. Zero-live-field constructors gain no new field;
a single live field remains computed. Value expressions, property order,
erasure and ordered prefixes stay in their existing positions.

`jd_literal_field_key(name, last)` also keeps every `__proto__` key computed,
including an earlier field. Noncomputed `__proto__` in an object initializer can
set the prototype instead of creating an own data property; quoting alone is
insufficient. Other names, including `constructor`, `default` and `field.name`,
use the same positional rule.

At the Phase58 checkpoint, host conversion clones used
`jd_host_marshal_field` with `last=false`, retaining quoted keys except
`__proto__`. That historical allocation result does not describe Phase66
conversion emission. The current
[host converter](../../selfhost/src/back/js/direct/host.bend) copies an ADT
with converted fields using `{...v}`, then assigns scalar conversions or queues
composite work. An unchanged ADT retains identity. These assignments do not use
the constructor-literal field-key rule above; see
[Phase66 converter qualification](../../implementation/phase66/host-runtime.md).

The earlier [all-literal experiment](../../implementation/phase58/literal-fields.md)
showed a compiler-request benefit on its exact saved image. Later generated
programs exposed a tradeoff; that diagnostic cannot qualify the final rule.
The [record-syntax investigation](../../implementation/phase58/record-syntax-tradeoff.md)
and [final-field design](../../design/phase58/last-field-selection.md) preserve
the competing measurements and the reasons for the general compromise. Static
field spelling alone does not establish allocation bytes, JIT causality or
universal speed. The last01 source change adds one helper and five physical
lines relative to shared01; current source accounting and timing remain separate.

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

## Distinct edges in emitted reachability

Reachability follows the compiler's emitted `JD_REF` metadata. This preserves
the decisions already made by erasure, demanded bindings, numeric pattern rows
and constructor folding; it does not introduce a second source-body analysis.
Previously, repeated references to one helper within a rendered definition each
used a queue entry, even when that helper had already been visited.

`jd_reach_refs_unique` now uses the existing exact-name index to collect each
target once per rendered definition. `jd_reach_marker_done` still validates
every occurrence, including duplicates. Unknown targets, unterminated metadata
and exhausted text budgets refuse the whole graph. References from different
definitions remain separate edges. The final filter retains original source
definition order, and the public scanner wrapper preserves its supplied output
list.

The limits remain 2,097,152 scanned characters per definition, 4,096 definitions
and 65,536 queue entries. The last limit now bounds roots plus distinct outgoing
edges, rather than textual reference occurrences. This deliberately admits some
graphs that the old accounting refused; it is not a raised limit or an unbounded
cache. It changes compiler traversal, not generated runtime calls. The
[design](../../design/phase58/reachability-deduplication.md) records the earlier
four-change candidate's edge-budget refusal and the required boundary controls.

## One dispatcher per mutual-tail component

The direct backend already represents mutual tail recursion with a program
counter and a loop. Previously, each named entry copied the complete component's
loop and cases. `jd_component_shared` now emits that body once under the component
leader. Every named entry keeps its existing maximum-width parameter list and
calls the private dispatcher with its constant entry counter. Singleton and
self-loop emission remain unchanged.

The dispatcher reuses `jd_component_cases` and the existing ordered body emitter:
case-local bindings, argument evaluation, parallel stores and counter updates
retain their previous order. Internal tail transfers continue in the same loop;
the additional wrapper call occurs on component entry. Each invocation owns its
parameters and counter, so callback reentry does not share activation state.
Non-tail and unknown calls retain their existing forcing protocol. This rule
uses existing SCC facts rather than another recursion analysis.

Wrappers reference the leader in `JD_REF` metadata. `jd_component_refs` makes
the leader retain every member, preserving the complete ordered component when
reachability and call facts are rebuilt. The private `$scc` suffix cannot collide
with an encoded source name. Public host wrappers and data representations are
unchanged.

The [design](../../design/phase58/shared-recursive-dispatch.md),
[dispatcher report](../../implementation/phase58/shared-scc.md) and
[latency report](../../implementation/phase58/latency.md#fixed-source-scc-sharing-pilot)
distinguish the fixed-source saved-image diagnostic from the genuine checked
implementation. The Phase58 `checked-last01` passed its checked build,
focused and broad controls, genuine B2 generation, fresh source check and exact
B2→B3 reproduction. Diagnostic image-size and startup observations remain
separate from the source implementation's request throughput and program speed.

## Phase58 key-reuse proposal: separate and unmeasured

At the Phase58 checkpoint, `jd_host_nat_status_on` serialized an unseen non-native-Nat ADT twice:
once for membership in its visited set and once for insertion. The isolated
[local-key proposal](../../selfhost/tools/performance/phase58/allocation/README.md)
would share that one immutable String inside the same selected branch. It is not
one of the six implemented changes above and has no measured retention result.
It must retain the native-Nat/non-ADT short circuits, normalization, worklist
order and fuel refusal; moving serialization before those tests changes demand.

The broader compiler already has template-instance memoization and recursive
marshaller tracking. Neither makes pre-lookup key construction free, and neither
justifies a global cache keyed only by term identity. Canonical keys depend on
binder context/depth, stored Var values and Sub reductions. Count callers,
serialized bytes and repeated keys before adding broader reuse. The
[Phase57 analysis](../../implementation/phase57/implementation-comparison.md#7-sk_char-is-canonical-key-escaping-with-a-separate-numeric-lowering-cost)
keeps that question separate from the scalar Word reconstruction removed here.

The qualification record distinguishes compiler request time, emitted-program
runtime, sampled cumulative allocation, peak memory and source/code size. Public
calling behavior, native/legacy support and the compiler's explicit proof-trust
limits remain separate obligations. The Phase58 report binds its historical
selection to its completed evidence; the [State08 results](../../implementation/phase61/state08-results.md)
record the current release.
