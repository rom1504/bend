# P98-003: repeated observations and branch closures

The first candidate caches `tg(t)` once in `infer_node` and `check_node`:
20 syntactic projections become two, adding two source lines. All branch
expressions and ordered tests remain unchanged. It additionally observes the
total tag function on `check_node`'s literal path.

Result: all 48 complete C outputs and diagnostics pass, but the six-source
request geometric ratio is **1.00749×**, process ratio **1.00435×** versus D04.
This is approximately neutral; the candidate is not promoted.

Generated C explains a limitation: the two inspected function families have
fewer `tg` calls but unchanged closure-allocation counts. A false-branch closure
also gains a field for the cached tag. Static call sites are not dynamic counts.

Separate frozen candidates remove actual branch thunks using typed selectors
and parameter matches. The four-selector version adds252 source lines; the
broader closure variant adds525. Their branch-expression replay, code shape,
full-value selector controls, universal selector laws and real compiler timings
must justify this simplicity cost. The original hoist result is not evidence
that those distinct mechanisms succeed or fail.

Receipts: `selfhost/build/phase98/dispatch-frozen01` through `03`,
`dispatch-screen01/report.json`, and `dispatch-controls01/manifest.json`.
Canonical production sources remain unchanged at this checkpoint.
