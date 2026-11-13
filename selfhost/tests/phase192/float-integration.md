# Unary float conversion integration

Apply `float-integration.patch` from repository root. The new maintained module
is `selfhost/src/back/x86/float-conversions.bend`. The patch uses the existing
`X186InlineF32` and `X186FloatValues` constructors for ids 23/58; unary values
occupy both metadata operands. Duplicating the read is conservative placement
metadata only. Unary fallback reads offset zero only, so verified eight-byte
buffers remain sufficient. The existing private-buffer/XMM passes are reused.
No arithmetic operation or rounding point is reordered. The only clobbers are
reserved r10/r11, xmm0/xmm1 and flags, matching every shared effect consumer.

The actual retained Phase191 numeric ELF at
`extra-dev-build01/coverage-numeric-recurrence-256/machine/program` contains
COMISS (not UCOMISS) at 0x4158bd, COMISS at 0x4158d2 and signed64 CVTT at
0x4158db. COMISS is intentional: changing it to UCOMISS loses invalid flags for
quiet NaNs. The replacement preserves the first COMISS, sanitizes disallowed
encodings to zero, and then converts. Its integer upper-bound test is exact for
positive F32, including the last valid float below 2^32. The second runtime
COMISS cannot raise a new exception once the first comparison has admitted a
finite nonnegative operand; flags are sticky. Negative zero is sanitized to
positive zero with the same integer result and no new exceptions. Denormal
operands retain the initial comparison and conversion behavior under DAZ/FTZ.
The existing unmasked COMISS exception is retained; no invalid conversion is
executed speculatively. This preserves value and masked-MXCSR behavior; no
independent trap-handler gate has yet been executed.

## Focused checked fixture

Add `float-conversion-controls.bend` to the checked fixture source. Export
`p192fc_controls` and `p192fc_emit`. The generic Phase191 typed-control driver
can accept this group:

```
float: {
  controls: 'p192fc_controls', emit: 'p192fc_emit', outputs: 1,
  fixture: 'selfhost/tests/phase192/float-conversion-controls.bend',
  observer: 'selfhost/tests/phase192/float-conversion-controls.c',
  independentAssembly: 'selfhost/tests/phase192/float-conversion-controls.s',
  expected: 'phase192 float conversions: checks=529280 failures=0\n',
  labels: ['cvtt-high-registers', 'comiss', 'cvtt-reject-word',
    'cvtt-reject-gpr-source', 'cvtt-reject-memory-destination', 'cvtt-reject-arity']
}
```

The C observer uses an integer IEEE-754 decomposition oracle for F32->U32,
separate ordinary C floating conversion/exception oracles, 39 edge values,
4096 deterministic xorshift raw values, four MXCSR rounding modes and four
DAZ/FTZ combinations. Each of the two conversions runs through core, XMM home,
full-width poisoned stack home and destructive buffer-pointer destination
routes. Input upper words vary; source cells must remain intact. The independent
assembly route uses guarded floating comparisons rather than candidate masking.
Object and rendered-assembly products must both pass. Staging integration has
separate fixtures owned by the staging task.

## Validation status

Only source inspection and `git apply --check` were performed in this agent
lane. No compiler, assembler, target or timing job was run. Root must acquire
the checked API and execute all three fixture routes on the guarded CPU3 lane.
The patch changes only the x86 module list, not unrelated backend profiles.

## Actual runtime exception anchor

The observer now includes the maintained ABI header and calls the pinned
`p111_rt_op` for both ids23/58 before checking each generated route. A real
zero-initialized `P111State` is required: the dispatcher reads `state->e` before
the switch, so passing NULL is invalid even for these heap-free operations.
The header contains declarations/types/static assertions, no external definitions.
The independent integer value oracle and C value/exception oracle remain; any
C/runtime mismatch fails explicitly, rather than silently choosing one.

Link the float group's observer/routes with the same pinned runtime used by
Phase191 and preserve the ordinary `-no-pie ... -pthread -lm` link policy:
`selfhost/dist/qbe/runtime.o`, 125264 bytes, SHA256
`67141c4505a0355901d857c4ba81dfc17559329e536818a843ce68615384d13e`.
Place that object before the library flags. No new runtime compilation is needed.
Pin `selfhost/src/runtime/qbe/runtime.h` as an observer dependency too.

For the C observer compile, add `-frounding-math -fsignaling-nans` to its existing
`-std=c11 -O2 -fno-pie` flags. GCC's trapping-math is enabled by default; do not
use fast-math. Volatile input reads prevent interprocedural constant/pure-call
reuse of the two local C reference routines across MXCSR settings. These flags
and the explicit runtime comparison establish this finite pinned-toolchain
observation; they do not turn C floating-environment handling into a portable
language guarantee. The expected successful observation count stays 529280.
