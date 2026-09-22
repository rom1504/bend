# Compiler experiment ledger

This ledger records decisions and links evidence; it does not replace the reports.
Read [workflow](README.md) and [current strategy](STEERING.md) before a new investigation.
User objective: make the Bend compiler written in Bend and its validation loop much faster while preserving correctness. The current authorized optimization window ends about 20:16 UTC on 2026-09-22.

## Migration checkpoint — 2026-09-22, 17:13 UTC

The file workflow is adopted during Phase 4 in response to the user's `rom1504/math` suggestion. These records summarize already completed or active experiments; they were not preregistered. Existing designs, detailed reports and raw evidence stay in place. Earlier phases remain indexed by their reports rather than being retroactively relabeled as this wave.

| ID | Experiment | Decision at checkpoint |
| --- | --- | --- |
| [P4-001](phase4/P4-001-private-calls.md) | Private compiler calling convention | Accepted |
| [P4-002](phase4/P4-002-indexed-book.md) | Indexed final-definition selection | Accepted |
| [P4-003](phase4/P4-003-telescope-facts.md) | Reuse substitution-invariant telescope suffixes | Accepted |
| [P4-004](phase4/P4-004-projection-layout.md) | Projection copies and direct child access | Deferred |
| [P4-005](phase4/P4-005-normalization-shortcut.md) | All/ADT weak-head shortcut | Rejected |
| [P4-006](phase4/P4-006-tag-comparisons.md) | Direct private tag comparisons | Rejected |
| [P4-007](phase4/P4-007-nullary-sharing.md) | Share private nullary values | Deferred |
| [P4-008](phase4/P4-008-native-flags.md) | Native PGO and compiler flags | Deferred |
| [P4-009](phase4/P4-009-stability-memo.md) | Memoize completed private stability facts | Pending |
| [P4-010](phase4/P4-010-wnf-pair-memo.md) | Memoize private weak-head normalization | Rejected |
| [P4-011](phase4/P4-011-ordinary-uncurry.md) | Flatten ordinary partial-call chains | Rejected |
| [P4-012](phase4/P4-012-boolean-matchers.md) | Specialize exact private Boolean matchers | Pending |
| [P4-013](phase4/P4-013-edit-loop.md) | Checked B1 rebuild and persistent focused validation | Accepted |
| [P4-014](phase4/P4-014-full-profile.md) | Full-source inspector sampling | Rejected |

“Accepted” means the stated implementation/boundary is supported by the linked gates, not complete language conformance or a universal speedup. “Rejected” includes valid transformations that did not help; it does not necessarily mean semantically incorrect. “Pending” is not promoted.

### Updated frontier

The combined source has completed checked self-reproduction: both H stages have SHA `b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`. Full frontend observations remain unchanged, with 560 existing differences from pinned TypeScript. The actual focused developer loop is already seconds rather than a full-build iteration.

Prioritize a controlled full-source private-image comparison and the reviewed Boolean/stability combination. Keep the unchanged control image. Do not revisit weak-head memoization, direct tag comparisons or ordinary-function uncurrying without explicitly overcoming their recorded obstruction. Native O2 is a proven useful full-source lane; PGO setup is a separate amortization decision. Large term-layout migration remains an open research direction, not an inferred requirement.

Next wave must use the current [strategy](STEERING.md), specify the quickest falsifying check, and preserve exact output and resource evidence before promotion. Update this frontier after each material decision; preserve the older entry as history.

## Full-source private-image counterexample — 2026-09-22

[P4-016](phase4/P4-016-private-lexical-scope.md) records a lexical-scope bug found
by the whole-source gate. The canonical private image completed checking but
failed emission with `F is not defined`. Specialized workers had been
hoisted out of their generated helper-table blocks. The 602-second failed run
is retained and provides no successful-compilation speedup. The public compiler's
fixed point and earlier scoped observations remain valid.

The new small comparison passes all 54 observations, with successful B1 requests
7.6%/12.8% faster. A negative-case regression is retained; a separate five-round
confirmation finds a smaller 4.9% request regression, with all 15 exact outcomes.
See [the complete comparison](../implementation/phase4/small-comparison.md).

### Updated frontier

Correct the private lexical-scope transformation first, using a tiny reproducer
and independent review, then issue new image identities and repeat the affected
full-source gate. Other prototypes remain experimental. Do not multiply their
standalone gains: the four-way Boolean/stability comparison already shows
interactions and run variation. The exact Con-arm pilot
[P4-015](phase4/P4-015-exact-con-arms.md) is rejected for inconsistent material
benefit; retain its proof and measurements without escalating to a full build.

## Private scope correction — 2026-09-22

The fix for [P4-016](phase4/P4-016-private-lexical-scope.md) is independently
reviewed. Only proven module-level generated functions can be hoisted; captured
workers use the original closure. Twenty-five package tests and fourteen actual
split-worker controls pass. The escaped-string fixture's actual output equals
public H byte for byte. The new private image is `61e7d94c…`; its full-source
request is running under the original resource limits.

### Updated frontier

Complete that full-source gate and regenerate the Boolean/stability comparison
on the corrected base. The original four-way results remain scoped historical
evidence. Prioritize exact final-image frontend observations once the candidate
is chosen. Archive principal checked artifacts so later investigations can start
from verified bytes without repeating an eleven-minute emission solely to
recover their starting image.
