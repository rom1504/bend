# P149-001 — optional optimization cost versus runtime value

Status: design/implementation.

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
