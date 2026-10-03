# Phase41 campaign accounting — preliminary snapshot

The active [raw campaign ledger](../../selfhost/build/phase41/campaign.jsonl) is
the source. This snapshot includes sequence12, through the `lists-screen01`
receipt ending 2026-10-03 16:57:17.353 UTC. The campaign began 16:39:33 UTC.
The root job is still active, so 1,064.353 seconds (17m44.353s) is elapsed only
through the last recorded job boundary, not a final campaign duration.

| Ledger quantity through sequence12 | Seconds | Basis |
|---|---:|---|
| Wall interval | 1,064.353 | Campaign start to last recorded job finish |
| Sum of recorded tool intervals | 56.604 | 11 event receipts; includes successful and failed jobs |
| Merged tool interval coverage | 56.608 | Union of absolute intervals, with receipt rounding |
| Unclassified interval | 1,007.745 | Wall interval minus merged tool coverage |
| Declared root/agent observation windows | 0 | No window records yet |

The unclassified interval is not an estimate of agent effort, thinking, idle
time, waiting, or model latency. Stage windows have not been recorded, and no
token data supports model/effort comparisons. These totals are a mechanical
snapshot of ledger entries only. Root owns further ledger appends and the final
cutoff/report.

| Job | Recorded seconds | Receipt result |
|---|---:|---|
| freeze-baseline01 | 0.985 | complete |
| tree-derive01 | 0.793 | complete |
| tree-controls01 | 0.686 | failed; retained initial deep-oracle mismatch |
| lexer-counterexample01 | 0.174 | complete |
| lists-derive01 | 0.702 | complete |
| lists-controls01 | 0.259 | failed; retained parenthesized-expression parser issue |
| tree-controls02 | 0.705 | complete |
| tree-screen01 | 30.418 | complete |
| lists-derive02 | 0.690 | complete |
| lists-controls02 | 0.997 | complete |
| lists-screen01 | 20.193 | complete |

The two screens are supplemental saved-output mechanism experiments. Their
reports do not establish installed compiler gains. Final tables must be
regenerated from the closed canonical campaign report after the root records
the actual end boundary; do not extend this snapshot by estimating unrecorded
agent cost.
