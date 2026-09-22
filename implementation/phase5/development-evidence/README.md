# Focused development-workflow evidence

`raw.tar.gz` preserves the actual checked/equality attempts, frozen compiler
source/runtime/host/API files, bootstrap and derivation reports, Base caches,
selected harness reports and worker histories, logs, focused test source, and
final maintained tool source. `manifest.json` gives every stored path, byte size
and SHA-256. `archive.py` is the metadata-only creation and read-back audit recipe;
it refuses existing outputs and never runs a compiler.

Archive: 4,516,760 bytes; SHA-256
`36446dbe52059ba6aab971dc72b78206dfc6542804796f01cc83ee8aa845b6d7`.
Every actual compressed member was reopened and verified against the manifest.
Extract into a new directory, never over a live checkout. Files use repository-
relative paths; report contents retain their original absolute identities.
Relocation does not create new checked provenance or automatically make old
replay commands valid. Exact replay requires the recorded canonical paths,
Node binary and pinned upstream checkout; those external prerequisites are
identified but not bundled.

The final equality workflow retains its consumed launcher source directly in
`equality-01/launcher/` and its frozen project under `snapshot/`. The earlier
checked build also retains its actual initial frozen wrapper. Intermediate
`reuse-01`/`execution-01` record launcher hashes but predate automatic launcher
source copying: their exact transient wrapper revision is not separately
bundled. Their compiler, host, harness, request/result and replay artifacts are
preserved. Do not infer a complete historical tool archive for those two early
wrapper invocations or silently assign them the final wrapper's bytes.

All runs are focused correctness gates. The 21-case default uses declared
acceptance/rejection-phase oracles and retains twelve exact diagnostic
differences. No complete frontend sweep, fixed-point proof or performance
comparison was performed by this archive operation.
