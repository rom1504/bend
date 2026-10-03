# Phase41 frontend validation outcome

Both fresh two-worker frontend gates pass on Phase41 checked01 API
`9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b`.
Exact agreement remains3,026 main +196 broader observations with zero behavior
or extra-field differences. Candidate workers are2; the attested reference
retains4. Main preserves2,525 pass /497 observed /4 shared failures; broader
preserves195 pass /1 observed. Both worker slots have zero timeouts/failures,
and both enclosing supervisors complete without resource stops.

| Scope | Historical Phase40 wall | Fresh Phase41 wall | Historical wall reduction | Phase41 peak tree RSS |
|---|---:|---:|---:|---:|
| Main |784.390s|413.647s|47.265% (370.743s)|1,175,924,736 bytes|
| Broader |37.354s|23.382s|37.405% (13.972s)|978,124,800 bytes|
| Serial total |821.743s|437.028s|46.817% (384.715s)|Scopes run separately|

This is a historical workflow comparison between different checked images:
Phase40 checked06 used one candidate worker on CPU3; Phase41 checked01 used two
on CPU3,4. It is not a controlled same-image worker A/B experiment and does not
establish a causal worker speedup, compiler throughput or generated-program
speed. The observed main gate saves about47% enclosing wall relative to the
historical run. Both fresh runs stay below the3GiB aggregate RSS ceiling and
above the2GiB available-memory floor; main minimum available memory is
27,917,000,704bytes and broader28,210,319,360bytes. No OOM or resource failure
is reported. The selected-image preinstall audit has since passed 14/14 gates;
installed verification and release checks remain postinstall work.

[Canonical receipt-derived statistics](validation.json) bind the exact reports
and execution hashes. Main [gate](../../selfhost/build/phase41/integration01/final-plan/frontend-main/report.json)
and [execution](../../selfhost/build/phase41/integration01/final-plan/run-frontend-main/run.json);
broader [gate](../../selfhost/build/phase41/integration01/final-plan/frontend-broader/report.json)
and [execution](../../selfhost/build/phase41/integration01/final-plan/run-frontend-broader/run.json).
Historical comparisons use Phase40 final-plan02's corresponding gate and
run-frontend receipts, which remain unchanged.


Prepared the [review recipe](../../design/phase41/validation.md) and one narrow
[derivation tool](../../selfhost/tools/performance/phase41/validation/derive-frontend.py).
No compiler, dist, previous phase tool, old raw evidence or frozen plan changed.
This validation owner ran static checks only; root subsequently ran the fresh
frontend gates described above.

Static validation: exact pinned parent derivation succeeded to
/tmp/phase41-validation-derivation-check; pinned Node24.18 --check passes on the
produced successor. Candidate workers change exactly1→2, reference remains4;
3026/196 selection and all exact comparator/provenance/health checks remain.
The successor refuses historical failed-candidate acquisition reuse, requires
exactly two explicit CPU IDs and at least5GiB initial available memory. Root must
use aggregate RSS3GiB and remaining-memory2GiB outer supervision and serial
main/broader runs. Root has now completed both fresh frontend runs successfully.

The current frontend main receipt is 784.390 seconds and broader is
37.354 seconds. The fresh observed enclosing-wall comparison is reported above;
it compares different images and does not isolate worker scheduling causally.
Focused counter, fold, unary, component, tail, and additional owner controls
were subsequently included in the selected-image preinstall closure below.

The selected-image preinstall audit now accepts the exact owner closures,
canonical-source binding, expanded observations, backend outcomes, and fresh
frontend receipts. Postinstall release installation, installed verification,
and 42 ordinary/relocated CLI checks remain pending. Measurement/regression
admission and independent release review are separate decisions. The old
auditor's gate hash remains versioned; its frozen plan provenance is preserved.

## Exact integration recipe successor

Added `validation/integration-recipe.json`, `validation/README.md`, and
`validation/derive-integration.py`. The recipe preserves standard Phase40
acquisition, owner mappings/closers and final installation while selecting only
reviewed current diagnostics. The fold wrapper successor keeps its three-role
emission and guard obligations and directly launches foldV3. Its exact pinned
parent SHA is51bd2646c5a08d784b0ae216e06441ed791cb4a8e5d556cd5170e0fc18629426.
The derived auditor pins Phase37 parent
808068f34159c1e9979914a469a46ba52a18f2cb4194ec47cc117d059226516a,
changes frontend candidate slots/config/result count to2, and requires successful
3GiB RSS /2GiB free-memory /1200second outer receipts at both plan scope paths,
as well as frontend derivation lineage. All other semantic/audit checks remain.

Both generators and emitted Python successors parse with AST; emitted frontend
passes pinned Node syntax. `/tmp/phase41-integration-static02` records the cheap
successful derivation check. At preparation time no generated successor was
executed; root has subsequently run both frontend successors. The selected-image
preinstall auditor passes 14/14 gates; postinstall is still pending. Fresh
actual list/Nat/linear-order, independent TS list, unadapted ray scalar precedence,
and expanded154 command arrays match successful Phase40 receipt shapes. Generic
ATTEMPT now binds checked01 API
9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b
for the observed frontend results.

The old compiler-cost planner cannot directly consume the new portable Phase41
archive: its retained-provenance schema/path is Phase39 specific. Root chose
four-source direct baseline acquisition from Phase40 checked06 rather than a
new archive framework. The recipe reflects that choice and maintains old raw
artifact identity. Fresh bindings verify both compiler images before costs.
