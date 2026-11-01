# One maintained compiler and research toolchain

Implementation of the [repository consolidation plan](../../design/repository-consolidation/README.md).
Started from `2a4f9f8383cbc66fadaedd9b4b27f83b93a13511` on
`selfhost/bootstrap`. This report is being completed with the integration gates.

## What is being consolidated

The maintained module tree replaces historical source composition. Its initial
QBE entry assembles to the exact qualified Phase146 source: 3,010,912 bytes,
SHA256 `96c40c9dd273e2fae5fabfe68093aa7fb8f25f075e2317bed06ff46d4feaab80`.
The same declarations supply JS and C entry profiles. Separate output backends,
runtime contracts and bootstrap generations remain explicit.

Build orchestration, semantic qualification, benchmark execution, diagnostics,
laws, profiling and historical recovery have maintained entry points. Algorithms
remain in Bend; host tools transport bytes, supervise processes and record evidence.
Historical reports and independent test inputs are evidence, not alternate active
implementations. Their original conclusions are not retroactively relabeled.

## Evidence collected so far

- `baseline.json` freezes the incumbent authorities and pre-existing dirty files.
- `source-checkpoint.json` records byte-exact modular extraction and protected
  declaration checks. Source maps retain declaration order and byte spans.
- An independently checked JS B1 API was acquired from the exact source in
  18.574 seconds, with 2.80 GB peak process-tree RSS. It is not a genuine B2.
- Three positive controls across direct JS, legacy JS and C produced nine raw
  products byte-identical to their corresponding incumbents. All 18 executions
  passed their complete-output oracles.
- The controlled type-error case was rejected by both producers on all three
  paths. It did not pass by crashing, timing out or producing a partial product.

The original numeric C execution attempt exposed a missing Clang include-path
argument in the harness. The full second attempt passed all positive controls but
used an overly narrow diagnostic predicate for the native C rejection. The third
attempt reran only that negative control with the exact source-backed diagnostic
contract. Both failed harness attempts remain recorded; neither was a compiler
semantic failure.

## Performance claims and boundaries

This is a source and workflow cleanup, not a new compiler optimization campaign.
Byte-identical emitted products preserve generated code in the measured controls.
No fresh corpus speed ratio or cold-build speedup follows from a file move.

Historical Phase144's approximately 247-second complete build and Phase146's
237.491-second compiler request have different boundaries and sources. They must
not be compared as a new improvement. Host, generation, emitted target,
preparation mode, machine construction and validation are recorded separately.

## Remaining integration gates

The final report will record native C/public CLI acquisition, JS derived-image
continuity, maintained tool smokes, source and artifact retirement, fresh-worktree
checks, selected capabilities and storage/source census. Installed selectors are
not changed merely because an acquisition succeeds.

## Historical retirement checkpoint

The first applied tranche removes56,800 exact Git-backed files from the working tree and retires826 additional index entries while preserving their working bytes. The planned logical total is5,500,736,880bytes. The compressed retirement receipt pins every preservation and the recovery baseline; no Git history was rewritten. Native CLI historical bindings remain pending until current-source replacement qualifies.
