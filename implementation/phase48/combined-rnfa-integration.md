# Phase48 isolated RNFA composition

Prepared source only; no Node, compiler, target, or timing job executed. Root owns checked acquisition and qualification.

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

## Changed files and frozen hashes

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
