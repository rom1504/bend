# Phase53 benchmark plan

Status: the selected ordered02 comparison is complete:45 points,23 sources,
669 samples, all output checks passing. See the [complete results](../../../../implementation/phase53/results.md)
and [bound performance summary](evidence/performance-summary.json). The commands
below retain the frozen method and require fresh output paths for reuse.
Historical Phase52 tools, raw evidence and bundles remain unchanged.

## Roles and identities

The final comparison is **selected new direct backend / prior selected direct06 /
pinned TypeScript**. Both Bend roles use `upstream-compatible-direct-v1`; this is
not the earlier comparison with Phase51's mutable descriptor interface.

The immutable prior direct06 bundle is
`../phase52/bundles/current/manifest.json`, SHA256
`cb084a94c3ff1db33d6de1bd1f30c0d009beed609ad72496ef8d52c3247cb005`.
Its actual derived-B1 API is
`472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a`,
direct runtime
`417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a`,
compiler source
`3c5671579628de5c113907403188df17e3d35a15dd520bc1d20b6dc3263d3513`.
Its legacy-runtime identity is retained metadata, not the emitted direct prefix.
TypeScript modules come unchanged from Phase52's baseline archive, manifest SHA
`31264f61e39ef80ca105eda58ca8d5447451c53cf7b36055deb21e4524b0d69e`.
The upstream pin remains `018751270e800bc222a93dad7f257083ee53a5f7`.

There are three distinct comparisons, never silently mixed:

1. Correctness/default-driver baseline versus direct06, using the frozen8 points.
   The Bend API can be unchanged while direct runtime and driver differ.
2. Optimization candidate versus that corrected baseline, on the same8 points.
   This isolates the optimization from the preceding correctness/default change.
3. Final selected candidate versus original direct06 and TS, all45 points. This
   provides the overall Phase53 result and uses the original Phase52 denominator.

[freeze-reference.py](freeze-reference.py) writes an explicit
`baseline-binding.json` containing the whole compiler identity and output-manifest
hash. [compare.py](compare.py) requires that binding; equal API hashes alone are
insufficient. The fresh-baseline path also requires `--attempt` and joins the
actual API, runtime, Base, frozen driver, direct runtime and source identities.
No historical timing is used as a denominator.

## Fixed ladder and decisions

The [profiles](profiles.json) retain the Phase37 catalog and exact point oracles.
No smaller substitute input or new checksum changes an established measurement.

| Gate | Fixed points | Preset | Required fresh samples | Purpose |
| --- | ---: | ---: | ---: | --- |
| Numeric rejection | Mandelbrot, active ray64, edit distance |20 |27 | Quickly reject numerical regressions |
| Existing intrinsic screen | Same8 sources as P52-002/003 |60 |72 | Test gain and independent-program regressions |
| Final full corpus | All45 points from23 sources, three15-point batches |600 each |219+225+225=669 | Unfiltered overall result |

The8 points are Mandelbrot, local pair, edit distance, active ray64, local
fold8192, Morning, expression128 and closures64. The full corpus preserves the
three Phase52 partitions and both equal-point and equal-source weighting.
The cheap screens are not a substitute for full-corpus coverage. This maintained
corpus informed development; it is not an untouched holdout.

Current campaign decision: root skips the optional3-point rejection screen and
uses one fixed8-point screen per candidate. Correctness/default-only baseline
measurement has no speed-win requirement. Optimization selection is precommitted
in `optimization-decision-v1.json`: at least1.05× geometric mean benefit and no
unexplained point more than10% slower. This decision precedes the measurements.

All selected checked emissions and smoke oracles must pass before timing.
A budget exhaustion or missing rotation is incomplete evidence, not permission
to report only favorable rows. Root sets the optimization's numerical acceptance
threshold before measurement. The comparison receipt's `passed` means method and
oracle success; it does not automatically declare a speed-gain threshold passed.
Correctness and default-driver changes have their own semantic gate and need not
pretend to be performance wins. Known failures remain visible until independently
fixed and qualified.

## Reused methods and resource limits

[acquire.py](acquire.py) is a31-line launcher of the hash-pinned, unchanged Phase52
`prepare-v2.py` and `emit-worker-v2.mjs`; it adds identity lineage, not a new
compiler driver. It explicitly selects **direct**. The original Phase52 labels
inside acquisition receipts identify the inherited method, not a historical
compiler. Default-driver changes cannot silently turn this into a legacy lane.
Any separate legacy/compiler-cost test must explicitly select `backend:'js'` or
use the product owner's new legacy-driver adapter; omitted selectors are not safe
legacy identities after the default changes.

Every target uses CPU3, Node24.18.0,1GiB Node heap,2GiB tree RSS and4GiB available
memory floor. Checked emissions have180-second per-source limits. Executable
parents remain unpinned so children can select CPU3; one existing shared guard
owns the hardware slot. Do not wrap self-guarded acquisition/timing in a second
shared guard. Data-only work can use CPU0; compression and large hash sweeps wait
until no timing is active. The timing worker and all warmup/calibration protocols
are unchanged. Smoke uses the unchanged Phase52 tool and carries no speed claim.

## Reference packaging: data only, once

After root authorizes data preparation, use exact existing portable modules:

```bash
taskset -c 0 python3 -B selfhost/tools/performance/phase53/freeze-reference.py \
  --out selfhost/build/phase53/reference-direct06
```

The archive contains only the required direct06 and TS modules. It does not copy
old raw campaigns or recursively archive inherited evidence. The maintained
reader verifies every archived byte and every selected source/point hash.
The role remap is explicit in provenance; original bundles remain untouched.

Data-only checkpoint: `reference-direct06` now contains45 points/90 role-point
mappings and48 exact modules in217,186 compressed bytes. The maintained reader
reopened them successfully. Manifest SHA256
`37be3740c46d98c16342448e5082313a49fdc32da806e10a75ce694934faa3d0`;
baseline-binding SHA256
`e27527a84d5ef9ce811ab3e515c858a4e414611cc2e122c6e30769fdffae6f94`.
This consumed output is immutable; a replay of the command needs a fresh path.
No source was compiled and no generated module executed by this packaging.

## Acquisition and smoke

Set `P53_IMAGE` to the root-selected attempt name; the placeholder is not an
existing result. `P53_CASES` selects the fixed3,8 or full batch IDs from JSON.
For a final acquisition use `--set full` instead of `--cases`.

```bash
P53_IMAGE=checked-corrected01
P53_CASES="$(python3 -B -c 'import json; print(",".join(json.load(open("selfhost/tools/performance/phase53/profiles.json"))["screen8"]))')"
python3 -B selfhost/tools/performance/phase53/acquire.py \
  --attempt "selfhost/build/phase53/$P53_IMAGE" \
  --catalog selfhost/tools/performance/phase37/catalog.json --cases "$P53_CASES" \
  --role candidate --backend direct \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --timeout 180 \
  --out "selfhost/build/phase53/prepared-$P53_IMAGE-screen8"
python3 -B selfhost/tools/performance/phase52/smoke.py \
  --manifest "selfhost/build/phase53/prepared-$P53_IMAGE-screen8/manifest.json" \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --out "selfhost/build/phase53/smoke-$P53_IMAGE-screen8"
```

Do not put a Phase53 wrapper around the smoke guard. Its inherited kind remains
truthful and selected module hashes determine the image it checked.

## Same-run screen and corrected causal baseline

First compare the corrected image with direct06. Later a new optimization may
use the corrected reference by changing both baseline paths together:

```bash
P53_REFERENCE=reference-direct06
python3 -B selfhost/tools/performance/phase53/compare-v2.py \
  --baseline-binding "selfhost/build/phase53/$P53_REFERENCE/baseline-binding.json" \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline "selfhost/build/phase53/$P53_REFERENCE/manifest.json" \
  --candidate "selfhost/build/phase53/prepared-$P53_IMAGE-screen8/manifest.json" \
  --cases "$P53_CASES" --budget 60 \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --rss-mib 2048 --available-mib 4096 \
  --out "selfhost/build/phase53/screen-$P53_IMAGE"
```

Build the corrected reference without executing or recompiling any program:

```bash
taskset -c 0 python3 -B selfhost/tools/performance/phase53/freeze-reference.py \
  --current selfhost/build/phase53/prepared-checked-corrected01-screen8/manifest.json \
  --attempt selfhost/build/phase53/checked-corrected01 --cases "$P53_CASES" \
  --label 'Phase53 corrected baseline: exact checked emissions' \
  --out selfhost/build/phase53/reference-corrected01
```

For the3-point rejection screen use `profiles.numeric3`, `--budget20`, and fresh
matching acquisition/output names. The60 preset is expected to complete72 samples
in roughly one minute based on Phase52; it is not a guaranteed deadline. Never
silently expand a deadline or reuse a failed output directory.

## Final45: selected candidate versus original direct06

Acquire all23 sources once for the selected image into a fresh
`prepared-$P53_IMAGE-full` directory, then smoke all45. Use the comparison command
three times, with `P53_REFERENCE=reference-direct06`, `--budget600` and case IDs
from `profiles.full45Batches[0]`, `[1]`, `[2]`, in order. Output paths are
`full-$P53_IMAGE-batch0`, `batch1`, `batch2`. Require each batch complete before
starting the next. The unchanged raytrace three-round exception gives669 samples.

```bash
taskset -c 0 python3 -B selfhost/tools/performance/phase53/aggregate.py \
  --attempt "selfhost/build/phase53/$P53_IMAGE" \
  --candidate "selfhost/build/phase53/prepared-$P53_IMAGE-full/manifest.json" \
  --baseline selfhost/build/phase53/reference-direct06/manifest.json \
  --smoke "selfhost/build/phase53/smoke-$P53_IMAGE-full/report.json" \
  --reports "selfhost/build/phase53/full-$P53_IMAGE-batch0/report.json" \
            "selfhost/build/phase53/full-$P53_IMAGE-batch1/report.json" \
            "selfhost/build/phase53/full-$P53_IMAGE-batch2/report.json" \
  --out "selfhost/build/phase53/aggregate-$P53_IMAGE"
```

The21-line adapter applies checked literal metadata substitutions to the frozen
Phase52 aggregator and pins both producers. All45/23/669 assertions, actual
attempt/runtime/driver joins, smoke/module joins, independent median recomputation,
full oracle checks, drift flags, regression lists and final rehash remain. It
writes JSON/Markdown and the same45-row SVG with the correct direct06 denominator.
It deliberately refuses a corrected-baseline input for this final overall table.

## Reuse and cost

- Never recompile the direct06 or TypeScript references; their modules already
  exist with checked provenance and exact full-output oracles.
- One prepared candidate bundle can serve many timing selections and repeated
  semantic observations while the attempt and all emission identities stay exact.
  An8-point timing screen may use a full45 manifest; this needs no re-emission.
- A new runtime, driver or compiler image needs fresh checked emission even if
  its API hash happens to be unchanged. Whole-module byte equality after fresh
  acquisition can support explicitly scoped semantic-evidence reuse, not a
  fabricated fresh execution or a historical timing denominator.
- Staged acquisitions do not currently merge different preparation receipts into
  a synthetic full report. For a likely winner, acquiring all23 sources once and
  applying3/8/full selections to that bundle avoids repeated compilation. For a
  risky prototype, acquiring3 or8 sources first saves rejection latency, accepting
  a later modest repeated-acquisition cost. Do not build another cache framework
  merely to save roughly45 seconds before a19-minute final measurement.

Observed Phase52 costs: eight source acquisitions~45s, full23~135s, eight-point
screen~58s, three full batches~1,124s (18.74min). Final acquisition+smoke+timing is
about21–23min, separately from semantic checks, installation and publication.
All estimates are planning figures, not authorization or completed Phase53 work.

## Time accounting and closure

[time-use.py](time-use.py) reuses the reviewed Phase52 interval-union producer via
15 lines of path/kind/lineage adaptation; the smoke prefix also covers the new
`smoke-checked-*` names so output gates are not counted as timing. It requires the campaign's actual
`start.json.startedUtc`, scans finished process/run receipts, deduplicates and
unions intervals, and keeps failures visible. Record final accounting only after
target jobs stop, with an explicit UTC cutoff and a fresh output:

```bash
taskset -c 0 python3 -B selfhost/tools/performance/phase53/time-use.py \
  --root selfhost/build/phase53 --end YYYY-MM-DDTHH:MM:SSZ \
  --out selfhost/build/phase53/time-use-final.json
```

This is wall occupancy, not agent work or CPU time. Residual time is mixed
analysis/coding/review/docs/orchestration/unrecorded work, not automatically
waiting. Final docs/archive/publication after the cutoff are separate. The lead
owns raw writer closure and release; no producer creates those claims implicitly.

## Launcher correction retained

The first corrected-baseline timing launch stopped in argument parsing before
creating its output or running targets. The preliminary `--baseline-binding`
parser had accepted `--baseline` as an abbreviation. The original
[compare.py](compare.py) and
`build/phase53/screen-checked-corrected01-launch-failure.json` are preserved.
[compare-v2.py](compare-v2.py) disables abbreviation in that preliminary parser
and pins its predecessor; the timing worker and argument values are unchanged.
Its no-target `--plan` preflight passed before the fresh measurement launch.

## Corrected baseline checkpoint

The corrected01 image completed checked acquisition 8/8, exact-output smoke 8/8,
and the unchanged 60 preset: eight points, three roles, three rounds, 72 samples
in 57.429 seconds. The geometric means were corrected/TypeScript 1.224461 and
original direct06/TypeScript 1.226614; original/corrected 1.001759. This screen
shows no material overall speed change and no point slowed by more than 10%.
No role/point crossed the retained 25% sample-spread or 20% absolute-half-drift
threshold. A correction-only baseline had no performance-gain requirement.

Exact reports remain in `selfhost/build/phase53/`:

- `screen-checked-corrected01/report.json`, SHA256
  `366d94dd4d3c98742ae4332b8e21a6e14b7b41237d4ebc3abd92014a3a7ae95d`.
- `screen-checked-corrected01/phase53-comparison.json`, SHA256
  `4c1d1560f76ae31af992c6ee3c6bdc3652de807853a2cfe95e15582a9cd00d5e`.
- `screen-checked-corrected01-summary.json` records all eight ratios and the
  explicit scope. These eight points do not establish full 45 performance or
  complete language/host conformance.
- `reference-corrected01/manifest.json`, SHA256
  `e2342a7b0df15789518f85a55e5df7b7cc4e6e3fbdc09730bede8c2fd8c5e56d`;
  the 58,770-byte archive holds 16 exact modules and reopens with all hashes valid.
- `reference-corrected01/baseline-binding.json`, SHA256
  `a5e5a059c3f3ef6706a00e4d050f56f9c193f2467c5da7d0d66dae2184a5c355`,
  binds the corrected runtime and driver even though the Bend API hash equals
  direct06. Use this reference only for the causal optimization screen.

Separate semantic work reported corrected core 96/96 and cold original/renamed
40/40, while two additional computed-U32 ordering differences remain visible.
The benchmark's passing scalar oracles do not resolve those separate findings.

## Ordered02 causal screen (prepared, not executed)

Semantic checks must release the target slot before these commands run. Use the
screen sequence above with `P53_IMAGE=checked-ordered02` and
`P53_REFERENCE=reference-corrected01`; retain the exact eight IDs, explicit
`--backend direct`,60 preset,72 samples and all output oracles. Its fresh outputs
are `prepared-checked-ordered02-screen8`, `smoke-checked-ordered02-screen8`, and
`screen-checked-ordered02`. The original direct06/TS reference remains reserved
for the separately authorized final45 campaign.

The checked ordered02 attempt is
`c8e1a28b53d42a44eb7d8ebe69a17fa52967359019ea8eac7bd02671e961ba0f`;
API `3e3fb8c3bc4c445567696ce62bd95979e36746ddde5bb9e0aad3038fc362c9b9`.
Its direct runtime is the same corrected
`c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23`,
and its frozen driver is the same
`eb4bb871371fb2fb61fa1c077d093a817a1f6ae35205ebb2beecfb6e064fc417`.
These artifact bytes, Base, Node and bootstrap report were independently
rehashed before measurement. This distinguishes the ordered compiler change
from the already measured runtime/default correction.

The premeasurement decision file requires at least1.05× equal-point geometric
speedup over corrected01 and no unexplained point slowdown above10%, in addition
to the independent semantic gates. Keep every row and flag, including a failed
performance threshold. Passing this screen does not itself authorize full45 or
installation; the lead explicitly selects the next campaign.

## Ordered02 causal screen outcome

The planned acquisition and smoke each passed all eight points. The unchanged
three-role screen then completed all 72 samples in 57.503 seconds with every
result oracle passing. Equal-point corrected01/ordered02 speedup was **1.068387×**;
ordered02/TypeScript was **1.130115×**, compared with same-run
corrected01/TypeScript **1.207400×**. This meets the precommitted 1.05× screen
threshold, with no point slowdown above 10% and no retained spread/drift flags.
The full campaign remains a separate authorization and qualification step.

| Point | Corrected01 / ordered02 speedup | Ordered02 / TypeScript |
|---|---:|---:|
| `mandelbrot` | 1.135010× | 1.501230× |
| `local-pair` | 1.169650× | 1.144853× |
| `editdist` | 1.118660× | 1.132820× |
| `variation-ray-active-64-2440` | 1.146810× | 1.351583× |
| `variation-local-fold-8192-123` | 1.061122× | 1.038468× |
| `test-morning-program` | 0.952317× | 0.908069× |
| `coverage-expression-128` | 1.023686× | 1.025686× |
| `coverage-closures-64` | 0.963541× | 1.045330× |

A speedup below 1 means a regression: Morning was 5.01% slower and closures64
3.78% slower. Both remain in the geometric mean. The other six cases improved;
these descriptive results do not identify the V8 mechanism or predict all45.

The original measured report is
`selfhost/build/phase53/screen-checked-ordered02/report.json`, SHA256
`f19051a93dff6a00643cc41532d74ba0b19559784c16b5827fdb792a226426f7`.
Its explicit comparison contract is SHA256
`d7d5b0e57d1b825f29a33cf8ac3a0de7d1b591fae9d673252f7a3d171efdccda`.
The data-only `screen-checked-ordered02-summary.json` records every median, ratio,
flag threshold and the original decision-file hash; SHA256
`4eef54ef4668a16fa1e5dfd6484c4fee5104ee086624f283f4f590f692ac9916`.
No point or role was dropped, and no timing was repeated to obtain this result.

The two preliminary screen summaries explicitly used a 1.25 round-spread flag.
The unchanged full45 aggregator retains the historical stricter 1.20 threshold
and absolute half-drift above 20%. Checking both screens at 1.20 also produces
zero flags (maximum spreads 1.1664 and 1.1242); original summaries are preserved.
This clarification changes neither their measurements nor acceptance decisions.

## Full ordered02 campaign outcome

The final acquisition checked all 23 source files and covered all 45 retained
points; all 45 smoke oracles passed. Three unchanged 600-second profiles then
completed 219,225,225 fresh samples: **669 total**, every result oracle passing.
Their measured supervisor walls were 365.201,377.027,378.941 seconds, totaling
1,121.170 seconds (18.686 minutes). The first attempt to launch the third batch
hit an automatic permission-review timeout before creating output or running a
sample. Its metadata is retained; the single permitted identical retry succeeded.
Completed samples were never repeated or filtered.

| Weighting | Previous direct06 / TS | Ordered02 / TS | Previous / ordered02 |
|---|---:|---:|---:|
| Equal point (45) | 1.129266× | 1.069599× | 1.055785× |
| Equal source (23) | 1.135543× | 1.078076× | 1.053305× |

Fifteen points ran faster than TypeScript; 34/45 were within ±10% and 39/45 within
±20%. Twelve points regressed versus direct06, all by less than 10%; the largest
was Evening at 3.3899%. The highest ordered02/TypeScript ratio remained the
4-grid Mandelbrot variation at 1.911888×. These are same-run medians and
geometric summaries, not confidence bounds or a guarantee for arbitrary programs.

All six flagged role/point combinations remain in both summaries: candidate
fold8192, TypeScript closures256, TypeScript list512, candidate expression128,
TypeScript records64, and candidate records256. The full report retains each
spread/half-drift measurement and the unchanged 1.20/20% thresholds. No timing
flag permits dropping a point.

The reviewed aggregator independently recomputed medians and both weights,
joined the exact attempt, runtime, frozen driver, source, output and per-invocation
oracle identities, and rehashed its inputs. Outputs under
`selfhost/build/phase53/aggregate-checked-ordered02/`:

- `report.json`: SHA256
  `2354f28489d01a5ae415f8b238353a67c275361f43031b2a9f3233e4462c1bbb`.
- `report.md`: SHA256
  `19c9a73a8061f810c134a9bc82a884f93843a405c7899ffa5ce813955ac3934f`.
- `ratios.svg`: SHA256
  `ebf884f67736b0862c1ce05291d5d4881df6019ee85df2320c3cccdba836eb22`.

Timing and aggregation are complete. These artifacts do not themselves claim
installation, portable replay, archive closure or universal conformance; the
release owner performs and records those separately.

## Final release and publication

Ordered02 is installed. Separate release qualification passes42 explicit legacy
and24 default/legacy checks, integrity before/after, relocation and copied-runtime
tamper controls. Installed direct-row acquisition passes its exact oracle.
All135 portable point/role mappings verify; final portable replay passes3cases
and27samples. See [installed release](evidence/installed-release.json),
[portable replay](evidence/portable-replay.json), [time accounting](evidence/time-summary.json)
and the [publication index](publication.json). These results retain their distinct
scopes; none establishes universal conformance or a new compiler fixed point.
