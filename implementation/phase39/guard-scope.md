# P39-002 guard-scope investigation

Status: the saved-output prototype passed 25 semantic observations and a paired
two-point screen. The checked01 compiler emits the new scope and passes 13
actual-output observations. A five-point clean comparison also passed; broader
integration remains pending. Checked01 combines this change with the countdown
optimization.

The final active-ray module's `coverage.active` root has complete admission
checks but no `regionProofOpen`. Its residual `nearest` path therefore repeats
checks. Existing `colf`/`rowf` roots already scope their proofs. The smallest
production candidate is reuse of `j_tree_scope` at `j_region_root_done`, subject
to its complete original-source graph proof and unchanged guards.

Baseline active-ray module:
`selfhost/build/phase37/variation-final01/modules/candidate/modules/raytrace-active.mjs`,
SHA256 `a4bb4434cc19e9adfbe283a2679a032ca59577c531de9d407ea627080324bfaa`.
Inputs/results are the unchanged active-ray 64/2440 and 256/2240 catalog points.
Exact expected results come from the frozen Phase37 catalog, which labels these
F32 values as TypeScript differential oracles.

The [prospective design](../../design/phase39/guard-scope.md) separates guard
amortization from activation of already-emitted finite selectors. Public mutation,
error reentry and scope cleanup remain necessary observations. An attractive
checksum timing alone cannot admit the change.

## Root-executed prototype evidence

`guard-controls01` passed all 25 observations in 1.207 seconds, at about 84 MB
peak process-tree RSS. Controls cover actual scope entry, unchanged checksums,
mutations after a successful call, Math/Number hook reentry, conservative refusal
under an unused DataView mutation, raw/partial/extra application and injected
Error reentry/cleanup. The injected error is diagnostic validation of the actual
`try/finally`, not a claim that an admitted ordinary ray program invokes a callback.

The maintained clean comparison completed in **23.176 seconds**, three paired
rounds per point/role. Values below are median milliseconds per call, with
observed minimum–maximum ranges. No counter-instrumented module was timed.

| Active pixels | Phase37 baseline | Scope | Scope, finite disabled | Pinned TS | Baseline / scope |
| --- | ---: | ---: | ---: | ---: | ---: |
| 64, start 2440 | 26.034 (25.671–26.176) | 14.922 (14.833–15.078) | 15.507 (15.365–15.926) | 0.304 (0.301–0.304) | 1.745× |
| 256, start 2240 | 107.340 (107.142–110.142) | 41.154 (40.458–44.955) | 42.386 (41.980–46.372) | 1.245 (1.243–1.251) | 2.608× |

Both scoped variants improve every baseline pair, with disjoint ranges. The
remaining scope/TS ratios in this short experiment are 49.13× and 33.06×, not
parity or language-wide estimates. At 256 the candidate's last round is slower;
its range is retained. No median is pooled across the two inputs.

Separate counters establish the changed work:

| Active pixels | Full host checks before → after | Full scalar checks before → after | Actual finite entries after | Proof opens/closes |
| --- | ---: | ---: | ---: | ---: |
| 64 | 730 → 1 | 730 → 1 | 478 | 1 / 1 |
| 256 | 2,973 → 1 | 2,973 → 1 | 1,968 | 1 / 1 |

Host guard function calls still occur; all but the outer one return under the
active proof. `localGuard` can similarly return before calling `scalarGuard`.
Disabling finite selectors retains 1.679×/2.532× baseline gains. Enabling them
adds about 3.9%/3.0% to the median speed ratio over the no-finite variant, but the
256-point ranges overlap, so that smaller marginal gain needs confirmation.

The 2.608× result exceeds the old 1.72× estimate derived from 42% sampled guard
self CPU. That profile share was not an exact removable-time partition: guard
allocations can induce GC, native work can have different attribution, and JIT
behavior can change. The ablation does not isolate those secondary causes yet.
It would be incorrect to report that 62% of execution was previously measured
inside guard frames, or to explain the complete gain by the finite entries.
An actual-candidate CPU/allocation comparison is the next attribution step.

## Minimal source change and independent review

`j_region_root_done` now wraps its already admitted body using
`j_tree_scope(book,d,j_region_helpers(s),body)`. This changes one expression,
adds no production lines, modules or runtime protocol, and retains the original
complete admission condition and generic fallback. `j_tree_scope` independently
requires the scalar root signature, residual work and complete original-source
`j_pure_graph`; failure retains the old unscoped body.

The independent optimizer agent inspected helper coverage before this edit:
`j_region_residual_proved` merges every discovered pure definition;
`j_region_helper_done` replaces only its own entry while retaining other names;
the guard list contains root plus all helpers. `JGeneric` results are forced
inside ordinary private evaluation, while delayed returns leave through `finally`.
No blocker was found. This is source review, not an executed whole-language proof.

`guard-checked-derive.mjs` verified the actual checked emission receipt,
selected attempt/API/runtime/Base/driver/source identities, one genuinely emitted
scope, byte-identical entry condition and exact unchanged dependency-name list.
Its diagnostic copies add only counters. `guard-checked-controls.mjs` passed
all 13 actual-candidate observations in **0.806 seconds**, with 78,520,320 bytes
peak process-tree RSS. Neither tool inserts a missing compiler scope.

Actual emission identities are:

- checked01 attempt: `7d64e0ba7c2b89ad8c0539cb9a2ffe47abc76421018448363c1797f248d0cd4a`;
- checked01 API: `963caaea0005026a88f2aeadd0aec0b875bd457d968a69b9b1b6150370c2e298`;
- active-ray module: `e4c5d59ff692913bee47c9a4fa68666da5040a846d4f861a2660d47289270f60`;
- emission receipt: `b69928c4bf6a9ae4f95fa4595411b48d9d8864d353a09ba2ac22c8caa5e1548a`.

The actual compiler output reproduces the 730→1 and 2,973→1 full host/scalar
check counts, one balanced outer scope, and 478/1,968 finite entries. Mutated
dependencies and live host hooks refuse the root; injected Error reentry sees
the proof suspended, and both nested/outer scopes close afterward. These
observations establish the emitted path rather than merely the saved-JS model.

An independent static walk of literal `get(G,name)` dependencies from the
emitted `coverage.active` reaches exactly the same **26 names** as its guard
array. There are no missing or surplus names in this witness: 25 are ordinary
emitted definitions and `F32.to_u32` is the separately captured native
`regionF32ToU32` leaf. The set includes the root/countdown, pixel/subray/trace,
clamp, nearest/intersection, sphere-field and shading helpers. This walk checks
the emitted dependency closure; it does not replace the original typed JPure
proof or claim that a lexical walk proves arbitrary JavaScript purity.

## Actual compiler timing confirmation

The maintained `checked01-screen01` run completed five points, five balanced
rounds and all checks in **91.331 seconds**, under the 300-second preset
(600 ms warmup, 250 ms measured target). Its ray results are below. These are
new same-run comparisons against Phase37, not ratios assembled across runs.

| Active pixels | Phase37 baseline ms | Checked01 ms | Pinned TS ms | Baseline / checked01 | Checked01 / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| 64, start 2440 | 24.735 (24.527–25.702) | 9.866 (9.842–10.009) | 0.303 (0.301–0.310) | 2.507× | 32.60× |
| 256, start 2240 | 119.852 (115.508–121.116) | 38.183 (38.085–38.855) | 1.246 (1.241–1.255) | 3.139× | 30.65× |

All five pairs improve, with disjoint observed ranges. Within-sample drift is
still material: baseline 256 slows by 24.43–32.18% from its first to second
half; candidate 64 improves by 7.81–11.24%. Candidate 256 ranges from −1.85%
to +0.80%. The ratios describe this recorded protocol, not a claim of complete
JIT steady state. Stronger gains than the earlier scope-only screen cannot be
assigned entirely to one mechanism: this compiler also narrows eligible Nat
countdowns, and the warmup/measurement protocol differs. Broader measurements
and separate diagnostic profiles remain the appropriate promotion evidence.

## Separate CPU and allocation observations

`checked01-diagnostics01` completed all 12 requested captures in 16.724 seconds.
On active ray 256, estimated sampled allocation fell from **87.184 MB to
35.641 MB per call**, about **59.1%**, using decimal MB. This is allocation
during the sampling window, not retained heap or an exact object count.

The baseline's largest self CPU site was `regionHostGuard` (25.4%); the
candidate's was `apply` (27.7%). The largest attributed allocation site shifted
from `getOwnPropertyDescriptor` (38.9%) to `apply` (25.9%). This supports the
counter evidence that removing repeated descriptor work changes allocation as
well as direct guard execution. It also identifies generic dispatch as a
remaining target. These profiles are separately instrumented observations,
with different sample totals; they do not establish a throughput ratio or an
exact causal partition of the measured gain. In particular, the combined
candidate includes countdown changes as well as the scope change.

## Final checked05 correctness closure

The final source image reacquired this owner through
`guard-final-derived01/derive.json` and reran all **13 observations** in
`guard-final-controls01/report.json`. The selected checked05 API is
`04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`;
the final active-ray checked receipt is
`final-candidate01/modules/raytrace-active.mjs.json`, SHA256
`ffd9f17bbe4076748eaf05b55b0e725b7e5303bbcadf505569a7042d479a5ab2`.
Its clean emitted module retains SHA256
`e4c5d59ff692913bee47c9a4fa68666da5040a846d4f861a2660d47289270f60`.
That byte equality is confirmed by a fresh final-image receipt, not used as a
substitute for one.

The final derivation verifies all 26 unchanged guard names. Controls again
witness 730→1 and 2,973→1 full host checks for the two active-ray cases,
balanced scope restoration, dependency mutation, host-hook reentry and staged
entry behavior. The [successful four-owner audit](new-owner-gates.md) binds
these exact final reports and the bounded control execution to checked05;
its raw receipt is `new-owner-close03/report.json`. Final guard report SHA256:
`6914e3d3c2e10a1b34fd17d29b3b36aee2852420a43b910c3a2c586bfa0ba4b7`.

This closes guard correctness and provenance for the final image. The timing
and allocation sections above remain explicitly checked01 development evidence;
the final 45-point campaign supplies the separate final performance decision.

## Evidence and reproduction

Root retained `selfhost/build/phase39/guard-derived01`, `guard-controls01` and
`guard-screen01`; their input manifests bind source/tool/module identities.
Actual candidate artifacts are `guard-actual-derived01`,
`guard-actual-controls01`, and supervisor `guard-actual-control-run01` under
the same Phase39 build directory.
Use the phase evidence capsule once published to restore ignored raw paths.

```sh
node selfhost/tools/performance/phase39/guard-derive.mjs PHASE37_RAY.mjs TS_RAY.mjs \
  selfhost/tools/performance/phase37/catalog.json NEW_DERIVED
node selfhost/tools/performance/phase39/guard-controls.mjs NEW_DERIVED NEW_CONTROLS
python3 selfhost/tools/performance/phase35/compare.py NEW_DERIVED/compare.json NEW_RUN \
  --node NODE24_ABSOLUTE --cpu 3 --budget 60
```

Derivation and controls run under the root's bounded supervisor. The comparison
owns its shared execution lock and must not be nested inside another owner of
that lock. All target jobs remain serial. The tools preserve clean and diagnostic
artifacts separately, along with failure reports and exact checked inputs.
