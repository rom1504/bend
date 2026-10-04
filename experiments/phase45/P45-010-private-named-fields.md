# P45-010 — One object for private tagged values

- Owner: Phase44 IR agent; checked builds and measurements: root.
- Correctness: source patch prepared; independent semantic static review passed.
- Measurement: not run. No speedup or promotion is claimed.
- Decision: investigate as an isolated change on worker05, before combining it
  with the worker06 budget or worker07 nullary-entry changes.

## Hypothesis and opportunity

The complete first-order worker graph still emits ordinary tagged constructors
as `ctor(tag, [fields...])`. That creates a field array and a wrapper object;
projections then read `value.a[index]`. A closed private graph can use one object
with named fields and preserve its scalar/String public boundary.

The proposed operation-level rule applies to every admitted tagged ADT. It has
no source-function, benchmark, constructor-family or size selector. Native Bool,
Nat, String, Char and Tuple representations remain unchanged.

Read-only inspection of
`selfhost/build/phase45/preparation-worker06/manifest.json` and its generated
modules found the following static sites in the direct worker functions. Loop
fallback copies are excluded from these counts, although the shared emitter
changes those copies too.

| Source | Non-nullary tagged constructors | Nullary tagged constructors | Tagged field reads | Native Tuple constructors |
| --- | ---: | ---: | ---: | ---: |
| Map churn | 220 | 70 | 120 | 67 |
| Record aggregation | 228 | 69 | 123 | 66 |

Map's non-nullary sites are MNode 136, MLeaf 75, Some 8 and Con 1. Records has
MNode 142, MLeaf 76, Some 8 and Con 2. These are static opportunities, not executed
allocation counts. Each changed construction removes one allocation and each
field read removes one indirection. Neither fact establishes a program speedup.

## Representation and boundary proof

```js
// Previous private representation.
const value = ctor("Node", [left, item, right]);
const field = value.a[1];

// Candidate private representation.
const value = {$: "Node", _0: left, _1: item, _2: right};
const field = value._1;
```

The existing `value.$ === tag` case test stays unchanged. A fresh object is
allocated at the same instruction; constructors are not interned. The lowering
already evaluates fields into stable values in source order before construction.
This patch does not move evaluation, alter field demand or change worker stack
handling.

Named fields are preferable to a `[tag, ...fields]` vector for this first slice:
the existing native U32 comparator returns a tagged Cmp object. Its exact type
proof guarantees that LT, EQ and GT all have zero fields, so its existing `$`
tag is already compatible. A vector representation would require a conversion
at this boundary or a second case layout.

The full current boundary inventory is:

| Boundary | Admitted values and consequence |
| --- | --- |
| Public worker root | Scalar arguments; scalar or exact native String result. Tagged objects and tuples do not enter or escape. |
| Direct private calls | Values remain inside the same proved graph and use one shared layout. |
| Literal globals | Only U32, Nat, F32, String or Char literal definitions; their original `get` evaluation remains. |
| Private nullary references, when enabled | Evaluated as private calls at the original demand point; tagged results remain internal. |
| Residual native inputs | Bool, Nat, U32, F32 or String; no tagged value or tuple crosses outward. |
| Residual native results | Scalars/String, zero-field Cmp from U32.cmp, or native Tuple<Nat,Nat> from Nat.divmod. |
| Public match/project helpers | Worker tagged values do not reach these helpers. Public representation and helpers remain unchanged. |

The native inventory is Bool.xor/and, Nat.add/sub/is_lt/divmod, U32.cmp,
String.append and F32.to_u32. Ordinary exact primitives are lowered separately.
No native receives an immutable container containing a private object.

The worker lowerer now enforces an additional representation fence on residual
native signatures. Arguments must be scalar/String/Char; results must be one of
those types, exact nullary Cmp, or the exact native Nat pair. This is a restriction
in addition to the existing complete JPure proof. It prevents a future broader
native whitelist from silently admitting an incompatible object or tuple ABI.
No new entry, primitive, constructor or native definition is admitted.

The independent reviewer checked construction/projection layout agreement,
ordered stable field values, fresh allocation, direct/fallback consistency and
the explicit native fence. Static review passed; it is not an execution result.

## Implementation and isolation

`JWConstruct` gains a layout derived from the proved result type. Only layout
`tagged` changes construction and projection. All other constructors retain the
existing runtime `ctor` expression, including U32/F32 forms that do not have a
worker match layout. The shared value printer handles both direct execution and
the bounded-stack loop fallback. The change adds 32 lines across:

- `selfhost/src/back/js/ir/worker-model.bend`
- `selfhost/src/back/js/ir/worker-lower.bend`
- `selfhost/src/back/js/ir/worker-emit.bend`

Before/after copies and the isolated unified patch are recorded under
`selfhost/build/phase45/named-fields-patch01/`. The patch SHA256 is
`b05c05b3aaf7cb48fbc67cc18062c55d85807b918f27f020c81f43e73c380516`.
Its paths are relative to a selfhost source snapshot. `git apply --check` passes
against `selfhost/build/phase45/source-worker05`; the patch does not include the
worker06 budget change or worker07 nullary changes. Root owns execution and
durable evidence closure for the isolated candidate.

## Smallest falsifiers and qualification

1. Build the isolated checked candidate. Verify its emitted tagged construction
   and projections agree in both direct and fallback functions; native Tuple,
   String, Char, Bool and Nat forms must remain byte-equivalent.
2. Differentially execute recursive user ADTs and nested Tuple/List/Maybe values,
   including a native U32.cmp result stored and matched inside private data.
   Exercise Nat.divmod to confirm its native tuple boundary is unchanged.
3. Exercise enough recursion to cross the shared budget and return through mixed
   direct/fallback paths. Include empty/nullary and multi-field constructors.
4. Retain source/native descriptor and host-prototype mutation controls: guards
   must select the ordinary fallback with the same public results, errors and
   effects. Check that object-valued public roots remain refused.
5. Inspect activation and allocation samples, then run the short serial Map and
   records screen against freshly executed worker05 and pinned TypeScript.
   Require unrelated-source confirmation before broader promotion.

An anticipated 10–35% execution improvement on allocation-heavy programs is a
planning estimate, not a measured result. Weak activation, a runtime mismatch,
mixed-layout access or a repeatable slowdown falsifies the proposed benefit or
its applicability. Compiler cost and module growth must be recorded separately.
