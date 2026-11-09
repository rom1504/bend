# Phase185 native candidates and qualification boundaries

Both candidates are built from the final maintained source at `e91e03b`.
Independent upstream source checking, native self-reproduction, finite semantic
qualification, and measured program performance are separate evidence.

| Property | QBE | Direct AMD64 assembly |
|---|---:|---:|
| Maintained source bytes | 3,202,029 | 1,525,646 |
| Generated compiler text bytes | 102,207,685 | 105,592,580 |
| N1/N2/third-emission text identity | exact | exact |
| N1/N2 assembly and object identity | exact | exact |
| Current finite qualification | 64/64 | 64/64 |
| Native45 independent output oracles | 45/45 | 45/45 |
| Final checked-B1/native-N2 emitted-byte comparisons | 4/4 | 8/8 |
| Additional current assembly runtime controls | — | 10/10 |
| Complete N1 build, seconds | 195.108 | 165.561 |
| Complete N2 build, seconds | 193.764 | 257.758 |

These build times are single observations with prepared Base. QBE's N0 and
N1 are QBE-built; assembly's N0 is QBE-built and N1 is assembly-built. The
assembly column therefore exposes a same-source executable-performance gap:
the assembly-built compiler takes 1.56× the complete build time of its QBE-built
producer. It is not a controlled before/after compilation-speed gain, a cold
whole-profile benchmark, or an upstream comparison. Final ELF files differ;
the report claims exact emitted text/assembly/objects, not exact ELF identity.

The bootstrap receipts deliberately say `semanticsQualified: false`: that tool
only establishes reproduction. The separate current 64-case qualification
receipts supply the finite semantic evidence, with zero unsupported cases.
Neither these gates nor the executable descriptor facts are BendTT proofs.
No unrestricted foreign ABI, parallel, GPU, or whole-language correctness claim
is added.

## Use the qualified candidates explicitly

The installed Phase183 JS/C/QBE/x86 selection is unchanged. The maintained
release command binds all selected targets to one canonical source and binds
the assembly seed to the selected QBE image. Publishing only these two new
images would bypass those existing cross-target release conditions. This phase
qualifies named QBE/x86 candidates without relaxing the publication contract
or spending another campaign rebuilding unrelated JS/C images.

For QBE, use the maintained native build command with a **fresh** output path:

```sh
python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json \
  --image selfhost/build/phase185/release-qbe-chain01/n2/program \
  --image-receipt selfhost/build/phase185/release-qbe-chain01/n2/report.json \
  --host native --stage N2 --target qbe --mode cache \
  --source path/to/program.bend --out path/to/fresh-build --seconds 60
```

For assembly, replace both `release-qbe-chain01` components with
`release-x86-chain01` and set `--target x86`. Run actual build/benchmark jobs
under the maintained process-tree/disk guard as documented in
[the workflow](../../docs/self_hosted/workflow.md). Do not overwrite immutable
products or hardlinked emitted text.

## Retained receipts

All paths below are under `selfhost/build/phase185/`:

- `release-source03/`: canonical QBE and selected x86 source and maps.
- `source-qbe-check01/`, `source-x86-check01/`: independent source checks.
- `release-qbe-chain01/report.json`, `release-x86-chain01/report.json`:
  actual native N0 → N1 → N2 → third-emission chains.
- `release-qbe-native64/report.json`, `release-x86-native64/report.json`:
  current finite semantic gates, including rejection cases.
- `release-native45-acquire01/report.json`: native N2-built executables,
  independent exact output/count oracles and pinned machine-tool identities.
- `release-b1-identity01/report.json`: 12 final byte comparisons; no whitespace
  or newline normalization.
- `release-x86-runtime10/report.json`: ten current runtime controls, including
  array, character, argument, file and valid exit behavior.
- `release-full45-runtime02/report.json`: final native-produced program timing;
  three rotated rounds with C as the explicit runtime denominator.

The QBE N0 seed was archived and authenticated after its chain and qualification
succeeded, under `selfhost/build-retention/phase185/release-qbe-seed01-close/`.
Its original hot paths are intentionally absent; replaying its historical
input checks requires restoration. Both N2 images, their binding receipts,
the full chain products and all measured programs remain available. Two exact
duplicate text copies per chain share the N2 text inode: paths and bytes remain
unchanged, recovering about 396 MiB without deleting unique evidence.
