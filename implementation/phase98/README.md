# Phase98: laws that support real native compiler optimization

Status: final qualification in progress. No new public default is claimed until
its admission and public CLI checks complete. This campaign began at
2026-10-15 20:07:27 UTC and follows the [three-hour design](../../design/phase98/laws-and-native-optimization.md).

## Results measured so far

The selected source improves upstream-built native B1 substantially and
self-hosted native B2 more modestly. Both are Bend compilers executing as native
programs. Neither timing is JavaScript-hosted compilation or the execution time
of a generated user program.

| Measurement | Candidate / previous native stage | Evidence |
| --- | ---: | --- |
| B1 compilation request, six fixed programs | **0.81067×** | Four balanced rounds; 48 exact complete C/diagnostic matches. |
| B1 complete process, same screen | **0.86564×** | Includes startup, prepared Base, output writing and teardown. |
| B2 compilation request, same six programs | **0.93924×** | Four balanced rounds; 48 exact per-producer C/diagnostic matches. |
| B2 complete process, same screen | **0.97834×** | Small-request preparation remains significant. |
| B1 full self compilation | **104.821 s request**, 105.531 s process | Exact final source; matching previous B1 reference is being measured. |
| B2 full self compilation | **141.614 s request**, 142.440 s process | Whole self-C and diagnostic equal B1; repeated old/new pairs pending. |

A first previous-B2 reference on that exact source took 151.672 s request and
152.493 s process. It is a separate preliminary observation, not the final paired
estimate. Timed C identity is only consistency evidence; independent behavior and
conformance checks remain required for changed backend output.

The final source is SHA256
`2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051`.
B1 was built from unchanged pinned-upstream C in 190.613 s with 4.007 GiB peak
RSS. B2 was built from actual B1-emitted C in 260.847 s with 3.855 GiB peak RSS.
B1 self compilation used 1.527 GiB peak RSS and stayed under the original 2 GiB
request cap. Compiler-image build costs are separate from compilation requests.

## What changed and why

**Keep the owning strings alive while comparing them.** A three-line finishing
helper retains both complete inputs until the unchanged recursive comparison
returns. The upstream backend then recognizes borrowed reads instead of doing
ownership work at every character. This source-only form beat a larger retained
product representation with less code. Fusing 1,366 term-tag comparisons adds a
further B1 improvement.

**Make that opportunity available to native B2.** The own C backend previously
tied observer permission to the whole-program packed-array certificate. An
otherwise admitted IO program, including the compiler, therefore missed pure
borrowed traversals. The new permission is narrower: it authenticates the nine
existing providers, preserves the old scalar/array/cold/product restrictions,
and still requires every individual observer to pass the existing structural
analysis. This is not a global unchecked borrowing switch.

The exact own-backend self-C contains seven new observer workers and adapters.
Shared String equality traverses with `term_peek`; the adapter keeps both roots
until the observation returns, then releases them normally. The consuming
fallback is preserved exactly. **The KTerm tag projection itself remains
consuming in B2.** It benefits indirectly through String comparison, while B1
gets a better projection lowering. This helps explain why the stage gains differ;
a full physical B2 profile is being collected to quantify the remaining costs.
See [actual B2 C spans and mappings](own-backend-mechanism.md).

**Correct an exposed termination defect.** Enabling more observer analysis
exposed an eager `&&` around ancestry recursion. A nonmatching non-field origin
still recursively accessed `kid(Absent, 0)` forever. Full-self runs hit both 2 GiB
and 4 GiB guards. Two intentionally stopped physical profiles and exact generated
C inspection located the defect. Replacing the conjunction with a lazy branch
adds one line and 38 bytes. The old helper fails with a stack overflow; the new
helper passes 11 origin decisions, three unchanged full C products and a valid
root-swapping program which must decline borrowing. This is extended termination
for previously divergent inputs, not an unconditional equivalence claim.

## Laws: useful evidence and explicit limits

The exact selected source has **13 independently accepted named statements:
eight public contracts and five support lemmas**. Two closures contain 15
instances because they share statements; those are not 15 distinct laws. They
connect actual extracted comparison, tag and provider-membership helpers to
frozen reference contracts. Source checking, safe BendTT elaboration, the
independent Lean kernel and a false-statement kernel control all ran. No opaque
helper assumptions substitute for those source bodies.

Independent challenge choices were frozen before inspecting the new suites and
proofs. Incorrect equality carry, character-width and complete retained-product
helpers were first admitted as safe code, then rejected by unchanged laws. A
full-value retained-product fault escaped the public-Bool finite corpus; the law
caught the internal contract violation. A semantically valid codepoint refactor
needed a two-line support-proof repair while its public statement remained fixed.
Targeted follow-up witnesses cover all eight selected bad changes and accept both
equivalent controls, separately from the original finite-suite outcomes.

The wider experiment catalog has 56 distinct Phase98 names, including rejected
and historical variants. That number is **not final-image coverage**. The actual
ancestry nontermination was found by native execution and profiling: safe value
equations did not prove native evaluation order or resource behavior. Runtime
reference counting, observer analysis, unsafe adapters, FFI and the whole
compiler are not mathematically proved.

The practical loop is to extract the actual new helper, run its one relevant
law closure, check complete values and aliases, inspect emitted C, and only then
build a full native image. The final tag and membership checks took about 4.7 s
and 5.3 s end-to-end, respectively. [Reproduction commands](../../selfhost/proofs/phase98/RUNNING.md)
make that loop available for later edits.

## Rejected and retained experiments

| Experiment | B1 request ratio | Source cost | Decision |
| --- | ---: | ---: | --- |
| Cache two tag observations | 1.00749× | +2 lines | Neutral; reject. |
| Retained three-word equality product | 0.85866× | +10 lines | Superseded by smaller finishing helper. |
| Finishing helper alone | 0.85619× | +3 lines | Keep. |
| Finishing helper plus fused tags | 0.81383× | +23 lines | Keep. |
| Wide dispatch extraction across 19 functions | 0.98766× | +525 lines | Reject; no material gain. |
| Held scalar field readers | 0.83766× | +14 lines | Exclude; weak incremental benefit and worse process result. |
| Cached schema planning and lazy redirect construction | Not measured as a native image | +59 lines combined | Keep as separate source/proof/control experiments; not in selected source. |

The held-string IO microbenchmark is 0.14587× previous time, about 6.86× faster,
with complete surviving inputs checked. It demonstrates a mechanism, not a
representative compiler or generated-program speedup. The 105 complete worker
and 60 schema controls for the separate planning candidates do not qualify or
measure them as compiler images.

## Qualification, release and five-metric scope

Final native controls, 45 original programs, 69 native conformance cases per
stage, five complete observer programs and Phase93 batch-C continuity are in
progress. The unchanged 31 native exclusions remain explicit. The installed JS
release and canonical Bend modules are unchanged; their previous results are
continuity references, not fresh Phase98 tests.

The final native profile has 38,790 physical lines: **79 more** than D04, with
5,257 fewer bytes. The selected optimization does not halve compiler complexity.
It rejects the large neutral rewrite and preserves separate narrow permissions.
The compact exact forward/inverse source recipe is 14,812 compressed bytes plus
its manifest. Historical native07 remains available independently.

[Native usage and source replay](../../docs/self_hosted/NATIVE_PHASE98.md) describe
B1/B2 identities, entry limits and restoration. This report will record actual
public selection, capsules, final performance and resource accounting once those
gates finish.

## Evidence and further reading

- [Comparison experiments](comparison.md), [dispatch](dispatch.md), [proof accounting](proofs.md), and [independent challenges](review.md).
- [Observer permission](observer-permission.md), [caller/lifetime review](observer-safety-review.md), and [profile diagnosis](profile-findings.md).
- [Design](../../design/phase98/laws-and-native-optimization.md), [experiment ledger](../../experiments/phase98/), and [current-source law commands](../../selfhost/proofs/phase98/RUNNING.md).

Failures are retained, including both resource stops, the interrupted C build,
initial harness/preparation mistakes and the exact rejected candidates. A server
restart interrupted one C build; it is not evidence of a machine-wide OOM.
Execution accounting distinguishes recorded guard occupancy from elapsed work,
and does not invent token or quota percentages.
