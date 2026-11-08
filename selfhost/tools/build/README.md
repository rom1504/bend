# Maintained compiler build tools

These tools assemble the maintained Bend source, run an explicitly identified
compiler, capture its complete product, and construct native products. Compiler
checking and optimization remain in Bend. Tool code does not import an experiment
implementation or reconstruct the compiler from a sequence of historical patches.

The operational asset map is
[`assets-native.json`](../../manifests/assets-native.json). It binds a compiler
image's actual host, generation, entry protocol, capabilities and source identity;
the Base/carrier pair; runtime providers; and machine tools. Its initial native
image is the qualified ordinary N2 image, not an installed or incremental-qualified
selection. A successful build does not change the installed compiler.

## Inputs and artifacts

| Tool | Responsibility | Output |
| --- | --- | --- |
| `source.py` | Assemble one editable source recipe; frozen verification is separate | Bend source and optional declaration map |
| `check-source.mjs` | Independently load/check the assembled source with pinned upstream and require zero unresolved holes; no API emission | Source acceptance, assumption counts and authenticated inputs |
| `assets.py` | Verify named pins or acquire exact files from explicit local inputs | Acquisition receipt; at most the declared asset bytes |
| `request.py` | One JS-hosted or native compiler request with explicit target/stage | Raw JS/C/QBE product, command, timing and input/output pins |
| `hosted.mjs` | IO adapter for the checked Bend API; upstream checked B1 acquisition | Raw product and worker report, or checked API with image binding |
| `base-prepare.mjs` | Explicit checked API and Base; fresh Bend-produced mandatory preparation | Private frame4 and authenticated producer receipt |
| `base-carrier.mjs` | Offline strict frame4 transport, with no compiler execution | P88/P130 carriers and reversible-transcoding receipt |
| `base-verify.mjs` | Explicit checked consumer; full frame/live/P88/P130 value comparison | Complete hosted preparation/decoder equality receipt |
| `native.py` | QBE emission/machine construction with a 64 KiB transport buffer | Assembly, object, ELF, full QBE digest; optional retained QBE |
| `runtime.py` | Explicit maintained QBE runtime source/header recipe | Runtime object and exact comparison to its qualified reference |
| `bootstrap.py` | Actual N1 → N2 → Q3 execution | Separate fixed-point, machine-identity and generation evidence |
| `common.py` | Streaming identities, fresh paths and bounded child lifecycle | No resource admission or compiler semantics |

Release promotion is separate: [`RELEASE.md`](RELEASE.md) specifies the bounded
current selector, independent gate audit, and rollback-capable `release.py`
installer. Build success alone cannot install or qualify a release.

Use one outer [disk/process guard](../build-retention/README.md) for a target run.
Every output path must be a fresh child of the explicitly selected workspace's
`selfhost/build`. These builders never acquire another guard. Their child deadlines
and failure cleanup also work when imported by a guarded campaign. Start another
run with a fresh path; do not overwrite or alter a consumed receipt.

`--host` names the executing compiler runtime (`js` or `native`), `--target`
names the emitted language (`js`, `c`, `qbe`), and `--stage` names the actual image
generation recorded by its producer. These fields are checked, not inferred from
a directory name. Native image construction can provide `--output-stage N1` and
an entry protocol to record a derived compiler; that claim is distinct from
semantic qualification or a release selection. In particular, B1/B2 describe
JS compiler generations and N1/N2 describe native compiler generations.

## Acquire and verify bootstrap assets

The initial bounded copy set is about 108.4 MiB: native N2, checked QBE API,
runtime object, prepared Base, QBE and Bun. Assembler, linker, Clang and pinned
upstream files are declared external pins. Runtime source/effect files are
maintained repository paths. Acquisition refuses changed existing files and
requires its bytes plus the 5 GiB mount reserve.

Supply the original files explicitly; a local JSON binding maps asset names to
absolute files. The acquisition tool does not read the historical provenance map
to discover those files and does not contact the network.

```sh
python3 -B selfhost/tools/build/assets.py acquire \
  --manifest selfhost/manifests/assets-native.json \
  --bindings /absolute/local-asset-bindings.json \
  --receipt selfhost/build/consolidation/assets-acquisition-fresh.json

python3 -B selfhost/tools/build/assets.py verify \
  --manifest selfhost/manifests/assets-native.json
```

A binding file can be replaced with repeated `--from NAME=/absolute/file`.
Select a bounded subset with repeated `--key NAME`. Copies are published only
under `selfhost/.assets`, with atomic no-clobber creation. Existing external
assets must already match their explicit pin; they are never overwritten.

The prepared carrier's stamp includes the **exact Base source path**, in addition
to Base bytes and ABI identities. A fresh worktree may explicitly use the pinned
external bootstrap checkout at that path. Relocating that Base invalidates cache
admission, even when its bytes are identical. Use `--mode live` with an explicitly
rebound Base asset; preparing and qualifying a new cache identity is separate work.
The original checked QBE-only API did not export live preparation, so its binding
advertises cache mode only. A fresh union API supports live/cache QBE and live JS/C.

Historical producer receipts and original file locations are recorded separately
in [`assets-native-provenance.json`](../../manifests/assets-native-provenance.json).
They explain derivation and recovery; they are not recursively read by a build.
Generated bootstrap assets remain separate from maintained compiler source.

## Prepare a new Base carrier

Use an explicitly checked hosted API report and the exact canonical Base path
that subsequent requests will use. Within one outer guard, run these commands
in order, declaring each output directory as a run root (or their common fresh
parent). Substitute the pinned engine for `node` where necessary.

```sh
node selfhost/tools/build/base-prepare.mjs \
  --authority selfhost/build/example/typed-api/report.json \
  --base /absolute/pinned/upstream/bend2/base.bend \
  --out selfhost/build/example/base-preparation

node selfhost/tools/build/base-carrier.mjs \
  --preparation selfhost/build/example/base-preparation/report.json \
  --out selfhost/build/example/base-carrier

node selfhost/tools/build/base-verify.mjs \
  --carrier selfhost/build/example/base-carrier/report.json \
  --authority selfhost/build/example/qbe-api/report.json \
  --out selfhost/build/example/base-verification
```

The producer calls maintained `prepareBase` with `backendProducts:false`, an
explicit private cache directory, and `fresh:true`. It bypasses cache reading
entirely: no earlier frame, global cache or optional annotation sidecar is used.
All loading, checking and readiness construction execute the selected Bend API.
The offline serializer authenticates the exact API, source, Base bytes/path,
frame and current transport tools. It preserves strict term ABI1/span ABI3/world
version3 validation, backward references and readiness/alias checks; bounds remain
65,536 nodes, 4,096 strings and 16 MiB per native carrier.

The serializer is a maintained extraction of the two transport scripts at commit
`449b01ad25dcea16d20fb68c6a46937e4f542d91`, formerly
`selfhost/tools/performance/phase88/base/carrier.mjs` and
`selfhost/tools/performance/phase130/base/carrier.mjs`. It imports the maintained
codec only and has no historical compiler or phase snapshot dependency.

Verification runs `p86_prepare` and `p88_cache_prepare` from a checked API built
from the same compiler source as the producer (the export sets may differ). It
compares canonical bytes for every prepared root, including source spans and
flags, and compares complete source identity for live, decimal and word-pair
preparation. It does not sample declarations. These receipts do not grant native
admission or installation: qualify actual native live/cache requests and bind the
new carrier, source identity and stamp explicitly in the operational asset map.

## Assemble and preflight

The current module recipe accepts body edits. `verify` checks its frozen extraction
identity; `refresh` creates an explicit new declaration inventory when definitions
are added or removed. The profiles differ only in their entry contract.

```sh
python3 -B selfhost/tools/build/source.py assemble \
  --manifest selfhost/src/compiler.json --root selfhost \
  --profile qbe --out selfhost/build/example/compiler.bend \
  --map selfhost/build/example/compiler.map.json

python3 -B selfhost/tools/build/request.py \
  --assets selfhost/manifests/assets-native.json \
  --image-key qbe-n2 --host native --target qbe --stage N2 \
  --source /absolute/program.bend --mode cache \
  --out selfhost/build/example/request --plan
```

`--plan` authenticates all declared request inputs and prints the exact command
without executing a compiler or creating its output directory. Unsupported
host/target/entry combinations fail. The pinned native QBE image cannot emit C
or JS simply by changing `--target`; an actual appropriate derived image is needed.

For source checking without JavaScript emission, run the pinned Bun engine under
the same outer resource guard:

```sh
selfhost/.assets/bin/bun selfhost/tools/build/check-source.mjs \
  --source selfhost/build/example/compiler.bend \
  --out selfhost/build/example/source-check
```

This uses the unmodified upstream `book_load`, `book_valid` and zero-hole gates
from checked API acquisition. The current adapter permits the assembled source
plus its pinned Base import only. It neither emits nor executes the candidate,
checks backend ownership, proves its unsafe assumptions, nor invokes BendTT.
Generated-code, semantic and native qualification gates remain separate.

## Emit or build a program

This example performs one emission with complete raw-byte capture. It deliberately
does not strip trailing newlines or normalize native `IO.print` output.

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/example/request-guard \
  --run-root selfhost/build/example/request \
  --seconds 360 --disk-mib 1024 --rss-mib 8192 --available-mib 16384 --cpu 3 -- \
  python3 -B selfhost/tools/build/request.py \
    --assets selfhost/manifests/assets-native.json \
    --image-key qbe-n2 --host native --target qbe --stage N2 \
    --source /absolute/program.bend --mode cache --seconds 300 \
    --out selfhost/build/example/request
```

Replace `request.py` with `native.py` to stream directly through QBE, aligned GNU
assembler and the pinned non-PIE link policy. Add `--retain-ir` when the complete
QBE product is needed; its digest is recorded in either mode. Alternatively,
`native.py --assets MANIFEST --ir PROGRAM.ssa --out FRESH` constructs an existing
QBE product without executing a compiler. `--expected-qbe FILE` checks complete
IR bytes/digest; `--expected-stdout FILE` executes the product and compares complete
output. These oracles must come from an independent reference or prior qualified
generation, not a copy of the just-produced output.

The default QBE runtime object has one Bend heap mutator, permits host IO workers,
and supports the pinned direct-QBE foreign-provider table. It is not arbitrary
C embedding/callback support. An explicit `--runtime FILE` is accepted as a new,
unqualified runtime binding; the builder never inherits the default runtime's
qualification for different bytes. The executing compiler's linked runtime and
the emitted program's construction runtime are separately recorded.

To construct a native C-emitting compiler from the same module tree, assemble
`--profile native-c`, then run `native.py` with a QBE-emitting producer and
`--output-stage N1 --output-protocol native-c-source-v1`. The resulting image
binding records the required CLI sentinel. A subsequent `request.py --host native
--target c --stage N1 --image IMAGE --image-receipt BUILD/report.json` uses explicit
C runtime/effect provider pins from `selfhost/manifests/assets-c-request.json`.
That fresh asset boundary also pins the existing Bend-produced
`runtime-template.json`: its five insertion boundaries and complete concatenation
are authenticated before the host writes request-local `runtime.c.part0` through
`.part4`. The host does not search for template markers or split the runtime.
Native C success diagnostics must follow the exact preparation/request timing and
verdict protocol; unknown lines, changed ordering and consumed-character mismatch
fail. An `unsafe-or-foreign` dependency verdict is preserved explicitly and never
converted into a mathematical-validity claim. C machine compilation and execution are separate
qualification steps with the manifest's pinned Clang policy. They do not inherit
the serial QBE runtime object.

The runtime can itself be reconstructed from `selfhost/src/runtime/qbe`:

```sh
python3 -B selfhost/tools/build/runtime.py \
  --assets selfhost/manifests/assets-runtime.json \
  --out selfhost/build/example/runtime --seconds 90
```

Run it inside the same outer guard convention. `--plan` performs metadata checks
only. The recipe pins GCC, the maintained source and both quoted headers, rejects
unbound quoted includes, uses the preserved serial-RFC flags, and compares the
entire rebuilt object against the explicitly pinned qualified object. System
libc/toolchain installations remain declared external dependencies; this is not
a claim of a hermetic C toolchain. A source/flag change needs a new explicit
binding and independent ABI qualification.

## Checked hosted API and actual bootstrap generations

For a fresh checked B1 API, invoke the maintained `hosted.mjs acquire` inside the
same outer guard, with explicit `--source`, `--out`, `--upstream` and `--engine`.
The acquisition checks the entire source with pinned upstream and exposes the
roots listed in `hosted-exports.json`. It records a B1 image binding. JS/C requests
use that image with `--host js --stage B1 --mode live`, `--image API.mjs` and
`--image-receipt API/report.json`. Existing public typed-driver interfaces remain
available; target/runtime compatibility is checked by the maintained adapter.

`bootstrap.py` accepts the same explicit producer request and builds actual N1,
executes it to build actual N2, then executes that N2 to emit Q3. It retains QBE
for complete comparison. Its whole-chain deadline applies to all three steps.
Assembly/object/ELF identity is reported separately; a machine-layout difference
does not bypass actual N2 execution. `semanticsQualified` and `selected` remain
false: corpus/reference/law controls must establish those claims separately.

```sh
python3 -B selfhost/tools/build/bootstrap.py \
  --assets selfhost/manifests/assets-native.json \
  --image-key qbe-n2 --host native --target qbe --stage N2 \
  --source /absolute/current-qbe-entry.bend --mode cache \
  --out selfhost/build/example/bootstrap --seconds 1200
```

Wrap the preceding command in one guard with a sufficient time/disk budget;
do not separately guard each internal generation.

## Migration and offline checks

| Historical implementation | Maintained responsibility |
| --- | --- |
| Phase130 `native-request.py` and Phase125 `native/native-emit.py` | `request.py`, `assets.py`, `common.py` |
| Phase134 `pipe/build-v02.py` | `native.py` bounded relay, full digest and process cleanup |
| Phase123 `build-aligned.py` | `native.py` explicit machine policy |
| Phase111 `check-api.py` | `hosted.mjs acquire` and existing `stage0-library.mjs` |
| Phase-specific source preparation/patch chains | `source.py` and the maintained source recipe |
| Per-experiment N1/N2/Q3 orchestration | `bootstrap.py` actual generation execution |

The initial operational binary/runtime/carrier/tool assets are exact byte copies
of previously qualified products, with their provenance preserved separately.
Their recipes and historical evidence remain recoverable from Git/evidence
capsules; none of the predecessor Python implementations is imported here.
The `phase111` string in the native request is an existing CLI sentinel, not a
filesystem dependency. Historical names inside compiler declarations likewise do
not imply source reconstruction.

```sh
python3 -B -W error::ResourceWarning selfhost/tools/build/test_build.py
```

These bounded tests execute only Python fixture producers/consumers. They cover
identity/stamp changes, cache-path relocation, immutable asset acquisition,
host/stage/target refusal, exact trailing newlines, bounded streaming, early child
failure and deadline cleanup. They establish host-tool behavior, not compiler
correctness or performance. Actual target/continuity evidence belongs in the
consolidation qualification reports.

## Public native C compiler

Use the qualified public package with its native-public-cli-v1 image binding:

```sh
python3 -B selfhost/tools/build/request.py \
  --assets selfhost/manifests/assets-c-request.json \
  --image /absolute/package/bend --image-receipt /absolute/package/BUILD.json \
  --host native --target c --stage N1 --mode cache \
  --source /absolute/program.bend --out selfhost/build/example/public-request
```

Run inside the single outer guard. This entry receives only INPUT, -o OUTPUT and
optional --live. The public startup owns CPU/GPU/runtime arguments. The adapter
authenticates the image binding's exact sixteen sibling assets, checks the five
runtime parts against targetRuntime, and records their actual package locations.
The package owns its Base, cache and runtime; unrelated external Base/runtime
assets are not read, and custom Base/cache-key overrides are refused.

Success stderr must be exactly the proof-verdict grammar; prepared-entry timing
lines and arbitrary extra diagnostics fail. The publicVerdict observation preserves
unsafe/foreign dependency reports without claiming mathematical validity. Nonzero
process status always remains failure. This is distinct from the build-only
native-c-source-v1 entry and does not reuse its argv or telemetry protocol.
