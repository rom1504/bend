# Final compiler-core residual profiles

Both bounded diagnostics complete successfully and emit the identical checked
138,371-byte library, SHA
`016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186`.
These are instrumented profiles of one 60,909-byte core fixture, not benchmarks
or whole-compiler cost ceilings. The uninstrumented
[combined comparison](private-combined-fixed.md) and [full-source comparison](private-full-source.md)
supply timing evidence separately.

## Frozen experiment

[P4-022](../../experiments/phase4/P4-022-residual-private-profile.md) was recorded
before either diagnostic. Both used CPU2, Node v24.18.0, a 4 MiB stack, 3 GiB
heap cap, 90-second deadline and 10-millisecond sampling interval. Base preparation
and dependency discovery preceded sampling. Frozen B1 is `0653f21e…`, private
profile is `4318bbcd…`, source is `34c6ef63…`, host and Base are identical.
Both launchers, requests and before/after input checks completed; no timeout or
partial profile was discarded. Root kept other compiler measurements off CPU2;
this does not establish isolation from shared caches, memory or background work.

| Diagnostic | Checked B1 | Private profile |
| --- | ---: | ---: |
| Samples | 1,904 | 2,606 |
| Sampled duration | 20.091 s | 25.340 s |
| Instrumented request | 20.058 s | 25.149 s |
| Check API span | 7.186 s | 9.039 s |
| Annotation API span | 5.355 s | 6.453 s |
| JS library emission API span | 2.015 s | 1.742 s |

API spans include boundary encoding/decoding. The sampled interval and measured
request are not exactly the same interval, and the inspector introduces overhead.
Do not calculate a controlled B1/private speedup from these rows. Phase attribution
uses an explicitly recorded profiler-start clock uncertainty; exclusive function
samples are distinct from inclusive stack attribution.

## Remaining work

In the private image, exclusive samples attribute 28.16% to generic `apply`,
9.65% to `force`, 3.64% to `project`, 3.01% to `call`, 2.70% to `stringEq` and
1.82% to global `get`. Garbage collection accounts for 5.22%. The original
ordinary-call transform removes useful paths but leaves substantial generic
application work. These percentages cross checking, annotation and other phases;
they cannot be added to individual helper measurements or treated as removable
fractions. Force includes required evaluation, not only avoidable dispatch.

B1 instead spends 21.38% of exclusive samples in `run_loop`. Three named string
comparison helpers account for 7.41%, 7.32% and 1.85%, with `String.eq` another
2.91%; garbage collection is 5.29%. These are generated upstream helper names,
not the same runtime implementation as private H. This supports separately
investigating name/index operations and trampoline work in B1, without claiming
that every comparison or trampoline sample can disappear.

Checking and annotation remain the largest top-level spans in both diagnostics.
Optimizing only text emission cannot account for the entire remaining request.
The [generated-code comparison](residual-architecture.md) identifies a concrete
next falsifier: typed internal workers spanning matcher boundaries, restricted
initially to already-computed arguments. That mechanism addresses application
paths missed by ordinary function uncurrying. Sampled `apply` alone does not
prove that this specific family dominates it; actual family entry/staging counts
are the first gate before implementation or timing.

The [design](../../design/phase4/next_compiler_lowering.md) specifies evaluation
order, error, captured-context, partial/overapplication and deep-stack controls.
No production compiler or emitted program was changed by these diagnostics.

## Evidence

The profile archive preserves raw V8 samples, exact emitted output, launch and
request reports, configurations, profiler tools and consumed-input hashes.
Archive publication follows the isolated frontend-scheduling measurement window;
raw observations currently reside in the immutable Phase 4 build directories.
