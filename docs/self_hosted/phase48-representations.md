# Phase48 private representations: candidate checkpoint

Phase48 is in progress. The likely RNFA candidate is frozen in
`selfhost/build/phase48/source-combined-rnfa02`; final combined gates and release
selection are pending. Phase47 array06 remains the installed baseline.
The [campaign checkpoint](../../implementation/phase48/README.md) preserves its
metrics and separates completed isolated outcomes from combined qualification.
This document explains source mechanisms, not an installed-release guarantee.

## One boundary contract, four contained extensions

The backend already proves typed first-order components, direct calls, private
layouts, loops and continuation fallback. Phase48 extends those mechanisms at
specific representation boundaries. It does not replace the runtime ABI or
waive mutable source/host observations. The original source G bindings,
code/arity/env/bound metadata, native identities and required host protocols
remain freshly checked. Refusal runs the original public path.

| Slice | Removed or enabled work | Proof and retained observation |
| --- | --- | --- |
| R: composite result | A complete private scalar-input graph can return a structural record containing canonical local arrays. | Exact constructor field telescope, scalar/Array fields and complete graph proof; transport original handles and construct the final public shell. |
| N: native String value | Canonical JWNative String.append emits primitive concatenation rather than generic native dispatch plus its argument vector. | Exactly two proved Strings and unchanged exact native identity/arity; left/right evaluation order, guards and generic fallback remain. |
| F: private finite F32 literal | An accepted typed-region literal writes its bits to the shared view, then uses an exact dyadic Number expression instead of reading/decoding it back. | The leaf stays F32 and requires full float host proof. The original write/demand site survives; exponent255 and ordinary/public literal paths retain decoding. |
| A: typed array effects | U32/F32 new/get/set/swap/size share canonical native/type/effect facts across handle and raw printers. | Exact erased kind, live arity and element-consistent telescope; ordered conversions, reads and writes; fresh complete graph ownership before raw representation. |

The [frozen composition](../../implementation/phase48/combined-rnfa-integration.md)
contains the reviewed R/N/F/A slices and two narrow F32 leaf audit admissions.
It excludes higher-order and aggregate-transport convention changes. No runtime
fragment changes are included.

## Public results and private arrays

Composite results transport the original Array handles rather than reconstruct
new wrappers over raw storage. The final public record shell retains its tag,
field order and prototype. Shared handles/backing storage, retained aliases and
post-return mutation remain observable. Host-injected shared values exercise
fallback; they do not acquire private ownership from a favorable shape.

Raw arrays still require fresh local construction, scalar public boundaries
and a complete admitted helper graph. No public host array is granted ownership.
F32 cells remain JavaScript Numbers: array stores introduce no new rounding;
source arithmetic retains Math.fround and checked conversions. Swap retains
two ordered index conversions and length reads, while size/set return the
original array identity. Exact host hooks matter before any observable input
or dependency read.

The shared array guard repair covers old U32 graphs too. A replaced allocator
hook can replace a helper after allocation; the old optimized path once bypassed
that replacement. The fresh array host guard now refuses before allocation and
retains the original error/trace. This is an executed correctness repair, not
equality to the incorrect historical optimized path.

Canonical literal array handles are a separate admission. They preserve lazy
backing realization and repeated nullary demand. The first acyclic Evening
adapter was correct but slower. The successor requires existing loop work,
so it keeps that acyclic source on its old route without a benchmark-name or
input-size rule. Literal handles do not establish raw backing escape permission.

## Observable operations must remain observable

Private String concatenation is safe only after the existing typed String
native proof and source/host admission. It preserves strings with supplementary
characters, lone surrogates and NULs; no public object coercion is newly admitted.
Mutated native code, getters, prototype/global hooks, raw/partial application,
Error and reentry remain independent refusal/fallback controls.

Finite literal specialization retains each shared DataView write even when the
Number value is statically known. A generic observer can have retained the view;
a detached buffer must still throw at the write. Only finite bit payloads use
the exact private expression. Infinities/NaNs remain decoded, and runtime F32
rounding/conversion operations are unchanged. This is not broad constant folding
of observable host operations.

Entry permission is not cached. The deferred allocation-free guard removed
some temporary guard vectors but showed no broad gain. Further host narrowing
cannot use only the optimized worker's footprint: the original generic
invocation/forcing machinery can observe concat/slice/iterator/Reflect hooks
which the private worker removes. Those original-path observations still
require their guards or an independently proved nonobservability argument.

## Evidence and limits

Isolated checks establish actual ordinary execution separately from marker
presence. Unicode16/64 execute 178/706 private concatenations and show
1.215×/1.520× gains in a three-round screen. Numeric256/1024 execute 769/3073
finite writes; the latter gains 1.081×. Generic row executes the composite path
and improves 12.586× in its short screen. These are different isolated images
and workloads; their gains cannot be multiplied into a combined result.

Private transport and fewer tuple constructors do not imply zero allocation.
Public shells, handles, strings, backing arrays and persistent data remain;
V8 may already eliminate some temporary objects or assign extra cost to wider
scalar frames. Higher-order fixture success currently has weak measured-corpus
coverage, and the aggregate convention's mixed screen does not justify including
it in RNFA. Keep those research outcomes separate from selected mechanisms.

Read [composite results](../../implementation/phase48/composite-results.md),
[native values](../../implementation/phase48/native-values.md),
[finite literals](../../implementation/phase48/private-f32-literals.md),
[typed effects](../../implementation/phase48/typed-array-effects.md),
[literal handles](../../implementation/phase48/literal-array-handles.md), and
[entry profitability](../../implementation/phase48/entry-profitability.md) for
exact inputs, control scopes, drift, adverse attempts and remaining decisions.
Final source/size/compiler-request costs and full-corpus measurements remain
separate release gates. Historical conformance and the checked B1 derivative
status do not become a new self-emitted fixed point from these transformations.
