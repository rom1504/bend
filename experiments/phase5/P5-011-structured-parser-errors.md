# P5-011 — Structured raw-parser errors

- Owner: lexer-analysis; root owns design and promotion.
- Status: validated and promoted as narrow source/host hunks after root approval; combined integration pending (initial preregistration retained below).
- Scope: isolated source overlay; no production module/default API changes.
- Related design: `design/phase5/structured_parser_diagnostics.md` (root-owned).

## Hypothesis and initial subset

A private raw-parser result can retain the original Error term until the public
`f_parse(source)` boundary, where an expectation, actual source position and source
text can be rendered once. This avoids reparsing and extracting positions or
expected text from formatted messages. Public `FResult{book,error:String,imports}`
and loader behavior remain unchanged. No App metadata or core representation
change is involved.

First scope: explicit delimiter expectations in `f_expect`, plus the structured
constructor-freshness expectation when the source owner has frozen it. Unknown
legacy errors keep their existing strings. The candidate must not automatically
reinterpret all errors or infer a location from a later parser failure.

The inspected attempt01 report has 165 same-rejection parse-diagnostic differences
against the historical pinned reference: 80 have a nonzero position in the legacy
`f_err` representation, 25 report line0, and 60 are other unstructured errors. This
is an opportunity count, not a promised repair count. Missing positions and
elaboration errors are explicitly outside this initial transport spike.

## Invariants and refusal boundaries

- Preserve exactly the first Error already selected by existing parsing. Changes
  to swallowed-error propagation require a separate explicit proposal.
- Transport the Error term, not `nm(error)`, through internal declaration results.
  Success and plain legacy-message cases have explicit distinct representations.
- Render only errors with genuine structured metadata. Read the observed original
  source unit or EOF at that position; do not substitute the whole token. Pinned
  TypeScript observes one UTF-16 code unit, which requires explicit non-BMP and
  malformed-input tests rather than assuming Bend Char is identical. The initial
  renderer explicitly retains the legacy diagnostic when the offending scalar
  is non-BMP: B1 and H reject constructing an isolated surrogate, whereas the
  reference may expose its high UTF-16 surrogate. A non-BMP prefix remains a
  supported coordinate test. No Char/String runtime change is allowed.
- Keep accepted book/import order, constructors, terms, binder metadata and removal
  metadata exactly equal. The public result and loader/cache ABI stay unchanged.
- Preserve standalone frontend component dependencies; do not make raw parsing
  depend on the diagnostic backend just to reuse its snippet formatter.
- Do not add reparsing, arbitrary guessed spans, error-message parsing, silent
  fallback to TypeScript, or formatted-text matching as semantic control flow.

## Bounded implementation shape

The inspected source has 26 internal FResult-returning declaration/import laws
across `front/declarations.bend`, `front/validate.bend` and `load/imports.bend`, plus
22 `f_result` call sites. Keep public `f_parse` returning FResult; migrate the
private raw result consistently, including each `f_choose` result type. The fourth
existing file is `front/parser.bend`, which creates structured errors. A small
source-aware renderer may live in that frontend layer without a new dependency.
Root must authorize the exact frozen source before edits; P5-008/P5-010 owners
retain their production files throughout.

## Gates and stop conditions

1. Genuine checked bootstrap of the isolated candidate. Preserve every failure;
   no fabricated API/proof metadata.
2. Compare full raw books and imports for accepted cases: definitions, constructors,
   ordering, every KTerm field and metadata. Include laws/fills, binders, nested
   terms, imports, strings/non-BMP and the frozen source component where feasible.
3. Compare baseline, candidate and live pinned TypeScript for targeted delimiter
   and constructor-name errors. Every changed diagnostic must become exactly the
   reference. Unsupported errors must retain their old text. No acceptance or
   parse/check phase change is permitted for a transport-only patch.
4. Check first-error versus later-error inputs, imported module errors, EOF with
   and without trailing newline, comments, tabs, non-BMP preceding the fault and
   malformed Unicode. Unknown/zero-position errors must not invent an excerpt.
5. Validate a standalone frontend component. If the small gates are useful, root
   chooses a broader negative parse selection and combined integration proof.

Stop if this needs a public ABI migration, broad parser/scoper rewrite, guessed
positions, new error precedence, or expensive successful-path processing. Keep
performance observations separate from correctness; equality timing has its own
scheduled uncontended slot. No automatic promotion or performance claim.

## Bounded spike outcome (2026-09-22 23:07 UTC)

Implementation was authorized against genuine integration attempt02. Final isolated
attempt03 passes 25 targeted controls (eight exact repairs), three additional
CRLF/line-width controls, and full raw-result equality on Base, the frozen compiler
and list_sort. Across 167 baseline parse-error cases, six become exactly the live
reference and 161 remain unchanged, with zero classification changes or new
mismatches. Two pre-existing acceptance gaps remain; the overall conformance
runner correctly remains failing. No performance claim is made.

The first checked build failed on the unconverted forwarding law in sugar; the
second candidate exposed a real spaced-constructor position mismatch. Both are
retained. The final refusal requires genuine name/brace adjacency. Unknown token
coordinates and offending non-BMP scalars also retain legacy text. Standalone
frontend compilation exposed a pre-existing book_without layer dependency,
reproduced on baseline and closed only with an explicit unchanged helper in the
component test. Root owns the separate production layer correction.

Independent static review found no blocker for this bounded scope. Promotion and
combined source proof are pending root coordination. See
[implementation report](../../implementation/phase5/structured-parser-diagnostics.md)
for exact artifacts, controls and limitations. No production source or default
API was changed by this experiment owner.

Final report-only audit passed all 167 rows. Root authorized production promotion
after the timing hold; the exact overlay applied cleanly, preserving independent
matcher/sugar/core-layer changes. Historical failed attempts, exact consumed tool
versions and before/after promotion sources are now durably archived. No default
API was updated and no combined-proof claim is made by this isolated gate.
