# Phase37 maintained-harness source review

This is a separate source-review pass by the agent that authored the additive
preparation changes. It is not an independent-person review or an executed test
result. Root executes the controls and records their results separately.

The inspected diff is limited to `programs/prepare.py`, `emit-worker.mjs` and
`freeze-reference.py`. The timing worker, rotation/summary logic, diagnostics and
historical catalog are unchanged. No blocker was found in the default behavior.

| Change | Compatibility and identity check |
|---|---|
| Optional `prepare.py --catalog` | Default is the same original catalog; source paths remain identical in that mode. Explicit catalogs resolve fixtures relative to their own directory. |
| Catalog-relative confinement | Absolute paths and `..` remain refused; every relative path component now also rejects symlinks. This deliberately strengthens the old leaf-symlink check. |
| Worker fourth argument | Optional, so direct three-argument callers retain the old catalog. Checked upstream/source/API/runtime/Base validation remains unchanged. The selected catalog is hashed before and after emission. |
| Preparation receipts | The selected catalog is copied into `consumed/catalog.json`, recorded by hash, passed explicitly to each emission, and rechecked at close. Existing source/compiler/verifier checks remain. |
| Reference packaging | Optional catalog argument reaches all fixture checks; default remains original. Full case-set agreement, source/point/module hashes, TypeScript pin/Base agreement and archive reopening remain. |

The five new source controls cover valid explicit roots, content tampering,
absolute/parent traversal, file symlinks and directory symlinks. The root reported
those controls passing before this review. Real checked acquisition of the added
fixtures provides the end-to-end custom-catalog path; synthetic path tests alone
would not establish that. The complete inherited Python/JavaScript harness
controls remain required before promotion.

## Integrity and metadata limitations

- Historical `family` fields in the derived catalog are case IDs. They must not
  be used to count distinct programs: scalar canaries share one source and pair/
  row share another. Report **45 points,23 source files,8 new application
  families**, and separately note the two additional algorithm-wrapper files.
  Correcting this metadata later would require a new catalog identity; it need
  not invalidate already bound measured points.
- The enlarged `broad` group means the ten new development application points.
  The historical catalog's `broad` remains unchanged. Always identify the catalog
  with the group name; do not compare unlike groups as identical suites.
- Named custom groups are selected through the read-only `catalog-cases.py`
  helper and existing `--cases`. Fixed argparse `--set` choices are unchanged.
- New ray expectations are checked pinned-TypeScript differential results, not
  an independent F32 oracle. The final catalog binds their receipt and preserves
  the draft-to-final derivation. Candidate output never sets its own expected
  result. Digest equality still permits collisions.
- Reference archives contain modules, preparation receipts, logs and consumed
  tools/catalog. They do **not** contain every Bend fixture source. The tracked
  exact fixtures beside the catalog are therefore part of the portable reference
  contract. Preserve versioned source bytes if a failed fixture is corrected.
- Absolute paths in provenance are historical identity records. Timed bundle
  module paths and catalog fixture paths remain relative, so ordinary execution
  does not require those historical absolute directories. The separate raw
  evidence capsule must retain any receipt that the report links.
- Explicit-catalog support does not recursively constrain all Bend imports.
  Existing checked acquisition records the compiler/Base identities, but the
  catalog only hashes its named fixture. Current catalog fixtures import the
  pinned `Base`; adding local imported modules later needs an explicit graph
  manifest rather than claiming current single-source hashing covers them.

No consumed acquisition tool was edited during this review.

## Remaining root-run controls and resource boundaries

Root already ran `execute.test.mjs` successfully in
`execution-worker-controls02`; the earlier sandbox `spawnSync` EPERM remains in
`execution-worker-controls01`. Use the new launcher for the remaining inherited
AST/profile controls and the full Python discovery, including the five new
catalog tests:

```sh
python3 selfhost/tools/performance/phase37/harness-controls.py \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --out selfhost/build/phase37/harness-controls01
```

Do **not** put this launcher under `phase32/bounded-run.py`: Python orchestration
tests invoke runners that acquire the shared campaign lock. The launcher already
uses `ExecutionGuard` with a distinct `selfhost/build/phase37/outer-tests.lock`, a2GiB tree cap,
a2GiB free-memory floor, CPU3 and120 seconds per sequential command. Root must
still reserve this complete job against other compiler/benchmark work. Add
`--include-execute` only for a complete reproduction when the earlier worker
receipt is not being reused.

The two direct Node control parents have explicit256MiB heaps; synthetic worker
children spawned by execution/profile controls have explicit128MiB heaps.
Python runner/diagnostic tests invoke their unchanged Node commands with explicit
1024MiB heaps and4MiB V8 stacks. `taskset -c3` on each top-level command is inherited
by descendants, and the Python runners also choose CPU3 from that restricted
affinity. `PROGRAMS_TEST_NODE` fixes the Node executable; neither `NODE_OPTIONS`
nor `NODE_PATH` is used to impose a limit, because supervisors deliberately clear
them. Python guard tests use isolated temporary locks and one intentionally
96MiB allocation to check a64MiB internal stop; the outer guard retains the2GiB
host safety floor throughout. Their deliberate deadline/signal/memory-stop
results are successful negative controls, not corpus benchmark failures.
