# Packed U32 modular scan runtime leaf

This experiment supplies one ordinary SysV x86-64 leaf, linked as a separate
object alongside the unchanged qualified runtime. It does not replace the
runtime, allocate/free, alter reference counts, or own an array handle.

```c
uint64_t p199_rt_u32_scan4(uint32_t *data, uint64_t mask, uint64_t fuel,
                         uint64_t index, uint64_t carry);
```

Arguments occupy RDI/RSI/RDX/RCX/R8 and the result is RAX. Existing call lowering
must preserve live state, the original array owner and result-pair ABI. SSE2 is
the x86-64 baseline requirement; this object is compiled without AVX.

The existing direct worker guard establishes raw tag byte 4 (excluding shared
RFC bit 63, uniform TAG_ARR and non-array values), heap location at or above
the program's bound, and packed scalar-array mode. Its payload is
`(uint32_t *)(state->e.mem + (handle & ((1ULL<<40)-1)))`; corpus locations count
eight-byte words, while packed elements are adjacent four-byte U32 values.
Its mask is `(1ULL << ((handle>>40)&31))-1`. These facts are verified both in
`runtime/qbe/runtime.c` (`blk_ptr`, `blk_at`, `native_array_get/set`) and in the
unchanged exact worker object pinned in `frozen.json`. The recognizer must
retain that existing guard and its complete fallback. No class-7/128-slot
assumption belongs in the compiler or helper.

For zero fuel, the helper preserves every incoming carry bit and dereferences
nothing. For positive fuel it implements the original U32 add/XOR/index
increment, retaining the full U64 fuel count. It scalarizes capacities one and
two, aligns the index with at most three scalar steps, scans four distinct
consecutive cells in each non-wrapping chunk, and scalarizes the tail. The
index is unmasked for XOR and wraps as U32; masking is only for memory access.
All state after every SIMD chunk equals four original iterations. This follows
from associativity of U32 addition modulo 2^32 and the four distinct addresses.
Chunks retain their original order, including ring and U32 index wrap.

Caller preconditions are valid exclusive ordinary mutable packed storage,
mask/capacity consistency and the certified recurrence. Concurrent, volatile,
atomic, uniform-reference or shared-array semantics are not admitted by this
leaf. A defensive scalar path also handles non-power-of-two masks, but does not
make malformed pointers or bounds valid. The helper makes no new ownership
assumption beyond the original admitted direct path.

The guarded `build-check.py` acquisition compiles the helper with pinned GCC10
`-std=c11 -O3 -msse2 -mno-avx`, and links controls with the original generated
object (only its `main` symbol renamed) and unchanged baseline runtime.
Controls construct a sparse corpus satisfying the exact existing guard, call
the actual old worker, and compare owner, return ABI, carry, all cells and
canaries to both helper and independently written scalar oracle. They include
59,136 cases across classes 0–10; high index/carry bits; empty, short and wrapped
lengths; a NULL empty call; split-execution checks; 256 long mask cases; nine
full states independently recomputed in Python; and fuel `2^32+5` compared to
two subcalls each below `2^32`, explicitly differing from truncated fuel.

These controls exercise the actual old worker layout/ABI but do not initialize
the runtime allocator or prove candidate compiler admission. Independent
candidate-worker controls from the product-ABI agent cover initialized runtime
storage and fallback paths. Finite execution and source reasoning are distinct
from a formal proof or universal performance claim.

Root coordinates this one bounded acquisition:

```sh
python3 -B research/phase198/numeric/job.py p199-scan-runtime01 15 32 python3 -B research/phase199/scan-runtime/build-check.py --out selfhost/build/phase198/p199-scan-runtime01
```

The intended artifact is `selfhost/build/phase198/p199-scan-runtime01/scan.o`.
No performance result is inferred from the earlier source-kernel ceiling.

## Actual leaf acquisition

The root-dispatched acquisition **passed in 3.380 seconds** (guard 3.445 s,
44.6 MB peak process-tree RSS), and its retention close is sealed. All 59,136
actual-worker state comparisons, 2,816 split cases, 256 long-mask cases, nine
Python full-state vectors and the full-width fuel case passed. Decoded code
retains 64-bit fuel subtraction/comparisons, zero-fuel full-width return,
32-bit arithmetic and SSE2 scan instructions. The helper is 1,888 bytes with
SHA256 `3c32b17c57eb1e2e331e7b0a7e881f2f9f477aae71ee942c258decc2b9b30d5a`.

Compact exact evidence is retained in `evidence/`; no ELF or object is stored
in git. This result qualifies the leaf against the retained worker under its
stated entry conditions. It does not establish the new recognizer, fallback
selection, complete-runtime allocation behavior or whole-program performance.
Those belong to the separate candidate product and initialized-runtime tests.
