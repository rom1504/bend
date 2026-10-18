# P107-005: stop optimizing definitions the entry no longer uses

Status: implemented and finite semantic controls passed; retained in experimental
compositions. Initial source preparation ran no targets; later parent-run
evidence is recorded below. No standalone universal pass-speed gain is claimed.

The artifacts02 `many` entry-first pass spent about 473 ms optimizing a program
whose hot entry ultimately needs none of its 128 original helper definitions.
The [code-shape audit](../../implementation/phase107/code-shapes.md) establishes
the removed call chain and retained dead functions; it does not establish how
much of those 473 ms is avoidable. The hypothesis is that skipping helper
expansion after entry optimization reduces compiler work while preserving the
same useful entry body and global growth bound.

`nx_inline_demand`, in the new
[`inline/demand.bend`](../../selfhost/tools/performance/phase107/inline/demand.bend),
uses the existing deep purity certificate and common inliner. It optimizes the
sole public entry, restores original definition order, prunes unreachable
definitions, then optimizes only the surviving non-entry functions once in that
order with the remaining fuel. Both stages expand **original callee bodies**.
A final prune and verifier gate complete the candidate. The original
`nx_inline_entry` implementation and behavior are unchanged.

The contract is a closed program with one external entry. `NxFunc` references,
including stored and returned function addresses, remain reachable roots through
the existing reachability pass. Budget zero and invalid input preserve the
complete original program. Original programs above 256 functions or 65,536
counted nodes refuse unchanged; the global growth budget remains capped at 4,096
and expansion depth at 128. Pruning may itself decline at its capacity bound.

Do not prune after each surviving helper: a later expansion uses an original
callee body, which may name a helper an earlier expansion stopped using.
Pruning only before and after the remaining-function stage keeps those original
dependencies available. This simple policy can still optimize a helper that
becomes dead during that final stage; it intentionally avoids a more complicated
dependency scheduler.

The [control metadata](../../selfhost/tools/performance/phase107/inline/demand-controls.json)
reuses nine existing fixtures: direct dependencies, stored/returned function
addresses, dead/live cycles, both branch arms, the 257-function refusal, deep
`many`, and per-invocation local reset. Keep their independent expected outputs.
Test budgets 0/1/32/4096, ordered retained names, no dangling calls/addresses,
verifier and growth bounds, exact invalid-input refusal, and complete outputs.
Never execute the recursive cycle or invalid `tail_dead` fixture. For `many` at
4096, compare the entire result with `nx_reachable(nx_inline_entry(p,4096))`;
the useful entry body should be identical.

Root execution should append this optional source to the existing bridge, check
the new export, run those controls, then compare pass time and complete
optimization/emission/object time on the already frozen corpus. Measure the
old and new policies on the same actual bridge where possible. Retain failures
and separate compiler time from emitted-code runtime. Accept only if the skipped
work produces a useful measured reduction without correctness regressions;
otherwise keep the existing policy. No speed factor or promotion is assumed.

## Closed result and successor

[Demand audit01](../../selfhost/build/phase107/demand-audit01/report.json)
passes 88 transformation pairs, 272 distinct model executions and three detected
typed semantic mutants. [Artifacts06](../../selfhost/build/phase107/artifacts06/report.json)
and [measure07](../../selfhost/build/phase107/measure07/report.json) retain the
policy in a broader optimization composition. Those results do not isolate its
incremental runtime or optimizer-cost contribution.

Skipping dead work did not remove the repeated-verification cost of composing
public passes. The [boundary-pipeline experiment](../../implementation/phase107/boundary-verification.md)
then obtained exact products on 69 controls with substantially cheaper warmed JS
optimization; its denominator and remaining proof/control gaps are explicit.
See [demand-inlining.md](../../implementation/phase107/demand-inlining.md) and the
[phase report](../../implementation/phase107/README.md). Production defaults did
not change, and an exact finite comparison does not prove the entire pipeline.
