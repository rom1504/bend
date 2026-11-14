# Hybrid: actual emitted mechanism

The hybrid changes useful machine code in several families, but barely changes
the dominant edit-distance loop. It merits a bounded runtime screen for tree,
lexer and ray coverage; these static results do not support an edit-distance
parity claim.

`compare-machines.py` authenticated all six baseline/hybrid program hashes,
build and oracle receipts, and matching program source/expected-output pins.
Baseline is Phase194 native45-02; hybrid is Phase195 hybrid-dev-build01. The
hybrid preparation uses Phase194 selected-source02, replacing only
`x190_j_checked` through overlay-v3. No selected-analysis projection is composed.
The comparison only invokes objdump and reads artifacts; it runs no target.

| Actual emitted owner | Instructions, baseline→hybrid | Frame-reference instructions, baseline→hybrid |
| --- | ---: | ---: |
| editdist/local-pair p113d product.row loop | 77→74 | 20→19 |
| ray p113d product.nearest largest cyclic component | 578→579 | 129→117 |
| ray p113d direct.nearest.t largest cyclic component | 468→468 | 83→71 |
| tree p114r direct.warp largest cyclic component | 341→322 | 110→85 |
| tree p114r direct.warp whole function | 557→496 | 193→133 |
| lexer p113d product.step.at whole function | 638→562 | 174→131 |
| shared borrowed String.order.go cyclic component | 203→188 | 48→29 |

The edit owner is the exact p113d worker accounting for98.02% of previously
sampled CPU, not the identically named cold p117v fallback. Its entire loop
diff is the final store index `p113a_4_index`: a five-instruction sequence using
R10/R11 and storing to `[rbp-0xb60]` becomes `mov rdi,rsi; and rdi,r13`; the
following element store addresses through RDI. Three instructions and one
frame store disappear. All other loop instructions are identical after
normalizing branch addresses. The second regionally eligible name does not
produce another actual hot-loop change.

The cold p117v row's exact whole-function counts are481→418
instructions and167→84 frame-reference instructions. These much larger static
reductions must not be attributed to the98% hot p113d owner.

Ray trace, pixel and direct.trace have unchanged counts. The profiled nearest
and nearest.t owners do remove frame references, although their instruction
counts barely change; register moves and floating-bank transfers still matter.
The numeric recurrence worker does not change: only shared argument/string
helpers change in that product. The tree and lexer reductions affect relevant
worker functions, but this audit does not supply their dynamic CPU shares.

Counts include explicit RBP/RSP-reference instructions, not memory transactions,
stalls or elapsed time. Loop counts are the largest strongly connected component
of intra-function instruction control flow. They reproduce the independently
recorded77/20 baseline edit loop, but are not dynamic path counts for arbitrary
branching loops. Whole-function counts include setup, exit and prologue work.

Full pinned results: `machine-comparison01.json`. To add completed pool products
without executing them, run the same offline script with
`pool=/absolute/path/to/pool-dev-build01` and save a new report. It refuses partial
acquisitions or mismatched program sources/oracles. No claim about added compiler
analysis time is possible from these static comparisons alone.
