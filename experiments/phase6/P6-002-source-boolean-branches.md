# P6-002: explicit Boolean matches in the stability predicate

Recorded 2026-09-23T02:43:09.679502+00:00, before the checked candidate build.

P6-001's optimized-core profile attributes substantial samples to trampoline,
choice helpers and closures inside core_subst_stable. Test one source-level
intervention: replace kc choice thunks inside core_subst_stable and its list
predicate with local Boolean bindings followed by explicit Bool matches. Keep
the same comparison/child traversal order and all application-shape checks.
Do not memoize, skip substitution or modify the runtime/emitter. The purpose is
to let the pinned bootstrap emitter lower direct branches and avoid constructing
both branch closures. The self-emitter already recognizes many kc patterns;
its behavior/output also needs a later gate before any source promotion.

Use an isolated copy of final05 source and unchanged maintained checked/equality
workflow, CPU2, 4GiB heap, 5-minute total build/selected gate bound. Compiler
production sources and consolidated default stay unchanged. Compare actual
checked generated predicate bodies, then direct canonical/malformed graph
controls and a small real core compilation with exact emitted-byte oracle.
Retain failed checks and do not call paired generic rejections exact agreement.

If semantic gates survive, schedule opposite-order fresh-process core samples
only after broad correctness and other compiler jobs finish; no concurrent wall
timing constitutes a speed result. Require at least5% improvement in both pairs
to justify broad validation; keep every pair and stop on mixed results. If no
controlled window remains, report a semantically tested candidate, unmeasured and
unpromoted. This small predicate experiment cannot explain or close the entire
6.03× gap and is distinct from rejected private substitution-worker fusion.
