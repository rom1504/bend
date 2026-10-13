# P83-003: frontend scaling versus cold execution

Status: strong warm-process sensitivity; no quadratic-work finding.

Hypothesis: the many-function frontend cost might indicate repeated source-world
work. Alternative: cold execution/tiering and allocation contribute substantially.
Generate8/32/65/128 simple chained definitions;65 matches the prior fixture byte
for byte. In eight fresh role/source processes run three ordinary check/report
requests, without a persistent inspector. All24 requests pass.

At65 functions B2 check/report falls351→136 ms; source completion144→45 ms and
checking82→24 ms. The128-function source completion falls217→55 ms. These results
do not isolate V8 from GC/module/OS state or prove steady-state/asymptotic cost.
Upstream checks Base each time; Bend uses explicitly prepared Base. First B2
check-only65 already beats upstream slightly,351 versus371 ms, so the complete
native gap still requires backend preparation/planning work.

Decision: collect logical visits and V8 tier evidence before a parser rewrite.
Retain ordinary warm-session development as a distinct contract, not cold parity.

[Frozen method](../../selfhost/tools/performance/phase83/prepare-frontend.py) ·
[Observations](../../implementation/phase83/frontend.json) ·
[Pipeline research](../../research/compilers_architecture_and_techniques/phase83/pipeline-comparison.md).
