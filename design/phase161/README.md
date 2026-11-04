# Phase161 — source size and architectural work versus bendc

Start d3588cf, selfhost/bootstrap,2026-11-04. User explicitly asks to investigate
the second difference: complexity and amount of compiler work, not another
execution-runtime tuning campaign. Target a bounded60–90min investigation,
with findings/evidence committed and pushed, no production promotion.

1. Hold the executing original Phase156 QBE request image, Base, full checking,
   optimizer, verifier and write protocol fixed. Compare qualified3.085MB source
   with the Phase1601.698MB native-main closure. Source-check receipt and exact
   kept-declaration/owner identities are prerequisites. Measure fresh complete
   request time/RSS/output; require the original full-input oracle. For the
   smaller input compare full output and classify any difference before treating
   it as an equivalent compiler. Keep compiler execution and input changes separate.
2. If emitted QBE is identical, reuse the qualified machine product under exact
   runtime/toolchain identity and avoid redundant full-image construction. If it
   differs, inspect function/data census and build/test the candidate only if
   the measured benefit justifies it. Preserve installed and qualified images.
3. Use the existing stage profiler, if its retained image and input contract
   admit the new source economically, to separate frontend savings from surviving
   lowering/optimization/emission work. Do not add nested stage timers twice.
4. Two bounded independent source audits compare frontend/core/checker and
   backend/optimizer responsibilities with pinned current bendc56ed. Count
   meaningful source regions and representations, not generated text as source
   complexity. Trace equivalent computations, identify work bendc avoids, and
   distinguish necessary semantics from representation/analysis duplication.
5. Combine measured stage costs, source complexity and existing work counters
   into one ranked simplification proposal. Test a small falsifier if it has
   stronger information value than further measurement. No large rewrite or
   broad self-hosting campaign merely to investigate architecture.

One root-owned CPU3 target lane, ordinary2GiB RSS/16GiB available RAM floor,
5GiB disk reserve and explicit per-run budgets. Before jobs, authenticate and
prune only the three archived Phase156 request-image bulk intermediates
(program.ssa/.s/.o); retain the ELF, source, maps, reports, runtime and all
qualified compilers. Those raw files are not consumed by the selected request.
Document exact archive recovery. No directory-age pruning or lock replacement.

Keep failed attempts, full identities, independent output gates, stage/profile
quality, acquisition versus request time and resource costs visible. Source
closure is target-specific assembly, not removal of maintained JS/C/QBE features.
