# Phase55: finish direct compiler-image generation

The user requests profiling and optimization of the full direct compiler-image
timeout. Start from installed Phase54 graph02 at commit6433689, API
`d7d0396cda189918299ddeb0105e9d682f6a22bffa70004ab6d0ebeac20f4857`.
Keep the upstream pin, 103 unrelated files and all closed evidence unchanged.
No PR comments. Commit and push source, qualification and results.

## Hypotheses and first experiment

The preserved 240-second full77 attempt did not finish. A profiled90-second run
spent55.9seconds in emitted reachability before final library emission. Its
sampled profile attributed26.5% of ticks to j_find_ctor and11.2% to missing;
80.3% of j_find_ctor samples were under jd_raise_head. This supports a lookup
hypothesis, not a promised speedup or complete attribution of the final timeout.

First inspect the checked-core contract. Annotated matchers already carry the
expected argument datatype, but jd_raise strips their annotations and globally
searches every owner for each constructor. Prefer an annotation-aware lookup
through the existing j_layout_ctor helper if the checker establishes constructor
uniqueness and the annotator preserves the local expected type. Retain the old
unannotated/unknown-type path. Common j_find_ctor stays unchanged. This narrows
work under the checked-annotated emission contract; it must not weaken checking
or assume arbitrary forged private Ann records are checked programs.

Independent review must challenge aliases, refinement, normalization, erasure,
nested annotation/lambdas, shadowing and duplicate-constructor rejection. If a
valid checked counterexample exists, reject this path and test an immutable
constructor index with precise first-owner/Absent/cache semantics. Do not add an
index only to preserve undefined behavior of malformed private input.

## Controlled profile and iteration

Keep the compiled subject fixed to Phase54's exact assembled source and77 API
roots while varying the checked generator. Separate subject and generator
identities. Add a diagnostic-only export bridge to a copy of the checked API and
split the final library call into its existing selected-context, call-analysis,
validity, definitions and exports stages. Pin the original core implementation,
retain its invalid-analysis branch, and prove split versus unsplit exact output
on a restricted image before using the decomposition for attribution.

Use durable phase progress and counts, not large dumped term books. Reuse the
preserved constructor profile first; if another stage dominates, profile that
stage with bounded sampling. Avoid repeating the106MB/full-tick processor that
exceeded its512MiB heap. Every candidate is a fresh checked B1 with the strict36
frontend witnesses before full emission. Do not hand-rewrite emitted JS as the
installed optimization or raise the timeout to call an unchanged compiler fixed.

Targets are serialized on CPU3,1GiB Node heap,2GiB process-tree RSS and4GiB
available-memory floor. First diagnostic bound120seconds; decisive full-image
bound remains240seconds. Competing analysis/review and data-only preparation can
run in parallel; root transfers target ownership explicitly. Retain every
failure and consumed method; retry corrected tools into new output directories.

## Completion and correctness

The first win is full77 generation within the existing bound. Require actual
ES-module import, exact requested API/ABI, shared named-field data transport and
the unchanged ordinary driver's parse/check/error/JS/C/repeated-request probes.
A generated file alone is not a usable compiler. Then emit the final candidate's
own compiler source and test the resulting image, distinct from the fixed-subject
comparison. Fresh compiler-source checking, self-emission and a fixed point are
separate expensive gates; attempt them only after the resulting compiler runs.

A changed compiler must retain source96, numeric34, composition18,
overapplication2, direct census26, maintained legacy8 and representative native
behavior. Compare all45 benchmark point modules with Phase54. If full modules
are exact, retain dated Phase53 timing for those bytes and skip redundant669
runtime samples. A mismatch requires explanation and its own semantic/performance
qualification; do not normalize it away.

Before promotion, install only a qualified checked image and run the existing
42 legacy/24 default interface, relocation and integrity controls. Preserve the
prior release. Do not replace legacy compiler-image clients/private transforms
until their actual route is qualified. Report compiler generation speed, generated
compiler execution, user-program output and bootstrap/fixed-point status
separately. Record source size and total elapsed/recorded process time. Publish
compact evidence plus one closed raw archive.
