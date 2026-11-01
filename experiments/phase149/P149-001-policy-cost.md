# P149-001 — optional optimization cost versus runtime value

Status: completed; experimental switches retained, default-policy promotion rejected.

Hypothesis: a few optional optimization groups consume substantial preparation
and verification work with unequal downstream benefit. Early Bend policy gates
can expose a useful development-build tradeoff, possibly retaining exact output
when only unsuccessful alternative search disappears.

Measure complete requests and generated-program runtime from one executing
compiler binary. Hold source, Base, runtime, toolchain, affinity and work fixed.
Use policy-specific full-output references plus independent program oracles;
retain current code0 as the baseline and verify it against Phase147.

Falsifiers: omitted optimizations expand generated work enough to erase compile
savings; generated compilers lose more execution time than acquisition saves;
an apparently optional group is required for correctness; policy overhead is
material; benefits do not transfer. Do not infer whole-build gain from pass
timers or the historical Phase115 emission-only result.

[Design](../../design/phase149/README.md) records the exact initial policy table,
validation stages and conditional larger ambitions.


Result: code11 cuts four-request geometric time20.61%, but three generated
programs slow3.018×. Full frozen-source emission239.089→188.443s; separate guarded
machine builds give staged sums258.413→204.819s. The compiler produced by code11
subsequently takes1.831× on two ordinary requests; about21–31 such requests erase
the acquisition saving. Code4's small exact-output win does not generalize:
RLE is1.327× slower. All measured independent outputs pass within their stated
scope. No new default, full-corpus score or native qualification.

[Report](../../implementation/phase149/README.md),
[metrics](../../implementation/phase149/metrics.json) and
[cost](../../implementation/phase149/cost.json) preserve positive/negative evidence.
Next test a cheap exact rejection prerequisite for wasted preparation, retaining
valuable call/helper optimizations and requiring complete QBE identity.
