# Independent review: serial reference-count updates

Source review finds no blocker to **testing** the isolated variant with the
existing closed, sequential native ABI and its exact fixed effect providers.
This is not runtime qualification, a race-detector result, or approval to replace
atomics in other runtime operations. No compiler, native program or benchmark
was executed during this review.

## Exact scope

The parent is `selfhost/build/phase128/runtime-borrow01/runtime.c`, SHA-256
`6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a`.
The candidate is `selfhost/build/phase144/serial-rfc01/runtime.c`, SHA-256
`aa95d2c0426c05bcc4d34244dd8b22b79ebcaf6d30634569201961f60b57f333`.
Its preparation method is `selfhost/tools/performance/phase144/serial-rfc/prepare-v01.py`,
SHA-256 `f0a6fd6ac7ffabf63d5cdb4550805c721787259aefdc376056902143e6182a5a`.
The unchanged headers are `runtime.h` (`9b19b8d6…79d12`) and
`primitives.h` (`ecbdfe62…65d20`), with full identities in the preparation manifest.

The actual diff replaces `rfc_bump`'s fetch-add and `term_drop`'s fetch-sub-release
with two helpers. Mode 0 uses the original atomic operations. Mode 1 reads and
writes exactly four bytes through `memcpy`, performs unsigned 32-bit arithmetic,
and returns the old value. The existing overflow refusal, final-owner test,
acquire operation, reclamation traversal and all other atomic operations remain
unchanged. A compile-time guard rejects non-Boolean mode values and mode 1 with
device/Metal/CUDA/BANGS execution. Mode 1 also refuses `pool_open` before a compute
worker can be created.

## One heap mutator, despite host IO threads

The inspected parent gives the following concrete boundary:

| Path | Relevant parent source | Finding |
| --- | --- | --- |
| Native entry | `runtime.c:4448`–`4501` | Default one thread/GPU off; effective `threads != 1` or enabled GPU refuses before corpus setup. |
| Ordinary evaluation | `runtime.c:410`, `2277`–`2318` | `BANGS` is exactly zero; one-worker evaluation selects sequential execution. Retained fallback can open a compute pool; the candidate adds an unconditional mode-1 refusal there. |
| IO dispatch | `runtime.c:2630`–`2677` | Helper threads invoke only `IoWork.call`; result packing receives `Env` only from `io_take` on the event loop. The parked-callback path in `io_wait` is also on that loop. |
| Actual worker callbacks | `runtime.c:3281`–`3470`, `3597`–`3731` | `file_open_call`, `file_read_call`, `file_read_at_call`, `file_size_call`, `file_write_call`, `nh_read_call`, `nh_path_call`, and `nh_publish_call` use OS handles and detached malloc buffers, never RFC/heap operations. |
| Foreign admission | `runtime.c:3743`–`3887` | The runtime installs a fixed provider table; requested names without a registered provider refuse. It does not dynamically load arbitrary foreign callbacks. |
| Signals | `runtime.c:579`–`585`, `1762`–`1771`, `3023` | Fault handlers only write a fixed diagnostic and `_exit`; SIGPIPE is ignored. No signal handler mutates or resumes Bend heap operations. |

`IoAct` does contain Bend continuation/value words, so the worker function
signature alone is not a confinement proof: a new C callback could cast its
pointer or access globals. Confidence depends on the actual eight callback
bodies and their callees, all reviewed here, remaining pinned. Existing queue,
mutex, condition-variable and wake-pipe synchronization is unchanged. The
reviewed runtime contains no cancellation routine, cleanup callback or signal
handler that drops a Bend value on another thread.

RFC cells reside in the ordinary `uint64_t` corpus, not a declared `_Atomic`
object. The existing GCC atomic builtins operate on the low 32-bit address.
The new `memcpy` helpers access its representation without adding a dereferenced
plain-`uint32_t` alias assumption. The old-value and modulo-32-bit update must
remain exact, including the high eight bits of that low word which belong to
the packed location. Replacing release semantics is justified only because
these RFC cells have no second mutator or concurrent reader in the admitted
execution. Unchanged acquire loads are not a substitute for that condition.

Exported `p111_rt_*` functions and segment pointers are a C boundary. A hostile
or independently modified C caller could call them concurrently or install
thread-starting segment code; descriptor capability bits do not police such
behavior. Such embedding, injected libraries/providers, device execution and
future runtime changes are **outside this admission**, and require a new audit.
No unsupported concurrent heap experiment should be treated as a valid usage
test of this variant.

## Gates before timing or qualification

1. Bind the actual runtime/header/provider identities and compiler flags to the
   variant. Verify the mode-0 executable code against the original control and
   explain any differences. Inspect mode-1 machine code to confirm only the two
   intended RFC updates lose their atomic read-modify-write instructions; array,
   allocator, queue and scheduler atomics must remain.
2. Compare helper old values and all eight bytes of containing cells for
   representative and boundary low-word values: zero/one/multiple counts,
   different packed location bits, unsigned wrap, and the original overflow
   refusal threshold. Preserve the exact existing refusal rather than inventing
   a new count invariant.
3. Exercise owning constructors, shared siblings, repeated keep/drop, final-owner
   reclamation, nested shared nodes, strings, arrays/clone and borrowed readers
   against the atomic control. Check complete outputs and the existing ownership
   controls, including refusals. Identical final scalar checksums alone do not
   cover lifetime errors.
4. Exercise real file and native-host read/path/publish providers, including
   success and failure/cleanup, against independent output oracles. Ensure helper
   threads really run; synthetic immediate effects do not establish this edge.
   Where a supported fixture permits multiple activations, retain shared Bend
   values while host work is pending. Do not broaden the provider set merely to
   manufacture concurrency coverage.
5. Test `--threads 2`, enabled/size-valued GPU options, invalid mode values and an
   internal forced `pool_open` refusal before worker creation. Preserve ordinary
   `--threads 1 --gpu off` behavior and the existing signal fault diagnostic.
6. Only then compare complete compiler emissions and independently expected
   generated-program outputs with the same source, program object, flags and
   host. Performance is a separate balanced comparison; source review does not
   establish a speedup or transfer the old runtime's full qualification.

The strongest practical risk is accidentally generalizing the serial contract
when providers, scheduler entry points or C embedding evolve. Keeping the
variant optional and the two-site diff small makes that boundary inspectable.

The prepared [word controls](../../selfhost/tools/performance/phase144/serial-rfc/word-controls-v01.json)
bind the actual candidate and contain 384 paired helper/atomic-reference cell
comparisons per mode, safe/overflow boundary cases and forced mode-1 pool
refusal. Their expected commands and complete stdout/stderr are explicit.
Preparation is not execution; these controls do not replace owning-lifetime,
real-effect or full-program gates.


2026-10-26 empirical boundary update: the integrated compiler linked with this serial runtime completed the full fixed compiler request with exact QBE. The [full comparison capsule](serial-rfc-full-evidence/summary.json) records one atomic/serial pair (266.8624s / 249.6785s, 6.44% less request time). This is a single pair and does not transfer qualification to a new N2 image. It exercises NativeHost.read on this compiler path; dedicated path/publish and batch/session smokes remain separate obligations for the selected final chain.
