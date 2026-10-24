# Constructor ownership index: useful fact, mixed hosted result

**Do not integrate this candidate by default.** Its checked semantic fact is
useful, but the small hosted screen does not demonstrate a broad speed gain.
All 29 finite controls and all 18 independently frozen QBE products passed.
No native compiler image containing the ownership index was acquired or timed.

The experiment replaces repeated `nc_ctor_owned` book scans with an exact index,
prepared once before generic/private lowering. The key preserves ADT and child
order, first-match ownership=False, missing names, non-constructor shadowing,
hash collisions and Unicode. Child `BookCache` metadata is conservatively refused.
Only the Boolean ownership fact is reused; source checking, layout preparation,
candidate lowering and independent final verification remain unchanged.

Three checked hosted routes ran in both orders: unchanged parent, query wrapper
falling back without an index, and the explicit late index. Ratios below are
geometric means of the two paired observations; lower is faster.

| Workload | Indexed / parent backend | Indexed / wrapper backend | Indexed / parent whole computation |
|---|---:|---:|---:|
| Lexer | 0.865× | 0.875× | 0.853× |
| Closures | 1.215× | 1.473× | 1.196× |
| Map churn | 0.929× | 1.065× | 0.921× |

Lexer improved against both controls in both orders. Closures lost against the
same wrapper by 33.4% and 62.6%; Map lost by 4.8% and 8.2%. Map's indexed/parent
backend ratio reversed from 1.095× to 0.788×, so its apparent average win is not
robust evidence that indexing removed enough work. The wrapper itself changed
substantially against the parent without the index, further warning against
reading these hosted/JIT/GC observations as native compiler speed.

This is a screening result, not a statistical qualification. There are only two
observations per route, with no independent warmup campaign. Round 0 builds the
index and round 1 reuses it, so cache state and execution order are confounded.
Both rounds compile identical source; finite body-edit/invalidation checks do
not turn the timings into an actual-edit experiment. Whole computation includes
frontend plus backend but excludes Base acquisition and host output transport.
The complete screen cost 90.824 s guarded and peaked at 954,867,712 RSS bytes.

The native stage diagnostic subsequently made the larger missing work clearer.
Its **separate, unindexed** full edited compiler request took 378.296 s:

| Stage | Seconds |
|---|---:|
| Frontend, checking, annotation and erasure | 175.080 |
| Admission, preparation, generic and raw private lowering | 62.179 |
| Unit processing, verification and borrowed-helper closure | 68.360 |
| Rendering, writes and downstream FIFO backpressure | 72.677 |

The late ownership attachment cannot save the 46.3% spent before lowering and
also misses initial constructor preparation. These stage totals do not tell us
how much ownership scanning occurs in each stage; the older 7.48% active-context
profile is neither a current stage attribution nor a promised speedup. Do not
add those percentages or compare this native run directly with hosted timings.

The next useful experiment, if this fact is revisited, is to count its actual
full-source query coverage and acquisition cost before moving the attachment
earlier. An earlier context must preserve the original source-checking book,
first-match/absence semantics and all admission results. A broader raw-candidate
cache requires many more dependencies than this ownership table and is not
justified by this result.

Reproducible numerical derivation: [summary.json](summary.json), produced by
`selfhost/tools/performance/phase135/preparation/summarize-v01.py` from completed
receipts only. Source contract, controls, reproduction commands and strict clock
audit are in `selfhost/tools/performance/phase135/preparation/README.md` and
`native-stage-audit.md`. The shared Phase135 evidence archive should retain the
ownership-source01 snapshot, source/API receipts, 29 controls and comparison
receipts; generated hosted APIs and machine products are unnecessary.
