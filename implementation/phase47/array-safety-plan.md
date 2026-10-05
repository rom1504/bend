# Private array views: bounded implementation contract

The saved-output experiment isolates a useful cause: five rotated rounds gave
approximately 680 ms for the original, 683 ms for helper expansion, and 186 ms
for either backing-view reuse or backing-view-plus-length reuse. All twenty
digests agreed. These diagnostic derivatives do not establish production safety.
The useful next step is a private raw-view representation for a completely
proved region; length caching has no additional measured justification.

## The invariant

An admitted root has canonical scalar inputs and a canonical scalar result.
Its complete existing typed region plan contains only local value transport,
known private calls, structured control, proved scalar primitives, and canonical
`Array<U32>` operations `Array.new`, `Array.get`, and `Array.set`. Every array
therefore originates inside this root. Internal aliases share the same backing
array, but no array, tuple containing one, closure, or callback crosses its public
boundary. Unknown syntax or exhausted analysis fuel refuses this extra plan.

Refuse generic/residual calls, opaque callbacks, foreign operations, producer or
fold adapters whose bodies have not been covered, Array constructors/matching,
public container parameters/results, and native operations outside the whitelist.
This is a structural proof on existing typed plans, never a workload/name match.
Retain all existing source dependency guards even for calls removed by lowering.

Before existing input/dependency checks, require a fresh host guard that cannot
inherit permission from `regionProof`. It checks the exact captured Number and
Array globals, `Number.isSafeInteger`, `Array.prototype.fill`, the relevant
scalar intrinsics, and Array/Object prototype chains and numeric-property hooks.
Use captured reflection and descriptor values; inspecting a changed accessor
must not invoke it. The existing standard-at-module-initialization premise stays.

This stronger guard plus the complete no-callback graph makes the invariant
stable until return: allocation cannot call a replaced fill/constructor or an
inherited numeric setter; scalar conversions receive primitives; local accesses
cannot reach a proxy or getter; no unknown callback can replace storage later.
An entry guard is sufficient only with this entire proof. The existing guards
alone are insufficient: `localGuard` misses allocation/conversion hooks, and
`regionHostGuard` omits fill/isSafeInteger and accepts an active `regionProof`.

## Representation and demand

Use ordinary JS arrays as the private representation of `Array<U32>`:

| Operation | Selected private emission |
| --- | --- |
| `Array.new(U32, depth, value)` | Existing `arrayfill(value, depth, '^').array` at the original allocation site |
| `Array.get(U32, a, i)` | `[a, a[Number(i) % a.length]]` after ordered argument capture |
| `Array.set(U32, a, i, v)` | Capture all arguments, assign `a[Number(i) % a.length] = v`, return the same `a` |
| Existing consumed-read bridge | Bind its private raw `a` as the data view, keeping the existing Number and length access |

The first version keeps the existing allocation wrapper and unwraps its fresh
own data property once. Removing that tiny allocation is a separate experiment.
Do not move allocations or accesses across branches, parallel lets, or zero-trip
checks. Retain each Number conversion and each length read. Preserve the original
order: evaluate read arguments before the access; evaluate every write argument
before its conversion and store. No persistent ownership registry, mutable global
mode, cache invalidation protocol, or extra loop dependence analysis is needed.

If either static proof or runtime guard fails, run the original unmodified
wrapper path, including its old input/dependency checks and private/generic
selection. Jumping directly to the generic body could skip observations from
those checks. Runtime selection happens before source body evaluation, so the first
allocation/access is evaluated exactly once. No backing-storage inspection occurs
on an external object. A zero-iteration loop keeps its original demand behavior.
Error construction may reenter, but the failing computation does not resume its
private body, and a nested invocation must establish its own fresh permission.

## Small implementation boundary

Add `selfhost/src/back/js/array-view.bend` for the bounded plan audit and an
immutable request-local BookCache metadata flag. Source lookup and planner
indexes remain unchanged. Only the selected private body and its private helper
declarations receive the flagged book; the original wrapper path and its fallback
receive the original book. The initial implementation creates an additional
lexical helper closure once per eligible public definition, duplicating those
private helper declarations to preserve the exact old path on refusal. This
emitted-size cost must be measured. Keep the source type as `Array<U32>`; the
flag is a private representation fact, not a change to source typing.

The consumers are the existing `JNative` emitter in `emit.bend`,
`j_region_read_definition`, and `j_region_inline_output` in `region.bend`.
All three must agree on raw representation. `j_region_root_selected` chooses
this proven mode and adds its fresh host guard before existing input/dependency
checks. A final-only guard is insufficient: a hostile reflection helper could
spoof an earlier dependency check and restore itself before the final guard.
Do not enable it for tree/fold,
residual, ordinary public, or unrelated JW emission by accidental flag reuse.

Runtime work is a small dedicated guard beside `regionHostGuard`, sharing its
captured reflection and prototype snapshots while explicitly checking the
missing hooks. It must not use the existing permission short circuit. Conservative
refusal when an outer `regionProof` is active is acceptable for this first slice.

The frozen array03 module was 186 Bend lines; the array04 source checkpoint is
197 lines after the bounded known-helper normalization extension. It includes the executable-node audit,
private marker, native-App normalization, raw operations, and ordered-store
continuation helpers. The dedicated runtime guard and narrow consumers remain
separate. This is slightly above the initial 100–180-line module estimate; no
ownership registry, invalidation framework, or public layout is introduced.

## Source-App normalization and ordered stores

A typed plan can retain a saturated native source App as well as `JNative`.
Recognize the former only through `j_region_local_native`'s existing exact owner,
element/telescope/arity proof and a matching native helper dependency. Skip only
its proved erased first operand during executable-node auditing. After the whole
plan passes, normalize every such App in the private root and nonnative helpers
to `JNative`; preserve Ann/JUnpack type metadata. This complete conversion is
required for one coherent raw representation. The original helper set still
supplies guards, and the original fallback is emitted without normalization.
Array03 passed build/static review but did not activate local-pair. Its next
diagnostic proved native Apps passed and identified a collected annotated helper
App as the remaining first refusal. Array04 additionally requires exact positive
helper arity (at most 32), a nonnative collected Def and zero erased-prefix
metadata, then normalizes source Apps to JCall. Only the current Mat helper's own
self App is retained for existing countdown tail lowering; other Mat-target calls
must become private too. The complete typed helper proof owns demand and cycle
legality. This contract is not an activation claim for array04.

Where existing region lowering already has a statement destination or a return,
`j_array_view_statement` captures all Array.set arguments before the store and
continues with the identical array value. Reserved block-local `$arraySetN`
variables retain array→index→value→Number→length→store order. Vector fields keep
their existing sequential evaluation; expression-only contexts retain the prior
IIFE. This operation exposure does not change allocation, guards, aliasing,
zero-trip demand, or loop state.

## Validation and rejection

Use the independent `controls/array-view-v1.bend` and
`controls/array-view-controls-v1.mjs` under
`selfhost/tools/performance/phase47/`. They include local alias-sensitive values,
external aliases/proxies/getters, changed backing storage, returned storage,
zero-trip demand, ignored-read errors, Number/getter hooks, fill reentry/proxy/
throw, fill replacing Number and resizing storage, isSafeInteger replacement,
opaque callbacks, and mutations of public native/source helpers.

Add an activation witness for the selected root and refusal witnesses for public
array and returned-container roots. Validate a renamed independent local loop,
two local arrays, and parameter permutations. Add Array constructor/getter and
inherited numeric setter controls if the current controller does not cover them.
Keep failed attempts immutable. Run focused correctness before any timing, then
repeat the same clean array batch and the maintained canaries. A production gain
may be smaller than the diagnostic 3.656× because the real guard has a cost.

Promotion needs the relevant maintained backend/public-boundary gates. This
document makes no full conformance, universal speed, or installed-release claim.


The checked array01 and isolated ordered-store array02 checkpoints both passed
24 independent value oracles and 39 host/public-boundary controls, including raw
activation and refusal witnesses. Broader multi-array/record controls are being
prepared separately. Pending canary/full qualification and the unresolved array03
coverage result must not be replaced by the stronger saved-output speed claims.
