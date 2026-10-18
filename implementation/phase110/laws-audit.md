# Phase110 ownership laws audit

The packages establish **23 unique laws** through safe source checking,
BendTT emission and the independent Lean kernel: five selector/storage laws,
five reconstruction additions, four stored-field laws and nine wrapper-spare
laws. The selector laws imported by reconstruction are counted once.
All **14 deliberately wrong helper/model variants** separately passed safe
admission, then failed unchanged source laws with expected/observed mismatches
across 28 checks. These mutant rejections are frontend evidence. The independent
kernel separately rejected its unequal-label control for each accepted positive
package; it did not check rejected source mutant proofs.
Two actual compiled lowering-consumer mutations subsequently passed all 191
unchanged static assertions and machine builds, then failed explicit native
semantic checks against the frozen retained-alias fixture.

Accepted full evidence:
[source03](../../selfhost/build/phase110/reconstruction-source03/manifest.json),
[check02](../../selfhost/build/phase98/phase110-reconstruction-check02/report.json),
[mutants01](../../selfhost/build/phase98/phase110-reconstruction-mutants01/report.json).
The independent package contains 53 definitions, none opaque, and 15,496 bytes
of BendTT with SHA-256
`7aadc1ec8900b4876f9ac701483ea00dc7fd8002529b54b1af52dd3a627fd214`.
The coordinator ran all compiler and proof targets serially on CPU3.

## The source-connected contract

The experimental candidate's `nxo110_fused` calls
`nxo_law_select(String,String.eq(keep,a),a,b)` from the complete safe
[helper](../../selfhost/tools/performance/phase110/laws/helper.bend).
The helper returns the runtime keep index, retained field and remaining field
together. Index zero selects the first input and leaves the second; index one
selects the second and leaves the first. Both results are universally specified
over arbitrary Data payloads, so the same checked definition selects whole
ownership records in the semantic package.

The later private runtime-IR candidate also calls this helper in
`nx110rt_try_fusion`. The accepted proof preparation binds the initial policy
call site; the runtime-IR assembly receipts must bind their own inclusion of
the same helper bytes. That additional source use does not prove the private
memory templates or their physical classification.

The preparation tool verifies that exact candidate call occurs once, snapshots
the helper verbatim with only an added `import Base`, and hashes the candidate
policy, helper, reference, laws and every generated package. This is stronger
than proving a disconnected replacement selector, but source inclusion and call
correspondence are not a theorem about the entire lowering or emitter.

The ownership IR verifier still establishes the fusion shape before the policy
is used. This package assumes the Bool decision identifies the retained field;
it does not prove String comparison, source admission, the entire ownership
credit checker, or the optimization's pattern search. The existing fresh-name,
constructor-shape, no-intervening-operation and tail-consumption guards remain
separate obligations.

## Complete local ownership semantics

The safe [model](../../selfhost/tools/performance/phase110/laws/model.bend)
contains one parent, two separately accounted children and an incoming owner
for the other reconstructed field. Each nontrivial child carries an arbitrary
immutable String observation and an unbounded structural Nat count of owners
in addition to the one principal owner being transferred. Existing external
child owners are arbitrary. Shared parents have at least two owners before the
consume step and retain at least one afterwards. Static parents contain only
trivial children, matching the restricted runtime entry contract.

The fused transition consumes the parent, claims both children when the parent
remains shared, invokes the actual polymorphic selector, constructs the new
parent and transfers the remaining child out of scratch. The separate
[reference](../../selfhost/tools/performance/phase110/laws/reference.bend)
spells out consume/build/transfer with its own selection and claim definitions.
It does not call the candidate selector, reuse, claim, take or fusion functions.

The main law universally equates the complete `NxoLawResult`: reuse permission,
constructor tag, retained child, incoming other child, remaining child, their
complete ownership records, surviving old-parent owner count and contents, and
empty scratch state. Four anchors independently constrain shared child claims,
trivial claims, unique ownership transfer and static alias preservation. Five
additional selector/storage laws constrain the actual selector and every
abstract storage class. The model's reuse Bool specifies permission to overwrite
the consumed parent; it does not assert that unfused C chose the same address.

This advances Phase97's single-cell immutable read model: parent-owned child
references and escaped child owners are distinct obligations, and retaining a
shared parent forces an extra child claim. It still models separately accounted
child cells. Aliasing the two child cells or incoming `other` to each other,
arbitrary cyclic heaps, concrete dangling pointers, machine overflow, allocation
failure, atomic memory order and concurrent mutation remain outside the theorem.

## C runtime correspondence boundary

The actual imported runtime uses `ctr_take` and, for a genuinely shared parent,
`span_fade` to retain escaping fields before dropping one parent owner. A unique
constructor, including a last-owner redirect, supplies a spare. That spare can
also refer to immortal static storage. `nx_rt_rebuild2` therefore permits an
overwrite only for a dynamic heap spare (`spare >= HEAP_OFF`), never merely for
`spare != 0`. The safe helper's three-way classification expresses that contract;
the C implementation does not call the Bend reuse helper.

No simulation relates physical addresses, redirect counters, `rfc_seal`,
allocator freelists or C loads/stores to this model. Runtime retained-alias,
static-storage and lifetime tests are a separate evidence category. The laws
cannot justify removing child retains or replacing the runtime guard without
that missing bridge. No whole-compiler, full runtime or machine-code proof is
claimed.

## Falsification protocol

Five isolated mutations are prepared: reverse retained/remaining fields, emit
the wrong runtime field index, permit static-spare reuse, permit shared-parent
reuse, and omit a shared child's ownership claim. The unchanged laws must reject
each after its changed law-free source has separately passed safe checking.
Expected/observed proof diagnostics must identify the specified law. Syntax,
scope, resource and tool failures cannot satisfy this gate. All five
prepared mutations passed this protocol in `mutants01`:

| Changed behavior | Unchanged law rejecting it |
| --- | --- |
| Wrong retained/remaining order | `select_second_complete` |
| Wrong emitted keep index | `select_first_complete` |
| Reuse immortal static spare | `allocate_static` |
| Reuse shared parent | `allocate_shared_dynamic` |
| Missing shared-child ownership claim | `shared_transfer_claims` |

The ten admission/rejection subprocesses totaled 4.830 s of guarded wall time.

The existing Phase98 checker reauthenticates its audited source/tool boundary,
freezes the import closure, checks the source, emits BendTT and executes the
independent Lean kernel. It also requires concrete nonopaque proof bodies and
rejects an independent false equality. Mutation rejection remains frontend
evidence; positive kernel acceptance is recorded separately.

The separate
[actual-candidate mutation recipe](../../selfhost/tools/performance/phase110/laws/actual-candidate-mutations.json)
pins frozen source/runtime/control identities and prepares two production
consumer faults: flip the tagged runtime keep index after correct selection,
or transfer scratch into the retained local instead of the remaining local.
These deliberately leave the proved selector correct and corrupt its caller.
Native falsification requires successful checked API acquisition, unchanged
shape/ownership/Nx controls, successful emission and machine build, then an
explicit runtime failure or exact-oracle mismatch without a resource stop.
The [runnable supervisor](../../selfhost/tools/performance/phase110/laws/run-actual-mutations.py)
uses accepted `call-source04` / `call-api02`, cached `private-build01` objects,
and the frozen `train01` small retained-alias case. It first requires a fresh
tagged positive worker, then exact static-control/owned-graph agreement and the
intended Nx delta for both consumer mutants. It extracts historical modules
from the accepted assembled source rather than reading an evolving live policy.
Accepted execution:
[actual-consumer-mutants01/report.json](../../selfhost/build/phase110/actual-consumer-mutants01/report.json).
The fresh tagged positive produced the exact frozen count 7 and hash
`7a6bdde4b47f69b2`; both retained aliases independently survived with count 5
and hash `5b64ea960ad292a2`, and all ownership was released.

Both isolated sources then passed the exact accepted checked-API profile,
all 191 assertions across ten unchanged static reports, and QBE/assembler/link
jobs. Their checked owned graphs remained byte-identical to the positive.
Each emitted library differed at exactly two intended sites, one in each
reverse worker. The selected list fixture produced these explicit failures:

| Production consumer mutation | Native rejection |
| --- | --- |
| Flip tagged runtime keep index after selection | Exit 1: `bend: nx ABI: impossible source branch` |
| Transfer remaining child into retained local | Exit 2: `harness: worker leaked ownership` |

The run completed all 17 subprocess jobs with no timeout or resource stop and
reauthenticated every bound input afterwards. Target subprocess walls totaled
4.859 s; the supervisor's own wall interval was 7.150 s. Cached runtime and
harness acquisition are excluded. The earlier cached-build receipt recorded
their sources and successful compilation but did not hash these two objects;
this run pins their bytes and uses the identical objects for its new positive
and both negatives.

These faults leave the proved selector helper correct and corrupt its caller.
They therefore make the remaining source-to-consumer/runtime correspondence
obligation concrete: the local laws and structural controls alone do not prove
that the generated code uses the selected field and ownership transfer properly.

A direct helper-index mutation has an earlier production control: the existing
`v2_specialized_keeps_first` assertion should refuse its changed call name during
emission. That is a distinct source-to-lowering connection check and must not be
counted as a native runtime rejection.

## Replay

Exact fresh-directory commands are in the
[package README](../../selfhost/tools/performance/phase110/laws/README.md).
The checker owns its CPU3 guards; a nested outer guard conflicts with the
exclusive execution lock and is not a failed mathematical proof.

The first shorter selector-only package independently passed its five laws in
[selector-check02](../../selfhost/build/phase98/phase110-selector-check02/report.json),
from [selector-source01](../../selfhost/build/phase110/selector-source01/manifest.json).
The first selector attempt used an outer guard and failed at that nested lock.
Its [check01 receipt](../../selfhost/build/phase98/phase110-selector-check01/report.json)
is preserved. Check02 used the same prepared source and the checker's own guard.
Its recorded subprocess walls were 0.534 s for source checking, 0.534 s for
emission, 0.370 s for the independent kernel and 0.309 s for the kernel negative.
These are single process observations excluding orchestration and authoring,
not a compiler-performance or proof-scaling claim.

The first full reconstruction
[check01](../../selfhost/build/phase98/phase110-reconstruction-check01/report.json)
rejected the proof body's match order: it matched `parent` before the earlier
`keep_first` binder. The theorem and model were not changed; the proof now
matches binders in order. The independent reference was also tightened before
that check to define its own child observation rather than sharing the model's
observer. Source02 retains that independent reference; source03 is the proof-order
repair. Neither failed/prepared package is relabeled as accepted evidence.

The accepted full check recorded 0.534 s for source checking, 0.554 s for
BendTT emission, 0.432 s for independent kernel acceptance and 0.288 s for the
kernel negative control. These timings exclude authoring and orchestration.

## Stored-field seal omission model

The separate [seal package](../../selfhost/tools/performance/phase110/laws/seal/README.md)
adds four independently checked model laws and three rejected welltyped semantic
mutations for the proposed retained-field reseal omission. Accepted receipts:
[seal-law-source01](../../selfhost/build/phase110/seal-law-source01/manifest.json),
[seal-check01](../../selfhost/build/phase98/phase110-seal-check01/report.json),
[seal-mutants01](../../selfhost/build/phase98/phase110-seal-mutants01/report.json).
It distinguishes raw
constructors from existing reference words and records complete count-1 wrapper
allocations, so unwanted resealing effects are observable. The stored-field
premise is derived from the modeled writer's initial seal. A stronger fixed-point
law allows any later allocation state, then congruence establishes complete
rebuild-result preservation while the arbitrary incoming other field is sealed.

This package is explicitly model-only. Its correspondence premise is that every
admitted live dynamic constructor payload writer establishes a nonconstructor
or reference word in every field. The new omission preserves that invariant only
for a retained word read from such a shell; the other field remains sealed.
The raw static-writer exception matters: `term_triv` does not imply a seal fixed
point for a raw static constructor. Both direct static shells and count-1
redirects to static shells must stay outside the fast path. The ABI writer
closure audit and native controls remain separate from these laws.

All four laws passed the first submitted source package and independent kernel
check. Its 40 definitions are all nonopaque; the 9,376-byte BendTT has SHA-256
`a067bc4e5cfd6abe197721a80a78760bbb528bc28ebd00e2aea97dc86da8de5d`.
An independent false kernel equality was rejected. The three changed models
separately passed safe admission, then unchanged laws rejected skipping initial
raw sealing (`raw_seal_allocates_one`), wrapping an existing reference again
(`stored_field_fixed_in_later_state`), and omitting the incoming other field's
seal (`retained_seal_omission_complete`). Their six subprocess checks totaled
2.903 s. Positive subprocess walls were 0.534 s for source checking, 0.596 s
for emission, 0.411 s for independent acceptance and 0.350 s for the kernel
negative; these exclude orchestration and authoring.

## Wrapper-spare transfer model

The separate [spare package](../../selfhost/tools/performance/phase110/laws/spare/README.md)
passed all nine laws in the first submitted source package and independent
kernel check. Accepted receipts are
[source01](../../selfhost/build/phase110/spare-law-source01/manifest.json) and
[check01](../../selfhost/build/phase98/phase110-spare-check01/report.json).
Its 44 definitions are all nonopaque; the 11,651-byte BendTT has SHA-256
`d1bf44ec8e86e731a6dcefbce36efdfb7221937866dbdde3bb4d9c1150f76d57`.
The independent kernel rejected its unequal-label control. The authoring agent
has not executed compiler or proof targets.
Unlike the stored-field package, this transition retains the original head seal.
It models reserving an exclusively consumed last-owner dynamic parent redirect
only when the incoming other word is raw, then consuming that resource into a
count-1 redirect for the incoming value. Shared/static/redirected-static parents,
raw parents without a wrapper, and already-referenced/immediate incoming values
cannot produce a reserve.

The complete result is compared with an independent release-and-allocate
specification with arbitrary replacement address. Its observation erases only
the newly live wrapper address: constructor tag/target, count 1, zero old-parent
owner credits, retained and remaining ownership records, the arbitrary external
ownership frame, and the empty residual spare remain observable. A second
attempt to spend that returned spare is refused. The model intentionally does
not equate allocator free lists, heap addresses, allocation history or timing.
The old-parent credit denotes ownership of the old referent, not a second
physical count simultaneously stored in the reassigned wrapper cell.

Physical address separation, exclusive last-owner classification, live/acyclic
owned values, correct class size and word packing remain explicit refinement
obligations. The model's separate ownership frame is an assumption about
resources, not a proof of numeric-pointer nonaliasing. It does not extract or
verify the C/generated-Nx implementation. The ABI agent's wrapper-source
admission and native controls provide separate correspondence evidence.

The six admitted-and-rejected mutations reserve shared/static wrappers, create count 2, change the
incoming target, preserve a consumed parent owner, or leave a reusable spare.
Each changed model passed safe admission independently before its unchanged
law failed as intended in
[mutants01](../../selfhost/build/phase98/phase110-spare-mutants01/report.json).
Those twelve source checks totaled 5.822 seconds. The positive source, emission,
kernel and kernel-negative subprocesses took 0.554, 0.555, 0.411 and 0.309
seconds respectively; these exclude authoring and orchestration.

## Consolidated evidence accounting

There are **23 unique independently checked laws**. The earlier selector-only
package repeats five laws later imported into reconstruction; it adds no unique
law to this total. Accepted positive checking means safe source admission,
concrete proof bodies, BendTT emission and independent Lean kernel acceptance.
Each of the four accepted positive runs also rejected the independent
unequal-label kernel control. That is one repeated control design, not four
distinct source mutant designs.

| Package | Unique law names |
| --- | --- |
| Selector/storage (5) | `select_first_complete`, `select_second_complete`, `reuse_unique_dynamic`, `allocate_shared_dynamic`, `allocate_static` |
| Reconstruction additions (5) | `shared_transfer_claims`, `trivial_transfer_has_no_count`, `unique_take_transfers`, `static_take_preserves_aliases`, `reconstruction_complete` |
| Stored-field seal (4) | `raw_seal_allocates_one`, `writer_establishes_stored_representation`, `stored_field_fixed_in_later_state`, `retained_seal_omission_complete` |
| Wrapper-spare transfer (9) | `last_dynamic_raw_reserves`, `shared_parent_cannot_reserve`, `static_parent_cannot_reserve`, `raw_parent_has_no_wrapper`, `existing_redirect_needs_no_spare`, `immediate_needs_no_spare`, `transferred_wrapper_has_one_owner`, `spare_transfer_complete`, `consumed_spare_cannot_wrap_twice` |

The accepted five reconstruction, three seal and six spare mutants are
**14 source-only negative checks after 14 separate safe admissions** (28 checks,
13.555 seconds of guarded subprocess time). They have no emitted mutant
proof that was rejected by the independent kernel. Their unchanged laws and
reference modules are bound to the prepared source manifests.

| Frozen semantic mutant | Unchanged law that rejects it |
| --- | --- |
| Wrong retained/remaining fields | `select_second_complete` |
| Wrong runtime field index | `select_first_complete` |
| Reuse static shell | `allocate_static` |
| Reuse shared parent | `allocate_shared_dynamic` |
| Missing shared child claim | `shared_transfer_claims` |
| Skip raw seal | `raw_seal_allocates_one` |
| Rewrap existing reference | `stored_field_fixed_in_later_state` |
| Omit incoming other seal | `retained_seal_omission_complete` |
| Reserve shared wrapper | `shared_parent_cannot_reserve` |
| Reserve static wrapper | `static_parent_cannot_reserve` |
| Incoming redirect count 2 | `transferred_wrapper_has_one_owner` |
| Wrong incoming target | `spare_transfer_complete` |
| Keep consumed-parent owner credit | `spare_transfer_complete` |
| Leave consumed spare reusable | `spare_transfer_complete` |

The two actual compiled consumer mutants form a separate third evidence layer:
their safe helper laws remain valid and their unchanged static controls pass,
but the compiled tagged/QBE workers reject with explicit runtime ABI or harness
ownership errors on `list-two-root-aliases`. These are tests of the consumer
correspondence boundary, not additional theorem failures.

The ABI agent's authenticated source-admission mutants form a fourth layer:
for example [wrapper-spare admission sourcecheck02](../../selfhost/build/phase110/wrapper-spare-admission-sourcecheck02/manifest.json)
refuses nine altered source variants. Those exact-source refusals are neither
welltyped safe-law rejections nor native runtime executions. Physical runtime
probe corpus recipes and their later native receipts must likewise be reported
separately; a prepared oracle alone is not an executed observation.

The actual typed-source frontend also rejected
[`p110_cert_wrong_result`](../../selfhost/build/phase110/capture-admission-invalid01/report.json)
with expected `List<&2, String>` versus observed `String`. Its receipt explicitly
records `typeAccepted: false`, `proofTrust: not-assessed`, and
`kernelChecked: false`. This is an illtyped source admission control, not one of
the 14 welltyped semantic mutants or two compiled native consumer mutants.
