# Qualification of the earlier stack-hazard audit

The source-only `native-stack-audit.md` was too broad when it treated recursion
through `nt_choose` closures as inherently retaining hosted call frames.
Subsequent inspection by the independent reviewer found that the generated API's
`nt_choose` can return `run_tail`/`$JMP`, which `run_loop` trampolines. A source
closure-tail call alone therefore does **not** prove stack growth; the generated
calling convention must be inspected. Existing `p111v_functions` handles large
catalogues using that mechanism.

The concrete `native-safe02` failure is different: its generated
`nc_pack_foreign` computes eager OR operands by recursively calling children and
rest before returning the accumulated answer. The captured repeated rest frames
prove that traversal grows the host stack. The focused explicit-worklist repair
addresses that actual evidence.

Accordingly, treat the earlier observer-permission and other closure/mutual-call
items as source shapes reviewed, not dynamically established bottlenecks. Their
equivalence checks and direct-loop observations remain useful, but do not claim
they caused or fixed the observed failure. Do not expand the repair to
`p111_effects`, `p112s_defs`, or `nc_constructors` based only on source closure
syntax. The next failure stack, if any, should choose the next repair.
