# P99-005: eliminate avoidable branch closures

Status: prototype, before execution. Baseline: Phase99 source04 `c19e926e…`.

Recognize a bounded general saturated-callee shape that selects and calls a
literal branch closure. Lower selection before constructing both closure
environments, preserving argument evaluation, effects and ownership. Use the
ordinary path when the shape or demand conditions are not established. This is
not recognition by helper name. Existing nct_cat already has direct branching;
name_key and nc_lower_live_to still expose the relevant pattern.

Prior full profiles attribute roughly 12 seconds to physical kc/nt_choose work,
with related allocations elsewhere. A >10% whole-compiler gain is a hypothesis,
not an additive forecast. First test a small genuine caller/capture workload,
both selected outcomes, nested branches and unselected-effect/demand controls.
Inspect actual allocation/cleanup code and measure before building an image.
