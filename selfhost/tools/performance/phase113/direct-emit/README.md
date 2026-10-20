# Complete direct-function QBE emission

The direct emitter consumes `P113DProgram`, retaining the original verified
`P112StaticProgram` and a callee-before-caller list of complete functions.
All semantic lowering stays in Bend under `direct/`; this module does not parse
C, QBE, or generated native code. The original N111 scalar operations and QBE
renderer remain shared with the generic backend.

## Interfaces and machine ABI

Append `verify.bend`, `emit.bend`, and `program.bend` after the direct model and
lowering/planning modules. Public entry points are:

- `p113d_verify(program) -> String`: empty on successful structural verification.
- `p113d_chunks(program) -> List<String>`: verifies before emitting.
- `p113d_text(program) -> String`: joined output of the same checked route.

Every private function receives borrowed `state` followed by full-U64 Term
arguments. Physical widths do not imply that a Term is non-owning. A single
result returns one owning Term directly. Two through eight results receive an
additional borrowed output pointer after `state`, write exactly that many U64
slots, and return status zero. Calls load all results before another call can
reuse the caller's fixed eight-slot result buffer. No C aggregate ABI is used.

`Again` is a terminal local loop edge. The emitter snapshots every argument
before rebinding any formal, preserving permutations and overlapping moves.
Ordinary calls target previously admitted functions only; no native recursive
cycle is silently introduced. `Result` and every loop edge require the exact
declared vector width. QBE creates SSA from the emitted mutable temporaries.

## Verification boundary

Every scalar statement is checked through the unchanged `p111v_schema` and
`p111v_stmt` machinery, including operand widths, definite assignment, runtime
signatures, buffer bounds, alignment and operator legality. Nested scalar
branches retain its branch-intersection rule. P113 branches compose the same
flow rules; direct calls validate all inputs before defining their destinations.
Duplicate result destinations, unknown/forward/self-native calls, bad signatures,
undefined values, terminal suffixes and missing return paths are refused.

Private functions cannot use scheduler/frame/dispatcher helpers, raw segment
returns, state-buffer accesses, pointer assignment or pointer arithmetic.
Runtime calls retain the fixed CPU ABI and required checked buffer contracts.
The existing CPU fail-stop profile admits `p111_rt_fail`; this does not qualify
the returning device-error behavior. Stack buffers are explicit and bounded.

This is a structural/type boundary, not an ownership proof of arbitrary raw
P113 graphs. Semantic/ownership provenance comes from the checked source and
the direct lowerer's retained keep/drop/transfer rules. The runtime, source
admission and native behavior remain separate qualification gates.

## Public and fallback integration

`public=True` is an explicit claim that the direct function preserves the old
single-Term public ABI. The verifier requires an existing zero-incoming,
zero-flags public segment with matching argument count and one result. Its
public wrapper reads the arguments from the register bank, calls the complete
function, then uses the unchanged `p111_rt_return` to resume pending frames.

The facts renderer already emits private workers called by generic/fused
functions. Replacing only public segments would leave those callers on the old
implementation. Matching scalar-compatible private `p112w_` definitions therefore
retain their exact signatures and forward to the new `p113d_` implementation.
Unmatched private definitions and their dependency registry remain intact.

Product variants use `public=False`. They may have separate private identities
and flat signatures; their original boxed public implementation remains the
fallback. Direct callers can select them only through the product planner's
layout proofs. Equal argument counts alone are not a boxing-layout certificate.
With an empty direct-function list the emitter delegates to `p112s_chunks`
exactly. Existing tables, static images, symbols and runtime data stay shared.

## Optional array-result import

`products.bend` is a separate explicit override profile, composed after
`products/{model,layout,array}.bend`. It adds only `p113_rt_array_pair` using the
ABI module's exact operation catalogue and structural signature predicate.
The verifier additionally checks all six argument types, input capacity, the
16-byte output capacity, and exclusion of the state pointer as a buffer.
It requires the separately admitted product runtime extension. The base scalar
profile still works with the unchanged runtime04 object.

This first product adapter accepts the import as a P113 scalar statement.
Embedding it inside a raw nested `N111If` is conservatively refused by the
original N111 import checker; use structured `P113DIf` for that control flow.

## Qualification

Source readiness is not an execution claim. Root owns serial guarded checks:
checked API acquisition, independent IR mutations, exact output/status controls,
native loop/call/result-vector witnesses, then measured applications. Keep generic
fallback qualification, compiler-request time, generated-program runtime and
source growth separate. The scalar direct lowerer must preserve or conservatively
refuse previously recovered fixed-width Word patterns before broad promotion.
