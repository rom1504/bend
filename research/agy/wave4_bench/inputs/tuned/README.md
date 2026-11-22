# native-tuned-v1

How fast can equivalent Bend and handwritten C implementations make the same task when both authors may change the algorithm and data structures? The pilot measures four task families from native45. It builds original and tuned handwritten C, then compiles the same original and tuned Bend sources through AGY direct x86, the installed native QBE N2 and the installed Bend-to-C N1. List fusion has an extra implementation in all four lanes. The 36 executables and the independent oracle are reusable on additional runtime inputs.

[Results by input, family and backend](RESULTS.md) · [Raw timing samples](results.json) · [Inputs, source hashes and reserved workloads](suite.json) · [Compiler and runtime identities](toolchain.json)

## First run

On one Xeon E3-1245 v2, tuned AGY took **4.32×** tuned handwritten C time with the four families weighted equally. On the historical sizes weighted by their original repetition counts, the original sources took **0.607 s AGY / 5.983 s C**, while the tuned sources took **0.582 s AGY / 0.064 s C**. These normalized times cover the nine pilot anchors under the v1 seed schedule. They cannot be substituted for the full native45 score.

The strongest contrast was edit distance. On four sequence pairs, the bit-vector algorithm cut handwritten C from 495 to 38.4 µs. The same algorithm took AGY from 521 to 578 µs. Keeping AGY's faster original source still left a 13.5× family gap. In the opposite direction, the original list pipeline at 128 elements took AGY 0.330 µs, already as fast as our hand-fused Bend loop at 0.348 µs. Hand fusion changed the C time from 14.05 to 0.158 µs. Periodic reduction then brought both languages into single-digit nanoseconds, where the timing driver matters.

All 184 additional algorithm/backend control executions and all 880 timed batch outputs passed. The reserved workloads have no result in this pilot.

## The four contracts

| Family | Observable result | Optimization applied in both languages |
|---|---|---|
| List pipeline | Generate the specified wrapping LCG sequence, keep low nibbles greater than one, double and sum in U32. | First fuse generation, filtering, mapping and reduction into one loop. Then exploit the full-period low nibble. Every 16 steps visit 0–15 and contribute 238. Evaluate only the remaining 0–15 items. The extra size 257 exercises the tail. |
| Generated expression | Evaluate the generated arithmetic expression with wrapping U32 operations. | Eliminate AST construction. Walk the seeds backwards, applying the same operations in evaluation order. The reference oracle instead composes affine functions from the root down. |
| BST and in-order hash | Insert the generated keys, preserving duplicates, and compute the hash of their sorted traversal. | All keys are in 0–256 and no tree escapes. Count each key, then fold the histogram in order. The oracle sorts the generated words independently. This measures the observable task and does not measure the cost of returning a usable BST. |
| Edit distance | Compute unit-cost Levenshtein distance over each generated pair of 256-symbol sequences and return the original batch checksum. | Use the Myers bit-vector recurrence in eight 32-row stripes. Pass horizontal score differences between stripes. The independent oracle computes the ordinary scalar dynamic-programming matrix one row at a time. |

These are shared tuning attempts. A source form marked “tuned” identifies the algorithm we tried even if a backend executes its original faster. The list period optimization and the bounded-key histogram rely on the public input generators. Results for either should only be extrapolated to tasks with the same properties.

## Timing and validation

- Nine points retain native45's size, first seed, independent scalar answer and reference repetition weight. A tenth is a new nonmultiple-of-16 list size. The original Bend kernel prefix is taken from the pinned fixture and the new driver appended. The original handwritten C kernel is compiled from its existing source.
- Each executable takes the repetition count, warmup count, size and seed at runtime. A timed call uses the given size and seed plus a multiple of 2654435761 modulo 2^32. The seed index cycles over 0–31. Every calibrated count is a multiple of 32, so each implementation sees exactly the same seed distribution per call.
- Drivers print the first result, the warmup checksum, the measured checksum and elapsed milliseconds. The host computes the 32 expected values independently, composes the wrapping polynomial checksum, and checks all three outputs on every run. The first result at each historical point also has to match the preserved native45 oracle. The independent controls include empty structures, duplicate keys, non-aligned lengths and U32 wraparound. These are finite correctness checks.
- Each executable warms up for a full 32-seed cycle. Calibration targets at least 72 milliseconds per sample. A balanced Latin square puts each executable in every timing position once, with eight samples per role and input, or twelve on the list family. Each sample is a fresh process pinned to the same physical machine's logical CPU 3. Executable construction and warmup are outside the internal timer. The batch checksum and one print are inside it. Per-call time includes loop overhead, which matters for the cheapest algorithms. Handwritten C calls a kernel in a separate translation unit without LTO. Each Bend backend can optimize its whole program. The resulting times include those code-generation choices, which can dominate differences of a few nanoseconds.
- Family comparisons give each historical size equal log weight within its family, then each family equal log weight. The separate fixed-work estimate weights per-call times by the historical repetition counts and excludes the added point. Both scores describe this pilot's rotating-seed workload. Continue to use the original native45 score for longitudinal comparisons.

The preliminary fixed-input harness passed all controls but one product still failed the minimum-duration calibration at 100 million repetitions. That trial produced no usable speed score. The first rotating-seed run was stopped after two cases when filesystem usage exceeded its 24 MiB guard budget. The complete run used a larger disk allowance with the same 5 GiB free-space reserve. The published results come from that single complete rotating-seed run.

## Holdout and versioning

BFS, Merkle and k-means are reserved as whole workloads for a future transfer test. The manifest pins both upstream source files for each. Their results were not inspected or used to tune this pilot. They come from a public repository and cannot establish blindness for every previous compiler author. An externally selected, previously private task would provide a stronger transfer test.

The contract pins the kernel and driver sources. Keep v1 for comparisons against these measurements. Add a new version for changes to the scored algorithms, input distribution, result contract or time boundary. Compiler versions may change when they are the variable under test. The pilot does not alter the native45 catalog, kernels, or scoring.

## Reproduce

Run from the repository root on the retained machine and use fresh output names. The installed C and QBE lanes use the repository's verified asset manifest. AGY uses the Wave 2 hosted emitter with its matching native runtime. Handwritten C uses retained Clang 16, C11 -O3, no LTO and no floating-point contraction. This benchmark uses single-threaded CPU execution. Source and executable identities accompany the recorded results.

```sh
b=selfhost/tools/bench/native-tuned-v1
j=research/phase201/cold/job.py
r=selfhost/build/phase201
python3 -B "$j" tunedrebuild 620 320 python3 -B "$b/build.py" OUT
python3 -B "$j" tunedremeasure 540 768 python3 -B "$b/measure.py" OUT "$r/tunedrebuild"
python3 -B "$b/report.py" "$r/tunedremeasure/results.json"
```

For a shorter cycle, append `--families expression` (or `list`, `bst`, `editdist`) to both build and measurement commands. The build accepts `--roles` to split acquisition into smaller jobs. Pass the resulting product directories together to the measurement command, which requires all four roles for each selected family and checks that the three Bend targets received identical source bytes.
