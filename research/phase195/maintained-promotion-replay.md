# Maintained promotion and historical replay

`promote-maintained.py` defaults to a read-only source check and writes a plan
under `selfhost/build/phase195/maintained-promotion-plan01.json`. It requires the
existing shared execution lock, so run it in a gap between controlled jobs.
Do not pass `--apply` until root confirms that qualification and all measurements
have finished and authorizes the copy.

The method pins baseline commit `8230a06ef060d4e4b5eb375e1ce29c89b26f1bee` and
requires each current changed file to match its exact HEAD bytes (or the exact
selected bytes on an idempotent rerun). The new table module must be absent at
baseline. Mixed partial states and unrelated source changes are refused. It
verifies every selected file hash, the frozen staged manifest/source pins,
seven-root audit, and all five other source profiles/maps before any copy.
Only the eight files in `selected-source02/changed-files.json` are copied.
Afterward, reassembly of live x86 must exactly equal the checked source02 bytes.
An already-selected tree is verified without copying again. The installed
compiler, selector and asset manifests are outside this operation.

Commands, from repository root after the shared lane is released:

```sh
python3 -B research/phase195/promote-maintained.py
# Only after root's explicit final signal:
python3 -B research/phase195/promote-maintained.py --apply
```

Historical hosted receipts retain the old live compiler-manifest pin:
SHA256 `b383771a7335832749d7cf55c6430ab4c2db3d78f11a471c4ba7f67dbee59d9f`.
Changing live maintained source intentionally invalidates fresh authentication
of those old bindings against the current checkout. Do not rewrite historical
receipts, replace their manifest hash, or weaken source-bound preparation checks.
The measured products remain immutable evidence with their original receipts.

To reproduce the historical hosted setup, check out the baseline commit in an
isolated workspace and restore the exact pinned assets, APIs, source snapshots
and preparation artifacts from retained evidence. Receipts contain absolute
paths: reproducing the original binding literally requires that historical
checkout and its artifacts at the same repository path inside an isolated
filesystem/container. A normally relocated worktree must create fresh source/API
bindings and preparation receipts for its new paths; that is a new replay, not
authentication of the original receipt. Do not restore the old manifest over
the active checkout to make a historical command pass.

Native candidate image receipts bind the frozen selected-source02 bytes and
explicit image/assets. Keep that staged source and its manifest hot with the
qualified images. Later hosted work against the promoted tree needs fresh
checked API preparation bound to the newly assembled live source/manifest.
