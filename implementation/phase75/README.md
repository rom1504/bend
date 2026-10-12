# Phase75: faster native compilation with identical generated programs

[Design](../../design/phase75/native-compilation-parity.md) ·
[Measurements](measurements.json) ·
[Methods](../../selfhost/tools/performance/phase75/README.md) ·
[Compiler documentation](../../docs/self_hosted/NATIVE_COMPILATION.md).

Selected and installed: **compiler14**, checked B1 `7f05ac96…`, genuine B2/B3
`0444d283…`. [Qualification and installation](qualification.json) pass; the prior
release’s seven files are preserved.
**Compilation parity was not reached.** The final interleaved 45-request comparison
reduces B1 compilation time 18.09% and B2 time 17.78%. All twelve benchmark C files
and executables reproduce the Phase73 artifacts exactly. The faster prototype
that changed generated-program speed was rejected.

## Compilation results

These are **fresh JS-hosted checked Bend-to-C requests**, not a compiler built
as a C executable, Clang time, or generated-program execution. Imports/API load,
explicit prepared Bend Base, Clang and execution are outside the request clock.
Upstream checks Base within its ordinary request. Backend products are disabled.
The unchanged reference is 059266225b77c8ca256ac6b25ee5c21449bab151.

| Source | Previous B1 | Selected B1 | Previous B2 | Selected B2 | TypeScript |
|---|---:|---:|---:|---:|---:|
| Numeric |2489ms|2026ms|1669ms|1378ms|708ms|
| Array |2554ms|2100ms|1691ms|1364ms|714ms|
| Lexer |3221ms|2644ms|2049ms|1711ms|899ms|
| Geometric request ratio |3.55981×|**2.91581×**|2.33580×|**1.92053×**|1×|

Three rotated/reversed rounds interleave old/new B1/B2 and upstream, one CPU 3
process tree. Each request must produce its complete independently executed C
oracle. Three repetitions provide finite screening precision, not a confidence
interval or coverage of all programs. The older Phase73 headline ratios came
from another run; the improvements above use the interleaved baseline.

Parity still requires about 48% less selected B2 request time and 66% less B1 time.
The selected images have no warm-service, persistent-result-cache or relabeled
B2-as-B1 speed claim.

## What changed

The checked host transports a single Bend-owned `NR_Request`: original source
context, ordered runtime closure, erased ordinary bodies, runtime arities, foreign
paths and scope. It shares the existing indexed context across frontend/backend
boundaries. Foreign bodies still use their actual fresh-ID-dependent construction.
Source ownership and binder-range checks remain independent of generated facts.

Worker planning reuses successful work. Only an otherwise eligible ordinary
worker that references a withdrawn product signature needs a retry. Generic
scheduler bodies and the existing device path remain in the selected compiler.

One trust traversal returns the verdict and ordered unsafe names. A completed
safe dependency closure can be reused by subsequent roots; an unsafe traversal
cannot publish its partially visited set as safe. The older public algorithms
remain differential oracles.

A request-local constructor index retains the exact first depth-first constructor
winner, including nested cache children and duplicate names. A separate compact
U32 Patricia set replaces definition dictionaries for variable occurrence facts.
It avoids string keys, collision buckets and allocations on repeated insertions.
Full-width IDs, malformed Var-as-leaf behavior and liveness/drop ordering stay
unchanged. These are compiler implementation changes in Bend; the C runtime and
JavaScript backend are unchanged.

## The rejected larger gain

Candidate08 reached 2.321× B1 and 1.683× B2 upstream in its own interleaved 45-request
run: 35.6%/26.7% less time. It selected host workers before lowering and omitted
their unused generic scheduler bodies. C output became roughly 40% smaller on
the initial screen while optimized worker text stayed identical.

The broader candidate09 runtime gate nevertheless measured tree 311ms vs 297ms
and Array.map 478ms vs 456ms. All 273 common tree functions retained their sizes but
changed address offsets. That implicates native code layout; it does **not** prove
the complete cause. Function alignment recovered tree, but did not recover
Array.map. Minimum bank width, hot/outline alignment and branch-boundary variants
failed to recover both; forced block alignment made tree slower. A macro-wide
alignment attempt failed to compile after also aligning a function-pointer type.
No runtime attribute or Clang flag from these experiments was adopted.

The selected compiler removes the body-omission implementation. Its twelve C
files **and machine-code executables are byte-identical** to Phase73, and fresh
checksum executions pass. Repeating long performance samples on identical
executables would add noise rather than validate a changed program. The prior
Phase73 twelve-family execution result, 1.05060× upstream, therefore describes
the same artifacts; this phase does not claim a new runtime speedup.

Candidate16 tested 32-ID bitmap leaves. It passed 199,400 set controls and the
checked/B2 fast gates, but did not improve the timing screen over the simpler
set. It was rejected. All candidates, controls, profiles, layout probes and
unexecuted prepared plans remain retained; a prepared plan is not passing evidence.

## Correctness and self-hosting

The [qualification record](qualification.json) closes checked 36, genuine B2
driver 8, 45 exact-C timing requests, twelve fresh C/executable identities, twelve
exact B2 C outputs, native100, raw 31 and additional 14 fixtures. The latter include
a small choice and a user-dominated 64-function chain beyond the timing harness.
Twenty-eight executions at 1/4 threads and six sharing-shape certificates pass.

The generated closure of 2,992 non-native functions and all prior public wrappers
remains exact. Trust graphs 166, constructor comparisons 1,066 and U32 occurrence
controls 199,400 pass for the selected image. B2 accepts its own source with the
expected unsafe proof-trust refusal, and emits byte-identical B3. Installed
legacy 42/default 24/helper 5 and verification before/after pass. The selected
source exactly matches its frozen checked snapshot.

Finite conformance limits remain explicit: the reference has seven known native
failures, and the broader thirteen native API gaps are not claimed closed. This
is not a full GPU or native-executable-compiler qualification. These finite checks are separate from timing and do not constitute a formal
proof of the compiler.

## Simplicity, costs and remaining work

Maintained Bend manifest modules grow 129→131; physical lines 31,730→31,984
(+254, 0.80%); nonblank/noncomment lines 25,939→26,140 (+201). Request state and
variable-use sets get explicit types; the rejected omission path is removed.
This is not a source-size reduction claim.

Fast checked B1 builds take about 32–34s. Genuine B2 generation and driver checks
are separate, roughly 110–120s. The three-source clean request loop is tens of
seconds after preparation; saved-C layout probes are roughly 30s. Broad gates
are reserved for selected candidates. One guarded target tree, 2 GiB RSS and 4 GiB
available-memory floor avoided OOMs. No subagents, upstream-source edits or PR
comments were used. Quota consumption is not inferred from wall time.

Not all attempts were useful. Compiler01 failed an affine capture check;
compiler03 omitted a new bootstrap export; compiler12 was an accidental duplicate
build after a manifest-path assertion; compiler15 used the wrong shift-operation
arity. The first final09 controller mistakenly required all reference cases to
pass instead of retaining its known failures. The first final14 Python controller
had a syntax error before running targets. Original failures and corrected runs
remain separate.

The current bottleneck is distributed across frontend work, repeated native
lowering/analysis, text rendering and allocation. A new numeric B2 profile still
samples substantial occurrence traversal and GC after compact sets; instrumented
clocks are not clean timing measurements. More small caches cannot establish a
credible guaranteed 1× result. The larger remaining directions are reusable
standard-library backend products with precise dependency/static-image/temporary-ID
relocation, or a typed native intermediate representation that retains per-node
analysis and shares it between generic and optimized lowering. Both need an
output-equivalence fast prototype before a broad rewrite. Body omission remains
an experimental lead only after its runtime regression is understood.

## Evidence

Raw selected evidence lives under `selfhost/build/phase75/`: `paired14-compilation`,
`compiler14-program-identity12.json`, `compiler14-C-identity12`, `compiler14-native100`,
`compiler14-raw31`, `compiler14-new14`, `compiler14-b2` and subsequent qualification
receipts. The [content-addressed evidence capsule](../../selfhost/tools/performance/phase75/evidence01/README.md)
preserves all stages of this experiment, including failures, while sharing identical
source snapshots and compiler-image contents. Historical baselines, upstream and toolchains
remain explicit external dependencies.

The capsule contains 21,413 files, 1,024,377,119 uncompressed bytes, 5,297 unique
objects and 94,377,103 compressed bytes in three pieces. Every original/archive
content and mode is verified; a full fresh restoration is checked and its
redundant temporary copy removed. Phase75 target writers are closed after sealing.
