# Discovery evidence

`summary.json` records the matched one-pair compiler result and archive hash.
`manifest.json` lists every archived file and hash. `discovery01.tar.xz` contains
the experimental compiler source/recipes, checked API, generated C, native image,
and the selected raw guard logs and results. Archive paths are repository-relative
under `selfhost/build/phase99/`.

This is an experimental evidence bundle, not an installed release or a standalone
toolchain. It depends on the repository's existing pinned Phase98/upstream assets.
The installed native selection is unchanged. The duplicate candidate self C and
the baseline's different C are omitted; their hashes remain in the receipts and
the candidate's exact C is included as `combined-discovery02/program.c`.

Read [the report](../discovery-restart.md) for scope, timing limits and the
deferred release checks. The preparation and execution methods are tracked under
`selfhost/tools/performance/phase99/`.
