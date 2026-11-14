# Remaining row cost and a recurrence diagnostic

After branch facts, both actual `branch-dev-build01` editdist and local-pair
product-row kernels have the same positive loop: 67 instructions, 12 explicit
frame-memory instructions, four U32 array loads and one U32 array store. The
original Phase194 loop had 77 instructions and 20 frame references. These are
static path counts, not cycle estimates. Exact binaries, loop boundaries and
disassemblies are pinned in `inputs.json` and `loop-metrics.json` here. The two
retained assembly function bodies are byte-identical.

The remaining frame traffic comprises four loop-state save/reload operations,
two invariant base/mask reloads, two Boolean-result save/reloads, two diagonal
value save/reloads, and two selected-result save/reloads. Selection and register
allocation experiments already address much of this. The C reference's hot
pair loop at `a770..a7c9` has no frame access, but it retains the same four
array reads and one store. A further small MOV reduction does not by itself
establish a large remaining opportunity.

## A distinct serial memory recurrence

In the branch editdist machine, `40c9a3` loads current-row cell
`[rdx + (j & r13)*4]` into `r14d`. The result is stored at `40ca15` to
`[rdx + (U32(j+1) & r13)*4]`. The backedge assigns `j := U32(j+1)`.
Therefore the next iteration's current-row load reads exactly the previous
iteration's stored word. The current load feeds an increment and both minima,
so the memory round trip lies on a loop-carried dependency. The C hot loop
also has that dependence (`a79c` load, `a7be` store); it is not an artifact of
the x86 frame allocator alone.

A compiler implementation would need a certified loop-entry value and
backedge transfer, distinct from ordinary within-block value facts. The
current `Again` and dead-write/liveness machinery must be accounted for;
simply preserving an alias across `Again` is insufficient. Rather than rush
that implementation, the authorized diagnostic changes this exact retained
machine only. It is not a benchmark-named compiler optimization, a checked
compiler derivative, or a promotion candidate.

## Exact diagnostic and semantic argument

`selfhost/tests/phase195/loop-carry/prepare.py` created the immutable
`selfhost/build/phase195/loop-carry-diagnostic-plan01/` plan, baseline and carry
assembly copies, and exact context diffs. Original assembly, object, ELF,
source, independent oracle and tool pins are retained. The diagnostic:

1. After the existing successful array guard, tests the loop count. If zero,
   it reaches the unchanged exit without any array load. Otherwise it loads
   the initial current cell into R14d once.
2. Removes the three instructions computing and loading the current cell on
   each iteration. R14 is already that load's destination and is used only as
   the current cell in the positive loop.
3. Keeps the original store and immediately copies its EAX value to R14d.
   The backedge continues with the existing count and index updates.

The entry load uses the same base, mask and full-width initial index as the
original load. On nonzero entry, the positive path has only reads before that
load: moving this read to the successful preheader crosses no write or call.
It does not execute on the cold fallback path. The count test specifically
preserves zero-iteration behavior, including inaccessible array cells.

Inductively, the carried word equals memory at the next load's address: the
store writes a U32 value, the next index is the exact same U32 increment used
by the store address, and R14d zero-extends the same word as the old U32 load.
This holds at U32 wraparound and for high initial indices. RDX and R13 do not
change in the positive loop. There is no intervening call, array store or
other externally visible write between this store and the next corresponding
load; the only intervening memory writes are compiler-owned frame slots.
The argument does not require disjoint character, previous-row and current-row
arrays. Aliasing those arrays leaves all reads and the observable store in
their original order, and the carried value is exactly the last stored word.
R14 is restored by the unchanged epilogue; no additional register or canonical
runtime-state register is borrowed. The preparation asserts the exact relevant
instruction contexts and control edges and refuses a different machine.

## Independent checks and execution

The C observer uses a literal U32 recurrence oracle and checks all memory cells,
the four output words and the return value. It covers 576 combinations of
counts 0/1/2/7/16/33, six indices including U32 and U64 wrap boundaries, four
character words, and four alias layouts (disjoint, previous=current,
characters=current, all equal). An additional zero-count case supplies
PROT_NONE array memory. Thus each baseline/carry observer must report exactly
577 checks and zero failures. The observer calls the actual emitted product
row via its ABI; it does not emulate the derivative to create its expected
answers. The native fixture's `main` is renamed only in observer-link copies.
Strict C syntax checking passed; Python syntax and metadata preparation passed.
No assembler, linker or target was executed by the preparing agent.

Root's exact guarded command is:

```sh
python3 -B selfhost/tests/phase195/job.py loop-carry-diagnostic01 75 32 \
  python3 -B selfhost/tests/phase195/loop-carry/run.py \
  --plan selfhost/build/phase195/loop-carry-diagnostic-plan01/plan.json \
  --out selfhost/build/phase195/loop-carry-diagnostic01 --seconds 60
```

The runner uses maintained bounded subprocess transport and validates every
frozen input before each subprocess. Its 19 subprocesses assemble/link both
ordinary roles for both workloads, check their original independent stdout
oracles, and build/run both C observers. Both baseline and carry use identical
pinned assembler/linker/runtime policy; comparing a freshly assembled carry
against the original direct-object ELF would introduce a separate assembly
policy difference. Expected new output is below 8 MiB; admission budgets
32 MiB and 75 seconds. Source copies already prepared occupy 3.26 MiB.
On success it emits an explicitly unqualified `programs.recipe.json` for the
maintained benchmark runner. Target execution and timing remain root-owned.

## What would justify a general transform

This removes only two net instructions per positive iteration (67 to 65), so
instruction count alone predicts no large effect. Its purpose is to remove a
serial array store/load round trip. A second round trip remains through the
selected-result frame slot. In a simplified latency-bound model with two
memory round trips of cost M and other serial work A, eliminating one offers
`M / (2M + A)` relative reduction: above 20% only when `A < 3M`. Neither M nor
A has been measured here, and throughput, address readiness, front-end work,
code layout or register pressure can dominate instead. This is a conditional
mechanism model, not a speed prediction or a numerical measured ceiling.

The pre-branch profile attributed 98.02% of editdist CPU to this product row;
that establishes historical relevance, not a fresh post-branch share. If
balanced timing of the two exact derivative roles shows a substantial gain
with both oracle suites passing, a bounded general store-to-next-load carry
certificate is justified. A small/no gain falsifies the claim that this
recurrence alone is the remaining large bottleneck, even if the machine
change is correct. Do not broaden into adjacent-load reuse without a separate
alias/write proof: the current store can overwrite a previously read cell
when arrays alias.
