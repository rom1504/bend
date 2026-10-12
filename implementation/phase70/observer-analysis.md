# Observer analysis checkpoint

The checked Bend implementation recognizes the motivating `Map.bit.go` and
`String.cmp` traversals, plus independently written one-root and two-root
`Strand` traversals. These are analysis results, not generated-C correctness or
performance results. Production emission and installation remain pending.

Checked attempt `selfhost/build/phase70/observer-analysis04` passed its maintained
frontend selection in 32.61 seconds, peaking at 1,549,897,728 bytes tree RSS.
The B1 API SHA256 is
`8cc8afc0c93c1b736894960948ec0836dfc8401d98ac80eb12534d0ac36c0c4f`.
This image adds a diagnostic query export but does not route compilation through
the observer emitter.

| Actual Bend query | Accepted with diagnostic permission | Query time |
|---|---|---:|
| `Map.bit.go` | yes | 107.45 ms |
| `String.cmp` | yes | 17.98 ms |
| `strand:compare` | yes | 65.09 ms |
| `strand:probe` in its reachable program | yes | 61.32 ms |

Every corresponding False-permission query refused the optimization. These
single diagnostic clocks include different warmup states and are not compilation
throughput measurements. The True argument is supplied after checked entry for
analysis testing; production must additionally establish effect and bang safety.

The residuals retain ordered scalar operations and error paths, and replace
reconstruction with traversal of borrowed cursors. Map has four scalar operations
and one tail transition; String comparison has one operation and one transition.
Original owning roots remain in the separate proposed adapter. The independent
data audit in `observers-analysis/residual-audit01.json` checks scalar kinds,
descriptor owners, binder scope/freshness, loop slots, strict descent, and
exact-once wrapper roots/results for all four accepted plans. It does not replace
the source-level identity argument or runtime controls.

Raw evidence under `selfhost/build/phase70`:

- `observer-query01/report.json`: Map/String, SHA256
  `3aba3c9a47a45122cf9476c06b46dceb09c0ae35b19b35754fa30a513096f9ef`.
- `observer-query02/report.json`: two-root program, SHA256
  `7d5fb7fc840856d9c2baf66243615962371c8880a8f18977f5f4cfbbcc9c505d`.
- `observer-query03/report.json`: reachable one-root program, SHA256
  `55d4afcd4047de694e2e7f237bd345042da6c3e637bea61592a939dd7d60c7f3`.

Query02 also requested an imported but unreachable `strand:probe`; its definition
was not elaborated in that program and the analysis correctly refused its matcher
width. Query03 uses the program that actually checks and reaches that definition.
Production candidate discovery must use the checked runtime reachability set.

Preserved unsuccessful gates include analysis02 (missing affine sharing
annotations), analysis03 (missing local list annotation), and core06 (an input
changed while the query ran, detected by its final hash check). No failed gate is
reclassified as successful. The extra successor-overflow fixture initially missed
a Nat annotation and has not yet qualified as a runtime control.

The analysis/layout/bridge proposal is 834 lines, exceeding the initial estimate.
Its complexity must be justified by measured general gains; source recognition
alone does not warrant promotion.
