# Ordered demand metadata discriminator

**Rejected before build:** the genuine-B2 census found zero ordered parallel-let
groups on all four selected sources, with exact complete output equality. See
[the report](../../../../../implementation/phase65/output-metadata.md). This
is an archived unapplied candidate against Phase65 baseline `49431ba`. Root alone runs targets.
The before/after Bend file and `candidate.json` bind the exact isolated patch.
No live compiler file was edited while preparing this proposal.

`JDText` already stores use/reference notes and composes them without rescanning
joined children. This candidate reuses that existing implementation at one
remaining String boundary: an ordered parallel-let body currently receives one
`String.contains(body, jd_use(id))` query per binder. For two or more binders,
scan the complete `prefix ++ value` once and share its notes among those queries.
Zero/single-binder groups retain the original early-exit substring route.

The public String-taking `jd_ordered_bindings` helper stays unchanged, as do
`JDOrdered`, `JDText`, byte rendering, names, escaping, slot numbering, evaluation
order and the binding join. Malformed, split-looking and over-limit metadata uses
the existing `jd_text_used` fallback to exactly the original String query. The
new leaf is local to this demand pass; it adds no lookup world, cached plan, IR
or serialization layout. It does not remove the later final-output scanner.

The patch adds 27 Bend lines and three private helpers. The major risk is cost:
a whole scan and a note list can lose against two early-exit substring searches.
The group threshold is prospective, not tuned after timing. Do not retain this
candidate based only on fewer substring calls.

## Archived execution proposal

0. Run `opportunity.mjs PREPARATION_RESULT PLAN CASE_ID NEW_PHASE65_OUTPUT`
   against the actual Phase64 State09 genuine B2 first. The Phase65
   `baseline-state09/preparation/prepare-baseline.result.json` and
   `baseline-state09/baseline-four/plan.json` bind the four existing sources and
   complete output oracles. Use a fresh process/output per source. The observer
   counts groups at the actual ordered-let entry and counts actual nonempty
   haystack positions at the original `String.contains` SCC search state. Only
   the lexical call from `jd_ordered_bindings` enables those counters. Needle
   comparisons are excluded. Metadata eligibility is reported separately for
   groups with at least two binders. Every full module must match its original
   oracle. This creates reversible diagnostic API/driver copies and passes no
   custom API into ordinary `inspect`; no source candidate or B1 build is needed.
1. Only if that opportunity is meaningful, apply after verifying the target's
   before hash and build strict checked B1.
2. Run `compare.mjs CHECKED_ATTEMPT NEW_PHASE65_OUTPUT`. Its append-only
   diagnostic verifies every enclosing `JDOrdered` value and compiles complete
   modules with the candidate enabled and forcibly routed through the unchanged
   old helper. The default set includes Numeric, Map and a focused parallel-let
   fixture. A supplied catalog and case IDs select other actual sources.
3. The synthetic controls compare complete binding outputs and independent
   RHS/type-query event order for zero, one, two and four bindings, with live and
   erased RHSs. They include exact and prefix-similar IDs, leading zeros, quoted
   and escaped lookalikes, Unicode, duplicates, unknown/malformed REF metadata,
   and marker fragments. They also compare full reference results with the old
   scanner. RHS spies establish the local demand/order contract, not execution
   of arbitrary generated programs.
4. `PHASE65_METADATA_LARGE=1` adds code-point sizes 2,097,151, 2,097,152 and
   2,097,153. The last must retain the old substring fallback for local demand
   and the old refusal for reference queries. Run this separately if its cost
   does not fit the first focused guard; preserve failed attempts. Also retain
   existing reach-order/budget and direct effect/erasure gates.
5. Only after exact controls, run the unchanged balanced four-source clean
   campaign against the actual previous image. Record metadata admission count
   and eligible body sizes separately from clean time. If real corpus admission
   is negligible or request time is flat/noise-sized or worse, reject this lane
   rather than widening the output representation.

No compiler/Node target has been run by this proposal's author. The new fixture
has source-level expected result 19 and remains subject to actual checking.

## Controller provenance

`compare.mjs` follows the reviewed Phase64 discarded-argument controller's
checked-attempt verification, append-only diagnostic import, enclosing-result
oracle, old-path whole-module comparison and input re-verification. It does not
modify that consumed controller. Counts are instrumented logical observations;
`eligibleBodyCodepoints` is body size admitted to one scan, not a claim about how
many characters the old early-exit searches would have visited.

## P65-006: structured live-lambda returns

This separate hypothesis removes an existing render/rescan round trip, with
zero added source lines, helpers or types. Its one-line `closure-candidate.patch`
and receipt remain isolated until root integrates them. Registration:
[P65-006](../../../../../experiments/phase65/P65-006-structured-closure-return.md).

`closure-opportunity02.mjs PREPARATION_RESULT PLAN CASE_ID NEW_PHASE65_OUTPUT`
uses the same genuine-B2 preparation and complete original output oracle as the
rejected demand census. It records Nil-arm admissions and the exact lexical
outer raw-input codepoint span, capped at 2,097,153. These are diagnostic counts,
not every primitive parser comparison or a clean clock.

After root builds checked B1, run
`closure-compare.mjs CHECKED_ATTEMPT NEW_PHASE65_OUTPUT [CATALOG CASE_IDS...]`.
The diagnostic appends helper wrappers and compares candidate versus the old
render/rescan route, including every complete module. It compares rendering,
codepoint size, use decisions, full reference Maybe/list/refusal and ordered
notes where both representations are safe and within the cap. Tree shapes are
intentionally different. Synthetic body-producer controls call the actual
candidate helper and old expression path and verify identical body arguments,
owner removal, retained captures and `$arg`. No arbitrary production lowering
is replaced during the real module comparisons.

The default real modules include Numeric, Map, the new nested-capture witness,
existing closure/HOF, closure-owner recursion and generic erased-closure cases,
plus an explicit erased-inner-lambda witness (source-level result 17).
The new witness's source-level result is 15; its actual checking remains a gate.
Set `PHASE65_CLOSURE_LARGE=1` for the required cap−1/cap/cap+1 controls, including
an astral Unicode codepoint at the exact limit. Preserve any failed/skipped
observations and finish this boundary gate before retention. Instrumented
comparisons do not establish request speed or generated-program execution.
