# Finite primitive and special-representation interface

`primitives.inc.c` exposes the existing native primitive semantics through four
ordinary C-ABI entry points. It is included after the production runtime helpers
in the same translation unit. It does not parse generated C, lower Bend program
bodies, implement a second allocator, or decide which operations a program uses.
Those decisions remain in the Bend lowerer.

`catalogue.json` fixes all operation IDs and arities and pins the source inputs.
The first 69 operations correspond exactly to `ni_template` name/expression
pairs. These pairs were also compared with the selected Phase102 compiler source;
that source uses `p88_string_eq` for name comparisons, but all template names and
expressions are identical. Operation 70 is `nat_divmod`; 71–85 are the finite
array catalogue. Unknown IDs and incorrect argument counts fail before accessing
arguments. All calls initially remain conservative ordered effects in IR.

```c
uint64_t p111_rt_op(P111State *, uint32_t op,
                    const uint64_t *args, uint32_t count);
uint64_t p111_rt_special_ctor(P111State *, uint32_t kind,
                              const uint64_t *args, uint32_t count);
uint64_t p111_rt_special_test(P111State *, uint32_t kind, uint64_t term);
uint64_t p111_rt_special_take(P111State *, uint32_t kind, uint64_t term,
                              uint64_t *out, uint32_t count);
```

The caller owns scratch buffers and the helpers never retain their addresses.
`special_take` returns the number of fields transferred, equal to `count`.
The state supplies the original two-pointer `Env`; there is no by-value Env
cross-language ABI. `primitives.h` must follow the `P111State` declaration.

## Preserved scalar boundaries

- U32 arithmetic uses the original `U32_BIN` forms and unsigned 32-bit wrapping.
  Division by zero returns zero; modulus by zero returns its numerator. Variable
  shifts at least 32 return zero before C executes a shift.
- Nat remains the production immediate representation, bounded at `2^48-1`.
  Checked addition, doubling and multiplication retain runtime overflow
  fail-stop. Subtraction saturates at zero; dividing by zero yields the owned
  tuple `(0,numerator)`.
- U32/Nat comparisons return descriptor-bound `LT`, `EQ` or `GT` constructors,
  not the intermediate ordinal used by the scalar comparison expression.
- Bool operations preserve both immediate 0/1 and the existing tagged True
  compatibility check. Special False matching is the original negation of that
  check, not a new representation validator.
- F32 is the original low-32-bit payload. The helpers retain float unboxing,
  wrapping, comparisons, libm-to-float conversion, signed-zero/NaN behavior,
  text formatting and parsing. They do not replace Bend F32 with host doubles.
  Backend/compiler floating-point flags still need to match the runtime's
  established policy and be part of acquisition records.

The local `p111_native_bool` and `p111_native_word` have the exact algorithms from
`nc_helpers`; names are local to avoid collisions with generated helpers. U32/F32
constructor creation consumes a Word through `term_word`, while destructuring
constructs the original 32-node Word representation. These conversions have
allocation/ownership effects and are not bit casts at the source-language level.

## Arrays and special constructors

Array operations call `blk_new`, `native_array_get/set/swap`, `blk_copy`, and
`array_atomic`. Result pairs use a boxed Tuple with conservative `rfc_seal` on
its fields. This preserves the original array handle and the retained, copied,
replaced or scalar second result according to `nc_array_value`. `array_set`
returns the array itself after consuming the supplied replacement value.

Atomic IDs 77–85 map in order to the runtime's operation numbers 1–9: add, min,
max, and, or, xor, exchange, compare-exchange and floating add. Compare-exchange
takes four arguments; the others take three. Their synchronization and returned
old value are supplied by the unmodified production runtime helper.

Special constructor IDs are False=1, True=2, Zero=3, Succ=4, Chr=5, U32=6,
F32=7, ALeaf=8 and ANode=9. These are interface kind IDs, **not** the program's
constructor IDs. ALeaf extraction calls `blk_leaf` then `blk_free`, retaining a
shared leaf element before releasing its parent. ANode extraction computes the
low half first and the high half second; the high-half operation releases the
parent. Reversing these calls would violate lifetime semantics.

The runtime acquisition binds `NATIVE_SCALAR_ARRAYS` and
`NATIVE_UNSHARED_ARRAYS`. A new whole-program representation policy must get a
separate descriptor/cache identity; this adapter does not infer either policy.
Tuple and Bool/Cmp/Word constructor macros must bind the linked program's actual
descriptor. Generic boxed constructors, closures, scheduler transitions and
foreign effects are handled by the owning runtime adapter, outside this file.

## Qualification status

This implementation was prepared and audited as source only. No target build,
execution, timing or broad conformance result follows from this file. Integration
must test scalar edge values, tuple tags/ownership, array aliasing and atomic
results, both Word conversion directions, and special-constructor matching and
destruction. Source correspondence is not a whole-compiler correctness proof.
