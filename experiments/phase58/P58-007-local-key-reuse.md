# P58-007 — Reuse one demanded ADT serialization key

- Owner: allocation investigator; source integration belongs to root.
- Status: proposed/deferred; no checked candidate, focused execution or measurement credited.
- Objective: reduce genuinely repeated compiler serialization without a context-incomplete cache.
- Decision: defer outside the six-change installed `checked-last01` release.

This is a **retrospective index** of the already frozen local proposal, not a preregistered run record. The [canonical proposal and falsification recipe](../../selfhost/tools/performance/phase58/allocation/README.md), [source/identity manifest](../../selfhost/tools/performance/phase58/allocation/host-key-once-v1.json) and [Phase58 design](../../design/phase58/compiler-allocation-and-code-generation.md) remain authoritative. Source plans preceded target execution; this particular slice has no target result.

## Claim and cheapest disproof

**Hypothesis:** In the non-native-Nat ADT branch of `jd_host_nat_status`, sharing the already-demanded `term_key(t)` String between membership and insertion removes one serialization on an unseen entry.

**Invariant:** Native Nat and non-ADT tests still precede serialization. The selected key has the same term and context, with unchanged normalization, source/type queries, status walk, fuel and errors. This is local value reuse, not a memo keyed only by object identity or binder ID.

**Falsification:** Changed status/type/book, serialization on a previously short-circuited path, altered demand/errors, or no meaningful dynamic opportunity stops the hypothesis. A helper-call cost can outweigh saved work on seen entries.

## Controlled setup and gates

The isolated baseline, replacement and patch are frozen beside the proposal. No runtime, serializer format or general memo table changes. The recipe specifies actual old/new diagnostic helper counters, native Nat/U32, closed/repeated/recursive ADTs, Nat-bearing fields/callbacks/arrays, erased fields and combined-budget failure, followed by ordinary host ABI observations. Those tests and measurements remain unrun here. No profile share is converted into a predicted gain.

## Independent audit and decision

Local structural reuse is narrower than a global term-key cache. Existing specialization caches still compute canonical keys before lookup; substitution/reduction and binder context prevent assuming a term-only cache is sound. Keep the small proposal available, but do not add an unmeasured seventh source change to release qualification.

## Preservation

The tracked proposal records parent/candidate hashes and the regeneration path. Retain it alongside the larger deferred parser-index, substitution and serialization opportunities; no checked or performance receipt is invented. Main six-change source checkpoint is `67be31f`, which does not imply this proposal was integrated.
