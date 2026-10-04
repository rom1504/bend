# Phase43 independent review

The first shared-plan change should make typed direct lowering reusable, while
keeping semantic closure, representation, recursion strategy and runtime entry
permission distinct. Extending a global purity predicate and hoping every
consumer can emit the new family is insufficient: Phase42's strict Sigma1/1
equality accidentally removed the existing Sigma2/2 vector optimization.

Use the existing request-local context. BookCache child0 is the original source
index, child1 is JSPlanContext, and child2 is the lexical JSFlatContext. Original
source lookup and binder identity must remain unchanged. A successful compile-time
plan never memoizes a mutable runtime guard or grants ownership to public data.

## Minimal typed plan

Retain JPure as the exact original-source closure witness and retain its refusal
and remaining-budget results. A call-plan row should additionally name the exact
canonical definition, its normalized typed telescope, the original call's exact
saturation, and one emission strategy: existing primitive, finite acyclic helper,
structural iterative worker, bounded hybrid worker, or unchanged generic route.
It should contain the exact closure obligations and normalized representation
requirements used by that strategy. Refused/missing rows preserve the old path.

A separate layout row records the exact normalized owner specialization,
constructor identities and arities, quantities and specialized field/result
telescope. Distinguish native scalar/String, tagged custom data, native List,
native Sigma, and a lexical flat custom layout. These are emission capabilities,
not a single boolean "closed type". In particular, legacy vector policy,
owned Sigma1/1, ground U32 List selection and closed List<T> must remain distinct.

The smallest useful new emitter is a lexical direct callee shared by a completely
proved graph, rather than another recursively copied helper IIFE. Compile a
callee once with its typed environment and resolve saturated edges against that
same graph. Preserve callee-before-argument demand, argument evaluation once in
source order, erased runtime slots, existing deferred constructors, and result
annotation types. Acyclic-helper and structural-recursion checks remain explicit;
String or parameterized-ADT type admission alone cannot authorize native recursion.

Derive rows from original typed KTerms, not emitted JavaScript. Audit the exact
normalized bodies that are subsequently emitted, including every residual generic
edge and native operation. No post-audit inline pass may introduce an unsupported
observer or representation bridge. Start by consuming one row in existing direct
and component emitters and deleting their duplicate type/callee checks. Expand
only after an ordinary-root activation witness and measured family-level gain.

## Minimum adversarial matrix

| Boundary | Small falsifier |
| --- | --- |
| Mutable graph | Warm root, replace an inner G binding/code/arity/bound/env or install a getter; require exact fallback trace and zero private entry. |
| String | Post-import native String hook changes, astral characters, lone surrogates, empty input and throwing conversion; verify values and original demand order. |
| Typed layout | Same owner with different type parameter or quantity, dependent Sigma family, stale source definition and forged cache payload; require refusal. |
| Evaluation | A first argument throws while a later argument/callee getter records events; no replay, duplicate demand or reordered lookup. |
| Alias/allocation | Uneven/shared data, retained intermediate, identity-return leaf and fresh reconstruction; compare complete private values and aliases. |
| Callback | Distinct captures, partial/extra application, foreign function fields, callback getters/errors and reentry; known workers cannot absorb arbitrary public callbacks. |
| Error suspension | Error constructor reenters a public data/callback function while outer private permission exists; foreign code must execute generically and cleanup must restore the correct prior proof. |
| Stack/work | Unbalanced depth30000; actual iterative fallback must activate. Alias-DAG type comparison and repeated helper expansion must consume one aggregate budget. |
| Fusion | Noncommutative fold, modulo zero, retained/shared intermediates and throwing/early terminating callback; purity does not prove demand equivalence. |
| Guard cost | Exact complete dependency and host gates, primitive/function prototype mutations, hot success then mutation; no cross-invocation success memoization. |

The maintained standard-intrinsics-at-initialization contract predates Phase42.
Supported post-import mutation and Error observation remain mandatory. Historical
pre-import wrapper deltas remain diagnostics outside that documented scope.
Phase42 raw receipts and the installed checked16 release stay closed and immutable.
