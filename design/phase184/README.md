# Phase184 — handwritten C versus generated Bend program runtime

The user explicitly selected **runtime only**. Compilation is acquisition, not a
scored metric. No production compiler optimization or selected-image replacement.

## Question and comparison

Implement direct C counterparts for all45 retained native cases (44 nonzero
workloads plus the existing zero-work control). Compare three explicit roles:

1. Handwritten C, pinned Clang-O3, separate driver/kernel translation units,
   no LTO, no fast math and FP contraction disabled.
2. Installed self-hosted Bend N2 → QBE → native executable.
3. Installed self-hosted Bend N1 → C → pinned Clang-O3 executable.

The third role checks the assumption that QBE is the fastest Bend target.
Report each real backend separately. Any per-case minimum is an explicitly
labelled best-of-two envelope, not the speed of one hypothetical compiler.
The upstream TypeScript compiler and assembly target are outside this comparison.

Keep native45 case IDs, inputs and full independent expected output. C files
implement shared kernels across genuine argument variants, not45 independent
copies. Preserve algorithms and high-level list/tree/array/string/map operations;
use ordinary C machine types, structs and explicit memory ownership. Family
notes must document arenas, stack arrays, unique mutable updates, byte strings
and other representation choices. These are practical language/implementation
comparisons, not an experiment isolating backend instruction selection.

## Correctness before timing

- Read each actual `p93.value` path, not an unused benchmark entry. Reuse upstream
  handwritten twins only when their algorithm matches these retained fixtures.
- Preserve U32 wrapping, guarded shifts/division,48-bit Nat boundaries where
  applicable, F32 operation rounding, Unicode codepoints and ordered traversal.
- Reclaim per-call allocations; no cross-call memoization or expected-result
  constants in kernel code. Runtime expected values belong to the driver.
- Compile driver separately without LTO: the optimizer cannot replace repeated
  unknown external kernel calls with one result. Inspect its machine calls.
- Acquire/check every Bend product through maintained tools. Handwritten C must
  match the complete catalog output, then repeat with per-call equality/counts.
- For each distinct C implementation, compare additional small inputs against
  both real Bend executables using zero timing/warmup counts to expose the
  actual value without the fixed-case repetition oracle. Start with (0,0),
  (1,17), (3,4294967295); include focused bounds where reviews identify value.
- Keep mismatches, failed acquisition and partial campaigns. Never label a
  missing/failed point as a pass, or silently redefine the45-case score.

## Measurement protocol

Use one root-owned CPU3 execution lane, sequential runtime policy, authenticated
assets and pinned binaries. No sampler, preload diagnostics or concurrent target
campaign. Preserve full initial result, warmup successes, repetition successes
and integer elapsed milliseconds. The interval matches native45: every result
comparison plus timed success-count printing is included; acquisition, process
startup, initial result and warmups are excluded from the reported kernel time.
Process wall/RSS remain recorded separately.

C can be orders of magnitude faster, so uniformly expanding all three roles to
resolve C's millisecond clock would waste substantial time on Bend. This campaign
therefore uses an explicit **new adaptive per-invocation protocol**, not the
historical fixed-batch score. Inputs/results never change. Pilot each role from
its original repetitions, aim at250ms, grow boundedly when unresolved or reduce excessive batches, and record
every pilot. Freeze that role's repetition count, then run three rotated rounds.
Normalize by actual repetitions. All admitted timed observations must exceed the
existing100ms resolution threshold and match every complete-output/count oracle.
Bound each child and the full campaign; retain limits and incomplete metrics.

Report per-case medians and Bend/C slowdown, source/family-weighted comparisons,
correctness coverage, ranges and the best-of-two Bend envelope separately. Do
not aggregate the zero-work point or unresolved/failed cases into a claimed
full-suite result. Flag representative limitations: this is our existing compiler
benchmark corpus, not the entire space of Bend programs or an optimized C ceiling.

## Efficient execution and deliverables

Five bounded agents author disjoint C families. Independent reviews inspect
cross-family semantics; root alone compiles/runs and owns integration. Use small
correctness pilots, then complete45 acquisition, differential controls and one
balanced runtime campaign. No full compiler-image rebuild or bootstrap needed.
Native build tools are reused; only narrowly needed benchmark transport is added.

Keep the5GiB reserve. A reviewed exact-byte hardlink plan can reclaim duplicate
immutable historical copies without touching installed inodes, source, manifests,
symlinks or unique outputs. Fresh output paths and existing retention guards are
mandatory; record actual storage and execution cost.

Commit direct C sources, methods, notes, raw results and a report under
`implementation/phase184/`. Link a runnable README from maintained benchmarks.
Explain which backend is actually fastest, what headroom the C comparison exposes,
and which claims are confounded by representation/allocation choices. Push the
validated benchmark work; do not alter production selection.
