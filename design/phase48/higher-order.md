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
