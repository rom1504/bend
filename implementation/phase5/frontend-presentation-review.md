# Independent review of P5-019 and P5-022

Reviewer: compact_index. This is a source and retained-observation review, not an additional compiler run. Production sources and frozen benchmark inputs were not changed during the review.

## P5-019: explicit expectations at existing rejection sites

Reviewed `selfhost/build/phase5/parser-expectations/attempt-02/overlay.patch` and the owner's retained 167-negative result and presentation supplement. The patch changes existing error branches in `parser.bend`, `declarations.bend` and `sugar.bend`; it does not change their successful parse branches. `fpe_error` delegates to `fpe_legacy` with the same already formatted fallback and explicit expected/token fields. The new repeated reserved-word check occurs only after the original name branch has rejected. Foreign quoted paths with wrong extensions retain the legacy fallback because the upstream cursor follows the closing quote; `@` and reserved-word cases likewise retain their known cursor limitations.

The renderer's existing source/token and Unicode guards remain responsible for refusing unsupported metadata. No new first-error selection or accepted-path traversal was found. This review covers typed frontend inputs; it is not a guarantee for arbitrary malformed JavaScript objects pretending to be token records.

The reported broad gate has 45 newly exact diagnostics, 113 unchanged rows and nine changed residual mismatches, with no classification changes and none of the eight previously exact rows lost. Those nine residuals are not repaired merely by presenting the existing Bend error more faithfully. The original stronger unchanged-or-newly-exact gate remains a recorded failure. Scoped decision: **GO for the explicit presentation change**, subject to the owner's retained gates and combined-source validation, not a claim of full diagnostic parity.

## P5-022: preserve the selected embedded error's source and metadata

Reviewed the source-aware graph-result wrapper and its helper file, plus baseline/candidate negative rows and `faithful-rendering-review.json` under `selfhost/build/phase5/embedded-errors/`. The wrapper first obtains the unchanged authoritative graph result. Earlier graph errors return unchanged; successful results return without a new book scan. Only a rejected validation result triggers the search in the same definition/type/value/constructor order used by the existing error selection, including its empty-name-error behavior.

The selected error's legacy text must match before rendering. Its declaration index is mapped through chronological definition counts, including seeded definitions; ambiguous duplicate canonical source paths fall back. Freshening and accepted output books are unchanged. The seed, trace and diagnostic entry points use the same source-aware wrapper. No blocker was found in the reviewed declaration-count/source mapping, while the owner's seeded/unseeded and imported-source controls remain the empirical gate.

An actual earlier integration witness retained an `Error` node inside `statement_lam_absorb` with expected `'}'`, token `':'`, line 25 and column 5. The original matcher already produced structured metadata; later extraction of the error name discarded it. This supports fixing the rejection transport rather than adding a redundant matcher-specific tag or changing successful parsing.

Of 167 broad negative rows, classifications are unchanged and all seven formerly exact rows remain exact. `undo_residual_lane` becomes exact. The two changed array rows still disagree with upstream: Bend selects an expected-`]`/observed-`:` error at its existing position, whereas upstream selects an earlier expected-`^` error. Formatting the same chosen Bend error faithfully does not fix that parser/error-order divergence. `statement_lam_absorb` becomes exact in the separate focused gate.

Scoped decision: **GO for rejection-only faithful rendering**, retaining the failed original unchanged-or-newly-exact gate and explicitly revising the criterion to faithful facts, unchanged classifications and no loss of earlier exact results. Restricting the renderer to matcher tags solely to hide the array residuals would obscure the known underlying discrepancy. Neither this review nor the revised criterion establishes full conformance.

The owner preserves the consumed patches, raw reports and failed original gates in the P5-019/P5-022 experiment and implementation archives; historical build paths above identify the reviewed observations.
