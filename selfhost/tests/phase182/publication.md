# Phase182 operational publication

Keep the retained selectors and all historical images unchanged until the new
gates pass. The native chain uses its frozen asset map; the helpers below do not
edit that map or the shared native/request/session adapters.

## Small gates that retain existing capabilities

All target commands below run inside one `tests/phase182/job.py` guard each,
using fresh output names. `P182=selfhost/build/phase182`, `A` is the ordinary
current asset manifest, and `N2=$P182/native-chain03/n2`. Reasonable initial outer
budgets are 180 seconds/128 MiB disk for API acquisition, 900 seconds/256 MiB for
session gates, and 1800 seconds/512 MiB for hosted focused qualification. These
are provisioning bounds, not timing predictions.

The operational hosted QBE API has **23** exports. All are present in snapshot07.
`qbe-operational-exports.json` preserves the exact list from the authenticated
installed acquisition receipt; the small seven-export acquisition is a different
API profile. Acquire and qualify the operational profile:

```sh
selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source "$P182/snapshot07/compiler.bend" \
  --exports selfhost/tests/phase182/qbe-operational-exports.json \
  --engine selfhost/.assets/bin/bun --out "$P182/qbe-operational-api01"
python3 -B selfhost/tools/build/qualification.py --assets "$A" \
  --catalog selfhost/tests/phase182/qualification-catalog.json \
  --image "$P182/qbe-operational-api01/api.mjs" \
  --image-receipt "$P182/qbe-operational-api01/report.json" \
  --host js --stage B1 --target qbe --mode cache --suite focused \
  --seconds 120 --build-seconds 120 --execute-seconds 20 \
  --out "$P182/qbe-hosted19"
```

QBE supports all 19 focused oracles, including three refusals. This is separate
from JS→JS/C focused18 and native C positive16. No hosted broad45 is required to
retain the existing cache-only QBE API claim.

Prepare the session fixtures without executing a compiler. Qualify the native
protocol before using the normal adapter:

```sh
python3 -B selfhost/tools/build/session/controls.py prepare --out "$P182/session-fixtures01"
python3 -B selfhost/tests/phase182/native-session.py --assets "$A" \
  --image "$N2/program" --image-receipt "$N2/report.json" \
  --source "$P182/snapshot07/compiler.bend" \
  --jobs "$P182/session-fixtures01/native-jobs.json" --seconds 600 \
  --out "$P182/native-session-bootstrap01"
python3 -B selfhost/tools/build/session/session.py --assets "$A" \
  --image "$N2/program" \
  --image-receipt "$P182/native-session-bootstrap01/image-binding.json" \
  --host native --stage N2 --jobs "$P182/session-fixtures01/native-jobs.json" \
  --seconds 600 --out "$P182/native-session-normal01"
```

The bootstrap gate retains six positive snapshots, two independent cold
references, six whole-QBE comparisons, a reuse observation, and generated outputs
`3\n`/`5\n`. The Phase182 port changes only runtime-argument selection and its
provenance/report fields. The frozen Phase170 method remains unchanged. The
normal adapter then executes the six positive jobs using the qualified binding.
Neither gate advertises native recovery or object-unit support.

Hosted sessions have always used an explicitly acquired experimental API, rather
than an installed `session-api` default. Preserve that workflow with the existing
eight-request/error-recovery matrix; its source extension adds only three object
boundary declarations:

```sh
python3 -B selfhost/tools/build/session/prepare.py \
  --source "$P182/snapshot07/compiler.bend" --out "$P182/session-source01"
selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source "$P182/session-source01/session.bend" \
  --exports selfhost/tools/build/session/exports.json \
  --engine selfhost/.assets/bin/bun --out "$P182/session-api01"
python3 -B selfhost/tools/build/session/session.py --assets "$A" \
  --image "$P182/session-api01/api.mjs" --image-receipt "$P182/session-api01/report.json" \
  --host js --stage B1 --jobs "$P182/session-fixtures01/jobs.json" \
  --check-cold --units --seconds 600 --out "$P182/session-hosted01"
python3 -B selfhost/tools/build/session/controls.py inspect \
  --report "$P182/session-hosted01/hosted.json" --out "$P182/session-semantic01"
python3 -B selfhost/tools/build/session/object-controls.py --assets "$A" \
  --session "$P182/session-hosted01/hosted.json" --seconds 120 \
  --out "$P182/session-objects01"
```

The object gate needs the separately pinned `objcopy` asset from the existing
session manifest. It executes cold/no-op/edit outputs `3`, `3`, `5` and rejects a
corrupt cached object. Skip only if no new object-reuse qualification is claimed;
the eight hosted controls independently cover two refusals and recovery. No
repetition of the unchanged host-only transport34/framing12 controls is required
for this runtime migration unless those methods change.

## Release recipe additions

`prepare-release.py` accepts these optional fields while preserving the existing
`release.audit` schema and exactly three top-level compiler components:

```json
{
  "hostedQbe": {
    "acquisition": "selfhost/build/phase182/qbe-operational-api01/report.json",
    "qualification": "selfhost/build/phase182/qbe-hosted19/report.json",
    "exports": "selfhost/tests/phase182/qbe-operational-exports.json"
  },
  "nativeSession": {
    "bootstrap": "selfhost/build/phase182/native-session-bootstrap01/report.json",
    "binding": "selfhost/build/phase182/native-session-bootstrap01/image-binding.json",
    "normal": "selfhost/build/phase182/native-session-normal01/report.json"
  }
}
```

The helper validates source/image/runtime identities, current upstream, exact
hosted19 counts and native session claims. It installs the hosted API and the
five operational QBE receipts, and records the qualified native session
capability. It rejects loss of any previously installed hosted export. Hosted
session receipts can be attached using existing `extraGates`, with role `lineage`
and exact `complete`, `request.checkCold`, `request.units`, eight-request/two-
refusal assertions. Those methods do not emit a `passed` field, so do not relabel
them as generic `qualification` receipts. Their generated API remains explicit.

## Default asset maps and benchmarks

After preparing the audited release, prepare replacement defaults without
installing them:

```sh
python3 -B selfhost/tests/phase182/prepare-operational-assets.py \
  --promotion "$P182/release-proposal01/promotion.json" --assets "$A" \
  --out "$P182/operational-assets01"
```

This requires the hosted/native-session gates above. It prepares all three
`assets-native.json`, `assets-session.json`, `assets-c-request.json` together,
including new Base/carrier, runtime/provider identities, actual installed image
and evidence pins, and both runtime argument conventions. It preserves the
separate `objcopy` pin. The candidate map needs `js-legacy-runtime` for
`src/runtime.mjs` as well as `js-runtime` for the direct runtime.

The new maps bind `qualificationCatalog` and `publicCliCatalog` by file, byte
count and SHA256. The runners use these only when `--catalog` is absent; an
explicit catalog wins and manifests without these fields retain the historical
fallback. Historical catalog contents and oracles are never rewritten.

Candidate07's four `upstream-*` rows still point to Phase66. The preparation helper
refreshes `bend.ts`, `comp.ts`, `main.ts`, `safe.ts` from the clean active Git
worktree and declares `bend-rts-v1` for `upstream-comp`. Otherwise benchmark
reference acquisition rejects the old checkout/new manifest revision mismatch,
or executes a new C product with the wrong argument convention. Runtime flags
for new ordinary products already come from the authenticated runtime provider.
The native45 `p93.arguments` wrapper consumes the final four arguments, so the
additional executable-name argument is accommodated. Frozen benchmark recipes
remain historical; reacquire current products with the updated defaults.

Install audited release files before publishing the staged maps. Verify every
installed image/evidence pin, then publish all three exact maps and run
`build/assets.py verify` against each. A cheap final ordinary-native live request
compared against a qualified cached product exercises the retained `live` mode;
do not substitute a native session's cold mode for ordinary live preparation.
The preparation helper does not modify installed defaults or claim those final
postinstallation checks ran.
