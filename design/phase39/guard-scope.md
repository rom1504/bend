# P39-002: reuse a complete entry proof across an existing scalar root

Prospective design, 2026-10-01. Baseline: installed Phase37 checked03, API
`ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`.
This plan changes no public ABI or requirement to inspect mutable host state.

The active-ray export already has an exact-entry scalar root with complete host,
scalar-input and dependency checks. Its admitted body calls private helpers and
residual generic functions, but it does not open the existing `regionProof`
scope. `colf` and `rowf` already open such scopes through `j_tree_scope`.
Repeated `nearest` checks therefore remain a specific, testable cost.

## Hypothesis and isolated variants

Opening the existing synchronous proof scope after the unchanged root checks
will amortize nested guards. It may also activate existing finite selectors;
measure that interaction explicitly rather than calling every saving guard cost.

Derive from the exact final active-ray module:

- `baseline`: byte-identical installed output.
- `scope`: wrap only the admitted `coverage.active` body in
  `regionProofOpen($guards)` / `try` / `finally` / `regionProofClose`.
- `scope-no-finite`: the same scope, with existing private finite selector
  conditions disabled, isolating their contribution to the combined change.

Keep clean modules for timing and separately instrument host/scalar guard calls,
full checks, scope opens/closes and finite-selector entries. Counters cannot be
part of clean timing. No variant removes a mandatory entry guard. No guard answer
survives a public call. The root's generic fallback stays byte-identical.

## Production admission is a separate obligation

If the prototype survives, reuse `j_tree_scope(book,d,helpers,body)` at
`j_region_root_done`. That helper independently requires a scalar input/result
signature, residual work and the full original-source `j_pure_graph` proof.
The existing guards must cover all dependencies used by the scope; emitted
helpers are not themselves proof that a residual graph is pure.

Ownership is restricted to `region.bend`'s `j_region_root_done` integration.
The numeric/countdown agent owns scalar Nat-loop emission in `worker.bend`.
No duplicate scope mechanism, global invalidation cache or new IR is proposed.

## Controls and timing

Compare actual output across zero/small/active catalog inputs. Test changed
dependency descriptors, raw/partial/extra arguments, prototype/native/DataView
hooks, restoration between calls and error reentry. Confirm full checks occur
again on the next public call and that proof state is restored after exceptions.
Use exact-entry and nonzero scope/finite-entry witnesses to avoid vacuous controls.

First use 20/60-second clean paired screens on the two active-ray points. The
held arithmetic, viewport, source inputs and expected checksums remain unchanged.
Acquire/build cost is separate. Root alone executes jobs serially under CPU3,
Node24.18, 1 GiB heap, 2 GiB process-tree and available-memory constraints.

Stop for any changed callback/error/demand observation, a missing dependency,
zero intended entry, no reproducible clean improvement, or compiler cost that
outweighs useful runtime work. The prior 1.15–1.5× ray estimate is a hypothesis,
not a measured result or an acceptance threshold. Numeric already has one outer
guard and is not a second scope-amortization target.

Results and commands belong in
[the implementation report](../../implementation/phase39/guard-scope.md).
