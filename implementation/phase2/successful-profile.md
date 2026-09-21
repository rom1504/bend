# Successful-compilation CPU profile

A bounded profile of `tests/flatten/literal_rows_cubic.bend` gives a concrete
optimization target for the self-emitted compiler: its generic application,
forcing and global-lookup helpers account for about **49.4% of recorded leaf
sample time**. This corroborates the runtime cost already seen in phase 1; it
does not justify repeating the same guarded direct-call experiment. It does not explain
the full compiler's self-compilation gap or establish that a 10× improvement is
available.

Both unchanged final compilers accepted the same pinned fixture and emitted
exactly the same 140,593-byte JavaScript program, SHA
`0bf940c282c816b20fae6f7707d2d6df9f11eecafcb0424dd042dacd13b176cf`.
Execution exited 0 and matched all five expected output lines. Recorded inputs
remained unchanged. The [compact evidence](evidence/successful-profile.json)
contains source, bootstrap/proof, API, Base, runtime, host, configuration and raw
profile hashes, exact commands, sampled functions and caller attribution.

## Scope and controls

The two fresh processes ran sequentially on CPU 3 with Node 24.18.0, a 4 MiB
Node stack, a 4 GiB heap ceiling and `--cpu-prof --cpu-prof-interval=1000`.
Each compilation had a 180-second deadline. The canonical pinned Base's real
validated cache was prepared before profiling each compiler. B1 is API
`794cbf5f…`, emitted by pinned upstream; H is the final self-emitted stage 2,
`0b2b86ab…`. Both implement frozen source `266933eb…`; the completed fixed-point
proof identifies H's matching stage 3.

The existing `native-graph-measure.mjs --host` worker was used without edits.
It disables detailed diagnostic-presentation exports, so this is explicitly an
**accepted-program path**, not a diagnostic conformance experiment. Normal
successful checking and compilation remain enabled. Raw requests, logs, emitted
programs and CPU profiles stay in `selfhost/build/phase2/successful-profile/`.

Profiling perturbs execution, and the generated call trees produced unusually
large raw profiles (about 333 MiB and 469 MiB). Instrumented process times were
74.8 seconds for B1 and 144.6 seconds for H, including startup and profile
publication. **These are not an unprofiled speed comparison.** One fixture and
one profile per compiler are sufficient to choose a next probe, not to claim a
representative speed ratio.

## What the samples show

Percentages below are exclusive leaf attribution, weighted by V8's sample time
deltas. Inclusive call-tree entries overlap and are retained separately.

| Sampled work | B1 | H |
| --- | ---: | ---: |
| Garbage collector | 24.60% | 7.49% |
| `run_loop` trampoline | 15.26% | — |
| Three `String.cmp` workers | 17.33% | — |
| `apply` | — | 31.61% |
| `force` | — | 6.81% |
| `call` | — | 6.18% |
| `get` | — | 4.76% |

B1 additionally spends 3.80% in `kt`, 2.03% in `subst_node`, and 3.33% in the two
listed `String.eq` workers. Its generated string comparison recursively splits
strings and builds tuple results. This is a specific representation/allocation
hypothesis; the profile does not attribute GC allocations to those functions.

H's `apply` handles saturation and currying and copies argument arrays before
calling a worker. `force` handles trampoline/build results, while `get` performs
global lookup and evaluates zero-arity globals. These are actual runtime helpers
in the unchanged emitted artifact. Matcher callbacks, `project` and `fields`
also appear prominently. GC is visible in both runs, but the sampled GC share
alone does not identify allocation sources, memory retention, or why H is slow.
V8 inlining and native operations further limit precise source attribution.

## Prior experiments constrain the next step

[Phase 1 already tested this apparent dispatch opportunity](../phase1/rapid_performance_experiments.md#round-1-calls-and-index).
Its guarded transform replaced **10,248 saturated call sites and 1,872 tail
sites**, yet improved the measured whole compilation only **1.03×**. A second
[guarded positional-worker experiment](../phase1/rapid_performance_experiments.md#round-2-positional-workers-and-combined-upper-bound)
gave **1.05×**. Both kept live global lookup, relevant guards, forcing and
stack-safe tails; the positional version also guarded worker identity and
environment. Their workloads and artifact differ from this profile, but those
completed interventions are stronger evidence about the unchanged proposed
transform than a large sampled runtime percentage.

The new profile therefore does **not** justify repeating that same ablation or
promising its sampled share as a realizable gain. It also does not establish that
remaining guards or global lookup can safely be removed. A more aggressive
compiler-owned worker contract would be a materially different semantic change,
requiring a precise ownership/identity argument before implementation.

## A distinct bounded next hypothesis

For a distinct successful-compilation probe, investigate B1's **string
comparison representation and operation count**.
The previous call transforms changed dispatch; they did not remove the recursive
`String.cmp` splitting, tuple reconstruction and comparison work now sampled at
17.33% across three workers. Count calls, compared code points and equal-prefix
lengths on a frozen input, then isolate that component from its caller dispatch.
A disposable comparison variant can test whether reducing those operations or
temporary results matters before changing any compiler source.

Use the unchanged comparison as an exact oracle, including returned strings and
ordering results, empty/prefix cases, BMP and astral characters, and malformed
UTF-16 behavior. JavaScript code-unit ordering must not silently replace the
language's character ordering. Require exact emitted bytes and program output
before measuring fresh unprofiled compilations. This targets a different cost
than the prior guarded-call experiments and does not assume that sampled GC was
caused by comparisons.

Keep this experiment bounded. Neither the 49.4% dispatch sample share nor the
17.33% comparison share demonstrates a 10× opportunity. Larger gains may need
changes to representation, allocation or algorithms, established by separate
interventions. Profile frozen checking/annotation and full-source emission before
extending this single fixture's observations to the self-compilation workload.
