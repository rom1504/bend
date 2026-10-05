# Phase52 direct-backend parity contract and decision gates

This is a source audit and validation proposal for the explicit `direct` backend,
not a record of passed executions. The installed Phase51 `js` backend remains
the compatibility reference. The independent language/backend reference is Bend's
compiler implemented in TypeScript at
`018751270e800bc222a93dad7f257083ee53a5f7`, not Microsoft's TypeScript compiler.
See the [Phase52 design](../../design/phase52/direct-javascript.md).

## What changes, and what does not

The new backend may choose upstream's representations and export interface
without reproducing the legacy runtime's additional mutable-descriptor protocol.
This is an explicit target-contract choice, not permission to remove guards from
existing `js` output. It must still implement checked Bend programs and the
selected upstream library/effect boundary faithfully.

The distinction is visible in source:

- [Legacy library emission](../../selfhost/src/back/js/emit.bend) exports
  `G`, `call`, `list`, and `ctor`. Its default wrappers reread `G` on invocation.
  [Legacy core](../../selfhost/src/runtime/js/core.mjs) represents functions as
  `{arity,code,env,bound}` and probes `bounce/build/io/typeName` during generic
  application and forcing. Its `scalarGuard` comment explicitly identifies the
  inherited hooks that generic forcing observes even on primitive values.
- [Pinned upstream `comp.ts`](../../bend2/comp.ts), `js_call` at line 3061,
  emits lexical positional calls for known functions. `js_expr` at line 3138
  emits native literals or tagged objects with named fields; its closure case
  emits JavaScript functions. `js_lib` at line 3374 exports `run_lib` wrappers
  around lexical functions and does not export a mutable `G` table.
- The [legacy contract](../../docs/PHASE42_GENERATED_JS.md#runtime-boundaries-and-maintenance)
  deliberately preserves supported post-import binding, code, metadata and
  getter mutations, under standard initialization intrinsics. Those obligations
  remain with `js`; they are not universal language laws applying to every
  possible backend representation.

Consequently, direct code need not scan the legacy descriptor/prototype graph
before every ordinary call. It must not introduce a claim that arbitrary host
effects are irrelevant: operations upstream actually performs, including
property reads, native conversions, mutation and foreign callbacks, still have
their own observable order. Removing legacy-only machinery and reproducing
upstream behavior are different from assuming an eternally unchanged host.

## Feature and observation matrix

“Required” below is a validation obligation, not a statement that it is already
implemented. A prototype may explicitly refuse a feature or an entire reachable
module; it must not silently substitute `null`, empty code or a different ABI.

| Area | Direct target | Legacy distinction / minimal observation |
| --- | --- | --- |
| Frontend | Reuse checked, annotated KTerms and the pinned Base/source identities. | No TypeScript compiler calls to make direct emission decisions; bootstrap/reference use is separate. |
| Erasure and lets | Follow live quantities and the pinned emitter's live binding policy, preserving evaluation of remaining operands. | Erased arguments must not accidentally execute; parallel RHS scope and shadowing must remain correct. |
| Known application | Lexical positional calls with proved live arity. | Replacing a legacy `G` entry affects legacy callers; replacing a direct module's exported property need not rewrite its lexical callees. |
| Unknown application | Native closures, with the upstream calling and trampoline conventions. | Do not infer a multi-argument closure from a declared telescope alone; matcher/closure stages can expose fewer arguments. |
| Public application | Match `js_host` plus `run_lib`, including partial entry. | `run_lib` accumulates arguments until its declared arity; excess arguments follow the actual host wrapper, not legacy descriptor overapplication. |
| Constructors/matching | Named fields and canonical native layouts; evaluate live fields and selected arms as upstream does. | Legacy `.a` vectors and `build/force` hook traces are not the direct value ABI. Test source demand/order, not only final checksums. |
| U32/F32 | Match exact primitive lowering, wrapping, per-operation F32 rounding, signed zero and exceptional values. | No approximate numeric oracle. Literal lowering must be judged against the direct runtime, not automatically its legacy shared DataView protocol. |
| Nat | Match upstream's distinct internal, library-marshalling and effect seams. | Do not transplant the legacy private BigInt48 entry guard onto every boundary; see below. |
| Arrays/records | Native storage and upstream marshalling, aliasing, update and callback order. | Full returned state and subsequent writes matter; copying a returned array to hide layout differences can change semantics and timing. |
| Recursion | Same-function and mutual tail loops, fresh turn bindings, selective closure forcing. | Direct non-tail native recursion may have a different stack limit from legacy continuation workers; disclose and test the selected policy. |
| Errors | Match the pinned target's demanded failure and observation order. | Legacy `Error` objects and upstream thrown strings are not interchangeable in exact host tests. |
| IO/FFI | Preserve effect registration, arguments, continuation/resumption and boundary values. | An initial pure-only prototype may refuse IO; it must not count IO cases as covered. |
| Introspection | Upstream callable-export contract and whatever it actually exposes. | Raw `G.code/env/bound`, legacy exact-entry tokens and positional readback factories are unsupported in the direct contract unless explicitly adapted. |

### Nat has more than one boundary

In pinned `comp.ts`, `nat_chk` at line 505 checks the immediate arithmetic cap
`2^48-1`. Library `nat_host` at line 512 accepts a nonnegative integer BigInt or
Number through `2^53`, converts it to Number, and otherwise returns an object
whose primitive conversion throws. `js_marshal` converts exported Nat results
to BigInt; it recursively handles function types, arrays and named ADTs.
`js_host` orders live-input marshalling, computation/forcing, result marshalling,
then input back-conversion. An exception skips the later stages. Array Nat
conversion mutates elements in place; aliased input arrays are therefore a
boundary-order test, not permission to replace marshalling with a pure copy.

The effect seam has separate evidence. The unchanged pinned test
[marshal_nat_bigint.bend](../../tests/io/marshal_nat_bigint.bend) deliberately
expects an inbound `-3n` to select `Succ` without demanding its predecessor.
Its commentary calls this value raw; the actual `nat_host` implementation above
is the representation authority. An invalid input's throwing conversion object
can reach a nonzero match arm before a numeric operation demands conversion. The
[nat_host_bounds.bend](../../tests/io/nat_host_bounds.bend) and
[foreign implementation](../../tests/io/nat_host_bounds.js) cover `2^48-1`,
`2^48`, and `2^53` through unchecked word/division/remainder operations. Rejecting
these values everywhere as malformed would contradict the reference's tests.

For a bounded prototype, refusing unsupported effects or nested Nat marshalling
is honest. Accepting them while using a universal scalar-entry guard is not.
Test source-created overflow separately from library and foreign host inputs.

## Smallest useful correctness gate

Run controls on actual output from a checked Bend-owned emitter. A saved-output
rewrite or a successful runtime-only test does not establish source lowering.
Keep failures and unsupported reasons in the report, including stages that fail
before execution.

1. **Calls and demand:** one known positional call, a returned capturing closure,
   a matcher-produced closure, partial application in two stages, zero-live-arity
   definitions invoked twice, and a mutual tail cycle. Use an untaken failing
   arm, erased argument and ordered foreign/callback observations where admitted.
2. **Values:** renamed two-constructor data with both branches, reordered named
   fields, nested tuples/records and complete return values. Include a constructor
   field with a demanded error and one with a reused value. Native/non-native
   constructor ownership must come from checked provenance, not its spelling.
3. **Numbers:** U32 wrap/division/shift edges; F32 `-0`, subnormal, infinity/NaN
   behavior and operation rounding; Nat zero, values above U32, cap overflow,
   and public BigInt return. Add library/effect Nat probes when those seams enter
   the admitted scope.
4. **Arrays and callbacks:** zero/one/multiple iterations, aliased array updates,
   read/size returning the same handle, index/value/callback order, complete
   returned arrays and a second call after mutation. Nested Nat arrays need
   additional marshalling/alias checks.
5. **Interface and recursion:** exported name inventory, repeated nullary
   computation, partial entry, exact ordinary invocation and the chosen deep
   tail/non-tail policy. Constructor recursion and closure tail calls need
   independent witnesses; a direct scalar loop alone does not cover either.

These groups are feature gates, not prescribed unique test counts. Reference
observations should come from the same pinned upstream output contract. Existing
legacy controls remain useful to establish that `js` output is unchanged; a test
that requires exported `G` is not a direct-mode conformance failure or a pass.

## Benchmark identity and adapters

Reuse the frozen [45-point catalog](../../selfhost/tools/performance/phase37/catalog.json)
and existing [execution worker](../../selfhost/tools/performance/programs/execute.mjs).
Its full expected scalar is checked on the first call, every warmup call and
every timed call. A String length contributes to the checksum only after the
complete String has been checked. Keep that distinction.

Record three independent roles: installed Phase51 compatibility output,
checked direct output and pinned upstream output. Freeze source/API/runtime/Base,
source-to-module receipts, upstream revision, Node, options and observer hashes.
Direct output must not reuse upstream-generated program bodies while claiming
Bend-owned compilation. A static runtime adapted from pinned source is allowed
with attribution and its own identity.

Two integration traps need explicit treatment:

- [Preparation's `observe_row`](../../selfhost/tools/performance/programs/prepare.py)
  currently picks its representation from `role == 'typescript'`. The direct
  candidate needs the **named/native** observer
  `JSON.stringify([st.a,st.b,st.prev,st.cur])`, not the compatibility observer
  `JSON.stringify(st.a.map(x=>x.array))`. Choose by declared output ABI while
  retaining candidate role, all four arrays and serialization inside timing.
- `execute.mjs` supports finite JSON scalar expectations and plain JSON arguments.
  It cannot by itself qualify public BigInts, higher-order exports, alias identity,
  NaN/signed-zero distinctions in serialized inputs, or structured results.
  Keep separate untimed interface controls; do not turn those values into a
  reduced checksum and then claim full-value conformance.

Source-only backend reuse is separate from the compiler host adapter described
in [COMPILER-ABI.md](../../selfhost/docs/COMPILER-ABI.md). The checked compiler API
can keep its current representation while its new emitter produces direct user
programs. Replacing the compiler's own host ABI or proving a new fixed point is
not a prerequisite for the first useful runtime experiment.

## What the one-hour decision can establish

Freeze a small set before timing, and include more than a scalar arithmetic
loop. Useful existing contrasts are RLE (guard-heavy private execution),
Morning or a separate capturing/matcher factory (generic function transport),
Expression (constructor producer/consumer), and a larger scalar or array loop.
An unsupported member stays visible; add independent renamed fixtures for the
implemented mechanisms, not benchmark-name selectors in production.

The design's provisional **1.5× geometric improvement against compatibility
output**, with multiple cases approaching pinned upstream, is a reasonable
continue-investing threshold on that frozen subset. It is not a promotion or
parity threshold. Require actual direct lowering through the timed work, correct
complete values and a second warmed comparison when small deltas or tiering
affect the decision. The current 60-second preset has three rounds and a short
warmup; its passing screen does not prove stationary speed.

Reject or narrow the prototype if support works only through legacy fallback,
if its actual corpus output remains unchanged, or if gains require weaker
source demand/array/closure semantics. A general direct path that succeeds on
several shapes but refuses IO is valuable evidence for expansion, not a full
compiler replacement.

For scale, [Phase51's full comparison](../phase51/results.md) is 2.927825× TS by
equal point. Hypothetically making only Morning, Evening, RLE and MapSet equal
to their TS times would reduce that to approximately **2.045×**, with the other
41 points unchanged. This calculation uses rounded published per-point ratios;
it is a counterfactual, not a forecast. Even very large wins on those four tiny
programs do not establish whole-corpus parity.

Full admission/qualification should report the retained 45-point denominator,
source and family weightings, every refusal and regression, and fresh paired
ratios rather than pooling historical timings. Separate clean timing from
profiles, import/first-call cost from repeated execution, and generated-program
speed from compiler request latency. Broad conformance and release installation
remain separate decisions after the prototype value gate.
