# Native ownership and scalar facts

The C backend remains a compiler written in Bend. These analyses reuse the
checked annotated book, existing native ownership operations and `N_WordKind`.
They do not replace the runtime representation, scheduler or JS backend.
[Phase73 design](../../design/phase73/native-parity.md) and
[report](../../implementation/phase73/README.md) distinguish experiments from
installed, measured compiler versions.

## Share only where a value can actually be shared

`native/sharing.bend` inspects reachable checked definitions. A runtime variable
used more than once heats its annotated type and its transitive live fields.
Branch alternatives use the maximum occurrence count, while sequential uses
add. Type visitation records the complete instantiated type: `List<U32>` and
`List<Chain>` must not share one incomplete certificate. Primitive immediate
values need no heap-sharing metadata. Erased fields do not participate.

Unknown/open/dependent layouts, malformed telescopes or exhausted analysis
budgets produce a global refusal. The existing checked/effect permission is
required. For a constructor whose type cannot be shared, C emission omits the
otherwise conservative `rfc_seal` calls on its fields. Ownership transfers,
allocation, dropping and error checks remain. This also covers Base constructors,
using their validated identity rather than user-controlled spelling.

The analysis reads the existing request-local prepared native bodies for
occurrence counts and original checked annotations for types. It does not erase
the same definition again or maintain a second body cache.

## Borrow a shared recursive root

The existing bounded observer analysis also admits scalar-result tail traversals.
An ordinary private worker tests whether **any** recursive root is shared. It
then uses a borrowed traversal and releases its owned roots once on completion.
Unique roots keep the ordinary consuming loop. The guard repeats at every loop
backedge: a unique prefix may lead to an independently shared tail.

A stronger constructor certificate can leave the recursive children unsealed
when every destructive consumer takes this borrowed route while shared. This
requires every reachable matching consumer to be a registered observer, with no
ordinary/product-worker bypass. Each use must be an exactly saturated, non-bang
named call; an escaping partial application refuses the certificate because its
closure body could bypass the guarded entry. Unsupported helpers, mutation or
foreign effects retain the conservative path. The stronger certificate currently
covers only unindexed, zero-parameter user recursive datatypes accepted by the
observer schema. Raw/device compilation and a globally refused sharing analysis
cannot enable it.

Tests include escaped consumers, reconstruction, independently shared tails,
mixed shared/unique roots, nested containers, captured values, deep inputs and
parallel users. Source-shape checks verify that both accepted and refused routes
are actually exercised; checksums alone could pass through a fallback.

## Preserve scalar facts through suspension

`NC_Binding` carries the existing `N_WordKind` alongside its ownership identifier
and C word. Known U32/F32/Char/Bool arguments acquire their fact from the original
checked telescope. Variable aliases, environment filtering and continuation
parameters retain it. Compiler-owned 32-bit literals supply the same fact;
unknown results stay opaque. `layout.bend` owns these small propagation helpers.
This replaces the later pass that reconstructed argument widths after lowering.

Match erasure already specializes the constructor telescope to find live field
arity. It also records an eight-field scalar mask in the native-only `Mat.qty`
slot. The checker never sees this erased metadata. Erased fields do not advance
the live index, and unknown/dependent fields remain opaque. Both monomorphic
constructor macros and per-use capture kinds consume the same mask computation.
Thus a generic field's fact can survive a scheduler continuation. Monomorphic
product arguments/results also retain the established field-width facts.

Only checked CPU permission enables narrowing; raw/device loads keep full Terms.
No assumption is made that a general Nat fits32 bits. Overflow/error checks,
field ownership and the boxed scheduler ABI remain in place. Ordinary non-tail
recursion continues through the explicit scheduler; forcing C recursion was
measured and rejected.

## Extending this safely

Keep constructor identity/provenance, complete type instantiations and the
foreign-effect boundary explicit. Any new route that destructures a certified
recursive type must either preserve the borrowing invariant or invalidate the
certificate. Any extension to scalar facts must prove the represented value's
width, including erased/dependent fields and raw fallback.

Use the [Phase73 methods](../../selfhost/tools/performance/phase73/README.md)
for short, hash-pinned generated-code experiments and scoped runtime checks.
Measure compilation separately, preserve failed attempts, then run native/raw,
threaded, JS-closure and self-hosting gates before installing a new image.
