# Ordinary JS integration of native output chunks

The checked JS B1 candidate passes the selected frontend gate and preserves all
24 measured C outputs, but its six-case geometric mean request time is **4.11%
slower** than the Phase88 checked B1. Whole-process time rises **1.09%**. This
does not support unconditional promotion of chunks into ordinary JS hosting.
The native-host speed result and this JS-host result are separate measurements.

## Inputs and correctness

The isolated project starts from all333 authenticated source/tool/test files in
the Phase88 development snapshot. All132 production Bend modules and the module
manifest matched that baseline before applying exactly ten chunks-v2 overrides.
Those overrides include the owned match-composition change. No native entry,
cache decoder, foreign-effect extension or native String equality adaptation is
part of this ordinary JS project. Production and installed images are unchanged.

Both stages are upstream-built checked B1 images with the same maintained
`equality` development profile, not genuine self-produced B2:

| Role | Checked raw API SHA256 | Selected equality API SHA256 |
| --- | --- | --- |
| Phase88 baseline | `95c7f6282e238b91ddf9a03adf0f55bfc2e2c1f43f275bf90f0726def2df1bca` | `fc488307466359595cb7d98062fb108a3b54503e852ba60d695afb2d0d93ce6d` |
| Phase89 chunks | `a7825ecc385e5963ac06ab084386a9a549fa03e1dd71e9184b3c07bcf0ae79be` | `9ce2015d10377cb1614c91a1cad89bcbbec0e522880677f2f6327d9a89ec62a9` |

The candidate's checked acquisition plus strict frontend36 workflow takes36.10s
and peaks at1,618.52MiB tree RSS. Reference/candidate both pass36 selected probes;
exact differences and discrepancies are zero. Expected proof-trust/frontend
refusals are retained, not changed into successful language acceptance.

The paired plan authenticates both raw-to-equality derivations, completed checked
builds and strict frontend gates. Both roles use identical host/runtime files,
Node24.18.0, CPU3, a1GiB heap, a2GiB RSS ceiling and a4GiB available-memory floor.
They prepare separate API-specific Base caches; no cache is borrowed across APIs.

All26 guarded jobs pass: two preparations and24 requests. Every request enables
the report, includes checking and C emission, and matches its complete retained
Phase88 B2 C oracle. The analysis additionally rehashes both retained output
copies per request. No new C executable or compiled-program speed measurement is
needed for byte-identical output. This six-source gate is not full conformance.

## Cold request results

Each cell lists the two raw rounds in milliseconds. Ratios are candidate/baseline;
the median of two values is their arithmetic midpoint. Pair order is reversed
between rounds. Imports and Base preparation are outside the request stopwatch.

| Case | Baseline samples ms | Candidate samples ms | Median B/C ms | Median ratio | Paired ratios |
| --- | --- | --- | --- | --- | --- |
| Map | 2729.36 /2175.02 | 2412.62 /2397.75 | 2452.19 /2405.18 | 0.9808 | 0.8840 /1.1024 |
| Small | 292.85 /281.16 | 299.21 /288.65 | 287.00 /293.93 | 1.0241 | 1.0217 /1.0266 |
| Functions65 | 685.60 /666.00 | 765.26 /737.30 | 675.80 /751.28 | 1.1117 | 1.1162 /1.1071 |
| Numeric | 477.98 /463.21 | 515.31 /494.25 | 470.60 /504.78 | 1.0726 | 1.0781 /1.0670 |
| Lexer | 1137.08 /1104.59 | 1214.69 /1177.88 | 1120.84 /1196.29 | 1.0673 | 1.0683 /1.0663 |
| Unicode | 295.94 /288.45 | 294.30 /287.71 | 292.19 /291.01 | 0.9959 | 0.9945 /0.9975 |

Equal-case geometric mean of median ratios: **1.04108**. Geometric mean of all
twelve paired ratios:1.04218. These are descriptive summaries of two rounds,
not confidence intervals or evidence of universal performance.

Functions65 is consistently10.7–11.6% slower, Numeric6.7–7.8% and Lexer6.6–6.8%.
Their direction survives order reversal. Map is the unstable case: baseline
falls20.3% between rounds while candidate changes0.6%, reversing the pair result.
Do not dismiss the Functions65 regression as isolated noise because its first
whole-process sample is longer. A focused four-pair Functions65 repeat would be
reasonable if promotion depended on its precise magnitude; another complete
survey would add less information than the smaller architectural ablation below.

## Whole-process cost and preparation

These guarded process medians include startup, all frozen-input hashing, imports,
output hashing/writing and report work. They are not equivalent to user CLI or
request latency; their fixed overhead dilutes compiler request differences.

| Case | Baseline process ms | Candidate process ms | Ratio |
| --- | ---: | ---: | ---: |
| Map | 3648.01 | 3572.55 | 0.9793 |
| Small | 1412.94 | 1393.09 | 0.9860 |
| Functions65 | 1861.07 | 1983.86 | 1.0660 |
| Numeric | 1586.95 | 1587.16 | 1.0001 |
| Lexer | 2221.42 | 2303.89 | 1.0371 |
| Unicode | 1372.72 | 1372.01 | 0.9995 |

Equal-case median process ratio is1.01088. All26 guarded jobs occupy59.95s;
the24 request jobs occupy48.63s. Peak tree RSS is376.68MiB. Single Base preparation
samples are5161.89ms baseline and3854.46ms candidate, with process costs6335.75ms
and4987.87ms. They are separately reported single observations, not a repeatable
Base-speed claim or credit against request regressions.

## Decision before the owned-only ablation

Keep the chunks candidate isolated pending an **owned-composition-only** ordinary
JS ablation. That variant changes one bridge module, removing repeated ownership
operations while keeping string bodies. Check it through the same strict B1
workflow and six-case/two-round comparison. This distinguishes the two mechanisms
more directly than repeating the combined candidate until a favorable aggregate
appears. If chunks remain slower in JS, keep them confined to an explicitly
identified native-host variant rather than silently changing the default.

Defer the23-source JS-output continuity campaign until an ordinary-JS candidate
is selected. Reuse the existing Phase82 full-output method, comparing the selected
checked B1 against the frozen Phase88 checked B1; do not describe it as B2 or
reuse native-only entry images. No new continuity target has run in this task.

Evidence: [all samples and verified identities](js-integration.json),
`selfhost/build/phase89/js-chunks-paired02/plan.json`, its26 guarded reports,
`js-chunks-development01/validation-001/report.json`, and
`js-chunks-project01.receipt.json`. The incompatible Python3.9 hashing call and
native guard `path`/`file` schema mistake are retained in
`offline-method-failures01`; corrected actual-input preflight is recorded in
`offline-method-preflight02.json`. Syntax parsing alone did not validate either
runtime compatibility or input schemas. Existing plan/method pins stay unchanged.

## Completed owned-only ablation

The follow-up isolates the one-module owned match-composition change, without
the chunk representation. Its shadow project uses the same333 baseline files and
132-module manifest, overriding only `src/back/native/bridge.bend` (+14 physical
lines). The checked raw API is
`3b5799998b92f9588d0210ae8acdd4726f850332ee102a227b2a86186b5d541b`;
the selected equality API is
`cd50fb563fb1eb49a7688b25f6ef20dc8b0df99284480d7c99f68632a8a2e381`.
The Phase88 baseline remains `fc488307…`.

The owned-only checked workflow takes35.83s and peaks at1,664.61MiB. Its strict
frontend36 gate passes with zero exact differences and discrepancies. All26
paired jobs pass, and all24 full C outputs match the same retained oracles;
the offline analysis rehashes the actual output copies. No target was run by
the reporting task. The previous chunks plan and method remain frozen.

Request samples below are milliseconds, with candidate/baseline ratios. Each
role again has its own freshly prepared API-specific Base cache and two rotated
cold rounds under the same resource configuration.

| Case | Baseline samples ms | Owned samples ms | Median B/O ms | Median ratio | Paired ratios |
| --- | --- | --- | --- | --- | --- |
| Map | 2173.46 /2214.28 | 2202.16 /2255.18 | 2193.87 /2228.67 | 1.0159 | 1.0132 /1.0185 |
| Small | 281.08 /284.25 | 282.35 /284.20 | 282.66 /283.28 | 1.0022 | 1.0045 /0.9998 |
| Functions65 | 668.74 /667.60 | 667.25 /668.47 | 668.17 /667.86 | 0.9995 | 0.9978 /1.0013 |
| Numeric | 459.40 /461.87 | 472.50 /461.31 | 460.64 /466.90 | 1.0136 | 1.0285 /0.9988 |
| Lexer | 1099.48 /1096.54 | 1175.31 /1100.49 | 1098.01 /1137.90 | 1.0363 | 1.0690 /1.0036 |
| Unicode | 309.50 /288.12 | 310.43 /288.38 | 298.81 /299.40 | 1.0020 | 1.0030 /1.0009 |

The equal-case geometric mean of median request ratios is **1.01150**:1.15%
slower. The geometric mean of all paired ratios is1.01139. Functions65 is
effectively unchanged; Numeric and Lexer vary between rounds, while Map is
slower in both. None demonstrates a useful JS-host gain. Two rounds do not
establish the precise size or statistical significance of these small changes.

| Case | Baseline process ms | Owned process ms | Ratio |
| --- | ---: | ---: | ---: |
| Map | 3291.09 | 3372.80 | 1.0248 |
| Small | 1341.40 | 1382.47 | 1.0306 |
| Functions65 | 1771.70 | 1761.00 | 0.9940 |
| Numeric | 1556.10 | 1535.69 | 0.9869 |
| Lexer | 2178.38 | 2292.28 | 1.0523 |
| Unicode | 1431.15 | 1420.84 | 0.9928 |

Whole-process median ratio is1.01328, with the same harness-overhead caveat as
above. All26 guards occupy56.12s, including46.67s for the24 request jobs; peak
tree RSS is393.48MiB. Per-pair process values, preparation observations, complete
sample identities and lineage are retained in
[the separate owned-only record](js-owned-integration.json).

**Final JS decision:** keep both owned composition and chunks in the explicit
native build profile. Leave canonical production source and installed Phase82
unchanged. The native ownership/string-cost gains do not transfer automatically
to the JS host. The owned-only ablation removes the combined candidate's large
Functions65 slowdown but provides no positive JS result warranting promotion.
No additional JS repeat or23-source JS-output continuity run is needed for this
decision because production JS is unchanged. The two separately paired campaigns
do not justify subtracting their percentages to estimate an exact chunk-only
cost; such attribution would need its own controlled comparison.
