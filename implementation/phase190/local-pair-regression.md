# Local-pair held-out regression: bounded static audit

The held-out `local-pair` candidate is 1.133934× baseline in the recorded broad
screen: median 1.886792 versus 1.663934 milliseconds per repetition. Its three
candidate samples are 1.896226, 1.886792, and 1.783019 ms; baseline samples are
1.770492, 1.663934, and 1.647541 ms. Neither dispersion gate is flagged.
These timing observations come from root's
[`broad-summary01.json`](../../selfhost/build/phase190/broad-summary01.json);
this audit performs no new target execution.

The machine evidence supports **worse placement of frequently consumed address
temporaries as a plausible cause**, despite substantially fewer total loop
instructions. It does not establish the cause or quantify the contribution of
placement, branch behavior, instruction scheduling, or code layout.

## Authenticated products and static scope

| Product | Bytes | SHA-256 |
| --- | ---: | --- |
| Phase188 frozen baseline | 223160 | `deecc3b017357628f693fd05b5d2230fc457041143d68a949446f556698fb98c` |
| Phase190 `native45-01` candidate | 210864 | `642c3c0fa6ef8e979657a49a1be28ae5fc3f07256c549a8618e15d02afc6cfe0` |

[`machine-audit-local-pair01/report.json`](../../selfhost/build/phase190/machine-audit-local-pair01/report.json)
pins both binaries, exact nm/objdump tools, all selected function instructions,
and raw disassembly. The candidate acquisition report was complete before
inspection. Counts below use the shared audit definitions: explicit frame
addressing, with address-only `lea` references separately identifiable. They
are not cache misses or DRAM accesses.

The source computes edit distance over 256×256 cells per pair. The product row
worker contains the complete cell arithmetic and array operations inline.
It is an expected repeated region based on source/control flow; no local-pair
sampling profile was collected to establish its measured CPU share.

## Whole functions hide the repeated-path tradeoff

| Function | Instructions baseline→candidate | Frame refs baseline→candidate | Static calls baseline→candidate |
| --- | ---: | ---: | ---: |
| `$product.row` | 453→393 | 201→169 | 2→1 |
| `$product.cell` | 536→535 | 160→200 | 5→5 |
| `$product.cell.f1` | 464→444 | 142→158 | 4→4 |
| `$direct.cell` | 185→195 | 66→46 | 5→5 |

The cell workers retain their existing runtime array-pair helper calls and
fallback operation calls. The row's two baseline calls are fallback/private
dispatch and failure handling; candidate retains the fallback call and removes
the failure block. There is **no new call on the positive row-backedge path**.
Whole-function `%rsp` staging does grow in some callers—for example direct
cell 3→27 references—but that alone does not explain a call-free repeated row
body, and dynamic selection of generic/helper paths is unmeasured.

The static CFG was enumerated from row header to its backedge, excluding exits.
There are 64 syntactic paths in each product. Predicate correlations were not
solved, so these are conservative path bounds, not measured dynamic totals:

| Positive row path | Baseline | Candidate |
| --- | ---: | ---: |
| Header | `0x40e37a` | `0x40d71e` |
| Backedge instruction | `0x40e770` | `0x40da6b` |
| Instructions | 185–191 | 142–147 |
| Explicit frame references | 52 | 54–55 |
| Moves | 135 | 97–98 |
| Calls | 0 | 0 |
| Conditional branches | 8 | 7 |

[Path-count receipt](../../selfhost/build/phase190/local-pair-path-audit01/report.json) ·
[offline derivation](../../selfhost/build/phase190/local-pair-path-audit01/derive.py).
The candidate removes many copies and Boolean/width instructions while slightly
increasing repeated frame transport. The location of that transport matters:
dependent stores and reloads appear inside the array address chain.

## Concrete placement witness

The sequence calculating and loading `prev[j+1]` occupies
`[0x40e52a,0x40e568)` in baseline and `[0x40d841,0x40d8b5)` in candidate:

| Corresponding sequence | Instructions | Explicit frame references |
| --- | ---: | ---: |
| Baseline | 16 | 2 |
| Candidate | 20 | 12 |

Baseline keeps its intermediate index, mask result, scaled offset, address, and
loaded word in `%rdi`/`%rsi`/`%r10`; its two frame reads fetch invariant mask
and base. Candidate spills/reloads the truncated index at `-0xab0(%rbp)`,
increment at `-0xab8`, masked index at `-0xac0`, scaled offset at `-0xac8`,
computed address at `-0xad0`, then stores the loaded word at `-0xad8`.
This introduces serial stack transport directly between producer and consumer.

Candidate's row exit returns four array handles from `%rbx`, `%rdx`, `%r8`,
and `%r9` at `0x40d72b`–`0x40d752`; baseline reloads all four handles from
frame slots at `0x40e3a3`–`0x40e3ce`. In the inlined positive cell body, array
accesses instead consume previously derived base/mask values. Keeping those
four handles in homes throughout the loop therefore occupies registers for
exit state while short-lived address values spill. Candidate also holds loop
count/index, the row's symbol, and a mask in homes. This is concrete evidence
of an unfavorable pressure tradeoff for this witness; it is not evidence of
an allocator correctness failure.

The next general opportunity is loop-aware lifetime placement: reserve homes
according to repeated uses and interference duration, rather than allowing
exit-only state to crowd out address temporaries. Scaled-address selection can
also remove intermediate address values. These are reusable hypotheses, not a
benchmark exception or a causal explanation already validated by an ablation.
The first held-out result remains unchanged. No source changes, target reruns,
held-out retuning, or first-capsule overwrite was performed by this audit.
