# P5-019 — Explicit parser expectation sites

- Owner: lexer_analysis; root owns promotion.
- Status: preregistered static triage during the P5-015 timing hold.
- Budget: approximately 30 minutes after the hold and a confirmed source snapshot.
- Scope: isolated extension of P5-011's structured transport; no grammar changes,
  new parser, legacy-message extraction, or default API update.

## Hypothesis

Several existing rejection branches know both the expected grammar item and the
actual token cursor. Passing those facts explicitly to `fpe_error` can repair
additional reference diagnostics using the existing renderer. This should require
small call-site changes, not new formatting or source-position inference. Unknown
or differently positioned cases must retain their old diagnostic.

Static reference is pinned `bend2/bend.ts` SHA
`461e0c5dd12789ea293daf01c1cb5b8504f8dfcf8d38b85744665a77ecc63168`.
P5-011's accepted isolated API is `1d4e8450…`, source `31c2055c…`; the final
implementation baseline will be recorded after root coordinates promotion.

## Cursor and expected-string triage

| Existing branch | Reference expectation and cursor | Proposed first scope |
| --- | --- | --- |
| `f_atom_base` final rejection | `a term`; raw default in `parse_term` at the offending character | Punctuation/non-reserved tokens only initially. Reserved words have specialized messages and a cursor after the consumed word; do not blanket-convert them. |
| `f_args` forbidden semicolon, `f_do_parameters_open` semicolon | `a term` at `;` after whitespace skipping | Reuse the same explicit expectation helper. Retain existing branch/control order and distinct legacy fallback strings. |
| `f_top_ready` final rejection, late import | `'def', 'type' or 'law'`; final `parse_book` branch after `parse_skip` | Exclude unknown decorators: TS consumes `@` first and reports expected `'unsafe'` at a different cursor. Known `@unsafe` failure also has its own expectation. |
| `f_law_clause` non-leading `~` rejection | `a plain clause (only leading clauses take ~)` at `~` after `for` and `parse_skip` | Token position appears aligned; include same-line, newline, comment and first-error controls. |
| `f_do_parameters` missing `<` | `'<'`; `parse_eat` skips whitespace after the monad name | Reuse existing spaced token list, subject to actual cursor controls. EOF stays conservative. |
| `f_foreign` invalid path | Missing opening quote expects `'"'` at the next nonspace character; wrong extension expects `a .c or .js path` **after** the closing quote | Only missing-opening-quote branch initially. Do not attach wrong-extension errors to the token start. Retain the exact old plain fallback text rather than accidentally adding a legacy line prefix. |

There are two distinct foreign failures hidden behind one current string. The
extension error cannot safely reuse the missing-quote cursor. A small explicit
Error constructor accepting the exact legacy string may be necessary; neither
helper nor branches may recover semantics by recognizing formatted English.

## Required gates

1. Genuine checked candidate build with exact frozen source/host provenance.
2. Fresh baseline/candidate/live-reference controls for every proposed site:
   whitespace, comments, CRLF, tabs, first versus later error, EOF and non-BMP
   prefix/offending scalar. Include reserved words, unknown decorators, quoted
   wrong-extension foreign paths and valid neighboring forms as refusal controls.
3. Full raw book/import equality for accepted controls and the existing substantial
   raw-result fixtures. No classification or first-error changes are allowed.
4. Repeat all167 baseline parse-error observations against live reference, and
   preserve P5-011's newly exact controls. Classify each result as unchanged,
   newly exact, or changed-but-still-mismatching. The last category is a failed
   candidate gate, never counted as conformance improvement. Existing acceptance
   gaps remain explicit.
5. Review exact source diff before root promotion. No successful-path rendering,
   reparsing, arbitrary span budget, guessed EOF position, or performance claim.

Stop or reduce scope if a site needs new position reconstruction, altered grammar
or error precedence, or a broad source representation change. Preserve all failed
attempts and counterexamples. Compiler execution is prohibited during P5-015;
this preregistration records only static inspection.

## Results and explicit presentation-gate amendment

The genuine attempt02 candidate has API `2a5a2748…`, source `ba982452…`, based on
the checked P5-022 candidate `4da20a0d…`. Its first26 controls repair14 diagnostics
exactly; three diagnostics change but remain divergent. Two top-level examples
retain original import text in the excerpt where the reference loader blanks
leading imports. A comment-separated law clause still reaches the old later
expected-term failure instead of the reference's earlier non-leading-template
failure. These are retained counterexamples, not exact repairs.

The broader167 comparison repairs45 diagnostics exactly, leaves113 unchanged and
changes nine remaining mismatches. All eight formerly exact observations remain
exact; classification is unchanged throughout. Remaining differences involve
existing parser-state gaps in array syntax, old lambda syntax, if syntax and
framed match heads. Full before/after/reference text is retained. No fixture or
message-specific filters were added to remove those failures.

The original strict26/167 gates remain **failed**. After independent static review,
root explicitly approved a presentation criterion: unchanged parsing/control
flow and authoritative legacy Error identity, explicit grammar-site expectation
metadata, conservative actual-token/source fallback, no loss of prior exact
diagnostics, and transparent retention of still-divergent cases. This does not
convert unresolved parser semantics into conformance passes. All new formatting
is on already-rejected paths. Guarded source promotion must preserve the separate
P5-018 Nat parser and P5-016 sugar changes; a fresh combined build follows the
controlled timing hold. No isolated speed or full-language-conformance claim.

The approved exact hunks were promoted during the timing hold without running a
compiler or archive job. Full original source hashes guarded parser/declarations/
sugar, preserving P5-018 and P5-016. The new26-case integration manifest explicitly
separates14 exact diagnostics from12 acceptance/phase controls. Original failed
strict reports remain unchanged; substantial raw equality and archival run only
after the hold, followed by the root-owned combined build.

Post-hold raw frontend checks passed on pinned Base, frozen P5-022 compiler source,
and list_sort, with identical malformed UTF-16 exceptions. The immutable
[evidence archive](../../implementation/phase5/parser-expectation-evidence/manifest.json)
retains 3,876 historical file identities and both original failed strict gates;
[promotion source versions](../../implementation/phase5/parser-expectation-promotion-sources/manifest.json)
are retained separately. Final combined proof remains a distinct gate.
