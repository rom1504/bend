# Next compiler lowering: workers across pattern matches

The strongest new architectural hypothesis is to give internal functions a typed, saturated worker that can continue through a pattern match, while retaining the existing staged application behavior wherever argument demand is observable. This is a proposal for a bounded experiment, not an established speedup or an approved emitter rewrite.

The existing private compiler has already optimized ordinary function calls, field access, selected Boolean operations and repeated stability facts. Repeating those transformations does not address functions whose first argument selects a matcher before later arguments arrive. The actual final emitted code exposes that remaining distinction from the pinned TypeScript emitter.

## Evidence and scope

The [static inventory](../../implementation/phase4/evidence/residual-lowering-inventory.json) records complete hashes and 19 helper declarations from checked B1 `0653f21e…`, public H `b33b38e3…` and private candidate `4318bbcd…`. B1 and H implement the same final Bend source `34c6ef63…`; they are emitted by different compilers. The upstream compiler is pinned at `6018e28ecc67cf1fffc0c20c64b11023474c2df8`. Restorable artifacts are in the [final source capsule](../../implementation/phase4/final-source-capsule/README.md) and [private image capsule](../../implementation/phase4/private-final-images/README.md).

| Helper | B1 worker parameters | H initial entry | Work still crossing a matcher |
| --- | ---: | --- | --- |
| `subst_node` | 3 | One-argument KTerm matcher | Six projected fields enter an eight-argument arm; `id` and replacement arrive afterward. |
| `subst_terms` | 3 | One-argument list matcher | Nil returns a two-argument function; Con returns a four-argument arm including its two fields. |
| `ka_defs_except` | 3 | `fn(1)` | Book arrives first, then the list matcher, then stop names. |
| `tele_check` | 5 | `fn(3)` | Context, level and telescope precede the argument-list match; demand arrives afterward. |
| `ka_args` | 4 | `fn(3)` | The final argument is consumed by a separately constructed list matcher. |
| `wnf`, `check`, `annotate` | 2 / 5 / 4 | `fn(2)` / `fn(5)` / `fn(4)` | These entry arities already agree; their descendants require separate analysis. |

The frozen H contains 386 matcher-root globals among 1,518 named globals. Its private image contains 1,123 positional workers. These are syntax counts, **not** execution frequencies, allocations, time fractions or an achievable ceiling.

In [`emit.bend`](../../selfhost/src/back/js/emit.bend), `j_lambda_count` counts consecutive Lam nodes and stops at a Mat. `j_call_arity` uses that count, and `j_apply_regular` groups arguments only within it. `j_match` emits runtime `matcher`/`matcher1` values. Consequently the private `subst` worker still reaches `subst_node` through the equivalent of:

```js
jump(call(call(get(G, "subst_node"), [term]), [id]), [replacement])
```

The pinned upstream `comp.ts` takes a different route: `sig_def` obtains the live typed signature; `js_def` declares those parameters together; `js_func` carries the remaining parameters through Lam, Mat and Let. The selected arm receives projected constructor fields followed by the remaining parameters, within one generated JavaScript function. See upstream `sig_def` near line 1146, `js_func` near line 3137 and `js_def` near line 3213, with the exact consumed file hash in the inventory.

This does not make B1 uniformly cheaper. It still emits `run_jump`/`run_loop` trampolines and `run_clo` closures. Its `core_subst_stable` branches through generated `kc` calls, whereas H already lowers the corresponding known choice to conditional JavaScript. H's constructor builder also preserves deep stack safety explicitly. A new implementation must retain those advantages rather than copy upstream output indiscriminately.

## First experiment: typed internal workers across matches

Start with one small actual helper family, preferably `subst_node`/`subst_terms`, selected after current private profiles establish that it executes often enough. Produce a disposable component or exact-image transformation; do not initially change the public emitter or canonical private package.

The worker takes the complete known live argument list, projects the matched argument and executes the selected body inline. It retains the exact existing constructor, beta-rebuild and tail-result behavior. The original generic entry remains available for partial application, higher-order values, unsupported shapes and public entry points. Calls may use the new worker only when all relevant arguments are already computed compiler data values and the callee/constructor metadata are fixed. Preserve enclosing lexical captures: the prior `F` hoisting defect demonstrates why merely recognizing a global name is insufficient.

**Evaluation order is the first proof obligation.** In `call(call(f,[first]),[later()])`, applying `first` may reject or diverge before `later()` runs. Replacing this with `worker(first,later())` evaluates `later()` first. Bend purity does not preserve exceptions or divergence automatically. The initial experiment must therefore restrict itself to already-computed arguments. General production lowering needs an explicit schedule of argument evaluation and matcher demand, or a proof that crossing that boundary is safe. Full typed arity alone is not that proof.

This is materially different from [P4-011](../../experiments/phase4/P4-011-ordinary-uncurry.md), whose intermediate applications had to remain ordinary underapplications and found zero eligible chains. Here an intermediate application saturates a prefix and performs a match. It also differs from [P4-015](../../experiments/phase4/P4-015-exact-con-arms.md): that experiment fused only exactly saturated Con/arity-two arms and deliberately excluded arms still awaiting later arguments. Its inconsistent core gain remains a negative result; removing more syntax does not guarantee a useful gain here.

The cheapest falsifier has four steps:

1. Count this exact family in one real compiler-core compilation, separately from timing. Record entries, staged applications and partial records that the proposed worker would remove. Do not convert operation counts into allocated bytes or time saved.
2. Differentially compare the worker against the unchanged image using the controls below. If the safe already-computed subset is empty or too rare, stop before timing.
3. Run two opposite-order fresh-process core pairs, with frozen Base cache policy, CPU affinity, Node flags, exact emitted bytes and peak RSS. Stop for no consistent useful core benefit; roughly 5% is a practical escalation threshold, not a statistical confidence claim.
4. Only a survivor receives three alternating repetitions, a rejection/import/source-change matrix and a full frozen-source emission gate. Retain all failed observations. A private compiler improvement does not establish faster generated user programs.

Required controls include a rejecting first matcher followed by a throwing or counted later argument; a divergent early stage under a bounded supervisor; zero, partial and overapplication; wrong field counts taking the original path; captured contexts and nested parameter names; selected and unselected errors; exact constructor field demand order; at least 100,000 tail steps and deeply nested constructor results. For compiler semantics include dependent telescopes, Lam-headed App beta reduction, neutral App reconstruction, removed metadata, fresh binder identities, separate immutable book versions and exact diagnostic order. Never apply the invalid absent-variable substitution shortcut: rebuilding an App can beta-reduce it even when the variable is absent.

The private scope assumes finite, well-typed immutable compiler graphs, without injected getters, proxies, mutable function records or host callbacks. Public library support is a separate, broader contract. Public wrappers must preserve the existing ABI and staged application observations; a new private worker is not a replacement public export.

## Second hypothesis: explicit constructor continuations

H's `j_constructor_mode` emits `build(name,[fieldThunk,...])` in tail position. Runtime `force` executes the fields in order using an explicit pending stack before calling `ctor`. This allocates closures and frames but protects deep construction from JavaScript recursion. B1 commonly emits direct constructor object literals containing `run_loop` calls; those forms are not interchangeable for stack depth.

A possible next design uses first-order continuation records with known worker/environment slots rather than a closure per field. This would require emitter support or a tightly scoped generated-code intermediate representation. It is not another Con-arm splice. First count build nodes, field thunks and maximum pending depth on real checking/annotation, then prototype one recursive list/tree constructor family. Demand/error order, nested build/bounce combinations and deep stack behavior are mandatory falsifiers. Reject the idea if continuation dispatch merely replaces equivalent allocation or worsens memory. No current profile isolates a defensible savings estimate for this mechanism.

## Third hypothesis: typed lowering facts scoped to a compilation

The upstream emitter records typed call-spine/signature/layout facts (`term_spine`, `sig_def`, `tele_unbind`) and clears book-specific caches while preparing a compilation. The Bend JS emitter repeatedly consults `j_type`, `wnf`, `subst` and `lookup` when emitting calls, lambdas and constructor fields. That code inspection identifies a question, not proof that these operations repeat on equivalent inputs or dominate emission.

Instrument calls with their exact immutable book, term, type and environment identities before proposing reuse. The smallest probe stores only a fact with a demonstrated dependency contract, such as a definition's live signature within one fixed annotated book, then verifies exact output and errors. Preserve declaration replacement, dependent arguments, annotations, binder freshness and demand order. A cached result keyed only by a definition name or term is insufficient. This is distinct from the rejected general `wnf(book,term)` WeakMap experiment, which already increased core time and memory.

Changing generic ADT representation is lower priority until control-flow effects have been separated. B1 uses named object fields while H uses tag plus field arrays, but private accessor specialization already removes several generic projection paths. The inventory cannot tell whether another representation wins in the current V8 workload.

## Scope, effort and decision boundary

An already-computed-argument component prototype and its initial differential gate should fit a few hours; a robust typed worker lowering across matches, erased arguments, effects and higher-order exports is multi-day work. Constructor continuation lowering and a typed emission representation are also multi-day changes. These are planning estimates, not delivery promises.

Do not start a broad rewrite during the remaining Phase 4 gate window. Use the new residual profiles to select one falsifier, and update this design with its actual result. Old `apply` shares, a small-case profile, or a static count of 386 matcher roots cannot justify a whole-compiler speedup ceiling. B1/H implementation comparisons also cannot eliminate the separate algorithmic gap between the Bend compiler and the original TypeScript compiler.
