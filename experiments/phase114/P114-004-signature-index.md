# P114-004 — restore the mature product signature index

Source review found an omitted existing optimization: mature nf_plan_scoped
wraps nq_signatures in book_cached(...,0), while the new product planner passes
the linear list into repeated candidate, shape and call lookups. The failed
full-source acquisition requests2707 names. An unchanged exact-name index could
remove quadratic lookup work without changing any semantic decision.

Two isolated overrides restore that representation for production planning and
diagnostic candidate discovery. Existing tail-first index construction preserves
the list's earliest-definition-wins behavior, including duplicate shape keys.
No new table implementation, lowering rule or identifier allocation is added.

The candidate composes with verification reuse. Checked acquisition passes;
both staged kernels emit byte-identical QBE. Single-run product-lowering times:
local-pair1.772→1.629s; list-pipeline1.363→1.339s. These small-source diagnostics
do not establish a large-source benefit or a statistically qualified ratio.
Full-source stage timing is the decisive next measurement. Preserve the final
verifier and stop if output changes or resource limits are exceeded.

Source SHA256 `1211ff97bf853d63d093b787c35ee7de4eaca96e514262541ce3864143778e43`.
Exact source reasoning and helper pins: `scaling/catalogue.md` and
`catalogue-modules01.json` under `selfhost/tools/performance/phase114`.
Receipts: `selfhost/build/phase114/catalogue-split01-*`.
