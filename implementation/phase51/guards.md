# Phase51 guard experiment: batch captured-intrinsic descriptor inspection

Status: descriptor batching was rejected after a short root-executed screen.
The next saved-output experiment reuses a fresh String proof within one entry.
Production source is unchanged by this track; root owns target execution.

Phase49 found that fresh entry validation dominates the small RLE public call.
Phase50 distinguishes guard-heavy entries from generic dispatch and larger
computations; a guard change is not expected to improve every program equally.
This experiment preserves the required checks rather than weakening admission.

`stringHostGuard` repeatedly calls captured `getOwnPropertyDescriptor` for every
own key of the captured String constructor and prototype. The derivative captures
the standard native `Object.getOwnPropertyDescriptors` at initialization and
obtains one descriptor map per object, freshly on each guard invocation. It then
compares the same key order and complete descriptors against the same snapshots.
The global String descriptor and both object prototypes are checked as before.

The proposed equivalence relies on the existing standard-intrinsics-at-import
contract, not host stability after import. The captured String objects are
ordinary intrinsic objects, not replaceable proxies. Native descriptor inspection
does not invoke own getters; the new descriptor map has native-created own data
properties. No user code runs between its acquisition and comparison. Extra,
missing, reordered or changed properties still refuse, including symbols and
descriptor flags. The original public body and fallback remain byte-identical.
This reasoning does not permit batching arbitrary proxy objects or replacing
descriptor inspection with value reads.

The performance hypothesis is deliberately uncertain: two extra descriptor-map
objects may outweigh the reduction in individual native calls. Stop the track if
fresh clean timing fails to show a useful gain. Neither allocation counts in
source nor a faster instrumented run qualifies promotion.

The data-only [producer](../../selfhost/tools/performance/phase51/guards-derive.py)
requires an exact input module SHA-256, asserts unique original runtime fragments,
and proves reversible replacement of only the capture declaration and guard body.
It writes a fresh derivative, consumed producer and provenance receipt. The
[independent controls](../../selfhost/tools/performance/phase51/guards-controls.mjs)
append a diagnostic-only predicate export to both copies. Eighteen cases compare
fresh guard booleans and zero hook invocation under post-import global String,
constructor/prototype property, symbol, descriptor-flag and prototype mutations;
captured reflection replacement and inherited descriptor fields are also tested.
Each case restores the host and requires the original permission to return.
Clean RLE public results are checked separately; this is not a universal proof.

Root execution, with fresh output directories:

```sh
python3 selfhost/tools/performance/phase51/guards-derive.py \
  --module selfhost/tools/performance/phase49/inputs/baseline.mjs \
  --sha256 d62ccfa7e27ef5124877c736b6ed4d39ee507b049b4a86e10b03c0c6b8530c4a \
  --out selfhost/build/phase51/guards-derived01
node selfhost/tools/performance/phase51/guards-controls.mjs \
  selfhost/build/phase51/guards-derived01/derivation.json \
  selfhost/build/phase51/guards-controls01
```

Reuse the existing serial resource-bounded execution tools for these commands
and subsequent fresh-process timings. Time only the unchanged public result
oracle on the original and uninstrumented derivative; diagnostic exports are not
timing artifacts. Recheck a guard-heavy renamed fixture before production changes.

A static census found no adjacent emitted `scalarGuard` plus `localGuard` checks
in the 24 installed module variants. `localGuard` calls `scalarGuard` internally;
shared prototype checks may still overlap the host fence. A separate question is
whether the explicit String guard is repeated by `scalarGuard`'s dependency
snapshot flag. Such removal would require a fresh same-entry permission proof
and preservation of refusal order, not a permission cache across public calls.

## Recorded batching outcome

`selfhost/build/phase51/guards-controls01/report.json` passed all 18 direct guard
cases and two clean public oracles. In `guards-screen01/report.json`, three fresh
rounds with 100 ms warmup and 50 ms target windows gave these descriptive medians:

| Point | Original µs | Batched µs |
| --- | ---: | ---: |
| RLE | 51.476 | 82.817 |
| Unicode 16 | 134.007 | 177.345 |
| Map churn 32 | 804.691 | 545.246 |

These windows drift substantially; the table is not a mature estimate of effect
size. The unfavorable guard-heavy results suffice to stop this cheap experiment.
The mixed Map result does not qualify batching as an optimization. The candidate
remains uninstalled and its evidence is retained.

## Reusing an already established String proof

The counter-only `guards-count01/report.json` confirms two String checks and one
selected-root entry for each of Unicode 16, Map churn 32 and records 64. An owned
argument vector whose getter mutates String is read before either check and
refuses the selected root while retaining the full output oracle. Restoring the
host restores entry. This stronger internal argument-vector probe is not a new
public ABI and is not a throughput measurement.

The exact contextual-wrapper emitter already caches every `a[i]` in `$sN` before
`regionHostGuard()` and the first `stringHostGuard()`. Between that check and
`localGuard`, `j_region_inputs` emits only canonical U32/Bool/Nat/F32 predicates
on those cached primitive values. The full fresh host fence covers the invoked
`Number.isInteger`, `Number.isNaN` and `Math.fround` intrinsics. No user callback
can invalidate the String proof in this interval. This is stronger than merely
having an exact-entry token: arbitrary argument getters could invalidate a proof
if they were read later.

The [token derivative](../../selfhost/tools/performance/phase51/guards-token-derive.py)
fails closed unless every contextual wrapper has that exact shape and recognized
scalar predicates. It adds a private `stringHostChecked` capability and passes it
to `localGuard` only at those sites. `scalarGuard` skips only its second String
scan; all prototype, dependency and `.call` checks remain. The capability stores
no mutable permission and authorizes no later public entry. Fresh host and String
checks remain at the start of every admitted invocation.

The [token controls](../../selfhost/tools/performance/phase51/guards-token-controls.mjs)
require full output oracles, two-to-one String-check counts, argument getter
mutation/reentry/throw, source descriptor/code/call getters, reflection and Number
hooks, and restored admission. Root executed all 11 paired scenarios for each of
Unicode 16, Map churn 32 and records 64: 33 boundary observations passed. The
three reports are under `selfhost/build/phase51/token-controls-<point>01/`.
Consumed producer and controller bytes remain unchanged.

`token-screen01/report.json` then passed six points and 54 fresh samples in
44.440 seconds. Three rounds used 350 ms warmup and 150 ms target windows:

| Point | Original µs | Token µs | Original/token |
| --- | ---: | ---: | ---: |
| Unicode 16 | 92.900 | 76.351 | 1.217× |
| Unicode 64 | 223.787 | 210.225 | 1.065× |
| Map churn 32 | 359.752 | 335.430 | 1.073× |
| Map churn 128 | 1,404.734 | 1,356.294 | 1.036× |
| Records 64 | 649.344 | 605.830 | 1.072× |
| Records 256 | 2,251.611 | 2,279.316 | 0.988× |

Five medians improve; records 256 is slower. These short windows are provisional:
maximum absolute half-drift across the two Bend roles ranges from 3.30% to 26.92%
by point. They justify broader evaluation, not a corpus gain or significance claim.

The reviewed [production proposal](../../selfhost/tools/performance/phase51/proposals/same-entry-string-proof.patch)
and [identity manifest](../../selfhost/tools/performance/phase51/proposals/same-entry-string-proof.json)
contain only a private runtime token, one `scalarGuard` predicate change and one
argument at `j_instance_root_guarded_mode`'s `localGuard` call, with proof comments.
No new graph analysis is needed. The patch is not applied by this track; assembled
runtime regeneration, checked compilation and broader qualification remain root
integration work. These results do not describe an installed compiler change.
