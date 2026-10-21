# Independent cold-constructor source audit

Read-only audit against repository HEAD `6436eb5` and
`experiments/STEERING.md`. No target, compiler, build, benchmark, commit or
subagent was run. Only this audit file was written. No concrete incorrect
parent-CID decision, descriptor offset or legacy-capability regression was found
in the inspected source. This is a conditional source review, not qualification
of the new route or an ownership proof inferred from mature C results.

## Exact reviewed inputs

| Input | SHA-256 |
| --- | --- |
| Phase117 `version-source03/compiler.bend` | `8010f9b5691a32f9b8d3a45da444e05b4bf4275fd1380e2acb122bfd2e53fec6` |
| `cold-model.bend` | `a10d44813cef417d9f2eb47a7d19c7846d9850b68b05cddcae3347051553e03c` |
| `cold-tables.bend` | `7d89f427900501f7d004f19dfcec1709c4560f59369ba05a79b48a72cf2163a6` |
| `cold-hook.bend` | `ce73434565ef10b0358dc1f6077fad21a38a1ae7c7b8507e6381d6f80e067eb3` |
| `runtime-cold.py` | `9d85b552eeecc355aa5859c8c1c58d5071e0ba97b4f76b5a61863f5220e751bd` |
| `emit-v4.mjs` | `f15ca390bb3c12a2a66f39519ebd2a662f7b7517d86919feca71ff6c96598d5a` |
| Phase118 `runtime01/runtime.c` | `d2cbac3f3c0650766e98cecd10bf6d76f7ceb62a9763ab0c72bf07d2f3c6ee0e` |

The audit also read the selected request/sharing/descriptor declarations,
`runtime-sized.c`, `runtime-dest.c`, `runtime-borrow.c`, and the current borrowed
observer/TRMC source overlays. The runtime preparation pins its complete parent
receipt and source/object inputs and requires each changed C fragment to occur
exactly once. This review did not execute that preparation script.

## Certificate provenance and closure

`p118c_plan` uses the original checked request's annotated book and reachable
names, not erased machine words. `nr_visit` derives the reachable closure from
references in ordinary erased definitions and retains the original definitions
in the book. `nh_definitions` visits those names; annotated repeated variables
heat their checked datatype, constructor identities, type arguments and live
field types transitively. Unknown duplicate annotations, open/dependent layouts
and exhausted layout/type budgets heat `*`, which prevents cold application.
Different generic instantiations contribute to the same global constructor hot
set conservatively. Candidate CIDs use the same `nc_ctor_specs` identity and
live-arity machinery as the descriptor, preserving row order and arity.

Native and foreign definitions are not inspected by `nh_terms`; that is a real
trusted boundary. `ns_definitions` restricts native operations to the selected
catalogue and foreign permission to authenticated Base `IO.args`, `IO.print`
and `IO.now`. The scalar-array restriction excludes general owning array-element
sharing from this permission. Custom foreign providers and other effects must
keep the plan invalid. Source ADTs that are unreachable may get cold metadata,
but no admitted runtime path may manufacture their values outside this closure.
The source request, Base cache, native catalogue and effect implementations must
therefore remain pinned together.

**Request/program binding is enforced by the harness, not by `p118c_apply`.**
That function verifies its program and rederives its plan, but it does not prove
the supplied program was lowered from the retained request. `emit-v4.mjs` does
use the same checked `request` for lowering, cold planning and application and
verifies the result again. This suffices for that pinned experimental path; a
general public API must not treat an independently supplied program/plan pair
as authenticated. The structural verifier also does not prove the hot flags.

## Representation and runtime correspondence

A raw child in a uniquely consumed parent transfers once through `ctr_take` and
is destroyed once through `term_drop`. An RFC count-one parent likewise transfers
its fields before freeing its wrapper. The critical forbidden state is a shared
parent with a nontrivial raw child: `span_fade` can increment an existing child
RFC but cannot repair an unsealed owning child. Source-level transitive heating,
and preservation of its ownership decisions by this lowerer, are consequently
essential. Mature C's use of the same certificate alone does not prove that
preservation for this new QBE/runtime combination.

The four changed store sites use the correct **parent** CID: generic constructors,
the sized-constructor macro, TRMC prefix initialization, and deferred TRMC tail
fill. The last derives CID from the pending parent; it does not classify the
incoming child's CID. Existing shared child words remain RFC words; cold stores
transfer them without an additional seal. Helpers such as `p111_tuple` and
`p111_native_word` retain unconditional sealing, which is conservative.

TRMC retains its private unfinished-root/current-parent protocol. The current
parent is a borrowed location inside the owned construction, not a second source
owner; the hole remains private until filled. Existing shape, dynamic-parent,
arity and `TERM_HOLE` checks remain. Coldness does not authorize input reuse or
publication of partially initialized nodes. Both a hot parent/cold child and a
cold parent/hot or already-shared child must follow the parent's store policy.

This plan deliberately omits `nh_observer_types` and its stronger relaxation.
An originally duplicated root stays hot even when the optional borrowed worker
can inspect it without destructive Take. Borrowed field views are safe for cold
raw descendants only while the original owner remains live and the borrowed
worker neither transfers nor releases those views. The existing observer
admission and root-once wrapper contract remain separate requirements.

Static image nodes contain closed static/immediate fields, remain immortal below
`HEAP_OFF`, and are unchanged by the hot-table rewrite. `term_triv` and
`spare_free` preserve that boundary. A dynamic cold parent may transfer a static
suffix directly; a hot parent retains the ordinary sealing policy. Readback
peeks and does not create additional owning references.

The existing `io_seal` already consumes `cid_hot` without a capability test.
Thus changing this table also changes allowed effect-produced List/String/box
construction, not merely the four patched functions. The reviewed args provider
constructs fresh values; print destructively consumes its String; now returns a
scalar. Those exact implementations fit the intended permission. Extending the
foreign whitelist requires a fresh ownership review, even if C signatures match.

## Descriptor and legacy behavior

The hook runs at `p111q_data_chunks`, reached by generic, static, direct and
array-enabled table renderers. In the array route it runs after `p117p_tables`
sets capability 3. It detects zero bytes in the named hot table and ORs bit 8
into descriptor datum 11, the existing capability slot at byte offset 88.
Constructor hot bytes remain at the existing offset-136 pointer. No descriptor
slot, CID ordering, static word, segment or direct function is rewritten.

Runtime binding accepts exactly 1, 3, 9 and 11. The new generic/sized/TRMC store
branches require bit 8 and a cold parent; descriptors 1/3 retain their previous
sealing behavior. Array capability bit 2 is preserved. Existing metadata checks
still require hot bytes in 0..1. These checks authenticate layout, not the
source-derived meaning of a cold byte; emitted table provenance is mandatory.

## Ordinary qualification still required

Use checked source controls and complete values/alias observations, recording
the actual cold/hot rows and capability for each product:

- A unique nested user tree/list, a directly duplicated parent, and a duplicated
  outer container containing that parent. The latter two must heat the relevant
  constructors transitively, including multiple generic instantiations.
- A cold parent containing an already-shared dynamic String, plus dynamic parents
  ending in static suffixes; consume one result while retained aliases stay live.
- Mixed-constructor TRMC with tail slots 1 and 3, with a cold/hot policy boundary
  between adjacent constructors; compare cold-only and cold-plus-TRMC products.
- A borrowed observer that returns its owned root, then a destructive consumer,
  including an externally shared root. Borrowing must not silently turn a hot
  source type cold.
- Ordinary partial applications/closures and supported IO.args/print/now;
  ordinary unsupported foreign/effect programs must preserve fallback. Include
  legacy capability-1 and capability-3 products linked to the new runtime.
- Descriptor/table comparisons across generic, direct, static and scalar-array
  routes: only justified hot bytes and capability bit 8 may change.

No control outcome or performance result is asserted here. In particular,
reduced count-one wrapper work must not be reported as removal of genuine
shared-parent work without separate evidence.
