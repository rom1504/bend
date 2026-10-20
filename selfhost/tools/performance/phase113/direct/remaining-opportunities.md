# Closures and lexer after products11

The strongest bounded reuse is the mature known-partial/literal-combinator
rewrite, now prepared separately in `../direct-closure/`. It has a concrete
closure-chain witness and a small semantic boundary.

In `coverage-closures-256`, products11 admits only14 direct functions, all
library/observer helpers. The workload's `chain`, `compose` and `bench` remain
generic. The actual `$direct.chain` body calls the retained compose factory,
allocates its literal addition closure, and uses continuation/application
transport. `$direct.compose` still saves one runtime frame and dynamically
applies `f`, then its continuation applies `g`.

The selected mature `direct.bend` provides `nd_partial_def`,
`nd_partial_selected` and `nd_comb_try` for this exact category. `compose`'s
closed linear App/Var body `g(f(x))` qualifies when the caller supplies a literal
lambda. Current Phase111 `p111_ref_app` handles saturation and otherwise takes
the slow curried path; the selected Phase112 selector adapter addresses matcher
combinators, not this non-matching linear case. Restoring the bounded semantic
plan can remove the factory/intermediate application without eliminating the
dynamically sized residual closure chain or changing stack behavior.

Lexer has a different remaining boundary. Products11 already admits33 direct
functions, including `$product.lex`, `$product.step`, `$product.step.at`,
classification, hashing and arithmetic helpers. Its product step avoids the
outer pair but still constructs the tagged `Mode` state: the flat `step.at`
body contains six constructor sites and two takes. A generic tagged-union
register representation could remove those state shells, but it needs a new
shape theorem and is not the same single-constructor product optimization.

The generator remains non-tail recursive: `ident` and `num` construct a String
node after recursive return; `gen` recursively builds the tail before applying
the expansion. Their public products11 bodies respectively contain four,
four and eight static frame sites. `batch` also has parallel/recursive work.
The mature `nf_call_local` explicitly refuses non-tail self calls, so simply
admitting native recursion would discard an existing stack-safety boundary.
Tail SCC support would not solve these observed non-tail generators.

Consequently:

- First restore the bounded known literal-combinator plan, then verify actual
  chain-route allocation/application removal and complete output.
- Keep lexer on the existing product/direct path while field facts, scalar
  inlining and runtime work are measured.
- Defer tagged-union flattening and non-tail constructor-recursion conversion
  until each has an explicit structured plan and a stack-safe emitted witness.

Evidence was read from
`selfhost/build/phase111/p113-products11-{coverage-closures-256,lexer}-emit/program.ssa`,
their emitted reports, the unchanged Phase93 fixture sources, and selected
mature `selfhost/src/back/native/{direct,flat,product}.bend` plus the Phase99
branch-closure helpers. Counts are static call-site counts, not dynamic events
or measured time attribution. No targets were run during this audit.
