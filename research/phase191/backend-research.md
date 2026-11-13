# Phase191: useful backend lessons and cheap machine diagnostics

Investigated 2026-11-13 against frozen `e4cdffa` source, within a 20-minute
research budget. Live Phase191 edits are deliberately excluded from the missing
capability claims below. No compiler products were built or executed here.

The strongest next experiments are **loop-use-sensitive register priority** and
**scaled-address selection**. A larger instruction count dashboard is less
useful than showing the exact frame transport between an address producer and
its consumer. This follows the retained
[local-pair witness](../../implementation/phase190/local-pair-regression.md):
the candidate has fewer row-path instructions but its `prev[j+1]` sequence has
12 frame references versus 2, while four handles used on exit occupy homes.
This is a placement hypothesis, not an established cause of the runtime loss.

## Primary-source findings connected to our code

| Mechanism | External evidence | Exact gap at `e4cdffa` | Bounded next step |
| --- | --- | --- | --- |
| Address selection | LLVM represents `base + scale*index + displacement` directly in memory operands; its x86 DAG selector has address matching. [Code generator](https://llvm.org/docs/CodeGenerator.html#representing-x86-addressing-modes-in-machineinstrs), [selector source](https://llvm.org/doxygen/X86ISelDAGToDAG_8cpp_source.html) | `selfhost/src/back/x86/object-model.bend:X187Operand` has only base/displacement memory and RIP-relative memory; no index/scale. `scalar.bend:x185_load_memory` stages the base in r10 and emits `X187Mem`. | Add typed indexed operands and an independently tested encoder before selecting them. Fold only proven local address expressions; preserve width/truncation, signs, flags, aliasing, shared uses and scratch-register constraints. |
| Allocation priority | LLVM computes spill weights using per-instruction uses/defs and block-frequency information. [CalcSpillWeights source](https://llvm.org/doxygen/CalcSpillWeights_8cpp_source.html) | `loop-liveness.bend:x190_j_weighted` weights all body reads; `regalloc.bend:x190_register_scores` uses syntactic counts and setup/parameter classification. Exit-only body uses do not get a separate repetition class. | Rank repeated-cell uses above exit-only uses while leaving the interference/ABI validation intact. Record selected names, priority and rejection reason on the affected function. |
| Allocation lifetime | LLVM's greedy allocator can split regions and individual blocks using spill-cost comparisons. [RegAllocGreedy source](https://llvm.org/doxygen/RegAllocGreedy_8cpp_source.html) | `loop-liveness.bend:x190_j_install` installs one home per chosen name. `x190_j_valid` validates that global assignment; it does not produce regional homes or boundary moves. | First try priority changes within existing legality. Full splitting needs new boundary-move correctness machinery and is a later project, not a 20-minute patch. |

Rust is not an independent x86 allocator reference: its normal codegen route
hands LLVM IR to LLVM, with alternative backends also supported. Compare Rust
with a recorded backend/optimization level; an LLVM-generated Rust example
mostly demonstrates LLVM here. [Rust compiler development guide](https://rustc-dev-guide.rust-lang.org/backend/codegen.html)

Zig supplies a different lesson: the pinned **0.15.1** release makes its own
x86_64 backend the Debug default on specified systems and reports much faster
compilation, while explicitly acknowledging slower generated machine code
than LLVM. Its compiler is itself built with that backend. This supports
tracking compiler turnaround and generated runtime separately; it does not
establish LLVM-level optimized code quality or identify the allocator we
should copy. The same release's time reports separate semantic analysis,
codegen and linking costs. These are historical version-specific observations,
not claims about the newest Zig. [Official release notes, x86 backend and time reports](https://ziglang.org/download/0.15.1/release-notes.html#x86-Backend)

Attempts to retrieve the pinned Zig `CodeGen.zig`/`register_manager.zig`
through the web tool failed. No allocator algorithm or benchmark result has
been invented from those unavailable sources.

## Implemented offline extension

[`frame-transitions.py`](../../selfhost/tests/phase191/frame-transitions.py)
calls the unchanged Phase190 `machine-audit.py`, with the same arguments,
then adds `frame-transitions.json`. Its report ties every witness to the ELF
SHA-256, symbol, exact instruction addresses/offsets, raw disassembly and
original user-selected spans. Existing fresh-output and exact symbol-byte
coverage checks remain in force.

The new statistic is a same-width integer `%rbp` store followed by the next
recognized load of that slot within a conservative straight-line sequence.
Each witness records the two instructions and intervening instruction count.
State is cleared at branches, branch destinations, calls, gaps, unknown
instructions, frame-base writes and unknown memory writes. Overlapping slots
are invalidated. Indirect jumps disable matching for the function. Immediate
stores, SIMD, implicit stack operations and cross-block dependencies are not
modeled. Report barrier counts to make undercoverage visible.

Use the existing audit invocation with only the script path changed:

```sh
python3 -B selfhost/tests/phase191/frame-transitions.py \
  --baseline "$BASELINE_ELF" --candidate "$CANDIDATE_ELF" \
  --symbol "$ROW_SYMBOL" --regions "$EXACT_REGION_SPEC" \
  --out selfhost/build/phase191/frame-audit01
```

Run this read-only inspection separately from timed targets. Root owns actual
artifact selection and measurements. The five finite Python test methods
(including multiple negative subcases) pass via
`python3 -B selfhost/tests/phase191/test_frame_transitions.py`; they cover widths,
overlaps, unknown stores, calls, joins, gaps and indirect control flow. No
target execution is involved. An end-to-end ELF invocation remains for root.

**A transition is not a redundant spill proof.** It does not say the source
register survives until the load, that memory is private, or that eliminating
the pair is legal. Neither frame counts nor transition counts measure cache
misses, store forwarding, latency, dynamic frequency or runtime.

## Priorities and stopping points

1. **Now, 5–10 minutes:** audit the exact row address spans in parent/candidate/C
   products, reviewing transition witnesses alongside the existing static path
   bounds. Preserve function/ELF identity and do not pool different workloads.
2. **Next, 20–40 minutes per hypothesis:** test one general allocation-priority
   change or indexed-address rule with adversarial controls, then a balanced
   development screen. Fewer transitions support the mechanism; only matched
   runtime supports a speed claim. Freeze before broad transfer checks.
3. **If explanatory uncertainty remains, 10–15 minutes:** use the maintained
   native sampling profiler on the exact local-pair workload and objects, with
   its existing owner/PC mapping, to establish whether this row is actually
   hot. This is a proposal, not a profiler modification or run authorization
   request. Keep root's single measurement lane and retention guard.
4. **Later:** integrate real def-use chains, loop-carried recurrence depth,
   call-crossing live values and branch-edge frequencies only when an observed
   bottleneck needs them. These require operand semantics/CFG or dynamic data;
   mnemonic counts cannot substitute. Avoid broad decoder development now.

`llvm-mca` is optional for a few exact hot straight-line snippets: pin tool
version, target triple, CPU model, selected assembly and iteration settings;
inspect register dependency timelines/resource pressure. Run both explicit
`-noalias=true` and `-noalias=false` assumptions when investigating memory.
Its default assumes loads and stores do not alias; it does not model cache
hierarchy or store-to-load forwarding. Thus it can support a scheduling
hypothesis but cannot settle this stack-transport latency question or replace
runtime measurements. No installation or integration is needed for the first
two priorities. [llvm-mca documentation](https://llvm.org/docs/CommandGuide/llvm-mca.html)
