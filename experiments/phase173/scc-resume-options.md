# Phase173: whole-computation admission before general continuation machinery

Bounded source audit, no targets or production edits. The current store import,
export, reference and compaction source components are tail-recursive state
machines. Their non-tail calls to node access, emission and other computations
are outside the recursive component. Therefore **general non-tail recursion is
not yet an established requirement** for this experiment. The raw candidate
diagnostic should distinguish lowering errors, missing dependencies, return
adaptation and real non-tail internal calls before another implementation.

## Preferred narrow repair if return adaptation is the barrier

`p113pl_call` selects an available `NQSig` product route. A boxed caller can then
receive a product result, construct a box, and return it. That is no longer the
exact `Call; Result` vector accepted by tail-SCC fusion, even when the source
call was tail. Conversely a product caller can fall back to a boxed callee and
unpack its result. A mixed cycle can therefore be blocked by calling-convention
choices rather than source semantics.

If the diagnostic confirms this, choose one result convention for the closed
component and preserve it on every internal transfer. Use the existing checked
`NQSig` facts to justify any product convention. The smallest conservative
fallback is a common owned single-Term convention internally, keeping external
product optimizations and original public wrappers. Product boxing should occur
at actual observation/exit boundaries, not solely to satisfy an intermediate
helper's independently selected convention.

This is a regional ABI decision, not source-name recognition. It still needs
exact argument/result compatibility, owned-value transfer, alias preservation
and the unchanged final verifier. It may sacrifice some flat argument transport
initially; compare complete runtime and actual boxing counts. Do not infer
profitability from admission alone.

## If genuine non-tail internal calls remain

There are two substantially different extensions.

### Reuse existing semantic continuations

The smallest defensible starting point is the already verified generic
`N111Segment` representation and the `P114H` local continuation machinery in
`selfhost/src/back/qbe/local-continuations.bend`.

Today it represents one recursive owner, a bounded table of continuation cases,
and already-ready external helpers. It retains the original runtime frame
operations, restores captures and handles the result through local unwind
dispatch. Extending the **owner set** could reuse this ownership knowledge:

```text
ClosedRegion
  entries: source identity, arity, local state identity
  continuations: original identity, captured slots, result contract
  blocks: original scalar work plus verified local transfers

Tail(target, arguments)
Descend(target, arguments, original continuation frame)
Return(result)
Resume(original continuation, result)
CallReady(verified external helper, arguments)
```

Every transfer would preserve the original argument evaluation and snapshot
before changing lanes. `Descend` retains the original already-established frame
ownership operations and increments local depth. `Return` either exits the
region or restores one authenticated continuation. Calls inside the region use
local labels/state transfer; they do not recurse on the native stack. Unknown
dynamic calls, effects, capture layouts or escaping continuations decline.

The initial generic public contract is one owned Term. That can contain the
ordinary Tuple, preserving existing results without inventing a mixed-vector
resume ABI. External flat helpers can retain their already-verified wrappers.
A vector extension must explicitly record and verify all result lanes and their
layout; merely increasing the capture-count bound is insufficient.

The existing final segment verifier must still accept the complete original
program. An additional region-plan checker must independently match each local
transfer and continuation to those verified bodies. Do not mark recursive
machine calls ready, weaken the direct verifier, or treat an arbitrary emitted
label as a semantic certificate. Public entry adapters can select the new local
region without claiming that it is already an ordinary acyclic P113D worker.

This reuses existing frames and boxed results, so it initially removes dispatch
and register-bank transitions rather than all frame/tuple allocations. That
limitation is desirable for a controlled first experiment.

### Synthesize continuations from arbitrary direct IR

Splitting an arbitrary `P113DCall` into a resume block is less economical. A
correct implementation must determine exactly which live values cross the call
and distinguish owned Terms from raw scalar and pointer temporaries. It must
preserve keep/drop credits, tuple/result conventions, scratch lifetimes, error
behavior and bounded native stack use.

The existing `P113DStmt` representation does not provide a universal semantic
ownership certificate for every U64 temporary. Storing arbitrary live U64 bits
in an ordinary owned constructor is not justified: some words can be layout or
address intermediates. Similarly, adding runtime stack calls to direct IR is
not permitted simply because the generic runtime has such operations. Its final
verifier has deliberately narrower contracts.

This route can eventually be valuable, but it is not a small extension of the
current tail fuser and should not be built to fix an unconfirmed ABI mismatch.

## Smallest decisive test

First obtain the exact refused candidate and first blocking edge from the real
store request. If it is only return adaptation, repair that regional convention
and require the complete state machine to become direct with unchanged output.
If it is a real internal non-tail call, extract the smallest two-entry region
with one owned continuation frame and one already-ready helper. Compare exact
outputs at deep recursion and with shared/aliased input; verify original frame
counts, transferred words and disappearance of scheduler transitions.

Do not start with all 36 compaction states. The parent already found that helper
fusion alone improves the store workload by only about 5.7% while the store
remains much slower than the original term computation. The next experiment
must admit a complete measured computation or reject that direction promptly.
