# Phase93 offline method review

The reviewed harness has no blocking correctness or measurement defect for its
stated fixed-input batch comparison. The five pilot cases' inspected C and
representative optimized paths retain repeated workload evaluation. This is a scoped
review, not proof against optimization removal on all 45 points or a final runtime
result. The reviewer ran no compiler, generated program, benchmark or profiler.

The reviewed [runner](../../selfhost/tools/performance/phase93/run.py),
[template](../../selfhost/tools/performance/phase93/batch-template.bend) and
[generator](../../selfhost/tools/performance/phase93/prepare.py) preserve the
original workload bodies and catalog arguments. The final four argv values handle
both native argument conventions. Each iteration compares its entire scalar or
string result with the retained oracle and increments a success count; the generic
row adapter serializes all four 128-slot arrays. Four stdout lines expose the full
first result, warmup count, measured count and elapsed milliseconds. Counts stay
below 2^32. Native B1/B2 complete-C equality permits one shared own-backend binary;
the upstream product is independently emitted. Both use the same pinned Clang,
`-std=c11 -O3`, include path and link flags.

The [five-case acquisition](../../selfhost/build/phase93/pilot02/report.json)
contains `b2.1.c` and `upstream.1.c` in each case directory. Numeric256 and
local-pair have value calls inside their scalar repetition loops. Evening,
generic-row and record64 dispatch to the workload on each nonzero iteration;
string continuations invoke full equality before returning to the loop. No
workload result was prebound outside these emitted loops.

Root recorded six dumps of the actual O3 executables; the
[plan](../../selfhost/build/phase93/disassembly01/plan.json) binds their case,
role and symbol. The following instructions establish the relevant repeated paths:

| Retained dump | Observed optimized path |
|---|---|
| [0: upstream numeric256](../../selfhost/build/phase93/disassembly01/0/stdout.log) | Outer repetition decrement at `0x9b30` proceeds through `0x9b39` to floating recurrence instructions at `0x9b77`; inner backedges include `0x9be5 → 0x9b60`. |
| [1: own numeric256](../../selfhost/build/phase93/disassembly01/1/stdout.log) | Outer decrement at `0x9af0` proceeds through `0x9af9` to recurrence instructions at `0x9b38`. |
| [2: upstream local-pair](../../selfhost/build/phase93/disassembly01/2/stdout.log) | `call spin_26` at `0x986c` lies inside the loop whose decrement/backedge is `0x9883/0x9886 → 0x9860`. |
| [3: upstream evening loop](../../selfhost/build/phase93/disassembly01/3/stdout.log), [4: continuation](../../selfhost/build/phase93/disassembly01/4/stdout.log) | The loop decrements the count and jumps to `P93_VALUE` at `0x1aecf`; its continuation compares 81111, increments success and returns at `0x1b00b → 0x1aea0`. |
| [5: own evening loop](../../selfhost/build/phase93/disassembly01/5/stdout.log) | Count decrement precedes the workload jump at `0x43553`. Its return chain was reviewed in C; that continuation has no separate machine-code dump here. |

Both numeric products hoist invariant seed setup and an optional first recurrence step.
The remaining recurrence executes per repetition; the batch is not replaced by
its success count. All six requested symbols resolved.

Additional C-only review covers
[scalar-region-0](../../selfhost/build/phase93/broad01/scalar-region-0/upstream.1.c)
and [RLE](../../selfhost/build/phase93/broad01/test-rle-roundtrip/upstream.1.c),
alongside each directory's `b2.1.c`. Their source loops also evaluate the workload
per iteration. RLE returns through equality with 11; its review remains C-only.
The initial scalar-region-0 review left optimized behavior unresolved because
this point intentionally requests zero recurrence steps.

Subsequent [calibration](../../selfhost/build/phase93/calibrate-broad01/report.json)
preserves 74 records and 10 completed plans before its timing-floor refusal.
All 18 scalar-zero trials passed correctness but reported 0 ms, including
200,000,000 repetitions in both roles. Root's additional O3 dumps resolve the
cause: [own code](../../selfhost/build/phase93/disassembly02/own/stdout.log)
branches on zero workload size at `0x9a31 → 0x9b00`, directly adding the repetition
count to accumulated successes. [Upstream code](../../selfhost/build/phase93/disassembly02/upstream/stdout.log)
branches at `0x99af → 0x9ace`, directly moving that count into the result. Both
bypass the repetition and arithmetic loops for the actual catalog input.
This is a correctly optimized zero-work control with an unresolved submillisecond
interval, not a measurable throughput point or evidence of free execution. Its
ratio is undefined; retain it separately from any explicitly labeled 44-point
timing aggregate. No full-45 timing ratio follows.

Interpretation remains limited by the fixed input/call context. CLI-dynamic
arguments alone do not prevent hoisting; a success count alone does not prove
that work survived optimization. Three alternating rounds are not perfectly
position-balanced within each case, and ranges are descriptive, not confidence
intervals. `IO.now` uses monotonic time truncated to 1 ms; the 100 ms admission floor
reduces quantization error but does not eliminate it. The measured interval
includes result validation, success-count formatting and printing, while startup,
argument parsing, first-result observation and warmup precede it. At most 32
warmup calls are used; no JIT or long-duration steady-state claim follows. Keep
zero-work canaries explicit, and do not transfer historical JS45 or C12 ratios to
these new native batch products.
