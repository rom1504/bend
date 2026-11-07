# Direct terminal destination: independent source audit

Scope: source review only; no compiler, target, or benchmark execution. This
reviews `selfhost/tests/phase173/store-direct.bend` and the measured frozen
`selfhost/build/phase173/store-direct-modules01/` against `nc_compact`,
`nc_refs`, and the indexed implementation they replace in the vertical API.
It does not qualify a production compiler or establish a speed result.

The frozen direct module has SHA-256
`573128bb220fcfdc9a62eb3720613a8529af090aa61eb0c48ce0f1a135539b55`.
The working module differs only in the explicit type annotation on
`p173o_candidate`; the frozen module fills its prelude declaration.

## Result

No incorrect value transformation or reference-order change was found in the
admitted path. Two limitations prevent treating this as an exact replacement
of the bounded indexed API without further qualification:

1. The fused 20-million-step budget is a new admission policy. It is not
   equivalent to separate 10-million-step compaction, reference, and export
   budgets. A failure returns an explicit error; it must not be accepted as a
   valid partially transformed body.
2. The direct path has the 16 vertical finite controls and 101 real-body
   comparisons in `store-direct-verifier01`, rather than a new run of all
   indexed-store edge controls. The latter's existing `p173st_observe` still
   calls `p173s_compact`. Do not attribute those tests to the new traversal.

Neither is evidence of a wrong result on the measured workload. The second is
a coverage requirement before generalizing the experimental route.

## Invariants checked

- **Opaque static values:** a `NStatic` visit switches descendants to raw mode.
  Raw mode preserves every original shape field, literal payload, child order,
  lambda quantity-presence bit, removed-name list, and source range. It still
  records `Ref` nodes, matching the separate `nc_refs` traversal of an opaque
  compacted value. It does not compact a string or number below `NStatic`.
- **Numeric values:** constructor decoding delegates to the unchanged
  `p173c_decode` and `p173c_succ_scan`. Their U32/F32 bit decoding, malformed
  constructor behavior, Nat overflow refusal, and dynamic successor tail rules
  therefore retain the indexed implementation's behavior. Successful decoding
  does not traverse references in discarded malformed children, matching
  `nc_compact` before `nc_refs`.
- **Strings:** explicit `SNil`/`SCon`/`Chr` construction matches expansion by
  `core_literal_step` followed by compaction. Character payloads use
  `Char.to_u32`; constructor quantity is one, word quantity is zero, and source
  ranges are cleared outside static values.
- **Ordered dependencies:** references are accumulated at node entry before
  left-to-right descent and reversed once at completion. Duplicate occurrences
  remain. Numeric/string replacement introduces no references. Successor
  collapse visits its retained tail once.
- **Frame discipline:** each visit produces one value. Child, successor, and
  string-join continuations consume one value before producing their completed
  value. From the public singleton-root entry, normal completion therefore has
  one value. `p173o_done` ignores a residual value tail, as the old compactor
  does, so callers must not treat arbitrary fabricated frame states as a public
  validated interface.
- **Failure propagation:** invalid store accesses and exhausted decoders set
  the sticky store error. Empty value stacks and exhausted frame budgets call
  `p173o_refused`. `p173s_valid` includes the sticky error in its header checks;
  `p173o_validated` consequently returns a nonempty error. Computing the unused
  `fuel - 1` expression at zero does not resume execution after refusal.
- **Final verification boundary:** store validation now checks the immutable
  imported store, not newly materialized output nodes. This is a structural
  validity check, not a proof that the resulting `KTerm` is semantically
  equivalent. Independent complete-value comparisons and the production final
  verifier retain their distinct roles.

The cheapest additional direct-path controls are the existing finite fixtures
for static strings, overflowing Nat, malformed numeric children, 32-bit
constructor words, and duplicate references; pass those fixtures through
`p173o_body`, rather than through the legacy indexed observation helper. Tiny
explicit-fuel calls can test refusal without creating million-node inputs.

## Product-argument bridge follow-up

A bounded follow-up inspection of `product-arguments.bend` found no additional
concrete blocker beyond the separate ownership review. The current bridge
requires an actual unique semantic binding and unique emitted local name for
each consumed boxed argument, excludes special representations, checks the
runtime constructor before `p111_take`, and reserves fresh field locals.
Fields are loaded out of the shared scratch area before the next product is
taken. The success path removes the consumed shell from the environment and
uses the established flat call/result machinery; unsupported cases retain the
original path. This observation is not a claim that the bridge is admitted or
profitable on the full compiler.
