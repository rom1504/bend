# Independent diagnostic-runtime control

`runtime-control.c` is a byte-identical copy of the Phase112 frozen independent
ABI fixture, SHA256 `41bfdd1aaf6943a0f61a6ada8365e8cd27ca21c9a85e316fbbe988339c369721`.
Its original `control-freeze.json` predates this profiler. Its result is
`(7 + 5) * 3 + 9 = 45`, with exact stdout `45\n` and empty stderr.

`runtime-control.expected.json` was written before this profiler control was
run. The expectations follow the fixture and the audited uninstrumented
Phase126 runtime, not observed counter output:

- Dispatch visits runtime ENTER(6), first(0), second(1), continuation(2), and
  runtime EXIT(5) once. No IO_EMIT(3) or closure APPLY(4) is needed.
- Before dispatch, `task_node` allocates the two-word main-task header. The
  initially empty class1 lane refills once. These events have unknown FID.
- ENTER frees that two-word task. First then constructs and takes a two-word
  raw Tuple, reusing the available class1 lane; this needs no second refill.
- First performs one scalar keep and sink, one take, one primitive add, and
  one frame containing one captured word. Its jump copies two register words
  and clears none at transport width2.
- Second multiplies once and returns one word, copying one and clearing one.
  Continuation adds the captured9 directly in C, then returns one word with
  the same copy/clear counts. EXIT delivers the scalar root and printing uses
  no additional hooked allocation or ownership operation.

Thus totals are five dispatches, two allocations/frees (four words each), one
refill, one keep/sink/take/frame, one captured word, two primitives/returns,
four register-copy words and two register-clear words. Every other per-FID
counter is exactly zero. `term_drop` is zero because all owned fields and the
explicit kept/sunk value are immediate scalars. This verifies a negative
drop-counter control, **not positive coverage of the drop hook**.

`check-runtime.py` accepts `--runtime-plan PLAN --build-report REPORT --out
FRESH_OUT`. It links this tiny fixture to the retained diagnostic runtime.o,
then runs with counters disabled and enabled. It checks all16 counter channels
per FID, zero invalid contexts/overflow, the descriptor/storage dimensions,
disabled allocation/rows, and exact independent output in both modes.
Compilation and execution must be under the root's resource guard on CPU3.
The script snapshots source/expectations before execution, records commands
and identities, kills/reaps owned children on timeout/interruption, and retains
failures. Neither a passing control nor these counts demonstrate compiler
correctness, profile sample attribution, logical ancestry or runtime speed.

Changed task/allocator semantics may require re-deriving this fixture's heap
expectations. Preserve the old oracle and justify a new one from source;
never update it merely to match an unexpected observed count.
