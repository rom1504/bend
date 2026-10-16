# Phase100 evidence

`phase100.tar.xz` preserves every file under the Phase100 build directory:
application C/executables, source preflights, successful and failed requests,
commands, guard/resource receipts, complete stdout/stderr, input files and
expected outputs, runner snapshots and the final independent oracle audit.

The verified capsule contains **2,821 files**, 404,264,882 raw bytes, in a
2,452,160-byte archive. SHA-256:
`f952864fc752ee54e35ed1956e03f7f268b3bf1d1e9dc8bbca3ace5ba6d32f85`.
See [receipt.json](receipt.json) and [manifest.json](manifest.json) for each
member's SHA-256, byte count and mode. The archival method itself is included as
`selfhost/build/phase100/archive-method.py`. Every archived member was streamed
back and checked against the manifest, without extraction.

The compiler images, pinned upstream source, Clang/Bun and shared request assets
are dependencies of the recorded runs. They are authenticated in acquisition
receipts and remain in the existing release/toolchain assets; this capsule does
not duplicate them or claim to be a standalone portable toolchain. Restore the
[Phase98 native release](../../../docs/self_hosted/NATIVE_PHASE98.md) first when
recompiling applications.

From the recorded checkout root `/home/ai/bend2/build/publish/bend`, restore only
when the Phase100 build directory is absent:

```sh
tar --keep-old-files -xJf implementation/phase100/evidence/phase100.tar.xz
```

Archive paths are checkout-relative, but receipts contain canonical absolute
paths. Replaying in a different checkout location requires an explicit new
acquisition/measurement; do not silently rewrite historical pins. Existing files
are refused by the command above.

Earlier oracle revisions were identified by hashes but not all were copied as
source snapshots. Their complete generated expected outputs and actual program
outputs are preserved. Later methods snapshot oracles explicitly. The final
`current-oracles01/audit.json` independently regenerates all **50 current cases**
and verifies byte-exact agreement with every distinct successful historical
expectation. That audit ran no compiler or generated program. It establishes the
current reference connection without pretending old source snapshots existed.

Useful retained runs:

- `source-acquire01`, `image-acquire01`, `dependency-acquire02`: actual upstream,
  native B1 and native B2 emissions, identical native-stage C, and program builds.
- `source-survey01`, `dependency-survey01`: four-round input-size surveys.
- `image-production01`: four-round useful-image worker sweep and one-tile control.
- `fixture-replay01`, `fixture-confirm01`: one-round replay check and four-round
  confirmation; the slower replay observations are retained in the pooled result.
- `combined-fast01`, `filtered-fast01`, `additional-controls01`: focused integration
  and edge/error contracts, with complete expected and actual output.
- `preflight*`, `dependency-acquire01`, `dependency-smoke01`, `source-edges01`:
  preserved application/method failures, not successful qualification campaigns.

The report's 318 passing executions count completed measurement reports only.
Six passing executions inside the typo-affected incomplete `source-edges01` are
preserved but excluded. Runtime clocks, compiler clocks, build clocks and oracle
generation remain separate.
