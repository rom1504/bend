# Phase109 structured owned-Term lowering

This audit separates the semantic implementation from target qualification. The
root report records executed controls and timing; no performance result follows
from this source inspection alone.

## Boundary chosen

The new experimental Bend modules under
`selfhost/tools/performance/phase109/lower/` consume a `NativeErasedBody` fact from
the existing `nr_prepare_annotated` request. They do not parse C, repeat quantity
erasure, infer field counts from source spelling, or replace a function by name.
The host captures these existing private facts and binds them to the checked
source/API receipt. The `NativeErasedBody` tag alone is not authentication.

The mature backend remains authoritative for erasure:

- `erase.bend:nc_erase_app` removes an argument according to its checked telescope.
- `nc_erase_annotated` selects live constructor fields and qualified identities.
- `nc_erase_mat` records the number of live fields as `Mat.id = count + 1`.
- `request.bend:nr_walk` stores the erased body and live arity once.

The experimental lowerer requires this recorded match count to agree with an
explicit runtime constructor catalogue. The first adapter admits arities zero
and two; this limitation is checked rather than silently treating arbitrary data
as pairs. Constructor names come from the catalogue, not hardcoded reverse names.
The erased match also retains a word-field mask (`SCon` marks its character
field). This first lowering does not use that optimization fact: both fields are
opaque Terms and production runtime helpers handle trivial immediate values.
Consequently this slice establishes an ownership boundary, not complete
preservation or exploitation of every checked representation fact.

## Semantic representation

The structured operations are `Keep`, `Sink`, `Build`, `Take`, `Branch`, `Return`,
`Tail`, and fail-stop for the checked match's impossible `Efq` fallback. Bindings
are owned Terms, not integers or process addresses. A `Take`
consumes one constructor owner and produces its owned children. Nullary matching
also records `Take`, with no children; its final machine lowering is empty because
the fixed runtime ABI represents admitted nullary values as non-reference-counted
immediates. A `Build`
consumes its children and produces a new constructor owner. `Keep` updates the
original binding with the possibly changed redirect-bearing Term returned by
the runtime. A `Sink` consumes a dead owner.

This corresponds to existing native decisions, with a narrower surface:

| New operation | Existing semantic authority |
| --- | --- |
| `Sink` | `bridge.bend:nc_partition_step`, `nc_prepare_env` |
| `Keep` | `nc_keep_uses`, `nc_share_env` |
| `Take` | `nc_destructure`: `ctr_take`, then `spare_free` |
| `Build` | `emit.bend:ne_constructor`: child sealing and constructor allocation |
| `Branch` | checked constructor identity and `nc_match_apply_slow_to` |
| `Tail` | direct saturated self-call with ownership transferred to next arguments |

For the admitted first-order terminal expressions, exact variable occurrence
counts replace the general continuation live-set splitting: one keep is emitted
for each additional use, and unused incoming owners are sunk. Calls inside a
constructor value are refused, so this counting does not cross effects or hidden
continuations. Matching consumes its scrutinee; a later attempt to reference that
consumed binding refuses. This deliberately does not yet implement a retained
scrutinee alias inside the matching body.

The final Nx representation uses physical U64 words for Terms and a distinct Ptr
for the opaque runtime context. It only receives explicit imported ownership
calls. No raw heap load/store, pointer conversion, allocation forwarding, or
closed-world inlining is applied to those Terms. The separate NxLibrary verifier
does not pretend that its structural/type checks prove ownership correctness.
An independent structured ownership verifier runs before Nx lowering, with
path-local ownership credits and constructor facts. Candidate construction is
inside the successful verification branch, so failed ownership admission cannot
construct calls to the unchecked ABI. Executed mutation controls belong in the
root report.

## Control and runtime calls

`Lam`/`Mat` application binds incoming arguments and extracted fields. A saturated
self-tail call evaluates every next argument before changing any parameter. It
then performs a parallel move through dedicated locals and returns to an
explicit `while` header. Native stack use is independent of list depth.

The runtime adapter's two-slot scratch transfer replaces a C stack array for
`Take`: both fields are acquired exactly once before any subsequent take. No
field needs a separate heap allocation. The adapter retains actual production
allocation, reference counts, `rfc_seal`, `ctr_take`, and shell reclamation.

There is an important baseline qualification: the production C backend already
lowers `nt_reverse` to an optimized direct worker with an `nf_again`/`goto` loop.
Consequently this experiment cannot claim to remove one scheduler transition per
list cell relative to that production worker. It tests structured information
preservation, reusable runtime imports, code acquisition, and the overhead of
that ABI. A faster result would need to be attributed using matched code.

## Scope and refusals

Intended source witnesses are the unchanged compiler `nt_reverse`, instantiated
on `List<String>`, and unchanged Base `String.reverse.go`. Both are generic
constructor/match computations with saturated self-tail calls. The actual
source and checked-erasure captures, not a hand-constructed reverse AST, must be
used in qualification.

Four separate derived source controls discard or duplicate a list/string head.
They exercise generated `Sink` and `Keep` insertion, including immediate character
fields, which neither unchanged reverse body needs internally. Their oracles are
frozen separately from the unchanged source witnesses.

The entry takes one to eight live owned-Term parameters. Foreign calls, dynamic
application, partial application, non-tail calls, closures, arrays, IO, primitive
arithmetic, general lets and unsupported constructor representations refuse.
This is not full compiler self-hosting or a replacement for the general Nx
frontend. No production compiler or runtime source is changed.

## Extension seam

`NxoOp` deliberately survives before runtime-call lowering. Future experiments
can fuse a proven `Take`/`Build` pair, choose a unique/shared implementation, or
retain a scalar representation without reverse-engineering Nx machine words or
C strings. Such transformations still require ownership laws and held-out data
layouts. The first implementation uses conservative runtime imports to establish
that seam, not to assert that imported helper calls are already optimal.

## Explicit trusted and fused candidates

After the raw comparison exposed substantial runtime ABI overhead, two optional
policies were added. `nxo_lower` remains the raw entry. The additional
`nxo_lower_policy(..., policy)` accepts exactly `raw`, `trusted`, or `fused`;
unknown policies refuse. All retain the original structured ownership graph.

`trusted` selects private runtime imports whose boundary checks have been
established by checked-source admission and the owned-IR verifier. The public
checked adapter remains unchanged. It also reuses a constructor discriminant in
an immediately nested fallback match on the same word. Every intervening
non-branch operation invalidates that cached fact. Thus a keep, take, allocation,
or unrelated call cannot accidentally leave a stale tag. This reuse is generic
control-flow knowledge, independent of list or reverse names.

`fused` additionally recognizes this exact verified sequence:

```
Take(parent) -> [a,b]
Build(cid, [a,other]) -> dest
Tail([b,dest])
```

The symmetric choice of `b` as retained child and the permutation of the two tail
arguments are also admitted. The other constructor child must be external to
both extracted fields and the parent. The destination cannot alias the parent,
children, or external owner. No intervening keep, observer, or other operation is
allowed, and the two-argument tail is the end of the block. These conservative
conditions ensure the retained child does not escape, the remaining child has
exactly one subsequent consumer, and no omitted field read was needed elsewhere.

The candidate emits one `rt_rebuild2` call followed immediately by one scratch
field transfer. The runtime can reuse the consumed shell when production
`ctr_take` yields reusable dynamic storage, while shared/static cases retain the
production ownership behavior. This eliminates the free-list roundtrip and
several C-ABI calls together; it does not invent a new collector or data layout.
Both fields retain their original ownership meaning, and constructor children
are conservatively sealed. The optimization is guarded by semantic operations
and ownership validation, rather than recognizing a function or C string.

`policy-controls.bend` contains 19 local admission/emission controls covering
both retained-child positions, argument permutation, forbidden aliases,
intervening operations, discriminant invalidation, and emitted call shape. These
controls supplement actual generated-program lifetime/oracle gates. Source
implementation and independent review alone are not measured speed gains; the
root report records candidate qualification and timing.
