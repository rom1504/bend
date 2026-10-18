# Native IR and constrained optimization loop

2026-10-18. Work in progress. [Design](../../design/phase106/native-ir-research-loop.md).
The current compiler selection and production source remain unchanged.

## Completed attribution

One full-source native B2 sample run preserved complete emitted C and diagnostics.
It took 142.160s with 1,353,492KiB maximum RSS; this is an instrumented observation,
not a new clean speed estimate. 8,879 physical CPU samples cover the process.

| Physical leaf | Samples |
|---|---:|
| `term_drop` |34.00%|
| `span_fade` |21.44%|
| `p88_string_eq` |17.49%|

These disjoint leaves total 72.94%. `span_fade` handles field ownership while
destructuring shared constructors; it is not text copying. Leaf sampling does
not give inclusive caller costs, allocated bytes or exact compiler-phase times.
See [source attribution](attribution-notes.md) and [receipt](fullself-profile.json).

A fresh current-source Clang O2 image build took **375.644s**, maximum RSS
2,491,012KiB, with the same pinned toolchain and selected recipe. This is one
clean build observation; no new image is promoted. [Receipt](self-clang-clean.json).

The build is a major separate bottleneck. A faster machine backend could reduce
it, while ownership and comparison costs in the compiler executable still need
attention. The IR experiment therefore includes both construction/runtime
tradeoffs and an explicit shared-versus-borrowed observation fixture.

## Pending execution

The Bend IR producer, C/Cranelift consumers, law suite, differential controls,
bounded profile search and held-out evaluation are being implemented and checked.
No backend speedup or independently checked Phase106 law is claimed yet.
