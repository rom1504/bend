# Phase117 array proof and guard audit

Source audit at `6703ff7d426213c98c3ab036d5984d664602adb9`, followed by an
explicitly requested experiment-local Bend prototype.
No compiler, target executable, benchmark or custom failure reproduction was
run. This note proposes a bounded experiment; it does not qualify an optimizer
or authorize a production selection change.

## Existing authority and its limits

`phase113/array-fast/model.bend:p113a_certificate` already computes
`ns_definitions(book,names)` and then `nr_unshared(book,names)`. Both must hold
before `p113a_functions` transforms the private function list. The checked
request is derived internally, the original owning graph is verified, and the
private generated namespace is checked. A reflected `P113ACertificate{True,True}`
supplied by an arbitrary caller is not a proof.

`ns_definitions` checks reachable array representation demands against trusted
native U32/F32/Char/Bool element types. Unknown types, unsupported proof transport
and unaudited foreign functions decline. `nr_unshared` separately rejects
repeated use of array-containing values by scanning checked annotations and the
prepared erased body. Neither Boolean is a per-SSA-value initialized-pointer
certificate. Keep source/runtime/effect identity and the original verifier.

The selected runtime has `NATIVE_SCALAR_ARRAYS=0` and
`NATIVE_UNSHARED_ARRAYS=0`: arrays are uniform64 words. This is distinct from the
selected C compiler's packed32 configuration. Changing a load to 32 bits does
not implement packed arrays. Creation, clone, split/join, atomics, drop/readback
and generic operations must agree before changing representation.

## What can change without a stronger representation theorem

| Operation/check | Conclusion | Reason and boundary |
| --- | --- | --- |
| `index &= 0xffffffff` immediately before `index &= mask` | Remove. | `class=(array>>40)&31`, so `mask=(1<<class)-1 <= 0x7fffffff`. For every 64-bit input, `(index & 0xffffffff) & mask == index & mask`. This preserves the runtime's wrapping semantics even for oversized raw words. |
| Repeated extraction of `location=array & ((1<<40)-1)` inside one template | Reuse the already computed value. | It is the same snapshotted array word with no intervening assignment. Keep the later location-plus-index as a distinct value if subsequent users need the base location. |
| Raw/dynamic guard for `array_size` (id75) | Remove for the exact verified helper shape. | `p113_rt_array_pair` computes only `1ull << blk_cls(array)` and transfers the original full array word. It does not dereference, keep, sink or modify the array. Thus even an RFC handle does not require `term_peek`; size comes from unchanged aux bits. Preserve input snapshot, output order/status and exact class mask. |
| `class & 31`, location40 mask and wrapped index mask | Retain unless separately constant/proven. | These specify the runtime representation and wrap semantics. They are not ordinary bounds checks. Array depth zero means one cell, not an empty array. |
| Cached `state->heap` | Already implemented. | Phase113 heap overlay loads it once before the loop. Do not credit or reimplement that gain. |
| Get/set/swap raw/RFC guard | Retain in the first experiment. | The fallback handles generic/shared representations. Source-level no-duplication is not alone a proven initialization/error-state contract for every internal handle. |
| Dynamic-location guard for payload access | Retain initially. | Static arrays are refused by current static-image admission, but allocation failure can yield a sentinel rather than a normal dynamic array. Removing this requires error/order reasoning beyond the element-type certificate. |

The existing original runtime operation is the strongest specification for the
first three rules. No new global cache, array ownership inference or runtime
object is needed.

## Stronger but still small change: scalar payloads without scalar rechecks

The highest-value bounded candidate retains the raw/dynamic handle guard and
uniform64 layout, but removes old/new top-byte scalar tests **only under the
existing authenticated scalar-array factory**. The needed invariant is:

> Every stored cell and every new value supplied to an admitted scalar-array
> operation has a representation on which keep/sink/seal are identities.

This is stronger than saying “the handle is an Array,” but follows from the
closed native element representation plus all admitted producers if that
correspondence is maintained. Relevant actual runtime cases:

- U32/F32 special constructors extract a word; Bool constructors return0/1;
  Char's special constructor preserves the checked immediate word.
- `ARRAY_NEW` and `ALeaf` create uniform arrays from their checked element.
- `ANode`, half extraction and clone move/copy cells using the same layout.
- Get transfers an existing element; set/swap accept the same checked element
  type. Atomic operations operate on native32-bit lanes and retain scalar cells.
- `rfc_seal` wraps `TAG_CTR` only. Native scalar words do not become owning RFC
  children merely by being stored. `term_keep` on a trivial immediate is identity.
- Current static-image verification explicitly refuses `ALeaf`/`ANode`; generic
  boxed array cells and captured/shared handles retain refusal/fallback.

Before qualification, bind these cases to the exact selected runtime and the
checked source certificate. Do not generalize from `N_W32` alone or from a
matching primitive ID in arbitrary user IR. Keep all64 output bits: this pass
removes redundant reference-handling tests; it does not silently normalize
representations or narrow loads.

For set (id73), the old value is loaded only to decide whether sinking it is
trivial. Under this invariant **omit that old-cell load as well as the tests**.
Get and swap still need the old value as their result. This removes a memory
operation and control-flow join per set without changing storage or allocation.

### Minimal Bend IR edit

Use an experiment-local exact override of the template functions, not a change
to the public IR verifier:

1. Factor `p113a_address` into address computation and an optional old-cell load.
   Preserve the existing heap-base overlay and namespace discipline.
2. In the scalar-certified path, `p113a_raw(id,...)` becomes address computation,
   old load for get/swap, then unchanged `p113a_success`. No scalar guard or
   scalar-failure branch is emitted. Keep the outer raw/dynamic fallback intact.
3. Special-case size before the outer guard using the exact helper identity.
4. Apply the low32-mask algebraic simplification independently, so its effect
   and output correctness can be isolated from scalar-proof use.

The certificate remains tied to the immutable original request. Unsupported
IDs, counts, local origins, namespace collisions and failed verification retain
the original path. The complete runtime ABI, original helper bodies and generic
segment behavior stay unchanged. Record actual transformed-site activation;
passing output through a refused path does not test the candidate.

## Hoisting across operations and loops

The full array word is an exact transfer identity for get/set/swap/size in the
existing runtime; Phase113 `identity.bend` already exposes it. Therefore class,
mask and raw location are invariant while that same live handle is transported.
Payload values are not invariant. Root mutation does not change the handle bits,
but arbitrary imports, rebinding, clone/half/node construction and ownership
termination do not supply a reusable identity by default.

The current IR uses mutable names and nested branches. A small fact map must
kill facts when a destination is assigned, intersect facts at joins, and use a
fresh snapshot as the identity anchor. Comparing variable spellings is
insufficient. Do not hoist payload reads across stores or across aliasing calls.

For one complete loop, a conservative version is an entry test followed by a
fast loop carrying handle/base/mask and the original slow loop on refusal.
Admission must prove the loop backedge carries that exact handle and preserves
its owner, and that no body operation closes/replaces the context. This is
larger than the scalar-guard candidate and should follow only if its profile
shows repeated header/address work remains significant. Avoid broad loop
versioning before the smaller experiment establishes useful gain.

## Corner cases and economical existing controls

- `controls/field-array/scalar-array-wrap-v2.bend`: U32/Bool/Char/F32 get,
  set, swap, size, and indices7/11/3 wrapping to the same cell of depth2.
- `shared-array-capture-v2.bend`: a captured alias observes mutation; require
  the expected unshared refusal and unchanged output5/42.
- `string-array-owners.bend`: owning cells require the generic path; verify
  certificate refusal and both values after operations.
- `mixed-record-owner.bend`: unrelated shared ownership control.
- `tests/compile/array_generic_cell.bend` and
  `tests/reg/array_borrow_generic.bend`: generic element layout and ownership
  boundaries; retain their independent expected results from the source manifest.
- `tests/run/array_wrap_index.bend`, `array_size.bend`,
  `array_split_join.bend`, `array_atomic_fadd.bend`: existing ordinary sources
  for wrap, metadata, replacement handles and floating atomic payloads.

The frozen source manifest is
`selfhost/tools/performance/phase113/controls/field-array/source-manifest03.json`.
The existing runtime boundary controls in `array-pair-boundary.c` and
`array-shared-handle.c` cover input/output-buffer overlap and both release
orders, but do not by themselves exercise the emitted optimized template.

For low-cost structural controls use explicit IR values with class0 and31,
high index bits, shared-tag words for size, and distinct old/new input buffers;
these can be inspected/evaluated as transformation output without executing
synthetic owning IR. Retain original verified-graph checks and complete ordinary
program outputs. Do not add custom OOM/failure execution campaigns: the error
sentinel issue here is a reason to keep the existing outer guard.

The first performance comparison should be local-fold plus local-pair/editdist
using existing products, followed by a non-array unchanged-output control. A
large machine/profile improvement justifies broader array and original45 gates;
static deletion counts alone do not.

## Implemented bounded invariant-metadata prototype

`selfhost/tools/performance/phase117/array-invariants.bend` overrides only the
private `p113ah_function` emission hook and adds an exact-origin analysis. It is
an unqualified experiment; the audit agent ran no compiler or target. Root owns
composition, checking, activation inspection and differential measurements.

The analysis runs on the original verified `P113DBody`, before array-template
expansion. A fact is either unknown or the complete entry word of one parameter.
Copies snapshot that origin rather than referring to another mutable variable.
Every assignment overwrites its destination fact. Full64-bit stores/loads track
exact aligned slots in recognized scratch/output buffers; narrower or unknown
stores clear all slot facts. Runtime/private calls clear all slot facts. Only
the exact verified get/set/swap/size helper identity restores its output handle
origin. The array payload and ownership count are never inferred from this map.

Each `Again` contributes a separate obligation: argument `i` must have origin
`i+1`. Intersecting all obligations proves that each retained parameter word is
unchanged on every self-loop edge. Each branch starts from the same incoming
local/slot facts; branch joins forget both maps. Array sites retain their origin
and the same deterministic site order as the existing template scan. No eligible
backedge or no eligible site leaves the original array emission unchanged.

The domain is intentionally narrow: at most16 parameters and8192 visited direct
statements. Nested scalar `N111If`, any pointer assignment or pointer offset,
and parameter names resembling scratch/output buffers decline the whole
function. Reassigning a recognized buffer name invalidates all hoist admission.
Original `p111v_decl` also rejects duplicate alloca names and any local/alloca
redeclaration. Consequently the tracked buffers are distinct fixed allocations,
not spelling-based aliases; there is no new general pointer analysis. Calls and
unknown memory writes still clear slot facts. These conservative refusals are
coverage limits, not semantic errors.

For retained origins, the emitter snapshots the entry word and computes tag,
raw/dynamic admission, class, mask and bytebase before the existing loop label.
Every transformed access retains its own cached-admission branch and exact
original runtime fallback. The fast branch still snapshots its inputs, wraps
the current index, computes its current cell address and performs its current
load/store. No payload is hoisted. Speculated entry calculations are integer
word operations plus pointer arithmetic, with no new dereference; the existing
stable heap-base load remains the only entry memory operation.

The proof is induction over loop edges: entry snapshots are equal on iteration0;
full-word origin preservation and every `Again` obligation preserve equality on
each next iteration. Cached metadata is a pure function of that unchanged word
and the already-stable heap base. Retaining the original fallback means this
does not require a stronger raw-pointer/initialization theorem, does not create
ownership credit, and does not move payload memory effects across calls.

Three narrow hooks (`p117h_raw_tag`, `p117h_index_shift`, `p117h_cell_type`) default
to uniform64. Packed32 composition must override them to4,2,U32, respectively,
and use the packed module's unsigned-load emitter and existing store template.
Heap location units remain64-bit words, so entry bytebase always shifts by3.
The packed image/runtime descriptor is independent authority; these hooks do
not authorize packed layout or bypass the scalar/unshared certificate.

Before accepting the experiment, inspect that hoisted metadata appears above
`@p113_loop`, actual access sites use it, changing-handle loops retain original
templates, and full output/refusal gates pass. A compiler check alone does not
establish activation or runtime equivalence. The prototype can be rejected
without changing either original IR or the qualified compiler selection.

## Packed runtime producer cross-check

The existing runtime already implements packed scalar arrays under
`NATIVE_SCALAR_ARRAYS`: `ARRAY_NEW` and `SPECIAL_ALEAF` select `blk_new` layout;
`ANode`, half and clone follow the block tag; get/set/swap call native helpers;
atomic operations select32-bit lanes from the block tag; drop/readback likewise
distinguish BUF and ARR. `p113_rt_array_pair` calls those native get/swap helpers
and transfers the handle; it does not hardcode64-bit payloads. The static-image
admission rejects `ALeaf`/`ANode`, preventing a uniform static array from silently
entering the packed image. No additional producer hole was found in this source
audit. This is not a substitute for exact source/runtime binding and ordinary
packed array/type/refusal controls.

### Hoist v1 missed-GET diagnosis and v2

Root's checked v1 run activated only the SET site in the hot fold loop. Inspection
of `hoist-emit01/variation-local-fold-128-0.ssa` and the exact
`phase113/array-fast/identity-entry.bend:p113p_pair_code` builder identifies the
reason: GET lowering writes the input scratch slots, then declares a fresh
output alloca, then invokes the helper. The v1 analysis unnecessarily erased
**all** scratch facts at every alloca. SET has no fresh output allocation and
therefore retained its origin. This is a conservative lost opportunity, not an
incorrect transformation or a site-numbering failure.

`array-invariants-v2.bend` preserves existing slot facts at a fresh alloca; that
is its only semantic change. The original verifier prohibits duplicate alloca
names and alloca/local reassignments; the prototype declines pointer copying,
offset aliases and buffer-like parameters. Thus creating this independent fixed
allocation cannot modify a previously tracked scratch slot. It creates no facts
for uninitialized output memory. Calls and unknown stores still invalidate all
slots, and v1 remains frozen. The audit agent did not execute the v2 compiler or
targets; root must verify that GET now uses cached metadata and remeasure.

### Why edit-distance's hot cell is outside v1/v2

The frozen v1 `editdist.ssa` gives a direct boundary diagnosis: `$product.cell`
(lines4013–4580) has five array sites and no loop backedge; `$product.row`
(lines4682–4825) has a backedge and one private call, but no array site. The
prototype requires both a retained loop origin and an array site in the same
function. Row also loses the four array origins at the private call result.
Therefore the fresh-alloca fix cannot by itself move hot-cell metadata out of
the row loop. These are static counts, not measured dynamic shares.

The qualified source already uses the wide inlining policy:384 candidate nodes,
1024 growth nodes,2048 initial caller nodes,16 expansion sites,8192 candidate
stack bytes and16384 transformed-caller stack bytes. The preserved earlier
diagnostic `implementation/phase113/interim03/files/044-after.txt` reports the
same `$product.cell` family at391 nodes,136 stack bytes, six inputs and four
results; the earlier number is a useful boundary clue, not a newly measured
current-node count. A general384→512 candidate-limit ablation, leaving all
other gates intact, can test whether the call boundary is cheaply removable.
Existing bottom-up inlining retains the verified DAG and rejects recursive
callees; no function-name test is needed.

Inlining alone will not suffice for the current conservative origin analysis:

1. `p112_scalar_compare` creates an `N111If` that selects literal1/0 into one
   U64 destination. Existing `p113bq_scalar` recognizes precisely this shape.
   The origin analysis can reuse that recognition to invalidate only the one
   destination, preserve other locals/slots and keep rejecting every other
   scalar conditional. No array sites or memory effects occur in this diamond.
2. The source's `b2u`/`umin` matches form direct conditional joins. Instead of
   forgetting every local fact, intersect exact nonzero origins from both
   branches. The current KIndex traversal in `p113k_join` is a compact model;
   slot facts can still be forgotten, avoiding a broader memory join analysis.
   Equal immutable origins need no mutable-variable alias chains or epochs.

These are proposed independent ablations, not implemented or measured by this
audit. First inspect actual row inlining and retained origin/site counts; then
require machine-level disappearance of repeated loop metadata before timing.
Simply lifting the `again` requirement would not address cross-call/iteration
reuse and could add entry work to ordinary one-access functions.

### Implemented v3 and separate512-node ablation

On root's request, `array-invariants-v3.bend` adds30 lines over v2: the existing
`p113bq_scalar` recognizer admits exactly the two-arm literal0/1 assignment
diamond, killing only its destination origin, and a KIndex intersection retains
equal nonzero origins in both local and slot maps after direct branches. Every
other scalar conditional still declines the function. Pointer restrictions,
call/write invalidation, bounded analysis, every-backedge conjunction and
original fallback branches are unchanged. Including a terminal arm in the
intersection is conservative: any retained origin holds on all continuing
paths, while a terminal arm may merely discard an otherwise usable fact.

`inline-512.bend` separately overrides `p113i_eligible`, changing only the
candidate node cap384→512. This separates the effect of moving an existing
checked body into its loop caller from the effect of preserving origin facts.
Both prior hoist variants remain unchanged. Static delimiter/definition checks
passed; compiler checks, activation and performance are root-owned subsequent
gates. No speed gain is inferred from these source edits.

## Loop-wide versioning review

Read-only review of `array-versioning.bend` SHA256
`5f2fc4ad329dabaa9148a26bd4dff386fc5291e17f13f11c59d9acb598b0da8c`
and `array-invariants-packed-v3.bend` SHA256
`7b3a24da1f941d582dda0bcc5051dfd45cc0bc732d881f603295f8a52a3b8a75`.
No compiler, target, benchmark or custom failure reproduction was run by the
reviewer. The structural-match compiler fix being handled by root is outside
this semantic source review.

**Finding:** no new semantic blocker was found within the existing checked
source/runtime factory and original verified-IR boundary. Qualification remains
open: static reasoning does not validate the new textual QBE dispatcher or its
machine-level calling convention.

The versioned entry computes the same pure metadata, ANDs the raw/dynamic
predicates of all used invariant origins, and branches before executing any
original body statement. On false it calls the unchanged structured-body
fallback; on true it enters the fast loop. Moving these predicates earlier
does not reorder source effects or failures: they perform integer operations,
pointer arithmetic and the existing stable heap-base read, with no new payload
dereference. The fallback starts the original body from its original parameters,
so a prefix before the first array access is executed exactly once.

`p117v_all` checks every recorded recognized array-template site against the
final invariant mask. Analysis and rewrite use the same scalar-site predicate
and yes-before-no traversal. Accepted nested scalar diamonds contain only the
two literal assignments, hence no uncounted array site; any other scalar
conditional declines analysis. Budget exhaustion or an unsupported pointer
operation clears the invariant mask. Unrecognized runtime operations and
private calls remain in the body, with their original semantics; “all sites”
means all rewritten array sites, not every possible array operation in callees.
Every `Again` must preserve each admitted full handle word, so the entry
predicate remains valid for all loop iterations. Payloads remain mutable and
are loaded/stored at their original sites.

The local/slot alias assumptions remain those audited for v3. The original
direct verifier additionally forbids pointer assignments/loads/offsets and
state-backed loads/stores in its scalar blocks; original stack-buffer names
cannot be redeclared. Fresh allocas are distinct, unknown writes and calls
invalidate memory facts, and exact-origin intersections retain only values
equal on both paths. No new owning reference or uniqueness credit is created.
Packed access still requires both checked certificates and capability3; the
runtime binds one program per process and then retains its active descriptor.

The fallback ABI is internally consistent: `p117v_signature` emits the same
state argument, optional product-output pointer and full-word parameters in
the same order as the existing function signature. At the dispatch point
these are also the correct actual argument names. Scalar results return the
same full word; product results write to the caller's original output pointer
and return the same status. No source parameter is mutated by the setup.

Symbols use the distinct `p117v_` prefix and the existing injective character
code encoding; original workers use `p113d_`. New local guard names occupy the
already-reserved `p113a_` namespace, and `%p117_fallback_value`/`@p117_*` cannot
collide with original `%v_*` locals or the emitter's `@b_*` labels. The fallback
retains self edges as local `Again` jumps. Its calls target only earlier
functions in the verified DAG, so adding wrapper→fallback edges cannot create
input-dependent native recursion.

There is a resource cost rather than a new recursion hazard: on refusal, both
the wrapper frame and fallback frame can reserve their scratch/explicit
buffers at once. This can increase stack by one extra fixed frame per direct
call level; it is not one extra frame per loop iteration. Record final code
size and stack reservations instead of claiming stack or simplicity parity.

### Remaining gates and precise recommendations

- Build representative scalar-result and product-result versioned functions
  through QBE/as/link; original IR verification alone cannot validate the
  newly assembled dispatcher strings.
- Exercise the fallback with ordinary valid inputs by a separate test-only
  emission variant initializing its version guard to0. This tests the fallback
  call ABI, exact outputs and bounded self-loop behavior without fabricated
  handles, allocation failure or unsafe failure probes. Keep that variant
  separate from performance candidates.
- Inspect that the entry guard dominates the fast loop and that no recognized
  template fallback call remains inside that loop. Unrelated calls may remain;
  classify them rather than inferring success from total call counts.
- For inexpensive defensive correspondence, compare the recorded site count
  with `p113a_count_body(body,0)` and the rewrite's final count before selecting
  versioning. Current traversal already matches; an explicit count equality
  would protect this interface against future analysis/rewrite drift.
- Keep certificate refusals, descriptor capability1 behavior, ordinary packed
  array controls and the independent expected outputs. The original source
  verifier is the semantic boundary, not an arbitrary caller-supplied origin
  map or certificate. No installed promotion follows from this source review.

### Checked-source follow-up and finite origin controls

Root's later `array-versioning-v2.bend` introduces a bound helper around the
fallback match scrutinee; `array-invariants-packed-v4.bend` marks the reused
intersection accumulator explicitly unrestricted. Inspection of both diffs
finds no semantic alteration to the versioning argument above. Compiler/target
results reported by root remain separate evidence; this audit did not run them.

`origin-controls.bend` now exports `p117h_controls() -> String`, containing22
finite analysis checks with explicit PASS/FAIL labels. They cover snapshot
rebinding, changed origins and all-backedge conjunction; the fresh-output-alloca
GET regression; agreeing/disagreeing local and slot joins; unknown/narrow memory
writes and calls; pointer/offset and buffer-parameter refusals; the exact Boolean
diamond boundary; and complete/missing/noninvariant version-site admission.
The controls construct IR values and inspect compiler-analysis results only.
They never emit or execute an owning graph, invoke a runtime helper, fabricate
an actual runtime handle, or reproduce a runtime failure. In particular, alias
and effectful-conditional inputs exercise analysis refusal rather than runtime
behavior. Unique labels and lexical delimiters were checked statically; root
owns the checked compilation and execution of this pure analysis report.

## Bounded two-iteration expansion prototype

`unroll-two.bend` is a separate107-line experiment and overrides only
`p117v_private`. It receives the already-versioned structured fast body; the
original fallback and entry guard remain unchanged. It admits at most16 formals,
exactly one static `Again` site and a small body budget. It rejects private calls
and runtime calls except the existing exact `p111_rt_fail(state,w4)` used by
exhaustive pattern matching. Root explicitly authorized retaining this narrow
profitability exception because the machine optimizer removes its unreachable
branch in the measured fold; the unroll transformation itself does not delete,
move or assume away failure behavior, and no failure input is constructed.

At the first `Again`, the pass snapshots every full-word actual into a fresh
reserved `p113a_unroll_i`, then assigns all formals from those snapshots before
appending one copy of the original body. That copy's `Again` remains unchanged.
This is the same parallel update as the existing loop emitter followed by the
same next iteration. Both copies retain all exit tests, so zero, odd and even
iteration counts do not require a divisibility or positive-count assumption.
Source effects, including the retained failure helper, keep their logical
iteration order. Metadata outside the loop is neither duplicated nor modified.

All explicit allocas are removed from the second copy, including nested scalar
branches: the existing emitter already lifts every original alloca into the
entry block exactly once. Consequently second-iteration locals reuse precisely
the same stack buffers as an ordinary loop iteration. Original verified pointer
rules plus the versioning factory justify the generated address operations;
the gate additionally refuses pointer copies/loads/stores and permits offsets
only in the existing private array namespace. Fresh snapshot names cannot
collide with source locals or the established template role names.

The budget counts each structured `Again` as its existing two moves per formal
plus jump, instead of pretending the eventual parallel transfer costs one
instruction. Admission requires at most256 such transfer-expanded units; the
candidate must cost no more than twice its original, hence at most512. This is
a bounded structural-growth metric, not a promise that final machine code or
register spills grow by at most2×. Exactly one static backedge prevents repeated
body copies in several branch arms. All other bodies retain their original
versioned emission. The ordinary `p113e` emitter still performs its existing
width and Boolean lowering; no generated-code text replacement is used.

Only static delimiter checks were run by the audit agent. Root owns checked
compilation, activation inspection, ordinary exact-output controls and timing.
Useful checks are unchanged alloca count, one retained loop backedge, fresh
parallel-copy temporaries, both exit tests and unchanged fallback bytes. An
unprofitable result should leave this module outside the selected composition.

## Root qualification outcome

Selected source03/API03 passes22 finite origin controls,11 ordinary owner/array
controls, forced-slow fold/edit scalar/product ABI observations, and405 original45
observations. Unroll source01 passes its separate ordinary count control and
matched screens, but remains unselected. Full native compiler/stack qualification
is still outstanding. See the main report for cost and runtime limitations.
