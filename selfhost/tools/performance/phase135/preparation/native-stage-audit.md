# Why the full edit now needs native stage clocks

The actual Phase135 compiler-source A→B experiment reused1387/1507 private inline
and prior-range units on B, while A took362.510s and B374.922s. Both complete
outputs match their independent107MB QBE oracles. This demonstrates legal reuse
at full scale, but **not** end-to-end acceleration. A and B are different inputs;
the result alone also does not isolate cache overhead or establish a regression
against an uncached B. The root is collecting that comparison separately.

Evidence: `selfhost/build/phase135/full-session01/report.json`. The measured
image is the frozen Phase134 experimental session, not a newly qualified default.

## What existing profiles can and cannot answer

The full-source Phase131 active-context capture attributes7.48% to
`nc_ctor_owned`,5.43% to`lookup`,5.20% to`f_find`,4.43% to`p111v_get` and4.17% to
`String.append`. A separate physical capture attributes29.38% combined to
`term_drop`/`span_fade`. These are active contexts or physical leaves, not
inclusive source stacks or stage boundaries. They cannot tell us which fraction
belongs to parsing/checking, annotation/erasure, generic lowering, private
preparation, verification or output. A late String/ownership sample is not by
itself a rendering sample.

Phase134's detailed stage timings are hosted small-request diagnostics. The
9.0–25.9% private-candidate preparation range and the large lexer inline/range
shares cannot be transferred numerically to the native full compiler. Native
same-image timings are now the high-information discriminator.

## Minimal instrumentation chosen

`stages-v02.bend` reroutes only the experimental framed entry's
`p135ms_prepared`. Ordinary requests and the original phase134 session remain
untouched. It uses these exact existing computations:

| Interval | Exact computation charged |
|---|---|
| `frontend_ms` | `p86_plan`: parse/check, annotation, merged book, native reachability/erasure and associated setup; not checking alone |
| `lowering_ms` | Runtime admission, `p113a_certificate`, `p128raw_lower_request`: compile admission, constructor/static preparation, generic lowering, raw private candidates and initial candidate closure |
| `optimize_ms` | Unchanged `p134u_session`: opening verification, cache checks/transformations, commit checks, final verification, borrowed-helper closure and sealed emission planning |
| `render_ms` | Existing framed writer: render context, text generation, writes/close and any downstream pipe backpressure |

Each boundary matches the returned data constructor before reading`IO.now`.
The corrected v02 explicitly matches`P128RawLowering`, rather than only the new
wrapper around it. The clocks do not bypass a verifier or change an optimizer.
The sum of the four durations must equal the corresponding original A/B duration.
All added diagnostic lines are printed only after both outputs have closed, so
they cannot corrupt the framed output streams.

The shared pure factory/completion has an independent bridge export
`p135t_pure_plan`. `stage-bridge-v01.mjs` compares it with original
`p134ns_planned` on Lexer and Closures, each with an actual A→edited-B transition.
It compares complete outputs, returned cache values and statistics; A also
matches its frozen oracle and B matches fresh ordinary compilation. Three
frontend/admission refusal checks preserve the original short circuits. These
passed in `selfhost/build/phase135/stage-bridge01/report.json`: both real edits,
exact full returned caches/statistics and all three refusal cases. The root ran
the checked bridge in 29.44 s guarded (28.50 s inside the harness, 513,007,616 peak
RSS bytes). The source was the checked machine-source02,
`391a6f2dde2ef960a2d8b33a3100a0d9ba53ff68848a2279d502f7858019091c`, through
`selfhost/build/phase111/p135-machine-api02/report.json`. The framed candidate's
121 finite controls also passed in `selfhost/build/phase135/machine-finite02/`.
The pure bridge does not pretend to execute IO. Subsequent native framed gates
and the full-source session completed; the latter receipt is
`selfhost/build/phase135/machine-session01/report.json`.

## Strictness and scope audit

The relevant source is the frozen Phase134 session source04; its declarations
remain unchanged in the instrumented image except the new framed entry routing:

- `p86_plan_loaded` forces checking, and `p86_plan_annotated` produces
  `P86PlanReady{nr_prepare_annotated(...),verdict}` (lines 38403–38459). The ready
  request contains the prepared/erased book, not an unevaluated IO computation.
- Native constructor and call arguments become ordered lets through
  `nc_sequence` (32445) and `nd_bind_value` (32857). The generic
  `p112_liveness_cut` (41073) pushes a continuation, evaluates the current value,
  then resumes its consumer. This is the source-level reason the diagnostic
  records hold evaluated fields; a constructor match alone would not provide a
  general deep-forcing guarantee for an arbitrary lazy language.
- `p128raw_prepared` (56422) calls generic compilation and raw-candidate
  preparation before `p128raw_plan_finish` can construct the result. Its
  `p113d_finish(p113d_passes(...))` also belongs before the lowering clock.
  `p135t_raw` explicitly matches that actual `P128RawLowering` before reading it.
- `p134u_session` (58908) opens/verifies, runs the units, commits and reaches
  `p128raw_lowered` (56502), whose original final verifier and borrowed closure
  run before a `P134UEmission` is returned. The emitted `P134Planned` intentionally
  stores data for later rendering; `p134e_begin` (57867) builds rendering context
  in the writer, so that work is charged to rendering.
- Runtime `io_now_run` (runtime-borrow01/runtime.c:3242) returns
  `io_tick()/1000000`: these are monotonic **milliseconds**, not nanoseconds.

These coarse intervals include generated orchestration, reference management and
cleanup around each boundary. Ownership destruction can be charged where a
value's last use ends, rather than where it was originally allocated. They are
therefore stage wall times, not additive source-function self profiles. The
diagnostic adds small records/closures and clock effects; no claim of zero
instrumentation overhead is made. The root should use the same instrumented
image and method when comparing variants.

## Completed full-source observation

The instrumented framed route's edited B request reports 175.080 s frontend,
62.179 s lowering, 68.360 s optimization and 72.677 s rendering, exactly summing
to 378.296 s. Its old A request reports 153.539/59.651/77.613/90.517 s, summing to
381.320 s. Both complete outputs match their independently frozen QBE oracles;
the machine consumers also complete. These are different inputs and retained
cache states, so their difference is not a controlled per-stage cache speedup.
Rendering includes downstream machine backpressure, as designed.

The largest B interval is now concretely the frontend (46.3%). The small late
ownership-table prototype does not run there and should not be credited with
headroom from that entire interval. Its separate hosted screen is mixed and
remains unselected; see `implementation/phase135/preparation/README.md`.

This is intentionally a coarse discriminator. If opening/final verification
dominates the remaining interval, the next refinement can split existing
`p114s_open_lowered`, `p134u_optimize` and `p134u_emitted` calls. If the frontend
dominates, inspect checking versus `nr_walk` erasure before adding another backend
memo. Do not expand the cache based on hit counts alone.
