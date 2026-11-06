# Phase170: assemble a fresh maintained release

Status: preparation method, not a promotion result. The script
[`promotion.py`](../../selfhost/tests/phase170/promotion.py) constructs a proposal,
copies its finite gate receipts, and invokes the unchanged maintained release
auditor. It never builds, executes a compiler, installs, changes an asset selector,
or grants a session protocol. Root owns all guarded target jobs and installation.

## Source and stage boundary

Freeze one maintained canonical source after integration. Reassemble it with
`selfhost/tools/build/source.py`; use those exact bytes for checked JS acquisition,
genuine B2/B3 self-emission, and actual native QBE N1/N2 construction. The selected
native build receipt must say `N2`, not an experimental label rewritten later.
The selected JS receipt must say `B2`, and actual B3 must freshly check and emit
the same source with complete B2/B3 image equality.

The assembler deliberately refuses the extracted Phase169 native closure as a
substitute for canonical source. The old `release_bridge.py` is a narrow historical
Phase146 equivalence; it is not authority for relabeling Phase169. If the final
maintained architecture requires a distinct native profile, resolve that source
contract explicitly before using this assembler. No bypass is implemented here.

Public C uses the maintained `public-cli.py` derivation, with only `main` and
`p86_effect_read` changed relative to canonical plus its checked CLI additions.
Use `public-cli-bridge.py`, `native.py`, `request.py`, and `public-cli-c.py` to build
the actual package. A freshly qualified QBE image may build the bridge. The
bridge's NativeHost admission is private to that exact source/profile/provider;
the bridge is never installed as the public compiler.

Do not edit source, driver, runtime, or acquisition methods between checked JS B1
and B2/B3: authority closures are rechecked. Existing JS and C images are stale
relative to current maintained source; source-dependency inspection found real
reachable changes, so they must be rebuilt.

## Required evidence and useful small gates

The assembler requires these completed reports, authenticates selected images,
and binds each qualification to the actual image that ran:

| Recipe role | Required result |
| --- | --- |
| `qbeBuild` | Maintained native build, actual N2, exact canonical source, QBE protocol |
| `qbeQualification` | Maintained all64: 61 complete outputs + 3 explicit refusals; zero failures/unsupported |
| `jsB2`, `jsB3` | Genuine self-emission; B3 fresh check, accepted source, exact B2/B3 image |
| `jsQualification` | Actual B2, JS target, broad45 complete-output oracles |
| `jsPublic` | Actual B2, seven public JS CLI controls |
| `cliProfile` | Exact canonical-derived public CLI source profile |
| `cliPackage` | Actual native N1 C package with unmodified emitted C |
| `cliControls` | Relocation, options/errors, whole C products, executions, cache/live and asset/publication refusal controls |
| `cliQualification` | Actual packaged N1, C target, broad45 complete-output oracles |

The extra `qbe-reproduction` gate is mandatory and must be assigned to `qbe`.
Declare its expected assertions before assembling: same-source N1/N2 complete QBE
equality and any additional assembly/object/mapped-ELF comparisons actually made.
Bind the report's source and selected N2 image fields. Full ELF equality is not
required when only authenticated nonloaded linker metadata differs; retain the
explicit comparison receipt rather than asserting full-byte equality.

Also attach the integrated finite optimizer/verifier controls, genuine source
checking, and fresh JS frontend-negative/live-cache gates as explicit extra gates.
The integrated controls must exercise the maintained candidate, not simply point
to passing historical private-module receipts. Preserve the original diagnostic
priority controls and the existing borrowed/public/adapter invariants.

For inexpensive coverage beyond the ten receipt roles, run JS's two supported
frontend refusals and a small JS-hosted C execution subset. The C-native foreign
and frontend refusal protocols are not all supported by the finite catalog;
unsupported cases are not passes. This remains finite qualification, not complete
language conformance or independent BendTT proof.

All commands below are inner commands for one outer
`selfhost/tools/build-retention/guard.py` with fresh run roots, explicit time/RSS/
disk budgets and the default 5GiB reserve. Do not nest guards. Paths in capitals
are explicit already-built artifacts, not implicit installed defaults.

```sh
python3 -B selfhost/tools/build/qualification.py \
  --assets selfhost/manifests/assets-native.json \
  --image QBE_N2 --image-receipt QBE_N2_REPORT \
  --host native --stage N2 --target qbe --mode cache --suite all \
  --seconds 30 --build-seconds 30 --execute-seconds 10 --out FRESH_QBE64

python3 -B selfhost/tools/build/qualification.py \
  --assets selfhost/manifests/assets-native.json \
  --image JS_B2 --image-receipt JS_B2_REPORT \
  --host js --stage B2 --target js --mode live --suite broad \
  --seconds 60 --build-seconds 60 --execute-seconds 20 --out FRESH_JS45

python3 -B selfhost/tools/conformance/public-cli.py \
  --assets selfhost/manifests/assets-native.json \
  --image JS_B2 --image-receipt JS_B2_REPORT \
  --host js --stage B2 --target js --mode live --seconds 60 --out FRESH_PUBLIC7

python3 -B selfhost/tools/build/qualification.py \
  --assets selfhost/manifests/assets-native.json \
  --image JS_B2 --image-receipt JS_B2_REPORT \
  --host js --stage B2 --target js --mode live --suite focused \
  --case negative-type --case negative-affine --seconds 60 --out FRESH_JS_NEGATIVES

python3 -B selfhost/tests/consolidation/native-cli/controls.py \
  --package FRESH_C_PACKAGE --baseline RETAINED_PREVIOUS_C_PACKAGE \
  --cc PINNED_CLANG --cc-include PINNED_CLANG_INCLUDE --out FRESH_C_PUBLIC_CONTROLS

python3 -B selfhost/tools/build/qualification.py \
  --assets selfhost/manifests/assets-c-request.json \
  --image FRESH_C_PACKAGE/bend --image-receipt FRESH_C_PACKAGE/BUILD.json \
  --host native --stage N1 --target c --mode cache --suite broad \
  --seconds 60 --build-seconds 90 --execute-seconds 20 --out FRESH_C45
```

The public C controls compare complete numeric and IO C products with the retained
incumbent and independently execute their full stdout oracles. If an integrated
backend change legitimately changes C bytes, investigate and document it; do not
silently remove this gate or count the failed control as passing.

The live-cache control is
`selfhost/tests/consolidation/hosted/live-cache.mjs --image JS_B2 --base BASE
--source SOURCE --expected AUTHENTICATED_COMPLETE_PRODUCT --out FRESH` using the
pinned Node/Bun executable already selected for the campaign. It guards all shared
cache filesystem entry points and checks the exact existing rejection diagnostic.
Do not use a newly generated candidate product as an independent golden oracle.

Cheap metadata/fixture checks, separate from compiler jobs:

```sh
python3 -B selfhost/tools/build/test_release.py
python3 -B selfhost/tools/conformance/test_qualification.py
python3 -B selfhost/tests/phase170/promotion.py --help
```

These tests do not qualify any real compiler image. The first tests selector-last
publication, failed gates, actual B3 requirements, and rollback after a partial
installation. Existing session assets/protocols stay explicitly bound and unchanged;
ordinary QBE promotion must not imply `P140/2` session qualification.

## Assembler input and output

Prepare a small JSON recipe after all artifacts and reports exist:

```json
{
  "kind": "phase170-release-inputs",
  "version": 1,
  "canonical": "selfhost/build/phase170/canonical01/compiler.bend",
  "sourceRecipe": "selfhost/src/compiler.json",
  "sourceRoot": "selfhost",
  "sourceProfile": "qbe",
  "previous": "selfhost/manifests/current.json",
  "reports": {
    "qbeBuild": "QBE_N2_REPORT",
    "qbeQualification": "QBE64_REPORT",
    "jsB2": "JS_B2_REPORT",
    "jsB3": "JS_B3_REPORT",
    "jsQualification": "JS45_REPORT",
    "jsPublic": "PUBLIC7_REPORT",
    "cliProfile": "CLI_PROFILE_REPORT",
    "cliPackage": "C_PACKAGE_BUILD_JSON",
    "cliControls": "C_PUBLIC_CONTROLS_REPORT",
    "cliQualification": "C45_REPORT"
  },
  "providers": {
    "base": {"file": "BASE", "bytes": 0, "sha256": "ACTUAL_SHA256"},
    "jsLegacyRuntime": {"file": "LEGACY_RUNTIME", "bytes": 0, "sha256": "ACTUAL_SHA256"},
    "jsDirectRuntime": {"file": "DIRECT_RUNTIME", "bytes": 0, "sha256": "ACTUAL_SHA256"},
    "cRuntime": {"file": "C_RUNTIME", "bytes": 0, "sha256": "ACTUAL_SHA256"},
    "cRuntimeTemplate": {"file": "C_TEMPLATE", "bytes": 0, "sha256": "ACTUAL_SHA256"},
    "qbeRuntime": {"file": "QBE_RUNTIME_OBJECT", "bytes": 0, "sha256": "ACTUAL_SHA256"}
  },
  "extraGates": {
    "qbe-reproduction": {
      "report": "ACTUAL_REPRODUCTION_REPORT",
      "role": "lineage",
      "components": ["qbe"],
      "claims": {"REPLACE_WITH_ACTUAL_COMPLETE_QBE_EQUALITY_FIELD": true},
      "bindings": {
        "REPLACE_WITH_ACTUAL_N2_IMAGE_FIELD": {"bytes": 0, "sha256": "ACTUAL_SHA256"},
        "REPLACE_WITH_ACTUAL_SOURCE_FIELD": {"bytes": 0, "sha256": "ACTUAL_SHA256"}
      }
    }
  }
}
```

All zero byte counts, placeholder paths/fields/digests above must be replaced by
actual authenticated values. Extra gates use the unchanged release auditor's
dotted-field claims/bindings; values express expected success, never a mirror of
whatever a report happened to return. More gates may be added and associated with
one or more components; every supplied gate is audited.

```sh
python3 -B selfhost/tests/phase170/promotion.py \
  --recipe selfhost/build/phase170/promotion-inputs.json \
  --out selfhost/build/phase170/promotion01
```

The fresh output retains copied evidence, `promotion.json`, the unchanged
auditor's `audit.json`, a small operational native package binding, and the
previous selector. No old image is silently inherited. All previous installed
file pins are authenticated even when the previous source recipe is stale.
Failure preserves the fresh partial output; use a new root for any correction.

Installation is a later explicit root action using `release.py install`. Retain
its backup map, old artifacts, selector, and mutation journal as rollback assets;
the small saved selector alone is not a complete rollback package. Installation
does not update explicit development asset manifests or session selections.
`selfhost/bend` points directly to the native package, while the JS launcher uses
the current selector. Verify both actual public paths after installation and run
`release.py verify`. Do not remove the previous compiler merely because the new
audit passed.
