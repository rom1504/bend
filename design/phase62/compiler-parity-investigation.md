# Phase62: explain the remaining compiler-speed gap

Authorized 2026-10-07: investigate the next steps toward TypeScript compilation
speed parity. This phase measures and researches; it does not optimize, replace
the installed compiler, update upstream, or post to the upstream PR.

## Baseline and questions

Use Phase61 state08 at `18ed443`, genuine B2 `23bd6a48…`, checked B1
`97f412af…`, and upstream `018751270e800bc222a93dad7f257083ee53a5f7`.
The previous balanced 23-source comparison is 1.433877× for import/API load plus
first compilation and 2.071828× for first compilation alone. Prepared persistent
Base caches, fresh processes, and no claim of cold operating-system caches.

1. Which current stages account for excess time relative to TS across the corpus?
2. Does the same Bend source run materially differently as B1 and genuine B2?
3. Which traversals, substitutions and analyses repeat or rebuild unchanged data?
4. What changes with repeated requests and increasing source size/structure?
5. Which specific techniques in upstream Bend, Lean, Lean4Lean, smalltt and Rust
   address the measured work while preserving Bend's semantics?

## Execution

Start from existing frozen collectors, deriving fresh Phase62 tools where output
boundaries require it. Preserve Phase61 and earlier raw evidence. Root alone runs
serial CPU3 compiler jobs under one process-tree guard: 1 GiB Node heap, 2 GiB
tree RSS, 4 GiB available-memory floor, explicit deadlines. Source work and Python
analysis use CPU0. Record failures without overwriting or silently excluding them.
Keep new disk use modest; record artifact sizes before publishing.

Parallel owners: generation comparison/method relocation; profile analysis;
diagnostic work counters; exclusive stage clocks; term-processing research;
upstream/query-reuse research. No agent independently launches compiler targets.

Collect separate CPU and sampled-allocation profiles for all 23 sources on B2
and TS. Profile timings are diagnostic, not performance results. Preserve signed
CPU deltas, refused weighted views and count-only alternatives. Explain previous
unclassified costs and keep reachability and final emission separate.

For clean generation comparison, use Numeric, MapSet, Lexer and active raytrace,
three rotated rounds, B1/B2/TS, no later requests. Bind identical Bend source and
note B1's derived equality profile, different generated images and runtime/ABI
boundaries: this comparison tests complete generation paths, not one backend pass.

Diagnostic counters and stage clocks must preserve original results and complete
emitted bytes. Restrict instrumentation to private derived copies; do not call
instrumented durations clean timings. Begin with coarse counters and a small
contrasting subset; expand only when useful. Record visited/rebuilt terms,
substitution traversal, query repetition or emission repetition where feasible;
different internal representations prevent naive one-to-one count comparisons.

Use separately labeled repeated requests and small scaling families to test
fixed overhead versus size-dependent work. Retain output/value oracles; synthetic
mechanism probes supplement the real corpus and never replace it. Prefer a
bounded useful result over an extensive new framework.

## Decisions and deliverables

Initial investigation target: approximately 90 minutes, with frequent progress
updates and a review after the first profiles. Scope may be narrowed when a
measurement is expensive or misleading; report unmeasured questions explicitly.

Write a reproducible report in `implementation/phase62/`, exact evidence and
scripts, focused primary-source research, and a small set of ranked experiments.
For each proposed change give its observed opportunity, falsifier, semantic
requirements, likely complexity, and evidence-supported ceiling rather than an
invented speedup. Keep allocation fractions separate from CPU fractions and
avoid adding overlapping stage shares. Research does not establish conformance.

Commit and push owned investigation files under the existing authorization.
Preserve inherited unrelated Phase6 files and all installed artifacts.
