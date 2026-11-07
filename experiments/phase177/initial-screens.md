# Initial frontend screens

These are concurrent screens on distinct physical cores, not promotion measurements. Inputs: frozen356,626B parser compiler and656,302B frontend compiler. Phase175 N2 built every image with identical runtime and toolchain. One baseline/candidate pair per input, no concurrent machine construction. Exact native digest observations passed; independent complete-value campaigns are separate.

| Candidate | Small request ratio | Medium request ratio | Decision |
|---|---:|---:|---|
| One-owner substitution |0.9725|0.9711|Retain for larger isolated screen|
| One-owner freshening |0.9827|0.9861|Small; retain provisionally|
| Tail-recursive declaration filter |0.9744|0.9979|Reject as primary candidate|
| Reuse reachability membership |0.9728|0.9987|Reject as primary candidate|
| Producer summary skips lower pass |0.9746|0.9903|Weak; compare with single-owner implementation|

References: selfhost/build/phase177/screen-batch01 and screen-batch02. Exact values are in their nested result/report.json files. Independent source checking passed for each; finite source controls passed264 substitution,419 freshening,22 filter,129 reach,290 summary observations.14 full parsed/request comparisons passed independently for substitution, freshening, reach and summary (controls are finite, not compiler equivalence theorems).

Negative infrastructure findings: three parallel hosted acquisitions exceeded the2GiB aggregate RSS cap and were stopped by the guard before OOM; two workers under4GiB succeeded. Summary v1 failed an affine quantity check; one-owner material v1 failed match ordering. Two filter-host fixtures used the wrong String representation; corrected to the actual upstream JS string ABI. The first generic frontend comparison attempt selected an experiment-specific gate requiring unavailable exports; corrected to its documented stages gate. These preflight failures do not constitute compiler semantic failures and are retained.
