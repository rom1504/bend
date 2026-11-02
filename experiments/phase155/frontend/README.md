# Phase155 frontend ideas 17–18

Source-only bounded preparation. No compiler, generated program or benchmark
was executed by this agent. The root owns independent Bend checking, native
screening, results and retention. Production files are unchanged.

The [specification](spec.json) registers one static rejection and one executable
candidate. [The Bend module](../../../selfhost/tests/phase155/frontend.bend)
has no `main`; append it to the maintained declaration selection and let the
tournament supply its common entry. Required maintained roots are `FToken`,
`f_lex_cursor` and `f_valid_name`, including their normal transitive dependencies.

## 17 — Reject a one-way fused token cursor as a local replacement

The current lexer still materializes and reverses `List<FToken>` and the parser
reconstructs `FInput` when advancing it. That does not make a single consuming
character cursor interchangeable with the existing interface:

* `front/lexer.bend:f_tl` constructs `FInput{rest,context}` from an immutable
  token list. `f_space`, `f_skip` and many grammar paths query the same position
  repeatedly. A cursor which rescans on every query may preserve values but
  does not establish work removal.
* `front/contextual.bend:f_context_rewind(old,input)` explicitly takes tokens
  from `old` and context from `input`. Advancing a one-way shared cursor cannot
  implement this operation by retaining only its newest position.
* `front/parser.bend:f_grow_existing` looks across newline tokens for an operator
  extending the preceding expression. For example, the valid source-shaped
  body `x\n  + 1` is not two independent parse units. A proposed fusion which
  discards the previous unit at each newline changes this branch.
* `front/parser.bend:f_args_existing` consumes a `>>` token and synthesizes a
  remaining `>` with updated span/column through `f_prepend`. This is pushback,
  not only forward consumption.
* `front/compact-parser.bend:p140p_token_same`, `p140p_prior` and
  `p140p_checkpoint` require all seven original token fields, original-stream
  membership and the previous lexical token. Synthetic parser tokens are
  deliberately not sufficient checkpoint evidence.

These are direct source behaviors, not benchmark results. ID17 is
`rejected-static`, has null timing entries and must not be scored as a measured
regression. A persistent memoized cursor or bounded token buffer could support
a future redesigned interface; the audit does not prove all fusion impossible.
Building that parser is outside this small tournament candidate.

The [Phase150 audit](../../../research/phase150/parser-audit.md) already records
these boundaries. The [Phase150 findings](../../../research/phase150/lexer-findings.md)
also show why another direct punctuation/quote scanner would repeat completed
work: the preferred scalar lexer is now integrated by Phase152. ID17 does not
present that earlier optimization as a new implementation.

## 18 — One scalar scan for identifier syntax and reserved words

The two entries are:

```bend
def p155x_name_old(n: U32) -> String
def p155x_name_new(n: U32) -> String
def p155x_controls(unused: U32) -> String
```

The old entry uses the actual maintained `f_valid_name`, whose complete result
combines a first-character check, recursive `f_name_chars` and the 16 ordered
String equalities in `f_reserved`. The candidate does not copy or modify those
functions. It directly matches each String character once, carrying the next
segment's start requirement, a length capped at seven, and two U32 lanes.
The first six ASCII bytes form an exact little-endian key. The length and both
lanes distinguish every reserved word exactly, including case; no hash or
intern-table identity is trusted.

The reserved spellings remain exactly `def`, `type`, `law`, `match`, `case`,
`do`, `return`, `for`, `exs`, `where`, `is`, `import`, `Type`, `Data`, `Kind`,
`Quant`. None exceeds six bytes. Once the capped length reaches seven, the
word cannot be reserved; the scan still validates every later character and
segment boundary. The cap prevents U32 wraparound from reclassifying a very
long name as a short keyword.

At the beginning or just after a dot, the next character must be an ASCII
letter or underscore. Other positions also admit digits and dot. Finishing
while a segment start is pending rejects empty strings and trailing dots.
These rules reproduce the current `f_valid_name`/`f_name_chars`, including
rejection of Unicode letters as names; this experiment does not broaden the
language. The candidate eliminates the syntax walk's repeated head/tail and
dot lookahead operations and the separate reserved-word String scans.

Both roles create fresh valid Bend source per repetition, varying an integer
literal between zero and31. The source defines `tally` and `bump`, with ordinary
typed parameters and `U32.add` bodies. Both invoke the actual current scalar
`f_lex_cursor`, then visit every token. The observer consumes token text, all
six scalar fields, and each complete name-validity result into a rolling U32
value returned as a decimal String. Source construction, lexing, name checking,
observation and eventual destruction are charged in both roles. There is no
pretokenized input, name cache, source cache or production interning change.

This is a complete real **lexer plus name predicate** region, not the complete
parser. Keywords/numbers/punctuation are valid tokens of the source while
correctly returning false from the *identifier-name predicate*; that is not a
claim that their containing program is invalid. Actual grammar context decides
where a name is required. The observer is useful for timing consumption, not
an exact parse-tree equivalence proof.

## Controls and falsifiers

The requested common repeat controls are `0,1,2,7,31`; zero returns
`"2166136261"` without constructing source or scanning names. Old/new values
must agree for all five. Independently, `p155x_controls(0)` must return `"ok"`.
It checks each implementation against 42 hand-declared Boolean expectations:
17 valid names and25 invalid names, including all16 reserved words.

Valid controls include ordinary/underscore names, dotted names, a long dotted
name, exact-case contrasts (`DEF`, `deF`, `data`, `kind`, `quant`), and keyword
extensions (`Typex`, `typex`, `returning`). Invalid controls cover empty input,
leading/trailing/doubled dots, a digit after dot, a leading digit, embedded NUL,
Unicode, and punctuation. The controls are predicate oracles and are separate
from the syntactically valid source corpus used for the region screen.

Reject on any independent control or old/new mismatch. Native generated-code
inspection must establish whether repeated equality calls/projections actually
disappear: source spelling alone does not prove a cheaper machine path. The
[Phase137 query findings](../../../implementation/phase137/query-notes.md)
already improved complete scalar observers, so ID18 claims removal of traversals
and comparisons, not discovery of another generic borrowing optimization.

The [Phase144 findings](../../../research/phase144/remaining-opportunities.md)
and [Phase150 parser result](../../../implementation/phase150/README.md) warn
against promoting a large kernel ratio as full-parser speed. The current parser
has other reserved-word tests before `f_valid_name`; replacing only this
predicate does not erase those calls. The actual lexer is deliberately charged
here, so it may dominate or hide a useful predicate gain. Even a strong result
would need a whole-parser comparison with original diagnostics/graph behavior
before any production integration. No new compiler image acquisition or broad
qualification is justified by this source-only artifact alone.

The root's first combined preparation (`prepare02`) rejected the draft's
`case 1+p` pattern on U32 before any native target. That failed assembled source
is preserved by the root. The current repeat loop uses an explicit zero case,
then `U32.sub(n,1)` under the other branch; recursive helpers carry the same
`@unsafe` annotation used by the maintained compiler probes. No termination or
kernel-proof claim is made for these experimental recursive functions.

Combined preparation `prepare05` then rejected two draft two-argument calls to
`U32.shl`; the pinned Base defines that operation as unary and `U32.shln` takes
a Nat distance. The current `p155x_place` uses fixed U32 multipliers for byte
positions zero through three, so the corrected scan has no Nat shift-distance
conversion. The root retains the rejected assembled source; this correction
does not count as a native result or an optimization measurement.
