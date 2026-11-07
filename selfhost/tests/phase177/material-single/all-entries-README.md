# Public higher/lower entry extension

Root identified direct signature calls to `f_context_higher` and final-type calls
to `f_context_lower`. Replacing only `f_context_materialize` does not route these
calls through the candidate machine. This additive overlay supplies that routing
without changing the already tested loop or substitution sources.

Add `all-entries-prelude.bend` and `all-entries.bend` to the existing single-owner
materializer/substitution configuration. The two additional exact replacements
are `f_context_higher` and `f_context_lower`. Full combined replacements are:

```
f_context_materialize
f_context_higher
f_context_lower
f_sub
```

Both new wrappers preserve the original public parameter quantity. Forward laws
declare the helper signatures; their implementations are untyped and call the
existing `p177ms_loop` directly. No tested source file is edited or copied, and
there is no second loop implementation.

The higher entry starts with `lower=False` and an empty stack. Its resulting
pending bit is discarded at the root: a higher-only caller must receive deferred
children unchanged. In particular, higher on `Lam(Error)` must return the Lam.
FName selection, implicit-operator refusal, eager error order and App/Lam beta
remain higher operations exactly as in the existing loop.

The lower entry starts with `lower=True` and an empty stack. It always executes
the lower traversal; no producer summary is assumed at this public boundary and
no root Finish frame can skip it. State 6 gates beta on `Bool.not(lower)`, so a
lower-only App remains an App even when its function is a Lam. Lower also does
not resolve an FName or reject an implicit Ref at its own root: `p177ms_enter`
routes lower directly to ordinary child traversal after the Error check.

Lower still starts a high/low region for each deferred child, using state 9 and
a Finish frame. The summary can omit only that child's lower identity pass
after its higher producer has established the fact. Ordinary lower children
remain lower-only. Parent Node frames restore `parentLower` after child return,
so finishing such a deferred region does not enable beta in its lower parent.

Original public partial-child helpers are unchanged. Their calls to the newly
routed higher/lower entries retain those entries' complete contracts, including
arbitrary partial accumulators. The loop itself calls neither public wrapper,
so this extension introduces no recursive dependency cycle.

Reuse the existing 287-observation `values.mjs` gate: it compares all three public
transformations on 32 complete cases, six real loader inputs, literal ordering
expectations and 180 public partial-child states. The existing cases include
deferred lambda errors, standalone lower Apps, FNames and implicit operators.
Root owns all source checking, admission inspection and timing; no runs were
launched by this subtask and no speedup is claimed here.
