# Independent pure Boolean-width controls

Root runs `controls.mjs CHECKED_API FRESH_PHASE113_OUT` using the existing
checked API acquisition. Required exports are `p113bq_scalar`,
`p113bq_direct`, `p113bq_ready`, `p113bq_emit` and `p113d_verify`.
The author runs no compiler API or native target.

The 112 checks cover scalar/direct recognition of exact single-assignment
U64 1/0 and 0/1 branches; refusal of different destinations, widths,
nonconstant/non-Boolean values, extra statements, calls, terminal transfers and
nested branches; counter, diagnostic and terminal-state guards; and exact
normalized word comparison followed by explicit unsigned extension. Existing
emission chunks and the fresh-name counter must be retained correctly.

Independent finite observations cover both branch polarities with conditions
0, 1, 2, 3, 2147483647, 2147483648 and 4294967295. Each corresponding original
IR program is structurally verified and interpreted independently; the two
emitted operations are checked against direct zero/nonzero arithmetic.
Destination names resembling generated temporaries exercise namespace separation.

These are ordinary structural and functional compiler controls. They do not
execute custom native failure programs or establish backend correctness.
Existing Bend source fixtures and complete-output benchmark gates provide the
separate end-to-end checks.
