# Private product result islands in the existing native backend

This is the implementation decision note for
[P69-007](../../../../../experiments/phase69/P69-007-multiword-scheduler-products.md).
It proposes a general compiler slice; the saved-C diagnostic is a discriminator,
not a production source-text rewrite. Root-owned results belong in the phase
report, and no compiler patch has been applied by this lane.

## New source finding

Compiler23 already emits admitted two-word workers for `Map.bit.chr`,
`Map.bit.go.chr` and `Map.bit.go.rec`. Each has exactly two name occurrences:
prototype and definition. There are no call sites. Their ordinary one-word
workers are reached through scheduler adapters instead.

The private workers already preserve field ownership, product demand, scalar
checks and polling. The missing part is retaining their product result through
the actual caller/continuation. Upstream has a two-word `Map.bit.go` recursive
entry, a two-word recursive reconstruction continuation, and direct calls to
its product helpers. It still traverses, consumes and reconstructs String nodes;
it does not implement a read-only borrowed String cursor for this function.

This is stronger than changing an allocator helper or deleting a single outer
Tuple. The diagnostic removes recursive product transport *and* the extra
helper adapter/return segments at the same boundary. It deliberately preserves
String construction and seals inside String fields, so it does not credit an
unproved borrowing or immutable-update elimination.

## Keep the existing IR and make one earlier plan

The native IR already provides the necessary ABI substrate:

- `N_Segment.result` records the number of incoming continuation result words.
- `N_Param` and `N_Frame` distinguish captured stack words from result registers.
- `ne_ret(words)` emits the matching `WL_RETN(width)`.
- `nb_returns`, `nb_bank`, result tables and register save/restore already derive
  their maximum widths from the segments.
- `N_Segment.host` emits a `#if !DEVICE` body.
- `NQShape`, `NQBundle` and admitted `NF_Worker`s describe the fixed-shell values
  and already-evaluated field words.

There is no need for a second low-level IR or a runtime ABI replacement. The
principal change is to compute an explicit validated native plan **before**
scheduler lowering, then let both scheduler and worker lowering use it. Today
`nf_finish_show` computes the worker admission plan after scheduler bodies and
continuations have already committed to one-word results.

Extract a small `NF_Plan` holding the workers, admitted names and filtered
signatures. Computing it does not require emitted scheduler segments. Reuse it
at final declaration/adapter emission instead of recomputing it. The plan must
be explicit lowering context, not user-forgeable `KDef` source annotations.

## Bounded initial representation contract

Start with a single-constructor result of at most eight one-word fields, using
the existing bounded `nq_layout` query. **Keep all generic entry parameters
boxed.** Result unboxing alone avoids the parameter-demand/parent-drop problem
which made the lexer loop extension more complicated.

The source annotation proposes a layout; complete lowering proves it. Every
successful return must construct that exact shell, transfer a bundle with that
shape, or call another admitted private result entry with the same contract.
A scalar/opaque/mismatched return refuses the optimization, including malformed
raw annotated definitions. Recursive components need a closed contract check:
all assumed edges must remain within a successfully lowered candidate set, and
failures must propagate to every dependent route before emission.

Scheduler recursion remains on the existing scheduler stack. Do not admit
arbitrary ordinary C recursion merely because a result has a product shape.
Initial private routes decline foreign, bang, dynamic-call and parallel-let
boundaries. The generic route remains available for them.

## Concrete lowering hooks

1. Add an explicit scheduler destination carrying desired result shape and the
   validated plan, alongside the existing ordinary local destination. Keep a
   default ordinary scheduler destination for old/raw callers.
2. Teach `nq_transfer` to emit `ne_ret(fields)` for a matching private scheduler
   result. A generic one-word destination retains boxing. A mismatched private
   result fails candidate admission rather than coercing arbitrary data.
3. Generalize `nc_let_cut` so a known product producer creates a continuation
   whose incoming fields are represented by `NQBundle`. Retain held values in
   their original order, put only those values in `N_Frame.slots`, and set
   `N_Segment.result` to the product width. Its full arity is captured words
   plus result words; the task result insertion index is the captured count.
4. Permit constructor-proven `nq_match_local` bundle consumption in this
   scheduler context. This reuses its exact field binding order and avoids a
   boxed matcher. A repeated, escaping or opaque use reboxes through the
   existing fallback; initially refuse any case whose drop/share contract is
   not established by existing single-use checks.
5. At a scheduler call site, use the already-admitted product worker when its
   argument bundles fit; call it locally with an output array and continue with
   the result words. Otherwise jump to a private product scheduler entry or
   keep the generic path. Local helper calls preserve their existing polls.
6. Emit a boxed generic adapter where a raw/closure/public entry needs one
   result word. The private body retains all original boxed-parameter matching
   and error paths. At successful exit only, the adapter boxes the proven
   result fields. If entry wrapping risks a broad behavior change initially,
   limit private entry selection to known local producer/consumer sites.

The target context must be propagated through let/call/match lowering rather
than silently replaced with `NC_Scheduler{}`. This is the main implementation
audit. It is preferable to a late pass that parses or rewrites
`N_Segment.body: String` after the ownership and continuation decisions are gone.

## ABI and fallback requirements

Every segment must bind incoming registers **before** `WL_OPEN`, because the
host macro shadows them with a new register bank. The first saved-C attempt
omitted this in its generic wrapper and failed the first output oracle with
`ERR_FIDS`. The failure and v1 producer are preserved. V2 binds all three input
words before `WL_OPEN` and restores them before the private jump; this was found
by independent review, not treated as a production compiler defect.

For a two-result continuation retaining one captured word, arity is three,
result-width metadata is two, and `N_Frame.pop` is one. A boundary-box
continuation with no captured words has arity two and result width two. Its
outgoing `WL_RETN(1)` is distinct from those incoming result words. The saved-C
producer explicitly updates these tables and `WL_RESW`/`WL_SAVE`/`WL_TAKE`; a
general compiler implementation should obtain them from the existing IR.

Private segments and worker calls are host-only. The ordinary emitted device
body remains a fallback and must never jump to a host-only private ID. Do not
claim CUDA/Metal conformance from CPU one/four-thread controls. Global register
width/layout changes must remain internally consistent even when only the host
uses the wider route.

Keep `err_seen` sequence points between already-evaluated arguments, existing
worker entry polling and scheduler task error behavior. Changing dispatcher
frequency inherently changes where work occurs between polls, so the first
implementation should avoid an additional tail-loop fusion while qualifying
the result ABI. This keeps return layout and scheduler control changes separable.

## Useful controls and scope

Run an unrelated recursive producer returning a named record to a consuming
continuation; a recursive product with an owned Array field; alternating return
branches; shared fields; an ignored whole result; an escaping result; mismatched
raw annotations; competing errors; foreign fallback; actual parallel call; and
one/four-thread controls. Verify the generated private edge/width rather than
accepting output-only tests of an inactive optimizer. Preserve existing raw
unused-product and parent-drop controls unchanged.

A bounded initial implementation likely touches `flat.bend` (plan),
`product.bend` (private destination and transfer), `bridge.bend` (continuation
width and context threading), `direct.bend` (call choice), and `book.bend`
(planning/emission order). Existing runtime, tables and segment emitter should
mostly work unchanged once supplied truthful metadata. Estimate 6–12 hours for
the first general recursive-result slice and focused debugging, with substantial
uncertainty; nested products and general sums are later extensions.

One further idea has larger potential than layout parity: recognize a recursive
reconstruction whose returned data is unchanged, retain the original owned root
and traverse through a borrowed cursor while computing only the scalar result.
`Map.bit.go` is such a source-level witness on valid Strings. Upstream still
rebuilds this prefix, so a general identity-return/borrowing analysis could beat
it. This needs proof of structural identity, root lifetime, raw fallback, demand
and alias behavior; it is not permission to substitute a Map-specific algorithm.
It has not been implemented or measured by this lane.
