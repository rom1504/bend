# Phase174: independently audit publication of the measured Phase171 compiler

This is a release plan, not a qualification result. Audited from HEAD
`c1af28f5b3862b3c638b830349b5f71e4130a482`, the existing Phase170 selector and
`selfhost/tools/build/RELEASE.md`. Root owns target execution and installation.
This review changes no compiler, release tooling, installed artifact or gate.

## Scope and exact source boundary

Integrate only Phase171's four measured overlays: 16 replaced definitions and
28 added declarations, retaining all 8,414 originals. The frozen candidate is
3,161,409 bytes, SHA256
`74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.
Its parent is Phase170's 3,150,535-byte `434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
The 180.677 s observation compiles that *parent workload*; it is not a measured
self-build of the larger candidate. Keep these two source identities separate.

Require the maintained assembly to match the frozen candidate byte for byte,
not merely agree on selected function names. Validate all declaration bodies,
order, original signatures, original native main, protected map and zero pruning;
reversing precisely the 16 replacements and 28 additions must recover the parent.
Helper laws and their definitions must share an owner module. The six forward-law
positions are those in `selfhost/build/phase171/native-source01/report.json`.
No Phase172/173 optimization or unrelated working-tree change belongs here.

Recheck the final canonical source independently through the maintained hosted
acquisition. The 77 compiler-data controls must run against an API derived from
the *maintained candidate*, with only the four control modules appended. Do not
overlay experimental implementations on top of the integrated source: that can
hide integration mistakes. Historical `phase171/prepare-api.py` deliberately
requires the old parent; keep its guard unchanged. A metadata-only fixture
assembly may extract the maintained dependency closure, preserving exact bodies.

## What can be reused

The Phase171 N1 can be reused **if canonical bytes are exactly the frozen bytes**.
Its `native-candidate01/report.json` records a genuine native N1 built by installed
Phase170 N2, not a relabeled experimental stage. Authenticate that receipt,
source/image/runtime pins and the machine products before using them:

| Existing artifact | SHA256 |
| --- | --- |
| N1 `program`, 16,122,336 bytes | `c354b39cf852c556624de93011b98a03f9bdeafb087ea5adc9a2d6938050ec41` |
| N1 QBE, 98,023,231 bytes | `91b67c0667804e0fb47e1ea127c2289d83822a0786c3627174a3a3ee00b0ef04` |
| N1 assembly | `09b9fbc98540d18d1af88a4214075a2cdd3ca37813e7d6fdbdbe173d27544d60` |
| N1 object | `b8e33013511cf9e8aa64f3102c5f7948a8e35395afdd5a85d380e2a07ab34de0` |
| QBE runtime | `2d07832382a11d7e993124ecc70452e4e1a3b7f753cf429343e1183cd8e493a3` |

All four N1 machine artifacts were still hot at this audit. Build fresh N2 using
this actual N1, require full QBE equality, then execute actual N2 to emit Q3.
Retain original N1 acquisition provenance/time. The release contract requires
actual source-bound generations, not a redundant fresh acquisition directory.
If the integration changes any canonical byte, reacquire N1 with `bootstrap.py`
and do not pretend this exact-source reuse remains applicable.

Unchanged Base/carriers, runtime/provider files, tool executables, independent
stdout oracles and frozen benchmark sources remain reusable by exact identity.
The 45 timed products can transfer previous runtime evidence through whole-QBE
identity plus unchanged machine/runtime policy. This is not a new runtime timing.

The old public **JS and C images cannot be relabeled** as this release. The
publication-history replacements `p156cp_start`/`p156cp_continue` affect shared
checking. Moreover the release contract requires canonical JS source identity,
actual fresh B3 checking and a canonical-derived public C profile. Rebuild their
actual images and qualify them. A historically qualified exact unchanged image
retains its historical qualification; that alone proves no new source lineage.
The narrow historical `release_bridge.py` QBE exception does not cover JS/C or
this source change. Unchanged mathematical proof bodies may retain their exact
protected-source evidence; the finite release does not claim a new BendTT proof.

Actual acquisition falsified the proposed JS qualification reuse shortcut. The
fresh B1 API matched its Phase170 counterpart, but fresh B2 did not: both B2
files are5,024,712 bytes, while the new SHA256 is
`6b71bd3e51bcf7eff6b168c5c752366c7673a8c4e02bf816c6c856d38643b416`,
versus installed `a689f6b8629eb959f1489f63675a15748f033e14f2cb57fdba5489c5e7c54329`.
Equal precursor bytes or output size do not establish output identity. All four
fresh JS behavior gates therefore remain required. No identity-transfer helper,
builder exemption or semantic-equivalence investigation was introduced.

## Minimum acceptance matrix

| Boundary | Required evidence |
| --- | --- |
| Source integration | Exact candidate bytes; inverse, signature, main, inventory and protected checks |
| Independent source check | Fresh checked hosted API from final canonical source |
| Four transformations | 22 success/first-error + 6 SCC + 32 complete planner + 12 catalogue + 5 history controls = 77 |
| Native self-hosting | Authenticated N1, fresh N2, actual N2→Q3; complete QBE fixed point |
| Native machine identity | N1/N2 assembly/object comparison; inspect loadable ELF segments if whole ELF differs |
| Final native behavior | `qualification.py --suite all`: 64 pass, zero fail/unsupported (61 output + 3 refusal) |
| Broad code-quality preservation | 45 correctness products and separate 45 timed wrappers exactly match retained references |
| Hosted QBE | Fresh canonical B1 cursor API; 19 focused checks |
| Native P140/2 | Six positive jobs, same-mode cold references, reuse/edit observations, independent `3`/`5` outputs; normal admission replay |
| Hosted session | Fresh derived session API and existing eight-job recovery/cold/object controls; no native object/recovery claim |
| Public JS | Genuine B2/B3 fixed point; actual B2 broad45, public7, type/affine2 and JS-hosted C focused5 |
| Public native C | Exact thin profile, actual Bend-produced C/package, independent public controls and actual package broad45 |
| Installation | Unchanged release audit, selector-last transaction, explicit operational selector pins, installed verification/smokes |

Do not replace actual image qualification with build success or fixed-point
agreement. Do not count unsupported cases or incomplete deadlines as passes.

## Concrete acquisition and gate sequence

The commands below are **inner commands**, each under the existing single CPU3
disk/RSS guard with a fresh declared run root, finite deadline and 5 GiB reserve.
Do not run the entire section unguarded or nest guards. Variable names identify
explicit paths; they do not change an installed selection.

```sh
TASK_P174=selfhost/build/phase174
TASK_SOURCE=$TASK_P174/source01/compiler.bend
TASK_N1=selfhost/build/phase171/native-candidate01
TASK_N2=$TASK_P174/native-n2
TASK_BUN=selfhost/.assets/bin/bun
TASK_BASE=selfhost/.bootstrap/upstream-phase66/bend2/base.bend
TASK_ASSETS=selfhost/manifests/assets-native.json

python3 -B selfhost/tools/build/source.py assemble \
  --manifest selfhost/src/compiler.json --root selfhost --profile qbe \
  --out "$TASK_SOURCE" --map "$TASK_P174/source01/map.json"

"$TASK_BUN" selfhost/tools/build/hosted.mjs acquire --source "$TASK_SOURCE" \
  --exports selfhost/tools/build/js-c-exports.json --out "$TASK_P174/b1" \
  --upstream selfhost/.bootstrap/upstream-phase66 --engine "$TASK_BUN"

python3 -B selfhost/tools/build/native.py --assets "$TASK_ASSETS" \
  --image "$TASK_N1/program" --image-receipt "$TASK_N1/report.json" \
  --host native --stage N1 --target qbe --mode cache --source "$TASK_SOURCE" \
  --expected "$TASK_N1/program.ssa" --retain-ir --output-stage N2 \
  --out "$TASK_N2" --seconds 330

python3 -B selfhost/tools/build/request.py --assets "$TASK_ASSETS" \
  --image "$TASK_N2/program" --image-receipt "$TASK_N2/report.json" \
  --host native --stage N2 --target qbe --mode cache --source "$TASK_SOURCE" \
  --expected "$TASK_N2/program.ssa" --out "$TASK_P174/q3" --seconds 300

"$TASK_BUN" selfhost/tools/build/js-bootstrap.mjs \
  --generator "$TASK_P174/b1/api.mjs" --generator-report "$TASK_P174/b1/report.json" \
  --source "$TASK_SOURCE" --base "$TASK_BASE" --out "$TASK_P174/js-b2-retry"
"$TASK_BUN" selfhost/tools/build/js-bootstrap.mjs \
  --generator "$TASK_P174/js-b2-retry/api.mjs" --generator-report "$TASK_P174/js-b2-retry/report.json" \
  --source "$TASK_SOURCE" --base "$TASK_BASE" --out "$TASK_P174/js-b3" \
  --compare "$TASK_P174/js-b2-retry/api.mjs"
```

Require B3 `freshSelfCheck`, `typeAccepted`, `byteEquality`, and exact B2 image
as B3 generator. Preserve the native machine comparisons as a separate lineage
report binding canonical source and actual N2. Do not demand full ELF byte equality
if a bounded loadable-segment audit proves only nonloaded metadata differs.

Use the existing four Phase171 control runners with the freshly checked maintained
control API. The two baseline receipts remain
`selfhost/build/phase171/ff-baseline-api01/report.json` and
`selfhost/build/phase171/lazy-baseline-api02/report.json`. Run
`fail-fast-controls.mjs` (28), `lazy-admission-controls.mjs` (32), and
`value-controls.mjs --export p171sc_controls --count 12` / `--export p171s_controls
--count 5`. Their exact invocation is in
`implementation/phase171/reproduce.md`; replace only candidate/output paths.

```sh
python3 -B selfhost/tools/build/qualification.py --assets "$TASK_ASSETS" \
  --image "$TASK_N2/program" --image-receipt "$TASK_N2/report.json" \
  --host native --stage N2 --target qbe --mode cache --suite all \
  --seconds 30 --build-seconds 30 --execute-seconds 10 --out "$TASK_P174/qbe64"

python3 -B selfhost/tests/phase170/reemit-products.py --assets "$TASK_ASSETS" \
  --image "$TASK_N2/program" --image-receipt "$TASK_N2/report.json" \
  --host native --stage N2 --target qbe --mode cache \
  --reference selfhost/build/phase169/quality-six-native01/report.json \
  --reference selfhost/build/phase169/quality-remaining-native01/report.json \
  --expected-count 45 --out "$TASK_P174/timed-products" --seconds 60

"$TASK_BUN" selfhost/tools/build/hosted.mjs acquire --source "$TASK_SOURCE" \
  --exports selfhost/build/phase170/qbe-exports.json --out "$TASK_P174/qbe-api" \
  --upstream selfhost/.bootstrap/upstream-phase66 --engine "$TASK_BUN"
python3 -B selfhost/tools/build/qualification.py --assets "$TASK_ASSETS" \
  --image "$TASK_P174/qbe-api/api.mjs" --image-receipt "$TASK_P174/qbe-api/report.json" \
  --host js --stage B1 --target qbe --mode cache --suite focused \
  --seconds 60 --build-seconds 30 --execute-seconds 10 --out "$TASK_P174/qbe-hosted"

python3 -B selfhost/tests/phase170/native-session.py --assets "$TASK_ASSETS" \
  --image "$TASK_N2/program" --image-receipt "$TASK_N2/report.json" --source "$TASK_SOURCE" \
  --jobs selfhost/build/phase170/session-fixtures/native-jobs.json \
  --out "$TASK_P174/native-session-bootstrap" --seconds 120
python3 -B selfhost/tools/build/session/session.py --assets selfhost/manifests/assets-session.json \
  --image "$TASK_N2/program" --image-receipt "$TASK_P174/native-session-bootstrap/image-binding.json" \
  --host native --stage N2 --jobs selfhost/build/phase170/session-fixtures/native-jobs.json \
  --out "$TASK_P174/native-session-normal" --seconds 60
```

Use `compare-products.py` to compare the 45 broad products already emitted by
`qbe64` with the exact prior native qualification; this executes no targets.
The timed wrappers are distinct inputs and cannot be replaced by broad45.
Session claims are granted only after the bootstrap receipt exists for this image.
For the unchanged hosted-session gate, derive through `session/prepare.py
--source "$TASK_SOURCE" --out "$TASK_P174/session-source"`, acquire its
`session.bend` with `session/exports.json`, then run `session/session.py` with
`--host js --stage B1`, explicit new API/receipt,
`phase170/session-fixtures/jobs.json`, `--check-cold --units --seconds 120`.

For selected JS, use explicit `js-b2-retry/api.mjs` and `js-b2-retry/report.json` with these
unchanged runners (all use `--assets "$TASK_ASSETS" --host js --stage B2 --mode live`):

| Runner | Selection | Fresh output |
| --- | --- | --- |
| `build/qualification.py` | `--target js --suite broad --seconds 60 --execute-seconds 20` | `js45` |
| `conformance/public-cli.py` | `--target js --seconds 60` | `js-public` |
| `build/qualification.py` | `--target js --suite focused --case negative-type --case negative-affine --seconds 60` | `js-negative` |
| `build/qualification.py` | `--target c --suite focused --case pure-u32 --case u32-wide-wrap --case higher-order-capture --case arrays-io --case f32-arithmetic --seconds 60` | `js-c-focused` |

## Public C: rebuild the source-bound package

These are the existing Phase170 commands, using the new canonical source via the
maintained recipe. The bridge is a private exact-provider construction tool;
never install it as the public compiler or broaden normal foreign admission.

```sh
python3 -B selfhost/tools/build/public-cli.py --out "$TASK_P174/public-profile"
python3 -B selfhost/tools/build/public-cli-bridge.py \
  --profile "$TASK_P174/public-profile/report.json" \
  --assets selfhost/manifests/assets-c-request.json --out "$TASK_P174/public-bridge-source"
python3 -B selfhost/tools/build/native.py --assets "$TASK_ASSETS" \
  --image "$TASK_N2/program" --image-receipt "$TASK_N2/report.json" \
  --host native --stage N2 --target qbe --mode cache \
  --source "$TASK_P174/public-bridge-source/compiler.bend" \
  --out "$TASK_P174/public-bridge" --seconds 330 \
  --output-stage N1 --output-protocol native-c-source-v1
python3 -B selfhost/tools/build/request.py --assets "$TASK_P174/public-bridge-source/assets.json" \
  --image "$TASK_P174/public-bridge/program" --image-receipt "$TASK_P174/public-bridge/report.json" \
  --host native --stage N1 --target c --mode cache \
  --source "$TASK_P174/public-profile/compiler.bend" --out "$TASK_P174/public-c-emission" --seconds 210
python3 -B selfhost/tools/build/public-cli-c.py --profile "$TASK_P174/public-profile/report.json" \
  --bridge-profile "$TASK_P174/public-bridge-source/report.json" \
  --bridge-build "$TASK_P174/public-bridge/report.json" \
  --emission "$TASK_P174/public-c-emission/report.json" \
  --assets selfhost/manifests/assets-c-request.json --out "$TASK_P174/public-package" --seconds 650
python3 -B selfhost/tests/consolidation/native-cli/controls.py \
  --package "$TASK_P174/public-package" --baseline selfhost/dist/native \
  --cc /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang \
  --cc-include /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang \
  --out "$TASK_P174/public-controls"
python3 -B selfhost/tools/build/qualification.py --assets selfhost/manifests/assets-c-request.json \
  --image "$TASK_P174/public-package/bend" --image-receipt "$TASK_P174/public-package/BUILD.json" \
  --host native --stage N1 --target c --mode cache --suite broad \
  --seconds 60 --build-seconds 90 --execute-seconds 20 --out "$TASK_P174/c45"
```

Authenticate the literal Clang/include paths against the existing asset manifest;
do not silently substitute a system compiler. Keep incumbent native package bytes
unchanged until controls finish. Profile claims must change exactly `main` and
`p86_effect_read`, with all other bodies identical to the new canonical source.

## Exact Phase170 command/provenance references

All following paths are under `selfhost/build/phase170/`; `*-guard/process.json`
contains the exact previous guarded command. Final product receipts are separate:

| Lane | Exact retained receipt / command root |
| --- | --- |
| JS checked B1 | `b1-final/report.json`, `b1-final-guard/process.json` |
| B2 and B3 | `js-b2-final/report.json`, `js-b3-final/report.json`, corresponding `-guard/process.json` |
| Hosted QBE | `qbe-api-final/report.json`, `qbe-hosted-final/report.json`, corresponding guards |
| Native source chain | `native-chain-final/report.json`, `native-chain-final/{n1,n2,q3}/report.json` |
| Native final suite | `qbe64-final/report.json`, `qbe64-final-guard/process.json` |
| Timed QBE identity | `timed-products-final/report.json`, `timed-products-final-guard/process.json` |
| Native session | `native-session-bootstrap-final/report.json`, `native-session-normal-final/report.json`, corresponding guards |
| Hosted session | `session-api-final/report.json`, `session-hosted-final/report.json`, corresponding guards |
| Selected JS | `js45-final-retry/report.json`, `js-public-final/report.json`, `js-negative-final/report.json`, `js-c-focused-final/report.json` |
| Public C derivation/build | `public-profile-final/report.json`, `public-bridge-source-final/report.json`, `public-bridge-final/report.json`, `public-c-emission-final/report.json`, `public-package-final/BUILD.json` |
| Public C qualification | `public-controls-final/report.json`, `c45-final/report.json`, corresponding guards |
| Publication | `promotion-final/promotion.json`, `promotion-final/audit.json`, `install-final01/report.json`, `selector-install01/report.json` |

## Cost discipline and final publication

Avoid a new runtime benchmark campaign when all 45 timed QBE products are exact.
Avoid repeating N1 acquisition when its entire source/artifact lineage is exact.
Do not spend time recertifying unchanged upstream/runtime/provider artifacts.
The old final acquisition/gate times give useful deadline floors: B2 about314 s,
B3 277 s, live JS45 402 s, native64 68 s, hosted QBE116 s, C bridge126 s, C emission
141 s, C package432 s and C45 103 s. These are budgeting observations, not forecasts.
JS45 needs a600 s outer bound; its previous300 s attempt was incomplete. The C
package command already grants650 s. Native retained N2 needs a256 MiB run budget;
a complete retained N1/N2/Q3 chain previously used489 MiB inside640 MiB. Keep the
guard's available-memory floor and one resource-heavy lane; do not trade OOM risk
for parallel target jobs. Metadata preparation/audits can overlap that lane.

Reuse `selfhost/tests/phase170/promotion.py` unchanged with explicit recipe kind
`phase170-release-inputs`, version1, but all new canonical/artifact/gate paths.
Its historical kind is a schema, not a requirement to pretend this is Phase170.
Supply all ten required report roles, six exact providers, and explicit extras:
source/77 controls, same-source native reproduction bound to canonical and N2,
machine comparison, timed identity, hosted acquisition/qualification, sessions,
and the selected-JS small gates. Every asserted claim must express the intended
success condition rather than copying an arbitrary report's result.

The concrete metadata preparer is `selfhost/tests/phase174/prepare-release.py`.
It requires the declared completed receipts and immutable previous selector at
`selfhost/build/phase174/reference-source01/selfhost__manifests__current.json`.
Its exact source/77/reproduction assertions are agreed with the coordinating
agent; it also gates the actual Q3 request separately. Preparation grants no
qualification or installation. The initial `js-b2` attempt was interrupted by
its disk guard; the explicit default is `js-b2-retry`, with a `--js-b2-report`
override for another independently successful attempt. Preserve the failed
attempt and use at least the corrected64 MiB JS output guard budget.

```sh
python3 -B selfhost/tests/phase174/prepare-release.py \
  --out selfhost/build/phase174/release-inputs
python3 -B selfhost/tests/phase170/promotion.py \
  --recipe selfhost/build/phase174/release-inputs/recipe.json \
  --out selfhost/build/phase174/promotion
python3 -B selfhost/tools/build/release.py audit \
  --manifest selfhost/build/phase174/promotion/promotion.json \
  --out selfhost/build/phase174/promotion-audit.json
```

Run its proposal audit, then unchanged `release.py audit`. Only after they pass,
run `release.py install` with a fresh transaction root. It stages/authenticates
bytes, backs up actual destinations and replaces `current.json` **last**. Keep the
rollback map, mutation journal and previous selector. Update the three operational
asset maps (`assets-native`, `assets-session`, `assets-c-request`) through a separate
audited selector transaction, changing only the selected artifacts/receipts/source
bindings and proved capabilities. Do not mutate maps used by in-flight builds.

Finally `release.py verify --manifest selfhost/manifests/current.json`, verify all
operational asset maps, and run the existing installed native/hosted `nt-reverse`,
native session and public JS/C smoke contracts. JS under the existing pinned Node24
must print `42`; C must emit the independent expected C bytes and its normal
qualified proof diagnostic. Do not require empty public-C stderr: that caused a
spurious Phase170 failure. The completed installation report must distinguish
fresh gates, exact-artifact inheritance, finite checks and unclaimed capabilities.
