# Phase118 next bounded experiment: expose native integer division

## Observation, not a new architectural hypothesis

The current structured scalar fast path excludes `U32.div` and `U32.mod`:
selected `phase117/version-source03/compiler.bend:41175` admits primitive IDs1–17,
20 and21, while IDs18/19 fall through `p112_intrinsic_fallback:41154` to scratch
stores plus `p111_rt_op`. The generated runtime's `runtime-cold01/runtime.c:615`
unconditionally uses a quotient formula documented as a Metal workaround.
The repository upstream implementation already uses ordinary native division
outside Metal (`bend2/comp.ts:348` and351). This is a concrete lost lowering
opportunity, not evidence that all arithmetic needs a new representation.

Root's existing `combined-profile01`8ms captures are usable main-thread profiles
with562/567/621/570 samples for list/map/lexer/tree respectively. Physical
`p111_rt_op` leaves account for71/32/32/19 samples:12.6%,5.6%,5.2%,3.3%.
For list60 of those71 samples are in the modulo block; lexer has23 of32 there.
Disassembly of the exact list binary locates `p111_rt_op+2516` after its integer
divide, followed by multiply/add/subtract/correction instructions. These are
instruction leaves, not inclusive call costs or operation counters. The13ms
captures have fewer than500 samples and should not support precise percentages.
These profiles precede the bank optimization; do not relabel their percentages
as the latest complete candidate's profile.

The source-to-machine trace is unusually decisive:

* `combined-emit01/coverage-list-pipeline-128.ssa:708`, private TRMC `p37.list`,
  stores constant16 as divisor and calls op19. The runtime therefore performs a
  generic division and correction for what should ultimately be a bitmask.
* `combined-emit01/lexer.ssa:1315`,2255 and2388 use modulo26,10 and6 in
  `ident`, `num` and `expand`; line2856 repeats modulo6 in inlined `gen.at`.
* The same selected source already lowers ordinary U32 arithmetic directly;
  extending constant information through these two primitives is general and
  does not depend on workload/function names.

All paths above are beneath `selfhost/build/phase118`, except the explicitly
named selected compiler and upstream source. Existing profile reports pin their
binary/source identities. No target was executed for this audit.

## Two independent, cheap ablations

1. **Runtime-only native quotient.** `runtime-u32.py` pins `runtime-bank01` and
   changes exactly the `U32_QUO` macro to the upstream Metal/native distinction.
   It writes a new runtime/object/receipt when root executes it. Existing emitted
   QBE can be relinked without frontend preparation. All count checks and the
   existing zero-divisor branches remain byte-for-byte unchanged. This isolates
   correction instructions, not dispatch or scratch traffic.
2. **Direct guarded U32 division/remainder.** `u32-divmod.bend` overrides only
   `p114t_stmt`. After original structured verification it recognizes exact
   `p111_rt_op(state,18|19,authenticatedScratch,2)` calls. A small QBE template
   loads both words, narrows to32 bits, branches on the low32 divisor, performs
   `udiv`/`urem`, and explicitly zero-extends the result. The zero branch returns0
   for division or the original full dividend for modulo. Original operator
   verification is unchanged: no arbitrary new division node is admitted into
   generic reflected IR. Existing reserved `p114t_` names and fresh label supply
   protect the generated template; all other emission delegates unchanged.

The first removes part of runtime work; the second additionally removes the
generic primitive call, its dispatch/prologue/arity work and its barrier to
constant reasoning. QBE may then eliminate or reduce a constant divisor; inspect
actual machine instructions rather than assuming its strength reduction. The
prototype deliberately does not introduce reciprocal-division arithmetic or a
new range-analysis pass. If QBE retains division by16, a separately proved
power-of-two rule is the next bounded addition.

## Exact semantics and verification boundary

For unsigned32 operands with nonzero divisor, the old quotient formula is
mathematically exact: let `q=floor(floor(a/2)/b)`. Then `a-2*q*b` is in `[0,2*b)`,
and the comparison adds the one possible missing quotient bit. Intermediate
`2*q*b` does not exceed `a`, so replacing it with native quotient preserves the
result. The modulo expression reduces to the ordinary unsigned32 remainder.

Do not remove the divisor test. Its tested value is the **low32** divisor;
division by zero returns0, and modulo by zero returns the original full input
word, exactly as the existing runtime specifies. The direct template preserves
this even if a reflected full-width input carries upper bits. Both scratch words
are read before assigning the result; no ownership operation is involved.
Existing verifier checks the literal operation/count, assigned pointer and
two-word capacity before emission. The template is a narrow trusted derived
lowering, not a new formal proof of arbitrary IR.

Qualification should use ordinary checked numeric programs covering divisor0,
1,2,powers of two, nonpowers, maximum U32 values, upper-bit narrowing and live
input/result aliases, then the unchanged focused outputs. These are defined
numeric inputs, not malformed runtime probes. Inspect the generated count of
generic op18/19 calls and actual native divisions, then compare clean times on
the same source/runtime policy. Preserve the runtime-only and direct ablations
separately to attribute gains.

## Priority and limits

This is the strongest cheap next experiment: actual hot instructions implement a
known primitive with a visible constant operand, and upstream already shows the
native semantic equivalent. The observed10.7%list and3.7%lexer modulo leaves
bound the directly sampled work; caller spills/call overhead may add benefit,
but these percentages do not imply whole-program parity. Tree/map have smaller
observed op shares and need their own residual evidence.

Defer broader Nat inlining, arbitrary unboxing and destination-layout redesign.
Nat overflow/error posting, boxed comparison constructors, and shared Boolean
representations require separate laws. The existing array/product lowering
already preserves several useful scalar fields. If integer primitives cease to
matter, the list profile instead points back to take/extend/link costs; a narrow
constant-arity allocation-only extend is cheaper to test than adding another
ownership protocol after the initial cell-reuse regression. Do not spend another
full self-hosting campaign merely to validate this local hypothesis.

## Source-only qualification artifacts and allocation-only follow-up

`u32-divmod-controls.bend` reads a runtime argument list with default seed1 and
prints22 full literal quotient/remainder observations. Dividends and computed
divisors therefore depend on runtime input. The oracle includes zero, odd maximum
U32, signed/unsigned boundary values, divisor1/2/3/7/10/16/max, and shared source
inputs. A separate host integer-arithmetic check confirmed every literal row;
neither that check nor the source delimiter scan is a compiler qualification.

Root also requested the narrow allocation-only follow-up. `extend-sized.bend`
overrides only `p118q_sized`, retaining old constructor/take specialization and
recognizing verified prefix counts1..7. New four-argument `p118_rt_extendN`
helpers encode the removed count in their symbol. Count0 is deliberately not
specialized because the original destination contract starts at one prefix.
`runtime-extend-sized.c` is an additive macro family; a source comparison confirms
its body is identical to the exact `runtime-u32-01` generic extend body after
substituting the constant count. Every arity/pointer check, allocation, prefix
sealing decision, hole initialization, and parent-link operation is preserved.

`runtime-extend-sized.py --out <new-phase118-directory> --extra
selfhost/tools/performance/phase118/runtime-extend-sized.c` pins and extends
`runtime-u32-01`; root owns executing it. `extend-sized-controls.bend` has five
finite shape/boundary controls. Existing full construction/shared/mixed-arity
fixtures remain the semantic gate; this ablation introduces no new destination
or reuse protocol. No gain is claimed until an identical-policy comparison passes.
