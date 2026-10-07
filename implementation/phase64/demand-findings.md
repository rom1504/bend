# State09 prepared Base demand

**Selective decoding alone has little headroom in the current pipeline.** All
three diagnostic requests preserve complete qualified output bytes and pass
before/after input hashes. State09 eagerly constructs **46,757 graph nodes**:
35,378 in the book segment and 11,379 additional prepared-state nodes. Between
96.12% and 96.61% receive a property read. The unused fraction is only 3.39–3.88%
by node count; this is not a byte-weighted allocation or latency estimate.

| Request | Accessed nodes | Post-cache API demand | Book / prepared nodes accessed | Selected backend demand |
| --- | ---: | ---: | ---: | ---: |
| Numeric | 44,944 / 96.12% | 44,648 / 95.49% | 34,920 / 10,024 | 687 / 1.47% |
| Lexer | 45,136 / 96.53% | 44,840 / 95.90% | 34,920 / 10,216 | 953 / 2.04% |
| MapSet | 45,174 / 96.61% | 44,878 / 95.98% | 34,920 / 10,254 | 9,605 / 20.54% |

Percentages use all 46,757 decoded nodes. Selected backend demand unions source
reachability, annotation, plan lowering, layout proof, foreign handling and final
plan rendering. The sets overlap; adding phase counts would overcount.

The broad demand comes from two concrete paths. The top-level
`check_program_diagnostic_world` call touches 35,924–36,110 nodes. Its successful
result enters `driver_program_checked`, which calls `driver_todos(original)` on
the whole original book. Separately, `book_context` touches exactly **28,961
nodes and accesses bodies of 503 definition nodes in every case**. On an uncached book
it calls `norm_max_book`, then `book_cached` constructs `index_build(book)`.
The selected frozen source locations are
[driver/api.bend](../../selfhost/build/phase63/checked-state09/snapshot/src/driver/api.bend),
[check/prefix-state.bend](../../selfhost/build/phase63/checked-state09/snapshot/src/check/prefix-state.bend)
and [core/index.bend](../../selfhost/build/phase63/checked-state09/snapshot/src/core/index.bend).

Removing those two entire top-level phases from the *accounting* leaves only
2,689 / 3,017 / 11,332 accessed nodes: **5.75% / 6.45% / 24.24%**. This is a clue
about where broad scans occur, not a valid optimization: those phases also
contain necessary checking and context work. The current probe cannot separate
their inner TODO traversal from every required operation.

The cache-decode phase records only 597 proxy-read nodes, including 296 body
fields. That does **not** mean validation needs only 597 nodes. The helper performs
raw-record validation and eagerly allocates every admitted node before proxies
are registered. The mandatory book segment and admitted optional prepared segment
retain their validation. Exactly 296 nodes are read only during cache admission
in each request.

The practical order is to qualify the prepared TODO facts already being developed,
then carry the authenticated maximum/index/context facts instead of rediscovering
them from Base. Repeat this demand probe after those changes. Selective
materialization becomes a stronger prospect only if the remaining observed demand
actually falls. MapSet will still need substantial reachable Base work; the small
Numeric and Lexer backend sets should not be generalized to every program.

[Compact evidence](evidence/state09-demand.json) preserves per-phase book/prepared
counts, top fields, source identities and the helper's original limitations.
[Raw report](../../selfhost/build/phase64/state09-demand01/execution/report.json)
retains the three workers and full node/property counters. Reproduce this
data-only analysis with:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase64/latency/demand/analyze.py selfhost/build/phase64/state09-demand01/execution/report.json implementation/phase64/evidence/state09-demand-NEW.json
```

No compiler target ran during analysis. Proxy overhead is substantial and no
timing comparison is claimed. Each request is fresh; persistent inspection and
freezing remain outside this diagnostic's supported scope.
