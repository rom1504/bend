# Phase112 scalar hypothesis

Replace the generic runtime dispatch for a finite, audited set of U32
intrinsics with existing typed machine operations. The hypothesis is that
removing argument-buffer stores and opaque helper calls reduces scalar-loop
cost. No performance or compiled correctness result is claimed by these files.

`../scalars.bend` exports `p112_intrinsic(name, values) -> P111ValueCode`.
The root source composer replaces the exact `p111_intrinsic` declaration with
a delegation to this function. `p112_intrinsic_fallback` is the original
Phase111 function body with only its declaration name changed. Historical
Phase111 sources stay unchanged.

The initial 19 operations are `u32_add/sub/and/or/xor/mul`,
`u32_is_eq/ne/lt/le/gt/ge`, `u32_inc/shl/shr/shln/shrn/not/is_zero`.
Division, remainder, tagged `Cmp`, conversions, Nat, float, array, and every
other intrinsic use the original path. Incorrect arity and references to the
three private temporary names also use that path. Unknown names preserve the
original compile error. This is an internal checked-source lowering routine,
not a validator for arbitrary caller-fabricated machine programs.

## Exact source boundary

The source semantics were read directly from the selected mature compiler:

* `selfhost/build/phase102/projection-cost-source01/compiler.bend:31204`:
  U32 intrinsic templates, including guards for large shifts and zero division.
* `selfhost/build/phase108/portable-source04/runtime.c:539`:
  `U32_BIN(a,o,b) = ((u64)((u32)(a) o (u32)(b)))`.
* `selfhost/tools/performance/phase111/runtime/primitives.inc.c:31`:
  the actual finite runtime switch used by the current generic backend.
* `selfhost/tools/performance/phase111/runtime/catalogue.json`:
  exact names, IDs, arities, and source provenance.

The specialization does not parse or generate C. All algorithms and IR
construction are in Bend. The Python fixture preparation writes source and
independent expected data only; it never executes a target compiler or program.

All input and output machine values remain U64. Operand masking implements the
u32 casts even for raw high-half input bits. U64 add/subtract/multiply followed
by a low32 mask gives the same modulo-2^32 result; multiplication of two masked
inputs fits in an unsigned 64-bit word. Bitwise operations preserve the same
low32 bits. `not` is XOR with `0xffffffff` after masking.

Unsigned comparisons operate on masked U64 values. The IR comparison result is
a U32 predicate, used only by `N111If`. Each arm assigns U64 `value` to 0 or 1,
so no implicit U32/U64 assignment or zero-extension rule is needed. Both arms
define the result before the join. Reusing the temporary predicate is always
at the same U32 type; operand temporaries are always U64.

Variable shift counts are full Nat/U64 words. The specialization tests the
untruncated count against 32 before shifting. Counts 32, 64, or 2^32 therefore
produce zero; they cannot become a machine shift by zero after masking. The
shift instruction is reached only for counts 0–31. Fixed shifts use count 1.

Both operands are snapshotted before assigning `value`, so inputs may refer to
the previous `value` local or repeat the same local. Input locals named
`p112_s_a`, `p112_s_b`, or `p112_s_test` fall back before any overwrite. Actual
Phase111 binders have the separate generated `v_...` namespace.

There are no new memory accesses, ownership operations, runtime ABI fields,
machine operators, or verifier permissions. Pure scalar helpers previously
neither retained nor sank their arguments, so removing those calls changes no
owned heap transfer.

## Frozen qualification inputs

`fixtures.json` pins 57 source observations and two dynamic self-tail loops.
`boundaries.bend` covers each admitted operation, wraparound, unsigned sign-bit
boundaries, both Boolean outcomes, and counts 0/31/32/33/64/2^32. The last seven
observations deliberately exercise unchanged division/modulo/Cmp fallbacks.
Every observation is a complete printed decimal word, not a checksum or a
Boolean assertion that might share the operation being tested.

The loop computes repeated `x -> 1664525*x + 1013904223 (mod 2^32)` from seed
305419896. Expected results come from independent logarithmic affine-function
composition in the fixture preparer, not a second execution of the candidate
loop. Small: 65,536 iterations, result 918115960. Large: 1,048,576 iterations,
result 1518622328. The loop counter and every intermediate arithmetic value
remain dynamic. Both sources contain exact `#|` expected output.

Root-run gates should compare baseline and candidate complete outputs, verify
every emitted program with `p111_verify_program`, and retain per-operation IR
or helper-call counts. Then compare repeated matched loop execution with the
same QBE/runtime/link flags. Compile time, emitted-program runtime, and future
native compiler throughput are separate measurements. These two diagnostic
loop inputs are not a broad application suite or a held-out selection set.

Useful falsifiers are removal of result masking (wrap cases), signed comparison
of low32 values (sign-bit cases), masking the Nat count before its guard (2^32
case), machine modulo shift behavior without a guard (32/64 cases), swapped
comparison operands, and U32 result assignment where U64 is required (verifier).
Raw IR controls should additionally supply equal low32/different high32 words
and private-name alias operands; valid source U32 values normally have no high
bits, so those controls are intentionally separate from checked-source cases.

Preparation and delimiter checks are complete. Source checking, compiled
semantics, timing, and promotion remain separate root-owned gates.
