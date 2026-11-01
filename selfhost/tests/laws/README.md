# Independent law controls

`production/reference.py`, serializer, catalog and mutation recipes retain the
original independent 226-case oracle. They do not import compiler code.
`production/supplements.json` adds the two separately frozen Phase97 gap witnesses
only when explicitly requested. Expected values are never inferred from the
candidate's output.

`production/serialize-current.bend` is an explicit observer successor, not a
replacement of the frozen original. Its sole added branch maps the current
`N_Imm64` constructor to distinct wire tag `3`; old encodings and expected values
remain unchanged. `serializer-current.json` authenticates that exact extension.
The original serializer's nonexhaustiveness was retained as an admission failure,
not counted as a semantic test failure or mutation detection.

`challenges/phase97` and `challenges/phase98` preserve independently selected bad
and good recipes, complete-value witnesses and historical defect provenance.
Paths embedded in those records refer to original evidence, not maintained
implementation dependencies. A frozen bad recipe may fail admission or no longer
match current code; neither outcome is a semantic detection. Good transformations
can need proof maintenance. Broader later witnesses are coverage expansion, not
retroactive improvements to the original frozen-suite score.

See [current commands and scope](../../tools/laws/README.md). Original campaigns
can be recovered via the history archive; they are not a fresh-current-source CI
suite. Formal proof, model proof, finite execution and native lifetime validation
remain distinct claims.
