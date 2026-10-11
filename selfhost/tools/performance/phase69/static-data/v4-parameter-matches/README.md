# Static graph parameter-match repair

Build04 parsed the newly included module and rejected `match ks(t)`. Replace
the computed scrutinees in `ns_packed` and `ns_static_scalar` with helper
parameters. No optimizer behavior changes.

Every other match in static.bend scrutinizes a declared parameter. The nested
`match book` in `ns_attach` also scrutinizes an original parameter; it is legal
and needs no rewrite. Frozen v2 and build04 inputs remain unchanged.

Prepared source only; no compiler/native target executed by this lane.
