# Native String equality: candidate24 and candidate25 probes

Worker23 remains the installed, fully qualified compiler. Candidates24 and25 are
retained as promising **unselected prototypes**. The longer installed23→25
comparison passes and observes a 1.37766× Map/Set ratio, but benefits one corpus
source, enlarges its emitted module by 56.4%, and still shows timing drift.
There is no controlled candidate25 compiler-cost comparison or full qualification.
No further candidate or transformation is part of this phase.

## What the small proof change actually admitted

The [proposal](../../experiments/phase45/P45-024-native-string-equality.md)
adds exact native `String.eq` admission to the existing shared String signature
proof. It retains the ordinary `JWNative` call, runtime Unicode/error behavior,
Bool result boundary, descriptor dependencies and full guards. There is no new
IR operation, source-program selector or equality implementation.

The source isolation receipt (`selfhost/build/phase45/source-worker24-isolation.json`)
confirms that only `src/back/js/jpure.bend` differs from frozen worker23. The
runtime is unchanged. The checked candidate API is
`eb82df03b99ad01c72af1fc1f8cd27fd3d75dba230377e6425041d596b32c1f8`;
its shared runtime is
`4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26`.

The complete-assignment comparison (`selfhost/build/phase45/worker24-seven-static.json`)
finds exactly two changed Map/Set definitions:

| Root | Worker23 expression size | Candidate24 expression size | Result |
| --- | ---: | ---: | --- |
| `chk_order` | 1,962 | 93,735 | New guarded private graph |
| `chk_set` | 253 | 128,167 | New guarded private graph |

Neither new graph uses Number-Nat mode: its separate native whitelist still
refuses equality, retaining BigInt Nat. `main.out`, `chk_del` and the previously
admitted `chk_get`/`chk_union` assignments are unchanged. Equality closes real
first-order graphs, but does not admit the entire Map/Set root.

Generated Map/Set module size grows from **389,034 to 608,721 bytes**
(+219,687 bytes, about 56.5%). The compiler proof is small; emitting two complete
private graphs has a substantial generated-code cost. A runtime benefit must be
weighed against that cost rather than treating admission as sufficient success.

The four other acquired source modules (`local-row`, `local-fold`,
`scalar-region`, `unicode-text`) and the derived complete-row observer are
byte-identical. The acquisition therefore covers five source files, six modules
including the observer, and seven execution points.

## Executed correctness

The checked build (`selfhost/build/phase45/job-candidate24-checked-worker24/run.json`)
completed in 50.39 seconds as an enclosing job. All
eight maintained suites (`selfhost/build/phase45/qualify-worker24/report.json`)
passed; their enclosing job took 16.61 seconds. These are scoped checked B1 and
backend gates, not a new full frontend campaign or self-emitted fixed point.

Fresh baseline23, candidate24 and pinned TypeScript acquisitions of the renamed
fixture feed the native-equality controller (`selfhost/build/phase45/equality24-controls/report.json`),
which passes:

- 135 independent valid-value points across three roles: 14 recursive Bool cases
  and 121 valid String pairs, plus the five catalog points checked by the tool.
- Six activation observations covering the newly admitted roots, a genuine
  private **Char-construction** range error, and clean replay.
- Nineteen mutation boundaries: 11 native descriptor/global/`.call` cases and
  eight String method/getter cases.
- Eight error observations: six malformed **public String** inputs and two
  source-error hook/reentry cases. Malformed public input is not claimed as
  private malformed-string admission.

The controller compares exact predecessor behavior for mutation and malformed
Unicode. Global Error is intentionally supported rather than guarded out:
`bad()` suspends the private proof, and the reentrant root is independently
observed. Public String-argument equality remains generic.

## Five unchanged-code canaries

The five-canary screen (`selfhost/build/phase45/runtime-worker24-fast-five/report.json`)
passes all values in three balanced rounds per role and takes 35.11 seconds.
The ratio below is worker23 time divided by candidate24 time.

| Point | Ratio |
| --- | ---: |
| `local-pair` | 1.00476× |
| `local-fold` | 1.00106× |
| `scalar-region-0` | 1.02354× |
| `scalar-region-8192` | 1.00083× |
| `complete-generic-row32` | 0.97319× |

These modules are byte-identical. Their small timing changes are run variation,
not evidence that native equality improves unrelated execution. No gross
regression appears in this rejection screen.

## Focused timing and decision

The first Map/Set–Unicode screen overlapped with data-only receipt publishing on
CPU0. Different affinity does not remove shared-machine interference. Preserve
`runtime-worker24-mapset-unicode/report.json` as exploratory; it took 13.59 seconds
and reported a 1.06584× Map/Set ratio, which is not the selected timing evidence.

After both jobs finished, the clean repeat
(`selfhost/build/phase45/runtime-worker24-mapset-unicode-clean/report.json`) passed
all values in three balanced rounds per role and took 14.89 seconds:

| Point | Worker23 ms | Candidate24 ms | TypeScript ms | Worker23 / candidate24 |
| --- | ---: | ---: | ---: | ---: |
| Map/Set | 1.54693 | 1.32150 | 0.0210122 | 1.17059× |
| Unicode text64 | 0.236730 | 0.238365 | 0.0842504 | 0.99314× |

Map/Set is still **62.892× TypeScript time in this short protocol**. Its candidate
within-sample half drifts are +26.57%, +33.70% and +36.49%; baseline drifts range
from −7.36% to +6.14%. Thus the 1.17059× ratio is a screening observation, not a
settled throughput estimate. Unicode is byte-identical and supplies a preservation
check. These two points do not update the full-corpus worker23 metrics.

Decision: retain candidate24 as a correct scoped coverage probe, **uninstalled**.
A narrow short-screen improvement with 56.5% larger emitted code does not justify
promotion. [Candidate25](../../experiments/phase45/P45-025-string-equality-number-nat.md)
is a separate one-line change allowing the already proved String operation
to compose with Number-Nat lowering; its executed scoped results follow. Preserve both timing
runs and their separate elapsed-time accounting. Worker23 remains the usable,
fully qualified selected compiler.

## Candidate25: representation mode changes, short timing does not improve

Candidate25 adds only `String.eq` to the Number-Nat pass's existing native
operations that keep their representations. The previously proved native inputs
are immutable String and its result is Bool; none crosses a Nat boundary.
Runtime, call order, equality semantics and guards remain unchanged.

Its checked API is
`d8b084d7c30b46ecafaa6b7f8100ab70ccd52c5ae5b29ba51c3f969f91cad0cd`.
The checked build and eight maintained suites pass. The successor controller
reuses exact candidate24 and TypeScript fixture acquisitions and passes 135
oracles, six activation observations, 21 boundaries and eight error observations.
The two additional boundaries install Boolean-prototype `bounce`/`build`
getters and verify exact generic observations and private refusal. Original
Unicode, native mutation, private Char error and Error reentry checks remain.

The new emitted-code receipt proves that exactly `chk_order` and `chk_set` retain
private admission and switch from BigInt to Number-Nat mode. The same five other
modules remain byte-identical; their timings are not needlessly repeated.
Map/Set module size is **608,375 bytes**, 346 bytes below candidate24 and still
about 56.4% above installed23.

The clean short candidate24→25 screen
(`selfhost/build/phase45/runtime-worker25-vs24-mapset-unicode/report.json`) passes
all values in three balanced rounds per role, taking 14.74 seconds:

| Point | Candidate24 ms | Candidate25 ms | Candidate24 / candidate25 |
| --- | ---: | ---: | ---: |
| Map/Set | 1.27598 | 1.29761 | 0.98333× |
| Unicode text64 | 0.238260 | 0.239439 | 0.99507× |

Number-Nat composition activates but provides no benefit in this short screen.
Candidate Map/Set within-sample drift ranges from +19.31% to +41.34%, so do not
treat a 1.7% difference as settled evidence of a regression. This comparison does
not demonstrate an additional Nat-only gain.

## Final longer confirmation and retention decision

The final installed23→candidate25 comparison
(`selfhost/build/phase45/runtime-worker25-vs23-confirmation/report.json`) passes
all **30 samples**: two points, three roles and five balanced rounds. It uses
three warmup calls and 1,000 ms warmup, 50 ms calibration and 300 ms target time;
elapsed time is 49.55 seconds. No other heavy job overlapped this confirmation.

| Point | Installed23 ms | Candidate25 ms | TypeScript ms | Installed23 / candidate25 |
| --- | ---: | ---: | ---: | ---: |
| Map/Set | 1.15836 | 0.840818 | 0.0203410 | 1.37766× |
| Unicode text64 | 0.228095 | 0.230582 | 0.0853786 | 0.98922× |

Map/Set remains **41.336× TypeScript time in this protocol**. Both Bend roles
still speed up within samples: baseline half drift ranges from −19.10% to
−16.56%, and candidate from −24.77% to −3.88%. The longer comparison supports a
promising measured improvement; it does not establish a fully settled throughput
estimate. Unicode is byte-identical and remains a preservation control. The
combined23→25 observation cannot attribute its benefit to Number-Nat separately,
particularly when the short24→25 isolation supplied no additional gain.

**Decision: retain both prototypes and their exact evidence; select neither.**
The general native-proof omission is real and the two new closed graphs are
correct under the focused controls. However, only one corpus source benefits,
its module grows from 389,034 to 608,375 bytes, and both `chk_del` and
`main.out` remain generic. The exact first refusal for that larger graph has not
been established. Full candidate25 qualification has not run. Worker23 remains the usable release and its published full-corpus
results are unchanged.

There is also **no controlled candidate25 compiler-cost measurement**. Build
completion and elapsed qualification time do not measure comparative compiler
throughput. More emitted bytes are an observed size cost, not a quantified
compilation/import-time cost. Further evaluation would have to weigh those costs
alongside stable runtime behavior; it is outside this closed phase. Preserve the
overlapped first focus, both short clean screens and final confirmation separately.
Do not average or multiply their ratios across different protocols.

## Evidence identities

These paths identify local probe receipts. The [Phase45 report](README.md)
indexes the selected release evidence; candidates24/25 remain separate probes.

| Receipt | SHA-256 |
| --- | --- |
| Checked attempt | `2222616d09f66437645007d924e4042481877c68098bd89b74bea982a314436d` |
| Eight maintained suites | `62a098bb6449295b989001a3c8941ede36dafbea9768245b7297ac3fd0bf2db6` |
| Native equality controls | `ae6d004c8404aa6ad1cef51521b02b4de530a73fa8caad643411b38993578379` |
| Source isolation | `ea09efacbac5b98781db46c4031350e70daae4f99f8a3f0f6313a77dd2685789` |
| Emitted assignment comparison | `2d5d4bf6987aac990f9fc9a341b0a0fc41b633b52447d68d0e614f9b1da6f7f5` |
| Five canaries | `b14383d167ec8b2a9d73f3ed024a48dd0ccde25fe57cae9ec2b9a26d74e34e5c` |
| Exploratory overlapped focus | `1b201b05db221cda07babbb83d28a4ae59d7c38abee4c24a3d21726779356061` |
| Clean short focus | `10419e2cac1f2f1721e943dc8e43fb834fb2b699c6c4daae48940f3cf7fc5d6e` |
| Candidate25 checked attempt | `d3e831c8486e00b8a7b6aa77d986cffb92a01047674502e457ba53bbcacf869a` |
| Candidate25 maintained suites | `2620fdccf723e05109d27f9b0bfdd446f85edbfb4616a1496fa2c323e270c054` |
| Candidate25 native equality controls | `4548362e2a1be81f1c73b2f4f11e97963dd78cd0160461e595ea03c9f3a764a6` |
| Candidate25 emitted assignment comparison | `059eaa5ab9ccffbcad171cfeb9a2c4b8f742047bf5e81b10bf861645fef1f33b` |
| Candidate24→25 short focus | `dfedf8c351b46fa4d7e5d96d9809a22e3b084b7d9427b8d0a6c843a97434b87c` |
| Installed23→candidate25 longer confirmation | `74707a8d0557ecd352a24d95852698937707d6b122bccd3a876428f2d28862b4` |
