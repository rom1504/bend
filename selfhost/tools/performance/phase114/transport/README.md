# Fixed-ABI continuation transport

This isolated candidate exposes `frame`, `stack_pop`, and `stack_get` as
structured N111 operations at final statement emission. All checked owning IR,
worker admission and the original final verifier run unchanged first. The
runtime source/object and its register bank remain unchanged. No target has
been run by this agent; root owns source checks and ordinary program gates.

For candidate31, append `original.bend`, `model.bend`, `namespace.bend`, and
`emit.bend`, then apply `entry.bend` as exact overrides of `p111q_stmt` and
`p113a_verify`. Both previous declarations are copied exactly with renamed
symbols in `original.bend`; the verifier override invokes the original before
the additional namespace check. `modules01.json` binds the complete baseline,
its admission, the modules, runtime source/object, ABI header and controls.
Export `p114t_expand`, `p114t_buffer`, `p114t_namespace`,
`p114t_negative_bytes`, `p114t_stmt`, and `p111q_ids` alongside the existing
array/native entry exports. Combined profiles require a separate conjunctive
source admission rather than reusing this candidate31 receipt.

The exact `P111State` ABI has `sp` at byte16, `rn` at28, `next` at32 and
`regs` at40; physical capacity is256 words. The unchanged header contains
static assertions for these offsets. Only `sp` is accessed by this candidate:

| Helper | Expanded behavior |
| --- | --- |
| frame | Read sp; copy each capture with the original ordered load/store pair; store the known FID; advance sp by `(count+1)*8`; return U64 zero. |
| stack_pop | Read sp; subtract `count*8`; write sp; return U64 zero. |
| stack_get | Read sp; load the full U64 at `sp+index*8` into the original destination. |

Frame is selected only for the exact U64 import signature, state local,
descriptor-known `N111FuncId`, literal count below256, and an exact supported
scratch name. Pop/get likewise require the original state local and literal
count/index below256. Unsupported signatures, buffers or dynamic operands keep
the original call. Descriptor arity, continuation incoming width, capture
capacity, stack-get/pop bounds and definite assignment remain the unchanged
original verifier's obligations. There is no new permissive public memory IR.

Supported scratch origins are the canonical stack allocation, exact bounded
fusion scratch names, and the existing recursively authenticated inliner
scratch ancestry. The checked source factories allocate these buffers separately
from the runtime state and continuation stack. The string predicate alone is
not a pointer-separation proof for arbitrary reflected IR. The public verifier
is structural; source provenance remains required. Source-defined `p114t_`
locals are refused across original segment bodies and complete functions.
Every expanded site reserves the shared QBE fresh counter before emitting its
private names; both If branches advance the same counter. The fallback renderer
keeps all existing explicit-width, accessor and float behavior.

Frame copies preserve source order instead of replacing the operation with
`memmove`. The original helper has ordered scalar copies, while the separate
register-transfer helper deliberately uses `memmove` for possible overlap.
Keeping that distinction avoids inventing an alias rule. With the admitted
scratch/stack separation, caching old sp is safe: capture stores cannot overwrite
the `state->sp` cell. Child ownership is merely transported; no keep, sink,
allocation or reference-count operation is added or removed. Pop retains the
old popped words, just as the runtime does; get preserves every word bit.

Expected mechanism: remove an out-of-line call and ABI register saves around
each selected stack operation, allowing QBE to optimize neighboring local
loads/stores. This does not eliminate continuation allocation, the dispatcher,
register-bank transport or recursive calls. Current public complete-function
wrappers and recursive-G unwind/load builders emit some helper calls directly
as text; they do not visit this hook and remain unchanged initially. The scope
must be measured on actual output, not inferred from all static helper calls.

Jump and return are deliberately deferred. Their exact expansion needs typed
per-program context containing `W=max(register_width,result_width,2)` from the
same descriptor. It must preserve the existing `memmove`, zero `[count,W)`,
leave physical `[W,256)` untouched, distinguish `rn` and next-FID, and maintain
Reply zero. Encoding W into `N111Ids` or assuming all inactive reads disappear
would weaken the current contract. A future context should be passed explicitly
to the admitted renderer, with a size limit to avoid duplicating large clears.

Root commands after source/API checking:

```
node selfhost/tools/performance/phase114/transport/controls.mjs CHECKED_API FRESH_PHASE114_OUT
python3 selfhost/tools/performance/phase114/transport/admit.py \
  --compiler COMPILER --api-report API_REPORT \
  --runtime-source selfhost/build/phase113/runtime-products01/runtime.c \
  --runtime-object selfhost/build/phase113/runtime-products-build01/runtime.o \
  --out FRESH_PHASE114_ADMISSION
```

The12 structural groups inspect tree ordering, full-width loads/stores, zero
counts, signed byte offsets, supported factories, exact fallback, unique site
names and the namespace guard. They execute no generated IR. Semantic gates
reuse ordinary checked source programs and complete output comparisons; there
are no malformed-memory or custom native failure probes.
