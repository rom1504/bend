# Phase 4 structural compiler optimization report

Status: in progress. Authorized window: 2026-09-22, approximately 14:16–20:16 UTC.
Design: [structural compiler speed](../../design/phase4/structural_compiler_speed.md).
Starting compiler revision: `89e2c83`. The design was committed and pushed as
`4f59f08` before production compiler edits.

## Frozen starting point

[baseline.json](baseline.json) identifies 73 captured artifacts in
`selfhost/build/phase4/baseline`, including the 59 source modules, manifest,
assembled source, B1 and H APIs, runtime, host helpers, and prior evidence.
The original files remain available. The canonical pinned Base is shared;
separately keyed, previously validated Base cache entries were copied for the
diagnostic runs.

| Artifact | SHA-256 |
| --- | --- |
| B1 API | `8787894920cc8959ab0abec28ddae0ea0dc05ad7665dc6f4d43f845445e60923` |
| H API | `360bb62bec910e8148a8c24ee63c1a350a8fda06c206bdd5f04c153a006804de` |
| Assembled compiler | `936266643e95973709bac4b567289c5792decadbb3297f90018ed5052582d772` |
| Runtime | `26f5eee2f54b194b64f768df6ff505c67bf7a5df2159aa06caf53ecba54e910b` |
| Base | `b8c2734d45ec6b4ce70fee70ff06ef35e08fce885af8852d8eb77dbff020e946` |

The reference remains untouched TypeScript revision
`6018e28ecc67cf1fffc0c20c64b11023474c2df8`. Phase 3 established approximately
50 seconds for full-source TypeScript compilation, 250 seconds for native O2,
704 seconds for B1, and 1,980 seconds for H. Those observations have different
run histories; they are starting context, not a new causal benchmark.

## Successful-compilation profiles

The new diagnostic tool
[`cpu-profile.mjs`](../../selfhost/tools/performance/phase4/cpu-profile.mjs)
captures V8 exclusive CPU samples and synchronous top-level compiler API spans.
It hashes consumed inputs before and after the request and retains the emitted
output. Base preparation and dependency discovery precede the profile. Discovery
therefore warms the process; these instrumented observations are not fresh-process
timing benchmarks and are not used as the denominator of speedup claims.

Both initial runs used the frozen H API, CPU 1, Node v24.18.0, a 4 MiB V8 stack,
4 GiB old-space limit, and a 1,000 microsecond sampling interval.

| Exclusive sampled function | Tree | List sort |
| --- | ---: | ---: |
| Generic `apply` | 38.76% | 38.38% |
| `force` | 6.40% | 6.37% |
| Garbage collection | 5.52% | 6.60% |
| `call` | 2.97% | 3.59% |
| `project` | 2.57% | 2.50% |
| Global `get` | 1.93% | 2.89% |

The instrumented request took 3.472 seconds for tree and 6.390 seconds for list
sort. Checking, graph loading, and annotation account for most API wall time;
the runtime helper costs cut across those phases. Samples support investigating
dispatch and allocation, but cannot be summed into an achievable speedup.

Retained reports and raw profiles:

- [Tree report](evidence/h-tree-profile.json) and
  [compressed CPU profile](evidence/h-tree-profile.cpuprofile.gz).
- [List-sort report](evidence/h-list-profile.json) and
  [compressed CPU profile](evidence/h-list-profile.cpuprofile.gz).

A full-source B1 diagnostic profile is also running. Its timing will be labeled
as instrumented and kept separate from controlled comparisons.

## Experiments underway

The private-image experiment isolates all compiler function objects in a child
process and transports data-only requests/results. This makes stronger internal
call specialization possible without changing the ordinary public library ABI.
The first alternating matrix passed 45 exact host-observation, emitted-byte, and
program-execution checks. Preliminary public-H to combined-private medians were
3.088 to 2.695 seconds for tree and 6.391 to 4.974 seconds for list sort. These
are experimental artifacts; integration and final gates remain pending.

The representation experiment found millions of projection copies but no clear
gain from removing those copies alone. Its first pilot included uncached Base
loading/checking and must not be compared directly with the warm-cache profiles
above. Follow-up experiments distinguish projection calls from data layout.

The analysis experiment found many repeated weak-head-normalization requests for
terms already in weak head normal form. A conservative `All`/`ADT` shortcut keeps
all other tags on the original evaluator. A disposable list-sort ablation showed
about 1.16x; a checked Bend-source overlay and exact normalization controls are
required before accepting that result as an implementation improvement.

The coordinator is testing indexed final-definition selection for
`driver_final` and `sp_canonical`. The old routines repeatedly filter all prior
declarations. The candidate preserves last-definition-wins order and the initial
list's unrelated duplicates; short lists retain the original path. It is still
an isolated source overlay, not a production change.

The shared
[`checked-overlay.mjs`](../../selfhost/tools/performance/phase4/checked-overlay.mjs)
builds such overlays in new directories, verifies frozen and actual consumed
inputs, checks the pinned upstream checkout, assembles the full compiler, runs
type/ownership/completeness checks, and emits selected API roots. It does not
fabricate normal bootstrap metadata. Its caller supplies process resource limits
and a deadline.

## Pending completion gates

No Phase 4 production optimization or distributed API promotion has been claimed
at this checkpoint. Combined-source checking, broader exact conformance, final
controlled timing, checked self-reproduction, native validation where affected,
and final development documentation remain to be completed during this pass.
