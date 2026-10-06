# Distinct emitted dependencies

The first full choice01 compiler-image acquisition failed at
`selfhost/build/phase58/final-choice02/bootstrap/full/report.json`.
Emitted reachability returned after 32.451182952 seconds with
`direct reachability edge budget`; the worker reported the error at 54.4502
seconds. This is an explicit compiler resource refusal, not a timeout or OOM.
The preceding source closure contained 3,128 definitions / 3,242 entries.

`jd_reach_refs` previously appended one target for every physical `JD_REF`
occurrence. `jd_reach_visit` charges its 65,536-entry fuel before checking whether
the popped name was already visited. Thus repeated textual references consume
queue capacity even though a definition is rendered at most once. Literal
choice lowering also exposes tail components whose switches contain several
source bodies; replication can increase this pressure. Exact attribution and
counts remain diagnostic work, not an inferred optimization result.

`reach.patch` is the independently reviewed, isolated repair (+12 physical
lines, one helper, no new type). Its new internal scanner carries a per-rendered-
definition KDef index, reusing validated JDReachName records. A repeated target
is not appended again. Every occurrence is still parsed, looked up and charged
against the same character budget; an unknown or malformed later marker refuses
the whole scan. The existing `jd_reach_refs` signature remains available and
preserves its supplied output list verbatim; only new scanned occurrences are
deduplicated. Each invocation starts a fresh set.

The policy becomes roots plus distinct source-to-target dependencies per rendered
definition, with the **same 65,536 queue fuel**, **4,096-definition bound** and
**2,097,152-character per-definition scan bound**. This deliberately changes the
resource-refusal set; it does not reproduce the old textual-occurrence limit.
Multiple definitions pointing to one target still contribute separate edges.
If SCC replication produces more than the distinct-edge budget, it must still
refuse rather than automatically increasing the bound.

Successful selected definitions remain filtered in original source order.
Removing duplicate queue entries can change traversal order, but not the reached
set or that final order. Fresh tiny-budget scanner/worklist controls and complete
emitted-byte comparisons remain required, followed by actual full-image emission.
Static review alone does not establish that this repair resolves the observed
full-image failure. Root owns application and all execution; the before/after
files and `identity.json` retain the exact proposal.
