# P69-006 — Specialize literal captures of tiny closed combinators

- Registered before patch/target execution: 2026-10-11.
- Owner: closure-factory lane; root executes all guarded targets.
- Correctness/measurement: proposed, unexecuted; no promotion.
- Follows P69-003 factory removal; compare separately with its selected v2.

## Claim

The factory optimization still allocates a literal function argument and calls it
dynamically. A tiny closed linear combinator can instead capture that lambda's
free values and expose its calls to existing literal-lambda beta lowering. For
example `compose(x => add(x, k), g)` becomes a residual closure that captures k/g
and directly computes `g(add(x, k))`. This removes work still present upstream.

## Restricted proof boundary

Only a P69-003-admitted ordinary partial call is considered. Require one to eight
actual live leading lambdas, at least one supplied literal lambda, and a residual
body containing only App/Var. All variables must be bound by the leading telescope
and each parameter must occur exactly once. Thus the residual body is at most
15 nodes, has no global references, effects, matches or recursive expansion, and
copies each literal argument at most once. Repeated/dropped parameters retain the
v2 factory path. A bounded body-depth scan refuses large malformed raw trees.

Alpha-rename every telescope binder before capture substitution. Reject synthetic
ID collisions with the original body, argument trees or caller environment; raw
IDs do not authorize accidental capture. Sequence all nonliteral arguments once
and in original order. Supplied literal lambdas are values; their existing free
value ownership passes to the residual lambda environment. Existing native
let/lambda sharing and beta rules handle those values, with no new runtime ABI.

Do not substitute arbitrary reference/function-producing expressions as code.
Their evaluation may fail, demand input, or produce distinct captures. Preserve
explicit bangs, foreign/intrinsic, early-matcher, overapplication and dynamic
fallbacks inherited from v2.

## Gates and falsification

Before execution root and an independent reviewer inspect the separate v3 patch.
Use a checked B1 and compare v2 versus v3 plus pinned upstream. Require correct
oracles, fewer closure environments/applies, and balanced native improvement.
Cover compose and an unrelated argument-permuting combinator, shared String
captures also used outside the closure, escaped/stored closures, repeated and
dropped combinator parameters (fallback), capture versus application error order,
and raw binder-ID collisions/unbound variables. Native controls include threads1/4.

Reject on changed output/first error, lifetime failures, missing fallback, excessive
code growth, or no measured gain. The predicted closure-family benefit is larger
than a helper micro-optimization, but no runtime estimate earns promotion without
actual output and timing receipts. No whole-corpus 0.5x claim is made.

## Preservation

V2 remains frozen. V3 source, patch, manifest, focused sources and raw cases live
under `selfhost/tools/performance/phase69/closure-factory/`. Root records actual
image/source/toolchain pins, all failed attempts and finite observation scope.
