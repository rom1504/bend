# Phase147 — remove cold compiler representation work

Matched cold native compilation fell **262.50 → 246.17 seconds (6.22%)**.
The compiler remains written in Bend, with QBE as its native backend. This is a
useful gain, but does not reach the proposed 150/100-second targets. The strongest
result is identifying and removing concrete representation work while preserving
the complete generated program, rather than changing optimization quality.

[Design](../../design/phase147/README.md) · [Metrics](metrics.json) ·
[Qualification](qualification.json) · [Candidate](candidate.json) ·
[Final profile](../../research/phase147/final-profile.md) ·
[Methods](../../experiments/phase147/tools/README.md).

## Changes and measurements

Three production changes are integrated in the one maintained source tree:

1. **Compact direct-admission facts.** Exact local names map to dense IDs;
   immutable schema and numeric flow/capacity facts replace repeated string and
   generic-record work in selected private admission paths. Complete native
   verifier regions, charging conversion and destruction, improve by about
   12–23% across Lexer, Map and an extracted compiler computation. The original
   raw, final and session verifiers remain independent and unchanged.
2. **Fragment rendering.** Argument and memory/statement rendering accumulate
   chunks instead of repeatedly constructing intermediate strings. Three existing
   definitions change; there is no second production emitter or new backend.
   Three complete-body rendering/write kernels take 13–37% less time than
   the original, including output construction and writing. The separate
   nested-emitter correctness gate covers 18 complete selected bodies.
3. **Runtime-name membership.** A Boolean question now directly recognizes the
   same 25 names rather than constructing a signature list and checking its
   nonemptiness. It passes 677 independent controls. The isolated native
   classifier is 10.85× faster, but this is a small part of real compilation:
   its additional full-build effect is inconclusive.

| Same frozen compiler source, fresh native build | Wall time |
| --- | ---: |
| Qualified baseline | 262.496s |
| Compact admission + rendering | 246.745s |
| Final integration, including membership | 246.173s |

These measurements include native compiler execution, QBE construction,
assembly and linking. Emission and QBE overlap, so their pipeline clock is not
pure compiler time. Prepared Base and toolchain/runtime are fixed; no
source-specific semantic or object reuse is used, and OS caches are not flushed.
There is one full observation per variant, not a confidence interval.
The final 0.23% difference from the intermediate variant is too small to claim
as a reliable incremental whole-build improvement.

For the actual larger, newly edited compiler source, acquisition took **271.21s
for N1** using the older compiler and **255.53s for N2** using N1. N1 acquisition
retained QBE while N2 did not, so these are actual workflow costs rather than a
controlled speed ratio. The 246.17s headline is the fixed-source benchmark,
not the new source's 255.53s self-build.

Three alternating native request pairs per input provide a cheaper transfer
check: final/baseline time ratios are **0.9154** for the compiler verifier slice,
**0.9240** for Lexer and **0.9637** for Map. These compile complete selected
inputs; the compiler slice is not the entire compiler. All outputs match exactly.

The full timing workload is the frozen baseline source `00940ed5…fb5e`,
3,010,912 bytes. Its output is exactly 117,232,528 QBE bytes in all variants.
Assembly and machine objects also match byte for byte. Complete ELF files
differ; load layout and the three later load segments match, while 21 bytes in
the first load segment differ and remain unclassified. ELF identity is not
claimed. The new compiler's own source and self-reproduction output are separate
identities: `0f3bd8a0…7eaf` and 119,544,406 QBE bytes respectively.

## What profiling established

We used the maintained native profiler before, during and after integration.
Campaign methods now authenticate each image's fresh source/FID/unwind mapping,
use the active Phase146 closing boundary, and sample at 32ms rather than
oversampling. The first pilot's obsolete stage marker was rejected and retained.
Existing delivery, loss, coverage and stage checks were not weakened.

The three complete captures have 7,302–7,794 samples, no lost samples or overruns,
about 99.99% delivery, and about 99.4% sampled-thread/process-CPU coverage. Every
capture satisfies the complete output oracle. Stage clocks below are disjoint
diagnostic thread-CPU durations, not clean end-to-end wall times.

| Region | Baseline | Final |
| --- | ---: | ---: |
| Rendering, output and teardown | 47.469s | 38.864s |
| Raw lowering | 36.937s | 37.634s |
| Parsing/loading | 32.292s | 32.025s |
| Checking/publication | 31.546s | 31.304s |
| Initial optimizer | 28.861s | 24.293s |
| Observer composition and selected final admission | 20.064s | 19.205s |
| Registry preparation | 16.879s | 15.944s |

Rendering and the initial optimizer explain most of the first integration's
observed CPU saving. The unchanged first and nested final verifier still cost
about 7.9s and 9.1s; the latter is already inside the observer row. Do not add it
again. The final registry interval has 496 samples, below the established
500-sample threshold: its milestone clock is measured, but its detailed owner
distribution is descriptive only.

The classifier audit explains an important limit of isolated experiments.
Its production direct worker matches the fast prototype's QBE and generated
assembly after symbol/local-label normalization, but real callers still pass
through forwarding and scheduler wrappers. The
prototype's direct loop omits that surrounding work. This is a plausible
dilution mechanism, not a measured attribution. We did not spend another full
build retesting shared strings: the original benchmark already retains them.

## Correctness and usable native checkpoint

Independent full-source checking, finite positive/negative controls, actual
parent → N1 → N2 construction, and actual N2 → Q3 emission pass. All complete
self-reproduction QBE products agree. N1 and N2 each pass focused19; N2 passes
ordinary45. The **61 unique positive N2 programs** have byte-identical QBE and
machine objects to authenticated earlier qualified products, with unchanged
runtime/toolchain; executions and three refusals match independent oracles.
No expensive fresh runtime campaign or new geometric runtime score is claimed.

All 112 protected declarations and all 683 existing law bodies remain exact.
The compact admission checker has independent fixed-result controls and complete
real-function comparisons; it does not replace the independent final verifier.
This establishes finite qualification and preserved evidence, not a new BendTT
theorem or universal compiler correctness.

The explicit serial native candidate is:

```
selfhost/build/phase147/integrated-sequel02/n2/program
selfhost/build/phase147/integrated-sequel02/n2/report.json
```

Pass these as `--image` and `--image-receipt` with `--host native --target qbe
--stage N2 --mode cache` to the maintained request/build tools. Use
`selfhost/manifests/assets-native.json`, a fresh output directory and the normal
disk guard; the [workflow](../../docs/self_hosted/workflow.md) supplies the full
invocation. The serial runtime policy remains one thread and GPU off.

The installed JS/C/QBE release and operational assets remain unchanged. This
phase qualifies the edited canonical source's ordinary native QBE path; it does
not promote new JS/C images or broaden incremental, GPU or parallel qualification.

## Cost, failed hypotheses and complexity

The assembled source grows from **64,958 to 65,606 lines (+648)**, with 73 added
definitions and six types. Most added code is the compact admission checker;
the original independent checkers intentionally remain. This is a measured
performance tradeoff, not a source-simplification claim. No persistent cache,
new backend, runtime ABI, or general IR framework was introduced.

Rejected or bounded ideas are preserved:

- Early exit on failed transport admission cannot help this full accepted
  compiler request: its emitted capability descriptor proves the walk succeeds.
- A small-overlay publication hypothesis lacked a measured occurrence on the
  QBE path; the threshold was not changed.
- Caching encoded global names would add substantial retained string data for
  only two observed uses per name; it was not pursued.
- Numeric verifier refinement after the first compact representation adds only
  about 1% in the region experiment. It is not another large whole-build gain.
- Source/harness failures, the stale profiler marker and a faulty first assembly
  normalizer are retained alongside successful results. None is counted as a
  speed improvement or correctness pass.

Exact methods, receipts, failures and measurements are preserved in compact
evidence capsules. Full candidate images and required source/runtime inputs remain
available; recoverable diagnostics follow the repository's archive/verify/close
policy. See [retention checkpoint](retention-checkpoint.md) for scope and recovery.

All76 guarded commands are closed:68 completed, six failed and two qualified
image builds. Recorded guarded execution totals53.61minutes; this includes
acquisition, profiling, experiments and qualification, and is not agent billing
or total research wall time. Closure archives were verified without pruning raw
artifacts. No OOM, disk-reserve breach or guard resource abort occurred.

## Best next experiment

The next substantial gain must remove work across a complete region. Prioritize
preserving compact identities/facts through lowering, or a compact frontend
boundary that avoids repeated name, ownership and record reconstruction. Parsing,
checking and raw lowering together still cost about 101 diagnostic CPU seconds.
The earlier upstream comparison suggests frontend headroom, but its different
work scope is not a drop-in speed forecast.

Test one complete real region with conversion, errors, traversal and destruction
included, then an unrelated transfer case. Keep output and final verification
independent. Extend chunk accumulation only where the new profile demonstrates
remaining reconstruction cost. A 100-second full build still needs about 59%
less time than this result; these measurements do not justify promising it from
another isolated helper optimization.
