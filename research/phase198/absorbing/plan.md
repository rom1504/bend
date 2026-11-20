# Absorbing countdown rule

The initial [generated-assembly diagnostic](../../phase197/discovery-b/absorbing/README.md) showed 23.3–23.8% less BST64 time and 4.3–7.0% less BST32 time. This experiment tests whether a compiler rule can realize that gain at the shared IR join.

## Admission

The direct x86 worker must start with an exact unsigned-64 comparison of a formal fuel word to zero. Its base arm returns only incoming parameters or constants. There is no one-time setup. On the positive edge (possibly guarded by the complementary nonzero comparison), the fuel predecessor must be a fresh local defined by a full-width subtract-one. A single optional fixed frame declaration may follow. The x86 emitter represents this declaration with statically assigned space, and emits no instruction or dynamic allocator call at this point.

A bounded, pure integer prefix computes a predicate before a conditional immediately followed by a single shared tail backedge. Each selected-arm instruction must make a 64-bit local copy of a constant or nonfuel input, possibly via another certified copy. Writes to formals, reserved machine slots, the fuel predecessor or the declared buffer refuse. For the backedge's parallel arguments, the fuel position must be exactly the predecessor. Every other position must be its own original word or a known constant. Overwrites in copy chains are interpreted in their original order.

Using those resulting constants, re-evaluate the complete guard prefix through existing word-fact arithmetic, resolving constructor identities through this program's ID map. Both operands of every operation must be exact. Shifts are bounded to the operand width. The final exact Boolean must select the same arm. Therefore another positive iteration preserves the entire nonfuel state while decreasing the fuel by one. Induction on unsigned fuel proves the original base case eventually receives the same state. Trapping/effectful operations are outside the prefix and the admitted arm. Other arms are unchanged. The transformation appends a local assignment of zero to the predecessor on the eligible arm. The common parallel backedge and existing base return still execute. No benchmark, symbol, tag literal, argument count or register name identifies the optimization.

## Experiments

- Acquire a checked standalone API on the Phase195 parent. Exercise positive and negative compiler-data examples and independent C ABI observations through the direct ELF encoder and GNU assembler.
- Emit complete programs from shared prepared data. Require the regenerated baseline object to equal the qualified Phase195 object on every ordinary case. Run a separate authored draining-queue example and a plain integer saturation example. Keep refusals.
- For changed programs, time the complete ordinary result/count workload on direct-object siblings and default GNU-assembler siblings. Reverse balanced pair order over two sessions. Each cell has four candidate/baseline pairs. Require every median ≤0.98 and at least three winning pairs per cell before recommending integration. For saturated synthetic outcomes with short candidate intervals, report the actual resolution.
- Check all ordinary timed results, additional inputs and private-worker ABI edges independently. Count descent iterations in separately instrumented executables. Use static work and counters to separate causal evidence from run-to-run changes in placement.

All jobs use the shared guard and retention receipts. Full native45 qualification of a future combination is independent of these focused standalone measurements.
