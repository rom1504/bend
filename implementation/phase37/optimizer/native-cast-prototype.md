# Private native cast: prototype findings

The expanded numeric recurrence exposed a small, high-impact omission: the
compiler already made its recursion a private Nat loop, but each iteration
still dispatched `F32.to_u32` through the public descriptor and generic function
application. Reusing the exact native body inside the existing guarded region
removed most of this overhead. The corrected saved-output prototype improved
the two numeric points by **2.66× and 5.07×**. They remain **7.31× and 3.33×**
slower than the pinned TypeScript output, respectively.

These are **saved-output mechanism measurements**, not results from a new
compiler release. Actual checked compilation, broader regressions and compiler
cost were still pending when this report was written. No holdout timing was
used for this experiment.

## What was changed experimentally

The original generated module is the frozen Phase36 numeric recurrence, SHA256
`4be6605751c64a403cc73453d62d0562f9bdefad210339637278c0f610e83017`.
The derivative replaces precisely two existing private-region call sites. The
ordinary generic fallback call and mutable public descriptor remain intact.
Clean timed modules are separate from diagnostic counter modules. The unchanged
points are 256 iterations with seed 17 and 1024 iterations with seed 123, with
independently derived expected values 2747714257 and 1376326140.

Inspection found two runtime registrations of `F32.to_u32`. The final effective
one returns zero for nonfinite, negative or out-of-range inputs and otherwise
returns `Math.trunc(x) >>> 0`. The earlier saturating body would be incorrect for
this experiment. The proposed canonical change shares the final body between
public registration and the private helper rather than duplicating semantics.

## A correctness failure caught before promotion

The first derivative passed the original 27 oracle observations, 53 boundary
controls and three private-entry witnesses. A subsequent review discovered an
unguarded host callback in F32 literal decoding: `bitsFloat` invokes methods on
a shared `DataView`. A replacement method can mutate the native descriptor
after region entry. The old generic dispatch sees the mutation; the direct
call does not. A preceding fallback can also leak that view, allowing an own
method or prototype change after the public prototype is restored.

The preserved `cast-dataview-controls02` experiment completed all 22 adversarial
observations, with **18 failures and four matching throws**, and no harness
errors. Failures included matching final scalar values with missing
`changed-native` callbacks. Merely checking numerical output would miss the
semantic regression.

The corrected derivative guards the constructor, prototype and parent, four
method descriptors, shared view prototype, and absence of own methods on the
view. `cast-controls03` then passed the original controls; the unchanged
DataView worker passed all **22/22** observations in
`cast-dataview-controls03`. This correction protects both literal decoding and
float-bit encoding. The original failed evidence and vulnerable derivatives
remain separate, unchanged files.

## Timings

All entries are median milliseconds per completed call. Each run uses fresh
serial processes, role rotation, exact result checks, CPU 3, Node 24.18.0 and a
1024 MiB heap cap. Compilation, import and warmup are excluded from these
execution medians. The first screen used three rounds, 350 ms warmup and a
150 ms target per sample; the corrected confirmation used five rounds, 1000 ms
warmup and a 300 ms target. Its total wall time was 48.594 seconds.

| Run and validity | Iterations | Phase36 | Direct cast | TypeScript | Phase36/direct | Direct/TS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `cast-screen01`, vulnerable; rejected | 256 | 0.039849 | 0.014097 | 0.002101 | 2.83× | 6.71× |
| `cast-screen01`, vulnerable; rejected | 1024 | 0.130217 | 0.025495 | 0.008255 | 5.11× | 3.09× |
| `cast-confirm03`, corrected prototype | 256 | 0.039791 | 0.014975 | 0.002049 | 2.66× | 7.31× |
| `cast-confirm03`, corrected prototype | 1024 | 0.129403 | 0.025499 | 0.007666 | 5.07× | 3.33× |

The corrected direct samples ranged from 0.014434 to 0.015213 ms at 256
iterations and 0.025271 to 0.025927 ms at 1024. The corresponding Phase36 ranges
were 0.039444–0.040505 and 0.128305–0.136751 ms. Separate runs use different
warmup and target settings, so their differences do not isolate guard overhead;
the useful comparisons are the paired roles within each run.

Raw evidence is under `selfhost/build/phase37/`: `cast-derived01`,
`cast-screen01`, `cast-dataview-controls02`, `cast-derived03`, `cast-controls03`,
`cast-dataview-controls03` and `cast-confirm03`. The corrected clean derivative
has SHA256 `924e423265e95fe1646f6a9b1c6f101dcfa15ca9921891851300a725963850c4`.

## Actual compiler gate and limits

`native-cast-acquire-v1.mjs` serially acquires the same frozen source fixture
from Phase36, the checked candidate and pinned TypeScript, using the unchanged
emission worker and explicit Phase37 catalog. `native-cast-actual-derive-v4.mjs`
binds these receipts and the candidate's full checked compiler snapshot, then
adds only counters around actual generated private native call sites. It adds
no implementation or guard substitutions. Clean copies remain byte-identical.

`native-cast-actual-controls-v5.mjs` carries the existing boundaries forward,
adds actual source demand/order/unused/staged functions and canonical F32 checks
against TypeScript. Adapter invocation counts are labeled as such; a separate
live `Math.fround` event witness checks composed argument evaluation. The
unused pure expression has no required private-call count because its removal
under a valid guard would be legal. The dedicated actual DataView worker repeats
the previously failing controls against the checked output.

This narrower patch is not general native inlining. It requires the exact
checked F32-to-U32 definition and keeps the original mutable descriptor in the
dependency guard. Remaining work includes actual compiled output correctness,
expanded catalog and holdout execution, short-program guard overhead, compiler
cost, and post-change profiles. No conclusion about those gates follows from
the two-point prototype result.

## Actual checked-source result

Root subsequently completed the actual source acquisition and controls on
`checked02`, selected API SHA256
`c8fcc0704bd27cc666da2ab0747a6190aaff6870686da14e02e40ac445536194`.
The fixture SHA256 is
`a809e18954dd1c96c748d842fdffce48ef16aff713da7aaeaa3d66adf7ef5410`.
All three checked emissions used those same source bytes. The actual candidate
contained seven instrumented private native call sites; the original contained
none. Clean candidate bytes were preserved independently of the counters.

| Evidence | Result | Report SHA256 |
| --- | --- | --- |
| `cast-actual-derived01/derive.json` | Complete, checked; exact source/API/runtime/Base and 249 input identities | `3a23a6cfd878c6963b61d5751714cb15e0e422cb404a818f349c0b18d80e4116` |
| `cast-actual-controls01/report.json` | Pass: 44 oracle observations, 57 boundaries, seven admission records | `aa81526595b25117a6e693f38937eb01564fdcc879c043ab22108f8fcb02df13` |
| `cast-actual-dataview01/report.json` | Pass: all 22 prototype/instance observations, no errors | `726d0b8cd661e03ca6816fe92f13eb6f5d15538ef7336e427d081cccd6d0024d` |

Paths in the table are relative to `selfhost/build/phase37`. The general worker
was `native-cast-actual-controls-v5.mjs`, as bound by the report input and the
supervised command receipt; it retains the v4 JSON kind label. Its exact count
and live composed-argument assertions are the tightened v5 controls. The
DataView worker is `native-cast-actual-dataview-controls-v4.mjs`.

These actual-output semantic gates passed without replacing generated guards,
the helper body or lowering decisions in the adapter. They do not convert the
earlier saved-output timings into actual compiler timings. Expanded execution,
normal compilation cost, inherited semantic gates and final owner closure remain
separate promotion requirements.

## Final checked03 semantic repetition

After the smaller DataView guard and finite-scope profitability change, root
reacquired the same cast fixture from checked03, API
`ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`,
and reran both unchanged actual control workers. The general controls again
passed all 44 oracle observations, 57 boundaries and seven admission records;
all 22 DataView observations passed. Earlier checked02 results were not reused
as this successor's verdict.

| Final evidence | SHA256 |
| --- | --- |
| `cast-actual-derived02/derive.json` | `e6e8ac4db4241f2cb2ca96ea0348a697229b347925125dc8f19c3923d1175b5b` |
| `cast-actual-controls02/report.json` | `f2a9bbd897007048d9dc0fdcbf071879efbc55d5154e9c1bde7f8bcfe7d7fc79` |
| `cast-actual-dataview02/report.json` | `a8ba8b601faa2b6f0e1e7b5eb0d27ca3f3805259444adc22fd1148cebf20c5a7` |

All paths remain relative to `selfhost/build/phase37`. Final owner audit and
broader promotion gates remain separate from these successful semantic controls.

## Actual compiled execution result

The final `development-final01` run subsequently measured the clean checked03
numeric output: 256 iterations improved from 0.039730 to 0.014856 ms per call
(**2.674×**), and 1024 from 0.131576 to 0.025473 ms (**5.165×**). The candidate
remained **7.382×** and **3.338×** slower than the same-run TypeScript medians.
Every paired round improved and both baseline/candidate ranges were disjoint.

The [final development observations](development-final-observations.md) retain
all sample ranges, half drift, protocol and evidence identity. They also record
the separate list512 regression with disjoint ranges; the cast improvement does
not erase that measured cost elsewhere. These final timings replace the
prototype as evidence of actual compiled numeric speed on the selected points.
