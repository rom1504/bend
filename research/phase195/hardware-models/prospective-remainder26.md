# Prospective remainder26 arithmetic prediction

The frozen candidate arithmetic projection is cheaper in the Ivy Bridge LLVM11
model:2529→242 total cycles for100 repetitions (ratio0.095690), and block
reciprocal throughput10.0→2.0 (ratio0.200000). This supports the predeclared
direction of arithmetic improvement. Neither ratio predicts a whole-program
speedup; there is no candidate runtime measurement in this report.

Before model execution, the independent investigation supplied
[constant-remainder-evidence.json](../prospective/constant-remainder-evidence.json),
including actual combined-product ELF/caller/runtime pins, two proposed input
projections and the frozen expectation: arithmetic improves, whole-lexer magnitude
unknown. A [snapshot and timestamp](evidence/prospective-frozen/freeze.json) were
recorded before both this model run and candidate target execution. Inputs stayed
unchanged; no model-output-driven register or instruction selection occurred.

| Model result | Existing DIV projection | Proposed multiply/shift projection |
| --- | ---: | ---: |
| Instructions per repetition | 5 | 7 |
| Cycles across100 repetitions | 2529 | 242 |
| Block reciprocal throughput | 10.0 | 2.0 |
| Reported modeled uOps across100 repetitions | 500 | 700 |

The DIV projection comes from the actual nonzero U32 remainder arithmetic at
`0x41cbea..0x41cbf1`, with divisor26 from caller`0x408afa`; input/output registers
are normalized to ebx/edi. Candidate instructions use a proposed reserved-r10/r11
multiply/shift sequence. They have not been authenticated against emitted
candidate machine code by this model job. Both sequences omit calls, dispatch,
packing, argument loads, branches and actual layout, and repeat independent
inputs rather than reproducing a full caller loop's dependencies.

The model reports DIV latency25, reciprocal throughput10, and its `U` side-effect
marker. The gap between total-cycle and throughput ratios is retained rather
than resolved by selecting the larger projected win. Reported uOps are model
values, not measured hardware events. Operand-dependent division latency and
the full program's runtime/profile fractions are not established by this run.
The existing arithmetic oracle/certificate investigation is separate correctness
evidence; successful model parsing proves no semantic property.

[Raw report](evidence/prospective01/report.json), complete stdout/stderr and
guard/retention receipts sit together. The [runner](run-prospective.py) verifies
frozen projection/evidence hashes, all12 referenced existing ELF hashes and the
authenticated tool/library pins. Both calls used
`-mtriple=x86_64-unknown-linux-gnu -mcpu=ivybridge -iterations=100 -noalias=true`,
exited0, emitted empty stderr and reported exactly500/700 instructions.

Two model processes cost0.0323s elapsed/0.0284s CPU; guard wall0.453s with94.60MiB
sampled peak process-tree RSS and40KiB allocated output. CPU2,2s per-call and30s
whole-job limits,16MiB disk budget,2GiB RSS cap,16GiB available-memory floor and
5GiB disk reserve applied. Root granted the shared-lock gap after its unrelated
broad-runtime job stopped; no performance target overlapped. The run is sealed
`completed` with a verified archive under
`selfhost/build-retention/phase195-hardware-prospective01`, no pruning.

Next validation must check emitted candidate instructions and then paired target
runtime under the same workload. The four historical pairs remain a separate
[retrospective](results-2026-11-20.md); this fifth comparison adds a prospective
model hypothesis, not another measured model-versus-runtime outcome.
