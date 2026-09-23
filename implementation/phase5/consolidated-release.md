# Consolidated default compiler

The ordinary `selfhost/cli.mjs` now uses the final equality-derived compiler in `dist/typed-api.mjs`, SHA-256 `e2b5463678a26558e8fea1d585782e0863f1046067949a374f0469080281b15a`, without API overrides. This is the same compiler image whose whole-source output and all 2,756 frontend observations were validated. The default bundled Base is unchanged; the active JS/native runtimes and host/source files are bound by the release manifest.

`npm run build` composes the maintained checked bootstrap, guarded equality derivation, 21-case paired acceptance/phase gate and installation. The actual command was tested with only CPU affinity configured:

```sh
npm run build -- build/phase5/default-release/build-config.json build/phase5/default-release/build-attempt
npm run verify:release
```

The fresh build and derivation completed at 02:43:26.858 UTC; focused validation completed at 02:43:47.576. Both live compilers passed all 21 controls. Seven known exact diagnostic differences remain visible. The result reproduced the already validated default API and final assembled-source SHA `e3b927d13dc2645e19171b72de60c49dd5bc5e5059863937153b957e2ce0ec1d` exactly. No new full fixed-point run was needed or claimed. Building requires the pinned local upstream checkout and Node 24; native program execution additionally requires supported Clang.

The maintained `tools/development/release.mjs` also provides `--install-attempt ATTEMPT [DERIVATION]` for verified existing artifacts and `--verify` for installed releases. `dist/release.json` uses relative file identities, checks current compiler modules/configuration, host, CLI and runtimes, and replays the guarded transformation against the retained genuine checked parent. Verification succeeded after relocation to an independent directory; it does not dereference historical absolute report paths. Original bootstrap and derivation reports remain byte-for-byte historical records in `dist/release-lineage`. They are not rewritten to fabricate relocated bootstrap provenance.

The previous default API and its authentic reports are retained under `dist/release-history`. The stale `dist/typed-api.mjs.bootstrap.json` and `dist/typed-bootstrap-report.json` were removed from the default location: the installed derivative is never represented as a new checked bootstrap. Historical distributions elsewhere remain history, not alternative defaults.

Twelve focused controls passed: release verification, default CLI checking, interpreter/JavaScript/native execution of the repaired Nat witness (all print `8`), invalid-type diagnostic equality with the genuine checked parent, relocated verification, stale bootstrap-sidecar refusal, changed runtime/API refusal, and restoration. A separate plain `node cli.mjs … --interpret` invocation with no compiler overrides or Node resource flags also printed `8`.

The first sandboxed native observation was correctly rejected by the test: Clang pipe capture reported `EPERM`, the host emitted no program output, and the existing CLI returned zero despite that error. This failure is retained. With authorized ordinary subprocess permissions, actual native compilation/execution passed. No frozen host helper was changed to conceal the failed observation. The host’s zero-exit error propagation is a remaining limitation, separate from compiler-image correctness.

Tests used CPU0 while other correctness gates ran; timings are workflow observations, not performance measurements. [Durable evidence](consolidated-release-evidence/manifest.json) preserves the actual build/validation reports, controls, failed sandbox attempt, installed manifest/lineage and consumed source/tool bytes. No fabricated bootstrap or full-conformance claim is made.

## Final host correction — 2026-09-23 02:53 UTC

The observed native error-propagation defect is now fixed: an error returned with
child status0 produces exit1, while genuine nonzero compiler statuses are preserved.
Five native host regression groups pass, including the exact observed error tuple,
signal/null status, ordinary compile rejection and success. A second actual
default-CLI sandbox observation reproduces EPERM and now exits1 with no program
output. The original exit0 observation remains in the earlier archive.

A fresh maintained release build after this one-line host change passes all21
paired controls and reproduces the exact same API/source hashes. The current
release manifest binds the corrected native helper and the new genuine checked
build lineage; local release verification passes. The broader compiler/proof
evidence still applies to identical compiler bytes, while broad backend execution
uses its immutable pre-fix host and is labeled accordingly. No source compiler
change or new fixed-point claim follows from the host repair.

The [additional archive](native-exit-fix-evidence/manifest.json) preserves344file
identities in248objects,1,521,356compressedbytes, including the tested current
release manifest, exact helper/tests, all rebuild/paired reports and actual CLI
observations. It supplements rather than replaces the first release archive.
