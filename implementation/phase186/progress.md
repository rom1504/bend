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
also passes focused controls, but regresses tree/Map/record by 8.90–15.27%;
it is rejected as well.
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

## Frozen candidate, 11:15 UTC

Both final maintained sources pass the unchanged upstream source checker with
zero unresolved holes (6.82s QBE; 6.22s assembly). The QBE source is 3,213,774
bytes and the assembly closure 1,589,782 bytes. Native acquisition is now in
progress; these source checks alone do not qualify either native candidate.

The final assembly candidate adds bounded XMM placement for closed canonical
F32 regions and exact unsigned-32-to-F32 instruction selection. All focused
controls pass, including 1,365 XMM/inherited observations and 105 unsigned
conversion observations. The three-case ablation has 48 timed and 44 pilot
observations, all correct, with no >10% spread flags. On active ray, full versus
XMM-disabled is 0.95656, and full versus conversion-disabled is 0.71610. These
are conditional contrasts, not additive gains. The earlier candidate versus
sixth-version ray ratio is 0.65262; its dispersion flag belongs to C timing,
while both assembly roles have less than 2.4% spread. Full45 evidence is pending.

Both unique-take experiments are excluded. Widening old admission size limits
also produced no new useful plans, so those limits remain unchanged.

## Campaign close

Both native chains reproduce text/assembly/objects. Both N2 images pass64 finite
cases; assembly also passes runtime10. All45 outputs per target and eight exact
hosted/native product identities pass. The final five-role comparison is complete
as an explicitly preserved40+5 case-block composition after the original timing
deadline: QBE runtime decreases8.43% to1.34731×C, assembly27.64% to4.00353×C.
All1125 timed and731 retained pilot observations pass; four dispersion flags
remain included. See [the final report](README.md), [runtime data](runtime-summary.md)
and [final native profile](final-profile.md). Parity is not reached. The assembly
self-build cost regression and source growth are recorded; installed selection
is unchanged. No PR comment was posted.
