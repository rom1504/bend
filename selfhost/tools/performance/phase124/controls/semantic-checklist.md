# Bounded semantic falsification checklist

This is an offline review checklist, not a claim of executed tests.

1. **Callable authority:** accept only an already-verified public P113D single-Term
   worker or an entry from the immutable P112-ready registry. Check exact original
   arity, symbol namespace and return ABI. Private flat/product workers, unknown
   symbols, dynamic apply, wrong arity, effects and oversized arguments must retain
   fallback. A reflected record with the right fields is not callable authority.
2. **No recursive native cycle:** a new helper cannot call the enclosing owner or
   reach it transitively. Self-tail loops inside a verified helper are fine. Owner
   recursive descent must remain the existing explicit-stack transition. The two
   controls exercise depth and two child calls; inspect calls in emitted QBE too.
3. **Capture lifetime:** execute the exact original frame/capture stores before
   the helper. Preserve their original order, widths and ownership. In list control,
   rest survives the first helper and its result survives owner recursion. In tree
   control, the right subtree and payload result survive left recursion, then the
   left result survives right recursion. Retained originals must print unchanged.
4. **Transfer exactly once:** snapshot arguments before overwriting shared machine
   registers; no implicit retain, drop, truncation or duplicate transfer. After the
   helper returns, its single U64 result owns one live Term. Keep captures alive
   until the authenticated continuation consumes or drops them, including empty
   payload/empty-subtree branches.
5. **Frame accounting:** one helper-call frame creates one depth increment; existing
   unwind performs one matching pop. The helper must not pop its caller's frame.
   Zero initial depth returns normally. Continuation identity, capture count and
   result position must match the original segment, not a guessed local signature.
6. **Continuation closure:** every newly reachable continuation must pass the same
   original plan checks and finite table budgets. Rename all statements and the
   new result local injectively. Unknown return targets and excess table entries
   must fall back before any partial plan is emitted. Other R/G renderers must
   refuse the new node if they cannot interpret it.
7. **Evaluation and fallback:** preserve helper-before-descent and left-before-right
   order, exact U32 wrapping, constructor identity and preexisting error behavior.
   Failure to recognize a complete chain must preserve the whole original route.
   Check emitted activation and exact output independently; a valid fallback result
   alone establishes nothing about the proposed call/resume node.

Do not read this finite checklist as native N1/N2 qualification, a whole-language
proof, or permission to weaken independent verification.
