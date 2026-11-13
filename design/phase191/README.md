# Phase191: compose addressing, placement and machine diagnostics

Start2026-11-13 18:01:53UTC, parent e4cdffa. User authorizes one to two hours;
target a selected result by19:02 and qualification/report by20:02. Direct-x86
program runtime is3.083793× our mature C backend across44 timed native45 cases.
Parity is the goal, not a predicted result. Retain installed Phase189 and the
qualified Phase190 N2 as independent references.

## Competing hypotheses and bounded ambition

H1: our base/displacement-only operand representation prevents indexed memory
operations. Add a typed indexed operand, exact SIB/REX encoding, and a checked
selection window which removes address temporaries before register allocation.
Preserve load/store order, integer widths, aliases, exceptions and all fallback
obligations. Allocation-only projection is metadata, never executable semantics.
The selected operation must always emit correctly even when registers collide.

H2: static occurrence weights keep exit-only handles resident while repeatedly
used values spill. Add a default-off profitability policy counting backedge-
reaching uses separately. Preserve actual liveness, interference, incoming ABI,
call-clobber checks and independent post-color validation. First measure priority
changes; do not assume larger register counts or unrestricted bounds help.

H3: instruction counts miss dependency-sensitive stack traffic. Add exact-ELF,
span-bound store/load transition statistics and study LLVM/Zig/Rust primary
sources. Improve or adapt the existing native profiler only where the findings
justify it. Static accesses are neither cache misses nor measured latency.

The base ambition is a decisive2×2 experiment (old/new placement × old/new
address selection), then transfer to the37 held-out cases. The larger ambition
is composable known-address/width facts across local computations and selective
loop simplification. The extreme ambition is a compact virtual-register machine
stage enabling combined selection/allocation/scheduling. Pursue either extension
only when a measured obstruction justifies it; do not rewrite a backend merely
to satisfy an ambition label or multiply overlapping prospective gains.

## Experiment ladder and time allocation

1. First15–20minutes: freeze reference products/partition, implement independent
   operands/placement changes with Astra-high agents, and write adversarial
   machine fixtures. Root owns integration and one guarded CPU3 target lane.
2. Next20–30minutes: upstream-check candidate APIs; independently execute exact
   encoder and scalar controls through objects/assembly/C oracles. Compare the
   four policies on eight development programs, inspecting actual hot machine
   code and per-stage compiler costs. Reject expensive or ineffective variants.
3. Next15–25minutes: follow one evidence-backed extension if warranted; add
   final-candidate profiles where old samples no longer describe the code.
   Candidate switches stay independent; preserve negative and neutral findings.
4. Last20–35minutes: freeze a candidate, expose held-outs once, and run broader
   native qualification only after substantial transfer. Reuse byte-identical
   products instead of repeating runtime campaigns. Preserve raw observations,
   significant regressions, source/runtime/tool identities and qualified images.

Frozen eight tuning cases include local-pair/editdist, so their Phase190 held-out
status is not reused. Remaining cases include known variants, not independent
new algorithms. Retain44-case GM, positive log deficit, family weighting,
fixed-work excess and threshold counts. C means our mature C target. Separate
native compiler cost, generated runtime and total research cost.

No source-oracle weakening, target-name recognizers, silent semantic fallback
changes, full image build for an early idea, or installed promotion without
independent qualification. Compiler algorithms stay Bend; host code transports,
authenticates and measures. Formal proofs, source acceptance, structural checks,
finite tests and self-reproduction remain different claims.

All new jobs declare full disk/RSS/time budgets,16GiB available-memory floor and
5GiB disk reserve. Archive/verify before any explicit historical pruning; never
delete hardlink groups or the shared execution-lock inode opportunistically.
Commit the design and validated results/report; do not post PR comments.

## Bounded follow-up after machine inspection

The first exact-product inspection finds row paths of97–102instructions after
indexed selection, versus142–147in Phase190 and26in mature C. Seven conditional
branches remain versusone in C. This justifies two additional independent,
default-off experiments: pure one-to-four-copy branch selection with CMOV,
including elimination of empty arms; and adjacent64-bit private-frame store/load
forwarding that preserves stores and clears state at every intervening item.
The finite CMOV encoder has independent byte and C oracles. Selection never
speculates a user memory load. Neither rule changes source verification,
ownership, stack layout, or the final interference validator.

A failed ablation exposed a harness dependency on the mutable project manifest.
Subsequent API acquisition explicitly uses the frozen toolchain01.json snapshot.
Earlier receipts remain preserved; they are not relabeled as current evidence.
