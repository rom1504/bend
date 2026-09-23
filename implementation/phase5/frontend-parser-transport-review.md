# Independent parser transport review

Read-only review of P5-011 attempt03; no tests were rerun by this reviewer.
The reviewed overlay is `selfhost/build/phase5/parser-errors/attempt-03/overlay.patch`,
SHA-256 `365f868a274c1df9f9bffd4fa2baa592509f1df821e2432d3b4432cf8cb16eff`.

Scoped approval: `f_expect` preserves its original existing-Error branch, token
consumption and successful branch. The structured error constructor is reached
only for an already-failing expectation of one of three closing delimiters.
Declaration and import control flow retain the same branch order while carrying
an Error term instead of immediately extracting its name. Public `FResult`
retains its original fields and types; successful completion maps Absent to the
same empty error string without scanning the source.

The renderer scans source only on selected rejection paths. Legacy text remains
the fallback for unsupported metadata/positions. Duplicate-constructor rendering
uses the next token only for an adjacent name/brace; whitespace-separated cases
retain legacy formatting rather than fabricate the upstream position. The actual
source-character/token check and non-BMP/surrogate fallback are conservative.
This is partial formatting coverage, not a general Unicode location repair.
The host avoids adding a second Error prefix for already rendered errors.

No semantic blocker was found in this patch. The owner reports separate fresh
controls, accepted-book equality and a broader rejection gate; their actual
reports determine validation scope, not this static review. The independent
namespace-error issue belongs to P5-016: transport must not silently absorb that
semantic fix. Its planned `f_group_namespace` edit is disjoint from P5-011’s
`f_law_where` return-type change in the same module.
