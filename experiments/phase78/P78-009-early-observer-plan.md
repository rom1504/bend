# P78-009: plan observers before generic lowering

Move successful observer routing before scheduler lowering in the private checked,
effect-admitted, no-bang path. Derive eligible direct entries from the same positive
arity gate as `nd_extend_arity`. Carry the completed route in the native plan and
permit omission of the now-redundant generic body. Scalar observers retain their
ordinary worker, and declined routes retain normal lowering. Raw/bang paths keep
late routing and their original validation/error order. No public book payload may
grant early-plan permission.

This changes generated C and fresh IDs, so an exact-old-C test is not appropriate.
First require checked B1 plus independent compile/execute on six native families.
Then time against the frozen Phase77 B1 and upstream; broad raw/observer/threaded
and B2 checks are required before selecting it. Reject if the generic work removed
is too small to justify the extra plan state. The hypothesis is structural work
avoidance across all admitted observers, not a String.cmp-specific shortcut.
