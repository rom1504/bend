# Supplemental compact-verifier review controls

`verifier-cases-extra.json` adds 16 independent, source-reviewed cases to the
original frozen 60: seven raw and nine direct cases, with ten expected
acceptances and six exact errors. Use the existing
`experiments/phase147/tools/controls.mjs` with this file as `--cases` and a fresh
output directory. No target ran during preparation; a separate execution receipt
must establish whether the original and candidate match these expectations.

The added cases cover:

- Collision-bucket overwrite with distinct widths, and colliding names assigned
  on opposite branches. A hash match must never merge their identities.
- Nested terminal/nonterminal joins, nested all-terminal continuation rejection,
  and multiple nested definite-assignment intersections.
- Equal-capacity joins and the original zero-capacity/zero-offset behavior.
- Direct typed-concat, TRMC extend/finish, and array-pair imports, including
  constructor reversal, undersized buffers, and forged buffer-name provenance.
- A later reserved parameter overriding an earlier invalid-name diagnostic,
  preserving the original seed's order rather than assuming sticky errors.

Offline preparation checked all 801 tagged objects against current constructor
field declarations. The fixture records the unchanged original fixture's hash
and the source files used to derive expected errors. This is data, not an
alternative verifier implementation.

The fixtures exercise shared branch inputs but do not independently establish
native retained-root ownership, all Patricia prefix configurations, or the
65,535-local boundary. Those require separate map/state controls. Full-state
projections must compare semantic rows rather than tree shape, and internal
helper comparisons require the candidate's canonical schema/live invariant.
