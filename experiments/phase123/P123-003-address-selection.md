# P123-003: retain scaled addresses in QBE's recognizable form

Status: implemented and focused controls/runtime pass; broad qualification pending. Inspecting the remaining editdist
loop found explicit shifts before every packed-array access. The pinned QBE1.3
amd64 address matcher (`amd64/isel.c:681`, `opn`) recognizes multiplication by
1/2/4/8, but not the equivalent left shift. Our `p117h_address` emits a U64 shift
by2 then a pointer offset. The multiplication and shift are identical modulo
2^64 for these literal amounts; no bounds check or masking may be removed.

Test a Bend producer change restricted to this existing array-address template,
using multiply for literal scales supported by QBE and retaining shift otherwise.
Keep the predicate candidate as the ablation parent. Measure actual scale4 machine
addressing, instruction/spill counts, exact outputs and runtime before retaining.
This is an extension of Phase122's machine-level evidence, not a QBE fork or a
new array representation. Require additional array workload/controls and full
compiler/runtime qualification of any retained combination.

Version01 failed source checking because U32.shl is unavailable; version02 selects
literal1/2/4/8 and retains the old shift otherwise. The combined short editdist
screen is252ms vs430ms parent and203ms upstream. Longer four-role comparison
confirms an additional8.7% reduction over predicates alone.80 modular-arithmetic
and450 masked-offset checks pass, with exact GET/SET/SWAP templates. Local-fold
is neutral. No bounds/ownership check or runtime representation changed.
