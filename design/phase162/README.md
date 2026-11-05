# Phase162 — explain the frontend gap on identical source

Start6c645c3,2026-11-04. The user asks to investigate the unexplained speed gap;
previous source inventory and own-stage profiling are not a quantitative
explanation. Hold source and Base fixed and first compare parsing/loading,
checking and reporting boundaries across our qualified compiler and pinned
bendc56ed. Source checking, unsafe/proof verdict, normalization and code generation
are different tasks; confirm actual work before interpreting times.

1. Reuse existing images, exact sources and same-host serial CPU3 lane. Start
   with ordinary valid source and finite parser/type error controls. Identify
   compatibility failures rather than silently changing source or Base.
2. Use bendc's explicit parse/check-only modes, but audit reporting/exit behavior
   and actual body checking, especially @unsafe. Use identical source bytes where
   admitted. If a layout adapter is necessary, require the existing independent
   structural parse gate and disclose it.
3. Reuse our accepted Phase161 stage profiles and exact native object. Build only
   a small diagnostic terminal/runtime adapter or extracted checker when needed;
   do not rebuild the complete compiler just to time the frontend.
4. Compare semantic work, allocation, lookup/publication and term processing.
   Choose counters from profiles, verify their exact source/native boundaries,
   distinguish inclusive call counts from total work, and keep clean timings
   separate from instrumented runs. Do not infer operations from sampled bytes.
5. Seek a falsifiable mechanism with a quantitative ceiling and a small causal
   ablation. No production optimization/rewrite unless the investigation itself
   demands a tiny reversible diagnostic. Preserve errors, independent outputs,
   exact input identity and final verifier/qualified selection.

Two bounded source-audit agents; root alone runs targets. Maintained resource
and disk guard for every target, ordinary2GiB RSS/16GiB available floor and5GiB
disk reserve. Larger budgets require measured need; no unsafe runtime probes.
Use explicit artifact budgets and archive/verify before deletion if needed.
Report same-source observations separately from different-compiler self tasks,
published unchecked times, machine construction and whole-program runtime.
Commit/push the design, reproducible evidence and honest report; no PR comments.

Execution refinement: exact operation counts required code-site hooks unavailable
in the retained QBE object. Recompile the already frozen generated C artifacts
(two roughly95-second good diagnostic acquisitions), rather than regenerate Bend
source or conduct native self-hosting. Retain the first wrong-thread observer
acquisition as rejected evidence. This trades bounded acquisition cost for exact
loop counts and a same-image publication-policy ablation.
