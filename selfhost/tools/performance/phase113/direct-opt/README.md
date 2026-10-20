# Optional complete-function leaf inlining

This source-only Phase113 experiment tests whether exposing small direct helper
bodies to QBE removes native calls and reveals constants after continuation
elimination. It is not enabled in the baseline emitter.

Compose `model.bend`, `eligibility.bend`, `inline.bend`, then `pass.bend` after
the direct emitter. The public API is
`p113i_optimize(program: P113DProgram) -> P113DProgram`. It verifies the input
and candidate with the existing `p113d_verify`; rejected input is left unchanged,
and any candidate verification failure retains the original program.

Optional entry integration appends `entry-helpers.bend` and applies exactly one
final override: `overrides-scalar.bend` for the enhanced scalar profile, or
`overrides-products.bend` for the product profile. `p113i_lowered` preserves a
nonempty lowering error exactly and only optimizes successful results. The
scalar adapter retains an exact renamed copy of the existing request entry;
the product adapter calls `p113pl_lower_request` directly. Neither calls the
overridden public entry recursively.

The first policy selects public-compatible single-result leaf functions with at
most eight arguments and 48 structured nodes. It refuses native direct calls,
self loops, products, the array-pair extension, large stack allocations, and
partial returns followed by a shared suffix. Final branch trees and ordinary
fall-through branches are supported. Callers are limited to 1,024 initial nodes,
four expansion sites and 128 additional nodes. Counts include nested N111
branches. Each site adds its own 2,048-byte scratch allocation. Explicit stack
reservations are limited to 8 KiB in a candidate and 16 KiB in a transformed
caller, in addition to the emitter's ordinary 2-KiB scratch area.

The pass reuses the existing structural `p112f_stmt`/`p112f_value` renamers.
State and symbolic function/constructor/static values retain their identities.
Every callee local and scratch name receives a distinct `p113i_<site>_local_`
prefix. Callers or callees already containing a `p113i_` local are refused.
Arguments are copied into these fresh formals before any callee operation,
preserving source-order operations and argument/destination aliases. Terminal
result leaves become assignments to the original call destination. All runtime
calls, ownership operations and branches retain their original order.

Functions are processed in the verifier's existing callee-before-caller order.
An optimized function can enter the hash-trie table when it becomes a small
leaf. This allows a chain of small wrappers to disappear in one bounded pass.
Generated nested namespaces are renamed again at each site; only functions
whose original input passed the namespace gate can enter the table. The pass
does not expand recursive cycles or specialize names/programs.
Retaining the original function declarations and generic fallback avoids ABI
or symbol changes. Calling it again is conservative because the reserved prefix
causes an already transformed function to remain unchanged.

Qualification should separately establish:

- Independent reflected execution before/after for true/false branches,
  argument/destination aliases and ordered keep/drop/observer calls.
- Exact refusal for early return with shared suffix, recursion, nested calls,
  product imports, prefix collision and growth limits.
- Native source fixtures proving both output equivalence and actual disappearance
  of the selected call sites, followed by measured application runtime.

Verifier success is structural legality, not an ownership proof for arbitrary
hand-built IR. No native execution or performance gain is claimed here.
