# Phase48 isolated RNFA composition

This document preserves RNFA02/03 assembly and correction history. RNFA03 passed
the strict checked build in 50.4437 seconds and completed full acquisition.
The final successor is RNFA04, with the separately proved literal-count decline
policy; its current measurement and release status is in the [phase report](README.md).
The source-composition author executed no target jobs; root owns qualification.

Selected inputs are the frozen `source-composite01`, `source-native01`, `source-float01`, and `source-arrays03` snapshots, composed against `phase47/checked-array06/snapshot`. V/H changes are excluded. The reviewed `private-float-array-composition-v1.patch` contributes only two JF32 audit admissions.

Frozen project: `selfhost/build/phase48/source-combined-rnfa02`; build configuration: `selfhost/build/phase48/combined-rnfa02-config.json`. Composition receipt: `selfhost/build/phase48/integration-rnfa02/composition-receipt.json`, SHA256 `ba6737ace4aefab4a230d338f0e151cce743626d9fe758c0eb32f1c676ce9135`. Its input identities and per-file baseline/output identities preserve exact provenance. The ordinary snapshot receipt binds all copied baseline files and overlays.

## Static self-review

- All reviewed variant patches apply with zero fuzz; offset adjustment composes independent overlapping-file hunks. Manifest lists 92 unique modules, all present; the 2,662 textual definition names are unique. Tools/tests match the checked array06 snapshot byte for byte. No runtime fragments change.
- Composite selection runs only after the existing region root produced empty code. A strong composite plan keeps original Array handles and the final public ctor shell. The literal adapter is reached only for a non-strong plan and never displaces nonempty existing region code.
- Shared typed array/native proof delegates, argument order, raw versus handle mode, and fresh arrayViewHostGuard remain the reviewed arrays03 mechanisms. Composite results retain the complete full guard.
- Finite F32 leaves are created only by the existing successful typed-region traversal; nm remains F32, and full float proof is retained. Both raw/handle closed-array audits accept the new leaf without admitting a new effect or escaping representation. Exponent255 retains original decoding; shared DataView write stays at literal demand.
- JW native String.append emitter is unchanged from native01 and retains its original fallback for other names/arities. No V/H planner or emitter broadening is included.
- Source composition is not semantic validation: root must run fresh combined checked acquisition and composition controls, including actual entry, host mutation/refusal, shared-view demand, and handle identity.

## Preserved preparation correction

The first preparation `source-combined-rnfa01` accidentally included a patch-generated `emit.bend.orig` backup as an unlisted overlay. No target ran from it. The original producer and all 01 receipts are preserved. `assemble-combined-rnfa-v2.py` disables patch backups and creates the clean 02 successor with 14 changed files; no `.orig` or `.rej` remains.

## RNFA02 preparation hashes (preserved parent)

| File | SHA256 |
| --- | --- |
| `src/back/js/array-effect-guards.bend` | `c024d8969c275d66d00a8483b0e7d35e882e5af50d5d14bc985fadd9870c7580` |
| `src/back/js/array-effects.bend` | `bbae40d6a1929b83189d5ad8942a66857a967a305aa1f5d87bcbfe16e6d3b04d` |
| `src/back/js/array-literals.bend` | `9bd9568c55f00f0ed177b95903fac89807934191982b3e3c271ddd89c65b7485` |
| `src/back/js/array-result.bend` | `1eb531ca87139383c976699d43166b1aa736d2e8cb83a87ea177ce55c7bb3582` |
| `src/back/js/array-view.bend` | `3ff09fec7396c8bc8caf21fb8e63ecb22255e8e06d2a7896fe27e51f46524cb3` |
| `src/back/js/emit.bend` | `c839a308ee173c1057f7145b357caac56b72d59ad635db8c6b2ad6b735be6472` |
| `src/back/js/fold.bend` | `d714084b17562a0bb8902be412aa1e3c9887e341217e3e057ed79d51cc794a1b` |
| `src/back/js/ir/native-values.bend` | `9fb4835dddffb59aec3cb0ed4ced58867182abcb5b88fa675f2d07f4c4e38372` |
| `src/back/js/ir/worker-emit.bend` | `6d4d2de819c61037db8b2a52182136aa2df7de3ab5c9bc307cf5fb952f1c517b` |
| `src/back/js/local.bend` | `388c8d90a67817fdd02eed50ae96767f72bbbdcca004d687413a9ece1e41e19b` |
| `src/back/js/private-float.bend` | `07155fa45b6dde83a158843cc25b8c586c796a891c7ff0931bbcb59333de29b9` |
| `src/back/js/region.bend` | `bc129162b65a4cacb85d0b43d2300a01e389413a03520a7159108507b3db990f` |
| `src/back/js/tree.bend` | `a91086de26138367d8dd4f029cb2463f2c48448f4fbc743345098b469e0b29b0` |
| `src/compiler.json` | `598d2563fecc08f64d7081501478c35dce20998b0e46f67e68b3290847779704` |

All six new modules are manifest-listed: private-float, array-effects, array-effect-guards, array-literals, array-result, and ir/native-values. Eight existing files change: emit, region, tree, array-view, fold, local, ir/worker-emit, and compiler.json.

## RNFA03 checked successor and eager-predicate correction

`source-combined-rnfa03` copies the checked RNFA02 snapshot and overlays only
`src/back/js/array-effects.bend` with the reviewed
`selfhost/tools/performance/phase48/proposals/array-effects-lazy-v1.bend`.
Data-only comparison confirms every other source/tool/test byte remains identical.
The correction introduces two predicate helpers, leaving the 92-module manifest,
selected R/N/F/A features, admission rules, emitted operations, and runtime guards
unchanged.

Bend `Bool.and` evaluates both operands. RNFA02's `j_array_effect_native` used
an apparent `&&` rejection chain before calling `j_array_effect_definition`.
The latter eagerly normalized `kid(spine,0)` as an erased element type even for
an ordinary nonnative call. That first argument can instead be a live computation;
normalizing it is inappropriate demand on rejected input. RNFA03 uses `kc` to
fence tag/name/arity, native owner, and erased telescope before element
normalization. The array and array-of predicates likewise fence element demand
until the corresponding shape proof succeeds. This is a concrete rejection-order
bug; whether it caused the RNFA02 heap failure awaits fresh acquisition evidence.
The reviewed overlay receipt is a pre-execution input and remains unchanged.

The root-owned checked job completed with return code 0 in 50.443743169 seconds,
using the unchanged 1,024 MiB Node heap. The attempt has checked=true,
strictExact=true, profile=equality, fullFrontend=false. It is a checked B1
derivative, not a new self-emitted fixed point.

| Identity | SHA256 |
| --- | --- |
| RNFA03 source snapshot receipt | `25db6b1c960270777a3a63d56d0437290fdd43ca8c4b38022d00c43daf58e4c9` |
| RNFA03 checked attempt.json | `605171cceef8847af3f7560b933c550be8c4353aa5836f5bd1718afd4517cf5e` |
| RNFA03 equality API | `a64c4dceb00f60c7cdb9994afb864564f4ff9a9c8b1c143b066db793b9ba738b` |
| RNFA03 bootstrap metadata | `17c2ee1b5eaf75640ec991c40e4622d682e62c83d449b0c0f72dbdc8076553e2` |
| RNFA03 bootstrap source image | `c90da91e7d9fbbfaf9186b9d5f236da8923ce8cdb2258cff4738d5cd623069e0` |
| Lazy array-effects overlay | `e74844cc241cc3185363ccea6c477a3fcd6c58012a59244aaad805c6c1b41abd` |
| Runtime, unchanged from array06 | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |

Exact source receipt: `selfhost/build/phase48/source-combined-rnfa03/snapshot-receipt.json`;
checked metadata: `selfhost/build/phase48/checked-combined-rnfa03/attempt.json`;
job: `selfhost/build/phase48/job-checked-combined-rnfa03/process.json`.
All file identities above were rehashed. Runtime bytes equal the checked array06
runtime, rather than merely sharing a reported hash. The ongoing full campaign
`selfhost/build/phase48/combined-rnfa03-full` covers 23 sources/45 points, with its
acquisition/semantic/timing outcomes pending. RNFA02's failed emission, OOM logs,
and the trace confound remain documented in [the static failure note](combined-rnfa-oom-static.md).

## First-source reacquisition outcome

RNFA03 successfully acquires the same historical local-row source that failed
under RNFA02: `combined-rnfa03-full/emit-00/process.json` reports return code 0,
6.1255 seconds and peak process-tree RSS 553,205,760 bytes. Its exact checked
module receipt is `combined-rnfa03-full/modules/local-row.mjs.json` (SHA256
`332b3eefe73b52f2be6cfd4e990f51b75f3a472facd7fa730f4d27533e631cec`); emitted module SHA256
`822156fcf6deec02d910fd5e8e042616e600ff42d09386693d0efa0f92a4cb15`.

The source input and heap limit are unchanged; source comparison finds only the
lazy array-effects overlay changed. Success with roughly half the former peak
RSS strongly supports premature predicate demand as the failure cause. This
single before/after acquisition is not a memory benchmark or an independent
predicate-demand control; the latter remains pending. Root reports 13/23 source
acquisitions passed at this update, so no full-corpus pass or promotion is claimed.

## Evening exact-output comparison

All 23 source acquisitions/45 campaign points are now prepared (root campaign
status); semantic and timing qualification remain separate. A data-only exact
comparison of `combined-rnfa03-full/modules/test-evening-program.mjs` against
`phase47/array06-full/modules/test-evening-program.mjs` finds the entire 177,066-byte
module identical, SHA256 `b21b0bbd4e40873907038838d89c559ef73d6c7e599f87e63e94b9f5be77f8b7`.
All 85 complete generated G assignments therefore match, as do runtime and module
export bytes. Acyclic fpart has no private literal-array adapter or private-F32
marker; its original 249-byte assignment remains intact.

The rejected arrays02 output is 178,676 bytes, SHA256
`b67afedbacb274617512fab203affa39ba44a6dd4128ee992e49d18f51e490b6`.
Its only changed G assignment is fpart (249→1,859 bytes), containing one private
literal-array adapter marker. RNFA03 restores this exact output discrepancy by
retaining the loop-qualified gate. There is no unidentified F32 change to waive;
RNFA03's entire Evening output matches baseline. This establishes saved-code
identity, not a fresh runtime or timing result.

Complete assignment comparisons and exact input hashes are preserved in
[evidence/combined-evening-comparison.json](evidence/combined-evening-comparison.json)
(SHA256 `54c9b491610173a51028e1de4309857dc7eaf67deb51737a8ac50812cea97d08`).
The assignment scanner respects balanced expression delimiters, strings and
comments; the whole-module byte comparison does not depend on that scanner.

## Independent F32 composite qualification

The corrected source-v2/controller-v3 composite-float control group passes 50
exact value observations and five paired boundaries on checked array06 versus
RNFA03. Actual counter derivative witnesses two clean composite entries and no
clean fallback; zero call writes only initial +0 once, one call writes +0,0.25
and 0.125 each exactly once. All five hostile/injected boundary cases refuse
private entry (seven fallback calls including reentry). See the separate
[control report](composite-float-controls.md) for hashes, exact counters, identity
scope and the preserved v1 affine fixture failure. This closes the F32 array
record-result composition coverage gap; no release selection follows.
