# P44-002 — Stable invocation sites for known generated functions

- Owner: Phase44 lowering agent; independent reviewer: Phase44 review agent.
- Started: 2026-10-04 08:01 UTC, before derivation or timing.
- User objective: optimize ordinary language operations across applications using
  a modular backend. This experiment concerns generic application dispatch.
- Correctness: source inspection only; the proposed derivative is **unchecked
  saved JavaScript**, not a checked compiler implementation.
- Measurement: no derivative measurements yet. Decision: investigate with one
  bounded screen, then stop or choose a justified follow-up.
- Related work: [P44-001](P44-001-composable-ir.md),
  [IR architecture](../../selfhost/docs/JAVASCRIPT_IR.md) and
  [Phase44 design](../../design/phase44/README.md).

## Claim and cheapest disproof

**Hypothesis:** the generic runtime sends many unrelated generated functions
through shared JavaScript invocation sites. Giving an already known source
callee its own stable invocation site may help V8 optimize these calls while
retaining the current function descriptor protocol. The rule applies to supported
ordinary named calls independently of argument types, algorithm or benchmark name.

The first six-point checked04 production screen was effectively flat against
Phase43: the equal-point geometric execution gain was **0.98978×**, over 54 fresh
samples in 46.15 seconds. Individual baseline/candidate ratios were lexer 0.9910,
Map128 1.0016, BST64 1.0004, list512 0.9912, records256 0.9995 and closures256
0.9558. This short screen supports no speedup claim. Its
[raw report](../../selfhost/build/phase44/runtime-screen04/report.json) motivates
testing the remaining dispatch cost rather than assuming local IR simplification
will close the gap.

**Cheapest disproof:** derive the saved modules, confirm that eligible calls
exist, then run a fresh bounded comparison against their unchanged checked04
parents. No useful activation or no useful timing signal ends this direction for
the present phase. An attractive single point cannot justify a general speedup
claim. A semantic counterexample rejects the derivative regardless of timing.

## Intervention and invariants

The [derivation tool](../../selfhost/tools/performance/phase44/known-call-derive-v1.mjs)
parses actual generated JavaScript and selects module-level `G[name]` definitions
whose descriptor is built by `fn` with a literal code function, optionally under
the existing `scalarCapture` wrapper. Multiple writes, nested assignments,
unsupported wrappers and shadowed runtime identifiers refuse selection.

At the original code-function allocation site, the derivative captures that
function in a reserved private slot. A sequence expression prevents a newly
inferred JavaScript function name. It performs no extra public descriptor read,
reflection call or initialization-time callback.

For ordinary `callOwned(get(G, name), arguments)` sites, a private per-callee
invoker is passed through the existing runtime. The original `apply` logic still
decides exact saturation. Only the existing fallback invocation points in
`invokeExact` choose the specialized invoker. If the current code equals the
captured function, that invoker uses its stable private slot; otherwise it calls
the current code through the same original operation.

Required retained behavior:

- Callee lookup precedes argument evaluation; arguments retain their order.
- `.call` is resolved before `f.env`, with the same receiver and arguments.
- Existing descriptor, host-hook and exact-entry checks remain present.
- Replacement code, partial application and oversaturation retain their original
  behavior. No new exact-entry permission is granted.
- Forcing, trampoline messages, argument ownership and result representations
  remain unchanged. The callee body is not required to be pure.
- New private identifiers cannot collide with source bindings. Added parameters
  cannot capture an existing name in the two runtime functions being rewritten.

Extra private JavaScript frames and changed generated function text remain
observable through host stack/source inspection. This is an explicit diagnostic
limitation, not permission to silently change the production ABI. Matchers and
`exactCode` construction are outside this first intervention.

## Controlled setup and decision

The parent is the checked04
[full preparation manifest](../../selfhost/build/phase44/full-preparation04/manifest.json),
covering the maintained 45 points. The tool verifies every consumed module hash
and records parent/output identities, selected functions, rewritten sites and
refusals. It neither compiles Bend nor executes target programs.

From `selfhost/`, use a fresh output directory:

```sh
node --max-old-space-size=1024 tools/performance/phase44/known-call-derive-v1.mjs \
  --manifest build/phase44/full-preparation04/manifest.json \
  --out build/phase44/known-call-derived01
```

Root owns bounded derivation and serial execution on CPU 3, with a 1 GiB Node
heap, 2 GiB process-tree RSS ceiling and 2 GiB free-memory floor. Other builds and
profiles must not overlap timing. The first measurement uses fresh unchanged
checked04 and derivative execution under the same harness/protocol; retained
historical timing is not its denominator. Derivative roles remain explicitly
unchecked.

Limit the initial decision to derivation plus one short screen. If it shows a
repeatable, useful signal across different sources, choose the smallest additional
mutation/order/activation checks and a separate confirmation before considering
production lowering. Do not start a large validation campaign merely because
the rewrite produced many static sites. If the screen is flat or worse, preserve
it and stop; no source compiler change follows automatically.

## Independent review and preservation

Static review checked allocation timing, anonymous function names, `.call`/env
ordering, mutable code fallback, exact-entry handling, partial application and
oversaturation. One pre-consumption hardening request prevents the new runtime
parameter from capturing an existing identifier. No derivative execution or
performance result is implied by this review.

Preserve this pre-execution design, the exact consumed tool, input manifest,
derivation receipt, all outputs and all timing attempts. Record outcomes in the
Phase44 implementation report and ledger; leave the original checked04 modules
and earlier negative or neutral results unchanged.
