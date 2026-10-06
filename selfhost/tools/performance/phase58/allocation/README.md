# Phase58 additional allocation slice

Proposed only; no compiler/target execution or live source edit. The four primary
Phase58 changes remain separate experiments. This slice adds one bounded source
candidate and ranks larger work only for diagnostics.

## Local key reuse

[Patch](host-key-once-v1.patch), [source](host-key-once-v1.bend), and
[identity/evidence](host-key-once-v1.json) freeze a change to
`back/js/direct/host.bend`. The native-Nat test still executes first. The existing
non-native-Nat ADT branch invokes `jd_host_nat_status_key` with the exact original
`term_key(t)` result. Membership and insertion share that immutable String.
The original status scan, normalization, lookup, type specialization, worklist
order, fuel decrement and failure paths stay in place. No common query helper,
serialization format, runtime, memo table or source-language representation changes.

For each non-native-Nat ADT visited, old key-entry count is one on a seen hit and
two on an unseen hit; the proposal gives one in both cases. Non-ADT and native
Nat branches still perform zero key calls. Thus saved key calls equal unseen
non-native-Nat ADT visits. These are source-path invariants, **not measured dynamic
counts**. Whether that number matters on ordinary requests is unknown. The small
helper call may offset the reduction on seen hits; measure before promoting.

The source argument expressions of the new helper are already-bound values,
except the key computation already demanded for membership in the same selected
branch. Do not hoist the key above the ADT/native-Nat tests or compute it on fuel
exhaustion. Do not globally cache a key by binder identifier or object identity.

## Cheapest focused gate

Root may build a checked candidate and run saved-image private diagnostic exports
of the real old/new `jd_host_nat_status` and `term_key` helpers. This is an internal
helper test, not a public ABI export or accepted-source conformance claim.

Use native Nat (status1), plain U32 (0), one closed no-Nat ADT (0), repeated
specialized ADT in the worklist (0), recursive no-Nat ADT (0), Nat hidden in a
constructor/callback/native Array field (1), erased Nat formal (0), and the
existing combined-signature >1024 walk (2). Assert status equality, complete type
and book fingerprints unchanged, exact key-entry counter invariant above, and
zero new serialization on the short-circuit paths. Reuse the Phase55 host gate's
exact emitted-wrapper equality and independently fixed runtime outputs/events,
including outbound Number9→9n and combined-budget fallback. Keep actual selected
API/source/runtime/Base/driver identity receipts and reject unknown helper bodies.

No target command is claimed ready: the existing Phase55 gate pins its historical
baseline policy; final integration needs the qualification owner's explicit
selected-image successor. Root owns all builds/runs under the usual serial CPU3,
1GiB heap/2GiB treeRSS/4GiB available-memory policy. No nested execution guards.

## Larger opportunities, ranked

1. **Substitution allocation census.** The saved Phase57 direct lexer capture has
   three requests. `subst_terms` has 2,263 sampled allocations /296,700,216 estimated
   sampled bytes (98.90MB/request); `subst_node` has 1,827 /239,974,504 bytes
   (79.99MB/request). These are sampled self attributions, not exact event counts
   or retained memory. Count source substitutions by beta versus binder freshening,
   nodes traversed, replacements, and rebuilt non-App versus App nodes before
   changing anything. A no-occurrence test does not justify returning the original
   subtree: `subst_node` invokes `core_rebuild`, which beta-reduces App/Lam pairs
   even when no substitution occurred. A pre-scan also doubles tree traversal.
   Reusing unchanged compound graphs needs an explicit reduction/demand invariant;
   no identity cache or delayed-substitution rewrite is proposed.
2. **Declaration first-event visits.** The saved own-source CPU profile has
   `f_find` 2.96% weighted self attribution for direct B2. The frozen compiler
   assembly has 629 laws preceding its 3,012 definitions, with matching later
   fills. These are static inventory facts, not counts of dynamic list visits.
   Existing scope-index misses already skip a local list scan; hits deliberately
   keep first-event order. Count hits, actual event visits and successful fill
   distance. Replacing scope.index results with local declarations is incorrect
   because mapped headers and original first events differ. A new local-event
   index would change parser state plumbing and is deferred beyond this slice.
3. **General repeated serialization.** `sk_char` has 5,007 allocation samples /
   656,722,968 sampled bytes (218.91MB/request) in the direct lexer capture. That
   frame also includes the primary scalar-view opportunity; it does not isolate
   avoidable repeated whole keys. Count `term_key` by caller plus serialized bytes
   and repeated output keys, aggregated once/request. Existing template memo
   already retains completed/active instances; it does not make pre-lookup key
   construction free. Bound-variable depth, stored Var values and Sub reductions
   prohibit a term-only cache. The local host proposal above is the only proven
   textual duplicate removed here.

The [Phase57 comparison](../../../../../implementation/phase57/implementation-comparison.md)
and [profiles](../../../../../implementation/phase57/profiles.md) retain source
analysis and raw provenance. The proposal JSON joins the completed allocation
analysis and exact sampled observations. Profile shares are not predicted gains;
no extra allocation/event counts, timings or performance claims were inferred.
