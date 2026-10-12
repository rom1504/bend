# P69-010 result: defer additional layout metadata

Completed 2026-10-12. The original
[registration](P69-010-native-result-layout-facts.md) remains immutable because
its bytes are pinned by the prepared source plan.

Root's `selfhost/build/phase69/result-facts-diagnostic01/report.json` is complete:
25 correct qualified intervals, five balanced rounds over five roles, and nine
additional correct controls for the three derived roles. The source lane
independently recomputed its medians and checked every qualification/correctness
flag. Report SHA-256:
`dd3d1775c9a15fd05415f0973f0ecaf094a7b65091565bf38fe94423726d7f5c`.

| Role | Median kernel ms | Less time than typed10 |
| --- | ---: | ---: |
| Compiler23 control | 616 | — |
| Typed10 attribution baseline | 448 | — |
| Scalar result-field facts | 446 | 0.45% |
| Packed input facts | 444 | 0.89% |
| Upstream control | 246 | — |

Neither mechanism establishes a meaningful gain relative to the proposed
metadata and correctness complexity. Samples overlap; these sub-1% differences
are not a robust speedup claim. **Do not integrate either prototype.** Preserve
typed10, both saved-C arms and this negative result. The original typed scalar
parameter optimization remains separately selected on its larger measured
gain; this finding does not undo it.

Remaining lexer representation differences include the boxed loop-state pair
and upstream's flattened sum discriminator/payload transport. Those are larger
changes, previously explored in part by P69-004, and cannot be credited to these
fact probes. No production code changed in P69-010, and this lane ran no compiler,
Clang or native target.
