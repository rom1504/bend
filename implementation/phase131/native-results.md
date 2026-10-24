# Phase131 native results

Final N2 reduces native request time by **20.92%** geometrically versus qualified Phase130 N1 across three frozen requests. Its request ratio is **1.443× upstream**, down from the same-block parent's 1.825×. All 27 output observations pass; all 18 native outputs match exactly between the two native roles.

This measures native compilation requests, not generated-program execution. Final source is `1bc5930…728f9`; measured final **N2** ELF is `2fae360…fd5dc`. Parent is Phase130 **N1**, source `995d6b4…6bdd`, ELF `a25e4c7…15c2c5`. Full SHA256 identities are in the JSON. Independent final N3 qualification has now closed (Q2=Q3, focused19 N2/N3 and ordinary45 N3). The figures here measure the actual N2 binary; N3 speed is not asserted from QBE equality. Installed selection is unchanged.

| Request | Parent seconds [range] | Final N2 seconds [range] | Upstream seconds [range] | Final/parent | Final/upstream |
|---|---:|---:|---:|---:|---:|
| lexer | 1.9146 [1.8931, 1.9282] | 1.5465 [1.5425, 1.5604] | 0.7153 [0.6933, 0.7244] | 0.8077 | 2.1619 |
| coverage-closures-256 | 0.4717 [0.4677, 0.4730] | 0.4152 [0.4122, 0.4186] | 0.5105 [0.5078, 0.5281] | 0.8803 | 0.8134 |
| coverage-map-churn-128 | 2.7714 [2.7608, 2.7911] | 1.9273 [1.9158, 2.0742] | 1.1278 [1.0635, 1.1887] | 0.6954 | 1.7089 |

All three final ranges are below their corresponding parent ranges. These are three-sample descriptive ranges, not confidence intervals.

| Clock, geometric ratio | Final/parent | Final/upstream |
|---|---:|---:|
| Compiler child request | 0.7908 | 1.4430 |
| Machine-build child sum | 0.9926 | 0.1004 |
| Request + machine children | 0.8017 | 0.7150 |
| Ready executable with between-stage harness | 0.8215 | 0.7635 |

The request clock includes startup, source/input reads, Base preparation, output and exit; authentication/reporting are outside it. Ready-child sums exclude Python bookkeeping and output execution. Ready-harness time starts after preflight and includes between-stage bookkeeping. Native emits QBE using prepared compact Base/cached runtime; upstream Bun emits C using source Base and rebuilds its runtime with Clang. The ready-workflow advantage is not same-format request parity.

Earlier FAST block, kept separate: qualified FAST **N1** (`7f79529…d22fd` source) used 0.9389× parent request time (6.11% lower), 1.7038× upstream request time and 0.8053× upstream ready-child time. That block's parent/upstream was 1.8147×. Different compiler sources, generations and observation times prevent treating this as an interleaved final-versus-FAST comparison.

Full final-source requests, one observation each: Phase130 N1 acquired Q1 in 489.619s native child time; final N1 emitted Q2 in 393.599s (0.8039×; 19.61% lower). CPU times were 489.617s and 393.598s. Q1 and Q2 differ as expected for new codegen policies. Acquisition overlapped CPU6 work, so this single pair is supporting evidence, not a controlled gain estimate. Final N2 then emitted Q3 in 379.228s (3.65% lower than N1 in this single pair), and Q2=Q3 now passes the independent binder.

Same-source compiler generations were also measured in a separate rotated 27-observation block. Both execute source `1bc5930…728f9`: N1 ELF `57b6f168…e7c3a`, N2 ELF `2fae3602…fd5dc`. N1 was built from parent-emitted Q1; N2 from final N1-emitted Q2. Runtime, machine tools, carrier and requested programs are unchanged.

| Same-source request | N1 seconds [range] | N2 seconds [range] | N2/N1 |
|---|---:|---:|---:|
| lexer | 1.7326 [1.7287, 1.8504] | 1.5497 [1.5430, 1.5690] | 0.8945 |
| coverage-closures-256 | 0.4516 [0.4414, 0.4620] | 0.4240 [0.4125, 0.4302] | 0.9389 |
| coverage-map-churn-128 | 2.2572 [2.2483, 2.2718] | 1.9181 [1.9104, 1.9213] | 0.8498 |

N2 uses **0.8936× N1 request time (10.64% lower)** geometrically, with all three observed ranges below N1. Both native generations emit exact identical QBE for these requests. N1/upstream is 1.5966× and N2/upstream 1.4268× in this block. This demonstrates benefit from the compiler's generated code with compiler source fixed. It does not yet measure increased subsequent optimization-research throughput.

Selected final compiler: **57,842 physical lines / 41,855 code lines**, 6,529 unique declaration names; 2,667,581 bytes. Versus Phase130 this is +824 physical / +636 code lines / +53,993 bytes, with 86 added names. Literal exposure also rewrites existing declarations: 302 normalized bodies differ. These are selected compiler-source counts; external laws and harnesses are excluded, selected control/reference helpers included. Declaration counts are not counts of concepts or proven laws.

Evidence: [final timing analysis](final/timing-summary.json), [raw final observations](final/timing-report.json), [separate FAST analysis](fast/timing-summary.json), and [exact identities / all clocks](native-results.json).

Literal exposure accounts for 419 replacements in 285 declarations and 17,179 bytes, without changing declaration or line counts. The final N2 image is 17,132,048 bytes (3.29% larger than Phase130 N1).

Additional evidence: [same-source stage timing](final/stage-timing-summary.json), [final qualification](final/native-qualification.json), preserved local provisional cutoff `selfhost/build/phase131/native-results-provisional01/report.json`.
