# Optional uniform-array emission experiment

This source-only profile preserves runtime04's uniform64 ARR representation and
the additive product helper runtime11301. It removes exact get/set/swap/size
helper calls from verified complete private workers. Clone, allocation, atomic
operations, generic segments and all unsupported cases keep the existing route.
No performance result is claimed before root's serial qualification.

The checked request supplies the unchanged mature `ns_definitions` and
`nr_unshared` certificate. Both must hold. The final product lowerer and inliner
run once before `p113a_verify` applies the unchanged public direct verifier and
checks the new private-local namespace. The private emitter then builds
structured N111 loads, branches and stores and uses the existing renderer.
The public verifier continues to reject raw heap/state access.

`P113ACertificate` is reflected data, not an independently authenticated ownership
proof. Only the checked-request factory plus exact source/runtime admission
establishes this profile's source provenance. Arbitrary caller-constructed
`P113AProgram` values have no stronger ownership claim than arbitrary original
direct IR. The native entry and hosted staged route must use the same factory.

All input words are snapshotted before any writes. The first runtime guard
requires the entire top byte to equal6, excluding RFC/shared handles, and the
location to be at least the original descriptor's `HEAP_OFF`. Static or other
handles take the unchanged helper before any payload read. Within the raw path,
get checks the old cell's top byte is0/1; set checks old and new; swap checks new.
These exact predicates exclude RFC and imply trivial keep/sink plus identity
seal. Swap transfers its old stored owner, so an old owning cell need not be
trivial. Every failed check invokes the exact original helper before mutation.

The address is `heap + 8*(loc + (low32(index) & ((1<<class)-1)))`, with
`class=(array>>40)&31`. This matches runtime `blk_at(a,index,0)`. Class0 has one
cell; zero-length ARR is not a runtime representation. Out-of-range indices wrap,
including low32 truncation. Full64 cell words and original array words remain
unchanged; there is no packed-array configuration switch. Get omits only an
identity keep/writeback. Set omits only trivial sink and identity seal. Size
does not dereference the heap. No allocation, free, dispatcher, or pending-frame
state changes are introduced.

The source-bound CPU contract is single active context, one thread and GPU off.
The stable heap base is read fresh at the operation. `STAT_OFF=51413504`,
page128, physical bank256 and descriptor static-size bounds remain those of the
authenticated runtime/static renderer. The template does not infer uniqueness
from a tag alone: the checked unshared gate remains and shared handles also have
an explicit dynamic fallback.

## Composition and API

After the final product/inliner/verifier modules, append:

1. `model.bend`
2. `template.bend`
3. `transform.bend`
4. `program.bend`

Apply `entry.bend` as the final exact `p111_emit_admitted` override.
No existing module is edited. The inliner's optional exact buffer-origin
predicate must precede verification, so renamed array helper sites remain legal.

Export `p113a_lower_request`, `p113a_verify`, `p113a_chunks`,
`p113a_admitted_chunks`, `p113a_inspect_lowered`, and `p113a_inspect_request`.
The factory returns `P113ALowered{program,error}`. The program contains
`original:P113DProgram` and `certificate:P113ACertificate{scalar,unshared}`.
Verification returns an error string; chunks return `List<String>`.
Use admitted chunks only after successful verification of that same program.
Inspection reports scalar/unshared/enabled/functions/sites/error and performs
verification; omit it from a normal already-verified emission path.

## Root-only qualification

The independent `controls-v2.mjs` additionally needs exports
`p113a_stmt_id`, `p113a_template`, `p113a_scan`, `p113a_heap_min`,
`p113a_enabled`, `p113a_body_names`, and `p113d_verify`.
It checks source selection, exact failure branches, input snapshots, dynamic and
scalar guards, index/address widths, status/results, namespace freshness and the
unchanged public verifier. It never executes synthetic IR.

```sh
node selfhost/tools/performance/phase113/array-fast/controls-v2.mjs \
  CHECKED_API selfhost/build/phase113/array-fast-controls01
python3 selfhost/tools/performance/phase113/array-fast/admit-v2.py \
  --compiler COMPOSED_SOURCE \
  --runtime-source selfhost/build/phase113/runtime-products01/runtime.c \
  --runtime-object selfhost/build/phase113/runtime-products-build01/runtime.o \
  --out selfhost/build/phase113/array-fast-admission01
```

Independent source witnesses are in `controls/field-array/source-manifest01.json`:
all four scalar types with wrapped indices, captured shared handles and String
array owners. Record actual certificate admission/refusal separately from
complete-output results. Existing product runtime controls include actual shared
array handles, both release orders, overlapping argument/output buffers, and
owned String cells. Those runtime controls alone do not execute this template.

The source admission pins the exact new declarations, native hook, mature
certificate helpers, original verifier/rendering layer and selected runtime
source/object. It rejects altered declarations and extra private factories.
Qualification remains conjunctive with the checked compiler, product/inliner,
native semantic and runtime receipts. No installed compiler change is implied.

Source17 passed root's checked-API gate at
`selfhost/build/phase111/p113-arrays-api17/report.json`. Its data-only admission
is `selfhost/build/phase113/array-fast-admission02/manifest.json`:207 exact
declarations and15 source mutation refusals. `modules01.json` freezes reviewed
module, dependency and controls hashes. The v2 admitter authenticates that
inventory before inspecting a composed source. Original admitter/admission01
and the unexecuted original controls transport are preserved; controls-v2 fixes
the API's default-export access without changing any Bend source.

## Separate identity and stable-base experiments

`identity.bend` plus the exact overrides in `identity-entry.bend` preserve every
array helper call, status and second result. They snapshot the already evaluated
array word before argument stores and reuse it for the first pair result or set
return. This is the runtime's full-word transfer identity, including RFC/shared
handles; it asserts no new uniqueness or scalar fact and creates no owner credit.
Only the original result credit escapes. The independent source review found no
ordering or ownership defect. `identity-modules01.json` freezes the two modules
and `identity-controls.mjs` (eight structural controls; root executes them).

Source21 adds identity to source20's range and bottom-up inliner composition.
Its exact data-only receipt is
`selfhost/build/phase113/array-identity-admission21/manifest.json` (214 declaration
checks, nine mutation refusals). `identity-admit-v2.py` additionally binds
`composition21.json` and replays all91 frozen modules and572 declaration edits
byte-for-byte from the pinned baseline. This pins the active lowering wrappers
and pass order as well as the original array/runtime facts. `composition.py`
only reconstructs source text; it does not execute the composer or implement
semantic lowering. Previous source17 and identity-v1 methods remain unchanged.

The separate `heap.bend`/`heap-entry.bend` option reads `state->e.mem` once before
the self-loop label in private workers that contain eligible array sites. It
retains all guards and payload reads. Other private workers use the original
emitter. The reserved `p113a_` namespace protects the cached base. The exact CPU
runtime assigns this base once, extends the corpus at its existing base, and
rejects relocation; admitted private imports cannot close or replace the context.
Mutable heap contents and allocator metadata are still read where required.
Independent source review confirmed this lifetime boundary; no new runtime or
device claim follows. `heap-modules01.json` freezes this separate option.

For a root-only checked API, append `heap.bend` and `heap-controls.bend`, then
override with `heap-entry.bend`, and export `p113ah_control_text`. Run
`heap-controls-v2.mjs CHECKED_API FRESH_PHASE113_OUT` for four emitted-text checks
(array/no-array, return/self-loop); the synthetic owning graph is never executed.
Native qualification should reuse wrapped-index, shared-capture and owning-cell
witnesses. Source22's separate data-only receipt is
`selfhost/build/phase113/array-identity-heap-admission22/manifest.json` (219 exact
declarations,14 mutation refusals). `heap-admit.py` binds `composition22.json`,
the complete replayed source, exact heap overlays and the unchanged runtime.
Source21's receipt cannot authorize an added heap override. Later compiler
compositions likewise require new source-bound receipts and their own companion
pass qualification.

The first heap host-control run failed before its first assertion completed:
the host sent reflected `False` objects, but the checked JS API uses primitive
Booleans. Both objects were truthy and selected the array/self-loop fixture.
`heap-controls02.json` pins this generated-API evidence, preserved failure, and
the v2 host-only correction. All Bend modules, runtime bytes and assertions are
unchanged. The original control method/inventory remain preserved; use the v2
transport receipt conjunctively with the source admission.
