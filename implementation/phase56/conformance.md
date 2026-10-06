# Phase56 B2 qualification

## Selected String equality image: completed qualification

The selected direct B2 image freshly type-checks its own complete source and
passes all eight broader semantic jobs. The
[explicit image binding](../../selfhost/build/phase56/bootstrap-string01-plan/image-pins.json)
ties B2 `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`
to checked B1 `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`
and source `5356ec9963db7b300e8cbdf5474328b72150f582df96b01aeea29d6a07868244`.
These are fresh observations of this image, not reused baseline executions.

The [fresh source-check receipt](../../selfhost/build/phase56/self-check-string01/report.json)
is complete/pass: the ordinary driver reports `checked: true` and
`typeAccepted: true`. All 3,012 unique definitions are explicitly unsafe;
the exact returned unsafe list contains those 3,012 names and no extras.
`proofTrust: failed` and `kernelChecked: false` remain explicit. The worker
records 29.681 seconds inside the source-check call; its
[supervisor](../../selfhost/build/phase56/self-check-string01-supervisor/run.json)
records 35.570 seconds overall and 798,896,128 bytes peak process-tree RSS.
This is a bounded diagnostic observation, not a controlled speed comparison
with the profiled baseline check below. Receipt SHA-256:
`5a366be103a45895bb8a7d0669f1245a0d2e8a7692981101866cedde2d07868e`.

| Selected B2 runtime gate | Candidate | Pinned TS | Receipt SHA-256 |
|---|---:|---:|---|
| [Source](../../selfhost/build/phase56/semantic-string01/source-controls/report.json) | 96/96 | 95/96 | `1230d72cb17a22554ba61604d30f685deeacfe01454e819f616cd2a285d444ee` |
| [Numeric](../../selfhost/build/phase56/semantic-string01/numeric-controls/report.json) | 34/34 | 28/34 | `29fe40ce5ecf1000fd1de560f5250fbacf152f1d2e6abf2241a1cac8558895d1` |
| [Composition](../../selfhost/build/phase56/semantic-string01/composition-controls/report.json) | 18/18 | 18/18 | `329c03648258a4ffd9a2c5da41988cb6bf4f42b2dde2b90f723044e1c6f5ab44` |
| [Overapplication](../../selfhost/build/phase56/semantic-string01/overapplication-controls/report.json) | 2/2 | 2/2 | `fa01a81d68f6331f3b6de881c205fc6dc9f2bbcdd155544275b27eb3a860357b` |

The [eight-job execution receipt](../../selfhost/build/phase56/semantic-string01-execution/report.json)
is complete/pass. Four acquisitions freshly check 33 fixture sources, followed
by the unchanged runtime oracles. Counts overlap; the known TS NaN failures
remain explicit failures, not differential agreements. No mathematical proof
or full-language conformance is inferred.

The focused [String definition gate](../../selfhost/build/phase56/string-controls02/report.json)
also passes: 484 primitive UTF-16 string pairs, eight order/demand/throw cases,
two user-native-name observations, two duplicate-Base declaration refusals,
and three separately instrumented native entries. Its supervisor records
19.190 seconds and 603,381,760 bytes peak process-tree RSS. Receipt SHA-256:
`050f7b292d1a497c086ef0f4de521d5b0af58f71d0e49f428a55a266a64ea508`.
The failed v1 parser-loader attempt is preserved below.

The [B2-to-selected-B1 benchmark gate](../../selfhost/build/phase56/benchmark-b2-string01/report.json)
also completed: B2 freshly checks all 23 sources, reproduces all 23 raw modules,
and matches all 45 point outputs byte-for-byte, representing 24 unique modules
including the complete-row observer. A read-only review independently reread
the actual source/module bytes and confirmed those counts. No generated
benchmark program was executed by this gate. Its
[supervisor](../../selfhost/build/phase56/benchmark-b2-string01-supervisor/run.json)
records 60.496 seconds and 665,669,632 bytes peak process-tree RSS. Receipt
SHA-256 is `fd484566cab75a7debf48cde6987fc5b7334bc5a75ae7a69f08c5fd1fc009d02`.
This connects B2's output to the selected B1 benchmark evidence; it does not
claim that changed selected-B1 programs equal historical output. Independent
B2→B3 reproduction is reported by the bootstrap workstream.

## Installed checked B1 and retained compatibility

The selected checked B1 is installed. All eight maintained legacy suites pass,
including the 37 IR checks, 72 arm observations, 1,129 primitive guards and
25 primitive observations; these are overlapping internal suite counts. All
42 legacy and 24 default/relocated package checks pass, including integrity and
tamper/restoration. The [independent release review](../../selfhost/tools/performance/phase56/evidence/release-review.json)
binds the five executed release jobs, installed identities and seven preserved
previous-release files. The [publication index](../../selfhost/tools/performance/phase56/publication.json)
links the closed raw archive. B2's independent qualification does not change the
installed B1's artifact kind.

## Baseline Phase55 B2: completed historical qualification

B2 freshly type-checks its complete original source. The
[completed receipt](../../selfhost/build/phase56/self-check-b2-01/report.json)
is complete/pass with `typeAccepted: true` and `checked: true`; the separate
proof-trust result remains `failed`, as expected for all 3,019 explicitly
unsafe definitions. The returned unsafe set contains exactly those 3,019
names, with no additional declarations. Kernel verification and mathematical
validity are not claimed.

The [bounded supervisor](../../selfhost/build/phase56/self-check-b2-01-supervisor/run.json)
records 62.707 seconds and 845,799,424 bytes peak process-tree RSS. The worker's
ordinary full-source check took 55.839 seconds. Root enabled V8 profiling;
these are diagnostic timings, not an unprofiled throughput measurement.
The private Base cache started empty, was produced by the actual B2 image,
and remained inside Phase56. Receipt SHA-256 is
`8dc17a427118b3c5a9cd1411c068325c33ae458b592ef7f89f5c44851a954ac6`;
supervisor SHA-256 is
`03b84e593639d79e9378307987e975fc7c65506d5791c3b494f8d87d7937a2cf`.
The broader eight-job semantic plan also completed: all 33 source acquisitions
were freshly checked by this B2, and the four unchanged independent runtime
controllers passed. Candidate counts are source **96/96**, numeric **34/34**,
composition **18/18** and genuine overapplication **2/2**. These scopes overlap.
The pinned TypeScript reference remains 95/96 and 28/34 in the first two scopes;
its documented NaN defects are retained, not counted as agreements.

| Completed baseline B2 gate | Receipt SHA-256 |
|---|---|
| [Source 96](../../selfhost/build/phase56/semantic-b2-01/source-controls/report.json) | `9355783bd62594d559fceb2be2852d9066e55599778710771fdec697597c42c4` |
| [Numeric 34](../../selfhost/build/phase56/semantic-b2-01/numeric-controls/report.json) | `700d821544506022834a0af01472fc8bab317fb0d2b02de3ed90ac26c9f2ca50` |
| [Composition 18](../../selfhost/build/phase56/semantic-b2-01/composition-controls/report.json) | `f1e098cd9bedf914c7264584f65480428a055519cd3f03cf1ba2e6d4b7bffa2c` |
| [Overapplication 2](../../selfhost/build/phase56/semantic-b2-01/overapplication-controls/report.json) | `cbccbe2c367547b28059dac921a861393019c98d5b61a2a44e54994b8e02c2aa` |

This plan exercises the actual compiler image emitted in Phase55. It does not
turn that image into a synthetic checked development attempt. Target execution
and any eventual selection are separate from preparation of these tools.

The input image is
[`bootstrap-own-host02-full01/compiler.mjs`](../../selfhost/build/phase55/bootstrap-own-host02-full01/compiler.mjs),
SHA-256 `ae5abd461c24f707747f37b187cedcecd86f5d3c727950f8f8a332fd9dca4091`.
Its original [emission receipt](../../selfhost/build/phase55/bootstrap-own-host02-full01/report.json)
binds the checked host02 generator API
`cfde1ebf44d958e593331cfd9af77f7b6ee657441dbd582db8d27f3928815a62`
to its exact source
`e4383fa08d621716acac437224de182af52e0b16c32b3f29b2614fc1ad1d6710`.
The source proof was inherited from that checked B1. Neither the historical
emission nor its eight ordinary-driver observations claimed a fresh complete
B2 source check or a B2→B3 fixed point.

The shared [setup](../../selfhost/tools/performance/phase56/bootstrap/setup.mjs)
verifies the checked subject and generator, tiny split/unsplit equivalence,
complete emitted bytes, all 77 public roots, direct runtime and the completed
eight-observation driver comparison. It copies the ordinary driver, required
host helpers, runtime files and exact image into a fresh Phase56 project. The
driver loads that image using its normal named-function route. No compiler
method wrapper, TypeScript compilation fallback, synthesized `attempt.json`
or invented bootstrap sidecar is involved. Each private project's Base cache
starts empty and is keyed by the actual B2 bytes. The original Phase55 source,
images, caches, tools and archived evidence are read-only inputs.

## Fresh complete-source type check

[self-check.mjs](../../selfhost/tools/performance/phase56/qualification/self-check.mjs)
calls the private ordinary driver's `inspect(exactSource, {mode: 'check'})`.
There is no injected API override, selected-definition subset or inherited
Base cache. Its final receipt requires complete type acceptance and records
the original result without suppressing diagnostics.

The exact source contains 3,019 unique function definitions, all directly
annotated `@unsafe`. Thus a successful complete type check is expected to end
with the ordinary driver's proof-trust rejection for a module without `main`.
The gate requires this specific shape:

- `checked: true`, `typeAccepted: true`, `kernelChecked: false`;
- `status: 'error'`, `phase: 'verdict'`, `exitCode: 1`, `proofTrust: 'failed'`;
- a unique unsafe-name list containing all 3,019 independently censused
  explicitly unsafe definitions;
- the exact ordinary verdict rendering of that ordered list.

Additional type or constructor declarations may transitively rely on unsafe
definitions; the receipt retains them separately. Parse, load and type-check
failures cannot satisfy this gate. A successful receipt means a **fresh complete
type check**, with an explicit proof-trust failure; it is not mathematical
validity or kernel verification.

Root's initial command is:

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 300 --rss-mib 2048 --available-mib 4096 \
  selfhost/build/phase56/self-check-b2-01-supervisor -- \
  taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase56/qualification/self-check.mjs \
  selfhost/build/phase55/bootstrap-own-host02-full01/report.json \
  selfhost/build/phase56/self-check-b2-01
```

Both output paths must be fresh. A timeout or memory limit is retained as a
failed bounded observation; it does not authorize increasing limits or
reclassifying partial checking as success.

## Independent semantic scopes

The prepared [eight-job plan](../../selfhost/tools/performance/phase56/qualification/launch-b2-02.json)
uses one fresh private image per catalog acquisition, then the existing
independent semantic oracles. The [acquisition worker](../../selfhost/tools/performance/phase56/qualification/acquire.mjs)
calls ordinary `inspect` with explicit direct emission, checks every fixture,
and records the exact program output and source/API/runtime/driver lineage.
Its `checked` observation refers to the **fixture program's actual B2 checker
result**, not to a checked compiler bootstrap.

| Scope | Fresh checked source files | Required runtime observations |
|---|---:|---|
| Composition order, captures and partial calls | 1 | Candidate and pinned TS 18/18 |
| Genuine overapplication | 1 | Candidate and pinned TS 2/2 |
| Original source semantics | 29 | Candidate 96/96; retain TS 95/96 and its exact documented defect |
| Numeric, bits and cold/repeated host behavior | 2 | Candidate 34/34; retain TS 28/34 and every mandatory differential order case |

These scopes overlap and are not summed into a language-conformance score.
Original source goldens, error/event order, aliasing, capture and demand
assertions remain mandatory. The pinned TypeScript NaN payload failures are
still reported as failed reference observations, not agreements or candidate
waivers.

The four [controller successors](../../selfhost/tools/performance/phase56/qualification/controls-derivation.json)
change provenance admission only. Their entire execution/oracle/count/exit
sections are byte-identical to the frozen Phase53 controllers; retained
worker and reference paths are explicit. The new
[image validator](../../selfhost/tools/performance/phase56/qualification/image-provenance.mjs)
requires the exact real B2 emission lineage and copied host inputs. It permits
different private cache directories only when the compiler image, source,
generator proof, runtime and driver bytes agree. A direct fixture receipt must
have compiler kind `direct-self-emitted-image` and no checked-attempt field.

All eight jobs have one outer bounded supervisor, CPU3, a 1 GiB Node heap,
2 GiB process-tree RSS cap, 4 GiB available-memory floor and 4 MiB JS stack.
Acquisition jobs initially have 300 seconds each; controllers retain 60-second
bounds, or 110 seconds for the 96-scenario source scope. Run serially and stop
on the first unexpected failure. The plan materializer does not execute jobs:

```sh
python3 -B selfhost/tools/performance/phase56/qualification/plan.py \
  --out-base selfhost/build/phase56/NEW_SEMANTIC_OUTPUT \
  --plan-file selfhost/build/phase56/NEW_SEMANTIC_PLAN.json
```

`launch-b2-01.json` is an unexecuted drafting artifact; the reviewed successor
is `launch-b2-02.json`. The latter's fixed output root is
`build/phase56/semantic-b2-01`. Do not reuse existing output directories.

## What remains separate

B2→B3 whole-image equality is a distinct reproduction gate owned by the
bootstrap workstream. It cannot stand in for these independent semantic
observations, and neither gate proves universal compiler soundness.

Preserving the historical generated-program performance result additionally
requires B2 to check and compile the 23 benchmark sources and compare all 45
point modules, including the complete-row observer, against the retained
Phase53/55 bytes. The same private acquisition method can serve that gate;
the extra work is emission and exact-byte comparison, not a new 669-sample
timing campaign. It is deferred until the complete-source and semantic gates
are ready. No performance-retention claim follows from preparation alone.

For the String equality candidate, the immediate reference is its newly
selected B1 acquisition, not historical Phase53/55 output. The completed
[benchmark equality gate](../../selfhost/tools/performance/phase56/qualification/benchmark-equality.mjs)
accepts the candidate's explicit B2 image pins and that complete 45-point B1
manifest. B2 must freshly check all 23 sources, reproduce their raw modules
exactly, and reproduce the unchanged named-field complete-row observer.
The gate requires 45 equal point modules, representing 24 unique module bytes.
It executes the compiler only. Old-versus-new B1 code changes and performance
remain a separate workstream; B2 equality cannot transfer an old timing claim
across a changed B1 output.

## String equality controls and preserved harness failure

The additive [String controller](../../selfhost/tools/performance/phase56/qualification/string-controls-v2.mjs)
compares checked host02 with the candidate through two private ordinary-driver
projects. Their runtime, driver and Base identities must agree; source emission
and Base checking actually use each selected compiler. Nothing is written to
the closed Phase55 snapshot or its caches. The independently reviewed v2
completed successfully with the counts recorded above. The
[first run](../../selfhost/build/phase56/string-controls01/report.json) checked
the initial source successfully, then failed before any runtime oracle because
the harness loaded Acorn without its CommonJS `module` binding. The preserved
[v2 derivation](../../selfhost/tools/performance/phase56/qualification/string-controls-v2.derivation.json)
fixes that parser binding only; all sources and semantic expectations remain
unchanged. A tiny parser-only check passes with Node's Acorn 8.16.0.

The 22 primitive JS strings yield 484 ordered pairs. Their independent oracle
compares length and integer UTF-16 code units. Inputs include empty strings,
NULs, non-BMP pairs, decomposed versus precomposed text, unmatched/reversed
surrogates, and 1,024-unit equal/late-different strings. This tests string equality,
not Unicode normalization or boxed-host-value coercion.

Eight explicit event oracles cover left-to-right callback arguments, throws
that suppress later work, the packed tuple whose numeric prefix runs before
the pending equality call, and an equality closure whose supplied callback
must remain deferred until application. A separately emitted no-Base fixture
defines an ordinary function named `String.eq` returning `Different{}` even
for identical arguments. A maintained duplicate-Base declaration must still
be rejected. The duplicate declaration is not misrepresented as a valid shadow.

The candidate's exact native definition must contain strict equality while
the caller remains an ordinary named call. Untouched modules supply all value
and event observations; a separate saved counter derivative requires three
actual native-definition entries. It supplies activation evidence only.
Nonprimitive host String objects and arbitrary builtin prototype hooks remain
outside this gate's stated contract.

The completed candidate B2 successors use
[explicit image pins](../../selfhost/tools/performance/phase56/bootstrap/setup-v2.mjs)
after its own-source emission and eight driver observations pass.
[Their recorded derivation](../../selfhost/tools/performance/phase56/qualification/controls-derivation-v2.json)
preserves every semantic oracle tail byte-for-byte. The fresh self-check
successor independently requires the candidate assembly's 3,012 unique unsafe
definitions and the same exact trust-verdict contract. Their fresh completed
receipts are listed at the top; they do not transfer the historical B2's
results to new image bytes.
