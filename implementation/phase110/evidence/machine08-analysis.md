The post-selection context-call experiment removes checked pointer accessors
from ordinary recursive workers while retaining both checks at each public
entry. The [offline receipt](machine08/report.json) pins all 18 successful
`context-machine02` executables and the `nm`/`objdump` tools. Inspection executes
no generated program. The runtime object is byte-identical to the earlier
runtime object; its source adds only authenticated layout assertions.

For actual `Base.String.append`, the selected original compact/general worker
calls `nx_rt_ir_heap` and `nx_rt_ir_alc` on every recursive invocation. Both
experimental private workers have zero such callsites. Each public wrapper
retains exactly one call to each accessor. A length-n left spine therefore
avoids 2n accessor calls within one ordinary append invocation, assuming its
normal complete traversal. No runtime checks are silently removed from the
public entry, and mutable heap/allocator contents remain loads.

| Backend and recursive body | Bytes | Instruction sites | Explicit stack-memory sites | Non-tail callsites |
| --- | ---: | ---: | ---: | ---: |
| QBE baseline | 548 | 154 | 6 | 10 |
| QBE threaded | 568 | 161 | 7 | 8 |
| QBE context loads | 522 | 146 | 6 | 8 |
| Clang baseline | 409 | 117 | 4 | 8 |
| Clang threaded | 415 | 113 | 4 | 6 |
| Clang context loads | 375 | 102 | 2 | 6 |

These are whole-symbol static sites, including fallback and cold branches.
Stack-memory counts exclude push/pop, address calculations and padding; call
counts exclude tail jumps. They are not dynamic instruction or cycle counts.
Clang tail-jumps to the final constructor helper, so its callsite totals cannot
be compared directly with QBE as total runtime calls.

The threaded QBE body preserves `ctx,heap,alc,p0,p1` in the five System V argument
registers and forwards those five arguments at its recursive call. Keeping the
two extra borrowed values live adds moves and one explicit spill site despite
removing the two accessors. All three QBE recursive bodies reserve 40 local
stack bytes and save the same five general registers plus the frame pointer.
The context form instead reads `(%rdi)` and `8(%rdi)` once per private invocation
and preserves the original `ctx,p0,p1` recursive ABI. Its body is 46 bytes and 15
instruction sites smaller than threaded. Clang's threaded private body reserves
24 local bytes versus 8 for baseline/context, and its context body removes two
explicit stack accesses. Clang also tail-jumps from each checked public wrapper
to its private body; QBE uses an ordinary call. QBE wrapper sizes are 72 bytes
threaded and 63 context; Clang sizes are 61 and 43 respectively. Public-wrapper
cost is paid once per exported call rather than once per recursive cell.

The root's completed `context-machine02` gate passed 234 original semantic
observations across three libraries, three modes and two backends. Its five
paired rounds on the same two frozen String.append cases give these median
variant/baseline ratios:

| Backend and case | Threaded | Context loads |
| --- | ---: | ---: |
| QBE shared left 512 | 0.90400 | 0.88415 |
| QBE unique left 1024 | 0.85006 | 0.85706 |
| Clang shared left 512 | 0.88209 | 0.90715 |
| Clang unique left 1024 | 0.83398 | 0.84261 |

Every individual variant/baseline observation is below one. The small difference
between forms changes direction with case/backend, so fewer static instructions
alone does not rank them. The controlled change and machine evidence identify
repeated accessor work as a material cost, while register allocation, wrapper
shape and direct-load cost also change. These reused cases support a bounded
diagnostic, not selection of a new policy, a fresh heldout result, or a direct
comparison with fused/production workers. No historical ratio is multiplied
into these measurements, and the selected native image remains unchanged.

The first machine run's Clang attempt stopped before executable construction:
the acquired Clang resource headers lack `stddef.h`, newly needed through
`string.h`. The successful runner uses one explicitly pinned GCC standard
include directory for all Clang modes. Generated source, the alias-safe memcpy
pointer loads and runtime behavior remain unchanged. Earlier checker failures,
the hosted comparator stack overflow, and the header failure remain preserved.

The next conceptual step is to qualify a checked internal-context convention
across a larger actual ordinary-call corpus, with code size, stack depth and
wide argument behavior measured explicitly. This experiment does not add that
convention to the selected native compiler or claim unrestricted concurrency,
callbacks, context lifetime, or whole-compiler speedups.
