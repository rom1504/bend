# Phase175 parser decision work: two small independent falsifiers

Source audit at `0d12402`, 2026-11-07. The installed compiler is the Phase171
version qualified in Phase174, whose current-source cold N1→N2 observation is
188.002s. No target was run for this audit and no maintained source was edited.
The experimental Bend implementations below still require source checking and
complete-value comparisons before any performance claim.

## Selection and evidence

**Test exact operator classification first; separately test shared parser
lookahead.** These remove repeated decisions in actual maintained parser code,
without another AST representation, cache or optimizer pass.

The retained Phase171 full caller capture observes `f_grow_base` in 42 of 952
parse/load active-context samples. The whole interval is 30.522s. This is a
selection signal, not an inclusive function cost: 514 contexts are unknown, and
a recorded dispatch context can outlive a direct call. The earlier separate
Phase171 capture saw 48 `f_grow_base` contexts. Phase162's older full-source
capture additionally saw 48/920 `f_prec` and 28/920 `f_grow_existing` contexts.
Do not pool the captures or turn these counts into a current seconds forecast.

Primary evidence:

- `selfhost/build/phase171/runtime-callers-full-stages01.json`, parse interval.
- [Phase171 frontend audit](../phase171/frontend-audit.md).
- [Phase162 parser work census proposal](../phase162/ours-frontend-boundaries.md).
- Current `selfhost/src/front/parser.bend:520`, `:538`, `:638`.

Current lexical source counts, **not dynamic execution counts**:

| Function | Repeated source sites |
|---|---|
| `f_prec` | 23 `f_eq` calls, a chain over operator spellings |
| `f_grow_base` | 17 `f_tx`, 11 `f_tl`, 16 `f_eq` calls |
| `f_grow_existing` | 7 `f_tx`, 5 `f_tl`, 6 `f_skip` calls |

`f_tl` constructs an `FInput` around the old context and remaining tokens;
`f_skip` may traverse a newline/semicolon prefix. Repeated spelling tests also
perform ordinary String/record ownership work. Existing helper specialization
may already remove some of this, which is why source counts cannot establish
the speed ceiling. Inspect the actual resulting QBE as a secondary explanation,
but judge complete loader time.

## Avoided repetitions of prior failed work

- Phase172's deferred pattern-row implementation preserved full values and QBE
  but had neutral hosted loader time. It is not reused here.
- Phase173's consuming materializer carried an empty-child shell and passed
  complete controls, but measured 67.553→68.174ms on the complete native loader.
  No new shell, materializer rewrite or full compiler image is proposed.
- Phase173's automatic decomposition improved selected computations but added
  2,035 lines and did not improve complete cold compilation. This experiment
  changes executed parser algorithms, not that optimizer's admission.
- Indexed parser name/constructor scope facts, Phase170 lexer suffix repair,
  current ASCII classification and native closed-selector lowering already exist.
  The experiment does not claim to introduce those capabilities.

## Experiment A: exact finite operator dispatch

Files:

- `selfhost/tests/phase175/parser-precedence-prelude.bend`
- `selfhost/tests/phase175/parser-precedence.bend`

Replace only `f_prec`; add four scalar helpers. Match the exact String length
and codepoints for the 23 existing operator spellings. An unrelated name or
delimiter returns zero after inspecting at most four codepoints and whether a
fifth cell exists. No lexer/token schema, diagnostics or operator meaning changes.
The source helper intentionally handles `>op` and `>>op`; bare `>` and `>>`
retain precedence zero. It preserves `. | .`-style operators without whitespace
(`.|.`, `.^.`, `.&.`), `<&>`, empty Strings, unknown spellings and Unicode.

Legality is a finite decision-table equivalence over String constructor shape.
All nonlisted strings map to zero. There are no callbacks, IO, mutable fields or
changes to argument evaluation. This is a source equivalence argument, not a
BendTT proof. Native branch layout and ownership costs may still negate the
reduced comparison count.

## Experiment B: compute parser lookahead once

Files:

- `selfhost/tests/phase175/parser-lookahead-prelude.bend`
- `selfhost/tests/phase175/parser-lookahead.bend`

Replace only `f_grow_base` and `f_grow_existing`. Keep the original `f_prec` for
the first independent comparison. A current token spelling is extracted once
per decision; newline skipping is done once; sign/bang lookahead obtains one
tail input, shared by its coordinate/text observations. The `>>` terminator
classifier receives one next spelling rather than repeating tail construction
for nine spelling comparisons. No new persistent parser view is introduced.

All unchanged parser transitions receive the original `n`, `ts`, `min`, or the
same `f_skip(ts)` as before. The final expression stops, call parsing, indexing,
bang adjacency, newline continuation, `%`/`-` adjacency and angle restrictions
remain separate. Early returns only skip pure total token access/classification;
they do not skip or reorder a parser call that could return a diagnostic.
`f_grow_base` still returns its exact error term/input immediately.

More helper functions may introduce transport/continuation costs. This is an
explicit failure hypothesis. If complete time is neutral, retain the evidence
and stop; do not acquire an image merely because fewer accessors appear in text.

## Gates and efficient execution order

`parser-controls.bend` is the same observation module for original, A, B and
(only if useful) A+B. Export:

- `p175p_prec_observe`: complete result list for every supported operator and
  rejected near miss, delimiters, names, Unicode, empty Strings and long words.
- `p175p_parser_observe`: complete `FParsed` values for precedence boundaries,
  newline/sign cases, adjacent/spaced/multiline bangs, indexing, nested angle
  syntax, all `>>` terminators, malformed/empty expressions and maximal minimum
  precedence. These are parser inputs; not all are well-typed Bend programs.
- `p175p_growth_boundaries`: exact error/empty-input preservation.

Insert the respective prelude laws before replacement definitions and append
the uniquely named helpers. The original helper declarations remain untouched;
new law fills use bare parameter names. All variants must include the same
observation module and independently pass upstream source checking. No passing
result is claimed by the file preparation.

1. Compare all complete values to the unchanged checked original. Do not use
   only `f_pn`, a candidate digest or successful/error status: remaining tokens,
   context, source spans and diagnostics are part of `FParsed`.
2. Reuse the retained Phase173 complete-loader controls as a first acquisition
   shortcut, then add a real operator-rich compiler closure with actual source
   and nested application/type syntax. Require complete `FLoadTrace` equality.
   Its prior 32-load nested-call workload alone underrepresents arithmetic and
   Boolean operator classification; do not treat it as the only coverage.
3. Screen A on the complete loader first. If substantial, compare native
   original/A through the **same current installed producer**, runtime and
   toolchain, consuming every output field. Then test B separately. Counter
   captures are optional after a clean signal, not a prerequisite campaign.
4. One small full compiler request must produce exact original QBE before any
   integration. Only a material complete-loader improvement justifies full
   compiler acquisition. Keep acquisition/pass cost, loaded program runtime and
   generated-code quality separate.

No justified 100s forecast follows. Even the entire historical parse/load
interval is only about 30s; these changes target a subset of it. The useful
question is whether a tiny, stable source simplification can remove actual
repeated parser work at low research cost.

## Other candidates, deferred rather than ignored

The same full parse profile contains `f_decl_local` 37 and `f_ctor_lookup` 32
active contexts. Current scopes already have declaration and constructor
indexes, but local-hit selection retains first-event list scans, while local
constructor collision checks can recursively scan the declaration book.
Replacing those scans with a dedicated current-file index could avoid more work,
but namespace aliases, laws/fills, incomplete datatypes and first depth-first
constructor selection must remain exact. A global-index hit is not authority
to return a local declaration. Start by counting actual visited local rows and
which existing indexed facts are insufficient, then test one complete local
declaration-publication path. Do not add an unsound global cache or repeat the
already selected parser-index optimization.
