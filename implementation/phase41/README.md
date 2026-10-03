# Phase41 interim campaign report

Status: in progress from 2026-10-03 16:39:33 UTC. **The installed compiler
remains Phase40 checked06.** A checked Phase41 source patch has passed its
checked build and focused tree wrapper controls, but Phase41 has not completed
integration or final admission. The upstream pin remains `018751270e800bc222a93dad7f257083ee53a5f7`.

See the [campaign design](../../design/phase41/README.md), [prospective
experiments](../../experiments/phase41/), and the [interim tree results](results.md)
with canonical values and raw receipt identities in [results.json](results.json).
The tree report is explicitly `final: false`; it describes checked emission and
a supplemental three-point screen, not a release or broad catalog result.

The checked Phase41 tree wrapper passed 124 actual-emission oracles and 17
boundary checks, including the deep-tree case. Its screen medians were 1.40–1.45×
faster than fresh Phase40 output on those three points, while remaining 11.2–15.4×
slower than pinned TypeScript. The observed interval from checked job start to
screen finish was 202.652 seconds. Full tree integration, source review, and
remaining admission gates are pending.

Other experiment decisions:

- **Private transfer tuples:** reject source integration. The corrected controls
  passed; the two-point screen shifts were only +0.23% and +0.40% versus noise,
  with overlapping samples. See [P41-001](../../experiments/phase41/P41-001-transfer-tuples.md).
- **Lexer host ownership:** defer. The String host-hook counterexample shows
  that the existing scalar guard is insufficient for a private String region.
  See [P41-003](../../experiments/phase41/P41-003-lexer-host.md).
- **Frontend validation:** the focused counter, fold, and unary preflight passed
  in 37.264 seconds of recorded tool intervals. The independent new fixture and
  the complete validation/integration gates are still pending. See
  [P41-004](../../experiments/phase41/P41-004-frontend-two-workers.md).

The root owns the active campaign ledger and final accounting cutoff. Interim
elapsed figures use recorded intervals; unclassified wall time is not attributed
to agent effort or model latency. No final performance, release, or admission
claim is made at this checkpoint.
