# Phase90: locate native self-emission cost beyond the first minute

Prepared one longer capture of the unchanged native Phase89 compiler. The
180 s default samples every 16 ms, approximately 11,250 samples per busy thread;
the optional 240 s duration produces about 15,000, below the existing25,000
capacity. Root builds only a tiny watchdog preload whose duration bound changes
120→240. No full compiler C acquisition/build, runtime edits or sampler capacity
increase is needed. The source/image remain `4584cf08…` / `8bacae26…`.

[Tools and exact command](../../selfhost/tools/performance/phase90/profiling/README.md).
Preparation verified all343 admission/method/assets/library identities without
executing a target. The offline ownership-window reader reproduces the earlier
accepted752-sample stopped-Map prefix. Root owns the new target execution; no
late-profile findings are claimed by this preparation report.

This is a new investigation of later work, not a retry to turn the earlier
one-overrun capture green. Existing strict rejection rules remain unchanged.
Watchdog return77 never means successful self-compilation; normal return0 would
retain C for independent validation rather than automatically proving native B2.
The runner preserves outputs, failures, process receipts and before/after pins.

Use the 30 s monotonic wall windows to answer whether the String equality/name
projection activity persists, shifts to normalization/checking, or reaches native
planning/emission. Compare physical leaf and ownership return-site distributions,
not just total term_drop percentages. Sampling uses thread CPU timers, but the
timestamps used for binning are wall clocks. Neither windows nor changing symbols
constitute measured compiler-stage boundaries. Do not extrapolate a stopped
prefix into a complete self-compilation speed or removable-time estimate.

## If samples still do not distinguish stages

The frozen request's actual boundaries are:

| Frozen Bend source | Work |
| --- | --- |
| `compiler.bend:38414`, `p86_requests` | IO.now; plan+compile; consume returned Strings; IO.now; print; write C outside timer |
| `:38229`, `p86_plan` | Header/located source and imports, prefix source load, checking, reporting/entry guards, context, reachability, annotation, layout validation, NR_Request preparation |
| `:38280`, `p86_plan_loaded` | Successful parsed graph enters `check_program_diagnostic_world` |
| `:38293`, `p86_plan_checked` | Checked result enters `driver_report_data`, ownership/entry guards and context selection |
| `:38323`, `p86_plan_context` | Stops, reachability and `annotate_selected` |
| `:38329`, `p86_plan_annotated` | `jl_checked_error`, then `nr_prepare_annotated` |
| `:38390`, `p86_compile` | Foreign sources/effects, then `nr_compile_prepared` |

The exact source is
[`native-self01/compiler.bend`](../../selfhost/build/phase89/native-self01/compiler.bend),
SHA256 `4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618`.
Calling the entire `p86_plan` interval simply “parsing” or “frontend” would be
wrong: it already contains annotation and native request preparation.

The smallest justified stage-clock derivative for a **subsequent** checked build
adds a mark after evaluating `p86_plan`, another after `p86_effects`, and another
after `nr_compile_prepared`; retain the existing request-end mark after complete
String consumption. Emit a stage label with monotonic/process time at each
boundary and preserve error exits. This separates planning, foreign processing,
emission and output consumption without changing compiler algorithms. Confirm
the generated strict evaluation order and full output identity on a tiny case;
do not merely place a clock before a deferred computation.

If planning itself dominates, one second-level host derivative would expose
the existing loaded/checked/context/annotated continuations as IO steps, placing
marks at their existing product handoffs. Do not instrument recursive helpers or
change evaluation order inside the checker. Those extra effect boundaries can
change lifetimes and fusion, so they are diagnostic timings, not clean speed
results. This requires a checked full build and is deferred until the unchanged
late capture demonstrates that it is necessary.

Existing preload clock interception observes actual IO.now effects only. It
cannot turn the current pure internal helpers into exact stage clocks without
new instrumentation; physical samples alone cannot supply missing boundaries.
No stage-clock source derivative or production change was made in this task.
