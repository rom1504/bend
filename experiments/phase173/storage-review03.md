# Phase173 retired API/source storage review

This third proposal adds **112.5546875 MiB raw allocated** across 40 exact files
in 22 retired experimental roots. Nothing was archived, compressed, deleted, or
executed as a compiler target. The first two proposals remain unchanged.

| Category | Selected files | Allocated MiB |
| --- | ---: | ---: |
| Fourteen obsolete source snapshots | `compiler.bend` and `manifest.json` in each root | 74.66015625 |
| Six obsolete hosted APIs | `api.mjs` in each root | 19.34765625 |
| Two completed verifier witness sets | Three value JSON files in each root | 18.546875 |
| **Additional tranche** | **40 files** | **112.5546875** |

Combined with the separate 46.66796875 MiB assembly/object proposal02, this is
**159.22265625 MiB raw**, assuming none has already been applied. Actual net
recovery is smaller and is unmeasured. This does not promise 150–300 MiB net.

The exact list, current hashes/inodes, provenance pins, classifications and
protected dependency closure are in
[storage-proposal03.json](storage-proposal03.json). It is a review proposal, **not
an executable archive or prune plan**.

## What can move into exact archival storage

The fourteen source roots are `vertical-base-source01`, `store-source01` through
`store-source04`, `store-source06`, `store-flat7-source01`,
`store-direct-source01`, `scc-source01` through `scc-source03`,
`scc-diagnostic-source01`, `abi-source01` and `abi-source02`. Only their explicitly
listed compiler source and full manifest are selected. Their small exports and
binding descriptors remain hot. Archived source is preserved scientific evidence;
it is not being treated as disposable code.

The six API roots are `store-api06`, `store-flat7-api01`, `store-direct-api01`,
`scc-api03`, `scc-diagnostic-api01` and `abi-api02`. Only each `api.mjs` is selected.
Their original reports and diagnostics remain hot.

The two optional witness roots are `store-flat7-verifier01` and
`store-direct-verifier01`. Each selection is exactly
`complete-input-values.json`, `baseline-complete-values.json` and
`candidate-complete-values.json`. Their completed verification reports remain hot;
detailed historical replay requires restoring the archived witness bytes.

All selected leaves are exclusive regular files without extended attributes.
Fresh hashes match original artifact pins where those exist. Each source
snapshot manifest declares a complete metadata-only write; its compiler source
identity also agrees with the terminal API receipt. These source snapshots did
not have a guarded compiler writer, and this review does not invent one. Their
associated guarded API readers are sealed/completed or sealed/failed, as recorded.
Failed acquisition remains failed. Successful API and witness writers are
sealed/completed with successful guards.

## Active dependency checks

The protection seed includes every current `dispatch-*`, `plan-*` and `borrow-*`
root, each `abi-*03` root, `vertical-base-api02`, `vertical-base-source02` and
`store-native-candidate-source02`. Every direct file in these roots is protected.
The review then follows existing Phase173 path references transitively through
bounded JSON receipts. At the recorded snapshot this traversed 851 files and
protected 855 files. A separate scan covered 180 current manifests,
build/native/profiler methods and Phase173 test sources. No selected file belongs
to the protected closure or has an exact literal use in that method scope.

This caught two non-obvious dependencies that must **remain hot**:

- `store-api05` and `store-source05` are still referenced by active receipts.
- The complete value files under `store-verifier-controls01` are inputs to the
  selected `store-native-candidate-source02` manifest. The generic checked-plan
  capture/replay chain depends on that selected source, so those value files were
  explicitly excluded.

All ABI03, dispatch01/02, checked-plan capture/replay and their inputs remain hot.
All borrow artifacts, including older borrow APIs and new AST/digest experiments,
remain hot. Every program binary and retained/source IR remains hot, as do runtime
objects, profiles, qualified chains, native oracle source roots, timing/output
oracles, original API/control reports, guard/retention records, and all unlisted
files. The shared lock is untouched.

The closure is conservative for the known current workflow, not a prediction of
future experiment choices. A root coordinator choosing to revive one of the
retired APIs must restore its exact source/API leaves first. Recheck current
bindings and active requests immediately before any capture.

## Capture compatibility and required safeguards

The existing `experiments/phase169/archive-selected-v02.py` cannot apply this
proposal: it deliberately accepts only `program.ssa`, `program.s` and `program.o`
and requires successful original writers. The `close.py` CLI also cannot reopen
already sealed runs. Do not change old lifecycle records or relax those checks.

A small, separately reviewed exact-file capture adapter can reuse the maintained
`close.py` capsule implementation and unchanged `archive-v02.py`
verification/apply/restore functions. Its scope must be the proposal's exact
leaves, with one root processed at a time. It must authenticate this proposal,
writer/reader terminal evidence, current bytes/modes/inodes and the active
protected set before writing a capsule. Full source manifests must be captured
byte-exactly; preserving only their hashes is insufficient.

Retain terminal API/control receipts and the compact review outside the selected
leaves. Define capsule metadata honestly: `archive-v02.py` automatically protects
paths named in fields such as `writersClosed`. If a selected snapshot manifest is
placed there, accept the resulting protection rather than suppressing a refusal.
The original complete manifest can itself be a reviewed archived member, while
its terminal API reader receipt and compact source identity remain available.

Require a **5 GiB reserve plus an explicit 32 MiB archive scratch bound per root**.
Serialize with the sole execution lane. Reopen and hash every member, verify
original files stayed unchanged, and let the unchanged maintained verifier produce
an exact file-level prune plan. Root must inspect the selected list before apply.
No directory removal, implicit extension expansion, or age rule is needed.
Preserve the capsule, original closures, exact recovery location and measured
apply receipt. Stop on changed identities, new dependencies or reserve failure.

The agent implemented no adapter and generated no archive/prune plan. This
proposal provides the additional safe candidates and the dependency evidence;
root decides whether the small amount of added capture machinery is justified by
the prospective build's actual disk budget.
