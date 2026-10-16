# Phase99: recover native scalar and borrowing information

Status: design, before candidate execution. Baseline commit `795ad05`;
native profile `2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051`.

## Objective and measured starting point

Improve native B2 compilation without compromising generated-program speed,
native B1 compilation, conformance or simplicity. The compiler stays written in
Bend. Preserve the installed Phase98 release until an exact successor qualifies.
Use the existing infrastructure and small experiments before full compiler builds.

Phase98 measured full-source requests at 104.821 s for B1, paired median
140.9875 s for B2, and 45.359 s for upstream TypeScript/Bun. The latter is contextual:
its Base preparation is inside the request whereas native preparation is outside.
B1 and B2 execute the same Bend source, built by different C backends. Matching
B1 is an intermediate milestone, not TypeScript parity. Existing generated-program
evidence is 44 measurable points at 1.115x upstream C, with 45 unchanged C products.
Native conformance is 69 cases and three exact rejections per stage, with 31
explicit exclusions. The selected source has 38,790 physical lines.

The complete matched profiles identify concrete gaps: append/reconstruction
accounts for 4.86 s in B1 and 13.44 s in B2; B2 uses general Terms where B1 keeps
32-bit characters, and a more expensive continuation dispatch. B1 borrows term
tags while B2 consumes their fields. Ownership helpers account for about 71.4 s
in B2, but that is not all removable. These partly overlapping sample buckets
are leads, not additive gain forecasts.

## Sequential experiments

1. **Scoped scalar permission.** Existing `N_WordKind` facts survive bindings,
   captures and fields, but `NATIVE_TYPED_SCALARS` is tied to the packed-array
   certificate. Inspect every consumer and the concrete native ABI before
   separating this permission for checked, authenticated programs. Preserve
   array, cold-constructor, product, raw and device permissions independently.
   Do not infer width for unknown, dependent or generic structural values.
   Expected whole-B2 reduction is a hypothesis of 5–12%, not a release promise.
2. **Borrowed projection and equality boundary.** Explain the current refusal
   with actual generated C, then extend the existing structural analysis only
   where roots remain live and escaping children keep their required ownership.
   Use general analysis rather than recognizing compiler helper names. Reuse
   comparison/tag laws, add the needed lifetime controls, and preserve fallback.
   A 5–15% total-B2 reduction is speculative and overlaps the first experiment.
3. **Conditional follow-ups.** Investigate direct known-branch lowering or
   continuation dispatch only when the first experiments identify a concrete
   additional mechanism. Avoid the previously rejected wide dispatch rewrite.
   Runtime atomic protocols are outside this cycle. Stop neutral candidates.

## Fast falsification and useful laws

Acquire narrow checked testing APIs from exact baseline/candidate Bend source.
Use those only to generate small native programs; report this testing host
separately from the actual native B1/B2 measurements. Freeze inputs and complete
outputs, including errors, surviving aliases and full-width scalar values.
Inspect C and assembly: the intended lowering must actually occur. Benchmark
the generated executables in balanced order with identical work and pinned CPU.
No full compiler build merely because a microbenchmark or a proof passes.

Scalar controls cover U32/F32/Char/Bool boundaries, continuation captures,
generic and dependent fields, IO providers, unknown/changed providers, false
permission, raw entry and device fallback. Existing safe helper laws constrain
values but do not prove the C ABI. Add a production-linked scalar transport
obligation where feasible, and state the remaining unsafe/runtime boundary.
Borrowing controls consume complete roots and surviving child aliases, cover
shared/unique tails and root identity, and require the expected owning fallback.
Any branch experiment needs an operational selected-branch contract, not just
a Boolean identity. Preserve failed proof/admission attempts and distinguish
them from independently checked semantic failures.

Cheap stop gates: no desired code shape, no measurable affected-workload gain,
incorrect complete outputs, or an unsupported authority/ownership assumption.
Refine a bounded candidate when a failure identifies a specific fix; do not
expand the optimizer to rescue a neutral broad hypothesis.

## Integration and five metrics

For a promising candidate, acquire checked native B1 and B1-produced B2 with
the pinned C compiler/flags. Measure each against its own Phase98 baseline on
the six-source screen and on the same complete compiler input. Check complete
per-producer C and diagnostics, and cross-stage source-bound consistency. Changes
to emitted C require original-program execution and appropriate runtime evidence;
byte-identical products can reuse the existing artifact-backed runtime results.
Do not confuse faster compiler-image construction with faster compiler requests.

Reuse Phase98's approximately 163-second two-stage conformance method, broad45,
exact rejection and backend-specific controls. Scope any inherited exclusions.
Keep installed JS and canonical modules unchanged unless an explicitly validated
shared-source change is necessary. Record source lines/bytes and additional
analysis concepts, excluding experimental tooling from the compiler count.

Promote only after exact-source qualification, public launcher checks and
restorable assets pass. Otherwise retain the candidate and report why the
qualified default stays unchanged. No PR comments are authorized.

## Execution discipline and accounting

Root owns the serial compiler/program target queue. Two collaborators perform
bounded source/safety review and candidate preparation without running targets.
Small laws and data audits can be prepared while a guarded target runs. Keep
heavy builds bounded by time/RSS; initial free disk is about 6 GB, so avoid
duplicating raw images and use compact evidence. Never delete unique old evidence.

Retain wall-clock task events and actual guard intervals separately. Measure
time spent in acquisition, native builds, microbenchmarks, compiler screens,
qualification and packaging; do not classify uninstrumented time as coding or
invent token/quota consumption. No deliberate waiting to meet a duration.
Commit the design first, then tested experiments and the final report. Push
checkpoints to `selfhost/bootstrap` with the user's standing authorization.
