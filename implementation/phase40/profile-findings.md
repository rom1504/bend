# Checked06 generated-program profile findings

[Diagnostics06](../../selfhost/build/phase40/diagnostics06/report.json) completes
all18 captures in22.586seconds: list512, tree8 and the unchanged scalar8192
control, each with Phase39, checked06 and pinned TypeScript CPU/allocation roles.
[Compact summary](profile-summary06.json) copies identities, normalization,
accounting warnings, top self frames and selected static counts; bulky profiles
remain in the original diagnostic directory. These are separate instrumented
runs. No profiled timing or call-count ratio enters a speed claim.

All nine analyzed module copies match their selected manifest hashes and sizes:
candidate matches final-candidate02 checked06 API
`630879d8f030241a1d2c56e97f18f88b5be2070ac45dd02304afd06b3e3c5c0a`,
baseline/TypeScript match portable phase40/baseline. All50 diagnostic input,
48 output and19 analysis-input identities rehash successfully. Every capture
is complete with checked expected result, zero process status and matching module
identity. Scalar baseline/candidate bytes are identical. Source/module identities
and raw-profile hashes are retained in the compact summary.

The preset uses CPU3, Node24.18.0,1GiB heap/2GiB sampled RSS and free-memory
contracts,150ms warmup and a600ms profiled target. CPU sampling interval is1ms;
allocation interval is32768bytes. Each is one sampled window per point/role,
not a repeated confidence estimate. Profiles include validated call-loop and
harness costs; import, first call and warmup are outside the profile window.

## Allocation per validated call

| Point | Phase39 bytes/call (calls) | Checked06 bytes/call (calls) | TypeScript bytes/call (calls) |
|---|---:|---:|---:|
| list512 |2,748,742 (274)|500,160 (3,313)|92,740 (6,222)|
| tree8 |11,821,917 (46)|6,281,858 (110)|1,365,266 (1,236)|
| scalar8192 control |6,642 (5,019)|6,468 (5,078)|196 (6,012)|

These estimates divide sampled allocated bytes by validated profiled calls.
List allocation per call falls81.8% and tree46.9% in this capture. Raw candidate
allocation totals are larger at both changed points because the profiled roles
execute different numbers of calls; comparing those totals would reverse the
useful interpretation. The scalar control's2.6% estimate difference cannot be
attributed to Phase40 because its bytes are identical.

Candidate list allocation self weight is concentrated in list construction36.2%,
filter34.2% and map26.6%. Tree allocation remains in warp27.2%, warp_leaf20.6%
and ctor15.2%, with flow8.1%. This supports reduced dispatcher/closure churn while
retaining full intermediate values and explicit frames. TypeScript still samples
about5.4times less allocation per list call and4.6times less per tree call. Those
are allocation-estimate comparisons, not speed ratios or exact object counts.

V8 sample totals and call-tree selfSize totals differ in every allocation role;
the compact summary retains both and their differences. Scalar baseline includes
71,576unattributed bytes, about0.21% of its sample total; other roles have zero
unattributed sample bytes in these captures. The36 TypeScript scalar samples
mostly attribute to harness/timing helpers. This small nonzero estimate does not
prove its algorithm allocates nothing. Samples include collected objects and
exclude comprehensive native/external memory; they measure neither retained
heap nor exact allocation events.

## CPU attribution and generated code

List baseline CPU self shares include apply30.8%, force16.8%, callOwned7.1% and
invokeExact5.1%. Candidate's largest frames are direct list23.0%, filter17.9%
and map16.1%, followed by GC11.7%, bench9.0% and regionHostGuard6.8%. TypeScript
similarly concentrates in list30.3%, filter24.4% and map21.3%. The shared materialized
pipeline dominates after the new worker selection; guards and frame handling
remain extra work. Sample shares across different executions are not additive
saved time, and guard cost is not proved by one attributed frame alone.

Tree remains dispatch-heavy: candidate apply17.7%, invokeExact12.0%, warp11.4%,
GC7.2%, warp_leaf6.6% and flow4.9%. Baseline includes warp18.4%, apply15.4% and
invokeExact12.8%. TypeScript instead attributes warp54.4% and flow20.0%, with
GC11.0%. New flow/constructor continuations remove selected generic recursion,
but warp_leaf and warp_node still use residual generic calls. A higher remaining
apply percentage after other work shrinks is not evidence apply got slower.

Static analysis makes the distinction explicit. Each of the six candidate list
workers has zero exclusive generic trampoline calls, global lookups and closure
helper calls. Their retained generic definitions/fallbacks still exist: total
source-owned generic call sites grow65→112 for lists and90→102 for trees.
Those syntax counts do not measure executed calls. Candidate tree worker counts
retain warp3, flow4, bsort10 and scan2 generic helper sites, including fallback
branches. The corresponding source-owned array-literal sites grow138→382 for
lists and174→227 for trees; new explicit frames trade native dispatch for saved
argument/continuation arrays. No static shrinking claim follows.

TypeScript uses direct named function calls and single objects with named fields
for List/Tree constructors. Selfhost preserves tagged objects plus field arrays,
native BigInt Nat coordinates, explicit continuation storage and exact mutable
host/dependency guards. These concrete remaining mechanisms fit the allocation
and CPU observations without establishing their individual causal contributions.
No fusion, layout replacement or broader proof is justified by these profiles
alone. Scalar CPU stays90.8%/90.5% in the same private mit worker; its allocation
is mainly entry descriptor checks, providing a useful unchanged control.

Clean same-run execution ratios, performance admission, compiler cost and release
identity are separate evidence. These selected captures explain remaining work
and suggest bounded future experiments; they do not establish TypeScript parity,
universal steady-state behavior or a new compiler-throughput result.
