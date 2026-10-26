# Sequential reference counts: a cross-cutting runtime falsifier

The strongest inexpensive runtime experiment is to remove locked instructions
from reference-count updates **only in the existing single-Bend-mutator native
ABI**. This does not add parallel execution, change generated QBE, or remove
scheduler/I/O synchronization. The qualified runtime remains intact.

This document separates the original static/profile hypothesis from the later
coordinator-owned execution results. Sample percentages are not demonstrated
speedups; the final section records the clean comparisons and their limits.

## Machine evidence

The existing Phase144 context capture has10,083 retained samples, zero loss or
overrun and99.585% sampled-thread/process CPU coverage. Exact executable and
analysis hashes, original machine disassembly and active-owner counts are in
[the evidence capsule](serial-rfc-evidence/summary.json).

| Physical function | Atomic instruction PC | Following PC | Samples at following PC | All function samples |
| --- | --- | --- | ---: | ---: |
| `span_fade` | `40307f: lock xadd` | `403085: and` | 795 | 978 |
| `term_drop` | `f5354a: lock xadd` | `f5354e: and` | 824 | 1,616 |
| `p111_rt_keep` | `f544ca: lock xadd` | `f544cf: and` | 215 | 293 |

These three immediate post-atomic PCs account for1,834 samples, **18.19% of
all samples**. This concentration is much more actionable than counting static
helper calls. It suggests costly reference-count operations, but instruction
retirement, interrupt delivery and skid prevent attributing every sample to
the preceding locked instruction. The `and` itself is not evidence that bit
masking consumes18% of execution.

The same locked updates are present in the qualified clean ELF. Addresses in
the table belong to the diagnostic ELF only; clean and diagnostic disassemblies
are stored separately. No clean runtime ratio is inferred from diagnostic
timing.

`term_drop` and `span_fade` together account for25.73%; `p111_rt_keep` adds2.91%.
Their active owners include constructor-ownership analysis, verifier lookup,
parser-prior lookup, ordinary lookup, index maintenance and normalization.
This is therefore a plausible cross-cutting opportunity rather than a named
benchmark recognizer. Those physical shares overlap stage and active-owner
shares and must not be added to them. If half of the combined28.64% disappeared,
the conditional whole-request reduction would be14.32%; whether anything near
that happens is the question being tested.

## Why the existing ABI permits a bounded experiment

The audited parent is the exact Phase128 `runtime-borrow01/runtime.c`, SHA256
`6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a`.
The source has remained the runtime parent of qualified Phase143 N2. Relevant
facts are independently visible in that frozen source:

| Boundary | Actual source behavior |
| --- | --- |
| Native entry | `p111_rt_main` rejects `threads != 1` and GPU enabled before corpus execution. |
| Descriptor | `p111_bind` admits only known capability combinations containing the sequential bit and validates all declared effect providers. |
| Evaluation | `BANGS` is0; the admitted one-lane corpus starts a sequential `work_loop`. The ABI has no admitted fork/join operation. |
| Compute worker creation | `pool_open` is the sole compute-worker `pthread_create` site. The experimental serial mode additionally fails immediately if this function is ever reached. |
| Host I/O workers | `io_help` invokes `IoWork.call` on detached host buffers, then communicates a completion pointer through the pipe. |
| Heap packing | `io_take` invokes `IoWork.pack(e,...)` on the main event loop. Conversion of request Strings/buffers to host buffers also happens on that loop. |
| Foreign boundary | Only the frozen provider table is admitted; a requested effect with no registered provider is rejected. |
| Signal handlers | The fault handler writes a constant message and exits. It neither evaluates Bend nor accesses reference-count cells. |

All eight worker callbacks were inspected: file open/read/read-at/size/write,
and NativeHost read/path/publish. They use host descriptors, malloc buffers,
paths, hashes and syscalls. None receives an `Env` or accesses the Bend heap.
Their pack callbacks run later on the event loop. `IoAct` itself contains Bend
words, so the callback type is not an isolation proof; the actual fixed callback
bodies and their callees establish this restriction. Mutexes, condition
variables, pipes and allocator/scheduler atomics remain unchanged.

This is **one Bend heap mutator**, not a single-threaded process. The admission
does not cover arbitrary C embeddings that spawn threads and call public
`p111_rt_*` functions concurrently, nor future foreign providers. Exact runtime
and header identities are part of the experiment's boundary. A future parallel
ABI must retain/reintroduce atomic reference counts or establish a different
ownership protocol.

The prior [Phase129 audit](../phase129/runtime-parallelism.md) reached the same
single-evaluator conclusion for the borrowed-field optimization. Searches of
the repository's research/design/implementation notes found discussion of
locked counts, but no prior serial-count ablation. That is a repository search
result, not a claim about compiler literature.

## Exact proposed change

[The preparation tool](../../selfhost/tools/performance/phase144/serial-rfc/prepare-v01.py)
checks exact runtime, headers, GCC10 and retained compiler-object hashes. It
writes a fresh experiment directory and four build commands; it executes none.
The original runtime/object/selection are untouched.

Both candidate modes use one generated source. Mode0 is the atomic control.
Mode1 changes only:

1. The `rfc_bump` fetch-add.
2. The `term_drop` reference-count fetch-sub.
3. A fail-closed guard before compute-worker creation.

The two update helpers preserve the old unsigned32 value and modulo32-bit
arithmetic. Four-byte `memcpy` reads/writes avoid introducing a new plain-u32
strict-aliasing assumption on the existing ordinary u64 heap storage. Overflow
checks, last-owner detection, RFC location reconstruction, destruction order,
`a32_acq`, and every other atomic macro/site remain unchanged. The compiler
should lower these constant-size copies to scalar memory operations; inspect
actual machine code rather than assume it.

Mode1 rejects device/CUDA/Metal/bang-enabled compilation at preprocessing time.
Existing thread/GPU/provider admission stays byte-exact. The source-transform
tests check the parent pins, exact reviewed delta, unchanged atomic macros,
and fail-closed handling of missing/duplicated edit anchors. These are four
offline tests, not runtime correctness qualification.

Prepared directory: `selfhost/build/phase144/serial-rfc01/manifest.json`.
The manifest records exact command vectors and identities. A fresh preparation
can be reproduced with:

```sh
python3 selfhost/tools/performance/phase144/serial-rfc/prepare-v01.py \
  --out selfhost/build/phase144/serial-rfc-fresh
```

## Atomic control build inspection

The coordinator built and linked both modes using the retained compiler object.
The atomic control's runtime object has a different whole-file hash, but the
difference is exactly **two bytes in nonloaded `.strtab`**: GCC's internal
`CSWTCH.618` label becomes `CSWTCH.620` after the two helper declarations are
introduced. Every other byte is identical. The linked compiler ELF also differs
from qualified Phase143 N2 in exactly those two string-table bytes. All section
metadata, executable code, allocatable data, relocations and addresses match.
There is no machine-code/layout confound between the parent and atomic control.
The [complete section audit](serial-rfc-evidence/atomic-control.json) pins both
objects and both executables and includes a reproducible offline method.

The serial mode has actual instruction/layout differences, including removal
of the newly prohibited compute-pool path. Timed comparisons should still use
the same-source atomic control, preserve the qualified parent as a noise check,
and describe the result as the admitted sequential-runtime policy change.
Its actual `span_fade`, `term_drop` and `p111_rt_keep` contain no locked
instructions. Static lock sites across the runtime object fall27→11; the
remaining sites belong to allocator/scheduler/operation paths, which were not
changed by the source transformation. [Machine inspection](serial-rfc-evidence/serial-machine.json)
records the exact objects and instructions. These static counts are not
dynamic operation counts or a runtime improvement measurement.

## Cheapest decisive test and stopping rule

First compile both runtime modes and relink the **same retained Phase143 N2
`program.o`**. This avoids any QBE regeneration or full bootstrap. Compare the
mode0 runtime object and hot machine instructions to the original; if the
object differs, retain that explicit control and do not attribute all layout
changes to atomic removal. Confirm the serial hot paths actually lose `lock`
without deleting unrelated runtime atomics.

Before timed use, test reference-count old/new values, count1/multiple cases,
low32 wrapping/high32 preservation, overflow failure, and the compute-worker
refusal. Run existing independent ownership/sharing and real effect tests,
including worker I/O while the evaluator does heap work. Verify `--threads 2`
and `--gpu on` still fail. Unknown provider/descriptor gates must remain intact.

Then use balanced repeated **clean** short native requests with exact frozen
QBE outputs, plus ownership-heavy and I/O witnesses. Charge runtime compilation
and relinking separately. If the result is consistently negligible or negative,
stop without a full self-build. If it transfers and is material, one same-source
full compiler request against the unchanged frozen output oracle can establish
whether the diagnostic hypothesis transfers to the real cold workload. Keep
the qualified atomic runtime available throughout.

This is a runtime policy experiment, not a new optimization pass, a general
parallel-runtime change, or evidence of recursive improvement. Its attraction
is that one small audited boundary may remove work across many compiler stages
without adding per-request analysis or increasing Bend compiler source size.

## Closed results and qualification boundary

The coordinator completed both modes'384 helper/reference comparisons, safe
and overflow boundaries, and serial compute-pool refusal. All61 existing
program objects passed their independent complete-output oracles when linked
with each runtime (122 executions), plus three fresh thread/GPU CLI refusals.
The three compiler-stage refusals without executable objects remain historical.
[Semantic and fixed-batch results](../../implementation/phase144/serial-rfc-relink-results.json)
retain the exact original objects, receipts and observations.

Six alternating fixed-work pairs on four preserved Phase131-generated programs
gave serial/atomic median ratios1.0018 for Map,0.9949 for records,0.9782 for BST,
and0.9623 for Unicode. Map and records were effectively flat; the other two
improved modestly. These are not the full45-program speed distribution or a
new upstream-parity ratio. The generic RFC policy does not guarantee that every
workload spends meaningful time in shared reference-count updates.

The serial runtime was then linked to the **same new integrated Phase144 N1
program object** as the atomic comparison. The composed executable compiled
the frozen Phase142 source to the exact115,909,112-byte oracle, with unchanged
source, Base carrier, flags and CPU3. The verified
[full comparison capsule](../../implementation/phase144/serial-rfc-full-evidence/summary.json)
publishes all three request/guard receipts and the actual relink lineage.

| Compiler used on the same frozen source | Native request, s | Relative comparison |
| --- | ---: | --- |
| Phase143 parent, atomic runtime | 304.534 | Current clean parent observation |
| Integrated Phase144 N1, atomic runtime | 266.862 | 12.37% less than parent |
| Identical integrated N1 object, serial runtime | 249.679 | 6.44% less than integrated atomic;18.01% less than parent |

The serial request used249.446 process CPU seconds and peaked at1,046,256KiB
child RSS; the atomic integrated request peaked at1,046,380KiB. This is not a
memory-reduction result. The serial guard took252.268s, versus269.446s for
integrated atomic; both include verification/supervision outside the native
request. Runtime compilation and relinking are separate acquisition costs.

There is **one full observation per role**, not a confidence interval. Processes
were fresh, but OS caches were not flushed. The17.184-second runtime reduction
is a useful measured result for this exact compiler workload; it does not
validate the original18% post-atomic sample share as a causal time budget.
The transformation retains reference counts, memory traffic, allocation and
reclamation traversals. Only their atomic-update requirement was removed.

Actual compiler execution exercises the current NativeHost read and output
paths. Neither this run nor the61 old-object cases independently establish
every file/path/publish provider and failure-cleanup path. Source review pins
those boundaries; arbitrary concurrent C embedding remains unsupported.

The composed compiler has **no new N2 self-reproduction qualification and has
not been installed or selected**. Its report explicitly marks that status.
The request tool's `runtime` field names a future-build context; the linked
serial runtime is established by the separate relink receipt, not that field.
The next promotion decision must retain this distinction and keep the qualified
atomic compiler/runtime available.
