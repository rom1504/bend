# Independent source review of the projection ceiling

Bounded review of `projection-source01/plan.json`, its saved-QBE transformer,
runtime extension and ordinary-state controls. No target ran in this review.
No blocking semantic mismatch was found for the explicitly experimental ceiling
on valid ordinary published Data. This is not compiler admission, qualification
or a production implementation.

The matcher replaces complete terminal blocks only: one bounded constructor
take, all distinct field loads, an increasing sequence of distinct field sinks
excluding the result, then return of one loaded field. It accepts no additional
observable instruction. The function-level scratch check requires one private
2,048-byte allocation and permits only derived addresses, loads and recognized
takes; escaping or otherwise used scratch is rejected. Valid original QBE gives
the SSA/terminal-control context. Exact edit replay authenticates every changed
byte; 84 branches are selected from the retained checker program.

The runtime fast path preserves the ownership distinction:

- It requires the original constructor arity, a nontrivial RFC constructor,
  a heap payload and a parent count greater than one.
- Before mutation, every child must be trivial or a nontrivial positive-count
  RFC value with conservative headroom for all possible repeated field aliases.
  An omitted unsunk field must be trivial. Unsafe cases fall back unchanged.
- It retains the escaping child once, then releases one parent reference. The
  still-shared parent cannot destroy any child. Other children retain the same
  final counts as the old bump-then-sink sequence, including duplicate aliases.
- The count bound is deliberately stronger than necessary, so the original
  temporary bumps cannot overflow on the fast path. Near-boundary values keep
  the original operation and its ordering; no failure probe was added.
- Raw/static/RFC-unique/packed inputs keep the original take and exact ordered
  sinks. Atomic and device configurations compile out the fast path.

The fallback preserves whether the original call used `p111_rt_take` or one of
the arity-specific `p125_rt_takeN` helpers. It uses a private bounded local
buffer and sinks exactly the old literal mask in increasing field order.
It does not replace unique-parent destruction with a bare parent drop.

The 24 differential rows construct ordinary published values via runtime APIs,
cover raw, RFC-unique and shared parents with distinct or duplicate owning
children, and compare the complete heap/result snapshots before and after
retained-root/selected-result consumption. Separate ordinary static and packed
rows exercise fallback. The runner checks exact complete stdout/stderr and
requires atomic-with/without-fast-flag executables to match. These are ordinary
state controls, not malformed-input or resource-failure probes.

Two interpretation limits remain. The timed checker output is its retained
digest, not a collision-free comparison of all checking values; successful
timing is a ceiling screen, not enough to qualify the transformation. Also keep
the original versus ABI-only comparison distinct from fast versus ABI-only:
the helper call and runtime layout may cost time even before its fast path saves
work. Four balanced observations are screening evidence, not a precise universal
speed estimate. Production would still require a checked Bend transformation,
independent import/ownership admission and broader complete-value controls.

Reviewed SHA256 identities:

| File under `experiments/phase169/tools` | SHA256 |
|---|---|
| `prepare-projection.py` | `34c7e85c58de4eca020ca91d677f8ebce84b7e513f92ab5fe3f4a15ac68a0184` |
| `run-projection.py` | `6342bc9cf7041a434ca0709c9674c0d5077a8e722dc11e80bfe02f4c923d9b23` |
| `projection-census.py` | `306e395e0ffd47fc842b7a4918029079bf38e0f6de7967e14b9ce088f457c968` |
| `projection-runtime.inc` | `daf73edde95e2acfbdb916cfc26ecc63b0d84066f888a7a19647d62dc27ceef6` |
| `projection-controls.c` | `a80e78b55967b05e3402b0ccd306ab7677f5848cbb7106a8affff5947c706af1` |
