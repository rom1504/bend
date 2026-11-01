# P150-001 — fused lexical production across the parser boundary

Status: validated component candidate; production promotion deferred.

Hypothesis: repeated character extraction/lookahead construction and quote
rescanning create avoidable native work. A single consuming/pattern-matching
producer can retain exact FToken metadata without changing the parser's public
representation. This may reduce complete parse cost, but lexer share is unmeasured.

Falsifiers: lexing is not an important share; ownership/helper admission makes
the new producer slower; reduced lexical time disappears in complete parsing;
token/error/position semantics differ; code complexity exceeds the useful gain.

Compare current native baseline and candidate under the same producer/runtime.
Charge input, metadata, reversed words/tokens, parse consumer and reclamation.
Keep NUL versus EOF, cursor-disabled mode, Unicode width, comments, exponents,
operator adjacency, raw quotes/escapes, depth and first-error behavior explicit.

See [design](../../design/phase150/README.md). No production promotion or large
speed estimate is established by the design.

Outcome: selected scalar-comparison producer lexes4.43× faster and reduces
complete native parsing9.62% on the frozen compiler input. Exact controls and
full token/finite graph comparisons pass. Initial literal-pattern source made
acquisition43.87% slower; [P150-003](P150-003-literal-pattern-expansion.md) removes
that penalty. No full compiler build or user-program runtime claim. See the
[report](../../implementation/phase150/README.md) for scopes and negative evidence.
