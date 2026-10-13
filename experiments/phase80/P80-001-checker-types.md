# P80-001: retain types in the checked graph

Status: rejected after checked-B1/frontend36 and exact-C screens; not promoted.
Full qualification was not run. [Report](../../implementation/phase80/README.md).

[Design](../../design/phase80/checker-to-backend-ir.md).

Hypothesis: the checker can retain the types it already computed in its existing
output graph, allowing final backend readback to avoid a second type-inference
and telescope walk at a net reduction in fresh C-request time.

Control: installed Phase78 source/B1 and pinned Phase66 TypeScript, unchanged
request clock and `backendProducts:false`. Candidate: compiler written in Bend,
checked B1 first. Complete previous C is the initial output oracle. Small and
functions65 are held-outs; profiles are separate diagnostic observations.

Reject or revise on semantic disagreement, failed prefix admission, or no net
speed benefit. The intended first discriminator is at least5% request reduction
without a held-out regression. Report preparation, graph/line-size costs and all
failed attempts. No new image is installed on the strength of a short screen.

Compiler01 fails prepared-Base admission: checking-local binder IDs exceed the
source prefix bound. Compiler02 retains that invariant and drops those
definitions' private annotations. Its18 clean requests pass exact C but save
0.61%; Base grows1.18→2.16MB. Compiler03 retains live types and field boundaries:
18 screen requests save1.25%, but12 held-outs regress small17.4%/functions65 8.9%.
Two Numeric profiles show annotation84.86→25.51ms accompanied by increased
graph/decode/context costs. Production source is restored exactly.
