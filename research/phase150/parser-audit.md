# Phase150 parser producer audit

Read-only source/evidence investigation at `267ae45`, 2026-11-01. No compiler
targets, native runs or source edits were performed by this audit. This document
selects a bounded experiment; it supplies no new performance result.

## Recommended first boundary

Replace the implementation of the complete lexer producer, preserving the exact
`List<FToken>` output and all existing `FInput`/parser consumers. Use direct
`SNil`/`SCon` matches and bounded character lookahead, dispatch symbol pairs and
triples on character codes, and calculate quoted-token UTF-16 width and final
physical line/column during the scan. Keep the original lexer as an explicit
reference in the experimental source. Charge token/name construction, reversal,
retention and destruction; this experiment does not eliminate all those costs.

The concrete maintained boundary is
`selfhost/src/front/lexer.bend`: `f_lex_cursor`, `f_lex_comment`,
`f_lex_symbol`, `f_scan_word`, `f_scan_quote`, `f_lex_scanned`,
`f_lex_quote_end`, `f_pair_op`, `f_triple_op`, `f_symbol_text`.
`selfhost/src/load/modules.bend:f_body_header` feeds its result directly through
`f_input` to `f_tops`, then diagnostic finishing and contextual completion.

This replaces repeated producer work without a packed intermediate conversion:
head/tail projections and ASCII tests; repeatedly constructed two/three-character
Strings; string equality over those temporary names; and the quote's independent
`dg_width` and `f_lex_quote_end` walks. An ordinary quoted token currently gets a
scan, reverse, width walk and physical-position walk. Identifier text currently
gets a reversed list plus reversal, but replacing it with non-tail recursive
forward copying must retain the old long-name stack behavior. Do not silently
trade a heap-bounded scan for host stack overflow.

A lazy token cursor is a larger and less decisive first experiment. Parser
functions repeat `f_tl`/`f_space` on the same immutable input, and
`f_context_rewind` deliberately combines an old token position with a newer
context. Without memoization, a lazy tail can scan characters repeatedly. The
incremental `p140p_*` checkpoint code also compares exact tokens and uses the
previous lexical token as lookbehind. Chunking at a newline is not sufficient:
an operator after the newline can extend the previous expression.

## Exact lexical obligations

These are current behavior to preserve, including unusual cases.

* Only `SNil` is EOF. A real NUL character in `SCon` is an ordinary symbol.
  `f_head(SNil)` also returns NUL for lookahead, so direct matching must preserve
  the distinction between missing and present characters.
* Cursor zero disables metadata. `f_cursor_add(0,n)` is zero and the empty-input
  lexer omits the EOF token when its final offset is zero. Otherwise EOF has
  text `<eof>`, line/column/kind zero, equal begin/end, and supplied previousEnd.
  Arithmetic is U32, including wraparound to zero.
* ASCII identifier characters are letters, digits, underscore and dot. A
  leading dot delays word scanning until after the three-character operator
  test. Non-ASCII letters are single symbol tokens; their UTF-16 width may be
  two, while the physical column increases by one.
* A plus/minus joins a word whenever the most recently accepted character is
  `e` or `E` and the following character is an ASCII digit. This applies to
  `name+2` and `e-1`, not only conventional numeric literals. Accepted exponent
  characters may be followed by further ordinary identifier characters.
* Newline advances physical line, resets column, advances UTF-16 offset, and
  emits a token only at depth zero. It does **not** update previousEnd. Depth
  changes only for single-character `()[]{}` symbols and uses modular U32
  addition/subtraction even for unmatched closing delimiters.
* Comments consume through the next newline/EOF, advance UTF-16 offset, and
  deliberately leave the physical column unchanged while consuming comment
  characters. The newline is handled by the ordinary newline branch.
* `++` is suppressed when the previous token's text ends in `n` and its
  physical column plus `String.length(text)` equals the current column.
  Thus `1n++foo`, `1n++2n` and `1n ++foo` take different paths.
* `>>` becomes `>>op`, and `>` becomes `>op`, when the current physical column
  exceeds the previous token's column plus **stored text** length. There is no
  line-number comparison. Previously rewritten token lengths therefore affect
  subsequent decisions. The accumulator's empty lookbehind is `<eof>` at
  column zero, and a depth-zero newline can itself be the lookbehind token.
* A single plus becomes `+bind` only when the next character is ASCII alphabetic
  and the same contiguous prior-ending-`n` condition does not hold. Underscore,
  digit and non-ASCII letter do not satisfy the alphabetic condition.
* Triple operators are exactly `.&.`, `.|.`, `.^.`, `<&>` and are tried before
  the final dot-word/symbol branches. Pair operators are the exact current
  thirteen strings in `f_pair_op`; matching a pair must not alter delimiter depth.
* Quote scanning retains delimiters and raw escape bytes/code points. A slash
  consumes the following character without closing the quote even if that
  character is the matching delimiter. Escape validity belongs to later parser
  decoding. Actual newlines, including escaped actual newlines, change physical
  line/column. A source backslash plus letter `n` is two ordinary columns.
* Unterminated quotes, including a trailing backslash, produce kind 3 text
  `unterminated string`, at the opening physical location, with begin=end at
  the opening cursor and preserved previousEnd. Earlier tokens survive. No EOF
  token or tokens after the quote are emitted. Failed scanner output size zero
  must not accidentally publish accumulated final line/column/width metadata.
* Quote/word end cursors are calculated once from the opening offset and total
  width/size. Accumulate quote width with raw `U32.add`; do not apply
  `f_cursor_add` to an absolute cursor per character, because crossing zero
  midway through a quote would introduce a false disabled-cursor state. Comments
  do apply `f_cursor_add` once per consumed code point, as in the original.

## Small exact controls

First compare complete token lists, including every one of the seven FToken
fields. `p140p_token_same` in `front/compact-parser.bend` already supplies exact
single-token comparison; extend it with an ordinary list observer or use the
existing host structural comparator. Run each family with cursor zero and a
nonzero cursor, and selected cases with nonzero line/column/depth and a supplied
lookbehind accumulator.

| Family | Minimum distinguishing inputs |
| --- | --- |
| EOF/NUL | empty, a real NUL, `x` followed by NUL, one/two-character lookahead at EOF |
| Words | `a.b`, `.a`, `.`, `..`, `e-1`, `name+2`, `1e+2`, `1E-2`, `e+`, `e+x`, `e+2x` |
| Operator priority | all pair/triple spellings, proper one/two-character prefixes, `.&x`, `.<&>` |
| Adjacency | `1n++foo`, `1n++2n`, `1n ++foo`, `n+abc`, `n +abc`, `+_x`, `+1`, plus a non-ASCII letter |
| Greater-than | `a>>b`, `a >> b`, `a>b`, `a > b`, chained spaced `>` tokens, line transitions and leading columns 0/6 |
| Newline/depth | LF, CRLF, CR, tab/vertical-tab/form-feed, nested brackets, unmatched closer before LF, comments at EOF/inside brackets |
| Quotes | empty single/double quotes, escaped matching quote, escaped backslash, raw LF, escaped raw LF, trailing backslash, unterminated quote after valid token |
| Unicode | BMP and non-BMP inside/outside quotes, non-BMP in comments, valid/invalid Unicode escape text, isolated-surrogate Char constructed by Bend if supported |
| Numeric bounds | nonzero cursor near U32 maximum; depth zero/one/maximum; nonzero initial column |

Then compare complete `FResult` on ordinary valid programs and on failures:
duplicate declarations/constructors; law filling including imported laws;
namespaces/aliases; template parameters; first error followed by a second error;
multiline/Unicode quote diagnostics; incomplete headers; marks and constructor
patterns. A missing marked type can be accepted by raw parsing and rejected
later: do not repeat Phase144's incorrect raw-stage expectation.

## Existing extraction, entry and oracle

The retained directory
`selfhost/build/phase144/parser-native-source04/` contains `candidate.bend`,
`original.bend`, `native-entry.bend`, `manifest.json` and build receipts.
The candidate manifest lists 906 named dependencies and 1,114 original ordered
declaration spans, preserving both earlier laws and later same-name definitions.
This is a historical extracted parser, not the current maintained compiler.

`selfhost/tools/build/source.py` provides current `maintained_assemble`, `blocks`,
`grouped` and `normalized`, but no dependency-closure extractor. Current slicing
can select exact current spans with those facilities; it must separately retain
constructor-owner dependencies, source order, annotations and all laws. Merely
copying the old name set is insufficient when new helpers are introduced.

The old safe extractor and independent comparator are recoverable through
`selfhost/tools/history/restore.py` from baseline
`2a4f9f8383cbc66fadaedd9b4b27f83b93a13511`:

* `selfhost/tools/performance/phase144/parser/prepare-native-v04.py`
* `selfhost/tools/performance/phase144/parser/native-oracle-v01.mjs`
* `selfhost/tools/performance/phase144/parser/parse-screen-v02.mjs`
* `selfhost/tools/performance/phase141/census/read-onlyinventory.py`

The extractor's two historical failures are relevant: a last-name map lost an
earlier law, and a double-quote-only masker misread a character literal. The
corrected extractor groups laws/definitions and masks strings, character literals
and comments, then independently audits dependency names and constructor owners.
Recover for explicit inspection; normal current builds should use maintained
tools and exact current source, without an implicit historical composition chain.

The existing native entry copies six ordinary `p86_plan*` functions, renames the
private result/continuations, and stops immediately after `f_prefix_graph_trace`.
It retains the prepared seed, times Base preparation separately, then parses the
complete fixed input, then observes the entire external FResult. Runtime argv
requires an ignored sentinel before INPUT BASE CARRIER STAMP. `IO.args` excludes
argv[0]; omitting the explicit sentinel caused the old failed native attempt.

The old hosted oracle compares complete parse trace and retained seed using
strict key/scalar equality plus a worklist and memoized object pairs. Its
independent tagged-field checksum agrees with Bend's checksum over every
external FResult field. The retained full-input result compares 3,535,203 object
pairs and 16,769,616 words, hash 2842271599. The checksum alone is not exact
equality. Its 169.5s/3.1GB hosted validation is a reason to start with exact full
token-list equality and small graph controls before paying for another full
graph oracle.

Use current `build/native.py`, `build/hosted.mjs`, explicit assets and one disk
guard for new acquisition. Charge both native images and every failed attempt.
Historical 119s acquisition and 79s paired harness costs are planning evidence,
not a quote for current tools or current source.

## Larger traversal opportunity and constraints

The private ready-prefix path in `load/prefix.bend` validates the complete suffix
through `f_validate_result -> fpe_defs`, checks top-level graph names, then walks
the suffix again through `f_fresh_defs`. A later complete producer experiment
could return freshened definitions together with the first error selected from
the **original** tree. The successful ready-prefix route could thereby combine
validation and freshening; any detected error/name failure can use the unchanged
fallback path. This requires a precise private contract, not weakening public
validation or accepting a caller-supplied flag.

`fpe_defs` visits each definition's type, value, constructor definitions, then
the remaining definitions. `fpe_term` selects a nonempty-name Error, skips an
empty-name Error without visiting its children, and synthesizes an error for
ImportLaw. Freshening unwraps FName/FGlobal and changes the visited children, so
collecting errors only from the rebuilt tree would be wrong. Preserve graph
error precedence and any fallback's whole-book renumbering as well.

Moving the global next counter directly into the parser is not a local change.
`f_context_enter` deliberately resets it per declaration. Materialization and
beta/flattening may change the final tree and binder order. The final freshener
orders type before value before nested constructors; allocates an All's binder
before its domain but exposes it only in the body; evaluates parallel Let values
under the original environment and its body under the extended environment;
preserves KLambda quantity presence and exact origins; and resolves local-ID
shadowing. Any producer-side replacement must establish all those invariants.

## Cost hypothesis and stop gate

The final Phase147 parse/load stage is 32.025s with 999 samples. Its largest
reported owners include `f_eq` 102, `f_grow_base` 46, `f_pattern_sub` 36,
`f_lex_symbol` 28, `f_context_material_deferred` 26 and `f_triple_op` 25.
Those owners establish distributed work; they do not measure inclusive lexer
time. Token/character operations also occur beneath runtime leaves. There is
no basis to multiply 32s by a proposed lexer speedup or to promise 2x whole parse.

A 2x complete lexer boundary is a plausible falsifier for the direct producer,
subject to machine-code/ownership inspection and native measurements. A 2x
complete parse/load boundary would require removing at least half that region's
cost; the present evidence does not show that the lexer owns half. Measure full
native parse and complete process time, including observation/reclamation and
source conversion if any. If the region gate is defined as full parsing, report
the measured failure honestly rather than relabeling a fast lexer as success.
