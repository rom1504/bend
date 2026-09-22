# Structured parser diagnostics without slowing accepted compilation

This is the bounded P5-011 follow-on to the Phase5
[conformance/development design](conformance_and_development.md), proposed after
P5-005 was rejected for repeated application-source reconstruction. That rejected
experiment concerns checker locations; this proposal concerns errors already
identified by the parser. It must not reuse reparsing or alter core application
metadata.

## Problem and measured scope

`f_err` already knows the offending token's line and column, but embeds them in
an English string. Declaration parsing then calls `nm(error)`, losing structured
metadata. The public `FResult` contains a string error. This makes consistent
source excerpts and exact expected/observed formatting difficult, and encourages
one-off formatting at individual callers.

A read-only classification of the first integrated frontend reports found165
same-rejection parse diagnostic differences:80with nonzero recorded `f_err`
positions,25with line0/lost position, and60other unstructured errors. These are
candidate categories, not80or165promised fixes. The first spike handles only a
small explicit expectation family. Many message texts and first-error ordering
rules differ independently of rendering.

## Internal transport and public boundary

Introduce a raw-parser result type carrying the existing ordered book/imports
and the actual error term. The public `f_parse(source)` continues to return the
existing `FResult{book,error:String,imports}`. Render the raw error once at that
boundary, using the same source bytes and retained lexer coordinates. All public
loader, host and54export contracts remain unchanged. Accepted books/imports and
their metadata must be exactly identical; success takes a trivial empty-error
branch and must not scan source for diagnostic rendering.

Approximately26internal result-returning declaration/import laws and22result
construction sites need an atomic type migration across declaration parsing,
parser helpers, validation wrappers and import parsing. Do not migrate public
loader/freshening interfaces. Retain an explicit unstructured fallback for
legacy messages; their bytes must stay unchanged until a separately validated
rule provides structured information.

Errors remain `Error` terms so existing propagation checks still work. Structured
payload must be explicit at construction: expected text/kind plus actual
line/column, with a clear distinction between message-only and
expected/observed diagnostics. Do not parse English diagnostic strings to infer
these fields. Do not infer positions from the final token stream, generated
terms, line0, or a guessed source match. Do not put positions in `App.id`.

## First supported expectations

Start with delimiter expectations created by `f_expect`, and the local
constructor-freshness rule once P5-010's source is frozen. Supply the pinned
expected text directly at those construction sites. Other grammar expectations
remain legacy. If needed, start with an even smaller two-case subset before
extending the family.

The pinned `parse_fail` observes one original UTF16 code unit at the cursor,
or `end of input`; a whole lexer token is not equivalent. Source extraction must
use the retained actual coordinate with the correct Unicode convention. Excerpts
must use the pinned surrounding-line/padding rules, including first/last line,
trailing newline, blank lines, comments and a non-BMP character before the error.
The first spike conservatively preserves the existing diagnostic if the offending
scalar itself is non-BMP. The reference can expose its high UTF-16 surrogate,
but both checked B1 and H reject constructing an isolated surrogate through
Char. This is an explicit unsupported rendering case, not an invitation to
change the String/Char runtime. Non-BMP characters before an ASCII fault must
still preserve its genuine lexer coordinate and surrounding source excerpt.

The renderer belongs to the standalone frontend's dependency closure. Reusing
checker-only diagnostic modules by accident is not acceptable; inspect the
component assembly contract before choosing a shared helper location.

## First-error and semantic constraints

Current `f_pr(f_expect(...))` paths sometimes discard an earlier error and later
report line0. Structured rendering alone does not repair those paths. Preserve
their current fallback and record them. Any propagation repair is a separate
small change with a two-error witness proving which error should win. Likewise,
post-elaboration `f_error_term`/`f_error_defs` currently traverse nested terms in
a defined order; leave these unstructured errors unchanged in the first spike.

An error with missing/invalid metadata must fall back conservatively. It must
not invent an excerpt, silently accept a program, change a checker error into a
parser error, or suppress an earlier error because its presentation is harder.
Normal imports, law fills, constructor namespaces and graph ordering retain
their existing semantics.

## Decisive gates

1. Freeze the integrated P5-008/P5-010 parser/declarations before an isolated
   overlay; preserve the complete baseline and every attempted candidate.
2. Genuine checked bootstrap, plus standalone frontend component assembly/check.
3. Baseline/candidate raw-book/import equality on accepted fixtures, including
   order and all term metadata. Exact outputs alone are insufficient here.
4. Targeted live TypeScript diagnostics: delimiter and duplicate-constructor
   expectations; actual EOF; newline/comment boundaries; first/last line;
   non-BMP prefix; imported bad module; and competing earlier/later errors.
5. Prior exact negative parse diagnostics must remain exact. Unsupported errors
   must preserve their previous text and phase unless a separately documented
   intended-rule repair is under test.
6. Combined full1378fixture parse/check comparison after review. No positive
   regressions, infrastructure failures, input drift or newly incorrect spans.
7. A bounded accepted-path timing check in an isolated window, then include the
   final source in the campaign's checked self-reproduction/backend gates.

A failed type migration, changed accepted book, invented cursor or material
accepted-path slowdown falsifies the candidate. Record the result and stop or
shrink scope; do not compensate with a host-side parser/formatter. Promotion is
based on observed exact improvements and maintenance cost, not merely successful
bootstrap. Keep the complete TypeScript difference count visible.

## Ownership, budget and integration

`lexer_analysis` owns the isolated prototype after the current parser and
freshness owners release their source snapshots. Root coordinates integration,
performance windows and final gates. Begin with a bounded45–60minute spike;
review scope before extending it. Existing production sources stay untouched
until the transport and first explicit expectation family pass their gates.
The campaign's02:20UTCsource freeze and03:39:36UTCend remain unchanged.
