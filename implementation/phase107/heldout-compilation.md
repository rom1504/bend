# Held-out compilation cost

The fixed native Bend/QBE path takes **36.4–38.6% less source-to-executable wall
time** than the installed native Bend/C/Clang-O2 path on these three new source
families. All nine alternating pairs, 18 fresh builds and 18 exact main outputs
pass in the [completed receipt](../../selfhost/build/phase107/heldout-latency01/report.json).
No source, oracle, method or optimization policy was adapted after the timing
freeze, commit `86de36c`.

| Source | Installed C/O2 median, s | Native QBE median, s | Native / installed | Shorter |
| --- | ---: | ---: | ---: | ---: |
| Bounded subtraction GCD | 0.673388 | 0.424523 | 0.630428 | 37.0% |
| Non-tail triangular sum | 0.682814 | 0.419534 | 0.614419 | 38.6% |
| Saturation and piecewise helpers | 0.673789 | 0.428572 | 0.636062 | 36.4% |

Each median has three samples. The geometric mean of the three median ratios is
0.626903; all three are below the stated 0.75 finite compilation-cost threshold.
Order reverses across rounds and sources. Every object is rebuilt, with no object
cache. The prior [source gate](heldout-source-gate.md) independently checked raw
and fast behavior across 196 boundary-input executions; this timing experiment
uses only the fixed fast policy and zero-argument `main`.

The primary clock sums complete compiler subprocess walls. Installed Bend emits
C and pinned Clang22 builds it at O2; native image04 emits QBE, then the driver
assembles and links it with the common runner. Both use prepared Base. Native
driver wall includes Python startup and authentication; installed Bend performs
its own asset authentication. One-time tool/input/version auditing and image
acquisition are outside these pairs. Full supervisor intervals and component
clocks are retained separately. This compares complete interfaces, not isolated
compiler algorithms or host-language overhead.

Adding the validation executable's process wall gives source-to-result median
ratios 0.631026, 0.615182 and 0.636779, geometric mean 0.627596. Each execution
must print exactly its independent main answer plus one LF, with empty stderr:
GCD `1`, triangular `1234698706`, saturation `2147483647`.

These are compilation measurements on sources whose `main` passes fixed
constants. Constant inputs can enable different simplifications in each path;
the retained QBE still contains the triangular recursive call, while the
saturation helpers are inlined. Neither shape inspection nor the roughly
1.6–2.9ms validation processes establish emitted-program throughput. The result
does not measure a repeated GCD, recursion or saturation runtime workload.

The [freeze manifest](../../selfhost/tools/performance/phase107/heldout-latency-freeze.json)
pins 33 inputs and the earlier correctness receipt; the
[thin wrapper](../../selfhost/tools/performance/phase107/heldout-latency.py) reuses
the existing paired orchestration. A read-only audit matched all 135 recorded
input/product pins and all 46 subprocess logs, including the 18 exact outputs.
The [external CPU3 guard](../../selfhost/build/phase107/heldout-latency-guard01/process.json)
completed successfully in 15.458499s, with 182,267,904 bytes peak process-tree
RSS. The reused method recorded 14.123300s including 1.978872s setup; the outer
guard also includes wrapper authentication and surrounding process overhead.

This supplies final held-out compilation-cost evidence after source correctness.
It does not retroactively make earlier policy-search inputs held out, establish
a universal speedup, or qualify the entire compiler. The three-source sample is
small; the raw per-round observations remain available for review.
