# Complete local-schema and numeric-flow prototype

The initial experiment was additive. After checked controls and native transfer
measurements, the maintained source selects this implementation only for three
direct-admission calls; full-request qualification remains pending. The original
raw and final verifiers remain in the execution path. The implementation is
`selfhost/src/back/qbe/verify-compact.bend`; the installed compiler is unchanged.

## Boundary and proposed work elimination

The test adapters `p147v_segment(segment, ids)` and
`p147v_function(function, ids, ready)` take the
same original named IR and global metadata as their reference entries, and return
the same ordered diagnostic string. They build their entire local environment on
each invocation. The ordered direct-list entry is `p147d_functions`.

An immutable, exact-name schema assigns dense IDs in first-declaration order.
Each schema row stores name, ID, numeric kind, width and declared capacity.
Absence is a distinct constructor. The schema uses a private collision-checked
Patricia table; a hash match never establishes name equality. No spelling is
interpreted as an ID, and source parameter IDs are not trusted as local IDs.

Flow stores only assigned numeric IDs and current capacities in a second private
Patricia tree. Assignment resets capacity from the final schema; pointer offset
alone computes a transferred capacity. Branch intersection operates structurally
on numeric trees, preserving only common IDs and setting unequal capacities to
zero. It does not hash names or reconstruct generic nine-field `KDef` rows.

No statement tree is copied or preconverted. Names are still resolved through
the schema on uses; those lookups are included in the measured entry. The extra
schema/live carrier may add allocations and call transport. Both are explicit
reasons this experiment might lose despite cheaper joins. Do not report a
preconverted lookup microbenchmark as its result.

## Exact semantic obligations

- Schema construction runs before flow, visiting yes before no and preserving
  first-error behavior. Raw schema count checks occur before the next statement;
  direct flow additionally checks its final count. The prototype retains this
  existing difference, including the raw final-statement boundary.
- Repeated same-width declarations retain their ID. Width changes, alloca
  redeclarations, invalid names and reserved `state` are rejected by the original
  ordered conditions. Direct seeds include `state`, `scratch` and exact parameter
  spellings; duplicates keep the original diagnostic behavior.
- Successful schemas establish immutable width and kind. Live assignment and
  offset operations may change capacity only. Unequal branch capacities become
  zero, not their minimum. A terminal arm contributes no continuing path; two
  terminal arms retain the yes state. Yes errors precede no errors.
- Function/constructor metadata and ordered ready-prefix maps remain original
  `KDef` values. Runtime signatures, raw names, scalar safety, pointer restrictions
  and direct public ABI predicates are reused unchanged.
- Direct Nat.divmod, typed concat, TRMC extend/finish and array-pair contracts
  operate directly on the compact environment. They do not reconstruct generic
  state for imported calls.

The equivalence claim is **only at the complete entry boundaries**. Internal
helpers accept privately constructed environments. On a fabricated environment
with a missing schema declaration, compact assignment/offset leaves state
unchanged whereas an arbitrary invocation of the old helper could insert a
record. These helpers must not become public arbitrary-input verifiers or be
used as optimizer assertions. No theorem or ownership proof is claimed here.

## Evidence required before integration

1. Independently source-check both additive modules. The test-only module
   `selfhost/tests/consolidation/verify-compact-observe.bend` projects schemas and
   live facts back into original records. Compare complete semantic rows,
   terminal status, count and diagnostics, not incidental tree shapes.
2. Exercise expected-error controls, hash collisions, schema failure precedence,
   capacity reset/offset/join, duplicate parameters, unknown and forward direct
   calls, every extended import and the count boundary. Never execute invalid IR.
3. Compare real raw and direct functions from unrelated Lexer, Map and compiler
   inputs. Native timing includes schema construction, flow, joins, errors and
   teardown. Retain input and acquisition identities and every failed attempt.
4. Inspect generated worker admission. Phase144's single-record absence lost
   useful workers; an explicit absent constructor fixed that earlier experiment.
   Merely writing a smaller Bend datatype does not establish faster machine code.
5. Promote only after complete-region native gains transfer. A successful
   integration should replace local representation in place and share semantic
   decisions; retaining a second full verifier algorithm is not the intended
   production architecture. A failure may instead justify preserving IDs in the
   lowering producer, but does not by itself justify a universal IR rewrite.

At creation, the candidate had 585 lines and 68 definitions. Its scalar-observer
successor passes checked acquisition, 60 expected-error/full-state controls,
16 additional state controls and 36 captured actual functions. Complete native
slice ratios are approximately 0.775 Lexer, 0.881 Map and 0.813 compiler against
the original verifier in the same executable. These do not establish a whole
compiler speedup; see the fast-loop and machine-inspection reports.

## Selected direct-admission integration

Only `p114s_open_functions`, `p114s_commit` and the changed-function miss in
`p134v_check` call the optimized direct verifier. The latter operational function
currently belongs to the maintained `tests/compiler/native-controls.bend`
module; this change does not move or duplicate it.

Raw verification remains original. This matters because Phase146 retains raw
acceptance through the request rather than repeating raw checking at the end.
`p146c_functions` and `p118b_verify_projected` continue to call the original
direct checker, so actual final transformed bodies are independently rechecked.
Protected session checking also remains unchanged.

The production module contains 609 lines, 71 functions and six types. Three
experiment entry adapters moved to the test observer module; four unused
generic observation helpers were removed. All 112 protected declaration hashes
pass metadata assembly. The existing verifier and optimized admission algorithm
are intentionally distinct at this boundary; do not describe this as eliminating
all duplicated checking logic. Complete request cost and qualification decide
whether the added representation and code earn their place.

Exact before/after identities and the reviewable integration patch are under
`selfhost/build/phase147/verifier-integration01/`. The combined renderer/verifier
source is `selfhost/build/phase147/integrated-source01/compiler.bend`, SHA256
`15e240909a0d27e268c69822d657e34a3ed1da0fedc58b42a9befe6e5108ec80`.
