# Known lexical function transport

Phase48 experiment, baseline installed Phase47 array06 (`ee54723`). This is a
bounded source normalization before successful first-order admission, not a
blanket function-type purity rule. No timings or checked compilation exist yet.

The Phase47 Morning inventory identifies `Str.split.fin` and `Str.join.fin`
receiving recursive factory results. Their producers match before returning a
lambda. Immediate literal beta reduction alone cannot close that complete graph.
The first useful slice instead covers exact lexical lambdas, immutable aliases,
leading-lambda source helpers, and factories with straight-line Let prefixes.
Matcher-selected targets, recursive closure families, record-field transport and
public closure results remain future work; no claim that Morning now qualifies.

## Contract and representation

`j_function_flow(book, term, fresh)` returns a candidate term, the next fresh ID,
a bounded rewrite count, expanded source dependencies and a validity flag.
`fresh` must exceed all binder IDs in the original request book and context.
Only checked `Def` bodies with no templates and no native flag can become global
known targets. Their initializer must start with a lambda. Each copied bound ID
is renamed; free captured IDs keep their lexical value and alias identity.

Every live non-function actual gets a singleton administrative Let whose RHS is
annotated with the formal domain. Nested administrative Lets preserve left-to-
right argument evaluation, including unused arguments. A known lambda actual
can substitute an inert closure value; its body remains delayed until application.
A Let before a returned lambda stays before the next application's argument.
Only singleton sequential Lets reassociate; parallel source RHS scopes stay
unchanged. Erased arguments are omitted only under the exact formal quantity0
and a separate runtime absence check. No source numeric expression is duplicated
or discarded. Scalars, constructors and native calls are still subject to the
existing complete JPure/JW proof; this pass does not authorize their effects.

The returned dependency set is an integration obligation: retain the original
book, original source rows, original primitive scans, exact public code/env/bound
and arity snapshots, host/protocol checks and proof suspension at Error/reentry.
A normalized helper being first-order does not prove its public descriptor is
immutable. There is no new runtime dispatch helper or public closure ABI.

## Bounded hypothesis and falsifiers

At most64 expansions/reassociations,2048 nodes per copied lambda,8192 input nodes,
32768 output nodes and128 traversal depth. Exhaustion returns the original term
with `valid=false`; the caller must discard the entire candidate. Unknown
callbacks and escaped lambdas survive normalization and must fail first-order
admission. Request-local results only; no cross-context compiler cache.

Independent renamed fixtures must show a private entry actually runs, rather
than only observing a marker. Compare original installed compiler, candidate and
pinned TS full output. Positive cases include a factory prefix, noncommutative
nested application, a callback helper, two fresh factory captures and an unused
scalar actual. Negative cases include a returned function, an unknown function
parameter, a match-returning factory and partial application escaping publicly.
Boundary controls must mutate each expanded G dependency's code/env/bound/arity,
exercise ordinary/raw/oversaturated entry and Error-hook reentry, and verify
fallback plus source argument/error order. Array captures require a later owned
array fixture to demonstrate writes and aliases; scalar captures alone cannot
establish mutable capture safety.

## Relation to research

Lean's bounded specialization and lambda lifting motivate explicit capture and
context identities, not its purity assumptions. Go's `directClosureCall` prepends
free variables for literal known calls; global returned factories need separate
flow and prefix execution. Their contracts cannot justify changing Bend's public
mutable descriptors or matcher/partial saturation boundaries. See the pinned
[Lean survey](../../research/compilers_architecture_and_techniques/lean.md),
[Go survey](../../research/compilers_architecture_and_techniques/go.md) and earlier
[function-flow roadmap](../phase45/known-local-functions.md).

## Next finite-family slice: actual matcher-selected factories

The real source chain is exact and general:

* `Str.split(s)` matches String first. Nil returns a separator lambda with no
  captures; Con returns a separator lambda capturing the matched Char and tail.
* Inside the latter lambda, `Str.split(tail)` executes its factory prefix before
  `Char.eq(head, separator)`. `Str.split.fin(rec, comparison)` receives that
  already-created closure, matches the comparison, then applies `rec(separator)`.
* `Str.join.go(xs, head)` matches List first. Nil returns a separator lambda
  capturing head; Con returns one capturing head, next element and tail.
  `Str.join.fin` receives the recursive factory result and applies it inside
  nested String.append calls. Captures are String/List/Char, not function values.

Do not rewrite `factory(a)(b)` to a two-argument function that evaluates `b`
before the factory's match. Neither uncurried syntax nor final checksum proves
this legal. Directly distributing application into matcher arms also needs a
place for the actual evaluated after discrimination but before the lambda body.
A private closure-family data result supplies that place without moving work.

The proposed extension is request-local defunctionalization, followed by the
existing complete first-order graph proof and JW machinery:

1. Discover a finite set of terminal leading-lambda sites under typed factory
   Let/match prefixes. Keep each original prefix and saturation stage unchanged.
   A site's captures are exactly its runtime free variables in lexical order,
   with first-order closed types from the checked environment. Initially refuse
   function-valued captures, dependent captured field types and public escapes.
2. Generate one private tagged data family per compatible checked function
   signature and flow component. Each lambda site becomes one constructor with
   explicit captured fields. The factory still performs its original prefix and
   returns this record at exactly the former closure-creation point. Creation
   snapshots binder values once; repeated aliases reference the same captured
   Array/String/aggregate values, not reconstructed values.
3. Specialize source helpers on callback-family identities, extending the erased
   contextual-instance key with a tuple of finite family IDs. Rewrite callback
   parameters to their private family types. A callback application evaluates
   its callee record first, then every live actual once, then selects a site's
   lifted body through an ordinary private matcher/direct call. This is compile-
   time lowering into existing cases/calls, not a new public dispatch primitive.
4. Emit each lifted body with captures followed by source leading arguments.
   Recursive factories and callback helpers create ordinary graph cycles; reuse
   existing SCC/continuation machinery instead of recursive compiler inlining.
   Nil/Con alternatives remain distinct even when capture vectors are empty.
5. Retain the original source and primitive dependency closure, including factory
   and consumer helper identities. Generated private definitions never become
   public G dependencies or exports. Complete normalized graph admission must
   refuse a generated family at any native, public-result or foreign boundary.

This needs explicit private definition/type construction and contextual flow
collection, not a twelve-line extension to beta substitution. A reasonable
first cap is32 sites,32 helper contexts,8 captures/site,128 graph nodes and one
fully saturated callback stage. Any unknown merge or budget exhaustion refuses
that root entirely. General record-field transport can follow only after source
record provenance and every use stay within this same private graph. Partial
applications need separate staged family signatures and are not silently accepted.

Before implementing the family rewriter, root should obtain a diagnostic walk
of the exact checked Morning type/body tree: factory matched arm environments,
terminal Lam IDs/types, free captures, helper callback positions and original
saturation chunks. It must classify the two finite families without a source-
name whitelist. An independently renamed recursive list factory and callback
consumer should then demonstrate factory-prefix order and captures; this is a
stronger gate than the non-branching first fixture. Remaining native/String/Map
or public nullary profitability blockers may still prevent Morning activation.
No coverage count or performance estimate is asserted from this design.

## Feasibility gate and separate follow-on decision

The saved checked-API diagnostic is
`selfhost/tools/performance/phase48/function-flow-factory-facts-v2.mjs`. It
intercepts the actual library planner input, walks original typed source, records
Lam sites/constructor-arm paths, exact formal/body quantities, free runtime
capture IDs/types and original references, and stops before emission. It scans
higher-order source signatures without a name whitelist. It mirrors the existing
runtime-child traversal, including erased actual/field omission and Let RHS
versus body environments. It is a diagnostic, not the future admission proof.

Root may run one bounded source acquisition:

```sh
node selfhost/tools/performance/phase48/function-flow-factory-facts-v2.mjs \
  selfhost/build/phase47/checked-array06 \
  selfhost/tools/performance/phase37/fixtures-historical/test-morning-program.bend \
  selfhost/build/phase48/function-factory-facts02
```

The producer pins API/runtime/base/source/producer and rehashes them, writes an
API derivative with its own hash, and reports expected diagnostic termination.
Its walk bounds are4096 nodes per definition,150000 aggregate runtime nodes,
256 lambda sites,2048 nodes per capture scan,65536 aggregate capture nodes,
and depth128. Capture/type shape truncation or unknown typing is recorded and
must not be treated as a closed capture proof. No source compiler or runtime
file changes, target execution, timings or selected-entry claim result.

Proceed to a new family implementation only when the facts support all of:
finite terminal lambda alternatives; closed first-order capture types; callback
helper positions with finitely known families; no public/native family escape;
and a bounded original dependency graph. A negative finding falsifies the
proposed small family slice rather than licensing a broader flow analysis.
A positive finding still requires generated private type/constructor validation,
context collection and complete JPure/JW admission on independently renamed
recursive fixtures. Prefix failure, twice-created retained captures, unknown
callback, untaken arm dependencies and partial saturation are mandatory controls.

The complete family transform is deferred from H02 retention. H02 is the bounded
lexical slice and must first establish compiled activation, correctness, compiler
cost and representative impact. Morning remains outside that candidate; a
large, unmeasured recursive closure rewrite will not hold combined qualification.

Diagnostic v1 is preserved but unqualified: several checked helper calls return
trampoline messages, so direct inspection could silently misclassify their
results. V2 forces every compiler helper result through `run_loop`; accessors
remain direct. This is a diagnostic correction, with no admission or compiler
source change.

## Root-run factory facts: actual finite signatures and stages

Root ran the v2 diagnostic successfully in5.37 seconds. The report is complete
with expected stop, source `checked=true`, and no emission. Its data contains14
source definitions,266 runtime-child nodes,542 capture-walk nodes and28 Lam
sites, with no truncation or recorded typing errors. These are static source
facts, not a transformed-graph or escape proof.

The relevant terminal callback sites are:

| Owner / matched arm | Terminal binder | Captured source binders and exact types | Runtime callback signature |
| --- | ---: | --- | --- |
| `Str.split`, `SNil` | 3444 | none | `Char -> List<&2,String>` |
| `Str.split`, `SCon` | 3447 | 3445:`Char`,3446:`String` | `Char -> List<&2,String>` |
| `Str.join.go`, `Nil` | 3466 | 3465:`String` | `String -> String` |
| `Str.join.go`, `Con` | 3470 | 3467:`String`,3468:`List<&2,String>`,3469:`String` | `String -> String` |

Every terminal callback has formal/body quantity1. No terminal capture is a
function value. Diagnostic Lam sites also include constructor field binders and
ordinary source formals;28 sites must not be reported as28 closure alternatives.
The four rows above isolate the returned separator callbacks using exact arm
paths and checked types. IDs are evidence for this source, never compiler rules.

The consumer positions are `Str.split.fin` argument0 (`rec`, body binder3437),
with exact `Char -> List<&2,String>` type, and `Str.join.fin` argument1 (`rec`,
body binder3457), with exact `String -> String` type. Those function-typed helper
parameters still need contextual family conversion; inspecting scalar terminal
captures does not make the existing graph first-order. The join finisher's
separator formal/body quantity is2 and its sharing must remain intact.

The actual source corrects the proposed initial saturation scope. `Str.join.go`
is Mat-leading (zero leading lambdas, declared arity2). Each arm then has two
contiguous lambdas: head, separator. Recursive `Str.join.go(tail,nextHead)`
creates the matcher-selected function first, then supplies one argument of the
returned two-argument stage, leaving a bound separator callback. A single
fully-saturated unary-family rewrite is insufficient.

A bounded next implementation should therefore be staged:

1. Extract typed matcher-prefix alternatives, separating constructor field
   binders from runtime lambda stage parameters. Build a private stage record
   with the constructor-field captures; the original match still completes
   before any subsequent live actual. For split this record already has the
   unary callback signature.
2. For join, recognize exactly one known partial binding of that returned
   two-argument stage. Evaluate the head actual once after the factory prefix,
   append that value to a new private bound-stage record, and execute no lambda
   body yet. Preserve retained aliases and the original stage-arity boundary.
   Unknown, escaped or mixed-family partial calls refuse the root.
3. Specialize the two consumer callback parameters on family IDs and lower the
   final separator application to an ordinary private matcher/lifted body. Keep
   original recursive factory and finisher relationships as graph cycles.
   Split's recursive factory creation still precedes `Char.eq`; join's recursive
   prefix and bound head still precede its separator actual.
4. Re-run erased contextual specialization as needed, then complete JPure/JW
   graph admission. Generated family types/constructors and helpers remain
   private; original identity/primitive dependencies and full public fallback
   remain unchanged. No generated family is allowed at a public/native boundary.

Cap the first attempt at2 source factory components, at most3 private stage
signatures (split unary, join unbound head/separator, join bound separator),
2 alternatives per stage,1 known partial-binding stage,3 first-order capture
fields/site,8 contextual callback helpers and64 private graph definitions.
Unbound and bound join records require distinct closed types or an equally
explicit stage proof; do not let a separator apply accept an unbound record. Aggregate source-size and fresh-ID
bounds still apply. The caps are a falsifiable scope, not source-name selection.
The independently renamed recursive fixture must prove actual family activation
and constructor-match failure before a later argument; retained captures,
noncommutative bodies, partial over/undersaturation, unknown callbacks and Error
reentry are mandatory. Refuse rather than expand if a function-valued capture,
unknown flow merge, escaping stage or larger contextual graph is needed.

This diagnostic supports the finite captured-family hypothesis, while exposing
the necessary partial-binding extension. It does not establish full Morning
admission or speed. H02 remains deferred: its representative modules are exactly
unchanged. The bounded family pass is future work, not a reason to add the
lexical slice to the selected production compiler now.
