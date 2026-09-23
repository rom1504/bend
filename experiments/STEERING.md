# Current compiler experiment strategy

Evidence checkpoint: 2026-09-23T03:21:31+00:00. Authorized campaign window:
2026-09-22 21:39:36 to 2026-09-23 03:39:36 UTC.

The default is consolidated, validated and pushed on `selfhost/bootstrap`.
Run it through the ordinary CLI; rebuild with `npm run build` from `selfhost/`.
The [compiler guide](../docs/BEND-IN-BEND.md),
[Phase 5 report](../implementation/phase5/report.md) and
[Phase 6 opening report](../implementation/phase6/report.md) separate the release
from isolated candidates.

## Established position

- Released API: maintained equality derivative `e2b5463678a2…`, genuine checked
  parent `5969c53d34a0…`, source `e3b927d13dc2…`. The manifest verifies current
  source/host/runtime and transformation replay; the derivative has no fabricated
  bootstrap sidecar. Default interpreter, JS, native and relocation controls pass.
- Complete frontend: 919/919 positive fixtures; strict check failures 377→318;
  exact live differences 560→444; status/phase differences 50→16. No lost exact
  observations on the pinned inventory. Text differences are not all cosmetic.
- Controlled final complete-source means: TS 60.248s, checked B1 642.581s,
  released derivative 363.392s. The derivative is 6.03× TS under the documented
  workflow/cache policy. Small Phase 6 pilot gains do not update that ratio.
- Genuine checked B1→H→H produced identical H bytes `5043267732f5…`.
  H and derivative each reproduce all 2,756 final B1 frontend observations.
- Broad paired JS/native coverage: 3,962 observations, stable inputs, no missing
  rows. Bend has 1,423 strict passes, 315 negative diagnostic/phase failures,
  242 N/A and one positive native timeout. Complete coverage is not a pass.
- Production source remains 59 modules / 16,509 physical lines (+2.83%).
  Duplicate filter/Nat helpers were removed; the compiler as a whole grew.

## Ranked frontier

| Rank | Next change | Cheapest decisive falsifier | State |
| --- | --- | --- | --- |
| 1 | Prefix precedence and erased names | `+f(1)` versus `(+f)(1)`, `+U32`, erased invalid name, valid neighbors and first error | Erased guard promising; marked-name candidate rejected for regression; no promotion. |
| 2 | Explicit Boolean source workers | Actual-H positional controls and exact core output; then separate H timing and broader gates | B1 small-core ABBA passes both ≥5% request/process thresholds; not a whole-source result. |
| 3 | Declared missing-import failure | Tagged ENOENT only, preserved span and competing malformed-body error | Read-only design covers ten current phase differences; no exact-diagnostic gain claimed. |
| 4 | Scalar native constructor fields | Emit-only 32/64/128 size scaling, then ownership/order/actual native execution | Static 255-field witness shows quadratic continuation saves and a real timeout. |
| 5 | Shared exact checked facts / typed lowering | Instrument duplicate visits, bounded component candidate with malformed/dependent controls | Designed; no implementation or gain yet. Largest plausible route beyond small hot-path gains. |

Also repair the confirmed multiline-string cursor/excerpt defect as a separate
checked change. Preserve the new `+U32` counterexample outside the pinned suite.
Do not turn all 428 text-only frontend differences into a generic formatting task.

## Correctness and promotion

Pinned upstream stays unchanged. Preserve failed attempts and exact provenance.
Generic rejection does not count as exact conformance. Keep compiler timings,
user-program runtime, output size, profile samples and proof-stage walls distinct.
Derived images are not new bootstrap or fixed-point proofs.

Use the maintained checked build/validate/release workflow. Compiler source edits
require fresh checked artifacts; fixture-only validation may reuse frozen attempts.
A combined promoted source requires full frontend checking, affected actual
backend execution and final checked self-reproduction. New candidates stay outside
the default until those gates finish. Current broad evidence uses final05's frozen
pre-native-exit-fix host; the separately tested host fix binds the installed release.

## Resources and stopping rules

Root owns integration, scheduling, Git and final reporting. Short correctness
jobs use separate cores; no intentional compiler/archive jobs compete with a
controlled timing window. Every experimental process has a finite deadline and
must close its worker history. Do not repeat a failed benchmark just to replace
its result. Rejected general memoization/uncurrying experiments need a new concrete
mechanism before reopening. Stop new experiments at the authorized boundary;
retain unfinished gates as unfinished. No new six-hour campaign is inferred.
