# Independent verifier fixtures

[`verifier-cases.json`](verifier-cases.json) contains 60 source-reviewed cases:
32 raw and 28 direct, with 17 expected acceptances and 43 exact expected errors.
It is prepared data, not an executed qualification. The frozen fixture retains
`originalValidated: false`; a separate run receipt records the original oracle
results without rewriting these inputs.

Every case has a target `function`, metadata `segments` and `constructors`,
preceding direct functions in `ready`, and a fixed `expectedError`. Data uses the
checked API's tagged objects; lists are `Con`/`Nil`, and Booleans are JSON Booleans.
`P113DScalar` has field `stmt`. `NC_Binding` has `id`, `word`, and `kind`.

For raw cases, construct `N111Ids` with the original successful
`p111v_functions` and `p111v_constructors` scans, then compare
`p111v_segment(function, ids)` with `p147v_segment(function, ids)` and the fixed
error. For direct cases use `p113e_originals(segments, missing())` and
`ns_ctor_index(constructors, missing())`; build `ready` with
`p113e_signatures(ready, missing())`. Compare `p113e_function` and
`p147v_function` with the same three arguments and fixed error. These are
per-function diagnostics, without the raw program verifier's function-name prefix.

Cases cover exact names (including a known hash collision and distinct `v_1` /
`v_01` widths), schema-before-flow error priority, reserved locals and parameters,
definite assignment, asymmetric terminal branches, capacity joins, pointer-copy
capacity reset, memory alignment/overflow, direct call readiness and arity,
return/tail vectors, public ABI checks, and the current `Nat.divmod` import.
No invalid IR is emitted or executed. No compiler algorithm is implemented in
the fixture data or host construction.

The fixed strings were reviewed against the pinned maintained declarations
listed in `sourceReview`. The historical Phase144 raw controls supplied data
patterns only; no retired implementation is imported. Before using timings,
the original verifier must match every independent expectation, and the candidate
must match both. Full schema/live-state observations and actual compiler/Lexer/Map
inputs are separate harness gates. This finite corpus does not cover the 65,535
local-count boundary or constitute a proof of verifier equivalence.

Offline preparation checked all 1,576 tagged objects against current constructor
field declarations. No Bend, JavaScript, C, native or Lean target ran during
fixture preparation.
