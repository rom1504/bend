# Independent review: borrowed root-preserving diagnostics

Source-only review of `root-preserve.py`, `root-preserve-strings.py`, and the
generated host routes in `map-root-both23-prep01/program.c`. These are saved-C
diagnostics for typed immutable Strings, not a general compiler pass or a raw
API equivalence claim. No target was executed by this reviewer.

## Ownership and result ABI

The original root remains owned for the entire Map traversal. The String
comparison retains both original owned roots. Cursors only inspect children;
they neither consume constructors nor decrement references. `term_peek` resolves
ordinary, RFC-backed and static constructor storage. Consequently a borrowed
tail remains alive through its owning root without an extra keep. Aliased
String roots and shared tails are safe provided the original caller already
holds its required two ownership references.

Successful Map traversal returns the original root and the computed bit in
the same boxed Tuple boundary. It reuses the admitted scalar product worker
for `Map.bit.chr`; the discarded first result is the unchanged immediate Char
on this typed path. String comparison returns both original roots in the
original nested Tuple ABI, followed by the ordering constructor. The new
Tuple allocations seal their owned children in the existing way.

Unsupported shape checks leave original ownership intact before falling back
to the old body. Device bodies are unchanged. Arguments are saved before
`WL_OPEN`, so the fresh register bank does not shadow the only copy of a live
input. No concrete ownership blocker was found within the declared typed
scope.

## Semantic limits

Exact Nil and Cons tags, immediate U32 character fields, and bounded immediate
Nat indices guard the fast traversal. These checks support its typed-value
diagnosis; they do not establish arbitrary malformed graph safety, foreign
mutation safety, or equivalence for cyclic/raw values.

The inserted host fast route runs before the original entry's nonsequential
error check. Periodic `err_spun` polling does not immediately check every
short invocation. Production integration must preserve the existing shared
error/cancellation policy before claiming equivalent task behavior. No timing
from this diagnostic qualifies that boundary by itself.

## Requirements for a general rule

A type such as `String -> String & U32` does not prove its first result is
the input String. Prove that every successful return either moves the original
root or reconstructs exactly the matched constructor with every original field
unchanged, recursively through all relevant calls. Preserve the original
evaluation and error order for other returned fields. Unknown mutation,
foreign calls, dynamic calls, failed recursive proofs and unsupported results
must retain the ordinary ownership route.

Keep the boxed public result ABI and confine borrowed cursors to the lifetime
of their owned root. Do not let a cursor escape through a result, closure,
scheduler suspension or foreign call without an explicit ownership rule.
Controls should include unrelated user ADTs, shared roots and shared tails,
static and dynamic strings, unequal lengths, unsigned character boundaries,
out-of-range indices, raw refusal, and one/four-thread cancellation behavior.
