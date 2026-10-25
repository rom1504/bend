# Phase141: a measured deletion budget

The best bounded replacement is the duplicated top-declaration parser. Keep the
Phase140 stop-aware parser as the sole implementation, preserve ordinary parser
entry signatures with two small adapters, and remove the old internal SCC. This
removes a real second algorithm implementation. It does not remove a language
feature or merely move tests out of the line count.

This is a read-only source audit of HEAD `0b6957a`, followed by an **unchecked**
19-line adapter proposal. No compiler target, native build or performance campaign
ran in this task. The qualified Phase137 source and Phase140 prototype remain
untouched.

## What the source sizes actually count

The canonical [census04 report](../../selfhost/build/phase141/census04/report.json)
pins both exact compiler sources, every inspected module, root authorities and the
inventory method. The two declaration inventories provide names, source lines,
category, provenance matches and dependency edges. Counts include type and law
signatures; “code lines” excludes blank and comment-only lines.

| Measure | Qualified Phase137 | Experimental Phase140 |
|---|---:|---:|
| Physical source lines | 58,569 | 64,408 |
| Nonblank/noncomment lines | 42,433 | 46,808 |
| Top-level declarations, including laws | 7,291 | 8,012 |
| Production/API/proof reachable code lines | 38,046 | 41,187 |
| Exclusively control/fixture reachable code lines | 2,413 | 3,430 |
| Other code lines, **not proved dead** | 1,973 | 2,190 |
| Native `main` closure code lines | 25,045 | 28,131 |
| Code lines with matching module declaration text | 31,600 | 35,975 |

The category totals omit the one `import Base` line. Phase140 adds 5,839 physical
and 4,375 code lines: 3,141 production/API/proof closure lines, 1,017 exclusively
control lines and 217 other lines under this conservative inventory. Calling all
5,839 lines production complexity would overstate the increase. Calling all
non-native code dead would be a much larger error.

The current maintained `selfhost/src/compiler.json` lists 132 modules containing
32,702 physical/26,702 code lines. That manifest is **not the whole qualified QBE
compiler**: the qualified image also incorporates later experimental modules and
source transformations. The inventory also examines 921 bounded Bend source files
under Phase111–137 and the 46 selected Phase140 modules. Those historical files
are provenance candidates, not 921 active production modules.

Matching preserves indentation and strips only blank/comment-only lines and
trailing whitespace. An exact declaration match is stronger evidence than a phase
prefix. Remaining assembly markers are explicitly labelled `marker-only`; later
overrides can leave a misleading original marker. About 10.8k code lines do not
have a normalized current-module match in this bounded scan. The report does not
pretend their complete historical provenance has been reconstructed.

## Roots and limits of the audit

The dependency graph includes lexical references in signatures and bodies,
first-class function references, constructor-to-type edges, and both declarations
when a law and definition share a name. It retains:

- All 108 current typed-driver export roots, including conditional backend APIs.
- Actual selected checked-API exports, with explicit fixture exports classified
  separately using their source modules and finite-control protocol.
- `main`, all protected verifier/entry declarations, and the 11 proof-connected
  usage-summary declarations.
- Every body reached by those roots, including fallback paths.

This is a conservative lexical audit, not a checked semantic reachability proof.
Binder/name collisions can create extra edges. Introspection and historical host
scripts can refer to names outside current published roots. No “unreached” row is
permission to delete it; complete source checking, API inventory, historical
fixture preservation and appropriate output gates remain necessary.

The first provisional census recognized only `List<Bool>` control entries; actual
finite controls mostly return `List<String>`. Census02 corrected that and census04
also includes helper declarations in explicit controls modules. Census01/02/03 are
retained as superseded audit evidence; census04 also correctly masks character
literals, so a literal `'#'` cannot hide a real dependency as if it began a comment.
That correction conservatively adds 56 code lines to each production closure.
**Use census04**, not the initial zero-control classification. The final method reads and lexes each input once and traverses
hash-indexed graphs; no quadratic source-pair comparison or target execution.

## The concrete parser replacement

[clone-v02.json](../../selfhost/tools/performance/phase140/parser/clone-v02.json)
records the mechanical derivation of the 34-function parser SCC. The original
functions have 19 separate laws, so each implementation occupies 53 declarations:

| Implementation | Code lines | Physical declaration lines |
|---|---:|---:|
| Original `f_*` SCC | 419 | 535 |
| Retained `p140p_*` stop-aware SCC | 440 | 526 |

The derivative only renames SCC calls, threads one `U32` stop cursor, changes the
result from `FRawResult` to `P140PStop`, wraps `f_result`, and adds a pre-`f_top`
stop branch. The independent reviewer replayed the inverse change across all 34
bodies and laws; no additional expression change was found.

Only two old names cross the SCC boundary:

| Retained entry | Actual external callers in source18 |
|---|---|
| `f_tops` | `f_header_next`, `f_body_header` |
| `f_top` | `p140p_seed_stopped`, `p140p_resume_lexed`, `p140p_before_stopped` |

The new stop-aware entry `p140p_tops` also has two outside callers:
`p140p_seed_tokens` and `p140p_before_tokens`. All remain unchanged.

[core-v01.bend](../../selfhost/tools/performance/phase141/parser/core-v01.bend)
contains just three definitions: old `f_tops`/`f_top` signatures call the matching
stop-aware entry with stop zero, then `p141p_raw` unwraps `P140PDone`. The original
laws for both public compatibility entries remain byte-for-byte intact. A defensive
`P140PCut` arm resumes all five saved parser fields at stop zero; it does not invent
a diagnostic or discard accumulated source context. The only cut constructor gate
requires `stop > 0`, so ordinary calls cannot take it.

[deletion-v01.json](../../selfhost/tools/performance/phase141/parser/deletion-v01.json)
pins every before-body, the two preserved laws, all retained stop-aware bodies,
the 32 names to retire, the actual callers and the unchecked adapter module.
Delete 32 definitions plus 17 laws: **49 declarations, 505 physical/397 code
lines**. Replacing the two 12-line original bodies and adding the 19-line complete
adapter module gives an approximately **498-physical-line net reduction** before
final assembly whitespace is measured. Root subsequently composed source01 and
reported **501 physical/393 code lines removed**; source checking is separate. This is roughly 0.8% of the full prototype,
not a claim of 50% compiler simplification.

There are two risks to check early:

1. The source checker must accept compatibility calls to later stop-aware
   declarations; `@unsafe` is not a substitute for correct declaration ordering.
2. Six parser entries cross an eight-argument optimization threshold after adding
   the stop argument: `context_law_open`, `def_body`, `def_prior`, `law_where`,
   `type_ctor_header`, `type_ctors`. Some private QBE worker routes cap arity at
   eight. Constant stop zero is not evidence that this overhead disappears.

The smallest decisive gate is complete raw `FRawResult` equality, including
partial books and structured errors, for ordinary and resumed parsing. Include
unsafe-before-law/type/EOF, imports after definitions, law fill/duplicates/aliases,
nonzero source origins, Unicode spans and checkpoint lookahead rejection. Then
measure ordinary native parsing and a full request before adopting the deletion.
The source, scope, freshness, checker and cache-admission algorithms do not change.

## Alternatives ranked by credible deletion value

| Candidate | Defensible scale | Assessment |
|---|---:|---|
| Unify the two top-parser SCCs | About 498 physical lines net | Best immediate bounded replacement; exact mechanical correspondence and narrow interface. |
| Separate embedded tests from production composition | At least 2,413/3,430 code lines for the two images | Useful build organization, **not a reduction in maintained test or algorithm complexity**. Retain every control in a checked test image. Measure self-compilation benefit independently. |
| Retire unreachable old helper fragments | 1,973/2,190 code lines is only an upper audit pool | Fragmented across many small routines and historical control adapters; requires per-interface retirement evidence. No single proved 500–3,000-line obsolete production subsystem found. |
| Fold identical tiny helper bodies | 127/157 duplicate-body code-line ceiling | Low return. Largest exact renamed-body duplicate is only 12 lines. Contracts, first-class identities and source laws still matter. |
| Remove legacy JS, JS IR or C backend | Large apparent count | **Rejected as simple deletion:** current CLI exposes `--legacy-js`, direct JS and C/native modes; typed-driver has explicit native preparation fallbacks. Would remove supported behavior or require a real compatibility implementation. |
| Remove old QBE collectors/registry routines wholesale | No established material budget | Streaming emitter still calls shared ordinary/private renderers and fallback paths; current APIs explicitly expose both collected and cursor forms. Consolidate only after a real dependency/interface proof. |

The parser consolidation is a useful first successful deletion, not the whole
simplicity strategy. After it passes, the next audit should target a second actual
shared algorithm boundary, rather than count all phase-prefixed functions as
obsolete or create a universal IR merely to shrink the headline.

## Can the whole compiler become 10,000 lines?

Not through an honest deletion-only campaign demonstrated by this audit. The
qualified source has 58,569 physical but 42,433 code lines; Phase140 has 64,408
physical and 46,808 code lines. Removing all blank/comment-only lines accounts for
16,136/17,600 physical lines, but discards useful explanations and barely changes
the implementation context. Moving control-only declarations to test composition
accounts for another 3,139/4,458 physical lines, but retains the same tests and
maintenance obligations elsewhere. These savings are not additive to code-line
savings because physical declaration slices include their whitespace.

The qualified image has 681 separate laws occupying 3,681 code/5,045 physical
lines, and 273 type declarations occupying 705 code lines. Some signature
presentation could become more compact, but deleting laws or types would remove
checking information or require an equivalent replacement. Even the unrealistic
operation of discarding *all* comments/whitespace, exclusively embedded controls
and every separate law leaves **36,339 code lines** in Phase137. The analogous
Phase140 remainder is **39,516**. A 10k target therefore needs removal or much
more compact expression of roughly three quarters of real implementation, not
another cleanup of test names and phase prefixes.

The 135 original maintained modules alone contain these code-line budgets:

| Responsibility | Maintained code lines | Why it is not automatically deletable |
|---|---:|---|
| Core terms, indexes, normalization, graphs, pretty printing | 2,698 | Shared language and diagnostic behavior. |
| Checking, environments, specialization, prefix state, annotation | 2,717 | Affinity, dependent checking and prepared-Base semantics. |
| Frontend, contextual parsing, elaboration, sugar, freshening | 3,562 | Actual language surface and stable identities/spans. |
| Loading/imports plus diagnostics and driver | 2,047 | Public file, import, error and interpretation behavior. |
| Shared/legacy JS facilities | 6,357 | Includes genuine optimization/analysis shared by later backends; explicit legacy interface remains public. |
| JS IR and direct JS | 4,040 | Two representations and public code-generation interfaces; a replacement must preserve them. |
| Native/shared C-oriented lowering | 4,997 | Much remains the analysis/lowering foundation of QBE, not merely a discarded C printer. |
| Backend-common helpers | 284 | Shared literals, arities and native facts. |

These are **original-module budgets**, not exact separable portions of the current
qualified image; later overrides and QBE additions sit on top. They demonstrate
why silently deleting an entire backend is an invalid explanation of “50k lines
that could disappear.”

There are three credible paths to substantially less context:

1. **Consolidate implementations of the same contract.** The parser is now a
   proved source-correspondence example. Repeat only where dataflow/interface
   evidence finds another duplicate. This can remove hundreds or low thousands
   of real lines without rewriting the compiler; this audit does not yet establish
   a 10k-line total outcome.
2. **Use one semantic optimization representation across complete computations.**
   A verified region carrying ownership, typed products, calls and continuations
   could replace multiple independent analyses/recognizers. This is the only
   plausible source of many thousands of algorithmic lines while preserving all
   targets. However, its deletion budget must name the old passes actually
   replaced; layering another IR above them would increase complexity. No such
   replacement is implemented or measured by this census.
3. **Make the maintained active source boundary explicit.** A canonical semantic
   module composition, distinct checked control composition, and small subsystem
   contracts can greatly reduce the context needed for a task even when total
   functionality remains large. Current maintained modules plus hundreds of
   historical experiment files make that boundary harder to see. Archiving
   history or splitting files improves navigation, not total algorithmic line
   count, and should be reported separately.

Generic visitors and callback-heavy abstraction can shorten source while making
this affine native compiler slower. Earlier safe-summary experiments already
showed that closure-based source simplification can obstruct private worker
lowering. Any larger consolidation should therefore have the same gates as this
parser experiment: remove the old algorithm, preserve exact interfaces/semantics,
count full replacement overhead, and check ordinary/native cost before adoption.

For this three-hour cycle, the right scope is one complete parser consolidation
plus an evidence-driven second candidate if time allows. A 10k total should remain
an architectural research target until a concrete representation replaces—not
merely hides—the distinct optimization and backend responsibilities above.
