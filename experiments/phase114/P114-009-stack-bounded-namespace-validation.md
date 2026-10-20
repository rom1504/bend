# P114-009: stack-bounded namespace validation

The ordinary full compiler acquisition for selected source01 passes its frontend
in221.705s and lowering in201.763s, then the final verification stage throws
`RangeError: Maximum call stack size exceeded` after45.977s. The guard stops
normally after472.137s, peak3.121GiB; no native image is qualified by that run.
Receipt: `selfhost/build/phase111/p114-native-final01-full-emit/report.json`.

Source inspection finds that the new transport namespace gate walks35,734
segments with `Bool.and(check(head), walk(rest))`. The checked hosted API emits
an ordinary recursive JavaScript call nested inside `Bool.and`, so flat list
length consumes the host call stack. The original verifier remains before this
gate. The retained scaling/index-only catalogue image, which lacked the new
namespace traversal, completed its full verification. This identifies a concrete
stack-scaling defect; the saved exception does not include a host stack trace,
so the failed frame itself has not been directly sampled.

Keep every namespace predicate and the complete original verifier. Replace the
six flat list traversals with direct self-tail accumulator helpers. For each,
the invariant is `go(xs, acc) = acc && old(xs)`. Pure name predicates and branch
checks are unchanged; no invalid graph becomes admitted. Nested branch depth
remains recursive, while flat list length no longer requires nested host calls.
The source overlay and independent review are separate from frozen module01.

Qualification: inspect actual checked JavaScript for six loop-shaped helpers;
use ordinary positive source programs and exact old/new QBE comparison; retry
the full compiler through the unchanged verifier and native-generation gates.
Do not raise the host stack limit or bypass validation. No malformed graph,
custom failure reproduction, or changed benchmark definition is needed.

This is a compiler-verifier scalability change. It does not alter target program
rendering; the original runtime campaign remains bound to source01. Any new
native source selection and exact-product comparisons are recorded separately.
