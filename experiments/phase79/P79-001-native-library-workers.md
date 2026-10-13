# P79-001: prepared native Base workers

Status: implemented, measured and rejected; production restored to Phase78.

[Design](../../design/phase79/prepared-native-library.md).
Phase78's local rewrites leave large repeated native work. Test a separate
Bend-produced Base artifact with annotations, erased bodies/arity and positive,
segment-free, static-address-free workers. Require the existing exact world/ABI/
compiler/Base binding and per-request disjoint-context admission.

First require exact Phase78 C and15% net request-time savings in the explicitly
prepared-native-library mode. Report preparation, size/RSS, decoding/admission,
ordinary fallback and non-IO held-outs. Reject or narrow if serialization/JIT
costs eat the saved work. Do not silently relabel the established baseline clock.

## Decision

Rejected. Compiler03 passes checked build/frontend36 and exact-C clean24;
its product saves only 3.49% against its ordinary mode (2.09% against Phase78).
Two profiles confirm cache use but expose decode, GC and context costs.
Compiler04 narrows retained metadata to request-selected workers: clean24
saves 5.15% against its ordinary mode (4.94% against Phase78). Both miss the
15% discriminator. Held-out16 is effectively unchanged. No observer-cache
extension or B2/release qualification is justified. Preserve snapshots, failures,
profiles and patch; restore production to Phase78. [Report](../../implementation/phase79/README.md).
