# Phase195 first experimental checkpoint

This is an intermediate result, not compiler qualification or a parity claim.
The maintained and installed compiler selections are unchanged. The frozen
Phase194 native45 result remains 1.971034× mature Bend C runtime. Experiments
below use that exact compiler's programs as freshly timed references.

## What changed our priorities

Fresh physical profiles resolve actual hot executable symbols rather than
assuming a similarly named fallback is hot. Editdist spends 98.02% in the
99-row `p113d` product-row owner; the larger 167-row `p117v` owner is cold.
The latter's 59 potentially regional locals therefore do not price the hot
optimization opportunity. The hot owner has only two such locals.

An offline allocator replay reproduces all original 32 candidate names and
colors. Raising the candidate cap alone admits only three additional hot
homes. Register pressure is more important: nine physical allocation colors
face a peak of thirteen represented live values. The eleven-color experiment
therefore tests explicit RCX clobber constraints and canonical stack-held state
to release R12, with separate final coloring validation. It is not yet measured.

## Completed experiments

| Experiment | Result | Decision |
| --- | --- | --- |
| Selection-aware placement | Hot row 77→74 instructions, 20→19 frame accesses; no useful runtime gain | Reject standalone |
| Larger joint-allocation admission | Large ray functions lose regional reuse and increase stack traffic; ray runtime 1.00147× baseline | Reject standalone |
| Physical compare/select emission | Hot row 77→65 instructions, frame accesses unchanged at20; editdist 1.00730× and local-pair 1.02320× baseline | Reject standalone |
| Certified constant-table calls lowered to loads | Ray64 runtime 0.729539× baseline, 1.85714× C; all six development outputs pass | Retain for composition and broader evaluation |
| Borrowed tree traversal with owned result escape | Fixture runtime 0.404514× unique / 0.409837× shared baseline | Investigate actual-source admission; no general compiler transformation yet |

The table experiment's six-case geometric ratio is 0.946039× the paired
baseline. This is a partial development screen, not the 44-case runtime score.
It removes calls to the same canonical constant tables already recognized by
the QBE path. Every emitted table matches its QBE counterpart; five tables
occupy360 bytes. The caller's static body grows, illustrating why standalone
instruction counts are insufficient.

The ownership fixture has four balanced timing rounds, 20,000 iterations and
depth8: 353.60→143.04 ns per unique search and353.71→144.97 ns per shared search.
All candidate searches take the guarded fast route. The independent observer
passes360 observations on each hot/cold × direct/rendered product. An earlier
cold observer incorrectly shared raw children; its failure is preserved and
the versioned correction constructs a valid published graph. Raw unique fields
still exercise the original fallback. This is finite evidence, not a theorem.

## Evidence and next gates

The checked source parents, exact artifact identities, independent oracles and
balanced raw timings are retained under `selfhost/build/phase195/`. Key receipts:

- `physical-table-runtime01/report.json` and the committed
  [screen summary](physical-table-screen01.md).
- `profile-priority02/report.json`, `profile-remaining02/report.json`, and
  [profile analysis](../../research/phase195/profiles/remaining-findings.md).
- `ownership-controls02/report.json`, `ownership-timing01/report.json`.
- `hybrid-checked-controls02/report.json`: eighteen data assertions pass;
  six ordinary development programs also pass their independent outputs.
- `sqrt-controls01/report.json`: finite runtime compatibility controls pass;
  ordinary product emission was interrupted by the disk guard, not wrong code.

Pending experiments are the eleven-color allocator, incoming copy facts across
branches, integer selection inside floating regions, and actual-source
admission for an owned-result observer. Use small semantic controls, machine
inspection and balanced development timing before any full self-build. Preserve
heldout cases and require independent native qualification before promotion.

## Resource interruption

Two target runs stopped because filesystem-wide consumption exceeded their
disk budgets while their declared output roots remained small. `sqrt-dev-emit01`
used1.87 MiB in its root against40.02 MiB filesystem decrease;
`pool-api01` used20 KiB against96.18 MiB decrease in3.66s. Both failed receipts
remain retained. Subsequent external growth crossed the5 GiB reserve, so no
further target jobs are admitted until space is recovered. The guard and
installed compiler were not changed. Verified archival cleanup is tracked
separately from compiler improvement.
