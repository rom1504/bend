# Phase194 held-out machine check

Both inspected held-out cases remove actual work from their repeated kernels; neither is a byte-identical-kernel/layout-only result. This bounded offline audit uses the exact Phase193 baseline pins in `phase194/references01/manifest.json` and current pins in `phase194/native45-02/programs.manifest.json`. All four binary pins were verified. [Report and disassemblies](heldout-machine-witnesses/report.json), [reproducible extraction](heldout-machine-witnesses/derive.py). No compiler, target, timing or profiling job was run here.

| Kernel positive path | Baseline → current instructions | MOV | SETcc / TEST / CMOV | Explicit stack accesses | Function bytes | Frame bytes |
| --- | ---: | ---: | --- | ---: | ---: | ---: |
| scalar-region-8192 `$direct.mit` | 159 → 121 | 106 → 84 | 7/7/7 → 0/0/7 | 23 → 18 | 813 → 689 | 2688 → 2688 |
| closures-256 `$p121.callback.bench` | 13 → 11 | 7 → 5 | 0/0/0 → 0/0/0 | 0 → 0 | 102 → 95 | 2288 → 2288 |

The scalar loop's seven comparison→Boolean→TEST chains become direct CMP→CMOV sequences, including the arithmetic-shift sign fill, escape test and freeze/counter selections. Five removed predicate stores reduce explicit stack traffic. This is direct transfer of predicate-through-copy selection to the existing integer kernel; it is not floating arithmetic optimization. Seven CMOVs and the original frame reservation remain.

The closure fixture's dynamic chain is already lowered to a scalar callback loop in both products. Its final accumulation previously uses `mov %rsi,%r11; mov %rdx,%rsi; add %r11d,%esi`; current code uses `add %edx,%esi`. Commutative right-home selection removes those two hot moves on every chain step. The earlier constant-plus-counter addition remains unchanged. This result does not demonstrate a new closure representation or allocation optimization.

Both outer `$direct.p93.loop` repetition/validation paths also lose one SETcc/TEST chain while keeping CMOV: scalar 58→54 positive-path instructions, closures 27→23. The intervening `$direct.bench` wrappers retain their instruction counts and sizes; relative call relocations can still differ. Whole `.text` changes 102545→102241 bytes for scalar and 100577→100433 for closures.

Counts include the positive header check and backedge, excluding exit; explicit stack-memory counts exclude LEA and do not count memory through scratch pointers. These kernels have no loop calls. The measured candidate/baseline ratios reported separately by the root are 0.749075 for scalar-region and 0.761008 for closures. Static removal supports a concrete mechanism, but does not establish how much of either runtime gain it caused. Layout also changed: hot header address modulo64 is 2→4 for scalar and 57→37 for closures. No controlled layout ablation or fresh hot-PC profile was performed, and instruction counts must not be converted into a runtime gain estimate.

| Case | Role | Binary bytes | SHA256 |
| --- | --- | ---: | --- |
| scalar-region-8192 | baseline | 180024 | `eb6e5602df17994f6f4a94540e60fdff79f15d6fa44cebbaa1ca68b0ca88e592` |
| scalar-region-8192 | current | 180016 | `9a957a2082c0503eb6ace8873b82b0e9effa9a2be179361abfdab18c3a92b9ed` |
| coverage-closures-256 | baseline | 175712 | `156c48f347a9fa7fa14fb1e06a4c2d12f52c5704c2f9ada574418ab0695b73dd` |
| coverage-closures-256 | current | 175704 | `e5da15e0f6d4c1130379d9c81f84ba039e7be7e56f8e8e0ece1cfe8f6b475160` |
