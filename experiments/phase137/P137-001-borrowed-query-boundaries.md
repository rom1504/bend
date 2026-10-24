# P137-001 — Preserve complete borrowed query boundaries

Status: positive small experiment; integrated native qualification in progress.
Parent: `4778aff`; design: [Phase137](../../design/phase137/README.md).

Phase136 found repeated nine-field `KDef` extraction in actual compiler name and
constructor-ownership queries. Width16 support alone was insufficient: early
inlining copied owning bodies before borrowed-reader replacement.

The experiment separates width8/16, original/fused query source, source-only
argument/kind specialization, and a conservative early-inlining policy. The last
policy preserves calls containing exact nine-to-sixteen-field consuming reads.
It changes profitability, not borrowing legality; original fallbacks and final
verification remain. It uses the existing return-shape walk, without duplicate
preparation or a new whole-program pass.

Five rotated clean CPU3 rounds on the same independent oracle find:

| Exact extraction / transfer workload | Parent | Retained-boundary candidate | Reduction |
|---|---:|---:|---:|
| Six real compiler queries, 2,000 repetitions | 190.288 ms | 130.863 ms | 31.23% |
| Unrelated nine-field record, 262,143 repetitions | 227.974 ms | 80.059 ms | 64.88% |

These are deliberately small diagnostic workloads, not a representative runtime
score or a whole-compiler gain. Their controls include aliases, Unicode, misses,
shadowing and BookCache behavior. All ordinary and timed answers pass.

Negative findings matter: width alone was neutral; source factoring alone was
neutral; width plus factoring improved only the parser query. Reordering arguments
and specializing constant kinds did not restore the other calls. All are retained.

Actual linked calls now reach existing borrowed readers. Their seven relevant
bodies are byte-identical to the previous candidate: preserving their boundaries
made the difference. The owning `is_cache`/`dc` paths remain. Broadly suppressing
wide-record inlining can also retain unprofitable owning getter calls; full native
compiler measurements determine adoption.

[Source and machine audit](../../implementation/phase137/audit/generated-calls.md)
· [Raw experiment capsule](../../implementation/phase137/evidence01/receipt.json)
· [Detailed notes](../../implementation/phase137/query-notes.md).
