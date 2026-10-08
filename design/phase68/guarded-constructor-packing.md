# Exact-payload packing for ordinary one-field constructors

[P68-011](../../experiments/phase68/P68-011-guarded-constructor-packing.md)
is an isolated proposal. The compiler patch is
[constructor-packing/v5/candidate.patch](../../selfhost/tools/performance/phase68/constructor-packing/v5/candidate.patch),
with frozen before/after sources and identities in its adjacent manifest.
Production source is unchanged by this lane. No correctness or speed result is
claimed here.

The native runtime already has two ordinary constructor representations:
`term_ctr(cid, location)` points at fields, while `term_pak(cid, payload)` embeds
one field. Its `LOC_MASK` is exactly `(1ull << 40) - 1`. A field wholly inside
that mask has tag zero and no reference-count flag. `rfc_seal` leaves it alone,
and `term_keep`/`term_sink` need no heap work. Therefore the guarded branch can
carry this field exactly, without assuming its source type or narrowing it to
U32. All wider words retain their old node, sealing and ownership behavior.

The emitter evaluates the existing field expression once into a `Term`, then
sets one result variable to either representation. All original argument
evaluation precedes this step. Zero-field and multi-field constructors,
closures, native scalar encodings, primitive error checks and explicit
`packed=true` calls retain their old path. Avoiding an allocation naturally
changes resource exhaustion thresholds; it does not authorize moving source
effects or arithmetic errors.

Generated ordinary one-field matches in `bridge.bend::nc_destructure` already
read `term_loc` for `TAG_PAK`, before any heap operation. `runtime.c::show_val`
does the same while retaining the existing constructor identifier, descriptor
and field type. Sharing/dropping the packed constructor is safe because its
only field is trivial. Wider nested constructors and pointer-bearing fields
take the old path. There is no runtime or descriptor change.

## Conservative foreign and raw-effect boundary

Only constructor identities encoded by `nc_ctor_encode` (`$ctor.`) qualify.
Base-owned constructor identities and foreign effect definitions are outside
that encoding. This protects runtime helpers which consume Base/effect objects:
`ctr_take` itself assumes a heap node; `io_exec` calls it, and `io_step` reads
request fields through `term_peek`. A malformed raw immediate continuation must
not enter a new packed IO request path. This is a constructor ownership/encoding
rule, not a list of workload names.

A second fence disables the optimization when the whole input book contains
any non-Base `Foreign` value or unfilled (`Absent`) function declaration. The
latter requires definition kind `Def`, preserving ordinary ADT/Ctr absent
metadata. The scan includes definition children so cached
index representations cannot hide such a definition. The constant permission
is emitted before the C runtime. Lower-level emitters which do not pass through
final book assembly default to the boxed branch (`#if` on an undefined macro
is false). An unreachable imported foreign definition also disables packing;
that conservative loss of opportunity is intentional for this first slice.

Foreign C uses concrete runtime terms; `guide/EFFECTS.md` documents scalar,
String, handle and constructor helper representations. Existing tests such as
`tests/io/foreign_types.c` and `far_types.c` explicitly return packed U32 leaves.
Other C can inspect a custom object using `term_peek` and raw field reads.
Upstream packs a statically proved single `w32` field, whereas this proposal can
also pack a fitting Nat/Bool/unknown field. We therefore claim no new general
foreign layout ABI. A declared user-foreign program keeps its previous selfhost
representation. Arbitrary injected C outside the book's foreign declarations
is outside that provenance fence and cannot inherit a layout guarantee.

## Frozen diagnostic and remaining gates

The saved-C diagnostic uses exact Flat06 tree/lexer acquisitions, independently
of the pending compiler patch. Its generic encoded-constructor rule changes
21 tree allocation sites and 12 lexer sites. Common Base `Some` and IO request
sites remain unchanged. Site counts include all emitted paths and are not
dynamic allocation counts or hot-time fractions.

`packing-c-diagnostic01/plan.json` binds every original receipt, the selected
Flat06 snapshot manifest, exact before/after C snippets, diagnostic sources,
Clang commands, plan02 protocol and independent full output oracles. The
root-only runner uses one existing execution guard, two Clang builds, two smoke
runs, and three alternating baseline/candidate rounds per case. Every runtime
observation checks its child-process clock and reports whether it reaches
100 ms. Unqualified short samples remain visible.

Before compiler integration, require independent source review and focused
boundaries: field zero, maximum 40-bit payload, first rejected payload, full
64-bit raw values, pointer/reference-count words, mixed small/large Nat wrappers,
shared/drop/readback cases, recursive nested wrappers, custom foreign producers
and consumers, and raw effect/error precedence. Keep products, worker admission
and inlining fixed in a paired comparison. Genuine B2 and final frontend/JS
qualification remain later root-selected gates; no GPU result is transferred.
