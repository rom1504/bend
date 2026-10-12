# Capability and shared-error gates

These supplement the closed first 15 source controls; initial authoring is
source-only. Do not treat a passing output as proof of optimization refusal.

`foreign-refusal.bend` must print 7087. Its reachable user foreign definition
must disable observer permission, even though this effect itself is benign.
The imported Strand observer can still have a valid structural plan; the host
adapter must choose the ordinary route without checked effect permission.

`parallel-shared-root.bend` must print 7795 at one/four threads. A bang activates
pool scheduling outside the ordinary observer call. Two jobs consume distinct
owners of the same dynamic Strand. Inspect observer admission separately from
the output. This case exercises real shared ownership, not cancellation.

`raw-observer-cases-v1.mjs` uses the existing custom-raw schema. The inert forged
context must return 7n; forged internal return/loop core nodes must be rejected
without emitted C. Exact diagnostic wording need not match. Raw C must leave
the new checked observer permission undefined/false. No source annotation,
book marker or generated-looking name can activate the private observer ABI.

Once the emitter exists, root should derive separately pinned diagnostic C
copies for three deterministic error checks:

1. Set the ordinary runtime shared-error word before entering a nonsequential
   observer adapter. It must propagate failure before reading cursors or
   allocating the result wrapper, matching the ordinary route.
2. Inject a shared error after the observer succeeds but before the adapter
   allocates its output wrapper. The adapter must preserve its existing error
   check and return failure; success does not authorize ignoring cancellation.
3. Raise a shared error during a long borrowed traversal. The established
   `err_spun` polling policy must observe it. Keep the owning roots alive until
   the whole observer invocation exits; no dangling cursor or C stack growth.

Use existing runtime error posting/observation and stable insertion points in
both baseline/candidate. Record insertion coverage so a missing observer does
not become a vacuous pass. No diagnostic timing earns performance credit, and
CPU error injection does not establish physical GPU correctness. Internal
helper failure must propagate its success/error result without dropping or
reordering previously demanded scalar operations.
