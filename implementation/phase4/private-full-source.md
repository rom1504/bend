# Final private compiler: complete-source measurements

Status: complete. Both opposite-order pairs passed. The corrected default
private image and the Boolean/stability profile compile the complete final Bend
compiler into exactly the proven H library. This closes the emission gate that
initially found the block-local `F` capture bug.

| Run order | Compiler request | Complete CLI process | Maximum child RSS |
| --- | ---: | ---: | ---: |
| Control A | 778.536 s | 780.022 s | 4,333,668 KiB |
| Profile A | 747.601 s | 749.523 s | 4,464,192 KiB |
| Profile B | 822.745 s | 824.998 s | 4,384,292 KiB |
| Control B | 829.734 s | 831.247 s | 4,244,100 KiB |

The profile uses **3.91% and 0.75% less process wall** in the two pairs.
The two-observation means (also their medians) are 805.634→787.260 seconds,
**2.28% less wall**, with 3.16% more mean maximum-child RSS. This is a small
whole-source gain with visible drift, not the 11.3% gain measured on the compiler
core. Candidate A→B increases about 10.1%; control A→B increases about 6.6%.
Two samples per variant cannot establish a narrow uncertainty interval.

Source SHA is `34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122`;
all four actual outputs are 1,143,517 bytes, exactly equal to H
`b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`.
The corrected default is `61e7d94c…`; the profile is `4318bbcd…`. The
[image archive](private-final-images/README.md) preserves their complete immutable
inventories, and the [source capsule](final-source-capsule/README.md) preserves
the checked source/B1/H/runtime.

All four runs use one fresh canonical private CLI process, the same frozen source,
canonical Base, Node v24.18.0, CPU2, 4 MiB stack, 12 GiB worker heap and one-hour
deadline. Per-image Base caches were previously validated; their actual book
payloads are identical, with different compiler identities and generation times.
The caches are read inside the compiler request. OS caches are not flushed.
Other physical cores run separate experiments. A short unpinned, read-only C
inspection overlapped profile B around 18:13:40–18:14:05 UTC (conservative window);
its effect is unknown. The later serial/frontend/native workloads also differ
over time. All four valid observations are retained. Python measures outer process
wall and waited-descendant CPU; `RUSAGE_CHILDREN.ru_maxrss` is the maximum child
resident-set observation, **not a simultaneous sum of the process tree**.

The request, launcher, outer measurement, source/input audits and emitted bytes
agree. The [complete four-run archive](private-full-final-evidence/comparison.json)
retains every planned observation, actual consumed caches, launcher tools and
image manifests. The audit tool preserves its own source and selected plan and
refuses missing/duplicate observations, inconsistent aliases, changed inputs,
failed launches or nonidentical actual H output. The
[independent review](private-full-audit-review.md) initially covered the first
pair; nine refusal tests hardened the auditor before the four-run archive.
The [reviewed first pair](private-full-first-pair-reviewed/comparison.json),
[original first audit](private-full-first-pair/comparison.json) and intermediate
timestamp-parsing refusal remain preserved; no compiler measurement changed.

The earlier 602-second failed attempt remains in
[the lexical-scope report](private-scope-fix.md). That error observation supplies
no successful-compilation speedup. Its scope bug is fixed, tested on the original
escaped-string reproducer and independently reviewed. The completed public fixed
point and earlier bounded program observations remain separately identified.

For context, public H took 1,591.343 seconds in the checked fixed point, while
pinned TypeScript's three-run process median is 51.443 seconds for the identical
source and library-root policy. The private-profile mean is about 2.02×
faster than that public-H observation and still about 15.30× the TypeScript time.
Its observed range is about 14.57–16.04× the TypeScript median.
Those are **descriptive cross-workflow ratios**, with different run/cache/launch
histories; they are not the controlled private-control/candidate comparison.
Checked B1's full emission took 670.766 seconds, and native O2's three-run median
is 245.364 seconds. Use [B1's seconds-scale focused loop](development-final.md)
for edits, and keep full source emission as an integration gate.

From `selfhost/`, the permanent wrapper reproduces a single observation:

```sh
python3 tools/performance/phase4/private-full-source.py \
  /path/to/node tools/private-compiler/run.mjs IMAGE_DIRECTORY \
  CHECKED/compiler.bend PROOF/stage2.mjs NEW_MEASUREMENT_DIRECTORY \
  --cpu=2 --timeout-ms=3600000
```

The completed report retains every planned run and both orders. A missing,
failed or changed observation would withhold a complete performance summary.
