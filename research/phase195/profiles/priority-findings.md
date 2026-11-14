# Current Phase194 ray64 and editdist physical costs

Fresh `profile-priority02` captures show that ray64 has material table-helper
and runtime-operation work, while editdist is dominated by its generated row
worker. This supports testing the existing certified table-call plan on ray64
and inspecting selection/register transport inside editdist's loop. It does
not identify a single common removable overhead or establish a future speedup.

The retained Phase194 candidate/C/QBE products, exact runtime arguments and
independent result/count oracles are bound by
`selfhost/build/phase195/profile-priority-plan01/plan.json`. Root executed the
fresh retry after the original priority01 disk-admission refusal; that failed
receipt remains separate. Offline `normalize.py` reran the maintained comparator,
verified outputs/identities and checked each repetition denominator against its
frozen command. Results are in `profile-priority-plan01/per-invocation02.json`.
No target ran during this interpretation.

| Case | Candidate CPU µs/invocation | C | QBE |
| --- | ---: | ---: | ---: |
| active-ray64 | 281.928 | 109.284 | 103.513 |
| editdist | 2279.201 | 842.507 | 1060.740 |

These are single clean-process CPU observations divided by role-specific
repetitions, including startup, four warmups and output. They describe the
profiled work; Phase194 runtime02 remains the paired performance authority.

## Ray64: table calls, float transport and sqrt dispatch

| Physical candidate leaf | Weighted share | Estimated µs/invocation |
| --- | ---: | ---: |
| `$product.nearest` | 38.30% | 107.970 |
| `$direct.nearest.t` | 13.32% | 37.543 |
| `$product.trace` | 10.55% | 29.733 |
| `p111_rt_op` | 10.39% | 29.289 |
| `$direct.sr` | 8.30% | 23.387 |
| `$direct.sy` | 5.34% | 15.044 |
| `$direct.sz` | 5.13% | 14.467 |
| `$direct.sx` | 4.01% | 11.316 |
| `$direct.pixel` | 4.47% | 12.603 |

The four table helpers total approximately **64.214 µs, 22.78%** of the request.
Current `sr` machine code reserves a `0x8f0`-byte frame, executes an index compare
chain, and returns literal bits through repeated restore/return sequences.
The `sr`/`sz` prologue entries appear among hot sampled PCs. This is evidence
that the table-call boundary executes; it is not a dynamic count or proof that
the entire physical helper time can be removed.

The nearest worker's hot PCs include `0x409e98` (`movaps xmm3,xmm2`),
`0x409f07`/`0x409ecf` (`movaps xmm6,xmm2`) and `0x409efb`
(`movd r13d,xmm7`): floating-register copies and bank transfer remain visible.
Two static runtime opcode families (`0x24`, `0x19`) are passed at retained
nearest call sites. Runtime PC `0x4218fa` follows `sqrtss xmm0,xmm0` at
`0x4218f6`, then jumps to the shared float return at `0x420fc0`; dispatch and
epilogue PCs are also sampled. Consequently all 29.289 µs of `p111_rt_op`
cannot honestly be called dispatch waste or sqrt cost alone. QBE's separately
resolved sqrt library leaves total approximately 6.046 µs; its nearest,
nearest.t and trace cost 58.641, 22.895 and 10.835 µs respectively. C inlines
work differently, so absence of table-named leaves is not zero table work.

## Editdist: the row loop dominates

Candidate `$product.row` is **98.02%, approximately 2234.072 µs/invocation**;
the QBE counterpart is 97.97%, approximately 1039.249 µs. Candidate `dp`, `prng`
and allocation leaves are small (29.464, 9.697 and 5.967 µs). C's generated
`WL_FID_$direct.pair` worker takes approximately 841.428 µs. The generic
`scheduler` label applied to this C symbol is a naming heuristic: this is
generated computation, not evidence of 99.87% scheduling overhead.

Candidate hot row PCs include:

| PC | Actual current instruction |
| --- | --- |
| `0x40cc28` | `mov QWORD PTR [rbp-0xb58],r11` |
| `0x40cc51` | `mov DWORD PTR [rdx+r11*4],eax` |
| `0x40cbe2` | `cmovb r11,rax` |
| `0x40cbe6` | `mov r8,r11` |
| `0x40cc1d` | `mov r11,QWORD PTR [rbp-0xb40]` |
| `0x40cc16` | `mov rax,QWORD PTR [rbp-0xb30]` |

Across executable PCs, 32.79% of editdist's weighted samples land on instructions
with explicit RBP/RSP memory operands, versus 14.04% for ray64. This syntax
classification excludes implicit push/pop traffic and does not distinguish
allocator spills, private temporaries, product slots or ABI storage. It measures
sampled instruction locations, not memory stalls, traffic or dynamic instruction
counts. Static slot provenance is required before calling these removable spills.

Exact ELF disassemblies, the weighted PC join and input hashes are retained in
`research/phase195/profiles/hot-pcs/`. The PCs were joined by ELF address against
`objdump -d --no-show-raw-insn -M intel` of the exact candidate binaries.

## Quality and remaining uncertainty

All six pools are adequate under the maintained comparator, with 617–650 samples,
both 8/13 ms periods, zero rejected captures and zero drops/overruns. Sampled
thread CPU coverage is at least 99.99958%. All individual captures are below
500 samples, so the original `profilesUsable=false` remains correct; pooling
identical role commands uses the existing policy rather than changing a gate.
All pools have zero unknown samples except C editdist (one, 0.128% weighted),
which fails an additional historical zero-unknown rule but passes generic
pooling. Unknowns stay in the denominator.

Sampled/clean wall ratios span 0.9874–1.0035. Ratios below one are measurement
variation, not negative overhead. One clean observation, two fixed sample
periods and roughly 650 samples support large physical categories, not exact
causal attribution, confidence intervals, inclusive source costs or stall counts.

The optional three-case batch now has a fresh
`profile-remaining-plan01/execution02.json`: remaining02 capture/guard roots,
the original immutable workload manifest, 180 seconds and 64 MiB. Priority02's
complete eighteen-process capture occupies 1,921,024 allocated bytes plus a
16,384-byte guard; this supports the bounded 27-process continuation without
changing the free-disk reserve. Root still controls admission and execution.
