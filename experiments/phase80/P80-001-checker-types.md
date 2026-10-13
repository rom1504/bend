# P80-001: retain types in the checked graph

Status: registered; correctness untested; measurement not run; not promoted.

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
