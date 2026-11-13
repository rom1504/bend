# Phase192 experiment record

Design: [original](../../design/phase192/README.md),
[recursive-region pivot](../../design/phase192/recursive-regions.md).
Results and exact evidence: [report](../../implementation/phase192/README.md),
[evidence](../../implementation/phase192/evidence.json),
[costs and failures](../../implementation/phase192/cost-final.json).

Selected source is frozen at 21918bf` before held-out results. Main hypothesis:
consume an already verified closed recursive region to remove generic scheduler
transitions. Existing checker/ownership/fallback contracts remain authoritative.
Native45 improves 19.67%; held-out35 improves 18.59%. Native qualification completes.

Negative scoped-frame result: six helper calls disappear, yet lexer slows 1.68%
while expression improves 3.96% and tree 1.99%. Register placement adds snapshot
traffic. Scope-off objects exactly reproduce the prior H objects. Keep this
outside production. Path facts pass finite controls but lack runtime evidence;
wider floating regions retain the reused-local identity obstruction.

One calibration stopped after 30 admitted cases. Exactly the 15 unadmitted cases
were continued under identical frozen policy; authenticated joining revalidates
all 720 timed observations and 582 retained pilots. No admitted case was rerun or
selected by timing. Every regression and dispersion flag remains included.

The observed native fixed point and small compiler-cost improvement do not prove
accelerating research productivity. Use the post-change profiles for the next
ownership/local-control experiment; do not price remaining work from old shares.
