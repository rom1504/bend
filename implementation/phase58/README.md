# Phase58: compiler allocation and code generation

**Last01 is installed and verified.** Compiler allocation and self-hosted execution
improve substantially; generated-program performance is preserved.

Phase58 implements six general optimizations in the compiler written in Bend:
constructor lookup without intermediate missing records, proven scalar reconstruction
cancellation, literal-choice lowering, reference deduplication, shared mutual-tail
dispatch, and a revised literal-record printer. The final printer leaves the last
live constructor field computed while quoting ordinary preceding keys; `__proto__`
always stays computed. This balances compiler speed with generated-program speed.

[Design](../../design/phase58/compiler-allocation-and-code-generation.md) ·
[Final selection](../../design/phase58/last-field-selection.md) ·
[Reproduction recipes](../../selfhost/tools/performance/phase58/README.md) ·
[Mechanism documentation](../../docs/self_hosted/compiler-allocation.md).

## Final measurements

The clean same-method self-emission takes **36.058 seconds**, compared with
**223.475 seconds** for the retained Phase56 control: **6.20× faster**. The
baseline is an earlier run in this campaign, not a freshly consecutive pair.
Both runs use their own exact compiler source and the same frozen method; the
output is checked against each image independently.

Fresh B2 import-plus-first requests improve from **5.14–5.51× TypeScript to
2.42–2.62×**, across Evening and Lexer with three fresh processes per role/input.
Later requests are **2.44–2.99× faster than Phase56**, still **2.55–2.73× TypeScript**.
Those later sequences are still warming; this is not steady-state throughput.
Checked B1 remains roughly flat: first-request changes −0.76%/+1.59%, later
−2.78%/+3.89% for Evening/Lexer. B2 gains are not B1 gains.

Fresh B2 Lexer allocation sampling falls from **2,190.55 to 231.95 MB per
request: 89.4% less cumulative allocation**. TypeScript uses 59.67 MB per request
in this capture, so B2 remains about 3.89× higher. These estimates include collected
objects and are not retained heap or peak RSS. There is one profile worker per
role, with 3/11/32 completed requests; TypeScript reached the request cap. B1
allocation was not remeasured for last01.

See the [final measurement report](final-measurements.md) for individual runs,
allocation counts, profile attribution and exact evidence identities.

![Selected compiler latency](figures-last01/compiler-latency.svg)

![Selected B2 cumulative allocation](figures-last01/compiler-allocation.svg)

The full generated-program campaign passes **45 points / 23 sources / 669
samples**. Equal-point geometric mean is **1.046110× TypeScript**, versus
**1.061731×** for Phase56 (1.47% less execution time). Equal-source means are
1.040502× and 1.066364×. No point regresses by more than 3%; the largest is
edit-distance size3 at +2.949%. There are 19 small measured regressions, retained
in the [full program report](program-performance.md), and zero configured timing
flags. Evening improves 26.48%; RLE improves 12.75%. Eighteen points beat TypeScript.
These aggregates are close to parity on this corpus, not a universal performance
guarantee.
Earlier shared01 measurements are preserved in the
[historical checkpoint](shared-checkpoint.md) and [latency investigation](latency.md).
They are not measurements of the final last01 compiler.

## What changed and why

| Mechanism | General rule | Semantic boundary |
| --- | --- | --- |
| [Constructor lookup](lookup.md) | Avoid intermediate missing KDef/KTerm objects; use a checked owner annotation before the global fallback. | Preserve first-match behavior, malformed-query handling and fallback. |
| [Scalar residuals](scalar-residual.md) | Carry private U32 origin facts through residual binders and cancel complete reconstruction of that same word. | Require all 32 positions of one origin; refuse mixed, unproved and F32 shapes. |
| [Literal choices](literal-choices.md) | Lower structurally proved Bool/Unit choices directly to the selected continuation. | Preserve condition and prefix order, demand, errors, partial application and tail transfers. |
| [Reachability](validation.md) | Deduplicate target references within each emitted definition. | Preserve encounter order, validation and all existing resource limits. |
| [Mutual-tail dispatch](shared-scc.md) | Share one switch worker per multi-member tail-recursive component. | Keep entry formals, fixed program counters, complete references and local per-call state. |
| [Record syntax](record-syntax-tradeoff.md) | Quote ordinary constructor prefix keys; compute the final live key and every `__proto__`; host marshalling retains quoted ordinary keys. | Preserve own-property semantics, evaluation order, erased fields and prototype behavior. |

The direct runtime, legacy runtime, ordinary driver and all 17 native modules
retain their Phase56 bytes. There is no TypeScript fallback, runtime cache or
frontend relaxation. The native and legacy interfaces remain supported.

The constructor-query probe reduced missing-helper calls from 4,248 to three
across 139 actual/fallback queries; the annotated subset went from 2,391 to zero.
These are helper counts, not total allocated bytes. Scalar controls cover 1,728
observations per role. Choice and shared-dispatch controls include callback/error
behavior and self/mutual tails through 100,000 steps. Their earlier exact APIs
remain attached to those results; source-delta checks establish unchanged logic
in last01, while fresh whole-compiler integration gates qualify the combination.

## The important negative result

The intermediate shared01 compiler substantially reduced compiler cost, but its
full 45-point campaign found regressions in Morning, Map/Set and edit distance.
It was never installed. A dispatch ablation did not explain the regressions.
Exact source comparison showed that ordinary field-key syntax was the entire
old-to-new difference for Map/Set, edit distance and local-pair.

Reverting all fields in the compiler image cost about 50–68% on the screened
compiler requests. A small-record cutoff also lost compiler performance. The
last-live-field rule restored the three targeted programs in a 45-sample screen:
Map/Set −2.84%, edit distance +0.19%, Morning +1.09% versus Phase56. It cost
13–17% relative to the all-literal compiler diagnostic, missing the approximate
10% screen target. We explicitly selected this compromise for full qualification,
not a claimed threshold pass. Actual last01 output for all three programs matches
the screened derivatives byte for byte. The final fresh full-corpus results confirm removal of the earlier regressions;
the focused screen is not substituted for that campaign.

V8 inspection found the same eight inlined functions, four static allocation
paths and zero executed deoptimizations in the compared edit-distance row.
Object map initialization differed, but the data does not prove a particular
V8 cause or justify a record-width cutoff. The unexecuted synthetic syntax grid
stays labeled unexecuted. See [the source/trace evidence](program-regressions.md).

## Correctness and release scope

The selected checked build passes strict36 exact agreement. Fresh focused record
checks cover 17 groups per role plus nine supplemental groups, including trailing
and all-erased fields, `__proto__`, ordered callbacks and throws. The checked B1
integration stage passes all 14 jobs: source96, numeric34, composition18,
overapplication2, direct census26, maintained8, all45 program-value checks and
three native output/byte pairs. Counts overlap; they are not a total of distinct
programs.

The final B2 freshly accepts its source in 11.712 seconds internally (17.415
seconds overall), with all 3,055 explicit unsafe declarations producing the
expected proof-trust refusal. A separate gate emits byte-identical B3 in 39.199
seconds. These are qualification timings, not the clean speed comparison below.
B2 also passes source96, numeric34, composition18 and overapplication2; all 23
benchmark sources and 45 generated modules match B1 exactly. Installation, integrity before/after, **42 legacy + 24 ordinary/relocated interface
checks all pass**. Type acceptance and expected
unsafe proof-trust refusal are separate; self-reproduction is not a mathematical
proof. Pinned TypeScript remains `018751270e800bc222a93dad7f257083ee53a5f7`.
Its known NaN oracle defects remain explicit: source95 versus candidate96 and
numeric28 versus candidate34. No new candidate mismatch is waived.

The installed artifact remains a checked-derived B1. Installing the faster,
independently qualified B2 needs truthful emitted-image lineage support; that
separate packaging follow-up is described [here](b2-installation-followup.md).
B2 performance must not be advertised as installed-B1 request performance.

## Source complexity and image size

[Final accounting](source-complexity-last.md) uses unchanged counting rules:
26,560 physical lines, 21,823 code lines, 3,055 definitions, 101 types and 108 modules.
Against Phase56 that is +314 physical lines (1.20%), +238 code lines, +43 definitions,
one type and one module. This phase improves execution, not source line count.
The final record rule itself adds five physical lines and one helper versus shared01.

Choice lowering exposed mutual-tail edges that initially expanded the image to
8,671,962 bytes because each entry copied its component switch. Sharing removes
that duplication. The final B2/B3 is 3,821,470 bytes, 1.94% smaller than Phase56
(3,896,951 bytes). Its SHA256 is
`a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`.
The much larger saving against the expanded intermediate is not a saving against
the starting release, and emitted-image shrinkage is not source simplification.

## Remaining work suggested by the profiles

Intermediate profiles point to string scanning in emitted reachability and
library emission, substitution, persistent index operations, and driver span/Base
cache validation. The final selected profiles distinguish which remain hot.
A blind replacement of Bend string search with JavaScript `includes` is not
semantically equivalent at surrogate boundaries. Any next string optimization
needs an origin-reuse proof or a proved input domain.

One old-B2 whole-source allocation capture exceeded the unchanged 2 GiB tree-RSS
guard after 124.707 seconds. Its empty profile provides no baseline allocation
result. We retained the failed attempt and did not increase the limit. Ordinary
request allocation and clean image timings are independent successful methods.
Cumulative sampled allocation is not retained heap or peak RSS.

## Reproduction and preservation

All unsuccessful attempts and their corrected successors remain recorded in the
[historical checkpoint](shared-checkpoint.md), mechanism reports and raw campaign.
Consumed producers and closed Phase54–57 evidence are immutable. Root ran heavy
jobs serially on CPU3 with a 1 GiB Node heap, 2 GiB process-tree RSS limit and 4 GiB
available-memory floor; agents handled code, review and data analysis separately.
[Time accounting](timing-accounting.md) reports observed supervisor intervals,
not invented CPU usage or agent effort.

All **17,639 closed Phase54–57 files**, **103 unrelated files**, and all seven
prior installed files pass preservation checks. The closed archive contains **30,169 files / 1.303 GB uncompressed**, reopened
and hash-verified, with exact ordered transport parts. Closure and the complete
archive are recorded in the [publication index](../../selfhost/tools/performance/phase58/publication.json).
No PR comment was posted.
