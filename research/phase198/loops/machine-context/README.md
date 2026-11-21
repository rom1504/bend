# Pinned machine context

Every `.objdump` decodes an actual ELF object/executable whose complete identity
is in `pins.json`. `phase197-combined` uses the new Phase198 N1 ordinary products
of the unchanged Phase197 combination. C and QBE are retained independent
reference products; their compiler provenance is in the ordinary runtime plan.

| Workload / machine | Instructions per positive iteration | Frame memory references |
| --- | ---: | ---: |
| editdist / Phase197 combined | 58 | 12 |
| editdist / QBE | 44 | 4 |
| editdist / mature C | 26 | 0 |
| local-fold / Phase197 combined | 18 | 0 |
| local-fold / QBE | 17 | 0 |
| local-fold / mature C | 15 per two iterations | 0 |

Counts include loop control: the direct/QBE figures include the header CMP and
conditional branch and the backward JMP. Mature C uses a bottom CMP/JNE and the
fold loop is unrolled by two. No setup, fallback, final failed condition or exit
publication is counted. These static counts are not elapsed-time predictions.
Frame references count decoded operands mentioning RBP/RSP, not cache misses.

The direct positive bodies are 55 and 15 instructions respectively. Editdist
body `[0x752e,0x7625)` ends at its backedge to `0x74d7`; fold body
`[0x3e70,0x3ea2)` ends at its backedge to `0x3e33`. QBE backedges are
`0x408fab→0x408f10` and `0x407251→0x407220`. Mature C's counted ranges are
`[0x119a0,0x119fa)` and `[0xf880,0xf8b2)`.

All three routes already use scaled array memory operands and runtime masks for
circular indexing. The C edit loop keeps a single induction variable and compares
it with constant256; it does not carry separate fuel. It materializes mismatch
with SETNE, directly compares one memory operand and adds another memory operand
into the diagonal candidate. The current direct emitter's nine-color pool,
separate U64 fuel/U32 index, spilled intermediates, and scratch copies explain
concrete remaining work. Changing coalescing alone cannot be assumed to match C.

Historical physical attribution: Phase190's retained role analysis at
`selfhost/build/phase190/profile-role-analysis01/report.json` identifies fold's
C `NF_FID_112_57_51_46_108_111_111_112_` and product loop, while Phase195's
`profile-priority02` identifies editdist. The machine files here are freshly
pinned. Historical percentages are not transferred to different binaries.
