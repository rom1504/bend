# P73-001: non-tail recursive private workers

Status: registered; no measurements yet.

`nf_call_local` rejects non-tail self calls, while dependency admission allows
self references. This prevents ordinary native workers for general producers
and evaluators. A diagnostic API derivative replacing this refusal by the
existing named-call lowering is a fast falsifier of the runtime opportunity.
It deliberately lacks deep-stack safety and must not be installed or qualified.

Measure list pipeline, expression and Tape on the current pinned sources, then
expand if useful. Independent oracle, same Clang recipe, rotated baseline /
prototype / upstream. No semantic rewrite of the benchmark itself. Record
which workers become eligible, C bytes, and local/aggregate speed potential.
A production version requires bounded stack use and a tested fallback, or an
explicit-stack lowering. Refuse promotion if those safeguards erase the gain.
