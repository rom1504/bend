# P39-003: direct recursive components on the installed compiler

Status: prospective investigation, 2026-10-01. Compiler changes require new
measurements; Phase37's saved-output result is supporting history only.

The installed checked03 tree benchmark already opens one validated private
scope and lowers finite selectors. Its recursive `warp` still repeatedly
constructs partial closures, argument arrays, matcher dispatch and trampolines.
Replace that component with a direct explicit-frame worker while retaining
its algorithm, tags, fields, leaf ordering and generic public implementation.
This tests the missing recursive-call fact rather than a representation change.

The Phase37 predecessor used a Phase36 baseline and installed a new handwritten
root. This experiment instead requires the exact checked03 module, emission
receipt and API identity. It reuses checked03's existing proof entry unchanged.
Three clean roles are current, direct warp with generic leaf, and direct warp
with direct leaf/zip. Diagnostic variants carry counters; timing variants do not.
TypeScript remains the pinned same-source context, not the promotion comparator.

A second independent shape is the Phase37 asymmetric expression constructor.
Its `eval` already has a direct iterative fold: retain that fold and specialize
only `p37.expr` plus its known constructor chooser in the existing guarded
branch. An explicit descent/reconstruction stack keeps the tagged Expr, seed
arithmetic, operation choice and allocation order. This distinguishes a general
recursive component from a tree-bitonic-specific rewrite. It does not establish
admission for arbitrary higher-order, dependent or foreign definitions.

## Obligations

- Only exact saturated calls beneath a complete private scalar-input proof may
  use direct fields. Source purity alone does not admit public tree arguments.
- Keep live descriptor, closure environment/bound argument and host guards.
  Getter/mutation/error/reentry observations must follow the original fallback.
- Frame order is left child, right child, then combine. Tail transfers use loops
  or the existing trampoline; never replace bounded tail execution with JS
  recursive calls. Frame storage is invocation-local, with no global scratch.
- Observe full output structures and surviving aliases, including shared/frozen
  trees and identical arguments. Scalar checksums are insufficient.
- Preserve demand: complete private constructors may be read directly only
  because the exact admitted producer graph materializes them. Deferred public
  fields and first-error witnesses remain on generic paths.
- Test zero/mismatched/mixed shapes, live dependencies, raw/staged/overapplied
  calls, Math/Array/prototype hooks, exceptions and proof cleanup. Deep explicit
  stacks and 30,000-step tail controls have distinct evidence labels.

## Experiment sequence

1. Freeze source/module/receipt/tool identities. Root executes derivation, then
   no-timing controls. New fixes get new versioned tools and output paths.
2. Screen two tree sizes in a bounded 20-second serial run. Confirm survivors
   with 60 seconds and paired order; profile separately only when explanatory.
3. Run the independent constructor shape with complete structural expectations.
   Compare both compiler-checked source baselines; no new holdout tuning.
4. If both mechanisms win, identify the smallest common source proof using
   JPure's closed graph and the existing frame emitters. Propose source changes
   separately, with a static bound on component size/arity and refusal fallback.
5. Only an actual checked compiler candidate can establish admission. Measure
   compiler request cost, emitted bytes, source complexity and fresh holdouts;
   retain null/regression results and inherited controls before promotion.

Stop for any observable mismatch, absent actual entry, material retention
regression, or when a general proof needs a large new IR. The 1.5–2.5× current
eligible-tree estimate from Phase38 is speculative. Second-shape gains are
unquantified. Existing speedups cannot be multiplied or relabeled as new data.

Root alone runs target execution/builds and timings under the shared supervisor.
Agents author/read tools and documentation. Closed Phase37 raw files remain
unchanged. Runtime/backend edits belong to other owners until coordinated.

[Experiment](../../experiments/phase39/P39-003-components.md) ·
[Results](../../implementation/phase39/components.md)
