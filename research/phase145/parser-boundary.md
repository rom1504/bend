# Phase145 parser-boundary addendum

Read-only metadata/source audit, 2026-10-27; no new target runs or tools.

**The12.07× contrast is a legitimate descriptive stage opportunity on the same
source bytes. It is not a matched current compiler-speed result, an isolated
lexer ratio, or evidence that changing String representation alone gives12×.**
It deserves a bounded parser experiment because upstream demonstrably processes
the actual full input quickly, not just a tiny prefix.

## Exact observations and nonmatching boundaries

Both observations use the2,946,225-byte frozen Phase142 compiler source,
`selfhost/build/phase142/indexed-source02/compiler.bend`, SHA
`15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1`.

| Observation | Interval | Included | Excluded |
| --- | ---: | --- | --- |
| Historical Phase144 indexed-parser native slice |31.175s|Actual parse/import/contextual processing, validation and freshening prefix; its intermediate allocation/reclamation|Input file reads and initial String creation; prepared Base decoding0.208s; post-parse error/checksum observation0.605s; later checker/backend|
| New pinned upstream original TypeScript/Bun |2.583160s|`book_load` on the exact source, file IO, source Base parsing, name resolution and body construction/conversions|Module imports, post-load summary/hash, typechecking, checked-runtime erasure, backend emission, machine build|

The quotient is31.175/2.583160065 = **12.068551**. Each is one observation in a
different experiment. OS caches were not flushed, and these are not alternating
runs of matched current executables.

The Bend slice is source
`selfhost/build/phase144/parser-native-source04/candidate.bend`, SHA
`8fa3c137ae2e3474a2bfa99fc6b1bbd77bb506cf81017f9d6d857f272e5270ca`.
It was built by the qualified Phase143 producer and linked to the older
Phase128 atomic-reference-count runtime `9b3f57af…87749`. It is an extracted
parser, not final04 N2 with its later serial runtime and full-image layout.
The receipt is `selfhost/build/phase144/parser-native-timing02/report.json`,
SHA `888930fb786ea5e8afda5f46ed8cffb22d81c9ad262cf12c576fc5b69d789d8c`.
Its complete parse products were separately compared against the original
implementation over3,535,203 object pairs; the native checksum2842271599 is a
finite regression check, not a standalone structural proof.

The upstream receipt is
`selfhost/build/phase145/upstream-full-parse01/full-phase142-original/report.json`,
SHA `e8a0a4d5b22089f1f3301dfa7f05049522a0696f256d89004844b9391768e70d`.
The source implementation is pinned `bend2/bend.ts`, SHA
`1d133151652b597a1a035c77c172475e6de096da37f3b9e3adc23c2f75bdfe49`.
The loaded summary reports8,436 events,7,352 definitions,380 datatypes,
570 constructors and **zero checked erased bodies**. Counted versus original
loaded summaries agree, but that is not complete AST equality or a cross-compiler
semantic equivalence result. The counted5.023s load is diagnostic and must not
replace the original2.583s timing.

One inherited receipt sentence says "Source Base loaded and checked every
request." That generic sentence is inaccurate for this **parse-only** fixture:
the actual worker calls `book_valid` only when `fixture.mode === "compile"`.
The frozen plan, timings and zero erased bodies correctly identify this run as
load/parse only. Preserve the original evidence and apply this clarification;
do not quote it as2.583s for full compiler checking.

## Concrete source differences

Source citations below use final04's frozen
`selfhost/build/phase144/final04-source01/compiler.bend` for the current Bend
architecture; its timing is not substituted for the historical slice.

**Cursor and token materialization.** Upstream `Parse` (`bend.ts:337`) holds one
native JavaScript string and a mutable integer `pos`. `parse_peek/bump/at/take`
at1527–1550 index that string; `parse_skip` at1552 loops with `charCodeAt`;
`parse_lexeme` at1592 advances a range and slices the resulting identifier.
It parses terms directly from that cursor rather than constructing a complete
linked token stream first. `parse_char` at1617 handles code points and increments
the UTF-16 position by one or two units.

Our native input is semantically a `String` cons list. `f_head/f_tail` at11063/
11074 inspect its constructors; `f_scan_word` at11092 builds a reversed character
list and then reverses it. `f_lex_cursor` at11209 uses repeated head/tail/class
queries and constructs seven-field `FToken` values carrying text, physical line/
column, kind, UTF-16 begin/end and previous end. `f_body_header` at15245 consumes
that token stream through `f_tops`, then contextualizes the result. Character,
token and intermediate-list traversal and ownership are therefore real extra
representation work. Input file-to-String construction is outside the31.175s
clock, so removing only that construction would not remove the measured gap.

**Position and prefix obligations.** The extracted `p144pn_parse` at8580 first
walks `p86_width(text,0)` to position the whole source after the prepared Base.
It terminates only after `f_prefix_graph_trace`; final04's implementation at
15549 validates the parsed suffix, verifies graph/name conditions and calls
`f_fresh_defs(suffix,next)` through `f_prefix_trace_validated` at15577. Upstream
already knows the native String length and assigns fresh binder IDs through
its mutable parser state; `parse_book` at2489 resets the local fresh counter per
declaration. These outputs serve different internal identity/loader contracts.
Fusing or avoiding redundant walks is plausible, but omitting global freshness
or exact origin handling would change the Bend compiler's obligations.

**Resolution and publication.** Upstream `parse_reso` at1670 checks namespace,
alias and constructor/definition membership with string-keyed records;
`parse_fresh` at2422 and `parse_def` at2431 publish/check headers in place.
Our `FParseScope` at191 carries prior declarations, a name index, constructor
index, aliases, namespace and the newer exact-prior view. The Phase144 indexing
change already removed an important repeated flat scan. Its first-prior order,
named misses, law filling and constructor rules are not interchangeable with
every existing index. `f_context_resolve` at11377 still contextualizes parsed
terms, and some qualified-name checks use `f_declared` at15072. That does not
establish that `f_declared` is hot on this predominantly unqualified source:
the lazy equal-name branch avoids those checks. Count the actual route before
proposing another generic name-index replacement.

**Upstream also traverses and reconstructs syntax.** `parse_def` constructs its
body using `body_flatten`, `term_higher`, `term_lower`, then `term_higher` again
(`bend.ts:2484`). The counted full-source run observes millions of those term
entries. Its fast load is not evidence that upstream performs no contextual
work. The discriminating question is the cost and number of whole traversals,
the representations crossing them, and the native execution of the algorithms.

Both parsers have error and span obligations. Upstream throws structured errors
with source spans; ours must preserve its complete `FResult`, import handling,
law/duplicate precedence and first error, including physical columns and UTF-16
positions. The proposed experiment should retain those behaviors rather than
compare only successful declaration counts.

## What to do with this gap

The evidence supports prioritizing parsing as a potentially large absolute
stage opportunity, alongside the backend work. It does not support scaling
31.175s by12.07 to predict a new final04 request time. The retained final03 full
diagnostic parse/load interval33.411s corroborates the historical scale, but is
also a different image and instrumentation policy.

The smallest decisive next experiment is one complete lexer/parser boundary on
the already retained full input and small Unicode/error controls. First separate
lex/token construction, contextual declaration work, validation and freshening
with exact current-native markers or counters. Then prototype **one** of:

1. A cursor/token representation that avoids materializing/reversing identifier
   character lists and the entire token stream, retaining spans and errors.
2. Producer-side binder/origin information that removes a measured redundant
   width/freshening/context traversal while preserving the same final result.

Charge conversion to any packed character buffer, seed preparation, consumers
and teardown. Preserve the original parser as the complete-product oracle and
test comments, quotes/escapes, non-BMP characters, namespaces, aliases, laws and
duplicates. A global String ABI change is unnecessary for this falsifier.
Only after this whole-boundary result should we choose between a local parser
representation, a general compiled-loop improvement, and a larger frontend
refactor. No further target execution was performed for this addendum.
