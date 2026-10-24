# Phase132: what a native compiler rebuild actually costs

This audit reads the qualified Phase131 receipts and current artifacts; it runs no
compiler or target program. [Machine-readable measurements](build-cost.json) pin
all source, request/build receipts and selected artifact contents. The selected
compiler source is `1bc5930…728f9`; Phase130 N1 is the acquisition producer N0,
followed by final N1, N2 and N3. Q2 and Q3 are byte-identical; N2 and N3 ELF files
are not byte-identical. Installed production selection is unchanged.

## Measured boundaries

| Operation | Child/stage wall seconds | Child peak RSS | Outer process-tree peak RSS |
|---|---:|---:|---:|
| Parent N0 compiles final source to Q1 | 489.619 | 2.844 GB | 2.860 GB |
| Final N1 compiles final source to Q2 | 393.599 | 2.907 GB | 2.924 GB |
| Final N2 compiles final source to Q3 | 379.228 | 2.906 GB | 2.922 GB |
| Q2 → N2: QBE / assembler / linker | 8.728 / 4.824 / 0.265 | unmeasured per child | 0.935 GB |
| Q3 → N3: QBE / assembler / linker | 8.728 / 4.823 / 0.265 | unmeasured per child | 0.936 GB |
| Upstream independent check **and JS API emission** | 14.178 | unmeasured separately | 2.293 GB |

GB means decimal bytes. Native request RSS is Linux `wait4.ru_maxrss × 1024`;
outer peaks are sampled process-tree sums including the Python harness. These
are different measurements and must not be substituted. QBE/build reports time
subprocesses but do not record per-subprocess CPU/RSS. Their outer guard cannot
identify which child or wrapper caused the peak. The build wrapper also hashes
107 MB inputs using `read_bytes()`, introducing avoidable host allocation.

Full source requests include source/Base/carrier reads, parsing, checking,
ownership checks, annotation, lowering, optimizations, independent IR
verification, text construction and writing. Existing full-request receipts do
**not** split those stages. Compiler execution is essentially single-thread CPU
work here: final N2 uses 379.226 CPU seconds over 379.228 wall seconds. The
acquisition observation overlapped another CPU lane; these three individual
source emissions are not a repeated controlled speed comparison.

The controlled short-request measurements are in the
[Phase131 native report](../phase131/native-results.md): final N2/parent N1
0.79079×, final N2/upstream 1.44305×; a separate same-source N2/N1 block is
0.89365×. These are three particular requests, not full self-build ratios.
Neither block measures generated-program execution speed.

## A 10-second rebuild needs a different amount of work

Adding final N2's source request to the corresponding Q3→N3 machine-stage times
gives **393.044 seconds**. This arithmetic sum excludes the independent API
gate, harness overhead, qualification and promotion; it is not another measured
end-to-end run.

- QBE/assembler/linker account for **3.515%**. Eliminating them entirely gives at
  most **1.0364×** speedup while preserving the full source request.
- A tenfold machine-build speedup leaves about **380.61 seconds**.
- An otherwise unchanged 10-second source-to-executable build is impossible
  because machine building alone takes 13.816 seconds.
- If incremental machine building and bookkeeping cost one second, the source
  work must fall below nine seconds: at most **2.373%** of today's full request.
  A two-second allowance leaves **2.110%**. These are required residual-work
  budgets, not evidence that 98% reuse is available.
- Running the unchanged 14.178-second independent API gate for every edit also
  exceeds that budget. Its pure checking component is unmeasured; switching
  execution language cannot be credited with removing the whole gate.

Therefore the plausible 10-second target is a **warm, correctly invalidated
small-edit loop**, with reusable checked semantic units and machine artifacts.
It should be reported separately from cold full compilation and periodic native
self-reproduction. A full-pipeline 39× improvement is not established by shorter
names, output compression or skipping the external checker.

## Memory and disk are different problems

Source is **2,667,581 bytes**; Q2/Q3 each **107,059,385 bytes**; N2 ELF is
**17,132,048 bytes**. The executable's `.text` is 10,815,649 bytes, `.data`
930,312 and `.bss` 1,148,424. File bytes are not resident bytes: symbol tables need
not be mapped, mapped pages need not all be resident, and runtime heaps are not
in the ELF.

The selected source/API/Base/runtime plus Q1–Q3, their assembly, objects and
executables total **677,541,643 logical bytes** and **677,588,992 allocated bytes**
over 16 distinct inodes at this snapshot. This is deliberately a bounded
current-chain inventory, not repository disk usage. Other aliases/historical
artifacts, profile outputs and validation products are excluded. The JSON
records inode/link count and block allocation; summing all path lengths would
be wrong after hardlink deduplication.

There is a concrete memory amplification mechanism: emitted QBE is represented
as Bend `String`, a chain of two-word `SCon` nodes. An independently materialized
ASCII character has 16 bytes of field payload. Expanding 107 MB of ASCII output
therefore corresponds to roughly **1.71 GB of character-cell payload**, before
IR, transient analyses, reference metadata and allocator retention. This is a
representation calculation, **not a measured heap census or lower bound**:
shared tails, chunk-added newlines and exact lifetimes affect the total.

The entry returns a `P111Emission` containing a list of rendered strings, then
prints that list. At the runtime boundary `io_cbuf` consumes each string node
while producing the current UTF-8 chunk; it does **not** keep an additional
whole-file C buffer permanently. Pure rendering returns all chunks before the
IO traversal. This makes streaming verified units or using packed output
chunks a more credible resident-memory experiment than merely compressing the
file after execution.

A 1 MB **total IR** target and 10 MB **whole compiler RSS** target are not justified
for the current implementation. They are useful ambitions only after specifying
what is included: working set per incremental unit, additional heap per changed
unit, compressed cache, or total resident process. The current instruction text
alone exceeds 10 MB in decimal units; this is not a strict RSS lower bound,
but it makes a whole-image target inappropriate. An 8 GiB virtual arena
reservation in the runtime is likewise not 8 GiB physical RSS.

See [memory/native-first source audit](../../research/phase132/memory-and-native-first.md)
for concrete retention boundaries and a minimal source-edit witness.

## Evidence gaps worth closing, without another baseline rebuild

1. Use the existing full-source profiles to rank semantic work; do not call
   sample windows exclusive stage timers. Full active-context evidence identifies
   constructor ownership scans and lookup/destruction work that three short
   requests understate.
2. During the next already-required changed-source run, record coarse phase
   endpoints and RSS at those endpoints if this can be done without changing
   semantics. RSS alone still cannot identify live IR versus reusable freed
   arena pages; do not add another full run just to obtain a baseline.
3. Count invalidated semantic units, emitted changed bytes and rebuilt objects
   in an actual single-function edit. Preserve a complete full-reference result
   and independently checked source. Machine-object reuse after a full frontend
   run remains machine-only incremental compilation.
4. Compare native and JS-hosted full-source requests only with the same source,
   Base semantics, output contract, runtime policy and stage boundary. Historical
   872-second hosted versus 399-second native observations do not satisfy this.

## Update: the required source-edit run now has a memory curve

The [observed source-edit request](edited-memory01/README.md) completed in368.976
child seconds with2.900GB child peakRSS. It grew by1.897GB over a late34-second
interval while output remained empty, then exposed107MB of output in the final
roughly2-second observed window. This supports testing final-output retention,
without attributing exclusive stage time or claiming a speedup. A narrow-export
independent full-book check/API gate took5.477seconds/681MB outer peak; its export
scope differs from the earlier14.178-second gate.
