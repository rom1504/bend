# Public x86 routing controls

`selfhost/bend --target x86 FILE -o program.s` emits assembly. An output without
the `.s` suffix builds an ELF; `--run [-- ARGS]` builds and executes it. `--live`
selects live Base preparation. `cli.mjs` also delegates explicit `--target x86`
and implicit `-o program.s` to this route. Existing outputs (including symlinks)
are refused, and the output directory must already exist. Ordinary native C and
JavaScript requests retain their existing routes.

The helper authenticates `current.components.x86` as native N2 with protocol
`native-x86-source-v1`, its installed image and source identity, operational
`x86-n2`, Base, runtime object, ABI11102 and image/runtime argument conventions.
The machine path uses the explicit `toolchains.x86`, assembler and linker; no
QBE executable is used. All compiler work is done by the selected Bend image.

Ten public controls check independent literal output42, assembly syntax and an
independent assemble/link/run, ELF/run, protected program arguments, both JS
shell delegation forms, type refusal, source/output preservation and dangling
symlink refusal. Run only after a qualified x86 selector and operational assets
are installed in the workspace under test:

```sh
python3 -B selfhost/tests/phase183/job.py public-x86-01 600 512 \
  python3 -B selfhost/tests/phase183/public-x86.py \
  --out selfhost/build/phase183/public-x86-01
```

The gate sets the directory-only `BEND_PUBLIC_BUILD_ROOT` to its own `scratch/`
so transient builds are inside the declared disk guard root. The helper confines
this optional directory to `selfhost/build/` and removes each temporary build.
It does not select a compiler, runtime or asset manifest.

Metadata tests do not execute a compiler or generated target:

```sh
(cd selfhost/tools/build && python3 -B test_public_x86.py)
```
