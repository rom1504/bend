# Independent audit: unchanged-function verification reuse

Reviewed `reuse/verify-v01.bend` against the qualified Phase131 producer,
including the actual `p113e_*` verifier and every selected `P114SBoundary`
constructor. No target execution or production edits were performed by this
reviewer. This is a source argument for verifier-result preservation, not a
formal proof of compiler transformations or their semantic equivalence.

Version01 SHA-256 is
`f09b1c0222091abf94d163565e6efe49355ff3769289c7ffb578c726de0410b0`.
The subsequent version02
`91c561cb6b8d22d2feffc5af939d3929d0f1f2959ef052eb994bace66d3bf453`
has byte-identical implementation before `p134v_controls`; it adds six controls
covering earlier callee body changes, public flags and call-symbol/type/target
distinctions. The core audit therefore applies to both versions.

**No blocker found for the proposed internal route.** The important premise is
a genuine boundary from `p114s_open` or a prior successful commit, within the
same immutable request and fixed producer/runtime.

## Why the context is the same

`p113e_function` receives only the candidate function, immutable `N111Ids` and
the ordered `ready` index. The boundary retains the same original static program
and IDs. The complete header-list comparison checks function order, names,
parameter IDs/names/kinds/order, result count and public flags.

`p113e_signature` depends only on name, parameter count, result count and public
flag. Consequently, induction over the equal ordered headers gives the exact
same `ready` index at every function position, including index insertion order
and duplicate-name behavior. Earlier body changes do not alter that verifier
context. This is stronger than merely comparing a set of available names.

For a structurally unchanged function, its previous verifier result was success
under these same inputs. Reusing that result is valid. For a changed function,
the existing `p113e_function` still runs. The first failing changed function
causes the entire candidate to fall back to the prior boundary, as before.
Header/count/order changes take the original complete-verification path.

The equality helpers cover all current fields of:

- Three `N111Type` variants and five `N111Value` variants, including both U64
  constant halves and local/symbol/function-ID/constructor-ID distinctions.
- Every field of all nine `N111Stmt` variants, including call symbol and typed
  argument vector, load/store offsets, alloca size/alignment, both branches and
  pointer offsets.
- All five `P113DStmt` variants, preserving call destinations/target/arguments
  and the distinction between return and local-loop continuation.
- Four `N_WordKind` variants and complete parameter bindings.

No operation, ownership argument, runtime import or effect-bearing instruction
can change while being classified equal by these inspected helpers. This does
not add an effect/ownership proof to the verifier: it preserves exactly the
existing verifier's judgments. Optimization correctness remains a separate
obligation.

## Boundary provenance and final verification

The selected parent constructs successful boundaries through
`p114s_open_functions`, which runs `p113e_functions` from an empty ready index,
and `p114s_commit`, which either validates a new list or preserves the prior
successful list. Error/unchecked paths set `valid=False`. The proposed emission
route starts with `p114s_open_lowered`, then uses the new commit internally.
It preserves this provenance chain. The existing `p113a_verify` and later
complete final verifier are not replaced.

The Boolean field is **not an unforgeable proof**. On arbitrary user-constructed
`P114SBoundary{...,True}`, equivalence is not established. For example, a forged
boundary with an invalid first function and valid second function, followed by
a candidate changing only the second body, can skip the invalid first function
under the new route. The old complete verifier would reject earlier and retain
the original list. Final validation still rejects the invalid program, but the
intermediate commit results can differ. Keep this helper internal; do not
present it as a validated serialized-cache or untrusted-certificate API.

## Stronger controls recommended

1. Change an earlier callee's body while retaining its header, with a later
   caller unchanged. Test both a valid replacement and an invalid replacement;
   compare complete candidate acceptance/fallback with the old commit.
2. Mutate a runtime call's symbol, argument type or argument order into a
   verifier-rejected operation and ensure it cannot be classified unchanged.
3. Change a public flag or parameter name/order while keeping arity unchanged;
   require the original full-verification fallback.
4. Test invalid nested branch content and continuation/result-vector mutations.
5. Preserve original/IDs in the comparison observation. The current
   `p134v_boundary_same` compares validity and functions only; the source retains
   original/IDs directly, but that helper alone does not test their preservation.

Performance remains unmeasured by this audit. Structural comparison and two
header traversals add work; the relevant discriminator is full commit/request
cost with the unchanged final verifier, not the number of checks skipped.
