# Phase79: prepared native library, rejected after measurement

The optional native-library cache does not justify promotion. Keep the qualified
[Phase78 compiler](../phase78/README.md) installed. This experiment changes no
production source or default behavior after rollback. Parity remains unachieved.

[Design](../../design/phase79/prepared-native-library.md) ·
[Experiment](../../experiments/phase79/P79-001-native-library-workers.md) ·
[Preserved patch](../../experiments/phase79/prototypes/compiler04-vs-phase78.patch).

## What was tested

A Bend producer computes Base annotations, erased bodies and runtime arities,
plus successful ordinary native workers. It excludes scheduler segments and
static-image addresses. The host transports the product through the existing
Base arena and binds it to compiler, Base, source path, ABI and prepared-world
identity. The request must pass the existing disjoint-context admission.

Workers retain their signature queries. Reuse checks those queries against the
current request, including product-signature withdrawal; ordinary dependency
admission and retry still run. The prototype caches no negative lowering result.
The first version retained the whole library in request metadata. The second
retains only workers selected by the request, discarding the library-wide erased
index once request erasure finishes.

This is a separate **prepared-native-library** contract. It is not a gain on the
ordinary prepared-frontend-only clock unless explicitly compared as such.
Preparation is outside the request; reading, checksums, decoding, admission and
lookup are inside each fresh process's request. Imports, Clang and execution are
excluded exactly as in the established loop. TypeScript checks Base per request.

## Results and decision

| Screen | Library / candidate ordinary request | Library / Phase78 request | Library / upstream | Extra preparation |
| --- | ---: | ---: | ---: | ---: |
| Whole-library payload | 0.9651× | 0.9791× | 1.7280× | 3.26 s |
| Selected-worker payload | 0.9485× | 0.9506× | 1.6621× | 3.38 s |

Each screen contains 24 clean fresh requests: two rotations of three sources
across four isolated roles. The same candidate also runs without the product,
so its ordinary overhead cannot be hidden in the comparison. All complete C
outputs match independently executed Phase78 artifacts exactly. These are short
screens, not precise confidence intervals; individual samples show noticeable
variation. [First screen](screen03.json), [second screen](screen04.json).

The optional artifact is 2,942,203 bytes. Total explicit Base/library preparation
was about 6.6–6.8 s, versus about 3.3 s for Base alone. Illustrative break-even is
73 requests in the first screen and 47 in the second, using each screen's
average saving and its single preparation observation. This does not include
compiler rebuilding or guarantee gains on different programs.

The second prototype's non-IO controls show effectively no gain:

| Source | Phase78 B1 | Candidate ordinary | Candidate with library | Upstream |
| --- | ---: | ---: | ---: | ---: |
| Small | 333.9 ms | 333.9 ms | 335.9 ms | 306.3 ms |
| 65 functions | 669.3 ms | 670.9 ms | 671.4 ms | 366.5 ms |

[Sixteen held-out requests](heldout04.json). These controls reinforce that the
library-dependent three-source ratio is not universal.

The predeclared discriminator required at least 15% net request savings. Neither
prototype passes. **Reject both and stop the observer-cache expansion.** Do not
pay for B2 regeneration, broad release qualification or new native runtime
measurements for this losing candidate. Production source was restored exactly
to the installed Phase78 checkpoint and release verification passed afterward.

## Why the expected gain disappeared

Two separate V8 diagnostic requests confirm actual product admission and use.
In the numeric request, public stage timings changed approximately as follows:

| Stage | Ordinary | Whole-library product |
| --- | ---: | ---: |
| Annotation | 85.8 ms | 12.9 ms |
| Native request preparation | 87.8 ms | 37.9 ms |
| Merge annotated context | 19.6 ms | 41.9 ms |
| Native compilation | 669.4 ms | 634.4 ms |

Product reading/admission has about 36 sampled milliseconds, including about
34 in decoding/checksum work. GC self samples rise from about 113 to 147 ms.
Some avoided work becomes extra object materialization, context work and later
metadata traversal. The narrower payload recovers a little more. The remaining
compiler still loads/checks user source, validates layouts, builds static and
product plans, performs symbolic observer analysis and renders C.

The stage clocks and sampled stacks overlap and include profiling overhead;
they must not be added to predict clean savings. They diagnose the mechanism;
the separate clean screens determine the decision. [Profile receipts](profile03.json).

## Validation and limits

Both usable candidates pass the checked build and 36 focused frontend cases.
The 64 clean requests and two profiles pass exact-C checks. The first two
builds fail at a missing local type annotation and an affine binder used twice;
the snapshots and diagnostics remain preserved. No OOM occurred; builds stayed
below 1.6 GiB aggregate RSS. One guarded CPU3 process tree was used throughout.
No agents, upstream edits or PR comments were used.

This is not full cache correctness qualification. Custom-Base, corrupt-product,
product-withdrawal, foreign/bang and genuine B2 integration suites were not run
for the rejected prototype. It was never installed or made the default.
The unchanged installed Phase78 has its own full selected qualification.

## What this changes about the next investigation

A large serialized library graph is not a demonstrated route to cold parity.
Do not expand this design based only on the large annotation-stage saving.
Any future cache needs a cheaper representation or selective decoding, measured
before implementation expands. General user-code costs also need attention:
the 65-function control gains nothing from library reuse.

For the ordinary clock, reaching upstream still requires roughly 42% less B1
request time or 28% less B2 time on the Phase78 three-source loop. The retained
profiles implicate allocation, repeated structural traversal, normalization,
rendering and B1 trampoline dispatch. A larger representation or control-flow
change needs a bounded prototype against both IO-based and non-IO sources.
Existing direct-branch expansion and tag-classifier failures should constrain
that proposal; merely adding another broad cache or more tiny helpers is not
supported by these results.

[Guard accounting](timing-account.json) separates recorded execution from elapsed wall time; it does not estimate Codex quota.

[Complete verified evidence](../../selfhost/tools/performance/phase79/evidence01/README.md) preserves every candidate, failure, clean request and profile.
