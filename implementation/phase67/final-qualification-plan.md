# Minimal final qualification for native-only changes

This plan is prospective. It does not claim any unrun gate passed. Root owns
serial CPU3 targets and installation. Use the final selected checked attempt;
an earlier prototype's passing gates do not qualify a later source change.

## Reused methods and exact command arrays

From the repository root, prepare the existing methods for an actual selected
attempt (replace `checked-final01` if the selected attempt already has a name):

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase67/latency/prepare-final-methods.py --attempt selfhost/build/phase67/checked-final01 --out selfhost/build/phase67/qualification-method01
```

The resulting `qualification-method01/methods.json` contains seven exact command
arrays, in dependency order. Only four existing JavaScript gate methods and the
existing bootstrap factory are copied, with recorded output-boundary edits.
The compiler pin, source/API checks, 99 roots, tiny/unsplit oracle, eight driver
observations, own-source verdict and fixed-point checks remain unchanged.

1. **Checked B1 and strict36.** Runs the maintained workflow with equality
   profile7 and a fresh attempt. Skip this command if the final selected attempt
   already passed; never rebuild merely to obtain another directory name.
2. **Prepare B2 plan, then run it.** The old export admission remains valid only
   because the actual host driver and 99 export declarations are unchanged.
   The factory checks this, then runs tiny/full generation, B1/B2 driver
   comparison and pins the actual emitted B2. C output comparison is fresh and
   compares new B1 with new B2, not with old C bytes.
3. **Fresh actual-B2 own-source check and exact B2/B3 reproduction.** The former
   still expects unsafe proof-trust refusal, separately from type acceptance.
4. **Fresh B1 JS23 acquisition and B2 JS23/45 byte equality.** These compile the
   23 benchmark sources once per generation. The existing row observer and
   45-point mapping remain unchanged. Compare B1 module identities against
   `selfhost/build/phase66/b1-07-full-acquisition/manifest.json` before reusing
   prior generated-program timing. This is an output gate, not a new timing.

Every target command owns one existing guard. Do not put the bootstrap shell
queue or the program-acquisition controller inside a second memory guard.
Keep the orchestration parent unpinned; individual targets use CPU3.

## What can be retained without rerunning thousands of tests

Run this CPU0 source/data audit after the final checked build:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase67/latency/unchanged-js.py --baseline selfhost/build/phase66/checked-b1-07 --candidate selfhost/build/phase67/checked-final01 --out selfhost/build/phase67/unchanged-js-final01.json
```

It requires only `src/back/native/bridge.bend` and `direct.bend` to differ in the
checked snapshots. Host, Base, runtime/provider files and all other source
files must match. Using the already reviewed conservative generated-code
scanner, it requires exact runtime/public wrappers and every generated function
reachable from all 98 public roots except `nc_compile`; it separately checks
the frontend driver's 51 conservative roots. A failed audit stops reuse; do
not weaken it to assume identical behavior from identical function names.

A passing audit justifies retaining Phase66's finite frontend3174 and primary
JS1170 outcomes and their explicit shared failure/graphics/exemption limits.
Actual B2 remains freshly qualified as above. Exact JS23/45 bytes justify
retaining the old generated-program speed observation for those programs and
that unchanged runtime; they do not constitute a fresh performance campaign.
Existing Base permission and cache semantics can retain their prior evidence
under the same unchanged executable/host closure, while actual new-image cache
creation and ordinary host use are exercised by bootstrap and release gates.

**Changed native output cannot inherit old native results just because its
runtime is unchanged.** Fresh focused ownership/numeric/error controls, native
benchmark execution including held-out families, and applicable maintained
native checks qualify the selected implementation. Any old native cases not
reexecuted or shown byte-identical remain historical observations. Retain the
13 unsupported native methods; this patch adds no API support.

## Compilation-speed protection

Keep compilation timing separate from native executable timing. The existing
Phase66 `latency-method05` can run Numeric/Map with two roles and two rotated
rounds, giving eight workers for B1 and eight for B2. Preparation stays outside
clocks, the new candidate uses its actual checked/emitted identity, and every
output is compared with the freshly qualified oracle. A path-only method clone
must preserve old immutable admission paths and update its explicit profile
hash after relocation; blanket `phase66` replacement is invalid.

The data-only `latency/prepare-screen.py` factory now provides that clone and
fresh role bindings. Supply the selected `--attempt`, passing `--closure`,
`--image b1` and a fresh `--out`. For B2, use `--image b2` plus the actual
`--image-pins` and passing 23-source `--b2-equality` report. Its `recipe.json`
contains exact preparation, screen and analysis command arrays. The preparation
and screen controllers each own their guard; run the arrays sequentially.
The baseline is the actual selected Phase66 B1 or B2 respectively. The factory
retains the matching historical qualified raw outputs through the checked
non-native closure; B2 additionally requires fresh full-module equality.
Preparation and every timed sample compare the newly emitted full modules with
those pinned references. This is narrower than executing the generated programs
again, and the receipt states that limit.

This small screen protects against a material regression; it cannot refresh the
23-source 1.402×/1.321× headline or prove a tiny percentage improvement. Do not
rerun the full broad timing campaign unless the screen reveals a material
problem. Native source additions can change image loading/JIT costs despite
an unchanged non-native executable closure, so source identity alone does not
prove unchanged compiler latency.

## Install and verify the actual selected release

Once selected native controls, unchanged-JS admission, selfhosting, output gates
and latency screen close, reverify the seven preserved installed artifacts and
110 inherited unrelated files. Then use the existing packager on the final
attempt; it constructs a new coherent release inventory from that attempt:

```sh
python3 selfhost/tools/performance/phase46/job.py --out selfhost/build/phase67/release-final01/install --seconds 300 -- /home/ai/.nvm/versions/node/v24.18.0/bin/node --stack-size=4096 --max-old-space-size=1024 selfhost/tools/development/release.mjs --install-attempt selfhost/build/phase67/checked-final01
```

Run `release.mjs --verify` before and after installed-interface tests, each under
its own `phase46/job.py` guard and fresh output directory. Reuse these unchanged
controllers with new Phase67 output paths and the **new** hashes read from the
selected attempt/bootstrap/runtime:

| Gate | Existing controller arguments after Node flags |
| --- | --- |
| legacy42 | `selfhost/tools/performance/phase66/release/legacy-release-smoke-launch-v1.mjs SELFHOST NEW_OUT NEW_API_SHA` |
| default24 | `selfhost/tools/performance/phase66/release/default-release-smoke-v1.mjs SELFHOST NEW_OUT NEW_API_SHA NEW_SOURCE_SHA DIRECT_RUNTIME_SHA` |
| helper5 | `selfhost/tools/performance/phase66/release/helper-integrity-v1.mjs SELFHOST SELECTED_ATTEMPT_JSON NEW_OUT` |

Use `SELFHOST=/home/ai/bend2/build/publish/bend/selfhost`. Native CLI gates require
the existing Clang16 `CC`, `CPATH`, `LIBRARY_PATH` and `LD_LIBRARY_PATH` settings
from Phase66's release recipe. The controllers accept fresh Phase67 output paths;
their historical names do not mean historical outcomes are reused. Helper5
uses a copied release and does not mutate installed files. No old manifest or
old API hash should be relabelled as the selected release.

Finally record maintained source/module changes and new image sizes, preserve
all failed candidates and raw evidence, and commit/push the selected compiler,
coherent release, proof artifact and report together. No PR comment is part of
this task.
