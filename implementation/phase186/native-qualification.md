# Phase186 native qualification and use

The maintained source checkpoint is `86915d9`. Independent source checks, actual
native reproduction, finite semantic qualification and measured runtime are
separate evidence. The installed Phase183 selection is unchanged; the following
are explicitly qualified native candidates.

| Property | QBE | Direct AMD64 |
|---|---:|---:|
| Maintained source bytes | 3,213,774 | 1,589,782 |
| Generated compiler text bytes | 128,840,843 | 126,155,667 |
| N1/N2/third-emission text identity | exact | exact |
| N1/N2 assembly and object identity | exact | exact |
| Finite current catalog | 64/64 | 64/64 |
| Unsupported cases in that catalog | 0 | 0 |
| Extra current runtime controls | — | 10/10 |
| Native45 independent outputs | 45/45 | 45/45 |
| Checked hosted / native emitted products | 5/5 | 3/3 |
| Complete N1 build | 205.950 s | 206.457 s |
| Complete N2 build | 191.221 s | 290.135 s |

Both source checks have zero unresolved holes. Neither these checks nor the
finite gates are BendTT proofs. Bootstrap receipts deliberately retain
`semanticsQualified: false`: independent qualification receipts provide the
separate finite semantic evidence. Final ELF files differ, so the exact machine
claim is limited to assembly and object bytes.

The runtime remains sequential ABI11102, AMD64 SysV, one mutator and GPU off.
No unrestricted foreign ABI, parallel, GPU or whole-language guarantee is added.
Prepared Base is used. Build times are single observations and must not be
relabeled as cold whole-pipeline performance or upstream comparisons.

## Use a candidate

From the repository root, use a fresh output directory under the maintained
process-tree/disk guard:

```sh
python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json \
  --image selfhost/build/phase186/release-qbe-chain01/n2/program \
  --image-receipt selfhost/build/phase186/release-qbe-chain01/n2/report.json \
  --host native --stage N2 --target qbe --mode cache \
  --source path/to/program.bend --out path/to/fresh-build --seconds 60
```

For assembly, replace both `release-qbe-chain01` components with
`release-x86-chain01` and set `--target x86`. See the
[maintained workflow](../../docs/self_hosted/workflow.md) for the outer guard.
Do not overwrite immutable or hardlinked generated files.

The existing release command binds JS/C/QBE/x86 to a coherent canonical source
and binds the assembly seed to the selected QBE image. This phase preserves
that publication contract rather than partially replacing the installed selector.
The older qualified Phase185 candidates remain available for comparison and
research workloads where their compilation cost is preferable.

## Receipts

All paths are under `selfhost/build/phase186/`:

- `release-source01/`: exact maintained source and maps for both profiles.
- `source-qbe-check01/`, `source-x86-check01/`: independent source checks.
- `release-qbe-seed01/`, `release-x86-seed01/`: actual fresh frozen-source N0
  images built by the retained Phase185 QBE N2; stages are not relabeled.
- `release-qbe-chain01/report.json`, `release-x86-chain01/report.json`: actual
  N1/N2 and third emission, exact fixed points and machine identities.
- `release-qbe-native64/report.json`, `release-x86-native64/report.json`:
  independent finite semantic gates, including rejection cases.
- `release-x86-runtime10/report.json`: current assembly runtime controls.

- `release-native45-acquire01/report.json`: all 90 native-produced program
  products pass independent complete-output oracles.
- `release-b1-identity01/report.json`: eight exact emitted-byte comparisons
  against independently checked hosted compiler products, with source bindings.

Final timing receipts are linked from the [main report](README.md). Exact duplicate generated
chain text shares the N2 inode after authenticated, journaled deduplication;
every path and byte remains present. Objects, executables, sources and receipts
remain independent.
