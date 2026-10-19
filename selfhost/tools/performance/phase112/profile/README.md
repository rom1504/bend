# Runtime call counts without sampling privileges

This is an optional diagnostic runtime for the **exact Phase111 runtime04**
(`c0fc18aabb2749cc85b5040c29756d8d73d90b73bb954d10ed1d0d410528aa50`).
It does not change production selection, emitted QBE, runtime ABI, or the original
runtime file. Root owns compilation, linking and execution on CPU3.

`prepare.py` inserts counters into a fresh copy. Every source replacement must
match exactly once; reversing all replacements and removing the appended report
must reconstruct every original byte. The output manifest records each edit,
the original source, support sources and every materialized file. Default
instrumentation counts public helper calls, primitive IDs, constructor identities
and arities, direct jumps, closure application, continuation captures, dispatch
targets, and register words copied/zeroed. `--heap-rc` adds actual heap and ownership
helper counts. The fixed counter storage is about 4 MiB.

The unchanged runtime admits only sequential CPU execution. Counters are plain
64-bit values and detect overflow and histogram bounds violations. They count
**source-level helper invocations**, including helpers subsequently inlined by
GCC. Nested counters overlap: `rt_ctor`, `heap_alloc` and `rfc_seal` cannot be
added as independent costs. Allocator counts include startup and final readback.
`public_calls_fid` attributes calls to the most recently dispatched segment;
it is not a native call stack or a sample of CPU cost. Register-word counters
record source copy/zero requests, not guaranteed memory traffic after optimization.

Never use an instrumented executable's elapsed time as a benchmark result.
Use counts to choose a small hypothesis, then measure an unmodified baseline
against a separately validated candidate. Existing generated program objects can
be relinked with this runtime object; no compiler acquisition is necessary.

## Materialization and the independent small control

Run from the repository root. These examples are commands for the root agent,
which applies its existing serial resource guard to target work.

```sh
python3 selfhost/tools/performance/phase112/profile/prepare.py \
  --out selfhost/build/phase112/profile-runtime01 --heap-rc
gcc -O2 -std=gnu11 -ffp-contract=off \
  -c selfhost/build/phase112/profile-runtime01/runtime.c \
  -o selfhost/build/phase112/profile-runtime01/runtime.o
gcc -O2 -std=gnu11 -Iselfhost/build/phase112/profile-runtime01 \
  selfhost/tools/performance/phase112/profile/counter-control.c \
  selfhost/build/phase112/profile-runtime01/runtime.o -lm -pthread \
  -o selfhost/build/phase112/profile-runtime01/control
taskset -c 3 selfhost/build/phase112/profile-runtime01/control \
  > selfhost/build/phase112/profile-runtime01/control.stdout \
  2> selfhost/build/phase112/profile-runtime01/control.stderr
```

The control's expected observations were written independently before candidate
execution. It computes `(7 + 5) * 3 + 9 = 45`, passes a real allocated Tuple through
take, and transports a captured value through three dispatcher segments. Frozen
selected counts include two primitive calls, one constructor/take, one frame,
one direct jump, two returns and five dispatches. Expected selected counters are
complete for all public helpers; optional internal heap/RC totals are deliberately
not inferred from candidate observations. `control-freeze.json` pins this source
and the two expectation files.

After recording the actual exit status, validate it (replace `0` with that status):

```sh
python3 selfhost/tools/performance/phase112/profile/parse.py \
  --stdout selfhost/build/phase112/profile-runtime01/control.stdout \
  --stderr selfhost/build/phase112/profile-runtime01/control.stderr --status 0 \
  --expected selfhost/tools/performance/phase112/profile/control-output.json \
  --counter-expect selfhost/tools/performance/phase112/profile/control-counts.json \
  --runtime-manifest selfhost/build/phase112/profile-runtime01/manifest.json \
  --out selfhost/build/phase112/profile-control01
```

For a real program use its independently frozen `{status,stdout,stderr}` JSON,
omit `--counter-expect`, and supply `--qbe path/to/exact-linked-program.ssa`.
The parser enumerates the unchanged `$p111_segments` relocation table, verifies
its length against the active runtime descriptor, and decodes decimal Unicode
function names. Constructor names come from the runtime descriptor; primitive
names come from the finite Phase111 catalogue. It does not parse or translate
program algorithms. Root's link/run receipts must bind the actual executable to
that exact QBE object and diagnostic runtime object; table length alone does not
establish this provenance.

`parse.py` requires zero exit status, a complete versioned report, every scalar
counter, consistent histogram totals and exact original stdout/remaining stderr.
Only validated `P112_PROFILE ` lines are removed. Duplicated/truncated records,
overflow, missing reports and changed program output fail closed. Reports use
`atexit`; fatal `_exit` paths intentionally produce no successful profile.
Repeated nonzero buckets become ranked lists in `profile.json`; original files
and source metadata are pinned in its inputs.

`parser-check.py` runs only synthetic parser controls, never a target executable.

## Frozen six-program diagnostic runner

`batch-plan01.json` binds all six products in the existing `static-binding01.json`
to their original object, QBE, build receipt, source and independent expected
output hashes. It sets repetitions to one and warmups to zero before profiling;
workload arguments remain those in the frozen benchmark manifest.

Root runs this under its ordinary CPU3 resource guard:

```sh
python3 selfhost/tools/performance/phase112/profile/run.py \
  --runtime-source selfhost/build/phase112/profile-runtime01 \
  --out selfhost/build/phase112/profile-batch01 --budget-seconds 60
```

It compiles the diagnostic runtime once, qualifies the independent counter
control, then relinks existing program objects and runs each once. Each program
must print its complete frozen result, then `0` and `1` successful warmup/repeat
counts, followed by exactly one unsigned-decimal elapsed line. That line must
fit within observed process duration; its numeric value is **never a performance
sample**. All remaining stderr must be empty. Every case receives a decoded
`profile.json`; the campaign report includes dominant buckets, exact artifact
pins, command/output receipts and explicit missing or failed cases.

The existing wrapper evaluates the workload once to print its reference value
and once inside the repetition loop. Whole-process counts therefore include
**two workload evaluations**, argument parsing, wrapper bookkeeping, effect
handling and readback. They must not be described as one kernel invocation or
compared directly with old multi-repetition timings.

## The compiler itself

`compiler-plan01.json` freezes the complete native compiler's existing object
and exact 44,349,671-byte QBE image, then copies the successful `lexer-scan`
request argv/assets from `phase111/p112-native-focused01/5-native/report.json`.
Its expected raw SSA is the unchanged 204,540-byte product of that request.

After the batch runner's independent counter control succeeds, root can reuse
the same diagnostic runtime object without recompiling it:

```sh
python3 selfhost/tools/performance/phase112/profile/compiler-run.py \
  --runtime-run selfhost/build/phase112/profile-batch01/report.json \
  --out selfhost/build/phase112/profile-compiler01 --budget-seconds 60
```

The runner requires the control profile and runtime source/object receipts,
relinks the existing compiler object, and changes only the executable path in
the frozen native request. Compiler stdout must match the original SSA bytes
exactly; remaining stderr must be empty. FIDs are decoded using the complete
compiler QBE, rather than the small program it emits. Source, object, runtime,
asset, command and output hashes accompany the resulting profile. This gives
actual compiler workload counts across request IO, frontend, lowering,
verification, emission and readback, without claiming stage times or profiling
an entire self-emission.
