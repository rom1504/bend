# P136-001 — Split cold source-to-executable cost

Status: investigation complete; selected compiler unchanged.
[Design](../../design/phase136/README.md) ·
[Report](../../implementation/phase136/README.md) ·
[Metrics](../../implementation/phase136/metrics.json).

Hypothesis: earlier preparation, rather than the existing late object/optimizer
cache, contains enough work to deserve the next structural optimization.

Qualified Phase134 N2 compiles fixed full Phase131 source in375.923s guarded,
1.018GB peak, exact107,059,385-byte independent QBE. A separately checked native
diagnostic produces that same oracle and splits354.248s into seventeen intervals.
Parse/import44.745s, check53.149s, annotation/validation18.656s and erasure30.326s
explain most of the152.111s frontend excluding Base. Raw lowering59.411s,
optimization/verification77.734s and rendering64.760s remain substantial.
Dedicated ownership checking takes only0.144s.

The exact-QBE machine replay takes8.727s QBE,4.874s assembly and0.266s link.
This is a separate replay, not an additive decomposition of the overlapped cold
pipe. Diagnostic and clean executables/clock boundaries differ. No speedup or
new upstream ratio follows from their clocks.

Decision: the broad cold-build direction is justified; optimizing only the
checker, changing backend, shrinking text, or adding more late cache hits cannot
by itself reach60s. First remove measured query/ownership work, then test one
prepared semantic unit. All seventeen timings, independent source/output gates,
small instrumentation screen and failed diagnostic preparations are retained.
