# P113-001: preserve complete functions and products before runtime lowering

Status: planned, before implementation. Baseline `cc4566a`, Phase112 facts.

Hypothesis: complete direct functions with checked result/ownership facts and
flat product interfaces remove generic continuation and carrier work that local
QBE rewrites cannot recover. Reuse mature C-planner semantics in Bend while
rendering structured IR. Keep generic fallback and fixed runtime contracts.

First falsifiable gate: an admitted scalar loop has no recurring generic frame/
dispatch boundary; an array/product loop removes temporary tuples across ordinary
calls. Independent semantics and alias/depth controls precede matched timing.
Failure to change those structures blocks another full acquisition.

The [design](../../design/phase113/qbe-program-parity.md) defines1×/10×/100× scope,
frozen metrics, stop/go rules, resource caps and the three-hour budget. Gains are
unmeasured. Production selection remains unchanged until separate qualification.
