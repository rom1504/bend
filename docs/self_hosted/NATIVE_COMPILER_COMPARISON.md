# Comparing native B1, B2 and upstream compilation speed

Protocol, 2026-10-17. This defines a fresh comparison; writing this document did
not run it. Read the [metric definitions](METRICS.md), the
[candidate04 qualification](../../implementation/phase102/default-promotion.md)
and the [fast-backend proposal](../../design/phase105/fast-native-backend.md).

## Define the three executables

| Role | Implementation and construction | What executes during measurement |
| --- | --- | --- |
| Upstream | Pinned TypeScript compiler, commit `059266225b77c8ca256ac6b25ee5c21449bab151` | Its TypeScript implementation under a pinned Bun executable |
| Native B1 | The candidate04 Bend compiler source, emitted to C by pinned upstream and built with Clang | A native executable of our Bend implementation |
| Native B2 | The **same** Bend compiler source, emitted to C by B1 and built with the matched Clang recipe | A native executable of our Bend implementation |

All three compile identical input Bend programs to C. B1 and B2 describe the
compiler's generation, not the target program's generation. B1 versus upstream
compares two compiler implementations and their host environments. B2 versus
B1 holds our compiler algorithms/source fixed and measures how its own backend
and runtime execute those algorithms. B2 versus upstream is the practical
self-hosted comparison. Publish all three ratios, always **our time/reference
time**, so below one means faster.

Use the authenticated candidate04 stages from
[`selection.json`](../../selfhost/tools/native/selection.json), source SHA-256
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`.
The Phase103 public CLI has a different entry/source and build bridge; do not
silently substitute it for either member of this same-source pair. A separate
public-command comparison can measure that user interface. Record hashes of
source, binaries, upstream checkout, Bun, Clang, Base, effects, runtime, harness
and build recipes. Upstream means this pin, not an unrecorded current HEAD.

## Keep the clocks and preparation modes explicit

The primary practical metric is **fresh compiler-process wall time to emit C**:
startup, imports/preparation, checking, optimization, emission, output writes and
exit. Exclude the Python experimental launcher's authentication/publication and
the resource supervisor's own startup; retain their outer wall time separately
when measuring research infrastructure. No Clang runs inside this metric.

The native `request_ms` clock excludes Base preparation and runtime transport,
but includes complete C/diagnostic consumption. Record `base_prepare_ms` and
`runtime_prepare_ms` separately. The existing upstream worker includes source
Base loading/checking in its request, reports imports separately, and hashes and
writes outputs after the request. Thus those request clocks are **diagnostics
with different boundaries**, not a fair standalone algorithm-speed ratio.

Run two separately labelled preparation modes:

1. **Default prepared workflow:** native B1/B2 use their authenticated prepared
   Base carrier; upstream uses its normal source-Base path. Compare process
   wall time, and disclose the persistent artifact advantage plus its one-time
   acquisition cost. This measures the actual configured workflows.
2. **Live-Base workflow:** native stages use `--live`, and upstream loads/checks
   the same source Base in a fresh process. Native preparation remains outside
   `request_ms` even in this mode: use process wall time for the matched broad
   work envelope. This does not mean cold OS page caches, nor identical internal
   algorithms. A prepared-upstream API experiment would be a third mode with
   independently validated cache boundaries, not an assumed existing feature.

Never mix warmed requests with fresh-process samples. A persistent compiler
service deserves a separate campaign, including Bun JIT warmup and native setup.

## Small screen, broader check, then self compilation

First adapt the historical
[Phase92 comparison](../../selfhost/tools/performance/phase92/comparison/README.md)
to the current selection and fresh, role-specific output oracles. Its current
support code hardcodes the old `d04ad79c…` source and old images. **Running that
script unchanged does not benchmark the current compiler.** Phase104's existing
screen authenticates current B1/B2, but includes only Small/Lexer and no upstream.

Start with six sources: Small, Numeric, Lexer, Map, Functions65 and Unicode.
Use balanced role order, randomized with a recorded seed, across fresh-process
rounds. Four rounds are a useful screen; extend only noisy or decision-critical
cases. Give every process the same CPU affinity, available resources and output
filesystem; run targets serially with bounded memory/time and adequate disk
reserve. Store raw observations, medians, variation, peak RSS and generated C
bytes. Profiling belongs in separate untimed runs.

Then extend all three roles to the existing **45 closed catalog points from 23
original programs**. Do not count derivatives as 45 independent program families.
Report per-case ratios and geometric means with both equal-point and
equal-original weighting. Preserve failures and exclusions rather than silently
dropping them. Existing corpora are development/regression data, not holdouts.

For every request, validate its verdict and complete output against its own
frozen role oracle. Expect B1/B2 C equality for the same source/assets; upstream
C may legitimately differ. Build and execute representative products against
the same expected behavior to validate the cross-implementation comparison.

Finally measure all three compiling the **same complete candidate04 compiler
source**. Keep this large workload separate from the small-source aggregate.
Reuse admitted executables; repeated benchmarking does not require rebuilding
the bootstrap chain. Refresh self-emission timing only when its information
justifies its cost.

## Build cost and generated-program speed are separate results

For end-to-end application builds, add Clang/link time for each emitted product
using the same pinned compiler, optimization level, CPU flags and libraries.
Different C sizes and runtimes are real backend costs. Identical B1/B2 products
may share a build for correctness, but that supplies no independent fresh build
timing. Measure generated-program execution independently under the same input
and worker configuration. Also report the one-time cost of acquiring B1/B2 and
prepared assets; that is neither ordinary request latency nor program runtime.

The latest [Phase104 screen](../../implementation/phase104/README.md) records
47/46.5 ms B1/B2 Small requests and 311/303 ms Lexer requests, with distinct
process clocks. It contains **no current upstream ratio**. Historical Phase92
ratios must retain their old source/configuration label. The next actionable
step is the current-stage six-case, three-role, two-preparation-mode screen;
no compiler rebuild or backend change is necessary to obtain it.
