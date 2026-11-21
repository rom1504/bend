# Build ordinary programs with the scan-enabled native compiler

From the `build/publish/bend` checkout, run the following command in an allocated CPU 3 slot. Supply a fresh name and the path to an ordinary Bend source file. The driver writes the linked ELF executable to `selfhost/build/phase199/<name>/program`.

```sh
python3 -B research/phase199/native-use/program.py \
  --name native-use-local-fold01 \
  --source selfhost/tests/consolidation/native-broad/local-fold.bend \
  --expected-stdout selfhost/tests/consolidation/native-broad/local-fold.stdout \
  --run
```

With `--expected-stdout`, the driver executes the produced program and checks every output byte. Omit the option for a build-only request. Use `--variant original` for the original ABI 11102 runtime with the same scan helper. The default uses the Phase198 live runtime with the helper. User programs share one prelinked runtime per variant.

`program.py` reads the image binding in `selfhost/build/phase198/p199-integrated-native-image01/report.json`, authenticates the actual N1 executable, compiler source, scan composition and runtime, and submits an ordinary direct-object request to `selfhost/tools/build/native.py`. Running without `--run` prints the exact guarded and native argv without invoking the compiler. Add `--recipe-out new.json` to retain the argv with the input SHA-256 digests. `--inspect-existing` checks a finished request and reports whether its emitted object references the helper. The native pipeline receives these explicit arguments alongside its input and fresh output paths.

```text
--host native --stage N1 --target x86 --mode cache --emit object
--runtime selfhost/build/phase199/runtime-bundle01/runtime-live-scan.o
--runtime-abi 11102 --runtime-argument-convention bend-rts-v1
```

## Prepare the runtime bundles once

The one-time packaging job takes the two authenticated ABI 11102 runtimes and the checked SSE2 scan helper from the Phase198 and Phase199 experiments. From the same checkout, a fresh campaign can run the following job through the disk and process guard.

```sh
python3 -B research/phase199/screen/job.py runtime-bundle01 4 3 \
  python3 -B research/phase199/native-use/bundle.py \
  --out selfhost/build/phase199/runtime-bundle01
```

The pinned GNU linker combines each pair of ELF64 x86-64 objects with `ld -m elf_x86_64 -r`. Both completed packages preserve the 69 original public definitions, with matching binding, symbol type, visibility, size, section type and symbol payload bytes. All 85 original imports match. Each package adds exactly the 367-byte global function `p199_rt_u32_scan4` from the checked helper object. The generated program links the selected bundle through the native driver's usual linker and libraries. These are explicit research runtime objects.

| Bundle | Bytes | SHA-256 |
| --- | ---: | --- |
| `runtime-live-scan.o` | 128872 | `1c819e63386e8bf7c392f3fa13509699b0f4d99867cf26d8777042350522cda8` |
| `runtime-original-scan.o` | 125920 | `f6b444f3e2d5c1e9e1f3a495ab97dd8731ebb93eb2b7ef3baebd12a20ea8dd8c` |

The [package receipt](evidence/bundle-report.json.gz) records the input provenance, system linker identity, both argv lists and each ELF symbol checked. The [guard](evidence/bundle-process.json) and [retention closure](evidence/bundle-close.json) record the bounded execution. The [runtime leaf controls](../scan-runtime/README.md) describe the independent state checks, generated-worker contract and SysV ABI.

## Acquired N1 and ordinary inputs

The [ordinary IO recipe](evidence/ordinary-io-recipe.json) binds the 19,068,032-byte scan-enabled N1, SHA-256 `4c5ef960f02e803826801dcc47f12b1cbed2261708440a02d6707d1739cab0de`. The native driver's [accepted build plan](evidence/ordinary-io-plan.json.gz) authenticates the ordinary IO fixture, direct-object protocol and explicit live runtime. This plan performed zero compiler, linker or execution jobs.

The existing native45 acquisition separately compiled the catalog's `local-fold.bend` with that N1, linked the original-plus-scan bundle and ran the independent observation. Its 99,400-byte emitted object contains one `R_X86_64_PLT32` text relocation to `p199_rt_u32_scan4` at offset `0x3e44`. The executable returned zero and printed `2339999928`, followed by the three expected catalog counters. The existing broad preparation also linked the identical emitted object with the live-plus-scan bundle used by the ordinary recipe and verified the identical four output lines with zero exit and empty stderr. The [catalog execution evidence](evidence/native45-local-fold.json) identifies the distinct source entry, generated object, runtime, complete output and acquisition receipts.
