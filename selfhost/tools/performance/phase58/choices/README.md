# Typed literal-choice proposal

The isolated patch adds `direct/choices.bend` and small hooks in `core.bend`,
`ordered.bend` and `calls.bend`. Root owns application, manifest integration and
every compiler/target run. `identity-v1.json` records the complete before/after
files and patch. The new module belongs after `ordered-values.bend` and before
`core.bend`. There is no runtime or legacy-emitter change.

The shared legacy `j_choice_definition` establishes the exact source behavior:
an erased result type followed by a Bool matcher; True invokes the first callback
once with Unit, False invokes the second. Direct admission additionally checks a
four-argument monomorphic definition, complete saturation, literal live lambda
callbacks, and live canonical Bool / Unit callback domains. Source spelling does
not participate. Ordinary calls fail the structural checks before normalization.

In return position the selected callback body uses the existing continuation and
SCC transfer machinery. The call graph applies the same admission and scans both
possible callback bodies with one live Unit argument. The condition remains
non-tail. In expression position a local IIFE contains the branch bodies and
clears the outer SCC owner. Ordered lowering leaves the condition's prefixes in
the surrounding scope, before later sibling prefixes, while its pending value
stays in the conditional. Branch prefixes never run speculatively. A used Unit
binder receives a fresh ordinary `{$:"Unit"}` object; an unused allocation can
disappear. Captured source bindings retain their existing lexical scope.

Partial calls retain eta expansion. A surplus application retains the existing
overapplication path; its fully saturated inner call may independently qualify.
Nonliteral callbacks, altered selector bodies, and ordinary user Bool/Unit types
remain calls. This is source-value optimization under the direct backend's
standard-builtin domain: observing private `jd_clo` wrapper assignments through
inherited `Function.prototype.j`/`f` setters, or private trampoline packets, is
outside the claim. Arbitrary source callbacks, their effects and thrown values
remain inside it.

The first unconsumed draft hid condition prefixes inside the expression IIFE.
Independent review identified a tuple-sibling order change; the reviewed patch
propagates the prefixes and ordinal counter through `JDOrdered`. The `composed`
fixture explicitly requires probe(1) before later(2), including a later throw.

No compile-time or runtime benefit has been measured for this proposal. It adds
99 lines in one module plus narrow hooks. No cache or whole-program inliner is
introduced; recursive callback scans use the existing 8,192-node body budget.

## Root-executed gates

Use genuine open Phase58 checked attempts, preferably scalar01 → choice01, so
the baseline has all independently selected predecessor changes. The private
paired worker never imports a driver from a closed attempt directory. The two
catalog sources test 36 independent results/errors, including renamed admission,
wrong-body `kc` refusal, nonnative Bool/Unit refusal, 100,000-step self and mutual
tails, non-tail recursion, partial and surplus application, captures, and Unit.
The controller adds nine host observations per role and eight complete-function
AST activation/refusal checks. These are overlapping controls, not 53 programs.

From the repository root, run the following child command under the existing
root supervisor (CPU3, 1 GiB heap, 2 GiB tree RSS, 4 GiB available floor, 120 s):

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/qualification/paired-fixtures-v2.mjs \
  selfhost/build/phase58/checked-scalar01 selfhost/build/phase58/checked-choice01 \
  selfhost/tools/performance/phase58/choices/catalog-v1.json \
  selfhost/build/phase58/choices-paired01
```

The existing TypeScript acquisition owns its resource guard; do not nest one:

```sh
python3 -B selfhost/tools/performance/phase52/acquire-semantics-v2.py \
  --catalog selfhost/tools/performance/phase58/choices/catalog-v1.json \
  --selection upstream:selfhost/.bootstrap/upstream-phase23 --role typescript \
  --out selfhost/build/phase58/choices-typescript01
```

After both acquisitions pass, run this controller child under the same root
supervisor (60 s is the initial bound). It imports only the generated modules.
Each primary module must have its adjacent `non-native-choice.mjs` and checked
`.json` receipts from those exact producers:

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/choices/controls-v1.mjs \
  selfhost/build/phase58/choices-paired01/baseline/literal-choices.mjs \
  selfhost/build/phase58/choices-paired01/candidate/literal-choices.mjs \
  selfhost/build/phase58/choices-typescript01/modules/literal-choices.mjs \
  selfhost/build/phase58/choices-controls01
```

Keep every failed acquisition/control output. A source correction requires a
successor fixture/catalog/controller once these files have been consumed.
Successful focused gates would establish this bounded slice; final compiler
self-emission, corpus equivalence and promotion remain separate decisions.

## Acquisition correction

`selfhost/build/phase58/choice-fixtures01` accepted the main literal-choice source,
then rejected the negative source because `Bool` is a reserved compiler-encoded
name. The v1 source, catalog, controller and failed receipt remain unchanged.
This was a fixture admission error, not an optimization counterexample.

The current successor is `non-native-v2.bend`, with legal user-owned
`OpaqueBool`/`OpaqueUnit` and constructor names. `catalog-v2.json` changes only
that source identity and input tags. `controls-v2.mjs` pins its three v1 ancestors
and retains the 36 value/error oracles, nine host observations and eight AST
checks. This tests a legal ordinary-layout selector; the preserved v1 failure
separately records the frontend's reserved-name boundary.

For the recipes above, use `catalog-v2.json`, `controls-v2.mjs`, and fresh output
directories `choice-fixtures02`, `choices-typescript02`, `choices-controls02`.
The original main `choices-v1.bend` and compiler patch are unchanged.
