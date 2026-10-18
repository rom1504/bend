# Phase106 backend code-shape analysis

Read-only inspection of the already measured objects, 2026-10-18. No new
compiler build or generated-program execution was performed for this note.
The strongest observed difference is **optimization across function boundaries**.
The fast adapter currently compiles each IR function independently; Clang can
inline and simplify across the whole generated C unit. Closure and recurrence
results also expose machine-code differences that inlining alone cannot explain.

Evidence is under `selfhost/build/phase106/`:

- `measure01/report.json`, SHA256
  `63fee286d653bfdabed1bdc52736867f618d2794259d9fa31112d3a55e40291f`.
- `analysis01.json`, SHA256
  `3ff80b1b5300dec1f00d8a9031460ad003bb1a9b7aecb8c29d4f40f052609b11`.
- The measurement input manifest is `artifacts02/report.json`, SHA256
  `12b3d43836278210f235dbfcee763e4ffee5cdb8372b7cdc6c3bcb16d5576c46`.
  Measurement consumes each workload's **fold** C/JSON product. The manifest
  pins all those products and the actual Bend producer independently.

These are three-round screening medians, not fresh confirmations or a claim
about complete compiler execution. Runtime includes process startup and the
specified repeated kernel calls. Object-generation clocks exclude linking.

| Workload | C-O2 object generation | CL-size object generation | C-O2 execution | CL-size execution | CL/C runtime |
| --- | ---: | ---: | ---: | ---: | ---: |
| many | 229.405 ms | 13.595 ms | 15.326 ms | 86.054 ms | 5.615 |
| text | 40.602 ms | 3.166 ms | 73.746 ms | 131.537 ms | 1.784 |
| closure | 32.605 ms | 3.014 ms | 17.570 ms | 33.586 ms | 1.912 |
| tail | 29.611 ms | 2.567 ms | 38.211 ms | 46.074 ms | 1.206 |
| shared | 35.718 ms | 3.075 ms | 9.454 ms | 35.908 ms | 3.798 |
| shared_borrow | 37.660 ms | 2.956 ms | 8.116 ms | 33.637 ms | 4.144 |

## Static accounting

The inspected objects are `measure01/r0-WORKLOAD-CONFIG.o`. `nm -S` supplies
defined text symbols and their byte lengths; `objdump -dr` supplies static call
sites. Counts include the entry wrapper and cold allocation/error calls. They
are **not dynamic profiles** and byte totals exclude inter-function padding.

| Workload | C-O2 functions / function bytes / call sites | CL-size functions / function bytes / call sites |
| --- | ---: | ---: |
| many | 1 / 1432 / 0 | 130 / 4194 / 129 |
| text | 1 / 334 / 3 | 4 / 465 / 6 |
| closure | 3 / 178 / 4 | 4 / 315 / 5 |
| tail | 1 / 106 / 0 | 2 / 98 / 1 |
| shared | 1 / 285 / 5 | 3 / 374 / 8 |
| shared_borrow | 1 / 304 / 5 | 3 / 358 / 8 |

Object SHA256 pins, ordered C-O2 then CL-size:

| Workload | C-O2 | CL-size |
| --- | --- | --- |
| many | `fe8792955c10cd25aad1c19939e8c5480c4c96f4d75ec706c97cd1bf6f38fc62` | `6f88e3949596736968bfdcc2d4ffb88ae322d90b19a7cbbaa26d260263d97b42` |
| text | `c545ffe4e0791ef891bc6bb312a19ea6736b83a3368e713bf9c4a27a7570148d` | `5d68eca23c13bc349e3b06a3cc2e15b6b328b5c7b9748510d087540cdacbc98d` |
| closure | `2aa2a277520344ae0f6ab91ca540e40c9f32b424f2de605db896962ea29547bf` | `12f268f31fae4393bb6ec64f714a13203eccdead7b394ed1c48c8060e0d75a49` |
| tail | `5279ad4ae6f7eaaeed22810fb9f3d33e0f1928d6d0cd9421e33bbc241d1bf03d` | `25b23b2f7b272d389f1ecd0f27916da6a792a1ee8a20316ccae2a6a7e7419cab` |
| shared | `83f377e215bdc996f7ccddca6cbba0f877a105bdc97c05a7c378f89cbc1cffc3` | `d6a6bbb33e87dd838e8366b04e6a309ffe4897b2829e415ac05bfb4af8cbcc3a` |
| shared_borrow | `5d9f29194758ca9fad326120f15e8271ee35a4f7b0e5425bf2650ab626c72601` | `398db5e5e8f0fa2ebef2cfcd1acd1be13920d72e1978529001391a46be124e0e` |

## Supported findings

**Many small functions.** The Bend workload constructs 128 helpers and a main
loop (`ir/workloads.bend:nx_many_helpers`, `nx_many`). C-O2 has no helper symbols
or calls: its one entry contains the arithmetic chain, including a combined
argument increment of8128 (`0x1fc0`). CL-size retains128 helpers, main and the
wrapper. Each main iteration calls helper127 and descends the entire chain.
For2000 iterations repeated50 times, the emitted control flow implies12.8million
helper calls, versus zero in C-O2. This makes bounded interprocedural inlining a
well-founded next experiment; it does not prove that calls explain every cycle
of the5.615× gap. Whole-chain unbounded expansion is not the recommendation.

**Text.** C-O2 folds both ASCII classifiers into the scan. CL-size's scan still
calls `bend_ir_ascii_ident` and `bend_ir_ascii_space` once each per character;
it also saves the first result on the stack across the second call. The measured
200000-character input repeated100 times implies40million classifier calls.
C-O2's fill loop is unrolled by two and advances its input-code accumulator by34
per pair; CL-size recomputes `17*i` and the length mask in its scalar loop.
The inspected C object has no SIMD vector instructions. **Vectorization is not
an established explanation** for this result; inlining, strength reduction,
loop placement and local code selection are visible differences.

**Closure.** Both backends retain one indirect call per iteration, selecting
between two environment-reading workers. C-O2 did not devirtualize that call.
For the coefficient-three worker, C emits `lea`, memory `add`, `ret`; CL-size
emits `push rbp`, frame setup, `imul`, memory `add`, frame teardown/pop, `ret`.
Its main loop also recomputes the masked limit and uses integer multiply for
the hash recurrence. C folds the mask outside the loop and uses shift/add for
multiply-by33. These facts motivate testing tiny-function frame policy and
loop/code-selection behavior; they do not apportion the1.912× slowdown.

**Tail recurrence and the surprising optimization-mode result.** CL-none's
screen median is35.424ms, versus46.140ms for CL-speed. In `bend_ir_main`, none
masks `n & 0xffffff` at offset0x6 before the loop backedge to0xf. Speed computes
that mask at0xc on every backedge to0x9. Speed also uses immediate shifts and
reassociates the XOR recurrence; none retains variable-count shifts. Therefore
instruction count or the profile name alone cannot predict the winner.
CL-none's object SHA is
`b374d289c572493aedd94b3f38c0586dee074c5de2e240e829eabd941564df4a`.
CL-speed uses the same disassembled instruction shape as the inspected size
variant. Timing remains screening evidence: an isolated placement/reassociation
ablation is required to assign the regression to either difference.

**Ownership-shaped observation.** CL-size retains an observer call per loop
iteration. Its owned observer includes four memory read-modify-writes: parent
increment, child increment, parent decrement, child decrement. The borrowed
observer removes these four updates but keeps the call. C-O2 inlines both
versions; its owned loop still contains reference-count stores, so it has **not
eliminated all ownership traffic**. Its borrowed loop uses the retained scalar
value and unrolls by four. This explains why the borrowed transformation and
backend selection interact, without proving production Bend ownership gains.
These synthetic cells use explicit libc allocation and are not the production
runtime ABI or its sharing invariant.

## Next narrow experiments

1. A bounded, law-checked IR inliner for tiny pure direct calls, followed by dead
   local/constant simplification. Use the real ASCII slice and unrelated held-out
   helpers; keep a depth/size cap and measure object cost and runtime together.
2. A function-summary/borrow certificate that lets a caller retain an owner
   across repeated scalar observation. Preserve the existing ownership controls;
   do not generalize from synthetic refcount cancellation to production aliases.
3. Separately investigate frame elimination for leaf functions and placement of
   invariant expressions in loops. Do not silently assume `speed` dominates
   `none`; retain both as eligible measured policies.

These are options for the next experiment, not implemented changes or promised
gains. The present evidence favors a fast backend **plus inexpensive shared
high-level optimization**, with Clang retained for release quality. It does not
justify replacing the complete compiler backend based on small object-generation
ratios alone. All generated-program correctness, source-law scope, preparation
cost and training/held-out boundaries remain those of the main Phase106 report.
