# Phase45 execution optimization

Status: investigation and implementation in progress. The installed reference
remains Phase44 checked04. The [design](../../design/phase45/README.md) separates
immutable result admission, projection scalar replacement, runtime state ablation
and the main private-worker representation work. Results below are isolated screens,
not a qualified combined release or a full-corpus speedup claim.

Raw evidence is accumulating only under `selfhost/build/phase45`; prior campaigns
are closed. Exact compiler and source identities are in `baseline.json`, and
supervised jobs append to `campaign.jsonl`. Failed attempts remain preserved.

The [immutable-result experiment](../../experiments/phase45/P45-001-immutable-results.md)
admits exact native String results while retaining scalar input and complete
graph/host proofs. The checked candidate changed only record aggregation among six
acquired sources; its generated output now has a contextual worker. Record output
grew from 126,483 to 256,878 bytes. Other output bytes were unchanged.

| Isolated screen | Coverage | Observed baseline/candidate | Interpretation |
| --- | --- | --- | --- |
| String results, 20-second preset | Record aggregation 256; 9 samples | 1.1433× | Extreme candidate drift; insufficient warmup |
| String results, 60-second preset | Same point; 9 samples | 3.7294× | Substantial baseline/candidate drift; interpret with the stronger replay |
| String results, 600-second preset | Same point; 15 samples | 2.8185× | Positive general-rule signal; drift remains and candidate is 23.8798× TS |
| Projection candidate, 60-second preset | Lexer, Map 128, Unicode 64; 27 samples | 1.7117× / 1.0820× / 0.9648× | Promising lexer screen; Map drifts and Unicode regresses |
| Continuation worker02, 60-second preset | Six points; 54 samples | Lexer 1.6540×, Map 1.7831×, records 2.0731× | Records have two timing states; combined candidate, selected coverage only |
| Exact-state saved-JS ablation, 60-second preset | Six points; 54 samples | 0.9996×–1.0309× | Essentially flat; unchecked prototype, not installed compiler output |

All listed screens completed their selected samples with correct expected outputs.
Ratios compare freshly timed roles within each run, never different runs. The String
screens disagree substantially as warmup changes: the first candidate half drift
exceeds +280%, and the second still has +15.5% to +21.9% candidate drift alongside
−32.4% to −29.3% baseline drift. The stronger `runtime-immutable03` completed five
rounds per role in 27.11 seconds with 1,000 ms warmup and a 300 ms target. Its
medians were TypeScript 1.248865 ms, Phase44 84.056331 ms and candidate 29.822644 ms.
That is a positive signal for the general rule on this point, with residual drift
up to −21.1% baseline and +30.3% candidate; it is not a precise universal gain.

The independent String composition fixture passed eight exact oracles and 44
mutation/reentry boundaries. Its first-line-only shape scanner mistakenly labelled
the `bench` and `selected` workers absent; inspection of the exact hashed output
finds both emitted entries. Actual branch execution remains a separate activation
question. The controller for the changed record module is prepared, with production
boundary comparisons and a separate counter derivative; its execution is pending.

Current raw reports are `runtime-immutable01/report.json`,
`runtime-immutable02/report.json`, `runtime-immutable03/report.json`, `runtime-projection01/report.json`,
`runtime-exact01/report.json`, and `fixture-controls01/report.json`, all under
`selfhost/build/phase45/`.

The [continuation-worker experiment](../../experiments/phase45/P45-005-continuation-worker.md)
now passes 36 selected paired probes, eight maintained suites and all 54 execution
samples. It removes generic private-call machinery from the admitted Map and
record graphs. The profiles identify the next architectural bottleneck directly:
V8 marks both approximately 71 KB workers **too big to optimize**. Allocation also
remains about 9.7× TypeScript on these two profiled points, with roughly 92% attributed
to the worker. Tail register reuse and exact call-component partitioning are in
progress, with independent correctness and performance checks required. The graph
pass operates on worker IR and refuses invalid or oversized graphs. Owned
record/array result reconstruction remains a proposal; this work is not installed.
