# Phase100: useful applications before another bootstrap speed target

## Purpose

The user asks us to turn the self-hosted compiler into a useful toolchain and
learn from applications. Reducing one full self-compilation from 105 seconds
to 45 seconds is no longer the primary milestone. The latest 105-second image
is experimental; the installed, qualified Phase98 native B1/B2 release remains
the starting point. Its generated-program performance and its own compilation
latency are separate questions.

Success in this phase means three runnable, documented applications, independent
output checks, reproducible build/runtime measurements, and a concrete account
of what prevents useful native and parallel execution. It does not mean a new
compiler release, a claim of whole-language coverage, or a universal speed ratio.

## Workloads and selection

Choose applications by different user tasks and data behavior, before observing
speed results:

1. **Source index:** read an actual source file and print a deterministic lexical
   inventory. Exercises text input, scanning, allocation, identifiers and output.
   Its documented lexical scope must not pretend to be a complete Bend parser.
2. **Image renderer:** accept image parameters and produce a complete portable
   image. Exercises numeric computation, output construction and independent
   subdivisions suitable for parallel execution.
3. **Dependency planner:** read a dependency graph and produce a usable plan or
   an explicit invalid-input result. Exercises irregular traversal, shared
   dependencies, ordering and graph validity.

Use ordinary Bend source and runtime inputs. Keep each source independently
usable outside the timing runner. Work within the public native launcher's
documented import/provider boundary; report limitations rather than bypass it.
Include small edge controls and larger deterministic inputs, including real
repository source where appropriate. Synthetic graph generation supplies known
structures, not evidence of industry-scale build-system performance.

Each application gets a Python-standard-library reference implementation or
validator. Compare the complete semantic output, not only a checksum. Reference
execution is outside the program timing interval. Retain malformed-input and
parallel output checks. Executable contracts are not universal formal proofs.

## Experiment sequence

### 1. Establish usable behavior

Freeze the installed release, upstream pin, toolchain and app sources. Compile
the same apps with native B1, native B2 and pinned upstream TypeScript/Bun. Check
complete B1/B2 C agreement, build generated programs with identical Clang flags,
then execute small independent-output controls. Retain failures and fix the app
or harness only with an explicit new run. Do not change a compiler merely to make
an application benchmark faster.

### 2. Measure the complete experience

Record these separately:

- compiler request and compiler-process wall time for B1, B2 and upstream;
- Clang build time, resulting C/executable size and peak build RSS;
- executable process wall time, CPU time, peak RSS, output size and correctness;
- one-, two- and four-worker execution on explicitly recorded CPU affinity,
  where the application's parallel structure and available hardware permit it;
- maintained application source size and concrete missing toolchain capabilities.

Application runtime includes startup, file input and complete output production.
This is intentionally different from Phase93's warm fixed-input kernel batches.
Do not combine the two aggregates. Keep tiny processes as latency observations;
do not claim precise speedups below a useful duration. Use balanced repeated
orders for comparisons and report ranges. Parallel speedup requires identical
outputs and sufficiently substantial useful work, not just a worker flag.

### 3. Diagnose the limiting behavior

Use input-size scaling, generated-code inspection and serial/parallel comparisons
to identify whether useful work is limited by algorithm, representation, I/O,
runtime scheduling or code generation. Profile a representative application only
if the measurements pose a question that profiling can answer. Preserve generic
backend opportunities and distinguish them from app-level algorithm problems.

Select the next engineering objective from these findings. The prior 45-point
suite remains a regression tool; self-compilation remains a scaling workload.
Neither substitutes for application usefulness or parallel correctness.

## Efficient execution and correctness boundaries

Three collaborators prepare applications and independent references in separate
directories. The root owns integration and all compiler/native targets, serially
under the existing guard. Offline preparation may overlap target execution.
Reuse installed compiler images; do not rebuild the compiler or run full
self-reproduction just to add applications. Reuse identical B1/B2 C for program
builds. Existing compiler law and conformance results retain their historical
scope because this phase does not change the compiler.

Use fresh result directories, bounded jobs and memory, a disk reserve, and
incremental receipts. Preserve failed attempts. Offer a cheap correctness screen
and a deeper repeated application/scaling survey using the same runner and
sources. Archive compact evidence and link it from the report; do not duplicate
large compiler images. Commit the design, applications/methods, and findings as
they become reviewable. Push authorized commits; do not post to the upstream PR.

## Delivery

- `selfhost/apps/`: standalone applications, fixtures, reference checks and usage.
- `selfhost/tools/performance/phase100/`: bounded acquisition/measurement runner.
- `implementation/phase100/`: measured scoreboard, evidence, limitations and next
  priorities, with honest distinctions between measured facts and hypotheses.
- README and self-hosted documentation links so the applications are discoverable.

The long-term objective is efficient, understandable Bend programs with reliable
transformations and useful parallelism. A successful phase can reveal a missing
capability even when no compiler-speed number improves.
