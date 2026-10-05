# Phase52: direct JavaScript backend

The one-hour prototype demonstrated the architectural opportunity. We then built
an explicit direct backend in Bend, added program/IO/FFI support and independent
semantic controls, and selected checked candidate **direct06**. The full benchmark has completed successfully. Direct06 is installed; release integrity verification, **42 legacy CLI checks,
18 direct CLI checks**, and the final **3-case/27-sample portable replay pass**.

[Design](../../design/phase52/direct-javascript.md) ·
[User guide](../../selfhost/docs/direct-javascript.md) ·
[Prototype report](prototype.md) · [Contract](parity-contract.md) ·
[Independent review](review.md) · [Conformance](conformance.md) ·
[Source accounting](accounting.md) · [Remaining work](remaining-work.md).

## What changed

The direct backend lowers the existing checked, annotated terms to lexical
JavaScript functions, native closures and native data layouts. It has no mutable
`G` table or `code/env/bound` call transport. Known acyclic calls are ordinary
calls; self and mutual tail recursion use loops; generic higher-order tail calls
retain the necessary trampoline. Demand-sensitive views avoid conversions and
bindings whose values are unused.

This is a change in the exposed JavaScript contract, not a transparent deletion
of the legacy interface's checks. Use `--direct-js` to select it. The existing
backend remains the default compatibility mode. Ordinary compilation still runs
the compiler written in Bend; it does not invoke TypeScript as a fallback.

The complete candidate includes:

- Native callable library exports, partial application, erased arguments and
  arity raising across pattern matches.
- Native constructor layouts and numeric pattern rows, deferred Nat errors,
  and checked native-operation admission based on declaration identity/type.
- Self/mutual tail loops with simultaneous parameter updates and fresh lexical
  bindings for captured values.
- Program output, IO scheduling and foreign JavaScript modules. The 37 pinned
  Base effect providers are included for standalone installation and relocation.
- Dependency discovery from emitted code, so dead/erased foreign initializers
  are not imported. Unsupported forms or exhausted analysis bounds refuse
  explicitly rather than silently selecting another backend.

The backend adds nine Bend modules; their roles are documented in the user guide.
The original 92 compiler modules are unchanged.

## Evidence and performance decisions

The prototype's eight-point screen completed all 72 fresh timing samples and
all output checks. Direct03 measured **1.03522× TypeScript execution time** versus
same-run Phase51 **5.23997×**, a **5.06169× speedup**. The eight ratios span
0.87772–1.12016×. This proved value within the first hour; it was not a universal
or full-corpus parity result.

The first broad direct05 campaign passed all 45 benchmark outputs. Two batches
then measured 30 points and 444 samples. They exposed residual numeric costs:
Mandelbrot around 1.62–1.96× TS, ray tracing around 2.02–2.20×, and edit distance
around 1.41–1.46×. We stopped before its third batch to test the general cause.
The partial campaign remains intact and supplies no missing rows for the final
selected image.

[Atomic intrinsic expansion](../../experiments/phase52/P52-002-atomic-intrinsics.md)
removed wrappers when the operands were exact inert emitter-owned forms. The
fresh eight-point comparison improved **1.30162× → 1.21165× TS**, a **1.07426×
speedup**. Five distinct sources improve more than 5%; ray tracing improves
31.6%; expression evaluation regresses 3.9%. Exact byte reconstruction attributes
all changed modules to 375 primitive expansions and 52 removed wrappers.

Its prewritten 1.10× average-gain target was **not met**. The selection decision
is separate: we retained this small change for its measured broad benefit,
absence of a greater-than-10% point regression, exact code attribution and no
new semantic failure. The failed threshold has not been relabeled a pass.

[Computed-operand expansion](../../experiments/phase52/P52-003-ordered-intrinsics.md)
then tested local parameter functions to preserve evaluation order while
expanding the remaining primitive calls. Candidate07 passed its output checks
but was **25.75% slower** on the same eight-point screen; Mandelbrot regressed
3.568×. We rejected it, restored exact direct06 source, and avoided another
semantic/full-corpus campaign on the loser. The generated code and failed
performance evidence remain available. This experiment establishes the poor
performance of that lowering here, not a specific V8 mechanism.

The final comparison uses one frozen direct06 image, unchanged Phase51 and
pinned TypeScript modules, all **45 points from 23 sources**, complete output
oracles and **669 fresh rotated samples**. All pass. No prototype or direct05
timing rows are substituted. [All results](results.md) and the [all-point chart](ratios.svg)
retain every point.

| Weighting | Phase51 / TS | Direct06 / TS | Speedup over Phase51 |
| --- | ---: | ---: | ---: |
| Equal benchmark point | 2.630605× | **1.123799×** | **2.340815×** |
| Equal source program | 3.582113× | **1.129112×** | **3.172504×** |

The measured average gap is now 12.4%, with 29/45 points within 10% of TypeScript,
35/45 within 20%, and nine faster. The range is 0.867× for Morning to 1.994× for a
Mandelbrot variation. This is substantial progress toward parity on a corpus
that informed development, not universal parity or an untouched holdout. The
historical Phase51 2.928× result is not this campaign's denominator.

Seven points regress against Phase51. Five exceed 10%: two edit-distance points,
the large local fold, closures256 and list512. The last two regress 2.217× and
1.781×, respectively, yet remain only 1.038× and 1.020× TS: Phase51 already had
faster specialized paths there. Direct mode is therefore a broadly faster
alternative, not a per-program dominance claim. Three points have descriptive
round-spread/half-drift flags; none was removed. Absence of a flag does not prove
JIT convergence or statistical significance.

The 23 distinct whole modules, including runtime and observers, total 1,053,920
bytes for direct06 versus 4,194,685 for Phase51 and 543,407 for TypeScript. This
is roughly 75% less emitted JavaScript than Phase51, not 75% less compiler source
or an instruction/allocation count. Compilation is excluded from these execution
timings; import and first-call observations are recorded separately.

## Correctness and compatibility

Selected direct06 currently has these distinct qualifications:

| Gate | Result and scope |
| --- | --- |
| Checked build | Equality-derived B1, 36 strict frontend witnesses; not a new self-emitted fixed point |
| Independent direct semantics | 29 fixtures check; **95/96** runtime scenarios pass |
| Maintained JS census | **26/26 agreement**: 18 runtime passes, four expected compilation rejections, four N/A |
| Maintained compatibility suites | **8/8 pass**, including IR, backend, initializers, cases, primitive/provenance/foreign controls |
| Final benchmark outputs/timing | **45/45 outputs and 669/669 samples pass** |
| Legacy core screen | Eight outputs match Phase51 exactly; separate deeper gate passes **8/8 cases and 120 samples**; failed20s attempt retained |
| Installed/relocated interface | **42 legacy + 18 direct checks pass**, including copied-runtime tamper rejection/restoration |
| Portable replay | **3/3 cases, 27/27 samples pass**; all135 archived module mappings also verified |

The semantic failure is unwaived: `f32_table_nan_bits.bend` expects **40**,
pinned TypeScript JavaScript returns **1**, and direct06 returns **39**. Both
fail the source oracle and also differ from each other. Exact NaN-payload
transport requires more work; no passing full-conformance claim follows from
the other 95 controls.

Arbitrary post-import host-hook identity is also outside the promised contract:
upstream can replace numeric matches with tables using `Math.min`, while direct
currently emits comparisons. The backend has explicit analysis limits, including
512 selected definitions for call analysis. Exhaustion refuses compilation; it
is not a fallback or proof that arbitrary large compiler programs are supported.
Compiler throughput and a direct-backend self-hosted fixed point were not measured.

## Identity, size and repeatability

Selected API:
`472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a`.
Compiler source:
`3c5671579628de5c113907403188df17e3d35a15dd520bc1d20b6dc3263d3513`.
Direct runtime:
`417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a`.
Upstream remains pinned to `018751270e800bc222a93dad7f257083ee53a5f7`.

The compiler now has **25,790 physical / 21,235 code Bend lines, 2,957 definitions,
95 types and 101 modules**. The new backend contributes 2,128 physical / 1,746
code lines. Retaining compatibility increases total physical source by 9.0%;
this phase does not claim a total line-count reduction. Runtime, host tooling,
experiments and generated artifacts are counted separately in the accounting.

A checked build takes about 59 seconds at a 1 GiB Node heap and peaks below
1.5 GB process-tree RSS. The latest narrow iteration used roughly 59 seconds
for the build, 45 seconds for eight source emissions and 59 seconds for timing.
That is about three minutes of serialized target work, separate from analysis,
implementation and review. Full45 is reserved for integration and takes about
22 minutes including acquisition. [Time accounting](timing-accounting.md) records
measured work separately from elapsed time and planning estimates.

[Benchmark recipes](../../selfhost/tools/performance/phase52/README.md),
[full campaign](../../selfhost/tools/performance/phase52/full-plan.md), and
[release qualification](../../selfhost/tools/performance/phase52/release-qualification.md)
pin the method and fresh output paths. Heavy jobs run serially on CPU3 with a
2 GiB process-tree ceiling and 4 GiB available-memory floor. Source analysis,
independent review and documentation use parallel agents. Failed builds,
permission refusals, incorrect early harness attempts and rejected candidates
are retained rather than overwritten. No PR comment was posted.


## Installed release and evidence

From `selfhost/`:

```sh
npm run verify:release
node cli.mjs FILE.bend --direct-js --run
node cli.mjs FILE.bend --library --direct-js -o module.mjs
```

The [release manifest](../../selfhost/dist/release.json) binds the checked API,
source graph, direct runtime and vendored effects. The successful interface gate
covers both the ordinary installation and a relocated copy without the upstream
checkout. It also rejects a modified copied runtime, restores it and verifies
again. The initial sandbox Clang/Node failures and test-controller directory
collision remain failed receipts; the path-only controller repair did not change
the compiler or any assertion.

[Generated-code examples](generated-code/README.md) preserve exact Bend, direct
JavaScript and TypeScript output for RLE, lexer and expression interpretation.
The [portable bundles](../../selfhost/tools/performance/phase52/bundles/) contain
all45 points with relative module paths. [Compact evidence](../../selfhost/tools/performance/phase52/evidence/final/index.json)
and the [complete raw archive](../../selfhost/tools/performance/phase52/artifacts/raw/archive.json)
preserve failures, compiler images, snapshots, commands and measurements with
verified hashes. The separate [selected qualification receipt](../../selfhost/tools/performance/phase52/evidence/final/raw/selected-qualification06.json)
keeps release/performance passes distinct from the unwaived95/96 semantic result.
The [publication receipt](../../selfhost/tools/performance/phase52/publication.json)
joins the verified artifacts. All eight agents completed; the prototype proved
value within one hour, and implementation, selected benchmarks and release
checks completed in 173.9 minutes. Final archival and commit/push work followed
that accounting cutoff.
