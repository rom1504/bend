# Phase173 evidence05: automatic owned decomposition

This checkpoint preserves the completed automatic06 and QBE-scoped v3/API07 experiments, including failures. It does not promote a compiler or establish whole-compiler speedups. The earlier capsules retain the qualified producer, baseline source, toolchain and runtime evidence.

## What was demonstrated

- Automatic06's checked Bend transformation passed **16/16 finite controls**. It admitted two pattern-substitution rows and one unrelated Packet row; it admitted **zero** layout-substitution rows. The complete-value native outputs matched independent upstream/constant-program observations.
- Four paired digest rounds measured **104.575 → 93.018 ms** for the real pattern computation (**0.889483×**, 11.05% lower), and **66.256 → 34.263 ms** for Packet (**0.517128×**, 48.29% lower). Full-value pairs are below the timing floor and establish correctness only. These are extracted workloads, not self-build or broad user-program figures.
- Pattern events reduce keeps by 53,448, sinks by 201,504, drops by 365,456 and takes by 49,352, without reducing logical allocation or scheduler counts. Packet removes 1,320,000 drops, 10,000 keeps, 30,000 sinks, 10,000 takes and 10,000 logical allocation requests. Instrumented counts explain categories of work; their timings are not clean performance measurements.
- Six hosted requests provide three cost comparisons. Pattern is measured twice, layout once; no confidence interval or general overhead bound is claimed. Layout emitted **byte-identical QBE** while paying extra analysis cost. Exact wall/stage ratios are in `automatic-results-summary.json`.
- QBE-scoped v3/API07 passed **32/32 controls**. Original IO08 is independently executed upstream and its QBE request has permission but **zero transformed rows**. The separate actual Packet IO source has **one transformed row**, upstream output agreement, native baseline/candidate agreement, and preserved complete output order. Its few-millisecond pair is correctness evidence only. Neither these finite controls nor ordinary source checking prove whole-compiler semantic preservation; source verdicts and unsafe dependencies are retained without relabeling them as mathematical proofs.

## Failures and boundaries

Four failed checked acquisitions are retained: API02 local match, API03 match order, API04 affine duplicate consumption, API05 missing constructor annotation. Original IO oracle07 failed because a local String binding lacked an annotation; IO08 corrects that source. Every failure includes its terminal guard status, diagnostics, exact source identity and frozen changed modules. The ongoing multi-argument extension and capture04 are excluded.

## Reproduction

1. Restore the exact changed `.bend` modules in `modules/`, using `copy-provenance.json` for their historical locations. Six compiler-source manifests are projected with exact original hashes; declaration and original source-map inventories are omitted, not modified or treated as new authority. Full 1.5 MB assembled compiler sources and 4 MB original manifests are deliberately not copied per revision.
2. Source-reconstruction entries in `recipes.json` are derived from manifests and the preparation CLI. Start from the pinned canonical assembly and independently confirm each resulting source hash. Do not replace a failed revision with a later corrected module. Small Packet/IO sources and tiny upstream/constant/native output oracles are included verbatim under `fixtures/`.
3. Reacquire checked APIs using the exact upstream/Base/carrier/stamp identities. Follow the original exact target invocations in `receipts/*/process.json`; use fresh output directories and the same single execution lane, resource limits and runtime policy. No target was run to package this checkpoint.
4. For full Packet values, preserve the complete upstream value → constant Bend source → independently checked native readback → baseline/candidate stdout chain. Digest output alone is not the semantic gate. Preserve the earlier pattern full-value oracle by the pinned prior evidence.
5. Reproduce automatic06 and v3/API07 separately: they have distinct entry hooks and scopes. The admission observations must agree on owner/row counts as well as control outcomes. For IO, independently reproduce both original zero-row control and actual one-row Packet computation.
6. Benchmark clean executable pairs separately from instrumented event runs. Keep all paired samples, failed experiments and unsupported cases. Request timings are hosted compiler costs and must not be reported as native compiler throughput or full cold builds.

`automatic-results-summary.json` derives ratios and counts from retained receipts only. `inventory.json` hashes every capsule file except itself. `copy-provenance.json` covers verbatim copies. `referenced-artifact-pins.json` records actual embedded identities, not a claim that omitted large artifacts remain available. Historical harness files are copied only when their current bytes exactly match an original input pin; mismatches, if any, are explicit. No QBE, assembly, binaries, compiled APIs or large complete oracles are included.
