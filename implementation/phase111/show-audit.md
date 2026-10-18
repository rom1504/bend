# Structured pure-main display

[`segment/show.bend`](../../selfhost/tools/performance/phase111/segment/show.bend)
exports `p111_show(book, type, constructors) -> P111Show{words, names, error}`.
The segment bridge invokes it for pure main after selecting the same constructor
list used by the program descriptor. No compiler or native target was executed
by this implementation's author; coordinator receipts qualify the source.

The implementation ports the mature
[`native/show.bend`](../../selfhost/src/back/native/show.bend) worklist, field
telescope traversal, constructor arms and builtin decisions. `nc_show_find`
retains the mature normalized-type comparison. The former symbolic C cells are
replaced by `P111ShowWord`, `P111ShowRef` and `P111ShowCtor`. Breadth-first traversal
records each type node's numeric start offset. A final pass resolves type-index
references through those offsets and constructor identities through the actual
ordered `N_Constructor` list. Display names are raw
`name_key(nc_ctor_display(identity))` strings in that same order.

Neither `NC_Desc` string cells nor `NC_Show` declarations are consumed or parsed.
This is a typed descriptor producer, not a C-to-IR extraction pass. The runtime
keeps its original descriptor interpretation: tags 0/1/2 for U32/F32/Nat,
3 for Char, 4 for String, 5 for equality, 6 for Array, and 7 for datatypes.
Bool retains the inline two-arm encoding; ordinary datatypes use boxed
constructor IDs. Each field contributes its word offset and a type-descriptor
offset. Recursive and instantiated types share the same worklist lookup as the
mature implementation. List/tuple display remains a runtime decision using the
resolved constructor display names.

The existing refusals remain: erased fields, unsupported function/type/dependent
values, IO.OP as pure data, and the mature `i > 4096` type-graph guard. Additional
refusals catch numeric offset overflow and an unresolved typed reference or
constructor identity. This does not broaden the native representation model to
dependent layouts that the original display builder cannot print. Constructor
uniqueness and the runtime CID range are the enclosing descriptor's obligations.

Useful independent small oracles for coordinator checks are: Nat `[2]`, U32
`[0]`, F32 `[1]`, String `[4]`, and Char `[3,0]`. With constructor order
`[True,False]`, Bool is `[7,0,2,1,1,0,0,0,0]`. With only `[Nil,Con]` as the
constructor order, List<Nat> is
`[7,1,2,0,0,0,1,1,2,0,13,1,0,2]`: the Nat node starts at 13 and the list-tail
reference returns to offset 0. These distinguish constructor ordinal from
datatype arm ordinal and type index from descriptor offset. Wrong field
offsets, wrong constructor lookup order and replacing a recursive offset with
its type index should fail unchanged value-display observations.

This source review establishes the intended representation correspondence,
not a universal compiler or C readback theorem. Native observations must still
cover pure scalars, nested/user datatypes, recursive lists, Unicode strings,
arrays and refusal cases against unchanged expected output.
