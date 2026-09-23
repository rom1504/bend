# Independent review: Boolean parameter workers (P6-002 v2)

Reviewed 2026-09-23, before the controlled performance pilot. **Scoped GO for
that pilot; no production-promotion or speed conclusion.** This review read
source, actual generated JavaScript and existing controls; it ran no compiler,
tests or oracle. The Phase5 source/default remains unchanged.

The candidate changes only `src/core/term.bend` relative to final05. Genuine
checked API is `e9b440921e86f8dbb75e5a8f44aa3199a5fb1ecceeff49adc2a5ef5e71ad44fa`,
assembled source `d1556b4778942777855787068e6ad73f645780545b4d13afc37fcb9e33ff0600`,
and the actual derivative compared by the controls is
`603086e8792030d2a3f044131bbb251c17747f06296ed6cc9157e01f2ef62cdc`.
The reviewed v2 patch hashes to
`375eb6a78ce3b9ee2675f43acd2da490717d901fcb66b22c8e06fc7ad74c74d6`;
its `project-v2/src/core/term.bend` hashes to
`54b812fbc8d3170ba660cb42e5c0fdbfd6e6301bd301318b13f7fd78b6ab841f`.

## Semantic and demand-order review

The five explicit Boolean-parameter workers preserve the old decision tree:

1. Test Var and return false without visiting children.
2. Visit children left-to-right; the first false child prevents the rest and
   all App/name/metadata checks.
3. After all children are stable, test App; non-App returns true.
4. For App, preserve exactly the old name/id/quantity expression, then call the
   unchanged `core_subst_stable_app` metadata/arity/non-Lam validation.
5. The list continuation visits its tail only after a successful head predicate.

The old and new entry workers extract the same six KTerm fields before these
steps. The new helpers forward already bound values; they do not inspect nested
children, removed metadata or names early. The generated `run_loop` calls force
each predicate before selecting its continuation. The unchanged Boolean-and
expression retains its emitted evaluation order. No substitution, beta rebuild,
annotation dependency or validity test has been removed. Tail continuation
calls still return `run_jump` values, so list traversal retains trampoline
behavior rather than adding recursive JavaScript tail calls.

The actual seven generated bodies recorded in the control report match the
candidate file byte-for-byte. They contain direct Boolean branches and no `kc`
call or newly constructed branch closure. They still allocate/pass jump argument
arrays and add helper transitions, so removal of closure syntax alone does not
establish a net speed improvement. The public self-emitter may lower these source
forms differently; its emitted behavior is not established by these B1 controls.

## Existing controls inspected

`controls-03/report.json` is complete with438 rows and unchanged input hashes,
SHA-256 `5eab6c0222dc46e6a4b13f273ab518dbf7c5d2983645c34add8d89ce0ec5114e`.
Its exact consumed control tool is
`e46b5a232987c1de42c85202f9645b9bbeb963cc78905a5034f00dcf19b35e35`.
I rehashed the three recorded inputs and matched all seven extracted bodies;
I did not rerun the controls.

The disposable views append exports wrapping the real `$core_subst_stable$`
and `$core_subst_stable_terms$` with the existing `run_lib`; there is no substitute
worker or ABI decoder that would reject these values before reaching the changed
code. Thus the controls exercise the changed entry and continuations. Canonical
cases and400 generated finite graphs have explicit successful Boolean expectations.
The independent finite-graph oracle covers their stability contract. Malformed
Unicode, metadata and list cases retain exact returned values or exceptions;
head-only/child-only controls establish the intended first error, not merely two
unspecified failures. The false-head malformed-tail case and Var malformed-child
case must successfully return false.

All three deep cases (128/512/1024) and the100,000-element list explicitly require
successful true results. Two matching RangeErrors cannot satisfy these controls.
They establish those depths under the tested resources, not universal stack or
arbitrary cyclic/getter-bearing host-object equivalence. Existing error/fallback
behavior outside ordinary finite typed data is sampled, not exhaustively proved.

No new blocker was found for the planned core-output/paired pilot. Keep the first
locally-bound-Boolean build rejection and prior control version as history.
Promotion still requires the scheduled real compilation/output gate, opposite-
order performance threshold and any broader integration obligations selected by
root; a438-row helper gate alone does not replace them.
