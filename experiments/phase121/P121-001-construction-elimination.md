# P121-001: remove private materialized pipelines

Status: planned; no new runtime result.

Hypothesis: the QBE backend can recover substantial performance by reusing
existing JS total-scalar pipeline admission and lowering one scalar loop instead
of allocating multiple private lists. A diagnostic source transformation first
tests the achievable ceiling; it is never reported as an automatic compiler win.

Parent: `e384668`; qualified Phase118 source/runtime, unchanged original45 oracle.
See [design](../../design/phase121/construction-elimination.md). Record all results,
including compilation overhead and transfer limits, in the Phase121 report.
