# Final combined and delayed machine inspection

This offline audit inspected the already built `combined-build02` and
`delayed-build01` binaries. `machine07` and `machine06` authenticate their
disassembly; `machine06-paths/report.json` records the exact selected paths and
branch choices. No compiler, worker, probe or timing process ran for this audit.

The scenario matches `machine05-analysis.md`: one nonterminal list reverse
iteration, count1 dynamic RFC parent, already sealed retained field, raw CTR
accumulator, no allocator miss or handoff. Counts describe that path, not
hardware traces, micro-operations or cycles.

| Backend / candidate | Full worker bytes | Selected instructions | Conditional branches | Stack reads / writes | Heap reads / writes | Allocator reads / writes |
|---|---:|---:|---:|---:|---:|---:|
| QBE compact/general | 768 | 100 | 9 | 0 / 5 | 4 / 4 | 4 / 4 |
| QBE wrapper | 894 | 100 | 8 | 3 / 12 | 3 / 3 | 0 / 0 |
| QBE combined | 714 | 89 | 7 | 3 / 10 | 3 / 3 | 0 / 0 |
| QBE delayed | 658 | 79 | 7 | 0 / 2 | 3 / 3 | 0 / 0 |
| Clang wrapper | 801 | 54 | 7 | 0 / 0 | 3 / 3 | 0 / 0 |
| Clang combined | 641 | 50 | 6 | 0 / 0 | 3 / 3 | 0 / 0 |
| Clang delayed | 539 | 45 | 6 | 0 / 0 | 2 / 2 | 0 / 0 |

All selected paths are call-free. Delayed QBE actually repairs most of the
identified spill cost: its local frame shrinks from wrapper's 0x68 to 0x18 bytes,
and the spare path no longer performs the metadata shift/constant spill/reload
chain. Two unconditional stack stores remain, preserving the external top byte
and reconstructed metadata for cold paths. The redundant low40-bit mask before
the U64 shift by24 also remains. Clang additionally eliminates the retained
field's same-address load/store pair after the delayed seal; QBE retains both.

There is a scheduling tradeoff visible in the code. Compact/general QBE reads
the next owning list word at `0x401f36`, with 56 selected instructions before the
backedge. Combined reads it at `0x401f3c`, with 43 remaining. Delayed reads it at
`0x402065`, only 6 instructions before the backedge. Moving that loop-carried load
late reduces live values across cold calls but also reduces static distance
before its next-iteration use. This is a plausible latency-hiding tradeoff,
not proof of a hardware stall: out-of-order scheduling and memory dependence
prediction require hardware evidence to attribute cycles.

The frozen training decision supplies the rejection reason independently of
these counts. In `final-selection02.json`, combined QBE is 0.99708 times the
compact/general incumbent and delayed is 0.98602. Both miss the predeclared 3%
aggregate improvement and every-round improvement rule. Delayed improves the
two unique-string cases to 0.92400 and 0.91654, but its deep unique list is 1.02314,
source-derived unique list 1.00964, and shared cases 1.00597–1.01506. The narrower
selected path is therefore useful mechanistic evidence without establishing a
workload-wide win. The final QBE choice remains compact/general; Clang chooses
wrapper-only under the separately frozen backend comparison. Heldouts did not
rerank either choice.

The best conceptual next step is a self-contained eligible spare branch with
the continuation child loaded early, one wrapper encoding, and no cold allocator
call in that branch. The ordinary allocation path can retain its separate
state. That would aim to keep the reduced live state without delaying the next
owner behind reconstruction. It remains a generic ownership primitive, with
the same namespace, source admission and spare obligations; no such variant
was implemented or measured here. A separate backend algebra improvement can
remove the redundant mask, and exact alias reasoning can remove the same-word
retained-field load/store where applicable.
