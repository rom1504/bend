# Structured statement transport

This candidate replaces repeated whole-body text searches with a structured
statement document. The corrected text02 candidate passes its checked build and
36 build checks; focused qualification and measurement remain incomplete. This is not a
speedup claim. It addresses the Phase60 finding that emitted
reference/use frames exceed 5% of sampled allocation in eight sources, while
String frames do so in eighteen. Shared dispatcher names do not establish that
all those bytes belong to this mechanism.

The first private source is in
`selfhost/build/phase61/transport01/draft`. The installed compiler remains
unchanged until root qualification and release decisions. The earlier combined
Phase61 candidate01 excludes this transport change.

The first checked attempt, [text01](../../selfhost/build/phase61/checked-text01/attempt.json),
failed bootstrap parsing because `jd_text_prefix` matched a parameter inside
another parameter match. The [isolated successor](../../selfhost/build/phase61/transport02-parse-fix/source.json)
moves that match into `jd_text_prefix_char`; the failed source and patch remain
preserved. [Text02](../../selfhost/build/phase61/checked-text02/attempt.json)
passes in 62.007 s with 1.47 GiB peak RSS. Its transport source SHA256 is
`979d8abc08096fdbf3fa97388f1e1e3f1b2e8a532cb5950789a5fadf7f231bc6`.
These are build results, not full compiler-image or performance qualification.

The [first focused controller](../../selfhost/build/phase61/jdtext-controls01/report.json)
saved all 28 marker/demand/reference cases before reaching its 120 s deadline.
It did not save a completed skew/cap result, so the retained report is incomplete
and fails qualification. Its last checkpoint does not distinguish the cost of
the skew test from the first large raw cap test. Separate small/progress and
real-image cap successors are required; this timeout is not an observed value
mismatch and cannot be treated as a pass.

## What changes

`JDText` stores raw expression fragments and append nodes. A raw fragment has
its original String bytes, complete emitted USE/REF notes, a saturated code-point
count and a conservative safety bit. A join preserves left-to-right order without
rendering either child. Static emitter literals carry their checked literal size
and no metadata. They are internal source constants, not an arbitrary-text API.

Fifty-one existing String helper signatures remain wrappers. Their `jd_doc_*`
implementations compose documents through lambda binding, parallel Let bodies,
ordinary matches, shared Nat/Word rows, literal choices, tail transfers, shared
SCC entries and final definition assembly. The existing `JDOrdered` expression
printer, constructor folds, native templates and eta rules still produce raw
expression leaves. This is a bounded migration; expression-level Let demand and
some closure boundaries still render strings.

`jd_text_used` walks compact notes instead of searching the entire rendered
body for a local's marker. `jd_text_refs` visits notes in logical output order,
validates names against the existing reach-name map and preserves the first
occurrence/deduplication policy. `jd_reach_definition` therefore no longer needs
to render a complete definition and scan all its characters to discover edges.
The note adapter still scans each raw expression leaf once. No second KTerm
liveness or reachability traversal is introduced.

Render, demand queries and edge collection use explicit worklists so a skewed
append tree does not create a new native stack-depth requirement. Rendering
visits right-to-left and prepends each original leaf; concatenation is exact.
The existing public `jd_body`, `jd_match`, `jd_definition`, `jd_definitions` and
other String helper names retain their types. `jd_library_selected`,
`jd_library_context`, and the bootstrap split-emission policy do not change.
The independent batch-context hook remains in `jd_selected_context`.

## Proof boundary and fallback

Demand is still defined by the old emitted metadata. Only a demanded binding
lowers its RHS, including ordered prefixes. Erased inputs, row pruning, scalar
fragment refusal, closure capture and SCC member retention follow the existing
emitter decisions. This changes transport, not the program's order of effects,
coercions, exceptions, branches or tail transfers.

Metadata may cross a raw-leaf boundary. A leaf starting with a complete or
partial marker introducer, a truncated introducer after a newline, or a malformed
marker is conservatively unsafe. Safety combines through joins. Such a document
uses the original whole-rendered-string `String.contains` or `jd_reach_refs`
operation. Complete ordinary emitter markers remain inside safe leaves. The
fallback also preserves unusual physical metadata in foreign fragments rather
than assuming quoted/foreign text cannot contain it.

The original reachability cap is 2,097,152 code points. Each raw scanner counts
all consumed code points; joins add counts with saturation at 2,097,153. An
oversized document refuses exactly at the prior boundary. Safe reference notes
retain order, unknown names still refuse, and duplicate targets are charged once
per definition as before. Unsafe documents use the old parser, including its
malformed-marker behavior. No partial dependency result is accepted.

This additive size invariant relies on the emitter's chunk boundaries: static
syntax separates fragments, while expressions and quoted strings stay whole.
It does not cover arbitrary splitting between UTF-16 surrogate halves. Joining a
lone high-surrogate leaf and a lone low-surrogate leaf would merge two leaf code
points into one rendered code point. Focused controls split at code-point
boundaries; arbitrary malformed UTF-16 rope fragments are outside this internal
API contract.

## Required falsifiers

- Render equality for leaf and skewed joins, empty pieces, all marker split
  positions, malformed/unknown markers and the exact character-cap boundary.
- Demand equality against `String.contains(rendered, jd_use(id))`, including
  unused RHSs, captures, erased bindings and scalar Word-row refusal.
- Reference equality against the unchanged `jd_reach_refs`: order,
  deduplication, SCC members, malformed/unknown names and cap refusal.
- Exact program/module bytes through the existing compiler checks and ordinary
  semantic/numeric/composition controls. Expression ordering and native ABI
  behavior require no newly waived case.
- Compiler latency/allocation on the existing fast subset, then the broad
  population before promotion. New document/note allocation may outweigh removed
  text searches; no gain is assumed from the representation alone.

This applies the surveyed compilers' separation of emission structure from final
text without adding a pass framework or introducing unconsumed SSA machinery.
The remaining extension is to carry metadata through expression/native-template
substitution directly, once this statement-level migration has measured value.
