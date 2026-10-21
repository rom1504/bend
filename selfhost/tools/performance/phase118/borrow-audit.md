# Phase118 borrowed-observer audit and isolated prototype

This audit used only source/artifact reads. No compiler, benchmark, native target,
or full rebuild was run by this agent. The initial assigned checkpoint was
`c6a0564`; HEAD was `6436eb5` when the bounded audit resumed. The immutable selected
source is Phase117 `version-source03/compiler.bend`, SHA256
`8010f9b5691a32f9b8d3a45da444e05b4bf4275fd1380e2acb122bfd2e53fec6`.

## Measured evidence versus the architectural hypothesis

Phase116 `implementation/phase116/machine-hotspots.md` is the dynamic evidence.
Map has 824 pooled leaf samples: constructor134, Take120, libc173 (110 fill,
63 copy), work-loop35, `Map.bit.go`35, register transfer27, jump26. Tree has
930: Take164, constructor164, libc140, recursive warp87; scan has only three
named leaves. These are leaf PCs, not inclusive call costs. We cannot attribute
every constructor/Take/libc sample to one observer or sum all of those samples
as its attainable saving.

The distinction matters: the proposed root-preserving observer transform is
well aligned with Map key traversal and compiler String comparison, but it is
not a demonstrated solution to the tree warp hotspot. Tree modifies its result.
The mature observer schema admits two-constructor linear chains with one
recursive field and scalar payloads; binary Tree and arbitrary Map trie traversal
are outside that schema. Wider aggregate borrowing was separately prototyped
in Phase99 and must not be confused with the selected Phase117 implementation.

## Concrete missing work elimination

`bend2/base.bend:2541` defines `Map.bit.go` as an owning traversal returning the
same key and one bit. Its recursive continuation at2537 rebuilds every visited
`SCon`; `String.cmp` at1914 similarly rebuilds compared prefixes and returns both
input roots plus the comparison. The source is correct affine code. The
reconstruction is unnecessary once root preservation is independently established.

Mature C artifact
`selfhost/build/phase99/phase102-runtime-products04/coverage-map-churn-128/b1/output.1.c`
contains `$observer.Map.bit.go` around2020 and its adapter around2090. The worker
uses `term_peek(e, key)`, reads the character/tail, and tail-loops with local
variables. It performs no constructor Take, per-node owner drop, or per-node
reconstruction. The adapter keeps the original owned key alive and returns it
with the scalar observation in one final Tuple. There are also borrowed
`p37.map.string` and `String.cmp` workers. C SHA256:
`d576e2dd316a7fbd6a4913dd9284cb3ebd1411559f2ecaa430bc74ce30b16480`.

Qualified QBE artifact
`selfhost/build/phase111/p114-final-screen01-coverage-map-churn-128-emit/program.ssa`
still has the scheduled `$direct.Map.bit.go` at27612: Take the SCon, capture its
head, jump to the recursive traversal, and resume a reconstruction continuation.
The flat `$product.Map.bit.go.rec` at1490 still calls `p111_rt_ctor` for SCon; the
boxed helper at1452 also constructs Tuple. The same pattern exists for String
comparison. QBE SHA256:
`fafab73896673a651aa11c16da2e4eed0a11eefbff9a30ebcd8604ffe9e0a9ff`.
These exact line references are Phase114 products, which supplied the profiles;
they are not claims of fresh Phase118 measurement. Phase117 changes preserved
the relevant generic ownership route; the root experiment must inspect its new
products before making current performance claims.

This is stronger than merely removing redundant constructor validation. An
observer can eliminate whole Take/rebuild/scheduler sequences, including shared
RFC work. A known-layout owning Take keeps `ctr_take` semantics, including
shared `span_fade`, so primarily removes descriptor lookup, generic-size loops,
and scratch transport. Both are general transformations; their ceilings differ.

## Existing semantic machinery to reuse

The selected assembled source retains the mature modules:

- `observer-plan.bend:no_observer_plan`: checked owner/effect/arity admission.
- `observer-layout.bend:no_schema`, `nol_root_fields`, `nol_wrap`: checked
  root/constructor/result schemas, exact field types, bounded wrappers.
- `observer-analysis.bend:noa_analyze`, `noa_finish`, `noa_recur_done`: bounded
  symbolic evaluation establishes root reconstruction and descending tail loops.
- `observer-emitter.bend:no_emit`, `no_emit_match_layout`: independent residual
  vocabulary/layout/fresh-binder validation and borrowed read emission.
- `observer-adapter.bend:no_wrapper_nodes`, `no_wrapper_once`: bounded owning
  result construction. Scalar-only adapters have a different consumption policy.

The ordinary QBE entry `phase113/products/plan.bend:p113pl_lower_request` does not
call that observer planner. It admits complete owning functions/products and
otherwise preserves scheduled segments. The analysis exists, but the QBE route
does not yet use its result. No whole-compiler rewrite is needed to test transfer.

## Shared ownership contract

`runtime-products01/runtime.c:ctr_take` copies fields, releases a unique RFC
wrapper, or calls `span_fade` for shared owners. The latter increments child RFCs
before dropping the consumed root. Phase116 hot PCs include this shared branch.
An exact CID does not justify skipping it.

A borrowed reader instead retains the original owning root for its whole dynamic
extent and reads through `term_peek`, which resolves the RFC indirection. It never
owns those child views, increments/decrements their references, returns one as an
owning result, mutates them, or invokes an arbitrary owning callee with them.
The adapter finally returns the original owning root exactly once. Unique,
shared, and static roots are all valid under this contract; a shared-only fast
path is unnecessary for this root-preserving product subset. Scalar-only
observers are deliberately excluded from this first prototype because they must
consume/drop roots or preserve the mature unique-input fallback.

## Isolated implementation and boundary

Four additive Bend files implement the experiment:

1. `borrow-model-v3.bend`: checked-request plan and candidate admission.
2. `borrow-lower-v2.bend`: NO residual to existing structured P113D IR, plus an owning
   public adapter. Exact source helper names never select transformations.
3. `borrow-verify-v2.bend`: independent structural projection for the one new import.
4. `borrow-program-v3.bend`: optional emission entry; original verifier unchanged.

The four original unversioned files are retained byte-for-byte as pinned by
`borrow-source01/manifest.json`; the failed acquisition is reproducible. The v2
model/checker add exact argument-type and private-symbol collision guards. The
v2 program fixes an unsupported computed match scrutinee using a typed helper.
An independent overlay-transport failure initially dropped existing law/def
pairs; the root fixed that transport in a new preparation version. These are
acquisition failures, not native performance or semantic results.
The next acquisition found an affine duplicate capture in candidate recursion;
model-v3 marks its shared tail, lower-v2 marks values selected by alternative
branches, and program-v3 marks the filter's shared tail. All prior versions are
preserved rather than edited after acquisition.

Exports are `p118b_plan`, `p118b_plan_names`, `p118b_new_functions`,
`p118b_chunks`, and `p118b_emit_request`. The root harness must derive the ordinary
program and plan from the **same checked NR_Request**, retaining that source/API
identity in its manifest. Plans are compiler-internal records, not authenticated
serialized plans from another source. Candidate names are analyzed once when
planning and their NO plans re-derived before emission; no raw worker IR is
accepted through this interface.

The root supplies one additive helper:
`p118_rt_borrow_fields(state, term, out, cid, count)`. It validates CID, count,
representation, and destination presence, reads via `term_peek`, and copies
without consuming anything. Root's `runtime-borrow.c` matches this contract.
The initial admitted schema uses widths2–8; its unused unary PAK helper support
does not broaden compiler admission.

Unchanged `p113a_verify(original)` checks the complete original program. New
functions are generated only from a re-derived successful NO plan whose mature
`no_emit` validator succeeds and whose wrapper returns **every owning root
exactly once**. Their extra import is projected to the existing Take **signature**
for unchanged scalar/buffer/definite-assignment/call-graph checking. CID and exact
arity are checked separately. This is a structural projection, **not** an
assertion that borrowing and owning Take are semantically equal. The NO analysis
and retained-root adapter supply that separate semantic argument. No generic
verifier whitelist, heap-pointer permission, or production selection is relaxed.

## Fast falsification and ordinary controls

First root-run gate: checked API acquisition; list candidate names; compile one
small root-preserving String observer; independently verify exact output, then
inspect that it contains the borrowed worker and original public ABI wrapper.
Keep an ordinary owning fallback program and rejection evidence.

Reuse `phase99/borrowed-call-tests/aliases-v3.bend` for same-root aliases, shared
tails, Unicode characters, retained full roots after observation, and an escaping
child which must remain owned. That file's scalar-only equal-walk may intentionally
remain unselected under this narrower product profile; it still tests the fallback.
Use `Map.bit.go` and `String.cmp` with empty, equal, unequal, prefix, long shared
prefix, unique generated, shared generated, and static inputs, inspecting their
returned original roots as well as observations. No invalid pointer/tag workload
is needed. Existing Phase88 observer component controls exercise all residual
continuations and rejection shapes.

Only after those controls, run the existing map case and one unrelated String
comparison workload with matched repetitions. Record emitter preparation cost,
generated size, runtime, and whether shared Take/reconstruction disappeared.
Reprofile only if timing supports the mechanism. An unchanged tree result is
expected, not a failure: destination passing or owning layout transfer addresses
its different bottleneck. There is no measured speedup from this prototype yet.

## Possible scalar-only extension, not implemented

For a scalar-only accepted NO plan, the adapter can retain each original owning
root through the reader, then sink each original argument exactly once and return
the scalar observation. Two owned argument handles with identical bits still
represent two ownership tokens and require two sinks; they must not be deduplicated
by pointer equality. Distinct roots can also share tails. All sinks must follow
the final borrowed read, including an early-result path. NO scalar admission
already excludes returning an owning child view as the observation.

This is semantically plausible but not automatically profitable. A unique root
then suffers a readonly traversal followed by generic destruction of the original
root, while the owning worker can release visited nodes during its single pass.
The mature C `no_scalar_redirect` therefore borrows only when at least one root
has an RFC count greater than one, preserving the ordinary owned worker otherwise.
The small faithful QBE extension should initially require that ordinary complete
worker to exist, clone it under a fresh private name, and choose it for unique
inputs. An unconditional borrow-then-drop policy should be an explicit ablation.

Ordinary controls must cover same-root arguments with an external retained alias,
two different roots sharing a suffix, unique runtime-built roots, static roots,
empty inputs, early mismatches and long equality scans. Observe the external
roots afterward, not only the scalar result. Retain existing output oracles;
there is no reason to manufacture invalid raw Terms or unsafe runtime faults.
