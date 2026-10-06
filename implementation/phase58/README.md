# Phase58: allocation and generated-code improvements

**In progress; installation remains Phase56 string01.** The working selection is
`checked-shared01`, containing six general compiler-source changes. Its checked
build, strict 36-case agreement, focused controls and genuine own-source B2
emission pass. Final selected-image broad/B2 gates, repeated latency and
allocation comparisons, the full 45-point campaign, release checks and evidence
closure are still pending. Earlier checkpoint passes are not transferred to the
new image by assumption.

The [design](../../design/phase58/compiler-allocation-and-code-generation.md)
sets admission criteria. The main finding so far is that **representation and
emission choices carry substantial cost**: computed literal fields, intermediate
missing records, residual Word reconstruction, callback closures and copied SCC
switches create avoidable work. These observations do not show that Bend is
inherently slow, nor that all allocation/JIT activity is harmful. Each mechanism
has its own semantic proof and measured scope.

## Baselines and selected identities

Phase56's installed checked string01 release is the production comparator.
Pinned TypeScript at `018751270e800bc222a93dad7f257083ee53a5f7` remains the
independent reference, after Bend 2.0.34. It is not a fallback compiler. Retained
reference NaN defects remain explicit: source candidate96 versus TS95, and numeric
candidate34 versus TS28, where those existing gates apply. No additional candidate
mismatch may be waived using those historical defects.

| Binding | SHA256 |
| --- | --- |
| Phase56 checked B1 API | `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea` |
| Phase56 source | `5356ec9963db7b300e8cbdf5474328b72150f582df96b01aeea29d6a07868244` |
| Phase56 qualified B2/B3 | `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e` |
| Selected shared01 checked B1 API | `eddce7504207d91735e8369e7142f73ede8f77d8d2353b1ad6548796bdfd4569` |
| Selected shared01 source | `a4ad6717934a8596c6bf707ecabf11346f57ca5b4e4e08cdcbdaac7921546d9a` |
| Genuine shared01 B2 | `b7c5752d66ae4eaa8619e06b5a12655b370fba9d745d223660fbbb73da68fec8` |

The genuine B2 is newly emitted from the selected source by its own checked B1;
it is not the saved-image field or SCC diagnostic. Actual attempt, subject,
generator, runtime, Base, driver and Node bindings remain required alongside API
hashes. Image generation and eight ordinary-driver observations do not by
themselves establish a new B2→B3 fixed point or a fresh self-check. Those final
selected-image gates remain separate and pending here.

## Six production changes

| Change | General rule and retained boundary | Completed evidence |
| --- | --- | --- |
| [Literal fields](literal-fields.md) | Quoted ordinary keys for constructor/ordered/host-clone fields; exact `__proto__` stays computed. Values, own-property semantics and evaluation order remain unchanged. | Actual checked-source controls: 17 groups per role, complete values/prototypes/aliases/effects, and exact constructor/clone AST activation. |
| [Constructor lookup](lookup.md) | Skip intermediate missing KDef/KTerm construction on child misses; use checked annotated owner where proven, retaining global fallback and first-match semantics. | 135 actual annotated queries plus four fallback rows; synthetic malformed/cached/global controls; exact source oracles. |
| [Scalar residuals](scalar-residual.md) | Carry private U32 provenance through Word residual binders only when reconstruction covers all 32 positions of one origin. Refuse mixed/unproved/F32 shapes. | 1,728 counted observations per role across baseline, candidate and TS; arithmetic, aliases, callbacks, float bits and actual activation/refusal. |
| [Literal choices](literal-choices.md) | Structurally proved Bool/Unit selector with saturated literal callbacks becomes the selected continuation, preserving condition/prefix order and tail transfers. | 36 value/error oracles, nine host observations per image, eight function-shape checks, default-stack self/mutual tails through 100,000 steps. |
| [Reachability deduplication](validation.md#completed-choice-reach-and-shared-checkpoints) | Deduplicate repeated target references within one emitted definition; preserve validation, encounter order and all existing resource limits. | 22 scanner and 21 graph observations per role; reach01 full emission and its own fresh source check. |
| [Shared mutual-tail dispatch](shared-scc.md) | One private switch worker per multi-function SCC; original entries retain formals and fixed PCs, complete refs and per-call local state. | Original choice controls plus shared shape checks; nine supplemental library oracles, 12 host observations per role, one three-role program oracle and three component checks. |

These counts overlap and are not a unique source-program total. The direct
runtime, legacy runtime, ordinary driver and all **17 native modules** remain
byte-identical to Phase56. No native representation change, new runtime cache,
TypeScript fallback or relaxed frontend gate is introduced. Bootstrap and
private-image legacy clients are not retired by these direct-output changes.

## Isolated measurements and what they establish

The [compiler latency record](latency.md) separates saved-image causal ablations
from genuinely changed-source images and from generated-program execution.

| Experiment | Completed result | Limit |
| --- | --- | --- |
| Literal-field syntax, fixed Phase56 B2 source | Three rounds, six fresh processes: import/API/first median **3,147.51→2,373.32 ms (24.60% less)**; median of per-process later-request medians **1,778.88→1,377.90 ms (22.54% less)**. All emitted lexer bytes match. | Saved syntax derivative is explicitly unchecked; one source fixture, primed Base disk cache, continuing warmup; no memory reduction established. |
| Constructor-query hooks | Across 139 actual/fallback rows, `missing` calls **4,248→3**; annotated subset **2,391→0**. | Counts are query-local helper invocations, not total allocated bytes or an equivalent request speedup. One-pair lexer timing is essentially flat. |
| Reach01 genuine B2 lexer pilot | Import/API/first **3,291→1,531 ms**, sole later request **2,221→755 ms**, versus baseline B2. | One process per role and changed compiler source; promising diagnostic, not repeated selected-image throughput. |
| Shared-dispatch saved-image pilot | API load **174.890→95.616 ms**; sole later request **749.915→750.518 ms**. | Large code-size saving, essentially flat later-request observation; one pair, no isolated parsing/JIT/memory attribution. |

The first single-pair field pilot remains retained separately; it is not pooled
with confirmation. First requests, API imports, later requests and complete
process wall time are distinct denominators. No profiled or traced duration is
put into clean timing. The final selected B1/B2/TS request matrix and collected-
object allocation comparison will be reported only after their jobs complete.
No fresh program-speed result is inferred from these compiler-request studies.

## Source growth versus emitted-image duplication

[Selected source accounting](source-complexity-shared.md) uses unchanged Phase47
counting rules and frozen attempts. Manifest Bend source grows **26,246→26,555
physical lines: +309 (1.18%)**, with +234 code lines, +42 definitions, one type
and one module. Selected totals are 21,819 code lines, 3,054 definitions, 101 types
and 108 modules. This is not source simplification or a smaller compiler-source
claim. Ninety-eight original modules retain exact bytes; support/native identity
is verified independently.

Literal-choice lowering exposes additional mutual-tail edges. The existing
emitter originally copied each complete SCC switch into every entry. After
reachability deduplication allowed the full source through, reach01's genuine
B2 grew to **8,671,962 bytes**. The static census found 133 repeated loop groups
across 437 entries, including a 70,138-byte loop repeated 34 times.

Sharing those components produces a genuine shared01 B2 of **3,815,480 bytes**,
including 3,393,116 definition bytes and 409,081 export bytes. This is distinct
from the 3,812,483-byte saved diagnostic derivative. It also compares with the
Phase56 3,896,951-byte image, not an invented zero-cost source baseline.
Source line growth and emitted-file shrinkage measure different things; neither
alone determines runtime allocation, latency, correctness or maintainability.

## Checked and bootstrap checkpoint progression

Fields01 and lookup01 builds pass their 36 initial paired witnesses with zero
exact differences, but their configurations omitted `strictExact`, defaulting
to false. Image-admission controllers that demanded the flag refused them before
target observations. Preserved successors verify the actual completed exact
results and record the flag honestly. Scalar01 and later builds explicitly set
strict exact checking; no checked receipt is rewritten to change its scope.

Choice01 then completes a 14-job checked integration stage: source96, numeric34,
composition18, overapplication2, direct census26, maintained8, all45 program-value
smoke checks and three native output/byte pairs. Its full compiler-image emission
subsequently refuses the unchanged reachability edge budget after 54.450 seconds.
The checked-stage pass is valid for choice01; the refused bootstrap is not passed
or silently transferred to a successor.

Reach01's scoped deduplication preserves the **4,096-definition / 65,536 queued-
dependency / 2,097,152-character per-definition** limits. Its genuine full B2
emission completes in 104.416 seconds, and tiny comparison, both eight-observation
driver roles and image join pass. Its fresh own-source ordinary type check passes
in 10.451 seconds internally, 17.090 seconds in the worker; expected unsafe
proof-trust failure is recorded separately. This is not a mathematical proof or
new fixed point.

Shared01's checked build and strict36 exact agreement pass. Its genuine full B2
emission completes in **75.638 seconds**, with 13.939 seconds in emitted
reachability and 7.694 seconds in definitions. Tiny comparison, both driver roles
and the image join pass. These are individual instrumented pipeline observations
over different sources, not a controlled clean emission-speed ratio. Reach01's
self-check cannot qualify the new shared image automatically.

## Preserved failures and diagnostic limits

Failures remain alongside successful successors; details and exact identities
are in the linked owner reports and raw recipes.

- Field fixture v1 fails baseline quantity checking because a duplicated shared
  product was declared Type. V2 changes that declaration to Data and retains the
  sharing oracle. No candidate code had run at the failure.
- Field controls-v2 count unrelated `prototype:true` export metadata as a field.
  V3 scopes exact constructor/Nat-clone routes and retains all runtime/prototype
  gates; the failure remains preserved.
- Lookup admission v1 rejects the pilot's `strictExact:false` flag. The successor
  checks genuine completed 36-case exact results without relabeling the flag.
- The initial scalar TS acquisition hits a sandbox `git` spawn refusal; a fresh
  permitted acquisition succeeds without changing source or expected values.
  Consumed paired-producer bytes are preserved; hardened tooling is versioned.
- The initial choice negative fixture uses reserved Bool/Unit names and is
  rejected by the frontend. Its successor uses legal OpaqueBool/OpaqueUnit,
  retaining an ordinary-layout refusal test rather than claiming valid shadowing.
  Review also caught condition-prefix ordering in an early unbuilt draft; it was
  fixed before any choice compiler build.
- Choice01 full-image emission refuses its reachability budget. Deduplication
  solves repeated edges without increasing limits or ignoring malformed metadata.
- Shared choice controls first pass their values/host checks but fail a VM-array
  prototype assertion. The successor copies AST arrays into the host context,
  retaining identifier/structural expectations; no compiler fix is credited.
- Supplemental shared controls first pass library/host observations, then fail
  child launch with sandbox `spawnSync EPERM`. A fresh permitted run passes with
  unchanged source/controller; the environment refusal is not a semantic pass.

The failed data-only field derivation's initial missing output-parent-directory
refusal is also retained. None of these unsuccessful attempts is pooled into
passing counts, omitted from evidence, or repaired in place. Final time accounting
and publication must include remaining failed attempts and report their scopes.

## Remaining admission and publication

| Selected shared01 obligation | Status at this report checkpoint |
| --- | --- |
| Checked source build and initial strict36 agreement | **Pass** |
| Focused changes, shared dispatcher controls, full own-source B2 generation and eight-driver joins | **Pass**, with scopes above |
| Final selected checked-B1 broad semantic/maintained/census/native/program-value matrix | **Pending**; choice01's earlier matrix remains historical |
| Selected B2 broad semantics, fresh source self-check and exact B2→B3 reproduction | **Pending** |
| Repeated selected B1/B2/TS compiler latency and allocation | **Pending** |
| Full selected 45-point generated-program timing / 669 samples | **Pending** |
| Install, integrity, 42 legacy + 24 default ordinary/relocated interfaces | **Pending**; installed release remains Phase56 |
| Raw writer closure, protected-file verification, complete archive and reproducibility index | **Pending** |

The [qualification plan](validation.md) keeps correctness, compiler latency,
allocation, generated-program execution and release interfaces separate.
[Timing accounting](timing-accounting.md) describes the eventual occupancy ledger;
it is not a completed end-of-campaign result. Root runs targets serially on CPU3
under the existing heap/tree-RSS/available-memory limits. All historical
Phase54–57 raw evidence, prior release files and 103 protected unrelated files
remain preservation obligations. No commit/install/publication claim follows
from this report skeleton.
