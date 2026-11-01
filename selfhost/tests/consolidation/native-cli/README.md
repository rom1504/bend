# Native public CLI continuity

The maintained `tools/build/public-cli.py` assembles a public CLI profile from the canonical source. It adds the existing public option/IO adapter and immutable asset configuration. The only shared declaration changes are `main` and the existing provider-read seam, which checks provider bytes against their declared digest. The original compiler source and installed CLI remain unchanged.

The current construction path emits C through a temporary producer prepared by `tools/build/public-cli-bridge.py`. That producer is the same canonical compiler with its native-C entry and exact-provider permissions for the three authenticated `NativeHost` imports of this public profile. It contains no `NativeHost` foreign declarations itself. The source receipt checks all other bodies and limits the changed declarations to the provider-read, observer and packing predicates. These build-only permissions are absent from the resulting public compiler.

Build the temporary producer with `tools/build/native.py --output-stage N1 --output-protocol native-c-source-v1`. Use its actual image/report and the bridge asset map with `tools/build/request.py --host native --target c --stage N1` to emit the exact public profile. Finally, `tools/build/public-cli-c.py` authenticates those receipts and compiles the unchanged generated C at the preserved Clang `-O2` policy through `src/host/native-c-start.c`. That small startup is the original writable-argv/runtime-option bridge; it contains no compiler implementation. The package has `bend`, `assets/`, and `BUILD.json`, including the operational asset map, Base identity and cache stamp needed for future rebuilds. Construction does not grant qualification or installation.

Every construction command needs one outer resource guard. The source-only recipe at `selfhost/build/consolidation/public-cli-bridge02/jobs.json` binds the current canonical source and records the four pending construction/qualification commands; it does not claim they have run. The direct-QBE public-profile attempt is preserved as a failed alternative: non-Base foreign declarations select a conservative empty static pool, expanding repeated literal construction, and its 3 GiB guard stopped partial emission. No runtime or compiler policy was changed to bypass that failure.

Run `controls.py --package FRESH_PACKAGE --cc CLANG --cc-include CLANG_RESOURCE_INCLUDE --out FRESH_CONTROLS` under the same outer resource policy. The controls relocate a copy, preserve both input packages, and check:

- exact help, version, usage and checker refusal;
- two complete C products against the incumbent native CLI, plus independent complete `42\n` execution oracles;
- complete live/cache output equality;
- no overwrite of an existing file;
- refusal of altered Base and effect-provider bytes, followed by exact restoration.

The native qualifier binds the actual image, shared-source profile and package report. These are finite ordinary-CLI gates. They do not claim full conformance, self-reproduction, performance improvement or installation. Every compiler/program subprocess belongs to the root-supervised target lane; preparing these scripts does not run them.
