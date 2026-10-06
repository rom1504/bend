# Legacy JavaScript intermediate representations

This guide describes the retained **legacy descriptor backend**, selected with
`--legacy-js` or API `backend: 'js'`. Since Phase53, ordinary JavaScript output
uses the separate [direct backend](direct-javascript.md). Direct output does not
pass through the JIR/JW pipeline described here. See
[backend boundaries](../../docs/self_hosted/backend-boundaries.md) for the shared
checked core, backend-local representations and future native extension point.

The legacy JavaScript backend has two cooperating intermediate representations:

- **Ordinary runtime IR (`JIR`)** represents expressions that keep the public
  descriptor, application, matcher and trampoline protocols.
- **Private worker IR (`JW`)** represents a completely proved first-order graph.
  It makes private calls, control flow and layouts explicit so shared passes can
  remove those protocols inside a guarded boundary.

The dependent core and checker remain separate. The backend is not yet one
unified, source-independent IR: inherited optimizations and explicit compatibility
adapters still participate in selection. Neither IR is SSA, and introducing an IR
alone establishes no execution-speed claim. Its checked compiler API is not a
new self-emitted fixed point. Worker21 introduced the runtime exact-entry wrapper
for admitted nullary definitions while preserving their public function metadata;
compiler source and the selected runtime must be qualified together.

The Phase47 [private Array contract](../../docs/self_hosted/private-array-regions.md)
composes with the inherited typed-region and scalar-tree paths. A bounded audit
proves local Array<U32> origin, scalar public boundaries and a closed helper
graph. Consistent private-call normalization carries raw backing arrays through
helpers; existing statement destinations preserve ordered stores. The tree
adapter shares the same contract and existing frame emitter. A canonical no-F32
proof chooses a narrower host guard while retaining Math.floor for U32 division.
The original guarded handle-based and public fallbacks remain available. See the
[Phase47 report](../../implementation/phase47/README.md) for selection status,
measured costs and the short-call regression.

This guide describes the worker23/array06 foundations and the retained Phase48
RNFA04 mechanisms. At that historical checkpoint, release verification and all
42 CLI checks passed. The
[qualification receipt](../tools/performance/phase48/evidence/selected-qualification.json)
and [Phase48 report](../../implementation/phase48/README.md) bind that
compiler/runtime and its exact fresh scope. They are not current release
identities. The [Phase53 report](../../implementation/phase53/README.md) records
the direct-default release and its separate legacy compatibility checks. The
[Phase45 worker design](../../design/phase45/general-workers.md) and
[Phase44 ordinary IR design](../../design/phase44/README.md) retain their original
decisions and qualification boundaries.

The Phase48 RNFA04 compiler extends this foundation without a new general JW
pass: original-handle flat composite results, canonical String.append values,
typed U32/F32 Array effects, and finite F32 leaves inside successful private
region plans. The complete contracts, corrected strict-predicate demand and
bounded zero/one literal-entry policy are documented in
[private representations](../../docs/self_hosted/phase48-representations.md).
That campaign report separates its qualification and performance evidence from
earlier foundation checks. These preserved results are not measurements of the
current direct backend.

```text
checked, annotated KTerm
    |
    +-> ordinary expression lowering -> JIR -> local simplification
    |                                         -> expression/statement emission
    |
    +-> complete instance/JPure proof -> JW -> layout simplification
    |                                      -> whole-graph representation choice
    |                                      -> exact call components
    |                                      -> native loops + continuation fallback
    |
    +-> inherited proved plans
             |
        root-plan selection -> guarded public entry + ordinary fallback
```

The diagram shows legacy-backend domains, not unconditional compilation of every alternative.
Root selection evaluates candidates in order and keeps one result. A refused
private lowering retains the established fallback; it does not weaken the proof.

## Ordinary runtime IR

| Module | Responsibility |
| --- | --- |
| [`model.bend`](../src/back/js/ir/model.bend) | Typed operation and parameter definitions. |
| [`lower.bend`](../src/back/js/ir/lower.bend) | Type/provenance checks, erased slots, call chunks, literals and constructors. |
| [`control.bend`](../src/back/js/ir/control.bend) | Lower already admitted Boolean choices into ordered condition/branch operations. |
| [`facts.bend`](../src/back/js/ir/facts.bend) | The bounded `JIRCopy` environment, including lookup, admission and scope invalidation. |
| [`constants.bend`](../src/back/js/ir/constants.bend) | Fold nine admitted U32 operations on integer literal operands. |
| [`simplify.bend`](../src/back/js/ir/simplify.bend) | Bounded local alias propagation and exact identity-binding elimination. |
| [`emit.bend`](../src/back/js/ir/emit.bend) | Print the operations already selected by lowering. |
| [`statement.bend`](../src/back/js/ir/statement.bend) | Emit return-position bindings and branches as lexical blocks. |

The legacy entry is `j_expr -> jir_lower -> jir_compile`; `jir_compile`
runs `jir_simplify` before `jir_emit`. Lambda bodies use `jir_emit_return` for
statement emission. Compatibility entry points use the same compile schedule.

The facts module contains the lexical value environment actually consumed by
simplification. It is not a general effect, escape or ownership analysis. There
is no production structural-count visitor. Known target and arity alone do not
authorize bypassing a function's runtime descriptor.

### Operation contracts

- **Local and Null:** immutable lexical reads and the erased ABI value. Erased
  arguments, bindings and fields become Null without lowering their source
  expressions. Erasure must not evaluate an otherwise failing expression.
- **Global:** the ordinary `get(G, name)` operation. It can invoke a computed
  initializer on every reference, throw, or observe a mutated public binding.
  It is neither a constant nor a reusable pure load.
- **Literals:** preserve the existing checked provenance and runtime spelling.
  A user datatype named like a primitive retains its own representation. An F32
  word invokes bit reinterpretation; it is not automatically a movable constant
  under arbitrary host mutation.
- **Apply:** one already established application chunk. Evaluate the callee
  before the arguments and arguments left-to-right. Group only a proven leading
  lambda prefix. A matcher or intermediate computation can demand a result before
  later arguments run. Non-tail application retains `callOwned`; tail application
  retains the trampoline message.
- **Let:** parallel binding. Evaluate all RHSs in the outer environment, in
  order, before introducing any of the new binders. Source binder IDs can be
  deliberately reused by backend fixtures; shadowing must remain correct.
- **Lambda:** a public descriptor with the same leading arity and erased ABI
  slots. The delayed body retains tail demand. Captured values remain immutable
  lexical bindings.
- **Match:** delayed matcher construction. Its arm expression constructs the
  selected arm value when demanded; it is not an eagerly executed branch body.
  A proved single-constructor matcher has no emitted fallback. Ordinary field
  projection, copying and getter order remain runtime responsibilities.
- **Construct:** ordinary public construction. Non-tail fields are evaluated
  eagerly in order; tail fields remain delayed computations consumed by the
  trampoline. Passes must preserve that distinction and alias identity.
- **Primitive and choice operations:** retain the existing source/type/provenance
  admission. Primitive operands stay ordered and evaluated once. A Boolean choice
  evaluates its condition first and only its selected branch. Runtime arithmetic,
  errors and host assumptions are unchanged by representing the operation in IR.

Demand is part of the operation, not an emitter hint that a pass may freely
change. Returning an already demanded application must not convert it into a
tail message. Replacing a delayed constructor with an eager one can reorder
writes, reads and exceptions. Direct recursion also needs an explicit stack
strategy; known arity alone does not justify native recursive calls.

### General transformations

Copy propagation substitutes only admitted inert atoms. It evaluates parallel
RHSs using the old scope and invalidates a fact when either its alias binder or
its source is shadowed. At most 64 facts and 64 candidate bindings per scope are
considered. Larger scopes retain correct execution with less propagation.

An exact singleton `let x = value; x` becomes the same RHS node. The RHS is still
evaluated once in the outer scope, with its original demand. Other bindings stay
present because an opaque compatibility node may still refer to them.

Constant folding covers `U32.add`, `sub`, `and`, `or`, `xor`, `inc`, `not`, `shl`
and `shr` only when their already admitted IR operands are integer literal words.
The pass preserves modulo-2^32 arithmetic. It does not fold floating-point
words, mutable host functions such as `Math.imul`, or expressions involving
nonliteral operands. It introduces no general algebraic identity that could
discard an evaluation or coercion.

Statement emission removes immediate function calls around return-position
bindings. It first evaluates RHSs into reserved temporaries in one block, then
opens a nested block containing the source bindings and body. The two scopes are
necessary: declaring source bindings beside the temporaries would put outer-scope
RHS references into JavaScript's temporal dead zone. Constant bindings preserve
values captured by escaping closures. Branch statement emission retains delayed
branch selection and the same result demand.

These rules apply to operations and scopes. They do not test benchmark names,
input sizes or application algorithms.

## Private worker IR

Worker lowering is a consumer of admission proofs, not a substitute for them.
[`jpure.bend`](../src/back/js/jpure.bend) collects source instances and aliases,
replays exact source facts, and checks the complete `JPure` graph, coverage,
erasure and native provenance. An admitted legacy public root has zero to
eight live scalar inputs and a scalar or exact native String result. Its declared
arity must equal its consecutive leading lambda count. A matcher between
arguments therefore retains its public partial-application and demand boundary,
even when the same definition is legal as a saturated private callee.

The graph can contain closed internal ADTs and tuples. It cannot assume that
arbitrary public objects, returned closures or unknown callbacks share its private
ABI. Nullary roots must be nonliteral computations with a qualifying graph call;
plain values, function/IO/object results and unsupported graphs retain ordinary
emission. Native-source public roots require an actual contextual specialization.
An alias-only public graph also needs proved recursive work, as described below.
These entry restrictions leave acyclic helpers available as private callees in a
larger proved graph.

| Module | Responsibility and pass API |
| --- | --- |
| [`worker-model.bend`](../src/back/js/ir/worker-model.bend) | `JWValue`, `JWInstruction`, `JWFunction`, lowering results and emission context. |
| [`worker-lower.bend`](../src/back/js/ir/worker-lower.bend) | `jw_functions(book, defs, defs)` lowers checked types and source facts to ordered instructions; invalid or unsupported forms refuse the graph. |
| [`worker-simplify.bend`](../src/back/js/ir/worker-simplify.bend) | `jw_simplify_functions` removes terminal tuple/Char case tests already proved unconditional. |
| [`worker-nat.bend`](../src/back/js/ir/worker-nat.bend) | `jw_nat_functions_valid` checks the whole graph before `jw_nat_functions` changes Nat representation; also defines boundary conversions and exact Number operations. |
| [`worker-graph.bend`](../src/back/js/ir/worker-graph.bend) | `jw_components` validates explicit private edges and returns exact SCC labels or `None`. |
| [`worker-emit.bend`](../src/back/js/ir/worker-emit.bend) | `j_worker_emission` composes lowering, simplification, representation choice, component planning and emission, returning `JWEmission{code, numberNat, recursive}`. |

`j_worker_emission` first simplifies the lowered functions. It checks that every
function is valid, chooses Number Nat only if the whole graph qualifies, and
computes components from the explicit calls. Nat rewriting preserves those calls,
so the same component plan applies to both representations. Failed lowering or
component planning returns empty code; the caller then uses the existing backend.
`JWEmission.numberNat` is meaningful only with successful nonempty code.
`recursive` comes from the same successful SCC labels: a multi-member component
or an explicit self-call proves recursion. The caller uses this fact for public
entry profitability; it is not a second source-text or graph analysis.

### Values, instructions and ordering

`JWValue` distinguishes slots, admitted literal fragments, typed compact Nat
literals, global loads, projections, primitives, constructors, native calls and
selected Number operations. Constructor/projection/global nodes retain the layout
facts resolved during lowering. These are checked semantic tags, represented by
strings in the current model, rather than a separate fully typed machine language.
`JWLiteral` still contains an admitted JavaScript fragment; passes must not recover
semantic facts by parsing it. Nat has its own node specifically to avoid that.

Every private call is a `JWDirectCall` instruction with a numeric function target,
result slot and ordered arguments. There are no hidden private calls inside
`JWValue`. The other instructions are assignment, two-arm case, return and an
impossible-branch marker. This makes the call graph complete without searching
source terms or generated JavaScript.

Lowering stores nontrivial expression results in stable slots. Arguments and
constructor fields retain left-to-right evaluation, and parallel-let RHSs use the
outer environment. Literal leaves can remain inline; a later pass must not assume
that every value is a slot or that every literal fragment is inert under host
mutation. Matches project fields only in the selected branch. The simplifier
removes an unconditional tuple/Char case only in terminal position and keeps the
branch's field reads and ordering.

`JWGlobal` remains a `get(G, name)` at its established demand point. The small
admitted literal-global subset is not a general constant-propagation permission.
A computed zero-argument source reference instead represents a demanded call:
instance collection includes its body, rewrites it to its proved private target
and worker lowering emits `JWDirectCall` with an empty argument list. Each source
reference still executes; this adds no memoization or import-time evaluation.
Unknown targets and unsupported bodies refuse lowering.

`JWNative` keeps its public runtime call unless a separate representation pass
explicitly proves a direct operation. Exact source ownership and the enclosing
runtime guards remain necessary even for known primitive names.

### Components and stack policy

`jw_components` accepts at most 96 functions. It visits every explicit call,
including both case arms, validates target indices and function validity, and
computes full reachability with three U32 bitsets per row and exactly one pivot
per function. Mutual reachability determines SCCs. Missing rows, oversized graphs
or invalid targets refuse the backend; truncated analysis cannot report success.

Acyclic singleton components become ordinary positional functions with scalar
locals. Calls between components follow the condensation DAG, so their native
stack depth depends on the finite graph, not the depth of an input structure.
Recursive components share a native program-counter loop and, when needed, an
explicit continuation machine:

- An exact same-component call immediately returned from the same result slot is
  a tail transfer. The native loop captures **all** new arguments before updating
  any parameter slot, then changes its entry PC and continues. It neither recurses
  in JavaScript nor consumes another recursion allowance.
- Other recursive calls use one lexical budget of 32 native entries, shared by
  all recursive components in the root's private graph. Entry decrements it and
  `finally` restores it on normal return, error or reentry unwind. This is an
  entry count, not a claim of only 32 JavaScript stack frames.
- At exhaustion, the wrapper enters its private continuation machine. Same-SCC
  non-tail calls save a return PC and the current register vector; the child has a
  separate vector. Same-SCC machine calls stay in the machine and cannot reset the
  native budget. Cross-SCC calls still follow the DAG.
- If **every** intra-SCC edge is an exact tail transfer, the native loop is enough.
  `jw_tail_component` uses the same tail predicate as emission, traversing every
  member and both branches. Such a component has no machine or budget charge,
  including when called from a graph whose budget is already exhausted.

The fallback is private and preserves its current representation. Falling back
through public `G` could reenter another optimized root with fresh state and would
not establish this stack bound. The proof covers compiler-controlled recursion;
it does not bound arbitrary recursive calls made by external host hooks.

### Private representations

Tagged worker values use a fresh `{$: tag, _0: field, ...}` object, with matching
named-field projections. This removes the separate public field array only inside
the closed graph. Public construction, projection and returned-object identity
remain governed by the ordinary ABI. The worker does not yet reconstruct arbitrary
composite results for export.

The worker22 extension, retained in worker23, admits canonical Unit in the private
type proof and therefore `Map<&2, Unit>` (the pinned `Set()` representation). The predicate
requires the exact native zero-parameter Unit owner, its single native nullary
constructor and the same normalized result owner. It also permits Unit inside
already supported List/Maybe compositions. It does not admit arbitrary payload
ADTs such as `Map<Bead>` or a same-named local owner.

This extension uses the existing private tagged layout: each internal Unit is a
fresh `{$:'Unit'}` object. There is no singleton substitution. Public Unit/Map
inputs and results retain ordinary admission, identity and `{$:'Unit',a:[]}`
construction; native-call arguments do not gain Unit permission. Checked
independent controls exercise private activation and those public refusals;
full release qualification remains separate.

`jw_native_boundary` is a separate fence against incompatible native calls. It
rejects tagged/tuple inputs and admits only proved scalar/String/Char results,
the exact nullary-constructor comparison type, or the exact native Nat pair.
Keep this fence when widening the upstream purity/native whitelist: public and
private tagged objects do not generally have interchangeable fields.

The Number Nat pass is a whole-graph representation choice. Public Nats remain
BigInt; the existing scalar guard validates them before input conversion, and a
Nat result converts back at the public boundary. Internal values stay exact in
`0..2^48-1`. Addition and successor retain range checks, subtraction saturates at
zero, and division computes the remainder first and then `(a-r)/b`, preserving
exact integer quotient and the original zero-divisor result. Shift operations
retain the at-least-32 behavior. Only explicitly supported operations are rewritten;
an unsupported native operation or incompatible global retains the original
BigInt graph. Compact literal payloads are U32-sized; this does not narrow computed
Nats or public arguments/results above `2^32-1`.

Direct native constructor emission is another layout rule. Exact Bool, two-field
Tuple, String empty/cons and Char forms emit their established native operations.
Tuple creates one fresh array with each field evaluated once. String retains the
`String.fromCodePoint` lookup/receiver and argument order; Char still uses
`checkedChar`. Unknown layout/name/arity combinations keep `ctor`. Repeated String
head reads are legal only because lowering provides a typed Char leaf or stable
slot, not an arbitrary expression. Neither this pass nor Number Nat changes the
public constructor ABI.

[`projection.bend`](../src/back/js/ir/projection.bend) is a shared companion plan
for inherited private emitters. `jir_projection_plan` resolves exact String/Char
ownership; its condition, bindings and field APIs replace temporary projection
vectors with scalar bindings. It captures the input once and preserves the original
code-point reads and String method order. This plan does not itself grant private
entry permission and is not a third general-purpose IR.

## Public boundaries and backend selection

Private execution retains the public descriptor wrapper and ordinary fallback.
`exactCode` must establish exact-entry permission; direct ungranted `.code` calls
cannot acquire it. The entry checks source/dependency identities, supported host
protocols, scalar inputs and the existing region state before calling workers.
Global/descriptor mutation, `code`, `env`, `bound`, `.call`, partial application,
getter order and errors remain observable at those boundaries.

For nullary contextual roots, `exactCode(inner, arrow=false, nullary=false)` uses
a distinct anonymous normal function with zero formal parameters. It preserves
`code.length === 0`, empty `code.name`, own prototype and constructibility. It
reads `arguments[0]` only when an argument was supplied, so raw `.code()` does not
introduce an inherited numeric getter read. Raw invocation and oversaturation
receive no permission; exact saturation keeps the existing one-use token, late
environment evaluation and `finally` restoration. The runtime fragment and
concatenated runtime must stay synchronized.

Worker23 also captures the reflection methods and `Reflect.apply` used by
exact-entry bookkeeping during standard module initialization. A native WeakSet
membership function is bound once to the private set and called directly, with
no per-call membership vector. This prevents post-import reflection hooks from
running before the body can reach its host guard. The live public `code.call`
lookup still precedes `env`; token installation remains after that read, with
the same cleanup. The repair removes five newly exposed nullary hook observations
and an older dynamic WeakSet observation. The
[exact-entry experiment](../../experiments/phase45/P45-023-exact-entry-preflight.md)
records the ordinary-source anchor, historical behavior and six passing hook
controls; it does not broaden support to hostile pre-import intrinsics.

The primitive descriptor fence now comes from the complete successful source
graph, including original contextual bodies, before IR folding or Number-Nat
rewriting. The bounded collector visits every child and branch, deduplicates known
primitive names and conservatively includes erased/type occurrences. Missing or
invalid proof, or exhaustion of its aggregate 131,072-node budget, retains the
full historical 54-name fence. Source and native dependencies, full host/String
guards and their ordering remain unchanged. Removing an emitted operation alone
does not justify removing its source dependency.

These optimizations follow the existing
[host initialization and mutation contract](ARCHITECTURE.md). Standard intrinsics
at initialization and the supported post-import mutation fallbacks are not proof
of equivalence under arbitrary hostile pre-import shims. Unknown calls or
observer-bearing operations do not become pure because an enclosing graph has a
private representation. The used-primitive collector relies on this already
established initialization contract; the earlier pre-import shim counterexample
remains outside that supported domain, not disproved by post-import tests.

Root selection in [`emit.bend`](../src/back/js/emit.bend) preserves successful
existing natural-number/branch, structural-tree and callback plans first. It then
consumes `JRootPlan{code, strong}`, defined in
[`region.bend`](../src/back/js/region.bend):

1. A successful complete fusion, a region without residual generic helpers, or an
   actually audited and active flat graph is strong and precedes the general worker.
2. Otherwise try the complete instance/worker backend.
3. If that refuses, use the already constructed weaker region plan, then the
   existing U32 plan or ordinary descriptor fallback.

Strength is carried by the successful planner, including the flat-graph result in
[`tree.bend`](../src/back/js/tree.bend). It is not inferred from a source name,
output comment, graph size or a purity proof alone. The region result is constructed
once and its required declarations stay with its selected code. This is a
conservative ordering of existing plans, not a general performance cost model.
Before adding a new alias-only public entry, worker selection also requires
`JWEmission.recursive`. Real contextual rows retain their historical admission.
The same gate applies before either private emitter, so refusing a small acyclic
worker cannot silently install its older private counterpart. This corrected the
large row-program regression caused by guarding a two-function scalar helper at
every element; it uses graph structure, not that helper's name. Recursion is a
conservative amortization signal, not a guarantee of profitability.

Existing specialized transformations still need migration into shared passes;
deleting them before replacement can discard a better implementation.

## Remaining compatibility boundaries

`JIRLegacy` retains an expression, environment, type and demand for an inherited
backend path. Inherited private layout plans, deep closure factories, recursively
compressed constructor literals and less common runtime forms still use it. The
new worker pipeline is selected separately; ordinary JIR is not automatically
converted into worker IR. The adapter's hidden source uses and effects are opaque
to IR transformations. Ordinary
children emitted by the adapter reenter the IR pipeline.

`JIRCallPlan` retains an inherited guarded call plan and a structured generic
fallback. The plan still consumes source facts during emission; the new printer
is therefore not yet completely independent of the checked book. Rewriting its
fallback does not authorize dropping binders referenced by the retained plan.

Legacy instance coverage handles application spines, not computed nullary
references. If worker lowering fails and any original instance row has zero
source arity, selection declines the legacy private emitter too. It retains
ordinary source emission instead of generating an unbound private `G` load.
This conservative refusal is separate from ordinary `JIRLegacy` expression
adapters and does not authorize bypassing their source uses.

An opaque source subtree is not analyzed merely because its enclosing expression
has an IR node. Migrating an adapter should remove the replaced implementation,
not add a second unused path.

The exported library exposes mutable function descriptors and global bindings.
Known target and arity alone do not permit bypassing `code`, `env`, `bound`,
partial application or host hooks. Unknown calls and observer-bearing operations
can invalidate assumptions. Direct-call passes must keep these boundaries
explicit; a closed executable contract cannot silently replace the library ABI.

## Extending and validating the pipelines

1. Choose the domain first: a public-runtime operation belongs in ordinary JIR;
   a transformation relying on complete private ownership/admission belongs in JW.
   State demand, evaluation order, scope, erasure, representation and observer
   contracts before changing code. Legality and expected benefit are separate.
2. Resolve source/type facts in lowering. Express the transformation over shared
   operations and layouts; do not add source-name or generated-text recognizers.
   Add a node only when its semantic contract differs. Keep opaque fragments opaque.
3. Update every consumer of a changed node. For JW this includes lowering,
   simplification, Nat admission/rewrite, call-graph traversal, native-boundary
   validation and both direct/machine emission. A new private call form must appear
   in graph analysis; a new representation must either update all compatible
   boundaries or refuse them. Preserve exact tail argument capture and frame
   ownership. For JIR, update expression/statement emission and lexical scope facts.
4. Keep passes composable: graph analysis consumes explicit calls, representation
   rewriting preserves them, and root selection consumes planner results. If a
   pass changes calls or layouts, recompute affected facts rather than retaining a
   stale success flag. Bounds and unsupported forms must retain a correct fallback.
   Retire the old implementation when its replacement actually covers its contract.
5. First establish unchanged-emission or differential evidence for the migration.
   Then exercise renamed helpers, mixed features, parallel shadowing, erased
   failures, delayed matches, public mutation, raw `.code`, partial/oversaturated
   calls and genuine errors/reentry. Add deep tail and non-tail cases at the default
   host stack, including calls across components at exhausted budget. Test Number
   Nat above `2^32`, at `2^48-1`, overflow and division boundaries. Require evidence
   that the new path activates and that guard refusal reaches the ordinary path.
6. Measure compiler requests, emitted size and generated execution separately.
   Run cheap semantic screens before broad conformance and timed corpus checks.
   Validate selection across other admitted programs: one successful private
   optimization does not justify replacing every existing backend plan. Preserve
   failed attempts and distinguish historical identical-output evidence reuse
   from fresh executions.

The first Phase44 migration produced byte-identical output for the maintained
45-point, 23-source corpus and passed independent composition and backend
observations. That establishes a checked starting point for those artifacts;
subsequent transformations require their own qualification.

Run the focused IR contract suite from `selfhost/` with a checked attempt and a
fresh output directory:

```sh
node --max-old-space-size=1024 src/back/js/ir/test.mjs \
  build/phase45/checked-worker23 build/phase45/ir-local-check01 \
  --expect-statements --expect-folds
```

The suite uses the real `j_library` entry and selected runtime; its synthetic
KDefs isolate backend contracts and do not replace checked-source conformance.
Both flags require actual transformation activation. Change the attempt path
when qualifying a successor and retain each previous output directory.

Worker, SCC, native-boundary and deep-stack controls are listed with their actual
checked artifacts in the [Phase45 report](../../implementation/phase45/README.md).
They supplement this ordinary IR suite; they do not turn a bounded private backend
into a universal conformance or ownership proof.

## Phase48 adapters and their IR domains

| Source module | Consumed facts and representation |
| --- | --- |
| back/js/array-result.bend | Exact flat scalar/Array field telescope and closed scalar-input graph; private vector returns original Array handles, final ordinary ctor restores public record ABI. |
| back/js/array-effects.bend | Canonical erased U32/F32 element and native telescope; shared ordered printers for public handles and proven raw backing. |
| back/js/array-effect-guards.bend | Fresh complete host permission for native Array graphs, including retained handle/fold/tree routes. |
| back/js/array-literals.bend | Explicit constructor-handle context and loop witness; lazy arraydata remains public. Bounded direct-count facts may decline trivial entry, never grant permission. |
| back/js/private-float.bend | Compact finite F32 KTerm becomes private JF32 leaf; original shared DataView write followed by exact dyadic value. |
| back/js/ir/native-values.bend | Already admitted JWNative String.append with two String operands emits ordered primitive concatenation; other names/arities keep dispatch. |

JF32 is private typed-plan metadata, not a new ordinary JIRWord contract or a
JW constant-folding rule. The typed region creates it only for canonical finite
F32 literals; nm stays F32 so floating host requirements remain. Flat-tree and
closed-array audit whitelists recognize the leaf, while the ordinary public
fallback preserves bitsFloat. Nonfinite compact payloads retain decoding.

Raw-array mode and handle mode are separate facts. A result containing Array
handles can be publicly returned without reconstructing them, but does not
permit raw backing escape. Public container inputs, nested/dependent composite
results, unknown helper effects and escaped factories still refuse the new
adapters. Array stores retain source rounding rather than introducing a new
rounding convention; writes/conversions and self-tail updates keep their order.

Do not implement admission fences with eager Bool.and when rejected inputs
could trigger normalization, coercion or expansion. Use kc before demanding a
live argument as a type. Facts have bounded visitors and conservative absence;
a failed proof or exhausted budget keeps the original emission.

The deferred H function-flow and V aggregate-return conventions are archived
experiments. Their fixture passes and constructor counters do not put them in
RNFA04. See [remaining opportunities](../../implementation/phase48/remaining-opportunities.md)
for actual unsupported matched factories, persistent output and public-entry
costs. Selected layouts and counters alone establish no parity or speed claim.
