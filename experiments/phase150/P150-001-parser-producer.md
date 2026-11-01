# P150-001 — fused lexical production across the parser boundary

Status: planned.

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
