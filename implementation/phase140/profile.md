# Fresh native incremental profile

The separate diagnostic pair uses final source18 / `p140-n1d`, the same frozen
A→product-policy B inputs and independent output oracles as the clean run.
Both106MB products match. Diagnostic native stages are361.416s cold and101.464s
warm; these do not replace the clean363.377/101.030s observations.

The generic native sampler collected23,157 physical PC samples at20ms of
main-thread CPU. No lost samples or timer overruns were reported. Main-thread
coverage is99.4095% of process CPU;95.87598% of samples resolve to symbols.
Unresolved samples stay in every denominator. No caller-unwind or active-owner
sidecar was collected, so physical helper cost cannot be assigned to a particular
compiler analysis merely from this profile.

| Physical category | Complete cold+warm capture | Approximate warm window |
| --- | ---: | ---: |
| Reclamation (`term_drop`, `span_fade`, etc.) |26.47%|24.33%|
| Ownership/product helpers |16.42%|13.03%|
| Borrowed string equality leaf |8.62%|11.27%|
| Borrowed string ordering leaf |2.37%|4.81%|
| Borrowed name hash leaf |1.88%|2.51%|
| Unresolved |4.12%|4.15%|

The named string leaves belong to the generated-Bend bucket, not to the two
runtime-helper categories. These observations are not independently removable
costs or an additive speedup forecast. A high destructor count can arise from
many upstream representations and algorithms.

## How the warm window is bounded

Capture clocks report466.500s wall and463.147s main-thread CPU. Recorded,
non-overlapping preparation, source-IO and revision-stage intervals total463.235s.
The warm stage total is101.464s. Leaving all other process gaps unassigned bounds
its latest start at365.036 wall seconds and earliest end at459.882 CPU seconds.
The offline reducer chooses sample-ordinal CPU coordinates367–458s,4,550samples,
with margins for clock rounding and ordinary sampling jitter.

These coordinates are approximate, not measured phase timestamps or a theorem
about asynchronous timer delivery. The reducer requires intact delivery, no
reported loss/overruns, authenticated capture/binary identities and near-complete
thread coverage. It does not split frontend/raw/backend further. The complete
capture remains available so readers need not rely on the window selection.

## Implication

Typed comparisons removed actual callback machinery but only modestly reduced
the complete warm request. String comparisons and ownership work remain large.
The highest-value falsifier is producer-owned exact change evidence that avoids
rediscovering and reconstructing unchanged structures across stages. Retain the
existing comparator as an independent check of the new decision during the
experiment. Do not conclude that string interning alone can achieve10×: the
frontend, final verifier, output reconstruction and machine build have separate
costs.

## Reproduction and evidence

- Batch runner: `session/run-batch-v02.py`, with an explicit sampler receipt.
- Raw receipt/capture: `selfhost/build/phase140/profile01/report.json` and
  `samples.txt` (included in the final bounded metadata capsule).
- Existing generic reader: `selfhost/tools/profiler/analyze.py`; exact binary and
  capture pins are retained in `profile01/analysis.json`.
- Warm reducer: `session/profile-window.py`; output `profile01/warm-window.json`.
- This is offline analysis only. No cleaned timing was inferred from sample
  percentages, and the original capture and negative results remain intact.
