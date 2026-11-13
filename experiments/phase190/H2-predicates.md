# H2: predicate certificates before branch emission

Prediction: adjacent one-use comparisons can feed a branch directly, avoiding Boolean materialization. Whole-function read/write facts must preserve widths, signed/unsigned conditions, operand aliases and loop behavior.
The later repeated-predicate certificate aims to admit repeated definitions only when each occurrence has a certified adjacent branch use and no escaping read. It does not license arbitrary repeated-condition elimination.
The mechanism is [branch-selection.bend](../../selfhost/src/back/x86/branch-selection.bend); measured source identities are frozen in [alpha](../../selfhost/build/phase190/candidate-api-source09/manifest.json) and [joint](../../selfhost/build/phase190/joint-api-source02/manifest.json) receipts.

[controls01](../../selfhost/build/phase190/controls01/report.json) records 18 original branch controls and both independent machine routes; its branch observer checks 3,162 observations per route. Refusals include parameters, setup writes, duplicate writes, earlier/outer/continuation reads, aliases, unsupported widths and immediates.
The [repeated-use fixture](../../selfhost/tests/phase190/branch-reuse-controls.bend) adds nested, sequence and backedge cases plus escaping/nonadjacent-use refusals.
[integrated-controls01](../../selfhost/build/phase190/integrated-controls01/report.json) records **29 branch rows** and a literal **3,662-observation** C oracle per route, alongside register/liveness/operand/width/joint controls. The checked producer is [joint-api02](../../selfhost/build/phase190/joint-api02/report.json).

Alpha [emission](../../selfhost/build/phase190/candidate-emit01/report.json) and [runtime01 summary](../../selfhost/build/phase190/development-summary01.json) include original branch selection with allocation changes: 0.968552× baseline, but fold **8.280% slower** and tree-bitonic spread **1.151220×**. Branch selection has no isolated runtime gain here.
Joint [emission](../../selfhost/build/phase190/joint-emit01/report.json) enables repeated-predicate reuse together with physical operands and unified allocation. [runtime03 summary](../../selfhost/build/phase190/development-summary03.json) records **0.902469× baseline** for the whole bundle; this is not a predicate-only causal result.
[Alpha audit](../../selfhost/build/phase190/machine-audit-alpha02/report.json) shows fold 59 instructions/10 frame references; [joint audit](../../selfhost/build/phase190/machine-audit-joint02/report.json) shows 39/2. These machine differences also combine mechanisms and do not isolate repeated-predicate savings.

Decision: finite admitted/refused cases support continued investigation within the certificate’s scope. Keep source acceptance, finite machine observations and runtime benefit distinct.
No held-out observations, native candidate compiler qualification or installation. Runtime02’s four-role/three-round imbalance is retained in [H3](H3-physical-operands.md); it supplies no independent H2 attribution. A further local-copy/width cleanup remains planned, with no result credited here.
