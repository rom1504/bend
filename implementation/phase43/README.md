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
2GiB process-tree RSS ceiling and 2GiB available-memory floor. Controls and
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

## Release status

No new release is installed yet. Remaining work includes actual activation
and independent fixture controls, a bounded Map source experiment, source
freeze, inherited and new semantic gates, full 45-point runtime comparisons,
compiler-cost and complexity accounting, documentation and portable release
evidence. The final report will state rejected ideas and remaining gaps as
well as gains.
