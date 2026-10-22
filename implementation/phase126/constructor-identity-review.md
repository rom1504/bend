# Independent constructor-identity review

Source-only review of `constructor-identity/manifest02.json`, `plan02.bend`,
`lower.bend`, `controls.bend` and the ordinary owner fixture. No compiler,
generated program or benchmark was executed. No production source was changed.

No concrete semantic blocker was found within the authenticated checked-source
boundary. This is not an admission theorem for arbitrary reflected `KTerm`
records, and it does not establish that a real workload activates the rule.

- All three module bytes match manifest02. The two copied fallback declarations
  are byte-identical to Phase125 `verified-source06/compiler.bend` after only
  renaming the declaration. The original hook declarations and normal variable
  lowering also remain identical in Phase126 `clean-source11/compiler.bend`.
- `plan02.bend:69` admits exactly one variable scrutinee and no remaining match
  arguments. The bounded hit scan checks distinct live binder IDs, exact field
  order and the same constructor identity; matching textual variable names is
  insufficient. Calls, observations, aliases, permutations, duplicated or
  missing fields cannot pass this syntactic rule.
- `plan02.bend:59` checks original constructor identity, live arity and the
  enclosing nonbuiltin, zero-parameter ADT. Its declared telescope rejects
  dependent fields and indexed results. Primitive, Word, array and IO matching
  remain outside this path. The cheap hit-shape check now precedes telescope
  work for ordinary nonidentity branches.
- `lower.bend:28` and `:42` retain `p111_test` and its conditional. The hit lowers
  the original scrutinee in the original environment, through `p111_lower` or
  `p113pl_lower`. Their unchanged partition steps emit sinks for unrelated
  owners before returning/transferring the selected owner. Surrounding keeps
  are not removed. Shared and static owners therefore retain their existing
  ownership representation rather than being treated as unique mutable cells.
- The original miss expression is unchanged: dropping `nd_reapply(..., [])`
  is justified by the exact two-child `NMatch` admission. It receives the hit's
  returned fresh counter. The numeric counter can be smaller because field
  bindings no longer exist; no deleted field local remains referenced.
  The omitted generic IO guard is the identity function for every admitted
  constructor, because `Emit` and `Halt` are explicitly excluded.
- `lower.bend:51` sends every known flat `NQShape` target to the exact old product
  lowering. Opaque targets retain normal boxed/local/return/destination handling
  through `p113pl_boxed` and `p113pl_output`; there is no new public or private ABI.

The 19 finite controls cover the main shape refusals and inspect a normal
unused-owner sink. The ordinary fixture covers retained whole-root and payload
aliases, static/dynamic values, a reversed-field near miss, repeated identity
calls and a discarded unrelated String. These are useful scoped controls,
not a complete proof: the finite cleanup assertion is on the generic hit, and
the current finite list does not explicitly exercise private-product refusal.
Keep the root's actual admission, unchanged fallback, full-output and emitted
work-removal gates separate from this review. No timing conclusion follows.

Reviewed module hashes:

| Module | SHA256 |
| --- | --- |
| plan02.bend | b2bf53bd402adf4395d7865bc1677b72dbd288e8f6b8d9aade6f20cc7d023f51 |
| lower.bend | c8a10161edab307530366d78a745cbaac5e047a7f02295ce2775778794235609 |
| controls.bend | 4397ba143113354247ea4d9b7576bc5b6bf7e57d2ca6c1109b0939862c0ba6d5 |
