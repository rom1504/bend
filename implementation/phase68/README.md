# Phase68 native parity investigation and optimization

Status: investigation in progress; no new compiler promoted.
[Design](../../design/phase68/native-parity.md).

The Phase67 installed compiler and 110 inherited files are preserved. Baseline
identities and all new receipts live under `selfhost/build/phase68`; old evidence
remains closed. This phase separates native runtime, B1/B2 C request latency,
Clang time, JS protection, conformance and complexity.

Initial source audits identify missed matcher arity, scheduler continuation
transport, boxed product results and duplicate ordinary/direct emission. These
are hypotheses until the measured experiments below qualify them.

- [Upstream native comparison](../../research/phase68/upstream-native.md)
- [Primary compiler research](../../research/phase68/world-compilers.md)
- [Investigation experiment](../../experiments/phase68/P68-001-investigation.md)
- [Matcher arity experiment](../../experiments/phase68/P68-002-match-arity.md)

No Phase68 gain, parity or conformance expansion is claimed at registration.

## First measured prototype (not promoted)

The unchanged cached baseline replay passed12/12 outputs. Paired native counters
then completed numeric/array/lexer for both compilers. For16extra workloads,
array allocation calls are393,340selfhost versus18upstream; generic closure
entries327,842 versus0. Numeric has32,821 versus2allocations and49,277 versus0
closure entries. Lexer has4,796,550 versus734,878allocations and8,602,643 versus0
closure entries. No local allocator misses occurred in these deltas. Counts are
frequencies, not time attribution; output/digest work is included.

Matcher-arity prototype B1 `4fe50555…` passes strict checked build (zero exact
differences) and all six independent benchmark oracles. Recalibrated common-work
timings (all24intervals≥100ms) give0.363465× prior runtime, or2.75× faster.
Per-family speedups: numeric4.33×, array3.38×, closures1.21×, tree2.24×, Map3.15×,
lexer3.46×. Campaigns are sequential, two rounds each; the array baseline has
noticeable spread. This is a baseline-relative screen, not a fresh upstream ratio.

Costs:1.612257× C bytes and1.512764× single-acquisition Clang time. Therefore the
prototype is not a release selection. A shared full-body/curried-adapter design
is being tested to remove duplicated lowering while preserving partial calls.

The six-source semantic gate passes five valid controls. The sixth new fixture
was invalid in both compilers with different rejection phases; its attempted
bytes and receipts are preserved and a corrected successor is required. Separate
competing-error tests show saturated calls agree, but partial calls reach different
first errors (upstream Nat overflow, candidate tag refusal). This retained
partial-call behavior needs correction. The explicit staged-match fixture also
violated the language's parameter-only match rule and needs a fresh successor.
No failed fixture is counted as a pass.

Evidence: `native-counts01/report.json`, `native-arity-comparison01.json`,
`arity-build01/attempt.json`, `arity-controls01/execution/selected/paired.json`,
and `error-order-controls01/execution/selected/paired.json` under freshPhase68raw.

## C-request baseline and next hypotheses

All15 compilation baseline jobs complete with exact full-C equality (two Base
preparations, nine clean fresh requests, four request-only profiles). They use
actual installed B1 and genuine B2 snapshots; no Clang is inside the request
clock. Single-sample B2 requests are numeric1.921s, array1.845s, lexer2.300s;
TS0.783s/0.715s/0.928s. These are exploratory points, not a qualified broad ratio.

Profiles identify eager `ni_templates()` construction at260–312ms exclusive
sampled time (approximately11–14% of these B2 request profiles), substantial GC,
and repeated runtime-text scanning. Demand-selected templates and fewer scans
are stronger immediate compilation hypotheses than the small cached-bound shortcut.
See [compilation research](../../research/phase68/native-compilation.md).

## Mechanism confirmed

A separately instrumented arity candidate confirms the prediction. On the same
16 additional numeric workloads, allocations fall from 32,821 to 2 and generic
closure entries from 49,277 to zero. Scheduler entries fall from 164,291 to
16,460. Array allocations fall from 393,340 to 131,122 (two remaining small
records per hot iteration); closure entries fall from 327,842 to zero, and
scheduler entries from 1,508,035 to 524,500. Both output oracles pass.
Reference-count operations barely change, which narrows the next optimization
to boxed-result and continuation transport. These instrumented runs receive no
clean timing credit. Evidence: `native-arity-counts01/report.json`.

## Shared-body and local-value follow-ups

The checked shared-body compiler (`eta-build02`) produces correct results for all
six benchmark families. Against the frozen Phase67 baseline, resolved timings
give **0.376615× runtime (2.66× faster)**, **0.765296× Clang time**, and
**0.878338× C bytes**. This removes the first prototype's C-size/build penalty.
All nine paired semantic observations agree with upstream, including the formerly
different partial-call error order. Eight pass their fixture goldens; the ninth
has correct String content but an incorrectly unquoted fixture golden. A fresh
version corrects that readback-format expectation, preserving the failed version.

Local value lowering (`prefix-build04`) reduces runtime a further10.7% on the
three discriminator families (numeric, array, lexer), relative to the shared-body
version. Four valid ownership/value fixtures and all ten preserved raw controls
pass. Two newly authored fixtures used tuple destructuring on computed values,
which this language version rejects; both compilers reject identically. They are
being repaired as new versions and will receive a reference-only frontend smoke
before further native execution. No compiler mismatch is concealed by these
fixture corrections. An earlier compiler build also caught one missing shared
binder annotation in the proposal; that failed build remains preserved.

New mechanisms remain under investigation: ordinary C workers/local joins
([P68-005](../../experiments/phase68/P68-005-flat-workers.md)), demand-selected
intrinsic templates ([P68-006](../../experiments/phase68/P68-006-demand-templates.md)),
and one-level product bundles ([P68-007](../../experiments/phase68/P68-007-flat-products.md)).
The installed release is still Phase67; no Phase68 promotion yet.

## Template correctness checkpoint

The demand-template compiler (`templates-build05`) passes strict checked build.
Actual old/new image controls cover all 69 catalog entries, 216 adverse unknown
names, 570 membership checks, 570 complete-template checks and 3,990 substitution
checks. All pass. Numeric, array and lexer C are byte-identical to `prefix-build04`,
so these native products do not need rebuilding. B1's exploratory request clocks
show no speed improvement; the B2 hypothesis remains unmeasured and must not be
credited from source intuition. A genuine B2 prototype is prepared for that test.

All nine repaired/new control sources now pass a separate reference frontend
smoke (zero holes, no C compiler or execution). Native retries still determine
their runtime qualification. Compiler-source commits are development checkpoints;
installation waits for final selection and integration gates.
