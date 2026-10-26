# Current ordinary cold self-build: first profile

The current Phase142 N1 compiled its exact current source to the independent
qualified-Phase137 QBE oracle in **374.677 seconds**. The matching diagnostic
runtime relink completed the same output in **386.466 seconds**. This single
diagnostic/clean comparison is 1.0315×, not a precise overhead estimate.

`selfhost/build/phase143/profile01/capture02` passes all output and profiling
quality checks: 12,017 samples, zero dropped samples/overruns, 99.637% sampled
thread/process CPU coverage in the capture header, and 11,620 known dispatch
contexts. All 435 eligible bounded libc samples recover the `p111_set_regs`
caller. The actual process receipt includes a small amount of CPU after the
sampler's shutdown window; neither denominator implies every instruction was
observed. [Derived counts and exact input hashes](cold-profile-summary.json)
retain the complete process observations separately.

| Active Bend owner | All-sample share |
| --- | ---: |
| `lookup` | 6.27% |
| `index_remove` plus `index_remove_step` | 5.53% |
| `nc_ctor_owned` | 4.63% |
| `String.append` | 4.59% |
| `p111v_get` | 4.08% |
| `f_find` | 3.86% |
| `nb_contains` | 3.44% |
| `nc_occurs` plus `nc_occurs_list` | 3.35% |

Physical `term_drop`/`span_fade` occupy 27.48%; the borrowed string-equality
worker occupies 7.49%. Direct register transport plus its independently
recovered libc caller occupies 5.86%. These physical categories overlap the
active owners above. They must not be added to predict a speedup.

The [approximate CPU timeline](../../selfhost/build/phase143/profile01/timeline02/timeline.md)
shows predominantly `f_find`, lookup and index-removal work in the first
120 CPU seconds; constructor/contains/occurrence work through roughly 210;
verifier queries and late summaries later; and text construction in the last
approximately 55 seconds. These are CPU-order observations, **not established
frontend/checker/erasure stage boundaries**. In particular, they must not be
aligned to the separate JS/Bun wall-clock stages.

The strongest supported directions are:

1. **Remove repeated checker publication/reconstruction.** `dg_event_publish`
   performs `lookup(rest, dn(d))`, `book_put`, `kw_with_book` and
   `kw_put_checked`. Lookup/index-remove/publication active contexts sum to
   12.75%, but lookup serves other passes too. Eliminating immutable-book
   reconstruction might also remove associated reclamation; its extra benefit
   is not established by adding the global 27.48% reclamation share. A persistent
   publication view should first demonstrate the original lookup/shadowing/order
   semantics and reduce actual repeated work, then pass a complete cold request.
2. **Fix repeated occurrence and constructor-classification queries.** The direct
   occurrence pair is only 3.35% of this full build. A dramatic kernel speedup
   alone therefore need not produce a large build gain. `nb_contains` has mixed
   callers and cannot all be assigned to occurrence. Constructor ownership is a
   separate 4.63% lead, prominent in the middle windows. Share exact book-derived
   summaries when semantics permit, rather than introduce another broad cache.
3. **Keep verifier lookup and output construction as later measured targets.**
   `p111v_get` accounts for 4.08%, while text construction dominates late windows.
   `p111q_body_text` already uses `nt_text_finish(chunks, "")`; it is incorrect
   to assume every output path is a naive repeatedly concatenated growing prefix.
   Inspect dynamic copying before redesigning emission. Existing independent
   final verification remains enabled.

Another adjacent source-backed opportunity is constructor-name membership:
`event_error` → `constructor_names` → `constructor_exists`, and
`base_prefix_ctor_disjoint`, still repeatedly scan completed definitions.
Its current cold active share is only 1.51%, unlike the earlier warm-profile
11.13% local window. An exact constructor-name index may be useful as part of
the publication view, but that historical warm fraction is not its cold gain.

The failed first capture is retained. The selected Phase140 sampler lacked a
compiled unwind table, so the process refused immediately with status 125.
Version 2 reuses the authenticated Phase127 CFI sampler compiled with the exact
libc table/header. It changes neither the diagnostic compiler image nor target
inputs. The corrected metadata, failure receipts, attribution and timeline all
remain under `profile01`; no profiling failure is presented as performance data.

The full hosted comparison was stopped at its 3 GiB memory guard during the
frontend, after approximately 231 seconds. Only Base preparation completed in
its stage receipt. This is a resource-limit result, **not a successful full
JS/native runtime ratio**. Raising memory or changing the input requires a new
explicit observation rather than filling in the missing stages.

An optional native boundary recorder is now source-prepared under
`selfhost/tools/performance/phase143/milestones/`. It compiles only a tiny
diagnostic runtime delta and relinks the unchanged current object. Its eleven
ordered direct-entry markers must first pass a small exact-output request;
missing or inlined entries invalidate attribution. This could supply actual
checking/annotation/erasure interval ceilings without acquiring another full
compiler image. It has not been built or run by this investigation.
