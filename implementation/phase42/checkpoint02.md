# Checked07 development checkpoint

Checked07 is a checked B1 derivative, API `37f2c045e07470016ecbcbcbe3656829b3fedf39e4aa5136fe6058b5d25ea4d7`. The installed ordinary release
remains Phase41; broad integration and promotion have not run. The frozen pin
and runtime are unchanged. Design and first checkpoint were pushed as ef83a07
and c7165a6.

The compiler now emits acyclic direct helpers, reuses full inherited proof
coverage, constructs proved nonnative ADTs directly, fuses a restricted total
producer/filter/map/fold pipeline, and caches exact request-local planner facts.
All public guards/fallbacks and structural stack machines remain.

New focused gates pass: actual pipeline116 complete-stage/arithmetic/deep rows,
79 boundaries and ordinary entry; independent Chain255 rows (three roots each,
including ordered wrapping arithmetic and modulo zero); renamed graph75 oracles
and16 boundaries; constructor fixture31 checks including depth30000; facts5
identity/invalidation/refusal groups. The tree module is byte-identical to the
checked03 module whose191/75 complete-value/boundary and deep controls passed.
Final promotion will bind every owner freshly to its final image.

The fresh short pipeline screen measures128 elements at0.039987/0.013867/0.006376ms
for Phase41/candidate/TS and512 elements at0.112949/0.016660/0.028677ms. The
larger point is6.78× faster than Phase41 and takes0.581× TS time; the smaller
point is2.88× faster but remains2.17× TS. These are two points, not a whole-language
parity claim. Longer final sampling and larger supplemental points remain.

The direct-constructor tree module measures around2.5–3.2× TS in the residual
screen, improving the starting Phase41 denominator roughly4×. Saved-JS flat
clones preserving actual stack machines add1.22–1.42× versus their array-clone
control and remain1.85–2.64× TS. The earlier~1.05× TS fullgraph diagnostic uses
limited native recursion and is not a compiler result. Number counter changes,
helper hoisting, compact frames and lazy frame allocation have no consistent
gain; the largest lazy-stack case regresses. Do not integrate those variants.

A real compiler interaction was caught before promotion: rewriting an outer
helper App into JDirectCall hid the recursive child from unary continuation
classification. A fused root checksum passed while its public/unfused stage
failed with undefined saved operands. Owner-aware traversal now preserves any
App shell containing structural self recursion; the original unchanged stage
and refusal controls pass on checked07. Failed checked03/05 emissions remain
evidence. A source-annotation build failure and a follow-up arity typo, two
invalid independent fixtures, unsuccessful diagnostic CLI attempts and the flat
prototype's grouping syntax failure are retained separately.

Request-local planner-cache controls preserve source-index/rest identity, full
ordered successful/failed graphs and fuel, invalidation on book_put, and fresh
request isolation. Compile-cost improvement remains unmeasured.

A possible timing conflict was investigated: the agent's3s verifyAttempt ended
19:00:55 UTC; residual timing started19:01:08.485, so those heavy jobs did not
overlap. A0.2s mapping-only read/write did overlap and remains disclosed. Final
acceptance measurements use root-only scheduled jobs.

Next: checked closed flat graph with exhaustive normalized-emission audit,
then one frozen broad conformance/performance/cost integration. Map/String and
BST container/SCC/structural limits are being investigated separately; no
unsupported String purity or handwritten whole-program replacement is promoted.
