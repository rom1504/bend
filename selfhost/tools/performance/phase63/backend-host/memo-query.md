# Exact-identity memoization ceiling experiment

This is a diagnostic JavaScript derivative of the genuine Bend-produced B2,
not a production compiler change. It tests whether repeated *identical* queries
offer enough gain to justify a Bend implementation with explicit owned state.

Under the root's usual serial CPU3 process-tree guard, run a fresh worker for
each source/variant:

```sh
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase63/backend-host/memo-query.mjs \
  selfhost/build/phase63/checked-state06 \
  selfhost/build/phase63/final-state06/bootstrap/full/compiler.mjs \
  SOURCE baseline NEW_BASELINE_OUTPUT

node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase63/backend-host/memo-query.mjs \
  selfhost/build/phase63/checked-state06 \
  selfhost/build/phase63/final-state06/bootstrap/full/compiler.mjs \
  SOURCE arity NEW_ARITY_OUTPUT NEW_BASELINE_OUTPUT/program.mjs
```

Then repeat with `wnf`; use `both` only if an individual variant merits it.
Numeric and Map are the intended first screen. Keep each output new. A one-round
screen can reject an idea; repeated rotated fresh workers are required before
inferring stable gains. These workers themselves do not launch child targets.

Every variant imports the same original B2 bytes plus an identical appended
hook implementation, and uses the public supplied-API driver lane. This preserves
the comparison's loader path across variants, but does **not** measure ordinary
owned-API request latency: prepared-world admission differs in that lane.
Derivative generation and input verification are outside the reported clocks.
Import and request clocks are separate; no generated module is executed here.

`arity` wraps `$jd$jd_95_arity`; `wnf` wraps `$jd$wnf`. Each memo is a WeakMap from
the exact book object to another WeakMap keyed by the exact definition/term
object. It stores only a completed U32 or KTerm/KLambda/KLiteral result, without
forcing a trampoline or sharing an unfinished evaluation. A reentrant key runs
the original function. Each query's capacity is 4,096 entries per book and
65,536 total stores. Cap misses and uncacheable results remain original calls.
Exceptions remove pending entries. Tables reset immediately before the request.

The key assumes books and queried nodes remain immutable throughout a request.
It does not allow a hit between structurally equal books, normalize key terms,
equate aliases or survive a changed request. Returning the same cached immutable
result object can increase sharing, so this experiment measures avoided query
work *and* resulting allocation/sharing effects. Identity cannot simply be
replaced with a definition name, `term_key`, or a global persistent table in Bend.

The baseline includes the same counter wrappers with memoization disabled. This
balances much of their overhead but does not remove V8 specialization, lookup,
retention or JIT effects. Counts report lexical wrapper entries, not all internal
recursive SCC steps. Hit rate is not a speed gain. Memo variants must match the
complete independently produced baseline module; their finite success does not
prove purity, all refusal behavior, self-hosting or production conformance.

The receipt binds the original B2 emission and checked generator, derivative,
source, driver, runtime, Base and all returned input files. No derivative receives
a checked sidecar or becomes an installed artifact. Failed results remain failed.
