# Scalar catalogue hoisting: scoped opportunity, not selected

Decision: **do not implement another adapter chain yet**. Existing evidence
establishes repeated work but does not establish native hotness or a gain large
enough to justify copying another schema orchestration path. No compiler code
or benchmark was changed for this investigation.

The selected Phase137 source has this ordinary schema route:

`no_schema` → `nol_params` → `nol_param_head` / `nol_param_type` →
`nol_result` → original `nol_wrap` → `nol_finish`.

`nol_finish` (line 36828 in the selected source) computes the original failure
reason, then appends `nol_scalar_specs(book,book)` only when that reason is
empty. The catalogue depends on the request book and is identical across such
successful calls. Phase140 `late/core-v03` already computes and retains exactly
that catalogue once per initial observer scan for invalidation.

A private variant of the six schema/telescope functions could carry that value
to `nol_finish`, while leaving normalization, wrapping, admission, diagnostics,
fresh counters and analysis unchanged. One small observer wrapper would route
cache misses through it. This looks like roughly 60–80 additional Bend lines,
plus threading the value through the existing late scan. The value would be
consumed only in the same successful branch; ordinary failure behavior must not
change. This is a feasible seam, not an implemented transformation.

There is also a separate nested-schema path: `p128br_plan` first tries the
ordinary schema, then `p128bl_schema`; successful `p128bl_finish` (line 55850)
also appends `nol_scalar_specs(book,book)`. The small ordinary adapter would
not remove that work. Reusing a previously successful schema during retry does
not itself reconstruct the catalogue; actual call paths must be counted.

The retained complete QBE from `session-screen03` provides a narrow lower
bound on successful observer work:

| Program | Retained borrowed reader definitions |
|---|---|
| Lexer | 0 |
| Map churn | 3: `p37.map.string`, `String.cmp`, `Map.bit.go` |

These names were decoded from the actual numeric `p113d_FID_…` symbols. Map's
three readers require successful schemas through the ordinary or nested paths;
they do not prove three ordinary-adapter opportunities. Lexer having no
retained reader does not prove zero successful schemas: analysis, admission,
later composition or dead-code removal can discard them. Nor does a retained
reader count reveal how often the same owner was reconsidered.

The small receipts record 30 initial candidate misses for cold Lexer and 54
for cold Map. Those are candidate counts, not successful schema counts. The
receipts do not retain every intermediate schema or time catalogue construction
separately. Consequently no native speedup estimate is warranted yet.

Evidence identities:

- `selfhost/build/phase140/session-screen03/lexer-fresh-a.ssa`:
  577,297 bytes, SHA-256
  `d7f319ddfe98e211951e305d692fa0190f4c2ade7cf0beb998a5e88ae7f13559`.
- `selfhost/build/phase140/session-screen03/coverage-map-churn-128-fresh-a.ssa`:
  1,028,294 bytes, SHA-256
  `37fd22e781e93290c2ab661c06f1991d57542f58e90d983890cebff6f7ef24e5`.
- `selfhost/build/phase140/session-screen03/report.json` binds the actual
  candidate API, requests and independently compared complete outputs.

The cheapest useful follow-up is to count ordinary successful schema finishes,
nested successful schema finishes and catalogue time separately on one real
compiler request, including cold acquisition and warm misses. If that identifies
a material native cost, pass the existing immutable catalogue explicitly and
compare complete schemas/plans, error order and final QBE. Otherwise keep the
current code simpler and pursue a measured larger cost.
