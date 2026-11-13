# Closure regression: identical worker, changed placement

The measured regressions remain real results in the full score: closure64 is
9.643% slower than Phase191, and closure256 is 26.367% slower. The candidate
remains respectively 0.10033× and 0.09741× the retained C time. These advantages
over C do not cancel or excuse the baseline regression.

Offline disassembly of exact Phase191 `native45-02` and Phase192
`selected-build01` products found **identical complete bytes** for the repeated
`p113d_FID_$p121.callback.bench` worker in both closure cases and both versions:
102 bytes, 28 instructions, SHA-256
`88558e5bc67ffc65834a02f37353074e3ec2e40476dda0279fe89de0dd1bb9f6`.
The worker already specializes the dynamically sized closure pipeline into a
countdown and U32 accumulator. Its loop performs no call or heap allocation.
The 0x8f0 frame, argument transfers, arithmetic, local branch displacements and
return sequence are unchanged.

| Region | Phase191 address | Phase192 address |
| --- | --- | --- |
| Callback worker entry | 0x4083d6 | 0x408358 |
| Repeated loop compare | 0x4083f7 | 0x408379 |
| Loop exit branch | 0x4083fe | 0x408380 |
| Loop backedge | 0x40842b | 0x4083ad |
| Outer repetition/validation worker | 0x408bd0 | 0x408b3b |

The callback moved backward 126 bytes. Its compare and exit branch therefore
occupy different fetch boundaries: the new branch starts exactly on a 32-byte
boundary whereas the prior branch crossed one. This is a concrete placement
witness, not a demonstrated CPU mechanism. No counters, controlled alignment
experiment or new timing run was acquired. The outer repetition/validation
worker remains 54 instructions and its complete instruction/operand sequence
matches after replacing absolute branch/call addresses with symbol-relative
targets. Its call still targets the identical callback. There is no observed
increase in repeated semantic work on this direct path.

The only added H worker in each closure product is String.length. Other changed
functions are string support, three generated SCC helpers and a continuation;
these move the unchanged callback and outer worker in the image. This supports
code placement or other execution-environment sensitivity as the leading
explanation, but it does not prove that placement causes the entire regression.
The available static evidence cannot exclude effects outside these workers.

The very favorable C ratio comes from an existing representation difference.
The retained C product still has `$direct.chain` (566 bytes), `$direct.compose`
(162 bytes) and `$direct.bench` (164 bytes), with heap/free-list and continuation
work. In closure256 C, direct.bench at 0x9b30 branches into chain at 0x9c40 and
contains a heap allocation miss path at 0x9bc3. Chain has heap allocation miss
calls at 0x9d7f/0x9e5c and ownership wrapping at 0x9c9d/0x9e43. The x86 callback
specialization predates Phase192; it must not be credited as a new H gain.

Source/result equivalence is retained by the existing independent-oracle
receipts. Exact object equality is asserted only for the callback's 102 bytes,
not whole products. The timing values above come from
`selfhost/build/phase192/runtime-summary01.json`: closure64 baseline/candidate
70.000/76.750 ns per repetition; closure256 244.526/309.000 ns. These are
normalized repeated-workload measurements, not standalone function-call clocks.

Inspection used `objdump`, Python metadata reading and byte hashing only; no
compiler, target, profiler, alignment tuning or production edit ran. Reproduce
with `objdump -d --disassemble=SYMBOL` on
`selfhost/build/{phase191/native45-02,phase192/selected-build01}/coverage-closures-{64,256}/machine/program`.
The function symbol is the decimal-byte encoding of `$p121.callback.bench`
after `p113d_FID_`. Preserve both regressions in the aggregate and retain this
placement hypothesis as a bounded future diagnostic, not a corrected metric.
