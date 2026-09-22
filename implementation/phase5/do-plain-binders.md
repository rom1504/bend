# Plain binders in pure do assignments

P5-009 distinguishes a do assignment's one-name binder from an ordinary local
pattern. The pinned parser intentionally uses `parse_bind` in do notation and
`parse_patt` for ordinary local bindings. `False : U32 = 4` is therefore a legal
do assignment; treating it as a constructor pattern rejected a valid program.

The two-line source change marks generated pure-do `Local` nodes with `Do` in
the unused name field. Their single pattern is validated without constructor
lookup. Name and pattern-kind validation still apply; the existing scoping
path still checks the value with the outer environment/book and the continuation
with its new binder. Scoping clears the marker before the unchanged Let lowering.
The effectful `<-` path and ordinary constructor patterns retain their behavior.
There is no change to the core representation or lambda/application semantics.

A live five-case baseline proved two valid-program rejection differences and
three agreeing controls. The checked candidate passes 49 check observations
(45 combined old/new cases and four additional scope/first-error controls),
with 20 exact diagnostic differences across those two selections. Seven positive
programs pass 14 interpreter/JavaScript probes with exact expected outputs.
They cover marked repeated use, repeated shadowing, outer variables, and mixed
pure/effectful binding. Own-value and own-type references remain correctly
unbound; ordinary constructor patterns still reject before a bad value.

The first five-case manifest was labeled proposed before its live oracle check;
all five reference oracles passed. One speculative constructor/match fixture was
written but never selected or counted. The separate paired reports retain
observed outcomes. `direct_calls` independently reviewed the source change.
The singleton plain-pattern shape is established by the existing parser/scoping
construction, and non-variable patterns remain rejected by shared validation.

Reproduce through the [maintained workflow](../../docs/PHASE5_DEVELOPMENT.md)
using `selfhost/tests/frontend/phase5-do-next/expanded-cases.json`, followed by
`scope-controls.json` and `execution-cases.json`. The
[evidence manifest](do-plain-binders-evidence/manifest.json) preserves the genuine
checked candidate, baseline and validation reports, source overlay and fixtures.
These selected gates do not replace the combined frontend/backend and final
self-reproduction gates in the [campaign report](report.md).
