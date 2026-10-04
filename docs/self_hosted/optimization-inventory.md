# Optimization inventory: implemented scope and missing passes

Source survey dated **2026-10-04**, at
`55e5b79dc9ac3e02436a712e34722f2eb519e5df`; selected **Phase45 worker23**,
upstream `018751270e800bc222a93dad7f257083ee53a5f7`.
This inventory reads the manifest and maintained implementations. It does not
infer availability from an experiment title, an old proposal, or an emitted
JavaScript pattern. See [architecture](architecture.md) for the complete pipeline
and [the IR contracts](../../selfhost/docs/JAVASCRIPT_IR.md) for detailed invariants.

## Status vocabulary

- **General:** applied structurally across an IR/domain, subject to explicit
  semantic preconditions; not a claim of whole-language coverage.
- **Local:** an expression, binding, call-site, or limited representation rewrite.
- **Specialized:** a proved source/type/graph shape with a dedicated lowering.
  Specialization on a language construct differs from selecting a benchmark name.
- **Absent as a general pass:** no such reusable pass exists in the selected
  pipeline. A local analogue or downstream V8/Clang optimization may still exist.
- **Unselected:** preserved experimental code or proposal, outside worker23.

## Frontend, checker, and compiler-work reductions

| Mechanism | Status and exact scope | Implementation |
| --- | --- | --- |
| Exact-name persistent index | General book lookup accelerator; source event order remains intact; collision buckets compare exact names. | `index_find`, `index_build`, `index_bucket`, [`core/index.bend`](../../selfhost/src/core/index.bend). |
| Compact literals and lambda metadata | General core storage: `KLiteral` avoids expanded constructor trees; `KLambda` records quantity-presence metadata. | [`core/term.bend`](../../selfhost/src/core/term.bend), [`front/literals_arrays.bend`](../../selfhost/src/front/literals_arrays.bend). |
| Contextual source completion | General load path; imported scope is available during parsing, completed sources are handed off without reparsing that body. | `f_source_header`, `f_source_body`, `f_complete_source`, [`load/modules.bend`](../../selfhost/src/load/modules.bend). |
| Indexed frontend scope | General contextual parser support; exact-name and constructor lookup avoid repeatedly searching all earlier declarations. | `FParseScope` construction in `f_source_body`, [`front/declarations.bend`](../../selfhost/src/front/declarations.bend). |
| Validated Base source cache | Host cache with compiler/Base/path/span identity checks; avoids repeated parsing/physical preparation. Current ABI-2 still calls full `dg_check_world`. | `prepareBase`, `readBaseCache`, `inspectWithMemo`, [`typed-driver.mjs`](../../selfhost/tools/typed-driver.mjs); `check_program_diagnostic`, [`driver/api.bend`](../../selfhost/src/driver/api.bend). |
| Explicit freshening work stack | General frontend binder traversal with fresh numeric identities. This is compiler stack/work management, not a runtime optimization. | `f_fresh_stack`, `f_fresh_book_stack`, [`front/fresh_work.bend`](../../selfhost/src/front/fresh_work.bend). |
| Weak-head evaluation | General semantic reduction for checking/type queries, with application spines; opaque native definitions remain opaque. | `wnf`, `norm_eval`, [`core/normalize.bend`](../../selfhost/src/core/normalize.bend). |
| Structural conversion shortcut | Local fast path before definitional conversion; does not replace conversion semantics. | `compare`, `norm_compare`, `norm_exact`, [`core/normalize.bend`](../../selfhost/src/core/normalize.bend). |
| Shared strong normalization | General normalizer with `GCell`, persistent memo heap and evaluator frames; prevents repeated argument copying. | `graph_strong`, `GHeap`, [`core/graph.bend`](../../selfhost/src/core/graph.bend). |
| Comptime instance memoization | General language specialization; exact template keys, checked publication, fresh binders and recursion/growth limits. | `sp_live_memo`, `sp_live_fresh`, `sp_live_done`, [`check/specialize.bend`](../../selfhost/src/check/specialize.bend). |
| Reachability before emission | General definition-level pruning after checking; retains type/constructor dependencies and honors backend intrinsic stops. | `reach_book`, `kr_dependencies`, [`core/reach.bend`](../../selfhost/src/core/reach.bend). |
| Selected annotation | General backend preparation restricted to retained definitions in full original context; not another validation pass. | `annotate_selected`, `ka_def`, [`check/annotate.bend`](../../selfhost/src/check/annotate.bend). |
| Pure/direct plan caching | Shared backend facts indexed once for selected definitions and discovered callees, bounded scans; not a universal analysis manager. | `j_plan_context`, `j_plan_prepare`, `j_plan_needed`, [`back/js/jpure.bend`](../../selfhost/src/back/js/jpure.bend). |

There is no measured compiler-stage attribution proving these are the current
hot spots. Source-level opportunities to share type/graph queries must be tested
with compiler-request profiling, not generated-program profiles.

## Ordinary JavaScript lowering

| Mechanism | Status and exact scope | Implementation |
| --- | --- | --- |
| Runtime erasure | General typed lowering; quantity-zero args/fields are never evaluated, with required public null slots retained. | `jir_lower_argument`, `jir_lower_values`, [`ir/lower.bend`](../../selfhost/src/back/js/ir/lower.bend). |
| Saturated argument batching | Local known leading-lambda prefix only; matcher/computation boundaries retain their original evaluation order. | `jir_lower_apply_generic`, `j_call_arity`, [`ir/lower.bend`](../../selfhost/src/back/js/ir/lower.bend), [`emit.bend`](../../selfhost/src/back/js/emit.bend). |
| Owned fresh argument vectors | Local emission/runtime contract: `callOwned` avoids the public argument copy when the compiler supplies a fresh unshared vector. | [`ir/emit.bend`](../../selfhost/src/back/js/ir/emit.bend), `apply`/`callOwned`, [`runtime/js/core.mjs`](../../selfhost/src/runtime/js/core.mjs). |
| Leading-lambda grouping | General structural lowering of consecutive lambdas; public arity and erased slots remain explicit. | `jir_lower_lambdas`, [`ir/lower.bend`](../../selfhost/src/back/js/ir/lower.bend). |
| Deep closure factories | Specialized nesting management with explicit lexical captures; still public closure descriptors, not general closure elimination. | `j_l_deep`, `j_l_mark`, `j_l_walk`, [`emit.bend`](../../selfhost/src/back/js/emit.bend). |
| Local/null copy propagation | General JIR walk; at most 64 copy facts; shadowing invalidates key and source; globals, constructors and opaque sources are not copied. | `jir_simplify_with`, `jir_copy_bind`, [`ir/simplify.bend`](../../selfhost/src/back/js/ir/simplify.bend), [`ir/facts.bend`](../../selfhost/src/back/js/ir/facts.bend). |
| Identity-let removal | Local exact `let x=rhs; x`; evaluates RHS once in its original outer scope and keeps its demand/tail flag. | `jir_simplify_let_select`, [`ir/simplify.bend`](../../selfhost/src/back/js/ir/simplify.bend). |
| Literal U32 folding | Local exact integer literals: add/sub/and/or/xor and inc/not/shl/shr; no arbitrary `x+0`, float reassociation or coercion assumptions. | `jir_fold_binary`, `jir_fold_unary`, [`ir/constants.bend`](../../selfhost/src/back/js/ir/constants.bend). |
| Proved primitive lowering | Specialized exact definition/type provenance maps supported U32/F32 operations to operators/helpers. Admission is broader than the nine constant folds. | `j_primitive_call`, `j_primitive_definition`, `j_primitive_code`, [`primitive.bend`](../../selfhost/src/back/js/primitive.bend). |
| Proved choice lowering | Specialized semantic choice becomes structured condition/branches; selected Unit-thunk application preserves erasure/delay. | `jir_lower_choice`, [`ir/control.bend`](../../selfhost/src/back/js/ir/control.bend); proof in [`choice.bend`](../../selfhost/src/back/js/choice.bend). |
| Statement-position lets/choices | General return-position JIR emission removes IIFEs; all parallel RHS temporaries precede the inner binding scope. | `jir_emit_return`, [`ir/statement.bend`](../../selfhost/src/back/js/ir/statement.bend). |
| One-constructor projection | Specialized complete matcher arm selecting one live field; retains public projection/snapshot semantics and refuses eta-short arms. | `j_projection_worker`, `j_projection_arm`, [`projection.bend`](../../selfhost/src/back/js/projection.bend). |
| Typed literal compression | Specialized native literal owners/provenance; generated primitives avoid general constructor-building paths when proved. | [`literals.bend`](../../selfhost/src/back/js/literals.bend), `jir_lower_constructor`, [`ir/lower.bend`](../../selfhost/src/back/js/ir/lower.bend). |
| Tail trampoline and delayed construction | General runtime stack/demand mechanism, not native tail-call elimination; `force` drives bounce/build messages. | [`ir/emit.bend`](../../selfhost/src/back/js/ir/emit.bend), [`runtime/js/core.mjs`](../../selfhost/src/runtime/js/core.mjs). |

`JIRLegacy` and `JIRCallPlan` are real optimization barriers. The former holds
opaque core/type context; the latter permits legacy call-plan selection around a
structured fallback. The copy pass traverses the fallback but does not rewrite
the source spine or remove bindings on the assumption that it has no uses.

## Private workers and complete-graph transformations

| Mechanism | Status and exact scope | Implementation |
| --- | --- | --- |
| Closed graph proof | General within a restricted first-order domain: exact definitions, admitted types/natives, complete callees and bounded proof fuel. | `j_pure_graph`, `j_pure_type`, `j_pure_native`, [`jpure.bend`](../../selfhost/src/back/js/jpure.bend). |
| Contextual instance rewriting | Specialized erased-prefix instances and aliases become private references; exact replay validates provenance before graph lowering. | `j_instances_collect`, `j_instance_fact_exact`, `j_instance_rewrite`, [`jpure.bend`](../../selfhost/src/back/js/jpure.bend). |
| Monomorphic graph admission | General extension to ordinary source definitions within the same proof domain; public wrapper profitability remains restricted. | `j_instance_source_definition`, `j_instance_root_collect`, [`jpure.bend`](../../selfhost/src/back/js/jpure.bend). |
| Demanded nullary private calls | General admitted computed nullary references become explicit zero-argument calls; never memoized; unsupported legacy fallback refuses them. | `j_instance_nullary_source`, `j_instance_has_computed_nullary`, [`jpure.bend`](../../selfhost/src/back/js/jpure.bend); `jw_expr`, [`worker-lower.bend`](../../selfhost/src/back/js/ir/worker-lower.bend). |
| Explicit positional calls | General JW instruction lowering; removes descriptor/vector handling on the native direct path. Same-SCC machine fallback still allocates child argument vectors; residual `JWNative` calls use `callOwned(get(G,...),[...])`. | `JWDirectCall`, [`worker-model.bend`](../../selfhost/src/back/js/ir/worker-model.bend), `jw_emit_direct`, [`worker-emit.bend`](../../selfhost/src/back/js/ir/worker-emit.bend). |
| Tuple/Char case removal | Local layout proof: a terminal `JWCase` whose condition is already true becomes its yes branch; preceding input/projection evaluation stays. | `jw_simplify_code`, [`worker-simplify.bend`](../../selfhost/src/back/js/ir/worker-simplify.bend). |
| Exact SCC partition | General bounded call-graph analysis, three 32-bit reachability words and Warshall closure; invalid/97-node graphs refuse. | `jw_components`, `JWReach`, [`worker-graph.bend`](../../selfhost/src/back/js/ir/worker-graph.bend). |
| Acyclic native functions | General proved component lowering to positional JS functions; no PC dispatch per ordinary operation. | `jw_emit_component`, `jw_emit_direct`, [`worker-emit.bend`](../../selfhost/src/back/js/ir/worker-emit.bend). |
| Bounded recursive native path | General cyclic components allow 32 charged native entries before a private continuation machine; not a 32-stack-frame bound. Restoration is exception-safe. | `jw_wrappers`, `jw_emit_recursive`, [`worker-emit.bend`](../../selfhost/src/back/js/ir/worker-emit.bend). |
| Same-SCC tail transfer | General direct tail calls snapshot args, assign next locals/target and continue; fallback has a corresponding machine transfer. | `jw_native_tail`, `jw_tail_result`, `jw_emit_tail_transfer`, [`worker-emit.bend`](../../selfhost/src/back/js/ir/worker-emit.bend). |
| Tail-only component bypass | General component property removes native budget/frame machinery where every internal recursive call is a terminal transfer. | `jw_tail_component`, `jw_tail_code`, [`worker-emit.bend`](../../selfhost/src/back/js/ir/worker-emit.bend). |
| Private named-field ADTs | General typed private tagged layout uses one fresh object rather than object plus field vector; native/public boundaries fence escape. | `jw_layout`, `jw_native_boundary`, [`worker-lower.bend`](../../selfhost/src/back/js/ir/worker-lower.bend); `jw_emit_construct`/`jw_emit_project`, [`worker-emit.bend`](../../selfhost/src/back/js/ir/worker-emit.bend). |
| Native constructor expressions | Local exact Bool/String/Char/Tuple layout/name/arity combinations avoid `ctor` and its temporary vector; Char check and String method semantics remain. | `jw_emit_construct_native`, [`worker-emit.bend`](../../selfhost/src/back/js/ir/worker-emit.bend). |
| Private Number Nat | Whole admitted graph representation transform; preserves exact 48-bit range, saturating subtraction, zero-divisor semantics and public BigInt ABI. Unknown native operations refuse the mode. | `jw_nat_functions_valid`, `jw_nat_functions`, `jw_number_code`, [`worker-nat.bend`](../../selfhost/src/back/js/ir/worker-nat.bend). |
| Canonical private Unit | Specialized exact Unit/constructor proof extends closed types and Map<Unit>; arbitrary object public roots remain excluded. | `j_pure_unit_type`, `j_pure_unit_constructor`, [`jpure.bend`](../../selfhost/src/back/js/jpure.bend). |
| Root-plan ranking | General selection policy: strong fusion/flat plans retain priority; new alias-only roots need recursion; small native-source public roots need contextual rows. | `JRootPlan`, `j_region_root_selected`, [`region.bend`](../../selfhost/src/back/js/region.bend); `j_l_def_region`, [`emit.bend`](../../selfhost/src/back/js/emit.bend); `j_instance_root_workers`, [`jpure.bend`](../../selfhost/src/back/js/jpure.bend). |
| Used primitive dependency fence | General bounded graph/source scan guards only used primitive names; inconclusive scans retain the full conservative fence. | `j_instance_primitive_capabilities`, `j_instance_primitive_cap_scan`, [`jpure.bend`](../../selfhost/src/back/js/jpure.bend). |
| Exact-entry capability | Shared runtime protocol permits private execution only through genuine exact saturation; raw calls and mutation retain fallback semantics. | `exactCode`, `enterExact`, `invokeExact`, [`runtime/js/core.mjs`](../../selfhost/src/runtime/js/core.mjs). |

## Older specialized paths still selected

These remain active and sometimes win over JW. They are not all instances of a
generic optimizer, and they must not be counted as general SROA or inlining.

| Shape family | Maintained implementation and scope |
| --- | --- |
| Nat countdown/branch workers | `j_nat_loop_worker`, `j_nat_branch_worker`, [`worker.bend`](../../selfhost/src/back/js/worker.bend): recognized scalar recursion and region composition. |
| Scalar U32 matcher workers | `j_u32_worker`, [`u32.bend`](../../selfhost/src/back/js/u32.bend): restricted native scalar matcher/type proof. |
| Scalar regions | `j_region_prefix`, `j_region_root_plan`, [`region.bend`](../../selfhost/src/back/js/region.bend): admitted scalar/local operations with explicit residual helpers. |
| Bounded private-helper inlining | `j_region_inline_defs`, `j_region_inline_children`, [`region.bend`](../../selfhost/src/back/js/region.bend): selected `JCall`/`JReadCall` helpers after closed-region proof; depth 8 and shared 2,048-visit budget, failure keeps original helper. |
| Virtual field/vector forwarding | `j_region_inline_virtual`, `j_region_vector_return`, [`region.bend`](../../selfhost/src/back/js/region.bend): `JInline`/`JUnpack` and the final private countdown vector can use scalar fields, with value reification for other uses. |
| Fold and producer lowering | `j_fold_plan`, `j_fold_emit`, [`fold.bend`](../../selfhost/src/back/js/fold.bend); `j_producer_plan`, [`producer.bend`](../../selfhost/src/back/js/producer.bend). |
| Producer/filter/map/fold fusion | `j_fusion_pipeline_defs`, `j_fusion_emit`, [`region.bend`](../../selfhost/src/back/js/region.bend): complete proved pipeline shape eliminates intermediates; not arbitrary loop fusion. |
| Callback composition/factory fusion | `j_callback_root` and its type/body proofs, [`region.bend`](../../selfhost/src/back/js/region.bend): selected callback shapes retain exact-entry/host guards; unknown callbacks remain public. |
| Finite/direct private calls | `j_direct_plan`, `j_finite_call`, `j_finite_emit`, [`finite.bend`](../../selfhost/src/back/js/finite.bend). |
| Tree/component/linear/pair paths | `j_tree_worker`, `j_component_plan`, `j_linear_combiner_emit`, `j_pair_loop_emit`, [`tree.bend`](../../selfhost/src/back/js/tree.bend): several explicit recursion and representation shapes. |
| Flat closed structures | `j_flat_root_scope`, `j_flat_root_emit`, [`tree.bend`](../../selfhost/src/back/js/tree.bend): successful full layout audit may avoid recursive object representation. |
| Native String/Char projection plan | [`ir/projection.bend`](../../selfhost/src/back/js/ir/projection.bend), used by finite/component emitters: removes intermediate projection vectors, preserving method evaluation count/order. |
| Local record/array type proofs | `j_region_local_type`, [`local.bend`](../../selfhost/src/back/js/local.bend): recognizes constrained closed shapes, including Array<U32>; this is not unrestricted Array effect analysis. |

The public single-field projection deliberately still calls `project(...).slice()`.
Its observable getter/snapshot behavior differs from private owned projections;
removing it using only an apparent field index would be a semantic change.

## Native-only lowering and external passes

| Mechanism | Status and implementation |
| --- | --- |
| Type-directed erasure | General native preparation: `nc_erase`, `nc_erase_args`, `nc_erase_annotated`, [`native/erase.bend`](../../selfhost/src/back/native/erase.bend). |
| Exact saturated direct calls | Local register entry selection from a leading live lambda telescope; partial applications retain ordinary closures. `nd_app`, `nd_arity`, [`native/direct.bend`](../../selfhost/src/back/native/direct.bend). |
| Immediate lambda beta reduction | Local `nd_beta`: variables substitute; nontrivial arguments become lets to preserve evaluation. Same file; not a heuristic function inliner. |
| Live environment/capture filtering | Source-occurrence analysis via `nc_live_env`; `nc_drop_dead` emits sinks and `nc_share_env` emits keeps. [`native/bridge.bend`](../../selfhost/src/back/native/bridge.bend). |
| Packed data and closure layout | Zero-field/eligible packed constructors avoid heap nodes; other constructors/closures allocate explicit runtime cells. `ne_constructor`, `ne_closure`, [`native/emit.bend`](../../selfhost/src/back/native/emit.bend), [`native/layout.bend`](../../selfhost/src/back/native/layout.bend). |
| Intrinsic and Array operations | Dedicated native operations and lowering, [`native/intrinsic.bend`](../../selfhost/src/back/native/intrinsic.bend), [`native/array.bend`](../../selfhost/src/back/native/array.bend). |
| Parallel tasks and shared segment ABI | `nc_parallel`, `nc_parallel_share`, [`native/parallel.bend`](../../selfhost/src/back/native/parallel.bend); `N_Segment` CPU/device dispatch in [`native/ir.bend`](../../selfhost/src/back/native/ir.bend). |
| Constructor/function tables and validation | Reachable program tables/IDs and layout/segment checks, [`native/tables.bend`](../../selfhost/src/back/native/tables.bend), [`native/validate.bend`](../../selfhost/src/back/native/validate.bend). |
| Machine optimization | **External** Clang `-O3` and device toolchains; not a Bend SSA/vectorization/register-allocation implementation. [`native-build.mjs`](../../selfhost/tools/native-build.mjs). |
| JavaScript engine optimization | **External** Node/V8 JIT may inline, eliminate allocations, or specialize numeric code; source shape can help/hurt, but these are not guaranteed compiler passes. |

Native `nc_live_env` is a real liveness-like mechanism. Therefore “the compiler
has no liveness” is too broad. The missing capability is reusable JW control-flow
liveness and live continuation/register compaction, not all use analysis.
JW's fallback retains parent register vectors by reference and allocates new
callee vectors; there is no existing whole-parent copying operation to remove.

## Verified gaps in the general JavaScript middle end

The evidence here is the positive pipeline and data structures: JIR's exhaustive
simplifier cases, JW's complete simplifier, `JWValue`/`JWInstruction`, and
`j_worker_emission`'s finite pass sequence. A repository keyword search alone
would not establish absence.

| Missing general capability | Existing partial analogue | Concrete missing information or pass |
| --- | --- | --- |
| Small-function inlining | Comptime instantiation, immediate native lambda beta reduction, `j_region_inline_defs` with depth/visit bounds. | No JW call-site cost model, general body substitution, binder/slot remapping and bounded code-growth pass over `JWDirectCall`. |
| Scalar replacement of aggregates (SROA) | Private single-object fields, `JInline`/`JVirtual` field forwarding, flat specialized trees/records, producer fusion. | No general constructor-to-projection forwarding across calls/branches with escape/identity proof. `JWConstruct` remains a value that allocates. |
| Def-use/value propagation across CFG | JIR local/null copies and tuple/Char case elimination. | No reusable use chains, known-constructor lattice, interprocedural return facts, or sparse conditional constant propagation. |
| Effect and exception analysis | JPure whole-graph admission and host capability guards. | No per-operation effects distinguishing inert/total, may-throw, demanded global loads, foreign calls and mutation; no effect-aware scheduler. |
| General instruction DCE | Whole-definition reachability and quantity-zero erasure. | JIR retains ordinary bindings; JW simplification does not remove unused assignments/calls using liveness plus effect facts. |
| CSE/value numbering | Memoized comptime instances and normalizer sharing. | No runtime expression equivalence table with effect/demand invalidation; repeated projections/checks are not generally merged. |
| JW continuation liveness | Numeric register upper bound and explicit fallback frames. | `jw_register_bound` counts required slot extent, not live-in/live-out sets. No pass minimizes saved state by continuation. |
| General range analysis | Exact literal folds, checked U32 operations, whole-graph 48-bit Nat representation. | No interval/range facts proving individual overflow, bounds, or Char checks redundant. |
| General known-local-function lowering | Deep closure factories and recognized callback fusion. | No arbitrary known closure target/environment representation or closure-conversion pass integrated with JW graph admission. |
| General Array effects/ownership | Native array backend and narrow scalar-region Array<U32> support. | No JW Array read/write/alias/effect operations covering arbitrary arrays, callbacks, mutation and public sharing. |
| General public-object adapters | Scalar/String public roots and some older specialized result shells. | No universal identity-/sharing-/mutation-preserving conversion between public ADTs/arrays and private worker layouts. |
| Loop-invariant motion/strength reduction/vectorization | Countdown/tree/fusion source patterns; downstream V8/Clang. | No general JW loop analysis, dominance, memory dependence, or loop transformation pipeline. |
| Unified analysis reuse/invalidation | `JPlan`, `JRootPlan`, instance proof rows, SCC labels, bounded copy facts. | No common analysis store spanning legacy KTerm plans, JIR and JW. Layout/purity/type queries remain distributed. |

Introducing all of these at once would expand proof obligations and compiler
cost. A composable pass should consume explicit facts, define refusal behavior,
and preserve the public fallback contract. The smallest useful tests include
evaluation order, erased work, host getter/error reentry, partial/overapplication,
public identity, and bounded stack behavior—not only a faster microbenchmark.

## Preserved but unselected directions

Worker23 does **not** include the experimental exact native `String.eq` admission
from candidate24 or its Number-Nat composition from candidate25. Selected
`j_map_native_string` admits `String.append`; selected `jw_nat_value_valid` has
no `String.eq` whitelist entry. The runtime nevertheless supports public
`String.eq`; missing private admission is not missing language functionality.

The [24/25 report](../../implementation/phase45/native-string-equality.md)
records a longer scoped Map/Set gain of 1.377655× versus worker23, with one source
module growing 56.4%, no isolated Nat-only improvement, and no full candidate25
qualification or controlled compiler-cost comparison. Unicode was an unchanged
canary. These prototypes preserve Unicode/error semantics and never replace
equality with bare JavaScript `===`; they remain unselected.

Earlier failed profitability/guard reductions also remain evidence. In
particular, broad new acyclic public wrappers regressed tiny/generic programs;
worker18's recursive alias-root requirement and worker23's preflight corrections
are selected fixes. More coverage is not automatically a performance win.
See the [phase report](../../implementation/phase45/README.md) and
[selection regressions](../../implementation/phase45/selection-regressions.md).

## Reproducible size accounting

Run this read-only command from the repository root. It counts only manifest
Bend source; it excludes runtimes, host tools, tests, generated APIs, copied Base,
old `src/compiler.bend`, and historical snapshots. “Code” means a nonblank line
not beginning with `#` after whitespace; it includes laws and `@unsafe` lines.

```sh
python3 - <<'PY'
import collections, json, pathlib, re
root = pathlib.Path('selfhost')
groups = collections.defaultdict(lambda: [0, 0, 0, 0, 0])
for name in json.loads((root / 'src/compiler.json').read_text())['modules']:
    text = (root / name).read_text()
    lines = text.splitlines()
    group = '/'.join(name.split('/')[1:3]) if name.startswith('src/back/') else name.split('/')[1]
    values = [1, len(lines), sum(bool(s.strip()) and not s.lstrip().startswith('#') for s in lines),
              len(re.findall(r'^def ', text, re.M)), len(re.findall(r'^type ', text, re.M))]
    groups[group] = [a + b for a, b in zip(groups[group], values)]
print('group: modules, physical, code, defs, types')
for group, values in groups.items(): print(group, values)
print('total', [sum(v[i] for v in groups.values()) for i in range(5)])
PY
```

| Manifest group | Modules | Physical lines | Code lines | Defs | Types |
| --- | ---: | ---: | ---: | ---: | ---: |
| Core | 6 | 3,039 | 2,568 | 280 | 13 |
| Check | 5 | 2,518 | 2,117 | 270 | 9 |
| Front | 14 | 4,234 | 3,528 | 476 | 15 |
| Load | 5 | 1,045 | 859 | 114 | 6 |
| Diagnostic | 5 | 861 | 718 | 93 | 8 |
| JavaScript backend | 31 | 8,994 | 7,264 | 1,051 | 19 |
| Native backend | 17 | 2,092 | 1,745 | 286 | 17 |
| Driver | 2 | 224 | 184 | 24 | 0 |
| **Total** | **85** | **23,007** | **18,983** | **2,594** | **87** |

Phase44 had 21,813 physical manifest lines; worker23 adds 1,194, or 5.47%.
Neither line reduction nor conceptual simplification is established by its
runtime gains. The 87 datatype declarations are not 87 independent compiler
concepts, and the many string-tagged cases are not captured by that count.

## Cost and evidence interpretation

Selected worker23's 45-point execution geometric mean is **3.0787× TypeScript**,
versus Phase44's 6.0867×. Its four sampled checked-library request ratios are
**6.160×** (local-pair), **11.684×** (lexer), **15.957×** (Map), and **4.547×**
(closures). They are different workloads and timing boundaries; neither ratio
is a universal property of Bend programs or compiler self-compilation.

The [generated-output profiles](../../implementation/phase45/diagnostics.md)
show named `apply`/`invokeExact`/`force`/`callOwned` self CPU down to 4.6% on Map
and 8.3% on records, with sampled allocation per call still about 1.33×/1.39×
TypeScript. Named guard self CPU is 8.00%/4.65%; this is not every reflected
builtin's cost. Eliminating guards alone cannot be justified as the full route
from roughly 3× to parity by these two profiles.

Private wrapper allocation attribution is also not proof that continuation
fallbacks allocated those objects: inlined callees may inherit the wrapper's
profile location. Use mechanism counters and independent examples before
changing recursion policy. Static generic call sites include cold public
fallbacks, and static object sites are not dynamic allocation counts.

The strongest architectural opportunities are the explicit gaps above, tested
as general transformations on renamed/mixed programs. Existing fast paths must
remain controls: a program already optimized by fusion or flat lowering does
not become a fresh opportunity merely because a newer IR can represent it.
All measurements cited here are preserved in the
[selected release results](../../implementation/phase45/results.md) and
[compiler-cost report](../../implementation/phase45/compiler-cost.md); no target
execution was performed for this survey.
