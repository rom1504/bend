# Runtime-activated scoped reentry observer

Use `scoped-reentry-controls-v2.mjs` with the same arguments and checked API
as the original transport. It selects `scoped-reentry-controls-v2.c` and
retains the unchanged Bend fixture, five compiler-data checks, literal stdout,
authority gates, pinned runtime/toolchain, and both machine routes. No new API
acquisition is required: only the host observer and driver changed.

The first observer invoked the retained `p111_rt_frame` before runtime
activation. That helper reads the active descriptor's segment count during
its FID validation, so an otherwise valid private worker could dereference
the null active program pointer. The previous all-expanded sentinel did not
exercise this helper.

The v2 observer calls the public `p111_rt_main` with a complete static
descriptor. Original fixture FIDs 0/1/2 keep their arity, flags, and result
metadata. An additional closed main at FID3 returns a no-capture action at
FID4. The action applies the runtime-provided continuation to Unit; normal IO
dispatch completes without printing. The original 84 observations then run
with that descriptor active. Original fixture segment dispatch is an explicit
abort, since the generated private workers must handle their entire region.

No runtime implementation, internal binding symbol, or fake frame helper is
introduced. The result recurrence, complete state-byte comparison, all stack
word comparisons, guards, depth range through 100001, and exact expected
stdout remain unchanged. All prior files remain intact.

This revision received source inspection only. Root owns compilation and
machine execution; this note does not claim a passing run.
