# Phase114 private Take2 exposure

Status: source-only prototype. The original owning graph and public verifier are
unchanged. Root owns all checker, ordinary-program, native and timing runs.

On the 39 preserved broad-suite candidate31 QBE files, complete private workers
contain 543 static `p111_rt_take` calls, including 368 count-two calls. They also
contain 858 constructor calls (634 count-two), 534 sink calls and only 12 keep
calls. These counts include cold and unused code; they are not dynamic costs.
Generic and old private segments account for many additional transitions and
remain unchanged. Tag extraction is already exposed by candidate31. Take2 is a
broader first experiment than another immediate-keep specialization; constructor
allocation is a separate next candidate.

The six modules in `modules01.json` add a private structured N111 template after
inlining and original verification. Append `model.bend`, `take.bend`,
`namespace.bend`, `transform.bend`, `program.bend`, then apply `entry.bend` as exact
overrides of `p113a_verify` and `p113a_admitted_chunks`. The baseline is the frozen
candidate31 compiler. Existing `p113a_lower_request`, `p113a_verify`,
`p113a_admitted_chunks` and the native admitted renderer keep their interfaces.
Export `p114rt_sites` to count eligible direct Take2 sites. Optional inspection
exports are `p114rt_take2` and `p114rt_template`.

The fast path requires an exact verified helper call with a private scratch
output, CTR tag, in-range CID with descriptor arity two, dynamic payload, and
either a raw owner or a count-one RFC owner. A new readonly full-word arity table
is derived from the original constructor descriptors. Each allocator hot queue
must remain strictly below its handoff threshold after the free. Every refused
case executes the unchanged helper before any mutation. Shared owners, decoded
static payloads, invalid metadata and queue boundaries therefore retain the
original behavior.

Both children are loaded and stored to scratch before freeing the old wrapper
and then the shell. The return value is two. Class-zero/class-one free lists use
exact runtime offsets 0/8 and 256/264, increments 1/2, and handoff threshold
32768. No allocator, representation, child reference count or wrapper creation
is changed. The shell/optional wrapper are consumed once; the two child words
carry the same ownership credits. Scratch is disjoint from heap by the original
verifier and exact local-origin gate. The runtime namespace protects temporary
locals and the new arity-table symbol.

The cached heap base is the existing candidate31 entry load. Runtime corpus
growth only extends the mapping at its existing address. Mutable payload,
allocator and wrapper cells are loaded when used. The aligned U64 wrapper load
matches `rfc_view` only within the authenticated CPU profile: the pinned runtime
main requires one thread and GPU off, and this synchronous private call tree has
no foreign ownership publication. CPU `err_post` fail-stops, so no pending error
can reach the ordinary free path. This is not a parallel/device expansion. The
source review by the independent laws agent found no concrete discrepancy under
these premises; it is not an extracted proof of the C runtime.

After root has composed and checked the API, run the source-only admission:

```sh
python3 selfhost/tools/performance/phase114/runtime/admit.py \
  --compiler selfhost/build/phase114/TAKE_SOURCE/compiler.bend \
  --api-report selfhost/build/phase111/TAKE_API/report.json \
  --runtime-source selfhost/build/phase113/runtime-products01/runtime.c \
  --runtime-object selfhost/build/phase113/runtime-products-build01/runtime.o \
  --out selfhost/build/phase114/TAKE_ADMISSION
```

The gate binds the full candidate31 declaration set plus this exact overlay,
checks the original candidate31 admission, runtime source/object and successful
API receipt, and refuses source-only mutations of the gates and templates.
Additional compiler changes require a distinct conjunctive recipe; this receipt
cannot be transplanted to a different source. Synthetic memory probes are not
part of the protocol. Independent ordinary positive programs live in the
Phase114 controls area: two owned fields, nested fields, sharing, final-owner
consumption, swaps and repeated reconstruction. Correctness, admission and
performance remain separate gates.
