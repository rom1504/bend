# P52-002: inline exact native operations with inert arguments

Status: the precommitted eight-point screen completed on checked direct06.
All output checks and72 timing samples passed. The measured7.4% geometric mean
speedup misses the prewritten10% target. The subsequent static byte proof passes
all eight modules, and the semantic suite passes95/96 scenarios with only the
previously recorded NaN-payload failure. This is not a blanket semantic pass.

## Hypothesis and existing evidence

The completed direct05 batches expose a recurring residual gap: Mandelbrot and
its grid variations run at1.62–1.96× TypeScript, and raytrace variants at about
2.02–2.20×. Edit distance is about1.41–1.46×. Other cases are close to parity.
These are separate same-run results from
`selfhost/build/phase52/full-direct05-batch{0,1}/report.json`; batch2 was held,
so direct05 has30/45 timed points and444 passing samples, not a full45 result.

The general candidate inlines an already-admitted exact native primitive at a
call site only when every emitted actual is inert: a decimal literal,
`true`/`false`/`null`, a positional/eta parameter, or an exact generated local-use
wrapper. Computed expressions, conversions and calls keep the previous named
wrapper. Existing primitive templates and native identity/type admission stay
authoritative. Emitter-owned reachability can then remove wrappers that have no
remaining reference; selected native roots must remain available.

This could expose simple arithmetic, array access and F32 operations to the JS
optimizer while avoiding call overhead. It is not restricted to a benchmark or
source name. It also must not reorder host getter access around effectful actuals,
turn eager arguments into short-circuit evaluation, duplicate an effectful
argument, change partial-call staging, or treat an ordinary native-looking
source definition as an intrinsic.

## Precommitted measurement

The [profile](../../selfhost/tools/performance/phase52/intrinsic-profile-v1.json)
has SHA256 `11e41bca09263752a3bec9500d0cc8e99731bd614398d3631a8206cdf9f637d9`.
Its exact eight IDs, sources, points and oracles are frozen:

1. `mandelbrot`
2. `local-pair`
3. `editdist`
4. `variation-ray-active-64-2440`
5. `variation-local-fold-8192-123`
6. `test-morning-program`
7. `coverage-expression-128`
8. `coverage-closures-64`

The three roles are **checked direct05**, the new checked intrinsic candidate,
and pinned TypeScript. The direct05 role is a data-only byte-exact remap of
`prepared-direct05-full`; TypeScript bytes come from the unchanged `reference01`.
This is not the earlier Phase51-baseline screen, and old timing receipts will
not be relabeled. Both Bend candidates use the same direct callable contract
and the same direct runtime. Each fresh timing run supplies its own TypeScript
denominator.

Use the unchanged60 profile:3 rotated rounds×8 points×3 roles=72 fresh samples.
Each call checks the exact oracle. The existing60-second inner budget is retained;
the chosen points have bounded small inputs. A deadline or incomplete rotation
is a failed/inconclusive screen, not permission to drop a case, extend only one
role, or infer the missing samples. There is no extra nested process guard.

## Acceptance and falsifiers

- All eight checked emissions and exact-output smoke cases must pass. All72
  timing samples must complete without oracle or resource failure.
- Require a broad measured benefit: target at least1.10× equal-point geometric
  speedup over direct05, with improvements exceeding5% in at least three distinct
  sources. These are engineering selection thresholds, not significance tests.
- Any point more than10% slower than direct05 is a review blocker pending a
  narrowly justified follow-up or rejection. Report every point and all timing
  drift; no successful-subset average qualifies this gate.
- The selected semantic controls must preserve exact native admission, native
  roots, partial application, host getter/effect order, eager Bool arguments,
  once-only complex Nat arguments and array aliasing. The pre-existing NaN
  payload failure remains visible and does not excuse a new discrepancy.
- Establish static byte attribution: runtime/support and source inputs remain
  identical; changed generated bodies must be accounted for by exact admitted
  atomic primitive expansion and resulting unused native-wrapper pruning. The
  simultaneous packaging/path fix is not credited with speed. If unrelated
  emitted changes remain, do not call the comparison an isolated intrinsic test.

The patch combines call-site expansion and wrapper pruning; even a successful
byte proof does not separately assign a percentage of the gain to those two
effects or to the JavaScript engine's response. A failed screen is retained and
the original direct05 remains available. A successful screen is followed by the
selected image's semantic and full45 gates, rather than stitching together
timing rows from different compilers.

## Commands, not executed by this document

The lead owns target scheduling. The prospective successor label is06; update
attempt/output labels together if it changes. Original consumed tools remain
frozen. The small comparison wrapper only adds exact profile/role/contract checks
and a separate receipt; `programs/run.py` and `programs/execute.mjs` are unchanged.

```bash
taskset -c 0 python3 selfhost/tools/performance/phase52/direct-reference.py \
  --direct selfhost/build/phase52/prepared-direct05-full/manifest.json \
  --reference selfhost/build/phase52/reference01/manifest.json \
  --out selfhost/build/phase52/intrinsic-reference05

python3 selfhost/tools/performance/phase52/prepare-v2.py \
  --attempt selfhost/build/phase52/checked-direct06 \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --cases mandelbrot,local-pair,editdist,variation-ray-active-64-2440,variation-local-fold-8192-123,test-morning-program,coverage-expression-128,coverage-closures-64 \
  --role candidate --backend direct \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --timeout 180 \
  --out selfhost/build/phase52/prepared-direct06-intrinsics

python3 selfhost/tools/performance/phase52/smoke.py \
  --manifest selfhost/build/phase52/prepared-direct06-intrinsics/manifest.json \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --out selfhost/build/phase52/smoke-direct06-intrinsics

python3 selfhost/tools/performance/phase52/compare-intrinsics.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/build/phase52/intrinsic-reference05/manifest.json \
  --candidate selfhost/build/phase52/prepared-direct06-intrinsics/manifest.json \
  --cases mandelbrot,local-pair,editdist,variation-ray-active-64-2440,variation-local-fold-8192-123,test-morning-program,coverage-expression-128,coverage-closures-64 \
  --budget 60 --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --rss-mib 2048 --available-mib 4096 \
  --out selfhost/build/phase52/screen-direct06-intrinsics
```

No target is launched until the lead confirms the checked image and grants the
serialized slot. Every output directory must be fresh.

## Measured screen outcome

The lead authorized the frozen06 image and the serial acquisition/smoke/timing
sequence. All eight checked emissions passed, all eight default-stack smoke
cases passed, and all72 fresh rotated samples passed exact output oracles. The
60-profile comparison completed in58.171909s without extending its budget.

| Point | Same-run TS µs | Direct05 µs | Direct06 µs | 05/06 speedup | 06/TS |
|---|---:|---:|---:|---:|---:|
| Mandelbrot | 50.639313 | 83.240082 | 80.998144 | 1.027679× | 1.599511× |
| Local pair | 1234.788508 | 1753.628884 | 1629.694924 | 1.076047× | 1.319817× |
| Edit distance | 5033.082452 | 7083.042227 | 6516.085609 | 1.087009× | 1.294651× |
| Active ray64 | 302.753038 | 613.465396 | 465.985040 | 1.316492× | 1.539159× |
| Local fold8192 | 124.628170 | 149.423272 | 137.118685 | 1.089737× | 1.100222× |
| Morning | 3.195387 | 3.068203 | 2.884187 | 1.063802× | 0.902610× |
| Expression128 | 9.200593 | 9.351527 | 9.713546 | 0.962731× | 1.055752× |
| Closures64 | 6.088617 | 6.439853 | 6.412716 | 1.004232× | 1.053230× |

Equal-point geometric means are direct05/TS **1.301616×**, direct06/TS
**1.211645×**, and direct05/direct06 **1.074256×**. Five distinct sources improve
by more than5%; expression evaluation is3.87% slower, and no point is more
than10% slower than05. The1.10× geometric mean target is **not met**. This is a
modest broad benefit with a larger raytrace gain, not a predeclared selection
gate pass or evidence of full parity.

The checked build took59.007782s and peaked at1,474,224,128 process-tree RSS
bytes. The eight acquisitions used45.659841 summed child-wall seconds and
peaked at580,988,928 bytes. No heap/RSS/headroom limit was raised. The unchanged
direct runtime remains
`417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a`.
The candidate API is
`472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a`,
with compiler source
`3c5671579628de5c113907403188df17e3d35a15dd520bc1d20b6dc3263d3513`.

Evidence under `selfhost/build/phase52/`:

- `intrinsic-reference05/manifest.json`, SHA256
  `3b86bff28d5bc9ad987679eaaf4774041d4ac7302710c802160a6ed917971d83`:
  explicit direct05 baseline role remap,16 exact copied role/module artifacts.
- `prepared-direct06-intrinsics/manifest.json`, SHA256
  `22cf06517c9b9a5909363382abc54519323e7b4fd31f71480fb3e70aa4988189`.
- `smoke-direct06-intrinsics/report.json`, SHA256
  `fcb6baf8c3312366522a1d66641f934c3a545c67b14e21db49dd372304a04930`.
- `screen-direct06-intrinsics/report.json`, SHA256
  `d628541b15e320a88ddccdf01aafaf62aee950a4950da2c45e6614b90063a9b1`.
- `screen-direct06-intrinsics/phase52-comparison.json`, SHA256
  `a36a16e0facc8a03f0eb9d7885aa13c7cae0feffd7c3ba35eea698aa4b251d75`:
  same direct ABI and explicitly different baseline from the earlier Phase51
  comparisons. Neither original05 batch was rewritten or relabeled.

Subsequent static attribution passed all eight modules in
`intrinsic-byte-proof06/report.json`, SHA256
`3c26b3a3661082491cf8151236bf791a707fed13a759f83e3d3cae2a916de0a8`.
Starting from exact05 bytes, the proof expands375 admitted atomic call sites
using the89 unchanged native templates and removes52 now-unreferenced native
wrapper declarations. These two transformations reconstruct every06 module byte;
the simultaneous packaging changes introduce no other bytes in this profile.
All614 consumed identities were rechecked. These are static site counts, not
executed-call counts, and they do not separate expansion from pruning or explain
how V8 distributes the measured gain.

The completed selected semantic run is
`semantic-direct06-controls01/report.json`, SHA256
`5357c24a5a1c9623bb25278e0b60e6d4b79b377653a841db08ba088f47485bf8`:
95/96 scenarios pass, including the six new native effect/order controls. The
one unchanged NaN-table case still fails its independent40 oracle: TypeScript
returns1 and direct returns39. The report correctly has `pass:false`; the
[qualified-scope receipt](../../selfhost/tools/performance/phase52/semantic-qualified-scope-v2.json)
records the limited result. No new discrepancy was observed, but neither this
suite nor the eight-point timing screen establishes full conformance. The full
selected45-point performance campaign is still pending.
