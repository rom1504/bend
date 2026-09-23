# Embedded parser diagnostics (P5-022)

The source-aware loader now renders the parser Error it already selected, even
when that Error was nested under a local body. This closes the composition gap
exposed by `flatten/statement_lam_absorb`. It does not choose an earlier error,
repair the remaining array grammar differences, or rescan accepted books.

Baseline: genuine integration03 API
`8cfa124d7567f8840941fcfdcce79a5b9a18caac406c9a3db89c31720e7d6e06`,
source `1c1f0d46bf3b3bfa357470749a1925d5eff950bc20b5b6db7798c193dfeaf9ab`.
The isolated checked candidate is API
`4da20a0d61ac7c8cc4a78659eb53cce35d27201314cdec09ae28d46abe2fa045`,
source `7a88b41050afd0e15d7003ab7f7c8c3d86259f2ed650e3c4405f68cdf8548b61`.
Its bootstrap and consumed-input records are under
`selfhost/build/phase5/embedded-errors/attempt-01`.

After the existing `f_graph_result` returns a nonempty error, a second traversal
follows precisely the existing type/value/constructor/next-definition error order.
It retains the actual Error and its top-level declaration index. Reversed Loaded
event counts identify the source module, including a seeded Base prefix and empty
modules. The Error name must equal the authoritative selected error. A unique
canonical source path supplies the original text to the existing formatter;
missing or duplicate source records preserve the old text. Pre-existing graph
errors keep priority. The accepted branch performs no additional book traversal.
The normal, traced, seeded and provenance-loader entry points share this wrapper.
Legacy standalone elaboration without source text can still return legacy text.

The original **unchanged-or-exact gate failed** and is retained unchanged. Root
and independent review explicitly approved a narrower presentation claim after
inspecting the counterexamples:

| 167-case fresh comparison | Result |
| --- | --- |
| Newly exact | `check/undo_residual_lane.bend` |
| Changed but still divergent | `parse/array_key_range.bend`, `parse/duplicate_buffer_key.bend` |
| Unchanged | 164 |
| Previously exact observations lost | 0 of 7 |
| Acceptance/phase/checked changes | 0 |

The two array cases already selected `expected ]; got :` at line 10, columns 13
and 8. The candidate renders the same expectation, character and position with
the source excerpt. TypeScript instead expects `^` at an earlier comma. Entire
raw parse results are equal before/after; each contains exactly one matching
Error, and its expected/token metadata and actual source character were checked.
These remain parser/first-error mismatches, not repairs. The revised criterion
requires faithful rendering and no new exact failures. It does not retroactively
turn the failed original gate into a pass or hide either residual behind special
matcher tags.

Additional differential controls passed: 33 focused cases required unchanged
baseline behavior or an exact live-reference repair, with nine newly exact
diagnostics (including the separate `statement_lam_absorb` case). This is not 33
claims of cross-compiler agreement: the missing-import control retains the old
Bend load-phase/ENOENT result while TypeScript reports a parse-phase diagnostic.
Seven actual
loader controls covering ordinary/traced/seeded results, source ambiguity and
import precedence; 16 direct checked-function controls for error ordering,
empty-name Error handling, nested constructor ownership and module boundaries;
and complete raw-result equality for Base, the frozen compiler and list_sort,
plus identical malformed UTF-16 throws. Existing function bodies were only
exposed through appended test exports for the ordering probe. No generated body
was rewritten. No performance claim is made.

Root approved guarded promotion after the
[independent scoped review](frontend-presentation-review.md). The graph's P5-020 starting SHA
`ef8b93ca6822f3bf5e0696ba4166967bc10557f14fa357f88105753c31dbac6b`
and freshness expression were explicitly checked and preserved; seed and
diagnostic modules were checked against their frozen baseline before copying.
The new graph SHA is
`05c9030572a608241d0974b58976addbd200287cc3c21359dd3c9aa1c07274ac`.
The [promotion patch](../../experiments/phase5/P5-022-embedded-parser-errors.patch)
and [preregistered design/amendment](../../experiments/phase5/P5-022-embedded-parser-errors.md)
make the scope and changed gate reviewable. Combined integration and final
self-host proof remain separate root-owned gates.

Integration fixtures are in
`selfhost/tests/frontend/phase5-embedded-parser/cases.json`: the original 18 exact
diagnostic oracles and 15 acceptance/phase-only controls are retained. Combined04
correctly exposed the pre-existing missing-import phase gap as a selected failure
(361/362 selected observations agreed). The explicit `confirmed-cases.json` subset
excludes only that residual, leaving 32 cases; the original oracle and failed
combined run were not rewritten. `missing-import-phase-gap.json` records exact
frozen baseline/candidate identity and the differing reference.

The [main archive](embedded-parser-evidence/manifest.json) preserves 5,397 file
identities in 3,775 verified gzip objects (4,790,478 compressed bytes), including
the original failed strict comparison. The [promotion before-sources](embedded-parser-promotion-sources/manifest.json)
retain the guarded P5-020 composition. The [later missing-import supplement](embedded-parser-late-evidence/manifest.json)
is preserved separately (13 identities, nine objects, 13,025 compressed bytes);
it does not amend historical reports. No compiler or archival workload ran during the controlled hold.
