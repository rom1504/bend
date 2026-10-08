# P68-002: share typed saturation facts with native calls

Status: registered before production changes, 2026-10-08.

Hypothesis: raising fully applied native entries through matcher prefixes,
using the existing typed JS arity analysis, removes per-iteration curry closures
and apply dispatch across ordinary recursive programs. Array has four transport
closures per steady element in source inspection; Map/lexer also miss full
entries. Initial source estimate: array 2–8×, broader families possibly1.2–3×;
these are overlapping unmeasured hypotheses, not expected results.

Prototype under `selfhost/tools/performance/phase68/architecture/arity-v1.patch`.
Retain ordinary partial entries and native/foreign/bang behavior. Constructor
fields precede residual arguments, fallback consumes its scrutinee first, and
fresh aliases preserve repeated-scrutinee ownership. Keep optimized Nat matching
on its existing safe domain. Investigate early matcher-error versus late argument
error against upstream; changed inherited behavior is not silently accepted.

Fast falsifiers: checked B1, array/Map/lexer oracles, current raw-core controls,
partial/over-application and alias/error discriminators. Count closure operations
before/after, then compare common-work native timing. A faster incorrect output
fails. Broad correctness/B2/JS qualification only for a selected candidate.

Results and selection: pending. Production untouched at registration.

First screen: checkedB1 `4fe50555…`, six-family exact outputs;0.363465× prior
runtime on recalibrated shared plan, but1.612257×C bytes and1.512764×Clang time.
Five valid fast semantic controls pass; invalid newfixture preserved forsuccessor.
Saturated error-order witness agrees; partial witness confirms remaining
upstream discrepancy. Not promoted. Follow-up P68-003 shares the full body and
aligns named partial-call delay. Exact evidence in Phase68 report.
