# What remains after inline15

This is read-only source and machine-code analysis of the frozen inline15
products. No target was executed for this audit and no optimizer policy changed.
The six-program measurements are diagnostic, not a paired timing qualification.

## Scalar loop: calls are gone, information is still missing

`selfhost/build/phase111/p113-inline15-scalar-region-8192-emit/program.ssa`
contains a complete `$direct.mit` with **no remaining ordinary direct calls**.
Its only ordinary hot runtime call is `p111_rt_special_take` for a Nat predecessor.
The other runtime calls are fail-stop branches. Nat extraction is already being
addressed by the separate Nat-match experiment.

The corresponding function in
`selfhost/build/phase111/p113-inline15-scalar-region-8192-build/program.s`
contains 428 assembly lines, including cold paths and labels:

- 36 occurrences of the `4294967295` mask constant.
- Five right shifts by 40 for tagged Bool inspection.
- 29 conditional/unconditional branch instructions.
- 66 stack-frame references through negative `%rbp` offsets.
- A 2,200-byte frame reservation before saving callee-saved registers.

These are static counts, not dynamic instruction counts or attributed runtime
costs. Nevertheless, the specific surviving work is visible on the normal path.
For example, a comparison first creates a full-word `0` or `1` through two
branch assignments. A subsequently inlined Boolean helper then compares that
word with `1`, shifts it right by 40, masks the shifted bits, compares those bits
with boxed-constructor tag `65538`, combines the tests, and retains a failure
branch. A value already known to be `0` or `1` cannot have those high bits.

Repeated U32 masking also survives in the final assembly: an already masked
value is shifted, masked again, copied, and masked again by another helper.
The machine code uses 64-bit arithmetic plus explicit masking where the
upstream compiler supplies 32-bit operations directly.

The pinned upstream C for this exact benchmark is
`selfhost/build/phase93/broad01/scalar-region-8192/upstream.1.c`.
Its `spin_12` uses `u32` locals and direct Nat subtraction. Its Bool helpers
already test raw integer truth. Clang inlines this into `WL_FID_MAIN_K93`; the
inner loop at addresses `0x9020..0x90a5` in the pinned upstream executable is
roughly forty instructions, with no calls, native 32-bit arithmetic and
conditional moves. This comparison identifies retained abstractions, not a
promise that copying those instruction counts reproduces its runtime.

## Array loop: one partial helper and opaque memory operations remain

In
`selfhost/build/phase111/p113-inline15-local-pair-emit/program.ssa`,
`$product.row` has inlined `cell`, `f1`, and `f2`. It still calls
`$product.cell.f3`. Its direct body contains:

- One Nat extraction helper.
- Three `p113_rt_array_pair` calls.
- One call to `$product.cell.f3`.

`$product.cell.f3` already contains the former `f4` and two `umin` helpers. Its
253 QBE lines contain another array-pair call and one generic primitive call
(`p111_rt_op`, operation 73: the array update in this case). Exact structured
node counts and the policy refusal reason should come from `p113j_audit`;
QBE line counts are not IR node counts.

The assembly preserves a separate call frame, stack-passed arguments, and an
output-vector buffer across the residual `f3` boundary. The hot row frame
reserves 2,264 bytes and `f3` reserves 2,152 bytes. The unconditional emitter
scratch reservation remains 2,048 bytes; the inliner's new scratch buffers are
already reduced to 16 or 24 bytes at these sites.

The upstream inner dynamic-programming loop is inside `spin_26` in
`selfhost/build/phase93/pilot02/local-pair/upstream.program`,
addresses `0xa660..0xa6ba`. It directly loads four-byte array elements,
calculates minima with conditional moves, stores the result, and repeats
without helper calls. Array bases and masks are computed outside that inner
loop. The separate array-fast work is intended to expose these operations;
this audit does not duplicate its implementation or claim its eventual result.

## Ranked bounded experiments

1. **Late scalar range and constant propagation after inlining.** Track exact
   constants and conservative unsigned bit-width bounds for mutable N111 locals.
   Comparisons yield a 0/1 range; copies preserve it; branch joins take a safe
   union; masks and constant shifts tighten it. Unknown loads/call results
   remain unknown. Fold shifts beyond a proven width, comparisons outside the
   range, and masks that preserve every possible bit. This removes impossible
   boxed-Bool tests without recognizing a benchmark or relying on source names.
   The existing emitter can then eliminate constant branches and dead code.
   Start each function/loop entry with unknown formals, and reset facts on every
   assignment; do not assume a fixed point across `Again`.

   A smallest useful witness is a comparison producing `0/1`, copied through
   an inlined helper and then inspected by a generic Bool match. The transformed
   output must agree on both outcomes and no longer contain the impossible
   high-bit test. Boundary controls include joins of `0/1` with an unknown word,
   overwritten locals, U32 maximum values, shifts at 0/31/32/63, and unknown
   calls. Candidate verification remains mandatory. Estimated engineering:
   roughly 45–90 minutes for a deliberately small pass and focused controls.
   A 1.5–3× scalar gain is a hypothesis suggested by the retained work, not a
   measurement or a whole-suite estimate.

2. **One isolated wider inlining policy.** First collect actual admission
   diagnostics. Then try `policy-wide.bend` (384-node candidates and 1,024-node
   growth, unchanged other limits). Its purpose is to determine whether removing
   the residual `f3` boundary helps before inventing a new interface. Preserve
   both measurements and compare emitted code size and surviving calls.
   This is a low implementation-cost experiment, but the timing gain is unknown.

3. **Native-width scalar operations.** Once late range facts are available,
   add explicit, verified truncate/zero-extend operations or a similarly precise
   typed scalar region interface. This can replace full-word U32 arithmetic and
   masking with native 32-bit operations. Do not silently reinterpret U64 Terms
   as U32 values or bypass the scalar verifier. This is a larger change than the
   range cleanup and should follow evidence from that cheaper experiment.

4. **Loop-invariant array base/header facts.** Reinspect machine code after the
   separately owned array-fast templates and Nat extraction land. Only then
   consider hoisting repeated state, array-base, and mask loads. Such motion
   needs an explicit invariant and alias/effect premise; a helper merely being
   named `array_get` is not enough.

The current architecture has exposed a useful optimization boundary: after
inlining, previously separate helper facts become local structured dataflow.
The next high-value step is to exploit that information, rather than adding
more hand-written source-specific rewrites.
