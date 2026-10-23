# Borrowed native queries and reusable preparation

Phase128 targets the cost of running the Bend compiler's own QBE-generated
executable. It combines ownership-aware generated code with less repeated
compiler work. See the [results](../../implementation/phase128/README.md),
[design](../../design/phase128/README.md),
[research](../../research/compilers_architecture_and_techniques/phase128-fast-compilers.md)
and [reproduction tools](../../selfhost/tools/performance/phase128/native/MEASURE.md).
The candidate and installed compiler are separate selections; consult the
report's exact qualification status before choosing an image.

## How it works

A read-only query such as string equality should not repeatedly take, retain
and release every character when the caller keeps the complete string alive.
The compiler now recognizes a larger set of checked scalar-result observers.
An adapter holds the owning roots, checks the supported sharing conditions,
and calls a private borrowed reader. Unique, ambiguous or unsupported cases
keep the original owning implementation. Aliased roots receive conservative
treatment; the result must have a proven nonowning scalar type.

Verified readers can call other verified readers. Concrete finite layout facts
allow a cursor into a nested structure, such as a list of strings, to remain
borrowed across a string comparison. Nominal type names alone do not establish
layout identity: incompatible generic instantiations are refused. Effects,
escaping results, unsupported recursion and unknown calls retain the fallback.

An earlier inliner can hide this optimization by replacing a public wrapper
with its underlying recursive worker. A bounded source-derived rule recovers
the wrapper only when its call/result equation, constants and parameter
permutation match exactly. Rules become available after the original definition;
generated adapters, readers and owning fallbacks are not rewritten. This keeps
call dependencies and fallback termination intact.

Finally, an already-verified borrowed-field import can use a late QBE template.
The template checks tag and constructor identity, decodes the exact RFC layout,
loads fixed fields and preserves the original scratch/result interface. It
retains the helper fallback before dereference. This is a pinned sequential
CPU ABI capability, with an independent 545-check fixture; it grants no new
general raw-pointer, concurrent or device permission.

## Compiler work eliminated

Initial and late candidate closure share one immutable raw candidate list.
Candidates rejected early remain available later; SCC rewriting still occurs
at its original use. This avoids repeating request preparation and boxed/flat
candidate construction without weakening final verification.

The observer pass collects workers, helper summaries and retry candidates in
one scan. Reachability filtering constructs the existing exact-name index once,
preserving definition order and duplicates. These changes use request-local
state; they do not introduce a cross-request cache or a new invalidation system.

## Running and extending the experiments

`selfhost/tools/performance/phase128/` contains the checked Bend modules, finite
predicates, independent fixtures, declaration composition and measurement
bindings. All analysis, optimization and QBE generation remain in Bend. Host
tools compose exact source declarations, authenticate artifacts and invoke the
compiler/toolchain.

Use the [native measurement guide](../../selfhost/tools/performance/phase128/native/MEASURE.md)
for actual N1/N2 request timings and generated-program comparisons. The ordinary
45-program correctness suite and historical 45 benchmark wrappers are different
sources: only the wrappers produce the historical 44-point runtime score.

For a new optimization, first use the unchanged compiler-name proxy and the
sharing/alias/Unicode and renamed numeric-spine controls. Confirm that the hot
caller actually reaches the new reader; admission alone proved insufficient in
this phase. Compare clean paired execution, and use the [profiler](PROFILING.md)
for attribution. Whole-function instruction or call-site counts include
fallbacks and cannot establish dynamic work or speed.

Full native acquisition is warranted after a useful bounded result. Keep source,
runtime, checked API, compiler image, Base/carrier and independent outputs pinned.
The documented process-tree guards enforce one serial CPU 3 target lane and
memory/disk limits. Preserve existing qualified images and rejected attempts.
