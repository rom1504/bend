# P51-003: reuse String validation within one contextual entry

The first descriptor-batching screen regresses RLE and Unicode. Counter-only
observations instead confirm two String guard invocations per admitted root on
Unicode, Map churn and records. Argument-slot getters run before either guard;
mutating String there rejects entry and preserves the complete output oracle.

Hypothesis: a distinct private capability passed from an explicitly validated
contextual entry can suppress scalarGuard's duplicate String scan. Slot reads
must precede fresh full host and String checks; intervening predicates must be
known scalar tests on cached values, using freshly verified native intrinsics.
All dependency, prototype, exact-entry and fallback checks remain. No permission
is cached between entries or reused after a possible callback.

First test structurally verified saved-output variants and boundary controls,
including accessor mutation/reentry/throws, source/code/call getters and changed
reflection/Number hooks. Reject unknown input predicate shapes. Then compare both
sizes of the three source families. Integrate only in the general contextual
emitter with the same proof; source names are not an admission criterion.

This extends the cheaper-check track based on measured evidence. The original
design and failed batching prototype remain preserved. At this record's freeze,
the token prototype has not executed and is unqualified.
