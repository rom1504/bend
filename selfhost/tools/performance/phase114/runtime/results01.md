# Take2 first measured result

Root's completed three-round matched screen preserves every complete output and
success count (27 observations across upstream, candidate31 and Take2). Five
ordinary ownership/program controls also passed according to the root's
qualification report. The runtime-only change yields a small improvement:

| Kernel | Candidate31 median | Take2 median | Take2 / candidate31 |
|---|---:|---:|---:|
| Tree bitonic | 555 ms | 541 ms | 0.9748 |
| List pipeline128 | 719 ms | 697 ms | 0.9694 |
| Expression128 | 484 ms | 470 ms | 0.9711 |

The geometric mean is **0.9717**, a2.83% elapsed-time reduction (1.029× speedup).
Take2 remains **11.160× upstream** on this selected three-kernel set, versus
candidate31's11.485×. This is not a broad-suite gain or parity. The first list
round tied; medians alone do not establish a robust larger effect. No subsequent
profile is included here.

Evidence: `selfhost/build/phase112/p114-take-screen01-measure/report.json` and
`selfhost/build/phase114/take-screen01-jobs-reports.json`. `results01.json` pins
these records and the exact generated QBE/upstream C inspected below. The audit
executed no target and generated no transformed program.

## Why the narrow helper change has limited reach

The hot recursive functions remain generic one-state segments:

- List: `p37.list`, `keep_gt1`, `dbl`; only terminal `suma` is a complete private
  loop and receives the Take2 template.
- Expression: `p37.expr` and `eval`; the complete private `p37.expr.pick` builds
  constructors but contains no Take2 site.
- Tree: `warp`, `flow`, `bsort`, `scan`; complete helper `warp_zip` receives three
  Take2 sites, but the recursive traversals retain generic helpers.

For example, list QBE lines8268/8541/8707 and expression QBE line8369 contain
frame/capture stores, `p111_rt_jump` and a segment return. The next continuation
loads captures through stack helpers and returns through `p111_rt_return`.
`runtime-products01/runtime.c:3933` copies arguments then zeros the inactive
logical bank; the dispatcher at1393 calls the next segment indirectly. The
admitted logical widths are5 words for list/expression and7 for tree, not256.
This is repeated small-call/transfer overhead, not the former full-bank-clear
problem.

Upstream C retains the same semantic continuation stack, but recursive descent
uses local parameters and `WL_SPIN`/`WL_AGAIN`; list C1894–2039 and expression
C1945–2048 show this directly. Heap operations and scalar arithmetic are visible
inside those blocks. Thus the strongest cross-layer hypothesis is to retain a
verified recursive component and its continuations as structured local control
flow, removing per-edge generic transport while preserving pending frames and
owner transfers. Root's separate recursive experiment tests this. Static source
inspection establishes the mechanism exists; it does not measure its share of
the remaining runtime.

## Concrete representation gap for the next bounded experiment

Upstream expression C1377–1396 constructs `Lit` fields with `term_pak`, and the
`eval` leaf at1950 extracts `term_loc` directly. QBE `p37.expr.pick` instead has
nine generic constructor calls, including six unary leaf allocations. The
frozen generic `p111_rt_ctor` always allocates nonempty constructors; storing a
raw CTR leaf in a parent then adds a count-one RFC wrapper. Tree `Leaf` has the
same discrepancy. Upstream list constructors also store certified cold tails
without sealing, but transferring that whole-program sharing certificate needs
a separate proof boundary and is not justified merely by these counts.

A smaller falsifiable representation hypothesis is **guarded ordinary unary
packing**, reusing mature `ne_single`: if the full payload fits `LOC_MASK`, make
a PAK word with the same CID; otherwise call the unchanged constructor helper.
This removes the leaf box and its later seal wrapper without guessing ownership
from names or treating a truncated value as a scalar. The generic take path
already accepts PAK at arity one. Before implementation, ordinary user
constructor identity, every applicable runtime consumer and readback must be
checked; effect/builtin layouts cannot be widened implicitly. No constructor2
implementation is justified by this result alone.
