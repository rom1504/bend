# P195-001 — certified selection before placement

Compare/CMOV selection removes predicate intermediates after existing allocation.
Hypothesis: preserving selected read/write events before allocation removes a
large share of row-worker spills. Fresh physical profile puts98.02% of editdist
CPU in that worker; x86/QBE/C loops have77/44/26 instructions and20/4/0 explicit
frame references. These are not cycle counts.

Version1 passed source checks,9data controls,968 independent observations per
object/assembly route and six ordinary outputs. Actual loops only shrink77→74
and20→19frame references. Balanced screen takes1.01266×baseline for editdist;
local-pair1.06549× with~6%dispersion. Reject version1 as a selected optimization.
The strong initial hypothesis was falsified for this narrow projection, not for
all possible allocation changes. Preserve files and screen-runtime01 receipts.
