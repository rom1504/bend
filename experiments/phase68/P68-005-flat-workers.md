# P68-005: ordinary C workers for admitted native definitions

Status: registered before source application or target execution. Source-only
prototype owner: p68_upstream. Root alone executes guarded CPU3 targets.

Hypothesis: replacing scheduler continuation cuts and indirect returns with
ordinary C calls and local joins for a conservatively admitted set of exact
saturated definitions will yield a large additional numeric/array improvement.
Keep the one-word boxed value ABI initially. Motivation and exact upstream
anchors: [source audit](../../research/phase68/upstream-native.md).

Prototype artifacts live in
`selfhost/tools/performance/phase68/flat-workers`; no production edits by owner.
Build on arity-v1 and the independently reviewed allocating-prefix extraction.
Use an explicit lowerer result destination: scheduler return, local assignment
and join, or worker return. Reuse the same liveness, sharing, destructuring and
primitive expression logic. The emitter declines unsupported workers; a
fixed-point admission accepts only bodies whose non-self dependencies have
already been admitted. A self-call is admitted only in worker return position;
non-tail self recursion and mutual cycles retain the scheduler.

The first prototype is host-only. Generated scheduler entry adapters call the
worker under `#if !DEVICE` and preserve the existing emitted body under `#else`.
Workers return a status separately from their arbitrary Term result. Primitive
and constructor evaluation order, nonsequential error checkpoints and bounded
loop polling remain explicit. Partial, unknown, foreign and bang call paths
retain the ordinary scheduler unless separately qualified.

Largest uncertainties: preserving first diagnostics and ownership when multiple
control paths fill a local destination; keeping all destination/owner metadata
through recursive lowering; preventing unsupported calls from escaping the
admission fixed point; avoiding host-stack growth on recursion cycles; retaining
device compilation with host-only declarations removed; and compiler latency/C
size cost from candidate construction. No automatic proof or parity claim.

Falsification and first gates: source-review the complete lowering/admission;
build a checked B1; compare numeric/array independent digests and focused
ownership/error/recursion/partial/bang controls with one/four host threads.
Confirm selected generated hot workers contain no scheduler frame operations.
Measure against the same frozen arity/prefix frontier and independently qualify
upstream anchors. Stop or restrict eligibility for any semantic mismatch or
unbounded host recursion. Broader families, B1/B2 native compiler workloads and
release gates remain separate after this screen.

Correctness: untested. Measurement: not run. Decision: investigate; not promoted.
