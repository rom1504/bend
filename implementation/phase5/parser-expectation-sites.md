# Explicit parser expectations (P5-019)

The candidate makes 45 of 167 selected upstream parse diagnostics exactly match
the live pinned compiler, preserving all eight previously exact results and all
acceptance/phase/checked classifications. Nine changed diagnostics remain
mismatches. The original strict unchanged-or-exact gate therefore remains failed;
root approved promotion only after explicit review of a presentation criterion.
This is not a claim to repair the underlying parser gaps.

The genuine checked candidate API is
`2a5a27486323d66803c8af2567831c2b6533f7e2d1c9b57ad4dfd540d2105a6d`,
source `ba9824526beef2aea789d3a4a7ea6f365c86e917188dacfe613297bb04e509ba`.
It derives from the checked P5-022 API `4da20a0d…`. The frozen 167-case P5-022
baseline was reused only after checking exact API, runtime, host and selection
identities; the candidate was run against a fresh live pinned reference.

Three frontend files change. Existing rejection branches now provide explicit
expected text for non-reserved term tokens/forbidden semicolons, normal top-level
declarations and late imports, non-leading template clauses, missing do `<`, and
missing foreign opening quotes. Reserved words and unknown decorators keep their
old paths because the reference consumes them differently. Wrong-extension foreign
paths retain the old error because their reference cursor is after the closing
quote. A shared `fpe_legacy` constructor preserves the exact original fallback
string, including the formerly unpositioned foreign-path message. There is no
legacy-English parsing, grammar change, reparsing, or successful-path rendering.

The 26 focused controls produced 14 newly exact diagnostics and three changed
residuals. Two top-level cases expose a source-context difference: TypeScript's
loader blanks leading imports before rendering, while this renderer retains the
original source. A comment-separated law clause still selects the old later
term error. The broad 167 gate produced 45 newly exact, 113 unchanged and nine
changed residuals, with zero previously exact results lost. Those nine are
`cost/array_fill_readback`, `parse/dead_lambda_syntax`, `parse/if_no_else`,
`reg/framed_cell_capture`, `run/array_bounds_000`, `run/array_bounds_001`,
`run/array_slab`, `run/array_struct_swap`, and `spec/comp_mint_dedupe` (all `.bend`).
They retain existing parser-state differences even with better structured text.

The original failed reports, full before/after/reference supplement, and source
identities are under `selfhost/build/phase5/parser-expectations`. The preregistered
[experiment and amendment](../../experiments/phase5/P5-019-parser-expectation-sites.md)
distinguish the stricter failed gate from the reviewed presentation criterion.
Root and compact_index reviewed source-local expected text, demand/error order
and fallback boundaries before authorizing guarded promotion; see the
[independent scoped review](frontend-presentation-review.md). The exact checked hunks were promoted with full original-file SHA guards,
preserving P5-018/P5-016; see the [promotion patch](../../experiments/phase5/P5-019-parser-expectation-sites.patch).
New production SHAs are parser `8daa5d7c…`, declarations `8b177021…` and sugar
`b8bdca5c…`. The integration manifest
`selfhost/tests/frontend/phase5-parser-expectations/cases.json` has 14 exact negative
diagnostic oracles and 12 explicit acceptance/phase-only controls; all 26
statuses/phases agree with the live reference. A fresh combined checked build
is a separate root-owned gate. No compiler or heavy archival job ran during
the controlled timing window.

After the timing hold, the isolated P5-022 baseline and P5-019 candidate also
returned exactly equal raw results for pinned Base, the frozen P5-022 compiler
source (13,421,696 serialized bytes), and list_sort. Isolated high/low-surrogate
inputs raised the same exceptions. This is a raw frontend equality check, not a
claim that the final combined compiler source has already completed its proof.

The [immutable evidence archive](parser-expectation-evidence/manifest.json)
retains 3,876 file identities in 2,913 verified gzip objects (4,051,216 compressed
bytes), including both original failed strict gates and the raw equality result.
The [promotion source archive](parser-expectation-promotion-sources/manifest.json)
retains the exact before/after production bytes (seven objects, 23,046 compressed
bytes), including the independently composed P5-018/P5-016 changes.

A separate [current-composition raw supplement](parser-expectation-combined-evidence/manifest.json)
then compared genuine integration04 and integration05 APIs: Base, list_sort and
the frozen integration04 compiler raw results are exact, with identical malformed
UTF-16 exceptions. It retains 147 identities in 85 objects (769,213 compressed
bytes). See the [final frontend comparison](final-conformance.md) for the full
combined source, rather than attributing all integrated improvements to P5-019.
