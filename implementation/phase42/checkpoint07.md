# Checkpoint 07: preserve the existing vector optimization

The inherited counter preflight found a real admission regression in checked15.
All 35 independent value oracles passed through fallback, but quantity-2 Sigma
vector workers had disappeared. The stricter quantity-1 native-container equality
had accidentally replaced the existing local-vector comparison policy.

The reviewed five-line repair restores the original Phase41 region comparison
and calls strict closed-type equality directly from the three JPure comparison
sites. This separates the two existing proof domains without widening native
ownership. The original counter controller is unchanged: checked16 now passes
all 35 oracles, five mutation boundaries, optimized Number countdown admission,
and observable/stored/aliased predecessor refusals.

Checked16 builds in 45.48 seconds, with 1.263 GB peak process-tree RSS. API:
`63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54`.
The runtime is unchanged from checked15. Source counts are unchanged by this
repair; compiler source is 22 bytes smaller. See [complexity](complexity.md).

Integration02 and its failed preflight remain evidence for checked15. The queue
was stopped before broad frontend validation; its current 45-point acquisition
finished intact. Final admission will use fresh checked16 acquisition and checks.
No old receipt is relabeled as a new compiler result. Phase41 remains installed.

Independent review also identified inherited instrumentation assumptions that
no longer match intentional optimizations: private lexical tree workers and
fused list roots bypass earlier global-worker counters. Versioned controllers
will instrument the actual paths while retaining complete values, deep behavior,
mutation boundaries and explicit activation requirements. These instrumentation
repairs are distinct from the real compiler regression above.

Evidence: `selfhost/build/phase42/focused16/preflight-counter/report.json`,
`selfhost/build/phase42/checked16/attempt.json`, and
[exact patch](../../selfhost/tools/performance/phase42/calls/equality-domains-v1/source.patch).
All failures and queue decisions will be included in the closed campaign archive.
