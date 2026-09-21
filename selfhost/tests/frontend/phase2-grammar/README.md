# Bounded grammar regression matrix

This separate 25-case matrix covers explicit types on marked parameters and
semicolon rejection at list element boundaries. It retains ordinary bare
quantity parameters, law fills, typed templates, typed arrays, nested lists and
valid statement/IO semicolons as positive controls. It does not change the earlier
21-case frontend oracle.

Run from `selfhost/` with a fresh checked bootstrap API and its matching report:

```sh
node --stack-size=4096 --max-old-space-size=4096 \
  tests/frontend/phase2-grammar.mjs build/checked/api.mjs build/grammar-attempt 0
```

The last argument optionally selects a CPU. The wrapper writes a fresh config
and invokes the ordinary paired conformance harness. Every case has an explicit
acceptance/rejection-phase oracle; this matrix does not assert exact diagnostic
text. The harness retains requests, responses, replay commands and artifact
identity. Successful selection remains separate from full conformance.

The list guard runs before the existing semicolon-skipping helper, at the opening
bracket and between list elements. Lexer nesting removes interior newline tokens.
It covers leading, middle, trailing, post-comma, multiline and nested-list cases.
It deliberately leaves general body/expression whitespace handling unchanged;
other delimiter contexts require their own compatibility audit. Argument-list
errors must propagate through `f_list` instead of becoming an empty list.

Only an unmarked plain parameter may omit its type and default to `Quant`.
Parameters marked `~`, `+` or `-` require `:` and a type, matching upstream's
telescope parser. Plain parameter names filling existing laws remain valid.
