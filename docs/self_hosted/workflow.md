# Maintained compiler workflow

Edit the Bend modules under [`selfhost/src/`](../../selfhost/src/). Their
[canonical manifest](../../selfhost/src/compiler.json) defines declaration order,
entry profiles and protected verifier/proof declarations. Build products,
prepared Base images, compiler executables and benchmark artifacts are explicit
inputs or outputs, not editable alternative compiler sources.

The [consolidation design](../../design/repository-consolidation/README.md)
records migration boundaries; the [Phase182 report](../../implementation/phase182/README.md)
records current installed qualification. Current tools live under
[`tools/build/`](../../selfhost/tools/build/),
[`tools/bench/`](../../selfhost/tools/bench/README.md),
[`tools/profiler/`](../../selfhost/tools/profiler/README.md),
[`tools/conformance/`](../../selfhost/tools/conformance/), and
[`tools/build-retention/`](../../selfhost/tools/build-retention/README.md).
Historical experiments are read through the
[history/recovery index](../../selfhost/tools/history/README.md), not imported as
the current implementation.

## Installed commands and current source

The existing public entry points are:

```sh
node selfhost/cli.mjs input.bend --run
selfhost/bend input.bend -o output.c
```

The installed [current selector](../../selfhost/manifests/current.json) binds
JS B2, public native C N1 and qualified QBE N2 to their recorded source and
qualification evidence. Phase182 installs all three from its recorded snapshot08
source, with an explicit thin profile for the public C CLI. The default
`qbe-n2` asset points to `selfhost/dist/qbe/bend`; `qbe-api` selects the separately
checked, cache-only B1 API at `selfhost/dist/qbe/hosted-api.mjs`. Native P140/2
positive reuse has its own gate; native error recovery and object-unit support
are not inferred from that result. A new assembly, successful small differential run or
moved tool does not install another release. Package availability, supported
imports/effects and image identities change only through qualified promotion.

The installed source incorporates the earlier Phase175/177 frontend improvements
and Phase178 cleanup, plus the upstream2.0.40 compatibility port. The selected
native N2 has actual same-source N1/N2/Q3 reproduction. The JS B2 has actual B3
self-reproduction and a fresh own-source check. These gates establish reproduction
and finite tested behavior, not whole-compiler correctness.

Full JS self-hosting on the pinned Bun1.4.3 required the explicitly recorded
`BUN_JSC_maxPerThreadStackUsage=7340032` setting; default-stack emission overflowed.
This Bun debugging option is unstable and specific to the pinned host. It is not
set automatically for ordinary commands. See the
[diagnosis, evidence and bounded invocation](../../implementation/phase182/js-stack.md).
Ordinary JS/C focused tests ran with the default host stack. Prefer the qualified
native compiler for ordinary compiler-development builds.

Generated program targets remain available through explicit interfaces:

| Program target | Current route |
| --- | --- |
| JavaScript | `node selfhost/cli.mjs input.bend -o output.mjs`; maintained `request.py --host js --target js --mode live` also accepts an explicitly checked hosted API and its binding. |
| C | `selfhost/bend input.bend -o output.c`; maintained `request.py --host native --target c` accepts the matching native-C or public-CLI binding and `assets-c-request.json`. The pinned C toolchain builds emitted C separately. |
| QBE/native | Maintained `request.py --target qbe` emits IR; `native.py` constructs its executable using the explicit QBE/runtime/assembler/linker assets. The public CLI is not a QBE selector. |

Host and stage must match the selected image. The original 45 benchmark catalog
uses JS callable libraries; its native 45 catalog uses the corresponding C/QBE
repetition wrappers. The same benchmark entry can execute all three targets, but
migration correctness gates and historical performance measurements have separate scopes; Phase182 does not publish a fresh broad speed comparison.

The maintained source has five entry profiles:

| Profile | Entry/API purpose | Qualification boundary |
| --- | --- | --- |
| `qbe` | Ordinary direct-QBE compiler entry | Exact extraction can inherit its frozen source identity; edits require fresh checking and relevant native gates. |
| `native-c` | The same source with the native C request entry | Shared source does not by itself inherit the older installed C compiler's full qualification. |
| `js-api` | The same source without a CLI main, for checked hosted APIs | Exports and the executing JS engine are separate authenticated image inputs. |
| `qbe-policy` | QBE entry with explicit optimization-policy selection | Experimental policy behavior requires its own gates; it does not replace the ordinary installed entry. |
| `qbe-policy-test` | Policy comparison/test entry | Test interface, not a separately qualified installed compiler. |

These profiles do not promise every host × target combination. The
[operational asset manifest](../../selfhost/manifests/assets-native.json)
advertises the actual images, their host/stage/target capabilities, Base/carrier
identity, runtime policies and machine toolchain. Unsupported combinations fail;
the tools do not substitute another compiler behind the request.

## Assemble before building

Run from the repository root and choose fresh output paths:

```sh
python3 -B selfhost/tools/build/source.py assemble \
  --manifest selfhost/src/compiler.json --root selfhost --profile qbe \
  --out selfhost/build/current-source01/compiler.bend \
  --map selfhost/build/current-source01/compiler.bend.map.json
```

Select `--profile native-c` or `--profile js-api` for the other entry contracts.
Assembly reads maintained modules; it does not replay a historical overlay chain
or execute a compiler. Ordinary declaration-body edits are allowed while the
manifest's protected verifier/proof declarations remain checked. Adding or
removing declarations requires the explicit `source.py refresh` inventory step
and review; it does not silently change declaration order.

For independent source acceptance without emitting another JavaScript API, use
[`check-source.mjs`](../../selfhost/tools/build/check-source.mjs) with the pinned
Bun engine and the ordinary outer resource guard:

```sh
selfhost/.assets/bin/bun selfhost/tools/build/check-source.mjs \
  --source selfhost/build/current-source01/compiler.bend \
  --out selfhost/build/current-source01/check
```

This checks the assembled source and pinned Base with upstream `book_valid`,
requiring zero unresolved holes. It is not BendTT verification, backend ownership
validation, generated-program execution or native qualification.

```sh
python3 -B selfhost/tools/build/source.py verify \
  --manifest selfhost/src/compiler.json --root selfhost
```

`verify` compares against the frozen extraction identity. It is useful for a
source-only migration and is **not** a typecheck or a qualification command for
edited source. An expected identity difference after an intentional edit is not
a substitute for checking that edit.

## Authenticate and run an explicit request

`request.py` binds a source and a real executing image. It distinguishes an
image's linked runtime from the target runtime/provider. Preflight runs no target:

```sh
python3 -B selfhost/tools/build/request.py \
  --assets selfhost/manifests/assets-native.json \
  --image-key qbe-n2 --host native --stage N2 --target qbe --mode cache \
  --source selfhost/tools/bench/catalogs/native45/fixtures/mandelbrot.bend \
  --out selfhost/build/current-request01 --seconds 60 --plan
```

The manifest's current `qbe-n2` names a qualified retained image, not an image
implicitly rebuilt from today's edited modules. Use an explicit newly acquired
image plus its maintained image-binding receipt when testing a change. Missing
or changed assets fail admission. Acquisition/restoration must be explicit;
existing workspace files are not assumed trustworthy from their names alone.

For execution, wrap the same command without `--plan` in **one** resource guard:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/current-request01-guard \
  --run-root selfhost/build/current-request01 --disk-mib 512 \
  --seconds 75 --rss-mib 3072 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/build/request.py \
    --assets selfhost/manifests/assets-native.json \
    --image-key qbe-n2 --host native --stage N2 --target qbe --mode cache \
    --source selfhost/tools/bench/catalogs/native45/fixtures/mandelbrot.bend \
    --out selfhost/build/current-request01 --seconds 60
```

This is a small compiler request, not a full compiler bootstrap. Its internal
checker and exact optional output oracle remain separate from independent source
checking. `--mode live` selects live Base only when the image advertises it;
prepared and live modes must stay distinct in results.

`native.py` adds bounded QBE→assembly→object→link construction using the manifest's
explicit runtime/toolchain policy. It accepts an authenticated compiler request
or a retained `--ir` input. Use `--expected` for an independent complete QBE
reference and `--expected-stdout` for a complete program-output reference.
Retaining textual IR is optional for ordinary work and explicit when qualification
requires it. Existing objects may be reused only under the separately documented
identity-based cache policy; a cold-build comparison must construct fresh objects.

`bootstrap.py` runs actual parent→N1→N2 generations and executes N2 to observe Q3.
Complete source/output identities, machine products and semantic gates are
separate evidence. Matching an ELF early is not permission to skip the next
generation; matching a fixed point is not a proof of compiler soundness. Budget
this gate explicitly after focused changes have passed; do not rebuild the whole
compiler for every tooling or fixture edit.

Experimental session/object reuse is maintained under
[`tools/build/session/`](../../selfhost/tools/build/session/). Its no-op, edit,
revert/error recovery and invalidation evidence belong to that mode. Ordinary
source qualification does not automatically qualify session behavior, and warm
edits do not replace cold compilation measurements.

## Package script entry points

The scripts in [`selfhost/package.json`](../../selfhost/package.json) are thin
names for these same maintained tools. `bootstrap` / `bootstrap:typed` acquire
a checked B1 API and require explicit `--source`, `--out`, `--upstream` and
`--engine`. `bootstrap:self` selects the genuine hosted self-bootstrap workflow;
`bootstrap:native` selects the native generation workflow. Neither installs its
result. `build` / `build:native` select direct-QBE construction with explicit
request/runtime/assets. Release installation and verification are separate from
construction: `release` forwards to `release.py install --manifest PROMOTION --out
FRESH_TRANSACTION`, `release:audit` forwards to `audit --manifest PROMOTION --out
FRESH_REPORT`, and `verify:release` verifies `manifests/current.json` from the
`selfhost` package directory. Verification requires an actually installed current
manifest; the tool's presence is not a promotion. See the [release contract](../../selfhost/tools/build/RELEASE.md).
Use `--` to pass required arguments through npm.

`survey` and `conformance` use the maintained conformance runner. `test:source`
is a metadata/source contract control requiring an explicit receipt; `test:build`
runs synthetic build-adapter fixtures. `test:self` requires explicit `--source`,
`--api` and `--base`, or an independent `--frontend`/`--checker` pair instead of
`--api`; optional `--report` must name a fresh file. These controls do not replace
a real bootstrap, independent output qualification or compiler/program speed measurements.

## Keep the metrics separate

| Dimension | Record it explicitly |
| --- | --- |
| Compiler host | JS under a pinned Node/Bun engine, or a native executable. |
| Generation | Actual checked B1/genuine B2 or native N1/N2 lineage; names are not interchangeable. |
| Output target | Direct JS, generated C, or direct QBE. |
| Preparation | Live Base or authenticated prepared Base/carrier; ordinary or session state. |
| Runtime/toolchain | Executing compiler runtime and generated-program runtime, with exact machine flags and threading policy. |
| Clock | Compiler request, source-to-executable construction, complete research loop, or generated-program execution. |

Cold compilation means a fresh process with no source-specific semantic state or
machine-object reuse. It does not imply flushed operating-system caches. Report
loading/parsing/checking, lowering/verifying/rendering, machine construction and
outer supervision at their actual boundaries; moving work outside an interval
does not count as speeding it up.

The [benchmark entry](../../selfhost/tools/bench/README.md) freezes compiler
commands and independent complete-output oracles, then rotates explicit roles in
fresh processes. It preserves both output target and generation rather than
calling every native comparison “B2”. For generated programs, acquisition and
compilation happen beforehand; only the prepared programs execute in that loop.
Upstream C can be the reference for QBE-generated executables, with that difference
visible in the role metadata.

Acquire selected benchmark products with the maintained
[`bench/acquire.py`](../../selfhost/tools/bench/acquire.py). A short role recipe
selects current build assets and actual images, and the tool fills every selected
case/product entry. It delegates checking/emission and QBE construction to the
maintained build tools, uses pinned upstream APIs for the independent reference,
and checks each generated product against its catalog oracle. See the
[current-assets native acquisition recipe](../../selfhost/tools/bench/examples/acquire-native.json)
and [B1/N2 QBE request recipe](../../selfhost/tools/bench/examples/acquire-compiler-qbe.json).
Run `--plan` first, then acquire under the outer guard; the separate acquisition
deadline is excluded from program execution budgets. Successful acquisition emits
frozen program and exact-output cold-request manifests automatically. A compiler
request ratio across different targets measures different backend work.

## Choose an iteration depth

Before broad generated-program acquisition, compare the candidate's complete
emitted QBE with retained qualified references (`request.py --expected`). If
source, output, runtime, machine toolchain and flags are identical, preserve the
identity receipt and reuse the qualified product. Build/time changed products
first; do not manufacture empirical timing ratios for unchanged products or
rename a changed-case subset as the full frozen benchmark. Phase152 rebuilt
and timed 45 cases before discovering identical QBE, assembly and objects for
every case; moving this identity gate earlier avoids that repeated work.

Use the maintained [original45 catalog](../../selfhost/tools/bench/catalogs/original45/catalog.json)
and [native45 timed wrappers](../../selfhost/tools/bench/catalogs/native45/catalog.json).
They preserve45 fixed input points from23 sources. Native timing has44 eligible
points plus an independently checked zero-work control. The older15-point JS
catalog remains explicitly named historical; it is not the broad corpus.

The program runner accepts20/60/300/600-second ceilings, independent case/set
selection, and explicit rounds. A20s screen can reject a local hypothesis;
60s checks transfer;300/600s can extend coverage and depth. These are ceilings,
not portable promises that every requested case completes. Partial/failed runs
remain incomplete; no input is reduced to fit and no historical timing becomes
a fresh denominator. Native calibration/counts and V8 warmup are different
protocols. See the [exact commands and boundaries](../../selfhost/tools/bench/README.md).

[`bench/smoke-plan.json`](../../selfhost/tools/bench/smoke-plan.json) and
[`bench/examples/`](../../selfhost/tools/bench/examples/) provide concrete acquisition recipes and bounded migration checks. The
`smoke-*` recipes name retained historical artifacts; `acquire-*` recipes bind
current build assets. Neither changes the installed compiler selection. The
[migration map](../../selfhost/tools/bench/migration-map.json) and
[validation status](../../selfhost/tools/bench/validation.json) distinguish exact
input/worker transfers, synthetic controls and pending/live adapter gates.

## Profile and inspect before changing code

Use the [generic native profiler](PROFILING.md) for clean clocks, CPU leaves,
active dispatch/source owners, authenticated physical callers and runtime events.
The [stage contract](../../selfhost/tools/profiler/STAGES.md) identifies exact
entry boundaries with required order/multiplicity. Stage intervals, allocation
counts, physical leaf samples and ownership work are different observations;
overlapping intervals must not be added together.

The benchmark [diagnostic planner](../../selfhost/tools/bench/diagnostics.py)
prepares V8 CPU/allocation profiles, JS AST/token comparisons and native profiler
jobs from the same pinned program artifacts. Native source inspection also
retains C/QBE lexical counts and ELF disassembly; lexical counts are not an AST
or a time profile. Diagnostics receive a separate budget and cannot supply clean
speed ratios. Main-thread-only captures with poor process-CPU coverage remain
insufficient attribution rather than silently losing worker time.

Reuse retained exact objects for instrumentation when the profiler's binding
checks permit it. Do not rebuild the compiler merely to inspect its already
generated machine code. Static site counts suggest a hypothesis; dynamic counts
and profiles narrow it; a controlled semantic change establishes its speed effect.

## Correctness and proof boundaries

Preserve independent expected outputs, invalid-source refusal, exact relevant
diagnostics, alias/ownership and public-interface controls. Source checking,
frontend/backend conformance, generated-program execution and bootstrap
reproduction are separate gates. A filtered suite cannot be reported as full
conformance, and a one-shot runtime check is not a performance campaign.

The [conformance infrastructure](../../selfhost/tools/conformance/) discovers
upstream fixtures and uses their independent output/refusal contracts. Bind the
active upstream pin and the real checked adapter; historical README defaults
do not identify the current image. The [law guide](COMPILER_LAWS.md) distinguishes
universal declarations independently checked by BendTT, source-extracted helper
contracts, finite production controls and unsupported whole-compiler claims.
Retain their independent references when source ownership changes.

Historical proof/gate recipes remain evidence until their maintained entry is
explicitly qualified. Consult the source/tool migration map before retiring a
unique control. Source consolidation does not strengthen a theorem, close an
unrun conformance gap, or enable a previously unsupported GPU/parallel policy.

## Evidence and recovery

Use fresh paths and the [retention policy](build-retention.md). Keep one controlled
target lane, declared output/disk budgets and complete failure receipts. Exact
artifact reuse must preserve source, policy, runtime, toolchain and oracle bindings.
Never edit a hardlinked retained artifact in place.

Current implementation paths and historical recovery records serve different
purposes. Retired code is restored from its authenticated Git revision and
declared non-Git assets through the [history tools](../../selfhost/tools/history/README.md).
It is not copied back into a second maintained compiler tree. The
[experiment frontier](../../experiments/STEERING.md) and each result's receipt
state what is qualified, installed, experimental or still incomplete.
