# Phase88 native compiler methods

[Report](../../../../implementation/phase88/README.md) ·
[Usage](../../../../docs/self_hosted/NATIVE_HOST.md) ·
[Design](../../../../design/phase88/native-correctness-and-speed.md).

`native.py SOURCE --image IMAGE -o NEW_C` is the guarded native launcher.
`restore.py` verifies/restores the exact admitted native02 assets; `--all` restores
all attempts and `--verify-only` verifies selected archived members. Cache
admission binds the original canonical root. See the usage guide for scope.
`auth-controls.py NEW_DIR` tests ten admission boundaries without running a
compiler; `launcher-controls.py NEW_DIR` exercises cached/live positives and
refusal/publication paths serially. Never overwrite evidence directories.

## Fast to slow loops

- Source/shape audit and tiny component gate: `component.mjs SOURCE NEW_DIR`
  checks a standalone Bend source and emits JS/C. Use the Phase86 resource guard;
  default to40seconds and one CPU. Observer, string and decoder controls have
  separate directories/READMEs and frozen failed attempts.
- Cheap correctness screen: authenticated native requests on Small, Numeric,
  Lexer, Map and Unicode; compare full C to the independent installed B2.
- Controlled comparison: `python3 -B measure.py NEW_DIR --rounds 2 --calls 1`.
  Default roles are native01, native02-live, native02-cached, TypeScript and B2;
  order rotates and reverses. Use `--roles cached02,typescript,b2 --calls 5
  --rounds 1` for repetition. The retained `screen01` freezes input/oracle hashes.
  All targets are serial and every output is consumed and checked.
- Broad gate: `broad.py --help` describes generation/run options. Use the final
  `broad-fixtures03/manifest.json`, cache receipt and `--execute`;45points from
  23originals must match full independent C and expected execution stdout.
  Earlier adapters and failures remain immutable; do not overwrite their files.
- Ordinary JS source integration: use the checked B1/frontend36 workflow in
  `docs/PHASE5_DEVELOPMENT.md`. `js-development01` is the passing phase gate;
  installed Phase82 B2 is not replaced.

`ownership/` contains the bounded native sampler and physical caller recovery.
Its profile phase marks are checked against actual native clocks. It does not
recover semantic tail-call stacks or allocation counts. Profile execution is a
diagnostic, never mixed into clean timing medians.

## Rebuilding an experimental image

1. `node acquire.mjs NEW_ACQUISITION base/entry-cache.bend js` assembles current
   manifest plus the cache entry, checks all Bend, and emits a JS sibling.
   An exact upstream receipt in `selfhost/build/phase86/upstream.json` is required.
2. `python3 -B strings/native-assembly.py NEW_ACQUISITION/compiler.bend NEW_SOURCE.bend`
   freezes the compiler-only consuming equality derivative. It changes neither
   imported Base nor ordinary source and records every replaced identifier.
3. `node acquire-derived.mjs NEW_ACQUISITION/report.json NEW_SOURCE.bend.derivation.json NEW_NATIVE`
   checks the whole derived source again, then emits JS/C. Run under the existing
   guard with bounded Node heap/stack; the qualified acquisition took76s.
4. Build the checked C once, with ClangO2, `-lm -pthread`, the recorded Clang
   include path, and CPU2,3. The full image needs the deliberate6GiB RSS /
   16GiB available-memory guard,360seconds. Native02 took175s and3.995GiB peak.
   The exact invocation and source/binary/checked-report bindings are preserved
   in `compiler-native02.build.json` and `native02-build-guard/process.json`.
5. Give the new build its own receipt and repeat the controls before adding a
   new cached-consumer identity. Existing `CACHED_CONSUMER` pins are a qualified
   artifact identity, not a generic acceptance switch. `--live` avoids prepared
   cache admission but still requires a checked build receipt.

Use absolute commands from the preserved receipts for exact reproduction. These
steps are an experimental build procedure, not an automated portable release.
Changing source without changing identities is never a rebuild.

## Evidence and accounting

`summarize.py` reduces all recorded guards, exact outputs and controlled medians
without executing a compiler. `seal.py` creates a new immutable `evidence01`
capsule only after all runs finish, including failed attempts, full images,
profiles, request logs and exact external assets required for native02. It
verifies archived and local hashes; no earlier seal is updated.

Two full image builds were used after cheap component tests. Bounded agents
worked on disjoint audits/fixtures; root alone ran native/compiler targets.
The resource ledger includes failed controls. Elapsed guard time is not a token
or quota-usage measurement. Historical Phase6/68 uncommitted work is outside this
phase and is not part of its promotion.
