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


## Ordinary C workers and current tradeoffs

The ordinary-worker prototype (`flat-build06`) passes its strict checked build
and eight paired native controls. Retained C inspection proves that the
100,000-step tail-recursion witness enters an `NF_` worker and uses a local
loop. Live non-tail and mutual-recursion witnesses retain scheduler entries;
they do not silently acquire recursive C workers. The array program contains
17 workers with maximum call-DAG depth six and no scheduler operations inside
those workers. All six benchmark output oracles also pass.

The three-family resolved screen against `prefix-build04` gives runtime ratios
0.606796 (numeric), 1.055385 (array), and 0.882813 (lexer): geometric mean
0.826877. These are two-round, sequential-campaign measurements on common fixed
work; all six intervals exceed 100 ms. They are **not** a new upstream parity
claim. C size grows 42.1% and Clang acquisition time 21.3% against the especially
small prefix version. Compared with the original baseline, numeric C is still
smaller and its Clang build falls from 13.75 seconds to 4.54 seconds.

Source and disassembly explain why arrays need the next representation change:
the hot loop still allocates and consumes two tuple shells per element, and
Clang leaves two ordinary helper calls uninlined. P68-007 targets those shells;
P68-008 separately tests general private-worker inlining without changing the
production policy. The additional closure/tree/Map runtime screen has closed;
its disjoint receipt join is pending.

`admission-build07` passes strict checking after a five-line analysis cleanup.
Worker admission now avoids traversing dependencies of already admitted or
rejected candidates. All three complete-C equality checks against actual06 pass; no additional
runtime gain is credited to this compiler-only change. The exploratory B1
request clocks show no material improvement, so the change is retained for
avoiding redundant analysis rather than a measured speed claim.

## Actual B2 request findings

The genuine `templates-build05-b2` image passes eight ordinary-driver comparison
observations. It emits a direct branch chain for template lookup, with no eager
69-entry catalog. All 15 native request jobs close successfully, including nine
clean requests and four separate profiles; every output equals its qualified
complete C oracle. This is a diagnostic B2 image, not release qualification.

| C request | Baseline B1 ms | Templates05 B1 ms | Baseline B2 ms | Templates05 B2 ms | Current TS ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| Numeric | 2,137 | 2,627 | 1,921 | 1,569 | 713 |
| Array | 2,018 | 2,676 | 1,845 | 1,582 | 719 |
| Lexer | 2,569 | 3,353 | 2,300 | 2,086 | 904 |

These are one clean sample per role/case, with preparation and imports outside
the request clock. The aggregate implementation improves B2 but regresses B1;
it does not establish an isolated template speedup. The new profiles identify
`nc_occurs_list` at 528–672 ms exclusive sampled time in B2 and repeated variable
occurrence analysis at about 1.3 seconds inclusive in B1's numeric profile.
The local-value optimization exposed repeated expression-tree walks per live
binding. A pure Bend occurrence-summary change is now the priority, with full-C
byte equality as its fast correctness discriminator. Instrumented profile clocks
are not substituted for clean timings.

Current source checkpoints remain developmental. Installed Phase67 files and
all historical raw evidence remain unchanged. No PR comments were posted.


## Working09: occurrence summaries and bounded worker inlining

Occurrence summaries pass the strict checked08 build, 2,345 actual-image
membership checks, and 210 ordered environment/partition and sharing cases.
All three complete C files equal checked06/07 byte for byte. The B1 acquisition
screen gives an 08/07 request ratio of 0.727177; this is diagnostic, not a
position-balanced final compilation result. The first control attempt failed
because its diagnostic export expected a function eliminated as unreachable;
the versioned successor reads the actual compiled partition result and passes.
The original failed source and receipt remain preserved.

A separate all-worker inline diagnostic passes two independent output oracles
and twelve alternating, resolved runtime intervals. Numeric median is unchanged
(127 ms); array falls 174→123 ms. Machine-code inspection confirms the private
calls disappear. Working09 adopts an explicit inline hint only for admitted
worker bodies at most 4,096 characters long, with a GCC/Clang guard and ordinary
INLINE fallback. This is a local size cutoff, not a transitive expansion bound.
Its three-family screen passes: numeric 125/127 ms, array 116/117 ms, lexer
140/141 ms on the same plan02. Broader final selection is still pending.

Actual working09 B2 construction and eight driver observations pass. All 15
native compilation jobs pass, including complete-C equality for every actual
B1/B2 request. Single-sample request times for numeric/array/lexer are
B1 2,285/2,432/2,988 ms; B2 1,415/1,442/1,954 ms; TS 707/724/862 ms.
The new B2 ratio is approximately 2.00/1.99/2.27× TS. These measurements contain
all intervening compiler changes and do not isolate the occurrence rewrite.
Profiles confirm the old occurrence-list hotspot disappeared; summary/index
construction and rendering are now visible targets.

The source census is [recorded separately](simplicity-working09.md): working09
adds 504 physical Bend lines (1.77%) over Phase67. Generated C and native
execution have decreased substantially; compiler source has not become smaller.
The [native architecture guide](../../docs/self_hosted/native-value-lowering.md)
explains the shared arity analysis and common lowering destinations.

The raw07 checkpoint control initially instrumented only the preserved device
fallback return, missing the active host worker. A versioned instrumentation
successor retains the original behavior oracle and all ten rows pass. This was
a stale diagnostic marker; no production error-checkpoint fix was needed.
Product source review separately found real ownership/demand risks before
execution. The corrected proposal requires appropriate use on every branch and
uses bounded syntactic layout analysis without global normalization. It remains
unselected until a checked build, active-path witnesses and native controls pass.

## Guarded scalar payload packing discriminator

A C-only diagnostic packs fitting, ordinary encoded one-field constructors and
retains the exact old box otherwise. Base/IO constructors remain unchanged.
Two output oracles and all twelve alternating timing intervals pass. Tree
median falls 210→161 ms (23.3%); lexer 168→159 ms (5.4%). This is evidence for the
mechanism, not a qualified compiler implementation. A small general source
proposal additionally disables packing in books with user foreign definitions
to preserve their representation boundary. No runtime implementation changes
are required by that proposal.

## Product transport: a useful failed mechanism check

Checked10 passes strict checking, six paired product controls, 18 actual-image
demand decisions, and the branch-discard fixture (`1831`) with its private
product entry absent. Its raw controls eventually pass all twelve observations.
The intervening failures are preserved: the first instrumenter counted `INLINE`
inside `NF_INLINE` twice; its successor contained an extra JavaScript bracket.
The final successor passes the actual Node syntax parser before execution.

These correctness results do **not** establish successful scalar replacement.
The active-C audit finds zero product workers in numeric, array and lexer.
Array timings are 125/124 ms against working09's 116/117 ms; there is no gain
to credit. Actual compiler introspection identifies a conservative query stopping
at the `Pair` alias used by `A & B`. The prototype remains unselected while the
general bounded alias query is investigated. This is why active-path inspection
belongs in the fast loop alongside output checks.

## Reusing occurrence summaries within a lowering operation

Checked11 adds six lines, no functions or types. Four existing lowering functions
reuse the same body summary for liveness, sharing and ordered drops. The value
path skips a second partition only after its environment was filtered to live
bindings. Product substitution paths remain unchanged.

The actual10/11 helper comparison passes 3,520 complete lowering-result pairs and
four product metadata cases, including emitted calls. Instrumentation observes
fewer body scans in 2,640 cases and fewer value scans in 1,680. Numeric, array and
lexer complete C outputs are byte-identical. Their B1 request screen changes
2,142/2,447/3,087 to 2,023/2,339/2,892 ms, approximately 5–6% less time. This is
a single-sample mechanism screen; final balanced B1/B2 timings remain pending.

The installed compiler is still Phase67. These source checkpoints and focused
controls do not substitute for final release qualification.
