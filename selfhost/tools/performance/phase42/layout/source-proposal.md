# Scoped flat compiler lowering proposal (not a patch)

Status: readonly source review. No compiler code is changed. Approximate change
budget: 160–230 added physical lines plus 15–25 wiring lines in tree/region/
finite/emit. The new closed-emission audit is the material correctness work;
JPure alone does not establish that every admitted expression currently emits
without a generic ADT observer. Do not enable flat constructors before that
negative audit and every field-read path are implemented together.

## Exact current owners

- `region.bend:j_region_root_done` emits the canonical scalar guard, local
  helper declarations, successful proof scope, and original generic body.
- `tree.bend:j_component_declaration` already marks covered and owned
  constructors; `j_component_cached` supplies request-local exact planner facts.
- `tree.bend:j_component_emit_match` and `finite.bend:j_finite_emit_match` both
  call `j_finite_fields`; this shared field read currently hardcodes `.a[i]`.
- `finite.bend:j_direct_emit_call` owns private acyclic helper IIFEs; its nested
  constructor and prefix field lowering must inherit the scoped layout.
- `emit.bend:j_constructor_literal` owns ordinary private constructor objects.
- `tree.bend:j_linear_split` owns resumed one-child constructor reconstruction.
- `emit.bend:j_expr_private` and `region.bend:j_region_return` own scalar
  record `JUnpack`; they currently build/read the `.a` argument vector.
- The parallel vector-output/read path stays unadmitted initially: reject
  JFold/JProducer/JReadCall/JInlineRead/JVirtual/JVector rather than extending
  its ABI in the same patch. This preserves native List/pair/vector contracts.

## Context storage without cache loss

Keep the head `BookCache` and its identity fields unchanged. Its children become
`[original source index, original JSPlanContext, JSFlatContext]` only in the
request-local scoped book passed to private emission. The first two child
objects remain exact originals. `j_plan_lookup` still reads the second child
and its original component/direct fact indices. `lookup`/binder identity still
uses the first child. Flat metadata contains exact original source graph KDefs;
never prepend an ordinary definition, rebuild the source index, or replace the
second-child facts. No persistent cache or new planner invocation is introduced.

## Narrow initial admission

Use only ordinary `j_region_root_done` roots with `j_region_signature` (native
scalar inputs AND native scalar result), a residual structural helper, valid
existing whole JPure proof, and complete original-name guard coverage. Reuse
that existing proof calculation once; do not calculate a second full graph.
Root helpers have transformed bodies, so construct the exact source context
from `lookup(book,dn(helper))`, rather than treating the modified helper KDef
as an exact source definition.

Audit the already normalized lowering terms, not only source purity:

- `JGeneric` must resolve to an exact saturated component JCall or cached
  acyclic JDirectCall with complete closure coverage; unresolved refuses.
- Any remaining nonprimitive App refuses, except the current worker's own
  saturated structural recursion already admitted by its cached component plan.
  Inspect the whole spine and its arguments, not inner partial App prefixes.
- Every JCall refers to an emitted local helper/clone; every JDirectCall's
  cached closure and expansion proof is valid. Foreign, unbound/reflection,
  observer, higher-order values, generic matcher/project, and native read/tuple
  bridge nodes refuse. Standalone function Ref refuses.
- Audit each graph definition once using its cached component/direct plan;
  all unsupported helper forms cause the complete flat route to be omitted.
- Constructor type/arity/field order remains proved by JPure and existing
  `j_owned_ctor_type`. Only original nonnative closed JPure ADTs flatten.
  Native Bool/Nat/U32/F32, List, Tuple and all special/native families retain
  their current representation; their existing prefix handling remains intact.

## Lexical placement

Successful guard code should have this shape (illustrative, not emitted patch):

```js
if (ORIGINAL_COMPLETE_ENTRY_GUARD) {
  const previous = regionProofOpen(guards);
  try {
    // Existing exact worker names shadow globals in this admitted block only.
    function $R_component$tree(...) { ORIGINAL_FRAMES_WITH_SCOPED_FLAT_READS }
    function $R_scalar_output(...) { SCOPED_FLAT_UNPACK }
    return CLOSED_SCALAR_ROOT_BODY;
  } finally { regionProofClose(previous); }
}
ORIGINAL_GENERIC_BODY;
```

Emit local cloned component declarations with the existing component emitter and
local scalar helper declarations with existing region emitter, under scoped
metadata. The successful root term sees those declarations. Existing global
workers and outside-try scalar helpers remain tagged-array ABI. Root fallback
cannot resolve the block-local clones. Function declaration allocation per call
is an explicit potential cost and should be screened; a later safe hoist into
an owned closure requires a separate declaration/route proof.

## Five lowering hooks

1. Non-native owned ctor under flat context emits `({$:tag,_0:field0,...})`.
   Generate field prefixes from the typed telescope, preserving erased/null
   positions and left-to-right expression order. Other ctors stay unchanged.
2. Component and finite prefix reads select `._i` only when their INPUT TYPE
   is a flattened nonnative ADT in active context. No marker-property demand.
   Native Bool/Nat remain primitive; List/Tuple use their original paths.
3. Acyclic helper emission inherits the same context and constructor marking.
4. Linear resumed ctor reconstruction prefixes each original resumed field
   expression with `_i:`; saved-before fields and `$value` timing stay unchanged.
5. Flat record JUnpack binds from `._i` directly, capturing the input before
   nested scopes. Do not create a temporary argument vector or generic bridge.

No runtime object test, WeakSet, representation conversion, mutation, Number
Nat, or input-depth limit is required. Constructors stay fresh; zero-depth
flow copies its root and retains its child aliases. Existing stack machines and
continuation phases stay unchanged. Every specialized object remains inside its
closed scalar graph until a native scalar result leaves.

## Required source-screen evidence

Before a checked build, static review must show all field/constructor paths
covered and unsupported graph routes refused. A checked emission must retain
original public workers byte-for-byte where source changes do not affect their
existing owned ctor path, include separate local flat clones, and contain no
runtime ctor/build/project/apply/invokeExact/get-G call in those clones. Compare
complete Tree/Stat diagnostic values, freshness/shared/uneven/mismatch cases,
root proof counters, hostile count and ADT getters, mutation/throw/bounded
reentry, raw entries and deep stack behavior. Then run an actual saved-module
array/flat paired screen. Broad gates follow only after this survivor freezes.

Status successor: the readonly estimate above is now implemented as frozen
`source-v4.patch` (208 additions/9 removals), with `source-v4.json` and
`source-validation-catalog-v1.json`. Static reviewer accepted V3's exact-frontier
fix; V4 adds the inactive-context normal fallback. Root still owns checked build,
complete-value controls, performance acquisition and any source promotion.
