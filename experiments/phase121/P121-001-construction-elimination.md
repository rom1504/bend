# P121-001: remove private materialized pipelines

Status: implemented and measured; checked-hosted experimental source04 retained.
Qualified native Phase118 and installed selections remain unchanged.

Hypothesis: the QBE backend can recover substantial performance by reusing
existing JS total-scalar pipeline admission and lowering one scalar loop instead
of allocating multiple private lists. A diagnostic source transformation first
tests the achievable ceiling; it is never reported as an automatic compiler win.

Parent: `e384668`; qualified Phase118 source/runtime, unchanged original45 oracle.
See [design](../../design/phase121/construction-elimination.md). Record all results,
including compilation overhead and transfer limits, in the Phase121 report.

The whole-list ceiling wins strongly; ordered-map digest fusion is neutral and
is stopped. Existing JS semantic admission enables two native rules: private
list pipeline fusion and immediately applied scalar closure-chain fusion.
They pass renamed/order-sensitive/wrapping controls and literal activation/refusal
checks. Original45 passes405 observations;41 programs emit identical QBE.

Same-run44-point geometric runtime improves2.98762→2.14395× pinned upstream,
28.24% less on that metric. Summed fixed-batch medians fall only6.48%;40 of44
points remain more than10% slower than upstream. The four changed cases improve
20–71× in the broad screen; longer closure confirmation gives84.3× parent and
47.7× upstream. Do not extrapolate these local wins to all programs.

Complete hosted three-case compilation cost is+1.41%; net compiler growth258
lines. No native-image or recursive-acceleration claim. Source-only ceilings,
three failed source/harness attempts and conservative callback refusal are
retained. [Report](../../implementation/phase121/README.md),
[results](../../implementation/phase121/results.json),
[reproduction](../../selfhost/tools/performance/phase121/README.md).
