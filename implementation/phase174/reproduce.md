# Reproduce the Phase171 publication

Run from the repository root. Compiler and program jobs use the maintained
resource guard, one CPU3 lane, explicit artifacts and fresh output roots.
The scripts below are release evidence/orchestration, not compiler algorithms.

## Source

```sh
python3 -B selfhost/tools/build/source.py assemble \
  --manifest selfhost/src/compiler.json --root selfhost --profile qbe \
  --out selfhost/build/reproduce174-source/compiler.bend \
  --map selfhost/build/reproduce174-source/map.json
```

Canonical identity: 3,161,409 bytes, SHA256
`74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.
It is exactly the earlier Phase171 candidate. The original fixed benchmark input
is 3,150,535 bytes/SHA256
`434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
Do not substitute one for the other in a timing comparison.

## Acquisition and gates

The [native plan](../../experiments/phase174/native-acquisition-plan.json) and
[continued plan](../../experiments/phase174/native-acquisition-retry-plan.json)
record exact targets, budgets and independent inputs. The original genuine
Phase171 N1 is reused by authenticated image/source identity; it is not relabeled
as newly built. A fresh N2 and actual Q3 establish exact QBE reproduction.

The [qualification plan](../../experiments/phase174/qualification-plan.json)
contains checked hosted API acquisition, native64, both 45-product lanes,
positive native and hosted sessions, genuine JS B2/B3, JS45/public/refusal/C
controls, and native public C acquisition/qualification. A fresh workflow may
use maintained `bootstrap.py` to acquire the whole native chain rather than
requiring the historical N1 artifact. Keep actual generation labels.

`selfhost/tests/phase174/prepare-controls.py` appends only the unchanged finite
controls to the canonical source. `collect-controls.py` authenticates the 77
observations; these are finite checks, not BendTT theorems.

The first ELF check remains a retained failure. `elf-audit.py` and
`reproduction-v2.py` establish the exact code/data equality with explicitly
reported section-table-offset/build-id metadata differences. They are
comparators for the recorded artifact pair, not generic permission to ignore
changed executable bytes. See the [audit](../../experiments/phase174/elf-audit.md).

The [fixed-input timing plan](../../experiments/phase174/fixed-comparison-plan.json)
uses the same original source path, Base preparation, runtime, toolchain and CPU
as the historical pair. Run it before changing the old installed reference or
explicitly bind the retained old image/receipt. Candidate runs first, then
baseline, with fresh processes and one observation each. OS caches are not flushed.

## Publication

`prepare-release.py` writes explicit receipt bindings for the unchanged Phase170
promotion assembler. The maintained `release.py` audits and installs with a
selector-last transaction and retained rollback. The selector helper updates
only the QBE image/API rows in the three operational asset maps. Installed
default native, hosted, session and public commands receive separate smoke checks.

Use fresh output directories; do not overwrite historical reports or simply
relabel old images as fresh generations. Runtime/Base/toolchain pins remain
unchanged. No upstream migration or PR comment is part of this publication.
