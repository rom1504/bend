# Phase112 accessor and special-test exposure

These additive candidates expose exact pure runtime operations to QBE. They
change no runtime function, physical state layout, ownership operation, or
public structural-verifier permission. Performance benefit remains unmeasured.

Compose `original.bend`, `emit.bend`, and exactly one of `entry-tag.bend`,
`entry-registers.bend`, or `entry-both.bend`. Only `p111q_stmt` is replaced.
Modes 1/2/3 select tag/register/both expansion. Original owning IR stays intact
until final rendering, so the worker planner still sees its authenticated
register-get prelude. `original.bend` is the exact Phase111 statement renderer
with only its declaration name changed. Unsupported call shapes use it.

`special-tests.bend` is independent: compose it to override `p111_test` with
direct tests for seven special constructors. Its fallback is the exact old
`p111_test` body. It composes with either accessor mode and the worker modes.

## ABI and refusal boundary

The accepted capsule is Phase111 ABI11101, exact `runtime-source04/runtime.c`
and its sibling `runtime.h`. `abi.json` pins both, the full Phase111 source,
and the unchanged structural verifier. `admit.py` checks the actual composed
compiler and runtime source, not just an asserted capability Boolean:

```sh
python3 -B selfhost/tools/performance/phase112/accessors/admit.py \
  --source FRESH_SOURCE/compiler.bend --mode both --special-tests \
  --runtime selfhost/build/phase111/runtime-source04/runtime.c \
  --out selfhost/build/phase112/FRESH_ADMISSION
```

Use `--mode none` for special-tests alone; omit `--special-tests` when absent.
The admission checks every original verifier function, the checked emission
boundary, selected overrides, and exact fallback definitions. Six reflected
source mutations must refuse. This is source authentication, not a runtime
object build receipt. Root must also bind the linked object to that runtime
source and retain the existing malformed-public-boundary execution controls.

`runtime/core.inc.c:67` defines `p111_rt_tag` as `term_aux(term)` with no state
access or checks. Exact `term_aux` is `(word >> 40) & 0xffff`. Its replacement
uses two U64 binary instructions and the original destination name. It remains
exact for all 64-bit words, including RFC and non-constructor words.

`runtime/runtime.h:59` statically asserts `regs` at byte offset40; line60
asserts state size2088. Each register is an eight-byte U64. Only exact
`p111_rt_reg_get(state, literalU32Index) -> U64` calls with index0–254 expand.
The original whole-program verifier runs first: `p111v_contract` requires the
index to be less than direct arity or continuation incoming width. Runtime
binding checks arity against register width and incoming width against result
width. Logical transport is their maximum (at least2), so every admitted index
also passes the unchanged runtime helper's dynamic bound. Largest exposed
offset is2072, fully inside the asserted physical state.

This proof is for the checked public pipeline and its fixed runtime capsule.
Calling an internal renderer on arbitrary unverified IR never had a safety
contract. An isolated expanded load is not a replacement for verification of
the original helper call. `p111_emit_lowered` and every verifier function remain
exact. Dynamic indices, wrong signatures, foreign state locals, and physical
index255 keep the old helper; public invalid programs still fail before rendering.
No stack pointer, heap pointer, allocator state, or arbitrary pointer arithmetic
is exposed.

## Special constructor tests

`runtime/primitives.inc.c:408` is the exact source boundary. For every U64 word:

* `True` is raw1 or a packed constructor with aux equal to the resolved `True`
  constructor ID. `False` is its Boolean complement.
* `Zero` and `Succ` compare the complete U64 word to zero.
* `Chr`, `U32`, and `F32` always match. Integer self-equality preserves operand
  definition/type checking and permits QBE to fold the result to true.
* Arrays and ordinary constructors use the unchanged fallback.

The packed-True test combines contiguous aux/tag bits:
`((word >> 40) & 0x7fffff) == (0x10000 | CtorId("True"))`.
It ignores RFC bit63 and every location bit, just like `p111_native_bool`.
The constructor ID is resolved from this program; no numeric CID is hardcoded.
Both inputs to the final Boolean OR are U32 predicates, and the resulting
`match_condition` is U32. Reserved input aliases use the original fallback.

## Qualification inputs and status

`controls.bend` exports `p112a_control_report`:14 structural controls, including
public malformed-program refusal before rendering. `raw-cases.json` fixes nine
tag words, four register observations and seven refusal classes.
`tag-boundaries.bend` has four independent full outputs for zero/one/two-field
constructors and a physically retained alias.

`special-controls.mjs API.mjs FRESH_OUT` constructs84 raw special-test cases
through the checked Bend API and writes baseline/candidate QBE plus the complete
expected bit string. Expected observations distinguish raw/packed True, RFC,
nonzero locations, wrong tags, and high-half words. Both graphs must verify;
the baseline retains84 real helper calls and the candidate retains zero.
Machine execution remains a separate root-run gate. Required API exports are
`p112_special_test`, `p112_special_test_fallback`, `p111_verify_program`, and
`p111q_chunks`. Optional accessor controls add `p112a_control_report` and
`p112a_expand`.

Source-only delimiter/Python checks and in-memory admission of all four modes
with special tests passed; all six admission mutations refused. No compiler or
machine target was run by this source owner. Existing scalar files and worker
files were not modified.
