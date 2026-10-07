# Phase64 typed facts: retain demanded signature work

Status: the isolated host-signature increment improves the focused B1 screen
by 1.37%. Discarded child-type reconstruction passes its differential oracle but
regresses the clean B1 screen and is rejected for selection. A separate candidate
removes discarded argument rendering. The source owner does not execute compiler
targets. No result establishes TypeScript parity or a 15–30% typed-pipeline gain.

## First prototype: one host-instantiated telescope

`jd_host` previously traversed the same host telescope three times: first to
find the result, then to build converted input arguments, then to build argument
copybacks. Each traversal weak-head normalizes and substitutes `Absent` for the
formal before continuing. The signature can be dependent, so reusing an
uninstantiated declaration telescope is incorrect.

The candidate adds `JDHostSignature{result, heads}`. It constructs this bundle
exactly where the existing result traversal was demanded, retaining each already
normalized head and the final result. Argument and copyback renderers replay
that saved list instead of normalizing and substituting it again. They still
perform their original conversions; no conversion is eagerly computed during
bundle construction.

The signature belongs to this one definition, this one immutable host context
and this exact arity. It is not indexed globally, attached to a user type, or
reused across contexts. Foreign IO uses a shadow book for its separate result
query and is unchanged. Raw public `jd_host_result`, `jd_host_args` and
`jd_host_back` remain available as the independent comparison oracle.

Preserved edge behavior:

- The result walk performs exactly `left + 1` normalizations, including a final
  normalization at zero remaining formals. It also keeps traversing a malformed
  non-All head through the original `j_app_type` behavior.
- Arguments stop at zero heads without another normalization. A premature
  non-All produces the same host-formal error fragment and stops.
- Copybacks also stop at zero; a premature non-All produces the original empty
  suffix. Erased formals do not consume a live argument index.
- Live-name generation remains before result traversal. Conversion order remains
  result, every input left-to-right, then every copyback left-to-right.
- Existing marshalling graph/depth/refusal budgets and strings are unchanged.

The patch changes only `selfhost/src/back/js/direct/host.bend`, adding 49 physical
lines and one private type. Its before/after snapshots and exact patch are in
[`typed-plan`](../../selfhost/tools/performance/phase64/typed-plan/host-signature.json).
After SHA256: `6432002e0c5313946984d9ed77c8c5cdf55e8c7faa15f7ea806a88cebf92a550`.
Independent source review found no contract violation; checking and execution
remain separate obligations.

The controller owner is deriving an append-only checked-image diagnostic. It
will compare each actual generated host wrapper to reconstruction with the old
helpers, compare the bundle's terminal result and both consumer strings, and
recompile complete modules with the prototype disabled. Real sources must
exercise dependent aliases, erased parameters, body-raised arity, recursive Nat
aggregates and host layouts. Synthetic zero/malformed telescope controls
supplement those programs. Fresh whole-request B1 measurements decide whether
the saved work exceeds the new small list/record allocation.

## Next scoped fact: raw live-formal summary

The declaration telescope used by `jd_live_arity` and `jd_params` follows raw
`kid(type,1)`; the host telescope substitutes Absent. These must remain distinct.
At its existing demand point, ordinary call analysis already computes both raw
arity and live arity. A separate candidate can retain that live count alongside
the existing arity fact, then produce parameter names with `jd_width_params` and
reuse the count for component widths and host wrapper arity. Native, foreign,
missing and public raw inputs keep their original path. No source edit for this
second candidate is included in the frozen host-signature prototype.

## Larger typed-pipeline question

Phase63's rejected application-spine prototype is a constraint: 389 exact local
comparisons passed, but replacing a small amount of normalization with shape
guards and temporary lists did not improve request time. Do not repeat that
experiment under a different name or treat a hit count as a gain.

The broader source survey identifies a real producer/consumer gap: `annotate`
computes `wnf(book,ty)` for `ka_node`, then wraps the result with the original type.
Later layout and lowering traversals normalize types and reconstruct matcher,
constructor and application facts again. Retaining normalized heads or layout
summaries may remove more work than a local signature cache, but its context
contract is harder: annotation's checked book and the canonical annotated
lowering overlay are different immutable books. Head-normal-form equality under
one does not authorize replay under the other.

The separate compact-annotation investigator is measuring the current Ann
allocation and generic-child access census. The host signature prototype keeps
annotations, so the investigations do not conflict. No checker/annotation or
layout source is changed here. A larger successor needs current State09 stage
costs and exact context/demand oracles before choosing whether to retain facts
in a compact annotation representation or combine layout validation with an
already-required typed traversal.

## Measured first increment

The root-owned [State02 versus State01 B1 screen](evidence/state02-vs01-b1-three.json)
passes 18 exact-output workers. Median compilation times are Numeric
375.49 → 370.17 ms (1.41% less), Lexer 777.75 → 763.04 ms (1.89% less), and
Map 1478.74 → 1467.02 ms (0.79% less). The equal-source geometric mean improves
1.37%; the separate import-plus-request clock improves 1.21%. These are the
screen's actual checked-B1 results, not a B2 or broad-catalog estimate. Retaining
the host telescope works locally but does not explain most remaining cost.

The selected State09 diagnostic stage survey locates the larger opportunity:
Map spends 349.65 ms in plan selection, 88.92 ms annotating, 53.29 ms checking
layouts, and 78.48 ms emitting the final plan. The instrumented compilation total
is 1184.5 ms; these observations must not be substituted for clean request
measurements. Source/CPU/allocation analysis implicates repeated substitution,
but shared generated SCC labels alone do not identify the executed operation.

## Second prototype: stop constructing discarded child types

The source survey found nine eager type derivations whose immediate child
consumer overrides the result with an existing annotation. This is a stronger
reuse boundary than transporting normalized facts between different books:
keep the actual annotated child, preserve its visit, and avoid only the parent
argument that the unchanged consumer discards.

Four small helpers cover direct lambda bodies, ordinary match arms, layout
lambda bodies and layout arms. They recognize only a direct `Ann`. Raw and Rwt
children retain the exact previous derivation. The candidate adds 26 physical
lines and no type, list, index or cache. Its exact source map and constraints are
in the [candidate README](../../selfhost/tools/performance/phase64/typed-plan/dead-child-types/README.md).
The patch SHA256 is
`2b3ec4c8d3c3670d7309df6a75ce743a08aff60a86835343d62284efdaa14eb2`.

The native numeric Word paths must retain their derived type because they strip
annotations before using it. Call-analysis Ann visits still charge their normal
fuel; fields 64/65, invalid-scan refusal and default-arm traversal are unchanged.
Layout still performs its open-array and constructor-count checks. The lambda
layout fallback retains unconditional substitution even for raw non-All types.

Independent review found no source-level blocker across the nine sites. The
proof scope is the unchanged annotated producer/consumer path: substitution may
beta-reduce on arbitrary raw terms, so we do not claim equivalence of divergence
on forged ill-typed annotations. No explicit refusal or error computation is
removed by these guards.

The diagnostic compares full enclosing JDText, JDCallScan and layout worklist
results, then compares complete module bytes with all four optimizations forced
off. Comparing helper type results would be the wrong oracle: those arguments
are intentionally discarded and can differ. Synthetic raw/Rwt, fuel and field
boundary controls supplement actual source compilation. Instrumented admission
and lexical query counters establish which derivations were avoided; clean
request measurements decide whether that avoided work has practical value.
The root-owned State04 [focused differential receipt](evidence/dead-child-types-state04.json)
passes both complete modules and 259 enclosing consumer comparisons. Map admits
2,976 skipped derivations with no fallback in these actual producer paths. Within
matched enclosing scopes, lexical substitution calls fall 143,189 → 110,612,
WNF 16,934 → 15,508, and arm-telescope reconstruction 2,412 → 12. Numeric admits
24 skips, with substitution 150 → 97. Synthetic raw/Rwt/non-All, fuel and
field-boundary controls pass. These are logical work counts from instrumentation,
not a percentage compiler-speed claim. The [State04 versus State03 clean B1 screen](evidence/state04-vs03-b1-three.json)
then rejects this version: 24 exact-output workers give Numeric +3.75%, Lexer
−3.06%, Map +6.58%, and an equal-source aggregate **2.34% slower**. Map's four
candidate samples (1531.4–1599.1 ms) are all slower than its baseline samples
(1438.7–1468.8 ms). B2 remains unmeasured for this ablation. Do not retain this
candidate merely because its logical counts improved.

Read-only generated-code inspection identifies a plausible added cost, not a
causal proof: the helpers introduce extra child/tag reads and trampoline paths.
The admitted arm helper returns an explicit `$JMP` to fetch the annotated type,
which the next consumer itself fetches again. An admitted helper could instead
return the already available parent type because it is discarded; that is only
a possible successor, not a measured fix. The next selected investigation is
whole discarded argument rendering, which adds no per-child shape guards.

## Third prototype: avoid rendering arguments twice

A second instance of discarded work appeared in the recursive tail-transfer
selector. It built complete argument JavaScript strings with `jd_arguments`,
then ignored every rendered value. It needed only the remaining actuals and
missing formal count before selecting the ordered transfer or regular emitter.
Both selected paths already render their own actuals.

The isolated 13-line candidate adds `jd_argument_shape`, keeping the exact
original telescope normalization/substitution and `rest/typ/missing` result
while omitting the unused expression strings and intermediate value lists.
The final consumer is unchanged. Public full argument emission is unchanged.
The [candidate and control documentation](../../selfhost/tools/performance/phase64/typed-plan/discarded-arguments/README.md)
records left-zero, empty, partial, overapplied, erased and malformed behavior.
The patch SHA256 is
`7186b6ea46318e912ab337dc57b93fab53a43d013357664c387498bbc0335ba5`.

This can save whole recursive expression-lowering walks, rather than a small
cached signature query. Its benefit depends on actual same-component call use;
it is not a blanket percentage claim. The append-only controller compares
projected raw argument metadata, full return JDText and complete generated
modules, and counts discarded rendering queries under the exact original
environment. Source review, checked construction and clean measurements remain
separate; no execution or speed result is claimed here yet.
