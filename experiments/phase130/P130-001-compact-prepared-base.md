# P130-001 — compact prepared Base: accepted

Phase129 measured identical decimal-parser entry counts on all three native
requests and substantial decoder context exposure. Hypothesis: fixed-width
numeric transport removes repeated parser/String work without changing checked
preparation or emitted programs.

The isolated native decoder reduces process time35.47%; the backward-compatible
mode integration reduces it36.01%. Complete cached/fresh products, sharing,
26 finite controls,32 entry refusals and nine QBE comparisons pass. Actual N1
request time falls11.68% geometrically in a fresh paired block (2.0412→1.8028×
pinned upstream). Qualified N1/N2 reproduce102,432,076 QBE bytes; focused19 on both
and ordinary45 on N2 pass. All45 ordinary products have unchanged QBE and allocated
machine sections. No new historical-wrapper runtime score is claimed.

See [report](../../implementation/phase130/README.md),
[candidate](../../implementation/phase130/candidate.json),
[raw timing identities](../../implementation/phase130/native-results.json),
[design](../../design/phase130/README.md) and [checks](../../implementation/phase130/checks.json).
Exact executable receipts are in `selfhost/build/phase130`,
`selfhost/build/phase112/p130-vs128-native01` and `p130-n1-n2-native01`.

Decision: qualified research candidate with explicit authenticated compact
carrier. Installed production selection remains unchanged. Preserve old decimal
behavior. This removes fixed startup work; full-source acquisition is still
expensive, so no recursive research acceleration is demonstrated.
