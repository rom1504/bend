# Predicate/continuation source ceiling

`insert-positive-v01.bend` changes only the negated prefix-bit comparison in the
actual `p131i_insert`, swapping its two syntactic lambda arms. Every other branch,
fallback, ownership annotation and runtime operation is retained.

`prepare-v01.py` freezes two dependency-closed current-compiler fixtures and checks
that the candidate is exactly that edit. `plan-v01.py` prepares seven root-owned
serial guarded jobs: two checked APIs, two original Phase131 complete-tree/payload
control runs, two ordinary native builds and one alternating native timing block.
Neither preparer executes targets. `time-v01.py` executes only under the root's
CPU3 guard and reuses the independent Phase131 output arithmetic.

Artifacts:

- Source/census: `selfhost/build/phase144/predicate-proxy-source01/`.
- Prepared jobs: `selfhost/build/phase144/predicate-proxy-plan01/jobs.json`.
- Future native images: `selfhost/build/phase134/p144-predicate-{original,positive}-native01/`.
- Future timing: `selfhost/build/phase144/predicate-proxy-timing01/`.

The current integrated compiler's425-line generic entry saves a64-byte frame
around the ready Bool.not call. Both proxy products retain QBE so that the baseline
can be checked for the same boundary and the candidate for its elimination.
Static source spelling/counts alone are insufficient evidence of changed work.

This is not a general optimizer or a claim of compiler speedup. The complete
[audit](../../../../../research/phase144/predicate-composition.md) distinguishes
old profile exposure, exact source semantics, generated machine shape and pending
measurements. The full compiler, final verifier and runtime remain unchanged.
