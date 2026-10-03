# Phase41 validation derivation review

Static review of `selfhost/tools/performance/phase41/validation/derive-frontend.py`,
`derive-integration.py`, their pinned parents, generated `integration01`
derivatives, and the integration recipe. No gate, build, or other heavy job was
run by this reviewer.

No blocker found in the requested areas. The frontend derivation pins the exact
Phase40 gate SHA, applies occurrence-counted edits for the explicit two-CPU
affinity, fresh-candidate requirement, two-job config/command, candidate worker
count, and Phase41 report kind. The selected case counts, reference worker count,
comparison policy, behavioral field set, source/layout assertions, and oracle
paths are untouched. It checks 5 GiB available before launch; the recipe uses
the 1,200-second outer supervisor with a 3 GiB process-tree RSS cap and 2 GiB
available-memory floor. The derived auditor requires successful bounded
receipts, enforces those exact bounds and observed peaks, and binds the derived
gate path, explicit affinity, run producer, candidate API, worker count and
case count back to the plan.

The integration derivation pins the Phase37 auditor and Phase35 fold wrapper,
retains the original wrapper, and changes only the selected current fold
control, owner label/config lineage, two-worker audit assertions, and
environment-specific parent paths. The derived fold wrapper still performs the
same three checked emissions under its internal `ExecutionGuard`; it invokes
Phase40 `fold-controls-v3.mjs` for fold assertions and the unchanged Phase35
fold guard control. Its hashed input list includes the original wrapper,
derivation metadata, selected Phase40 control and control manifest. The recipe
preserves the standard final plan and owner-close path while mapping only the
current fold receipts.

The root reports both derivations succeeded into `integration01`; the frontend
gate itself remains pending. That is root-run derivation evidence, not an
independent execution result or a gate pass. The frontend audit remains the
required next evidence before integration closure.
