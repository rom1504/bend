# Phase41 tree profile findings

The final diagnostic run profiled only `tree-bitonic`, with one separate sampled CPU and allocation capture per role. These captures describe the final tree workload; their CPU shares are not execution speedups, their shares do not add into saved time, and allocation estimates are not exact object counts.

| Role | CPU capture | Largest self frames |
|---|---:|---|
| Phase40 checked06 | 534 samples, 121 profiled calls | `apply` 16.21%, `invokeExact` 12.89%, `warp` 11.67%, GC 8.03%, `warp_leaf` 7.69%, `bench` 5.86%, `flow` 4.67% |
| Phase41 checked01 | 527 samples, 182 profiled calls | `warp` 13.14%, `invokeExact` 12.89%, `bsort` 10.39%, two `warp_leaf` frames 9.94% and 7.74%, `apply` 6.57%, `flow` 5.39%, GC 4.71% |
| TypeScript | 538 samples, 2,015 profiled calls | `warp` 54.80%, `flow` 19.73%, GC 9.64%, `scan` 4.60%, `warp_zip` 3.90%, `post` 3.76%, `bsort` 3.39% |

The candidate reduces sampled self share in generic `apply` from 16.21% to 6.57%, while `invokeExact` remains 12.89%. `warp`, sorting, and leaf work still dominate its generated frames. The remaining dispatcher and worker shares fit the source's retained generic fallbacks and continuation structure; a single sampled profile does not isolate the causal cost of any one mechanism.

Allocation estimates per validated call are 6,243,780 bytes for Phase40, 4,779,398 bytes for Phase41, and 1,388,321 bytes for TypeScript in these captures. The candidate estimate is about23.5% below Phase40 and remains about3.4× TypeScript. These are sampled allocation estimates normalized by each role's profiled calls. The diagnostic report itself warns that allocation sample and tree totals differ; they do not measure retained heap or exact allocation events.

Receipts: [diagnostic report](../../selfhost/build/phase41/final-diagnostics01/report.json) and its [analysis](../../selfhost/build/phase41/final-diagnostics01/analysis/report.json). The CPU capture uses one 600 ms target per role with the separate profiler window and calls listed above.

## Static generated-code comparison

The Acorn analysis includes runtime and fallback code; site counts are not hot
execution counts. The source optimization can reduce executed dispatch while
increasing total code sites because guarded direct code and fallback coexist.

| Role | Bytes | AST nodes | Calls | Trampoline helper sites | Array literal sites |
|---|---:|---:|---:|---:|---:|
| typescript | 10593 | 2190 | 130 | 19 | 3 |
| baseline | 107990 | 24870 | 2105 | 183 | 1191 |
| candidate | 109624 | 25100 | 2125 | 186 | 1202 |
