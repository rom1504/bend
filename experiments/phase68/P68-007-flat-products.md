# P68-007 — Forward fixed product fields between native workers

- Owner: research/source lane; root owns target execution, integration and promotion.
- Prospective registration: 2026-10-08, before prototype source edits.
- User objective: ambitious native parity while preserving general source behavior,
  raw API boundaries, and compiler simplicity.
- Correctness: design reviewed for public raw-demand constraints; no candidate
  compiled or executed at registration.
- Measurement: none; no performance improvement claimed.
- Decision: implement an isolated proposal after coordinating the P68-005 worker
  interface, then conduct a root-owned checked experiment.
- Related: [P68-005 workers](P68-005-flat-workers.md),
  [product design](../../design/phase68/flat-products.md),
  [primary-source research](../../research/phase68/world-compilers.md).

## Hypothesis and bounded first implementation

A known one-constructor product can remain an ordered vector of ordinary native
`Term` fields across private local/result/known-call boundaries. Avoiding its
temporary shell removes heap allocation, field stores/seals, and a subsequent
take/free. This mechanism applies to general records and pairs, including
generic products with an opaque Array handle or element. It does not require
recursive layout flattening, monomorphization, Array cell layout changes, or a
new scheduler ABI.

The first candidate extends the ordinary-C worker destination/result seam with
small bundles and a vector `nf_out`. Scalar emission lifts to one word. Native
Array pair operations preserve their exact `blk_*` operations and evaluation
order, changing only product result transport. General constructor/result flow
must also be supported and discriminated, so admission is not based on workload
or benchmark names. Opaque or unsupported flows materialize the existing box or
retain their original worker route.

Typed shape facts must be computed before native erasure removes constructor
type arguments and erased field positions. Initially consider fixed complete
single-constructor owners, positive bounded width, no erased constructor fields,
no runtime-dependent field family, and ordinary constructor representation.
Erased generic type parameters and opaque one-word field types are permitted.
Primitive encodings, recursive expansion, empty products, unknown shape, and
excessive widths fall back. Existing native/foreign/primitive-override provenance
rules remain authoritative.

## Demand, ownership and calling contract

The public native compiler has no authenticated checked-book bit. A type alone
cannot justify taking apart an arbitrary boxed parameter earlier than the source
would inspect it. Flat transport therefore requires known constructor/result
flow or splitting at the original demanded matcher success. Keep boxed public,
scheduler, unknown closure and foreign boundaries. Partial/bang calls do not
enter a new flat continuation early.

Each bundle owns its fields once. Transfer moves ownership; packing uses the
existing constructor seals; taking a box uses existing `ctr_take`/`spare_free`.
Initially shared or otherwise unsupported escaped bundles materialize. This
preserves parent-level sharing demand instead of moving possible `ERR_RFCS`
earlier through per-field keeps. Every successful output path fills all result
words, and failed calls leave outputs unread. Preserve existing error checkpoints,
polling, self-tail parallel moves and branch scopes.

Result vectors alone may still materialize at every named call. Report that as
partial coverage; it is not evidence that cross-call shell traffic was removed.
The minimum useful structure discriminator must show a produced pair/record
reaching a local or private worker consumer without an intervening shell.

## Setup and first controls

The isolated proposal will live under
`selfhost/tools/performance/phase68/flat-products/`, with immutable base/candidate
copies, a relative follow-on patch, and exact SHA-256 manifest. Root must verify
the coordinated worker base or record a rebase before applying it. Preserve all
prototype revisions and failed attempts; do not rewrite this registration as a
successful outcome.

Keep the pinned upstream, Base/runtime, host harness, C flags, workloads and oracle
fixed within an attempt. Root owns one guarded target tree; source/data work uses
CPU0. Compiler emission, C compilation and execution are separate clocks. No
parallel target execution is authorized by this source registration.

Required first discriminators:

- Checked B1 plus independent Array pair and ordinary record producer/consumer
  fixtures; scalar results remain unchanged.
- Closed and generic opaque fields, nested opaque records, matching owner
  identity, erased/dependent/zero-width fallback, and mixed return branches.
- Boxed escapes, shared scrutinee/residual aliases, unused malformed arguments,
  competing error order, ownership under one/four threads, and self-tail swaps.
- Unchanged raw precedence, bang, primitive override and foreign callback controls.
- Generated structure/counters: admitted boundaries remove intended shell
  allocation/take; fallback remains active and correct.
- Independent native families and held-out coverage if structure and correctness
  pass; record generated C bytes, emission time, C compilation and runtime.

Stop or narrow on unexplained diagnostic/ownership/calling differences, hidden
eager destructuring, absence of the intended general structure change, material
compile-time/code-size cost, or regressions outweighing the eligible-domain gain.
Do not broaden admission or alter controls to hide a failure. The source estimate
is 320–600 added lines and two or three checked candidate loops, with low
confidence in size; it is not a performance forecast or promotion decision.

| Attempt | Correctness | Measurement | Interpretation |
| --- | --- | --- | --- |
| Prospective registration | Design constraints only; no target run | None | Isolated implementation authorized by root |

## V1 source refinement, before application

The isolated implementation keeps scalar-output boxed workers and adds private
`$product.` variants. A variant's product parameters consist of already evaluated
field words; it is selected only when each corresponding actual is a matching
known bundle. It never eagerly unboxes a public boxed argument. Local constructor
flow uses a catalogue built from validated signature descriptors and requires
the exact emitted native constructor identity and live field count. This is a
storage-shape certificate for an actual constructor, not an inference about an
arbitrary typed variable. Nested fields remain opaque words.

The first version duplicates a source body for the boxed and product entries;
that generated-code cost must be reported. Local virtual bundles use fresh
ordinary scalar bindings. Repeated sequential uses and opaque escapes repack;
mutually exclusive matcher branches can retain the bundle. A boxed caller may
enter the private product loop once it has a known constructor/result bundle.
This covers the initial constructor state as well as primitive result pairs;
result-only transport would leave state boxes at each recurrence.

`NC_Code` carries explicit emitted worker-call dependencies so readiness checks
follow the selected boxed/product graph. Source references alone do not describe
that graph. Self-tail edges use staged parameter moves and a local goto;
unsupported variant cycles remain unadmitted. This is metadata only for ordinary
scheduler paths. New bundle internal nodes are gated to private worker lowering.

The source snapshot preserves both the initial worker-v3 base and a subsequent
integration base containing the parent's short-circuit admission and occurrence
summary changes. The source-only composer, relative integration patch and hash
manifest are under `selfhost/tools/performance/phase68/flat-products/v1/`.
Native/correctness reviewers checked the fixed-shell query and flow contract;
source review found and corrected fresh-ID and affine-capture issues. No target
result is claimed by this addendum. Independent ordinary-record and owned-Array
controls are supplied by the correctness lane.

## V2 safety refinement, before application

The v1 source is preserved. V2 rebases onto the parent's occurrence-summary and
small-inline source, with exact integration hashes. Its layout query now uses
bounded syntax reduction, direct ADT declaration lookup, nonreducing substitution
and structural equality. It does not unfold global aliases, normalize fields or
call conversion. Unknown shapes decline, preserving the raw API's lack of a
checked-book capability.

Local virtual bindings require min=max one use across branches. Private product
parameters must similarly reach exactly one source use on every inspected prefix
path after bounded symbolic beta. Zero-use and repeated-use paths keep boxed
ownership, rather than distributing a parent's drop or sharing into its fields.
Only runtime-unconditional guards and exact native Zero/Succ or False/True
complements exclude miss paths; general ADT exhaustiveness is never assumed.
Successful virtual matching uses the original held-bindings-then-fields order.

The relative v2 patch adds 533 net source lines and preserves the parent worker,
occurrence and inline behavior outside the product extension. Native and
correctness peers reviewed the bounded query and demand/drop changes. Require
the branch-drop fixture's private-entry exclusion as well as output, native
exhaustive-positive and unknown-tag-negative controls, and the unchanged raw
controls. Source checks are not target qualification; no gain or parity claim is
made before the parent's build and measurements.

## V3 bounded alias successor, before application

The actual products10 source audit found zero private product workers in the
numeric, array and lexer outputs. The parent's correctness controls passed, but
this does not establish the registered structural effect. Saved products10 C and
the failed strong array receipt remain unchanged. The actual signature diagnostic
showed Pair applications declined by v2's refusal to read global aliases.

V3 reads general aliases with a 64-transition syntax machine, visited-name cycle
refusal and a 4096-node substitution-growth bound. It invokes no global normalizer,
conversion or term computation. Final ADT equality keeps nominal identity and
exact structural arguments while excluding irrelevant outer parser metadata,
consistent with core ADT equality. There is no Pair or workload exception.
All flow, ownership and branch-demand gates remain unchanged. The isolated helper
patch is under `flat-products/v3/`; its effect still requires a new checked build,
raw controls and a passing reachable-product graph discriminator.
