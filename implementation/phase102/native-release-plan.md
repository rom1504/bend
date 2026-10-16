# Phase102 native release readiness

Candidate02, `depth-inline-source01/compiler.bend` (`535c1f8f…6286d9`), is
**semantically qualified** by `native-chain02/admission.json`. Genuine B1/B2,
the exact self fixed point, both stages' ordinary controls, broad45, native69,
the backend bridge and five final-image controls pass. Admission does not select
the default and does not decide program performance.

Its separate 45-product runtime campaign blocks default selection: the
`coverage-list-pipeline-128` and `512` point ratios versus Phase98 are 1.330 and
2.536 in `phase99/phase102-runtime-phase98-02/summary.json`; the larger point has
substantial sample variation. The aggregate point ratio, 0.989, does not erase
this regression. The later cold-link ablation diagnoses redundant TRMC reference
wrappers; its saved-C improvement is not qualification of a Bend-source fix.

The frozen successor is `projection-cold-source01/compiler.bend`, SHA256
`b3927732f2250c19a7a8988dab7cbf30726359c18b5305f73c28cadddb902d1f`.
It adds projected owning-observer results, hoisted inline eligibility and the
pending-constructor cold-field policy. Its native qualification is separate and
pending. Candidate02 receipts cannot be relabelled as successor evidence.
Installed Phase98 remains selected; its pointer SHA256 is
`0ec0287c1c5e0b877b16a10e451bce4eb1fffa7b3795fcf634d742ea50772fdf`.

## Exact source transport

The existing immutable `phase102-lowering02/profile.json` replays candidate02;
`profile-replay02/packaging.json` verifies both forward replay and recovery of
the committed D04 source. Its `experimental`/`releaseQualified: false` fields
describe source transport, not the later separate native admission. Preserve it.
The final source's new `phase102-lowering03` package and exact replay now pass;
profile SHA256 is `c8310996…fc95d4`, compressed delta is 26,753 bytes, and
`profile-replay03/packaging.json` records the exact inverse back to D04. The
following command produced those new immutable paths:

```sh
python3 -B selfhost/tools/performance/phase102/package-source-profile.py \
  --recipe selfhost/build/phase102/projection-cold-source01/changes.json --name phase102-lowering03 \
  --out selfhost/tools/native/profiles/phase102-lowering03 \
  --verification-out selfhost/build/phase102/profile-replay03
```

This launched no compiler; the output paths now exist and cannot be reused.
Check the new replay's candidate hash against the
eventual admission source. Keep `profile.py` unchanged: earlier profiles pin
that method, and its historical default still names Phase98. New documentation
must pass `--profile selfhost/tools/native/profiles/phase102-lowering03/profile.json`
explicitly. The compact D04 profile is source transport; admission still needs
the exact **Phase98-to-final-source** recipe accepted by its collector.

## Runtime acquisition without redundant builds

The reviewed `runtime-reuse.py` preserves the original timing function. It can
reuse candidate02 binaries only when fresh final B1 and B2 emit the same complete
C as those exact historical products. It authenticates every reused ELF, C,
recorded compiler executable and build argv, retaining their historical paths.
It makes no hermetic header/library rebuild claim. The authenticated prior
Clang total, 106.51 seconds, is historical build work that may be avoided; it is
not a measured current saving or a clean-build speedup.

After final native runtime continuity exists, root can run the following with
fresh output paths under `selfhost/build/phase99`:

```sh
python3 -B selfhost/tools/performance/phase102/runtime-reuse.py acquire \
  --changed-plan "$P102_CHAIN/runtime-continuity/changed-plan.json" \
  --b1-build "$P102_B1_ROOT/b1.json" --b2-build "$P102_CHAIN/b2.json" \
  --reuse selfhost/build/phase99/phase102-runtime-products02/report.json \
  --out "$P102_PRODUCTS"
python3 -B selfhost/tools/performance/phase102/runtime-reuse.py measure \
  --products "$P102_PRODUCTS/phase98-products.json" --out "$P102_RUNTIME"
```

Measurements remain fresh, with the unchanged complete-output checks and three
balanced rounds. Durations below 100 ms require fresh calibration. An explicit
`--plans` calibration must bind the new source, product manifest and adapter;
candidate02 calibration contexts cannot substitute. `--all` measures all 44
nonzero points when needed; the zero-work ratio remains undefined. Performance
acceptance is a separate root decision, outside the semantic admission collector.

## Public CLI, selection and capsules

Use the [qualification plan](native-qualification-plan.md) for the complete
final-source gates and admission. The Phase99 release tools accept the new
source; their `plan` mode assumes a different directory layout, so use the
individual commands below. `ADMISSION` and `NATIVE_CONTROLS` must be completed
final-source receipts. `STAGED` and `CLI_OUT` must be fresh Phase99 build paths.
Do not reuse the already-created candidate02 `phase102-release02/selection.json`.

```sh
python3 -B selfhost/tools/performance/phase99/release/prepare.py selection --admission "$ADMISSION" --out "$STAGED"
python3 -B selfhost/tools/performance/phase99/release/cli-controls.py "$STAGED" "$NATIVE_CONTROLS" "$CLI_OUT"
python3 -B selfhost/tools/native/assets.py seal "$STAGED" selfhost/tools/native/releases/phase102-staged01
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase102-staged01/receipt.json --verify-only
```

The unchanged nine CLI controls cover both stages' cached-small, live-file and
repeated-map requests, plus existing-output, changed-manifest and invalid-source
refusals. Require all nine and zero missing files in capsule verification before
calling the staged release ready. The public launcher itself needs no source
specific edit.

Only after semantic qualification, runtime acceptance, CLI controls and staged
capsule verification should root apply the conditional atomic replacement in
[the earlier release review](../phase99/static-release-readiness.md), substituting
the final source/paths. Recheck the old pointer hash, preserve its exact bytes,
authenticate both new stages, recheck inputs and preserve permissions. Then run
the actual default small compile and compare every C byte with the final B2
cached-small control. Retain that request receipt and seal the stable pointer:

```sh
python3 -B selfhost/tools/native/assets.py seal selfhost/tools/native/selection.json selfhost/tools/native/releases/phase102-assets01
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase102-assets01/receipt.json --verify-only
```

The staged capsule preserves its staged pointer path, not the default path.
Capsules are same-checkout request assets; they do not include raw qualification
history. Keep old capsules and audit-pinned original documentation unchanged.
Describe the new release in a new native guide and current README links, with
explicit source/profile/stage identities and actual completed measurements.

## Freeze and archive

After every target and metadata writer stops, use the fresh `archive-v2.py`.
It includes only native request directories named by explicit complete CLI
reports, plus an optional final-default request. It validates those receipt pins
and recursively preserves their actual raw files at original paths. This closes
the old archive method's omission of `selfhost/build/native/requests`; it does
not scan or archive all native history. Every archived file has a hash and mode
and every tar member is read back. Seven synthetic data-only helper controls pass
in `archive-v2-method01/report.json`, including missing receipts/captures,
changed pins, mismatched log paths, symlinks and exclusion of unrelated requests.
No archive has been created by this review.

```sh
python3 -B selfhost/tools/performance/phase102/archive-v2.py --frozen \
  --cli-report "$CLI_OUT/report.json" --request-report "$P102_DEFAULT_REQUEST" \
  --out implementation/phase102/evidence
```

Retain prior phase/toolchain capsules as dependencies. Archive verification,
missing-file restoration, source replay, native qualification and runtime
acceptance are distinct claims. If the successor does not finish or does not
earn the benefit decision, keep Phase98 selected and publish the exact completed
candidate evidence with the remaining limitations.
