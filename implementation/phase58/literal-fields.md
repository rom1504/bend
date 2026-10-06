# Literal record fields: mechanism and isolated outcome

The source implementation passes its focused checked-source controls. A separate
saved-image syntax ablation reduces the lexer compiler request's median
import/API-load/first-request interval **3,147.51 → 2,373.32 ms (24.60%)**, and
its median later-request statistic **1,778.88 → 1,377.90 ms (22.54%)**. These
are isolated compiler-request results, not generated-program execution speed or
qualification of the diagnostic image as a shipped compiler. Final combined
selection and release belong to the [Phase58 report](README.md).

## General source change

One JS-specific helper, `jd_literal_field_key`, emits a quoted ordinary object
literal key except exact `__proto__`, which remains computed. Three existing
sites use it: `jd_ctor_fields`, `jd_ordered_field_join`, and
`jd_host_marshal_field`. There is no benchmark-name selection, type-proof change,
threshold or runtime guard removal. Constructor values, ordered prefixes,
telescope specialization, erasure and host field reads remain unchanged.

`"constructor"`, `"prototype"`, `"default"`, dotted names and underscored names
are legal quoted keys. `__proto__` is special because a noncomputed object
literal property can select a prototype instead of creating an own data property;
it must retain `["__proto__"]` in both constructors and host spread-overrides.
The [reviewed patch and qualification guide](../../selfhost/tools/performance/phase58/fields/README-v3.md)
retain exact producer/source identities and the source oracle.

The [Phase57 V8 inspection](../phase57/v8-findings.md) supplies the motivating
mechanism: ordinary B1 kt uses 38 bytecode bytes and 532 optimized instruction
bytes; computed-key B2 kt uses 103 and 788. The latter retains successive map
writes and three main-path runtime entry calls at its final property-definition
sites. Aliases and the trivial loop disappear from its optimized return path.
Both inspected versions reserve the same `0x90` young-space allocation batch,
including a heap number, Nil and KTerm. Changing field syntax does **not** by
itself establish fewer allocation bytes, eliminate objects, or prove caller
inlining. Those are separate questions.

## Actual checked-source controls

Fresh private paired acquisition `fields-fixtures02` passes both genuinely
checked images in 19.5 seconds. It copies APIs, drivers and runtimes into private
Phase58 projects with fresh ordinary Base caches, avoiding writes into closed
Phase56 snapshots. Baseline is checked-string01; candidate is checked-fields01.

`fields-controls03` passes **17 observation groups per role** in the root's
5.33-second supervised job. It verifies complete own values, descriptors,
prototype and key order, wrapping U32 values, Nat conversion and roundtrips,
unchanged input fields, shared shell identity, callback ordering, throw identity,
reentry, partial application, getter traces and noninvocation of an inherited
`__proto__` setter. Both incomplete partial calls have explicit zero-event gates.
The Nat roundtrip getter trace retains exactly twelve accesses in both roles;
no event is discarded to obtain agreement.

The AST gate covers precisely the three source emission routes, after the exact
runtime prefix: five fixture constructor objects and four Nat marshalling clones.
Constructors have 19 ordinary keys and four `__proto__` keys; clones have eight
ordinary and four `__proto__` keys. Baseline ordinary keys are computed; candidate
ordinary keys are plain. All eight `__proto__` keys remain computed, with zero
plain forms. This proves actual emitted syntax change alongside runtime values.

The controller binds its producer, exact fixture/catalog, genuine checked
attempts, private copies, selected APIs/runtimes and all emission inputs.
Checked-fields01's pilot build has **`strictExact:false`**; this flag is recorded
honestly. Its retained completed validation nevertheless has 36 reference and
36 candidate witnesses with zero exact differences and zero discrepancies, which
the focused controller independently requires. Later strict builds and broad
gates remain separate evidence.

| Actual checked identity | SHA256 |
| --- | --- |
| Baseline API | `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea` |
| Fields01 API | `ef4692ccc61dd7324b371f08b22c6f406418e99973a95769f378e2807c3eba97` |
| Controls-v3 producer | `0b9b20a1b34bbcc97c89e0989037f1df938f96aa5ebc6a310de37ba889f4f959` |

## Saved-image causal compiler-request confirmation

This confirmation isolates syntax in the same genuine Phase56 B2 compiler
image. A data-only Acorn transform changes 7,297 post-runtime ObjectExpression
constant-string computed keys into quoted ordinary keys. It leaves
`__proto__` computed, changes no MemberExpressions or value expressions, and
verifies normalized AST equality plus exact source inversion. This compiler
image contains no `__proto__` field site, so the checked fixture above supplies
that independent semantic witness. The diagnostic receipt explicitly records
`productionQualified:false`; it is not a checked bootstrap or self-emitted fixed
point.

Three rounds rotate the two roles in fresh processes, each with first ordinary
request and three later requests. Private Base disk caches are primed outside
samples and reused from the completed pilot preparation. Cache/filesystem coldness
is not implied. The later statistic is the median of three per-process medians,
not an independent steady-state guarantee: the three requests continue warming.
No inspector or trace flags contaminate this clean confirmation.

| Lexer request measure, ms | Baseline median (range) | Syntax candidate median (range) |
| --- | ---: | ---: |
| Import + API load + first request | 3,147.51 (3,139.06–3,152.26) | 2,373.32 (2,368.77–2,376.44) |
| First request alone | 3,044.11 (3,036.20–3,047.58) | 2,270.27 (2,265.40–2,272.80) |
| Per-process later-request median | 1,778.88 (1,749.95–1,787.29) | 1,377.90 (1,361.72–1,510.83) |

The whole confirmation takes 66.99 seconds; six fresh processes complete and
check all emitted outputs. Both roles emit exactly **28,452 bytes**, SHA256
`7391f503044de65bff0836feaeb8cabcc3ca10b888e081b83fe814c1286d826e`.
The full catalog value is checked during preparation; every later emitted output
is compared to that role's prepared bytes. Cross-role bytes also match, although
the saved-image diagnostic method records that comparison as an observation
rather than its general acceptance rule.

Process peak-tree RSS ranges are 552,210,432–555,675,648 bytes for baseline and
553,754,624–557,367,296 for candidate. This is no observed memory reduction.
Node is pinned to v24.18.0; requests use CPU3, a 1 GiB heap, 2 GiB tree-RSS limit
and 4 GiB available-memory floor. API loading is about 99 ms in both roles, so
the improvement here chiefly concerns request work rather than import cost.

Baseline diagnostic API is `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`;
syntax candidate is `83224c065a9d12ce3fcd0bda6e0f1884ccf423fb46249d52fc17d74dca239f14`.
These differ from the genuinely checked source candidate's API above.

## Preserved failures and evidence boundary

V1 fixture acquisition fails before candidate emission: duplicated
`shared(+value:P58Fields)` needs a Data type, but P58Fields was declared Type.
V2 changes only that declaration to Data and retains the sharing oracle. This
is a fixture quantity correction, not evidence of a compiler optimization bug.

Controls-v2 then fails its baseline syntax gate because global Property traversal
counts unrelated export metadata `prototype:true`. Controls-v3 replaces that
scope with exact constructor/Nat-clone shapes and the exact runtime boundary.
It preserves every runtime/provenance assertion and strengthens syntax counts;
no real `__proto__` behavior is waived. V1/v2 consumed files, refusal and failed
control receipts remain unchanged.

[Compact hash-bound evidence](evidence/literal-fields.json) joins controls,
confirmation statistics and input hashes. Raw members are
`selfhost/build/phase58/fields-fixtures02/manifest.json`,
`fields-controls03/report.json`, `fields-latency-confirm01/report.json`, and
`fields-derivative01/derivation.json`. Focused correctness and a one-fixture
syntax ablation do not establish full language conformance, general compiler
throughput gains or an installed Phase58 release.
