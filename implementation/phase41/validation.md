# Phase41 validation proposal and static checks

Prepared the [review recipe](../../design/phase41/validation.md) and one narrow
[derivation tool](../../selfhost/tools/performance/phase41/validation/derive-frontend.py).
No compiler, dist, previous phase tool, old raw evidence or frozen plan changed.
No conformance, owner acquisition, profiling or timing job was run.

Static validation: exact pinned parent derivation succeeded to
/tmp/phase41-validation-derivation-check; pinned Node24.18 --check passes on the
produced successor. Candidate workers change exactly1→2, reference remains4;
3026/196 selection and all exact comparator/provenance/health checks remain.
The successor refuses historical failed-candidate acquisition reuse, requires
exactly two explicit CPU IDs and at least5GiB initial available memory. Root must
use aggregate RSS3GiB and remaining-memory2GiB outer supervision and serial
main/broader runs. The derivative remains proposed until fresh root execution.

The current frontend main receipt is784.390seconds, broader37.354seconds.
No new elapsed improvement or safe completion at two workers is claimed.
Current owner-control receipts show under5seconds summed execution for counter,
foldV3, recognizers, unary, component and mandatory tail controls, excluding
acquisition/derivation and launcher overhead. A120second baseline diagnostic
compatibility preflight is feasible to attempt. Fresh-image preflight must count
fresh acquisition within its deadline; the old fold wrapper needs a narrow
reviewed extraction to avoid replaying its obsolete counter expectation. This
proposal intentionally leaves that extraction to root's integration decision.

Final admission still needs the existing semantic owners and reviewed closures,
exact selected-image bindings, canonical/source audit, expanded observations,
backend outcomes and installed CLI gates. The old auditor's gate hash must be
versioned intentionally; substituting a new script into its frozen plan breaks
provenance and is prohibited.

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
successful derivation check. No generated successor was executed. Fresh actual
list/Nat/linear-order, independent TS list, unadapted ray scalar precedence and
expanded154 command arrays match successful Phase40 receipt shapes. Generic
ATTTEMPT bindings remain unresolved until root selects a checked survivor.

The old compiler-cost planner cannot directly consume the new portable Phase41
archive: its retained-provenance schema/path is Phase39 specific. Root chose
four-source direct baseline acquisition from Phase40 checked06 rather than a
new archive framework. The recipe reflects that choice and maintains old raw
artifact identity. Fresh bindings verify both compiler images before costs.
