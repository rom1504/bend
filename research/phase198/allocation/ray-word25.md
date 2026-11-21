# Ordinary raytrace word 25 in the incumbent

The native45 N1 raytrace object has SHA-256 `2cdeb3aade61f853e4f9f89965a16b29525365d946039653ba1a972f8fee4ff0` and its executable has `accb612adc8820b76bb1b9b220498b001969167c0460835ae2ae07ab863e3148`. The initial observer execution recorded 344,460 and 9,024 projections in the two separate geometry arms of `$product.nearest`, plus one elsewhere. The following addresses refer to the ordinary uninstrumented executable. [Observer report](../../../selfhost/build/phase198/runtime-count01/report.json) · [Build and object pins](../../../selfhost/build/phase198/native45-01/report.json).

| Ordinary successful word-25 path | Instructions |
|---|---:|
| Caller setup at 0x40a2d6 or 0x40a83a through CALL | 8 |
| Callee at 0x425230 through indirect jump at 0x425261 | 17 |
| Jump table at 0x42d09c, case 25 goes to 0x425f70 through its jump | 4 |
| Shared epilogue at 0x425314 through RET | 9 |

The old path pushes and pops six saved registers, loads two runtime-state words, bounds-checks the primitive, dispatches through a memory-indexed jump table, checks arity, and reads the low word. Replacing that group of 38 instructions with a single register-to-register 32-bit move would remove 13,078,908 executed instructions across these two sites at the observed volumes. This count excludes the separate argument-buffer stores and result copies. Retaining a materialized buffer or spilling at the new placement changes the net count. At four instructions per cycle, the illustrative front-end scale is 3.27 million cycles for one observed ray computation. Fusion, stack and memory micro-ops, branch prediction, and overlap with surrounding code prevent converting that calculation into elapsed time.

Both arms project the low word of RBX into integer state. Their subsequent ordered distance comparisons use R13 and R14, with reversed roles in the second arm. The integer result is not on that compare's data-dependency chain. Removing the call may free registers or expose scheduling freedom. The existing square root, division and ordered-compare dependencies remain. Prior current-ray experiments predicted 15.9% fewer local cycles by improving conversion inputs while retaining DIVSS and measured whole-program paired ratios of 1.0055 and 1.0000. Neither that model nor the present static estimate measures a word-25 whole-program speedup. [Previous ray hardware model and physical controls](../../phase197/discovery-a/RESULTS.md).
