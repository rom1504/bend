# Phase109 direct ownership/runtime boundary

This is a source and interface audit. Target compilation and execution evidence
belongs to the Phase109 integration report; writing this adapter does not qualify
its correctness or performance.

## What is reused

`selfhost/tools/performance/phase109/runtime/materialize.py` authenticates the
selected production runtime, 83,683 bytes with SHA-256
`9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9`.
It copies the prefix through the end of Term ownership operations and the exact
`pool_try`, corpus mapping, layout and growth functions. These retain the CPU
allocator's HOT/COLD/bank free lists, heap word locations, reference-count
redirects, atomics, iterative destruction, static-node treatment and fail-stop.
No ownership helper body is rewritten. The allocator-global declaration uses
standard C11 `_Alignas(128)` instead of GNU `__attribute__((aligned(128)))`, with
the same alignment and array type. This reuses the Phase108 portability fix and
is applied to **all** matched profiles, including GCC and Clang, so frontend
syntax is not a benchmark variable. Its exact old/new strings are recorded in
each materialization receipt. The first optional cproc attempt rejected the GNU
spelling; that attempt remains evidence rather than being overwritten.
The scheduler, effects, arrays, primitive
operations after this slice, and device execution are outside the adapter.

A fixed table is inserted at the existing Tables boundary; the opaque-context
adapter is appended. No generated C program body is parsed to produce IR. GCC or
Clang can acquire this object once, and ordinary worker experiments only link it.
That makes repeated worker construction independent of cproc and Clang without
claiming that the initial runtime object was acquired without a C compiler.

The test context reserves 1 GiB of virtual address space through the production
mapping/layout functions, using the original dynamic-growth method if needed.
It does not touch the whole reservation. Production rings/stacks determine the
large fixed heap-word offset even though this slice does not run the scheduler.
One live context and one CPU thread are admitted; the pointer does not pretend to
make the runtime's process-global allocator state reentrant.

## Explicit ABI v1

The four constructor IDs are `Nil=0`, `Con=1`, `SNil=2`, `SCon=3`, with live
arities `0,2,0,2`. The admitted list is `List<String>`; String heads are Unicode
scalar words, String tails are String Terms, and List heads/tails are String/List
Terms. The table is not a reusable descriptor for arbitrary Bend programs.

| Export | Machine signature | Ownership contract |
| --- | --- | --- |
| `nx_rt_id` | `(context*, u64) -> u32` | Borrow constructor identity; validates the admitted representation. |
| `nx_rt_fail` | `(context*, u32) -> u64` | Impossible checked branch reaches fail-stop; the declared machine result is never returned. |
| `nx_rt_zero` | `(context*, u32) -> u64` | Produce the corresponding immediate zero-field constructor. |
| `nx_rt_keep` | `(context*, u64) -> u64` | Replace the old handle with the returned shared handle; caller owns two claims on that result. |
| `nx_rt_sink` | `(context*, u64) -> u32` | Consume one owned value; return zero. Immediate Char keep/sink follow the production trivial-value path. |
| `nx_rt_take2` | `(context*, u64) -> u32` | Consume a binary constructor using `ctr_take` then `spare_free`, transferring its children to two context scratch slots. |
| `nx_rt_field` | `(context*, u32) -> u64` | Transfer one scratch child, index 0 or 1, exactly once. |
| `nx_rt_build2` | `(context*, u32, u64, u64) -> u64` | Consume two fields, allocate through `heap_alloc`, seal with `rfc_seal`, and return a constructor. |

All imported operations are ordered effects in the first Nx library contract.
`id` is semantically a borrowed observation, but no optimizer is yet authorized
to move it across ownership operations. Physical `u64` representation does not
license arithmetic on owned Terms or conversions to host pointers.

The scratch buffer is a two-word field of the opaque context, not a heap
allocation. A take refuses until both prior children were transferred. Duplicate
or out-of-range field reads fail. The worker must transfer both before its next
take and must return with no pending child. General calls that share a context
must not interleave such transfers. This deliberately small interface avoids
adding a caller stack-allocation instruction just to learn the ownership boundary;
it can later become caller-owned scratch without changing take/build semantics.

The adapter currently validates context identity, constructor kind, field types,
and transfer order. These checks are additional cost relative to trusted
production generated C. A future unchecked ABI needs an explicit admission
certificate and separate measurement; its cost must not be attributed to QBE's
instruction selection or the runtime allocator itself.

## Independent controls and observable lifetime

The harness binds `nx_list_reverse(context,xs,acc)` and
`nx_string_reverse(context,s,acc)`. Its only list/string loops construct inputs,
observe borrowed outputs, and release owners. Reversal is exclusively the linked
Bend-generated worker. `prepare-harness.py` authenticates the separately frozen
13-case JSON catalogue and renders C data initializers, not compiler algorithms.

The catalogue includes empty, singleton, unique, shared root, shared tail and
head, static inputs, Unicode/combining characters, and a 65,536-node list. Parent
construction conservatively seals nontrivial children, so retaining a borrowed
tail or head updates an existing redirect; the harness requires the returned
handle to equal the parent's stored word. Retaining a root instead replaces the
input root with the returned redirect before entering the worker.

Results are observed, then dropped. Aliases are observed **after result release**
and separately dropped. This catches some lifetime failures hidden by checking
an alias only while the result remains alive. Static fixtures use an immutable
128-word arena below `HEAP_OFF`, contain only static/immediate children, and are
never shallow-freed by the real runtime.

Release accounting reads the actual allocator. Reserved heap words are
`(H_BUMP - 1) * PAGE_LEN`; subtracting HOT free chains, COLD chains, and all bank
generations yields live heap words. The walk verifies HOT lengths against
`ALC_LEN`, host bank indices, address bounds, and bounded traversal. An accepted
case requires zero live words and no pending scratch value before unmapping.
This is a useful finite leak/double-release check, not a proof of ownership safety
or a race detector. No duplicate-free global mark set is maintained.

## Matched incumbent workers

With `--production-workers`, the materializer appends the two exact frozen
production C bodies from `controls/production-workers.c`. Their bytes are checked
against the extraction receipt. Only macro-level constructor ID bindings change
to match the fixed descriptor; conservative sealing stays enabled and `seq=true`.
Wrappers expose the same harness entry signatures.

This inspection corrects a tempting hypothesis: these two existing production
workers already use ordinary self-tail loops, with zero `WL_*` transitions per
cell. Direct IR may remove C acquisition from their repeated build path and
preserve ownership information structurally; it does not newly eliminate a
per-cell continuation trampoline in these particular kernels. They are not
sufficient to decompose the full Phase108 continuation-performance regression.

The same runtime/harness with GCC/Clang-built incumbent bodies and QBE-built
direct IR permits a matched worker comparison. Static input, aliases, runtime
state, ownership policy, and observations stay equal. Runtime acquisition,
worker construction, execution, observation and allocator auditing must be
reported separately. No full-compiler speed prediction follows from this slice.

## Separate trusted worker ABI and constructor reconstruction

The first matched screen found virtually equal direct-QBE/direct-Clang worker
times, while checked adapter calls cost much more than the optimized incumbent
loop. This motivates a **separate** trusted worker interface, not removing
boundary validation globally. The seven `nx_rt_fast_*` variants preserve the
same effect signatures as their checked counterparts but require admitted typed
input graphs and a verified structured ownership program. They avoid repeated
context/type/scratch validation. The checked constructor/observer API, allocator
accounting, context close, and negative-contract checks remain active. Source
verification is a compiler admission check, not a formal proof that arbitrary
native callers cannot violate this contract.

`nx_rt_rebuild2(ctx,parent,cid,keepIndex,other)` consumes a binary parent and an
owned `other`. It performs the original `ctr_take`, preserves field `keepIndex`
as the first field of a new binary constructor, and uses `other` as the second.
The remaining old field goes to scratch slot 0 and must be transferred by the
next `fast_field(ctx,0)`. Conservative `rfc_seal` remains on both constructed
fields; the old reference-count and shared-child logic is unchanged.

The constructor shell can be reused only when `ctr_take` returns a heap location
at least `HEAP_OFF`. A shared parent returns zero and needs a fresh allocation.
An immortal static parent returns a **nonzero static location**, which must also
allocate: treating every nonzero spare as reusable would mutate the static
image. The operation supports either keep index and either binary constructor
provided typed lowering establishes the resulting field types.

This operation removes a shallow-free followed by same-class allocation and
combines transfer/construction across an ABI boundary. It is a generic
ownership transformation rather than a source-name-specific reverse function.
It still needs a structured match/take/build equivalence rule and must not fuse
across intervening observable effects or unmatched ownership uses. Dedicated
operator controls cover unique, shared, static and keep-tail/type-changing
reconstruction, including observing the old shared/static parent after dropping
the new result. Actual measurements and promotion decisions remain in the main
integration report.

## Offline machine evidence after the qualified suite

[`evidence/machine-summary.json`](evidence/machine-summary.json) records
`objdump`, `nm` and `size` inspection of the 15 existing reverse-kernel binaries
from `selfhost/build/phase109/suite01`. Every input binary is authenticated
against its timing receipt; matching assembly files preserve workers, relevant
runtime helpers and cold fragments. No target was executed for this inspection.
The replay tool is `runtime/inspect.py`.

The following are **static instruction sites** in the nonempty list-worker
loop, excluding callees. They are not retired-instruction or cycle counts.

| Worker | Exported worker bytes | Loop instruction sites | Calls per nonempty iteration |
| --- | ---: | ---: | ---: |
| Checked imports, QBE | 186 | 38 | 6 |
| Checked imports, Clang | 166 | 28 | 6 |
| Trusted imports, QBE | 166 | 33 | 5 |
| Trusted imports, Clang | 155 | 23 | 5 |
| Reconstruct fusion, QBE | 138 | 25 | 3 |
| Reconstruct fusion, Clang | 102 | 17 | 3 |
| Production C through cproc/QBE | 101-byte wrapper + 361-byte worker | 61 | 9 |

The GCC and Clang production workers inline ownership helpers into their loop
and occupy 629 and 775 bytes respectively, excluding separately named cold
fragments. Their static function call count includes exceptional and
representation-dependent paths and is not comparable to a fixed per-iteration
import count. The original source already has direct self-tail control flow.

The nine cproc/QBE loop calls are `term_aux` twice, `cls_fit(2)` twice,
`ctr_take`, `spare_free`, `heap_alloc`, and `rfc_seal` twice. Constants are still
passed to out-of-line `cls_fit`, and environment words repeatedly reload from
the worker's stack. This exact shared-source experiment uses the Phase90 runtime
core, **without Phase108 v3's five accessor macros**. Consequently this is a
matched cproc/QBE reference, not the exact Phase108 v3 runtime profile. In
particular the two `term_aux` calls would disappear under that accessor policy.

The direct checked worker calls `id` twice, `take2`, two `field`s and `build2`.
The trusted policy also reuses the constructor observation, reducing this to
five imports, so its improvement combines validation placement with one
redundant-observation removal. Fusion reduces the loop to `fast_id`, `rebuild2`,
and `fast_field`. The same three effects remain calls in the Clang-emitted direct
worker: the separately acquired runtime object prevents cross-unit inlining.

### Why the fused worker still trails the integrated Clang loop

Observed machine evidence supports a remaining **runtime interface cost**:

- Constructor identity is an out-of-line `nx_rt_fast_id` call even though its
  body is just extraction from a tagged word. The Clang production loop performs
  the extraction locally.
- `nx_rt_rebuild2` receives constructor ID and keep index as dynamic arguments.
  Its generic code spills both transferred children into a stack array, then
  dynamically indexes them, although this worker always passes `Con` and index
  zero. The structured layer knows those constants; the separately compiled
  runtime helper does not.
- Rebuild stores the remaining child, pending mask and hole marker into the
  context. `fast_field` reloads the child, rotates a mask using its dynamic index,
  clears ownership bookkeeping, and returns. The integrated worker carries the
  next list tail in a register instead of exporting it through context scratch.
- GCC leaves the shared `nx_construct2` helper out of line. `rebuild2` unwinds its
  own frame and tail-jumps to it; that helper establishes another frame and tests
  child representations before sealing. This is real extra boundary work,
  although a tail jump does not grow the stack.
- QBE has more argument and register shuffling than Clang in the same small
  direct loop (25 versus 17 static instruction sites), but both retain those
  three imports. Existing fused timings differ by only about 4.7% between their
  workers, far less than the approximately 42% gap from fused QBE to the
  integrated Clang reference in that screen.

Those are mechanistic observations, not a cycle-by-cycle attribution. The
qualified fused screen's existing medians for 655,360 node visits are 9.974 ms
for direct QBE, 9.522 ms for direct Clang, and 7.015 ms for integrated production
Clang. They include actual ownership work but exclude fixture construction,
observation and release auditing. This inspection adds no fresh timings.

All three copies of each production variant have identical complete `.text`
hashes across raw/trusted/fused suite directories. Their timing variation must
therefore not be credited to a changed production binary. The direct worker
text changes are authenticated separately in the inspection report.

### Highest-value next falsifications

First test a dedicated structured constructor-ID operation and a typed
ownership-transfer result, retaining their semantic roles while avoiding a
generic imported call for pure extraction and for loading a transferred child.
Do not permit arbitrary pointer arithmetic on opaque Terms merely to do this.

Next preserve constructor ID, keep index and field ownership facts through the
operation boundary, either by generating specialized operation code or a small
descriptor-specialized adapter. This can test whether dynamic indexing,
scratch transport and helper frames explain the remaining cost. Require the
same unique/shared/static controls and independent outputs; compile-time work
and cached-runtime acquisition must remain separate clocks.

Do not infer that a new register allocator, whole-compiler inliner, or another
machine backend is necessary from this evidence. The compiler/runtime boundary
still hides constants and ownership results from both QBE and Clang. Conversely,
neither the 42% kernel deficit nor its possible removal predicts a
whole-compiler speed ratio.
