# P68-004: consume native value prefixes without a continuation

Date: 2026-10-08. Pre-execution status: source proposal, unmeasured,
investigate. Owner: value-prefix agent; root owns production and targets.
[Design](../../design/phase68/value-prefix.md).

## Hypothesis

Native constructor and Array results already have a structured
`N_Emitted{code,word,fresh}` representation before being wrapped in a scheduler
return. Consuming that representation directly at a let binding can remove
continuation/frame traffic, while keeping boxed values and the existing
allocation/ownership implementation. This should help transport-heavy programs
and expose one common producer interface for future ordinary C workers.

Candidate: `selfhost/tools/performance/phase68/value-prefix/prefix-v1.patch`;
exact before/after source identities and line counts live in adjacent
`candidate-v1.json`. The unexecuted candidate is +64 Bend lines across bridge,
array and direct modules. Current matcher-arity changes are included in its
frozen source baseline; this experiment's comparison must use that prior
compiler rather than attribute the arity improvement to value prefixes.

## Admission invariant and controls

Only known constructors and exact Base, saturated, non-bang Array/Nat.divmod
calls enter the new path. Arguments remain explicitly staged left to right.
Bound normalized operands feed the same code/word producer as return position.
The let consumer retains sharing, body drops and the nonsequential error
checkpoint. A lexical C block contains producer scratch variables; its one word
result is bound outside it. Fresh counters advance before body lowering.

Root should first execute a checked B1 build, existing flat-fast and ownership
controls, Nat.divmod zero/overflow boundaries, plus `prefix-scratch.bend`
(hand golden 7071122). The latter combines two initializers, two swaps and
repeated reads to expose duplicate C scratch names. Compare outputs and exit
status with the frozen reference, and inspect residual ownership/allocation
balance. There is no proof of runtime/ownership semantics from Phase67's pure
continuation model, and CPU error mocks do not establish device conformance.

## Measurement and decision

Use the existing serial native short loop with unchanged generated-program
inputs, Clang options, repetition protocol and CPU. Pair candidate against
matcher-arity B1, retaining numeric as a low-opportunity control and array plus
tree/closures/lexer as discriminators. Keep C emission, Clang compilation and
program execution clocks separate; operation-count instrumentation has no clean
time claim. Candidate removes transport, not the boxed aggregate allocations.

A 10–35% runtime reduction on transport-heavy cases is a provisional hypothesis;
after one checked build and focused comparison, broaden only a surviving
change. Reject on ownership/error/evaluation-order mismatch, unresolved C
scoping, or a broad meaningful slowdown. Preserve unsuccessful attempts. No
production promotion or speedup is claimed by this registration.
