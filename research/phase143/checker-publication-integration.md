# Prepared-Base boundary for the private checker prototype

Source-only integration investigation. The frozen fresh-seed prototype remains
unchanged; `checker/prepared-v02.bend` and `prepared-controls-v02.bend` are new
append-only modules. No target was executed and no production entry was edited.
Their source checking and semantic gates are pending. The initial control source
has a retained affine-binding check failure; the coordinator owns its v02 fix.

## Exact construction retained

Parent is Phase142 indexed-source02, SHA256
`15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1`.
The actual ordinary route is `p86_plan_loaded`(37897) →
`check_program_diagnostic_world`(10532) →
`base_prefix_program_world_book`(10522) →
`base_prefix_world_check_admitted`(10509) →
`base_prefix_world_resume_state`(10425).

The new `p143cb_resume_state` copies that last function's world construction:

1. Run original `check_declarations(suffix, kw_bound_book(saved, bound+stamp))`.
2. Run original `base_prefix_world_order`, retaining the observable Base-first
   raw list and the already extended index. Do not substitute the simpler fresh
   seed's declaration order.
3. Construct the same `KWorld{ordered, [], Known(bound+delta+1), checked}`.
4. Retain the original bounded saved `seen` book.
5. Run the private scheduled event loop and canonicalize its complete result.

The public experimental adapter retains ready/parse-error checks, the same
`max(savedBaseBound,max(suffix))`, and original `base_prefix_world_admitted`:
ready state, bounds, delta/stamp limits, admissible suffix names, disjoint saved
names and constructor constraints. It also retains the **original full-hash
collision fallback** through `base_prefix_world_check_admitted`, which replays
via `base_prefix_resume_saved` when necessary. No new result is substituted for
that fallback. A nonregular source-event list also takes the original route.

`p143cb_program` retains `driver_program_checked_prefix` with the saved TODO
count on admission, and original `driver_program_checked(...dg_check_world)`
on refusal. Thus errors, incomplete-law reporting and source finalization keep
their prior branches. `p143cb_plan_loaded` preserves the parse error and calls
the original `p86_plan_checked`; report preparation, ownership validation,
eligibility, context construction, erasure and later verification remain there.

## Private input authority and possible hook

The actual caller must couple the prepared world and `FPrefixLoad` through the
same authenticated `P86Seed` and current loader result. This is the existing
private prepared-Base premise. Bend constructors are not sealed capabilities;
the adapter does not authorize arbitrary hand-built saved worlds or a different
Base prefix. The saved canonical book plus the ordinary declaration/order
construction supplies the log invariant. Disjoint prefix/suffix names prevent
canonicalization from merging unrelated source events with Base definitions.

If qualification succeeds, the smallest ordinary-request hook is a single
`p86_plan_loaded(seed,load)` delegation to
`p143cb_plan_loaded(seed,load,True{})`. This is a proposed hook, **not installed**.
It avoids a global `dg_check_events`, `book_put` or normalizer override and keeps
the original prepared checker available as the independent oracle. Logically
equivalent fresh and prepared entry cases require separate actual tests.

The fresh entry already exists as `p143cp_check(book,logging)` / `p143cp_seed`.
An empty book or empty suffix is supported, but the latter still carries genuine
saved Base state. A refused prepared load deliberately uses the original full
checker rather than opportunistically enabling another new path. Empty suffix
logging may still pay canonicalization; that cost is part of the measurement.

## Proposed exports and gates

Append `prepared-v02.bend`, then `prepared-controls-v02.bend`, after the checked
private core and complete-state observer. Export:

- `p143cb_check_load`, `p143cb_program`, `p143cb_plan_loaded`.
- `p143cbc_controls`, called with the actual authenticated `P86Seed`.
- Original `base_prefix_check_world_load`, `check_program_diagnostic_world`,
  `p86_plan_loaded`, and `p140pl_load` for same-API differential observation.

Six proposed prepared controls load an empty suffix, ordinary bodies, a type
failure, successful specialization, a failure after specialization and a forced
unready load. They compare complete `DChecking` and `DResult`, including indexed
book structure, memo, fresh state, checked bodies and diagnostics. They use the
actual Base seed and never forge a ready saved world. The forced-unready row
pays the real full-check fallback and must be timed outside the optimization
screen. It is not a cheap cache hit.

Additional integration gates still needed: genuine Base/suffix full-hash
collision replay, source-law/TODO handling, successful and failed template
rollback with nonempty memo, relevant foreign/effect definitions, and complete
ordinary frontend plan/QBE equality on unrelated requests. Those are not
established by six finite rows or the earlier source-only observer audit.

## Scaling fixture and host-runner requirements

The coordinator's same-API synthetic100/500/1000-definition screen is a useful
first discriminator. Parse each source once, retain the exact resulting book,
and compare original, schedule-only and schedule+log modes on that same book.
Check complete outputs outside timing and balance order. A simple `Bit` program
does not model compiler template/checking complexity; label its results as a
constructed checker stream, not full-compiler speed.

For a cheap **actual-source publication ceiling**, obtain the current compiler's
post-freshening declarations, select500/1000 real publication rows, and replay
original versus logged updates from the same canonical declared world. Charge
index maintenance, canonicalization and cleanup. This isolates list-publication
cost and does not claim to execute the whole checker.

For actual500/1000-event checking, merely truncating the input is insufficient:
future headers must remain visible, and next-same-name relationships can extend
beyond the cutoff. Either use a bounded observer which stops the genuine full
event stream while retaining its full suffix schedule/world, or run complete
independently valid source subsets with their dependencies. A fabricated shorter
`FPrefixLoad` must not be reported as the real compiler's first1000 events.

The first complete prepared-Base test can simply compare original
`base_prefix_check_world_load` against both `p143cb_check_load` modes on an actual
full compiler load. That isolates checking from parsing and Base acquisition,
which should be reported separately. Subsequent full ordinary compilation is
the acceptance metric; neither proxy savings nor log-entry counts replace it.
