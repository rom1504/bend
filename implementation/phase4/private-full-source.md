# Final private compiler: complete-source measurements

Status: first opposite-variant pair completed; reverse pair is running. The
corrected default private image and the Boolean/stability profile both compile
the complete final Bend compiler into exactly the proven H library. This closes
the emission gate that initially found the block-local `F` capture bug.

| First pair | Compiler request | Complete CLI process | Maximum child RSS |
| --- | ---: | ---: | ---: |
| Corrected private default | 778.536 s | 780.022 s | 4,333,668 KiB |
| Boolean/stability profile | 747.601 s | 749.523 s | 4,464,192 KiB |

The candidate uses **3.91% less process wall** in this pair, with **3.0% more
maximum child RSS**. Its 11.3% compiler-core gain does not transfer unchanged to
the whole compiler. The reverse pair is needed to assess run-order and control
drift; this first pair is not being presented as a repeated estimate.

Source SHA is `34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122`;
both actual outputs are 1,143,517 bytes, exactly equal to H
`b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`.
The corrected default is `61e7d94c…`; the profile is `4318bbcd…`. The
[image archive](private-final-images/README.md) preserves their complete immutable
inventories, and the [source capsule](final-source-capsule/README.md) preserves
the checked source/B1/H/runtime.

Both runs use one fresh canonical private CLI process, the same frozen source,
canonical Base, Node v24.18.0, CPU2, 4 MiB stack, 12 GiB worker heap and one-hour
deadline. Per-image Base caches were previously validated; their actual book
payloads are identical, with different compiler identities and generation times.
The caches are read inside the compiler request. OS caches are not flushed.
Other physical cores run separate experiments. Python measures outer process
wall and waited-descendant CPU; `RUSAGE_CHILDREN.ru_maxrss` is the maximum child
resident-set observation, **not a simultaneous sum of the process tree**.

The request, launcher, outer measurement, source/input audits and emitted bytes
agree. The independently reviewed
[first-pair archive](private-full-first-pair-reviewed/comparison.json) retains
both observations, actual consumed caches, launcher tools and image manifests.
The audit tool also preserves its own source and the selected comparison plan.
The [independent review](private-full-audit-review.md) confirms the actual bytes,
cache payloads and cross-record identities, and adds nine refusal checks for
malformed or incomplete evidence. The original
[first audit](private-full-first-pair/comparison.json) and an intermediate auditor
timestamp-parsing refusal remain preserved; no compiler measurement changed.

The earlier 602-second failed attempt remains in
[the lexical-scope report](private-scope-fix.md). That error observation supplies
no successful-compilation speedup. Its scope bug is fixed, tested on the original
escaped-string reproducer and independently reviewed. The completed public fixed
point and earlier bounded program observations remain separately identified.

For context, public H took 1,591.343 seconds in the checked fixed point, while
pinned TypeScript's three-run process median is 51.443 seconds for the identical
source and library-root policy. The first private-profile run is about 2.12×
faster than that public-H observation and still about 14.57× the TypeScript time.
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

The final report will retain every planned run and compare both orders. A
missing, failed or changed observation withholds a complete performance summary.
