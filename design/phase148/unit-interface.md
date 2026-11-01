# Initial private unit interface

This is an experiment protocol, not a public compiler ABI. All implementations
are Bend. Root owns interface changes and target execution.

The [native ownership correction](ownership-successor.md) supersedes the initial
borrowed-wrapper signatures below. The tape encoding remains unchanged; wrappers
are affine and internal consumers pass raw buffers explicitly.

```
P148Tape { words: Array<U32>, values: Array<U32>, names: Array<String>,
           used: U32, valueUsed: U32, nameUsed: U32 }
P148Unit = P148Good { name: String, params: List<NC_Binding>, result: U32,
                     public: Bool, tape: P148Tape }
         | P148Bad { error: String }
```

The name dictionary is cold ordinary String storage, intentionally not claimed
as four-byte packed storage. Words/values are contiguous scalar slots. Names
are exact interned spellings, shared across local/symbol/opcode namespaces but
interpreted by distinct tags. Reserve ID0=`state`, ID1=`scratch`, ID2=`xor`. Unknown local
references may receive dictionary IDs but are NOT thereby declared or assigned.

Every instruction starts at a word offset, eight words:

| offset | field |
| --- | --- |
|0| tag +256*type, type1=U32,2=U64,3=pointer |
|1| destination name ID, or direct-call target name ID |
|2| first value reference |
|3| second value reference |
|4| aux0 |
|5| aux1 |
|6| payload offset |
|7| next instruction offset, skipping nested branches/payload |

Tags1..9 correspond to scalar Set,Bin,Call,If,Return,Load,Store,Offset,Alloca.
Tag10=direct If,11=direct Call,12=Result,13=Again. Scalar instructions are
implicitly P113DScalar in a direct block; scalar If child blocks decode to N111.
No nested direct instruction may occur inside a scalar If.

- Bin: aux0 is opcode name ID.
- Call: aux0 is runtime symbol name ID, aux1 is argument count; payload stores
  `[type,valueRef]` pairs.
- If: first value is condition; aux0=yes-start, aux1=no-start, next=end;
  child blocks are `[yes-start,no-start)` and `[no-start,end)`.
- Load/Store: first value is base; Store second is value; aux0=byte offset.
- Offset: first=base,second=byte-count.
- Alloca: aux0=bytes,aux1=alignment.
- Direct Call: field1=target,aux0=destination count,aux1=argument count;
  payload stores destination name IDs then argument valueRefs.
- Result/Again: aux0=count,payload stores valueRefs.

Value references are offsets into a separate values array, three words each:
`[kind,lo,hi]`. Kind1=local(nameID),2=constant(lo,hi),3=symbol(nameID),
4=functionID(nameID),5=constructorID(nameID). A reference must be below valueUsed
with room for all three words. Numeric0 is an ordinary offset, not absence.

Encoding pre-counts storage and allocates bounded power-of-two arrays. It stores
actual used lengths; all multiplication/addition must remain within the explicit
admission limit. Reserve additional value capacity for scalar substitution;
the optimizer updates valueUsed and must never overwrite a shared original value.
Whole-function unsupported/refused units use the original path.

Optimizer-only tag14=splice: aux0/aux1 describe the selected block to decode in
place; next skips the original full conditional. Tag15=omit follows next without
emitting. This retains bounded storage when constant branches disappear. The
decoder removes splices/omits; schema collection sees only the selected output.
Original structured equality after decoding is the decisive transformation oracle.

Functions shared by implementations (core.bend):

- `p148w_get(+data: Array<U32>, at: U32) -> U32`
- `p148w_set(data: Array<U32>, at: U32, value: U32) -> Array<U32>`
- `p148w_new(words: U32) -> Array<U32>`; bounded callers only.
- `p148w_clone(data: Array<U32>) -> Array<U32> & Array<U32>`
- `p148n_get(+names: Array<String>, id: U32) -> String`
- `p148_pack(function: P113DFunction) -> P148Unit`
- `p148_unpack(unit: P148Unit) -> P113DFunction`; only P148Good is a valid input.

Scalar consumer: `p148o_function(unit: P148Unit) -> P148Unit`.
Admission consumer: `p148v_function(+unit: P148Unit,+ids: N111Ids,+ready: KDef)
-> String`.

The scalar consumer **destructively consumes** its input unit. No prior alias is
valid afterward: instruction/value storage has changed and only the returned
unit carries the matching updated lengths. Repack from the original structured
function for each independent experiment. Branch cloning copies scalar facts,
not the instruction tape. A future snapshot API would have to clone both mutable
arrays and their metadata explicitly; unrestricted field syntax is not such an
API. The dictionary is read-only after packing.

Independent original consumers remain `p113k_function` and `p147d_function` /
`p113e_function`. Do not decode between compact consumers. Keep mutable state
private, explicitly clone branch state, and preserve scalar epochs/predicate
provenance and all verifier diagnostic ordering. Field declarations use the
repository's normal `+`/quantity spelling; this prose does not override affinity.
