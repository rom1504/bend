# Phase46 generated-code findings

The native diagnostics support two concrete explanations for the selfhost C
gap: retained curried calls/continuation dispatch, and heap allocation of
intermediate tuples and captures that upstream transports as scalar values.
They do not support whole-array copying as the explanation for this array case.
No production compiler or runtime change was made.

The [execution protocol](protocol.md) defines the common workloads and retained
failures. Source references below name preserved evidence members relative to
the restored Phase46 raw root, `selfhost/build/phase46/`; line numbers refer to
the original emitted files, before instrumentation. The evidence capsule must
retain those files, their adjacent checked-emission receipts, and
`diagnostics01/report.json`. The maintained [emission tool](../../selfhost/tools/performance/phase46/emit.mjs)
and [diagnostic driver](../../selfhost/tools/performance/phase46/diagnose.py)
provide the acquisition/run procedure; the receipts bind the exact sources,
compiler/runtime products and commands rather than assuming future regeneration
will produce identical bytes.

## Observed native counts

The [saved-C instrumentation producer](../../selfhost/tools/performance/phase46/native-counts.py)
adds atomic counters to `heap_alloc`, the CPU `WL_OPEN` segment entry, and generic
closure entry. An exit handler prints the counters to stderr. All eight native
diagnostic runs exited successfully and matched their three expected output
values. Each product ran with one CPU worker, GPU disabled and zero warmups.

The table subtracts the one-repetition run from the 17-repetition run in
`diagnostics01/report.json`:

| Workload | Compiler | Heap-allocation calls | Requested block words | Host segment entries | Generic closure entries |
| --- | --- | ---: | ---: | ---: | ---: |
| Numeric | Upstream | 2 | 3 | 3 | 0 |
| Numeric | Selfhost | 32,821 | 49,234 | 558,426 | 49,277 |
| Array | Upstream | 18 | 1,027 | 3 | 0 |
| Array | Selfhost | 393,340 | 657,590 | 2,885,057 | 327,842 |

These are 16 extra benchmark calls: 16,392 numeric recurrence steps or 65,544
array fold steps. The fixed base-result computation cancels. Different argument,
checksum and clock text leaves small IO/formatting differences, so this is not
an exact isolation of the kernel. The selfhost deltas correspond approximately
to two allocations per numeric step and six per array step.

Size classes distinguish small transport allocations from array storage:

| Array workload | Class0: one word | Class1: two words | Class2: four words | Class6: 64 words | Class7: 128 words |
| --- | ---: | ---: | ---: | ---: | ---: |
| Upstream delta | 1 | 1 | 0 | 16 | 0 |
| Selfhost delta | 131,108 | 262,215 | 1 | 0 | 16 |

All invalid-class counters are zero. Requested words mean allocated block
capacity, including reused blocks; they are not retained memory, useful payload
size, allocator misses or RSS. Segment entries include runtime entries but do
not count iterations inside an inline scalar loop. Atomic instrumentation can
change optimization and execution cost: these observations describe diagnostic
binaries, not exact allocation counts of the unmodified binaries. Instrumented
timing receives no speed credit and does not attribute a percentage of the clean
runtime gap to any one mechanism. Native `perf` collection was unavailable;
its failed capability probe is retained.

## What the emitted C explains

Upstream array C, `batch03/array-upstream-c/program.c`, keeps the loop's array
and accumulator in separate variables in `spin_11` (line1508). `spin_12`
(line1480) reads an element directly and passes scalar values to `spin_8`
(line1395), which writes directly into the same array. Intermediate results
travel in locals and stack output arrays; these inline functions expose the
whole operation to Clang.

Selfhost array C, `batch03/array-selfhost-c/program.c`, represents the same
`fold.loop`/`fold.cell`/`fold.step` region as 70 segments, with nine static
allocation sites and ten generic closure-dispatch sites. Positive loop branches
allocate captured arguments at lines8587 and8619. Even the direct `fold.cell`
entry at line9165 returns a capture closure. `Array.get` allocates a result
tuple at line10222; the step-result tuple allocates at line9885. These host
segment functions use the runtime's `noinline` calling convention, so Clang
cannot erase their boundaries as it can inline the upstream scalar functions.
The dynamic small-block and dispatch deltas corroborate this structural cost.

Array layout is also specialized upstream: `blk_new(..., 0, 7, ...)` at line1578
creates a packed 128-element U32 buffer in 64 words. Selfhost's native Array
entries use `blk_new(..., 1, ...)` at lines10281/10292, creating 128 generic
64-bit Term slots. The observed 16 class6 versus 16 class7 allocations match
one array per additional benchmark call. The twofold storage difference alone
does not explain the much larger execution gap.

There is no generated array-copy path here. In both outputs, `blk_copy`,
`blk_half` and `blk_node` appear only as definitions. Selfhost `Array.set`
(lines10130–10139) calls `blk_write` on the existing block, with no copying
branch. The array-sized allocation delta remains one per benchmark call;
the hundreds of thousands of additional allocations are small blocks.

The pure numeric pilot supplies a smaller view of the same call-lowering gap.
`pilot02/numeric-upstream-c/program.c:1197` emits a scalar `spin_0` loop with
inline F32/U32 operations. `pilot02/numeric-selfhost-c/program.c:2287` returns
the recurrence as a closure; lines2304/2338 allocate its captured arguments,
and even direct F32 multiplication occupies a separate segment at line2858.
The batch numeric counters independently show repeated allocation and dispatch
where the upstream batch has almost none.

The next general compiler experiment should therefore preserve a known call's
complete argument list across matcher/lambda boundaries and carry nonescaping
tuple fields separately across those private calls. This is an optimization
of the IR/ABI, not a workload recognizer. The current evidence motivates it;
it does not establish the gain or correctness of an unimplemented pass.

## A concrete next JavaScript experiment

The hot private fold in `batch03/array-selfhost-js/program.mjs:812` already
scalar-replaces the evolving array/accumulator tuple and avoids generic
`callOwned` dispatch and per-iteration entry guards. It calls `arraydata` for
the read and `arrayset` for the write; `arrayset` calls `arraydata` again.
The helpers at lines430–431 check the handle/backing tag and perform
`Number(index) % length`. Upstream `program.cjs:320,462,579` uses raw indexed
arrays through its loop, cell and step functions.

The whole-process selfhost CPU profile assigns6188/6609 samples (93.63%) to
the fold-loop function across its calling contexts, and107/6609 (1.62%) to GC.
This motivates testing an owned-array view cached outside the loop, rather than
another generic allocation-removal claim. The profile does not establish whether
V8 already inlines helpers or removes checks; a saved-output ablation is the
cheapest causal screen.

Admission must prove fresh owned storage that cannot be replaced, resized or
observed through opaque callbacks. Preserve alias writes, first-demand/errors,
zero iterations and public boundaries. `Number(index)` uses an observable host
conversion; removing it requires the existing host-identity permission or an
equivalent retained observation. An unconditional generated-source rewrite is
not a valid compiler optimization. No such ablation was run in this phase.

## Target and semantic boundaries

The JS and C products receive different optimizations. For example,
`pilot02/closures-selfhost-js/program.mjs:721` fuses closure-chain construction
and application into a scalar countdown, while both C products retain closures.
Conversely, the pure numeric selfhost JS main at line725 retains a generic
F32 conversion call that its separate scalar bench at line724 emits directly.
That pilot observation must not be projected onto the later batch: its JS CPU
profile is dominated by the scalar `p46.loop` path. These profiles are supporting
location evidence, not additional clean timing measurements.

`batch02` exposes a real native semantic gap, preserved separately from the
performance results. Selfhost native starts `io_argc=0`, `io_argv=argv+1`
(`numeric-selfhost-c/program.c:58265,59054`); pinned upstream preserves the
executable name with `io_argv=argv`, `io_argc=1`
(`numeric-upstream-c/program.c:4529–4530`). Both args effects return that list
unchanged. Thus arguments `1 0` become two values only in selfhost C; the old
common wrapper wrongly discards the first and runs zero measured repetitions
with two warmups. Batch03 reads the final two values in the same source for all
four products. This restores comparison validity without repairing native
`IO.args` conformance. The products also retain different native runtime
revisions; the comparison does not isolate emitter differences from runtime
implementation differences.
