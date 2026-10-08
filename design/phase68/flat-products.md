# Phase68: fixed product shells between native workers

Source-only proposal, 2026-10-08. No compiler, C compiler, or target was run in
this lane. No production source or worker prototype was edited. The ordinary-C
worker interface remains owned by the upstream lane and was not frozen at this
review. This is a follow-on to [architecture options](architecture-options.md)
and the [compiler mechanisms research](../../research/phase68/world-compilers.md).

**Recommendation:** represent an eligible one-constructor product as a small
ordered list of ordinary `Term` fields inside private C workers. Keep each field
in its current one-word representation, including Array handles and unknown
generic element types. Return several fields through the existing `nf_out`
pointer, and forward them to eligible consumers. Preserve the boxed scheduler,
closure, foreign, and device ABI. Recursive field flattening and monomorphization
are unnecessary for this first slice.

The first argument specialization must additionally prove the original demand
boundary: a constructed product can flow directly to a matching worker, or a
boxed value can be split at its existing matcher. A type annotation alone does
not permit eagerly taking apart every boxed parameter. That restriction is
material because the public native compiler accepts raw core books.

## Inspected interfaces and the missing information

| Source | Existing mechanism | Consequence |
| --- | --- | --- |
| [native/ir.bend](../../selfhost/src/back/native/ir.bend), lines 3–25 | `N_WordKind`, physical `N_Param`, `N_Segment.result`, single-word `N_Emitted` | Physical result width exists; logical product identity does not. |
| [native/layout.bend](../../selfhost/src/back/native/layout.bend), line 2 | `nl_c_type` maps a word kind to C spelling | This is not a typed layout analysis. There is no existing native product layout to enable with a flag. |
| [native/bridge.bend](../../selfhost/src/back/native/bridge.bend), lines 8–38, 133–147, 181–189 | `NC_Binding{id,word}`; sharing, drops, frame slots, and let result bindings each handle one word | Changing only `N_Segment.result` would make the caller disagree with the callee. |
| [native/emit.bend](../../selfhost/src/back/native/emit.bend), lines 44–60 | `ne_frame`, `ne_jump`, and `ne_ret` already accept lists of words | A later scheduler extension can reuse this physical machinery. It does not preserve product ownership by itself. |
| [native/tables.bend](../../selfhost/src/back/native/tables.bend), lines 6–23, 108–112 | Width is the maximum of physical params/results; frame result count is params minus held slots | Multiword frames are representable if all producers, bindings, and slot counts change together. The current validator caps params/results at 255. |
| [native/erase.bend](../../selfhost/src/back/native/erase.bend), lines 36–69 | Constructor arguments are erased using the specialized telescope; matchers retain a live field count | Constructor names and remaining field counts cannot recover dependent field types or erased positions after this pass. |
| [flat worker prototype](../../selfhost/tools/performance/phase68/flat-workers/candidate/flat.bend), lines 4–8, 18–39, 99–126, 166–201 | `NC_Destination` carries one word; worker returns status and writes one result through `Term* nf_out`; scheduler adapter returns one word | The pointer can carry a fixed-length result vector without changing the success/error convention. The local destination and logical binding must also become vectors. |
| [native/array.bend](../../selfhost/src/back/native/array.bend), lines 30–57 | `nc_array_pair` eagerly creates a boxed Tuple before returning `N_Emitted` | Product-aware calls alone leave these boxes intact. Array pair-producing intrinsics need a vector result seam too. |

There are no `jl_*` helpers in the current selfhost backend tree. The reusable
semantic facts are `j_specialize`, `j_app_type`, `j_layout_ctor`, and constructor
queries in [common/queries.bend](../../selfhost/src/back/common/queries.bend).
`j_layout_ctor` deliberately has a global fallback for unknown owners; that
fallback is not proof that a product belongs to the claimed type. Eligibility
must establish the exact ADT owner and constructor before using its telescope.

Direct JS already walks specialized fields in declaration order and omits
erased values in `jd_ctor_values`/`jd_ctor_fields`,
[direct/constructors.bend](../../selfhost/src/back/js/direct/constructors.bend),
lines 243–269. Share that semantic telescope policy, not JS expressions or JS
object representation. Legacy `jw_layout` and `j_pure_closed_sigma` are tied to
the old private/pure worker admission rules; importing that representation would
add an unnecessary second optimizer.

## Eligibility: a closed product shape, opaque fields

The useful initial domain is a **fixed product shell**, rather than a requirement
that every field type be closed. For example, `Array<T> & T` has a known Tuple
constructor and two live fields even when `T` is an erased generic parameter.
Both fields already have a valid one-word native ABI. Rejecting all open field
types would exclude generic Array result transport and many record helpers.

The first layout query should return either `Opaque` or a descriptor containing
the exact owner, native constructor identity, ordered live field positions, and
width. Every field is an opaque owned `Term`; there is no nested expansion and
no W32 narrowing in this slice. An immediate scalar still works: the existing
`term_keep` and `term_sink` operations already recognize trivial words.

Admit the following shape conservatively:

1. The normalized outer type is an exact known ADT with one constructor in the
   owner's complete definition. A multi-constructor owner narrowed by removed
   alternatives is not sufficient. Its runtime representation must be an
   ordinary constructor shell, not a native scalar, Array node, String, IO.OP,
   or other primitive encoding.
2. Specialize the constructor telescope with the outer ADT arguments before
   erasure. Constructor owner identity, declared field count, and the telescope
   must agree. A missing owner or incomplete/extra telescope yields `Opaque`.
3. Support erased ADT type parameters through normal specialization. Initially
   reject erased constructor fields, equality-only/zero-live-field products,
   and any field whose normalized type still mentions an earlier live field
   binder. This includes genuinely dependent Sigma families. Nondependent
   `A & B` reduces its family application to `B` and passes this check.
4. Leave unknown generic field types, arrays, recursive ADTs, and nested products
   opaque as individual one-word fields. Do not recurse into their layouts.
   The outer shell itself must not have a constructor field that recurs to its
   own owner; an uncertain family/owner cycle falls back. This restriction can
   be relaxed independently once useful fixed-shell controls pass.
5. Use a small explicit shell width cap, provisionally 8 fields. A function's
   complete physical parameter list must also stay under a separate cap; 32 is
   a reasonable initial screening policy, not a claim about an optimal C ABI.
   Unknown, excessive, or unsupported shapes retain the current boxed ABI.

The descriptor is a shape fact, not a proof that an arbitrary runtime word has
that shape. It must not be used to remove a demanded runtime tag check on a
word with unknown provenance. A literal constructor or an admitted flat result
provides the additional value-flow proof needed to bypass that check.

For a future closed nested-product extension, use a memoized instantiated-type
key plus an active owner set and a depth/width budget; preseed an in-progress
query as opaque. The upstream `lay_of` does this to prevent hidden-family cycles.
None of that recursion is needed to eliminate an outer two-field shell now.

## Preserve typed facts before erasure

`nc_definition` presently calls `nc_erase` before worker lowering. The proposed
facts pass must run against the annotated source definition and source type
telescope first. Do not reconstruct field types from the erased `Ctr`/`Mat`
nodes or reuse an erased field index as a source argument index.

A small proposed common API is a conservative product-shape query plus an
ordered field-telescope iterator. Keep native constructor identity and native
ownership policy in `back/native`. The query should have no target text, no
calls into JS emission, and no effect on source diagnostics: uncertainty returns
opaque. Do not scan unused definitions looking for new errors.

Cache the signature facts once per reachable definition, using the declaration's
neutral type parameters. Caller-specific type arguments must not silently
change a single worker's physical signature. Store the shape for each live
parameter and the result after the same arity/erasure policy used by the direct
entry. A generic element remains opaque even at a caller that knows it is itself
a product. This keeps generic callers in agreement without cloning workers.

Local constructor/matcher facts must survive erasure as structured metadata:
either annotate the native intermediate node with a stable shape key during a
combined erase-and-describe traversal, or lower the relevant typed constructs
directly into a small native value IR. A side table keyed only by constructor
name is insufficient; specialized erasure and owner identity can differ. A
side table keyed by transient tree position also needs maintenance across
`nc_compact`, substitution, and `nd_reapply`. Avoid creating that fragile index
unless those transformations explicitly preserve the key.

The narrowest implementation can initially use only signature shapes and
explicit constructor/result-producing operations with a supplied expected
shape. Any local operation whose shape cannot be established this way stays
boxed. This is less coverage than a general typed native IR, but is reviewable
within a few hundred new lines.

## Private value and result interfaces

The coordinated extension to the current worker proposal is conceptually:

```text
NF_Value   = { shape: Opaque | ProductShape, words: List<String> }
NF_Binding = { id: U32, value: NF_Value }
NF_Target  = { destinations: List<String>, shape, join, owner, params, tail }
NF_Sig     = { argument_shapes, result_shape, physical_width }
```

An opaque value has exactly one word; a product has exactly its declared field
width. Keep the existing scheduler binding representation until a scheduler
multiword experiment is justified. Worker helpers can lift a scalar
`N_Emitted{code,value,fresh}` to a singleton value. Product-aware emission needs
an equivalent prefix-plus-vector result; do not force every primitive emitter
to pretend it returns a product.

The worker C interface can stay:

```c
INLINE Term NF_name(Env e, bool seq, Term* nf_out, Term arg0, Term arg1, ...);
```

The status result is still 1/0. `nf_out[0..result_width)` is owned by the caller
and is valid only on success. Scalar workers continue to have width one. A call
declares a fixed-size local `Term result[width]`; local destinations can name
those cells or fresh scalar locals. Arguments/results must be evaluated into
temporaries before overwriting any self-tail-call parameters. Retain the
prototype's parallel-move staging, local join scopes, error checks, polling,
and branch structure.

An admitted flat return must be flow-proven on every returning path: a known
constructor, a variable already holding the same bundle, or a call to a worker
with that proven flat result. A typed opaque `Var` is not enough. Missing proof
retains an opaque result; it must not introduce an eager destructure merely to
fill the output vector. Self-tail recursion can retain the fixed declared
output shape, subject to the existing worker admission rules.

For Array primitives, preserve the same evaluated inputs, `blk_*` operation,
and output order. Replace only the final `nc_array_pair` shell construction with
two output words when the destination accepts that proved Tuple shape. The
ordinary primitive entry still materializes the Tuple. Array cells remain
one-word slots; Array.get does not flatten a product stored inside an element.

## Demand and the smallest sound argument slice

`nc_compile` performs native validation but carries no authenticated
checked-book capability. Raw books can contain misleading types or a malformed
word that is never inspected. Unpacking such an argument in a new adapter can
move a tag failure, reference-count error, or drop before an unrelated error.
Merely checking the tag early does not prove that an early `ctr_take` is safe.
The correctness lane independently confirmed this boundary.

The recommended first argument slice is a product matcher already at the
function's first demanded operation after its full parameters are supplied:

- Keep the ordinary boxed entry's original argument evaluation, sharing,
  condition, failure branch, and `ctr_take`/`spare_free` at that matcher.
- Extract the matched success continuation as the flat C body accepting the
  fields plus the remaining parameters. The boxed entry transfers its taken
  fields to that body. It need not duplicate the full body.
- A caller holding a flow-proven constructor/result bundle with the exact
  matching owner and constructor can call the same flat body directly.
- A parameter first inspected after another effect, a product forwarded without
  inspection, an unknown boxed argument, or a repeated product/scrutinee alias
  remains on the original boxed route in the first implementation.

This is a constructor-to-known-matcher worker specialization. It can remove
cross-call transport boxes while preserving the source's demand boundary. It
does not authorize flattening every product-typed function parameter. Matcher
arms with residual parameters must retain the arity work's exact argument
sequencing; a partially applied matcher does not enter the flat body early.

If this entry splitting is too intrusive for the first patch, implement only
result bundles and local constructor/matcher elimination, report the remaining
cross-call boxes, and keep the argument step explicitly incomplete. Do not
claim native parity from a product-result seam that immediately boxes at every
named call.

## Ownership, scopes, and materialization

The runtime mechanics are in
[runtime.c](../../selfhost/src/runtime/native/runtime.c), lines 724–778 and
886–926. `term_keep` can introduce an RFC wrapper; `rfc_seal` seals a constructor
stored in a heap field; `ctr_take` handles both unique and shared parents;
`span_fade` expects nontrivial shared children to be sealed. Eliminating the
parent shell does not eliminate ownership of its children.

Treat a bundle as owning each field exactly once. A consuming match moves those
fields to fresh bindings. A dead field is sunk once. A field passed to an owned
call transfers ownership once. Packing a bundle uses the existing constructor
path, including ordered stores and `rfc_seal`; the field bindings cease to own
the transferred words. Taking a boxed product uses the current `ctr_take` path,
not raw reads from `e.mem`, and consumes the parent exactly once.

Initially materialize a bundle at a shared or escaping use. Distributing
`term_keep` across fields may be correct for checked duplicable values, but can
change the timing of `ERR_RFCS` for a raw product holding a nonduplicable closure.
Retaining the existing parent-level sharing operation at that boundary is a
small, conservative policy. Scalar-only field copying or proved duplicable
bundles can be a later independently controlled extension. A dropped fresh
bundle similarly needs to preserve field evaluation and the existing drop order;
if that equivalence is not established, materialize it there too.

Other initial materialization boundaries are unknown/partial calls, closure
capture, foreign arguments/results, heap fields, Array element stores, public
readback/main, scheduler return, and joins whose incoming shapes disagree.
Foreign and primitive override rules remain based on existing definition
provenance. Never recognize a native Array operation from its display name
alone. Bang, parallel, and unsupported worker paths keep their current route.

Define all destination locals outside any branch that writes them. A product
shape is fixed at a join and every successful branch writes all of its fields.
Never read a destination after a status-0 return. Moving fields between locals
requires no heap allocation and no keep when ownership is simply transferred.
The existing whole-binding liveness remains the first policy; field-level dead
use analysis is optional and must not add a new repeated term scan per field.

## Why defer the scheduler multiword ABI

`N_Segment.result` and `ne_ret` are useful infrastructure, but broadening that ABI
also changes `nc_words`, `nc_params`, `nc_slots`, `nc_let_cut`, captured values,
task/parallel result positions, closure entry adapters, and all physical widths.
The existing `nb_frame_results` arithmetic works only if held slots count words
and incoming result fields occupy the remaining positions consistently.

The ordinary-C lane already avoids continuation frames inside its admitted
component. Extending that lane's output pointer and local values obtains the
product experiment without coupling it to scheduler/device changes. Keep the
boxed original scheduler path as the compatibility boundary. A later scheduler
experiment should update every producer and consumer together and verify the
255-word table limits, seq/parallel behavior, and device code separately.

## Cost, compiler work, and falsifiable benefit

These are source estimates, not implementation or performance measurements.

| Slice | Estimated new source | Expected implementation/qualification loop |
| --- | --- | --- |
| Conservative fixed-shell/signature facts; neutral generic params; cache | 80–140 lines | One source review plus admission inventory; verify opaque fallbacks before target work |
| Worker value/destination vectors; scalar lifting; result calls and Array pair seam | 120–220 lines | One checked candidate build and independent scalar/product result controls |
| Leading-matcher flat entry, boxed adapter, linear ownership/materialization boundaries | 120–240 lines | One candidate build/fix loop covering raw demand, sharing, escapes, and ownership |
| Scheduler multiword ABI, recursive layouts, borrow analysis | Deferred | Separate hypothesis and controls if profiling still warrants it |

The useful full first slice is roughly **320–600 added lines**, potentially
lower if the C-worker owner generalizes the result interface during integration.
Confidence is medium for the interface facts and low for the line estimate;
typed metadata plumbing and preserved raw demand are the largest uncertainties.
Budget two or three candidate build/control iterations followed by the parent's
normal qualification, not a promised one-shot patch. All execution remains
root-owned. Register an implementation experiment before applying any patch.

Compiler-time policy: one reachable-signature inventory, one conservative shape
query per cached signature, and reuse of existing lowering/worker admission.
Traverse a constructor telescope once in field order. Do not add a whole-body
layout fixed point per C emission, repeated normalization for every word, or a
second JS lowering. A body flow proof can be computed during existing lowering;
the worker dependency closure already supplies an admission iteration.

The structural wins apply to transient tuple/record handoffs, result pairs,
record-valued state machines, and helpers passing scalar metadata beside opaque
container handles. Each eliminated linear shell removes its allocation, field
stores/seals, and subsequent parent take/free. The C-worker lane separately
removes continuation/frame dispatch; these benefits must be counted separately.
Persistent recursive trees, Map nodes, Array cell layout, escaping products, and
unknown higher-order paths remain unchanged in this slice. No runtime multiplier
or parity claim follows from this source inspection.

Use independent controls for generic and closed pairs, ordinary records, exact
constructor ownership, erased and dependent fallback, nested opaque fields,
Array handles/elements, self-tail parameter swaps, mixed return branches, unused
malformed arguments, competing error order, shared scrutinee/residual aliases,
boxed closure/foreign/readback escapes, and primitive overrides. Preserve the
existing raw/error/bang controls as unchanged inputs. Check emitted structure
and operation counters before timing: the intended admitted edges should have
no Tuple allocation/take, and fallback edges should retain their old behavior.
Track C bytes, compiler time, C compilation time, and runtime separately across
independent families. Increased physical argument width and boundary packing can
regress low-traffic or higher-order code even if a hot linear pair path improves.

## Source snapshot and coordination

Read at HEAD `dae13e9c398ed9b9da06671e07ba070df0c7a33b`, with concurrent
Phase68 worktree changes. Relevant file SHA-256 values at inspection:

```text
native/ir.bend       dada548b975e325d96735f94b4e65e56d0d47b8e22851bc6815bed7063e0339b
native/layout.bend   35981acafb07efcf3983baef35fffe573f8dc79707ea3077d9a15d360f05390b
native/bridge.bend   d3d3ad02acc1853579e1186ef3c9975406f7869681f11299a58c9d9cb00a6832
native/erase.bend    8f536cdfbca91b26bf426b3c8c5f42106fc0e18af7bfd2550ba73e7dab5530ec
native/emit.bend     862af7916a7b26d6801726b48d422f154bb8a34c4c140cccc534c5d0ff21b46a
native/tables.bend   6b8f36fa9063f35105889d8977aa2345fb01eeceb117e6f641151430d084bbaa
common/queries.bend  e62d1b368c8c3b4a69eb0eedca263e3ac4ac3059746c257039e16999993038a8
flat-worker candidate/flat.bend
                    c117a74728a5341bd26ec9f998a3d7e3c73e8561cd95e0768cae3c336d9c37f9
```

The worker owner confirmed the current status-return/one-word-output interface
and agreed that destination vectors and binding bundles are the extension seam.
The root accepted fixed-shell fields with opaque owned leaves as the practical
scope. The correctness owner required flow-proven transport or splitting at the
original matcher boundary because annotations are not an authenticated
checked-book contract. This note incorporates both constraints. No prototype
module is claimed compiled or integrated.

## Isolated implementation refinement

Root subsequently authorized [P68-007](../../experiments/phase68/P68-007-flat-products.md),
committed its registration before implementation, and requested a runnable
source proposal. The isolated files are under
[`flat-products/`](../../selfhost/tools/performance/phase68/flat-products/).
V1 is preserved as an unexecuted source snapshot; v2 incorporates the parent's
occurrence-summary and small-inline worker changes plus review refinements.

The implementation uses cached signature shapes and a constructor catalogue
derived from those validated descriptors. An actual erased constructor with the
exact native identity and live field count is a valid fixed-shell producer;
its field types are never reconstructed. This permits an initial literal record
to enter a private product loop, not merely a product already returned by one.
Fields use the existing scalar `NC_Binding` environment, with internal bundle
nodes recording that their evaluation has already occurred.

The ordinary boxed workers remain, alongside private `$product.` variants.
Those variants receive field vectors only from matching proved bundles. This
initial version can duplicate body text; output size is an explicit cost to
measure. `NC_Code.calls` records the emitted boxed/product call graph so the
existing readiness algorithm sees actual selected variants and rejects cycles.
Scheduler effect metadata retains the original source-reference policy.

Review required two further restrictions. Local virtual bindings require a
single use on every matcher path; a zero-use branch retains materialization and
the original shell drop. Private product parameters also undergo a conservative
source-demand check through leading lambdas and matcher-raised residual
arguments, requiring exactly one whole-product use on every inspected path.
Only exact runtime-native complementary guards or literal-true guards eliminate
miss paths; general ADT exhaustiveness is not assumed. At successful direct product matching, the field environment is
ordered after other held values just as in the original take-and-bind path.
These rules avoid assuming arbitrary field-by-field drops equal parent drops.

The v2 layout query uses bounded syntactic reduction, with
no global reference unfolding or general conversion for newly inspected
constructor field types. Unknown aliases decline. Existing arity queries already
normalize the source function telescope, but that does not authorize extra
normalization inside a previously unused constructor definition in a raw book.
The source proposal, exact relative patch and baseline/candidate hashes are in
[`flat-products/v2/`](../../selfhost/tools/performance/phase68/flat-products/v2/).
It adds 533 net source lines, within the registered implementation estimate.

An independent source review is recorded in
[product-source-review.md](../../research/phase68/product-source-review.md).
Source checks and reviews are distinct from the parent's checked builds,
controls, counter evidence, and measurements. Another conservative coverage cost
remains: a selected product variant that later fails admission can prevent a
boxed dependant from using its otherwise valid worker; it then retains scheduler
fallback. Track worker coverage alongside runtime before broadening this choice.
