# Phase107 memory forwarding: independent static review

The review found no concrete transformation bug in the inspected pass. This is
a source-level audit of a bounded sequential optimization, not a proof of the
pass or a claim that its runtime controls passed. Root-owned experiment reports
record execution results separately.

Reviewed source: `selfhost/tools/performance/phase107/inline/memory.bend`,
15,532 bytes, SHA256
`f313276e844cc61a2eced51eead3d540bbe3c96075c15ee66fb31a0525050686`.
The pass changes loads only; it neither removes nor moves stores, allocation,
free, or calls. All claims below refer to this snapshot.

## Invariants checked

| Concern | Source mechanism and conclusion |
| --- | --- |
| Aliases and allocation reuse | `nx_m_allocate` gives a fresh root only to nonzero constant-sized allocations. Copies and constant offsets retain that root. `free`, direct calls and indirect calls erase all state. Consequently, a new allocation cannot reuse a still-tracked freed root. |
| Offset overflow and partial overlap | `nx_m_offset` and `nx_m_range` check bounds using subtraction before addition. `nx_m_disjoint` compares guarded distances rather than potentially overflowing end addresses. Stores remove every overlapping fact, including facts with another width. |
| Mutable values | Stored facts are only constants, variable references or function references. Assignment removes facts whose value refers to that variable. `nx_m_assignment` resolves pointer provenance against the old state before forgetting the assigned variable. |
| Changing pointer variables | Addresses in facts are allocation-root/offset pairs, independent of the current name used to reach them. Reassigning one pointer leaves aliases of its old allocation valid. Loads record their original address before updating the destination. |
| Unknown effects | Unknown stores erase memory facts and disable loop rewriting. Retaining pointer maps is appropriate because memory stores do not mutate IR local registers. Calls/free erase both pointer and cell facts. Branches discard outgoing state; nested loops disable an enclosing loop rewrite. |
| Loop entry and repeated iterations | `nx_m_assigned` removes every body-assigned variable from candidate pointer/value dependencies. The first probe filters cells overlapped by known writes. The second probe re-analyzes the original body after filtering and requires all remaining seed cells disjoint from its writes. If a filtered pointer load makes a write target unknown, rewriting is rejected. |
| Zero iterations and early exits | Only retained preheader facts leave an accepted loop. Body-produced facts never escape. No load is hoisted before the loop, preserving zero-trip behavior. Branches, free and calls force conservative fallback in the reviewed loop logic. |
| Pointer observations | The pass does not fold pointer comparisons, move allocations, or delete frees. Function pointer identity remains an atomic value. |
| Bounded application | Functions over 4,096 body nodes and programs over 256 functions or 65,536 nodes bypass rewriting. Candidate output is verified; that verifier checks structure/types, not memory safety. |

The loop argument is conditional induction: the retained preheader facts hold
on entry, depend only on unchanged locals and live roots, and the final analyzed
body cannot overwrite them. Thus the same facts are available on a later
iteration. This reasoning depends on the conservative effect barriers and on
the atomic-value restriction; widening either requires a new audit.

## Evaluation boundary found during review

The independent interpreter implements loads/stores with byte arrays
(`phase106/reference.py`). The existing C emitter instead casts and dereferences
typed pointers (`phase106/ir/c.bend`). A U64 store, overlapping U32 store, and U64
reload is useful for checking range invalidation, but ordinary optimized C with
strict aliasing is not a reliable semantic oracle for that byte-memory sequence.
Clang documents the effective-type restrictions, the disabling flag, and using
`memcpy` for representation accesses. [Clang Users Manual](https://clang.llvm.org/docs/UsersManual.html#strict-aliasing)

The root experiment will explicitly compile these C memory controls with
`-fno-strict-aliasing` and retain the flag in its provenance, alongside independent
interpreter/QBE/Cranelift comparisons. This review did not run that experiment.
The flag does not cure unaligned access or other C undefined behavior. Fixtures
must remain within live allocations and satisfy alignment obligations. A future
canonical C emitter should use `memcpy` if the IR promises arbitrary byte-memory
access; changing the emitter during the current measurements was deliberately
excluded. Existing same-width fields at separate aligned offsets do not exercise
this mixed-width issue.

## Focused controls requested

The implementer added fixtures for pointer-valued self-assignment, a loop whose
second probe loses pointer provenance after filtering, and an early-return loop.
The second-probe fixture changes `box.ptr` from `first` to `later`, then writes
through the loaded pointer on each iteration. A second iteration distinguishes
an invalid stale-pointer rewrite. Other requested controls cover zero trips,
partial-width overlap, unknown call/free barriers and range boundaries. Tests
should inspect both observations and retention of effectful statements; successful
outputs alone do not establish absence of load hoisting on unexecuted paths.

The current laws exercise the range-disjointness helper, not the complete pass.
The audit assumes verified, well-defined, sequential IR and the current 64-bit
pointer target. It does not establish correctness for concurrent memory,
volatile effects, arbitrary unsafe pointers, or whole Bend ownership semantics.
No installed compiler promotion or generated-target execution was performed by
this review.
