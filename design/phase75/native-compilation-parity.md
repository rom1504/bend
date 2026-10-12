# Phase75: native compilation parity without runtime regressions

Use the Phase74 evidence to remove work from checked Bend-to-C requests.
Keep compiler algorithms in Bend, current upstream0592662, one guarded target
tree, CPU3,2GiB RSS/4GiB available floor, Node1GiB heap/4MiB stack. No agents
or PR comments. Preserve Phase73/74 and inherited unrelated work.

1. Move worker admission ahead of generic lowering. First prototype only skips
   scheduler bodies for already-admitted positive-arity host workers in checked
   programs with no bang calls. The runtime enables device evaluation only when
   BANGS is nonzero; preserve the complete original path otherwise. Curried
   adapters, partial calls and unadmitted functions remain. Keep raw behavior.
2. Measure the short checked B1 loop, then genuine B2 for useful candidates.
   Preserve worker code and audit generated changes. Require native execution
   checks when C changes; never infer semantic equality from timing.
3. Reuse native request facts and eliminate avoidable repeated candidate work.
   Test stable compact occurrence facts only with a concrete source/CPU reason.
   Existing indexes are already compressed tries: do not claim a32-level cost.
4. If justified, extend the native plan to precise required entries and reusable
   library products. Changes must preserve source identities, demand/errors,
   foreign behavior, stack safety and device/parallel fallback requirements.
5. Once the fast loop shows useful gains, run broader native/raw/JS checks,
   the twelve-family generated-program runtime comparison, genuine B2/B3,
   paired upstream/B1/B2 compilation and release qualification. Also test a
   small non-harness program and a larger user-dominated compilation source.

Report unsuccessful trials and actual ratios. B2 deployment, warm service,
fresh requests, Base preparation, Clang and execution remain separate metrics.
No performance claim comes from diagnostic image patches. Do not accept a
generated-program slowdown to improve compilation. Prefer removing/replacing
existing passes to layering permanent alternative pipelines. Commit the design,
meaningful implementation milestones and final report; push throughout.
