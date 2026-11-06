# Phase173: complete semantic-store consumer and independent gates

This is an experimental validation design and source implementation. **No target
was run by the author of this note.** The root execution lane must append actual
receipt paths and results before any speed, correctness qualification, or
promotion claim. The qualified Phase170 compiler remains the reference.

## Select a complete, falsifiable computation

Use the actual erased-body closure of a checked compiler request. For every
reachable ordinary definition that static preparation would process, compute
native literal compaction and its exact ordered reference occurrences. The
reference is the unchanged `nc_compact` followed by `nc_refs`, not an invented
checksum or a tiny getter kernel. The candidate imports a body into the indexed
store once, compacts it and extracts references through IDs, then exports its
complete compacted value once. Its store is consumed before returning.

The boundary follows real code:

1. `host/native-plan.bend:p86_plan_context` selects and annotates the reachable
   declarations; `p86_plan_annotated` retains the existing layout/error check.
2. `back/common/constructor-facts.bend:p144o_prepare_annotated` merges annotation,
   computes the exact binder bound and constructor-ownership view, then calls
   `nr_walk` to create `NativeErasedBody` facts.
3. `back/qbe/static-data.bend:p112s_defs` applies `nc_compact` to those bodies
   before static construction. `p112s_def_step` retains the original erased body
   as the child of `NativeStaticBody`; observers need that original form.
4. The downstream candidate lowerer, generic fallback, independent final
   verifiers and QBE cursor remain unchanged.

The important limit is explicit: this first implementation **does not migrate
erasure, normalization, telescope substitution, static construction, or native
lowering to IDs**. It demonstrates a real allocating transformation plus another
consumer over IDs. It cannot establish a whole-compiler representation win by
itself. Full indexed erasure would require the `wnf`/`subst`/dependent-telescope
consumers called by `nc_erase_annotated` and `nc_erase_args`; wrapping those calls
in repeated exports would preserve most work and is not that architecture.

The initial experiment uses one bounded store per real body. This charges
creation and teardown rather than concealing their costs in an immortal store.
A later shared request store would need measured lifetime and snapshot costs.

## What the architecture comparison actually tests

The [Phase167 alternatives](../phase167/architecture-alternatives.md) separate
one canonical execution graph from lifetime/representation changes. This test
examines the second route. It does not repeat Phase164's reduced generic segment
count while retaining almost all later work. A favorable result permits the next
producer and consumer to move into the store; an unfavorable result distinguishes
transport, allocation, array operations, compaction and retained consumer costs.

The Phase171 diagnostic assigns approximately 4.13 seconds to the whole static
preparation interval, and this pilot touches only part of it. Even deleting that
entire interval would not explain a reduction from roughly 181 to 100 seconds.
The rationale is testing whether a better execution representation transfers to
complete allocating computations, **not** presenting compaction as an 80-second
hotspot. [Current cost ceilings](../phase171/next-work-ceilings.md).

Native arrays use the authenticated runtime's `TAG_ARR` path with constant-time
indexed access even when File effects forbid the optional scalar-array packing
policy. That policy affects packed scalar representation, not whether arrays are
native. Hosted Array execution and native execution are different mechanisms:
hosted timing must not select or reject this representation.

## Implementation and interfaces

- [`vertical.bend`](../../selfhost/tests/phase173/vertical.bend) exposes actual
  `NR_Request` body inputs and an unchanged reference consumer. `P173VBody`
  returns the complete name, compacted `KTerm`, ordered references and error.
  `p173v_erasure` also exposes the complete retained source's erased closure for
  a future erasure candidate, without pretending it is optimized today.
- [`vertical-store.bend`](../../selfhost/tests/phase173/vertical-store.bend)
  performs import → ID compaction → ID references → terminal export → independent
  store-shape validation. Failure is explicit. The store implementation has a
  separate status flag; exhaustion never counts as a passing empty result.
- [`vertical.mjs`](../../selfhost/tests/phase173/vertical.mjs) only authenticates,
  transports and compares values. All compiler algorithms execute in checked
  Bend. It compares every constructor/field/scalar and output order, and includes
  deliberate field/order mutations to test the comparator itself.
- [`vertical-native.py`](../../selfhost/tests/phase173/vertical-native.py) is
  metadata-only transport. From a passing complete-value receipt it embeds exact
  input/output constructor literals and extracts only the authenticated consumer
  declaration closure. It emits small baseline, candidate and constant-oracle
  sources; it does not execute Bend or reimplement any compiler pass.
- [`vertical-overlay.bend`](../../selfhost/tests/phase173/vertical-overlay.bend)
  replaces only `nc_compact` with the imported/indexed/exported computation for a
  full-request differential control. Use
  [`vertical-prelude.bend`](../../selfhost/tests/phase173/vertical-prelude.bend)
  to declare the helper before that earlier production definition.

The full-request overlay is a compatibility bridge, not the final representation:
existing downstream reference discovery is still paid. The combined consumer
test deliberately differs from that bridge by keeping compaction and references
inside the store. Report both boundaries instead of claiming all consumers have
migrated. A failed store operation returns an explicit compiler error, not a
silently successful original body.

The 16 finite controls cover ordinary terms, lambda presence/quantity and all
other metadata, scalar and String literals, Zero/Succ compaction, dynamic Nat
tails, duplicate references in exact order, opaque `NStatic` metadata, owned
constructor names and local binding structure. The separate roundtrip gate checks
original metadata before compaction intentionally removes some of it.

## Frozen real workloads and independent authority

| Workload | Source and SHA-256 | Independent runtime output |
| --- | --- | --- |
| Actual compiler verifier | `selfhost/build/phase167/verifier-source03/compiler.bend`; 39,333 bytes; `ff6b4083aa2f3e034f3b4f8e43dfb25d93a4f524685934e0ee13845278033ef3` | `768\n`; `experiments/phase169/verifier.expected` |
| Unrelated Map application | `selfhost/tools/bench/catalogs/native45/fixtures/coverage-map-churn-128.bend`; 3,659 bytes; `cd22c831c180c0de12d84aeb80debf4881d08cbd18fcf8f6d634153fba2feb03` | `experiments/phase167/tools/map-oracle.py`; check semantic output, not clock text |

The parent maintained source is Phase170, 3,150,535 bytes, SHA-256
`434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
`selfhost/tests/phase171/prepare-api.py` verifies that exact source and refuses
changes to all 112 protected declarations. Use separate baseline and candidate
checked acquisition receipts. `vertical.mjs` verifies every assembly input and
both complete source/API identities before and after execution, and requires the
same pinned Base, prepared carrier, stamp and Bun. The actual body lists and full
checked requests must match before the candidate pass runs.

The older Phase169 checker32 fixtures are intentionally not the workload here.
Their nonempty checking coverage does not establish coverage of a selected
transformation. These controls instead extract the exact erased bodies that the
actual QBE request is about to consume.

## Gates in order and charged cost

1. **Checked source and finite controls.** Assemble the unchanged reference plus
   `vertical.bend`; independently assemble the candidate store/compactor plus
   the same observations. Require 16 exact import/export controls and 16 complete
   compact/reference values. Stop on first semantic mismatch.
2. **Whole real consumer.** For each pinned source, require complete checked
   request equality, complete extracted body equality, and complete transformed
   body/reference equality. Save both full result artifacts, not just their
   checksums. The observer records prepared-Base, frontend, extraction and whole
   pass time separately; hosted numbers are diagnostic only.
3. **Same-producer native consumer.** Root should compile bounded consumer
   workloads with the same qualified native compiler/runtime/toolchain and compare
   complete outputs to gate 2's independent values. Include every live body and
   fresh store import/export/destruction; do not repeat an empty source or run an
   indefinitely retained kernel. Record native runtime, allocation requests and
   peak memory. Do not use JS tree-array timing as native evidence.
   The delivered extractor is `python3 -B
   selfhost/tests/phase173/vertical-native.py --controls PASSING_REPORT --role
   baseline|candidate|oracle --out FRESH_DIRECTORY`. Each program returns the
   complete `List<P173VBody>` through the same native derived printer. The oracle
   consists only of independently captured expected literals. Require exact
   native stdout equality across all three programs. This first probe runs one
   whole corpus per fresh process; no unused pure computations are repeated.
   Literal construction/static sharing, full output printing and exit are all
   charged and must be distinguished from the transformation itself when
   interpreting profiles. Native source checking and compilation remain root
   responsibilities; metadata extraction is not validation.
4. **Actual full request.** Assemble a separately checked candidate with
   `--replace nc_compact`, and run the existing Phase171 `request.mjs` in baseline
   mode on both APIs. It invokes the ordinary lowerer, independent final verifier
   and complete cursor. Require exact QBE bytes against the unchanged receipt.
   Build and execute both ordinary programs with their independent output oracles.
   Record source checking, compiler execution, QBE, assembly/link and generated
   runtime separately. Process exit/teardown belongs to the native total.
5. **Transfer before acquisition.** Only a material gain on actual native
   computations, with a credible larger-workload contribution, justifies moving
   another major consumer into the store or acquiring a new full compiler.
   Whole-compiler self-reproduction and ordinary qualification remain later gates.

The data runner takes `--baseline RECEIPT --baseline-assembly MANIFEST
--candidate RECEIPT --candidate-assembly MANIFEST --source PINNED_SOURCE --out
FRESH_DIRECTORY`. Required extra exports are `p173v_inputs`,
`p173v_control_inputs`, `p173v_baseline`, `p173v_original_body`, `p173v_candidate`
and `p173v_roundtrip`, as appropriate for each API. For candidate compilation,
include `store.bend`, `store-compact.bend`, `vertical.bend`, `vertical-store.bend`
and `--prelude vertical-prelude.bend`. The full-request overlay adds
`vertical-overlay.bend --replace nc_compact`. All target jobs must use the
maintained disk/resource guard and the single root-controlled execution lane.

## What would falsify the proposal

- Complete values differ: representation or compaction semantics are wrong;
  neither smaller IR nor lower allocation counts rescue the candidate.
- Import/export/release dominates: migrating one pass is insufficient. Quantify
  how many real later consumers would have to remain indexed to amortize it;
  do not simply omit the boundary from timing.
- Array storage remains mostly boxed shapes, child lists and transition tuples:
  IDs alone have not removed record/allocation costs. Inspect native code and
  allocation categories before proposing a denser layout.
- Whole native pass improves but full request does not: the touched interval is
  too small, or some later work increased. This is evidence for the representation
  only, not a successful cold-build optimization.
- Full compiler only fails at scale: preserve the bounded success and the failure
  separately; address identity, stack, capacity or lifetime limits before promotion.

The next durable interface, if justified, is an indexed erased-body fact plus
checked constructor/layout metadata retained through static preparation and
actual candidate lowering. Merely storing a KTerm pointer under an ID and
exporting before each consumer is not the proposed architecture.

## Native literal-transport failure and correction

The root's first native baseline build of the complete 101-body corpus failed
after 31.617 seconds with `adapter renderer original final IR: too many direct
locals`. Evidence remains in
`selfhost/build/phase173/store-native-baseline01/report.json` and
`compiler.stderr`; the original source remains in
`store-native-baseline-source01`. This is an observation about the test source's
single large literal constructor, not a store speed result. Both maintained
`verify-direct.bend` and `verify-compact.bend` correctly cap a function at 65,535
locals. Those bounds and final verification are unchanged.

The metadata transport now preserves the entire corpus while splitting literal
construction into per-body helpers and bounded nested-subterm, list and String
helpers. Its conservative 512-unit budget counts constructors, scalar fields
and String code points, rather than assuming a fixed correspondence to QBE
locals. The top-level list is additionally chunked every 32 bodies. Baseline and
candidate get identical input transport; the constant oracle uses the same
grouping algorithm on its independent complete expected values.

A metadata-only rerender of the exact captured input produces 914 helpers with
maximum budget 512 and 827,344 bytes of literal source. This additional source
and construction-call cost is explicit, not a simplification or benchmark
reduction. `literalTransport.version = 2` in each new receipt distinguishes it
from the failed source. It needs fresh native checking/execution before any
performance interpretation; grouping is not itself a correctness qualification.
