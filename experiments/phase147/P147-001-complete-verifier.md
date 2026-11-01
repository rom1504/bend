# P147-001 — Compact identities across a complete verifier computation

Status: integrated and ordinary serial native-qualified. See
[design](../../design/phase147/README.md) and
[final report](../../implementation/phase147/README.md).

Prediction: compact identities and dedicated schema/live-state records can remove
repeated string lookup and generic record reconstruction. The useful result is
lower total native schema→flow→join→error→cleanup cost on real raw/direct functions,
not fewer allocations alone. Aim for a substantial region improvement; full-build
savings are bounded by freshly measured exclusive stage costs.

Falsifiers: conversion dominates; direct workers disappear; errors/order differ;
sharing/branch state leaks; a second workload regresses; full-request gains vanish.
Candidate04 passes 60 original and 16 supplemental semantic controls, 19 numeric
flow controls, two count-boundary controls and 36 actual complete-function
comparisons. Native complete-region ratios are 0.775 Lexer, 0.881 Map and 0.813
compiler slice, including schema construction, conversion and teardown.

The integrated implementation accelerates three intermediate direct-admission
sites. Original raw, final and protected session verification remain unchanged;
all 112 protected declaration hashes agree. The selected module adds 609 lines,
71 functions and six types. This is a measured cost/benefit tradeoff, not a
complexity reduction or a mathematical equivalence proof.

Combined with fragment rendering, the first matched frozen-source cold build is
262.496 → 246.745 seconds, including QBE, assembly and linking. Complete QBE,
assembly and machine object are identical. Three smaller complete requests
improve about 5–8%. These combined measurements do not isolate the verifier's
whole-request contribution. Native self-reproduction and broader independent
gates remain separate from the region results. The final integration passes
N1/N2/Q3, both focused19 and N2ordinary45. With the separate membership change,
final cold time is246.173s; this does not isolate verifier-only savings.
