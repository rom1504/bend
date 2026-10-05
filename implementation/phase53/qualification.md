# Phase53 semantic and interface qualification

The source oracle and the pinned TypeScript result are separate obligations.
The original NaN fixture expects 40. Corrected checked Bend output returns 40;
pinned TypeScript returns 1. Accepting the latter would preserve a compiler bug.
No source expectation was weakened to obtain agreement.

## Two semantic findings

The NaN fix removes an intermediate ordinary JavaScript array in `f32_bits`.
Fresh typed-array storage preserves the tested payloads without sharing mutable
conversion state. Corrected01 passes all 96 existing source scenarios, while the
reference passes 95. Original and independently renamed source cases also pass
cold and repeated calls. See [diagnosis](nan-payload.md).

The expanded host-callback controls found a second issue in the old direct
emitter. For nested intrinsic expressions, upstream first emits every child's
statement prefix and then holds pending operands at the enclosing intrinsic.
The old direct emitter's nested function calls produce a different order. This
matters when native-callable libraries receive observable JavaScript callbacks.

The first test expectation assumed universal left-to-right evaluation. Its
failure is preserved, as is the uncompiled first lowering prototype. The
versioned correction follows the already published upstream-callable contract,
the pinned emitter and its actual generated module. Only the affected event
expectations change; result values, thrown errors and the NaN golden remain.

Ordered02 composes a statement prefix and a pending value through named calls,
unknown calls, constructors and expression lets. Supplied work in partial calls
stays deferred until full application. Captured let aliases use distinct names
from temporary arithmetic values. This preserves the audited upstream ordering
without one function wrapper per primitive operation.

## Completed focused controls

| Gate | Ordered02 candidate | Pinned TypeScript |
| --- | ---: | ---: |
| Original 29 checked fixtures / 96 source scenarios | 96/96 | 95/96 |
| Composition: getter/throw, constructors, lets, captures, partial calls | 18/18 | 18/18 |
| Numeric: bits, finite/signed-zero/subnormal arithmetic, callback ordering, cold/repeated NaN | 34/34 | 28/34 |

The six numeric reference failures are the original and renamed NaN table in
three fresh processes each. Every process completes healthily; each reference
sequence is `[1,0,0]`, while the candidate sequence is `[40,40,40]`. They are
reported as source failures, not passes or crashes. All finite numeric and
callback-order controls pass in both roles. Counts overlap existing fixtures and
must not be summed into a unique language-test count.

The final strict controllers independently check process success, return/throw
outcome, returned value or error, and ordered events. A shared assertion error
cannot pass merely because both sides recorded similar observations. Earlier
controller versions and their failures remain in the campaign evidence.

Reports currently reside under `selfhost/build/phase53/`:
`semantic-ordered02-controls01/report.json`,
`semantic-composition-ordered02-controls/report.json` and
`semantic-runtime-ordered02/report.json`. All consumed source, compiler,
runtime, driver and module identities are checked again at completion.

The complete selected source suite passes, with 95/96 exact differential
agreement; only the reference's unchanged NaN failure differs. The maintained
census/compatibility gates and installed/relocated default-interface qualification
are separate integration steps. No universal language/host equivalence, new
self-emitted fixed point or native/GPU qualification follows from these controls.
