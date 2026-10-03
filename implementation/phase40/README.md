# Phase40 implementation report

Status: checked05 passed all 45 output checks but was rejected for a 2.43×
raytrace slowdown. Checked06 narrows the new Nat rule to data results; corrective
validation is in progress. Phase39 remains installed. The campaign started
2026-10-02 00:18:49 UTC and resumed
on October 3 after an interruption. The [prospective design](../../design/phase40/README.md) defines
the baseline, experiment order, validation requirements and efficiency measures.

Starting installed compiler: Phase39 checked05, API
`04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`.
Two Sol 6.1 medium implementers investigate lists and trees; a Sol 6.1 low agent
handles evidence/tool reuse. Root runs heavy jobs serially and reviews semantic
boundaries. This is not a controlled comparison of models or reasoning effort.

The candidate reuses the existing structural frame engine for canonical native
Nat recursion, direct tail transfers, and one-child constructor/known-combiner
continuations. It admits only the fully checked `List<&2,U32>` representation.
It keeps tagged intermediate lists and all existing public fallback guards.
There is no fusion or new runtime representation.

Independent actual-emission controls pass on checked05: 52 list oracles and106
boundary cases; 302 Nat/tree oracles and84 boundaries;160 mixed unary/binary
oracles,12 error-order cases and36 dependency boundaries. Deep list/tree inputs
reach30,000 levels. These counts overlap in scope and do not replace the broader
integration gates. A missing saved argument in checked04 was caught by these
fixtures and fixed before this candidate; the failed results remain preserved.

Saved-JavaScript experiments show substantial list/tree opportunities and about
2× lexer gains. The lexer remains a manual prototype because production
integration needs a broader String/Char/Sigma proof boundary. Prototype timings
are not delivered compiler gains. Final actual-output timing and release
admission remain pending. The [selection review](raytrace-selection-review.md)
explains why the broader new worker displaced an existing faster scalar path.

- [Lists](lists.md), [trees and order](tree.md), [lexer experiment](lexer.md)
- [Source review](source-review.md), [emission correction review](linear-emission-review.md)
- [Workflow findings](workflow-findings.md), [reusable loop](../../selfhost/tools/performance/phase40/README.md)
