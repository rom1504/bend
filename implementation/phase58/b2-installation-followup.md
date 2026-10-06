# Emitted B2 installation follow-up

**Deferred; not implemented.** Phase58 continues to ship the checked-B1 lineage
(including its maintained equality derivation). This read-only assessment does
not change compiler source, runtime, workflow, installer, release policy or tests.
The completed B1 first-request comparison is approximately flat. B2 now takes
2.14–2.32× pinned TypeScript time on the two-input first-request screen, versus
B1's 2.90–3.05×. Its later requests also beat B1 in these separate paired matrices.
That makes B2 installation a concrete follow-up, without guaranteeing the same
gain on every workload. Keep compiler-request latency separate from generated-
program speed; exact values and timing boundaries are in [latency.md](latency.md).

## Existing support and blockers

`selfhost/tools/typed-driver.mjs::loadApiForIdentity` already accepts a no-`G`
module through its default callable exports after validating load/term/span ABIs.
The Phase58 private B2 project exercises that route. Installing the same image
would change compiler-image/source-hash lineage, not introduce a runtime ABI
conversion. The driver must retain direct, explicit legacy JavaScript, native,
interpreter and source-checking routes. Its API-hash-keyed Base cache requires
fresh preparation for B2; this is not a cache-format change.

The production boundaries currently reject an emitted B2:

- `selfhost/tools/development/workflow.mjs::verifyAttempt` requires a completed
  checked build and accepts only `checked-b1` or `derived-b1`. A derived API is
  verified against the genuine checked parent and its equality transformation.
  `validateAttempt` passes a bootstrap report only for the checked-B1 route.
- `selfhost/tools/development/release.mjs::installAttempt` accepts the checked
  attempt or its verified equality derivation. `verifyRelease` accepts only
  `bend-default-checked-release` and `bend-default-equality-release`, enforcing
  checked-byte identity or exact equality replay respectively. It also verifies
  relative installed/checkout identities and prohibits default bootstrap sidecars.
- `selfhost/tools/conformance/target.mjs` checks API equality with the bootstrap
  report in its checked launcher branch. Giving it the parent's report for B2
  would fail correctly; relabelling that report would misrepresent provenance.
- `selfhost/package.json` routes `build` through `release.mjs::buildRelease`, whose
  default profile is equality-derived checked B1. Routine rebuilding should keep
  that route unless an explicit emitted-image selection is introduced.

## Minimal safe future path

Introduce a distinct `emitted-b2` selection manifest/verifier, preserving
`verifyAttempt` for the genuine checked parent. Bind the selected image to the
exact assembled source and module inventory, subject and generator APIs, emission
producer and receipt, export roots, direct and legacy runtimes, effects, Base,
ordinary driver, Node and completed qualification receipts. Reject changed or
unknown inputs. Do not set B2's own `checked:true` bootstrap claim or manufacture
an upstream-bootstrap sidecar. A fixed point and successful type acceptance do
not establish kernel proof validity.

Add an explicit emitted selection to development validation and a distinct release
kind/install branch. Keep the real checked API/bootstrap in `release-lineage`,
add the emission/qualification lineage, and retain all current source/module/host
integrity checks. Verification after relocation must join local relative file
identities without requiring historical raw paths to exist. Historical receipts
remain unchanged data. Routine integrity verification should not silently compile
a whole image; reproducibility is a separately executed admission gate with a
pinned recipe. Installation should preserve the prior checked release for recovery.

An emitted-image option can remain opt-in while checked B1 continues as the
ordinary bootstrap/development route. This is a release/provenance change deserving
its own bounded future phase, rather than an installer flag during Phase58 closure.

## Reuse and new qualification

The [Phase58 report](README.md) and [validation plan](validation.md) own selected
pins and actual completion status. Existing genuine B1→B2 emission, selected B2
source/semantic gates, 23-source/45-point output equality, self-check and exact
B2→B3 reproduction may support future admission **only when the exact B2 image,
source, runtimes, Base, driver and controller identities join**. Preserve expected
unsafe proof-trust refusals and the explicitly known TS oracle defects. Earlier
checkpoint results do not transfer to a changed image by name or source intent.

Installing B2 still needs new artifact-verifier and launcher tests, rejection of
changed parent/source/emission/qualification inputs, and fresh B2-specific Base
cache preparation. Exercise cold and persistent source checking, selected frontend
refusals, interpreter, direct/legacy/native routes and any driver branches not
covered by the reused receipt inventory. Run the installed and relocated 42 legacy
plus 24 default interface checks through narrowly versioned artifact-aware tools,
then integrity/tamper rejection, restoration and rollback checks. Counts overlap
and are not a full-language proof. Repeat performance only for a changed execution
boundary; do not infer an installed speedup from profiled emission durations.

The testing cost is principally release-policy/launcher validation and these
installed interfaces; completed exact-image compiler-semantic gates need not be
rerun merely to add truthful metadata. Any API, driver, runtime or source change
requires reassessing that reuse. No elapsed-time estimate for this future work
has been measured.

## Consumers to audit

`selfhost/tools/performance/phase53/legacy-release-smoke-v1.mjs` hardcodes
`equality-derived-b1` in release and integrity expectations. Phase58's
`selfhost/tools/performance/phase58/publication/preservation.py` also requires
`derived-b1` and equality lineage. Preserve their consumed versions and create
explicit successors for emitted selection. `selfhost/tools/performance/phase46/emit.mjs`
uses `verifyRelease`; benchmark/acquisition producers importing `verifyAttempt`
need the explicit selection verifier rather than relaxed checked provenance.

`selfhost/tools/conformance/adapters/typed.mjs` delegates ordinary operations to
the driver; its artifact inventory and persistent session must bind the actual
selected image. Historical `selfhost/tools/test-compiler-abi.mjs` requires `G` for
its self-emitted compiler integration, while `selfhost/tools/test.mjs` explicitly
loads the separate `dist/bend2c.mjs` legacy compiler. Keep those historical tests
and artifacts in their original scope; do not redirect them to callable B2 or
weaken their assertions to make an installation pass.
