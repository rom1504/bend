# Frontend semantic witnesses

These small programs isolate four frontend restrictions from unrelated later
errors: law fills cannot restate their return type, law template clauses must
lead, local bindings require valid patterns, and imports precede declarations.
The manifest records acceptance and rejection phase, not exact diagnostics.
Positive controls include ordinary and template law fills, typed definitions,
simple and nested constructor patterns, repeated leading imports and `@unsafe`.

From `selfhost/`, build a fresh checked API and run the live differential test:

```sh
BEND_TYPED_API="$PWD/build/frontend/api.mjs" \
BEND_UPSTREAM="$PWD/.bootstrap/upstream" \
node tools/typed-driver.mjs --bootstrap

BEND_TYPED_API="$PWD/build/frontend/api.mjs" \
BEND_UPSTREAM="$PWD/.bootstrap/upstream" \
BEND_BASE="$PWD/.bootstrap/upstream/bend2/base.bend" \
node --stack-size=4096 --max-old-space-size=4096 \
  tests/frontend/phase2-rules.mjs build/frontend/new-results.json
```

The API's matching `.bootstrap.json` must exist and identify the pinned revision.
The runner refuses an existing output report, retains both compilers' verdicts,
records hashes, and checks every expected rejection occurs during parsing or
frontend elaboration. Its direct upstream check includes ownership and unresolved
law/hole gates. This is a focused check-only semantic test; it does not establish
exact diagnostic compatibility, execution compatibility, or full conformance.

The changed-return-type witness is deliberately retained: the old compiler
already rejected it through a later signature-consistency check. That hypothesis
did not demonstrate a soundness hole. The same-type arrow and other accepting
witnesses establish the missing syntax restrictions independently.

The foreign-import boundary witness already rejected before these repairs, and
continues to reject; it guards the existing foreign-declaration import grammar.
