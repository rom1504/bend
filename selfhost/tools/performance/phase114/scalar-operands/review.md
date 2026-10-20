# Independent source review, modules01

No concrete semantic defect was found in the frozen four-module prototype.
This review read source and checked hashes; it executed no compiler, API,
native program or benchmark. Target qualification remains with the coordinator.

Reviewed inventory SHA-256:
`199b1005327ea131682e21e4c01f54d9e0c6689b5d56b38744754427a3443b8b`.
All four module hashes, selected compiler source, runtime source and runtime
object match that inventory. The selected compiler source is
`4fb0572f0a011f6c1921594372d816bb49f26289ecc0e079328edd7491598587`.
The fallback declaration matches its original `p113e_private` declaration
after the name substitution, ignoring blank lines and full-line comments.
The preparer permits only the `p113e_private` override and preserves every
other selected parent declaration.

The central safety premise is the existing verified function. It establishes
the implicit scratch allocation, unique/type-correct local declarations and
memory capacity. The new audit is a use restriction, not a replacement verifier.
In particular, accepting an `N111Alloca` declaration during the audit relies on
the original verifier to reject conflicting/redefined allocation names.

For each candidate allocation, the audit checks every scalar operand and
destination, store value as well as store base, pointer offset, runtime argument,
direct-call result/argument vector, branch condition, terminal result and loop
argument. It traverses both branch representations. Only an exact contiguous
U64 store at zero, optional U64 store at eight, and matching supported primitive
call can account for a use of the candidate buffer. Buffer-as-operand,
buffer-as-call-result, aliases, unmatched accesses and escapes refuse the whole
buffer. A matching group must actually occur. Nested scalar `N111If` accesses
are conservatively refused; direct `P113DIf` groups are audited recursively.

The renderer currently replaces only top-level groups. Leaving nested groups
unchanged is compatible with removing other groups: every accepted group writes
each slot it subsequently reads, and no other observer of the buffer is allowed.
The allocation itself remains. No operation crosses a statement or branch, and
there is no saved-store or speculative-load inference.

IDs 23/1 and 26–35/2 retain the selected float emitter's low-32-bit operand
extraction, unsigned-U32 conversion, F32 operation and explicit `extuw` result.
Comparisons return full-U64 zero or one. Both binary operand copies/casts precede
the destination assignment, so a destination that also names an input remains
safe. No type-to-width or ownership assumption is introduced. This does not add
a claim about arithmetic NaN payload identity beyond the existing float backend.

The new sequence walker retains the selected word-pair/mask rendering and
delegates remaining statements to the original emitter, including Boolean-width
handling and nested branches. It threads the shared QBE counter, reserves nine
slots with an overflow guard, and preserves terminal/error handling. Public
wrappers, recursive-region emitters, runtime imports, original IR and original
verification stay unchanged.

Useful ordinary qualification covers repeated unary/binary float groups, input/
result name overlap, unsigned conversion boundaries, signed zero and NaN
comparisons, plus mixed runtime operations that force buffer fallback. Structural
controls should cover unmatched later reads, other call arguments, branch uses,
and loop/result vectors. These are review recommendations, not executed results.
Compilation cost of the per-buffer whole-function scans is also unmeasured here;
this review establishes neither a performance gain nor arbitrary ownership
correctness for externally constructed IR.
