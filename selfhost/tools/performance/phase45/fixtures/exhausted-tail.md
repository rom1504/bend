# Tail-only entry with an exhausted native budget

`exhausted-tail.bend` deliberately uses unsafe recursion to isolate backend
execution from termination checking. The public scalar root includes an erased
identity application, so its private graph is eligible before ordinary-call
admission was broadened. No benchmark name or source recognizer is required.

For depth `d`, tail count `t`, seed `s`, let `s_i = (s + 3i) mod 2^32`.
The result is `(s_d + 7t + sum(i=0..d-1, s_i xor 85)) mod 2^32`.
The controller computes the seed progression independently with BigInt arithmetic.
The acquisition example `bench(3, 5, 7)` is 316.

The clean predecessor, selected compiler and pinned TypeScript modules must all
return the exact U32 oracle. Cases include zero outer/tail steps, the 31/32 budget
boundary, and 80 or 81 pending non-tail calls followed by 50,000 tail steps.
The large cases use seeds 0, 7 and 2^32−1. Each is followed by a shallow replay.

A separately saved, untimed derivative locates the complete `G['bench']`
assignment with Acorn. It proves the unique tail-only wrapper directly targets a
native component in the same lexical block and has no corresponding machine.
Entry/exit snapshots require budget zero throughout the deep tail path, unchanged
charged-entry/restoration/machine counters, and exactly 50,000 native transfers.
All 32 charged outer native frames must restore, leaving budget 32 outside calls.
Diagnostic instrumentation is never used as performance evidence.

Run `exhausted-tail-controls.mjs BASELINE_MODULE CANDIDATE_MODULE TS_MODULE NEW_OUT`
with the normal bounded execution launcher and Node stack size 984. Module sidecar
receipts must identify this exact source/catalog and the pinned compilers.
