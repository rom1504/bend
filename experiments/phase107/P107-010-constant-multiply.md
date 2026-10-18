# P107-010: bounded unsigned constant-multiply reduction

Status: completed bounded experiment; retain as optional, not the default.
Bridge19 and the finite correctness gates pass, but paired execution results are
mixed, including a10.0% QBE text regression estimate. The original hypothesis was
frozen before implementation. The
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

Before interpreting the mixed measure07→measure08 screen, run a frozen five-round
alternating comparison of all39 existing optimized binary pairs (13programs×three
backends), with identical full-result guards/arguments/repetition counts. Record
ELF `.text` identities; a faster observation from code-identical pairs is not
credited to the transformation. No recompilation, policy retuning or case selection.
The method is `strength-pair.py`; complete source-stage and backend matrices remain
separate. Small/noisy effects do not justify a default change.

## Outcome

The first two checker failures were fixture-only: missing `+width` in Bridge17,
then a plain helper declared after its caller in Bridge18. Both failures and
control versions remain preserved; borrowing and definition order were corrected
without changing the strength-reduction core. Bridge19 passes.

`strength-audit01` passes282 valid graphs,8440 independent-model observations
and1500 generated native outputs across GCC/QBE/CL. `strength-extra01` passes all
11 supplemental controls: eight valid and three invalid graphs, including six
capacity/growth cases and exact effect operand/control-position checks. Its two
effectful witnesses add32 model observations and48 native outputs. This is finite
qualification, not a theorem or whole-language correctness claim.

The frozen paired protocol above completed39 pairs and390 observations. Twenty-five
pairs have identical ELF `.text`; their timing differences are not optimization
credit. Among changed-text pairs, strength/promotion ratios include recurrence
0.827 CL/0.802 QBE, closure0.873/0.920, borrowed0.854/1.029, text1.047/1.100,
and shared0.993/0.993. Lower is faster. The apparent roughly10% shared improvement
against raw Clang in the separate screens did not survive direct paired comparison.

Keep `nx_strength_reduce` available for explicit experiments, without making it
the standard pipeline. Arithmetic equivalence does not imply backend profitability;
instruction selection, register pressure and workload dependency chains still
matter. The complete table, method limits and exact receipt hashes are in the
[report](../../implementation/phase107/promotion-code-shapes.md#p107-010-closed-results-optional-not-default).
