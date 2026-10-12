# P70-005: reuse request-owned compact native bodies

Registered before candidate construction or execution. Owner: closure/compiler-work
source lane; independent reviewer: Phase70 review lane. Domain: C compilation
requests, with emitted C and diagnostics unchanged. Parent: [P70-003](P70-003-native-compilation-survey.md).

## Hypothesis and invariant

Phase69 `ns_defs` stores `ns_static_term(nc_compact(nc_definition_plain(...)))`
in fresh request-local `NativeStaticBody` facts. Scheduler, ordinary worker and
product-worker entry builders currently apply `nc_compact` again after retrieving
these facts. A fact-aware compact-body accessor can return the prepared term and
retain the exact old compact/definition path whenever no matching fact exists.
This removes traversals and term reconstruction without introducing a cache,
changing worker admission, or changing the generated-program policy.

The correctness condition is exact term equality between every genuinely prepared
body and its second compaction, including malformed raw terms that reach this
path. This is a restricted fixed-point property of `ns_static_term` after
`nc_compact`; arbitrary core-term idempotence is not assumed. Original source
metadata, raw foreign telescopes, intrinsic bodies, missing definitions and
unprepared books must preserve the old fallback and fresh-ID dependence.
`ns_source` strips previous static request facts before production compilation;
user-supplied facts alone must not grant a new public fast path.

## Cheapest discriminators and controls

1. Independent source challenge of the fixed-point property; reject or strengthen
   the fact production invariant if constructor folding can enable another fold.
2. Helper comparison of complete candidate compact bodies against actual baseline
   `nc_compact(nc_definition(...))`, using genuinely prepared books, multiple fresh
   IDs, prepared ordinary/static bodies, raw malformed constructors/literals,
   preserved lambda flags, dynamic children, NStatic leaves, foreign/intrinsic/
   absent/unprepared books, and stale/forged payloads through `ns_source`.
3. Checked B1 fast build; exact complete C comparisons for numeric, array and
   held-out lexer plus native raw demand/error controls. Keep failed attempts.
4. Only after survival, root measures paired B1/B2 clean request clocks separately
   from profiling and generated-program execution. Byte identity, unchanged
   diagnostics and no memory regression are promotion gates.

Initial static estimate: +5--8 Bend lines and three changed call sites. Saved
profile attribution limits expected isolated savings to0–1%, likely below0.5%.
Root integrated the six-line proposal with P70-004 in compiler01: checked build,
155 full-term helper queries per image and12 exact-C requests pass. Combined B1
screen is0.9642× baseline; no isolated compaction or B2 gain is claimed. Proposal,
review and data-only audit live under
`selfhost/tools/performance/phase70/compiler-work/`; ranked findings will be in
[the audit](../../implementation/phase70/compiler-work-audit.md).
