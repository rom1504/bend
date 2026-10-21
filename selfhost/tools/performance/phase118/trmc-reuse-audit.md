# Phase118 consumed-cell reuse: isolated structured projection

This is a proposal and source audit, not a measured improvement. Compose
`trmc-reuse.bend` after checked `trmc-v4.bend`; append `runtime-reuse.c` after the
selected cold-aware destination helpers. Do not change production selection.
Root owns qualification and measurements. The only replaced Bend definitions are
`p118t_ready`, `p118t_import`, and `p118t_import_contract`.

## Why this is a separate experiment

The allocation-only constructor-tail worker removes reconstruction continuations
but still frees each consumed input cell and allocates each output cell. Mature C
already retains an exclusive consumed cell with its allocation class. This
prototype transfers that capability to structured QBE without generating C
expression strings or changing source eligibility. Cold constructor metadata and
borrowed observers are separate improvements and must be held fixed when timing
reuse. A cheap negative result is useful: it would show that avoiding this local
free/allocate pair does not justify another private protocol on the tested paths.

## Private representation and transitions

Each admitted constructor-tail worker has one additional U64 formal,
`p118_credit`, initialized to zero by its public wrapper and propagated through
every structured local backedge. Its low40 bits are a dynamic cell location;
upper bits are its allocation class. It is opaque metadata, never a source Term,
source binding, heap child, return value, or scheduler register argument. One
fresh eight-byte alloca transports the next credit out of the extend helper.
Nested ordinary calls have independent formals/allocas. No state-global cache is
introduced; at most one cell of at most256 words is retained per active worker.

1. `reuse_take(state, term, out, count, credit)` preserves the exact original
   `p111_rt_take` checks, output order and `ctr_take` ownership transfer. A shared
   take returns no reusable cell; a static take must not yield writable storage.
   Both preserve an older private credit. A dynamic exclusive cell replaces the
   older credit, which is first returned shallowly to its original class. The
   old call's U64 count result is restored in a separate IR assignment.
2. `reuse_extend(state, parent, cid, prefix, count, credit, creditOut)` consumes a
   matching allocation-class credit or allocates normally. A mismatched credit
   remains available. Prefix fields and final hole are fully initialized before
   linking the new node into its predecessor. CID may differ from the consumed
   constructor: matching allocation class suffices because the new Term carries
   the new CID and all observable fields are rewritten.
3. `reuse_finish(state, root, parent, result, credit)` performs the existing
   destination completion and shallowly frees any unused credit before returning.

Raw and RFC count-one inputs both use the existing `ctr_take` result, rather than
guessing uniqueness from a tag or the old Term. `ctr_take` copies/moves children
before handing over their former cell. Shared inputs keep their original cell
and retain their children according to the original `span_fade` implementation.
Residual padding in a larger allocation class is not a constructor field.

## Correctness boundaries

The root/parent destination invariant is unchanged: incomplete nodes remain
private until terminal completion. Hidden metadata is absent from source
liveness inference. Therefore a retained credit cannot alias a published root,
pending parent, live child owner, shared constructor, or static storage. A credit
is not returned to the allocator until replacement/finish; ordinary nested calls
cannot allocate it. When reused it becomes a fully initialized new node and the
credit is cleared before any subsequent step can reuse it again.

Only the freshly derived private TRMC body is rewritten. Original generic
fallback segments, unrelated direct workers, and later borrowed observers retain
their original taking behavior. Ordinary scalar boolean diamonds are preserved.
Unexpected destination helpers inside scalar `N111If` cause conservative refusal
of the entire candidate; nested ordinary takes remain ordinary and free normally.
Structured `P113DIf` branches are traversed and every `Again` gains the current
credit. Source evaluations and runtime failures keep their existing order. There
is no new runtime failure-input campaign.

The unchanged trusted constructor-tail producer ensures every terminal path
passes through finish and every recursive step preserves the hidden protocol.
This projection is not an ownership proof for arbitrary reflected IR. Existing
parent verification still applies to the original generic program; candidate
verification additionally checks new helper signatures, assignment, argument
counts, constructor arity, prefix capacity, and the8-byte credit-out capacity.
The local prefix and credit-out names must differ. Existing direct-IR verification
forbids pointer aliases/offsets and alloca redeclarations, so fresh local storage
cannot alias the prefix buffer. Generated reserved names are outside source
binding names, and the usual direct inliner renames local storage on insertion.

Cold sealing is identical to the selected cold runtime: prefix policy uses the
new CID; parent-link policy uses the parent's CID through
`p118_destination_fill`. Shared/hot constructors continue to seal fields. Merely
reusing a cell does not justify omitting any reference-counting operation.

The original count is currently a verified literal (buffer contracts reject a
nonliteral count). Restoring it as U64 is therefore width-correct. The new helpers
remain ordinary calls in QBE; the Phase114 emission rewrite of old takes into
sized helpers does not rewrite these new symbols. No new machine template or
unverified native instruction is introduced.

## Qualification and falsification

`trmc-reuse-controls.bend` provides finite projection controls only. First check
the composed Bend API and candidate verifier, then confirm a private worker has
one extra initialized formal, a fresh credit-out alloca, rewritten take/extend/
finish calls, and exact backedge arity. Keep the original program verification.

Use existing ordinary fixtures for unique/shared/static input, live aliases,
packed one-field constructors, constructor arity changes, nested calls, argument
swaps, duplicate/non-scalar fields, base-only execution, skipped constructor
steps, and deep stack safety. `phase102/fusion/fixtures-v3/construction.bend` and
`phase102/trmc-cold/controls/mixed-construction.bend` cover most of these.
The existing refusal suite preserves nonfinal/two-child/SCC fallback. Full value
observations matter; checksums alone would miss some sharing/lifetime errors.

Measure list and text/map transfer against the exact allocation-only plus cold
candidate, with identical runtime flags and source. Inspect actual calls rather
than inferring reuse frequency from admission counts. A compiler-throughput
improvement and transfer to compiler self-compilation remain unmeasured until
separately tested. The separate register-transport certificate will conservatively
refuse these new symbols unless its reviewed whitelist is extended; do not bypass
that gate merely to combine experiments.

## Bounded constant-count ABI ablation

Root's first checked/focused reuse screen passed outputs but reported list about
197→210ms against allocation-only plus cold metadata; map/tree were essentially
flat and lexer changed only slightly. This is a negative first result, not proof
that reuse lacks value. One concrete confound is that replacing a previously
constant-sized owning take with generic `reuse_take` loses count specialization;
the seven-argument extend also places one argument on the x86-64 stack.

`sized-reuse-calls.bend` is a separate emission-only ablation. It overrides only
`p118q_sized` and delegates all prior constructor/take specialization to an exact
renamed copy. Verified literal takes1..4 become four-argument helpers; verified
prefix counts1..7 become six-argument extend helpers. The count is encoded in
the symbol and removed from the argument list. All other calls retain their
original ABI. Result names, remaining argument order, hidden credit, and the
credit-out buffer are unchanged. Original structured verification still precedes
the projection and checks the unmodified generic signatures/contracts.

Append `runtime-reuse-sized.c` after the generic reuse helpers. Its bounded macro
bodies are textually identical to the generic helper bodies after replacing the
constant macro parameter with `count` and ignoring whitespace/comments; a
source-only comparison confirmed that equality. Every runtime guard and ownership
effect is retained. Compile-time tautological count bounds may fold, while CID
arity, pointer, ownership and credit guards remain. The six finite controls in
`sized-reuse-controls.bend` test symbol/arity/credit-position projections and both
fallback boundaries. No target measurement was performed by this audit agent.

The decisive comparison is sized reuse versus the identical allocation-only
plus cold source/runtime. If restoring specialization does not produce a useful
transfer gain, retain reuse as rejected evidence instead of expanding its search
space or weakening guards.
