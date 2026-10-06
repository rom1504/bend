# Phase55: direct compiler-image throughput

The full direct compiler-image timeout is resolved. Fixed-source generation
finishes in **96.2 seconds**, and the optimized compiler's own-source image in
**104 seconds**. Both images pass eight exact ordinary-driver observations.
The original full-image attempt exceeded 240 seconds. **Host02 is installed and verified.** All final semantic, native, emitted-byte
and release gates pass.

[Design](../../design/phase55/direct-compiler-image-throughput.md) ·
[Arity proof](arity.md) · [Image usability](bootstrap-usability.md) ·
[Source accounting](architecture.md) ·
[Compiler-image guide](../../docs/self_hosted/compiler-image-generation.md) ·
[Methods](../../selfhost/tools/performance/phase55/README.md).

## Measurements and their scope

All generators use the same pinned upstream Base, unchanged runtime/driver,
CPU3, Node 24.18.0, 1 GiB Node heap, 2 GiB tree RSS limit and 4 GiB available-memory
floor. The fixed subject is the exact Phase54 compiler source, not each
candidate's changing source. Both successful fixed-source images retain every
export and are **3,895,592 bytes, exactly equal**.

| Generator / subject | Emitted reachability | Final call analysis | Definitions | Export wrappers | Total |
|---|---:|---:|---:|---:|---:|
| Phase54 / fixed Phase54 source, fresh diagnostic | 51.16 s | 10.16 s | Incomplete at deadline | Not reached | 120 s deadline |
| Arity01 / same fixed source | 22.89 s | 4.37 s | 14.11 s | 121.39 s | 198.49 s |
| Host02 / same fixed source | 21.91 s | 4.09 s | 13.80 s | 20.92 s | 96.23 s |
| Host02 / its own current source | Separate subject | Separate subject | Separate subject | Separate subject | 103.95 s |

The older Phase54 full, unsplit 77-root attempt timed out at 240 seconds. The
fresh 120-second baseline diagnostic identifies phase costs without spending
another full deadline. The second optimization alone halves complete generation
(2.06× faster) and makes export generation 5.80× faster. These are single bounded
observations with diagnostic forcing, progress IO and final identity checks;
they are not a warmed throughput campaign. The
[measurement summary](../../selfhost/tools/performance/phase55/evidence/compiler-image-performance.json)
contains exact values and hashes.

Restricted images prove the split diagnostic produces exactly the ordinary
library call's bytes before each full run. Full image generation alone is not
called a compiler qualification: the emitted module must also load and perform
real compiler requests.

## Why it was slow

The preserved V8 profile identified repeated whole-book constructor searches
under arity recovery. Matcher annotations already carry the checked argument
datatype. The old helper stripped that information and rediscovered the owner
by searching every definition. The new path uses the existing typed-owner
lookup; unknown or unannotated terms keep the original search. Checked
constructor uniqueness makes this equivalent within the emitter contract.
Common constructor lookup, signed matcher residuals and the declared-arity cap
are unchanged. This improves both emitted reachability and final call analysis.

The next bottleneck was separate: every exported function repeatedly scanned
its recursive argument/result types to decide whether Nat host conversion was
needed. One completed whole-signature no-Nat proof now permits all those
component conversions to stay empty. Nat-positive and budget-exhausted scans
fall back to the old component analysis, preserving conversions and refusals.
No export was filtered out, no runtime guard was speculatively removed, and no
cache or mutable analysis table was added.

These are general compiler optimizations based on checked type information,
not recognizers for named compiler functions or benchmark programs. The two
changes add **27 physical / 19 code lines and four definitions**. All other
105 Bend modules, all 17 native modules, both runtimes and the typed driver are
byte-identical to Phase54.

## Completed focused qualification

Each candidate first passed the checked build and 36 strict frontend witnesses.
The final arity gate checks six actual completed/annotated source graphs,
32 source definitions, 13 raw and 13 annotated matcher queries, four independent
arity goldens and two real source rejections. It includes erased/dependent
constructor fields and preserves the unannotated fallback.

Eight host-wrapper controls require exact old/new wrapper bytes and runtime
observations. They cover Nat results, callbacks, arrays and constructor fields;
erased Nat, recursive no-Nat types and a signature whose combined scan exhausts
its budget while each component remains admissible. The Nat result test returns
a Number internally and requires a BigInt at the public boundary. The large
budget witness is a synthetic private-helper policy test, not claimed source
conformance.

Both emitted compiler subjects pass the unchanged driver's parse success/failure,
check success/failure, direct JS emission, JS execution, native C emission and
successful replay after errors. Diagnostics and complete JS/C bytes match their
respective checked source-oracle images. The fixed-subject host02 result reuses
arity01's successful driver qualification by exact complete-module identity;
it is not described as a second execution. C is emitted in this image probe;
native CPU execution is a separate retention gate.

The own-source image is 3,900,194 bytes, SHA-256
`ae5abd461c24f707747f37b187cedcecd86f5d3c727950f8f8a332fd9dca4091`.
Its source proof is inherited from the exact checked bootstrap. Fresh complete
self-checking, B2→B3 emission equality and migration of every legacy image client
remain separate, unexecuted gates. The working bootstrap remains available.

## Preservation and iteration

Heavy targets are serial and memory bounded; agents investigate source, prepare
controls, review proofs and reconcile documentation concurrently. Broad semantic
and release checks run once for the selected compiler. Complete benchmark-module
identity can retain the existing timing evidence, avoiding another 669-sample
program-runtime campaign. This phase targets compiler-image generation, not a
new generated-program speed record.

Failures remain visible: the baseline diagnostic deadline; two arity harness
assumptions about raw header/body events instead of the actual completed book;
a launcher syntax error before any target ran; and a sandbox child-process
EPERM in the first composition controller. Corrected harnesses preserve the
oracles; the process-permission retry changes only execution permission/output
paths. The per-export v2 diagnostic and SCC body-cache ideas were prepared or
investigated but not executed/implemented: phase timing and full byte equality
were enough to validate the smaller change.


## Final qualification and installed version

The selected checked B1 passes **96 source, 34 numeric, 18 composition and two
true-overapplication controls**, the 26-row direct census and eight maintained
compatibility suites. All 33 semantic modules and all **45 benchmark point
modules from 23 checked sources** match Phase54 exactly. Three native sources
retain their complete C bytes and pass six CPU executions. The installed release
passes **42 legacy + 24 default interface checks**, including ordinary/relocated
routes, integrity and tamper restoration. These scopes overlap and are not a
claim of full language, GPU or native conformance.

The unchanged benchmark modules retain the **dated Phase53** result: 1.069599×
TypeScript execution time per point, 1.078076× per source, from 669 observations.
No new program-runtime speedup or timing campaign is claimed here. The measured
improvement is compiler-image generation.

Selected API: `cfde1ebf44d958e593331cfd9af77f7b6ee657441dbd582db8d27f3928815a62`.
Source: `e4383fa08d621716acac437224de182af52e0b16c32b3f29b2614fc1ad1d6710`.
Upstream pin: `018751270e800bc222a93dad7f257083ee53a5f7`.
The prior Phase54 release's seven files are preserved byte for byte; all 4,543
closed Phase54 evidence files and the 103 inherited unrelated files remain
unchanged. No PR comment was posted.

The [publication index](../../selfhost/tools/performance/phase55/publication.json)
binds compact summaries and the complete closed raw archive, including failed
attempts. Raw paths elsewhere in this report name archive members. The core
optimization commit is `c192b60`; the final publication commit also installs the
qualified artifact and updates the compiler documentation.

At the accounting cutoff **2026-10-06T03:06:45.446656+00:00**, elapsed time was
**44.59 minutes**, with **23.42 minutes** in the union of recorded process
intervals. The remaining **21.17 minutes** includes analysis, parallel review,
documentation, orchestration, unrecorded tooling and idle time; it is not a
waiting estimate. Final archival and publication after this cutoff are excluded.
