# P119-001: current code changes the profile priority

Status: measured diagnostic; no compiler candidate or promotion.

Hypothesis: after Phase118 ownership and live transport, the old Phase116
profiles overstate clearing cost and understate remaining numeric/construction
work. A small exact-product refresh can select the next experiment without
another full campaign.

Method and identities: [design](../../design/phase119/profile-refresh.md),
[reproduction](../../selfhost/tools/performance/phase119/README.md),
`selfhost/build/phase119/manifest01.json`. Six fixed programs, three native
roles, three clean rounds, two sampling periods; one identical native compiler
request across qualified Phase114/118 N1 images. Independent full outputs,
same CPU3 lane and unchanged sampler/oracle. No new JavaScript captures.

Results: [report](../../implementation/phase119/README.md),
[machine audit](../../implementation/phase119/numeric-audit.md),
[exact JSON](../../implementation/phase119/results.json),
[raw evidence](../../implementation/phase119/evidence/summary.json).
All102 observations and44 zero-loss profile analyses independently replay.

Current libc samples in all refreshed programs and the compiler are copies,
not fills. Compiler destruction/reclamation accounts for28.1% of leaves. Numeric
ray/scalar cores remain assembly-identical to earlier versions and hot; their
gaps are8.47×/2.13× upstream. List fill/take/extend accounts for59.5% of leaves.
The selected six-program QBE4.103× diagnostic aggregate is not the broad3.009×.

Next: exact signed-word identity as the smallest test, followed by typed numeric
regions and intermediate-container elimination. Native compiler leaves do not
yet identify which analysis produces its temporary structures; preserve that
uncertainty. SIMD in upstream is an additional observed capability, not a measured
prediction for a scalar-region change. Negative Phase118 attempts remain excluded.

Cost:313.254s serial guarded execution,82.64MiB peak. No target failures, builds,
source/runtime edits, promotion or recursive-improvement claim.
