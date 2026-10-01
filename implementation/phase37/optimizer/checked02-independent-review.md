# Checked02 finite selectors and shared host guard review

This is a read-only review of the frozen `checked02/snapshot` source. The
reviewer did **not** author the finite selector implementation; that part is an
independent review. The reviewer **did** author the native-cast proposal and
DataView guard correction; remarks about that correction are author review,
not independent validation. No compiler, module, control or benchmark was run.

Reviewed identities:

| File | SHA256 |
| --- | --- |
| `src/back/js/finite.bend` | `d79d569471ef48816f700b23c6d662eda3c53d3992fe1c4b785fefeb145f0dbb` |
| `src/back/js/jpure.bend` | `23fd65d2e74a0db6d3bf6a618eae9eff565eec0c8f2d09a2aaf90ccea382b41b` |
| `src/runtime/js/core.mjs` | `53d4a49d3c8782f10ae479f6ae2e9ef6bd4bf21d5245adbae8e0a27d7d461c24` |

## Independent finite-selector findings

No new correctness blocker was found in this inspection. The central obligation
is stronger than ordinary purity: the complete scalar-root proof must ensure
that tree inputs originate within the region and are fully materialized before
direct matching. The inspected path supplies that argument:

- The root signature admits scalar inputs; `JPure` rejects function-valued
  fields, native containers, foreign bodies and open/dependent ADT layouts.
  Public tree arguments cannot independently open this proof.
- Ordinary non-tail constructor emission evaluates each field. Tail constructor
  emission returns `build` messages; `force` finishes every pending field before
  returning the constructed value. Passing such a call as an ordinary argument
  therefore supplies a materialized value, even when generic recursive helpers
  construct it through the trampoline.
- The finite emitter captures all source actual arguments before introducing
  callee binders. Earlier pattern work crossed by that evaluation is restricted
  to inert private tag/field reads and typed complete matches. The independent
  `j_pure_prefix` check is essential: the separate finite-prefix predicate alone
  would not justify accepting `Efq` or a default branch.
- Finite leaves contain variables, literals, inert nonnative constructors and
  existing U32/F32 primitives. They contain no helper calls or recursion. The
  code preserves the original tagged object representation and shared fields.
- The new wrapper requires `regionProof===null` before opening and forcing a
  root. A recursive return through another root therefore keeps using the
  existing outer trampoline, addressing the earlier nested-force concern.
- A private finite call requires proof coverage for the callee. The complete
  root graph includes residual native dependencies; `Bool.xor` is still a
  captured mutable native descriptor, not an unconditional public primitive.
  Raw, partial and unsupported entries retain the generic branch.

The final inspected match probe strips annotations before traversing children,
and known-call readiness is gated by Call tag and exact arity. These address
the earlier review's annotation traversal and unconditional failed-name lookup
concerns. Readiness and graph analysis are still repeated across emitted call
sites. Per-body bounds do not bound total duplicated source or total planning
cost for a whole book. Normal checked compilation costs and emitted bytes remain
required admission evidence; the source review cannot declare that cost small.

Actual checked-output controls must still show nonzero private entry for owned
multiple-match/nested/shared inputs, refusal for public deferred/getter-bearing
trees, unchanged demand and first-error observations, and bounded-stack
self/mutual tail cycles. Saved-output controls are insufficient for these claims.

## Author review of shared DataView guard implications

The new host guard checks private view identity state before ordinary scalar
input validation and descriptor guards. It uses captured reflection functions,
so checking a changed method descriptor does not invoke that getter. A captured
shared view with own methods or a changed prototype is refused as well as a
changed public DataView prototype. The four guarded methods cover decoding and
encoding. No public tree ownership is inferred from these checks.

The `regionProof!==null` shortcut remains dependent on the complete source graph
not executing user callbacks. The finite extension retains that obligation.
Error construction through `bad` temporarily suspends the proof before a live
Error hook can reenter, then unwinds to the root's `finally` restoration.
Argument getter/reentry effects occur before the new root's guard. These paths
must be exercised by actual controls; source review is not a substitute.

The shared guard now charges additional reflection checks to short scalar
regions, including programs that do not use F32. This is an explicit performance
risk: measure zero-work and short arithmetic roots as well as the longer
recurrence. A future targeted guard should preserve dependency completeness;
no narrowing is justified merely because the numeric benchmark passes.
