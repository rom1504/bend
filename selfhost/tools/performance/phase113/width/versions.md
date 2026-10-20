# Width candidate fixture corrections

Production `emit.bend` and its one-declaration override remain unchanged across
these versions.

- Source25: checked API rejected the test fixture's repeated affine `which`
  argument. `cases-v2.bend` adds `+` to that one parameter. Original retained.
- Source26: checked API passed;19 of22 structural controls passed. The three
  exact-text snippet controls called `p111q_body_text` without a terminal
  result, so that helper correctly returned `INVALID_N111_FALLTHROUGH` instead
  of rendering the snippets. This was a fixture error, not a text-spacing or
  name-encoding difference.
- `controls-v2.bend` appends an explicit `Result(0)` to the snippet and includes
  `ret 0` in all three exact expectations. It preserves the original terminal
  validation rather than bypassing it.

`modules-v3.json` pins the current optional source composition:
`emit.bend`, `controls-v2.bend`, `cases-v2.bend`, with `overrides.bend` replacing
only `p113e_stmts`. Independent128 raw64 values are unchanged;
`width-controls-prepared03` pins these corrected fixture definitions. Native
qualification remains root-owned; failures and old prepared sets are preserved.
