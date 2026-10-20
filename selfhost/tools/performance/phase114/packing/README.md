# Guarded ordinary unary packing

Source-only candidate; Take2 and all prior compiler/runtime bytes remain frozen.
Root runs the checked API and ordinary compiler/native gates. Append
`original.bend`, `model.bend`, then apply `entry.bend` as the sole override of
`p111_constructor`. The baseline is candidate31. Existing array/direct/native
pipeline APIs stay unchanged. Optional inspection exports are
`p114p_ordinary` and `p114p_constructor`.

The shared constructor lowering covers both generic segments and complete
private functions. Only exact checked ordinary user identities encoded by
`nc_ctor_identity` as `$ctor.*`, with exactly one already-evaluated field, enter
the candidate. Builtin, Base and effect constructor identities and every other
arity retain the original lowering. The fallback alias is byte-equivalent to
candidate31's original declaration after renaming.

The candidate snapshots the entire U64 payload, stores it to the original
scratch position, and tests `payload <= 0xffffffffff`. A fitting value has
zero top24 bits: no owning tag, RFC bit or upper payload bits are discarded.
The result is `(1 << 56) | (CID << 40) | payload`, retaining `N111CtorId` until
descriptor-aware rendering. Otherwise the exact ordinary `p111_rt_ctor` call
runs with one field. Both arms are ordinary structured N111 IR and pass the
unchanged verifier. The fallback call retains the exact descriptor-arity check
in `p111v_counted_call`; initial verification precedes subsequent simplification.
Temporary locals are produced by this source lowering; the checked factory's
source variables use its existing generated ID namespace, and inlining applies
its existing local renaming. This is not a claim about arbitrary forged source
IR.

This is the same representation condition used by mature `ne_single` in
`selfhost/src/back/native/emit.bend`. It changes representation only for a
constructor whose sole child has no owning heap credit. Sharing/dropping the
packed parent therefore requires no heap reference count. Unknown/non-fitting
fields, including ordinary owning String/List values, keep their original box.
No allocator policy or runtime helper changes.

The unchanged frozen runtime already implements the necessary consumers:

- `p111_rt_take` validates CID/arity and extracts `term_loc` for count1+PAK
  (runtime-products01/runtime.c:3900).
- `p111_rt_tag` returns the same CID from `term_aux` (3887).
- `term_triv`, `term_keep`, `term_drop` and `term_sink` treat PAK as immediate
  (845,882,925,1011); no ownership credit is omitted because the guard excludes
  every owning representation in the payload.
- `rfc_seal` only wraps raw CTR, so storing a packed leaf needs no wrapper (859).
  Shared-parent `span_fade` accepts the trivial PAK child unchanged (1017).
- Boxed ADT readback uses a local payload word when tag is PAK, preserving the
  constructor identity and field descriptor (show_val at2883).
- Arrays/closures/continuations carry the full word through the existing keep,
  sink, store and load protocols. No untyped truncation is introduced.

Static constructors remain in their original representation and can coexist
with packed dynamic values. The private Take2 template selects arity2 and cannot
misinterpret these unary values. Specialized builtin/string/effect layouts are
excluded by identity, so direct runtime field peeks for those layouts remain
unchanged. Root's independent ordinary packing controls cover scalar identities,
low40 boundaries, larger Nat fallback, nested/shared containers and owning
fields. Their complete output is semantic evidence; source/IR inspection must
separately establish that packing was actually selected.

After root's checked API succeeds, `admit.py --compiler ... --api-report ...
--runtime-source selfhost/build/phase113/runtime-products01/runtime.c
--runtime-object selfhost/build/phase113/runtime-products-build01/runtime.o
--out selfhost/build/phase114/FRESH_ADMISSION` authenticates the exact full
candidate31+packing declaration set, runtime source/object, original baseline
admission, mature references and API receipt. Source-only mutation refusals are
not executable failure probes. Combined profiles need a distinct conjunctive
admission; this receipt cannot be transferred to another compiler.

The motivating source evidence is in `../runtime/results01.md`: upstream
expression/tree leaves use PAK while current QBE allocates a unary leaf and may
then allocate an RFC wrapper when inserting it into a parent. Removing those
allocations is a falsifiable hypothesis, not an inferred speedup. List pipeline
is a useful scope control because its main list nodes have two fields.
