# Table v3 ray machine audit

`table-dev-build01` eliminates every sx/sy/sz/sr/skr call in the audited recurrent nearest/trace functions. There are exactly five unique emitted table symbols. Their nine U64 words (72 bytes each; 360 total) are byte-identical to the retained QBE tables. Exact binary pins, symbols, data words and bounded function metrics are in `table-machine-metrics.json`; adjacent `baseline-ray-*`, `table-ray-*` and `qbe-ray-*` files preserve disassembly.

| Function | Baseline instructions / stack operands | Table v3 | QBE |
|---|---:|---:|---:|
| product.nearest | 767 / 201 | 865 / 210 | 314 / 49 |
| direct.nearest.t | 594 / 128 | 697 / 139 | 261 / 22 |
| product.trace | 1978 / 690 | 2114 / 742 | 496 / 76 |

These whole-function static totals include mutually exclusive paths. The larger table caller bodies exclude the eliminated 69-instruction selector callees, so this growth does not establish a runtime regression. Frame reservations grow by 32 bytes each: 3376→3408, 3312→3344, 4464→4496. Frame reservation is not the number of bytes actually touched. QBE counts use the saved bounded objdump instruction-line method; earlier aggregate notes differ by one boundary/padding instruction.

Each current table clamp still materializes a Boolean and branches: compare, SETB, MOVZX, move, TEST, conditional jump, chosen value move, unconditional jump, then shift/address/load. All four outputs are subsequently spilled/reloaded around floating arithmetic. QBE uses CMP/CMOV and indexed loads. The source cause is the separate X186FloatBranch consumer, not failure of the table-call certificate. `float-compose-v1.md` defines the bounded follow-up interface; there is no change to table data or catalogue admission.

Allocator-gate assessment must use pruned FloatNodes placement, not raw preselection IR. Economics' root-owned allocation-capture01 reports product.nearest189 rows and nearest.t175, with32 joint candidates; product.trace592 and legacy allocation. Each replaced call expands one row into seven counted rows (+6); eight replacements suggest237 and223 for the nearest functions, still below256, while trace remains above. This arithmetic assumes pruning otherwise unchanged; actual candidate placement recapture is needed to certify exact counts. The observed modest caller stack growth provides no evidence of a wholesale nearest gate drop. Avoid attributing remaining spills to such a drop without that capture.
