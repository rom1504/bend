# Phase66 JavaScript host and runtime migration

This lane ports the host boundary and direct JavaScript runtime to upstream
`059266225b77c8ca256ac6b25ee5c21449bab151`. Candidate files are isolated under
`selfhost/tools/performance/phase66/host-runtime/`; this report initially records
source work, not compiler validation or a measured speed improvement.

## Owned surfaces and dependencies

The source owner controls `selfhost/src/back/js/direct/host.bend`,
`host-native.bend`, `selfhost/src/runtime/js/direct.mjs` and copied JavaScript
effect-provider bytes. `host-native.bend` requires no change in this candidate.
The frontend owner supplies `name_key`, which replaces only the first namespace
colon with a dot. The backend owner updates constructor emission/patterns and the
pure-main display descriptor. The Base-host owner controls provider manifest,
origin documentation and host-side provider admission. No compiler algorithm
moves into JavaScript transport.

## Composite host marshalling

The old generated converters followed one directly self-recursive ADT field in
a loop, while other fields and Array elements called converters recursively.
An ADT/Array alternating value could therefore overflow JavaScript's call stack
at a modest value depth despite a small recursive type graph.

Every generated ADT or Array converter now accepts `(value, queue)`. A top-level
conversion creates one queue; composite fields append converter/object/key
triples, and only the owning converter drains the queue. This matches upstream's
LIFO composite work order. Nat conversions and function wrappers execute at
registration time, as upstream does. Arrays still mutate in place; ADT nodes
with converted fields are copied; unchanged ADT nodes retain their identity.
The emitted inline named converter expressions and lexical recursion references
remain in use. This candidate does not introduce a global converter registry or
claim upstream's per-file converter-code sharing.

One field plan determines both whether to copy an ADT and what conversion work
to emit. Obsolete tail-field-selection helpers are removed. Existing bounded
type-planning refusals remain explicit rather than silently omitting fields.
Value traversal itself has no recursive JavaScript call-stack growth through
composite ADT/Array edges. The new upstream regression fixture
`tests/io/marshal_array_depth.bend` exchanges a 20,000-deep Array-wrapped tree,
checks every BigInt Nat field, mutates the leaf, and checks the returned value.
This is the primary focused runtime control; deep ADTs, callbacks, multiple
branches, mutation/copyback aliasing and exception order require companion
controls.

## Effect and runtime contracts

Generated foreign requests now carry the displayed effect tag, marshalled
arguments and continuation. The registry maps tags to run functions directly;
there is no `$FFI` wrapper or `need` callback. Effects park themselves. The
runtime polls due timers and file descriptors while computations remain
runnable, and includes the current try/deadline IO helpers and Node errno
fallback. Thirty-five provider files are copied byte-for-byte from the pinned
reference; the removed `tcp_poll.js` and `udp_poll.js` providers are deleted.
The staged provider bytes match the Base-host owner's manifest exactly.

A source review found one retained old behavior incompatible with current
upstream: eager module registration checks prevented the required output before
an unregistered effect was actually executed. The preserved v1 candidate shows
this mistake. `host-converters-v2` removes the eager check and its dead helper;
missing registration is refused at request execution. Duplicate registration
remains a runtime error. The upstream `effect_unregistered` fixture explicitly
checks this demand order.

All public export names, constructor tags, effect tags and CID/FID substitutions
use `name_key`; internal function IDs and book lookup keys remain unchanged.
The runtime takes the new single mixed numeric/string display descriptor,
coordinated with the backend owner's program emitter.

## Deliberately retained runtime behavior

Two local differences from upstream remain: the qualified NaN-payload-safe
`f32_bits` implementation and the old array jump payload shared by unary
`run_tail` and variadic `jd_tail`. The optional upstream scalar unary micro-change
is excluded from this migration. This keeps variadic compatibility and avoids
mixing an unmeasured runtime optimization into the update. The underlying
`f32_round` implementation is byte-identical between the old and new upstream
TypeScript references. `F32.read` now follows upstream's ASCII-only leading
whitespace rule.

## Isolated artifacts and source checks

- `runtime-providers-v1.patch` / manifest: direct runtime plus exact provider
  bytes and the two removals; runtime SHA-256
  `7fe4fbb3ddfdd3c7ea9ccd8d71cecb8f3ce51cd678a8fb7d95fd02cc70aba575`.
- `host-converters-v2.patch` / manifest: host source SHA-256
  `b6d27efec9c7d4099d251c5bbdf3c3ad081d1c171750d5eccba6ff9d985976f3`;
  398 original lines become 381. Version1 remains preserved as pre-review work.
- Data-only checks confirm balanced staged Bend delimiters, unchanged
  `f32_round`, and all 35 provider names, lengths and hashes against the separate
  manifest. These checks are not parsing/typechecking or semantic execution.

Root owns applying these artifacts, the combined namespace/show integration,
all target executions and final qualification. No speed or passing compiler
claim follows from source review alone.
# Focused execution gate

The root-run [controller](../../selfhost/tools/performance/phase66/host-runtime/controls-v1.mjs)
and [method record](../../selfhost/tools/performance/phase66/host-runtime/controls-v1.json)
are ready for a fresh checked attempt. They pin the complete frozen snapshot,
qualified API, Node, Base, the exact converter-v2 source and runtime-v1 bytes.
Preparation and ordinary compilation use a private cloned host project.

The 16 controls cover five runtime protocols (unary, deep closure, variadic and
nullary tails, partial library application and NaN payloads), eight actual
Bend-generated wrapper behaviors (Array identity and copyback, copied ADTs,
curried Nat callbacks, function leaves, exported partial arity, composite LIFO
order, immediate scalar failure and unknown tags), and three upstream source
fixtures: `marshal_array_depth`, `marshal_closure`, `marshal_native_forms`.
The first fixture crosses 20,000 alternating ADT/Array levels. Private canonical
type-graph tests are explicitly diagnostic; the three source fixtures use the
ordinary owned driver and require exact upstream stdout and successful exit.

The controller preserves partial receipts after each case and verifies pinned
inputs again after completion. Its SHA-256 is
`525318f77807808890c94654d7bb8b3b3cc82fe76ef5e1e84b0158094507044b`.

Root's first execution is retained at
`selfhost/build/phase66/host-runtime-controls01/report.json`. The actual raw
checked-B1 image `abccec43…6671ab` passes all 13 runtime/private-wrapper cases.
The first source fixture then fails with `Maximum call stack size exceeded`
during `load`, before checking or backend emission. Closure/native-form source
fixtures are consequently unrun; the gate is incomplete and does not pass.
The 20,000-level runtime value has not been constructed at that boundary, so
this receipt alone does not implicate the new marshalling stack.

The separate [load diagnostic](../../selfhost/tools/performance/phase66/host-runtime/trace-load-v1.mjs)
clones that failed run's immutable host/cache, uses the same API, and forwards
public API calls while preserving their original exception stacks. It performs
ordinary owned parse mode only. This isolates source discovery/completion from
checker/backend execution without changing production code or the failed run.

Root ran this diagnostic in 2.02 seconds. The retained
`selfhost/build/phase66/raw-load-trace01/report.json` captures the exception in
`f_prefix_complete_ready_seed`, with alternating `$String$cmp$` and
`$String$cmp$fin$` frames. Thus this failure is recursive comparison while
admitting the exact Base prefix in the raw compiler image; it occurs before
the new emitted host converter runs. It supports applying the separately
reviewed compiler-image string-equality transformation, not changing the
marshalling implementation.

The [v2 gate](../../selfhost/tools/performance/phase66/host-runtime/controls-v2.mjs)
retains all 16 assertions and exact converter/runtime source hashes. It takes
the original checked attempt, fresh output, and a profile7 derivation receipt.
It joins the derivation to that exact checked API/bootstrap, requires the
reviewed frozen verifier `fcc80fd4…7eb5`, and replays the transformation before
import and after execution. The historical tail rewrite must be absent. This
gate was prepared without executing a compiler target; the raw failure remains
preserved independently.
