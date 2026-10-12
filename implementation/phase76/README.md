# Phase76 native compilation work reuse

In progress. Baseline Phase75 remains installed. No new performance or parity
claim. See the [design](../../design/phase76/native-work-reuse.md).

Initial read-only attribution of the selected Phase75 profiles finds occurrence
analysis on about 7–8% of B2 sampled CPU and formatting on about 10%. B1
occurrence analysis is around 13%, with substantial anonymous/trampoline cost.
These are overlapping diagnostic samples, not clean speed measurements.
Occurrence summaries alone cannot deliver the requested gain; the prototype
must evaluate wider reuse before a broad native representation rewrite.
