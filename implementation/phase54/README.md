# Phase54: backend cleanup and scalable direct analysis

The cleanup separates shared typed facts from JavaScript emission, makes the
remaining legacy compiler-image contract explicit, and replaces repeated graph
closure with compact SCC analysis. **Graph02 is installed and verified.** All
semantic, exact-output and release gates pass. Direct compiler-image migration
remains unqualified. The [publication index](../../selfhost/tools/performance/phase54/publication.json)
binds the selected release and complete evidence.

[Design](../../design/phase54/backend-cleanup-and-direct-bootstrap.md) ·
[Architecture and counts](architecture.md) · [Shared helpers](shared-helpers.md) ·
[Routing](routing.md) · [Scaling](scaling.md) · [Bootstrap investigation](bootstrap.md) ·
[Qualification](qualification.md) · [Independent review](review.md).

## Organization and retained foundations

Thirty-four helpers moved with unchanged names and bodies: 27 semantic queries
into three common modules, and seven JavaScript text helpers into one shared JS
module. Direct JS no longer imports these facts from legacy emitter modules.
The helper-only checked build passes 36 frontend witnesses and produces exactly
the Phase53 compiler API bytes. Its eight benchmark point modules are also exact.

Two maintained compiler-image commands now explicitly select `--legacy-js`;
six grouped routing controls pass. The legacy emitter, descriptor runtime and
private image transforms still have real callers. They remain until direct
compiler-image generation and those callers are qualified. Deleting them now
would break bootstrap functionality.

All 17 native backend modules, both JS runtimes and the typed driver are unchanged.
Shared KTerm/KDef annotations, erasure, ownership, effect and numeric facts remain
available to C and future LLVM/assembly lowerings. The existing C backend stays
usable. No speculative universal executable IR was added.

## Graph scalability and source size

Iterative forward/reverse traversal replaces a stored closure for every function.
The analysis preserves source-order component membership and propagates unknown
tail-call forcing through reversed edges. Fifteen independent graph cases and
ten budget controls pass on graph02. The production definition budget is now
4,096 instead of 512, shared by scanning, graph admission and emitted reachability.
The new total edge budget is an explicit acceptance-policy change.

A single cold 128-node graph invocation takes 226.9 ms before and 38.2 ms after;
a 3,004-node candidate chain takes 470.3 ms. These are graph diagnostics, not a
whole-compiler speedup or warmed benchmark. Checked source and execution scaling
are reported separately in [scaling](scaling.md).

Source grows from 26,151 to **26,259 physical lines**, and from 21,523 to
**21,598 code lines** (+0.35% code). There are 3,015 definitions, 100 types and
107 modules. This phase improves dependency boundaries and algorithmic complexity;
it does not claim net code deletion. Retiring legacy code depends on bootstrap
migration. Ninety-five original modules remain byte-identical.

## Bootstrap finding and next step

An isolated direct image with 11 requested roots passes ABI, shared/frozen data,
path and cached-book controls, including a 20,000-element list. Full 77-root
compiler-image generation hits the 240-second limit below 864 MB RSS. A shorter
instrumented attempt spends 55.9 seconds in emitted reachability before entering
final library emission. It does not complete a full compiler image.

A deterministic sampled V8 profile points to repeated whole-book constructor
search during arity recovery: `j_find_ctor` accounts for 26.5% of sampled ticks,
and the `missing` helper accounts for another 11.2%. This is a focused
follow-on hypothesis, not a proven optimization gain. Prefer lookup through a
known normalized ADT owner; otherwise test an indexed constructor context with
explicit precedence/invalidation controls. Keep this separate from helper moves.
The full raw profiler report exceeded its local 512 MiB processing heap; bounded
subsampling succeeded. Compiler jobs did not hit their memory bounds.

## Qualification, speed and evidence

Graph02 passes 96 source, 34 numeric, 18 composition and two overapplication
controls, the 26-row direct census and eight maintained compatibility suites.
All four semantic module comparisons are byte-exact. Three native sources emit
exact Phase53 C and pass six fresh CPU runs. The installed release passes
**42 legacy + 24 default interface checks**, integrity, relocation and tamper
restoration. Seven prior-release files are preserved byte-for-byte. These scopes
overlap; they are not summed or called full language conformance.

All **45 benchmark point modules / 23 checked sources** match Phase53 exactly.
The dated Phase53 generated-program result (**1.069599× TypeScript** equal-point
time, 1.078076× equal-source) therefore remains applicable to those executable
bytes. No new 669-sample timing campaign or runtime improvement is claimed.
Compiler throughput and a new self-emitted fixed point remain separate.

Failures remain visible: comparator archive assumptions; missing Base import and
forward-reference ordering in generated scale fixtures; a missing launch-plan
Node option; missing Clang environment; six sandbox Clang process refusals in the
first CLI run; full compiler-image deadlines; and the offline profiler heap
limit. Fresh corrected harness/environment runs pass where stated. Compiler
source, controllers and source goldens were not altered to waive these failures.

The [publication index](../../selfhost/tools/performance/phase54/publication.json)
preserves compact summaries and one verified raw archive, including failed
attempts. Detailed `selfhost/build/phase54/` paths in reports name archive members. The 103 inherited unrelated files remain
protected. No PR comment is posted.

At the accounting cutoff **2026-10-06T01:54:30.312781+00:00**, elapsed time was
**56.14 minutes** and the union of recorded process intervals was
**21.15 minutes**. The remaining **34.98 minutes** includes
analysis, parallel review, documentation, orchestration, unrecorded tooling and
idle time; it is not a waiting estimate. Publication after this cutoff is excluded.
Heavy compiler/program jobs remained serial and memory bounded. The unchanged
45-point executable bytes avoided a redundant full timing campaign.
