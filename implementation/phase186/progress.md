# Phase186 progress checkpoint

Parent1b46218; campaign started2026-11-09 09:10:53 UTC.
This checkpoint preserves checked experimental improvements. Native compiler
reproduction, full45 runtime measurement and publication remain pending. The
installed Phase183 selection and qualified Phase185 N2 references are unchanged.

The first controlled ten-program screen compares the same Bend programs with
our mature self-hosted C backend and actual Phase185 N2 products:

| Target | Before/C | First candidate/C | Runtime reduction |
|---|---:|---:|---:|
| QBE |1.52995|1.42392|6.93%|
| Direct AMD64 assembly |5.18040|4.16324|19.63%|

These are screen metrics, not the historical44-case geometric mean. See
[first-screen analysis](first-screen-analysis.md) for exact retained identities,
all180 timed observations and188 calibration observations.

The retained mechanisms remove scheduler argument-copy helper calls, preserve
full-word Char identity, retain inline-operation effects through register
placement, eliminate unobservable private memory, schedule acyclic loop moves,
and save only assigned callee-saved registers. Later assembly candidates add
bounded expression reuse, direct physical copies/loads, direct ABI argument
loading with a real snapshot fallback, and a distinct private F32 operand plan.
All transformation and instruction-selection implementations are Bend.

The continuation-only follow-up (`stack-only-qbe-runtime01`) improves Unicode
text another21.06% and generic rows13.78% relative to the first candidate, with
Map/tree/record within0.63%. Original/admitted continuation plans, ordering,
100001-level explicit stack descent, state restoration and full64 values are
independently checked by focused controls. This is stack-safe local resumption,
not native recursion or a general recursive-optimization claim.

Negative evidence matters. Unique-take v1 regresses tree4.65%, Map15.89% and
record14.01% in the bundled follow-up; its production hook was removed.
[The experiment](../../experiments/phase186/P186-004-unique-take.md) records
actual machine growth and repeated fallback code. A single-fallback prototype
has passed focused controls but is not selected or performance-qualified.
Changing old loop alignment produced no material recovery (<0.40%).

A transient disrupted one later assembly generic-row comparison, inflating an
unchanged binary by1.8x. Its apparent46% gain is rejected. A six-round focused
repeat (`fourth-x86-generic-recheck-runtime01`) instead observes2.78% less
runtime; the other nine cases' diagnostic geometric reduction is7.36%.
The isolated private-F32-plan screen observes8.62% less ray runtime,4.98% less
numeric runtime and unchanged fold work. None of these small screens establish
broad parity.

Focused source/machine controls cover ownership aliases, state snapshots,
argument cycles, inclusive lifetimes, widths, mutated/escaped buffers, F32
NaNs and full-word results. The original verifier and runtime ABI remain.
These finite observations are not BendTT proofs. Full integration gates and
an honest final report follow after the remaining bounded experiments.
