# Phase52: direct JavaScript lowering toward upstream parity

Started 2026-10-05 14:49 UTC. The user authorized a prototype, followed by the
full implementation if it demonstrates value. The requested planning targets
are one hour for the prototype and three hours for the full implementation;
these are checkpoints, not a license to skip correctness or claim completion.

## Hypothesis and contract

Upstream's normal JavaScript lowering uses lexical positional functions, native
closures, direct matches and native representations. Our current default lowers
through mutable function descriptors, general application and forcing, then
recovers fast execution in admitted complete regions. Much of the guard cost
preserves our additional mutable-G interface. A Bend-owned backend following
the upstream contract should remove this overhead across ordinary programs.

The new `direct` backend is explicit. The current `js` compatibility backend
keeps its observable descriptor, getter, mutation and continuation contracts.
The direct mode follows pinned upstream callable exports, erasure, arithmetic,
evaluation order, effect/FFI and marshalling behavior. Differences in deep native
recursion and host-visible internal representations must be documented. No
legacy guard is merely deleted and relabeled semantics-preserving.

All compilation decisions remain in Bend. The existing checked frontend and
annotated KTerm book are reused. A static JavaScript value/runtime library may
be adapted from pinned upstream with attribution; ordinary direct compilation
must never invoke the TypeScript compiler. Upstream remains the checked bootstrap
and independent reference. `bend2/bend.ts` and historical pins are untouched.

## Sequential gates

1. **Prototype:** implement general typed direct calls, native closures, matching,
   constructors and exports. Compile several distinct checked programs, including
   higher-order, allocation-heavy, numeric and recursive shapes. Reject unsupported
   constructs explicitly. Compare exact outputs with upstream before timing.
2. **Value gate:** compare unchanged Phase51, direct output and pinned upstream
   using identical calls, inputs and result checks. Record that direct output has
   the upstream interface; this is a new contract comparison, not a silent change
   to the legacy-ABI metric. Require broad structural change and a substantial
   win across multiple shapes, not a benchmark-name specialization. A useful
   early target is at least 1.5x geometric speedup against legacy on the frozen
   prototype set with multiple cases approaching upstream. Preserve all failures.
3. **Expansion:** if the gate supports the hypothesis, complete remaining language
   constructs, staged/partial calls, tail cycles, primitives, arrays, effects and
   FFI. Integrate an explicit public option, independent semantic fixtures, full
   maintained benchmark comparison, compatibility regression checks and docs.
4. **Promotion/report:** install only a checked, qualified artifact. Report coverage,
   unsupported cases, output size, compiler cost, execution ratios and uncertainty.
   If full parity or coverage is not attained, state the exact limit. Commit and
   push the design, reviewable implementation checkpoints and final evidence.

## Parallel work and resource policy

The lead owns driver/API integration, checked builds, target scheduling, releases
and reporting. Independent agents own core lowering; constructor/match lowering;
primitive/runtime adaptation; exports/marshalling; benchmark controllers; semantic
controls; and independent review/contract audit. Owners edit disjoint new files.
Agreement on cross-module signatures precedes integration. Source changes are
frozen into each checked attempt; no completed attempt or past phase is modified.

Use Node 24.18.0, 1 GiB heaps, 4 MiB stacks, 2 GiB process-tree RSS and 4 GiB
available-memory floor. Heavy builds and timing targets are serialized. Timings
are CPU-pinned, clean runs are separate from profiles, and each rejected or
interrupted attempt retains its receipt. Full45 is a final candidate gate, not
the prototype loop. Existing unrelated dirty files are preserved.

## Evidence required

Record source/API/runtime/pin identities; exact commands and exit status;
source-to-output provenance; benchmark role and export adapter; ordinary callable
and FFI semantics; measured warmup sensitivity; and tested scope. Match complete
results rather than a convenient checksum when the maintained oracle demands it.
No PR comments are authorized. Experiment records and the Phase52 report link
raw evidence and rejected attempts separately from successful qualification.
