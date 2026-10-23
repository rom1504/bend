# P131-001 — reusable use facts with source-connected laws

Status: implemented in qualified FAST candidate; proved first-order successor
is in the separately admitted final composition, pending native qualification.

Hypothesis: repeated queries over one immutable body can share an exact sparse
minimum/maximum summary. Preserve saturation, missing entries, alternative and
NWPattern semantics. Retain original queries as independent finite oracles.

The 64-ID native extraction improves27.41 times, including summary construction.
That is an amortized proxy, not a whole-compiler prediction. The first combined
native compiler improves6.11% on three requests, mainly Map17.58%; other identity
changes are included, so this does not isolate summary attribution.

The first safe closure algorithm is2.564 times slower than the fast summary.
A proved first-order rewrite is only1.02643 times its cost. Exact declarations,
proof closures and mutation rejections are in the [law package](../../selfhost/tools/performance/phase131/laws/README.md).
Bounded0/1/many counts are a necessary specification premise; unrestricted U32
entries make the proposed generic merge law false. Complete differing-key merge
correctness, invariant preservation and KTerm traversal remain unproved.

Evidence: `selfhost/build/phase131/usage-timing01`, `usage-safe-jobs01`,
`usage-first-order-jobs01`, `combined-fast-request02`,
`combined-first-order-bridge01`, `combined-literals-bridge01`.
See [analysis](../../research/phase131/usage-audit.md) and
[laws](../../research/phase131/laws.md).
