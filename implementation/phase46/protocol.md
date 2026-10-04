# Phase46 execution protocol and retained corrections

The frozen [design](../../design/phase46/backend-comparison.md) preceded target
execution. The production compiler remains unchanged.

- `pilot01`: retained setup failures. Upstream executable JS needs `.cjs` under
  this ESM package; selfhost output is ESM. Lean's Clang22 install puts resource
  headers in `include/clang`, requiring an explicit `-isystem` path. No compiler
  defect or timing claim is inferred from these failures.
- `pilot02` plus `expansion01`: all24 one-shot results agree exactly with the six
  maintained independent oracles. These have a pure scalar main and are cold
  feasibility observations, separate from library benchmarks and batch timings.
- `batch01`: invalid experiment source. Tuple destructuring directly inside a
  do block fails parsing in both compilers. The corrected wrapper destructures
  its options outside the do block. Original source, generator and failures stay
  in the evidence capsule.
- `batch02`: a real selfhost-native IO.args mismatch. The retained runtime starts
  io_argc at0 and io_argv at argv+1; current upstream includes argv[0]. Given
  arguments `1 0`, the old wrapper therefore chooses zero measured repetitions
  and its default two warmups only in selfhost C. The failure is not a pass.
- `batch03`: the same common wrapper now reads the final two arguments for all
  targets. This isolates the performance comparison from the program-name ABI
  difference; it does not repair or qualify that native behavior.

## Sustained workload

The batch uses a fixed16-input cycle: input i has size `size+(i&1)` and seed
`seed+(i&15)`. Each returned U32 contributes to
`h = (h*16777619) XOR ((value+i) mod2^32)`, wrapping to U32, initially2166136261.
The observer prevents dropping returned work. Every cell uses identical measured
and warmup counts; warm and measured batches start the same sequence. Independent
Python implementations supply all96 cycle results, with each point0 matching the
maintained catalog. Their fold predicts every warm/measured checksum.

The four printed lines are maintained base result, warm checksum, measured
checksum and elapsed milliseconds. IO.print of the measured checksum is between
IO.now calls, forcing computation before the second clock; formatting/output
cost is intentionally included. Process startup is outside that interval.
SelfhostJS IO.now uses Date.now; upstreamJS uses performance.now; native uses
CLOCK_MONOTONIC. All truncate to milliseconds. The harness rejects nonpositive
or implausible timing intervals and retains them without precise speed credit.

Calibration selects a shared count targeting120ms for the fastest observed cell,
with an8-second predicted slow-cell cap. It uses the same count for warmup.
Three fresh-process rounds rotate the four roles. This measures fixed-warmup
batch performance, not a proof of V8 steady state. All calibrations, clock
limitations, variation and failed samples remain visible.

Native is one CPU thread with GPU disabled; all jobs use CPU3 and the existing
exclusive process-tree guard. Node has a1GiB heap; tree RSS limit2GiB and available
memory floor4GiB. The native sparse virtual heap is not constrained by an address
space limit. Clang uses -O3 without fast-math and the same explicit resource
headers for both products. Compile/link costs are separate from execution.
