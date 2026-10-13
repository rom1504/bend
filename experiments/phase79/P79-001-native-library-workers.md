# P79-001: prepared native Base workers

Status: proposed, no implementation or timing result yet.

[Design](../../design/phase79/prepared-native-library.md).
Phase78's local rewrites leave large repeated native work. Test a separate
Bend-produced Base artifact with annotations, erased bodies/arity and positive,
segment-free, static-address-free workers. Require the existing exact world/ABI/
compiler/Base binding and per-request disjoint-context admission.

First require exact Phase78 C and15% net request-time savings in the explicitly
prepared-native-library mode. Report preparation, size/RSS, decoding/admission,
ordinary fallback and non-IO held-outs. Reject or narrow if serialization/JIT
costs eat the saved work. Do not silently relabel the established baseline clock.
