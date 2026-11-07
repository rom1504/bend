# Phase173 evidence08: final bounded checks and context experiment

All files here are receipts or source/metadata snapshots. No compiler target ran to package this capsule, and no production source or installed compiler is changed by it. Previous native source, frozen automatic08 modules and N1/N2/N3 identities remain in evidence06/07 and are referenced by inventory hashes.

The contextual source overlay passed upstream source checking and complete-value differential observation. Native complete output also matched the independently checked constant oracle. Its four balanced digest pairs measured **67.553 → 68.174 ms**, ratio **1.009182×**. This is a neutral result, not a speed improvement; the candidate was not selected. The short complete-value pair is below the timing floor. The overlay therefore remains experimental despite its correctness controls.

The original context baseline09 machine build remains **failed**: its guard stopped for disk budget after completed emission. Baseline10 explicitly authenticates and consumes that retained QBE with the original emission provenance. It does not retroactively turn the failed complete build into a success. The streamed pair harness retains and checks image, source, runtime, toolchain, stream-digest and complete machine-construction identities without requiring hot copies of assembly or object files. Its read-only audit includes 2 accepted controls and 15 expected refusals. These are provenance controls, not compiler proofs.

Candidate N2 passed **64/64** finite native cases, with zero failures/unsupported cases. This is the retained focused19+broad45 finite suite, not full-language conformance. The additional six-case quality screen emitted exact reference QBE for edit distance, tree bitonic, morning, RLE, record aggregation and Map churn; it is not a new runtime benchmark score.

Generation diff08 also remains **failed**, stopped by its disk budget after producing a partial 12.6 MB report. Bounded streaming diff09 completed. It confirms exact N2/N3 QBE, assembly and object identities, and equal ELF load-image metadata/content, despite differing whole-ELF hashes. Differences outside the load image are not claimed to affect execution. Its declaration add/remove counts include generated identity movement and must not be interpreted as thousands of semantic changes. Both tool revisions and the failure guard are retained; the partial report body is pinned but omitted.

Storage07 archived N3 assembly/object; storage08 archived context baseline/candidate assembly/object; storage09 archived N2 QBE only after the completed fixed-point, diff and finite-suite consumers. Exact archives are independently member-verified before pruning. All executable/source/runtime authorities remain protected. These later receipts supersede earlier descriptions of which intermediate files were hot; archive bodies and large compiler/IR products are omitted.

## Cost census

The final snapshot contains **307 guard receipts**, **281 successful** and **26 failed** terminal runs, totaling **3180.862 s (53.01 min)** of guarded execution-lane time. This excludes agent reasoning, quota/billing, unguarded work and overall elapsed research time. It also avoids double-counting nested qualification cases and native-build stages.

| Group | Runs | Failures | Guarded seconds | Maximum sampled tree RSS |
|---|---:|---:|---:|---:|
| api_acquisition | 56 | 14 | 422.502 | 2333.6 MiB |
| native_build | 90 | 3 | 1010.328 | 844.1 MiB |
| runtime_pair | 52 | 2 | 36.191 | 31.2 MiB |
| observation | 103 | 6 | 1403.884 | 1614.0 MiB |
| other | 6 | 1 | 307.957 | 1913.0 MiB |

`guard-cost-census.json` retains every individual receipt pin, its primary script, grouping rule, terminal status, time and sampled RSS. Observation includes hosted compiler requests, semantic controls, profiling events and generation-diff analysis; it is not synonymous with time spent verifying. Unfinished/missing receipts, if any, are explicit and excluded from sums. RSS peaks are maxima/medians, not additive memory costs.

## Reproduction and retained scope

Reconstruct context source from the pinned canonical assembly plus exact small drivers and higher/lower overlays in `modules/`. The six source manifests are projected with original hashes and explicit omission of declaration inventories. The 300 KB assembled context sources and 3 MB full compiler are deliberately not duplicated. Check each reconstructed source SHA-256 before acquisition. The native constant oracle, full upstream observation and tiny digest expectations are included; digest equality alone is not the complete semantic gate.

`recipes.json` contains original guarded target commands and explicitly reconstructed source-preparation commands. Use fresh outputs, the same independently checked images, exact source/Base/carrier/runtime/toolchain identities, and the controlled execution lane. `final-results-summary.json` derives its results from retained receipts only. Source audits are labeled as source audits even where targets were later run.

`inventory.json` hashes every retained file except itself. `copy-provenance.json` maps verbatim copies. Historical tools are retained only at their recorded input identities; mismatches are explicit. `pending.json` records any still-incomplete requested items. No root README or experiment ledger was edited by this collection.
