# Typed scalar parameters for private native workers

[Hypothesis P69-008](../../experiments/phase69/P69-008-typed-native-worker-parameters.md)
registers the saved-C discriminator. This design does not authorize raw casts or
replace product unboxing; it reuses source layout facts at a complementary C
boundary.

## Observed gap

Compiler23's hot tree `warp_leaf` and `warp_leaf.go` accept their U32 operands
and Bool direction as generic 64-bit Terms. The former calls `term_keep` on both
scalar operands before comparing them. The latter tests whether every Leaf
payload fits the immediate representation and retains a heap-construction
fallback. Upstream's corresponding private workers accept `u32` arguments.
Its C optimizer can see that a scalar is trivial and always fits.

The problem appears beyond tree. Lexer ordinary and `$product` workers emit
all arguments of `step.at(m:Mode,k:Cls,c:U32,acc:U32)` and
`step(m:Mode,c:U32,acc:U32)` as Term. Map does the same for both Char arguments
to `Char.cmp`, the first two of `String.cmp.rec`, the first of `Map.bit.go.rec`,
and the Char argument of `Map.bit.chr`. Width facts can remove field seal checks,
keep/drop checks and immediate-packing fallback where those bodies propagate
the scalar values. No cross-family timing gain is asserted yet.

## Small integration shape

Keep `NC_Binding` and the scheduler's uniform Term ABI unchanged initially.
Store `NF_Worker.params` as the existing `List<N_Param>` (name and word kind)
instead of `List<NC_Binding>`. The latter remains local to worker lowering, where
its binder IDs matter. After lowering, the stored parameters are used only to
render prototypes/bodies and count adapter arity, so reusing `N_Param` avoids
adding another field or changing nine pattern arities. Query an ordinary worker's
actual original checked type telescope once when creating the worker. Use the existing bounded `nq_layout_type` resolver, skip quantity-zero
binders, and require alignment with its actual runtime parameter count. A failed
or dependent/unknown query supplies generic Term slots; it must not evaluate
arbitrary type computation or partially misalign the remaining arguments.

Recognize trusted Base ADTs U32, F32, Char and Bool only. Verify the ADT definition
and its provenance, not merely the spelling of a type reference. F32 uses its
32-bit payload bits, not a numeric conversion to C float. Base Bool emission is
canonical immediate 0/1. Nat remains a 64-bit Term; user enums and Mode remain
Terms because their immediate tag/constructor identity occupies high bits.

Emit the private parameter type as `NF_SCALAR`, defined as:

```c
#if NATIVE_TYPED_SCALARS
#define NF_SCALAR u32
#else
#define NF_SCALAR Term
#endif
```

Only `nc_compile_checked` sets `NATIVE_TYPED_SCALARS`. A conservative first gate
can reuse its existing `packed` certificate: checked specialized annotated book,
known scalar representation demands and supported effect/foreign ABI. This is
independent of the no-sharing certificate: duplicating scalar values is safe,
so a program sharing user constructors need not inherently disqualify scalar
parameter layouts. The raw `nc_compile` path never defines the permission.
Thus forged or misleading raw type annotations do not change high-bit behavior.

Prototypes and definitions consume the same stored kind list. Calls need no new
helper; C applies the scalar conversion at the private checked entry. Generic
scheduler register words and raw dispatch remain unchanged. Compiler optimization
then propagates the range through existing keeps, arithmetic and constructors.
Do not hand-delete ownership/error operations based on textual variable names.

For product workers, original input shape order already maps source parameters
to flattened private slots. Carry a scalar kind for nonflattened inputs through
that same alignment. Initially leave every flattened product field as Term;
precise nested field kinds can share the eventual native-layout metadata. A
source proof about an entire argument must never be assigned to one arbitrary
field of its flattened representation.

Expected source cost: roughly 40–65 Bend lines in about three modules, plus
changing the stored parameter type, renderer and adapter counts. No new worker
field, pattern arity or runtime module is required. Keep
source/type queries out of per-call lowering and reuse their result for worker
prototype and body emission. Measure B1 request overhead as part of selection.

## Discriminator and boundaries

`selfhost/tools/performance/phase69/node-reuse/prepare-typed.py` prepares exact
saved-C variants from the previously pinned cold tree source:

- U32 operands narrowed in both leaf helpers;
- additionally narrow the canonical Bool argument;
- both scalar changes on the previously tested cold+reuse source.

Only declaration/definition types change; bodies, callers, polling, branches,
runtime helpers and scheduler boundaries remain exact. Reverse replay recovers
each parent. Root chooses a small balanced role set before running it. The
Boolean arm distinguishes a true scalar-width benefit from a broader accidental
change. A finite checked benchmark does not prove the admission rule.

Required controls include U32 near 2^32, nontrivial F32 bit patterns/NaN payload,
Char boundary values, canonical Bool, Nat above 2^32 (must remain Term), a user
enum (must remain Term), aliases that resolve or conservatively fail, quantity-zero
parameters, a dependent later parameter, product-input expansion, unknown foreign
signatures, and raw wrong-type/high-bit arguments that preserve old behavior.
Check prototypes against definitions, all call sites, generated JS protection,
selected native conformance and compiler latency. If direct signatures only move
work into an adapter or produce no measured benefit, retain the diagnostic as
negative evidence and prioritize another slice.
