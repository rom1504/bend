# Installed JS release versus current checkout

**Current checkout release verification fails.** Root's retained
[`release-verify01`](../../selfhost/build/phase89/release-verify01/process.json)
exits 1 after 0.146 seconds, reporting the changed `src/back/native/text.bend`.
This is an identity refusal, not a resource stop. The installed Phase82 artifact
bytes remain intact; that fact does not make the current checkout pass release
verification.

The offline audit checks every identity in `dist/release.json`: all **16/16
installed files** and **228/231 checkout files** match. Exactly three checkout
compiler-source files differ. Full hashes, sizes, Git origin checks and installed
artifact identities are in [release-status.json](release-status.json).

| Compiler source | Release hash prefix | Current hash prefix | Bytes, release → current |
| --- | --- | --- | ---: |
| `src/back/native/text.bend` | `31c1ff59` | `acc430c9` | 2,533 → 3,305 |
| `src/back/native/emit.bend` | `73aba2f0` | `7f0c0fa3` | 11,694 → 11,854 |
| `src/back/native/observer-analysis.bend` | `a438a531` | `26aa9fcb` | 25,032 → 26,235 |

All three changes first appear together in Phase88 commit
`36a11b89afe453f53583408cba49cc635952d4d8`, “fix(native): share observer
continuations as Data and use linear text builders”, dated
2026-10-14 06:50:32 UTC. For every file, the parent commit exactly matches its
release-manifest hash, and that commit's new content exactly matches current
production. Phase82 installation commit
`15dfd88c0790f2bd005c6826db2d3e8cc72d2e57` also has the release-matching bytes.
There is no current `git diff HEAD -- selfhost/src` and Phase89 added none of
these discrepancies. “Production unchanged in Phase89” means unchanged relative
to the Phase89 starting checkout, not identical to the Phase82 release source.

The installed API still has SHA256
`098320e8f3e40894156790d740ad205e386f375195b3c6741d67cca96e94e092`
and 4,731,079 bytes. Its bundled Base, lineage files and all release-bound host
and runtime files also match their recorded identities.

Source inspection shows that ordinary `selfhost/cli.mjs` does **not** refuse
because of these three discrepancies: it calls `typed-driver.main`, whose
normal `inspect`/`loadApi` path imports the installed API and checks its ABI.
That path does not call `verifyRelease` or read the three compiler-source
modules. The explicit release command separately checks every checkout identity
and correctly refuses. This distinction is established by inspecting
`cli.mjs:3`, `typed-driver.mjs:215` and `release.mjs:33`; this audit ran no new
CLI/compiler target and does not claim a fresh CLI smoke test or full semantic
release verification.

No verifier was weakened, source reverted, manifest rewritten, or JS image
promoted. A future source/release reconciliation needs the normal checked and
self-hosting qualification; the current identity failure remains recorded.
The separately qualified Phase89 native image has its own frozen source/build
and admission chain, independent of this JS checkout mismatch.

Root subsequently ran the ordinary installed CLI under the normal guard:
`node selfhost/cli.mjs selfhost/tools/performance/phase77/fixtures/small.bend --run`.
[The retained process](../../selfhost/build/phase89/installed-cli-smoke01/process.json)
completed successfully in0.432s, stdout was exactly `42\n`, stderr empty.
This is one actual installed-CLI smoke test; the explicit checkout verification
failure remains unchanged.
