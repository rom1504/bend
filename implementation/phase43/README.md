# Phase43: complete-operation direct execution

Work in progress, 2026-10-04. This report distinguishes saved-JavaScript
experiments from compiler-emitted improvements and the installed release.
The [prospective design](../../design/phase43/README.md) was committed before
production changes. The installed compiler remains Phase42 checked16 until
the final candidate passes qualification. No PR comment is authorized or posted.

## Baseline and protocol

Pinned upstream: `018751270e800bc222a93dad7f257083ee53a5f7`. Baseline release:
`714c5f5`, API `63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54`.
Phase42's full 45-point generated-program ratio was 8.862 times TypeScript
with equal point weighting and 11.421 with equal source weighting. These
describe the maintained corpus, not all Bend programs.

Experiments use Node24.18.0, CPU3, serialized execution, a 1GiB heap ceiling,
2GiB process-tree RSS ceiling and 2GiB available-memory floor. The inherited
full frontend gate retains its reviewed two-worker/3GiB combined supervisor
as an explicit documented exception, with no concurrent heavy job. Controls and
profiles are separate from clean runtime measurements. Each timing screen
includes a fresh baseline and pinned TypeScript role. Phase42 raw evidence
remains closed. The 103 unrelated starting files are protected.

Raw evidence: `selfhost/build/phase43/`. `campaign.jsonl` records enclosing
job intervals and consumed tools. Timing budgets exclude source acquisition
and semantic controls. The ledger began after initial setup/delegation;
unclassified wall time must not be described as idle time or model latency.

## Evidence so far

| Experiment | Selected fresh result | Status |
|---|---|---|
| Lexer, complete materialized direct graph | 10.91–12.66 times faster; still 7.00–7.39 times TS | Actual checked08; 439 value checks, 113 boundaries and 3 admission checks pass |
| Map operation graph | About 2.7 times faster; still 28–33 times TS | Saved-JS experiment; actual typed-instance admission remains under investigation |
| Known closures, private materialized environments | 1.77–4.70 times faster; 4.58/1.73 times TS on 64/256 | Actual checked08; 22 oracle groups, 32 boundaries and independent 85-observation fixture pass |
| Closure guard restricted to exact U32 proof | 4.13/9.07 times baseline speed; 2.14/0.941 times TS on 64/256 | Controlled ablation of actual08; 22 oracle groups/39 boundaries pass; checked09 source integration pending actual qualification |
| BST, scalar prefixes, wrappers and private pair state | 2.44/2.66 times faster; 3.42/2.33 times TS on 32/64 | Actual checked08; full pair/path/tree and alias checks pass with executed private pair worker |
| U32-specific fusion host checks | 1.21/1.05 times baseline speed on list128/512; 2.00/0.556 times TS | Actual checked06 screen; checked08 passes all 82 guard controls |
| Repeating a scalar guard after a full host guard | Only 3–4% improvement | Deferred; duplicate machinery not integrated |

Results above come from short screens and different, explicitly recorded
experiments. They are not additive and do not establish a new full-corpus
ratio. See [Strings](strings.md), [Map](map.md), [products](products.md),
[callbacks](callbacks.md), [guards](guards.md),
[validation](validation.md) and [independent review](review.md).

## Integration findings

The first computed-prefix predicate used conjunctions around recursive
arguments. Bend evaluates those arguments even when the preceding shape
check fails. A malformed/nonmatching term therefore branched recursively
and made BST compilation exceed 180 seconds. Explicit conditional branches
fixed termination. The failure and original source patch are retained.
Checked02 compiles the BST source in seconds. A separate refusal probe now
checks malformed and unrelated terms at fuel128, including the original
failure shape.

Checked03 caught a duplicate helper name in the combined String patch;
checked04 caught missing list type annotations in the callback patch.
Both failed attempts remain recorded. Checked05 builds in 42.24 seconds,
peaks at about 1.30GB process-tree RSS, and passes all 36 focused strict
checks. It acquires five representative source modules in 36.72 seconds.

Actual BST controls pass for full and partial results, fallback and deep
trees. The additional scalar-first wrapper closes the remaining hot generic
edge: BST64 uses two generic dispatches, compared with 775 in Phase42.
A fresh four-point screen (`checked05-screen02`) measures BST32 at 0.106914ms
versus baseline0.195543ms and TS0.0253603ms; BST64 at 0.170532ms
versus baseline0.347646ms and TS0.054142ms. List controls stay close.
The first screen request used an incorrect manifest path and failed before
measurement; its report is retained.

Lexer checked05 agrees on 375 initial value observations but fails its
mandatory ordinary-entry activation check; the closure module likewise
lacks the proposed private-environment body. These are admission failures,
not delivered speedups, and are being investigated before broad measurement.

The first integrated attempts also exposed a build-step omission: edited
`runtime/js/core.mjs` fragments were snapshotted alongside the previous
assembled `runtime.mjs`. Checked05 therefore uses the previous runtime, and
its evidence does not qualify the new String or U32 host guards. The bundle
was regenerated before the next attempt; final preflight will require exact
fragment/bundle agreement.

## Subsequent actual-source qualification

Checked06 exposed two actual-source failures after admission opened: lexer prefix
validation did not recognize its already-lowered direct call, and a callback
private source binder shadowed its public input. Both failures were retained and
fixed before checked08. String admission also needed a narrowly proved Bool.and
source path, because the emitter retains that source body despite its native flag.
The fixes preserve original type/body proof and eager argument evaluation.

Checked07 rejected a missing KDef local annotation in the Map prototype. Checked08
builds and passes the 36 focused checks in 54.12 seconds, peaking at 1.34GB tree RSS.
Six sources / eleven points acquire in 45.51 seconds. Its lexer, callback, tree,
list and independent fixture controls now execute the intended implementations.
The first pair fixtures instead selected the existing stronger scalar worker;
they are now explicit precedence controls, with separate positive pair fixtures.
The actual BST control independently proves the new down worker executes.

Map diagnostics found a real admission error: native-marked Map definitions are
source-emitted by this backend but were excluded by a blanket native predicate.
The candidate now follows the emitter's exact source-definition rule and still
excludes runtime intrinsic overrides. Checked09 includes that repair and the
reviewed U32 callback guard capability; it builds and passes 36 focused checks in
53.66 seconds at 1.371GB tree RSS. Actual source controls remain pending for it.

Evidence includes checked08-screen01, checked08-lexer-screen02,
callback-string-scope-screen01, strings-controls08-v4, callback-actual-controls08,
callback-source-fixture08, products-pair-real08 and run-guard-actual-controls08.
Earlier failed attempts and superseded controller versions remain recorded.

## Follow-up experiments and current source

Checked09's fresh four-point screen (`checked09-screen01`) confirms the guarded
closure environment change: size64 is 4.208 times faster than checked16 and
2.075 times TS; size256 is 8.069 times faster and 1.0105 times TS. Tree32/64
remain 2.185/2.534 times faster than checked16 and 3.803/2.516 times TS in
that same screen. Short-screen variation is retained rather than selecting the
best denominator from previous runs.

A further source-generic callback experiment fuses construction and application
under the existing exact total-U32/no-escape proof, removing the private
environment graph. Independent noncommutative composition and host controls
pass. Its fresh saved-JS screen gives 1.080/1.452 times the materialized09 speed;
the larger point takes 0.6585 times TS. The emitter change removes two lines.
Checked11 builds with it in 55.30 seconds at 1.350GB peak tree RSS and passes
36 focused checks. Genuine checked11 output passes 22 oracle groups/39
boundaries plus the independent 85-observation fixture. These fresh semantic
receipts are separate from the saved-JS timing. A bounded numeric countdown
experiment is being evaluated independently; it is not yet source-integrated.

Map's compiler integration has exposed four overly conservative or misplaced
checks: a native/source distinction, Cmp node metadata versus nominal type
identity, normalized closed kind compatibility, and traversal of erased type
arguments as runtime calls. Checked11's full diagnostic now collects 24 typed
instances and 28 ordinary sources, passes exact replay, and reaches the shared
purity proof. Its next missing rule is the existing native String.append ABI.
The diagnostic overlay and native signature controls are separate from actual
compiler activation, which remains pending.

Dead lexer resume work is a smaller hypothesis. Both-prefix-and-projection and
separate variants pass the full source controls and 48 additional fenced
Unicode/host observations. The two-point attribution screen is uneven: prefix
removal alone barely changes lexer8, while removing dead String projections
improves it roughly 16%; lexer6 does not reproduce a consistent combined gain.
No broad liveness machinery is integrated on this evidence. A direct-wrapper
experiment also passes controls but regresses around 1–2% with a repeated inner
guard; its failure is retained before trying an enclosing-proof variant.

The independent tree pair controls are now settled. `products-source-pair08`
proves ordinary private pair activation on the existing renamed prefix source.
`pair-bst-ignored10-controls` passes seven ordinary results and six private
value/alias/deep controls on a separate source that discards old pair fields.
The plain scalar fixtures remain explicit old-scalar-precedence controls; their
failed positive-activation attempts were not relabeled as passes.

Checkpoint `6cbd0a1` is pushed. Later experiment and source work is still under
qualification. Production source has grown overall; the shorter callback rule
does not justify claiming that the whole compiler became smaller.

## Bounded numeric callbacks and actual Map admission

The saved numeric countdown screen (`callback-number-screen01`) measures the
larger closure point at 0.4455 times TypeScript and 1.576 times the checked11
BigInt-loop speed. Its independent fixture has 85 observations; 22 oracle
groups and 40 boundaries include the original BigInt fallback. The first source
proposal rebuilt synthetic Call nodes that the expression emitter does not
accept. Static review rejected it before a compiler build. The corrected v8
preserves App shells; `callback-number-lowering12` confirms exact emitted U32
expressions across boundary predecessors and records the rejected null output.
Actual compiler-emitted numeric qualification remains pending.

Checked12 builds in 50.64 seconds and passes 36 focused checks. Exact native
String.append signature proof and canonical kind headers let the actual Map
operation activate, with no diagnostic semantic overlay. The compiler proof
controller passes 71 signature, quantity, malformed-header and kind observations.
Both independent scalar and renamed Map fixtures compile. Their first two fixture
versions were invalid against the pinned Map.get ABI/parser and remain failures.

Actual Map execution then exposes a lowering bug: a private call around a
recursive child loses the shell needed by the iterative continuation emitter.
The resulting undefined temporary is a real compiler defect, recorded in
`run-map-actual12-controls`. Review also identified missing identity guards for
inlined primitive dependencies. A conservative complete primitive-family fence
is applied, but execution and mutation controls must pass before Map is measured
or selected. Activation and type proof alone do not qualify generated execution.

The final lexer wrapper experiment passes controls but has mixed timing:
about 7% faster on lexer8 and 3% slower on lexer6. Both optional lexer follow-ups
are deferred; their source patches are not integrated.

## Checked13–14 correctness checkpoint

Checked13 builds in 54.77 seconds at 1.373GB peak tree RSS. Its genuine numeric
callback emission passes all 22 oracle groups and 40 boundary controls, including
the original BigInt branch. Map now reaches execution but fails on an unbound
private instance name; this confirms the independent review's continuation-call
finding. The next repair keeps recursive App shells and emits a lexical call only
for an independently admitted private target. Unsupported ancestor shapes make
the complete plan refuse; they cannot fall through to a nonexistent public name.

Checked14 builds in 54.27 seconds at 1.370GB tree RSS and passes 36 focused checks.
Its actual execution qualification is running. New AST audits reject unresolved
private calls, empty continuation argument vectors and unbound saved temporaries.
The unannotated independent Map fixture is retained as a conservative purity
refusal. A separate explicit-annotation fixture tests the supported domain without
expanding the compiler's type-inference machinery.

## Actual checked14 source qualification and fresh screen

All three Map source profiles pass: the main operation has16 value groups,
6 alias controls,699 boundaries and3 ABI controls; each independent annotated
literal/renamed fixture has19 values,6 aliases,645 boundaries and3 ABI controls.
Actual private Map workers execute through ordinary roots, including the owned
2048-element case and12000-depth private probe. The numeric callback source
passes22 oracle groups/40 boundaries and its independent85 observations.

The fresh four-point `checked14-map-callback-screen01` compares the actual compiler
against checked16 and pinned TS in the same run. Map32/128 improves1.862/3.088 times
and remains44.47/28.55 times TS. Closure64/256 improves4.519/19.222 times and takes
1.929/0.422 times TS. Map's large within-process half drift makes this a preliminary
screen, not the final steady-state result. The complete45-point protocol remains
required. [Profiles](profile-findings.md) explain the remaining allocation and
dispatch gap; [accounting](accounting.md) separates production growth and experiment
history. The production module graph grows20,056 to21,440 lines, a6.9% increase.

The runtime assembly matches its fragments exactly. Independent scalar review
confirms the five protected executable scalar bodies are unchanged; the explicit
frozen contract classifies every other registration-envelope change. Current
source is checkpoint `b0770fc`, pushed with the rejected attempts and fixes.

## Release status

No new release is installed yet. Remaining work includes actual activation
and independent fixture controls, a bounded Map source experiment, source
freeze, inherited and new semantic gates, full 45-point runtime comparisons,
compiler-cost and complexity accounting, documentation and portable release
evidence. The final report will state rejected ideas and remaining gaps as
well as gains.
