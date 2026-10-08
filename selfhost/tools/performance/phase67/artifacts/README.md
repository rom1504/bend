# Phase67 raw evidence

All raw writers are closed. `phase67-raw.tar.gz` contains every new Phase67 raw
file, including failed attempts, compiler snapshots, emitted code, executables,
process logs, fixed work plans and release checks. Every member was reread and
verified against the [manifest](manifest.json).

Extract into `selfhost/build/` to recover `phase67/`. The archive preserves
historical absolute paths; replay requires those paths or explicit path rebinding
with unchanged identities. Recipes name prior Phase66 evidence and external
Node/Bun/Lean/Clang tools as prerequisites; these are not duplicated here. See
the [Phase66 archive](../../phase66/artifacts/README.md) for historical inputs.

Installed-live baseline recipes are historical after promotion. Use explicit
immutable checked-image recipes for new experiments; do not overwrite old runs
or bypass a failed installed-release verification.

Files: 3956; uncompressed bytes: 191751940; archive bytes: 30990624.
