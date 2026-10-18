# P107-010: bounded unsigned constant-multiply reduction

Status: hypothesis frozen before implementation; no target execution. The
[object audit](../../implementation/phase107/promotion-code-shapes.md) finds a
loop-carried multiply by33 in promoted CL/QBE shared and borrowed kernels, while
raw Clang uses shift/add. The hypothesis is that a small general arithmetic pass
can recover part of the remaining runtime gap without new IR or memory analysis.
No speedup is predicted or attributed before paired measurement.

Add optional `nx_strength_reduce(program)`, with input/final verification and
unchanged-input refusal. For a known U32 or U64 atom, reduce multiplication by
`2^k` to a same-width shift and by `2^k+1` to shift/add. Accept either coefficient
position, match all representable coefficients, and do not inspect function or
variable names. Zero/one are safe atom identities. Unknown types, pointer atoms,
non-atomic multiplied operands and other coefficients retain their expression.
Recurse structurally without changing evaluation/effect/control order.

The existing IR stores constants in U32 fields even for U64 literals: coefficient
search therefore stops at bit31. A U64 shift must use a U64 shift-count constant;
never silently narrow a U64 product. Modular identities apply at the actual
operand width, including wraparound. Bounds:256 functions,65536 original counted
nodes,4096 original body nodes per rewritten function, and4096 whole-program
growth; capacity failure retains the original pass input. No production default.

Freeze fixtures and independent BigInt/modular expectations before compilation.
Cover zero, one, powers and powers-plus-one through bit31, arbitrary nonmatching
coefficients, both operand positions, values near both width boundaries, U64
high-bit/nonzero-high-half observations, non-atom refusal and invalid input.
Check complete products, output verification/growth, pure-expression semantics,
and existing whole-program oracles. Inspect backend objects for actual shift/add
before clean paired runtime comparisons. Arithmetic preservation is distinct from
profitability: the CL accumulator spill and backend unrolling remain separate.
