# Reuse substitution-invariant constructor telescopes

The final checked Bend candidate compiles the unchanged 312-declaration compiler
core in 42.908 s versus 53.545 s under the original self-hosted compiler: a 1.248×
speedup, or 19.9% less time, across three alternating fresh-process pairs. Every
output byte matches. Focused dependent-type, diagnostic and native gates pass.
This is a real compiler-component result; it does not establish a full-compiler
speedup or a new self-hosting fixed point.

[Evidence manifest](analysis-evidence/telescope-manifest.json) links compressed
reports with exact report hashes. Inputs, candidate modules, configuration files,
failed attempts and consumed tool versions are retained. Raw artifacts are under
`selfhost/build/phase4/analysis-*`.

## Real-source attribution

The workload is the unchanged compiler's actual `core/{term,index,normalize,graph}`
modules, assembled as a checked library: 60,909 bytes and 312 declarations. It
is not a synthetic wide-telescope benchmark. Frozen B1 and H identities are the
same ones recorded in [the normalization investigation](analysis-normalization.md).

Disposable counters preserve the exact emitted library bytes and are used only
for attribution, not timings. On that source, checking enters substitution
1,840,431 times and annotation 1,828,499 times. The first conservative predicate
requires no `Var` or `App` anywhere in a term. Constructor telescope tails account
for 496,383 eligible visited nodes during checking and 495,165 during annotation.
By comparison, eligible lambda and application-spine tails account for only
about 15,000 nodes during annotation. Datatype-parameter `tele_fill` roots have
no eligible complete tails in this workload.

That first predicate produces essentially no complete-pipeline improvement:
three warmed B1 core-compilation pairs have medians 20.356 s control and
20.582 s candidate. Ordinary monomorphic types such as `List<&2, KTerm>` contain
neutral application nodes, making the no-`App` condition too restrictive.

A stronger exact predicate permits canonical applications that substitution
cannot change. It identifies 1,530,015 constructor-telescope nodes in checking
and 1,528,797 in annotation, roughly 83% of the entered substitution visits in
each phase. These percentages describe visits, not avoidable phase time; scans,
fallbacks, checking, allocation and other analysis remain necessary.

Final-candidate counters verify that the source change actually removes
1,528,797 substitution entries in each phase: checking falls from 1,840,431 to
311,634 and annotation from 1,828,499 to 299,702. The replacement is not free:
checking performs 1,040,010 fact-term visits and 2,047,275 fact-list visits;
annotation performs 1,038,186 and 2,046,059 respectively. The cheaper read-only
scan avoids repeated rebuilding and allocation. These separately instrumented
runs produce the same 138,371-byte library, SHA
`016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186`.
[The count comparison](analysis-evidence/analysis-stable-count-comparison.json)
records the original report identities; its times are not performance evidence.

## Why the stronger fact is safe

For a finite immutable `KTerm` graph with the declared field types, the predicate
establishes structural identity under substitution for every binder/replacement:

1. A `Var` is never marked invariant.
2. Every child must itself be invariant.
3. For an `App`, require exactly two children, empty name, zero ID/quantity,
   empty removed-constructor metadata, and a function child whose tag is not
   `Lam`. Then the original `core_rebuild`/`core_apply` produces exactly the same
   canonical application. The metadata checks matter: rebuilding otherwise
   canonicalizes those fields even without beta reduction.
4. Other tags keep all metadata and their invariant children unchanged.

This includes arbitrary unknown tag text; it does not assume only known compiler
tags exist. It deliberately excludes beta applications, variables with payloads,
and malformed application arities/metadata. An absent variable alone is not
sufficient, as the earlier [Phase 3 experiment](../phase3/emission-analysis.md)
demonstrated.

The source change reuses this fact across the literal `All` suffix of a
constructor's argument telescope. It skips repeated substitution/rebuilding and
weak-head evaluation only while the same proven suffix remains an `All`.
A `Ref`, `Ann`, neutral application or any other head returns to ordinary
normalization and recomputes the fact about the newly exposed type. No fact is
cached across books, changed contexts, rewritten terms or requests.

The annotation fallback retains ordinary `ka_args`. Checking retains a documented
copy of the original remaining telescope traversal so a failed fact does not
rescan every dependent suffix. Both routes preserve argument order, use
accounting, error combination and the terminal telescope type. Results may share
more immutable structure; object identity is not used as a semantic oracle.

## Demand order and the supported input boundary

Review found two avoidable evaluation-order differences in the second candidate.
The final candidate evaluates the first `check`/`annotate` result exactly once
before scanning the tail, then passes that result to a continuation. Its fact
scan follows substitution's order: test `Var`, scan children, then inspect the
`App` rebuild. A false fact uses ordinary substitution.

An actual H audit confirmed three first-exception differences in compound
null-tag/malformed-UTF-16 probes, and confirmed that the ordered candidate fixes
all three. All 35 probes respecting `KTerm` field shapes, including malformed
UTF-16 tag/metadata text, agree with original H.

One intentionally ill-typed raw JavaScript graph still differs: `App.name = null`
violates the declared `String` field type. Original substitution discards that
metadata while canonicalizing the application; the predicate's String operation
rejects it. This remains an explicit unsupported raw-ABI boundary, not a passing
compatibility case. No JavaScript-specific `typeof` guard is introduced into
the Bend compiler.

## Validation and measured scope

The final overlay changes only `core/term.bend`, `check/kernel.bend` and
`check/annotate.bend`. The checked build validates all compiler source modules,
ownership and absence of holes. Its requested export roots are also verified to
exist. B1 API SHA is
`878ae06f76e4c48e18a9ac67bc54b9d4b2caf040885c2f49d59a6c1f1b2819b5`.

A separately assembled 14-module core/check/diagnostic component is fully checked
and emitted by frozen B1. Seventeen actual Bend-emitted workers replace only
the corresponding workers in frozen H, with constructor ABI and dependency
checks. Final H capsule SHA is
`bbc93d4f403f0e2c448fbdbe16376bdd85ff7bc0743c350a71795afa30554a91`.
This capsule is an isolated implementation experiment, not a whole-compiler
bootstrap fixed point.

Both final B1 and H pass 565 exact assertions covering dependent type arguments,
`Ref`/`Ann` invalidation, beta fallback, too many arguments, first/later type
errors, affine use accounting, residual metadata, unknown tags and generated
substitution-identity cases. Separate standard gates pass 31 normalization,
43 kernel and six specialization tests, plus 77 direct normalization controls.
Five pinned source checks also match the original H's complete observations:
dependent telescope and dependent-pair acceptance, and exact diagnostics/phase
for erased-field conversion, constructor-field typing and constructor arity.
These selected tests do not establish full conformance.

The final H capsule also emits exactly the original H's C for three selected
programs. Actual Clang 16 builds execute the tree program as `42`, an erased
polymorphic call as `Yes{}`, and the pinned dependent-pair/destructuring fixture
as `3`. The last case carries an erased equality proof through dependent
constructor fields. Build reports retain C, toolchain, preprocessed-header,
binary, runtime and host identities. These are selected native gates, not a full
native conformance claim.

The earlier second-candidate measurements, before the demand-order cleanup, are:

| Same compiler-core source | Control median | Candidate median |
| --- | ---: | ---: |
| B1, warmed process, three alternating measured pairs | 20.909 s | 18.089 s |
| B1 checker phase | 7.464 s | 6.302 s |
| B1 annotation phase | 6.487 s | 4.951 s |
| H, three alternating fresh-process pairs | 54.314 s | 43.230 s |

The final ordered candidate preserves the gain in a fresh, separate series:

| Final candidate, same compiler-core source | Control median | Candidate median |
| --- | ---: | ---: |
| H compile interval, three alternating fresh-process pairs | 53.545 s | 42.908 s |
| H process wall time | 53.813 s | 43.182 s |
| H checker phase | 20.310 s | 15.919 s |
| H annotation phase | 17.447 s | 11.425 s |
| H layout phase | 2.228 s | 2.163 s |

All measurements use physical CPU 2, Node v24.18.0, a 4 MiB stack and a 3 GiB
heap on the shared host. H Base caches were separately prepared and validated
before the timing workers. Each worker compiles the same absolute source in
library mode and consumes all output bytes with SHA-256; the complete bytes
must match. Library execution is not claimed. In the final-candidate H series,
maximum RSS is 572.57–575.61 MiB control versus 463.52–466.19 MiB candidate.
Other physical cores were active; CPU affinity does not remove shared-host
memory or scheduling effects. No final-candidate B1 timing or whole-compiler
ratio is inferred from these H samples.
Small B1 program samples had sizeable control excursions and are retained
without presenting their ratios as general benefits.

## Retained failures and reproduction

The first neutral-application source used a disallowed nested parameter match;
the pinned checker rejected it. The corrected source uses ordinary helper
functions. A later preparation script had an `index`/`indexOf` typo. Its shell
continued to build an empty overlay, producing a checked baseline-only artifact.
That artifact is explicitly marked invalid for the intended candidate and was
never used for an experiment. The builder now rejects empty supplied overlays
and missing export roots. The corrected candidate was rebuilt under the new
guard and produced exactly the same API as its valid earlier checked build.

The reproducible tools are under `selfhost/tools/performance/phase4/`:
`analysis-facts.mjs` and `analysis-neutral-facts.mjs` attribute real substitutions;
the telescope/neutral/stable overlay tools preserve successive source variants;
`analysis-stable-test.mjs` and `analysis-stable-h-test.mjs` run focused gates;
`analysis-order-audit.mjs` records partial-value outcomes;
`analysis-component-capsule.mjs` produces checked H capsules;
`analysis-native-gate.mjs` checks C and execution;
`analysis-source-gate.mjs` compares source verdicts and exact diagnostics;
`analysis-stable-counts.mjs` measures actual substituted/fact-scanned visits;
and `analysis-fresh.mjs`
performs bounded fresh-process comparisons. Use the archived configurations,
recorded Node executable and fresh output directories. Pin parent processes to
CPU 2 except the fresh-worker coordinator, which pins each child itself.
