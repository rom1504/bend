# Phase90 native compiler and runtime migration

This directory separates historical producer evidence from the assets needed by
a normal compiler request. `native.py` is the new native launcher after
`native-admission.json` exists. The Phase89 native launcher and its receipts are
retained as historical evidence; they do not select the Phase90 compiler.

The compiler itself is written in Bend. Python authenticates its selected files,
passes command-line arguments, and bounds execution. A request does not start
Node, compile the compiler, or reconstruct historical experiments.

## Compile and restore

From the repository root, after final admission:

```sh
python3 -B selfhost/tools/performance/phase90/runtime-migration01/native.py input.bend -o output.c
```

The entry accepts one source importing `Base` and the nine admitted IO effects.
Use `--live` to prepare Base normally rather than use the authenticated immutable
Base carrier. `--calls 5` repeats the same request in one process and requires all
five complete C outputs to agree before publishing the first. `--seconds 300`
increases the guarded request deadline. Existing
output files are refused. Request output, diagnostics and process receipts remain
under `selfhost/build/native/requests/` on success or failure.

The selected native binary is specific to the qualified Linux host. The carrier
binds source locations, so restoration requires the recorded checkout path.
This is not a relocatable distribution or a claim of complete language, GPU or
parallel-runtime qualification.

The compact public capsule contains the selected binary, Base and carrier,
runtime/template/five runtime parts/nine effects, frozen Bend source, selection
and admission, launcher and its guard dependencies. It excludes large generated
C and the historical 800-file provenance chain, which remain in the experiment
evidence capsules.

```sh
python3 -B selfhost/tools/performance/phase90/runtime-migration01/public-assets.py restore selfhost/tools/performance/phase90/runtime-migration01/public-assets01/receipt.json --verify-only
python3 -B selfhost/tools/performance/phase90/runtime-migration01/public-assets.py restore selfhost/tools/performance/phase90/runtime-migration01/public-assets01/receipt.json
```

The first command validates all archived bytes and modes without writing. The
second restores missing files atomically, refuses changed existing bytes or
permissions, and retains at least 160 MiB disk headroom. Neither runs a compiler.
The capsule, manifest and receipt must be obtained from the reviewed repository
revision together.

For benchmark harnesses, importing `native.py` provides
`load(pointer, live=False) -> (admission, binding)` and
`native_args(admission, source, prefix, calls=1, live=False) -> argv`.
Authenticate once before a batch, run guarded children serially, and authenticate
again afterward. `calls` is 1 or 5. Request timing excludes host authentication;
report end-to-end process time separately.

## Maintainer pipeline

All commands below are distinct gates, not implicit work performed by the public
launcher. Run target jobs serially under the existing guard. Preserve failed
attempt directories and create a fresh output directory for every attempt.

1. `freeze.py` preserves exactly the three old canonical runtime/template/driver
   files before migration. Historical receipts keep their original identities;
   `support.py` permits only these explicit frozen-path substitutions.
2. `prepare-transport-v2.py READY OUT` authenticates the new scanner-produced
   runtime chunks and freezes the nine effect files. The original script's
   receipt-schema rejection is retained; v2 verifies receipt file/hash against
   independently pinned full identities.
3. `run.py TRANSPORT OUT` asks the already qualified diagnostic native06 compiler
   to emit unchanged Bend source D04 using the new runtime. The separate genuine
   JS B2 emitter emits the same source with the same new runtime. Full generated
   C equality is required before building native07.
4. `bind-image-v2.py NATIVE_REPORT JS_REPORT JS_GUARD BUILD_GUARD IMAGE`
   binds the actual unpatched C, successful Clang command, binary, source and
   both independent producers. It preserves actual optimization flags.
5. `run-image-v3.py IMAGE BUILD_RECEIPT OUT --oracle EXPECTED_C --seconds 240`
   checks actual native07 self emission. The earlier `run-image-v2.py` is still
   valid for its recorded positive self-emission run; v3 corrects expected-error
   handling without changing positive success requirements.
6. `qualify-v2.py IMAGE BUILD_RECEIPT CONTROLS OUT` runs eight live/cached exact-C
   controls, two compiler rejections, and builds and executes four generated
   programs. An expected rc1 is a finalized unsuccessful process with no guard
   stop, the required diagnostic, and no output C. It is not a successful
   compilation or a timeout waiver.
7. `admit-v2.py IMAGE BUILD_RECEIPT SELF_REPORT QUALIFICATION RELEASE_DIR`
   rechecks the actual completed gates, writes the final admission under
   `selfhost/build/native/releases/`, and exclusively creates
   `native-admission.json`. It does not run targets or infer a pass from a plan.
8. `public-assets.py seal POINTER CAPSULE_DIR` seals the selected request assets.
   Use `public-assets01` for the first finalized capsule, then verify it with the
   restoration command above. Publish the capsule, receipt, manifest and methods
   together.

`qualify.py`, `admit.py`, and `run-image-v2.py` preserve the pretarget expected-rc1
review error. `expected-rejection-guard-v2.derivation.json` records the corrected
fresh methods; no recorded success or failure was rewritten. Offline status and
archive controls are in
`implementation/phase90/public-assets-method-controls.json`.

`cli-controls.py POINTER CONTROLS FRESH_OUT` exercises cached Small, live file IO,
five repeated Map requests, refusal to overwrite an output, refusal of a changed
admission digest, and invalid syntax through the actual public CLI. Compiler
children use the launcher's existing guard; do not put a second execution-lock
guard around the whole script.
