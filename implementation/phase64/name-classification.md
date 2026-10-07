# Phase64: fixed-name classification

This is a narrow, unapplied source proposal at handoff. No compiler, Node target,
benchmark or profiler was executed by this investigation. Root owns integration
and qualification; the installed compiler remains a separate decision.

## Evidence and scope

Fresh State09 allocation profiles identify two constant-table membership tests,
not the large primitive/effect classifier tables, as the immediate opportunity.
The [data-only attribution](../../selfhost/tools/performance/phase64/name-classification/attribution.json)
binds all three raw profiles and its reader. It independently reproduces the
measurement agent's nearest non-String generated caller attribution:

| Source | `jd_native_layout` | `j_layout_array_intrinsic` | Other `String.contains` |
| --- | ---: | ---: | ---: |
| Numeric | 0 B | 262,208 B | 0 B |
| Lexer | 262,200 B | 1,310,968 B | 142,912 B |
| Map | 9,701,216 B | 8,783,808 B | 786,592 B |

These are sampled bytes at `String.contains` shared-SCC leaves, assigned to their
nearest generated caller. They are not complete allocation totals, CPU weights
or a forecast of time saved. The selected two callers account for 18,485,024 B
of Map samples. The remaining caller is `jd_is_view`, which searches generated
expressions and is outside this fixed-name experiment.

The inherited [Phase6 membership attribution](../phase6/membership-attribution.md)
counts `has_name` list membership, including 1,279,499 reachability membership
cells. It neither implements nor rejects this constant-string classification
change. Historical Phase6 source, tools and evidence were read and preserved.

## Smallest source experiment

The [patch](../../selfhost/tools/performance/phase64/name-classification/candidate.patch)
adds one helper for seven native layout names and one for five Array operations.
Known members take equality tests. Unknown names without `|` return false;
names containing `|` use the original substring expression. The predicate's
existing tag and native-definition checks keep their source evaluation order.
The fallback uses `kc`: a Boolean expression alone would not ensure lazy fallback
evaluation in Bend.

The delimiter fallback is required for exact existing semantics. For example,
`Nat|Bool` and `Array.new|Array.set` match contiguous entries in the old tables.
Replacing substring membership with a plain set would reject them. For a name
without the delimiter, a match of `|name|` in these tables necessarily denotes
one complete entry. That establishes the formula equivalence for finite strings;
compiled-helper controls remain necessary to validate its implementation.

The patch deliberately leaves the large `j_intrinsic`, primitive and effect
tables, `j_printable`, general String primitives and `jd_is_view` unchanged.
Changing a general runtime primitive would introduce a larger ABI/semantics
question than the measured two-callsite opportunity requires.

## Fast controls and falsifiers

[Static controls](../../selfhost/tools/performance/phase64/name-classification/static-controls.json)
check the formula for 798 native-layout names and 1,437 Array-operation names.
They include every table substring, every contiguous sequence of entries,
nonadjacent/reversed/duplicate pairs, partial names, empty names, embedded pipes,
Unicode, control characters and a long unknown name. These are Python string
formula controls, not checked Bend or executable compiler evidence.

The [root-run diagnostic](../../selfhost/tools/performance/phase64/name-classification/compare.mjs)
requires a checked strict-exact attempt. It derives an append-only diagnostic API,
tests the actual compiled new helpers against the actual original compiled
`String.contains`, and cross-checks the deterministic corpus with host substring
semantics. It also checks each classifier invocation during Numeric and Map
compilation, then restores original membership functions and requires complete
emitted module equality. It verifies input identities before and after. Diagnostic
time must not be used as a speed sample.

The decisive performance screen is a separate fresh-process comparison using
unchanged raw-module oracles and the usual process-tree guard. Start with Map and
Numeric, then use Lexer as a held-out source before the broad compiler gate.
An unknown name still scans for a delimiter; a long unknown name can cost more
than the old short constant-table search. Equality chains also execute several
comparisons. Therefore reduced sampled allocations do not guarantee request gain.
Reject or revise if the fresh request regresses, exact outputs differ, native
ownership changes or the name-boundary controls fail.

The backend owner's dead-child-type patch touches different `validate.bend`
functions. Integrate using the narrow patch hunks; the captured whole-file hashes
in [proposal.json](../../selfhost/tools/performance/phase64/name-classification/proposal.json)
record the inspected source and are not a claim that another owner's valid,
nonoverlapping changes should be overwritten.

The backend owner independently reviewed the membership patch and found no source
blocker: the delimiter-free equivalence and identical delimiter fallback hold,
and the outer eager lookup remains unchanged. This review is not a checked build
or a substitute for the executable controls.

## Follow-up isolated hypothesis

Root requested a separate investigation of lazy tag guards. The current Bend
Boolean operands can evaluate lookup and classification even when a term is not
an ADT/Ref. Any guard patch is independent of this membership-only patch and must
establish the skipped computations are total and pure for its supported inputs.
No short-circuit guard is included in the membership patch.

The optional [guard-only patch](../../selfhost/tools/performance/phase64/name-classification/guard-only.patch)
retains original substring classification. Its
[guard-after-classifier counterpart](../../selfhost/tools/performance/phase64/name-classification/guard-after-classifier.patch)
composes with the membership helpers. Each introduces only an outer `kc` tag
guard, keeping lookup/native-flag evaluation before membership in the true arm.
Neither classifies before lookup nor short-circuits the remaining conjunction.

The supporting source argument is narrow: `core/term.bend:45`/`:57`/`:247`
exhaustively implement `tg`, `nm` and `db`; `lookup` at `:271` returns `missing()`
for a finite absent list and uses the existing index path when a BookCache is
present. `core/index.bend:71` follows finite child trees and `:126` scans finite
buckets. String membership terminates on finite strings. Thus skipping these
pure computations after a false tag cannot change the Boolean result on finite
well-typed values. This is not equivalence for forged cyclic host objects,
throwing JavaScript getters or resource exhaustion.

This is an established local compiler pattern: the [Phase10 loader experiment](../phase10/membership.md)
removed eager alias scans, and [Phase48 admission](../phase48/README.md) fenced
wrong shapes before normalization. The search found no previous experiment at
these two backend predicates; those historical successes supply no current gain
estimate. The unconsumed classifier diagnostic now reports each full predicate's
call count and rejected-tag count, separately for each real source. If rejected
tags are absent or rare, root should skip a guard build: added control flow can
cost more than it avoids. A surviving guard candidate still needs direct finite
KTerm/KLambda/KLiteral, missing-name, duplicate/native-shadowing and indexed-book
controls against the original full predicates before broader qualification.
